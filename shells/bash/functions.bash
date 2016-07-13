#!/usr/bin/env bash
#

# user defined aliases .bash
#

OS=$(uname -s)
export PROMPT_COMMAND="ps1;$PROMPT_COMMAND"

BLACK="\[\033[30m\]"
GREY="\[\033[1;30m\]"
RED="\[\033[1;31m\]"
GREEN="\[\033[1;32m\]"
YELLOW="\[\033[1;33m\]"
BLUE="\[\033[1;34m\]"
PURPLE="\[\033[1;35m"
CYAN="\[\033[1;36m\]"
WHITE="\[\033[1;37m\]"
NOCOLOR="\[\033[00m\]"

function dark {
  # yellow dir
  LS_COLORS="`echo $LS_COLORS|sed 's/di=0[01];3[0-9]/di=01;34:/'`"
  # cyan link
  LS_COLORS="`echo $LS_COLORS|sed 's/ln=0[01];3[0-9]/ln=00;36:/'`"
  # green executables
  LS_COLORS="`echo $LS_COLORS|sed 's/ex=0[01];3[0-9]/ex=00;32:/'`"
  export LS_COLORS
}

function light {
  # black dir
  # LS_COLORS="`echo $LS_COLORS|sed 's/di=01;33/di=00;30:/'`"
  # brown dir
  LS_COLORS="`echo $LS_COLORS|sed 's/di=0[01];3[0-9]/di=00;34:/'`"
  # purple link
  LS_COLORS="`echo $LS_COLORS|sed 's/ln=0[01];3[0-9]/ln=01;35:/'`"
  # green executables
  LS_COLORS="`echo $LS_COLORS|sed 's/ex=0[01];3[0-9]/ex=00;32:/'`"
  export LS_COLORS
}

function parse_git_branch {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

function parse_git_branch_colour {
  br=$(parse_git_branch)
  if [ -z "$br" ]; then
    return
  elif [ "$br" == "master" ]; then
    echo " $BLUE($RED"$br"$BLUE $(parse_git_dirty)$BLUE)"
  else
    echo " $BLUE($YELLOW"$br"$BLUE $(parse_git_dirty)$BLUE)"
  fi
}

function parse_git_dirty {
  local unchanged="$GREEN✔$NOCOLOR"
  local changed="$RED✗$NOCOLOR"
      sts=$(git status --porcelain 2>&1)
      if [ -z "$sts" ]; then
        echo $unchanged
      else
        echo $changed
      fi
}

function old_parse_git_dirty {

  local large_repos=~/.bash_git_large_repos
  local unchanged="$GREEN✔$NOCOLOR"
  local changed="$RED✗$NOCOLOR"
  local sts_skip="$RED❔$YELLOW❓$GREEN❓$NOCOLOR"

  # check for large repo (fastest)
  #[ -n "$GIT_LARGE_REPO" ] && echo $sts_skip && return
  [ ! -e /usr/bin/time ] && {
      sts=$(git status --porcelain 2>&1)
      if [ -z "$sts" ]; then
        echo $unchanged
      else
        echo $changed
      fi
      return
  }


  # (slower) check for large repo in filenames of all large repos
  $GREP -qw "$PWD$" $large_repos 2>/dev/null
  if [ $? -eq 0 ]; then
    echo $sts_skip
  else
    # not in list of large repos, run a one time check for this being a large repo
    if [ $OS == "FreeBSD" ]; then
      sts=$(/usr/bin/time -p git status --porcelain 2>&1)
      echo $sts
    else
      sts=$(/usr/bin/time -f "%E" git status --porcelain 2>&1)
      secs=$(echo "$sts"|tail -1 |cut -d: -f2|cut -d. -f1)
      secs=${secs:-0}

      # do we need to add it to the list of large repos?
      if [ $secs -gt 1 ]; then
          echo "$PWD" >> $large_repos
          export GIT_LARGE_REPO="$PWD"
          echo $sts_skip && return
      fi
    fi

    lns=$(echo "$sts"|wc -l)
    if [ $lns -eq 1 ]; then
      echo $unchanged
    else
      echo $changed
    fi
  fi
}

# Edit your current day's todo list.
function todo(){
  ${EDITOR:-/usr/local/bin/vim} + ~/$(date +todolist-%Y%m%d);
}

function ps1 {
  if [ `id -u` -eq 0 ]; then
    PS1="$RED${OSRV}$BLUE:\w$(parse_git_branch_colour)$RED#$NOCOLOR "
  else
    PS1="$GREEN${OSRV}$BLUE:\w$(parse_git_branch_colour)$NOCOLOR$ "
  fi
  PROMPT_COMMAND="ps1"
}

function psh {
  if [ `id -u` -eq 0 ]; then
    PS1="$RED\h:\W$(parse_git_branch_colour)$RED#$NOCOLOR "
  else
    PS1="$BLUE\h:\W$(parse_git_branch_colour)$NOCOLOR$ "
  fi
  PROMPT_COMMAND="psh"
}

function pss {
  if [ `id -u` -eq 0 ]; then
    PS1="$RED\W$(parse_git_branch_colour)$RED#$NOCOLOR "
  else
    PS1="$BLUE\W$(parse_git_branch_colour)$NOCOLOR$ "
  fi
  PROMPT_COMMAND="pss"
}

function psl {
  if [ `id -u` -eq 0 ]; then
    PS1="$PURPLE\W$(parse_git_branch_colour)$RED#$NOCOLOR "
  else
    PS1="$CYAN\W$(parse_git_branch_colour)$NOCOLOR$ "
  fi
  PROMPT_COMMAND="psl"
}

function psd {
  dark
}
function poof {
  sudo sync
  sudo sync
  sudo sync
  sudo systemctl start poweroff.target
}

# Environment variable settings for setting DISPLAY to local or remote
function get_xserver ()
{
  case $TERM in
    xterm )
        XSERVER=$(who am i | awk '{print $NF}' | tr -d ')''(' )
        XSERVER=${XSERVER%%:*}
        ;;
    aterm | rxvt)
        ;;
  esac
}

if [ -z ${DISPLAY:=""} ]; then
  get_xserver
  if [[ -z ${XSERVER} || ${XSERVER} == $(hostname) || \
    ${XSERVER} == "unix" ]]; then
      DISPLAY=":0.0" # Display on local host.
  else
      DISPLAY=${XSERVER}:0.0 # Display on remote host.
  fi
fi

export DISPLAY

function share {
  sudo mount -t vboxsf -o uid=1000,gid=1000,dmode=700,fmode=600,umask=077 share /home/mark/share
}

function su {
  SU=$(which su)
  [ -z "$1" ] && $SU -m || $SU "$1"
}

function anc {
  alias ls='lsn'
  alias tree='tree -n'
  alias grep='grep --color=none -i'
}

function dpkg-get-selections {
  dpkg --get-selections
  >&2 echo
  >&2 echo -----------------------------
  >&2 echo Usage: dpkg --get-selections
  >&2 echo -----------------------------
}

function dpkg-list {
  dpkg-query --list|awk -F' ' '{printf("%s\t%-32s\t",$1,substr($2,0,40));$1=$2=$3=$4=""; print $0}'
}

function pkg_locate {
  [ -z "$1" ] && echo "Usage: pkg_locate name" && return
  ports "$1"
}

function ports {
  [ -z "$1" ] && echo "Usage: ports name" && return
  pushd /usr/ports > /dev/null
  echo */*|tr ' ' '\n'|$GREP $1
  popd  > /dev/null
}

function pkg {
  [ "`uname -s`" != "FreeBSD" ] && return

  local old_pkg=/usr/sbin/pkg
  case "$1" in
    "add")  shift && $old_pkg install "$@"
            ;;
    *) $old_pkg "$@"
            ;;
  esac
}

function alarm {
  if [ ! -z "$1" ]
  then
    echo "alarm will go off in $1"
    sleep $1 && while true; do espeak "Time's up!"; done &
  else
    sleep 1m && while true; do espeak "Time's up!"; done &
  fi
}

function g+++ {
  rm -f a.out
  if [ -e /usr/bin/g++-4.9 ];
  then
    /usr/bin/g++-4.9 -std=c++1y -Wall $*
  else
    /usr/bin/g++ -std=c++0x -Wall $*
  fi

  if [ -e a.out ]
  then
    if [ -e /usr/bin/valgrind ]
    then
      valgrind 2>&1 a.out|sed '1,5d'
    else
      a.out
    fi
  fi
}


# show all git aliases
function gits() {
  # get all git-aliases and git-functions; filter out non-git; sort
  {
    alias|sed 's/alias //' | $GREP '^g[a-zA-Z]'
  } | sed -r '/(gpg|gvim|grep)/d'| sort | awk -F"'" '{printf("%8s %s\n",$1,$2)}'|less -E
  echo
  echo To see any expansion of the functions below use ghelp, example: ghelp amend
  echo
  {
    d=$(declare -F | $GREP ' -f g[a-zA-Z]' |cut -d" " -f3)
    a=$(sed -r '/#/d;/^$/d;/^\[/d;s/ *=.*//' $HOME/.git/aliases.gitconfig)
    f="$d $a"
    echo $f|tr ' ' '\n'
  } |sort |fmt -w `tput cols`
  echo
}

function ghelp() {
  if [ -z "$1" ]; then
    ghuman
    echo
    sed -r '/#/d;/^$/d;/^\[/d;s/ *=.*//' $HOME/.git/aliases.gitconfig|sort |fmt
    echo -e "\nUsage:ghelp search_term\n"
  else
    expand=$(alias "$1" 2>/dev/null)
    [ $? -eq 0 ] && echo "$expand" && return
    expand=$($GREP -w "^ *$1" $HOME/.git/aliases.gitconfig 2>/dev/null)
    [ $? -eq 0 ] && echo "$expand" && return
    expand=$(declare -f "$1")
    [ $? -eq 0 ] && echo "$expand" && return

    echo "$1 isn't a bash alias,git alias, or a bash function"
  fi
}

function ghuman() {
   sed -n '/BEGIN HUMAN/,/END HUMAN/p' $HOME/.git/aliases.gitconfig
}

# git most-recently-used aliases and bash-functions
function gmru {
   history|awk '{$1="";print $0}'|sort|uniq -c|sort -n|$GREP '[0-9] *g[a-zA-Z]'
}

# show all git commits history
function ghist {
  git log $* --graph --date=short \
          --pretty=format:"%C(red bold)%h%Creset %C(blue bold)%ad%Creset %C(cyan bold)|%Creset %C(auto)%d%Creset %s"
}

# completes the triad of:
#   * alias gcf for git commit --fixup
#   * alias gcs for git commit --squash
#   * function gcr for git commit --reword
function gcr {
  case $# in
    1)  git add . ;  git commit -vac $1  ;;
    *) echo "Usage: gcr <commit>" >&2 ;;
  esac
}


function __gdh {
  n=${1:--10}
  git log $n --graph --date=short \
              --pretty=format:"%C(red bold)%h%Creset %C(blue bold)%ad%Creset %C(cyan bold)|%Creset %C(auto)%d%Creset %s"
}
function __gh {
  n=${1:--10}
  git log $n --graph \
              --pretty=format:"%C(red bold)%h%Creset %C(cyan bold)|%Creset %C(auto)%d%Creset %s"
}
# queries git log based on arguments
#   no args : show last 10 one-line commit messages
#   1 arg   : show that (relative to HEAD~) commit message details
#   2 arts  : show summary of commit messages within the given numbers
function gh {
  #`echo "$*"|sed -r 's/(,|-|  )/ /g'`

  e=$([ "$1" == "d" ] && echo __gdh || echo __gh)

  [ "$1" == "d" ] && shift
  case $# in
    1) [ $1 -eq 1 ] && git log -p --stat HEAD...HEAD~1 \
                    || git log -p --stat HEAD~`expr $1 - 1`...HEAD~$1 ;;
    2) [ $1 -eq 1 ] && git log --stat  HEAD...HEAD~$2 \
                    || git log --stat  HEAD~$1...HEAD~$2 ;;
    *) $e;;
       #br_name=`git rev-parse --abbrev-ref HEAD`
       #br_all=`git branch -a|$GREP HEAD|cut -d'>' -f2`
       #case "origin/$br_name" in
       #  "$br_all") $e HEAD...origin/$br_name;;
       #  *)
       #esac
  esac
}

function gha {
   eval ` [ -z "$1" ] && echo __gh || echo __gdh ` --all
}


function ghb {
  for c in `seq $(gh|wc -l)`
  do
    git log --pretty=format:"%C(bold red)%h%Creset %C(bold cyan)%s%Creset%n %C(bold green)%b%Creset" HEAD~$c..HEAD~`expr $c - 1`
  done
}

function ghc {
  # lines=$(git log --oneline|wc -l)
  # pager=`[ $lines -gt 78 ] && echo "less -R"  || echo "cat"  `
  git log --decorate --abbrev-commit --date=short --all --graph\
          --pretty=format:"%C(red bold)%h%Creset %C(green bold)%s%Creset" #|\
  #cut -c1-64 | less #eval "$pager"
}


# if $1 is 1 'git show HEAD' otherwise 'git show $1'
function _gshow {
  case $# in
    1) [ "$1" == "1" ] && git show HEAD \
                       || git show HEAD~$1 2>/dev/null ;;
    *) git show HEAD ;;
  esac

  # unknown error, probably a SHA1, so git show $1
  [ $? -ne 0 ] && git show $1
}

# if $1 contains alphabets (HEAD,SHA1 commits) 'git show $1' otherwise call _gshow
function gshow {
  echo $1|$GREP '[a-zA-Z]' > /dev/null
  [ $? -eq 0 ] && git show $1 \
               || _gshow $1
}

# help learning git, without arguments shows a list, with arguments works like grep
function glearn {

  TFILE=/tmp/glearn

  if [ ! -z "$1" ]; then
    cat /dev/null > /tmp/glearn
    man -k git|$GREP --color=none -iw git|$GREP "(7)" | $GREP "$@" | tee -a $TFILE
    man -k git|$GREP --color=none -iw git|$GREP "(5)" | $GREP "$@" | tee -a $TFILE
    man -k git|$GREP --color=none -iw git|$GREP "([^157])" | $GREP "$@" | tee -a $TFILE

    if [[ `wc -l $TFILE|awk '{print $1}'` -eq 1 ]]; then
      echo
      read -p 'Show man page? (Y/y/q): ' key
      [[ "$key" == "q" || "$key" == "Q" ]] && return
      man `awk '{print $1}' $TFILE|sed 's/([0-9])//'`
    fi
  else
    man -k git|$GREP --color "(7)"
    echo
    man -k git|$GREP --color "(5)"
    echo
    man -k git|$GREP --color=none -iw git|$GREP --color "^[^:]*([^157])"
    # check if tty
    if [ -t 0 ]; then
      echo
      read -p 'Any key to continue or q to quit: ' key
      [[ "$key" == "q" || "$key" == "Q" ]] && return
    fi
  fi

  if [ ! -z "$1" ]; then
    man -k git|$GREP  -w git|$GREP "(1)"|sed 's/\(.*\) - \(.*\)/\2 : \1/'|sort|awk -F':' '{printf ("%-80s %s\n", $1,$2)}'|$GREP "$@"
  else
    man -k git|$GREP  -w git|$GREP "(1)"|sed 's/\(.*\) - \(.*\)/\2 : \1/'|sort|awk -F':' '{printf ("%-80s %s\n", $1,$2)}'|less
  fi
  rm -f $TFILE
}

# serve up git man-pages
function gman {
  old_pwd=`pwd`
  which adsf > /dev/null
  [ $? -eq 0 ] && {
    cd /usr/share/doc/git/html i
    adsf 2> /dev/null &
  }
  cd $old_pwd
}

function sc {
  case "$1" in
    "help"|"h"|"-h"|"--help") systemctl --help $* ;;
    * ) systemctl $* ;;
  esac
}

function ghw {
  echo -e "my git workflow\n\
    git branch wip\n\
    git commit ...\n\
    git rebase master\n\
    git checkout master\n\
    git merge wip"
}

function gsearch {

  [ -z "$1" ] && echo Usage: gsearch search_term && return
  for commit in $(git log --oneline|$GREP "$1"|awk '{print $1}')
  do
    git show --pretty="%h %s %b" --stat $commit
    git show --pretty="%n        %Cred===%C(yellow)**%Cgreenx%C(yellow)**%Cred===%Creset%n" -s $commit
  done
}


function glast {
  mru_repo=$(cat $HOME/repos/mru_repo)
  cd $HOME/repos/$mru_repo
  [ -z "$1" ] && echo "Usage: glast my_git_command/alias" >&2 || "$1"
}

function sdate {
  if [ `id -u` -eq 0 ]; then
    date `cat /tmp/date`
    rm -f /tmp/date
  else
    rm -f /tmp/date
    date "+%Y%m%d%H%M.%S" >/tmp/date
    scp /tmp/date mark@$VM:/tmp/date
  fi
}

function g() {

  aliases=$(git config --get-regexp alias.*|cut -d'.' -f2-|awk '{f=$1; $1=""; printf("%-15s %s\n", f, $0)}')
  case "$1" in
    "alias"|"a")  echo "$aliases"|sort -bk2,2|less ;;
    "ar")         echo "$aliases"|sort -rbk2,2|less ;;
    *)            git "$@" ;;
  esac
}

# vim:nospell:ft=sh:
