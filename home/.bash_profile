if [ -f ~/.profile ]; then
    . ~/.profile
fi

export PATH="$PATH:/home/gabci/opt/cross-x86_64-elf/bin"

export WATCOM="/home/gabci/opt/watcom"
export PATH="$PATH:$WATCOM/binl64:$WATCOM/binl"
export EDPATH="$WATCOM/eddat"
export INCLUDE="$WATCOM/lh"
#export LIB=
#export WWINHELP="$WATCOM/binw"
