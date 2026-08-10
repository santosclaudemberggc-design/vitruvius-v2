# Arquitetura — VITRUVIUS V2

## Visão Geral

```
┌─────────────────┐
│  Claude        │ (IA que quer automatizar Revit)
│  + MCP          │
└────────┬────────┘
         │
         │ MCP Call: revit_tools.load_family(...)
         │
┌────────▼────────────────────────┐
│  VitruviusMcp.exe              │ (MCP Server)
│  ├─ RevitTools.cs             │ Define ferramentas
│  └─ HttpClient                │ Chama HTTP
└────────┬─────────────────────────┘
         │
         │ POST http://localhost:48884/
         │ { "action": "load_family", "args": {...} }
         │
┌────────▼──────────────────────────────────────┐
│  VitruviusAddin.dll (Revit Add-in)           │
│                                               │
│  ┌──────────────────────────────────────────┐ │
│  │ App : IExternalApplication              │ │
│  │ ├─ OnStartup() → HttpBridge.Start()    │ │
│  │ └─ OnShutdown() → HttpBridge.Stop()    │ │
│  └──────────────────────────────────────────┘ │
│                     │                         │
│  ┌──────────────────▼──────────────────────┐ │
│  │ HttpBridge (HttpListener)              │ │
│  │ ├─ Listen: http://localhost:48884/    │ │
│  │ ├─ Parse JSON request                 │ │
│  │ ├─ Create ExternalEvent               │ │
│  │ └─ Return JSON response                │ │
│  └──────────────────┬──────────────────────┘ │
│                     │                         │
│  ┌──────────────────▼──────────────────────┐ │
│  │ RevitCommandHandler : IExternalEventHandler
│  │ ├─ Job: { Action, Args }              │ │
│  │ ├─ Response: JSON string               │ │
│  │ └─ Execute() → Dispatcher Switch       │ │
│  └──────────────────┬──────────────────────┘ │
│                     │                         │
│        ┌────────────┼────────────┐            │
│        │            │            │            │
│  ┌─────▼────┐ ┌─────▼────┐ ┌────▼─────┐    │
│  │ Family   │ │ Rotate   │ │ Move     │    │
│  │ Commands │ │ Commands │ │ Commands │ ..│
│  └──────────┘ └──────────┘ └──────────┘    │
│        │            │            │            │
│        └────────────┼────────────┘            │
│                     │                         │
│        ┌────────────▼────────────┐            │
│        │  Revit Document (DB)   │            │
│        │  ├─ Families           │            │
│        │  ├─ Elements           │            │
│        │  ├─ Levels             │            │
│        │  └─ ...                │            │
│        └────────────────────────┘            │
└──────────────────────────────────────────────┘
```

## Fluxo Detalhado

### 1. Claude → MCP Server

Claude chama uma ferramenta via MCP:

```python
# Claude (Python/Node.js)
tools.load_family(family_path="/path/to/file.rfa")
```

### 2. MCP Server → HTTP Request

VitruviusMcp.exe intercepta a call e faz HTTP POST:

```csharp
// VitruviusMcp/RevitTools.cs
[McpServerTool(Name = "load_family")]
public static Task<string> LoadFamily(string family_path)
    => Call("load_family", new { family_path });

// Call() → POST http://localhost:48884/
// Body: { "action": "load_family", "args": { "family_path": "..." } }
```

### 3. HttpBridge recebe requisição

```csharp
// HttpBridge.cs - HandleRequest()
var json = await reader.ReadToEndAsync();  // Ler POST body
var doc = JsonDocument.Parse(json);

var action = doc.RootElement.GetProperty("action").GetString();  // "load_family"
var args = doc.RootElement.GetProperty("args");  // { "family_path": "..." }

_handler.Job = new() { Action = action, Args = args };
_event.Raise();  // ← Disparar event no thread principal do Revit
```

### 4. Revit ExternalEvent executa

```csharp
// RevitCommandHandler.cs - Execute()
public void Execute(UIApplication app)
{
    var doc = app.ActiveUIDocument.Document;
    Response = Job.Action switch
    {
        "load_family" => FamilyCommands.LoadFamily(doc, Job.Args),
        "rotate_element" => RotateCommands.RotateElement(doc, Job.Args),
        _ => JsonResult(false, $"Ação desconhecida: '{Job.Action}'")
    };
}
```

### 5. Comando executa dentro de Transaction

```csharp
// FamilyCommands.cs - LoadFamily()
public static string LoadFamily(Document doc, JsonElement args)
{
    using var trans = new Transaction(doc, "Vitruvius: carregar família");
    trans.Start();
    
    // Revit API calls aqui — garantido thread-safe
    doc.LoadFamily(familyPath, out var family);
    
    trans.Commit();
    return Ok(new { family_id = family.Id.Value, ... });
}
```

### 6. Resposta volta via HTTP

```csharp
// HttpBridge.cs - HandleRequest() (continuação)
var response = Encoding.UTF8.GetBytes(_handler.Response);
ctx.Response.ContentLength64 = response.Length;
await ctx.Response.OutputStream.WriteAsync(response);
ctx.Response.Close();
```

### 7. MCP Server recebe resposta

```csharp
// VitruviusMcp/RevitTools.cs - Call()
var response = await _httpClient.PostAsync("http://localhost:48884/", content);
return await response.Content.ReadAsStringAsync();
// {"ok":true,"result":{"family_id":449336,...}}
```

### 8. Claude recebe resultado

```python
result = tools.load_family(family_path="...")
# result = {"ok": true, "result": {"family_id": 449336, ...}}
# Claude pode usar esse resultado no próximo passo
```

## Componentes-chave

### VitruviusAddin.dll (Revit Add-in)

**Projeto:** `src/VitruviusAddin/`  
**Target:** `.NET 8.0-windows`  
**Referências:** RevitAPI, RevitAPIUI  
**Porta:** 48884

| Classe | Responsabilidade |
|--------|------------------|
| `App.cs` | IExternalApplication (startup/shutdown) |
| `HttpBridge.cs` | HttpListener, parse JSON, dispatcher |
| `RevitCommandHandler.cs` | IExternalEventHandler, switch dispatcher |
| `Commands/*Commands.cs` | Implementações de ferramentas |

### VitruviusMcp.exe (MCP Server)

**Projeto:** `src/VitruviusMcp/`  
**Target:** `.NET 8.0-windows`  
**Port:** Stdio (Claude se comunica via stdin/stdout)

| Arquivo | Responsabilidade |
|---------|------------------|
| `Program.cs` | Entry point, host MCP server |
| `RevitTools.cs` | [McpServerTool] definitions |
| `Config.cs` | HTTP client config (localhost:48884) |

## Thread Safety

Revit é **single-threaded** — a maioria das APIs só funciona na thread principal.

**Solução:** `ExternalEvent`

```csharp
// HttpBridge (thread do listener HTTP — diferente do Revit)
_event.Raise();  // Enfileira job na thread principal do Revit

// Revit thread principal (depois, quando terminar o comando atual)
public void Execute(UIApplication app)  // Chamado automaticamente
{
    // Aqui estamos na thread certa, com acesso total à API
    doc.LoadFamily(...);  // Seguro!
}
```

## Fluxo de Erro

Se algo der errado:

```csharp
// Em qualquer ponto, se houver exception:
try
{
    // ... código ...
}
catch (Exception ex)
{
    trans.RollBack();  // Desfazer changes
    return Err($"Erro: {ex.Message}");  // {"ok": false, "error": "..."}
}
```

HttpBridge retorna para MCP, que retorna para Claude:
```json
{
  "ok": false,
  "error": "Elemento não encontrado"
}
```

## Config & Manifest

### .addin Manifest

**Local:** `C:\ProgramData\Autodesk\Revit\Addins\2026\VitruviusAddin.addin`

```xml
<RevitAddIns>
  <AddIn Type="Application">
    <Name>Vitruvius</Name>
    <Assembly>C:\ProgramData\Autodesk\Revit\Addins\2026\VitruviusAddin.dll</Assembly>
    <ClientId>f3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f</ClientId>
    <FullClassName>VitruviusAddin.App</FullClassName>
  </AddIn>
</RevitAddIns>
```

**Regras:**
- Path ABSOLUTO para DLL
- ClientId = ÚNICO (nunca mudar)
- FullClassName = `VitruviusAddin.App` (exato)

### Build Output

**Build:** `dotnet build -c Release -o bin/Staging`
- ✓ `-c Release` = Release config (otimizado)
- ✓ `-o bin/Staging` = Output ÚNICO
- ✓ **NUNCA** bin/Release (bug histórico)

## Performance

- **Latência:** ~100-500ms por operação (HTTP roundtrip + Revit lock)
- **Throughput:** ~2-5 ops/segundo (limitado por lock exclusivo)
- **Memória:** ~50-100MB por processo (Revit add-in + MCP server)

## Limitações & Workarounds

| Limitação | Razão | Workaround |
|-----------|-------|-----------|
| Uma ferramenta por vez | Revit single-threaded | Batch operations |
| Sem acesso fora do Revit | Precisa do DB aberto | Manter Revit rodando |
| Não pode ler parametric | API limitação | Use ElementIds diretos |
| Famílias carregadas na memória | Arquivo lock | Fechar Revit para apagar .rfa |

---

**Versão:** 2.0  
**Data:** 08/08/2026
