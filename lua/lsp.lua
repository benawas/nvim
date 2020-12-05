-- Load module
local vimp = require('vimp')
local lsp_status = require('lsp-status')
local completion = require('completion')
local lspconfig = require('lspconfig')
local configs = require('lspconfig/configs')
local util = require('lspconfig/util')

-- Completion setting
vim.o.completeopt = 'menuone,noinsert,noselect'
vim.g.completion_enable_auto_paren = 1
vim.g.completion_enable_snippet = 'UltiSnips'
vim.g.completion_customize_lsp_label = {
    Function = '',
    Method = '',
    Reference = '',
    Keyword = '',
    Variable = '',
    Folder = '',
    Snippet = '',
    UltiSnips = '',
    Operator = '',
    Module = '',
    Text = '',
    Class = '',
    Interface = '',
}
vim.g.completion_chain_complete_list = {
    default = {
		default = {
			{complete_items = {'lsp', 'snippet'}},
			{mode = 'file'}
        },
		comment = {},
		string = {}
	},
    python = {
		{ complete_items = {'lsp', 'snippet', 'ts'}}
    }
}
-- Use completion-nvim in every buffer
vim.cmd("autocmd BufEnter * lua require'completion'.on_attach()")
vim.cmd([[imap <expr> <CR> pumvisible() ? complete_info()["selected"] != "-1" ? "\<Plug>(completion_confirm_completion)" : "\<C-e>\<CR>" : "\<CR>"]])

-- Avoid showing message extra message when using completion
vim.o.shortmess = vim.o.shortmess..'c'

-- Diagnostic setting
vim.g.diagnostic_enable_virtual_text = 1
vim.g.diagnostic_insert_delay = 1
vim.g.diagnostic_show_sign = 1

function _G.diagnostic_or_doc()
    if not vim.tbl_isempty(vim.lsp.buf_get_clients()) then
        if not vim.tbl_isempty(vim.lsp.diagnostic.get_line_diagnostics()) then
            vim.lsp.diagnostic.show_line_diagnostics()
            return
        else
            vim.wait(1000, vim.lsp.buf.hover())
            return
        end
    end
end

-- Show diagnostic popup on cursor hold
vim.g.cursorhold_updatetime = 1000
vim.cmd('autocmd CursorHold * silent! lua diagnostic_or_doc()')
vim.cmd(
    [===[
    function! LspStatus() abort
        if luaeval('#vim.lsp.buf_get_clients() > 0')
            return luaeval("require('lsp-status').status()")
        endif
        return ''
    endfunction
    " Enable type inlay hints
    autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
        \ lua require'lsp_extensions'.inlay_hints{
            \ prefix = '>> ',
            \ highlight = "Comment",
            \ aligned = true,
            \ only_current_line = false
        \}
    ]===]
)

--  RishabhRD/nvim-lsputils theme
local border_chars = {
	TOP_LEFT = '┌',
	TOP_RIGHT = '┐',
	MID_HORIZONTAL = '─',
	MID_VERTICAL = '│',
	BOTTOM_LEFT = '└',
	BOTTOM_RIGHT = '┘',
}
vim.g.lsp_utils_location_opts = {
	height = 24,
	mode = 'editor',
	preview = {
		title = 'Location Preview',
		border = true,
		border_chars = border_chars
	},
	keymaps = {
		n = {
			['<C-n>'] = 'j',
			['<C-p>'] = 'k',
		}
	}
}
vim.g.lsp_utils_symbols_opts = {
	height = 24,
	mode = 'editor',
	preview = {
		title = 'Symbols Preview',
		border = true,
		border_chars = border_chars
	},
	keymaps = {
		n = {
			['<C-n>'] = 'j',
			['<C-p>'] = 'k',
		}
	}
}

vim.lsp.callbacks['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
vim.lsp.callbacks['textDocument/references'] = require'lsputil.locations'.references_handler
vim.lsp.callbacks['textDocument/definition'] = require'lsputil.locations'.definition_handler
vim.lsp.callbacks['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
vim.lsp.callbacks['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
vim.lsp.callbacks['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
vim.lsp.callbacks['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
vim.lsp.callbacks['workspace/symbol'] = require'lsputil.symbols'.workspace_handler

-- Lsp feature attach
local on_attach = function(client, bufnr)
  	lsp_status.on_attach(client, bufnr)
    completion.on_attach(client, bufnr)
    vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

lsp_status.register_progress()
lsp_status.config({
    status_symbol = '',
    indicator_errors = 'E',
    indicator_warnings = 'W',
    indicator_info = 'I',
    indicator_hint = 'H',
    indicator_ok = '',
    spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
})

-- Lsp Integration
lspconfig.clangd.setup{
    on_attach = on_attach,
    capabilities = lsp_status.capabilities,
    handlers = lsp_status.extensions.clangd.setup(),
}

lspconfig.cmake.setup{
    on_attach = on_attach,
    capabilities = lsp_status.capabilities,
}

lspconfig.gopls.setup {
    cmd = {'gopls', 'serve'},
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
    on_attach = on_attach,
    capabilities = lsp_status.capabilities
}

lspconfig.pyright.setup {
    on_attach = on_attach,
    capabilities = lsp_status.capabilities
}

lspconfig.rust_analyzer.setup {
    on_attach = on_attach,
    capabilities = lsp_status.capabilities
}

lspconfig.vimls.setup{
    on_attach = on_attach,
    capabilities = lsp_status.capabilities,
}
