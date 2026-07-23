local t = require("workbench.i18n").t

local function open_with_system(path)
  if vim.fn.has("wsl") == 1 then
    local result = vim.system({ "wslpath", "-w", path }, { text = true }):wait()
    local windows_path = vim.trim(result.stdout or "")
    if result.code ~= 0 or windows_path == "" then
      vim.notify(t("path_failed") .. path, vim.log.levels.ERROR)
      return
    end

    local command = { "explorer.exe", windows_path }
    if path:lower():match("%.pdf$") then
      local edge = "/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
      if vim.fn.executable(edge) == 1 then
        command = { edge, windows_path }
        vim.notify(t("open_pdf"), vim.log.levels.INFO)
      end
    end

    local job = vim.fn.jobstart(command, { detach = true })
    if job <= 0 then
      vim.notify(t("open_failed") .. windows_path, vim.log.levels.ERROR)
    end
    return
  end

  vim.ui.open(path)
end

local function ui_highlights(colors)
  return {
    SidekickChat = { bg = colors.mantle },
    SidekickWinBar = { fg = colors.blue, bg = colors.crust, bold = true },
    SidekickWinBarMuted = { fg = colors.overlay1, bg = colors.crust },
    SnacksDashboardHeader = { fg = colors.blue, bold = true },
    SnacksDashboardDir = { fg = colors.teal },
    SnacksDashboardBlue = { fg = colors.blue },
    SnacksDashboardGreen = { fg = colors.green },
    SnacksDashboardMauve = { fg = colors.mauve },
    SnacksDashboardPeach = { fg = colors.peach },
    SnacksDashboardTeal = { fg = colors.teal },
    SnacksDashboardYellow = { fg = colors.yellow },
    WinSeparator = { fg = colors.surface1 },
  }
end

local function apply_ui_highlights()
  local ok, colors = pcall(require("catppuccin.palettes").get_palette, "mocha")
  if not ok then
    return
  end
  for group, highlight in pairs(ui_highlights(colors)) do
    vim.api.nvim_set_hl(0, group, highlight)
  end
end

return {
  { import = "lazyvim.plugins.extras.coding.mini-surround" },
  { import = "lazyvim.plugins.extras.coding.yanky" },
  { import = "lazyvim.plugins.extras.dap.core" },
  { import = "lazyvim.plugins.extras.lang.docker" },
  { import = "lazyvim.plugins.extras.lang.git" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.markdown" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.yaml" },
  { import = "lazyvim.plugins.extras.test.core" },
  { import = "lazyvim.plugins.extras.ui.edgy" },
  { import = "lazyvim.plugins.extras.ui.treesitter-context" },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("workspace_ui_colors", { clear = true }),
        pattern = "catppuccin*",
        callback = function()
          vim.schedule(apply_ui_highlights)
        end,
      })
    end,
    opts = {
      flavour = "mocha",
      custom_highlights = ui_highlights,
      integrations = {
        blink_cmp = true,
        dashboard = true,
        dap = true,
        dap_ui = true,
        gitgutter = true,
        mason = true,
        native_lsp = { enabled = true },
        neotree = true,
        snacks = true,
        treesitter = true,
        which_key = true,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        width = 62,
        preset = {
          header = [[
███╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗  ██║██║   ██║██║████╗ ████║
██╔██╗ ██║██║   ██║██║██╔████╔██║
██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
          keys = {
            {
              icon = { " ", hl = "SnacksDashboardBlue" },
              key = "f",
              desc = t("dashboard_find"),
              action = ":lua Snacks.dashboard.pick('files')",
            },
            {
              icon = { " ", hl = "SnacksDashboardGreen" },
              key = "n",
              desc = t("dashboard_new"),
              action = ":ene | startinsert",
            },
            {
              icon = { " ", hl = "SnacksDashboardMauve" },
              key = "g",
              desc = t("dashboard_grep"),
              action = ":lua Snacks.dashboard.pick('live_grep')",
            },
            {
              icon = { " ", hl = "SnacksDashboardPeach" },
              key = "e",
              desc = t("dashboard_explorer"),
              action = ":lua Snacks.explorer()",
            },
            {
              icon = { " ", hl = "SnacksDashboardTeal" },
              key = "p",
              desc = t("dashboard_projects"),
              action = ":lua Snacks.dashboard.pick('projects')",
            },
            { icon = { " ", hl = "SnacksDashboardBlue" }, key = "a", desc = t("dashboard_codex"), action = " aa" },
            {
              icon = { " ", hl = "SnacksDashboardYellow" },
              key = "s",
              desc = t("dashboard_session"),
              section = "session",
            },
            {
              icon = { " ", hl = "SnacksDashboardMauve" },
              key = "c",
              desc = t("dashboard_config"),
              action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
            },
            { icon = { " ", hl = "SnacksDashboardPeach" }, key = "q", desc = t("dashboard_quit"), action = ":qa" },
          },
        },
        sections = {
          { section = "header", padding = 1 },
          function()
            local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
            return { text = { { "  " .. cwd, hl = "SnacksDashboardDir" } }, align = "center", padding = 1 }
          end,
          { section = "keys", gap = 1, padding = 1 },
          { title = t("dashboard_recent"), padding = 1 },
          { section = "recent_files", cwd = true, limit = 4, padding = 1 },
          { section = "startup" },
        },
      },
      picker = {
        sources = {
          explorer = {
            actions = {
              open_with_system = function(_, item)
                if item and item.file then
                  open_with_system(item.file)
                end
              end,
            },
            win = {
              list = {
                keys = {
                  ["o"] = "open_with_system",
                  ["O"] = "open_with_system",
                },
              },
            },
          },
        },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "debugpy",
        "prettier",
        "shellcheck",
        "shfmt",
        "stylua",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "css",
        "csv",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "html",
        "javascript",
        "json",
        "jsonc",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      })
    end,
  },
}
