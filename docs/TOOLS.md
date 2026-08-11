# Ferramentas Implementadas — VITRUVIUS V2

## Status Geral
- **Ferramentas Implementadas e Testadas:** 2/30 (6.7%)
- **Código Pronto (aguardando build/teste no Windows+Revit):** 2/30 — move_element, get_selection (infra, fora da lista de 30)
- **Última Atualização:** 11/08/2026
- **Próxima Ferramenta:** scale_element

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

**Status:** 🔶 Código implementado — build e teste no Revit pendentes (requer ambiente Windows)
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

**Status:** 🔶 Código implementado — build e teste no Revit pendentes (requer ambiente Windows)
**Data:** 11/08/2026
**Prioridade:** 🔴 Crítica (infraestrutura — usada por todas as outras ferramentas)

**Teste HTTP:**
```powershell
$body = @{ action = "get_selection"; args = @{} } | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost:48884/" -Method Post -Body $body -ContentType "application/json"
```

---

## ⏳ Próximas Ferramentas (Fila)

### 4. scale_element
- **Data Planejada:** 10/08/2026
- **Prioridade:** 🟡 Alta
- **Descrição:** Escala um elemento Revit (aumenta/diminui tamanho)

### 5. mirror_element
- **Data Planejada:** 11/08/2026
- **Prioridade:** 🟡 Alta
- **Descrição:** Espelha um elemento em relação a um plano

---

## 📚 Todos os Módulos Planejados

| # | Ferramenta | Categoria | Prioridade | Status |
|----|-----------|-----------|-----------|--------|
| 1 | load_family | Família | 🔴 Crítica | ✅ |
| 2 | rotate_element | Transformação | 🔴 Crítica | ✅ |
| 3 | move_element | Transformação | 🔴 Crítica | 🔶 |
| 4 | scale_element | Transformação | 🟡 Alta | ⏳ |
| 5 | mirror_element | Transformação | 🟡 Alta | ⏳ |
| 6 | unload_family | Família | 🟡 Alta | ⏳ |
| 7 | duplicate_family | Família | 🟡 Alta | ⏳ |
| 8 | rename_family | Família | 🟢 Média | ⏳ |
| 9 | set_parameter | Parâmetros | 🔴 Crítica | ⏳ |
| 10 | get_parameter | Parâmetros | 🟡 Alta | ⏳ |
| 11 | batch_set_parameters | Parâmetros | 🟡 Alta | ⏳ |
| 12 | create_wall | Criação | 🟡 Alta | ⏳ |
| 13 | create_door | Criação | 🟡 Alta | ⏳ |
| 14 | create_window | Criação | 🟡 Alta | ⏳ |
| 15 | create_floor | Criação | 🟡 Alta | ⏳ |
| 16 | create_roof | Criação | 🟡 Alta | ⏳ |
| 17 | select_by_type | Seleção | 🟡 Alta | ⏳ |
| 18 | select_by_category | Seleção | 🟡 Alta | ⏳ |
| 19 | select_by_parameter | Seleção | 🟡 Alta | ⏳ |
| 20 | get_element_info | Info | 🟡 Alta | ⏳ |
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
```

### Teste MCP (Claude)
```
tools.load_family(family_path="C:\\...\\file.rfa")
tools.rotate_element(element_id=123456, angle_degrees=45)
tools.move_element(element_id=123456, dx=5.0)
tools.get_selection()
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
