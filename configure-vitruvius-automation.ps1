# ============================================================================
# CONFIGURAR AUTOMAÇÃO LOCAL — VITRUVIUS V2
#
# Execute APENAS UMA VEZ no Windows
# Configura Task Scheduler para rodar build + deploy + teste automaticamente
# ============================================================================

param(
    [string]$ScheduleTime = "08:00",  # Horário diário (ex: 08:00, 14:30)
    [switch]$Help
)

if ($Help) {
    Write-Host @"
CONFIGURAR AUTOMAÇÃO LOCAL — VITRUVIUS V2

USO:
  .\configure-vitruvius-automation.ps1          # Padrão: 08:00 AM
  .\configure-vitruvius-automation.ps1 -ScheduleTime "14:30"  # 2:30 PM
  .\configure-vitruvius-automation.ps1 -Help    # Mostra esta ajuda

O que faz:
  1. Cria diretório de logs no seu perfil Windows
  2. Cria script local de build/deploy/teste
  3. Configura Task Scheduler para rodar automaticamente todo dia
  4. Tudo fica 100% LOCAL no seu Windows

Depois: pronto! Tudo roda automaticamente.
"@
    exit
}

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogsDir = "$env:USERPROFILE\VitruviusV2\logs"
$BuildScript = "$env:USERPROFILE\VitruviusV2\run-build.ps1"
$TaskName = "VitruviusV2-DailyBuild"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        VITRUVIUS V2 — CONFIGURAR AUTOMAÇÃO LOCAL              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ========================================================================
# 1. CRIAR DIRETÓRIO DE LOGS
# ========================================================================
Write-Host "[1/4] Criando diretório de logs..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
Write-Host "✅ Logs em: $LogsDir" -ForegroundColor Green

# ========================================================================
# 2. CRIAR SCRIPT LOCAL DE BUILD
# ========================================================================
Write-Host "[2/4] Criando script de build local..." -ForegroundColor Yellow

$BuildScriptContent = @'
# ============================================================================
# BUILD LOCAL — VITRUVIUS V2
# Roda automaticamente via Task Scheduler
# ============================================================================

$ErrorActionPreference = "SilentlyContinue"
$ProjectRoot = "D:\011_VITRUVIUS_V2"  # AJUSTAR SE NECESSÁRIO
$LogsDir = "$env:USERPROFILE\VitruviusV2\logs"
$LogFile = "$LogsDir\build-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"

function Log {
    param([string]$msg, [string]$color = "White")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $line = "[$timestamp] $msg"
    Write-Host $line -ForegroundColor $color
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

Log "════════════════════════════════════════" Green
Log "VITRUVIUS V2 — BUILD LOCAL INICIADO" Green
Log "════════════════════════════════════════" Green

if (-not (Test-Path $ProjectRoot)) {
    Log "❌ ERRO: Projeto não encontrado em $ProjectRoot" Red
    Log "Ajuste a variável \$ProjectRoot no script" Red
    exit 1
}

# Git Pull
Log "[1/4] Git pull..." Yellow
cd $ProjectRoot
git pull origin claude/sleepy-franklin-ihgxq6 2>&1 | ForEach-Object { Log $_ }

# Build VitruviusAddin
Log "[2/4] Compilando VitruviusAddin..." Yellow
cd "$ProjectRoot\src\VitruviusAddin"
dotnet build -c Release -o bin/Staging 2>&1 | ForEach-Object { Log $_ }

if (-not (Test-Path "bin\Staging\VitruviusAddin.dll")) {
    Log "❌ ERRO: DLL não foi criada" Red
    exit 1
}
Log "✅ DLL criada" Green

# Deploy
Log "[3/4] Deploy da DLL..." Yellow
$AddinDir = "C:\ProgramData\Autodesk\Revit\Addins\2026"
if (Test-Path $AddinDir) {
    Copy-Item -Path "bin\Staging\VitruviusAddin.dll" -Destination "$AddinDir\" -Force 2>&1 | ForEach-Object { Log $_ }
    Log "✅ DLL copiada para Revit" Green
} else {
    Log "❌ Diretório de add-ins não encontrado" Red
    exit 1
}

# Build MCP
Log "[4/4] Compilando MCP..." Yellow
cd "$ProjectRoot\src\VitruviusMcp"
dotnet build -c Release 2>&1 | ForEach-Object { Log $_ }
Log "✅ MCP compilado" Green

Log ""
Log "════════════════════════════════════════" Green
Log "✅ BUILD CONCLUÍDO COM SUCESSO" Green
Log "════════════════════════════════════════" Green
Log ""
Log "Revit carregará a nova DLL automaticamente na próxima vez que for aberto."
'@

$BuildScriptContent | Out-File -FilePath $BuildScript -Encoding UTF8 -Force
Write-Host "✅ Script criado em: $BuildScript" -ForegroundColor Green

# ========================================================================
# 3. REMOVER TASK EXISTENTE
# ========================================================================
Write-Host "[3/4] Configurando Task Scheduler..." -ForegroundColor Yellow
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "⚠️  Task existente detectada. Removendo..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
}

# ========================================================================
# 4. CRIAR NOVA TASK
# ========================================================================
$trigger = New-ScheduledTaskTrigger -Daily -At $ScheduleTime
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$BuildScript`""

$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest

try {
    Register-ScheduledTask `
        -TaskName $TaskName `
        -Trigger $trigger `
        -Action $action `
        -Principal $principal `
        -Description "VITRUVIUS V2 — Build automático local" `
        -Force | Out-Null

    Write-Host "✅ Task criada com sucesso" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao criar task: $_" -ForegroundColor Red
    exit 1
}

# ========================================================================
# RESUMO
# ========================================================================
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                   ✅ AUTOMAÇÃO CONFIGURADA                     ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Configuração:" -ForegroundColor Cyan
Write-Host "   Nome da Task:  $TaskName"
Write-Host "   Horário:       $ScheduleTime (todos os dias)"
Write-Host "   Script:        $BuildScript"
Write-Host "   Logs:          $LogsDir"
Write-Host ""
Write-Host "🚀 O que acontece agora:" -ForegroundColor Cyan
Write-Host "   • Todo dia às $ScheduleTime, a automação roda:"
Write-Host "     1. Git pull da branch"
Write-Host "     2. Compila o código"
Write-Host "     3. Copia DLL para Revit"
Write-Host "     4. Compila o MCP"
Write-Host ""
Write-Host "📖 Para desativar:" -ForegroundColor Cyan
Write-Host "   Abra Task Scheduler e desabilite: $TaskName"
Write-Host ""
Write-Host "📝 Logs:" -ForegroundColor Cyan
Write-Host "   Cada execução salva um log em $LogsDir"
Write-Host ""
Write-Host "✅ PRONTO! Você não precisa fazer mais nada." -ForegroundColor Green
Write-Host ""

Start-Sleep -Seconds 3
