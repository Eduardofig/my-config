# nohup find ~/ > /dev/null 2>&1
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export DISABLE_FZF_KEY_BINDINGS="false"
export PATH=$PATH:/usr/local/go/bin

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="mh" # set by `omz`

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
plugins=(git vi-mode web-search colorize fzf zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

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
alias n="~/.local/nvim-linux64/bin/nvim"
alias c="clear"
alias l="ls"
alias q="exit"
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
alias ee=explorer.exe
# alias ohmyzsh="mate ~/.oh-my-zsh"
# alias ohmyzsh="mate ~/.oh-my-zsh"
source /home/duzinho039/.local/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH=/home/duzinho039/.cargo/bin:$PATH
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/home/duzinho039/go/bin
export PATH=$PATH:/home/duzinho039/.local/bin
#source /home/duzinho039/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export OPENAI_API_KEY=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
export EDITOR="/usr/bin/nvim"

# pnpm
export PNPM_HOME="/home/duzinho039/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# bun completions
[ -s "/home/duzinho039/.bun/_bun" ] && source "/home/duzinho039/.bun/_bun"

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

export EDITOR="~/.local/nvim-linux64/bin/nvim"
export VISUAL='nvim'
export FZF_DEFAULT_COMMAND="fdfind . $HOME"
export FZF_CTRL_T_COMMAND="fdfind . $HOME"

docker-ip() {
        docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

export EDUARDO_AGE=23
export ARTEMIO_AGE=23

function zr () { zellij run --name "$*" -- zsh -ic "$*";}
function zrf () { zellij run --name "$*" --floating -- zsh -ic "$*";}
function ze () { zellij edit "$*";}
function zef () { zellij edit --floating "$*";}
eval "$(gh copilot alias -- zsh)"

alias zs="zellij -l compact -s "
alias za="zellij a"
alias zd="zellij d"
alias zka="zellij ka"
alias zda="zellij da"
alias zls="zellij ls"
