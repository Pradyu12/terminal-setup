#!/usr/bin/env bash
sleep 0.5
clear
COLS=$(tput cols)
ROWS=$(tput lines)

O='\033[38;2;234;182;76m'
W='\033[48;2;255;255;255m\033[38;2;0;0;0m'
X='\033[49m\033[38;2;234;182;76m'
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
p "${O}      -+ssssssssssssssssss${W}yy${X}ssss+-"
p "${O}    .ossssssssssssssssss${W}dMMMNy${X}sssso."
p "${O}   /sssssssssss${W}hdmmNNmmyNMMMMh${X}ssssss\\"
p "${O}  +sssssssss${W}hm${X}yd${W}MMMMMMMNddddy${X}ssssssss+"
p "${O} /ssssssss${W}hNMMM${X}yh${W}hyyyyhmNMMMNh${X}ssssssss\\"
p "${O}.ssssssss${W}dMMMNh${X}ssssssssss${W}hNMMMd${X}ssssssss."
p "${O}+ssss${W}hhhyNMMNy${X}ssssssssssss${W}yNMMMy${X}sssssss+"
p "${O}oss${W}yNMMMNyMMh${X}ssssssssssssss${W}hmmmh${X}ssssssso"
p "${O}oss${W}yNMMMNyMMh${X}sssssssssssssshmmmh${X}ssssssso"
p "${O}+ssss${W}hhhyNMMNy${X}ssssssssssss${W}yNMMMy${X}sssssss+"
p "${O}.ssssssss${W}dMMMNh${X}ssssssssss${W}hNMMMd${X}ssssssss."
p "${O} \\ssssssss${W}hNMMM${X}yh${W}hyyyyhdNMMMNh${X}ssssssss/"
p "${O}  +sssssssss${W}dm${X}yd${W}MMMMMMMMddddy${X}ssssssss+"
p "${O}   \\sssssssssss${W}hdmNNNNmyNMMMMh${X}ssssss/"
p "${O}    .ossssssssssssssssss${W}dMMMNy${X}sssso."
p "${O}      -+ssssssssssssssss${W}yyy${X}ssss+-"
p "${O}        :\`+ssssssssssssssssss+:\`"
p "${O}            .-\\+oossssoo+/-.${R}"

while :; do sleep 300; done
