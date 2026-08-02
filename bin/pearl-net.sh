#!/usr/bin/env bash
# Black Pearl Network Stats — wired + wireless display for TL pane
# Palette: gold #e8b54b, teal #4fb3a8, dim #4a5263, fg #dbe2e8

trap 'printf "\e[?25h\e[0m"; exit 0' INT TERM

HIDE=$'\e[?25l'
SHOW=$'\e[?25h'
RST=$'\033[0m'
GOLD=$'\033[38;2;232;181;75m'
TEAL=$'\033[38;2;79;179;168m'
DIM=$'\033[38;2;74;82;99m'
FG=$'\033[38;2;219;226;232m'
BRT=$'\033[38;2;255;209;102m'
CRIM=$'\033[38;2;168;36;47m'
BOLD=$'\033[1m'
RST_LINE=$'\e[K'

human() {
    local b=$1
    if (( b >= 1073741824 )); then awk "BEGIN{printf \"%.1f GB\", $b/1073741824}"
    elif (( b >= 1048576 )); then awk "BEGIN{printf \"%.1f MB\", $b/1048576}"
    elif (( b >= 1024 )); then awk "BEGIN{printf \"%.1f KB\", $b/1024}"
    else echo "${b} B"; fi
}

human_rate() {
    local b=$1
    if (( b >= 1073741824 )); then awk "BEGIN{printf \"%.1f GB/s\", $b/1073741824}"
    elif (( b >= 1048576 )); then awk "BEGIN{printf \"%.1f MB/s\", $b/1048576}"
    elif (( b >= 1024 )); then awk "BEGIN{printf \"%.1f KB/s\", $b/1024}"
    else echo "${b} B/s"; fi
}

# Detect wired and wireless interfaces
find_wired() {
    for iface in eno1 eth0 enp*; do
        [[ -d "/sys/class/net/$iface" ]] && { echo "$iface"; return; }
    done
    # fallback: first non-lo non-wl interface
    for c in /sys/class/net/*; do
        local i=${c##*/}
        [[ "$i" == "lo" || "$i" == wl* || "$i" == br-* || "$i" == docker* || "$i" == veth* || "$i" == virbr* ]] && continue
        echo "$i"; return
    done
    echo ""
}

find_wireless() {
    for iface in wlo1 wlan0 wlp*; do
        [[ -d "/sys/class/net/$iface" ]] && { echo "$iface"; return; }
    done
    # fallback: first wl* interface
    for c in /sys/class/net/wl*; do
        [[ -d "$c" ]] && { echo "${c##*/}"; return; }
    done
    echo ""
}

read_iface() {
    local iface="$1"
    [[ -z "$iface" || ! -d "/sys/class/net/$iface" ]] && return

    local status speed mac ip rx_bytes tx_bytes rx_pkts tx_pkts rx_errs tx_errs

    status=$(cat "/sys/class/net/$iface/operstate" 2>/dev/null || echo "unknown")
    speed=$(cat "/sys/class/net/$iface/speed" 2>/dev/null)
    [[ "$speed" == "-1" || -z "$speed" ]] && speed="---"
    mac=$(cat "/sys/class/net/$iface/address" 2>/dev/null || echo "---")

    # IPv4
    ip=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet /{split($2,a,"/"); print a[1]; exit}')
    [[ -z "$ip" ]] && ip="---"

    # Stats
    rx_bytes=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)
    tx_bytes=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)
    rx_pkts=$(cat "/sys/class/net/$iface/statistics/rx_packets" 2>/dev/null || echo 0)
    tx_pkts=$(cat "/sys/class/net/$iface/statistics/tx_packets" 2>/dev/null || echo 0)
    rx_errs=$(cat "/sys/class/net/$iface/statistics/rx_errors" 2>/dev/null || echo 0)
    tx_errs=$(cat "/sys/class/net/$iface/statistics/tx_errors" 2>/dev/null || echo 0)

    # Previous values for rate calc
    local prev_rx_var="PRX_${iface//[^a-zA-Z0-9]/_}"
    local prev_tx_var="PTX_${iface//[^a-zA-Z0-9]/_}"
    local prev_ts_var="PTS_${iface//[^a-zA-Z0-9]/_}"
    local prev_rx=${!prev_rx_var:-0}
    local prev_tx=${!prev_tx_var:-0}
    local prev_ts=${!prev_ts_var:-0}

    local now=$(date +%s)
    local rx_rate=0 tx_rate=0
    if (( prev_ts > 0 && now > prev_ts )); then
        local dt=$(( now - prev_ts ))
        rx_rate=$(( (rx_bytes - prev_rx) / dt ))
        tx_rate=$(( (tx_bytes - prev_tx) / dt ))
        (( rx_rate < 0 )) && rx_rate=0
        (( tx_rate < 0 )) && tx_rate=0
    fi

    eval "$prev_rx_var=$rx_bytes"
    eval "$prev_tx_var=$tx_bytes"
    eval "$prev_ts_var=$now"

    # Build display
    local label="${1:-$iface}"
    local status_color="$TEAL"
    [[ "$status" == "up" ]] && status_color="$BRT"
    [[ "$status" == "down" ]] && status_color="$CRIM"

    local lines=()
    lines+=("${GOLD}${BOLD}${label}${RST}")
    lines+=("  Status:  ${status_color}${status^^}${RST}")
    lines+=("  Speed:   ${TEAL}${speed} Mbps${RST}")
    lines+=("  MAC:     ${FG}${mac}${RST}")
    lines+=("  IP:      ${FG}${ip}${RST}")
    lines+=("  RX:      ${FG}$(human "$rx_bytes")${RST}  ${DIM}$(human_rate "$rx_rate")${RST}")
    lines+=("  TX:      ${FG}$(human "$tx_bytes")${RST}  ${DIM}$(human_rate "$tx_rate")${RST}")
    lines+=("  PKTS:    ${FG}${rx_pkts} rx / ${tx_pkts} tx${RST}")
    lines+=("  ERRS:    ${FG}${rx_errs} rx / ${tx_errs} tx${RST}")

    printf '%s\n' "${lines[@]}"
}

WIRED=""
WIRELESS=""
declare -A PRX_ PTX_ PTS_

main() {
    WIRED=$(find_wired)
    WIRELESS=$(find_wireless)

    while :; do
        printf "%b" "$HIDE"

        local output=""

        if [[ -n "$WIRED" ]]; then
            output+=$(read_iface "$WIRED" "ENO1 (wired)")
        else
            output+="${GOLD}${BOLD}ENO1 (wired)${RST}\n"
            output+="  ${DIM}no wired interface detected${RST}\n"
        fi

        output+="\n"

        if [[ -n "$WIRELESS" ]]; then
            output+=$(read_iface "$WIRELESS" "WLO1 (wireless)")
        else
            output+="${GOLD}${BOLD}WLO1 (wireless)${RST}\n"
            output+="  ${DIM}no wireless interface detected${RST}\n"
        fi

        printf "\e[H"
        printf "%b" "$output"

        # Clear remaining lines
        local rows
        rows=$(stty size 2>/dev/null | awk '{print $1}')
        for (( i=0; i<rows; i++ )); do printf "%b" "$RST_LINE\n"; done
        printf "\e[H"

        sleep 2
    done
}

main
