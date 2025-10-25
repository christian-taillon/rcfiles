# ==============================================================================
# This file is sourced when Zsh starts interactively.
# ==============================================================================

# ==============================================================================
# Zinit Plugin Manager
# ==============================================================================

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load Zinit annexes
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### Load Oh My Zsh and Plugins via Zinit ###
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::docker
zinit light "wbingli/zsh-wakatime"
zinit light "zsh-users/zsh-autosuggestions"
zinit light "zsh-users/zsh-syntax-highlighting"

# Configure zsh-roundy-prompt environment variables BEFORE loading
export R_MODE="full"      # Path display mode: full, short, or dir-only
export R_CODE="1"         # Show exit codes: 0=hidden, 1=non-zero only
export R_MIN="4"          # Minimum seconds before showing execution time
export R_USR="%n"         # Username format: %n (user), %m (host), or %n@%m

# Load the prompt plugin first
zinit light "metaory/zsh-roundy-prompt"


# ==============================================================================
# ZSH Theme System - Select and Load Theme
# ==============================================================================
# Available themes:
#   - ~/.zsh_theme-orange.zsh         : Original orange theme
#   - ~/.zsh_theme-color-pop-oled.zsh : New bright color-pop theme
#
# To switch themes, comment/uncomment the desired source line below.
# ==============================================================================

# Theme Selection (uncomment one theme to activate)
# source ~/.zsh_theme-orange.zsh           # Original orange theme
# source ~/.zsh_theme-color-pop-oled.zsh     # New color-pop-oled theme (with time/error)
source ~/.zsh_theme-fast.zsh                # Fast version - no time/error display
### End of Zinit's installer chunk

# ==============================================================================
# Core Zsh Configuration
# ==============================================================================

# Load completion system
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

# ==============================================================================
# Custom Functions & Completions for Flatpak Neovim (CORRECT & ROBUST METHOD)
# ==============================================================================
# A function is more reliable for completion than an alias.

unalias nvim 2>/dev/null || true
unalias vim 2>/dev/null || true
nvim() {
    # This function runs the flatpak command and passes all arguments ($@) to it.
    flatpak run io.neovim.nvim "$@"
}

vim() {
    # This function just calls our nvim function.
    nvim "$@"
}

export EDITOR=vim

# Now that the completion system is loaded and our functions are defined,
# we can assign file completion rules to them.
compdef _files nvim
compdef _files vim
# ==============================================================================


# History settings
fc -R ~/.zsh_history
setopt HIST_IGNORE_SPACE
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_VERIFY

# ==============================================================================
# Path and Environment Variables
# ==============================================================================

# Load aliases and secrets from separate files if they exist
[[ -e ~/.zsh_aliases ]] && source ~/.zsh_aliases
[[ -e ~/.zsh_secrets ]] && source ~/.zsh_secrets

# Golang configuration
export GOROOT=/usr/local/go
export GOPATH=$HOME/go

# Ruby for Jekyll
export PATH="$HOME/.local/share/gem/ruby/3.3.0/bin:$PATH"

# Path configuration
path=(
  $GOROOT/bin
  $GOPATH/bin
  $HOME/.local/bin
  ~/.npm-global/bin
  $path
)
export PATH
export PATH="$HOME/.local/bin:$PATH" # Ensure .local/bin is present

# ==============================================================================
# Lazy-load NVM (Node Version Manager)
# ==============================================================================
export NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]]; then
  nvm() {
    unfunction nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
  }
  node() {
    unfunction node; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; node "$@"
  }
  npm() {
    unfunction npm; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npm "$@"
  }
  yarn() {
    unfunction yarn; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; yarn "$@"
  }
fi

# ==============================================================================
# System-specific Settings
# ==============================================================================
export MUTTER_DEBUG_DISABLE_HW_CURSORS=1 # Fix HW Mouse Stuttering
fpath+=~/.zfunc # Add custom function directories to fpath
source /home/christian/.config/broot/launcher/bash/br # Broot config

# ==============================================================================
# Terminal and Key Bindings
# ==============================================================================
export TERM=xterm-256color
bindkey -e
bindkey "^[[3~" delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[A" up-line-or-history
bindkey "^[[B" down-line-or-history

# ==============================================================================
# BACKUP: Custom Prompt Configuration (not currently active)
# ==============================================================================
# Uncomment the section below to use custom prompt instead of zsh-roundy-prompt
#
# autoload -U colors && colors
# autoload -Uz vcs_info
# setopt prompt_subst
# zstyle ':vcs_info:git:*' formats ' %F{#e3992a}(%b)%f'
# zstyle ':vcs_info:*' enable git
# precmd_vcs_info() { vcs_info }
# precmd_blank_line() { print '' }
# precmd_functions+=( precmd_vcs_info precmd_blank_line )
# PROMPT=$'╭─%K{#feb17f}%F{black}%B %n %b%f%k─\n╰─ %F{#a5a2a2}%~%f${vcs_info_msg_0_}\n  %F{#d56a26}● %f%F{#a5a2a2}'
