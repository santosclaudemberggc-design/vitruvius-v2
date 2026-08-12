# Teste de fumaca do VitruviusMcp
# Verifica se o servidor MCP responde ao protocolo (initialize + tools/list).
# NAO precisa do Revit aberto - testa so o servidor MCP em si.
#
# Uso: build primeiro, depois rode este script:
#   cd D:\011_VITRUVIUS_V2\src\VitruviusMcp
#   dotnet build -c Release
#   cd D:\011_VITRUVIUS_V2
#   .\tests\mcp-tests\00-smoke.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Teste de fumaca: VitruviusMcp" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$dll = Join-Path $PSScriptRoot "..\..\src\VitruviusMcp\bin\Release\net8.0\VitruviusMcp.dll"

if (-not (Test-Path $dll)) {
    Write-Host "DLL nao encontrada em:" -ForegroundColor Red
    Write-Host "  $dll" -ForegroundColor Red
    Write-Host "`nRode o build primeiro:" -ForegroundColor Yellow
    Write-Host "  cd D:\011_VITRUVIUS_V2\src\VitruviusMcp"
    Write-Host "  dotnet build -c Release"
    exit 1
}

# Tres mensagens JSON-RPC, uma por linha, enviadas ao servidor pelo stdin.
$linhas = @(
    '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"smoke","version":"1"}}}',
    '{"jsonrpc":"2.0","method":"notifications/initialized"}',
    '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
)

Write-Host "`nEnviando initialize + tools/list ao servidor MCP...`n" -ForegroundColor Cyan

$saida = $linhas | dotnet $dll

Write-Host "Resposta do servidor:" -ForegroundColor Green
$saida | ForEach-Object { Write-Host $_ }

if ($saida -match '"name":"get_selection"') {
    Write-Host "`nOK! O servidor MCP listou as ferramentas corretamente." -ForegroundColor Green
    Write-Host "Proximo passo: conectar ao Claude local (ver docs\MCP_SETUP.md)." -ForegroundColor Green
} else {
    Write-Host "`nAVISO: nao encontrei 'get_selection' na resposta." -ForegroundColor Yellow
    Write-Host "Verifique se o build foi feito com sucesso." -ForegroundColor Yellow
}

Write-Host ""
