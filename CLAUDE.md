# CLAUDE.md - AI Assistant Guidelines for terradocs.nvim

## Project Overview

**terradocs.nvim** is a Neovim plugin that provides quick access to Terraform documentation for resources and data sources. Users can position their cursor on a Terraform resource or data source declaration and instantly view documentation in a floating window, fetched directly from GitHub API.

- **Language**: Lua (pure implementation, no external Lua dependencies)
- **License**: MIT
- **Author**: AmbiguousYeoman

## Codebase Structure

```
terradocs.nvim/
├── .github/
│   └── workflows/
│       └── ci.yml                   # GitHub Actions CI configuration
├── lua/
│   └── terradocs/
│       ├── init.lua                 # Main plugin module (~210 lines)
│       └── ts_helper.lua            # Tree-sitter helper utilities (~54 lines)
├── scripts/
│   └── test.sh                      # Test runner script
├── tests/
│   ├── minimal_init.lua             # Minimal Neovim config for tests
│   └── terradocs/
│       ├── init_spec.lua            # Tests for init.lua (~400 lines)
│       └── ts_helper_spec.lua       # Tests for ts_helper.lua (~300 lines)
├── .gitignore                       # Git ignore patterns
├── .luacheckrc                      # Luacheck configuration
├── CLAUDE.md                        # This file - AI assistant guidelines
├── LICENSE                          # MIT License
├── Makefile                         # Build/test commands
├── README.md                        # User-facing documentation
└── stylua.toml                      # Code formatter configuration
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

**Testing exports** (prefixed with `_`):
- `M._check_provider` - Exposed for unit testing
- `M._generate_search_urls` - Exposed for unit testing
- `M._terraform_search` - Exposed for unit testing
- `M._preview_markdown` - Exposed for unit testing
- `M._hashicorp_providers` - Provider list for testing
- `M._oracle_providers` - Provider list for testing

#### `lua/terradocs/ts_helper.lua`
Tree-sitter integration module:
- `M.get_resource_info()` - Uses Tree-sitter to parse HCL syntax and extract resource/data block information at cursor position

## Supported Providers

The plugin supports 31 Terraform providers:

**HashiCorp providers** (30): ad, archive, aws, awscc, azuread, azurerm, azurestack, boundary, cloudinit, consul, dns, external, google, google-beta, googleworkspace, kubernetes, hcp, hcs, helm, http, local, nomad, null, random, salesforce, tfe, time, tls, vault, vsphere

**Oracle providers** (1): oci

## Development Conventions

### Lua Module Pattern
- Standard Lua module pattern: `local M = {}` with `return M`
- Private functions are local (not exposed on M table)
- Only `M.setup()` is the public API entry point
- Internal functions are exposed with `_` prefix for testing (e.g., `M._check_provider`)
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

## Testing

### Test Framework
Tests use [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) with busted-style syntax.

### Running Tests

```bash
# Run all tests
make test

# Run specific test file
make test-file FILE=tests/terradocs/init_spec.lua

# Run init.lua tests only
make test-init

# Run ts_helper.lua tests only
make test-ts-helper

# Using the test script
./scripts/test.sh              # Run all tests
./scripts/test.sh init         # Run init.lua tests
./scripts/test.sh ts_helper    # Run ts_helper.lua tests
./scripts/test.sh file <path>  # Run specific file
```

### Test Structure

#### `tests/terradocs/init_spec.lua`
Comprehensive tests for the main module:
- **Config tests**: Verify default configuration values
- **Provider list tests**: Ensure all providers are present
- **`_check_provider` tests**:
  - HashiCorp providers return `"hashicorp"`
  - Oracle providers return `"oracle"`
  - Unknown providers return `nil`
  - Edge cases (case sensitivity, whitespace)
- **`_generate_search_urls` tests**:
  - Resource URL generation for all provider orgs
  - Data source URL generation
  - Invalid declaration handling
  - URL structure verification (trailing slashes, repo names)
- **Setup tests**: Command and keymap creation
- **Provider extraction tests**: Pattern matching for resource names
- **URL construction integration tests**: Full URL building for real resources

#### `tests/terradocs/ts_helper_spec.lua`
Tree-sitter integration tests (require HCL parser):
- **Resource block extraction**: Various providers (aws, google, azurerm, oci)
- **Data source extraction**: aws_ami, google_compute_image, etc.
- **Multiple blocks**: Correct block identification with cursor position
- **Edge cases**: Non-resource blocks (variable, provider, terraform, locals, output)
- **Complex resource names**: Multi-underscore names, kubernetes, oci

### Writing Tests

```lua
describe("feature", function()
    it("does something", function()
        assert.equals("expected", actual)
        assert.is_true(condition)
        assert.is_nil(value)
    end)
end)
```

For tests requiring HCL parser:
```lua
before_each(function()
    if not has_hcl_parser() then
        pending("HCL tree-sitter parser not available")
    end
end)
```

### CI/CD
GitHub Actions runs on push/PR to main:
- Tests on Neovim stable and nightly
- Luacheck linting
- Stylua formatting check

## External Dependencies

### Runtime Requirements
- **Neovim** with Tree-sitter support
- **HCL Tree-sitter grammar** installed (for Terraform file parsing)
- **curl** - for HTTP requests to GitHub API
- **base64** - for decoding responses (usually pre-installed)
- **open** command - for browser integration (macOS; Linux may need `xdg-open`)

### Development Dependencies
- **plenary.nvim** - Test framework (installed automatically by test runner)
- **nvim-treesitter** - For tree-sitter tests (installed automatically)
- **luacheck** (optional) - Linting
- **stylua** (optional) - Code formatting

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
- Only supports resources and data sources (modules not yet implemented)
- Relies on GitHub API (may have rate limiting)
- No custom configuration options beyond default keymap
- Tree-sitter tests require HCL parser to be installed

## Working with This Codebase

### Adding New Providers
1. Edit `lua/terradocs/init.lua`
2. Add provider name to `hashicorp_providers` or `oracle_providers` table
3. For non-HashiCorp/Oracle providers, add new organization handling in `check_provider()` and `generate_search_urls()`
4. Add tests in `tests/terradocs/init_spec.lua`

### Modifying the Floating Window
- Edit `preview_markdown()` function in `init.lua`
- Window dimensions calculated from `vim.o.columns` and `vim.o.lines`
- Keymaps set on the buffer: `Esc` closes, `Enter` opens browser

### Changing Tree-sitter Query
- Edit `ts_helper.lua`
- Query targets HCL `block` nodes with `resource|data` identifier
- Captures the first `template_literal` (resource type name)
- Update tests in `tests/terradocs/ts_helper_spec.lua`

## Commands and Keybindings

| Command/Key | Action |
|-------------|--------|
| `:TFSearch` | Search documentation for resource/data at cursor |
| `<leader>t` | Default keybinding for `:TFSearch` |
| `Esc` | Close floating documentation window |
| `Enter` | Open documentation in browser (from floating window) |

## Development Commands

| Command | Description |
|---------|-------------|
| `make test` | Run all tests |
| `make test-init` | Run init.lua tests |
| `make test-ts-helper` | Run ts_helper.lua tests |
| `make lint` | Run luacheck |
| `make format` | Format code with stylua |
| `make format-check` | Check code formatting |
| `make deps` | Install test dependencies |
| `make clean` | Remove test dependencies |
