## About
The Philosophy is "simplicity above everything", meaning:
- Just a few plugins (29 total)
- If I need a new functionality, first look for a native option else develop it and if its too hard
  to develop then install a plugin.
- Avoid modularizing too much.
- Edit config as little as possible (usually once per month at the moment)

**Versions**:
- Neovide 0.16.0
- Neovim 0.12.0
- OS: Windows / Linux

I don't plan on updating plugins/nvim, in fact most are set on a specific commit and won't be
updated unless necessary.

## Setup
I'm on [neovide 0.16.0](https://github.com/neovide/neovide/releases#release-0.16.0), though you can
use any terminal emulator of your liking.

You can download [nvim 0.12.0](https://github.com/neovim/neovim/releases/tag/v0.12.0) manually
but the python script should do this for you already, so just install python:
```bash
# Linux Ubuntu
sudo apt update
sudo apt install python3

# Windows Powershell (admin)
#  1 - install scoop
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser'
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression'

#  2 - install python
scoop install python3
```

Then clone the repo into your `.config/`, like so:
```bash
git clone https://github.com/TomasBorquez/neovim-config ~/.config/nvim
```

And run the setup file, `python3 setup.py` which will install all the necessary dependencies and
languages I regularly use.

Lastly depending on your machine you will have to edit some paths for terminals/programs, they all
live on the `Paths` table at the top of `init.lua`, that includes the `:Learn`/`:Ideas`/`:Config`
style shortcuts on `Paths.commands` (a trailing `/` opens the directory on oil, otherwise the file
gets opened on a buffer).

**WARNING**: This config also sets your timezone to `Argentina/BuenosAires` in the python script.

And you should be done :D, if you do find any errors/bugs please report them to me, this is
supposed to be a single install and run perfectly afterwards, so it would be ideal it breaks the
least possible in every platform.
