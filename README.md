# Philosophy

Simplicity above all, meaning:
    - Just a few plugins
    - Avoid modularizing and keep everything in one place
    - Edit config as little as possible
    - Whenever I feel I need a plugin look for native alternatives, develop it myself or avoid temptation from the evil :)

The current version of my editor works very well with very little/no bugs, so I'll not update the plugins that
I've already installed, even if they come with flashy new features or whatever, they will stay the same unless I REALLY
need to update something. 

**Versions**:
- Neovim 0.10
- Neovide 0.14.1
- Windows 11

## TODOS
- [x] Create a commands file
- [x] Get different color each month for cowsay
- [x] Get random quote each day for cow say
- [x] Center cow and quotes
- [x] Unbind oil.nvim keybinds
- [x] Paste in terminal
- [x] Find how to get in vim mode in terminal and how to get out of it
- [x] Source current file so I don't have to restart
- [x] Find out why is it pasting by default and making it all a comment
- [x] Format on save
- [x] Learn to use <C-v>
- [x] Add VimSurround 
- [x] Learn VimSurround
- [x] Remove wrap
- [x] Learn TeleScope
- [x] Fix terminal opening on different places
- [x] Learn Tutor
- [x] Show diagnostic errors faster (maybe on char change instead of file save)
- [x] Better clang formatting
- [x] Learn how to uppercase/lowercase
- [x] Learn macros/recording
- [x] Read advanced cheat sheet
- [x] Shortcut to close all nvim buffers expect current one
- [x] Change eventually to <C-p> and <C-n> for suggestions 
- [x] Move TeleScope shortcut, also learn how to close it
- [x] Add `telescope-fzf-native.nvim`
- [x] Fix the insert after comment thing that makes it annoying to type
- [x] Figure out why copy lags out
- [x] Fix Clangd not working on .h files
- [ ] Make terminal *cwd* equal to what `oil.nvim` has as *cwd*
- [ ] Watch you can do *almost* everything without plugins
- [ ] Get better with substitute

## Motions Notes
- [x] `<C-o>` For previous place where the cursor was at 
- [x] `<C-i>` For next place where the cursor was at
- [x] `<C-v>$A` For appending at the end
- [x] `<C-v>I` For inserting at the start
- [x] `vw}` For adding `{}`
- [x] `cs{[` For changing from `{}` to `[]`
- [x] `gu` To lowercase
- [x] `gU` To uppercase
- [x] `~` To invert casing
- [x] `<C-a>` To increment
- [x] `<C-v> g <C-a>` To increment
- [ ] `gx` Open URL on browser
- [ ] `gf` Open buffer on location 
- [x] `:s/old/new/g` For replacing all instances of a text
- [ ] `:s/\(.*\) \1` WTF?
- [x] `:set spell!` Toggle spellcheck
- [ ] `z=` Spell suggestions
- [ ] `1z=` First spell suggestion
- [ ] `zg` Marks word as good
- [ ] `zb` Marks word as bad
- [x] `*` Search for word under the cursor
- [x] `qa` To start recording `q` to stop, and `@@` to execute last macro
- [ ] `q:` Open command line history
- [ ] `q/` Open search history
- [ ] Add command copy to a register guide
- [ ] `<C-d>` to quit gdb
