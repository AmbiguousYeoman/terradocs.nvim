# CLAUDE.md - AI Assistant Guidelines for terradocs.nvim

## Project Overview

**terradocs.nvim** is a Neovim plugin that provides quick access to Terraform documentation for resources and data sources. Users can position their cursor on a Terraform resource or data source declaration and instantly view documentation in a floating window, fetched directly from GitHub API.

- **Language**: Lua (pure implementation, no external Lua dependencies)
- **License**: MIT
- **Author**: AmbiguousYeoman

## Codebase Structure

```
terradocs.nvim/
├── LICENSE                          # MIT License
├── README.md                        # User-facing documentation
├── CLAUDE.md                        # This file - AI assistant guidelines
└── lua/
    └── terradocs/
        ├── init.lua                 # Main plugin module (~200 lines)
        └── ts_helper.lua            # Tree-sitter helper utilities (~54 lines)
```

### Key Files

#### `lua/terradocs/init.lua`
The main plugin module containing:
- `M.config` - Configuration table with default keymap (`<leader>t`)
- `M.setup()` - Plugin initialization, creates `:TFSearch` command and keymapping
- `preview_markdown(content, search_url)` - Creates floating window to display documentation
- `check_provider(provider)` - Validates provider names against supported HashiCorp/Oracle providers
- `generate_search_urls(provider_org, provider_name, declaration)` - Constructs Terraform Registry and GitHub API URLs
- `terraform_search(declaration, resource_type)` - Core search logic that fetches and displays documentation

#### `lua/terradocs/ts_helper.lua`
Tree-sitter integration module:
- `M.get_resource_info()` - Uses Tree-sitter to parse HCL syntax and extract resource/data block information at cursor position

## Supported Providers

The plugin supports 34+ Terraform providers:

**HashiCorp providers**: ad, archive, aws, awscc, azuread, azurerm, azurestack, boundary, cloudinit, consul, dns, external, google, google-beta, googleworkspace, kubernetes, hcp, hcs, helm, http, local, nomad, null, random, salesforce, tfe, time, tls, vault, vsphere

**Oracle providers**: oci

## Development Conventions

### Lua Module Pattern
- Standard Lua module pattern: `local M = {}` with `return M`
- Private functions are local (not exposed on M table)
- Only `M.setup()` is the public API entry point
- Helper modules are separate and imported via `require()`

### Neovim API Usage
- Use `vim.api.nvim_*` for buffer/window/keymap operations
- Use `vim.fn.*` for Vimscript functions (system calls, file operations)
- Use `vim.treesitter` for syntax parsing
- Use `vim.o.*` for editor options

### Error Handling
- Check `vim.v.shell_error` after shell commands
- Use `pcall()` for operations that may fail (JSON decoding)
- Provide user-friendly error messages via `print()`
- Validate inputs before proceeding with operations

### Shell Commands
- Use `curl -s` for HTTP requests (silent mode)
- Use `vim.fn.shellescape()` for safe shell argument handling
- Use `base64 --decode` for decoding GitHub API responses
- Use `open` command for browser integration (currently macOS-specific)

## External Dependencies

### Runtime Requirements
- **Neovim** with Tree-sitter support
- **HCL Tree-sitter grammar** installed (for Terraform file parsing)
- **curl** - for HTTP requests to GitHub API
- **base64** - for decoding responses (usually pre-installed)
- **open** command - for browser integration (macOS; Linux may need `xdg-open`)

### No Build Dependencies
- Pure Lua implementation
- No external Lua libraries required
- Installed via Neovim plugin managers (Packer, vim-plug, lazy.nvim)

## How It Works

1. User places cursor on a `resource` or `data` block line in a Terraform file
2. User triggers `:TFSearch` command (or `<leader>t` keybinding)
3. Tree-sitter parses the HCL syntax to extract block type and resource name
4. Provider is extracted from resource name (e.g., `aws` from `aws_instance`)
5. Provider is validated against the supported providers list
6. GitHub API URL is constructed to fetch documentation markdown
7. Documentation is fetched via curl, decoded from base64
8. Content is displayed in a centered floating window
9. User can press `Enter` to open full docs in browser, or `Esc` to close

## Known Limitations

- `open` command is macOS-specific (needs `xdg-open` for Linux, different approach for Windows)
- No test coverage currently exists
- Only supports resources and data sources (modules not yet implemented)
- Relies on GitHub API (may have rate limiting)
- No custom configuration options beyond default keymap

## Working with This Codebase

### Adding New Providers
1. Edit `lua/terradocs/init.lua`
2. Add provider name to `hashicorp_providers` or `oracle_providers` table in `check_provider()`
3. For non-HashiCorp/Oracle providers, may need to add new organization handling in `check_provider()` and `generate_search_urls()`

### Modifying the Floating Window
- Edit `preview_markdown()` function in `init.lua`
- Window dimensions calculated from `vim.o.columns` and `vim.o.lines`
- Keymaps set on the buffer: `Esc` closes, `Enter` opens browser

### Changing Tree-sitter Query
- Edit `ts_helper.lua`
- Query targets HCL `block` nodes with `resource|data` identifier
- Captures the first `template_literal` (resource type name)

## Testing Changes

Currently no automated tests exist. Manual testing workflow:
1. Open a Terraform file in Neovim
2. Position cursor on a resource or data block
3. Run `:TFSearch` or press `<leader>t`
4. Verify floating window appears with correct documentation
5. Test `Esc` to close and `Enter` to open browser

## Commands and Keybindings

| Command/Key | Action |
|-------------|--------|
| `:TFSearch` | Search documentation for resource/data at cursor |
| `<leader>t` | Default keybinding for `:TFSearch` |
| `Esc` | Close floating documentation window |
| `Enter` | Open documentation in browser (from floating window) |
