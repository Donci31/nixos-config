#!/usr/bin/env bash
set -e
export PATH="$PATH:/run/current-system/sw/bin"
sudo env "PATH=$PATH" nixos-rebuild switch --flake /etc/nixos#nixos
