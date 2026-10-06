# ex_banner

Lib Elixir pública (Hex) que imprime banner ASCII no start da aplicação e renderiza texto com fontes FIGlet.

- Base de conhecimento: `~/obsidian/pessoal/dev/ex_banner/` (decisões em `decisoes.md`, detalhes em `implementacao.md`, publicação de versões em `novas-versoes.md`).
- Pendências e fontes não incluídas: `ISSUES.md`.
- Verificação: `mix precommit`.
- Golden: `FIGLET=/caminho/figlet test/support/generate_golden.sh` regera as fixtures a partir do `figlet` 2.2.5.

## Documentação

Exceção à regra geral de não comentar código: neste projeto `@moduledoc`, `@doc` e `@typedoc` são permitidos e esperados na API pública, em inglês, porque o pacote é publicado no Hex e o HexDocs depende deles. Exemplos com `iex>` são executados como doctest. Módulos internos continuam com `@moduledoc false`. Comentários com `#` continuam proibidos.
