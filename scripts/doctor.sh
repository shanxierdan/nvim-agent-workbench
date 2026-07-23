#!/usr/bin/env bash
set -u

failures=0

ok() {
  printf '  [ok]   %s\n' "$1"
}

missing() {
  printf '  [miss] %s\n' "$1"
  failures=$((failures + 1))
}

optional() {
  printf '  [opt]  %s\n' "$1"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

printf 'Nvim Agent Workbench doctor\n\n'
printf 'Required\n'

if have nvim; then
  version="$(nvim --version | sed -n '1s/^NVIM v//p')"
  if nvim --clean --headless -i NONE "+lua if vim.fn.has('nvim-0.11.2') == 0 then vim.cmd('cquit 1') end" +qa! >/dev/null 2>&1; then
    ok "Neovim $version"
  else
    missing "Neovim $version (0.11.2 or newer required)"
  fi
else
  missing "Neovim 0.11.2+"
fi

for command in git tmux codex; do
  if have "$command"; then
    ok "$command"
  else
    missing "$command"
  fi
done

printf '\nRecommended\n'
for command in rg curl unzip make gcc; do
  if have "$command"; then
    ok "$command"
  else
    optional "$command"
  fi
done

if have fd || have fdfind; then
  ok "fd"
else
  optional "fd (called fdfind on Debian/Ubuntu)"
fi

if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  ok "WSL integration ($WSL_DISTRO_NAME)"
elif [[ "$(uname -s)" == "Linux" ]]; then
  optional "WSL integration not detected; native Linux openers will be used"
fi

printf '\n'
if [[ $failures -eq 0 ]]; then
  printf 'Ready. Run :LazyHealth and :checkhealth sidekick after the first launch.\n'
  exit 0
fi

printf '%d required check(s) failed. See README.md for installation links.\n' "$failures"
exit 1
