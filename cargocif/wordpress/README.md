# CargoCIF — pacote para o WordPress (Elementor)

Dois arquivos, mesmo conteúdo:

| Arquivo | Para quê | Imagens |
|---|---|---|
| `cargocif-elementor-template.json` | **Importar** em Elementor → Templates → Importar | **Embutidas no arquivo** (nada externo) |
| `cargocif-elementor.html` | **Colar** num widget HTML do Elementor | Buscadas de uma pasta (`ASSETS`) |

Em ambos, todo o conteúdo vive dentro de um **Shadow DOM**, então o isolamento
vale nos dois sentidos:

- o CSS do tema e do Elementor **não entra** no bloco;
- o CSS do bloco **não vaza** para o header, o rodapé ou qualquer outra parte do site.

A página original continua sendo `cargocif/index.html` + `cargocif/mobile.css`.
Estes arquivos são gerados a partir deles — ao alterar a página, gere de novo em
vez de editar à mão.

## Importar o template (.json)

1. No WordPress: **Templates → Biblioteca de templates → Importar templates**
   (ou, dentro do editor, o ícone de pasta → Importar).
2. Selecione `cargocif-elementor-template.json`.
3. Crie uma página, abra no Elementor, **Adicionar template** → aba **Meus
   templates** → CargoCIF → **Inserir**.

O template é uma seção de largura total, sem padding, com um widget HTML dentro.
As cinco imagens (4 fotos + logo) vão **dentro do arquivo**, como `data:` URIs:
não há dependência do GitHub Pages nem da Biblioteca de Mídia, e o importador do
Elementor não precisa baixar nada.

**O que essa escolha custa** (738 KB de arquivo):

- as imagens **não aparecem na Biblioteca de Mídia**, então plugins de CDN, de
  conversão de formato e de lazy-load do WordPress não as enxergam;
- o HTML da página fica ~750 KB mais pesado e as imagens não têm cache separado;
- a foto do topo não pode ser pré-carregada (`preload`) pelo navegador.

Se isso pesar mais que a conveniência, use a opção de colar o bloco `.html`,
hospedando as imagens na Biblioteca de Mídia (próxima seção).

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
