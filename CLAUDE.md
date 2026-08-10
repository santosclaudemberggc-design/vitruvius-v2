# Instruções para Claude — VITRUVIUS V2

## Regras Gerais

### 1. Sempre Português
- Respostas, comentários, nomes de variáveis: **SEMPRE em português**
- Nunca responder em inglês, nem em resumos agendados

### 2. Confiança no Usuário
- **Não verificar processo Revit** via tasklist
- Confiar na palavra do Claudemberg sobre "Revit aberto" ou "fechado"
- Não usar `Get-Process | grep Revit` — apenas confie no relato

### 3. Coerência Lógica na API
- Se consigo criar via API, consigo ler também
- **Nunca dizer "não acesso"** quando estou usando a API ativamente
- Se a API funciona em um sentido, presumir que funciona em ambos

### 4. Testes: Esperar Confirmação
- **Nunca criar + validar + apagar elemento em sequência**
- Sempre aguardar que Claudemberg confirme que viu no Revit
- Depois dele confirmar: "Sim, vi. Pode continuar"
- Só aí apagar ou limpar

### 5. DLL e Build
- **Verificar localização de saída**, não só "0 erros"
- Bug antigo: `-o bin\Staging` criava pasta "binStaging"
- Sempre confirmar: `ls bin\Staging\VitruviusAddin.dll` existe
- Se build diz "OK" mas DLL não está lá, investigar antes de continuar

## Estrutura do Projeto

```
D:\011_VITRUVIUS_V2\
├── src\VitruviusAddin\           ← Add-in Revit (C#)
│   ├── Commands\                  ← Pasta para *Commands.cs
│   └── bin\Staging\              ← ÚNICO output (nunca bin\Release)
├── src\VitruviusMcp\             ← MCP Server (C#)
├── docs\                          ← Documentação
├── tests\                         ← Testes HTTP e MCP
├── config\                        ← .addin manifests
└── STRUCTURE.md                  ← Mapa da organização
```

### Localizar Erro

| Sintoma | Onde procurar |
|---------|---------------|
| "Ação desconhecida: 'xyz'" | `RevitCommandHandler.cs` switch |
| HTTP não responde | `HttpBridge.cs` (Port 48884) |
| Compilação falha | `src/VitruviusAddin/*.cs` |
| Ferramenta falha em Revit | `src/VitruviusAddin/Commands/*Commands.cs` |
| MCP não funciona | `src/VitruviusMcp/RevitTools.cs` |
| Add-in não carrega | `config/VitruviusAddin.addin` + `C:\ProgramData\Autodesk\Revit\Addins\2026\` |

## Padrão de Implementação

Toda ferramenta segue este padrão:

### 1. Criar arquivo `Commands/NomeCommands.cs`
```csharp
using System.Text.Json;
using Autodesk.Revit.DB;

namespace VitruviusAddin;

public static class NomeCommands
{
    public static string MinhaFeature(Document doc, JsonElement args)
    {
        var param1 = GetString(args, "param1");
        if (string.IsNullOrEmpty(param1))
            return Err("param1 é obrigatório");
        
        try
        {
            using var trans = new Transaction(doc, "Vitruvius: descrição");
            trans.Start();
            // Implementação aqui
            trans.Commit();
            return Ok(new { status = "sucesso", ... });
        }
        catch (Exception ex)
        {
            return Err($"Erro: {ex.Message}");
        }
    }
    
    private static string GetString(JsonElement args, string name) => ...;
    private static string Ok(object data) => ...;
    private static string Err(string msg) => ...;
}
```

### 2. Adicionar ao `RevitCommandHandler.cs`
```csharp
Response = Job.Action switch
{
    "minha_feature" => NomeCommands.MinhaFeature(doc, Job.Args),
    // ...
};
```

### 3. Adicionar MCP em `VitruviusMcp/RevitTools.cs`
```csharp
[McpServerTool(Name = "minha_feature")]
[Description("Descrição da ferramenta")]
public static Task<string> MinhaFeature(string param1, string param2 = "default")
    => Call("minha_feature", new { param1, param2 });
```

### 4. Teste HTTP em `tests/http-tests/NN-minha_feature.ps1`
```powershell
$body = @{
    action = "minha_feature"
    args = @{ param1 = "valor" }
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "http://localhost:48884/" -Method Post -Body $body -ContentType "application/json"
Write-Host $response.Content
```

### 5. Build & Deploy
```powershell
cd src\VitruviusAddin
dotnet build -c Release -o bin/Staging
Copy-Item bin\Staging\VitruviusAddin.dll C:\ProgramData\Autodesk\Revit\Addins\2026\ -Force
```

### 6. Testar
```powershell
# HTTP
& .\tests\http-tests\NN-minha_feature.ps1

# Revit visual
# (Abrir Revit e validar que funcionou)
```

## Memory & Feedback

Memórias importantes estão em `C:\Users\santo\.claude\projects\D--011-VITRUVIUS\memory\`:
- `feedback_idioma-portugues.md` → Sempre português
- `feedback_testes-aguardar-confirmacao.md` → Não apagar sem confirmação
- `feedback_build-o-flag-gitbash.md` → Verificar DLL de saída
- `vitruvius-nao-verificar-revit-processo.md` → Confiar no usuário
- `feedback_api-coherence.md` → Lógica de API consistente

## Limpeza Pós-Build

Depois de cada build, **SEMPRE:**
1. Verificar que `bin\Staging\VitruviusAddin.dll` existe
2. Deletar `bin\Release` se existir: `Remove-Item bin\Release -Recurse -Force`
3. Copiar DLL para add-ins: `Copy-Item bin\Staging\VitruviusAddin.dll C:\ProgramData\Autodesk\Revit\Addins\2026\ -Force`

## Emergency Cleanup

Se algo dar errado:
```powershell
# Parar RevitAccelerator
Stop-Process -Name "RevitAccelerator" -Force -ErrorAction SilentlyContinue

# Limpar cache
Remove-Item "$env:LOCALAPPDATA\Autodesk\Revit\Autodesk Revit 2026" -Recurse -Force -ErrorAction SilentlyContinue

# Fechar e reabrir Revit
```

## Quando Adicionar Ferramenta Nova

1. Criar `src/VitruviusAddin/Commands/NovaFerramenta​Commands.cs`
2. Implementar método `public static string NovaFuncionalidade(Document doc, JsonElement args)`
3. Adicionar case em `RevitCommandHandler.cs`
4. Adicionar método MCP em `VitruviusMcp/RevitTools.cs`
5. Criar teste em `tests/http-tests/NN-nova_ferramenta.ps1`
6. **Compilar, testar HTTP, testar Revit, documentar**
7. Atualizar `docs/TOOLS.md` com nova ferramenta

## Contato & Referências

- **Usuário:** Claudemberg
- **Email:** santosclaudembergg@hotmail.com
- **Idioma:** Português (BR)
- **Revit:** 2026 Professional
- **Licença Revit:** Estudante
- **Zona:** America/Sao_Paulo

---

**Última atualização:** 08/08/2026  
**Versão:** V2.0  
**Status:** Em desenvolvimento (Semana 1)
