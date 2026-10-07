# Issues

Pendências conhecidas do `exbanner`: riscos de implementação e de licença das fontes.

## Riscos

### 1. Smushing divergir do `figlet` 2.2.5

As 6 regras de smushing horizontal mais o smushing universal têm precedência sutil, definida pelos campos `OldLayout` e `FullLayout` do header da fonte. Divergências aparecem só em pares específicos de caracteres.

- Situação (2026-10-07): mitigado. Os testes golden (10 casos por fonte) batem byte a byte com o `figlet` 2.2.5 compilado da fonte oficial em 329 das 333 fontes. As 4 restantes estão no item 4.
- Gatilho: qualquer fixture golden falhando. Regerar com `FIGLET=/caminho/figlet test/support/generate_golden.sh`.
- Limite conhecido: os golden cobrem só entrada ASCII. Glifos Latin-1 e transliteração têm testes unitários, sem comparação com o `figlet`.

### 2. Fontes sem licença de redistribuição

Desde 2026-10-07 o pacote embute todas as 333 fontes encontradas em patorjk, manytools e datenkollektiv, por decisão do autor. Antes eram só as 26 com licença confirmada (BSD-3 do FIGlet 2.2.5 e MIT).

- Situação: 295 fontes não têm licença que permita redistribuir. Entre elas, 21 têm restrição explícita (Glenyn exige contato para uso comercial; Binary, Decimal, Hex, Octal, Peaks Slant, Rot13, Slide, Ticks e Ticks Slant, de Victor Parada, e as 7 Efti, de Michel Eftimakis, só trazem aviso de copyright; Santa Clara e Tombstone envolvem direito de terceiro; 3x5 e Letters foram modificadas sem autorização).
- Mitigação: `CREDITS.md` e a página de créditos do site creditam cada fonte ao autor, com os termos do arquivo, e prometem remover qualquer fonte a pedido do autor.
- Limite: versão publicada no Hex não pode ser apagada depois do prazo de revert. Remover uma fonte significa publicar versão nova e aposentar a antiga, que continua baixável.
- Auditoria completa e o gerador dos créditos (`gerar_creditos.py`) ficam na base de conhecimento, em `produtos/exbanner/auditoria-fontes/`.

### 3. Detecção da mix task corrente

O Mix não tem API pública para saber qual task está rodando. A implementação lê `:init.get_plain_arguments/0` e pega o argumento seguinte ao executável `mix`.

- Situação (2026-10-06): implementado com `config :exbanner, mix_tasks: :all | :none | [nomes]`, default `:all`. Validado em `mix run`, `mix test`, `iex -S mix` (vira `run`) e release (sem Mix, banner sempre aparece).
- Limite: `mix do compile + run` é visto como a task `do`. Aliases aparecem com o nome do alias.

### 4. Fontes com particularidades de arquivo

- Situação (2026-10-06): resolvido. As 8 fontes MIT renderizam igual ao `figlet`.
- `font_font.flf` tem BOM e CRLF: o `figlet` 2.2.5 recusa o arquivo por causa do BOM. O parser remove o BOM; o gerador de golden usa cópia sem BOM.
- `bubble`, `digital` e `term` guardam glifos alemães em Latin-1 e usam DEL (0x7F) como hardblank. O parser decodifica cada linha como UTF-8 ou, se inválida, Latin-1, e preserva o hardblank mesmo sendo caractere de controle.
- Julgamento registrado: 4 fontes MIT trazem só um aviso curto ("free to use and distribute / MIT License") sem o texto completo da licença. Foram aceitas como MIT.
- 24 fontes são TOIlet (cabeçalho `tlf2a`, glifos em UTF-8). Ficam com extensão `.tlf`, que o carregador procura depois de `.flf`, como o `figlet`.
- `pyramid` usa o byte 0x81 como hardblank. O `figlet` compilado com suporte a TOIlet decodifica esse byte como lixo e imprime bytes inválidos no lugar dos espaços; o `exbanner` imprime os espaços.
- `diet_cola`, `js_capital_curves` e `stforek` têm glifos com linhas de larguras diferentes, e nesses glifos o `figlet` lê memória não inicializada. As quatro ficam fora da comparação golden e têm teste próprio de saída limpa.

### 5. Auditoria de licenças

- Situação (2026-10-06): resolvido. A auditoria completa (`audit.csv` com 333 fontes, resumo e os `.flf` livres) está na base de conhecimento do projeto, em `auditoria-fontes/`, junto com `gerar_creditos.py`, que gera o `CREDITS.md` e a página de créditos do site a partir dela.
- Fontes oficiais: FIGlet 2.2.5 em https://github.com/cmatsuoka/figlet (tag `2.2.5`) e MIT em https://github.com/patorjk/figlet.js (diretório `fonts/`).

### 6. Documentação de API

O código seguia a regra de não ter comentários nem `@doc`, o que deixava o HexDocs só com o README e as specs.

- Situação (2026-10-06): resolvido. Exceção aprovada para este projeto e registrada no `CLAUDE.md`: `@moduledoc`, `@doc` e `@typedoc` na API pública, em inglês, com exemplos executados como doctest.

### 7. Memória das fontes em cache

Cada linha de glifo fica como lista de inteiros, e cada elemento de lista custa 16 bytes na BEAM. Medido em 2026-10-07: a `standard` ocupa 265 KB em cache e as 333 fontes juntas ocupariam 97 MB no `:persistent_term`, que nunca é liberado.

- Situação: o `showcase/2` lê as fontes sem gravar no cache, então o caso de carregar todas não acontece mais. No uso normal (uma ou duas fontes) o custo é irrelevante.
- Otimização opcional, não feita: guardar as linhas como string UTF-8 reduziria cerca de 3 vezes (`standard` de 265 KB para 87 KB; todas de 97 MB para 31 MB). Exige converter cada glifo em lista ao renderizar, ou reescrever o renderizador para binários. Parsear glifo sob demanda a partir do arquivo cru reduziria perto do tamanho do arquivo (cerca de 28 KB na `standard`), com bem mais complexidade.
- Gatilho para retomar: alguém precisar de muitas fontes em memória ao mesmo tempo.

