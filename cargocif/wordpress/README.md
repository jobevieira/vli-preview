# CargoCIF — template nativo do Elementor

## Arquivo a importar

**`cargocif-elementor-nativo.json`** — template do Elementor (`type: page`, formato `0.4`), feito só com
**containers e widgets nativos** (Container, Heading, Image, Icon List, Button, Icon, Toggle e **Form do Pro**).
Header e rodapé vão dentro do próprio template. Textos, cores e imagens são editáveis no painel, bloco a bloco.

### Imagens
As 10 referências (9 arquivos; o logo aparece no header e no rodapé) apontam para URLs **fixas por commit** em
`raw.githubusercontent.com`. Na importação o Elementor baixa cada uma e grava na **Biblioteca de Mídia**; a página
passa a usar a cópia local. O servidor do WordPress precisa alcançar `raw.githubusercontent.com` (HTTPS) só durante
a importação. Ícones e logo são PNG (SVG exigiria "uploads não filtrados").

## Importar

1. Crie a página e, em **Layout da página**, escolha **Elementor Canvas** (a página tem header e rodapé próprios).
   O template já traz `Canvas` nas configurações da página, mas o Elementor só aplica isso ao criar a página a
   partir dele; ao inserir numa página existente, confira o layout.
2. Abra no Elementor → ícone de pasta → **aba "Templates" (não "Blocks")** → seta de importar → escolha o `.json`.
   (A aba Blocks usa a origem `remote`, que não aceita importação: é o erro *"This source does not support import"*.)
3. Avisos: **Continue** → **Import Without Enabling** (só afeta SVG; o template não usa).
4. Em Meus templates, **Insert** no template **CargoCIF**.
5. Depois: **Elementor → Ferramentas → Regenerar CSS e dados** e limpe o cache do site/plugin de cache.

Alternativas: **Templates → Templates salvos → Importar** (painel) ou `wp elementor library import arquivo.json`.

## Configurar depois de importar
- **Formulário (Pro):** campos Nome, E-mail e Mensagem já vêm. Em **Actions After Submit → Email** informe o
  destinatário de CX/Comunicação (não está no arquivo porque não o conheço).
- **Header:** fixo (sticky do Pro, com `position: sticky` de reserva). No celular o menu é um widget Toggle
  (☰) no lugar do menu do tema.

## Por que a versão anterior vinha errada
Na versão anterior, a altura da imagem do hero, os degradês e vários ajustes dependiam de um único widget HTML com
`<style>` no fim da página. Quando o WordPress remove `<style>` desse widget (usuário sem `unfiltered_html`,
`DISALLOW_UNFILTERED_HTML`, multisite, otimizadores), a página perdia a imagem do hero (altura 0) e os degradês.
Agora **tudo que é estrutura é configuração nativa** (alturas, posições, degradês, tipografia com `clamp()`, linha
do tempo, pontos do fluxo, chips, FAQ). O CSS restante só refina (degradês exatos de 4 pontos, `text-wrap`, blur do
header, estilo do formulário) e vai em **dois lugares**: no widget HTML do fim e no "CSS personalizado" (Pro) do
header. Sem nenhum dos dois, a página continua igual ao original, exceto nesses refinamentos.

## O que foi conferido (WordPress real, Elementor 4.0.1/4.3.5, temas Hello Elementor, Astra e Twenty Twenty-Five)
- Importa pela aba Templates e pelo painel; as imagens entram na Biblioteca de Mídia.
- O template importado renderiza **idêntico, pixel a pixel**, ao template carregado direto (até a seção do formulário), em 1440 e 390 px, no Hello e no Astra.
- Contra a página original: **todas as seções com a mesma altura** (desktop 1920/1600/1440/1280 e mobile 430/390/360;
  ±1 px em 1100/1024); posição vertical dos 108 textos com desvio médio de **0,23 px** no desktop e **0,32 px** no
  celular (medido por glifo). Sem rolagem horizontal de 320 a 1920 px. Pixels que ainda diferem >45/765: ~1,2% no
  desktop e ~3,6% no celular (bordas de texto e reamostragem das fotos), ou seja, **visualmente idêntico, não
  idêntico bit a bit**.
- Com o CSS de refinamento removido (simulando o `<style>` cortado), a página mantém as mesmas alturas e posições.

## Não verificado / limites
- **Form do Pro e Sticky do Pro:** a sandbox não tem o Pro. Os nomes de controle do Form são os do Pro, mas não
  renderizei o widget; o visual e a altura do cartão do formulário precisam ser conferidos no seu site. O original
  tem o contador "0/600" e a seta do botão, que o Form do Pro não tem (o cartão fica ~20 px mais baixo).
- **Faixa 601–800 px (tablets):** o original usa o layout de celular até 800 px; o Elementor muda em 767 px. Entre
  768 e 800 px o layout é o de desktop (sem sobreposição, mas diferente). Telas ≤ 359 px (regra extra do original) não foram reproduzidas.
- **Abaixo de ~1150 px** o original usa colunas que se ajustam ao conteúdo (CSS Grid); aqui são proporções fixas,
  então o texto pode quebrar um pouco diferente.
- **Menu do celular:** abre dentro do header (empurra o conteúdo) em vez de sobrepor, e fecha ao tocar no ☰ de novo.
- Sem Shadow DOM: o tema do site pode influenciar o que o template não define. Tipografia, cores, entrelinhas e
  espaçamentos estão definidos explicitamente em cada widget para reduzir isso.
- O tema com layout normal (não Canvas) limita a largura do conteúdo; use Canvas.

## Arquivos antigos (substituídos)
`cargocif-elementor-template*.json` e `cargocif-elementor.html` (um único widget HTML com Shadow DOM) ficam no
repositório, mas **o arquivo a usar é `cargocif-elementor-nativo.json`**. A página original é `cargocif/index.html`
+ `cargocif/mobile.css`.
