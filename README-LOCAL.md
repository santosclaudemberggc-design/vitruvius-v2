# VITRUVIUS V2 — Automação LOCAL no Windows

## 🎯 O que é

Script PowerShell que configura **automação 100% local** no Windows:
- ✅ Build automático todo dia
- ✅ Deploy da DLL para Revit
- ✅ Compila MCP
- ✅ Salva logs de tudo

Você executa **UMA VEZ** para configurar. Depois roda automaticamente.

---

## 🚀 Como usar

### 1️⃣ Execute o script de configuração

**Clique com botão direito** em:
```
configure-vitruvius-automation.ps1
```

Selecione: **"Executar com PowerShell"**

### 2️⃣ Aguarde a configuração terminar

O script vai:
- ✅ Criar diretório de logs
- ✅ Criar script de build
- ✅ Configurar Task Scheduler
- ✅ Mostrar um resumo final

### 3️⃣ Pronto!

Automação está configurada. Todo dia às **8:00 AM** (ou horário que você definiu), o build roda automaticamente.

---

## ⚙️ Configurar horário diferente

Se quiser que rode em outro horário, execute:

```powershell
.\configure-vitruvius-automation.ps1 -ScheduleTime "14:30"
```

Substitua `14:30` pelo horário desejado (formato 24h).

---

## 📝 Onde ficam os logs

```
C:\Users\SEU_USUARIO\VitruviusV2\logs\
```

Cada execução cria um arquivo com timestamp. Você pode abrir e verificar se tudo deu certo.

---

## 🛑 Desativar automação

Se precisar desativar:

1. Abra **Task Scheduler** (pesquise na barra de pesquisa do Windows)
2. Procure por: **VitruviusV2-DailyBuild**
3. Clique com direito → **Desabilitar**

Para reativar, apenas clique → **Habilitar**.

---

## ❌ Troubleshooting

### "PowerShell não consegue executar o script"

Se aparecer erro de execução, abra PowerShell como Admin e execute:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Depois tente de novo.

### "Erro: Projeto não encontrado em D:\011_VITRUVIUS_V2"

Edite o arquivo `run-build.ps1` (em `C:\Users\SEU_USUARIO\VitruviusV2\`) e ajuste a linha:

```powershell
$ProjectRoot = "D:\011_VITRUVIUS_V2"  # ← AJUSTE AQUI
```

Para o caminho correto do seu projeto.

### Revit não carrega a DLL

1. Feche completamente o Revit
2. Verifique o log para ver se houve erro
3. Abra Revit novamente

---

## 📊 O que roda automaticamente

Cada dia às hora configurada:

```
1. git pull origin claude/sleepy-franklin-ihgxq6
2. dotnet build -c Release -o bin/Staging (VitruviusAddin)
3. Copy DLL → C:\ProgramData\Autodesk\Revit\Addins\2026\
4. dotnet build -c Release (VitruviusMcp)
5. Salva log de tudo em: C:\Users\SEU_USUARIO\VitruviusV2\logs\
```

---

## ✅ Confirmação visual

Depois que a automação roda:

1. Abra **Revit 2026**
2. Abra um projeto
3. Use a ferramenta `select_by_type` para verificar se está funcionando

Se funcionou → tudo está OK! 🎉

---

## 📞 Precisa de ajuda?

1. Verifique o log em `C:\Users\SEU_USUARIO\VitruviusV2\logs\`
2. Verifique se Revit está fechado durante o build
3. Verifique se `D:\011_VITRUVIUS_V2` é o caminho correto do seu projeto
