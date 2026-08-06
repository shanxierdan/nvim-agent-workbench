local t = require("workbench.i18n").t

local function codex_opts(opts)
  return vim.tbl_extend("force", { name = "codex" }, opts or {})
end

local function project_codex_state()
  local State = require("sidekick.cli.state")
  local Session = require("sidekick.cli.session")
  Session.setup()

  local attached = State.get({ name = "codex", cwd = true, attached = true })
  if attached[1] then
    return attached[1]
  end

  local cwd = Session.cwd()
  local sid = Session.sid({ tool = "codex", cwd = cwd })
  local exists = vim.system({ "tmux", "has-session", "-t", "=" .. sid }, { text = true }):wait()
  if exists.code ~= 0 then
    return nil
  end

  local session = Session.new({
    tool = "codex",
    cwd = cwd,
    id = sid,
    started = true,
    backend = "tmux",
    mux_session = sid,
  })
  return State.get_state(session)
end

local function project_codex_opts(opts)
  return codex_opts(vim.tbl_extend("force", { filter = { cwd = true } }, opts or {}))
end

local function start_codex(cmd)
  local Config = require("sidekick.config")
  local Session = require("sidekick.cli.session")
  local State = require("sidekick.cli.state")
  local original = Config.cli.tools.codex.cmd

  Session.setup()
  Config.cli.tools.codex.cmd = cmd
  local ok, err = pcall(
    State.attach,
    { tool = Config.get_tool("codex"), installed = true },
    { show = true, focus = true }
  )
  Config.cli.tools.codex.cmd = original
  if not ok then
    error(err)
  end
end

local function show_codex(state)
  return require("sidekick.cli.state").attach(state, { show = true, focus = true })
end

local function toggle_codex_state(state)
  local current, attached = require("sidekick.cli.state").attach(state)
  if not current.terminal then
    return
  end
  if not attached then
    current.terminal:toggle()
  end
  if current.terminal:is_open() then
    current.terminal:focus()
  end
end

local function restore_codex_input()
  local win = vim.api.nvim_get_current_win()
  local session_id = vim.w[win].sidekick_session_id
  if not session_id then
    return
  end

  vim.schedule(function()
    local terminal = require("sidekick.cli.terminal").get(session_id)
    if terminal and terminal.tool.name == "codex" and terminal:is_running() and terminal:is_focused() then
      terminal.normal_mode = false
      vim.cmd.startinsert()
    end
  end)
end

local function select_codex_session()
  local choices = {
    { label = t("resume_history"), cmd = { "codex", "resume" } },
    { label = t("resume_last"), cmd = { "codex", "resume", "--last" } },
    { label = t("resume_new"), cmd = { "codex" } },
  }

  vim.ui.select(choices, {
    prompt = t("no_codex"),
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice then
      start_codex(choice.cmd)
    end
  end)
end

local function toggle_codex()
  local state = project_codex_state()
  if state then
    toggle_codex_state(state)
  else
    select_codex_session()
  end
end

local function new_codex_chat()
  local state = project_codex_state()
  if state then
    show_codex(state)
    require("sidekick.cli").send(project_codex_opts({ msg = "/new", submit = true, focus = true }))
  else
    start_codex({ "codex" })
  end
end

local function resume_codex_chat()
  local state = project_codex_state()
  if state then
    show_codex(state)
    require("sidekick.cli").send(project_codex_opts({ msg = "/resume", submit = true, focus = true }))
  else
    start_codex({ "codex", "resume" })
  end
end

local function resume_last_codex_chat()
  local state = project_codex_state()
  if state then
    show_codex(state)
    vim.notify(t("codex_reconnected"), vim.log.levels.INFO)
  else
    start_codex({ "codex", "resume", "--last" })
  end
end

local function has_editor_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local is_float = vim.api.nvim_win_get_config(win).relative ~= ""
    local is_sidekick = vim.w[win].sidekick_cli ~= nil
    local is_file = vim.bo[buf].buftype == ""
    if not is_float and not is_sidekick and (is_file or vim.b[buf].snacks_main) then
      return true
    end
  end
  return false
end

local function protect_codex_window()
  local win = vim.api.nvim_get_current_win()
  if not vim.w[win].sidekick_cli or has_editor_window() then
    return
  end

  vim.schedule(function()
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_get_current_win() == win and not has_editor_window() then
      vim.cmd("leftabove vnew")
    end
  end)
end

return {
  {
    "folke/sidekick.nvim",
    init = function()
      local group = vim.api.nvim_create_augroup("codex_editor_window", { clear = true })
      vim.api.nvim_create_autocmd("WinEnter", {
        group = group,
        callback = protect_codex_window,
        desc = "Keep a file window beside the Codex terminal",
      })
      vim.api.nvim_create_autocmd("WinEnter", {
        group = group,
        callback = restore_codex_input,
        desc = "Restore input mode when focusing Codex",
      })
    end,
    opts = {
      -- Codex provides the agent workflow. Copilot NES is intentionally disabled.
      nes = { enabled = false },
      cli = {
        watch = true,
        win = {
          layout = "right",
          split = { width = 0.4, height = 20 },
          wo = {
            winbar = "%#SidekickWinBar#    CODEX %*%#SidekickWinBarMuted#  %{fnamemodify(getcwd(), ':t')}  %*%=",
          },
        },
        mux = {
          backend = "tmux",
          enabled = true,
          create = "terminal",
        },
        tools = {
          codex = { native_scroll = true },
        },
        prompts = {
          diagnostics = t("diagnostics_prompt"),
          review = t("review_prompt"),
          explain = t("codex_explain"),
          tests = t("codex_tests"),
        },
      },
    },
    keys = {
      {
        "<leader>aa",
        toggle_codex,
        desc = t("codex_open"),
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>an",
        new_codex_chat,
        desc = t("codex_new"),
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>ah",
        resume_codex_chat,
        desc = t("codex_history"),
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>al",
        resume_last_codex_chat,
        desc = t("codex_last"),
        mode = { "n", "t", "i", "x" },
      },
      {
        "<C-.>",
        function()
          require("sidekick.cli").focus(codex_opts())
        end,
        desc = t("codex_focus"),
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send(codex_opts({ msg = "{file}", focus = true }))
        end,
        desc = t("codex_attach_file"),
      },
      {
        "<leader>as",
        function()
          require("sidekick.cli").send(codex_opts({ msg = "{selection}", focus = true }))
        end,
        desc = t("codex_attach_selection"),
        mode = "x",
      },
      {
        "<leader>ad",
        function()
          require("sidekick.cli").send(codex_opts({ prompt = "diagnostics", submit = true, focus = true }))
        end,
        desc = t("codex_fix_diagnostics"),
      },
      {
        "<leader>ar",
        function()
          require("sidekick.cli").send(codex_opts({ prompt = "review", submit = true, focus = true }))
        end,
        desc = t("codex_review"),
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt({
            cb = function(_, text)
              if text then
                require("sidekick.cli").send(codex_opts({ text = text, focus = true }))
              end
            end,
          })
        end,
        desc = t("codex_prompt"),
        mode = { "n", "x" },
      },
      {
        "<leader>ax",
        function()
          require("sidekick.cli").close(codex_opts())
        end,
        desc = t("codex_detach"),
      },
    },
  },

  {
    "folke/snacks.nvim",
    optional = true,
    opts = {
      picker = {
        actions = {
          sidekick_send = function(...)
            return require("sidekick.cli.picker.snacks").send(...)
          end,
        },
        win = {
          input = {
            keys = {
              ["<a-a>"] = { "sidekick_send", mode = { "n", "i" } },
            },
          },
        },
      },
    },
  },
}
