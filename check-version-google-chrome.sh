#!/usr/bin/env bash
set -Eeuo pipefail

GOOGLE_CHROME_PACKAGES_URL="https://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/Packages"
CFT_STABLE_JSON_URL="https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json"

die() {
  echo "ERRO: $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Comando obrigatório não encontrado: $1"
}

normalize_version() {
  # Extrai algo como 148.0.7778.97 de:
  # - "Google Chrome 148.0.7778.97"
  # - "148.0.7778.97-1"
  grep -oE '[0-9]+(\.[0-9]+){3}' <<< "${1:-}" | head -n1
}

find_chrome_bin() {
  local pid exe

  # Tenta identificar o Chrome realmente em execução.
  pid="$(pgrep -xo chrome 2>/dev/null || true)"

  if [[ -n "${pid}" ]]; then
    exe="$(readlink -f "/proc/${pid}/exe" 2>/dev/null || true)"

    if [[ -n "${exe}" && -x "${exe}" ]]; then
      echo "${exe}"
      return 0
    fi
  fi

  # Fallback para o Chrome instalado.
  for bin in google-chrome-stable google-chrome /opt/google/chrome/chrome; do
    if command -v "${bin}" >/dev/null 2>&1; then
      command -v "${bin}"
      return 0
    fi

    if [[ -x "${bin}" ]]; then
      echo "${bin}"
      return 0
    fi
  done

  return 1
}

get_local_chrome_version() {
  local chrome_bin="$1"
  local raw_version

  raw_version="$("${chrome_bin}" --version 2>/dev/null || true)"

  [[ "${raw_version}" == Google\ Chrome* ]] || {
    die "O executável encontrado não parece ser o Google Chrome Stable: ${raw_version:-sem saída}"
  }

  normalize_version "${raw_version}"
}

get_latest_from_google_repo() {
  curl -fsSL "${GOOGLE_CHROME_PACKAGES_URL}" |
    awk '
      /^Package: google-chrome-stable$/ { found=1; next }
      found && /^Version:/ { print $2; exit }
    ' |
    xargs -r bash -c 'grep -oE "[0-9]+(\.[0-9]+){3}" <<< "$0" | head -n1'
}

get_latest_from_cft() {
  need_cmd python3

  curl -fsSL "${CFT_STABLE_JSON_URL}" |
    python3 -c '
import json, sys
data = json.load(sys.stdin)
print(data["channels"]["Stable"]["version"])
'
}

compare_versions() {
  local current="$1"
  local latest="$2"

  if [[ "${current}" == "${latest}" ]]; then
    echo "equal"
  elif [[ "$(printf '%s\n%s\n' "${current}" "${latest}" | sort -V | head -n1)" == "${current}" ]]; then
    echo "older"
  else
    echo "newer"
  fi
}

main() {
  need_cmd curl
  need_cmd awk
  need_cmd grep
  need_cmd sort
  need_cmd head
  need_cmd xargs

  local chrome_bin
  local local_version
  local latest_version
  local source
  local status

  chrome_bin="$(find_chrome_bin)" || die "Google Chrome não encontrado."

  local_version="$(get_local_chrome_version "${chrome_bin}")"
  [[ -n "${local_version}" ]] || die "Não foi possível detectar a versão local do Chrome."

  latest_version="$(get_latest_from_google_repo || true)"
  source="Google Linux Chrome repo"

  if [[ -z "${latest_version}" ]]; then
    latest_version="$(get_latest_from_cft || true)"
    source="Chrome for Testing Stable JSON"
  fi

  [[ -n "${latest_version}" ]] || die "Não foi possível consultar a versão Stable mais recente."

  status="$(compare_versions "${local_version}" "${latest_version}")"

  echo "Executável Chrome: ${chrome_bin}"
  echo "Versão local:      ${local_version}"
  echo "Stable mais nova:  ${latest_version}"
  echo "Fonte consultada:  ${source}"
  echo

  case "${status}" in
    equal)
      echo "OK: seu Google Chrome Stable está atualizado."
      exit 0
      ;;
    older)
      echo "DESATUALIZADO: existe uma versão Stable mais recente."
      echo
      echo "Para atualizar:"
      echo "  sudo apt update && sudo apt install --only-upgrade google-chrome-stable"
      exit 1
      ;;
    newer)
      echo "ATENÇÃO: sua versão local é maior que a referência Stable consultada."
      echo "Isso pode indicar canal Beta/Dev/Canary, instalação não padrão ou propagação diferente do repositório."
      exit 2
      ;;
  esac
}

main "$@"
