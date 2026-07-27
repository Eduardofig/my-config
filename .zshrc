export PATH="/opt/homebrew/opt/php@8.4/bin:$PATH"

# nohup find ~/ > /dev/null 2>&1

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export OPENCODE_YOLO=true

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export DISABLE_FZF_KEY_BINDINGS="false"
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/.toolbox/bin
export PERSONAL_BINDLE_ID="amzn1.bindle.resource.35vyroq6lwuwf3jv56kjnpqjq"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="mh" # set by `omz`

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git vi-mode web-search colorize fzf)

source $ZSH/oh-my-zsh.sh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"

# fdh() {
#     echo $(find ~/ -type d -print | fzf)
# }
#
# fd() {
#     echo $(find . -type d -print | fzf)
# }
#
# ffh() {
#     echo $(find ~/ -type f -print | fzf)
# }
#
# ff() {
#     echo $(find . -type f -print | fzf)
# }
#
#
alias n="nvim"
alias c="clear"
alias l="exa"
alias q="exit"
alias bb="brazil-build"
alias lg="lazygit"
alias cc="aifx agent run claude --dangerously-skip-permissions"
# opencode: macOS invalidates the ad-hoc signature of the Bun-compiled opencode
# binary after it updates, so AMFI SIGKILLs it ("Error: signal: killed", exit 137)
# on later launches until a reboot. Re-sign ad-hoc when the signature is invalid,
# then launch with --no-update so aifx can't rewrite (and re-break) it in the same run.
opencode-ensure-sig() {
  local bin="$HOME/.opencode/bin/opencode"
  if [[ -x "$bin" ]] && ! codesign --verify "$bin" >/dev/null 2>&1; then
    print -P "%F{yellow}opencode:%f re-signing binary (macOS invalidated its code signature)…" >&2
    codesign --force --sign - "$bin" >/dev/null 2>&1
  fi
}
oc() { opencode-ensure-sig; aifx agent run opencode --no-update --auto "$@"; }
# pull updates on demand, then immediately re-sign so the next launch works
oc-update() { aifx agent update opencode "$@"; codesign --force --sign - "$HOME/.opencode/bin/opencode" >/dev/null 2>&1 && print -P "%F{green}opencode:%f updated and re-signed."; }
alias cat="bat"
#
# alias cf="cd \$(fd)"
# alias cfh="cd \$(fdh)"
#
# alias nf="nvim \$(ff)"
# alias nd="nvim \$(fd)"
# alias ndh="nvim \$(fdh)"
# alias nfh="nvim \$(ffh)"
# alias nfd="nvim \$(fd)"
# alias nfdh="nvim \$(fdh)"
alias ee=open
# alias ohmyzsh="mate ~/.oh-my-zsh"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# source /Users/eduardoffa19/.local/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH=/Users/eduardoffa19/.cargo/bin:$PATH
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/Users/eduardoffa19/go/bin
export PATH=$PATH:/Users/eduardoffa19/.local/bin
#source /Users/eduardoffa19/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export OPENAI_API_KEY=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
export EDITOR="nvim"

# pnpm
export PNPM_HOME="/Users/eduardoffa19/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# bun completions
[ -s "/Users/eduardoffa19/.bun/_bun" ] && source "/Users/eduardoffa19/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export TERM="xterm-256color"

bindkey '^h' autosuggest-accept
export OPENAI_KEY=
export PATH=$PATH:/usr/local/bin

export DB_URL='postgres://postgres:lo981582@localhost:5432/dogs'
# export SEARCH_API_KEY='AIzaSyCFOEOTtLACroQcGVWs-E-Lufh5wJjGn80'

bindkey -r '^[c'
eval "$(zoxide init zsh)"

export VISUAL='nvim'
export FZF_DEFAULT_COMMAND="fd . $HOME"
export FZF_CTRL_T_COMMAND="fd . $HOME"

docker-ip() {
        docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

export EDUARDO_AGE=23
export ARTEMIO_AGE=23

function zr () { zellij run --name "$*" -- zsh -ic "$*";}
function zrf () { zellij run --name "$*" --floating -- zsh -ic "$*";}
function ze () { zellij edit "$*";}
function zef () { zellij edit --floating "$*";}
# eval "$(gh copilot alias -- zsh)"

alias zs="zellij -l compact -s "
alias za="zellij a"
alias zd="zellij d"
alias zka="zellij ka"
alias zda="zellij da"
alias zls="zellij ls"

function toon {
  echo -n ""
}

autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '%F{red}*'   # display this when there are unstaged changes
zstyle ':vcs_info:*' stagedstr '%F{yellow}+'  # display this when there are staged changes
zstyle ':vcs_info:*' actionformats '%F{5}[%F{2}%b%F{3}|%F{1}%a%c%u%F{5}]%f '
zstyle ':vcs_info:*' formats '%F{5}[%F{2}%b%c%u%F{5}]%f '
zstyle ':vcs_info:svn:*' branchformat '%b'
zstyle ':vcs_info:svn:*' actionformats '%F{5}[%F{2}%b%F{1}:%F{3}%i%F{3}|%F{1}%a%c%u%F{5}]%f '
zstyle ':vcs_info:svn:*' formats '%F{5}[%F{2}%b%F{1}:%F{3}%i%c%u%F{5}]%f '
zstyle ':vcs_info:*' enable git cvs svn

theme_precmd () {
  vcs_info
}

setopt prompt_subst
PROMPT='%{$fg[white]%}$(toon)%{$reset_color%} %~/ %{$reset_color%}${vcs_info_msg_0_}%{$reset_color%}'

autoload -U add-zsh-hook
add-zsh-hook precmd theme_precmd

# source "$HOME/.sdkman/bin/sdkman-init.sh"

export PATH=$PATH:$HOME/.toolbox/bin

# export PERSONAL_ACCOUNT_ID=908027422333
# export PERSONAL_REGION=us-west-2
# export PERSONAL_ALIAS=eduardoffa19
# export PERSONAL_STACK=true

export PERSONAL_ACCOUNT_ID=242201289313
export PERSONAL_ALIAS=lufuzina
export PERSONAL_REGION=us-west-2
export PERSONAL_STACK=true

export AWS_ACCOUNT_ID=$PERSONAL_ACCOUNT_ID
export AWS_REGION=$PERSONAL_REGION
export DISAMBIGUATOR=$PERSONAL_ALIAS
export PERSONAL_AWS_REGION=$PERSONAL_REGION
export JDTLS_JVM_ARGS="-javaagent:$HOME/Downloads/lombok.jar"
export _JAVA_OPTIONS="-javaagent:$HOME/Downloads/lombok.jar"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/eduardoffa19/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/eduardoffa19/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/eduardoffa19/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/eduardoffa19/google-cloud-sdk/completion.zsh.inc'; fi

export AIFX_ENABLE_PRIVATE_PREVIEW_FEATURES=true
eval "$(direnv hook zsh)"
export NVM_DIR="$HOME/.nvm"
[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh

export AIFX_AGENT_CLAUDE_USE_MA_VERTEX=1

alias '??'='noglob ??'

# opencode
export PATH=/Users/eduardoffa19/.opencode/bin:$PATH
