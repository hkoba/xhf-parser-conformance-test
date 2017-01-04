#!/bin/zsh

set -eu

emulate -L zsh

scriptFile=$(readlink -f $0)
appDir=$scriptFile:h:h

setopt extendedglob

files=(
    $(cd $appDir/yatt_lite && print -l **/*.xhf(.))
)

for f in $files; do
    src=../yatt_lite/$f
    dst=$f:gs,/,__,

    ln -vrsf $src $dst
done
