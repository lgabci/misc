#!/bin/sh

set -eu

BINUTILSVER=2.40
GCCVER=12.2.0

BINUTILSFILE="binutils-$BINUTILSVER.tar.xz"
GCCFILE="gcc-$GCCVER.tar.xz"

BINUTILSURL="https://ftp.gnu.org/gnu/binutils/$BINUTILSFILE"
GCCURL="https://ftp.gnu.org/gnu/gcc/gcc-$GCCVER/$GCCFILE"

OPT=~/opt
export TARGET=i386-elf
SRC="$OPT/src-$TARGET"
export PREFIX="$OPT/cross-$TARGET"
export PATH="$PREFIX/bin:$PATH"

# clean
case "${1:-}" in
  clean)
    echo clean ...
    rm -rf "$SRC/build-binutils-$BINUTILSVER" "$SRC/build-gcc-$GCCVER" "$SRC/fake-crt0" "$PREFIX" "$HOME/bin/$TARGET-"*
    exit
    ;;
  clean-all)
    echo clean-all ...
    rm -rf "$SRC" "$PREFIX" "$HOME/bin/$TARGET-"*
    exit
    ;;
esac

# test and install packages
pkgs="build-essential bison flex texinfo"
pkgstoinstall=$(dpkg -l $pkgs 2>&1 |
  awk '/dpkg-query: no packages found matching/ {printf "%s ", $NF; next}
       /^(D|\||\+)/ {next}
       !/^ii/ {printf "%s ", $2; next}')
pkgstoinstall=${pkgstoinstall% }
if [ -n "$pkgstoinstall" ]; then
  echo Installing "$pkgstoinstall"
  sudo apt install $pkgstoinstall
fi

# number of CPUs
NPROC=$(nproc)
if [ -z "$NPROC" ]; then
  NPROC=1
fi

# get files from GNU website
mkdir -p "$SRC"
cd "$SRC"
if ! [ -e "$BINUTILSFILE" ]; then
  wget "$BINUTILSURL"
fi
if ! [ -e "$GCCFILE" ]; then
  wget "$GCCURL"
fi

# extract tar achives
if ! [ -e $(basename "$BINUTILSFILE" .tar.xz) ]; then
  echo untar "$BINUTILSFILE"
  tar xJf "$BINUTILSFILE"
fi
if ! [ -e $(basename "$GCCFILE" .tar.xz) ]; then
  echo untar "$GCCFILE"
  tar xJf "$GCCFILE"
fi

# build binutils
mkdir -p "$SRC/build-binutils-$BINUTILSVER"
cd "$SRC/build-binutils-$BINUTILSVER"

if ! [ -e Makefile ]; then
  ../"binutils-$BINUTILSVER"/configure --target="$TARGET" --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
fi
if ! [ -x "$PREFIX/bin/$TARGET-as" ]; then
  make -j $NPROC
  make install
fi

# test target binutils
if ! which "$TARGET-as" >/dev/null; then
  echo "$TARGET-as not found." >&2
  exit 1
fi

# download prerequisites
cd "$SRC/gcc-$GCCVER"
if [ -x contrib/download_prerequisites ]; then
  if ! [ -e gmp ] || ! [ -e mpfr ] || ! [ -e mpc ] || ! [ -e isl ]; then
    echo "Downloading prerequisites ..."
    contrib/download_prerequisites
  fi
fi

# install GCC
mkdir -p "$SRC/build-gcc-$GCCVER"
cd "$SRC/build-gcc-$GCCVER"

if ! [ -e Makefile ]; then
  ../"gcc-$GCCVER"/configure --target="$TARGET" --prefix="$PREFIX" --disable-nls --enable-languages=c --without-headers --with-gnu-ld --with-gnu-as
fi
if ! [ -x "$PREFIX/bin/$TARGET-gcc" ]; then
  make -j $NPROC all-gcc
  make -j $NPROC all-target-libgcc
  make install-gcc
  make install-target-libgcc
fi

# create symlinks
if ! [ -e "$HOME/bin/$TARGET-gcc" ]; then
  echo "Create symlinks ..."
  ln -rst "$HOME/bin" "$PREFIX/bin/"*
fi

# fake crt0
mkdir -p "$SRC/fake-crt0"
cd "$SRC/fake-crt0"

if ! [ -e crt0.s ]; then
  cat >crt0.s <<EOF
.section .text
.global _start
_start:
   nop
   nop
   nop
   nop
.size _start, . - _start
EOF
fi

if ! [ -e crt0.o ]; then
  "$TARGET-as" -o crt0.o crt0.s
fi

if ! [ -e libc.a ]; then
  "$TARGET-ar" rcs libc.a crt0.o
fi

if ! [ -e "$PREFIX/lib/gcc/$TARGET/$GCCVER/crt0.o" ]; then
  cp crt0.o "$PREFIX/lib/gcc/$TARGET/$GCCVER/crt0.o"
fi

if ! [ -e "$PREFIX/lib/gcc/$TARGET/$GCCVER/libc.a" ]; then
  cp libc.a "$PREFIX/lib/gcc/$TARGET/$GCCVER/libc.a"
fi
