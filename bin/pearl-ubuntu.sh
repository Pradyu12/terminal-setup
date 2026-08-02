#!/usr/bin/env bash
# Black Pearl BL pane: shows Ubuntu logo, then usable shell
sleep 0.5
clear
COLS=$(tput cols)
ROWS=$(tput lines)

O='\033[38;2;234;182;76m'
W='\033[38;2;255;255;255m'
R='\033[0m'

LINES=20
WIDTH=40
top=$(( (ROWS - LINES) / 2 ))
if [ "$top" -lt 0 ]; then top=0; fi
for i in $(seq 1 "$top"); do printf '\n'; done
pad=$(( (COLS - WIDTH) / 2 ))
if [ "$pad" -lt 0 ]; then pad=0; fi

p() { printf '%*s' "$pad" ""; echo -e "$1"; }

p "${O}            .-/+oossssoo+\\-."
p "${O}        :\`+ssssssssssssssssss+:\`"
p "${O}      -+ssssssssssssssssss${W}yy${O}ssss+-"
p "${O}    .ossssssssssssssssss${W}dMMMNy${O}sssso."
p "${O}   /sssssssssss${W}hdmmNNmmyNMMMMh${O}ssssss\\"
p "${O}  +sssssssss${W}hm${O}yd${W}MMMMMMMNddddy${O}ssssssss+"
p "${O} /ssssssss${W}hNMMM${O}yh${W}hyyyyhmNMMMNh${O}ssssssss\\"
p "${O}.ssssssss${W}dMMMNh${O}ssssssssss${W}hNMMMd${O}ssssssss."
p "${O}+ssss${W}hhhyNMMNy${O}ssssssssssss${W}yNMMMy${O}sssssss+"
p "${O}oss${W}yNMMMNyMMh${O}ssssssssssssss${W}hmmmh${O}ssssssso"
p "${O}oss${W}yNMMMNyMMh${O}sssssssssssssshmmmh${O}ssssssso"
p "${O}+ssss${W}hhhyNMMNy${O}ssssssssssss${W}yNMMMy${O}sssssss+"
p "${O}.ssssssss${W}dMMMNh${O}ssssssssss${W}hNMMMd${O}ssssssss."
p "${O} \\ssssssss${W}hNMMM${O}yh${W}hyyyyhdNMMMNh${O}ssssssss/"
p "${O}  +sssssssss${W}dm${O}yd${W}MMMMMMMMddddy${O}ssssssss+"
p "${O}   \\sssssssssss${W}hdmNNNNmyNMMMMh${O}ssssss/"
p "${O}    .ossssssssssssssssss${W}dMMMNy${O}sssso."
p "${O}      -+ssssssssssssssss${W}yyy${O}ssss+-"
p "${O}        :\`+ssssssssssssssssss+:\`"
p "${O}            .-\\+oossssoo+/-.${R}"

echo ""
exec bash --norc --noprofile
