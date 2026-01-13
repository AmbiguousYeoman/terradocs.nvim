#!/usr/bin/env bash
# Test runner script for terradocs.nvim

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Dependency directories
PLENARY_DIR="${PLENARY_DIR:-/tmp/plenary.nvim}"
TREESITTER_DIR="${TREESITTER_DIR:-/tmp/nvim-treesitter}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Install dependencies
install_deps() {
    if [ ! -d "$PLENARY_DIR" ]; then
        info "Installing plenary.nvim..."
        git clone --depth 1 https://github.com/nvim-lua/plenary.nvim "$PLENARY_DIR"
    else
        info "plenary.nvim already installed"
    fi

    if [ ! -d "$TREESITTER_DIR" ]; then
        info "Installing nvim-treesitter..."
        git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter "$TREESITTER_DIR"
    else
        info "nvim-treesitter already installed"
    fi
}

# Run all tests
run_tests() {
    local test_path="${1:-tests}"

    info "Running tests in: $test_path"

    cd "$PROJECT_ROOT"

    if [ -f "$test_path" ]; then
        # Single file
        nvim --headless -u tests/minimal_init.lua \
            -c "PlenaryBustedFile $test_path"
    else
        # Directory - use lua to call test_harness for better control
        nvim --headless -u tests/minimal_init.lua \
            -c "lua require('plenary.test_harness').test_directory('$test_path', {minimal_init='tests/minimal_init.lua', sequential=true})"
    fi
}

# Show usage
usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  all          Run all tests (default)"
    echo "  init         Run init.lua tests"
    echo "  ts_helper    Run ts_helper.lua tests"
    echo "  file <path>  Run tests in specific file"
    echo "  deps         Install dependencies only"
    echo "  help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run all tests"
    echo "  $0 init               # Run init.lua tests"
    echo "  $0 file tests/terradocs/init_spec.lua"
}

# Main
main() {
    local command="${1:-all}"

    case "$command" in
        all)
            install_deps
            run_tests "tests"
            ;;
        init)
            install_deps
            run_tests "tests/terradocs/init_spec.lua"
            ;;
        ts_helper|ts-helper)
            install_deps
            run_tests "tests/terradocs/ts_helper_spec.lua"
            ;;
        file)
            if [ -z "$2" ]; then
                error "No file specified"
                usage
                exit 1
            fi
            install_deps
            run_tests "$2"
            ;;
        deps)
            install_deps
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            error "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
