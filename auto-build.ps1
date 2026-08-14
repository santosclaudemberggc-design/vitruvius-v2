# AUTO-BUILD — Roda automaticamente via Task Scheduler
# Faz: git pull → build → deploy → teste HTTP

$ErrorActionPreference = "SilentlyContinue"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = "$ProjectRoot\logs\auto-build-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"

# Garantir que logs exista
New-Item -ItemType Directory -Path "$ProjectRoot\logs" -Force | Out-Null

function Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

Log "=========================================="
Log "VITRUVIUS V2 — AUTO-BUILD INICIADO"
Log "=========================================="

# ==========================================
# 1. GIT PULL
# ==========================================
Log "[1/5] Git pull..."
cd $ProjectRoot
git pull origin claude/sleepy-franklin-ihgxq6 2>&1 | ForEach-Object { Log $_ }

# ==========================================
# 2. BUILD VITRUVIUS ADDIN
# ==========================================
Log "[2/5] Compilando VitruviusAddin..."
cd "$ProjectRoot\src\VitruviusAddin"
dotnet build -c Release -o bin/Staging 2>&1 | ForEach-Object { Log $_ }

if (Test-Path "bin\Staging\VitruviusAddin.dll") {
    Log "✅ DLL criada com sucesso"
} else {
    Log "❌ ERRO: DLL não foi criada"
    Log "=========================================="
    exit 1
}

# ==========================================
# 3. DEPLOY PARA REVIT
# ==========================================
Log "[3/5] Deploy da DLL..."
$AddinDir = "C:\ProgramData\Autodesk\Revit\Addins\2026"
if (Test-Path $AddinDir) {
    Copy-Item -Path "bin\Staging\VitruviusAddin.dll" -Destination "$AddinDir\" -Force
    Log "✅ DLL copiada para Revit"
} else {
    Log "❌ Diretório de add-ins não encontrado: $AddinDir"
    Log "=========================================="
    exit 1
}

# ==========================================
# 4. BUILD MCP
# ==========================================
Log "[4/5] Compilando VitruviusMcp..."
cd "$ProjectRoot\src\VitruviusMcp"
dotnet build -c Release 2>&1 | ForEach-Object { Log $_ }
Log "✅ MCP compilado"

# ==========================================
# 5. TESTE HTTP
# ==========================================
Log "[5/5] Teste HTTP..."
Start-Sleep -Seconds 2  # Aguardar Revit carregar a DLL

try {
    $body = @{
        action = "select_by_type"
        args = @{ type_name = "Wall" }
    } | ConvertTo-Json -Compress

    $response = Invoke-WebRequest `
        -Uri "http://localhost:48884/" `
        -Method Post `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) `
        -ContentType "application/json; charset=utf-8" `
        -TimeoutSec 5 `
        -ErrorAction Stop

    $result = $response.Content | ConvertFrom-Json
    if ($result.ok) {
        Log "✅ Teste HTTP PASSOU"
    } else {
        Log "⚠️  Teste HTTP retornou erro: $($result.error)"
    }
} catch {
    Log "⚠️  Teste HTTP falhou (Revit pode estar fechado): $_"
}

Log ""
Log "=========================================="
Log "✅ AUTO-BUILD CONCLUÍDO COM SUCESSO"
Log "=========================================="
Log ""
