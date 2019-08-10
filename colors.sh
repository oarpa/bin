#!/bin/bash
#
# HOW TO USE THIS SCRIPT:
#
# #!/bin/bash
# source /path/to/colors.sh
# echo -e "${RED}${BLINK}test$RESET"
#
#FORMATTING
export BOLD='\e[1m'
export DIM='\e[2m'
export UNDERLINE='\e[4m'
export BLINK='\e[5m'
export INVERT='\e[7m'
export HIDDEN='\e[8m'
export RESET='\e[0m'
export RESETBOLD='\e[21m'
export RESETDIM='\e[22m'
export RESETUNDERLINE='\e[24m'
export RESETBLINK='\e[25m'
export RESETINVERSE='\e[27m'
export RESETHIDDEN='\e[28m'
#FOREGROUND
export FG_DEFAULT='\e[39m'
export FG_BLACK='\e[30m'
export FG_RED='\e[31m'
export FG_GREEN='\e[32m'
export FG_YELLOW='\e[33m'
export FG_BLUE='\e[34m'
export FG_MAGENTA='\e[35m'
export FG_CYAN='\e[36m'
export FG_LIGHTGRAY='\e[37m'
export FG_DARKGRAY='\e[90m'
export FG_LIGHTRED='\e[91m'
export FG_LIGHTGREEN='\e[92m'
export FG_LIGHTYELLOW='\e[93m'
export FG_LIGHTBLUE='\e[94m'
export FG_LIGHTMAGENTA='\e[95m'
export FG_LIGHTCYAN='\e[96m'
export FG_WHITE='\e[97m'
#BACKGROUND
export BG_DEFAULT='\e[49m'
export BG_BLACK='\e[40m'
export BG_RED='\e[41m'
export BG_GREEN='\e[42m'
export BG_YELLOW='\e[43m'
export BG_BLUE='\e[44m'
export BG_MAGENTA='\e[45m'
export BG_CYAN='\e[46m'
export BG_LIGHTGRAY='\e[47m'
export BG_DARKGRAY='\e[100m'
export BG_LIGHTRED='\e[101m'
export BG_LIGHTGREEN='\e[102m'
export BG_LIGHTYELLOW='\e[103m'
export BG_LIGHTBLUE='\e[104m'
export BG_LIGHTMAGENTA='\e[105m'
export BG_LIGHTCYAN='\e[106m'
export BG_WHITE='\e[107m'
