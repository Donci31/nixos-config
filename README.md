# NixOS-WSL Configuration

Declarative NixOS configuration for Windows Subsystem for Linux (WSL2), managed via **Nix Flakes** and **Home Manager**, with integrated user configurations sourced directly from [Donci31/dotfiles](https://github.com/Donci31/dotfiles).

---

## Architecture Overview

```
nixos-config/
├── flake.nix             # Flake entry point (inputs, outputs, module orchestration)
├── flake.lock            # Immutable version lockfile for all inputs
├── configuration.nix     # System-level NixOS & WSL configuration (podman, shells, base pkgs)
└── home.nix              # Home Manager module (user CLI packages, runtimes, dotfile symlinks)
```

- **NixOS-WSL**: Uses [`NixOS-WSL`](https://github.com/nix-community/NixOS-WSL) for native Windows interop, default user management, and systemd support.
- **Home Manager**: Manages user packages, shell integrations, and environment variables.
- **Dotfiles Integration**: The flake imports `github:Donci31/dotfiles` as a non-flake input and symlinks configurations for Neovim (LazyVim), Nushell, Starship, Yazi (Dracula theme), and Pgcli.

---

## Initial Setup on a Fresh WSL Instance

### 1. Install NixOS-WSL

1. Download `nixos.wsl` from the [latest release](https://github.com/nix-community/NixOS-WSL/releases/latest).
2. Install the distribution:
   - **Explorer**: If you have WSL version 2.4.4 or later, open (double-click) the `.wsl` file to install it.
   - **PowerShell / Nushell**:
     ```powershell
     wsl --install --from-file path\to\nixos.wsl
     ```
     *(Use `--name` to customize the distro name and `--location` to customize the disk image storage directory).*
3. Open your NixOS shell:
   ```powershell
   wsl -d NixOS
   ```
   *(Or select **NixOS** from Windows Terminal profile dropdown or launch it from the Start Menu).*

### 2. Clone Repository to `~/.config/nixos`

Inside your NixOS WSL shell:

```bash
# Clone directly into user space (no root/sudo needed for Git)
git clone https://github.com/Donci31/nixos-config.git ~/.config/nixos

# (Optional, Recommended) Symlink /etc/nixos to point to your user repo
sudo rm -rf /etc/nixos
sudo ln -s /home/nixos/.config/nixos /etc/nixos
```

### 3. Build and Switch

```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
# (or simply 'sudo nixos-rebuild switch' if /etc/nixos is symlinked)
```

### 4. Restart WSL Session

To ensure the default shell (`nushell`) and all environment variables take effect across sessions, restart the instance from Windows:

```nu
# In Windows Nushell / PowerShell:
wsl --terminate NixOS
wsl -d NixOS
```

---

## Day-to-Day Operations

### Apply Changes (Switch)

Rebuild and activate configuration changes:

```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
# (or 'sudo nixos-rebuild switch' if symlinked)
```

### Test Build (Dry Run)

Compile the configuration without applying it to verify syntax and derivations (generates a `./result` symlink):

```bash
sudo nixos-rebuild build --flake ~/.config/nixos#nixos --show-trace
```

### Update Flake Inputs

Update all inputs (`nixpkgs`, `nixos-wsl`, `home-manager`, `dotfiles`):

```bash
nix flake update --flake ~/.config/nixos
```

Update only the `dotfiles` input (e.g. after pushing dotfiles changes to GitHub):

```bash
nix flake update dotfiles --flake ~/.config/nixos
sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
```

### Local Dotfiles Testing (Override Input)

To test changes from your local Windows dotfiles checkout without pushing to GitHub first:

```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#nixos --override-input dotfiles path:/mnt/c/Users/szige/.dotfiles
```

---

## Included Tooling & Environments

| Category | Tools |
| :--- | :--- |
| **Shell & Prompt** | Nushell (`nu`), Starship prompt, Zoxide (`z`), Carapace completions, Atuin history |
| **Editor** | Neovim (`nvim` configured with LazyVim via dotfiles) |
| **VCS** | Git, Lazygit |
| **File Management** | Yazi (with Dracula theme, PDF & image previews), `fd`, `bat` |
| **Search & CLI Utilities** | `ripgrep` (`rg`), `fzf`, `jq`, `xh`, `fastfetch`, `tree-sitter`, `duckdb` |
| **Dev Runtimes** | Python (`uv`, Python 3), Node.js (Node 24), AWS CLI v2, GCC, GNU Make, `unzip` |
| **Cloud & Containers** | Podman (with Docker CLI alias) |
| **Media Processing** | `ffmpeg-full` |

---

## Troubleshooting

### Uncommitted Flake Files
Nix Flakes only read files tracked by Git. If you add new `.nix` files or configs, stage them before rebuilding:
```bash
git -C /etc/nixos add -A
```

### Sourcing Custom Nushell Scripts (`extra.nu`)
In Nushell, `source` is evaluated at parse time. If using an optional local script (`~/.config/nushell/extra.nu`), ensure it is handled via the cache pattern in `env.nu` or placed into Nushell's autoload directory (`~/.config/nushell/autoload/`).
