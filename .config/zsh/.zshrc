#!/bin/zsh

# Check if interactive
[[ -o interactive ]] || return

#######################################################
# ZSH CORE SETTINGS & HISTORY
#######################################################

# History stored in .config/zsh/.zsh_history
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.

# Navigation options
setopt AUTOCD                    # If you type a directory name, cd into it.
setopt PUSHD_IGNORE_DUPS         # Don't push multiple copies of the same directory onto the stack.

#######################################################
# ANTIDOTE PLUGIN MANAGER
#######################################################

# Define the path to the plugin list in .config/zsh
zsh_plugins="$ZDOTDIR/.zsh_plugins.txt"

# Ensure antidote is installed
antidote_dir="${ZDG_DATA_HOME:-$HOME/.local/share}/antidote"
if [[ ! -d $antidote_dir ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git "$antidote_dir"
fi

# Source Antidote
source "$antidote_dir/antidote.zsh"

# Load plugins (Generate static file in .config/zsh/.zsh_plugins.zsh)
antidote load "$zsh_plugins"

#######################################################
# ZSH COMPLETION SYSTEM
#######################################################
# (Note: zsh-users/zsh-completions plugin handles most of this, 
# but these settings optimize the menu)

autoload -Uz compinit
compinit -d "$ZDOTDIR/.zcompdump" # Store dump file in .config/zsh

# Case insensitive completion (a -> A)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# Color completion for lists
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Navigation menu for completion (Press tab to cycle through options)
zstyle ':completion:*' menu select

#######################################################
# EXPORTS
#######################################################

unsetopt BEEP

export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Fix for last-working-dir plugin
export ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
[[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"

export LINUXTOOLBOXDIR="$HOME/linuxtoolbox"
export EDITOR=nvim
export VISUAL=nvim

# Colors
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

# Grep
if command -v rg &> /dev/null; then
    alias grep='rg'
else
    alias grep="/usr/bin/grep --color=auto"
fi

# Manpage Colors
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#######################################################
# ALIASES
#######################################################

alias web='cd /var/www/html'
alias ebrc='nvim $ZDOTDIR/.zshrc'
alias eplg='nvim $ZDOTDIR/.zsh_plugins.txt'
alias hlp='less ~/.bashrc_help'
alias da='date "+%Y-%m-%d %A %T %Z"'

alias cp='advcp -i -g'
alias mv='advmv -i -g'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'
alias apt-get='sudo apt-get'
alias multitail='multitail --no-repeat -c'
alias freshclam='sudo freshclam'

alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias svi='sudo -E nvim'
alias vis='nvim "+set si"'
alias spico='sudo pico'
alias snano='sudo nano'

alias yayf="yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:75% | xargs -ro yay -S"

alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias bd='cd "$OLDPWD"'

alias la='ls -Alh'
alias ls='ls -aFh --color=always'
alias lx='ls -lXBh'
alias lk='ls -lSrh'
alias lc='ls -ltcrh'
alias lu='ls -lturh'
alias lr='ls -lRh'
alias lt='ls -ltrh'
alias lm='ls -alh |more'
alias lw='ls -xAh'
alias ll='ls -Fls'
alias labc='ls -lap'
alias lf="ls -l | egrep -v '^d'"
alias ldir="ls -l | egrep '^d'"
alias lla='ls -Al'
alias las='ls -A'
alias lls='ls -l'

alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

alias h="history 0 | grep"
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias f="find . | grep "
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"
alias checkcommand="whence -v"
alias openports='netstat -nape --inet'
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
alias sha1='openssl sha1'
alias clickpaste='sleep 3; xdotool type "$(xclip -o -selection clipboard)"'

alias kssh="kitty +kitten ssh"
alias docker-clean=' \
  docker container prune -f ; \
  docker image prune -f ; \
  docker network prune -f ; \
  docker volume prune -f '

alias hug="systemctl --user restart hugo"
alias lanm="systemctl --user restart lan-mouse"

#######################################################
# FUNCTIONS
#######################################################

# Note: 'extract' function is removed because we are using the 'extract' plugin

ftext() {
    grep -iIHrn --color=always "$1" . | less -r
}

cpp() {
    set -e
    strace -q -ewrite cp -- "${1}" "${2}" 2>&1 |
    awk '{
        count += $NF
        if (count % 10 == 0) {
            percent = count / total_size * 100
            printf "%3d%% [", percent
            for (i=0;i<=percent;i++)
                printf "="
            printf ">"
            for (i=percent;i<100;i++)
                printf " "
            printf "]\r"
        }
    }
    END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

cpg() {
    if [ -d "$2" ]; then cp "$1" "$2" && cd "$2"; else cp "$1" "$2"; fi
}
mvg() {
    if [ -d "$2" ]; then mv "$1" "$2" && cd "$2"; else mv "$1" "$2"; fi
}
mkdirg() {
    mkdir -p "$1" && cd "$1"
}

up() {
    local d=""
    local limit=$1
    for ((i = 1; i <= limit; i++)); do d=$d/..; done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then d=..; fi
    cd $d
}

# Hook to ls after cd
chpwd() { lw }

pwdtail() {
    pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# Distro Detection
distribution() {
    local dtype="unknown"
    if [ -r /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            fedora|rhel|centos) dtype="redhat" ;;
            sles|opensuse*)     dtype="suse" ;;
            ubuntu|debian)      dtype="debian" ;;
            gentoo)             dtype="gentoo" ;;
            arch|manjaro|cachyos) dtype="arch" ;;
            slackware)          dtype="slackware" ;;
            *)
                if [ -n "$ID_LIKE" ]; then
                    case $ID_LIKE in
                        *fedora*|*rhel*|*centos*) dtype="redhat" ;;
                        *sles*|*opensuse*) dtype="suse" ;;
                        *ubuntu*|*debian*) dtype="debian" ;;
                        *gentoo*) dtype="gentoo" ;;
                        *arch*) dtype="arch" ;;
                        *slackware*) dtype="slackware" ;;
                    esac
                fi
                ;;
        esac
    fi
    echo $dtype
}

DISTRIBUTION=$(distribution)
if [ "$DISTRIBUTION" = "redhat" ] || [ "$DISTRIBUTION" = "arch" ]; then
      alias cat='bat'
else
      alias cat='bat'
fi 

install_shell_support() {
    local dtype
    dtype=$(distribution)
    case $dtype in
        "redhat")
            sudo yum install multitail tree zoxide trash-cli fzf fastfetch advcpmv
            ;;
        "suse")
            sudo zypper install multitail tree zoxide trash-cli fzf fastfetch advcpmv
            ;;
        "debian")
            sudo apt-get install multitail tree zoxide trash-cli fzf fastfetch advcpmv
            ;;
        "arch")
            sudo yay -S multitail tree zoxide trash-cli fzf fastfetch advcpmv bat
            ;;
        *)
            echo "Unknown distribution"
            ;;
    esac
}

alias whatismyip="whatsmyip"
function whatsmyip () {
    if command -v ip &> /dev/null; then
        echo -n "Internal IP: "
        ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1
    else
        echo -n "Internal IP: "
        ifconfig wlan0 | grep "inet " | awk '{print $2}'
    fi
    echo -n "External IP: "
    curl -4 ifconfig.me
}

apacheconfig() {
    if [ -f /etc/httpd/conf/httpd.conf ]; then sedit /etc/httpd/conf/httpd.conf
    elif [ -f /etc/apache2/apache2.conf ]; then sedit /etc/apache2/apache2.conf
    else echo "Apache config not found."; fi
}
phpconfig() {
    if [ -f /etc/php.ini ]; then sedit /etc/php.ini
    elif [ -f /etc/php/php.ini ]; then sedit /etc/php/php.ini
    else echo "php.ini not found."; fi
}
mysqlconfig() {
    if [ -f /etc/my.cnf ]; then sedit /etc/my.cnf
    elif [ -f /etc/mysql/my.cnf ]; then sedit /etc/mysql/my.cnf
    else echo "my.cnf not found."; fi
}

gcom() { git add . && git commit -m "$1"; }
lazyg() { git add . && git commit -m "$1" && git push; }
function hb {
    if [ $# -eq 0 ]; then echo "No file path specified."; return; fi
    uri="http://bin.christitus.com/documents"
    response=$(curl -s -X POST -d @"$1" "$uri")
    if [ $? -eq 0 ]; then
        hasteKey=$(echo $response | jq -r '.key')
        echo "http://bin.christitus.com/$hasteKey"
    else
        echo "Failed to upload the document."
    fi
}

#######################################################
# KEYBINDINGS & INIT
#######################################################

bindkey -e 
bindkey -s '^f' 'zi\n'

# History Search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

export PATH=$PATH:"$HOME/.local/bin:$HOME/.cargo/bin:/var/lib/flatpak/exports/bin:/.local/share/flatpak/exports/bin"

if command -v fastfetch &> /dev/null; then fastfetch; fi

# eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
