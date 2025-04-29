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
alias giow='git show'
alias giu='git add -u'
alias gine='git commit --amend --no-edit'
alias giune='git add -u && git commit --amend --no-edit'
alias gibu='git_backup'
alias gist='git status'
alias gisreset='git submodule deinit -f . && git submodule update --init'

# python
function __conda_init() {
    __conda_setup="$('/home/gleb/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    eval "$__conda_setup"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/home/gleb/anaconda3/etc/profile.d/conda.sh" ]; then         
            . "/home/gleb/anaconda3/etc/profile.d/conda.sh"
        else
            export PATH="/home/gleb/anaconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
}

alias condainit='__conda_init'
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
alias gr='grep -rn . -e '
alias gi='grep -i '
alias rc="batcat"
alias vima='vim $(fzf)'
alias aptd='sudo apt-get update'
alias aptg='sudo apt-get upgrade && dist-upgrade'
alias apti='sudo apt-get install'
alias aptr='sudo apt-get remove'
alias historya='eval $(history | cut -c 8- | fzf)'
alias killa="ps aux | fzf --multi | awk '{print $2}' | xargs kill -9"
alias cda='cd $(find . -type d | fzf)'
alias suspend='systemctl suspend'

# ai
export AIDER_OPTIONS="--map-tokens 0 --no-analytics --no-auto-commits --no-gitignore --no-check-update --edit-format diff"
alias aiderg="aider --model gpt-4o $AIDER_OPTIONS"
alias aiderc="aider --model claude-3-7-sonnet-20250219 $AIDER_OPTIONS"
alias whisper='/home/gleb/whisper.cpp/stream -m /home/gleb/whisper.cpp/models/ggml-base.en.bin -t 8 --step 500 --length 5000 -f /home/gleb/whisper.cpp/output.txt'
alias wakesound="python /home/gleb/programming/play/wakesound/wakesound.py"
alias arduino="cd /home/gleb/arduino-ide_2.0.3_Linux_64bit && ./arduino-ide"

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
