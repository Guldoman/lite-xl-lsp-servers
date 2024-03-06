-- mod-version:3

local lsp = require "plugins.lsp"
local common = require "core.common"
local config = require "core.config"

local installed_path = USERDIR .. PATHSEP .. "plugins" .. PATHSEP .. "lsp_nim" .. PATHSEP .. "nimlangserver"

lsp.add_server(common.merge({
  name = "nim-langserver",
  language = "Nim",
  file_patterns = { "%.nim$" },
  command = { installed_path },
  verbose = false
}, config.plugins.lsp_nim or {}))
