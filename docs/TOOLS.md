# Ferramentas Implementadas — VITRUVIUS V2

## Status Geral
- **Ferramentas Implementadas:** 6/30 (20%) — load_family, rotate_element, move_element, get_element_info, get_parameter, set_parameter
- **Infraestrutura testada (fora das 30):** get_selection
- **Última Atualização:** 12/08/2026
- **Próxima Ferramenta:** select_by_category (estratégia de camadas no ROADMAP.md — primárias antes de secundárias/terciárias)

> **Correções de infra durante o teste de 11/08:** ao validar as ferramentas
> no Revit, foram encontrados e corrigidos 3 bugs no `HttpBridge.cs` que
> afetavam TODAS as ferramentas (inclusive load_family/rotate_element):
> (1) resposta HTTP sem `Content-Type` — o PowerShell recebia o corpo como
> bytes em vez de texto; (2) condição de corrida — a partir da 2ª chamada o
> servidor devolvia a resposta da chamada anterior; (3) acentos corrompidos
> no envio (scripts de teste passaram a mandar UTF-8 explícito).

---

## ✅ Ferramentas Ativas

### 1. load_family

**Descrição:** Carrega uma família Revit (.rfa) no documento ativo

**Parâmetros:**
- `family_path` (string): Caminho absoluto para o arquivo .rfa

**Retorno:**
```json
{
  "ok": true,
  "result": {
    "status": "sucesso",
    "family_id": 449336,
    "family_name": "Generic Model.rfa",
    "categoria": "Generic Models"
  }
}
```

**Status:** ✅ Implementado e Testado  
**Data:** 08/08/2026  
**Prioridade:** 🔴 Crítica

**Teste HTTP:**
```powershell
$body = @{
    action = "load_family"
    args = @{ family_path = "C:\...\rac_basic_sample_family.rfa" }
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:48884/" -Method Post -Body $body -ContentType "application/json"
```

---

### 2. rotate_element

**Descrição:** Rotaciona um elemento Revit em torno de um eixo (X, Y ou Z)

**Parâmetros:**
- `element_id` (long): ID do elemento Revit
- `angle_degrees` (double): Ângulo de rotação em graus (0-360)
- `axis` (string, optional): Eixo de rotação - "X", "Y", ou "Z" (padrão: "Z")

**Retorno:**
```json
{
  "ok": true,
  "result": {
    "status": "sucesso",
    "elemento_id": 123456,
    "angulo_original": 0,
    "angulo_novo": 45,
    "eixo": "Z"
  }
}
```

**Status:** ✅ Implementado e Testado  
**Data:** 08/08/2026  
**Prioridade:** 🔴 Crítica

**Teste HTTP:**
```powershell
$body = @{
    action = "rotate_element"
    args = @{
        element_id = 123456
        angle_degrees = 45
        axis = "Z"
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:48884/" -Method Post -Body $body -ContentType "application/json"
```

---

### 3. move_element

**Descrição:** Move um elemento Revit por um deslocamento (dx, dy, dz) em pés

**Parâmetros:**
- `element_id` (long): ID do elemento Revit
- `dx` (double, optional): Deslocamento em X, em pés (padrão: 0)
- `dy` (double, optional): Deslocamento em Y, em pés (padrão: 0)
- `dz` (double, optional): Deslocamento em Z, em pés (padrão: 0)

**Retorno:**
```json
{
  "ok": true,
  "result": {
    "element_id": 123456,
    "dx": 5.0,
    "dy": 0,
    "dz": 0,
    "status": "movido"
  }
}
```

**Status:** ✅ Implementado e Testado no Revit (11/08/2026 — mudou vaga de estacionamento 5 pés em X, confirmado visualmente)
**Data:** 11/08/2026
**Prioridade:** 🔴 Crítica

**Teste HTTP:**
```powershell
$body = @{
    action = "move_element"
    args = @{
        element_id = 123456
        dx = 5.0
        dy = 0
        dz = 0
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:48884/" -Method Post -Body $body -ContentType "application/json"
```

---

### 9. set_parameter

**Descrição:** Define o valor de um parâmetro de um elemento Revit (por nome, via `LookupParameter`)

**Parâmetros:**
- `element_id` (long): ID do elemento Revit
- `parameter_name` (string): Nome do parâmetro (como aparece no Properties)
- `value` (number ou string): Novo valor — o tipo precisa bater com o `StorageType` do parâmetro (Double/Integer → número, String → texto, ElementId → número do ID)

**Retorno:**
```json
{
  "ok": true,
  "result": {
    "element_id": 123456,
    "parameter_name": "Comments",
    "status": "definido"
  }
}
```

**Status:** ✅ Implementado e Testado no Revit (11/08/2026 — gravou "Testado pelo Vitruvius" no parâmetro Comentários, confirmado por leitura e no Properties)
**Data:** 11/08/2026
**Prioridade:** 🔴 Crítica (primária — base de modificação de elementos)

**Teste HTTP:**
```powershell
$body = @{
    action = "set_parameter"
    args = @{
        element_id = 123456
        parameter_name = "Comments"
        value = "Testado pelo Vitruvius"
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:48884/" -Method Post -Body $body -ContentType "application/json"
```

---

### 10. get_parameter

**Descrição:** Lê o valor de um parâmetro de um elemento Revit (por nome, via `LookupParameter`)

**Parâmetros:**
- `element_id` (long): ID do elemento Revit
- `parameter_name` (string): Nome do parâmetro (como aparece no Properties)

**Retorno:**
```json
{
  "ok": true,
  "result": {
    "element_id": 123456,
    "parameter_name": "Comments",
    "value": "Testado pelo Vitruvius",
    "value_string": "Testado pelo Vitruvius",
    "storage_type": "String",
    "is_read_only": false
  }
}
```

**Status:** ✅ Implementado e Testado no Revit (11/08/2026 — leu o parâmetro Comentários da vaga de estacionamento)
**Data:** 11/08/2026
**Prioridade:** 🔴 Crítica (primária — base de leitura de elementos)

**Teste HTTP:**
```powershell
$body = @{
    action = "get_parameter"
    args = @{
        element_id = 123456
        parameter_name = "Comments"
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:48884/" -Method Post -Body $body -ContentType "application/json"
```

---

## 🛠️ Ferramentas de Infraestrutura (fora da lista original de 30)

Ferramentas de apoio que não fazem parte das 30 planejadas no ROADMAP.md,
mas que reduzem atrito no uso das demais (ex.: evitar copiar `element_id`
manualmente do painel Properties).

### get_selection

**Descrição:** Retorna o(s) elemento(s) atualmente selecionado(s) no Revit,
sem precisar informar `element_id`. Fluxo pretendido: você seleciona o
elemento no Revit, pede pra executar uma ferramenta, e o Claude chama
`get_selection` primeiro para descobrir o(s) ID(s) antes de chamar a
ferramenta desejada (ex.: `move_element`).

**Parâmetros:** nenhum

**Retorno:**
```json
{
  "ok": true,
  "result": {
    "count": 1,
    "elements": [
      { "element_id": 123456, "name": "Parede básica", "category": "Paredes" }
    ],
    "element_id": 123456,
    "status": "sucesso"
  }
}
```
- `element_id` no nível raiz do `result` só vem preenchido quando há
  exatamente 1 elemento selecionado (atalho); com 0 ou 2+ elementos, use a
  lista `elements`.

**Status:** ✅ Implementado e Testado no Revit (11/08/2026 — leu a vaga de estacionamento selecionada, ID 450002, sem cópia manual)
**Data:** 11/08/2026
**Prioridade:** 🔴 Crítica (infraestrutura — usada por todas as outras ferramentas)

**Teste HTTP:**
```powershell
$body = @{ action = "get_selection"; args = @{} } | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost:48884/" -Method Post -Body $body -ContentType "application/json"
```

---

### 11. get_element_info

**Descrição:** Retorna informações detalhadas de um elemento Revit (nome, categoria, tipo, localização, nível, material, etc)

**Parâmetros:**
- `element_id` (long): ID do elemento Revit

**Retorno:**
```json
{
  "ok": true,
  "result": {
    "element_id": 450002,
    "name": "Vaga 001",
    "category": "Genéricos",
    "element_type": "Genérico",
    "family_name": null,
    "host_id": null,
    "is_instance": false,
    "is_type": false,
    "level": "Pavimento Térreo",
    "location": {
      "type": "Point",
      "x": 100.5,
      "y": 200.25,
      "z": 0.0
    },
    "material_id": null,
    "parameters_count": 42
  }
}
```

**Status:** ✅ Implementado (12/08/2026) — pronto para teste no Revit
**Data:** 12/08/2026
**Prioridade:** 🔴 Crítica (primária — fecha a camada 🟢)

**Teste HTTP:**
```powershell
$body = @{
    action = "get_element_info"
    args = @{
        element_id = 450002
    }
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:48884/" -Method Post -Body $body -ContentType "application/json"
```

---

## ⏳ Próximas Ferramentas (Fila)

> A partir de 11/08, a ordem segue a estratégia de camadas do ROADMAP.md
> (primárias → secundárias → terciárias), não mais a data original.

### select_by_category *(próxima — fecha a camada 🟢 Primárias)*
- **Prioridade:** 🔴 Crítica
- **Descrição:** Retorna todos os elementos de uma categoria (ex: todas as paredes)
- **Data Estimada:** 13/08/2026

### 4. scale_element
- **Prioridade:** 🟡 Alta
- **Descrição:** Escala um elemento Revit (aumenta/diminui tamanho)

### 5. mirror_element
- **Prioridade:** 🟡 Alta
- **Descrição:** Espelha um elemento em relação a um plano

---

## 📚 Todos os Módulos Planejados

| # | Ferramenta | Categoria | Prioridade | Status |
|----|-----------|-----------|-----------|--------|
| 1 | load_family | Família | 🔴 Crítica | ✅ |
| 2 | rotate_element | Transformação | 🔴 Crítica | ✅ |
| 3 | move_element | Transformação | 🔴 Crítica | ✅ |
| 4 | scale_element | Transformação | 🟡 Alta | ⏳ |
| 5 | mirror_element | Transformação | 🟡 Alta | ⏳ |
| 6 | unload_family | Família | 🟡 Alta | ⏳ |
| 7 | duplicate_family | Família | 🟡 Alta | ⏳ |
| 8 | rename_family | Família | 🟢 Média | ⏳ |
| 9 | set_parameter | Parâmetros | 🔴 Crítica | ✅ |
| 10 | get_parameter | Parâmetros | 🔴 Crítica | ✅ |
| 11 | batch_set_parameters | Parâmetros | 🟡 Alta | ⏳ |
| 12 | create_wall | Criação | 🟡 Alta | ⏳ |
| 13 | create_door | Criação | 🟡 Alta | ⏳ |
| 14 | create_window | Criação | 🟡 Alta | ⏳ |
| 15 | create_floor | Criação | 🟡 Alta | ⏳ |
| 16 | create_roof | Criação | 🟡 Alta | ⏳ |
| 17 | select_by_type | Seleção | 🟡 Alta | ⏳ |
| 18 | select_by_category | Seleção | 🟡 Alta | ⏳ |
| 19 | select_by_parameter | Seleção | 🟡 Alta | ⏳ |
| 20 | get_element_info | Info | 🔴 Crítica | ✅ |
| 21 | get_element_geometry | Info | 🟡 Alta | ⏳ |
| 22 | get_all_parameters | Info | 🟡 Alta | ⏳ |
| 23 | set_material | Materiais | 🟢 Média | ⏳ |
| 24 | set_fill_pattern | Materiais | 🟢 Média | ⏳ |
| 25 | set_line_weight | Materiais | 🟢 Média | ⏳ |
| 26 | set_color | Materiais | 🟢 Média | ⏳ |
| 27 | create_view | Views | 🟢 Média | ⏳ |
| 28 | set_view_range | Views | 🟢 Média | ⏳ |
| 29 | create_sheet | Sheets | 🟢 Média | ⏳ |
| 30 | add_view_to_sheet | Sheets | ⚪ Baixa | ⏳ |

---

## 🔧 Como Testar Ferramentas

### Teste HTTP (PowerShell)
```powershell
cd D:\011_VITRUVIUS_V2

# Revit deve estar aberto com documento ativo
.\tests\http-tests\01-load_family.ps1
.\tests\http-tests\02-rotate_element.ps1
.\tests\http-tests\03-move_element.ps1
.\tests\http-tests\04-get_selection.ps1
.\tests\http-tests\05-get_parameter.ps1
.\tests\http-tests\06-set_parameter.ps1
```

### Via MCP (conversando com o Claude local)

O servidor `src/VitruviusMcp/` expõe estas ferramentas para o Claude rodando
no seu PC — aí basta pedir em português (ex.: "move a peça selecionada 5 pés
em X") que o Claude chama `get_selection` + `move_element` sozinho, sem
PowerShell. Veja o passo a passo em **[docs/MCP_SETUP.md](MCP_SETUP.md)**.

Teste de fumaça do servidor MCP (não precisa do Revit):
```powershell
cd D:\011_VITRUVIUS_V2\src\VitruviusMcp
dotnet build -c Release
cd D:\011_VITRUVIUS_V2
.\tests\mcp-tests\00-smoke.ps1
```

---

## 📝 Notas de Implementação

### Padrão de Retorno
Todas as ferramentas retornam JSON no formato:
```json
{
  "ok": true,  // ou false em caso de erro
  "result": { ... },  // dados da operação
  "error": "mensagem de erro"  // se ok=false
}
```

### Validações Obrigatórias
- ✅ Verificar se elemento existe
- ✅ Verificar se tipo é compatível
- ✅ Usar Transaction com rollback
- ✅ Retornar mensagens de erro claras

### Testes Obrigatórios
- ✅ Teste HTTP (PowerShell)
- ✅ Teste Revit (visual, com documento aberto)
- ✅ Teste de erro (elemento inválido, parâmetro faltando)

---

**Última revisão:** 11/08/2026  
**Responsável:** Claudemberg + Claude  
**Próxima atualização:** Diária (conforme implementação de ferramentas)
