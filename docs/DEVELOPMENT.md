# Como Adicionar Nova Ferramenta — VITRUVIUS V2

Passo-a-passo para implementar qualquer ferramenta Revit no VITRUVIUS.

## 1. Planejar

Antes de codificar:
- ✓ Qual API do Revit usar? (ElementTransformUtils, FilteredElementCollector, etc)
- ✓ Que parâmetros JSON recebo? (element_id, angle_degrees, etc)
- ✓ Que erros podem acontecer? (elemento não existe, tipo incompatível, etc)
- ✓ Precisa Transaction? (sim, quase sempre)

## 2. Criar Arquivo de Comandos

**Arquivo:** `src/VitruviusAddin/Commands/MinhaFerramenta​Commands.cs`

```csharp
using System.Text.Json;
using Autodesk.Revit.DB;

namespace VitruviusAddin;

public static class MinhaFerramenta​Commands
{
    /// Descrição breve da ferramenta
    public static string Acao(Document doc, JsonElement args)
    {
        // 1. Extrair parâmetros
        var parametro1 = GetString(args, "parametro1");
        var parametro2 = GetLong(args, "parametro2");
        
        // 2. Validar entrada
        if (string.IsNullOrEmpty(parametro1))
            return Err("parametro1 é obrigatório");
        if (!parametro2.HasValue || parametro2 <= 0)
            return Err("parametro2 deve ser um número > 0");
        
        try
        {
            // 3. Abrir Transaction
            using var trans = new Transaction(doc, "Vitruvius: descrição da ação");
            trans.Start();
            
            // 4. Buscar elemento(s)
            var elemento = doc.GetElement(new ElementId(parametro2.Value));
            if (elemento == null)
            {
                trans.RollBack();
                return Err($"Elemento {parametro2} não encontrado");
            }
            
            // 5. Validar tipo/compatibilidade
            if (!(elemento is Wall wall))
            {
                trans.RollBack();
                return Err("Elemento deve ser uma parede");
            }
            
            // 6. Executar operação
            // wall.SetParameter(...);
            // ElementTransformUtils.MoveElement(...);
            
            // 7. Commit
            trans.Commit();
            
            // 8. Retornar sucesso
            return Ok(new
            {
                status = "sucesso",
                elemento_id = elemento.Id.Value,
                propriedade = "valor"
            });
        }
        catch (Exception ex)
        {
            return Err($"Erro: {ex.Message}");
        }
    }
    
    // Helpers
    private static string GetString(JsonElement args, string name) =>
        args.TryGetProperty(name, out var prop) && prop.ValueKind == JsonValueKind.String
            ? prop.GetString()
            : null;
    
    private static long? GetLong(JsonElement args, string name) =>
        args.TryGetProperty(name, out var prop) && prop.ValueKind == JsonValueKind.Number
            ? (long?)prop.GetInt64()
            : null;
    
    private static double? GetDouble(JsonElement args, string name) =>
        args.TryGetProperty(name, out var prop) && prop.ValueKind == JsonValueKind.Number
            ? (double?)prop.GetDouble()
            : null;
    
    private static string Ok(object data) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = true, result = data });
    
    private static string Err(string message) =>
        System.Text.Json.JsonSerializer.Serialize(new { ok = false, error = message });
}
```

## 3. Registrar no Dispatcher

**Arquivo:** `src/VitruviusAddin/RevitCommandHandler.cs`

Adicione ao switch statement:

```csharp
Response = Job.Action switch
{
    "load_family" => FamilyCommands.LoadFamily(doc, Job.Args),
    "rotate_element" => RotateCommands.RotateElement(doc, Job.Args),
    "minha_ferramenta" => MinhaFerramenta​Commands.Acao(doc, Job.Args),  // ← ADICIONAR AQUI
    _ => JsonResult(false, $"Ação desconhecida: '{Job.Action}'")
};
```

## 4. Adicionar Método MCP

**Arquivo:** `src/VitruviusMcp/RevitTools.cs`

```csharp
[McpServerTool(Name = "minha_ferramenta")]
[Description("Descrição clara do que essa ferramenta faz no Revit")]
public static Task<string> MinhaFerramenta(string parametro1, long parametro2)
{
    return Call("minha_ferramenta", new { parametro1, parametro2 });
}
```

## 5. Criar Teste HTTP

**Arquivo:** `tests/http-tests/NN-minha_ferramenta.ps1`

Numere sequencialmente (01, 02, 03...):

```powershell
# Teste: Minha Ferramenta
# Descrição: Testa se a ferramenta executa corretamente

$body = @{
    action = "minha_ferramenta"
    args = @{
        parametro1 = "valor_teste"
        parametro2 = 12345
    }
} | ConvertTo-Json

Write-Host "Testando minha_ferramenta..."
Write-Host "Request: $body`n"

try {
    $response = Invoke-WebRequest -Uri "http://localhost:48884/" `
        -Method Post `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    $result = $response.Content | ConvertFrom-Json
    
    if ($result.ok) {
        Write-Host "✅ Sucesso!" -ForegroundColor Green
        Write-Host "Resposta: " + ($result.result | ConvertTo-Json -Depth 3)
    } else {
        Write-Host "❌ Erro: $($result.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Falha na requisição: $_" -ForegroundColor Red
}
```

## 6. Compilar

```powershell
cd D:\011_VITRUVIUS_V2\src\VitruviusAddin
dotnet build -c Release -o bin/Staging
```

**Verificar:**
- ✓ "0 Erros" na saída
- ✓ `bin\Staging\VitruviusAddin.dll` existe
- ✓ Deletar `bin\Release` se existir

## 7. Deploy

```powershell
# Parar RevitAccelerator
Stop-Process -Name "RevitAccelerator" -Force -ErrorAction SilentlyContinue

# Copiar DLL
Copy-Item "D:\011_VITRUVIUS_V2\src\VitruviusAddin\bin\Staging\VitruviusAddin.dll" `
    "C:\ProgramData\Autodesk\Revit\Addins\2026\" -Force

# Reiniciar Revit
```

## 8. Testar HTTP

```powershell
# (Revit deve estar aberto com documento ativo)
cd D:\011_VITRUVIUS_V2
.\tests\http-tests\NN-minha_ferramenta.ps1
```

Esperado:
- `"ok": true`
- `"result": { ... dados ... }`

Erro típico:
- `"ok": false, "error": "Ação desconhecida: 'minha_ferramenta'"` → Falta registrar no dispatcher

## 9. Testar no Revit

1. Abra o Revit com documento ativo
2. Crie/selecione um elemento de teste (parede, porta, etc)
3. Execute o comando manualmente se houver botão, OU
4. Chame via HTTP e valide no Project Browser/Properties

**Checklist:**
- ✓ Elemento foi modificado?
- ✓ Nenhum erro apareceu?
- ✓ Project Browser reflete as mudanças?

## 10. Documentar

Adicione à `docs/TOOLS.md`:

```markdown
### minha_ferramenta

**Descrição:** Faz tal coisa com tal elemento

**Parâmetros:**
- `parametro1` (string): Descrição
- `parametro2` (long): Descrição

**Retorno:**
```json
{
  "ok": true,
  "result": {
    "status": "sucesso",
    "elemento_id": 12345
  }
}
```

**Status:** ✅ Implementado e testado

**Data:** 08/08/2026
```

## Checklist Final

- [ ] Arquivo `Commands/*Commands.cs` criado
- [ ] Método implementado com validações
- [ ] Case adicionado em `RevitCommandHandler.cs`
- [ ] MCP method adicionado
- [ ] Teste PowerShell criado em `tests/http-tests/`
- [ ] Compilação sem erros
- [ ] DLL copiada para add-ins
- [ ] Teste HTTP passou
- [ ] Teste visual no Revit confirmado
- [ ] Documentado em `docs/TOOLS.md`

---

**Tempo estimado:** 30 minutos a 2 horas (dependendo da complexidade)
