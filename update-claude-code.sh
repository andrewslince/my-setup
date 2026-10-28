#!/usr/bin/env bash
set -Eeuo pipefail

# Atualiza o Claude Code instalado pelo instalador nativo em ~/.local/bin.
# Usa o próprio "claude update", que baixa a versão nova para
# ~/.local/share/claude/versions e troca o link simbólico.

CLI="${HOME}/.local/bin/claude"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  BOLD=$'\033[1m' DIM=$'\033[2m' GREEN=$'\033[32m'
  RED=$'\033[31m' CYAN=$'\033[36m' RESET=$'\033[0m'
else
  BOLD='' DIM='' GREEN='' RED='' CYAN='' RESET=''
fi

usage() {
  cat <<'EOF'
Uso: ./update-claude-code.sh

  -h  Mostra esta ajuda.

Atualiza apenas a instalação nativa em ~/.local/bin/claude. Sessões abertas
continuam na versão antiga até serem reiniciadas.
EOF
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

step() { printf '\n%s●%s %s\n' "$CYAN" "$RESET" "$1"; }
ok() { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
note() { printf '%sℹ%s %s\n' "$DIM" "$RESET" "$1"; }
fail() { printf '%s✗ %s%s\n' "$RED" "$1" "$RESET" >&2; exit 1; }

read_version() {
  local output
  output=$("$CLI" --version 2>/dev/null) || return 1
  # Saída esperada: "2.1.312 (Claude Code)".
  [[ "$output" =~ ^([0-9]+\.[0-9]+\.[0-9]+) ]] || return 1
  printf '%s' "${BASH_REMATCH[1]}"
}

printf '%s\n' '╭────────────────────────────────────────╮'
printf '│  %sClaude Code · atualização local%s       │\n' "$BOLD" "$RESET"
printf '%s\n' '╰────────────────────────────────────────╯'

step 'Verificando o ambiente'
[[ -x "$CLI" ]] || fail "Claude Code não encontrado em $CLI. Instale com ./install-claude-code.sh."
command_path=$(command -v claude || true)
if [[ -n "$command_path" && "$command_path" != "$CLI" ]]; then
  note "O comando claude no PATH aponta para $command_path; será atualizado apenas $CLI."
fi
current=$(read_version) || fail 'Não foi possível ler a versão instalada.'
ok "Versão atual: $current"

step 'Procurando e instalando atualizações'
"$CLI" update || fail 'A atualização falhou. Confira a saída acima.'

installed=$(read_version) || fail 'O Claude Code não respondeu à verificação final.'

if [[ "$installed" == "$current" ]]; then
  printf '\n%s✓ O Claude Code já está atualizado (%s).%s\n' "$GREEN" "$installed" "$RESET"
  exit 0
fi

printf '\n%s✓ Claude Code atualizado: %s → %s%s\n' "$GREEN" "$current" "$installed" "$RESET"
note 'Reinicie as sessões abertas do Claude Code para usar a nova versão.'
