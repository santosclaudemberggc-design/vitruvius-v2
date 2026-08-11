# Teste: move_element
# Descrição: Move um elemento no Revit por um deslocamento (dx, dy, dz)
# Uso: Execute com Revit aberto em um projeto, com um elemento selecionado

Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Teste: move_element" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan

# Solicitar input do usuário
Write-Host "`nInstruções:" -ForegroundColor Yellow
Write-Host "1. Abra o Revit com um projeto"
Write-Host "2. Selecione um elemento (parede, porta, coluna, etc)"
Write-Host "3. Copie o ID que aparece no Properties panel"
Write-Host "4. Deslocamentos são em pés (unidade interna do Revit)"
Write-Host ""

$elementId = Read-Host "Digite o ID do elemento para mover"
$dx = Read-Host "Deslocamento em X (pés) [padrão: 0]"
$dy = Read-Host "Deslocamento em Y (pés) [padrão: 0]"
$dz = Read-Host "Deslocamento em Z (pés) [padrão: 0]"

if ([string]::IsNullOrEmpty($dx)) { $dx = 0 }
if ([string]::IsNullOrEmpty($dy)) { $dy = 0 }
if ([string]::IsNullOrEmpty($dz)) { $dz = 0 }

# Montar requisição
$body = @{
    action = "move_element"
    args = @{
        element_id = [int64]$elementId
        dx = [double]$dx
        dy = [double]$dy
        dz = [double]$dz
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

        Write-Host "`n✓ Elemento movido!"
        Write-Host "  ID: $($result.result.element_id)"
        Write-Host "  dx: $($result.result.dx)"
        Write-Host "  dy: $($result.result.dy)"
        Write-Host "  dz: $($result.result.dz)"
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
