# Teste: get_parameter
# Descrição: Lê o valor de um parâmetro de um elemento no Revit
# Uso: Execute com Revit aberto em um projeto, com um elemento selecionado

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Teste: get_parameter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nInstruções:" -ForegroundColor Yellow
Write-Host "1. Abra o Revit com um projeto"
Write-Host "2. Selecione um elemento (parede, porta, coluna, etc)"
Write-Host "3. Copie o ID que aparece no Properties panel"
Write-Host "4. Use o nome exato do parâmetro como aparece no Properties (ex: 'Comments', 'Mark', 'Height')"
Write-Host ""

$elementId = Read-Host "Digite o ID do elemento"
$parameterName = Read-Host "Digite o nome do parâmetro"

$bodyJson = @{
    action = "get_parameter"
    args = @{
        element_id = [int64]$elementId
        parameter_name = $parameterName
    }
} | ConvertTo-Json
$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

Write-Host "`nEnviando requisição..." -ForegroundColor Cyan
Write-Host "Body: $bodyJson`n"

try {
    $response = Invoke-WebRequest `
        -Uri "http://localhost:48884/" `
        -Method Post `
        -Body $bodyBytes `
        -ContentType "application/json; charset=utf-8" `
        -UseBasicParsing `
        -ErrorAction Stop

    $result = $response.Content | ConvertFrom-Json

    if ($result.ok) {
        Write-Host "SUCESSO!" -ForegroundColor Green
        Write-Host "`nResposta:" -ForegroundColor Green
        $result.result | ConvertTo-Json | Write-Host
    } else {
        Write-Host "ERRO!" -ForegroundColor Red
        Write-Host "Mensagem: $($result.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "FALHA NA REQUISIÇÃO!" -ForegroundColor Red
    Write-Host "Erro: $_" -ForegroundColor Red
}

Write-Host ""
