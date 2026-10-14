# CargoCIF — pacote para o WordPress (Elementor)

Três arquivos, mesmo conteúdo:

| Arquivo | Para quê | Imagens |
|---|---|---|
| `cargocif-elementor-template.json` | **Importar** como template (seção + coluna, estrutura clássica) | **Embutidas no arquivo** |
| `cargocif-elementor-template-container.json` | **Importar** como template (container, padrão do Elementor recente) | **Embutidas no arquivo** |
| `cargocif-elementor.html` | **Colar** num widget HTML do Elementor | Buscadas de uma pasta (`ASSETS`) |

Os dois `.json` têm **o mesmo widget, byte a byte**; só muda o invólucro. Teste
primeiro o de **container**; se o seu Elementor o recusar, use o de seção e coluna.

Em ambos, todo o conteúdo vive dentro de um **Shadow DOM**, então o isolamento
vale nos dois sentidos:

- o CSS do tema e do Elementor **não entra** no bloco;
- o CSS do bloco **não vaza** para o header, o rodapé ou qualquer outra parte do site.

A página original continua sendo `cargocif/index.html` + `cargocif/mobile.css`.
Estes arquivos são gerados a partir deles — ao alterar a página, gere de novo em
vez de editar à mão.

## Importar o template (.json)

Use `cargocif-elementor-template-container.json` (container) ou, se o seu
Elementor ainda usa a estrutura clássica, `cargocif-elementor-template.json`.

**Pelo editor, na própria página:**

1. Abra a página no Elementor e clique no **ícone de pasta**.
2. **A biblioteca abre na aba "Blocks". Clique na terceira aba, "Templates"
   (Meus templates), ANTES de importar.** Este é o passo que evita o erro
   *"This source does not support import"* (explicação abaixo).
3. Clique na **seta de importar** e escolha o `.json`.
4. O Elementor avisa que arquivos JSON podem ser inseguros: **Continue**. Em
   seguida pergunta sobre arquivos não filtrados: **Import Without Enabling**
   basta, porque as imagens deste template vão dentro do HTML.
5. Na lista de Meus templates, passe o mouse sobre **CargoCIF** e clique em
   **Insert**.

**Pelo painel do WordPress** (alternativa, não depende de aba): **Templates →
Templates salvos → Importar templates**, escolha o `.json`, **Continue**,
**Import Without Enabling**. Depois, insira pelo editor, em Meus templates.

### Por que dava "This source does not support import"

Reproduzido e confirmado num WordPress limpo, com **Elementor 4.0.1 e 4.3.5**:

- a biblioteca **abre na aba Blocks**, cuja origem de dados é `remote`;
- o pedido de importação leva a origem da aba ativa
  (`elementor.templates.getFilter('source')`), então sai com `remote`;
- das três origens do Elementor (`local`, `cloud`, `remote`), só a `remote` não
  implementa importação, e o servidor responde com esse erro **antes de ler o
  arquivo**. Por isso falha até com um template exportado pelo próprio site, e
  um arquivo de 637 bytes falha igual.
- com a aba **Templates** ativa a origem vira `local` e o mesmo arquivo importa.

Se mesmo assim falhar no seu site, o `.json` não é a causa. Alternativas:
importar pelo painel (acima) ou via WP-CLI:
`wp elementor library import caminho/arquivo.json --returnType=ids`.

## Colar o bloco (.html), com imagens na Biblioteca de Mídia

1. **Envie as 9 imagens** de `cargocif/assets/` para a Biblioteca de Mídia.
2. No Elementor, crie um **Container** com largura **Full Width** e **padding 0**
   (o bloco se expande sozinho, mas sem padding o resultado é mais previsível).
3. Arraste um widget **HTML** para dentro dele.
4. Cole o conteúdo de `cargocif-elementor.html` **inteiro**, do primeiro
   comentário à última linha.
5. No topo do `<script>`, ajuste a constante `ASSETS` para a pasta das imagens
   na Biblioteca de Mídia, **mantendo a barra final**:

   ```js
   var ASSETS = 'https://www.vli-logistica.com.br/wp-content/uploads/2026/10/';
   ```

   Enquanto não ajustar, as imagens vêm do GitHub Pages — bom para testar,
   ruim para produção.

## Formulário

Hoje o bloco valida os campos, confirma e avisa na tela que nada foi enviado.
Há dois caminhos para ligá-lo de verdade:

- **Widget Form do Elementor** — apague o `<form class="lead">` de dentro do
  `<template>` e ponha o widget Form ao lado do bloco. É o caminho que usa o
  fluxo já existente no site.
- **Endpoint próprio** — preencha `FORM_ENDPOINT` no topo do `<script>` com uma
  URL que aceite `POST`. Os campos já se chamam `nome`, `email` e `mensagem`.

> O widget Form do Elementor **não aceita `POST` de outro domínio**: ele exige um
> nonce gerado a cada carregamento da página. Por isso o bloco não tenta enviar
> para ele a partir de fora do WordPress.

## Cuidados

- **Permissão `unfiltered_html`.** O widget HTML só guarda `<script>` e `<style>`
  para quem tem essa permissão. Administradores têm; em **Multisite** só o
  Super Admin. Sem ela, o WordPress remove o script e o bloco aparece sem
  menu, âncoras e formulário.
- **Limites de upload / firewall.** O `.json` tem 738 KB. Hospedagens com
  `upload_max_filesize` baixo ou WAF (ModSecurity, Cloudflare) podem recusá-lo;
  nesse caso use o bloco `.html`.
- **Plugins de minificação/otimização** (Autoptimize, WP Rocket, LiteSpeed):
  excluam este bloco do processamento. Minificadores que reescrevem HTML podem
  quebrar o `<template>` ou o `<style>` interno.
- **Montserrat** é injetada no `<head>` pelo próprio bloco, uma única vez
  (`@font-face` não funciona dentro de Shadow DOM). Se o tema já carrega
  Montserrat, não há conflito — apenas peso extra que pode ser removido.
- O bloco tem o **próprio header fixo**. Se o tema também tiver um, avalie usar
  um template de página sem cabeçalho.
- Para **editar textos**, mexa no `<template>`: é HTML normal.

## Conferência feita

**1. Num WordPress real, com Elementor real** (WordPress Playground, tema
padrão do WordPress, Elementor **4.0.1** e **4.3.5**, Chromium):

- reproduzido o erro *"This source does not support import"* ao importar com a
  aba Blocks ativa, e confirmado que com a aba **Templates** ativa o mesmo
  arquivo importa, nas duas versões;
- importação pelo painel (Templates salvos → Importar templates) também
  funciona;
- o template completo (`cargocif-elementor-template-container.json`) importou
  e, aberto no site, renderizou com o Shadow DOM íntegro, o título correto e
  **0 erros de JavaScript**; **224 elementos com a mesma caixa e 0 estilos
  computados diferentes** da página publicada, em 1440 e 390px.

**2. Num tema deliberadamente hostil** (resets globais, `!important`, colisão
das classes `.btn`/`.wrap`/`.stat` e dos elementos `header`/`nav`/`footer`,
container do Elementor com 1140px e padding), contra a página publicada:

- **0 pixels de diferença** em 320, 360, 390, 430, 600, 768, 801, 1024, 1280,
  1440, 1600 e 1920px;
- header e rodapé do tema inalterados pela presença do bloco;
- âncoras, menu mobile e formulário funcionando, sem erro de JavaScript;
- o `.json`, renderizado com o GitHub Pages **bloqueado na rede**, deu 0 pixels
  de diferença em 1440, 1024 e 390px e fez 0 requisições externas de imagem.

**O que não foi testado:** o site real da VLI (seus plugins e tema), o editor do
Elementor com a aba Templates carregada (na sandbox ela fica em "LOADING" por
não alcançar os servidores do Elementor, então a inserção foi conferida abrindo
o template importado direto no site), e o Elementor Pro.
