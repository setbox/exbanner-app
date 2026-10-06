# Issues

Pendências conhecidas do `ex_banner`: riscos de implementação e fontes FIGlet que não podem ser embutidas no pacote.

## Riscos

### 1. Smushing divergir do `figlet` 2.2.5

As 6 regras de smushing horizontal mais o smushing universal têm precedência sutil, definida pelos campos `OldLayout` e `FullLayout` do header da fonte. Divergências aparecem só em pares específicos de caracteres.

- Situação (2026-10-06): mitigado. 260 testes golden (26 fontes x 10 casos) batem byte a byte com o `figlet` 2.2.5 compilado da fonte oficial.
- Gatilho: qualquer fixture golden falhando. Regerar com `FIGLET=/caminho/figlet test/support/generate_golden.sh`.
- Limite conhecido: os golden cobrem só entrada ASCII. Glifos Latin-1 e transliteração têm testes unitários, sem comparação com o `figlet`.

### 2. Usuário esperar fontes populares que não vêm no pacote

Crazy, Doom, Epic, ANSI Shadow, Graffiti, Star Wars e outras aparecem nos sites de geração de banner, mas não têm licença de redistribuição confirmada (ver tabela abaixo).

- Mitigação: README explica como usar fonte própria via `config :ex_banner, font_paths: [...]`.
- Caminho para incluir: permissão escrita do autor, registrada aqui.

### 3. Detecção da mix task corrente

O Mix não tem API pública para saber qual task está rodando. A implementação lê `:init.get_plain_arguments/0` e pega o argumento seguinte ao executável `mix`.

- Situação (2026-10-06): implementado com `config :ex_banner, mix_tasks: :all | :none | [nomes]`, default `:all`. Validado em `mix run`, `mix test`, `iex -S mix` (vira `run`) e release (sem Mix, banner sempre aparece).
- Limite: `mix do compile + run` é visto como a task `do`. Aliases aparecem com o nome do alias.

### 4. Fontes com particularidades de arquivo

- Situação (2026-10-06): resolvido. As 8 fontes MIT renderizam igual ao `figlet`.
- `font_font.flf` tem BOM e CRLF: o `figlet` 2.2.5 recusa o arquivo por causa do BOM. O parser remove o BOM; o gerador de golden usa cópia sem BOM.
- `bubble`, `digital` e `term` guardam glifos alemães em Latin-1 e usam DEL (0x7F) como hardblank. O parser decodifica cada linha como UTF-8 ou, se inválida, Latin-1, e preserva o hardblank mesmo sendo caractere de controle.
- Julgamento registrado: 4 fontes MIT trazem só um aviso curto ("free to use and distribute / MIT License") sem o texto completo da licença. Foram aceitas como MIT.

### 5. Auditoria de licenças

- Situação (2026-10-06): resolvido. A auditoria completa (`audit.csv` com 333 fontes, resumo e os `.flf` livres) está na base de conhecimento do projeto, em `auditoria-fontes/`.
- Fontes oficiais: FIGlet 2.2.5 em https://github.com/cmatsuoka/figlet (tag `2.2.5`) e MIT em https://github.com/patorjk/figlet.js (diretório `fonts/`).

### 6. Documentação de API sem `@doc`

O código segue a regra de não ter comentários nem `@doc`. Para um pacote Hex público, isso deixa o HexDocs só com o README e as specs das funções.

- Decisão em aberto: aceitar o README como documentação única ou abrir exceção para `@moduledoc`/`@doc` nas funções públicas de `ExBanner`.

## Fontes WTFPL (12)

Licença permite redistribuição, mas WTFPL não é aprovada pela OSI e pode bloquear a adoção do pacote em auditorias corporativas. Ficam fora do `ex_banner`; candidatas a um pacote separado se houver demanda.

| Fonte | Átomo | Autor | Origem |
|---|---|---|---|
| Circle | `:circle` | Sam Hocevar | https://github.com/patorjk/figlet.js/blob/main/fonts/Circle.flf |
| Emboss | `:emboss` | Sam Hocevar | https://github.com/patorjk/figlet.js/blob/main/fonts/Emboss.flf |
| Emboss 2 | `:emboss_2` | Sam Hocevar | https://github.com/patorjk/figlet.js/blob/main/fonts/Emboss%202.flf |
| Future | `:future` | Sam Hocevar | https://github.com/patorjk/figlet.js/blob/main/fonts/Future.flf |
| Future Smooth | `:future_smooth` | Sam Hocevar; variant by John Goodliff | https://github.com/patorjk/figlet.js/blob/main/fonts/Future%20Smooth.flf |
| Future Thin | `:future_thin` | Sam Hocevar; variant by John Goodliff | https://github.com/patorjk/figlet.js/blob/main/fonts/Future%20Thin.flf |
| Letter | `:letter` | Francesco Poli | https://github.com/patorjk/figlet.js/blob/main/fonts/Letter.flf |
| Pagga | `:pagga` | Sam Hocevar and pagga | https://github.com/patorjk/figlet.js/blob/main/fonts/Pagga.flf |
| Small Block | `:small_block` | Sam Hocevar | https://github.com/patorjk/figlet.js/blob/main/fonts/Small%20Block.flf |
| Small Braille | `:small_braille` | Sam Hocevar | https://github.com/patorjk/figlet.js/blob/main/fonts/Small%20Braille.flf |
| Upside Down Text | `:upside_down_text` | Pat Gillespie | https://github.com/patorjk/figlet.js/blob/main/fonts/Upside%20Down%20Text.flf |
| WideTerm | `:wideterm` | Sam Hocevar | https://github.com/patorjk/figlet.js/blob/main/fonts/WideTerm.flf |

## Fontes restritas (1)

| Fonte | Átomo | Autor | Texto da licença |
|---|---|---|---|
| Glenyn | `:glenyn` | Lukasz Tyrala (lt.) | For comercial use of this font please contact with me (lt.). |

## Fontes com licença não confirmada (294)

Sem permissão explícita de redistribuição no header do `.flf` e fora da distribuição oficial do FIGlet 2.2.5. O MIT do repositório patorjk/figlet.js não cobre fontes de terceiros. Muitas trazem apenas "Permission is hereby given to modify this font, as long as the modifier's name is placed on a comment line", que autoriza modificar, não redistribuir.

Sites: patorjk (https://patorjk.com/software/taag/), manytools (https://manytools.org/hacker-tools/ascii-banner/), datenkollektiv (https://devops.datenkollektiv.de/banner.txt/index.html).

| Fonte | Átomo | Autor | Sites | Motivo |
|---|---|---|---|---|
| 1Row | `:1row` | unknown | manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion |
| 3-D | `:3_d` | Daniel Henninger | datenkollektiv, manytools, patorjk | no license statement (author only); site names: 3-d |
| 3D Diagonal | `:3d_diagonal` | nabis, LG Beard, Markus Gebhard and others | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: 3d_diagonal |
| 3D-ASCII | `:3d_ascii` | - | manytools, patorjk | no license statement; converted from TheDraw .TDF font |
| 3x5 | `:3x5` | Richard Kirk | datenkollektiv, manytools, patorjk | JUDGMENT: Porter notes it was "slightly changed (without permission)". |
| 4Max | `:4max` | Philip Menke | datenkollektiv, manytools, patorjk | no license statement (author only); site names: 4max |
| 5 Line Oblique | `:5_line_oblique` | pk6811s@acad.drake.edu | datenkollektiv, manytools, patorjk | no license statement; site names: 5lineoblique |
| Acrobatic | `:acrobatic` | Randy Ransom | datenkollektiv, manytools, patorjk | no license statement (author only); site names: acrobatic |
| Alligator | `:alligator` | Simon Bradley | datenkollektiv, manytools, patorjk | no license statement (author only); site names: alligator |
| Alligator2 | `:alligator2` | Daniel Wiz. AKA Merlin Greywolf | datenkollektiv, manytools, patorjk | no license statement (author only); site names: alligator2 |
| Alpha | `:alpha` | Lennert Stock | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: alpha |
| Alphabet | `:alphabet` | Wendell Hicken | datenkollektiv, manytools, patorjk | no license statement (author only); site names: alphabet |
| AMC 3 Line | `:amc_3_line` | LESTER | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: amc3line |
| AMC 3 Liv1 | `:amc_3_liv1` | LESTER | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: amc3liv1 |
| AMC AAA01 | `:amc_aaa01` | LESTER | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: amcaaa01 |
| AMC Neko | `:amc_neko` | LESTER | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: amcneko |
| AMC Razor | `:amc_razor` | LESTER | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: amcrazor |
| AMC Razor2 | `:amc_razor2` | LESTER | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: amcrazo2 |
| AMC Slash | `:amc_slash` | LESTER | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: amcslash |
| AMC Slider | `:amc_slider` | LESTER | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: amcslder |
| AMC Thin | `:amc_thin` | LESTER | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: amcthin |
| AMC Tubes | `:amc_tubes` | LESTER | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: amctubes |
| AMC Untitled | `:amc_untitled` | LESTER | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: amcun1 |
| ANSI Regular | `:ansi_regular` | - | patorjk | no license statement; converted from TheDraw .TDF font |
| ANSI Shadow | `:ansi_shadow` | - | manytools, patorjk | no license statement; converted from TheDraw .TDF font |
| Arrows | `:arrows` | Ron Fritz | datenkollektiv, manytools, patorjk | no license statement (author only); site names: arrows |
| ASCII 12 | `:ascii_12` | - | patorjk | JUDGMENT: caca2tlf output (TOIlet tooling); no license line in font. TOIlet package is WTFPL but font header does not say so. |
| ASCII 9 | `:ascii_9` | - | patorjk | JUDGMENT: caca2tlf output (TOIlet tooling); no license line in font. TOIlet package is WTFPL but font header does not say so. |
| ASCII New Roman | `:ascii_new_roman` | Marcin Glinsky and others | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: ascii_new_roman |
| Avatar | `:avatar` | Claude Martins | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: avatar |
| B1FF | `:b1ff` | Joe Rumsey | manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| Babyface Lame | `:babyface_lame` | cat | patorjk | no license statement (author only) |
| Babyface Leet | `:babyface_leet` | cat | patorjk | no license statement (author only) |
| Banner3 | `:banner3` | Merlin Greywolf merlin@brahms.udel.edu | datenkollektiv, manytools, patorjk | no license statement (author only); site names: banner3 |
| Banner3-D | `:banner3_d` | Merlin Greywolf merlin@brahms.udel.edu | datenkollektiv, manytools, patorjk | no license statement (author only); site names: banner3-D |
| Banner4 | `:banner4` | Merlin Greywolf merlin@brahms.udel.edu | datenkollektiv, manytools, patorjk | no license statement (author only); site names: banner4 |
| Barbwire | `:barbwire` | Ron Fritz | datenkollektiv, manytools, patorjk | no license statement (author only); site names: barbwire |
| Basic | `:basic` | Craig O'Flaherty | datenkollektiv, manytools, patorjk | no license statement (author only); site names: basic |
| Bear | `:bear` | myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: bear |
| Bell | `:bell` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: bell |
| Benjamin | `:benjamin` | Benjamin Weiland, Markus Gebhard, Christian Garbs | manytools, patorjk | no license statement |
| Big ASCII 12 | `:big_ascii_12` | - | patorjk | JUDGMENT: caca2tlf output (TOIlet tooling); no license line in font. TOIlet package is WTFPL but font header does not say so. |
| Big ASCII 9 | `:big_ascii_9` | - | patorjk | JUDGMENT: caca2tlf output (TOIlet tooling); no license line in font. TOIlet package is WTFPL but font header does not say so. |
| Big Chief | `:big_chief` | pk6811s@acad.drake.edu | datenkollektiv, manytools, patorjk | no license statement; site names: bigchief |
| Big Money-ne | `:big_money_ne` | nathan bloomfield | manytools, patorjk | no license statement (author only) |
| Big Money-nw | `:big_money_nw` | nathan bloomfield | manytools, patorjk | no license statement (author only) |
| Big Money-se | `:big_money_se` | nathan bloomfield | manytools, patorjk | no license statement (author only) |
| Big Money-sw | `:big_money_sw` | nathan bloomfield | manytools, patorjk | no license statement (author only) |
| Big Mono 12 | `:big_mono_12` | - | patorjk | JUDGMENT: caca2tlf output (TOIlet tooling); no license line in font. TOIlet package is WTFPL but font header does not say so. |
| Big Mono 9 | `:big_mono_9` | - | patorjk | JUDGMENT: caca2tlf output (TOIlet tooling); no license line in font. TOIlet package is WTFPL but font header does not say so. |
| Bigfig | `:bigfig` | Glenn Chappell | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: bigfig |
| Binary | `:binary` | Victor Parada | manytools, patorjk | copyright notice only, no grant |
| Blocks | `:blocks` | myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: blocks |
| Bloody | `:bloody` | (conversion by patorjk; original author not stated) | manytools, patorjk | no license statement (author only) |
| BlurVision ASCII | `:blurvision_ascii` | Aiden Neuding | patorjk | no license statement (author only) |
| Bolger | `:bolger` | Mike Rosulek | datenkollektiv, manytools, patorjk | no license statement (author only); site names: bolger |
| Braced | `:braced` | LG Beard | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: braced |
| Bright | `:bright` | Dennis Monk | datenkollektiv, manytools, patorjk | no license statement (author only); site names: bright |
| Broadway | `:broadway` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: broadway |
| Broadway KB | `:broadway_kb` | myflix | manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| Bulbhead | `:bulbhead` | Jef Poskanzer | datenkollektiv, manytools, patorjk | no license statement (author only); site names: bulbhead |
| Caligraphy | `:caligraphy` | Vinney Thai | datenkollektiv, manytools, patorjk | no license statement (author only); site names: caligraphy |
| Caligraphy2 | `:caligraphy2` | Paul Burton (from Vinney Thai) | datenkollektiv, manytools, patorjk | no license statement (author only); site names: calgphy2 |
| Calvin S | `:calvin_s` | - | manytools, patorjk | no license statement; converted from TheDraw .TDF font |
| Cards | `:cards` | myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: cards |
| Catwalk | `:catwalk` | Ron Fritz | datenkollektiv, manytools, patorjk | no license statement (author only); site names: catwalk |
| Chiseled | `:chiseled` | LG Beard | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: chiseled |
| Chunky | `:chunky` | Chris Gill | datenkollektiv, manytools, patorjk | no license statement (author only); site names: chunky |
| Coinstak | `:coinstak` | Ron Fritz | datenkollektiv, manytools, patorjk | no license statement (author only); site names: coinstak |
| Cola | `:cola` | MikeChat | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: cola |
| Colossal | `:colossal` | Jonathon (jon@mq.edu.au) | datenkollektiv, manytools, patorjk | no license statement (author only); site names: colossal |
| Computer | `:computer` | Mike Rosulek | datenkollektiv, manytools, patorjk | no license statement (author only); site names: computer |
| Contessa | `:contessa` | Christopher Joseph Pirillo | datenkollektiv, manytools, patorjk | no license statement (author only); site names: contessa |
| Contrast | `:contrast` | Dennis Monk | datenkollektiv, manytools, patorjk | no license statement (author only); site names: contrast |
| cosmic | `:cosmic` | Mike Rosulek | datenkollektiv | JUDGMENT: Only offered by datenkollektiv; xero/figlet-fonts cosmic.flf differs from patorjk Cosmike (Eftimakis corrected version).; source: xero/figlet-fonts (not in patorjk) |
| Cosmike | `:cosmike` | Mike Rosulek | datenkollektiv, manytools, patorjk | no license statement (author only); site names: cosmike |
| Cosmike2 | `:cosmike2` | half Cosmike, half Darth ObiKy | patorjk | no license statement (author only) |
| Crawford | `:crawford` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: crawford |
| Crawford2 | `:crawford2` | Rowan Crawford / Kent Nassen / patorjk | manytools, patorjk | no license statement (author only) |
| Crazy | `:crazy` | myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: crazy |
| Cricket | `:cricket` | Leslie Bates | datenkollektiv, manytools, patorjk | no license statement (author only); site names: cricket |
| Cursive | `:cursive` | Jan Wolter | manytools, patorjk | no license statement (author only) |
| Cyberlarge | `:cyberlarge` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: cyberlarge |
| Cybermedium | `:cybermedium` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: cybermedium |
| Cybersmall | `:cybersmall` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: cybersmall |
| Cygnet | `:cygnet` | Christian 'CeeJay' Jensen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: cygnet |
| DANC4 | `:danc4` | Richard Sabey | datenkollektiv, manytools, patorjk | no license statement (author only) |
| Dancing Font | `:dancing_font` | Myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: dancingfont |
| Decimal | `:decimal` | Karlton Wirsing (based on Victor Parada) | manytools, patorjk | copyright notice only, no grant |
| Def Leppard | `:def_leppard` | Hanspeter Niederstrasser | datenkollektiv, manytools, patorjk | no license statement (author only); site names: defleppard |
| Delta Corps Priest 1 | `:delta_corps_priest_1` | CoSMiC cHiLD | manytools, patorjk | no license statement (author only) |
| DiamFont | `:diamfont` | Diamond Planet | patorjk | no license statement (author only) |
| Diamond | `:diamond` | Ron Fritz | datenkollektiv, manytools, patorjk | no license statement (author only); site names: diamond |
| Diet Cola | `:diet_cola` | mikechat | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: dietcola |
| Doh | `:doh` | Curtis Wanner | datenkollektiv, manytools, patorjk | no license statement (author only); site names: doh |
| Doom | `:doom` | Frans P. de Vries | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: doom |
| DOS Rebel | `:dos_rebel` | Valerie Mates | datenkollektiv, manytools, patorjk | no license statement (author only); site names: dosrebel |
| Dot Matrix | `:dot_matrix` | Curtis Wanner | datenkollektiv, manytools, patorjk | no license statement (author only); site names: dotmatrix |
| Double | `:double` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: double |
| Double Shorts | `:double_shorts` | myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: doubleshorts |
| Dr Pepper | `:dr_pepper` | Eero Tamminen, t150315@cc.tut.fi | datenkollektiv, manytools, patorjk | no license statement (author only); site names: drpepper |
| DWhistled | `:dwhistled` | - | datenkollektiv, manytools, patorjk | no license statement; site names: dwhistled |
| Efti Chess | `:efti_chess` | Michel Eftimakis | datenkollektiv, manytools, patorjk | copyright notice only, no grant; site names: eftichess |
| Efti Font | `:efti_font` | Michel Eftimakis | datenkollektiv, manytools, patorjk | copyright notice only, no grant; site names: eftifont |
| Efti Italic | `:efti_italic` | Michel Eftimakis | datenkollektiv, manytools, patorjk | copyright notice only, no grant; site names: eftitalic |
| Efti Piti | `:efti_piti` | Michel Eftimakis | manytools, patorjk | copyright notice only, no grant |
| Efti Robot | `:efti_robot` | Michel Eftimakis | datenkollektiv, manytools, patorjk | copyright notice only, no grant; site names: eftirobot |
| Efti Wall | `:efti_wall` | Michel Eftimakis | datenkollektiv, manytools, patorjk | copyright notice only, no grant; site names: eftiwall |
| Efti Water | `:efti_water` | Michel Eftimakis | datenkollektiv, manytools, patorjk | copyright notice only, no grant; site names: eftiwater |
| Electronic | `:electronic` | Derek Lemay <THe PHaRCYDe> | manytools, patorjk | no license statement (author only); converted from TheDraw .TDF font |
| Elite | `:elite` | - | manytools, patorjk | no license statement; converted from TheDraw .TDF font |
| Epic | `:epic` | Claude Martins | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: epic |
| Fender | `:fender` | Scooter | datenkollektiv, manytools, patorjk | no license statement (author only); site names: fender |
| Filter | `:filter` | Aaron Nolan | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: filter |
| Fire Font-k | `:fire_font_k` | MJP | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: fire_font-k |
| Fire Font-s | `:fire_font_s` | MJP | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: fire_font-s |
| Flipped | `:flipped` | MikeChat and myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: flipped |
| Flower Power | `:flower_power` | Myflix, LG Beard | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: flowerpower |
| Four Tops | `:four_tops` | Randall Ransom | datenkollektiv, manytools, patorjk | no license statement (author only); site names: fourtops |
| Fraktur | `:fraktur` | Philip Menke | datenkollektiv, manytools, patorjk | no license statement (author only); site names: fraktur |
| Fun Face | `:fun_face` | MJP | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: funface |
| Fun Faces | `:fun_faces` | MJP (AKA MikeChat) | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: funfaces |
| Fuzzy | `:fuzzy` | Juan Car | datenkollektiv, manytools, patorjk | no license statement (author only); site names: fuzzy |
| Georgi16 | `:georgi16` | Richard Sabey | datenkollektiv, manytools, patorjk | no license statement (author only); site names: georgi16 |
| Georgia11 | `:georgia11` | Richard Sabey | manytools, patorjk | no license statement (author only) |
| Ghost | `:ghost` | myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: ghost |
| Ghoulish | `:ghoulish` | LG Beard | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: ghoulish |
| Goofy | `:goofy` | Steven | datenkollektiv, manytools, patorjk | no license statement (author only); site names: goofy |
| Gothic | `:gothic` | Howard Chu | datenkollektiv, manytools, patorjk | no license statement (author only); site names: gothic |
| Graceful | `:graceful` | Mikhael Goikhman | manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| Gradient | `:gradient` | Philip Menke | datenkollektiv, manytools, patorjk | no license statement (author only); site names: gradient |
| Graffiti | `:graffiti` | Leigh Purdie | datenkollektiv, manytools, patorjk | no license statement (author only); site names: graffiti |
| Greek | `:greek` | Bruce Jakeway--based on Standard by Glenn Chappell & Ian Chai | manytools, patorjk | no license statement (author only) |
| Heart Left | `:heart_left` | LG Beard | manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| Heart Right | `:heart_right` | LG Beard | manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| Henry 3D | `:henry_3d` | Henry Segerman henryseg@email.com | datenkollektiv, manytools, patorjk | no license statement (author only); site names: henry3d |
| Hex | `:hex` | Karlton Wirsing (based on Victor Parada) | manytools, patorjk | copyright notice only, no grant |
| Hieroglyphs | `:hieroglyphs` | LG Beard | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: hieroglyphs |
| Hollywood | `:hollywood` | Juan Car | datenkollektiv, manytools, patorjk | no license statement (author only); site names: hollywood |
| Horizontal Left | `:horizontal_left` | LG Beard | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: horizontalleft |
| Horizontal Right | `:horizontal_right` | LG Beard | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: horizontalright |
| ICL-1900 | `:icl_1900` | BIZUN (nefarious of Neurotics) | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| Impossible | `:impossible` | LG Beard | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: impossible |
| Invita | `:invita` | pk6811s@acad.drake.edu | datenkollektiv, manytools, patorjk | no license statement; site names: invita |
| Isometric1 | `:isometric1` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: isometric1 |
| Isometric2 | `:isometric2` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: isometric2 |
| Isometric3 | `:isometric3` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: isometric3 |
| Isometric4 | `:isometric4` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: isometric4 |
| Italic | `:italic` | Bas Meijer | datenkollektiv, manytools, patorjk | no license statement (author only); site names: italic |
| Jacky | `:jacky` | Meph.'99 | manytools, patorjk | no license statement (author only) |
| Jazmine | `:jazmine` | vampyr@acs.bu.edu | datenkollektiv, manytools, patorjk | no license statement; site names: jazmine |
| Jerusalem | `:jerusalem` | Gedaliah Friedenberg - based on Standard by G. Chappell & Ian Chai | datenkollektiv, manytools, patorjk | no license statement (author only); site names: jerusalem |
| JS Block Letters | `:js_block_letters` | Joan Stark | manytools, patorjk | no license statement (author only) |
| JS Bracket Letters | `:js_bracket_letters` | Joan Stark | manytools, patorjk | no license statement (author only) |
| JS Capital Curves | `:js_capital_curves` | - | manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| JS Cursive | `:js_cursive` | Joan Stark | manytools, patorjk | no license statement (author only) |
| JS Stick Letters | `:js_stick_letters` | Joan Stark | manytools, patorjk | no license statement (author only) |
| Katakana | `:katakana` | Vinney Thai | datenkollektiv, manytools, patorjk | no license statement (author only); site names: katakana |
| Kban | `:kban` | Randy Jae Weinstein | datenkollektiv, manytools, patorjk | no license statement (author only); site names: kban |
| Keyboard | `:keyboard` | Vinney Thai | datenkollektiv, manytools, patorjk | no license statement (author only); site names: keyboard |
| Knob | `:knob` | myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: knob |
| Konto | `:konto` | Markus Gebhard markus@jave.de | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: konto |
| Konto Slant | `:konto_slant` | David Dahlberg <D-Mail@gmx.net> | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: kontoslant |
| Larry 3D | `:larry_3d` | Larry Gelberg | datenkollektiv, manytools, patorjk | no license statement (author only); site names: larry3d |
| Larry 3D 2 | `:larry_3d_2` | Larry Gelberg | patorjk | no license statement (author only) |
| LCD | `:lcd` | Karl von Laudermann | datenkollektiv, manytools, patorjk | no license statement (author only); site names: lcd |
| Letters | `:letters` | Sriram J. Gollapalli | datenkollektiv, manytools, patorjk | JUDGMENT: patorjk notes his edit was made "(without permission)".; site names: letters |
| Lil Devil | `:lil_devil` | myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: lildevil |
| Line Blocks | `:line_blocks` | Bateau (lbm) | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: lineblocks |
| Linux | `:linux` | Larry Smith | datenkollektiv, manytools, patorjk | no license statement (author only); site names: linux |
| Lockergnome | `:lockergnome` | Christopher Joseph Pirillo | datenkollektiv, manytools, patorjk | no license statement (author only); site names: lockergnome |
| Madrid | `:madrid` | Juan Car | datenkollektiv, manytools, patorjk | no license statement (author only); site names: madrid |
| Marquee | `:marquee` | Ron Fritz | datenkollektiv, manytools, patorjk | no license statement (author only); site names: marquee |
| Maxfour | `:maxfour` | Randall Ransom | manytools, patorjk | no license statement (author only) |
| Merlin1 | `:merlin1` | LG Beard | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: merlin1 |
| Merlin2 | `:merlin2` | LG Beard | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: merlin2 |
| Mike | `:mike` | Michael Sullivan | datenkollektiv, manytools, patorjk | no license statement (author only); site names: mike |
| miniwi | `:miniwi` | - | patorjk | no license statement |
| Mirror | `:mirror` | David Walton | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: mirror |
| Modular | `:modular` | myflix | manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| Mono 12 | `:mono_12` | - | patorjk | JUDGMENT: caca2tlf output (TOIlet tooling); no license line in font. TOIlet package is WTFPL but font header does not say so. |
| Mono 9 | `:mono_9` | - | patorjk | JUDGMENT: caca2tlf output (TOIlet tooling); no license line in font. TOIlet package is WTFPL but font header does not say so. |
| Morse | `:morse` | Glenn Chappell | manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| Morse2 | `:morse2` | Glenn Chappell | patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| Moscow | `:moscow` | Tracy Schuhwerk | datenkollektiv, manytools, patorjk | no license statement (author only); site names: moscow |
| Mshebrew210 | `:mshebrew210` | Michael 'msh210' Hamm | datenkollektiv, manytools, patorjk | JUDGMENT: "Copyright (c) 2000 Michael Hamm ... Okay to modify this font iff modifier's name is on a comment line." modify-only.; site names: mshebrew210 |
| Muzzle | `:muzzle` | Katerina L | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: muzzle |
| Nancyj | `:nancyj` | vampyr@acs.bu.edu | datenkollektiv, manytools, patorjk | no license statement; site names: nancyj |
| Nancyj-Fancy | `:nancyj_fancy` | vampyr@acs.bu.edu | datenkollektiv, manytools, patorjk | no license statement (author only); site names: nancyj-fancy |
| Nancyj-Improved | `:nancyj_improved` | vampyr@acs.bu.edu | datenkollektiv, manytools, patorjk | no license statement; site names: nancyj-improved |
| Nancyj-Underlined | `:nancyj_underlined` | vampyr@acs.bu.edu | datenkollektiv, manytools, patorjk | no license statement; site names: nancyj-underlined |
| Nipples | `:nipples` | Ron Fritz | datenkollektiv, manytools, patorjk | no license statement (author only); site names: nipples |
| NScript | `:nscript` | Normand Veilleux | datenkollektiv, manytools, patorjk | no license statement (author only); site names: nscript |
| NT Greek | `:nt_greek` | Bruce Jakeway--based on Standard by Glenn Chappell & Ian Chai | datenkollektiv, manytools, patorjk | no license statement (author only); site names: ntgreek |
| NV Script | `:nv_script` | Normand Veilleux | datenkollektiv, manytools, patorjk | no license statement (author only); site names: nvscript |
| O8 | `:o8` | Gordon Lee | datenkollektiv, manytools, patorjk | no license statement (author only); site names: o8 |
| Octal | `:octal` | Karlton Wirsing (based on Victor Parada) | manytools, patorjk | copyright notice only, no grant |
| Ogre | `:ogre` | Glenn Chappell & Ian Chai | datenkollektiv, manytools, patorjk | no license statement (author only); site names: ogre |
| Old Banner | `:old_banner` | Ryan Youck | datenkollektiv, manytools, patorjk | no license statement (author only); site names: oldbanner |
| OS2 | `:os2` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: os2 |
| Patorjk's Cheese | `:patorjk_s_cheese` | patorjk | manytools, patorjk | no license statement (author only) |
| Patorjk-HeX | `:patorjk_hex` | patorjk | manytools, patorjk | no license statement (author only) |
| Pawp | `:pawp` | Curtis Wanner | datenkollektiv, manytools, patorjk | no license statement (author only); site names: pawp |
| Peaks | `:peaks` | Ron Fritz | datenkollektiv, manytools, patorjk | no license statement (author only); site names: peaks |
| Peaks Slant | `:peaks_slant` | Victor Parada | datenkollektiv, manytools, patorjk | copyright notice only, no grant; site names: peaksslant |
| Pebbles | `:pebbles` | Empath | datenkollektiv, manytools, patorjk | no license statement (author only); site names: pebbles |
| Pepper | `:pepper` | Dr. Pepper | datenkollektiv, manytools, patorjk | no license statement (author only); site names: pepper |
| Poison | `:poison` | Vinney Thai | datenkollektiv, manytools, patorjk | no license statement (author only); site names: poison |
| Puffy | `:puffy` | Juan Car | datenkollektiv, manytools, patorjk | no license statement (author only); site names: puffy |
| Puzzle | `:puzzle` | myflix and Mikechat | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: puzzle |
| Pyramid | `:pyramid` | Claude Martins | manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| Rammstein | `:rammstein` | Bateau (lbm) | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: rammstein |
| Rebel | `:rebel` | Valerie Mates | patorjk | no license statement (author only) |
| Rectangles | `:rectangles` | David Villegas | datenkollektiv, manytools, patorjk | no license statement (author only); site names: rectangles |
| Red Phoenix | `:red_phoenix` | Red Phoenix | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: red_phoenix |
| Relief | `:relief` | Nick Miners | datenkollektiv, manytools, patorjk | no license statement (author only); site names: relief |
| Relief2 | `:relief2` | Merlin Greywolf merlin@brahms.udel.edu | datenkollektiv, manytools, patorjk | no license statement (author only); site names: relief2 |
| Reverse | `:reverse` | Matt E. Thurston | datenkollektiv, manytools, patorjk | no license statement (author only); site names: reverse |
| Roman | `:roman` | Nick Miners N.M.Miners@durham.ac.uk | datenkollektiv, manytools, patorjk | no license statement (author only); site names: roman |
| Rot13 | `:rot13` | Victor Parada | patorjk | copyright notice only, no grant |
| Rotated | `:rotated` | MikeChat & myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: rotated |
| Rounded | `:rounded` | Nick Miners N.M.Miners@durham.ac.uk | datenkollektiv, manytools, patorjk | no license statement (author only); site names: rounded |
| Rowan Cap | `:rowan_cap` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: rowancap |
| Rozzo | `:rozzo` | Mike Rosulek | datenkollektiv, manytools, patorjk | no license statement (author only); site names: rozzo |
| RubiFont | `:rubifont` | RubixTW | patorjk | no license statement (author only) |
| Runic | `:runic` | Bryan Alexander | datenkollektiv, manytools, patorjk | JUDGMENT: "Modifying this font is fine with me; please e-mail me the result." modify-only.; site names: runic |
| Runyc | `:runyc` | Bryan Alexander | datenkollektiv, manytools, patorjk | JUDGMENT: "Modifying this font is fine with me; please e-mail me the result." modify-only.; site names: runyc |
| S Blood | `:s_blood` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: sblood |
| Santa Clara | `:santa_clara` | Wendell Hicken (from program by Jan Wolter) | datenkollektiv, manytools, patorjk | JUDGMENT: "Derived from a copyrighted program by Jan Wolter": upstream copyright explicitly asserted, no grant.; site names: santaclara |
| Serifcap | `:serifcap` | Bruce M. Binder | datenkollektiv, manytools, patorjk | no license statement (author only); site names: serifcap |
| Shaded Blocky | `:shaded_blocky` | Jäger | patorjk | no license statement (author only) |
| Shimrod | `:shimrod` | Shimrod | datenkollektiv, manytools, patorjk | no license statement (author only); site names: shimrod |
| Short | `:short` | Sub-Zero | datenkollektiv, manytools, patorjk | no license statement (author only); site names: short |
| SL Script | `:sl_script` | Jan Wolter | datenkollektiv, manytools, patorjk | no license statement (author only); site names: slscript |
| Slant Relief | `:slant_relief` | Nick Bryant | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: s-relief |
| Slide | `:slide` | Victor Parada | datenkollektiv, manytools, patorjk | copyright notice only, no grant; site names: slide |
| Small ASCII 12 | `:small_ascii_12` | - | patorjk | JUDGMENT: caca2tlf output (TOIlet tooling); no license line in font. TOIlet package is WTFPL but font header does not say so. |
| Small ASCII 9 | `:small_ascii_9` | - | patorjk | JUDGMENT: caca2tlf output (TOIlet tooling); no license line in font. TOIlet package is WTFPL but font header does not say so. |
| Small Caps | `:small_caps` | LG Beard | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: smallcaps |
| Small Isometric1 | `:small_isometric1` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: smisome1 |
| Small Keyboard | `:small_keyboard` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: smkeyboard |
| Small Mono 12 | `:small_mono_12` | - | patorjk | JUDGMENT: caca2tlf output (TOIlet tooling); no license line in font. TOIlet package is WTFPL but font header does not say so. |
| Small Mono 9 | `:small_mono_9` | - | patorjk | JUDGMENT: caca2tlf output (TOIlet tooling); no license line in font. TOIlet package is WTFPL but font header does not say so. |
| Small Poison | `:small_poison` | Vinney Thai | datenkollektiv, manytools, patorjk | no license statement (author only); site names: smpoison |
| Small Tengwar | `:small_tengwar` | Belinda Asbell | datenkollektiv, manytools, patorjk | no license statement (author only); site names: smtengwar |
| Soft | `:soft` | myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: soft |
| Speed | `:speed` | Claude Martins | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: speed |
| Spliff | `:spliff` | nathan bloomfield | datenkollektiv, manytools, patorjk | JUDGMENT: "You are free to make changes- just note them in the history." modify-only, no redistribution grant.; site names: spliff |
| Stacey | `:stacey` | Kent Nassen | datenkollektiv, manytools, patorjk | JUDGMENT: Informal Usenet note "A font, use it for your adds etc. Just don't be so lame and give the credz" reads like use-with-credit, but grants no explicit redistribution right; kept UNKNOWN (could be argued ATTRIBUTION_REQUIRED).; site names: stacey |
| Stampate | `:stampate` | Marco Bodrato <bodrato@genio.sns.it> | datenkollektiv, manytools, patorjk | no license statement (author only); site names: stampate |
| Stampatello | `:stampatello` | Marco Bodrato | datenkollektiv, manytools, patorjk | no license statement; site names: stampatello |
| Star Strips | `:star_strips` | Ralph Bluecoat | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: starstrips |
| Star Wars | `:star_wars` | Ryan Youck | datenkollektiv, manytools, patorjk | no license statement (author only); site names: starwars |
| Stellar | `:stellar` | Ron Fritz | datenkollektiv, manytools, patorjk | no license statement (author only); site names: stellar |
| Stforek | `:stforek` | Marcin `stforek` Glinski | manytools, patorjk | no license statement (author only) |
| Stick Letters | `:stick_letters` | Joan Stark | manytools, patorjk | no license statement (author only) |
| Stop | `:stop` | David Walton | datenkollektiv, manytools, patorjk | no license statement (author only); site names: stop |
| Straight | `:straight` | Bas Meijer | datenkollektiv, manytools, patorjk | no license statement (author only); site names: straight |
| Stronger Than All | `:stronger_than_all` | pC wIZARd | manytools, patorjk | no license statement (author only) |
| Sub-Zero | `:sub_zero` | Sub-Zero | datenkollektiv, manytools, patorjk | no license statement (author only); MEPH ASCII Editor conversion; site names: sub-zero |
| Swamp Land | `:swamp_land` | bpg | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: swampland |
| Swan | `:swan` | Christian 'CeeJay' Jensen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: swan |
| Sweet | `:sweet` | myflix | manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| Tanja | `:tanja` | Christopher J. Pirillo "The Locker Gnome" | datenkollektiv, manytools, patorjk | no license statement (author only); site names: tanja |
| Tengwar | `:tengwar` | Belinda Asbell | datenkollektiv, manytools, patorjk | no license statement (author only); site names: tengwar |
| Terrace | `:terrace` | AJN | patorjk | no license statement (author only) |
| Test1 | `:test1` | - | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: test1 |
| The Edge | `:the_edge` | - | manytools, patorjk | no license statement; converted from TheDraw .TDF font |
| Thick | `:thick` | Randall Ransom | datenkollektiv, manytools, patorjk | no license statement (author only); site names: thick |
| Thin | `:thin` | robert@cs.caltech.edu | datenkollektiv, manytools, patorjk | no license statement (author only); site names: thin |
| THIS | `:this` | - | manytools, patorjk | no license statement; converted from TheDraw .TDF font |
| Thorned | `:thorned` | - | manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
| Three Point | `:three_point` | Randall Ransom | datenkollektiv, manytools, patorjk | no license statement (author only); site names: threepoint |
| Ticks | `:ticks` | Victor Parada | datenkollektiv, manytools, patorjk | copyright notice only, no grant; site names: ticks |
| Ticks Slant | `:ticks_slant` | Victor Parada | datenkollektiv, manytools, patorjk | copyright notice only, no grant; site names: ticksslant |
| Tiles | `:tiles` | Ron Fritz | datenkollektiv, manytools, patorjk | no license statement (author only); site names: tiles |
| Tinker-Toy | `:tinker_toy` | Wendell Hicken | datenkollektiv, manytools, patorjk | no license statement (author only); site names: tinker-toy |
| Tmplr | `:tmplr` | Eugene Ghanizadeh Khoub | patorjk | no license statement (author only) |
| Tombstone | `:tombstone` | Kent Nassen (lettering from RSA Labs FAQ) | datenkollektiv, manytools, patorjk | JUDGMENT: Lettering taken from RSA Laboratories FAQ "copyright 1993, RSA Laboratories"; third-party copyright risk.; site names: tombstone |
| Train | `:train` | myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: train |
| Trek | `:trek` | Peter L. Buschman | datenkollektiv, manytools, patorjk | no license statement (author only); site names: trek |
| Tsalagi | `:tsalagi` | Jerrad Pierce | datenkollektiv, manytools, patorjk | JUDGMENT: "Permission to modify granted, but please send me a copy or notify me." modify-only with notification request.; site names: tsalagi |
| Tubular | `:tubular` | Ron Fritz | datenkollektiv, manytools, patorjk | no license statement (author only); site names: tubular |
| Twisted | `:twisted` | LG Beard | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: twisted |
| Two Point | `:two_point` | Bruce Jakeway | datenkollektiv, manytools, patorjk | no license statement (author only); site names: twopoint |
| Univers | `:univers` | Normand Veilleux | datenkollektiv, manytools, patorjk | no license statement (author only); site names: univers |
| USA Flag | `:usa_flag` | Kent Nassen | datenkollektiv, manytools, patorjk | no license statement (author only); site names: usaflag |
| Varsity | `:varsity` | myflix | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: varsity |
| Wavescape | `:wavescape` | SCA | patorjk | no license statement (author only) |
| Wavy | `:wavy` | Brian Krog | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: wavy |
| Weird | `:weird` | Bas Meijer | datenkollektiv, manytools, patorjk | no license statement (author only); site names: weird |
| Wet Letter | `:wet_letter` | MJP | datenkollektiv, manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant; site names: wetletter |
| Whimsy | `:whimsy` | Kent Nassen | datenkollektiv, manytools, patorjk | JUDGMENT: Original author: "if anyone wants to ... figletize it ... feel free. please keep the name"; permission to convert, not an explicit redistribution grant.; site names: whimsy |
| Wow | `:wow` | Pipeline | manytools, patorjk | modify-only permission (FIGlet/JavE boilerplate); no explicit redistribution grant |
