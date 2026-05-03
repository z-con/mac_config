#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"
CONFIG="$HOME/.config"

# ── Homebrew ────────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ── CLI tools ───────────────────────────────────────────────────────────────────
brew install \
    fish \
    starship \
    tmux \
    neovim \
    lazygit \
    gh \
    git \
    uv \
    ripgrep \
    fd \
    fzf \
    btop

# Yabai + skhd are on their own tap
brew tap koekeishiya/formulae
brew install yabai skhd

# ── Fonts ───────────────────────────────────────────────────────────────────────
brew install --cask font-meslo-lg-nerd-font

# ── Apps ────────────────────────────────────────────────────────────────────────
brew install --cask ghostty

# ── Symlink configs ─────────────────────────────────────────────────────────────
symlink() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "Backing up existing $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sfn "$src" "$dst"
    echo "  $dst → $src"
}

echo ""
echo "Symlinking configs..."

symlink "$DOTFILES/.config/yabai"         "$CONFIG/yabai"
symlink "$DOTFILES/.config/skhd"          "$CONFIG/skhd"
symlink "$DOTFILES/.config/fish"          "$CONFIG/fish"
symlink "$DOTFILES/.config/tmux"          "$CONFIG/tmux"
symlink "$DOTFILES/.config/nvim"          "$CONFIG/nvim"
symlink "$DOTFILES/.config/git"           "$CONFIG/git"
symlink "$DOTFILES/.config/lazygit"       "$CONFIG/lazygit"
symlink "$DOTFILES/.config/ghostty"       "$CONFIG/ghostty"
symlink "$DOTFILES/.config/starship.toml" "$CONFIG/starship.toml"

chmod +x "$CONFIG/yabai/yabairc"

# ── Start services ──────────────────────────────────────────────────────────────
yabai --start-service
skhd --start-service

# ── Fish as default shell ────────────────────────────────────────────────────────
FISH_PATH="$(brew --prefix)/bin/fish"
if ! grep -q "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "$FISH_PATH" ]; then
    chsh -s "$FISH_PATH"
    echo "Default shell set to fish — restart your terminal."
fi

# ── Permissions ─────────────────────────────────────────────────────────────────
echo ""
echo "Grant Accessibility access in System Settings → Privacy & Security → Accessibility:"
echo "    ✓ Yabai"
echo "    ✓ skhd"

echo ""
echo "Done. Open a new terminal to pick up fish + starship."
