#!/usr/bin/env bash
#
# Install dotfiles by symlinking everything from this repo into place.
# The repo stays the single source of truth; edits here take effect immediately.
#
# With no arguments, every step runs. Pass one or more flags to run only those:
#   --dotfiles  Symlink home dotfiles (.bashrc, .vimrc, .gitconfig, .inputrc, .profile)
#   --skills    Symlink skills/ into ~/.cursor/skills and ~/.claude/skills
#   --ask       Symlink ask.py into ~/.local/bin
#   --tools     Install vim and uv if missing
#   -h, --help  Show this help and exit
#
set -euo pipefail

# Resolve this repo's directory (no hardcoded paths).
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# link SRC DST: back up an existing real file/dir to DST.bak.<ts>, replace an
# existing symlink, then symlink SRC -> DST. Idempotent and non-destructive.
link() {
    local src="$1" dst="$2"
    if [ -L "$dst" ]; then
        rm -f "$dst"
    elif [ -e "$dst" ]; then
        local backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
        echo "  backing up existing $dst -> $backup"
        mv "$dst" "$backup"
    fi
    ln -s "$src" "$dst"
    echo "  linked $dst -> $src"
}

# link_skills DST: build a flat symlink farm at DST — one symlink per skill,
# dropping the category level (skills/<cat>/<name> becomes DST/<name> -> ...).
# A skill is any directory containing a SKILL.md, at any nesting depth.
link_skills() {
    local dst="$1"
    # Replace an existing target. A plain symlink or a farm of only symlinks
    # (what we create) is safe to drop; anything else is backed up first.
    if [ -L "$dst" ]; then
        rm -f "$dst"
    elif [ -d "$dst" ] && ! find "$dst" -mindepth 1 -maxdepth 1 -not -type l | grep -q .; then
        rm -rf "$dst"
    elif [ -e "$dst" ]; then
        local backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
        echo "  backing up existing $dst -> $backup"
        mv "$dst" "$backup"
    fi
    mkdir -p "$dst"

    local skill name
    while IFS= read -r skill; do
        name="$(basename "$skill")"
        if [ -e "$dst/$name" ]; then
            echo "  WARNING: duplicate skill name '$name' — skipping $skill" >&2
            continue
        fi
        ln -s "$skill" "$dst/$name"
    done < <(find "$DOTFILES/skills" -iname SKILL.md -printf '%h\n' | sort)
    echo "  built $dst ($(find "$dst" -maxdepth 1 -type l | wc -l) skills, flattened)"
}

install_dotfiles() {
    echo "==> Symlinking home dotfiles"
    for f in .bashrc .vimrc .gitconfig .inputrc .profile; do
        link "$DOTFILES/$f" "$HOME/$f"
    done
}

install_skills() {
    echo "==> Linking skills (flattened)"
    mkdir -p "$HOME/.cursor" "$HOME/.claude"
    link_skills "$HOME/.cursor/skills"
    link_skills "$HOME/.claude/skills"
}

install_ask() {
    echo "==> Symlinking ask.py"
    mkdir -p "$HOME/.local/bin"
    link "$DOTFILES/ask.py" "$HOME/.local/bin/ask.py"
}

install_tools() {
    echo "==> Installing vim"
    if command -v vim >/dev/null 2>&1; then
        echo "  vim already installed ($(command -v vim))"
    elif sudo apt-get update && sudo apt-get install -y vim; then
        echo "  vim installed"
    else
        echo "  WARNING: vim install failed (needs sudo/apt); install it manually" >&2
    fi

    echo "==> Installing uv"
    if command -v uv >/dev/null 2>&1; then
        echo "  uv already installed ($(command -v uv))"
    else
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
}

usage() {
    # Print the header comment block (lines after the shebang, minus the leading "# ").
    sed -n '2,/^set /{ /^set /d; s/^# \{0,1\}//p; }' "${BASH_SOURCE[0]}"
}

# Parse flags. With none, run everything; otherwise run only the selected steps
# in a fixed order (dotfiles, skills, ask, tools) regardless of flag order.
do_dotfiles=false do_skills=false do_ask=false do_tools=false
if [ "$#" -eq 0 ]; then
    do_dotfiles=true do_skills=true do_ask=true do_tools=true
else
    for arg in "$@"; do
        case "$arg" in
            --dotfiles) do_dotfiles=true ;;
            --skills)   do_skills=true ;;
            --ask)      do_ask=true ;;
            --tools)    do_tools=true ;;
            -h|--help)  usage; exit 0 ;;
            *) echo "Unknown option: $arg" >&2; usage >&2; exit 2 ;;
        esac
    done
fi

$do_dotfiles && install_dotfiles
$do_skills && install_skills
$do_ask && install_ask
$do_tools && install_tools

echo
echo "Done. Restart your shell or run: source ~/.bashrc"
