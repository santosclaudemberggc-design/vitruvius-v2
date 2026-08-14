# CONFIGURAR AUTOMACAO LOCAL - VITRUVIUS V2
# Execute apenas uma vez no Windows

param(
    [string]$ScheduleTime = "08:00"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogsDir = "$env:USERPROFILE\VitruviusV2\logs"
$BuildScript = "$env:USERPROFILE\VitruviusV2\run-build.ps1"
$TaskName = "VitruviusV2-DailyBuild"

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  VITRUVIUS V2 - CONFIGURAR AUTOMACAO" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 1. CRIAR DIRETORIO DE LOGS
Write-Host "[1/4] Criando diretorio de logs..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
Write-Host "OK - Logs em: $LogsDir" -ForegroundColor Green

# 2. CRIAR SCRIPT LOCAL DE BUILD
Write-Host "[2/4] Criando script de build local..." -ForegroundColor Yellow

$BuildScriptContent = @'
$ErrorActionPreference = "SilentlyContinue"
$ProjectRoot = "D:\011_VITRUVIUS_V2"
$LogsDir = "$env:USERPROFILE\VitruviusV2\logs"
$LogFile = "$LogsDir\build-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"

function Log {
    param([string]$msg)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $line = "[$timestamp] $msg"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

Log "===== VITRUVIUS V2 - BUILD LOCAL ====="

if (-not (Test-Path $ProjectRoot)) {
    Log "ERRO: Projeto nao encontrado em $ProjectRoot"
    exit 1
}

# Git Pull
Log "[1/4] Git pull..."
cd $ProjectRoot
git pull origin claude/sleepy-franklin-ihgxq6

# Build
Log "[2/4] Compilando VitruviusAddin..."
cd "$ProjectRoot\src\VitruviusAddin"
dotnet build -c Release -o bin/Staging

if (-not (Test-Path "bin\Staging\VitruviusAddin.dll")) {
    Log "ERRO: DLL nao foi criada"
    exit 1
}
Log "OK - DLL criada"

# Deploy
Log "[3/4] Deploy da DLL..."
$AddinDir = "C:\ProgramData\Autodesk\Revit\Addins\2026"
if (Test-Path $AddinDir) {
    Copy-Item -Path "bin\Staging\VitruviusAddin.dll" -Destination "$AddinDir\" -Force
    Log "OK - DLL copiada para Revit"
} else {
    Log "ERRO: Diretorio de add-ins nao encontrado"
    exit 1
}

# Build MCP
Log "[4/4] Compilando MCP..."
cd "$ProjectRoot\src\VitruviusMcp"
dotnet build -c Release
Log "OK - MCP compilado"

Log ""
Log "===== BUILD CONCLUIDO COM SUCESSO ====="
'@

$BuildScriptContent | Out-File -FilePath $BuildScript -Encoding UTF8 -Force
Write-Host "OK - Script criado em: $BuildScript" -ForegroundColor Green

# 3. REMOVER TASK EXISTENTE
Write-Host "[3/4] Configurando Task Scheduler..." -ForegroundColor Yellow
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "Aviso: Task existente detectada. Removendo..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
}

# 4. CRIAR NOVA TASK
$trigger = New-ScheduledTaskTrigger -Daily -At $ScheduleTime
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$BuildScript`""
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest

try {
    Register-ScheduledTask -TaskName $TaskName -Trigger $trigger -Action $action -Principal $principal -Description "VITRUVIUS V2 - Build automatico local" -Force | Out-Null
    Write-Host "OK - Task criada com sucesso" -ForegroundColor Green
} catch {
    Write-Host "ERRO ao criar task: $_" -ForegroundColor Red
    exit 1
}

# RESUMO
Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "  AUTOMACAO CONFIGURADA COM SUCESSO" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Configuracao:" -ForegroundColor Cyan
Write-Host "   Nome:      $TaskName"
Write-Host "   Horario:   $ScheduleTime (todos os dias)"
Write-Host "   Script:    $BuildScript"
Write-Host "   Logs:      $LogsDir"
Write-Host ""
Write-Host "O que faz todo dia:" -ForegroundColor Cyan
Write-Host "   1. Git pull da branch"
Write-Host "   2. Compila o codigo"
Write-Host "   3. Copia DLL para Revit"
Write-Host "   4. Compila o MCP"
Write-Host ""
Write-Host "PRONTO! Voce nao precisa fazer mais nada." -ForegroundColor Green
Write-Host ""

Start-Sleep -Seconds 3
