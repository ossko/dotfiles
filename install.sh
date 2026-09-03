#!/bin/sh
set -e

HELIX_VERSION=25.07.1
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

case "$(uname -m)" in
  x86_64)  ARCH=x86_64 ;;
  aarch64) ARCH=aarch64 ;;
  *) echo "unsupported arch" >&2; exit 1 ;;
esac

# Helix: binary + runtime
if [ ! -x "$HOME/.local/opt/helix/hx" ]; then
  mkdir -p "$HOME/.local/opt/helix" "$HOME/.local/bin"
  curl -fsSL "https://github.com/helix-editor/helix/releases/download/${HELIX_VERSION}/helix-${HELIX_VERSION}-${ARCH}-linux.tar.xz" \
    | tar -xJ -C "$HOME/.local/opt/helix" --strip-components=1
  ln -sf "$HOME/.local/opt/helix/hx" "$HOME/.local/bin/hx"
fi

# Config
mkdir -p "$HOME/.config/helix"
ln -sf "$DOTFILES/helix/config.toml"    "$HOME/.config/helix/config.toml"
ln -sf "$DOTFILES/helix/languages.toml" "$HOME/.config/helix/languages.toml"

# Shell
grep -q 'dotfiles bootstrap' "$HOME/.bashrc" 2>/dev/null || cat >> "$HOME/.bashrc" <<EOF

# dotfiles bootstrap
export PATH="\$HOME/.local/bin:\$PATH"
export HELIX_RUNTIME="\$HOME/.local/opt/helix/runtime"
export EDITOR=hx
. "$DOTFILES/.bashrc.local"
EOF

echo "dotfiles installed"
