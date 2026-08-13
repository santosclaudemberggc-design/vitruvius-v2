param([string]$typeName = "")

"
========================================
Teste: select_by_type
========================================

Instruções:
1. Execute com um nome de tipo válido
2. Exemplos: 'Parede - 150mm', 'Porta Dupla 1.0x2.1m', 'Coluna C1'
3. Revit deve estar aberto com um projeto ativo

Uso:
  .\09-select_by_type.ps1 'Parede - 150mm'           # Busca por tipo de parede
  .\09-select_by_type.ps1 'Porta Dupla 1.0x2.1m'     # Busca por tipo de porta

========================================
"

if ([string]::IsNullOrWhiteSpace($typeName)) {
    Write-Host "ERRO: Informe o nome do tipo. Exemplo: .\09-select_by_type.ps1 'Parede - 150mm'"
    exit 1
}

Write-Host "Enviando requisição..."
Write-Host "Tipo: $typeName"

try {
    $body = @{
        action = "select_by_type"
        args = @{
            type_name = $typeName
        }
    } | ConvertTo-Json -Compress -Encoding UTF8

    Write-Host "Body: $body`n"

    $response = Invoke-WebRequest -Uri "http://localhost:48884/" `
        -Method Post `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) `
        -ContentType "application/json; charset=utf-8" `
        -ErrorAction Stop

    $result = $response.Content | ConvertFrom-Json

    if ($result.ok) {
        "
SUCESSO!

Tipo: $typeName
Elementos encontrados: $($result.result.count)
"
        if ($result.result.count -gt 0) {
            "Elementos:`n"
            $result.result.elements | ForEach-Object {
                "  ID: $($_.element_id) | Nome: $($_.name) | Categoria: $($_.category) | Tipo: $($_.element_type)"
            }
        }
    } else {
        "ERRO: $($result.error)"
    }
}
catch {
    "ERRO: $_"
}
