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
lias giu='git add -u'
alias gine='git commit --amend --no-edit'
alias giune='git add -u && git commit --amend --no-edit'
alias gibu='git_backup'
alias gist='git status'
alias gisreset='git submodule deinit -f . && git submodule update --init'

# shell
function mount_path() {
  sudo mount -t ecryptfs $1 $1 -o ecryptfs_cipher=aes,ecryptfs_key_bytes=32,ecryptfs_passthrough=no,ecryptfs_enable_filename_crypto=no,ecryptfs_sig=$(sudo cat ~root/.ecryptfs/sig-cache.txt)
}

function cdup() {
  cd $(printf "%0.0s../" $(seq 1 $1));
}

alias gre='grep -rn . -e '
alias suspend='systemctl suspend'

# cpp
function cpp_script() {
    printf "#include<iostream>\n\nusing namespace std;\n\nint main() {\n\n}" > "$1.cc"; vim "$1.cc"
}

function gpp_script() {
    g++ -std=c++11 -o $1 $1.cc
}

# python
function conda_init() {
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

alias sact='source .venv/bin/activate'
