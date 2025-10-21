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
export R_MODE="dir-only"  # Path display mode: full, short, or dir-only
export R_CODE="1"         # Show exit codes: 0=hidden, 1=non-zero only
export R_MIN="4"          # Minimum seconds before showing execution time
export R_USR="%n"         # Username format: %n (user), %m (host), or %n@%m

# Load the prompt plugin first
zinit light "metaory/zsh-roundy-prompt"


# ==============================================================================
# Custom Color Theme for zsh-roundy-prompt
# ==============================================================================
# Override the RT color theme AFTER the plugin loads.
# The plugin creates default RT values, so we need to override them here.
#
# Color Palette:
#   - #fc9b0a : Orange (icon pill & username pill backgrounds, git text, ">" prompt)
#   - #45403d : Dark grey (directory pill & git pill backgrounds)
#   - #a5a2a2 : Light grey (directory text & execution time on input line)
#   - #090300 : Deep black (icon & username text)
#   - white   : White text (error text)
# ==============================================================================

# Success State (left pill - first pill with icon)
RT[bg_ok]="#fc9b0a"       # Orange background
RT[fg_ok]="#090300"       # Deep black text
# --- ICON OPTIONS: Uncomment your favorite! ---
# RT[icon_ok]="☕"           # 1. Coffee cup
# RT[icon_ok]=""
# RT[icon_ok]=""
# RT[icon_ok]=""
RT[icon_ok]=" "
# RT[icon_ok]="󱠛"
# RT[icon_ok]=""
# RT[icon_ok]=""
# RT[icon_ok]=""

# Error State (left pill when command fails)
RT[bg_err]="#fc9b0a"      # Orange background (same as success for consistency)
RT[fg_err]="white"        # White text
RT[icon_err]="✘"          # X mark icon

# Directory Path Display (grey pill after icon)
RT[bg_dir]="#45403d"      # Dark grey background
RT[fg_dir]="#a5a2a2"      # Light grey text

# Username Display (right side - orange pill)
RT[bg_usr]="#fc9b0a"      # Orange background
RT[fg_usr]="#090300"      # Deep black text

# Git Branch Display (right side - grey pill when in a git repo)
RT[bg_git]="#45403d"      # Dark grey background
RT[fg_git]="#fc9b0a"      # Orange text

# Execution Time Display (shown on input line after command execution)
# Note: Time is displayed as plain grey text on the input line (no pill background)
# The settings below are kept for reference but not currently used
RT[bg_time]="#45403d"     # [Not used] Dark grey background
RT[fg_time]="#fc9b0a"     # [Not used] Orange text
RT[icon_time]="󱑆"         # [Not used] Stopwatch icon

# ==============================================================================
# Custom Prompt Modification - Multi-line with "> " input indicator
# ==============================================================================
# This function runs after the plugin's precmd to:
# 1. Build first line: icon + directory (left) | username + git (right)
# 2. Add second line with orange ">" for command input
# 3. Show execution time in plain grey text on input line (only after command runs)

# Helper functions from the plugin (needed to rebuild prompt segments)
seg() { echo "%F{$1}%K{${2:-default}}$R_RIGHT${3:-}" }
seg_s() { echo " %k%F{$1}$R_LEFT%K{$1}%F{$2}${3:-}" }
seg_e() { echo "%F{$1}%k$R_RIGHT%f" }
status_color() { echo "%(?.${1}.%130(?.${1}.${2}))" }

custom_prompt_newline() {
  # Capture the last exit code
  local last_exit=$?

  # Build the right-aligned status line (time and/or error code)
  local status_line=""
  local has_time=0
  local has_error=0

  # Check if we have execution time
  if [[ -n "$RR_TIME" ]]; then
    status_line="$RR_TIME"
    has_time=1
  fi

  # Check if we have a non-zero exit code (and R_CODE is enabled)
  if [[ $last_exit -ne 0 && "${R_CODE}" == "1" ]]; then
    # Add error code in orange, with separator if we have time
    if [[ $has_time -eq 1 ]]; then
      status_line="${status_line}  "
    fi
    # Add the exit code in orange (no pill, just text)
    status_line="${status_line}\e[38;2;252;155;10m✘ ${last_exit}\e[0m"
    has_error=1
  fi

  # Print the status line if we have anything to show
  if [[ -n "$status_line" ]]; then
    # Calculate actual text length without ANSI codes
    local text_len=0
    if [[ $has_time -eq 1 ]]; then
      text_len=$((text_len + ${#RR_TIME}))
    fi
    if [[ $has_error -eq 1 ]]; then
      # "✘ " is 2 chars + exit code length
      text_len=$((text_len + 2 + ${#last_exit}))
    fi
    if [[ $has_time -eq 1 && $has_error -eq 1 ]]; then
      # Add separator space
      text_len=$((text_len + 2))
    fi

    local term_width=${COLUMNS:-80}
    local padding=$((term_width - text_len))

    # Print time in grey, error in orange
    if [[ $has_time -eq 1 && $has_error -eq 0 ]]; then
      printf "%${padding}s\e[38;5;248m%s\e[0m\n" "" "$RR_TIME"
    elif [[ $has_time -eq 1 && $has_error -eq 1 ]]; then
      printf "%${padding}s\e[38;5;248m%s\e[0m  \e[38;2;252;155;10m✘ %s\e[0m\n" "" "$RR_TIME" "$last_exit"
    else
      # Only error
      printf "%${padding}s\e[38;2;252;155;10m✘ %s\e[0m\n" "" "$last_exit"
    fi
  fi

  # Rebuild PROMPT without time: [status_icon][directory]
  # Always use success colors and icon (coffee mug) - never show error icon
  local bg="${RT[bg_ok]}"
  local fg="${RT[fg_ok]}"
  local icon="${RT[icon_ok]}"

  # Build left side: status icon + directory (no leading space, no trailing space)
  PROMPT="%k%F{$bg}$R_LEFT%K{$bg}%F{$fg}$icon$(seg "$bg" ${RT[bg_dir]})"
  PROMPT="${PROMPT}%F{${RT[fg_dir]}}${RR_DIR}$(seg_e ${RT[bg_dir]})"

  # Build right side of first line: username + git (no exit code)
  # Reconstruct RPROMPT without exit code by building username and git pills properly
  local first_line_right=""

  # Start with username pill
  first_line_right+="%k%F{${RT[bg_usr]}}$R_LEFT%K{${RT[bg_usr]}}%F{${RT[fg_usr]}} ${R_USR} "

  # Add git pill if in a git repo (connected to username pill)
  if [[ -n "$RR_GIT" ]]; then
    # Transition from username pill to git pill
    first_line_right+="$(seg ${RT[bg_usr]} ${RT[bg_git]})"
    first_line_right+="%F{${RT[fg_git]}}${RR_GIT} "
    # End git pill
    first_line_right+="$(seg_e ${RT[bg_git]})"
  else
    # End username pill if no git
    first_line_right+="$(seg_e ${RT[bg_usr]})"
  fi

  # Calculate spacing for right alignment on first line
  local prompt_len=${#${(S%%)PROMPT//(\%([KF1]|)\{*\}|\%[Bbkf])}}
  local rprompt_len=${#${(S%%)first_line_right//(\%([KF1]|)\{*\}|\%[Bbkf])}}
  local term_width=${COLUMNS:-80}
  local spaces=1
  [[ $spaces -lt 2 ]] && spaces=2

  # Combine first line with spacing, then add newline with orange ">" or 󰸷 󱞩  (oldcollor #a6da95)
  PROMPT="${PROMPT}${(l:$spaces:: :)}${first_line_right}"$'\n%F{#9f9b9b}    󱞩 %f'

  # Clear RPROMPT - we don't need it on the input line anymore
  RPROMPT=""
}

# Add our custom function to run after the plugin's precmd
precmd_functions+=( custom_prompt_newline )
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

# Now that the completion system is loaded and our functions are defined,
# we can assign file completion rules to them.
compdef _files nvim
compdef _files vim
# ==============================================================================


# History settings
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
