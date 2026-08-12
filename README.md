# VITRUVIUS V2 — Automação Revit via MCP

**Objetivo:** Automatizar 300+ ferramentas do Revit 2026 via Claude usando MCP (Model Context Protocol) e HTTP bridge.

## Status Atual (12/08/2026)

**Ferramentas Implementadas:** 6/30 (20%)
- ✅ **load_family** — Carrega famílias .rfa
- ✅ **rotate_element** — Rotaciona elementos
- ✅ **move_element** — Move elementos (dx, dy, dz)
- ✅ **get_parameter** — Lê parâmetros
- ✅ **set_parameter** — Define parâmetros
- ✅ **get_element_info** — Retorna informações do elemento (NEW 12/08)

**Próximas (esta semana):**
- ⏳ **select_by_category** — Seleciona por categoria
- ⏳ **select_by_type** — Seleciona por tipo
- 📋 **+190 ferramentas** — Roadmap em ROADMAP.md e ROADMAP_COMPLETO.md

## Arquitetura

```
Claude (MCP Client)
    ↓
VitruviusMcp (MCP Server)
    ↓
HTTP POST localhost:48884
    ↓
HttpBridge (VitruviusAddin)
    ↓
RevitCommandHandler (Dispatcher)
    ↓
Commands/* (Implementações)
    ↓
Revit 2026 API
```

## Quick Start

### 1. Build
```bash
cd D:\011_VITRUVIUS_V2\src\VitruviusAddin
dotnet build -c Release -o bin/Staging
```

### 2. Deploy
```powershell
Copy-Item bin\Staging\VitruviusAddin.dll C:\ProgramData\Autodesk\Revit\Addins\2026\ -Force
```

### 3. Teste HTTP
```powershell
$body = @{ action = "load_family"; args = @{ family_path = "C:\...\rac_basic_sample_family.rfa" } } | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost:48884/" -Method Post -Body $body -ContentType "application/json"
```

## Estrutura

Veja [STRUCTURE.md](STRUCTURE.md) para organização completa.

**Pastas-chave:**
- `src/VitruviusAddin/` — Add-in do Revit
- `src/VitruviusMcp/` — Servidor MCP
- `docs/` — Documentação
- `tests/` — Testes
- `config/` — Configurações e manifests

## Documentação

- **[ROADMAP.md](ROADMAP.md)** — Estratégia de implementação por camadas (primárias → secundárias → terciárias)
- **[ROADMAP_COMPLETO.md](ROADMAP_COMPLETO.md)** — Visão abrangente de todas as 30 categorias e 631-826 ferramentas potenciais
- **[docs/TOOLS.md](docs/TOOLS.md)** — Ferramentas implementadas com exemplos HTTP
- **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** — Como adicionar nova ferramenta
- **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** — Problemas comuns e soluções

## Cronograma Realista (até Novembro)

### Fase 1: Fundação (Agosto-Setembro) — 50 ferramentas
- **12/08:** 6 ferramentas ✅
- **20/08:** +4 ferramentas (select_by_category/type) → 10 total
- **31/08:** +10 ferramentas (transformações, delete, copy) → 20 total
- **30/09:** +30 ferramentas (criação, batch, views) → 50 total

### Fase 2: Especialização (Setembro-Outubro) — +80 ferramentas (130 total)
- **31/10:** Sistemas MEP (40-50) + Estrutural (20-25) + Arquitetura (20-30)

### Fase 3: Avançada (Novembro-Dezembro) — +80 ferramentas (210 total)
- **30/11:** Geometria, Links, Integração Dynamo

**Meta até Novembro:** 210 ferramentas (25-33% de cobertura, 95%+ dos workflows reais)

---

**Linguagem:** Português  
**Framework:** .NET 8.0-windows  
**Revit:** 2026 Professional  
**Porta HTTP:** 48884
