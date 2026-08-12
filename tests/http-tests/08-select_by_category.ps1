param([string]$category = "Mobiliário")

========================================
Teste: select_by_category
========================================

Instruções:
1. Execute com uma categoria válida (padrão: "Mobiliário")
2. Exemplos de categorias: "Paredes", "Portas", "Janelas", "Colunas", "Vigas", "Lajes", "Móveis"
3. Revit deve estar aberto com um projeto ativo

Uso:
  .\08-select_by_category.ps1                     # Busca "Mobiliário"
  .\08-select_by_category.ps1 "Paredes"           # Busca "Paredes"
  .\08-select_by_category.ps1 "Portas"            # Busca "Portas"

========================================

Enviando requisição...
Categoria: $category
Body: {
    "args":  {
                 "category_name":  "$category"
             },
    "action":  "select_by_category"
}

try {
    $body = @{
        action = "select_by_category"
        args = @{
            category_name = $category
        }
    } | ConvertTo-Json -Compress -Encoding UTF8

    $response = Invoke-WebRequest -Uri "http://localhost:48884/" `
        -Method Post `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) `
        -ContentType "application/json; charset=utf-8" `
        -ErrorAction Stop

    $result = $response.Content | ConvertFrom-Json

    if ($result.ok) {
        "
SUCESSO!

Categoria: $category
Elementos encontrados: $($result.result.count)
"
        if ($result.result.count -gt 0) {
            "Elementos:`n"
            $result.result.elements | ForEach-Object {
                "  ID: $($_.element_id) | Nome: $($_.name) | Tipo: $($_.element_type)"
            }
        }
    } else {
        "ERRO: $($result.error)"
    }
}
catch {
    "ERRO: $_"
}
