# CargoCIF — template nativo para o Elementor

## Arquivo a importar

**`cargocif-elementor-nativo.json`** — template do Elementor (`type: page`,
formato `0.4`) feito só com **widgets e containers nativos**: Container flexbox,
Heading, Text Editor, Image, Icon List, Button, Icon, Toggle e **Form (Pro)**.
Não há HTML embutido nem Shadow DOM. Header e rodapé vão no próprio template.

Os textos, as cores e as imagens são editáveis no painel do Elementor, bloco a
bloco.

### Imagens

As 10 referências (9 arquivos; o logo aparece no header e no rodapé) são URLs
**fixas por commit** (`raw.githubusercontent.com/.../<sha>/cargocif/assets/...`).
Ao importar, o Elementor baixa cada uma e a grava na **Biblioteca de Mídia** do
WordPress; a página passa a usar a cópia local. Depois do import o GitHub não é
mais necessário. Requisito: o servidor do WordPress precisa conseguir acessar
`raw.githubusercontent.com` (saída HTTPS) durante o import.

Ícones e logo estão em PNG (SVG exigiria "uploads não filtrados" no WordPress).

## Importar

**Pelo editor:**

1. Crie uma página e, em **Layout da página**, escolha **Elementor Canvas** (a
   página tem o próprio header e rodapé; o Canvas evita o duplicado do tema).
2. Abra no Elementor e clique no **ícone de pasta**.
3. **A biblioteca abre na aba "Blocks". Clique na aba "Templates" ANTES de
   importar.** Isso evita *"This source does not support import"* (abaixo).
4. Clique na **seta de importar** e escolha o `.json`.
5. *"JSON files may be unsafe"* → **Continue**. Sobre arquivos não filtrados →
   **Import Without Enabling** basta.
6. Em Meus templates, passe o mouse sobre **CargoCIF** e clique em **Insert**.

**Pelo painel** (não depende de aba): **Templates → Templates salvos →
Importar templates**, escolha o `.json`; depois insira pelo editor.

**WP-CLI:** `wp elementor library import cargocif-elementor-nativo.json`

### Por que dava "This source does not support import"

Reproduzido num WordPress limpo, com Elementor 4.0.1 e 4.3.5. A biblioteca abre
na aba Blocks (origem `remote`); o pedido de importação leva a origem da aba
ativa e só a `remote` não implementa importação, então o servidor recusa **antes
de ler o arquivo** — por isso falha até com um template exportado pelo próprio
site. Com a aba **Templates** ativa a origem vira `local` e importa.

## Configurar depois de importar

1. **Formulário (Elementor Pro).** O widget Form vem com Nome, E-mail e Mensagem
   (máx. 600 caracteres). Em **Actions After Submit** adicione **Email** e
   coloque o destinatário de CX/Comunicação (e o assunto desejado). Não deixei
   um e-mail no arquivo porque não o conheço.
2. **Header fixo.** O header usa *sticky* do Pro (e um `position: sticky` de
   reserva).
3. **Menu no celular.** O Nav Menu do Pro exige um menu do WordPress; por isso
   no celular o header mostra só o botão de CTA compacto, sem hambúrguer.
4. Todo o CSS fino (estados, gradientes, linha do tempo) fica em **um único
   widget HTML `<style>` no fim da página**, por classes `ccx-*`, não por ID —
   o Elementor troca os IDs ao importar. Não apague esse widget.

## Conferência feita

Num WordPress real (Playground), tema padrão, Elementor **4.0.1 e 4.3.5**,
Chromium:

- importa com a aba Templates ativa, e pelo painel;
- as imagens entram na **Biblioteca de Mídia**; reimportar reaproveita (o
  Elementor deduplica por hash);
- todas as chaves de configuração do template são reconhecidas pelo editor;
- depois de importado, hero até Inovação renderiza **sem diferença de pixels**
  em relação ao template antes do import, em 1440 e 390px;
- sem rolagem horizontal de 320 a 1920px.

Fidelidade contra a página original (`cargocif/index.html`): **não é idêntica
pixel a pixel**. No desktop, os textos-chave ficam em média 3,9 px do original e
as seções dentro de ±9 px. No celular, as seções batem em ±1 px, exceto
Operação (+22 px) e CTA (−10 px).

**O que não foi testado:**

- o **widget Form** e o *sticky* (são do Pro, que a sandbox não tem): a
  renderização e o envio precisam ser conferidos no seu site;
- o site real da VLI (tema e plugins). Sem Shadow DOM, o tema pode influenciar
  tipografia e espaçamento; o Canvas minimiza isso;
- no Form faltam o contador "0/600" e a seta do botão do original.

## Arquivos antigos (substituídos)

`cargocif-elementor-template*.json` e `cargocif-elementor.html` são a versão
anterior (um único widget HTML com Shadow DOM). Continuam no repositório, mas
**o arquivo a usar é o `cargocif-elementor-nativo.json`**.

A página original continua sendo `cargocif/index.html` + `cargocif/mobile.css`.
