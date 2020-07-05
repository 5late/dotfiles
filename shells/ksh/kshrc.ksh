# .kshrc
#-----------------------------------------------------------------

#
REPO=~/.ksh

#
print .kshrc called ...

# don't do anything if we don't have a prompt (not an interactive shell)
#[[ $- != *i* ]] && return || [ -z "$PS1" ] && return

[ -f $HOME/.profile ] && . ~/.profile
PATH=$PATH:/usr/local/bin:.:~/bin

# source local and private settings
# changes to local.bash should not be publicly tracked and shared (recommended)
if [ -f $REPO/local.ksh ]; then
  . $REPO/local.ksh
fi
# source common aliases used by power users
if [ -f $REPO/aliases.ksh ]; then
  . $REPO/aliases.ksh
fi

# source environment variables exported
if [ -f $REPO/exports.ksh ]; then
  . $REPO/exports.ksh
fi

# source various utility functions
if [ -f $REPO/functions.ksh ]; then
  . $REPO/functions.ksh
fi

# setup our prompt PS1, first get OS release+version
OSRV=
if [ $(uname) == "OpenBSD" ]; then
    OSRV=$(uname)
    /usr/local/bin/keychain ~/.ssh/id_rsa
    . ~/.keychain/$(hostname)-sh
else
  if [ $(uname -o) == "GNU/Linux" ]; then
    if [ $(cat /etc/*-release|wc -l) -eq 1 ]; then
      OSRV=$(cat /etc/*-release)
    else
      OSRV=$(cat /etc/lsb-release|grep DESCRIPTION|sed -e 's/.*=//;s/\"//g')
    fi
  fi
  if [ $(uname -o) == "FreeBSD" ]; then
    OSRV=$(uname -sr)
  fi
fi

set -o emacs             # vi-style editing
bind -m '^L'=clear'^J'   # clear the screen
FCEDIT='/usr/bin/vim'    # fc usese vi too

# resembles the bash equivalent of '\w$ ' with green colour highlighting
# next vary prompt according to regular user or root
export PS1=`print '\e[0m\e[32;1m$(basename $(echo $PWD|sed "s,^$HOME$,~," ))\e[0m% '`

# command line calendar
pal 2> /dev/null
if [ $? -eq 0 ]; then
  echo "Ah! Good. You've got pal - the command line calendar." >&2
  echo "If you'd like a Catholic saints calendar, check out" >&2
  echo "   misc/pal/saints.pal"  >&2
fi

# source local and private settings last so they take precedence over everything
# changes to local.bash should not be publicly tracked and shared (recommended)
if [ -f $REPO/local.ksh ]; then
  . $REPO/local.ksh
fi

# vim:nospell:ft=sh:
