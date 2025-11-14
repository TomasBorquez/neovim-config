## About
The current version of all plugins work well with no significant bugs that I've found, so I'll not update any plugin that
I've already installed, even if they come with flashy new features or whatever, they will stay the same unless I **REALLY**
need to update something. In fact updating _usually_ breaks everything at the moment, so no updates coming ever :)

**Versions**:
- Neovim 0.11.4
- OS: Windows 11 / Linux

## Philosophy
Simplicity above all, meaning:
- Just a few plugins (31 total)
- Avoid modularizing and keep everything most in one place.
- Edit config as little as possible (ideally once per year once stable).
- Whenever I feel I need a plugin look for native alternatives, develop it myself or avoid temptation from the evil :)

## Setup
Download [nvim 0.11.4](https://github.com/neovim/neovim/releases/tag/v0.11.4) ofc, and clone this into `.config/`, like so:
```bash
git clone https://github.com/TomasBorquez/neovim-config ./nvim
```

Run this command `python3 setup.py` (install any python version beforehand) which will install all the necessary dependencies and languages I regularly use. 
**WARNING**: If you are in windows you'll need [Scoop](https://scoop.sh/) installed.

And you should be done :D, if you do find any error please report it to me, this is supposed to be a single install and run perfectly
afterwards, so it would be ideal it breaks the least possible in every platform.

