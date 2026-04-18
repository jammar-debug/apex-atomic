# apex-atomic

A custom Fedora Atomic (bootc) image with:

| Component | Package | Source |
|---|---|---|
| **NVIDIA drivers** | (akmods, pre-baked) | Universal Blue `base-main` |
| **niri** | `niri` | `avengemedia/danklinux` COPR |
| **DankMaterialShell** | `dms` | `avengemedia/dms` COPR |
| **Quickshell** | `quickshell` | `avengemedia/danklinux` COPR |
| **DankGreeter** | `dms-greeter` | `avengemedia/danklinux` COPR |
| **DankSearch** | `dsearch` | `avengemedia/danklinux` COPR |
| **DankGOP** | `dgop` | `avengemedia/danklinux` COPR |
| **cliphist** | `cliphist` | `avengemedia/danklinux` COPR |
| **matugen** | `matugen` | `avengemedia/danklinux` COPR |
| **xWayland-Satellite** | `xwayland-satellite` | `avengemedia/danklinux` COPR (auto-dep of niri) |
| **Steam** | `steam` | RPMFusion-nonfree (pre-enabled in ublue base) |

No GNOME. No KDE. Just niri + the full DMS suite.

---

## Building

### Prerequisites

```bash
sudo dnf install podman just   # on Fedora Atomic
```

### Local build

```bash
git clone https://github.com/jammar-debug/apex-atomic
cd apex-atomic
just build
```

### Push to GHCR (CI)

Push to `main` — the GitHub Actions workflow builds and publishes automatically.
Make packages public at: `https://github.com/jammar-debug?tab=packages`

---

## Installing / Rebasing

From any existing Fedora Atomic / Silverblue / Kinoite system:

```bash
# Rebase to locally-built image
just rebase-local

# OR rebase to the published image
just rebase

# Then reboot
systemctl reboot
```

---

## First boot

1. **DankGreeter** (greetd + `dms-greeter`) handles the graphical login screen on VT1. It syncs wallpaper and Material You colour themes with your user session.
2. After first login, `dms-first-boot.service` runs automatically and:
   - Calls `dms setup --compositor niri --non-interactive`, generating `~/.config/niri/config.kdl` with all DMS keybinds and `~/.config/dms/` starter config
   - Calls `dms greeter sync`, setting up ACL permissions so DankGreeter can read your wallpaper and colour theme
3. The `dms` systemd user service starts automatically on every subsequent login.

Check first-boot progress:
```bash
journalctl -u dms-first-boot.service -f
```

---

## Key bindings (niri + DMS defaults)

| Keys | Action |
|---|---|
| `Super+Space` | App launcher (DMS Spotlight) |
| `Super+V` | Clipboard history |
| `Super+M` | Task manager |
| `Super+,` | Settings |
| `Super+N` | Notification centre |
| `Super+Alt+L` | Lock screen |

Full list: `dms keybinds show niri`

---

## Customising

### Add more RPMs

Append to the `dnf5 install` block in `Containerfile`.

### Use dms-git (bleeding edge)

Enable `avengemedia/dms-git` COPR instead of `avengemedia/dms` and change the package name to `dms-git`.

---

## Directory structure

```
apex-atomic/
├── Containerfile
├── justfile
├── .github/workflows/build.yml
└── system_files/                               # Overlaid onto / at build time
    ├── etc/greetd/config.toml                  # DankGreeter → niri-session
    ├── usr/lib/environment.d/
    │   └── 90-niri-dms.conf                    # Wayland / Qt / NVIDIA env vars
    ├── usr/lib/systemd/system/
    │   └── dms-first-boot.service              # dms setup + dms greeter sync
    ├── usr/lib/systemd/user-preset/
    │   └── 75-dms.preset                       # Auto-enables dms.service per user
    └── usr/share/wayland-sessions/
        └── niri.desktop                        # Session entry
```
