if [ -f ~/.profile ]; then
    . ~/.profile
fi

export PATH="$PATH:/home/gabci/opt/cross-x86_64-elf/bin"

export WATCOM="/home/gabci/opt/watcom"
export PATH="$PATH:$WATCOM/binl64"
export EDPATH="$WATCOM/eddat"
export INCLUDE="$WATCOM/lh"
