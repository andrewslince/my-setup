#!/usr/bin/env bash
# =============================================================================
# install-claude-code.sh
# Instala o Claude Code (Anthropic) via instalador nativo oficial.
# Compatível com Ubuntu 22.04 / 24.04 / 25.10 · x64 e ARM64
# Uso: bash install-claude-code.sh
# =============================================================================

set -euo pipefail

# --- Cores para output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[AVISO]${RESET} $*"; }
error()   { echo -e "${RED}[ERRO]${RESET}  $*" >&2; exit 1; }

# =============================================================================
echo -e "\n${BOLD}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║        Instalação do Claude Code             ║${RESET}"
echo -e "${BOLD}║        Anthropic · Instalador Nativo         ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${RESET}\n"
# =============================================================================

# --- 1. Verificar se já está instalado ---
if command -v claude &>/dev/null; then
  CURRENT_VERSION=$(claude --version 2>/dev/null || echo "desconhecida")
  warn "Claude Code já está instalado (versão: ${CURRENT_VERSION})."
  read -rp "$(echo -e "${YELLOW}Deseja reinstalar/atualizar? [s/N]: ${RESET}")" CONFIRM
  [[ "${CONFIRM,,}" =~ ^(s|sim|y|yes)$ ]] || { info "Instalação cancelada."; exit 0; }
fi

# --- 2. Verificar dependência: curl ---
info "Verificando dependência: curl..."
if ! command -v curl &>/dev/null; then
  info "curl não encontrado. Instalando via apt..."
  sudo apt-get update -qq
  sudo apt-get install -y curl
  success "curl instalado."
else
  success "curl já disponível."
fi

# --- 3. Executar instalador oficial ---
info "Baixando e executando o instalador oficial da Anthropic..."
curl -fsSL https://claude.ai/install.sh | bash

# --- 4. Garantir ~/.local/bin no PATH ---
SHELL_RC=""
if [[ "$SHELL" == */zsh ]]; then
  SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == */bash ]]; then
  SHELL_RC="$HOME/.bashrc"
else
  SHELL_RC="$HOME/.profile"
fi

PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

if ! grep -qxF "$PATH_LINE" "$SHELL_RC" 2>/dev/null; then
  echo "" >> "$SHELL_RC"
  echo "# Claude Code" >> "$SHELL_RC"
  echo "$PATH_LINE" >> "$SHELL_RC"
  info "PATH atualizado em ${SHELL_RC}."
else
  info "PATH já configurado em ${SHELL_RC}."
fi

# Carrega PATH na sessão atual para a verificação abaixo
export PATH="$HOME/.local/bin:$PATH"

# --- 5. Verificar instalação ---
if command -v claude &>/dev/null; then
  VERSION=$(claude --version 2>/dev/null || echo "instalado")
  success "Claude Code instalado com sucesso! Versão: ${VERSION}"
else
  error "Instalação concluída, mas 'claude' não foi encontrado no PATH.\nReinicie o terminal e execute: claude --version"
fi

# --- 6. Próximos passos ---
echo ""
echo -e "${BOLD}Próximos passos:${RESET}"
echo -e "  1. Reinicie o terminal (ou execute: ${CYAN}source ${SHELL_RC}${RESET})"
echo -e "  2. Navegue até o projeto:  ${CYAN}cd ~/projetos/thayoliveiraimoveis-crm${RESET}"
echo -e "  3. Inicie o Claude Code:   ${CYAN}claude${RESET}"
echo -e "  4. Na primeira execução, autentique via browser com sua conta Anthropic."
echo ""
echo -e "${YELLOW}Nota:${RESET} É necessário plano Pro, Max, Team, Enterprise ou Console (API)."
echo -e "      O plano gratuito do Claude.ai ${RED}não${RESET} inclui acesso ao Claude Code."
echo ""
