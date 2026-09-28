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

Download `nixos.wsl` from the [latest release](https://github.com/nix-community/NixOS-WSL/releases/latest).

If you have WSL version 2.4.4 or later, open (double-click) the `.wsl` file in Windows Explorer, or run:

```powershell
wsl --install --from-file path\to\nixos.wsl
```

Open your NixOS shell:

```powershell
wsl -d NixOS
```

---

### 2. Enter Temporary Shell with Git

A minimal fresh NixOS-WSL installation does not include `git` by default. Launch a temporary shell containing `git`:

```bash
nix-shell -p git
```

---

### 3. Clone Repository to `~/.config/nixos`

Inside the `nix-shell`, clone the repository into your user config directory:

```bash
git clone https://github.com/Donci31/nixos-config.git ~/.config/nixos
```

Exit the temporary `nix-shell` (Git will be installed permanently by the flake):

```bash
exit
```

(Optional, Recommended) Remove the default `/etc/nixos` folder:

```bash
sudo rm -rf /etc/nixos
```

Create a symlink from `/etc/nixos` to your user configuration:

```bash
sudo ln -s /home/nixos/.config/nixos /etc/nixos
```

---

### 4. Build and Switch

Rebuild and activate the configuration:

```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
```

*(Or simply run the following if `/etc/nixos` was symlinked):*

```bash
sudo nixos-rebuild switch
```

---

### 5. Restart WSL Session

Terminate the instance from Windows (PowerShell / Nushell) to ensure the default shell (`nushell`) and environment variables take effect:

```powershell
wsl --terminate NixOS
```

Start your NixOS environment:

```powershell
wsl -d NixOS
```

---

## Day-to-Day Operations

### Apply Changes (Switch)

Rebuild and activate configuration changes:

```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
```

*(Or from anywhere if `/etc/nixos` is symlinked):*

```bash
sudo nixos-rebuild switch
```

---

### Test Build (Dry Run)

Compile the configuration without applying it to verify syntax and derivations (generates a `./result` symlink):

```bash
sudo nixos-rebuild build --flake ~/.config/nixos#nixos --show-trace
```

---

### Update Flake Inputs

Update all inputs (`nixpkgs`, `nixos-wsl`, `home-manager`, `dotfiles`):

```bash
nix flake update --flake ~/.config/nixos
```

Update only the `dotfiles` input (e.g. after pushing changes to your dotfiles repo):

```bash
nix flake update dotfiles --flake ~/.config/nixos
```

Apply the updated inputs:

```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#nixos
```

---

### Local Dotfiles Testing (Override Input)

Test changes from your local Windows dotfiles checkout without pushing to GitHub first:

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
Nix Flakes only evaluate files tracked by Git. If you add new `.nix` files or assets, stage them before rebuilding:

```bash
git -C ~/.config/nixos add -A
```

### Sourcing Custom Nushell Scripts (`extra.nu`)
In Nushell, `source` is evaluated at parse time. If using an optional local script (`~/.config/nushell/extra.nu`), ensure it is handled via the cache pattern in `env.nu` or placed into Nushell's autoload directory (`~/.config/nushell/autoload/`).
