param([string]$type = "Wall")

========================================
Teste: select_by_type
========================================

Instruções:
1. Execute com um tipo válido (padrão: "Wall")
2. Exemplos de tipos: "Wall", "Door", "Window", "Floor", "Roof", "FamilyInstance"
3. Revit deve estar aberto com um projeto ativo

Uso:
  .\09-select_by_type.ps1                    # Busca "Wall" (paredes)
  .\09-select_by_type.ps1 "Door"             # Busca "Door" (portas)
  .\09-select_by_type.ps1 "Floor"            # Busca "Floor" (lajes)

========================================

Enviando requisição...
Tipo: $type
Body: {
    "args":  {
                 "type_name":  "$type"
             },
    "action":  "select_by_type"
}

try {
    $body = @{
        action = "select_by_type"
        args = @{
            type_name = $type
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

Tipo: $type
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
