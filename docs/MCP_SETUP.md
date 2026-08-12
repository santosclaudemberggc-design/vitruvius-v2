# VITRUVIUS MCP — Como conectar ao Claude (usar "só pedindo")

Este guia liga o VITRUVIUS ao Claude **rodando no seu computador**, para você
poder dizer *"move a parede selecionada 5 pés"* em vez de rodar scripts.

## Como funciona (o desenho)

```
Claude (no seu PC)  <-- stdio/MCP -->  VitruviusMcp  <-- HTTP -->  Revit + add-in
```

- O **VitruviusMcp** é um programinha que fica no seu PC.
- Ele NÃO conversa com o Claude da web (nuvem) — só com um **Claude local**
  (Claude Desktop ou Claude Code instalado na sua máquina), porque o Revit
  só é acessível em `localhost` (o seu próprio computador).

---

## Passo 1 — Build do servidor MCP

```powershell
cd D:\011_VITRUVIUS_V2\src\VitruviusMcp
dotnet build -c Release
```

Isso gera o arquivo:
```
D:\011_VITRUVIUS_V2\src\VitruviusMcp\bin\Release\net8.0\VitruviusMcp.dll
```

## Passo 2 — Teste de fumaça (não precisa do Revit)

```powershell
cd D:\011_VITRUVIUS_V2
.\tests\mcp-tests\00-smoke.ps1
```

Se aparecer a lista de ferramentas (incluindo `get_selection`), o servidor
MCP está funcionando. Pode seguir.

## Passo 3 — Conectar ao Claude local

Escolha **A** ou **B**, conforme o Claude que você usa no PC.

### A) Claude Code (linha de comando)

```powershell
claude mcp add vitruvius -- dotnet "D:\011_VITRUVIUS_V2\src\VitruviusMcp\bin\Release\net8.0\VitruviusMcp.dll"
```

Confira depois com:
```powershell
claude mcp list
```

### B) Claude Desktop (aplicativo)

Dentro do app: **Configurações → Desenvolvedor → "Servidores MCP locais"**.
Adicione a entrada `vitruvius` dentro de `mcpServers`, apontando **direto para
o `.exe`** (mais robusto — não depende do `dotnet` estar no PATH do app):

```json
{
  "mcpServers": {
    "vitruvius": {
      "command": "D:\\011_VITRUVIUS_V2\\src\\VitruviusMcp\\bin\\Release\\net8.0\\VitruviusMcp.exe"
    }
  }
}
```
(No JSON, as barras invertidas do caminho ficam duplas: `\\`.)

Depois **feche o Claude Desktop de verdade** (ícone na bandeja do Windows →
botão direito → **Sair**) e reabra. Confira em **Desenvolvedor** se o
`vitruvius` está **running**.

> ⚠️ **ATENÇÃO — onde fica o arquivo de config (pegadinha da Microsoft Store):**
> Se você instalou o Claude Desktop pela **Microsoft Store**, o
> `claude_desktop_config.json` **NÃO** fica em `%APPDATA%\Claude\`. Ele fica
> numa pasta empacotada, tipo:
> `C:\Users\<voce>\AppData\Local\Packages\Claude_<id>\LocalCache\Roaming\Claude\claude_desktop_config.json`
>
> Editar o arquivo da pasta normal **não terá efeito nenhum** — o app ignora.
> Para achar o arquivo certo sem erro, use o botão **"Editar Config"** na tela
> Desenvolvedor: ele revela o arquivo que o app realmente lê. Esse arquivo
> costuma ter MUITA configuração sua (sessões, preferências) — **não apague
> nada**; só adicione o `vitruvius` dentro do `mcpServers` (que pode estar
> vazio, `"mcpServers": {}`).
>
> Comando PowerShell para inserir o `vitruvius` no arquivo certo sem tocar no
> resto (funciona tanto para Store quanto instalação normal):
> ```powershell
> $real=(Get-ChildItem "$env:LOCALAPPDATA\Packages\Claude_*\LocalCache\Roaming\Claude\claude_desktop_config.json","$env:APPDATA\Claude\claude_desktop_config.json" -ErrorAction SilentlyContinue|Select-Object -First 1).FullName
> $txt=Get-Content $real -Raw
> $novo=$txt -replace '"mcpServers":\s*\{\s*\}','"mcpServers": { "vitruvius": { "command": "D:\\011_VITRUVIUS_V2\\src\\VitruviusMcp\\bin\\Release\\net8.0\\VitruviusMcp.exe" } }'
> [System.IO.File]::WriteAllText($real,$novo,(New-Object System.Text.UTF8Encoding($false)))
> ```

---

## Passo 4 — Usar

1. Abra o **Revit 2026** com um projeto (o add-in Vitruvius carregado).
2. Selecione um elemento.
3. No **Claude local**, peça em português. Exemplos:
   - "Pegue o elemento selecionado e me diga o ID e a categoria."
   - "Move a peça selecionada 5 pés no eixo X."
   - "Leia o parâmetro Comentários do elemento selecionado."
   - "Escreva 'Revisado' no parâmetro Comentários do que está selecionado."

O Claude vai chamar as ferramentas sozinho (`get_selection`, depois
`move_element`, etc.). Sem PowerShell, sem copiar ID.

---

## Ferramentas disponíveis via MCP

| Ferramenta | O que faz |
|-----------|-----------|
| `get_selection` | Lê o(s) elemento(s) selecionado(s) no Revit |
| `get_parameter` | Lê um parâmetro de um elemento (por nome) |
| `set_parameter` | Grava um valor em um parâmetro |
| `move_element` | Move um elemento (dx, dy, dz em pés) |
| `rotate_element` | Rotaciona um elemento (graus, eixo) |
| `load_family` | Carrega uma família .rfa |

À medida que novas ferramentas forem criadas no add-in, basta adicioná-las
na lista `BuildToolDefs()` do `Program.cs` e refazer o build.

---

## Se algo der errado

- **"Não foi possível falar com o Revit em localhost:48884"** → o Revit não
  está aberto, ou o add-in não carregou. Abra o Revit com um projeto.
- **O Claude não vê o servidor** → confira o caminho da DLL na configuração e
  reinicie o Claude (Desktop precisa ser fechado e reaberto).
- **Nome de parâmetro não encontrado** → use o nome exato do painel
  Propriedades, com acentos (ex.: `Comentários`, não `Comments`).

---

**Observação importante sobre o Claude da web (nuvem):** a sessão do Claude
no navegador roda na nuvem e **não alcança** o seu `localhost`. Por isso o
"só pedir" funciona com o Claude **local**. A rotina diária automática (que
roda na nuvem) continua escrevendo/planejando código, mas quem executa no
Revit é o Claude local via este MCP.
