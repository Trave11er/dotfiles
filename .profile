# ~/.profile: read by login shells (e.g. ssh), not by ~/.bashrc directly.

# Ensure user-local bin is on PATH (uv + ask.py live here)
[ -d "$HOME/.local/bin" ] && case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac

# Load interactive bash config for login shells
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
