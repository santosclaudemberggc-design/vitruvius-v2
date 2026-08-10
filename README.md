# VITRUVIUS V2 — Automação Revit via MCP

**Objetivo:** Automatizar 60+ ferramentas do Revit 2026 via Claude usando MCP (Model Context Protocol) e HTTP bridge.

## Status

- ✅ **load_family** — Carrega famílias .rfa
- ✅ **rotate_element** — Rotaciona elementos
- 🟡 **move_element** — Em implementação
- 🟡 **scale_element** — Em implementação
- 📋 **+30 ferramentas** — Roadmap em STRUCTURE.md

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

## Desenvolvimento

Para adicionar nova ferramenta, veja [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Troubleshooting

Erros? Veja [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## Timeline

- **Semana 1 (08-14/08):** 4 ferramentas → 30%
- **Semana 2 (15-21/08):** 5 ferramentas → 35%
- **Semana 3 (22-28/08):** 6 ferramentas → 40%
- **Semana 4 (29/08-04/09):** 7 ferramentas → 50%
- **Meta:** 60+ ferramentas até novembro 2026

---

**Linguagem:** Português  
**Framework:** .NET 8.0-windows  
**Revit:** 2026 Professional  
**Porta HTTP:** 48884
