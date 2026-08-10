# 👁️ Como Ver VITRUVIUS Funcionando Dentro do Revit

## 🎯 3 Formas de Confirmar que VITRUVIUS Está Ativo

---

## ✅ FORMA 1: Verificar Carregamento do Add-in

### Passo 1: Abrir Gerenciador de Add-ins

**No Revit:**
1. Clique em **"Add-ins"** (menu superior)
2. Selecione **"Gerenciador de Add-ins"**

### Passo 2: Procurar por Vitruvius

- Procure por **"Vitruvius"** na lista
- Deve estar com status **✅ Carregado**
- Se estiver com status ❌ Desabilitado, clique em "Carregar"

### Indicadores de Sucesso:
```
✅ Nome: Vitruvius
✅ Tipo: Application
✅ Status: Carregado
✅ Local: C:\ProgramData\Autodesk\Revit\Addins\2026\VitruviusAddin.dll
```

---

## ✅ FORMA 2: Testar Operação Visual (Recomendado)

### Objetivo: Criar uma parede e validar que o HTTP Bridge responde

### Passo 1: Preparar Documento

1. **No Revit:**
   - Abra um projeto (ou crie novo)
   - Vá para planta baixa (ex: "Estudo Preliminar - Plantas de piso - EP. Térreo")
   - Veja um ponto de referência (Level)

### Passo 2: Executar Teste HTTP

2. **No PowerShell (D:\011_VITRUVIUS_V2):**

```powershell
# Teste load_family
$json = '{
  "action": "load_family",
  "args": {
    "family_path": "C:\\Program Files\\Autodesk\\Revit 2026\\Family Templates\\English_I\\Metric\\Lighting - Ceiling.rfa"
  }
}'

$response = Invoke-WebRequest -Uri 'http://127.0.0.1:48884/' `
    -Method Post `
    -Body $json `
    -ContentType 'application/json'

$response.Content | ConvertFrom-Json | ConvertTo-Json
```

### Passo 3: Validar Resposta

Se receber resposta como:
```json
{
  "ok": true,
  "result": {
    "status": "sucesso",
    "family_id": 449336,
    "family_name": "Lighting - Ceiling.rfa"
  }
}
```

✅ **VITRUVIUS ESTÁ FUNCIONANDO!**

### Passo 4: Ver Mudança no Revit

- Vá para **Revit** e pressione **F5** (Refresh View)
- A nova família deve aparecer no Project Browser → Families
- Procure por **"Lighting - Ceiling"** na lista de famílias

---

## ✅ FORMA 3: Verificar Resposta em Tempo Real

### Teste Simples (ping)

**No PowerShell:**

```powershell
# Teste de conectividade
$json = '{"action":"teste","args":{}}'

$response = Invoke-WebRequest -Uri 'http://127.0.0.1:48884/' `
    -Method Post `
    -Body $json `
    -ContentType 'application/json' `
    -ErrorAction Stop

Write-Host "HTTP Status: $($response.StatusCode)" -ForegroundColor Green
Write-Host "Resposta: $($response.Content)"
```

**Resultado esperado:**
```
HTTP Status: 200
Resposta: {"ok":false,"error":"Ação desconhecida: 'teste'"}
```

✅ Se receber qualquer resposta = HTTP Bridge está ativo

---

## 🔍 INDICADORES VISUAIS NO REVIT

### 1. Projeto Browser (Project Browser)

**O que procurar:**
- Families → Novas famílias aparecem após load_family
- Views → Novas views aparecem após create_view
- Sheets → Novas folhas aparecem após create_sheet

**Antes de Testar:**
```
Families
  └─ Structural
  └─ Generic Models
```

**Depois de load_family:**
```
Families
  └─ Structural
  └─ Generic Models
  └─ Lighting - Ceiling ✨ ← NOVA!
```

### 2. Properties Panel

**O que procurar:**
- Selecione um elemento
- Properties deve mostrar valores atualizados após set_parameter
- Mudanças refletem em tempo real

### 3. Vista 3D

**O que procurar:**
- Elementos criados aparecem visualmente
- Rotações (rotate_element) mudam orientação
- Movimentos (move_element) mudam posição
- Escalas (scale_element) mudam tamanho

---

## 📊 Tabela de Verificação

| Operação | Como Ver | Indicador |
|----------|----------|-----------|
| **load_family** | Project Browser → Families | Família aparece na lista |
| **create_wall** | Vista 3D / Project Browser | Parede aparece visualmente |
| **rotate_element** | Selecar elemento → gira | Elemento rotaciona |
| **move_element** | Selecionar elemento → move | Elemento muda de posição |
| **set_parameter** | Properties Panel | Valor do parâmetro muda |
| **get_parameter** | HTTP Response JSON | Valor retornado no JSON |
| **create_view** | Project Browser → Views | Nova view aparece |
| **create_sheet** | Project Browser → Sheets | Nova sheet aparece |

---

## 🧪 Teste Prático Completo (Passo a Passo)

### Objetivo: Colocar uma família no projeto e ver no Revit

### PASSO 1: Preparar
```powershell
# No PowerShell, posicione-se no diretório
cd D:\011_VITRUVIUS_V2
```

### PASSO 2: Procurar Caminho da Família
```powershell
# Listar famílias disponíveis
Get-ChildItem "C:\Program Files\Autodesk\Revit 2026\Family Templates\English_I\Metric\" -Filter "*.rfa" | Select-Object Name | Head -5
```

### PASSO 3: Encontrar Family ID Válido

No Revit:
1. Crie uma parede simples (para ter um elemento)
2. Clique nela
3. No Properties, copie o **Element ID** (ex: 123456)

### PASSO 4: Executar Comando

```powershell
# Testar rotate_element com elemento real
$elementId = 123456  # ← Substitua com seu Element ID!

$json = @{
    action = "rotate_element"
    args = @{
        element_id = $elementId
        angle_degrees = 45
        axis = "Z"
    }
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri 'http://127.0.0.1:48884/' `
    -Method Post `
    -Body $json `
    -ContentType 'application/json'

Write-Host "Resposta:" -ForegroundColor Green
$response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3
```

### PASSO 5: Ver no Revit

1. Volte ao Revit
2. Olhe para a parede que rotacionou — **ela deve estar rotacionada 45 graus!**
3. Se rotacionou → ✅ **VITRUVIUS FUNCIONANDO!**

---

## ⚠️ Troubleshooting: Não Vejo Mudanças?

| Problema | Solução |
|----------|---------|
| Família não aparece | Pressione F5 (Refresh), ou feche/abra Project Browser |
| Elemento não rotacionou | Element ID pode estar errado, verifique Properties |
| Sem resposta HTTP | Revit pode estar congelado, tente aguardar 5 seg |
| Erro JSON | Copie/cole a família path exata, evite espaços |
| Precisa reiniciar Revit | Feche Revit, relance, reabra projeto |

---

## 🎬 Video Mental (O que Acontece)

```
Você                    PowerShell              HTTP Bridge           Revit
  │                         │                        │                 │
  ├─→ Executa comando ────→ │                        │                 │
  │                         ├─→ POST JSON ────────→ │                 │
  │                         │                        ├─→ Processa ───→ │
  │                         │                        │   comando      │
  │                         │    ← JSON Response ←───┤                │
  │                         ←─────────────────────────┤                │
  │   ← Vê resposta ←────────┤                        │                │
  │                         │                        │  ← Atualiza    │
  │   Olha Revit ───────────────────────────────────────────→ ✅ Ver mudança!
  │
```

---

## 🏆 Confirmação Final

Se você conseguir fazer qualquer uma dessas 3 verificações:

✅ **Add-in carregado no Gerenciador** → Sistema está ativo  
✅ **Resposta HTTP com "ok":true** → Bridge está funcionando  
✅ **Mudança visual no Revit** → Automação está operacional  

**Parabéns! VITRUVIUS V2 está 100% funcional! 🎉**

---

**Data:** 10/08/2026  
**Status:** ✅ Operacional
