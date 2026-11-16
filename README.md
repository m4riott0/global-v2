# Claude Code Global V2 

Personaliza um Claude Code **já instalado** (`%USERPROFILE%\.claude`) com um único comando no PowerShell:

```
irm https://raw.githubusercontent.com/SEU_USUARIO/claude-installers/main/install-global-v2.ps1 | iex
```

Pré-requisito: Claude Code instalado. Este pacote não instala o Claude Code.

## O que o Global V2 instala

- **CLAUDE.md global enxuto**: limites rígidos, comunicação curta, autonomia, economia de tokens, qualidade de código e política de subagents. Seu conteúdo pessoal é preservado; o bloco do pacote fica entre marcadores e é atualizado em cada execução.
- **5 skills**
  - `/efficient-engineer [tarefa]`: modo rígido de economia de tokens e qualidade para o resto da sessão.
  - `/implement-feature [descrição]`: implementa recurso/correção com escopo mínimo e pede revisão ao `code-reviewer` quando a mudança é grande.
  - `/refactor-code [alvo]`: refatoração segura preservando comportamento.
  - `/code-review [escopo]`: revisão independente, roda isolada no subagent `code-reviewer`.
  - `/analyze-architecture [área]`: análise de arquitetura, roda isolada no subagent `architect`.
- **7 subagents**: architect, code-reviewer, test-strategist (Haiku), node-specialist, react-next-specialist, dotnet-specialist, sql-specialist (só escreve SQL, nunca executa).
- **6 regras por stack** em `rules/` (Node, React, Next.js, .NET, SQL, testes). Só carregam quando o Claude mexe em arquivos daquele tipo.
- **Hook de proteção** (`hooks/guardrails.ps1`): bloqueia operações Git de escrita (commit, push, checkout, stash, reset…) e clientes SQL ou ferramentas de migração. `git status/diff/log/show` continuam liberados.
- **settings.json**: mais de 60 regras de bloqueio (Git, SQL, segredos) e `model: sonnet` como padrão para economizar o limite do Pro. O modelo só é definido se você ainda não tiver escolhido um. Suas configurações existentes são mantidas.
- **Backup automático** em `%USERPROFILE%\.claude\backups\global-v2-<data>` antes de qualquer alteração.

## Publicar no GitHub (uma vez)

1. Crie uma conta em github.com, se ainda não tiver.
2. Clique em **New repository** → nome `claude-installers` → **Public** → Create.
3. Clique em **uploading an existing file** e arraste **o conteúdo** desta pasta (`install-global-v2.ps1`, `README.md` e a pasta `global-v2`). Clique em **Commit changes**.
4. No GitHub, abra `install-global-v2.ps1` → ícone de lápis → troque `SEU_USUARIO` pelo seu usuário → **Commit changes**.
5. Troque `SEU_USUARIO` também no comando deste README e no comentário do topo de `install-global-v2.ps1`.

O repositório precisa ser **público**: `irm` não faz login. Não há nada sensível nos arquivos.

## Atualizar

Edite os arquivos no GitHub e rode o mesmo comando de novo. O instalador é idempotente: atualiza o bloco do CLAUDE.md, sobrescreve skills/agents/rules/hook do pacote, mescla o settings.json sem duplicar e faz um novo backup.

## Desfazer

Copie o conteúdo de `%USERPROFILE%\.claude\backups\global-v2-<data>\` de volta para `%USERPROFILE%\.claude\`.

## Validar

No Claude Code (terminal ou VS Code): `/skills`, `/agents`, `/permissions`, `/hooks`, `/doctor`.

## Se o PowerShell bloquear scripts

`irm | iex` não é afetado pela ExecutionPolicy. Se a sua empresa bloquear mesmo assim, rode antes:
`Set-ExecutionPolicy -Scope Process Bypass`

Leia `global-v2/SECURITY-NOTES.txt`: hooks e permissões não substituem um sandbox.
