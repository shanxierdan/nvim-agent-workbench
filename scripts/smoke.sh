#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

export XDG_CONFIG_HOME="$TMP_ROOT/config"
export XDG_DATA_HOME="$TMP_ROOT/data"
export XDG_STATE_HOME="$TMP_ROOT/state"
export XDG_CACHE_HOME="$TMP_ROOT/cache"
export NVIM_APPNAME="nvim-agent-workbench"

mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$XDG_CONFIG_HOME/$NVIM_APPNAME"
git -C "$ROOT" archive HEAD | tar -x -C "$XDG_CONFIG_HOME/$NVIM_APPNAME"

nvim --headless -i NONE "+Lazy! sync" +qa!
nvim --headless -i NONE "+lua assert(vim.fn.exists('#codex_editor_window#WinEnter') == 1)" +qa!
nvim --headless -u NONE -i NONE "+lua dofile('$ROOT/tests/ai_toggle.lua')" +qa!
