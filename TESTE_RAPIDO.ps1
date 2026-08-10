# 🧪 TESTE RÁPIDO — VITRUVIUS V2
# Execute este script quando Revit estiver aberto com documento ativo

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🧪 TESTE RÁPIDO — VITRUVIUS V2                          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# 1. Testar HTTP Bridge
Write-Host "1️⃣  Testando HTTP Bridge na porta 48884..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:48884/" `
        -Method Post `
        -Body (@{ action = "ping" } | ConvertTo-Json) `
        -ContentType "application/json" `
        -TimeoutSec 5 `
        -ErrorAction Stop

    Write-Host "✅ HTTP Bridge RESPONDENDO!" -ForegroundColor Green
    Write-Host "   Status: $($response.StatusCode)"
    Write-Host ""
}
catch {
    Write-Host "❌ HTTP Bridge NÃO respondeu" -ForegroundColor Red
    Write-Host "   Revit pode não estar aberto ou documento não está ativo"
    Write-Host ""
    exit 1
}

# 2. Testar load_family
Write-Host "2️⃣  Testando load_family..." -ForegroundColor Yellow
Write-Host ""

$familyPath = "C:\Program Files\Autodesk\Revit 2026\Family Templates\English_I\Metric\Generic Model.rft"

if (-not (Test-Path $familyPath)) {
    Write-Host "⚠️  Arquivo de teste não encontrado em: $familyPath" -ForegroundColor Yellow
    Write-Host "   Usando caminho alternativo..."
    $familyPath = "C:\Program Files\Autodesk\Revit 2026\Family Templates\English_I\Metric\Lighting - Ceiling.rfa"
}

$body = @{
    action = "load_family"
    args = @{ family_path = $familyPath }
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:48884/" `
        -Method Post `
        -Body $body `
        -ContentType "application/json" `
        -TimeoutSec 10 `
        -ErrorAction Stop

    $result = $response.Content | ConvertFrom-Json

    if ($result.ok) {
        Write-Host "✅ load_family FUNCIONOU!" -ForegroundColor Green
        Write-Host "   Family ID: $($result.result.family_id)"
        Write-Host "   Family Name: $($result.result.family_name)"
    } else {
        Write-Host "❌ load_family retornou erro:" -ForegroundColor Red
        Write-Host "   $($result.error)"
    }
}
catch {
    Write-Host "❌ Erro ao testar load_family:" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)"
}

Write-Host ""
Write-Host "3️⃣  Testar rotate_element..." -ForegroundColor Yellow
Write-Host ""

Write-Host "ℹ️  Para testar rotate_element:"
Write-Host "   1. Selecione um elemento no Revit"
Write-Host "   2. Copie seu ID (Project Browser → Properties)"
Write-Host "   3. Substitua element_id no script abaixo"
Write-Host ""

Write-Host "Comando para testar:"
Write-Host ""
Write-Host "`$body = @{" -ForegroundColor Magenta
Write-Host "    action = 'rotate_element'" -ForegroundColor Magenta
Write-Host "    args = @{" -ForegroundColor Magenta
Write-Host "        element_id = 123456  # ← Substitua com ID real" -ForegroundColor Magenta
Write-Host "        angle_degrees = 45" -ForegroundColor Magenta
Write-Host "        axis = 'Z'" -ForegroundColor Magenta
Write-Host "    }" -ForegroundColor Magenta
Write-Host "} | ConvertTo-Json" -ForegroundColor Magenta
Write-Host ""

Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ TESTES BÁSICOS CONCLUÍDOS!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Cyan
Write-Host "  1. Abra um documento no Revit"
Write-Host "  2. Execute: .\\TESTE_RAPIDO.ps1"
Write-Host "  3. Veja as respostas"
Write-Host ""
