# git
function git_backup {
    NAME=$(git branch --show-current)
    BRANCHES_NAME=$(git branch --no-color | grep "\bbu[0-9]*_$NAME")
    NUM_BRANCHES_NAME=$(echo "$BRANCHES_NAME" | wc -w)
    if [ "$NUM_BRANCHES_NAME" -eq 0 ]; then
        RET="bu1_$NAME"
    else
        NEW_NUM=$(($NUM_BRANCHES_NAME + 1))
        RET=$(echo "bu$NEW_NUM""_$NAME")
    fi  
    echo "Creating $RET"
    git checkout -b $RET
    git checkout $NAME
}

alias giff='git diff'
alias giffs='git diff --staged'
alias giu='git add -u'
alias gine='git commit --amend --no-edit'
alias giune='git add -u && git commit --amend --no-edit'
alias gibu='git_backup'
alias gist='git status'

# python
alias sact='source .venv/bin/activate'

# shell
function mount_path() {
  sudo mount -t ecryptfs $1 $1 -o ecryptfs_cipher=aes,ecryptfs_key_bytes=32,ecryptfs_passthrough=no,ecryptfs_enable_filename_crypto=no,ecryptfs_sig=$(sudo cat ~root/.ecryptfs/sig-cache.txt)
}

function cdup() {
  cd $(printf "%0.0s../" $(seq 1 $1));
}

alias mv='mv -i'
alias cp='cp -i'
alias rc="batcat"
alias vima='vim $(fzf)'
alias historya='eval $(history | cut -c 8- | fzf)'
alias killa="ps aux | fzf --multi | awk '{print $2}' | xargs kill -9"
alias cda='cd $(find . -type d | fzf)'
alias suspend='systemctl suspend'
[[ -s /usr/share/autojump/autojump.sh ]] && . /usr/share/autojump/autojump.sh

export PI='pi.local'
alias ssp='ssh pi@$PI'
alias arduino="cd $HOME/arduino-ide_2.0.3_Linux_64bit && ./arduino-ide"

# joplin
jrep() {
 # Check if search term is provided
 if [ $# -eq 0 ]; then
     echo "Usage: jrep <search_term>"
     return 1
 fi

 # Search term
 local search_term="$1"

 # Joplin database path (adjust if needed)
 local db_path="$HOME/.config/joplin-desktop/database.sqlite"

 # Search notes
 #sqlite3 "$db_path" "SELECT title, body FROM notes" | \
 #grep -i "$search_term" -B 1 -A 1 | \
 #sed \
 #    -e 's/^--$/🔸 ---------------------/' \
 #    -e "s/$search_term/\x1b[1;31m&\x1b[0m/gi"
 sqlite3 "$db_path" \
     "SELECT 'Title: ' || title || char(10) || body
      FROM notes
      WHERE title LIKE '%$search_term%'
      OR body LIKE '%$search_term%'" | \
 grep -i "$search_term" -B 1 -A 1 | \
 sed \
     -e 's/^--$/🔸 ---------------------/' \
     -e "s/$search_term/\x1b[1;31m&\x1b[0m/gi"
}

# requires curl -LsSf https://astral.sh/uv/install.sh | sh
export UV_EXCLUDE_NEWER="$(date -d '30 days ago' '+%Y-%m-%d')"  # quarantine new packages
alias markitdown="uvx markitdown[pdf]@0.1.0"
alias gitingest="uvx gitingest@0.3.1"

# python scripts (ask.py is symlinked here by install.sh; ~/.local/bin is put on
# PATH by ~/.profile / the environment, so no export needed here)
alias ask='uv run --with "openai==2.36.0" "$HOME/.local/bin/ask.py"'
