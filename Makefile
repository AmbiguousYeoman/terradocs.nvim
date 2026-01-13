.PHONY: test test-file lint clean deps

# Directories
PLENARY_DIR ?= /tmp/plenary.nvim
TREESITTER_DIR ?= /tmp/nvim-treesitter
TESTS_DIR := tests/terradocs

# Test runner - using PlenaryBustedDirectory
test: deps
	@echo "Running all tests..."
	@nvim \
		--headless \
		--noplugin \
		-u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests/terradocs { sequential = true, minimal_init = 'tests/minimal_init.lua' }"

# Run a specific test file
# Usage: make test-file FILE=tests/terradocs/init_spec.lua
test-file: deps
	@echo "Running tests in $(FILE)..."
	@nvim --headless --noplugin -u tests/minimal_init.lua \
		-c "PlenaryBustedFile $(FILE)"

# Run only init tests
test-init: deps
	@echo "Running init.lua tests..."
	@nvim --headless --noplugin -u tests/minimal_init.lua \
		-c "PlenaryBustedFile tests/terradocs/init_spec.lua"

# Run only ts_helper tests
test-ts-helper: deps
	@echo "Running ts_helper.lua tests..."
	@nvim --headless --noplugin -u tests/minimal_init.lua \
		-c "PlenaryBustedFile tests/terradocs/ts_helper_spec.lua"

# Install test dependencies
deps:
	@echo "Checking dependencies..."
	@if [ ! -d "$(PLENARY_DIR)" ]; then \
		echo "Installing plenary.nvim..."; \
		git clone --depth 1 https://github.com/nvim-lua/plenary.nvim $(PLENARY_DIR); \
	fi
	@if [ ! -d "$(TREESITTER_DIR)" ]; then \
		echo "Installing nvim-treesitter..."; \
		git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter $(TREESITTER_DIR); \
	fi

# Install HCL parser for tree-sitter tests
install-hcl-parser: deps
	@echo "Installing HCL tree-sitter parser..."
	nvim --headless -u tests/minimal_init.lua \
		-c "TSInstallSync hcl" -c "qa"

# Clean up test dependencies
clean:
	@echo "Cleaning up..."
	rm -rf $(PLENARY_DIR)
	rm -rf $(TREESITTER_DIR)

# Lint with luacheck (if available)
lint:
	@echo "Linting..."
	@command -v luacheck > /dev/null 2>&1 && luacheck lua/ tests/ --no-unused-args --no-max-line-length || echo "luacheck not installed, skipping lint"

# Format with stylua (if available)
format:
	@echo "Formatting..."
	@command -v stylua > /dev/null 2>&1 && stylua lua/ tests/ || echo "stylua not installed, skipping format"

# Check formatting
format-check:
	@echo "Checking formatting..."
	@command -v stylua > /dev/null 2>&1 && stylua --check lua/ tests/ || echo "stylua not installed, skipping format check"

# Help
help:
	@echo "Available targets:"
	@echo "  test           - Run all tests"
	@echo "  test-file      - Run a specific test file (FILE=path/to/spec.lua)"
	@echo "  test-init      - Run init.lua tests only"
	@echo "  test-ts-helper - Run ts_helper.lua tests only"
	@echo "  deps           - Install test dependencies"
	@echo "  install-hcl-parser - Install HCL tree-sitter parser"
	@echo "  clean          - Remove test dependencies"
	@echo "  lint           - Run luacheck"
	@echo "  format         - Format code with stylua"
	@echo "  format-check   - Check code formatting"
	@echo "  help           - Show this help"
