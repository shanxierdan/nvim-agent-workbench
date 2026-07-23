#!/usr/bin/env bash
set -Eeuo pipefail

REPO_URL="${NVIM_AGENT_REPO:-https://github.com/shanxierdan/nvim-agent-workbench.git}"
BRANCH="${NVIM_AGENT_BRANCH:-main}"
APP_NAME="${NVIM_APPNAME:-nvim}"
SYNC=1

info() {
  printf '[nvim-agent-workbench] %s\n' "$*"
}

warn() {
  printf '[nvim-agent-workbench] warning: %s\n' "$*" >&2
}

die() {
  printf '[nvim-agent-workbench] error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: install.sh [options]

Options:
  --app-name NAME   Install to $XDG_CONFIG_HOME/NAME (default: nvim)
  --branch NAME     Clone a different branch (default: main)
  --repo URL        Clone from a different repository URL
  --no-sync         Do not run Lazy.nvim synchronization
  -h, --help        Show this help

Environment variables:
  NVIM_APPNAME, NVIM_AGENT_REPO, NVIM_AGENT_BRANCH
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-name)
      [[ $# -ge 2 ]] || die "--app-name requires a value"
      APP_NAME="$2"
      shift 2
      ;;
    --branch)
      [[ $# -ge 2 ]] || die "--branch requires a value"
      BRANCH="$2"
      shift 2
      ;;
    --repo)
      [[ $# -ge 2 ]] || die "--repo requires a value"
      REPO_URL="$2"
      shift 2
      ;;
    --no-sync)
      SYNC=0
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *) die "unknown option: $1" ;;
  esac
done

command -v git >/dev/null 2>&1 || die "git is required"

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TARGET="$CONFIG_HOME/$APP_NAME"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP=""

mkdir -p "$CONFIG_HOME"

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  BACKUP="$TARGET.bak.$STAMP"
  info "backing up $TARGET to $BACKUP"
  mv "$TARGET" "$BACKUP"
fi

info "cloning $REPO_URL ($BRANCH) to $TARGET"
if ! git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TARGET"; then
  if [[ -n "$BACKUP" && ! -e "$TARGET" ]]; then
    warn "clone failed; restoring the previous configuration"
    mv "$BACKUP" "$TARGET"
  fi
  die "unable to clone the repository"
fi

if ! command -v nvim >/dev/null 2>&1; then
  warn "Neovim is not installed. The configuration is ready, but plugins were not synchronized."
  bash "$TARGET/scripts/doctor.sh" || true
  exit 0
fi

if ! nvim --clean --headless -i NONE "+lua if vim.fn.has('nvim-0.11.2') == 0 then vim.cmd('cquit 1') end" +qa! >/dev/null 2>&1; then
  warn "Neovim 0.11.2 or newer is required. Plugins were not synchronized."
  bash "$TARGET/scripts/doctor.sh" || true
  exit 0
fi

if [[ $SYNC -eq 1 ]]; then
  info "installing pinned plugins"
  if ! NVIM_APPNAME="$APP_NAME" nvim --headless "+Lazy! sync" +qa!; then
    warn "plugin synchronization failed; run :Lazy sync inside Neovim to retry"
  fi
fi

info "installation complete"
if [[ -n "$BACKUP" ]]; then
  info "previous configuration: $BACKUP"
fi
info "run: NVIM_APPNAME=$APP_NAME nvim"
bash "$TARGET/scripts/doctor.sh" || true
