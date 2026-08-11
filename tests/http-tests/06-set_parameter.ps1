# Teste: set_parameter
# Descrição: Define o valor de um parâmetro de um elemento no Revit
# Uso: Execute com Revit aberto em um projeto, com um elemento selecionado

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Teste: set_parameter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nInstruções:" -ForegroundColor Yellow
Write-Host "1. Abra o Revit com um projeto"
Write-Host "2. Selecione um elemento (parede, porta, coluna, etc)"
Write-Host "3. Copie o ID que aparece no Properties panel"
Write-Host "4. Use o nome exato do parâmetro como aparece no Properties (ex: 'Comments', 'Mark')"
Write-Host "5. O tipo do valor precisa bater com o StorageType do parâmetro no Revit"
Write-Host "   (Double/Integer = número, String = texto, ElementId = número do ID)"
Write-Host ""

$elementId = Read-Host "Digite o ID do elemento"
$parameterName = Read-Host "Digite o nome do parâmetro"
$valueType = Read-Host "Tipo do valor (numero/texto)"
$rawValue = Read-Host "Digite o novo valor"

if ($valueType -eq "numero") {
    $value = [double]$rawValue
} else {
    $value = $rawValue
}

$body = @{
    action = "set_parameter"
    args = @{
        element_id = [int64]$elementId
        parameter_name = $parameterName
        value = $value
    }
} | ConvertTo-Json

Write-Host "`nEnviando requisição..." -ForegroundColor Cyan
Write-Host "Body: $body`n"

try {
    $response = Invoke-WebRequest `
        -Uri "http://localhost:48884/" `
        -Method Post `
        -Body $body `
        -ContentType "application/json" `
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
