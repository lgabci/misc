. /etc/ksh.kshrc

HISTFILE="$HOME/.ksh_history"
HISTSIZE=5000
export HISTFILE HISTSIZE

PS1="\033[32m\u@\h\033[00m:\033[36m\w\033[00m$ "
export PS1
