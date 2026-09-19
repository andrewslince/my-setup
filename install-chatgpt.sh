#!/usr/bin/env bash

# Instala o aplicativo oficial do ChatGPT para Linux (versão preview).
# Referência: https://learn.chatgpt.com/docs/linux/linux-app
# Uso: bash install-chatgpt.sh

set -euo pipefail

BASE_URL="https://persistent.oaistatic.com/codex-app-prod/linux"

info() { printf '[INFO] %s\n' "$*"; }
error() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }

if [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]]; then
  cat <<'EOF'
Uso: bash install-chatgpt.sh

Instala o ChatGPT em sistemas Ubuntu/Debian com apt, Fedora 43/44 ou Arch Linux,
com processadores x64 ou ARM64. No Arch, o instalador oficial atualiza o sistema
e solicita confirmação. Ubuntu 24.04/26.04 e Debian 13 são as versões
formalmente suportadas pela OpenAI.
EOF
  exit 0
fi

[[ "$#" -eq 0 ]] || error 'Este script não aceita argumentos.'
[[ "$(id -u)" -ne 0 ]] || error 'Execute como usuário comum; o script usará sudo quando necessário.'
[[ -r /etc/os-release ]] || error 'Não foi possível identificar a distribuição em /etc/os-release.'

# shellcheck source=/dev/null
. /etc/os-release

officially_supported=false

case "${ID:-}" in
  ubuntu|debian)
    manager=apt
    ;;
  fedora)
    case "${VERSION_ID:-}" in
      43|44) officially_supported=true ;;
    esac
    manager=dnf
    ;;
  arch:*)
    manager=arch
    ;;
  *)
    error "Distribuição não suportada: ${PRETTY_NAME:-${ID:-desconhecida}}."
    ;;
esac

case "${ID:-}:${VERSION_ID:-}" in
  ubuntu:24.04|ubuntu:26.04|debian:13|fedora:43|fedora:44|arch:*)
    officially_supported=true
    ;;
esac

if [[ "$officially_supported" != true ]]; then
  info "${PRETTY_NAME:-${ID:-desconhecida}} não consta na lista de versões formalmente suportadas pela OpenAI; continuando com o instalador compatível."
fi

case "$(uname -m)" in
  x86_64)
    deb_arch=amd64
    rpm_arch=x86_64
    ;;
  aarch64|arm64)
    deb_arch=arm64
    rpm_arch=aarch64
    ;;
  *)
    error "Arquitetura não suportada: $(uname -m)."
    ;;
esac

for command_name in curl sudo mktemp "$manager"; do
  if [[ "$command_name" == arch ]]; then
    command_name=pacman
  fi
  command -v "$command_name" >/dev/null 2>&1 || error "Comando necessário não encontrado: $command_name."
done

download_dir=$(mktemp -d)
trap 'rm -rf -- "$download_dir"' EXIT

case "$manager" in
  apt)
    filename="chatgpt_${deb_arch}.deb"
    url="${BASE_URL}/deb/latest/${filename}"
    ;;
  dnf)
    filename="chatgpt.${rpm_arch}.rpm"
    url="${BASE_URL}/rpm/latest/${filename}"
    ;;
  arch)
    filename=install-arch.sh
    url="${BASE_URL}/${filename}"
    ;;
esac

info "Baixando ${filename} da OpenAI..."
curl --proto '=https' --tlsv1.2 -fL --retry 3 -o "${download_dir}/${filename}" "$url"
[[ -s "${download_dir}/${filename}" ]] || error 'O arquivo baixado está vazio.'

case "$manager" in
  apt)
    # O usuário _apt precisa ler o arquivo local durante a instalação.
    chmod 755 "$download_dir"
    chmod 644 "${download_dir}/${filename}"
    info 'Instalando ChatGPT com apt...'
    sudo apt install -y "${download_dir}/${filename}"
    ;;
  dnf)
    info 'Instalando ChatGPT com dnf...'
    sudo dnf install -y "${download_dir}/${filename}"
    ;;
  arch)
    info 'O instalador oficial do Arch fará uma atualização completa do sistema e pedirá confirmação.'
    sudo bash "${download_dir}/${filename}"
    ;;
esac

info 'Instalação concluída. Abra o ChatGPT pelo menu de aplicativos ou execute: chatgpt'
