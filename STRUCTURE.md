# Estrutura de Diretórios - VITRUVIUS V2

## Organização Completa

```
D:\011_VITRUVIUS_V2\
│
├── README.md                          # Overview do projeto
├── STRUCTURE.md                       # Este arquivo
├── CLAUDE.md                          # Instruções para Claude
├── CHANGELOG.md                       # Histórico de mudanças
│
├── src\
│   ├── VitruviusAddin\               # Add-in principal do Revit (.NET 8.0-windows)
│   │   ├── VitruviusAddin.csproj
│   │   ├── App.cs                    # IExternalApplication entry point
│   │   ├── HttpBridge.cs             # HTTP listener na porta 48884
│   │   ├── RevitCommandHandler.cs    # Dispatcher de comandos
│   │   │
│   │   ├── Commands\                 # Implementações de ferramentas
│   │   │   ├── FamilyCommands.cs     # load_family, etc
│   │   │   ├── RotateCommands.cs     # rotate_element
│   │   │   ├── MoveCommands.cs       # move_element (futuro)
│   │   │   ├── ScaleCommands.cs      # scale_element (futuro)
│   │   │   └── ...
│   │   │
│   │   ├── bin\
│   │   │   └── Staging\              # Única saída de build (NUNCA Release)
│   │   │       └── VitruviusAddin.dll
│   │   │
│   │   └── obj\                      # Intermediários (ignorar)
│   │
│   └── VitruviusMcp\                 # Servidor MCP para Claude
│       ├── VitruviusMcp.csproj
│       ├── Program.cs                # Entry point
│       ├── RevitTools.cs             # Definições MCP das ferramentas
│       ├── Config.cs                 # Configuração HTTP
│       └── bin\Staging\              # Output (NUNCA Release)
│
├── docs\
│   ├── ARCHITECTURE.md               # Arquitetura geral (HTTP bridge, MCP, etc)
│   ├── API.md                        # Documentação de endpoints HTTP
│   ├── TOOLS.md                      # Lista de ferramentas implementadas
│   ├── TROUBLESHOOTING.md            # Guia de erros comuns
│   └── DEVELOPMENT.md                # Como adicionar nova ferramenta
│
├── config\
│   ├── VitruviusAddin.addin          # Manifest do add-in (aponta para bin\Staging)
│   └── settings.json                 # Configurações globais (portas, paths, etc)
│
├── tests\
│   ├── http-tests\                   # Testes manuais via HTTP
│   │   ├── 01-load_family.ps1
│   │   ├── 02-rotate_element.ps1
│   │   └── ...
│   │
│   └── mcp-tests\                    # Testes via MCP/Claude
│       └── test-suite.md
│
└── .gitignore                        # Ignorar bin, obj, .vs, etc
```

## Regras de Ouro

### 1. Build Output
- **ÚNICO destino de build:** `bin\Staging`
- **NUNCA** usar `bin\Release`
- Deletar qualquer `bin\Release` após build
- Comando: `dotnet build -c Release -o bin/Staging`

### 2. Estrutura de Comandos
- **Um arquivo por categoria** (FamilyCommands.cs, RotateCommands.cs, etc)
- **Um método por ferramenta** (`LoadFamily()`, `RotateElement()`, etc)
- **Padrão de retorno:**
  ```csharp
  private static string Ok(object data) => 
    JsonSerializer.Serialize(new { ok = true, result = data });
  
  private static string Err(string msg) => 
    JsonSerializer.Serialize(new { ok = false, error = msg });
  ```

### 3. Dispatcher (RevitCommandHandler.cs)
- **Switch statement centralizado:**
  ```csharp
  Response = Job.Action switch
  {
      "load_family" => FamilyCommands.LoadFamily(doc, Job.Args),
      "rotate_element" => RotateCommands.RotateElement(doc, Job.Args),
      "move_element" => MoveCommands.MoveElement(doc, Job.Args),
      _ => JsonResult(false, $"Ação desconhecida: '{Job.Action}'")
  };
  ```

### 4. MCP (VitruviusMcp\RevitTools.cs)
- **Um método por ferramenta:**
  ```csharp
  [McpServerTool(Name = "rotate_element")]
  [Description("Rotaciona um elemento no Revit")]
  public static Task<string> RotateElement(long element_id, double angle_degrees, string axis = "Z")
      => Call("rotate_element", new { element_id, angle_degrees, axis });
  ```

### 5. Testes
- **PowerShell scripts** em `tests/http-tests/` para cada ferramenta
- **Nome padrão:** `NN-tool_name.ps1` (01-load_family.ps1, 02-rotate_element.ps1)
- **Formato:**
  ```powershell
  $body = @{ action = "..."; args = @{ ... } } | ConvertTo-Json
  Invoke-WebRequest -Uri "http://localhost:48884/" -Method Post -Body $body
  ```

## Quando adicionar nova ferramenta

1. **Criar arquivo** em `src/VitruviusAddin/Commands/NewFeatureCommands.cs`
2. **Implementar método** seguindo padrão (Ok/Err helpers)
3. **Adicionar case** em `RevitCommandHandler.cs` switch
4. **Adicionar MCP method** em `VitruviusMcp/RevitTools.cs`
5. **Criar teste** em `tests/http-tests/NN-tool_name.ps1`
6. **Compilar:** `dotnet build -c Release -o bin/Staging`
7. **Copiar DLL:** `cp bin/Staging/VitruviusAddin.dll C:\ProgramData\Autodesk\Revit\Addins\2026\`
8. **Testar** via HTTP e Revit
9. **Documentar** em `docs/TOOLS.md`

## Localizando erros

| Erro | Localização |
|------|-------------|
| Compilação C# | `src/VitruviusAddin/*.cs` |
| HTTP não responde | `src/VitruviusAddin/HttpBridge.cs` |
| "Ação desconhecida" | `src/VitruviusAddin/RevitCommandHandler.cs` switch |
| Ferramenta falha | `src/VitruviusAddin/Commands/XyzCommands.cs` |
| MCP não funciona | `src/VitruviusMcp/RevitTools.cs` |
| Add-in não carrega | `config/VitruviusAddin.addin` e `C:\ProgramData\Autodesk\Revit\Addins\2026\` |
| Teste HTTP falha | `tests/http-tests/NN-tool_name.ps1` |

