## About
The current version of all plugins work well with no significant bugs that I've found, so I'll not update any plugin that
I've already installed, even if they come with flashy new features or whatever, they will stay the same unless I **REALLY**
need to update something. In fact updating _usually_ breaks everything at the moment, so no updates coming ever :)

**Versions**:
- Neovim 0.11.4
- OS: Windows / Linux

## Philosophy
Simplicity above all, meaning:
- Just a few plugins (31 total)
- Avoid modularizing and keep everything most in one place.
- Edit config as little as possible (ideally once per year once stable).
- Whenever I feel I need a plugin look for native alternatives, develop it myself or avoid temptation from the evil :)

## Setup
Download [nvim 0.11.4](https://github.com/neovim/neovim/releases/tag/v0.11.4) like this on linux: 
```bash
# if you already installed it through apt:
# sudo apt remove neovim

curl -LO https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz

tar xzvf nvim-linux-x86_64.tar.gz

sudo mv nvim-linux-x86_64 /opt/nvim

sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

nvim --version # should print 0.11.4
```

And clone this into `.config/`, like so:
```bash
git clone https://github.com/TomasBorquez/neovim-config ./nvim
```

**If** on Windows, install [Scoop](https://scoop.sh/) like so:
```ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser'
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression'
```

Install python3:
```bash
# Ubuntu
sudo apt install python3 

# Windows
scoop install python3
```

And run the setup file, `python3 setup.py` which will install all the necessary dependencies and languages I regularly use. 

Lastly depending on the platform you will have to set the shell you want to use on the builtin terminal, search for the plugin `akinsho/toggleterm.nvim`
and change the shell parameter or remove it to use the default one.

**WARNING**: This config also sets your timezone to Argentina/BuenosAires timezone.

And you should be done :D, if you do find any error please report it to me, this is supposed to be a single install and run perfectly
afterwards, so it would be ideal it breaks the least possible in every platform.

