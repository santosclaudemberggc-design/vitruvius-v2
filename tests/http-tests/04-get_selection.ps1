# Teste: get_selection
# Descrição: Lê o(s) elemento(s) atualmente selecionado(s) no Revit
# Uso: Selecione um ou mais elementos no Revit ANTES de rodar este script

Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Teste: get_selection" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan

Write-Host "`nInstruções:" -ForegroundColor Yellow
Write-Host "1. Abra o Revit com um projeto"
Write-Host "2. Selecione um ou mais elementos (parede, porta, coluna, etc)"
Write-Host "3. Rode este script (sem precisar copiar nenhum ID)"
Write-Host ""

$body = @{
    action = "get_selection"
    args = @{}
} | ConvertTo-Json

Write-Host "📤 Enviando requisição..." -ForegroundColor Cyan
Write-Host "Body: $body`n"

try {
    $response = Invoke-WebRequest `
        -Uri "http://localhost:48884/" `
        -Method Post `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop

    $result = $response.Content | ConvertFrom-Json

    if ($result.ok) {
        if ($result.result.count -eq 0) {
            Write-Host "⚠️  Nenhum elemento selecionado no Revit." -ForegroundColor Yellow
        } else {
            Write-Host "✅ SUCESSO!" -ForegroundColor Green
            Write-Host "`n📋 Elementos selecionados ($($result.result.count)):" -ForegroundColor Green
            $result.result.elements | ForEach-Object {
                Write-Host "  - ID: $($_.element_id) | Nome: $($_.name) | Categoria: $($_.category)"
            }
        }
    } else {
        Write-Host "❌ ERRO!" -ForegroundColor Red
        Write-Host "Mensagem: $($result.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ FALHA NA REQUISIÇÃO!" -ForegroundColor Red
    Write-Host "Erro: $_" -ForegroundColor Red
    Write-Host "`nVerifique:" -ForegroundColor Yellow
    Write-Host "  1. Revit está aberto com um documento ativo?"
    Write-Host "  2. Add-in foi carregado? (reinicie Revit se necessário)"
}

Write-Host ""
