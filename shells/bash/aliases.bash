#!/usr/bin/env bash
#
# User defined aliases

THIS_SHELL=`ps o command -p $$ | grep -v "^COMMAND$" | tr -d '-' | cut -d' ' -f1`
case "${THIS_SHELL}" in
  bash|ksh|zsh) ;;
  *) >&2 echo "This script probably wont work with your shell, so bailing out now...bye!";
     exit 1;;
esac

OS=$(uname -s)

if [ $OS == "FreeBSD" ]; then

  alias eg='egrep -i'
  alias h='fc -l'
  alias iotop='top -mio -ototal'
  alias j=jobs
  alias l='ls -lG'
  alias links='elinks'
  alias ll='ls -lAFGo'
  alias lld='ls -lAFodG'
  alias ls='/bin/ls -FG'
  alias lsof='fstat'
  alias lynx='elinks'
  alias m=more
  alias pgr='vi -R'
  alias pkg_check='pkg_libchk'
  alias pkg_locate="echo /usr/ports/*/*|tr ' ' '\n'"
  alias portaudit='/usr/sbin/pkg audit -F'
  alias su='su -l'
  alias stats="man -k '*' | grep -Ee 'stat\((1|8)\) '"

else

  #alias ls='/bin/ls --color=always'
  alias vibb='vim.tiny -u ~/.vim/vim-bare-bones.vim'
  alias bbvi='vim.tiny -u ~/.vim/vim-bare-bones.vim'
  alias lsn='ls -pF --color=none'
  alias ls='ls --color=always --ignore="NTUSER.*" --ignore="ntuser.*" -F --group-directories-first'
  alias la='ls -lAhFt --time-style=+"%Y-%b-%d %H:%S"'
  alias lc='ls -FCp -w 120|less -FRMS'
  alias lld='ls -lhdFt --time-style=+"%Y-%b-%d %H:%S"'
  alias later='ll -tr'
  alias lltr='ll -tr'
  alias ltr='ll -tr'
  alias stats="man -k ' ' | grep -Ee 'stat \((1|8)\) '"

fi

alias ..='cd ..'
alias ...='cd ../..'
alias ack='ack-grep'
alias alldoc="cat $HOME/repos/dotfiles/doc/*-tips"
alias cd..='cd ..'
alias cls='clear'
alias cpi='cp -i'
alias cpu='cp -u'
alias cpr='cp -r'
alias cpa='cp -a'
alias cv='type -a'
alias dfh="df -h|egrep '^(Filesystem|/)'| sort -hk5"
alias e='emacs'
alias em='emacs'
alias emcas='emacs'
alias ft='tree -I .git -I "*.png" --charset UTF-8 --dirsfirst -F'
alias gnupg='gpg'
alias grep='grep --color=always -i'
alias gvim-server='gvim --servername GVIM'
alias gvim-send-to-remote-server='gvim --remote-tab-silent'
alias heman='eman'
#alias lsc='ls | cut -c1-50 | column -c "${COLUMNS:-80}"'
alias lsd='ls -d *'
alias lsf='ls-files-only'
alias lsaf='ls-all-files-only'
alias make='make -j `grep -wc "^processor" /proc/cpuinfo`'
alias mvi='mv -i'
alias pacman='sudo pacman'
alias pg='less -Feq'
alias python='/usr/bin/python3'
alias re='recent'
alias rehash='hash -r'
alias reset='reset -e ^?'
alias sau='sudo apt update'
#alias sadu='sudo apt update; sudo apt dist-upgrade'
#alias saru='sudo apt autoremove'
alias sbcl='rlwrap sbcl'
alias sus='/usr/bin/systemctl hybrid-sleep -i'
alias ssh-add-fingerprint='ssh-add -l -E md5'
alias sysdoc="cat $HOME/repos/dotfiles/doc/systemd-tips"
#alias tree='tree -I .git --charset UTF-8 -push'
alias tree='tree -I .git --charset UTF-8 --dirsfirst -F'
alias trd2='trd 2 -d'
alias trd3='trd 3 -d'
alias ftree='tree -I .git -I "*.png" --charset UTF-8 --dirsfirst -F'
alias tmux='TERM=tmux-256color tmux -u'
alias vi='vim'
alias vb='/usr/local/bin/vimb 2>/dev/null &'
alias vimb='/usr/local/bin/vimb 2>/dev/null &'

alias 0xMF-doc-pacman="showdoc $HOME/repos/dotfiles/doc/pacman"
alias 0xMF-doc-pcre="showdoc $HOME/repos/dotfiles/doc/re"
alias 0xMF-doc-perl="0xMF-doc-pcre"
alias 0xMF-doc-vim="showdoc $HOME/repos/dotfiles/doc/vim"
alias pacdoc="0xMF-doc-pacman"
alias vimdoc="0xMF-doc-vim"
alias reload=". ~/.bashrc"

# vim:nospell:ft=sh:
