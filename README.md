# dotfiles

Personal dotfiles, installed by symlinking everything from this repo into place.
The repo stays the single source of truth, so edits here take effect immediately.

## Install

With no arguments this runs every step:

```sh
./install.sh
```
Existing real files are backed up to `<file>.bak.<timestamp>` before being replaced; existing symlinks are replaced in place. The script is idempotent — safe to re-run.

Pass one or more flags to run only those steps:

```sh
./install.sh --skills            # just relink skills
```

| Flag | Step |
| --- | --- |
| `--dotfiles` | Symlink home dotfiles |
| `--skills` | Symlink skills into `~/.cursor` and `~/.claude` |
| `--ask` | Symlink `ask.py` into `~/.local/bin` |
| `--tools` | Install `vim` and `uv` |
| `-h`, `--help` | Show usage and exit |

After installing, restart your shell or run `source ~/.bashrc`.
