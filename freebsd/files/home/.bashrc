if [[ $- != *i* ]] ; then
  return
fi

export PAGER=less
export MANPAGER=less

export EDITOR=vim
export VISUAL=vim

HISTCONTROL=ignoreboth
shopt -s histappend

HISTSIZE=10000
HISTFILESIZE=2000

PS1='\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'

if [[ -f /usr/local/share/bash-completion/bash_completion.sh ]]; then
    source /usr/local/share/bash-completion/bash_completion.sh
fi
