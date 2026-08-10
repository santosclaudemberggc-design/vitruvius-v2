# Quick Start — VITRUVIUS V2

**Início rápido para começar com automação Revit.**

---

## 🚀 Configuração Inicial (Uma Vez)

### 1. Verificar .NET 8
```powershell
dotnet --version
# Esperado: 8.0.xxx ou superior
```

### 2. Revisar Configurações
```powershell
cd D:\011_VITRUVIUS_V2
cat config/settings.json
```

### 3. Verificar Manifest Revit
```powershell
# Deve estar em C:\ProgramData\Autodesk\Revit\Addins\2026\VitruviusAddin.addin
ls "C:\ProgramData\Autodesk\Revit\Addins\2026\"
```

---

## 🔧 Workflow Diário

### Morning (Antes de Trabalhar)

1. **Abrir Revit** com documento ativo
2. **Verificar HTTP Bridge**
   ```powershell
   cd D:\011_VITRUVIUS_V2
   
   # Teste rápido
   $response = Invoke-WebRequest -Uri "http://localhost:48884/" `
       -Method Post `
       -Body (@{ action = "ping" } | ConvertTo-Json) `
       -ContentType "application/json" `
       -ErrorAction SilentlyContinue
   
   if ($response) { Write-Host "✅ HTTP Bridge OK" }
   else { Write-Host "❌ HTTP Bridge falhou" }
   ```

3. **Revisar ROADMAP**
   ```powershell
   cat ROADMAP.md | Select-String "Ferramenta do Dia" -A 5
   ```

### During Day

- **Implementar** ferramenta agendada (manual ou automática)
- **Testar** via HTTP: `.\tests\http-tests\NN-*.ps1`
- **Validar** no Revit (visual)
- **Documentar** em `docs/TOOLS.md`

### Before Sleep (Opcional)

1. **Verificar log do dia**
   ```powershell
   ls logs/ -Newest 1
   ```

2. **Commit de progresso** (se implementação manual)
   ```powershell
   git add .
   git commit -m "Implementar xyz_element"
   ```

---

## 📋 Checklist para Implementar Nova Ferramenta

```markdown
- [ ] Ler descrição em ROADMAP.md
- [ ] Criar arquivo Commands/XyzCommands.cs
- [ ] Adicionar method em RevitCommandHandler.cs switch
- [ ] Adicionar [McpServerTool] em VitruviusMcp/RevitTools.cs
- [ ] Criar teste em tests/http-tests/NN-xyz.ps1
- [ ] Build: dotnet build -c Release -o bin/Staging
- [ ] Verificar: ls bin/Staging/VitruviusAddin.dll
- [ ] Deploy: Copy-Item bin/Staging/... C:\ProgramData\...
- [ ] Teste HTTP: .\tests\http-tests\NN-xyz.ps1
- [ ] Teste Revit: Validar no Project Browser
- [ ] Documentar: Adicionar entrada em docs/TOOLS.md
- [ ] Atualizar ROADMAP.md (mudar status para ✅)
```

---

## 🔍 Troubleshooting Rápido

| Problema | Solução Rápida |
|----------|------------------|
| HTTP não responde | Reiniciar Revit |
| DLL não atualiza | `Stop-Process -Name RevitAccelerator -Force` |
| Build falha | `rm bin obj -Recurse -Force` então `dotnet build` |
| "Ação desconhecida" | Adicionar case em RevitCommandHandler + rebuild |
| Elemento não criado | Verificar Transaction.Commit() no código |

---

## 📊 Monitorar Automação

### Ver próxima execução
```powershell
# Abrir no navegador:
https://claude.ai/code/routines/trig_01JbEN7zwyvadNyHoiRkoPDF
```

### Ver logs diários
```powershell
ls D:\011_VITRUVIUS_V2\logs\
cat D:\011_VITRUVIUS_V2\logs\YYYY-MM-DD-implementacao.md
```

### Forçar execução agora (teste)
```powershell
# Ir para URL da rotina e clicar em "Run Now"
# Ou usar API:
# curl -X POST https://claude.ai/code/routines/trig_01JbEN7zwyvadNyHoiRkoPDF/run
```

---

## 🎯 Metas Semanais

| Semana | Ferramentas | % | Prazo |
|--------|-------------|---|-------|
| 1 | 4 | 13% | 14/08 |
| 2 | 9 | 30% | 21/08 |
| 3 | 15 | 50% | 28/08 |
| 4 | 22 | 73% | 04/09 |

---

## 🆘 Precisa de Ajuda?

1. **Ver documentação:**
   ```
   docs/ARCHITECTURE.md → Como funciona
   docs/DEVELOPMENT.md → Passo-a-passo
   docs/TROUBLESHOOTING.md → Problemas comuns
   ```

2. **Contatar Claude:**
   - Descrever o problema
   - Cole erro completo
   - Mencionone arquivo e linha

3. **Logs para debug:**
   ```powershell
   Get-Content logs/http-bridge.log -Tail 20
   Get-Content logs/mcp-server.log -Tail 20
   ```

---

**Última atualização:** 10/08/2026  
**Status:** 🟢 Pronto para rodar
