#!/usr/bin/env bash
# Black Pearl TL pane: shows logo text, then drops to shell
echo -e "\n\n        \033[38;2;232;181;75mTHE BLACK PEARL\033[0m\n\n        \033[2mA ship too famous to be forgotten\033[0m"
exec bash --norc --noprofile
