#!/bin/bash

NOCOLOR='\033[0m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

# pretty print function
# $SIGN - use to tell which symbol to prepend
#         CONT     [*] (blue)
#         GOOD     [+] (green)
#         BAD      [-] (red)
#         WARN     [!] (yellow)
# $MESSAGE - the message to print. FIRST word should be in all caps
#            FIRST word will also be yellow
function echo() {
  SIGN="$1"
  ECHO="$(which echo)"

  case "$SIGN" in
    "INFO")
      symbol="${CYAN}*"
      shift
      ;;
    "GOOD")
      symbol="${GREEN}+"
      shift
      ;;
    "BAD")
      symbol="${RED}-"
      shift
      ;;
    "WARN")
      symbol="${YELLOW}!"
      shift
      ;;
    *)
      symbol="${CYAN}*"
  esac
  MESSAGE="$@"

  eval "$ECHO" -e "$($ECHO -e $MESSAGE | sed 's/ / ${CYAN}/; s/^/${CYAN}\[${symbol}${CYAN}\]\ ${YELLOW}/; s/${NOCOLOR}/${CYAN}/; s/$/${NOCOLOR}/')" 
}
