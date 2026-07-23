local M = {}

local messages = {
  en = {
    codex_attach_file = "Codex: attach current file",
    codex_attach_selection = "Codex: attach selection",
    codex_detach = "Codex: detach panel session",
    codex_explain = "Explain the purpose, data flow, and key design decisions in the following code:\n{this}",
    codex_fix_diagnostics = "Codex: fix diagnostics",
    codex_focus = "Codex: switch focus",
    codex_history = "Codex: choose a saved chat",
    codex_last = "Codex: continue latest chat",
    codex_new = "Codex: new chat",
    codex_open = "Codex: open/resume/hide",
    codex_prompt = "Codex: choose prompt and context",
    codex_reconnected = "Reconnected to the running Codex session for this project",
    codex_review = "Codex: review current file",
    codex_tests = "Write valuable tests for the following code and run the relevant test suite:\n{this}",
    dashboard_codex = "Open Codex",
    dashboard_config = "Edit config",
    dashboard_explorer = "File explorer",
    dashboard_find = "Find file",
    dashboard_grep = "Search text",
    dashboard_new = "New file",
    dashboard_projects = "Recent projects",
    dashboard_quit = "Quit",
    dashboard_recent = "Recent files",
    dashboard_session = "Restore workspace",
    diagnostics_prompt = "Fix the diagnostics in the current file. Explain the cause, make the smallest safe change, and run the relevant checks.\n{file}\n{diagnostics}",
    no_codex = "No Codex session is running for this project:",
    open_failed = "Failed to open: ",
    open_pdf = "Opening PDF in Microsoft Edge...",
    path_failed = "Failed to convert path: ",
    resume_history = "Choose a saved chat (recommended)",
    resume_last = "Continue latest chat",
    resume_new = "Start a new chat",
    review_prompt = "Review the current file, prioritizing bugs, regressions, and missing tests.\n{file}",
  },
  zh = {
    codex_attach_file = "Codex: 附加当前文件",
    codex_attach_selection = "Codex: 附加选区",
    codex_detach = "Codex: 分离面板会话",
    codex_explain = "请解释以下代码的作用、数据流和关键设计决定：\n{this}",
    codex_fix_diagnostics = "Codex: 修复诊断",
    codex_focus = "Codex: 切换焦点",
    codex_history = "Codex: 选择历史对话",
    codex_last = "Codex: 继续最近对话",
    codex_new = "Codex: 新建对话",
    codex_open = "Codex: 打开/恢复/隐藏",
    codex_prompt = "Codex: 选择提示和上下文",
    codex_reconnected = "当前项目的 Codex 会话仍在运行，已重新连接",
    codex_review = "Codex: 审查当前文件",
    codex_tests = "请为以下代码补充有价值的测试，并运行相关测试：\n{this}",
    dashboard_codex = "打开 Codex",
    dashboard_config = "编辑配置",
    dashboard_explorer = "文件浏览器",
    dashboard_find = "查找文件",
    dashboard_grep = "搜索内容",
    dashboard_new = "新建文件",
    dashboard_projects = "最近项目",
    dashboard_quit = "退出",
    dashboard_recent = "最近文件",
    dashboard_session = "恢复工作区",
    diagnostics_prompt = "请修复当前文件中的诊断问题。先说明原因，再进行最小修改，并运行相关检查。\n{file}\n{diagnostics}",
    no_codex = "当前项目没有运行中的 Codex：",
    open_failed = "无法打开：",
    open_pdf = "正在使用 Microsoft Edge 打开 PDF...",
    path_failed = "路径转换失败：",
    resume_history = "选择历史对话（推荐）",
    resume_last = "继续最近对话",
    resume_new = "新建对话",
    review_prompt = "请审查当前文件，重点检查错误、行为回归和缺失的测试。\n{file}",
  },
}

local requested = (vim.env.NVIM_AGENT_LANGUAGE or ""):lower()
local locale = (vim.env.LC_ALL or vim.env.LC_MESSAGES or vim.env.LANG or ""):lower()
if requested == "zh" or requested == "en" then
  M.language = requested
else
  M.language = locale:match("^zh") and "zh" or "en"
end

function M.t(key)
  return messages[M.language][key] or messages.en[key] or key
end

return M
