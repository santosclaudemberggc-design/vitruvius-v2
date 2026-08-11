# Roadmap — VITRUVIUS V2
## Implementação por Camadas de Dependência

**Objetivo:** Implementar 300+ ferramentas de automação Revit (de 631-826 potenciais)
**Período:** Agosto 2026 — Fevereiro 2028 (18 meses)
**Frequência:** Múltiplas ferramentas por dia (paralelização)
**Responsável:** Claudemberg + Claude
**Visão Completa:** Veja [ROADMAP_COMPLETO.md](ROADMAP_COMPLETO.md)

---

## 🧱 Estratégia: Primárias → Secundárias → Terciárias

Mudança de estratégia em 11/08: em vez de seguir só a ordem cronológica
original, a fila passa a priorizar **ferramentas primitivas que as outras
ferramentas usam por baixo dos panos**. Uma ferramenta primária bem feita
destrava várias secundárias/terciárias de uma vez (ex.: `get_parameter` e
`set_parameter` tornam `batch_set_parameters` e `select_by_parameter`
triviais depois).

Camada de uma ferramenta = quantas outras ferramentas do roadmap dependem
dela para funcionar:
- **🟢 Primárias:** não dependem de nenhuma outra ferramenta da lista; são a
  base (seleção, leitura/escrita de parâmetro, info do elemento, filtros).
- **🟡 Secundárias:** usam 1+ primária como building block.
- **🔴 Terciárias:** compõem várias primárias/secundárias em fluxos
  específicos (criação de elementos, views, materiais).
- **⚪ Módulos Avançados:** dependem de terciárias já estáveis (sheets,
  links, annotations, batch em massa).

### 🟢 Primárias

| # | Ferramenta | Categoria | Status | Prioridade |
|---|-----------|-----------|--------|-----------|
| 1 | get_selection *(infra, fora das 30 originais)* | Seleção | ✅ Concluído e testado (11/08) | 🔴 Crítica |
| 2 | get_parameter | Parâmetros | ✅ Concluído e testado (11/08) | 🔴 Crítica |
| 3 | set_parameter | Parâmetros | ✅ Concluído e testado (11/08) | 🔴 Crítica |
| 4 | get_element_info | Info | ⏳ Em fila | 🔴 Crítica |
| 5 | select_by_category | Seleção | ⏳ Em fila | 🔴 Crítica |
| 6 | select_by_type | Seleção | ⏳ Em fila | 🟡 Alta |

### 🟡 Secundárias (usam as primárias)

| # | Ferramenta | Depende de | Status | Prioridade |
|---|-----------|-----------|--------|-----------|
| 7 | move_element | get_selection (uso) | ✅ Concluído e testado (11/08) | 🔴 Crítica |
| 8 | rotate_element | get_selection (uso) | ✅ Concluído e testado | 🔴 Crítica |
| 9 | scale_element | get_selection (uso) | ⏳ Em fila | 🟡 Alta |
| 10 | mirror_element | get_selection (uso) | ⏳ Em fila | 🟡 Alta |
| 11 | batch_set_parameters | set_parameter | ⏳ Em fila | 🟡 Alta |
| 12 | select_by_parameter | get_parameter | ⏳ Em fila | 🟡 Alta |
| 13 | get_element_geometry | get_element_info | ⏳ Em fila | 🟡 Alta |
| 14 | get_all_parameters | get_parameter | ⏳ Em fila | 🟡 Alta |
| 15 | unload_family | load_family | ⏳ Em fila | 🟡 Alta |
| 16 | duplicate_family | load_family | ⏳ Em fila | 🟡 Alta |
| 17 | rename_family | load_family | ⏳ Em fila | 🟢 Média |

### 🔴 Terciárias (compõem várias camadas anteriores)

| # | Ferramenta | Depende de | Status | Prioridade |
|---|-----------|-----------|--------|-----------|
| 18 | create_wall | set_parameter | ⏳ Em fila | 🟡 Alta |
| 19 | create_door | create_wall | ⏳ Em fila | 🟡 Alta |
| 20 | create_window | create_wall | ⏳ Em fila | 🟡 Alta |
| 21 | create_floor | set_parameter | ⏳ Em fila | 🟡 Alta |
| 22 | create_roof | set_parameter | ⏳ Em fila | 🟡 Alta |
| 23 | set_material | select_by_category, set_parameter | ⏳ Em fila | 🟢 Média |
| 24 | set_fill_pattern | set_material | ⏳ Em fila | 🟢 Média |
| 25 | set_line_weight | set_parameter | ⏳ Em fila | 🟢 Média |
| 26 | set_color | set_material | ⏳ Em fila | 🟢 Média |
| 27 | create_view | get_element_info | ⏳ Em fila | 🟢 Média |
| 28 | set_view_range | create_view | ⏳ Em fila | 🟢 Média |
| 29 | create_sheet | create_view | ⏳ Em fila | 🟢 Média |
| 30 | add_view_to_sheet | create_sheet, create_view | ⏳ Em fila | ⚪ Baixa |

### ⚪ Módulos Avançados (dependem de terciárias estáveis)

- **Materiais extra:** apply_material_from_template
- **Views & Sheets extra:** set_view_properties
- **Links & Referências:** link_revit_file, unlink_revit_file, reload_linked_file
- **Annotations:** create_text_note, create_dimension, create_detail_line, create_detail_component
- **Batch em massa:** batch_delete_elements, batch_move_elements (usa move_element), batch_copy_elements

---

## 📊 Métricas de Sucesso

| Métrica | Camada Primária | Camada Secundária | Camada Terciária | Meta Final |
|---------|------------------|--------------------|--------------------|-----------|
| Ferramentas | 6 | 11 | 13 | 30+ |
| % Roadmap (das 30) | 20% | 57% | 100% | 100% |
| Taxa Sucesso | 100% | 95%+ | 95%+ | 98%+ |
| Latência Média | <500ms | <500ms | <500ms | <500ms |

---

## 🔄 Processo Diário

### Para cada ferramenta, executar nesta ordem:

1. **Planejamento (15 min)**
   - Revisar spec da ferramenta
   - Confirmar em qual camada ela está (primária/secundária/terciária) e quais dependências ela usa
   - Identificar API Revit necessária
   - Definir parâmetros JSON

2. **Implementação (30-90 min)**
   - Criar `Commands/XyzCommands.cs`
   - Implementar método com validações
   - Adicionar case em `RevitCommandHandler.cs`

3. **MCP (10 min)**
   - Adicionar método em `RevitTools.cs`
   - Documentar parâmetros

4. **Teste (20-30 min)**
   - Criar script em `tests/http-tests/NN-xyz.ps1`
   - Executar teste HTTP
   - Validar no Revit visualmente

5. **Deploy (5 min)**
   - Build: `dotnet build -c Release -o bin/Staging`
   - Verificar DLL em `bin\Staging\VitruviusAddin.dll`
   - Copiar para `C:\ProgramData\Autodesk\Revit\Addins\2026\`

6. **Documentação (10 min)**
   - Atualizar `docs/TOOLS.md`
   - Adicionar à lista de MCP tools
   - Marcar status como ✅

**Tempo total por ferramenta:** 90 min (1.5h) — exceto as críticas (1h)

---

## 📝 Notas de Implementação

### Dependências Entre Ferramentas
Ver tabelas de camadas acima (coluna "Depende de"). Resumo:
- `select_by_*` depende de estabilidade de `ElementFilter`
- `batch_*` dependem de `move_element`, `set_parameter` estáveis
- `create_*` (door/window) dependem de `create_wall` (paredes hospedam portas)

### Ferramenta de Infraestrutura Adicionada (11/08)
Fora das 30 planejadas, foi adicionada `get_selection` (ver docs/TOOLS.md):
lê o elemento selecionado no Revit sem precisar copiar `element_id`
manualmente. Passa a ser o primeiro passo padrão antes de qualquer
ferramenta que exija `element_id`, quando o Claudemberg pedir para agir
sobre "o que está selecionado".

### Testes Cruzados (após cada camada)
- [ ] Ferramenta A + Ferramenta B funcionam juntas?
- [ ] Performance degradou com N ferramentas?
- [ ] Documentação está completa?

### Rollback Strategy
Se ferramenta falhar testes:
1. Desativar case em `RevitCommandHandler.cs`
2. Manter código em arquivo separado (`Commands/_Working/`)
3. Retomar depois com tempo adicional

---

## 🚀 Início Imediato

**Próxima ferramenta a implementar:** `get_element_info`
**Prioridade:** 🔴 Crítica (última primária que falta antes de fechar a camada 🟢)
**Tempo estimado:** 1.5h

**Concluído em 11/08 (build + teste no Revit OK, mesclado em master):**
- `move_element` — `Commands/MoveCommands.cs`
- `get_selection` — `Commands/SelectionCommands.cs`
- `get_parameter` / `set_parameter` — `Commands/ParameterCommands.cs`
- Correções de infra no `HttpBridge.cs` (Content-Type, condição de corrida,
  encoding UTF-8) que destravaram TODAS as ferramentas via HTTP.

Com isso, a camada 🟢 Primárias está quase fechada — falta só
`get_element_info` e `select_by_category`/`select_by_type`.

**Infraestrutura MCP (branch `vitruvius/mcp-server`):** foi criado o
servidor `src/VitruviusMcp/` — o "tradutor" que permite usar o VITRUVIUS
conversando com o Claude local (Claude Desktop / Claude Code), sem rodar
scripts. É a peça que transforma tudo em "só pedir". Pendente: build +
conexão ao Claude na máquina do Claudemberg (ver `docs/MCP_SETUP.md`).
Não tem dependências externas (compila só com o SDK do .NET 8).

**Checklist para começar:**
- [ ] Revit 2026 aberto com documento ativo
- [ ] Projeto VITRUVIUS V2 aberto no VS Code/Visual Studio
- [ ] HTTP bridge respondendo em localhost:48884
- [ ] MCP server VitruviusMcp rodando

---

**Status:** 🟢 Pronto para início
**Última atualização:** 11/08/2026
**Próxima revisão:** 14/08/2026
