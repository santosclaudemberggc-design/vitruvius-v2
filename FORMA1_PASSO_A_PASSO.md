# 📍 FORMA 1 — Verificar Vitruvius no Gerenciador de Add-ins

## 🎯 Objetivo
Ver visualmente que o Add-in Vitruvius está carregado no Revit.

## ⏱️ Tempo: 30 segundos | Dificuldade: ⭐ Super Fácil

---

## 🔍 PASSO 1: Localize o Menu "Add-ins" ou "Gerenciar"

### Onde procurar:
Na barra de menu do Revit, no topo da janela:

```
Arquivo | Arquitetura | Estrutura | Aço | Pré-moldado | Sistemas | Inserir | Anotar | ...
                                                                            ↓
                                                                    Procure em um desses
```

### Opções possíveis (conforme sua versão do Revit 2026):

**OPÇÃO A: Menu "Gerenciar"**
- Procure por "Gerenciar" na barra superior
- Clique nele

**OPÇÃO B: Menu "Add-ins"**
- Procure por "Add-ins" como menu direto
- Clique nele

**OPÇÃO C: Menu "Complementos"**
- Procure por "Complementos"
- Clique nele

### 💡 Se não conseguir encontrar:
- Os menus podem estar no final da barra (scroll para direita)
- Clique com botão direito na barra de menu para personalizar
- Procure por um ícone de mais (⋯) no final da barra

---

## 🔍 PASSO 2: Procure por "Gerenciador de Add-ins"

Depois que clicar em Gerenciar/Add-ins/Complementos, procure por:

```
┌──────────────────────────────┐
│ Gerenciador de Add-ins       │  ← Clique aqui
│ Add-In Manager               │  ← Ou aqui (em inglês)
└──────────────────────────────┘
```

### Clique nessa opção e uma janela vai abrir

---

## 🔍 PASSO 3: Uma Janela Abrirá com a Lista de Add-ins

### Essa janela mostrará:

```
╔════════════════════════════════════════════╗
║ Gerenciador de Add-ins                     ║
╟────────────────────────────────────────────╢
║ Nome              │ Status     │ Fabricante║
╟────────────────────────────────────────────╢
║ Revit Server      │ Carregado  │ Autodesk ║
║ Dashboard         │ Carregado  │ Autodesk ║
║ Vitruvius         │ ✅ Carregado │ Claude  ║  ← PROCURE POR AQUI!
║ pyRevit           │ Carregado  │ pyRevit  ║
╚════════════════════════════════════════════╝
```

---

## 🔍 PASSO 4: Procure por "Vitruvius"

Na lista de add-ins, procure por:

```
📍 Nome: Vitruvius
📍 Status: ✅ Carregado (ou "Enabled")
📍 Fabricante/Autor: Claude (ou similar)
```

### ✅ Se encontrar com status "Carregado":
**Parabéns! VITRUVIUS ESTÁ ATIVO NO REVIT!** 🎉

### ❌ Se encontrar com status "Desabilitado":
1. Clique no add-in "Vitruvius"
2. Procure por um botão "Carregar" ou "Enable"
3. Clique nele
4. Feche e reabra o Revit
5. Volte ao Gerenciador de Add-ins e verifique se está "Carregado"

### ⚠️ Se não encontrar "Vitruvius" na lista:
1. Significa que a DLL não está no local correto
2. Verifique: `C:\ProgramData\Autodesk\Revit\Addins\2026\VitruviusAddin.dll`
3. Se não estiver lá, copie o arquivo de: `D:\011_VITRUVIUS_V2\src\VitruviusAddin\bin\Staging\`
4. Feche Revit, copie a DLL, reabra Revit
5. Volte ao Gerenciador de Add-ins

---

## 🎬 Resumo Visual

```
1️⃣  Abra Revit
2️⃣  Clique em Gerenciar (ou Add-ins/Complementos)
3️⃣  Clique em "Gerenciador de Add-ins"
4️⃣  Procure por "Vitruvius"
5️⃣  Se estiver escrito "✅ Carregado" → SUCESSO!
```

---

## 📸 Checklist

- [ ] Encontrei o menu "Gerenciar" ou "Add-ins"
- [ ] Cliquei em "Gerenciador de Add-ins"
- [ ] Vi a janela com lista de add-ins
- [ ] Encontrei "Vitruvius" na lista
- [ ] Status está "✅ Carregado"
- [ ] Agora vou fazer a FORMA 2 (visual no Revit)

---

**Próxima Forma:** [FORMA 2 - Teste Visual no Revit](COMO_VER_VITRUVIUS_FUNCIONANDO.md)

**Tempo total:** 30 segundos ⏱️
**Dificuldade:** ⭐ (Muito fácil)
**Confirmação:** Visual direta no Revit
