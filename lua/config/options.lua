-- Options are loaded before lazy.nvim starts.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt
opt.autowrite = true
opt.clipboard = "unnamedplus"
opt.colorcolumn = "100"
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.number = true
opt.relativenumber = true
opt.scrolloff = 8
opt.shiftwidth = 2
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smartindent = true
opt.softtabstop = 2
opt.tabstop = 2
opt.termguicolors = true
opt.timeoutlen = 300
opt.undofile = true
opt.wrap = false

-- Windows Terminal and WSL clipboard integration.
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WSL clipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = "powershell.exe -NoLogo -NoProfile -Command Get-Clipboard -Raw",
      ["*"] = "powershell.exe -NoLogo -NoProfile -Command Get-Clipboard -Raw",
    },
    cache_enabled = 0,
  }
end

vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"
