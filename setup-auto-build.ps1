# SETUP AUTOMÁTICO — Execute uma única vez
# Configura o Task Scheduler para fazer build automático todo dia

param(
    [string]$Hour = "08",
    [string]$Minute = "00"
)

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuildScript = "$ProjectRoot\auto-build.ps1"
$TaskName = "VitruviusV2-AutoBuild"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SETUP AUTOMÁTICO - TASK SCHEDULER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar se já existe
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "❌ Task já existe! Removendo..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

Write-Host "✅ Criando task para rodar todo dia às $($Hour):$($Minute)..." -ForegroundColor Green

# Criar trigger
$trigger = New-ScheduledTaskTrigger -Daily -At "$($Hour):$($Minute)"

# Criar ação
$action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$BuildScript`""

# Criar task com privilégios de admin
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

# Registrar
Register-ScheduledTask `
    -TaskName $TaskName `
    -Trigger $trigger `
    -Action $action `
    -Principal $principal `
    -Description "Build automático VITRUVIUS V2" `
    -Force | Out-Null

Write-Host ""
Write-Host "✅ PRONTO! Task criada com sucesso." -ForegroundColor Green
Write-Host ""
Write-Host "Configuração:" -ForegroundColor Cyan
Write-Host "  Nome:     $TaskName"
Write-Host "  Horário:  $($Hour):$($Minute) diariamente"
Write-Host "  Script:   $BuildScript"
Write-Host ""
Write-Host "A ferramenta será compilada e deployada automaticamente todo dia!" -ForegroundColor Green
Write-Host ""
pause
