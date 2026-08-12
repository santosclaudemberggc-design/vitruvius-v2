# Teste: get_element_info
# Descrição: Retorna informações detalhadas de um elemento (nome, categoria, tipo, localização, etc)
# Uso: Execute este script passando o ID do elemento ou execute após get_selection

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Teste: get_element_info" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nInstruções:" -ForegroundColor Yellow
Write-Host "1. Execute este script com um element_id válido"
Write-Host "2. Ou selecione um elemento e obtenha seu ID via get_selection"
Write-Host ""

# Se fornecido como argumento, use; caso contrário, pede para selecionar algo
$elementId = if ($args.Count -gt 0) { $args[0] } else { 450002 }

$body = @{
    action = "get_element_info"
    args = @{
        element_id = [long]$elementId
    }
} | ConvertTo-Json

Write-Host "Enviando requisição..." -ForegroundColor Cyan
Write-Host "Element ID: $elementId"
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
        Write-Host "`nInformações do Elemento:" -ForegroundColor Green
        Write-Host "  ID: $($result.result.element_id)"
        Write-Host "  Nome: $($result.result.name)"
        Write-Host "  Categoria: $($result.result.category)"
        Write-Host "  Tipo: $($result.result.element_type)"

        if ($result.result.family_name) {
            Write-Host "  Família: $($result.result.family_name)"
        }

        if ($result.result.level) {
            Write-Host "  Nível: $($result.result.level)"
        }

        if ($result.result.host_id) {
            Write-Host "  Host ID: $($result.result.host_id)"
        }

        if ($result.result.location) {
            Write-Host "  Localização (tipo): $($result.result.location.type)"
            if ($result.result.location.type -eq "Point") {
                Write-Host "    X: $($result.result.location.x), Y: $($result.result.location.y), Z: $($result.result.location.z)"
            } elseif ($result.result.location.type -eq "Curve") {
                Write-Host "    Início: ($($result.result.location.start_x), $($result.result.location.start_y), $($result.result.location.start_z))"
                Write-Host "    Fim: ($($result.result.location.end_x), $($result.result.location.end_y), $($result.result.location.end_z))"
            }
        }

        if ($result.result.material_id) {
            Write-Host "  Material ID: $($result.result.material_id)"
        }

        Write-Host "  Quantidade de Parâmetros: $($result.result.parameters_count)"
        Write-Host "  É Instância: $($result.result.is_instance)"
        Write-Host "  É Tipo: $($result.result.is_type)"
    } else {
        Write-Host "ERRO!" -ForegroundColor Red
        Write-Host "Mensagem: $($result.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "FALHA NA REQUISIÇÃO!" -ForegroundColor Red
    Write-Host "Erro: $_" -ForegroundColor Red
    Write-Host "`nVerifique:" -ForegroundColor Yellow
    Write-Host "  1. Revit está aberto com um documento ativo?"
    Write-Host "  2. Add-in foi carregado? (reinicie Revit se necessário)"
    Write-Host "  3. O element_id ($elementId) é válido?"
}

Write-Host ""
