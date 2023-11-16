# terradocs

Lua plugin for quickly opening terraform documentation for resources and data sources.

## Getting Started

Currently this only works for resources and data sources. Some functionality for modules to come later.

You do not need terraform installed to use this, it is only fetching webpage data from github and the terraform registry.

### Installation

Install using a package manager.

With [Packer](https://github.com/wbthomason/packer.nvim): `use 'AmbiguousYeoman/terradocs.nvim'`

With [vim-plug](https://github.com/junegunn/vim-plug): Plug `'AmbiguousYeoman/terradocs.nvim'`

With [lazy.nvim](https://github.com/folke/lazy.nvim), create the file `~/.config/nvim/lua/plugins/terradocs.lua`:

```lua
return {
  "AmbiguousYeoman/terradocs.nvim",
  config = function ()
    require('terradocs').setup {}
  end
}
```

## Usage

When your cursor is on a line with a resource or data source call the command `:TFSearch`

By default there is a mapping for `<leader>t`

It will first open a floating window with markdown, if you wish to read the documentation in your browser press Enter when on the floating window.
