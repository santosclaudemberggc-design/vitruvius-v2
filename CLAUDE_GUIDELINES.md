# 📋 CLAUDE GUIDELINES — Erros a Evitar & Padrão de Trabalho

**Versão:** 1.0 (12/08/2026)  
**Objetivo:** Documentar erros cometidos e padrão correto para sessões futuras (rotinas automáticas)

---

## 🚫 Erros Cometidos — NUNCA REPETIR

### 1. Falta de Transparência entre Responsabilidades
**Erro:** Dar instruções vagas sobre quem faz o quê.  
**Lição:** Sempre deixar explícito:
- ✅ O que EU vou fazer automaticamente (código, commits, push)
- ✅ O que VOCÊ precisa fazer (comandos no Windows/Revit)
- ✅ Quando você precisa avisar (confirmação de cada passo)

**Exemplo correto:**
```
O que EU vou fazer:
- ✅ Implementar SelectionCommands.cs
- ✅ Registrar no RevitCommandHandler.cs
- ✅ Atualizar ROADMAP.md

O que VOCÊ vai fazer:
1. No Windows, execute: dotnet build -c Release
2. Copie o DLL para C:\ProgramData\Autodesk\Revit\Addins\2026\
3. Me avise quando terminar
```

---

### 2. Comandos Compostos com `&&` 
**Erro:** `cd D:\path && dotnet run` — PowerShell do usuário não suporta.  
**Lição:** SEMPRE dar comandos separados:
```powershell
# ERRADO
cd D:\path && dotnet run

# CORRETO
cd D:\path
# (usuário pressiona Enter)
dotnet run
# (usuário pressiona Enter)
```

---

### 3. Jargão Técnico sem Explicação
**Erro:** Usar termos como "MCP Server", "HTTP bridge", "JSON-RPC" sem explicar.  
**Lição:** O usuário é leigo em algumas áreas. Sempre explicar ou simplificar:
- ❌ "Configure o MCP server no arquivo de configuração"
- ✅ "Abra um novo terminal e execute: dotnet run"

---

### 4. Não Verificar Antes de Assumir
**Erro:** Assumir que `get_element_info` estava no MCP sem verificar o arquivo.  
**Lição:** Quando disser "a ferramenta X está no MCP", verificar o arquivo `Program.cs` primeiro:
```csharp
// Verificar se está em BuildToolDefs()
new { name = "get_element_info", ... }
```

---

### 5. Não Avisar Claramente quando Algo Falha
**Erro:** MCP server caiu e eu não avisei diretamente — usuário teve que descobrir.  
**Lição:** Quando algo der erro:
1. ✅ Explicar claramente o que falhou
2. ✅ Indicar o PIDs/processos (ex: "VitruviusMcp.exe (15168) está bloqueando")
3. ✅ Dar passo-a-passo para resolver

---

### 6. Tentar Criar Recursos que Precisam de Permissão
**Erro:** Tentar criar sessão remota sem ter permissão de contexto.  
**Lição:** Se uma ação retornar erro de permissão/contexto:
1. ✅ Não repetir a mesma ação
2. ✅ Explicar ao usuário por que não consegui fazer
3. ✅ Dar instrução manual clara

---

### 7. Não Lembrar do Contexto da Sessão Anterior
**Erro:** Esquecer que o MCP server estava rodando e tentar fazer rebuild.  
**Lição:** Sempre perguntar/verificar estado atual antes de ações destrutivas:
- "O servidor MCP está rodando?" 
- "Há algum processo bloqueando o arquivo?"

---

## ✅ Padrão Correto de Trabalho

### Para Cada Ferramenta a Implementar:

#### FASE 1: EU IMPLEMENTO (Automático — nuvem/Linux)

```
1. Ler ROADMAP.md → identificar ferramenta
2. Criar Commands/XyzCommands.cs com método
3. Registrar em RevitCommandHandler.cs (adicionar case)
4. Adicionar em src/VitruviusMcp/Program.cs (BuildToolDefs)
5. Criar teste em tests/http-tests/NN-xyz.ps1
6. Atualizar docs/TOOLS.md
7. Atualizar ROADMAP.md (marcar como ✅ Concluído)
8. Fazer commit e push para GitHub
```

**O QUE EU RETORNO AO USUÁRIO:**
```
✅ Implementação concluída em GitHub

O que você precisa fazer AGORA (Windows):

1. Execute este comando:
   dotnet build -c Release -o bin\Staging

2. Copie o DLL:
   Copy-Item bin\Staging\VitruviusAddin.dll C:\ProgramData\Autodesk\Revit\Addins\2026\ -Force

3. Me avise quando terminar ✅
```

---

#### FASE 2: VOCÊ TESTA (Windows/Revit)

```
O que o usuário faz:
1. Build no Windows
2. Copiar DLL para Revit addins
3. (Se necessário) Restart MCP server: Ctrl+C, depois dotnet run
4. Avisar quando terminar
```

**O QUE EU FAÇO DEPOIS:**
- Instruir a testar no Claude.ai
- Validar resultado
- Atualizar documentação se necessário

---

## 📝 Checklist para Cada Sessão

Antes de começar a trabalhar, verificar:

- [ ] Qual ferramenta vou implementar? (Ler ROADMAP.md)
- [ ] Essa ferramenta está nas 30 planejadas?
- [ ] Quais dependências ela tem? (verificar coluna "Depende de")
- [ ] Preciso parar o MCP server antes de compilar? (sim, se estiver rodando)
- [ ] Vou dar comandos no PowerShell? (sem `&&`, sempre separados)
- [ ] Vou usar jargão? (explicar ou simplificar)
- [ ] Vou assumir algo sem verificar? (não! verificar arquivo)

---

## 🔄 Ciclo Completo Esperado

1. **EU implemento** (30-90 min na nuvem)
   - Code, test scripts, docs, commit, push ✅

2. **VOCÊ compila e deploy** (5-10 min no Windows)
   - Build, copy DLL, restart server ✅

3. **VOCÊ testa no Claude.ai** (2-5 min)
   - Nova conversa, pedir ação em português ✅

4. **EU atualizo documentação** (2 min)
   - Marcar como ✅ Testado, atualizar status ✅

---

## 🎯 Responsabilidades Claramente Definidas

| Responsabilidade | Quem | Como Comunicar |
|-----------------|------|----------------|
| Implementação de código | Claude (nuvem) | "✅ Implementado em XyzCommands.cs" |
| Build/Compilation | Usuário (Windows) | "Execute: dotnet build -c Release" |
| Deploy para Revit | Usuário (Windows) | "Copy-Item ... (comando completo)" |
| MCP Server restart | Usuário (Windows) | "Ctrl+C no terminal, depois dotnet run" |
| Teste no Claude.ai | Usuário | "Abra nova conversa, peça: ..." |
| Documentação final | Claude (nuvem) | "✅ ROADMAP.md e TOOLS.md atualizados" |

---

## 📌 Lembrete Final

**SEMPRE que iniciar uma sessão:**
1. Ler este arquivo (CLAUDE_GUIDELINES.md)
2. Verificar qual ferramenta implementar (ROADMAP.md)
3. Ser explícito: "O que EU faço" vs. "O que VOCÊ faz"
4. Não assumir, verificar
5. Sem `&&` em PowerShell
6. Avisar claramente quando algo falhar

---

**Criado:** 12/08/2026  
**Responsável:** Claude + Claudemberg  
**Próxima revisão:** Após sessão de `select_by_category`
