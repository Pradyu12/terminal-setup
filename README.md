# Black Pearl Terminal Setup

A pirate-themed terminal workspace built around **tmux**, **kitty**, **btop**, and **fastfetch** — midnight sea and gold palette across every layer.

## Workspace Layout

```
┌──────────────────────┬─────────────────────────────┐
│                      │                             │
│     TL: shell        │        R: btop              │
│   (empty / reserved) │     (system monitor)        │
│                      │                             │
├──────────────────────┤                             │
│                      │                             │
│     BL: shell        │                             │
│  (Ubuntu logo bg)    │                             │
│                      │                             │
└──────────────────────┴─────────────────────────────┘
```

- **Top-left** — empty shell (reserved for your work)
- **Bottom-left** — shell displaying a two-color Ubuntu logo (orange ring, white inner circle)
- **Right** — btop system monitor (≥60% width)

## Palette

| Token        | Hex       | Role                    |
| ------------ | --------- | ----------------------- |
| `bg`         | `#0b0e1a` | Deep sea background     |
| `fg`         | `#dbe2e8` | Primary text            |
| `gold`       | `#e8b54b` | Accents, pane borders   |
| `bright-gold`| `#ffd166` | Highlights, cursor      |
| `amber`      | `#f0a04b` | Warm highlights         |
| `sea-teal`   | `#4fb3a8` | Secondary accent        |
| `wood`       | `#8b5a2b` | Subtle warm accent      |
| `crimson`    | `#a8242f` | Alerts, destructive     |
| `bone`       | `#e6e0d0` | Dim text                |
| `dim`        | `#4a5263` | Dimmed / inactive       |

## What's Included

| Component | File(s) | Purpose |
| --------- | ------- | ------- |
| **tmux** | `tmux.conf` | Prefix `C-a`, gold pane borders, status bar with sparkline graphs |
| **tmux status** | `config/tmux/status.sh` | CPU / MEM / DSK usage with sparklines |
| **workspace launcher** | `bin/black-pearl-ws` | Creates/attaches the 3-pane layout |
| **Ubuntu logo** | `bin/pearl-ubuntu.sh` | Two-color logo (orange ring + white circle) for the BL pane |
| **ASCII banner** | `bin/pearl-ascii.sh` | "THE BLACK PEARL" ASCII art |
| **btop theme** | `config/btop/themes/black-pearl.theme` | Midnight sea palette for btop |
| **kitty theme** | `config/kitty/black-pearl.conf` | 16-color palette + tab bar |
| **kitty session** | `config/kitty/black-pearl.session` | Auto-launch workspace on kitty start |
| **fastfetch** | `config/fastfetch/config.jsonc` + PNG | Custom logo for fastfetch |

## Dependencies

### Required
- **tmux** — terminal multiplexer
- **btop** — system monitor
- **git** — for cloning
- **bash** — scripts

### Optional
- **zsh** — shell used in panes (falls back to bash)
- **kitty** — terminal emulator (for the full theme)
- **fastfetch** — system info display
- **JetBrainsMono Nerd Font** — recommended font for kitty

### Auto-detected package managers
`apt` (Debian/Ubuntu) · `dnf` (Fedora) · `pacman` (Arch) · `brew` (macOS)

## Install

```bash
git clone https://github.com/Pradyu12/terminal-setup.git
cd terminal-setup
./install.sh
```

The installer will:
1. Detect and install missing required packages (with your permission)
2. Prompt for each config file — **overwrite / backup & install / skip**
3. Optionally install kitty theme and fastfetch config
4. Place scripts in `~/.local/bin/` and configs in `~/.config/`

## Usage

```bash
# Launch the 3-pane workspace
black-pearl-ws

# Display Ubuntu logo (run inside a tmux pane)
bash ~/.local/bin/pearl-ubuntu.sh

# Display THE BLACK PEARL banner
bash ~/.local/bin/pearl-ascii.sh
```

### Kitty auto-launch
Add to `~/.config/kitty/kitty.conf`:
```
startup_session ~/.config/kitty/black-pearl.session
```

### Tmux reload
After editing `~/.tmux.conf`:
```
tmux source-file ~/.tmux.conf
```

## Installer Options

| Flag | Purpose |
|------|---------|
| `--dry-run` | Preview every action without writing files or installing packages |
| `--no-packages` | Skip all `sudo`/package installs — only installs config files |
| `--uninstall` | Restore backups and remove installed scripts |
| `--help` | Show usage |

```bash
# Preview what would happen
./install.sh --dry-run

# Install configs only (no sudo)
./install.sh --no-packages

# Full install with kitty + fastfetch
./install.sh
```

### Backups

Every existing config file is saved with a timestamp before overwriting:
```
~/.tmux.conf.20260802-143022
```

`--uninstall` restores the most recent timestamped backup for each file.

## Uninstall

```bash
./install.sh --uninstall
```

Restores the most recent timestamped backup for each config and removes installed scripts.

## License

MIT
