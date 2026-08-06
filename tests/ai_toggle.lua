local source = debug.getinfo(1, "S").source:sub(2)
local root = vim.fn.fnamemodify(source, ":p:h:h")
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path

local terminal = {
  open = false,
  focus_count = 0,
  toggle_count = 0,
}

function terminal:toggle()
  self.open = not self.open
  self.toggle_count = self.toggle_count + 1
end

function terminal:is_open()
  return self.open
end

function terminal:focus()
  self.focus_count = self.focus_count + 1
end

local state = { session = {}, terminal = terminal }
package.loaded["sidekick.cli.session"] = {
  setup = function() end,
}
package.loaded["sidekick.cli.state"] = {
  get = function()
    return { state }
  end,
  attach = function(current, opts)
    if opts and opts.show then
      terminal.open = true
      if opts.focus then
        terminal:focus()
      end
    end
    return current, false
  end,
}

local spec = dofile(root .. "/lua/plugins/ai.lua")
local sidekick = spec[1]
local toggle
for _, key in ipairs(sidekick.keys) do
  if key[1] == "<leader>aa" then
    toggle = key[2]
    break
  end
end

assert(toggle, "missing <leader>aa mapping")
assert(sidekick.opts.cli.tools.codex.native_scroll, "Codex must use native terminal scrolling")

toggle()
assert(terminal.open, "first toggle should reopen a hidden Codex terminal")
assert(terminal.toggle_count == 1, "reopening should toggle exactly once")
assert(terminal.focus_count == 1, "reopened Codex terminal should receive focus")

toggle()
assert(not terminal.open, "second toggle should hide an open Codex terminal")
assert(terminal.toggle_count == 2, "hiding should toggle exactly once")
assert(terminal.focus_count == 1, "hidden Codex terminal must not receive focus")

print("ai toggle: ok")
