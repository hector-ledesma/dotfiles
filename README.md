# Work Environment Dotfiles 

This repository serves the purpose of centralizing all of my personal configuration files, and as a living document of my changes in philosophy and tooling.

## Current State

- "Hacky" first version. Put together following multiple videos, plugin documentations, and general intuition.
- Uses `packer.nvim` for Neovim package management.
- Includes basic aliases.
- Equipped with code analysis, parsing, autocompletion, and debugging tools for working with C++ and Python. (can't beat IntelliJ for Java)

## Roadmap
- Deep dive into Lua modules and their integration into Neovim.
- Evaluate package managers(e.g., `lazyvim`) for potential migration. Deep dive into package configuration based on package manager I decide on.
- Refactor (and migrate if changing from `packer.nvim`) Neovim configuration structure for better modularity and readability.
- Document all tools needed for the full work environment (e.g., `tmux`, `eza`, `zoxide`, etc)
- Put together a shell script to install all the tools, and set up all the configuration files.
- Write a script that allows me to quickly switch themes. It needs to adjust configuration for `zsh`, `nvim`, `tmux`, `starship` (for WSL) and `alacritty` (for Windows).
