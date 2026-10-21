#!/usr/bin/env bash
set -Eeuo pipefail

# Atualiza somente a CLI instalada pelo instalador oficial em ~/.supabase/bin.
# Não para containers nem altera volumes, migrations ou projetos locais.

INSTALL_DIR="${HOME}/.supabase/bin"
CLI="${INSTALL_DIR}/supabase"
INSTALLER_URL="https://raw.githubusercontent.com/supabase/cli/main/install"
RELEASE_URL="https://api.github.com/repos/supabase/cli/releases/latest"
CHECK_ONLY=false
AUTO_STOP=false

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  BOLD=$'\033[1m' DIM=$'\033[2m' GREEN=$'\033[32m'
  RED=$'\033[31m' CYAN=$'\033[36m' RESET=$'\033[0m'
else
  BOLD='' DIM='' GREEN='' RED='' CYAN='' RESET=''
fi

usage() {
  cat <<'EOF'
Uso: ./update-supabase-cli.sh [--check] [--stop]

  --check  Verifica pré-requisitos, containers e versões sem instalar nem parar nada.
  --stop   Para os projetos Supabase em execução sem perguntar.
  -h      Mostra esta ajuda.

Se houver projetos rodando, o script pergunta se pode pará-los (supabase stop,
que preserva os volumes). Atualiza apenas ~/.supabase/bin/supabase.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --check) CHECK_ONLY=true ;;
    --stop) AUTO_STOP=true ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

step() { printf '\n%s●%s %s\n' "$CYAN" "$RESET" "$1"; }
ok() { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
note() { printf '%sℹ%s %s\n' "$DIM" "$RESET" "$1"; }
fail() { printf '%s✗ %s%s\n' "$RED" "$1" "$RESET" >&2; exit 1; }

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Comando necessário não encontrado: $1"
}

repeat_char() {
  local count=$1 char=$2 spaces
  printf -v spaces '%*s' "$count" ''
  printf '%s' "${spaces// /$char}"
}

fit_cell() {
  local value=$1 width=$2
  if (( ${#value} > width )); then
    value="${value:0:width-1}…"
  fi
  # printf %-*s conta bytes; acentos e reticências deslocariam a borda.
  printf '%s' "$value"
  repeat_char "$((width - ${#value}))" ' '
}

border() {
  local left=$1 middle=$2 right=$3 project_width=$4 name_width=$5 image_width=$6
  printf '%s%s%s%s%s%s%s\n' "$left" \
    "$(repeat_char "$((project_width + 2))" '─')" "$middle" \
    "$(repeat_char "$((name_width + 2))" '─')" "$middle" \
    "$(repeat_char "$((image_width + 2))" '─')" "$right"
}

show_containers() {
  local rows=$1 name image project project_width=7 name_width=9 image_width=6
  local terminal_width budget truncated=false
  local -a projects=() names=() images=()

  while IFS=$'\t' read -r name image; do
    [[ -n "$name" ]] || continue
    # Os nomes do supabase start seguem supabase_<serviço>_<project_id>.
    # A imagem cobre serviços com nome diferente ou versões futuras da CLI.
    if [[ "$name" != supabase_* && "$image" != supabase/* ]]; then
      continue
    fi
    project='não identificado'
    if [[ "$name" =~ ^supabase_(db|kong|auth|rest|realtime|storage|imgproxy|pg_meta|meta|studio|inbucket|mailpit|analytics|vector|edge_runtime|pooler|functions|graphql|supavisor)_(.+)$ ]]; then
      project="${BASH_REMATCH[2]}"
    fi
    projects+=("$project") names+=("$name") images+=("$image")
    (( ${#project} > project_width )) && project_width=${#project}
    (( ${#name} > name_width )) && name_width=${#name}
    (( ${#image} > image_width )) && image_width=${#image}
  done <<< "$rows"

  (( ${#names[@]} > 0 )) || return 1
  EXAMPLE_CONTAINER=${names[0]}

  terminal_width=$(tput cols 2>/dev/null || printf '100')
  [[ "$terminal_width" =~ ^[0-9]+$ ]] || terminal_width=100
  (( terminal_width < 32 )) && terminal_width=32
  # Em terminais estreitos, a tabela abrevia células e imprime os nomes completos abaixo.
  (( project_width > 28 )) && project_width=28
  (( name_width > 42 )) && name_width=42
  budget=$((terminal_width - 10))
  while (( project_width + name_width + image_width > budget )); do
    if (( image_width > 16 )); then
      (( image_width -= 1 ))
    elif (( name_width > 24 )); then
      (( name_width -= 1 ))
    elif (( project_width > 12 )); then
      (( project_width -= 1 ))
    elif (( image_width > 6 )); then
      (( image_width -= 1 ))
    elif (( name_width > 9 )); then
      (( name_width -= 1 ))
    else
      (( project_width -= 1 ))
    fi
  done

  printf '\n%sContainers Supabase em execução%s\n' "$BOLD" "$RESET"
  border '┌' '┬' '┐' "$project_width" "$name_width" "$image_width"
  printf '│ %s │ %s │ %s │\n' \
    "$(fit_cell 'Projeto' "$project_width")" \
    "$(fit_cell 'Container' "$name_width")" \
    "$(fit_cell 'Imagem' "$image_width")"
  border '├' '┼' '┤' "$project_width" "$name_width" "$image_width"

  local i
  for (( i=0; i<${#names[@]}; i++ )); do
    printf '│ %s │ %s │ %s │\n' \
      "$(fit_cell "${projects[i]}" "$project_width")" \
      "$(fit_cell "${names[i]}" "$name_width")" \
      "$(fit_cell "${images[i]}" "$image_width")"
    if (( ${#projects[i]} > project_width || ${#names[i]} > name_width || ${#images[i]} > image_width )); then
      truncated=true
    fi
  done
  border '└' '┴' '┘' "$project_width" "$name_width" "$image_width"
  if [[ "$truncated" == true ]]; then
    printf '\nDados completos:\n'
    for (( i=0; i<${#names[@]}; i++ )); do
      printf '  Projeto: %s\n  Container: %s\n  Imagem: %s\n\n' \
        "${projects[i]}" "${names[i]}" "${images[i]}"
    done
  fi
  return 0
}

list_running_projects() {
  # O label guarda o project_id e a pasta de origem, então não depende do cwd.
  docker ps --filter 'label=com.supabase.cli.project' \
    --format '{{.Label "com.supabase.cli.project"}}\t{{.Label "com.supabase.cli.workdir"}}' | sort -u
}

stop_running_projects() {
  local project workdir
  while IFS=$'\t' read -r project workdir; do
    [[ -n "$project" ]] || continue
    note "Parando $project${workdir:+ ($workdir)}"
    # Sem --no-backup: os volumes (dados do banco e storage) são preservados.
    SUPABASE_TELEMETRY_DISABLED=1 "$CLI" stop --project-id "$project" \
      || fail "Não foi possível parar o projeto $project."
  done < <(list_running_projects)
}

check_docker() {
  local rows projects answer
  if ! rows=$(docker ps --format '{{.Names}}\t{{.Image}}' 2>&1); then
    fail "Não foi possível consultar os containers Docker. Detalhes: $rows"
  fi
  if ! show_containers "$rows"; then
    ok 'Nenhum container Supabase em execução.'
    return 0
  fi

  projects=$(list_running_projects)
  if [[ -n "$projects" ]]; then
    printf '\n%sProjetos a parar (dados preservados):%s\n' "$BOLD" "$RESET"
    while IFS=$'\t' read -r project workdir; do
      printf '  %s  %s%s%s\n' "$project" "$DIM" "${workdir:-pasta desconhecida}" "$RESET"
    done <<< "$projects"
  fi

  if [[ "$CHECK_ONLY" == true ]]; then
    note 'Modo --check: nada foi parado. Sem --check, o script oferece parar esses projetos.'
    return 0
  fi

  if [[ "$AUTO_STOP" != true ]]; then
    [[ -t 0 ]] || fail 'Há projetos em execução. Use --stop para pará-los sem perguntar.'
    printf '\nParar esses projetos agora para seguir com a atualização? [s/N] '
    read -r answer
    [[ "$answer" =~ ^[sSyY]$ ]] || fail 'Atualização cancelada: os projetos continuam em execução.'
  fi

  stop_running_projects
  # Containers sem label (versões antigas da CLI) ainda precisam estar parados.
  if show_containers "$(docker ps --format '{{.Names}}\t{{.Image}}')"; then
    fail 'Ainda há containers Supabase em execução. Pare-os manualmente (docker stop <nome>).'
  fi
  ok 'Projetos parados.'
}

printf '%s\n' '╭────────────────────────────────────────╮'
printf '│  %sSupabase CLI · atualização local%s       │\n' "$BOLD" "$RESET"
printf '%s\n' '╰────────────────────────────────────────╯'

step 'Verificando o ambiente'
require_command docker
require_command curl
require_command jq
require_command bash
[[ -x "$CLI" ]] || fail "CLI não encontrada em $CLI. Este script atualiza apenas essa instalação."
command_path=$(command -v supabase || true)
[[ "$command_path" == "$CLI" ]] || fail "O comando supabase aponta para ${command_path:-outro local}. Esperado: $CLI"
current=$(SUPABASE_TELEMETRY_DISABLED=1 "$CLI" --version 2>/dev/null) || fail 'Não foi possível ler a versão da CLI instalada.'
ok "CLI atual: $current"
check_docker

step 'Consultando a versão estável mais recente'
release_json=$(curl -fsSL --connect-timeout 10 --max-time 30 "$RELEASE_URL") || fail 'Não foi possível consultar os releases oficiais.'
latest=$(jq -r '.tag_name // empty' <<< "$release_json")
[[ "$latest" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "Tag de release inesperada: ${latest:-vazia}"
latest=${latest#v}
ok "Última versão estável: $latest"

if [[ "$current" == "$latest" ]]; then
  printf '\n%s✓ A CLI já está atualizada.%s\n' "$GREEN" "$RESET"
  exit 0
fi

if [[ "$CHECK_ONLY" == true ]]; then
  printf '\n%sVerificação concluída.%s Execute sem --check para atualizar a CLI.\n' "$CYAN" "$RESET"
  exit 0
fi

note 'A instalação não altera containers, volumes nem dados dos projetos.'
note 'Antes do próximo supabase start, planeje o backup e a atualização de cada projeto.'

step 'Confirmando que os projetos continuam parados'
check_docker

step "Baixando o instalador oficial para a versão $latest"
tmp_dir=$(mktemp -d) || fail 'Não foi possível criar um diretório temporário.'
trap 'rm -rf "$tmp_dir"' EXIT
curl -fsSL --connect-timeout 10 --max-time 60 "$INSTALLER_URL" -o "$tmp_dir/install" \
  || fail 'Falha ao baixar o instalador oficial.'
ok 'Instalador recebido.'

step 'Instalando e verificando a CLI'
SUPABASE_TELEMETRY_DISABLED=1 bash "$tmp_dir/install" --version "$latest" --no-modify-path \
  || fail 'A instalação falhou. Confira a saída do instalador acima.'
installed=$(SUPABASE_TELEMETRY_DISABLED=1 "$CLI" --version 2>/dev/null) \
  || fail 'A CLI instalada não respondeu à verificação final.'
[[ "$installed" == "$latest" ]] || fail "Versão instalada inesperada: $installed (esperada: $latest)"

printf '\n%s✓ Supabase CLI atualizada: %s → %s%s\n' "$GREEN" "$current" "$installed" "$RESET"
note 'Os projetos locais não foram iniciados ou modificados.'
