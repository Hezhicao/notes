local api = vim.api
local fn = vim.fn
local keymap = vim.keymap

-- common things
local common = api.nvim_create_augroup("common", {})
-- Automatically relocate cursor position
api.nvim_create_autocmd("BufReadPost", {
  group = common,
  callback = function()
    local previous_pos = fn.line [['"]]
    if previous_pos >= 1 and previous_pos <= fn.line "$" and vim.bo.filetype ~= "commit" then
      vim.cmd 'normal! g`"'
    end
  end,
})
api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  group = common,
  command = "set cursorline",
})
api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
  group = common,
  command = "set nocursorline",
})
api.nvim_create_autocmd("CmdLineEnter", {
  group = common,
  pattern = ":",
  command = "set nosmartcase",
})
api.nvim_create_autocmd("CmdLineLeave", {
  group = common,
  pattern = ":",
  command = "set smartcase",
})
api.nvim_create_autocmd("VimResized", {
  group = common,
  command = ":wincmd =",
})
api.nvim_create_autocmd("TextYankPost", {
  group = common,
  callback = function()
    vim.highlight.on_yank { timeout = 300 }
  end,
})

-- lsp
local lsp_special = api.nvim_create_augroup("lsp_special", {})
api.nvim_create_autocmd("CursorHold", {
  group = lsp_special,
  callback = function()
    if not (vim.b.lsp_floating_preview and api.nvim_win_is_valid(vim.b.lsp_floating_preview)) then
      vim.diagnostic.open_float { scope = "cursor" }
    end
  end,
})

-- visual-multi
local restored_bs_map -- restore <BS> for autopairs
local visual_multi_speical = api.nvim_create_augroup("visual_multi_special", {})
api.nvim_create_autocmd("User", {
  group = visual_multi_speical,
  pattern = "visual_multi_start",
  callback = function()
    local bufnr = api.nvim_get_current_buf()
    keymap.set("n", "<C-j>", "<Plug>(VM-Add-Cursor-Down)", { buffer = bufnr })
    keymap.set("n", "<C-k>", "<Plug>(VM-Add-Cursor-Up)", { buffer = bufnr })
    keymap.set("n", "<C-l>", "<Plug>(VM-Single-Select-l)", { buffer = bufnr })
    keymap.set("n", "<C-h>", "<Plug>(VM-Single-Select-h)", { buffer = bufnr })
    vim.cmd "Searchlight!"
    local keymaps = api.nvim_buf_get_keymap(bufnr, "i")
    for _, existing_map in ipairs(keymaps) do
      if existing_map.lhs == "<BS>" then
        restored_bs_map = existing_map
      end
    end
    keymap.del("i", "<BS>", { buffer = bufnr })
  end,
})
api.nvim_create_autocmd("User", {
  group = visual_multi_speical,
  pattern = "visual_multi_exit",
  callback = function()
    local bufnr = api.nvim_get_current_buf()
    keymap.del("n", "<C-j>", { buffer = bufnr })
    keymap.del("n", "<C-k>", { buffer = bufnr })
    keymap.del("n", "<C-l>", { buffer = bufnr })
    keymap.del("n", "<C-h>", { buffer = bufnr })
    vim.cmd "Searchlight"
    keymap.set(restored_bs_map.mode, restored_bs_map.lhs, restored_bs_map.rhs or restored_bs_map.callback, {
      noremap = restored_bs_map.noremap == 1,
      silent = restored_bs_map.silent == 1,
      expr = restored_bs_map.expr == 1,
      buffer = restored_bs_map.buffer,
    })
  end,
})

-- other filetypes
local other_filetypes = api.nvim_create_augroup("other_filetypes", {})
api.nvim_create_autocmd("FileType", {
  group = other_filetypes,
  pattern = { "asm", "gitcommit", "NeogitPopup", "NeogitStatus" },
  command = "setlocal nolist",
})
api.nvim_create_autocmd("FileType", {
  group = other_filetypes,
  pattern = "qf",
  command = "setlocal nolist | setlocal nobuflisted",
})
api.nvim_create_autocmd("FileType", {
  group = other_filetypes,
  pattern = "NeogitCommitMessage",
  command = "setlocal nolist | startinsert",
})
api.nvim_create_autocmd("FileType", {
  group = other_filetypes,
  pattern = "asm",
  command = "setlocal filetype=gas",
})
api.nvim_create_autocmd("FileType", {
  group = other_filetypes,
  pattern = "rnvimr",
  callback = function()
    keymap.set("t", "<M-i>", "<cmd>RnvimrResize<cr>", { buffer = api.nvim_get_current_buf(), silent = true })
  end,
})
api.nvim_create_autocmd("FileType", {
  group = other_filetypes,
  pattern = "dap-repl",
  callback = function()
    require("dap.ext.autocompl").attach()
  end,
})

-- ros filetype detect
local ros_filetype_detect = api.nvim_create_augroup("ros_filetype_detect", {})
api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = ros_filetype_detect,
  pattern = "*.launch",
  command = "set filetype=roslaunch",
})
api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = ros_filetype_detect,
  pattern = "*.action",
  command = "set filetype=rosaction",
})
api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = ros_filetype_detect,
  pattern = "*.msg",
  command = "set filetype=rosmsg",
})
api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = ros_filetype_detect,
  pattern = "*.srv",
  command = "set filetype=rossrv",
})

-- defx file explorer, hijack netrw
local defx_file_explorer = api.nvim_create_augroup("defx_file_explorer", {})
api.nvim_create_autocmd("VimEnter", {
  group = defx_file_explorer,
  callback = function()
    api.nvim_del_augroup_by_name "FileExplorer"
    if fn.isdirectory(fn.expand "<amatch>") == 1 then
      vim.cmd [[
        bwipeout!
        execute "DefxIcon" expand('<amatch>')
      ]]
    end
  end,
  once = true,
})
api.nvim_create_autocmd("BufEnter", {
  group = defx_file_explorer,
  callback = function()
    local bufnr = tonumber(fn.expand "<abuf>")
    local path = fn.expand "<amatch>"
    if fn.bufnr(path) == bufnr and fn.isdirectory(path) == 1 and not vim.o.diff then
      vim.defer_fn(function()
        if not vim.o.diff and bufnr == api.nvim_get_current_buf() then
          vim.cmd "BufferWipeout!"
          vim.cmd("DefxIcon " .. path)
        end
      end, 0)
    end
  end,
})

-- Firenvim
local ui_special = api.nvim_create_augroup("ui_special", {})
api.nvim_create_autocmd("UIEnter", {
  group = ui_special,
  callback = function()
    local ui = api.nvim_get_chan_info(vim.v.event.chan)
    if ui.client and ui.client.name and ui.client.name == "Firenvim" then
      if vim.g.colors_name == "ayu" then
        vim.cmd "hi Normal guibg=#1F2430"
        vim.opt.guifont = "FiraCode Nerd Font Mono:h10"
        vim.opt.showtabline = 0
        vim.opt.laststatus = 0
        vim.cmd "hi Pmenu guibg=NONE"
        vim.cmd "hi PmenuSbar guibg=NONE"
        vim.cmd "hi PmenuThumb guibg=NONE"
        keymap.set("n", "<M-=>", "<cmd>silent! set lines+=5<cr>", { noremap = true })
        keymap.set("n", "<M-->", "<cmd>silent! set lines-=5<cr>", { noremap = true })
        keymap.set("n", "<M-,>", "<cmd>silent! set columns-=5<cr>", { noremap = true })
        keymap.set("n", "<M-.>", "<cmd>silent! set columns+=5<cr>", { noremap = true })
      end
    end
  end,
})