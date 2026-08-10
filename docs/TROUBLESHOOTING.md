# Guia de Troubleshooting — VITRUVIUS V2

Soluções para problemas comuns ao usar VITRUVIUS.

---

## 🚨 Problemas de Build

### ❌ "O projeto não compila"

**Sintoma:** `error CS...` ao rodar `dotnet build`

**Solução:**
1. Verificar se .NET 8.0-windows está instalado: `dotnet --version`
2. Limpar build anterior: `rm bin obj -Recurse -Force`
3. Restaurar dependências: `dotnet restore`
4. Recompilar: `dotnet build -c Release -o bin/Staging`

---

### ❌ "DLL não aparece em bin\Staging"

**Sintoma:** Build diz "Build succeeded" mas arquivo não existe

**Solução:**
1. Verificar path de output: `ls bin/Staging/`
2. Se vazio, problema no .csproj:
   ```xml
   <PropertyGroup>
     <OutputPath>bin/Staging</OutputPath>
   </PropertyGroup>
   ```
3. Se tiver `bin\Release`, deletar: `rm bin\Release -Recurse -Force`
4. Recompilar

---

## 🚨 Problemas de HTTP Bridge

### ❌ "Conexão recusada em localhost:48884"

**Sintoma:** `Invoke-WebRequest` retorna "Connection refused"

**Solução:**
1. Verificar se Revit está aberto
2. Verificar se HTTP listener começou: Ver output do Revit
3. Se ainda falhar, revisar `HttpBridge.cs` na porta 48884
4. Reiniciar Revit

**Debug:**
```powershell
# Teste se porta está escutando
netstat -ano | findstr :48884
```

---

### ❌ "Ação desconhecida: 'xyz'"

**Sintoma:** HTTP retorna `{"ok": false, "error": "Ação desconhecida: 'xyz'"}`

**Solução:**
1. Verificar se case foi adicionado em `RevitCommandHandler.cs`:
   ```csharp
   "xyz" => XyzCommands.Funcao(doc, Job.Args),
   ```
2. Recompilar e redeploy DLL
3. Reiniciar Revit

---

## 🚨 Problemas de MCP Server

### ❌ "MCP não conecta ao Claude"

**Sintoma:** Claude não vê as ferramentas VITRUVIUS

**Solução:**
1. Verificar se `VitruviusMcp.exe` está rodando
2. Verificar se HTTP bridge está respondendo
3. Verificar se métodos têm `[McpServerTool]` attribute
4. Reiniciar MCP server

---

### ❌ "Método MCP não aparece em Claude"

**Sintoma:** Tool existe mas Claude não vê

**Solução:**
1. Verificar se método tem decorator:
   ```csharp
   [McpServerTool(Name = "meu_tool")]
   [Description("...")]
   public static Task<string> MeuTool(...) { ... }
   ```
2. Verificar se name usa underscores (não camelCase)
3. Reiniciar MCP server
4. Recarregar Claude

---

## 🚨 Problemas de Deploy

### ❌ "DLL não atualiza após build"

**Sintoma:** Depois de build, Revit ainda usa versão antiga

**Solução:**
1. Parar RevitAccelerator: `Stop-Process -Name "RevitAccelerator" -Force -ErrorAction SilentlyContinue`
2. Fechar Revit completamente
3. Copiar DLL novamente:
   ```powershell
   Copy-Item bin\Staging\VitruviusAddin.dll C:\ProgramData\Autodesk\Revit\Addins\2026\ -Force
   ```
4. Reabrir Revit

---

### ❌ "Arquivo .addin não é lido"

**Sintoma:** Add-in não aparece no gerenciador de Revit

**Solução:**
1. Verificar localização: `C:\ProgramData\Autodesk\Revit\Addins\2026\VitruviusAddin.addin`
2. Verificar conteúdo — path da DLL deve estar absoluto
3. Deletar arquivo e copiar de novo de `config/VitruviusAddin.addin`
4. Reiniciar Revit

---

## 🚨 Problemas de Teste

### ❌ "Teste HTTP retorna timeout"

**Sintoma:** `Invoke-WebRequest` espera para sempre

**Solução:**
1. Verificar se Revit está respondendo (não travado)
2. Aumentar timeout: `Invoke-WebRequest ... -TimeoutSec 60`
3. Se persistir, revisar implementação da ferramenta (pode estar em loop)

---

### ❌ "Teste Revit falha — elemento não criado"

**Sintoma:** HTTP retorna OK mas elemento não aparece no Revit

**Solução:**
1. Verificar se Transaction.Commit() foi chamado
2. Verificar se não há exception silenciosa
3. Adicionar logging: `System.Diagnostics.Debug.WriteLine(...)`
4. Rodar teste novamente com Revit aberto

---

## 🚨 Problemas de Revit

### ❌ "Revit congela ao chamar ferramenta"

**Sintoma:** Revit não responde depois de teste HTTP

**Solução:**
1. Não forçar Revit a fechar, aguardar
2. Se timeout > 1min, verificar implementação (loop infinito?)
3. Revisar código: não usar `Thread.Sleep()` em Transaction
4. Se persistir, fazer rollback de commit anterior

---

### ❌ "Erro de permissão ao salvar"

**Sintoma:** Transaction.Commit() falha com "permissão negada"

**Solução:**
1. Verificar se documento é read-only
2. Verificar se elemento pode ser modificado (não system)
3. Verificar se categoria permite operação
4. Consultar Revit API docs

---

## 🚨 Problemas de Configuração

### ❌ "Porta 48884 já está em uso"

**Sintoma:** `HttpListener bind failed`

**Solução:**
1. Encontrar processo usando porta:
   ```powershell
   netstat -ano | findstr :48884
   ```
2. Matar processo: `taskkill /PID 1234 /F`
3. Ou mudar porta em `config/settings.json`

---

## 📋 Checklist de Debug

Quando algo não funciona:

- [ ] Revit está aberto?
- [ ] Documento está ativo?
- [ ] HTTP bridge respondeu em localhost:48884?
- [ ] Ferramenta foi registrada em RevitCommandHandler?
- [ ] MCP method foi adicionado?
- [ ] DLL foi copiada para add-ins?
- [ ] Revit foi reiniciado depois de copiar DLL?
- [ ] Teste HTTP retorna `{"ok": true}`?
- [ ] Elemento foi criado/modificado no Revit?

---

## 🔍 Logs & Debug

### Ver logs do HTTP Bridge
```powershell
# Arquivo: logs/http-bridge.log
Get-Content logs/http-bridge.log -Tail 20
```

### Ver logs do MCP Server
```powershell
# Arquivo: logs/mcp-server.log
Get-Content logs/mcp-server.log -Tail 20
```

### Debug em Visual Studio
1. Abrir solução em Visual Studio
2. Colocar breakpoint em `HttpBridge.cs`
3. Executar: F5 (vai atrelar ao Revit)
4. Rodar teste HTTP
5. Breakpoint vai parar

---

## 💬 Quando Tudo Falha

1. Limpar tudo: 
   ```powershell
   rm bin -Recurse -Force
   rm obj -Recurse -Force
   rm logs -Recurse -Force
   ```

2. Parar tudo:
   ```powershell
   Stop-Process -Name "Revit*" -Force -ErrorAction SilentlyContinue
   Stop-Process -Name "RevitAccelerator" -Force -ErrorAction SilentlyContinue
   ```

3. Resetar cache Revit:
   ```powershell
   rm "$env:LOCALAPPDATA\Autodesk\Revit\Autodesk Revit 2026" -Recurse -Force -ErrorAction SilentlyContinue
   ```

4. Começar do zero: `git clean -fd`

---

**Última atualização:** 10/08/2026  
**Responsável:** Claudemberg
