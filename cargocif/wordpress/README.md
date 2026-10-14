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

1. No painel do WordPress, **fora do editor**: **Templates → Templates salvos**
   (*Saved Templates*) → botão **Importar templates** no topo.
2. Selecione um dos `.json`.
3. Crie uma página, abra no Elementor, ícone de pasta → aba **Meus templates**
   → CargoCIF → **Inserir**.

> **Sobre o erro "This source does not support import".** Pelo código do
> Elementor, das três origens de template (`local`, `cloud`, `remote`) só a
> `remote` (a Biblioteca do Elementor, abas Páginas/Blocos) não implementa
> importação, e o servidor devolve esse erro **antes de ler o arquivo**. No
> editor, a origem enviada é a da aba ativa no momento do upload
> (`elementor.templates.getFilter('source')`). Ou seja: o erro não depende do
> conteúdo do `.json`.
>
> Há ainda um [bug aberto no Elementor 4.0.x](https://github.com/elementor/elementor/issues/35416)
> em que o import pelo editor falha com essa mesma mensagem mesmo com arquivo
> exportado pelo próprio Elementor, enquanto o mesmo arquivo importa pelo painel.
> Se acontecer: (1) limpe o cache do site e da CDN e recarregue o editor;
> (2) importe pelo painel (Templates → Templates salvos → Importar templates) e
> depois insira pelo editor, em Meus templates; (3) via WP-CLI:
> `wp elementor library import caminho/arquivo.json --returnType=ids`.

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

Tudo abaixo foi medido num **simulador** de tema WordPress (HTML e CSS escritos
para provocar conflito), em Chromium. **Não foi testado num WordPress com
Elementor de verdade** — a importação do `.json` em si e o comportamento do
widget HTML do Elementor são os dois pontos a conferir no primeiro uso.

Comparação da versão encapsulada, dentro de um tema deliberadamente hostil
(resets globais, `!important`, colisão das classes `.btn`/`.wrap`/`.stat` e dos
elementos `header`/`nav`/`footer`, container do Elementor com 1140px e padding),
contra a página publicada:

- **0 pixels de diferença** em 320, 360, 390, 430, 600, 768, 801, 1024, 1280,
  1440, 1600 e 1920px;
- 224 elementos com a mesma caixa e os mesmos estilos computados;
- header e rodapé do tema inalterados pela presença do bloco;
- âncoras, menu mobile e formulário funcionando, sem erro de JavaScript;
- o `.json`, renderizado com o GitHub Pages **bloqueado na rede**, deu 0 pixels
  de diferença em 1440, 1024 e 390px e fez 0 requisições externas de imagem.
