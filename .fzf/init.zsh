# Setup fzf
# ---------

case $(uname -sm) in
  Darwin\ *64 )
    export PATH="$CFG/.fzf/bin/mac:$PATH"
  ;;
  Linux\ aarch64 )
    export PATH="$CFG/.fzf/bin/and:$PATH"
  ;;
  Linux\ *64 )
    export PATH="$CFG/.fzf/bin/lin:$PATH"
  ;;
esac

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$CFG/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$CFG/.fzf/shell/key-bindings.zsh"

function psaux-fzf {
  ps aux | fzf -e --header-lines=1 -q ${1:-''}
}
alias px='psaux-fzf'

function pxx {
  local x=$(ps aux | fzf -e --header-lines=1 -m --preview='pstree $(echo {} | awk '"'"'{print $2}'"'"')' -q ${1:-''})
  echo $x | awk '{print $2}'
}

function pxk {
  kill $(pxx ${1:-''})
}

function cdf {
   local file
   local dir
   file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
}

source "$CFG/.fzf/shell/git.zsh"
