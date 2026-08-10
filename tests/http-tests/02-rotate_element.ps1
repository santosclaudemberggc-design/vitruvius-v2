# Teste: rotate_element
# Descrição: Rotaciona um elemento no Revit
# Uso: Execute com Revit aberto em um projeto, com um elemento selecionado

Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Teste: rotate_element" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan

# Solicitar input do usuário
Write-Host "`nInstruções:" -ForegroundColor Yellow
Write-Host "1. Abra o Revit com um projeto"
Write-Host "2. Selecione um elemento (parede, porta, coluna, etc)"
Write-Host "3. Copie o ID que aparece no Properties panel"
Write-Host ""

$elementId = Read-Host "Digite o ID do elemento para rotacionar"
$angle = Read-Host "Digite o ângulo em graus (ex: 45)"
$axis = Read-Host "Digite o eixo (X, Y, Z) [padrão: Z]"

if ([string]::IsNullOrEmpty($axis)) { $axis = "Z" }

# Montar requisição
$body = @{
    action = "rotate_element"
    args = @{
        element_id = [int64]$elementId
        angle_degrees = [double]$angle
        axis = $axis
    }
} | ConvertTo-Json

Write-Host "`n📤 Enviando requisição..." -ForegroundColor Cyan
Write-Host "Body: $body`n"

# Enviar
try {
    $response = Invoke-WebRequest `
        -Uri "http://localhost:48884/" `
        -Method Post `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop

    $result = $response.Content | ConvertFrom-Json

    if ($result.ok) {
        Write-Host "✅ SUCESSO!" -ForegroundColor Green
        Write-Host "`n📋 Resposta:" -ForegroundColor Green
        $result.result | ConvertTo-Json | Write-Host

        Write-Host "`n✓ Elemento rotacionado!"
        Write-Host "  ID: $($result.result.element_id)"
        Write-Host "  Ângulo: $($result.result.angle_degrees)°"
        Write-Host "  Eixo: $($result.result.axis)"
    } else {
        Write-Host "❌ ERRO!" -ForegroundColor Red
        Write-Host "Mensagem: $($result.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ FALHA NA REQUISIÇÃO!" -ForegroundColor Red
    Write-Host "Erro: $_" -ForegroundColor Red
    Write-Host "`nVerifique:" -ForegroundColor Yellow
    Write-Host "  1. Revit está aberto?"
    Write-Host "  2. Add-in foi carregado? (reinicie Revit se necessário)"
    Write-Host "  3. Elemento ID está correto?"
}

Write-Host ""
