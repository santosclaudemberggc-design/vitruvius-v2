# Roadmap — VITRUVIUS V2
## Implementação Sequencial de Ferramentas Revit

**Objetivo:** Implementar 300+ ferramentas de automação Revit (de 631-826 potenciais)  
**Período:** Agosto 2026 — Fevereiro 2028 (18 meses)  
**Frequência:** Múltiplas ferramentas por dia (paralelização)  
**Responsável:** Claudemberg + Claude  
**Visão Completa:** Veja [ROADMAP_COMPLETO.md](ROADMAP_COMPLETO.md)  

---

## 📅 Semana 1 (08-14 de Agosto) — 30%
**Meta:** 4 ferramentas + infraestrutura base

| Dia | Ferramenta | Status | Prioridade | Tempo Est. |
|-----|-----------|--------|-----------|-----------|
| 08 (sex) | rotate_element | ✅ Concluído | 🔴 Crítica | 1h |
| 09 (sab) | move_element | ⏳ Em fila | 🔴 Crítica | 1.5h |
| 10 (dom) | scale_element | ⏳ Em fila | 🟡 Alta | 1.5h |
| 11 (seg) | mirror_element | ⏳ Em fila | 🟡 Alta | 1.5h |

**Checklist Semanal:**
- [ ] Infraestrutura HTTP/MCP funcional
- [ ] Padrão de desenvolvimento estabelecido
- [ ] 4 ferramentas implementadas e testadas
- [ ] MCP client pode chamar via Claude

---

## 📅 Semana 2 (15-21 de Agosto) — 35%
**Meta:** 5 ferramentas + módulo de família

| Dia | Ferramenta | Status | Prioridade | Tempo Est. |
|-----|-----------|--------|-----------|-----------|
| 12 (ter) | load_family | ✅ Concluído | 🔴 Crítica | 0.5h |
| 13 (qua) | unload_family | ⏳ Em fila | 🟡 Alta | 1h |
| 14 (qui) | duplicate_family | ⏳ Em fila | 🟡 Alta | 1h |
| 15 (sex) | rename_family | ⏳ Em fila | 🟢 Média | 1h |
| 16 (sab) | set_parameter | ⏳ Em fila | 🔴 Crítica | 1.5h |

**Checklist Semanal:**
- [ ] Módulo Family 100% funcional
- [ ] set_parameter testado com vários tipos
- [ ] Documentação atualizada
- [ ] 9 ferramentas ao total

---

## 📅 Semana 3 (22-28 de Agosto) — 40%
**Meta:** 6 ferramentas + módulo de elementos

| Dia | Ferramenta | Status | Prioridade | Tempo Est. |
|-----|-----------|--------|-----------|-----------|
| 17 (dom) | get_parameter | ⏳ Em fila | 🟡 Alta | 1h |
| 18 (seg) | batch_set_parameters | ⏳ Em fila | 🟡 Alta | 1.5h |
| 19 (ter) | create_wall | ⏳ Em fila | 🟡 Alta | 2h |
| 20 (qua) | create_door | ⏳ Em fila | 🟡 Alta | 1.5h |
| 21 (qui) | create_window | ⏳ Em fila | 🟡 Alta | 1.5h |
| 22 (sex) | create_floor | ⏳ Em fila | 🟡 Alta | 1.5h |

**Checklist Semanal:**
- [ ] Módulo Element Creation funcional
- [ ] Parâmetros podem ser lidos/escritos
- [ ] 15 ferramentas ao total
- [ ] Performance monitorada (latência < 500ms)

---

## 📅 Semana 4 (29/08 - 04/09) — 50%
**Meta:** 7 ferramentas + módulo de seleção/filtro

| Dia | Ferramenta | Status | Prioridade | Tempo Est. |
|-----|-----------|--------|-----------|-----------|
| 23 (sab) | create_roof | ⏳ Em fila | 🟡 Alta | 1.5h |
| 24 (dom) | select_by_type | ⏳ Em fila | 🟡 Alta | 1.5h |
| 25 (seg) | select_by_category | ⏳ Em fila | 🟡 Alta | 1.5h |
| 26 (ter) | select_by_parameter | ⏳ Em fila | 🟡 Alta | 1.5h |
| 27 (qua) | get_element_info | ⏳ Em fila | 🟡 Alta | 1.5h |
| 28 (qui) | get_element_geometry | ⏳ Em fila | 🟡 Alta | 2h |
| 29 (sex) | get_all_parameters | ⏳ Em fila | 🟡 Alta | 1.5h |

**Checklist Semanal:**
- [ ] Módulo Selection/Filter funcional
- [ ] Informações de elementos acessíveis
- [ ] 22 ferramentas ao total
- [ ] 50% do roadmap concluído

---

## 📅 Semana 5+ (Setembro - Novembro) — 100%
**Meta:** 8+ ferramentas + módulos avançados

### Módulo Materials & Appearance (5 ferramentas)
- set_material
- set_fill_pattern
- set_line_weight
- set_color
- apply_material_from_template

### Módulo Views & Sheets (5 ferramentas)
- create_view
- set_view_range
- create_sheet
- add_view_to_sheet
- set_view_properties

### Módulo Links & Referências (3 ferramentas)
- link_revit_file
- unlink_revit_file
- reload_linked_file

### Módulo Annotations (4 ferramentas)
- create_text_note
- create_dimension
- create_detail_line
- create_detail_component

### Módulo Batch Operations (3 ferramentas)
- batch_delete_elements
- batch_move_elements
- batch_copy_elements

---

## 🎯 Priorização Geral

### 🔴 Crítica (15% - Dias 1-3)
1. **rotate_element** — ✅ Base de transformação
2. **move_element** — ✅ Precisa para qualquer posicionamento
3. **load_family** — ✅ Necessário para importar elementos

### 🟡 Alta (50% - Dias 4-14)
4. **scale_element**
5. **mirror_element**
6. **set_parameter** — Base de modificação
7. **get_parameter**
8. **create_wall**
9. **create_door**
10. **create_window**
11. **create_floor**
12. **select_by_type**
13. **select_by_category**
14. **get_element_info**

### 🟢 Média (25% - Dias 15-25)
15. **unload_family**
16. **duplicate_family**
17. **batch_set_parameters**
18. **select_by_parameter**
19. **get_element_geometry**
20. **get_all_parameters**
21. **create_roof**
22. **set_material**
23. **create_view**

### ⚪ Baixa (10% - Dias 26+)
24-30+. Módulos avançados (sheets, links, annotations)

---

## 📊 Métricas de Sucesso

| Métrica | Semana 1 | Semana 2 | Semana 3 | Semana 4 | Meta Final |
|---------|----------|----------|----------|----------|-----------|
| Ferramentas | 4 | 9 | 15 | 22 | 30+ |
| % Roadmap | 13% | 30% | 50% | 73% | 100% |
| Cobertura API | 4 módulos | 6 módulos | 8 módulos | 11 módulos | 15+ módulos |
| Taxa Sucesso | 100% | 100% | 95%+ | 95%+ | 98%+ |
| Latência Média | <500ms | <500ms | <500ms | <500ms | <500ms |

---

## 🔄 Processo Diário

### Para cada ferramenta, executar nesta ordem:

1. **Planejamento (15 min)**
   - Revisar spec da ferramenta
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
- `select_by_*` depende de estabilidade de `ElementFilter`
- `batch_*` dependem de `move_element`, `set_parameter` estáveis
- `create_*` (door/window) dependem de `create_wall` (paredes hospedam portas)

### Testes Cruzados (após cada semana)
- [ ] Ferramenta A + Ferramenta B funcionam juntas?
- [ ] Performance degradou com N ferramentas?
- [ ] Documentação está completa?

### Rollback Strategy
Se ferramenta falhar testes:
1. Desativar case em `RevitCommandHandler.cs`
2. Manter código em arquivo separado (`Commands/_Working/`)
3. Retomar na próxima semana com tempo adicional

---

## 🚀 Início Imediato

**Próxima ferramenta a implementar:** `move_element`  
**Data prevista:** 09 de Agosto (hoje/amanhã)  
**Tempo estimado:** 1.5h  

**Checklist para começar:**
- [ ] Revit 2026 aberto com documento ativo
- [ ] Projeto VITRUVIUS V2 aberto no VS Code/Visual Studio
- [ ] HTTP bridge respondendo em localhost:48884
- [ ] MCP server VitruviusMcp rodando

---

**Status:** 🟢 Pronto para início  
**Última atualização:** 10/08/2026  
**Próxima revisão:** 14/08/2026
