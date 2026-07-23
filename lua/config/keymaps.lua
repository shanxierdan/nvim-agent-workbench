-- Small additions to LazyVim's defaults.
local map = vim.keymap.set

map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>qa", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>uw", "<cmd>set wrap!<cr>", { desc = "Toggle line wrap" })

-- Keep a visual selection after indenting it.
map("v", "<", "<gv")
map("v", ">", ">gv")
