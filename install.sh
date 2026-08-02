#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Black Pearl Terminal Setup — Installer
# https://github.com/Pradyu12/terminal-setup
# ═══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
DRY_RUN=false
NO_PACKAGES=false

# ─── Colors ───────────────────────────────────────────────────────────────────
R='\033[0m' BOLD='\033[1m' DIM='\033[2m'
GOLD='\033[38;2;232;181;75m'
TEAL='\033[38;2;79;179;168m'
CRIM='\033[38;2;168;36;47m'
FG='\033[38;2;219;226;232m'
RED='\033[31m' GREEN='\033[32m' YELLOW='\033[33m'

banner() {
    echo -e "${GOLD}"
    cat << 'EOF'

    ╔══════════════════════════════════════════════╗
    ║         THE BLACK PEARL — Terminal Setup     ║
    ║          Midnight Sea & Gold Theme           ║
    ╚══════════════════════════════════════════════╝

EOF
    echo -e "${R}"
}

info()  { echo -e "  ${TEAL}[INFO]${R}  $1"; }
warn()  { echo -e "  ${YELLOW}[WARN]${R}  $1"; }
ok()    { echo -e "  ${GREEN}[ OK ]${R}  $1"; }
fail()  { echo -e "  ${RED}[FAIL]${R}  $1"; }
ask()   { echo -en "  ${GOLD}[?]${R} $1 "; }
dry()   { echo -e "  ${DIM}[DRY]  $1${R}"; }

# ─── Detect package manager ───────────────────────────────────────────────────
detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v brew &>/dev/null; then
        echo "brew"
    else
        echo "none"
    fi
}

install_pkg() {
    local pkg="$1"
    local mgr
    mgr=$(detect_pkg_manager)
    if $DRY_RUN; then
        dry "Would install package: $pkg (via $mgr)"
        return 0
    fi
    case "$mgr" in
        apt)    sudo apt-get install -y "$pkg" ;;
        dnf)    sudo dnf install -y "$pkg" ;;
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        brew)   brew install "$pkg" ;;
        *)      return 1 ;;
    esac
}

# ─── Dependency checks ────────────────────────────────────────────────────────
check_deps() {
    info "Checking dependencies..."
    local missing=()

    for cmd in tmux btop git bash; do
        if command -v "$cmd" &>/dev/null; then
            ok "$cmd $(command -v "$cmd")"
        else
            warn "$cmd not found"
            missing+=("$cmd")
        fi
    done

    if command -v zsh &>/dev/null; then
        ok "zsh $(command -v zsh)"
    else
        warn "zsh not found (optional — used for shell panes)"
    fi

    if $NO_PACKAGES; then
        if (( ${#missing[@]} > 0 )); then
            warn "Skipping package install (--no-packages). Missing: ${missing[*]}"
        fi
        echo ""
        return
    fi

    if (( ${#missing[@]} > 0 )); then
        echo ""
        ask "Install missing required packages (${missing[*]})? [Y/n] "
        read -r ans
        if [[ "${ans,,}" != "n" ]]; then
            for pkg in "${missing[@]}"; do
                info "Installing $pkg..."
                install_pkg "$pkg" || { fail "Could not install $pkg"; exit 1; }
            done
        else
            fail "Cannot continue without required packages: ${missing[*]}"
            exit 1
        fi
    fi
    echo ""
}

# ─── Optional components ─────────────────────────────────────────────────────
OPTIONAL_KITTY=false
OPTIONAL_FASTFETCH=false

check_optional() {
    echo -e "  ${BOLD}Optional components:${R}"
    echo "    1) Kitty terminal theme + session"
    echo "    2) Fastfetch logo config"
    echo "    3) Both"
    echo "    0) Skip optional components"
    echo ""
    ask "Install optional components? [1/2/3/0, default: 0] "
    read -r opt
    case "$opt" in
        1) OPTIONAL_KITTY=true ;;
        2) OPTIONAL_FASTFETCH=true ;;
        3) OPTIONAL_KITTY=true; OPTIONAL_FASTFETCH=true ;;
        *) ;;
    esac
    echo ""
}

# ─── Timestamped backup + install helper ──────────────────────────────────────
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# install_file SRC DEST — backs up existing DEST with timestamp, installs SRC
# Returns 0 on success, 1 if skipped
install_file() {
    local src="$1" dest="$2"
    local dest_dir
    dest_dir="$(dirname "$dest")"

    if [[ ! -e "$dest" ]]; then
        if $DRY_RUN; then
            dry "Would create $dest_dir/ and install $src → $dest"
            return 0
        fi
        mkdir -p "$dest_dir"
        cp "$src" "$dest"
        ok "Installed $dest"
        return 0
    fi

    # File exists — ask
    echo -e "    ${DIM}$dest already exists${R}"
    echo "    [o] overwrite   [b] backup & install   [s] skip"
    ask "Choice for $(basename "$dest"):"
    read -r choice
    case "${choice,,}" in
        o)
            if $DRY_RUN; then
                dry "Would overwrite $dest"
                return 0
            fi
            cp "$src" "$dest"
            ok "Overwrote $dest"
            return 0
            ;;
        b|*)
            if $DRY_RUN; then
                dry "Would backup $dest → ${dest}.${TIMESTAMP}, then install $src"
                return 0
            fi
            cp "$dest" "${dest}.${TIMESTAMP}"
            cp "$src" "$dest"
            ok "Installed $dest (backup: ${dest}.${TIMESTAMP})"
            return 0
            ;;
        s)
            warn "Skipped $dest"
            return 1
            ;;
    esac
}

# ─── Install core ────────────────────────────────────────────────────────────
install_core() {
    info "Installing core files..."
    echo ""

    # Binaries
    install_file "$SCRIPT_DIR/bin/black-pearl-ws" "$HOME_DIR/.local/bin/black-pearl-ws"
    install_file "$SCRIPT_DIR/bin/pearl-ubuntu.sh" "$HOME_DIR/.local/bin/pearl-ubuntu.sh"
    install_file "$SCRIPT_DIR/bin/pearl-ascii.sh"  "$HOME_DIR/.local/bin/pearl-ascii.sh"
    chmod +x "$HOME_DIR/.local/bin/black-pearl-ws" \
             "$HOME_DIR/.local/bin/pearl-ubuntu.sh" \
             "$HOME_DIR/.local/bin/pearl-ascii.sh" 2>/dev/null || true

    # tmux config
    install_file "$SCRIPT_DIR/tmux.conf" "$HOME_DIR/.tmux.conf"

    # tmux status bar
    install_file "$SCRIPT_DIR/config/tmux/status.sh" "$HOME_DIR/.config/tmux/status.sh"
    chmod +x "$HOME_DIR/.config/tmux/status.sh" 2>/dev/null || true

    # btop theme
    install_file "$SCRIPT_DIR/config/btop/themes/black-pearl.theme" \
                 "$HOME_DIR/.config/btop/themes/black-pearl.theme"
    install_file "$SCRIPT_DIR/config/btop/pearl-ws.conf" \
                 "$HOME_DIR/.config/btop/pearl-ws.conf"

    # ASCII art
    install_file "$SCRIPT_DIR/ascii/ubuntu-logo.ascii" "$HOME_DIR/.config/ubuntu-logo.ascii"

    echo ""
}

# ─── Install kitty ────────────────────────────────────────────────────────────
install_kitty() {
    if ! command -v kitty &>/dev/null; then
        if $NO_PACKAGES; then
            warn "Kitty not installed — skipping (--no-packages)"
            return
        fi
        warn "Kitty not installed — installing..."
        install_pkg kitty || { warn "Could not install kitty, skipping kitty config"; return; }
    fi

    info "Installing kitty theme + session..."
    install_file "$SCRIPT_DIR/config/kitty/black-pearl.conf"    "$HOME_DIR/.config/kitty/black-pearl.conf"
    install_file "$SCRIPT_DIR/config/kitty/black-pearl.session" "$HOME_DIR/.config/kitty/black-pearl.session"
    echo ""
}

# ─── Install fastfetch ────────────────────────────────────────────────────────
install_fastfetch() {
    if ! command -v fastfetch &>/dev/null; then
        if $NO_PACKAGES; then
            warn "Fastfetch not installed — skipping (--no-packages)"
            return
        fi
        warn "Fastfetch not installed — installing..."
        install_pkg fastfetch || { warn "Could not install fastfetch, skipping"; return; }
    fi

    info "Installing fastfetch config..."
    install_file "$SCRIPT_DIR/config/fastfetch/black-pearl.png" \
                 "$HOME_DIR/.config/fastfetch/black-pearl.png"

    # Write config with correct HOME path
    local dest="$HOME_DIR/.config/fastfetch/config.jsonc"
    local src="$SCRIPT_DIR/config/fastfetch/config.jsonc"

    if [[ -e "$dest" ]]; then
        ask "Overwrite $dest? [y/N] "
        read -r ans
        if [[ "${ans,,}" == "y" ]]; then
            if $DRY_RUN; then
                dry "Would backup $dest → ${dest}.${TIMESTAMP}, then install $src"
            else
                cp "$dest" "${dest}.${TIMESTAMP}"
                sed "s|__HOME__|$HOME_DIR|g" "$src" > "$dest"
                ok "Installed $dest (backup: ${dest}.${TIMESTAMP})"
            fi
        else
            warn "Skipped $dest"
        fi
    else
        if $DRY_RUN; then
            dry "Would create $(dirname "$dest")/ and install $src → $dest"
        else
            mkdir -p "$(dirname "$dest")"
            sed "s|__HOME__|$HOME_DIR|g" "$src" > "$dest"
            ok "Installed $dest"
        fi
    fi
    echo ""
}

# ─── Uninstall ────────────────────────────────────────────────────────────────
uninstall() {
    echo -e "${CRIM}Uninstall: restoring backup files where they exist${R}"
    local restored=0

    # Restore any timestamped backups (most recent first)
    for config in \
        "$HOME_DIR/.tmux.conf" \
        "$HOME_DIR/.config/tmux/status.sh" \
        "$HOME_DIR/.config/btop/themes/black-pearl.theme" \
        "$HOME_DIR/.config/btop/pearl-ws.conf" \
        "$HOME_DIR/.config/kitty/black-pearl.conf" \
        "$HOME_DIR/.config/kitty/black-pearl.session" \
        "$HOME_DIR/.config/fastfetch/config.jsonc" \
        "$HOME_DIR/.config/ubuntu-logo.ascii"
    do
        # Find most recent backup: *.2026XXXXXXXX-XXXXXX
        local latest
        latest=$(ls -t "${config}".20* 2>/dev/null | head -1)
        if [[ -n "$latest" ]]; then
            cp "$latest" "$config"
            ok "Restored $config from $(basename "$latest")"
            (( restored++ ))
        fi
    done

    for bin in black-pearl-ws pearl-ubuntu.sh pearl-ascii.sh; do
        local p="$HOME_DIR/.local/bin/$bin"
        if [[ -f "$p" ]]; then
            rm "$p"
            ok "Removed $p"
        fi
    done

    if (( restored == 0 )); then
        info "No backup files found to restore"
    fi

    echo -e "\n${GREEN}Done. Restart tmux/kitty to see changes.${R}\n"
}

# ─── Usage ────────────────────────────────────────────────────────────────────
usage() {
    cat << 'EOF'
Usage: install.sh [OPTIONS]

Options:
  --dry-run       Preview actions without changing anything
  --no-packages   Skip all sudo/package installation, only install configs
  --uninstall     Restore backups and remove installed scripts
  --help          Show this help message
EOF
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)      DRY_RUN=true; shift ;;
            --no-packages)  NO_PACKAGES=true; shift ;;
            --uninstall)    uninstall; exit 0 ;;
            --help|-h)      usage; exit 0 ;;
            *)              fail "Unknown option: $1"; usage; exit 1 ;;
        esac
    done

    banner

    if $DRY_RUN; then
        echo -e "  ${YELLOW}${BOLD}DRY RUN — no changes will be made${R}\n"
    fi

    check_deps
    check_optional
    install_core
    "$OPTIONAL_KITTY"  && install_kitty
    "$OPTIONAL_FASTFETCH" && install_fastfetch

    echo -e "${GOLD}══════════════════════════════════════════════════════════════${R}"
    echo -e "  ${BOLD}${GREEN}Install complete!${R}"
    echo ""
    echo -e "  ${TEAL}Usage:${R}"
    echo -e "    ${GOLD}black-pearl-ws${R}   — launch the 3-pane workspace"
    echo -e "    ${GOLD}pearl-ubuntu.sh${R}  — display Ubuntu logo (for BL pane)"
    echo -e "    ${GOLD}pearl-ascii.sh${R}   — display THE BLACK PEARL banner"
    echo ""
    echo -e "  ${TEAL}Tip:${R} Add to kitty.conf to auto-launch on startup:"
    echo -e "    ${DIM}startup_session ~/.config/kitty/black-pearl.session${R}"
    echo ""
    echo -e "  ${DIM}https://github.com/Pradyu12/terminal-setup${R}"
    echo -e "${GOLD}══════════════════════════════════════════════════════════════${R}\n"
}

main "$@"
