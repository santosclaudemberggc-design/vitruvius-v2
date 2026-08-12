using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

// ============================================================================
// VITRUVIUS MCP — servidor MCP (Model Context Protocol) por stdio.
//
// O que ele faz:
//   Quando o Claude (rodando no SEU computador) quer usar uma ferramenta do
//   Revit, ele fala com este programa via stdin/stdout (protocolo MCP,
//   JSON-RPC 2.0). Este programa traduz o pedido em uma requisição HTTP para
//   o add-in do Revit (HttpBridge, que escuta em http://localhost:48884/) e
//   devolve a resposta.
//
//   Claude (local)  <-- stdio/MCP -->  VitruviusMcp  <-- HTTP -->  Revit add-in
//
// Importante:
//   - Este servidor só funciona no MESMO computador onde o Revit está aberto,
//     porque "localhost:48884" só é acessível localmente.
//   - Toda a comunicação MCP acontece pelo stdout; por isso NENHUMA mensagem
//     comum é escrita no stdout (logs vão para o stderr).
// ============================================================================

var baseUrl = Environment.GetEnvironmentVariable("VITRUVIUS_URL") ?? "http://localhost:48884/";

// Streams UTF-8 sem BOM para não corromper acentos nem quebrar o protocolo.
var stdout = new StreamWriter(Console.OpenStandardOutput(), new UTF8Encoding(false)) { AutoFlush = true };
var stdin = new StreamReader(Console.OpenStandardInput(), new UTF8Encoding(false));

using var http = new HttpClient { Timeout = TimeSpan.FromSeconds(60) };

var jsonOpts = new JsonSerializerOptions
{
    DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
};

// Definição das ferramentas expostas ao Claude (nome, descrição, schema).
object[] tools = BuildToolDefs();

Console.Error.WriteLine($"[vitruvius-mcp] iniciado. Falando com o Revit em {baseUrl}");

string? line;
while ((line = stdin.ReadLine()) != null)
{
    if (string.IsNullOrWhiteSpace(line)) continue;

    JsonDocument doc;
    try { doc = JsonDocument.Parse(line); }
    catch { continue; } // ignora linhas que não são JSON válido

    using (doc)
    {
        var root = doc.RootElement;
        var method = root.TryGetProperty("method", out var mEl) ? mEl.GetString() : null;
        var hasId = root.TryGetProperty("id", out var idEl);
        // Clonamos o id porque o JsonDocument é liberado ao fim do bloco.
        JsonElement id = hasId ? idEl.Clone() : default;

        if (method == null) continue;

        try
        {
            switch (method)
            {
                case "initialize":
                {
                    // Devolvemos a mesma versão de protocolo que o cliente pediu.
                    var protocolVersion = "2024-11-05";
                    if (root.TryGetProperty("params", out var p) &&
                        p.TryGetProperty("protocolVersion", out var pv) &&
                        pv.ValueKind == JsonValueKind.String)
                        protocolVersion = pv.GetString()!;

                    WriteResult(id, new
                    {
                        protocolVersion,
                        capabilities = new { tools = new { } },
                        serverInfo = new { name = "vitruvius", version = "1.0.0" }
                    });
                    break;
                }

                case "ping":
                    WriteResult(id, new { });
                    break;

                case "tools/list":
                    WriteResult(id, new { tools });
                    break;

                // Não expomos resources nem prompts, mas respondemos vazio
                // para não gerar avisos em clientes que perguntam.
                case "resources/list":
                    WriteResult(id, new { resources = Array.Empty<object>() });
                    break;
                case "resources/templates/list":
                    WriteResult(id, new { resourceTemplates = Array.Empty<object>() });
                    break;
                case "prompts/list":
                    WriteResult(id, new { prompts = Array.Empty<object>() });
                    break;

                case "tools/call":
                {
                    var p = root.GetProperty("params");
                    var name = p.GetProperty("name").GetString() ?? "";
                    var argsRaw = "{}";
                    if (p.TryGetProperty("arguments", out var a) && a.ValueKind == JsonValueKind.Object)
                        argsRaw = a.GetRawText();

                    var text = await CallRevit(name, argsRaw);
                    WriteResult(id, new
                    {
                        content = new object[] { new { type = "text", text } }
                    });
                    break;
                }

                default:
                    // notifications/* não têm id e não recebem resposta.
                    if (hasId)
                        WriteError(id, -32601, $"Método não suportado: {method}");
                    break;
            }
        }
        catch (Exception ex)
        {
            if (hasId) WriteError(id, -32603, ex.Message);
            Console.Error.WriteLine($"[vitruvius-mcp] erro em '{method}': {ex}");
        }
    }
}

// Envia a requisição para o add-in do Revit e devolve o corpo da resposta.
async Task<string> CallRevit(string action, string argsRaw)
{
    var payload = $"{{\"action\":{JsonSerializer.Serialize(action)},\"args\":{argsRaw}}}";
    try
    {
        using var content = new StringContent(payload, new UTF8Encoding(false), "application/json");
        using var resp = await http.PostAsync(baseUrl, content);
        return await resp.Content.ReadAsStringAsync();
    }
    catch (Exception ex)
    {
        return JsonSerializer.Serialize(new
        {
            ok = false,
            error = $"Não foi possível falar com o Revit em {baseUrl} ({ex.Message}). " +
                    "Confira se o Revit 2026 está aberto com um projeto e o add-in Vitruvius carregado."
        });
    }
}

void WriteResult(JsonElement id, object result) =>
    stdout.WriteLine(JsonSerializer.Serialize(new { jsonrpc = "2.0", id, result }, jsonOpts));

void WriteError(JsonElement id, int code, string message) =>
    stdout.WriteLine(JsonSerializer.Serialize(new { jsonrpc = "2.0", id, error = new { code, message } }, jsonOpts));

// Lista de ferramentas — precisa espelhar o switch do RevitCommandHandler.cs.
object[] BuildToolDefs() => new object[]
{
    new
    {
        name = "get_selection",
        description = "Retorna o(s) elemento(s) selecionado(s) agora no Revit (id, nome, categoria). " +
                      "Chame isto PRIMEIRO quando o usuário disser 'o elemento selecionado', 'isso que selecionei', " +
                      "'essa parede', etc., sem informar um ID.",
        inputSchema = new { type = "object", properties = new { }, required = Array.Empty<string>() }
    },
    new
    {
        name = "get_parameter",
        description = "Lê o valor de um parâmetro de um elemento do Revit, pelo nome exato do parâmetro " +
                      "(como aparece no painel Propriedades, respeitando idioma e acentos, ex.: 'Comentários').",
        inputSchema = new
        {
            type = "object",
            properties = new
            {
                element_id = new { type = "integer", description = "ID do elemento no Revit" },
                parameter_name = new { type = "string", description = "Nome do parâmetro (ex.: 'Comentários', 'Marca')" }
            },
            required = new[] { "element_id", "parameter_name" }
        }
    },
    new
    {
        name = "set_parameter",
        description = "Define o valor de um parâmetro de um elemento do Revit. O tipo de 'value' deve combinar com " +
                      "o tipo do parâmetro (texto para String; número para Double/Integer).",
        inputSchema = new
        {
            type = "object",
            properties = new
            {
                element_id = new { type = "integer", description = "ID do elemento no Revit" },
                parameter_name = new { type = "string", description = "Nome do parâmetro (ex.: 'Comentários')" },
                value = new { type = new[] { "string", "number", "integer" }, description = "Novo valor do parâmetro" }
            },
            required = new[] { "element_id", "parameter_name", "value" }
        }
    },
    new
    {
        name = "move_element",
        description = "Move um elemento do Revit por um deslocamento em pés (unidade interna do Revit). " +
                      "Informe ao menos um entre dx, dy, dz.",
        inputSchema = new
        {
            type = "object",
            properties = new
            {
                element_id = new { type = "integer", description = "ID do elemento no Revit" },
                dx = new { type = "number", description = "Deslocamento no eixo X, em pés" },
                dy = new { type = "number", description = "Deslocamento no eixo Y, em pés" },
                dz = new { type = "number", description = "Deslocamento no eixo Z, em pés" }
            },
            required = new[] { "element_id" }
        }
    },
    new
    {
        name = "rotate_element",
        description = "Rotaciona um elemento do Revit em torno de um eixo (X, Y ou Z), em graus.",
        inputSchema = new
        {
            type = "object",
            properties = new
            {
                element_id = new { type = "integer", description = "ID do elemento no Revit" },
                angle_degrees = new { type = "number", description = "Ângulo de rotação em graus" },
                axis = new { type = "string", description = "Eixo de rotação: 'X', 'Y' ou 'Z' (padrão 'Z')" }
            },
            required = new[] { "element_id", "angle_degrees" }
        }
    },
    new
    {
        name = "load_family",
        description = "Carrega uma família Revit (.rfa) no documento ativo, a partir do caminho do arquivo.",
        inputSchema = new
        {
            type = "object",
            properties = new
            {
                family_path = new { type = "string", description = "Caminho absoluto do arquivo .rfa" }
            },
            required = new[] { "family_path" }
        }
    }
};
