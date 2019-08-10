#!/bin/bash
# :::::::::::  ::::::::::  :::    ::: 
#     :+:      :+:         :+:    :+:
#     +:+      +:+         +:+    +:+ 
#     +#+      :#::+::#    +#+    +:+ 
#     +#+      +#+         +#+    +#+ 
#     #+#      #+#         #+#    #+# 
# ###########  ###          ########  
#                   irc flood utility
#
# Use -h or --help to get started
#
# You want permission to edit a script or use it?
# Don't be a brainwashed weirdo.  Source code licensing is a mental illness.
#
################################################################################
_prereq_not_installed="no"
command -v bc >/dev/null 2>&1 || {
	echo "bc needs to be installed"
	_prereq_not_installed="yes"
}
command -v nc >/dev/null 2>&1 || {
	echo "nc (netcat) needs to be installed"
	_prereq_not_installed="yes"
}
command -v openssl >/dev/null 2>&1 || {
	echo "openssl needs to be installed"
	_prereq_not_installed="yes"
}
command -v pwgen >/dev/null 2>&1 || {
	echo "pwgen needs to be installed"
	_prereq_not_installed="yes"
}
command -v telnet >/dev/null 2>&1 || {
	echo "telnet needs to be installed"
	_prereq_not_installed="yes"
}
if [[ "$_prereq_not_installed" == "yes" ]]
then
	exit 1
fi
###############################################################################
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
export RESETINVERT='\e[27m'
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
###############################################################################
ifuproc_PID=
_basename="$(basename "$0")"
_channel=
_channel_key=
_current_line_number=1
_delay=
_do_not_save="no"
_dont_give_up="no"
_filename=
_eof_exit="no"
_first_line_sent="no"
_ipv4="no"
_ipv6="no"
_irc_hostname=
_irc_servername=
_last_line=
_last_line_number=1
_launch_code=
_loop="no"
_mixed_flood="no"
_mixed_flood_liklihood=7
_nick=
_nick_alt=
_nick_flood="no"
_nick_flood_blocked="no"
_nick_flood_block_pre=
_nick_flood_block_post=
_nick_flood_block_timeout=20
_nick_manual="no"
_nickserv="NickServ"
_nickserv_filename=
_nickserv_file_line_selected=
_nickserv_file_total_lines=
_nickserv_password=
_nickserv_timeout=10
_notice="no"
_notice_liklihood=7
_port=6667
_port_manual="no"
_postexec=
_preexec=
_random_lines="no"
_realname=
_register_nick="no"
_register_nick_email=
_register_nick_password="$(pwgen $(( 10 + RANDOM % 10 )) 1)"
_register_nick_time="$(( 60 + RANDOM % 30 ))"
_server=
_ssl="no"
_timeout=1
_timeout_maximum=1.5
_timeout_minimum=0.5
_timeout_random="yes"
_user=
_verbose="no"
_wait_for_voice="no"
###############################################################################
function ifu_print_help {
	echo -e "
${DIM}${FG_RED}:::::::::::  ::::::::::  :::    ::: 
    :+:      :+:         :+:    :+: 
    +:+      +:+         +:+    +:+ 
    +#+      :#::+::#    +#+    +:+ 
    +#+      +#+         +#+    +#+ 
    #+#      #+#         #+#    #+# 
###########  ###          ########  $RESET
                  ${FG_RED}${BLINK}irc flood utility$RESET

${BOLD}REQUIRED PARAMETERS:$RESET
Server is the First Default Argument (Unless specified with -s or --server)
-s <server>
--server <server>
	server address to connect to
Channel is the Second Default Argument (Unless specified with -c or --channel)
-c \"<channel>\"
--channel \"<channel>\"
	channel to join - use quotes (or else bash will think # is a comment)

${BOLD}OPTIONAL PARAMETERS:$RESET
-4
	force connecting using IPv4
-6
	force connecting using IPv6
-d <seconds>
--delay <seconds>
	sleep for <seconds> after joining a channel before sending
	replies to PINGs will not be processed until after the delay
-e
--eof-exit
	exit after sending the last line of the file (if you're sending a file)
	obviously doesn't work when using random lines
-f <filename>
--file <filename>
	specify text file to send, data is sent from beginning to end by default
	combine with --random-lines or --eof-exit for additional options
--fixed <seconds>
	specify a fixed amount of time in between sending each line of data
-k <channel key>
--channel-key <channel key>
--key <channel key>
	IRC channel password (key)
--launch-code \"launch code message\"
	If a launch code is specified, the client will wait after joining the
	channel for anyone to send this message - after which, sending data
	will begin to occur - you can either PM or post it to channel
-l
--loop
	loop the script until it is manually exited with CTRL+C; even if it is
	disconnected it will launch again
	(TIP:  used with -x/--execute to connect to various proxies or vpns in
	between each run)
-max <seconds>
--max <seconds>
--maximum <seconds>
	maximum random time between sending each line
	--fixed overrides this behavior
-min <seconds>
--min <seconds>
--minimum <seconds>
	minimum random time between sending each line
	--fixed overrides this behavior
--mixed-flood
	This option will enable random nickname changes as well as sending
	data to the channel.  By default, there is a 1 in 7 chance that
	instead of sending a line of text, the nick will change randomly
-n <nickname>
--nick <nickname>
	nickname to use
-n2 <nickname>
--nick-alt <nickname>
	alternate nickname (in case the preferred one does not work)
-ns <password>
--nickserv-password <password>
	password to attempt to identify a registered nick with NickServ
--nickserv-bot <bot-name>
	The full name of the NickServ bot
	Some servers disable generic messaging to the NickServ bot
	Example: --nickserv-bot NickServ@services.dal.net
--nickserv-file <filename>
	This option will grab a nickserv login and password from a colon-
	separated user:password per-line textfile.  With --register-nick,
	this file will be appended with a successfully registered nick.
	Otherwise, whichever attempted nickserv login is used will be
	removed from the file.  Use --do-not-save to never remove an
	attempted login from this file.  By default, a backup is made
	with the added file extension .backup appended to the original.
--nick-flood
	When this option is enabled, the only thing the script will do is
	change to random nicknames after joining the channel instead of
	sending lines of text
--notice
	This will enable a random chance that the data is sent to channel
	as a NOTICE instead of PRIVMSG - default 1 in 7 chance
--notice-flood
	This mode will only send the data as a NOTICE, and doesn't combine
	with PRIVMSG sending at all - 100% chance of NOTICE
-p <port>
--port <port>
	specify port number to connect to - default is 6667
-r
--random-lines
	send lines from a file in random order (only works with -f or --file)
	(or in nickflood mode, send nicknames in random order from a file)
--realname <realname>
	irc realname to use
--register-nick \"email@address.com\"
	This mode will prevent all sending.  After joining a channel and
	waiting a default of 60-90 seconds, the client will attempt to
	register the nick with nickserv
-ssl
--ssl
	use SSL to connect to server - changes default port to 6697
--stay-connected
	if the channel is temporarily muted, this will prevent a client that
	cannot send to the channel from instantly exiting - it will keep on
-u <username>
--user <username>
	irc username to use
-v
--verbose
	verbose output - must-have if you need help
--wait-for-voice
	do not send to channel unless you are first given +v
-x <command or script>
--up <command or script>
--execute <command or script>
	execute this command before connecting
-x2 <command or script>
--down <command or script>
--execute2 <command or script>
	execute this command after disconnecting

${BOLD}ADVANCED PARAMETERS:$RESET
--do-not-save
	Used with --nickserv-file
	This will prevent removing an entry that is used to login to
	nickserv from this file.
--irc-hostname <hostname>
	Default is tolmoon
--irc-servername <servername>
	Default is tolsun
--mixed-liklihood <value>
	this is the liklihood that a nick will change instead of sending to
	the channel - default is 7 (1 in 7 random liklihood of nick
	change) - a 4 means a 1 in 4 looklihood, 5 means a 1 in 5, etc
	only works with --mixed-flood
--nickserv-timeout <seconds>
	time to wait before assuming no NickServ reply to idenitfy
	(default is 10)
--notice-liklihood <value>
	This is the liklihood that a line of text will be sent as a NOTICE
	to the channel instead of PRIVMSG - only works with --notice, and
	does not work with --nick-flood - default value is 7, which means
	a 1 in 7 chance
--register-nick-time <seconds>
	Amount of time to wait after joining a channel to attempt nickname
	registration - default is a random number between 60-90 seconds

${BOLD}NOTES:$RESET
	most modern IRC servers will scan you for vulnerabilities
	all files in your current directory without a leading dot (.filename)
		might be exposed when connecting
	Does your text file have lines that are way too long?  This script will
		try to send the full line length, but try making a new file:
		fold -s -w140 yourfile.txt >newfile.txt
		(substitute 140 for the maximum length you want, -s will only
			break the file to a new line where there is a space)
		most servers will have a 512/1024 byte limit per line of text
			which includes the full raw string of data (PRIVMSG etc)

${BOLD}EXAMPLES:$RESET

# Default, spam a channel with random lines and a random nick:
$_basename irc.network.net \"#channel-name\"

# SSL-enabled, use a specified nickname and user and realname verbosely:
$_basename -ssl --nick NickName --user UserName --realname \"My Real Name\"
	--verbose irc.network.org \"#stupidchan\"

# Use a nickname that has been registered with NickServ:
$_basename -ssl --nick MyNickname --nickserv-password MyNickservPassword
	irc.network.com \"#channel\"

# Send files from a textfile in random order connecting to SSL port 9999:
$_basename -c \"#efnet\" --file RandomLines.txt -s irc.ircserver.com 
	--random-lines --nick NickName -v --port 9999 --ssl

# Use a script before and after connecting, and connect in a loop repeatedly:
$_basename -x ConnectToRandomVPNServer.sh -x2 DisconnectFromVPNServer.sh --loop
	irc.ircserver.net \"#TargetChannel\"

# Attempt to register a specified nickname with NickServ, and save it to a file
$_basename --register-nick my@email.address.net --nick MyNickName
	--nickserv-password "Some@RandomText1!" --nickserv-filename mynicks.txt
	irc.network.net \"#idle_channel\"

# Use a saved nickserv file to grab a random saved nickserv login, and send
#  NOTICE messages along with regular PRIVMSG flood to the channel
$_basename --notice --nickserv-file mynicks.txt irc.network.net \"#reg_channel\"
"
}
###############################################################################
if [[ $# -eq 0 ]]
then
	echo "Use -h or --help to get started"
	exit 0
fi
while [[ -n "$1" ]]
do
	case $1 in
		-4 )	_ipv4="yes"
			if [[ "$_ipv6" == "yes" ]]
			then
				echo "Cannot force both IPv4 and IPv6"
				exit 1
			fi
			;;
		-6 )	_ipv6="yes"
			if [[ "$_ipv4" == "yes" ]]
			then
				echo "Cannot force both IPv4 and IPv6"
				exit 1
			fi
			;;
		-c | -chan | --chan | -channel | --channel )
			shift
			_channel="$1"
			;;
		-d | -delay | --delay )
			shift
			_delay="$1"
			;;
		--do-not-save)
			_do_not_save="yes"
			;;
		-e | --eof-exit | -eof | -eof-exit )
			_eof_exit="yes"
			;;
		-f | -file | --file | -filename | --filename )
			shift
			_filename="$1"
			test -r "$_filename" || {
				echo -e "${BLINK}FATAL${RESET}\\tCannot read from file '${_filename}'${RESET}"
			}
			if [[ "$(wc -l "$_filename" | cut -d ' ' -f 1)" -gt 32767 ]] && [[ "$_random_lines" == "yes" ]]
			then
				echo "Warning:  Only lines 1 through 32767 will be sent from '$_filename'"
				echo "This is a limitation of the bash random number generator"
			fi
			;;
		--fixed )
			shift
			_timeout="$1"
			_timeout_random="no"
			;;
		-h | --help | -help )
			ifu_print_help
			exit 0
			;;
		--irc-hostname )
			shift
			_irc_hostname="$1"
			;;
		--irc-servername )
			shift
			_irc_servername="$1"
			;;
		-k | --key | --channel-key )
			shift
			_channel_key="$1"
			;;
		--keep-trying | --stay-connected | --dont-give-up )
			_dont_give_up="yes"
			;;
		-l | -loop | --loop )
			_loop="yes"
			;;
		--launch-code | -launch-code | -lc | --lc )
			shift
			_launch_code="$1"
			;;
		-max | --max | --maximum)
			shift
			_timeout_maximum="$1"
			_timeout_random="yes"
			;;
		-min | --min | --minimum )
			shift
			_timeout_minimum="$1"
			_timeout_random="yes"
			;;
		--mixed-flood | -mix | --mix  | -mixed | --mixed )
			_mixed_flood="yes"
			if [[ "$_nick_flood" == "yes" ]]
			then
				echo -e "${BLINK}FATAL:${RESET}\\tCannot set multiple flood modes"
				exit 1
			fi
			;;
		--mixed-flood-liklihood | --mixed-chance | --mixed-flood-chance )
			shift
			_mixed_flood_liklihood="$1"
			;;
		--nick-flood | -nickflood )
			_nick_flood="yes"
			if [[ "$_mixed_flood" == "yes" ]]
			then
				echo -e "${BLINK}FATAL:${RESET}\\tCannot set multiple flood modes"
				exit 1
			fi
			;;
		--nick-timeout | --nick-flood-timeout )
			shift
			_nick_flood_block_timeout="$1"
			;;
		-n | -nick | --nick | --nickname )
			shift
			_nick="$1"
			_nick_manual="yes"
			;;
		-n2 | -alt | --alt | --altnick | --nick-alt | --nick2 | -nick2 )
			shift
			_nick_alt="$1"
			_nick_manual="yes"
			;;
		-ns | --ns | --nickserv | --nickserv-password | --nickserv-login )
			shift
			_nickserv_password="$1"
			;;
		-nsb | --nsb | --nickserv-bot | -nickserv-bot | -nick-bot | --nick-bot )
			shift
			_nickserv="$1"
			;;
		--nickserv-filename | --nickserv-file )
			shift
			_nickserv_filename="$1"
			if [[ ! -r "$_nickserv_filename" ]]
			then
				echo -e "${BLINK}FATAL:${RESET}\\tCannot read from file '$_nickserv_filename'..."
				exit 1
			fi
			;;
		-notice | --notice )
			_notice="yes"
			;;
		--notice-flood | -notice-flood )
			_notice="yes"
			_notice_liklihood=1
			;;
		-notice-chance | --notice-chance | --notice-liklihood )
			shift
			_notice_liklihood="$1"
			;;
		-p | -port | --port )
			shift
			_port=$1
			_port_manual="yes"
			;;
		-r | -random-lines | --random-lines | -randomlines | --randomlines )
			_random_lines="yes"
			if [[ -n "$_filename" ]] && [[ -r "$_filename" ]] && [[ "$(wc -l "$_filename" | cut -d ' ' -f 1)" -gt 32767 ]] && [[ "$_random_lines" == "yes" ]]
			then
				echo "Warning:  Only lines 1 through 32767 will be sent from '$_filename'"
				echo "This is a limitation of the bash random number generator and large files"
			fi
			;;
		-random | -rand | --rand | --random )
			_timeout_random="yes"
			;;
		-realname | --realname | -rn | --rn | -rlname | --rlname )
			shift
			_realname="$1"
			;;
		--register-nick )
			_register_nick="yes"
			shift
			_register_nick_email="$1"
			;;
		--register-nick-time )
			shift
			_register_nick_time="$1"
			;;
		-s | -serv | --serv | -server | --server )
			shift
			_server="$1"
			;;
		-ssl | --ssl | -tls | --tls )
			_ssl="yes"
			if [[ "$_port_manual" == "no" ]]
			then
				_port=6697
			fi
			;;
		-u | -user | --user | --username )
			shift
			_user="$1"
			;;
		-v | --verbose | -vv )
			_verbose="yes"
			;;
		--wait-for-voice | --voice )
			_wait_for_voice="yes"
			;;
		-x | -exec | --exec | --pre-up | --preexec | -up | --up )
			shift
			_preexec="$1"
			;;
		-x2 | -exec2 | --exec2 | --post-down | --postexec | -down | --down )
			shift
			_postexec="$1"
			;;
		* )	if [[ -z "$_server" ]]
			then
				_server="$1"
			elif [[ -z "$_channel" ]]
			then
				_channel="$1"
			else
				echo "Use -h or --help to get started"
				exit 1
			fi
			;;
	esac
	shift
done
###############################################################################
# final check on nickserv file
if [[ -n "$_nickserv_filename" ]] && [[ "$_do_not_save" == "no" ]] && [[ ! -w "$_nickserv_filename" ]]
then
	echo -e "${BLINK}FATAL:${RESET}\\tCannot write to file '$_nickserv_filename'..."
	exit 1
fi
if [[ "$_register_nick" == "no" ]] && [[ -n "$_nickserv_filename" ]]
then
	_nick_manual="yes"
fi
if [[ "$_register_nick" = "no" ]] && [[ -n "$_nickserv_filename" ]]
then
	_nickserv_file_total_lines="$(wc -l "$_nickserv_filename" | cut -d ' ' -f 1)"
	_nickserv_file_line_selected="$(( 1 + RANDOM % _nickserv_file_total_lines ))"
	_nick="$(head -n "$_nickserv_file_line_selected" "$_nickserv_filename" | tail -n 1 | cut -d ':' -f 1 | tr -d '\n')"
	_nickserv_password="$(head -n "$_nickserv_file_line_selected" "$_nickserv_filename" | tail -n 1 | cut -d ':' -f 2 | tr -d '\n')"
	if [[ -z "$_nick" ]] || [[ -z "$_nickserv_password" ]]
	then
		echo -e "${BLINK}FATAL:${RESET}\\tThe NickServ file gave invalid data"
		exit 1
	fi
fi
# _server already has to be set since at least 1 argument or exit happened
# make sure we have a channel before starting
if [[ -z "$_channel" ]]
then
	echo "Specify a channel to join using -c or -channel or second default argument"
	echo "Make sure to use \"quotes\" because bash thinks the \"#\" character starts a comment"
	echo -e "\\tExample: \"#ChannelName\""
	exit 1
fi
# can we contact the server?  invalid?
nc -w5 -z "$_server" "$_port" >/dev/null 2>&1 || {
	echo -e "${BLINK}FATAL:${RESET}\\tCannot connect to '$_server' at port '$_port'"
	exit 1
}
###############################################################################
# Start defining functions:
###############################################################################
function ifu_exit {
	echo
	echo "Caught exit, cleaning up..."
	if [[ -n "$ifuproc_PID" ]]
	then
		kill -9 "$ifuproc_PID" >/dev/null 2>&1
	fi
	wait
}
trap ifu_exit EXIT
###############################################################################
_total_line_count=
if [[ -n "$_filename" ]]
then
	_total_line_count="$(wc -l "$_filename" | cut -d ' ' -f 1)"
fi
function ifu_send_line {
	if [[ "$_nick_flood_blocked" == "yes" ]]
	then
		_nick_flood_block_post="$(date +%s%N)"
		_nick_flood_block_diff="$(( _nick_flood_block_post - _nick_flood_block_pre ))"
		_nick_flood_block_diff="$(echo "scale=9; ${_nick_flood_block_diff}/1000000000" | bc)"
		_nick_flood_timeout_diff="$(echo "$_nick_flood_block_timeout - $_nick_flood_block_diff" | bc)"
		if [[ "$_nick_flood_timeout_diff" == *"-"* ]]
		then
			_nick_flood_blocked="no"
		fi
	fi
	_data=
	if [[ "$_nick_flood" == "yes" ]] && [[ "$_nick_flood_blocked" == "no" ]]
	then
		if [[ -z "$_filename" ]]
		then
			_data="$(pwgen -0 $(( 4 + RANDOM % 3 )) 1)"
		else
			if [[ "$_random_lines" == "yes" ]]
			then
				_last_line_number=$_current_line_number
				_current_line_number=$(( 1 + RANDOM % _total_line_count ))
			else
				if [[ "$_first_line_sent" == "yes" ]]
				then
					_last_line_number=$_current_line_number
					_current_line_number=$((_current_line_number + 1))
					if [[ $_current_line_number -gt $_total_line_count ]]
					then
						if [[ "$_eof_exit" == "yes" ]]
						then
							echo "Reached EOF end-of-file, terminating..."
							exit 0
						fi
						_current_line_number=1
					fi
				else
					_first_line_sent="yes"
				fi
			fi
			_data="$(head -n "$_current_line_number" "$_filename" | tail -n 1 | cut -d ' ' -f 1)"
		fi
		echo -e "NICK ${_data}\\r" >&"${ifuproc[1]}" 2>/dev/null
		if [[ "$_verbose" == "yes" ]]
		then
			echo -e "${DIM}${GREEN}NICK ${_data}${RESET}"
		fi
	elif [[ "$_mixed_flood" == "yes" ]] && [[ "$(( RANDOM % _mixed_flood_liklihood ))" == 0 ]] && [[ "$_nick_flood_blocked" == "no" ]]
	then
		_data="$(pwgen -0 $(( 4 + RANDOM % 3 )) 1 )"
		echo -e "NICK ${_data}\\r" >&"${ifuproc[1]}" 2>/dev/null
		if [[ "$_verbose" == "yes" ]]
		then
			echo -e "${DIM}${GREEN}NICK ${_data}${RESET}"
		fi
	elif [[ "$_notice" == "yes" ]] && [[ "$(( RANDOM % _notice_liklihood ))" == 0 ]]
	then
		if [[ -n "$_filename" ]]
		then
			if [[ "$_random_lines" == "yes" ]]
			then
				_last_line_number=$_current_line_number
				_current_line_number=$(( 1 + RANDOM % _total_line_count ))
			else
				if [[ "$_first_line_sent" == "yes" ]]
				then
					_last_line_number=$_current_line_number
					_current_line_number=$((_current_line_number + 1))
					if [[ $_current_line_number -gt $_total_line_count ]]
					then
						if [[ "$_eof_exit" == "yes" ]]
						then
							echo "Reached EOF end-of-file, terminating..."
							exit 0
						fi
						_current_line_number=1
					fi
				else
					_first_line_sent="yes"
				fi
			fi
			_data="$(head -n "$_current_line_number" "$_filename" | tail -n 1)"
		else
			_data="$(pwgen $(( 1 + RANDOM % 128 )) 1)"
		fi
		echo -e "NOTICE $_channel :${_data}\\r" >&"${ifuproc[1]}" 2>/dev/null
		if [[ "$_verbose" == "yes" ]]
		then
			echo -e "${DIM}${FG_GREEN}NOTICE $_channel :${_data}${RESET}"
		fi
	elif [[ "$_nick_flood" == "no" ]]
	then
		if [[ -n "$_filename" ]]
		then
			if [[ "$_random_lines" == "yes" ]]
			then
				_last_line_number=$_current_line_number
				_current_line_number=$(( 1 + RANDOM % _total_line_count ))
			else
				if [[ "$_first_line_sent" == "yes" ]]
				then
					_last_line_number=$_current_line_number
					_current_line_number=$((_current_line_number + 1))
					if [[ $_current_line_number -gt $_total_line_count ]]
					then
						if [[ "$_eof_exit" == "yes" ]]
						then
							echo "Reached EOF end-of-file, terminating..."
							exit 0
						fi
						_current_line_number=1
					fi
				else
					_first_line_sent="yes"
				fi
			fi
			_data="$(head -n "$_current_line_number" "$_filename" | tail -n 1)"
		else
			_data="$(pwgen $(( 1 + RANDOM % 128 )) 1)"
		fi
		echo -e "PRIVMSG $_channel :${_data}\\r" >&"${ifuproc[1]}" 2>/dev/null
		if [[ "$_verbose" == "yes" ]]
		then
			echo -e "${DIM}${FG_GREEN}PRIVMSG $_channel :${_data}${RESET}"
		fi
	fi
}
###############################################################################
function ifu {
	# Connect using coproc with telnet or openssl
	ifu_connect_cmd=
	if [[ "$_ssl" == "yes" ]]
	then
		if [[ "$_ipv6" == "yes" ]]
		then
			ifu_connect_cmd="openssl s_client -connect ${_server}:${_port} -6"
		elif [[ "$_ipv4" == "yes" ]]
		then
			ifu_connect_cmd="openssl s_client -connect ${_server}:${_port} -4"
		else
			ifu_connect_cmd="openssl s_client -connect ${_server}:${_port}"
		fi
	else
		if [[ "$_ipv6" == "yes" ]]
		then
			ifu_connect_cmd="telnet -6 $_server $_port"
		elif [[ "$_ipv4" == "yes" ]]
		then
			ifu_connect_cmd="telnet -4 $_server $_port"
		else
			ifu_connect_cmd="telnet $_server $_port"
		fi
	fi
	coproc ifuproc { $ifu_connect_cmd ; } 2>&1
	# Don't waste our main loop on openssl/telnet program jargon:
	ssl_check="no"
	while true
	do
		kill -0 "$ifuproc_PID" >/dev/null 2>&1 || {
			if [[ "$_verbose" == "yes" ]]
			then
				echo "Connection PID exited prematurely"
			fi
			echo -e "${BLINK}FATAL:${RESET}\\tFailed to start network session"
			return 1
		}
		read -r init_data <&"${ifuproc[0]}" 2>/dev/null
		if [[ "$_verbose" == "yes" ]]
		then
			echo -e "${DIM}${init_data}${RESET}"
		fi
		if [[ "$init_data" == "Escape character is"* ]]
		then
			break
		fi
		if [[ "$init_data" == "Extended master secret:"* ]]
		then
			ssl_check="yes"
		fi
		if [[ "$ssl_check" == "yes" ]] && [[ "$init_data" == "---"* ]]
		then
			break
		fi
	done
	# We have connected and need to send NICK and USER commands:
	test -n "$_nick" || _nick=$(pwgen -0 $(( 4 + RANDOM % 3 )) 1)
	test -n "$_user" || _user=$(pwgen -0 $(( 4 + RANDOM % 3 )) 1)
	test -n "$_realname" || _realname=$(pwgen -0 $(( 4 + RANDOM % 3 )) 1)
	test -n "$_irc_hostname" || _irc_hostname="tolmoon"
	test -n "$_irc_servername" || _irc_servername="tolsun"
	echo -e "NICK $_nick\\r" >&"${ifuproc[1]}" 2>/dev/null
	echo -e "USER $_user $_irc_hostname $_irc_servername :${_realname}\\r" >&"${ifuproc[1]}" 2>/dev/null
	if [[ "$_verbose" == "yes" ]]
	then
		echo -e "${DIM}${FG_GREEN}NICK ${_nick}${RESET}"
		echo -e "${DIM}${FG_GREEN}USER $_user $_irc_hostname $_irc_servername :${_realname}${RESET}"
	fi
	echo "Connection initiated..."
	#######    LOOP VARIABLES    #######
	if [[ -z "$_nick_alt" ]] && [[ "$_nick_manual" == "no" ]]
	then
		_nick_alt="$(pwgen -0 $(( 4 + RANDOM % 3 )) 1)"
	fi
	_have_delayed="no"
	_ifu_registering="no"
	_ifu_registration_sent="no"
	_ifu_sending="no"
	_joined_channel="no"
	_nick_alt_tried="no"
	_nickserv_logged_in="no"
	if [[ -z "$_nickserv_password" ]]
	then
		_nickserv_logged_in="yes"
	else
		_register_nick_password="$_nickserv_password"
	fi
	_nickserv_time_sent=
	_nickserv_waiting=
	_pre_time=$(date +%s%N)
	_post_time=
	_register_nick_time_sent=
	_remote_server=
	_sent_join="no"
	_time_diff=
	_timeout_diff=
	_voice_block=
	_wait_for_timeout="no"
	if [[ "$_wait_for_voice" == "yes" ]]
	then
		_voice_block="yes"
	else
		_voice_block="no"
	fi
	#######       MAIN LOOP       #######
	while true
	do
		# Check if our connection process is still running:
		kill -0 "$ifuproc_PID" >/dev/null 2>&1 || {
			if [[ "$_verbose" == "yes" ]]
			then
				if [[ -z "$ifuproc_PID" ]]
				then
					echo "Connection PID is no longer running"
				else
					echo "Connection PID '$ifuproc_PID' is no longer running"
				fi
			fi
			echo -e "${BLINK}FATAL:${RESET}\\tProcess or connection terminated"
			return 1
		}
		# Grab input and send output using coproc FD:
		if [[ "$_ifu_sending" == "yes" ]]
		then
			# _wait_for_timeout is set if the client has received
			# input from the server before it is ready to send another
			# line of data;
			# Do 0-timeout reads until we reach the timeout:
			if [[ "$_wait_for_timeout" == "yes" ]]
			then
				read -r -t 0 server_string <&"${ifuproc[0]}" 2>/dev/null
				_post_time=$(date +%s%N)
				_time_diff=$(( _post_time - _pre_time ))
				_time_diff="$(echo -e "scale=9; ${_time_diff}/1000000000" | bc)"
				_timeout_diff="$(echo "$_timeout - $_time_diff" | bc)"
				if [[ "$_timeout_diff" == *"-"* ]] #if negative number
				then
					ifu_send_line
					_wait_for_timeout="no"
				fi
			# We are sending and will do a standard read - if it receives input 
			# early, we will send the loop to the above 0-timeout reads
			else
				if [[ "$_timeout_random" == "yes" ]]
				then
					_timeout=$(seq "$_timeout_minimum" 0.01 "$_timeout_maximum" | shuf | head -n 1)
				fi
				_pre_time=$(date +%s%N)
				read -r -t "$_timeout" server_string <&"${ifuproc[0]}" 2>/dev/null
				_post_time=$(date +%s%N)
				_time_diff=$(( _post_time - _pre_time ))
				_time_diff="$(echo -e "scale=9; ${_time_diff}/1000000000" | bc)"
				_timeout_diff="$(echo "$_timeout - $_time_diff" | bc)"
				if [[ "$_timeout_diff" == *"-"* ]] #if negative number
				then
					ifu_send_line
				else
					_wait_for_timeout="yes"
				fi
			fi
		# Not sending yet - no need for timeouts on read or sending
		# Timeout set to default 1 second in case of NickServ timeout
		else
			read -r -t 1 server_string <&"${ifuproc[0]}" 2>/dev/null
		fi
		# INPUT PROCESSING
		# If verbose, output the input we received:
		if [[ "$_verbose" == "yes" ]] && [[ -n "$(echo "$server_string" | tr -d '[:space:]')" ]] && [[ "$_last_line" != "$server_string" ]]
		then
			echo -e "${DIM}$(echo "$server_string" | tr -d $'\r' | tr -d $'\x03' | tr -d $'\x02' | tr -d $'\x15' | tr -d $'\x1D' | tr -d $'\1F' | tr -d $'\x0F')$RESET"
		fi
		_last_line="$server_string"
		# Reply to PING with PONG and restart the loop
		if [[ "$server_string" == "PING "* ]]
		then
			echo -e "PONG${server_string//PING/}\\r" >&"${ifuproc[1]}" 2>/dev/null
			if [[ "$_verbose" == "yes" ]]
			then
				echo -e "${DIM}${GREEN}PONG${server_string//PING/}${RESET}"
			fi
			continue
		fi
		# Identify the Remote Server
		# This should be the first thing the client catches
		# telnet/openssl should not begin any lines with ':'
		if [[ -z "$_remote_server" ]]
		then
			if [[ "$server_string" == ":"* ]]
			then
				_remote_server="$(echo "$server_string" | cut -d' ' -f 1)"
				_remote_server="${_remote_server:1}"
				if [[ "$_verbose" == "yes" ]]
				then
					echo "Remote server is communicating as '$_remote_server'..."
				fi
			fi
		fi
		# HANDLE NICK ERRORS
		# Check for Erroneous Nickname error 432
		if [[ "${server_string^^}" == ":${_remote_server^^} 432 "* ]]
		then
			if [[ ( "$_nick_flood" == "yes" ) || ( "$_mixed_flood" == "yes" ) ]] && [[ "$_ifu_sending" == "yes" ]]
			then
				continue
			elif [[ "$_nick_alt_tried" == "no" ]] && [[ -n "$_nick_alt" ]]
			then
				echo "Erroneous nickname, trying alternate nick..."
				echo -e "NICK ${_nick_alt}\\r" >&"${ifuproc[1]}" 2>/dev/null
				_nick_alt_tried="yes"
				_nick="$_nick_alt"
			else
				echo -e "${BLINK}FATAL:${RESET}\\tErroneous nickname (already in use? invalid name?) no other nick to try"
				return 1
			fi
		fi
		# Check for Nickname Already in Use error 433
		if [[ "${server_string^^}" == ":${_remote_server^^} 433 "* ]]
		then
			if [[ ( "$_nick_flood" == "yes" ) || ( "$_mixed_flood" == "yes" ) ]] && [[ "$_ifu_sending" == "yes" ]]
			then
				continue
			elif [[ "$_nick_alt_tried" == "no" ]] && [[ -n "$_nick_alt" ]]
			then
				echo "Nickname is already in use, trying alternate nick..."
				echo -e "NICK ${_nick_alt}\\r" >&"${ifuproc[1]}" 2>/dev/null
				_nick_alt_tried="yes"
				_nick="$_nick_alt"
			else
				echo -e "${BLINK}FATAL:${RESET}\\tErroneous nickname, no other nick to try"
				return 1
			fi
		fi
		# Check for Nickname Collision error 436
		if [[ "${server_string^^}" == ":${_remote_server^^} 436 "* ]]
		then
			if [[ ( "$_nick_flood" == "yes" ) || ( "$_mixed_flood" == "yes" ) ]] && [[ "$_ifu_sending" == "yes" ]]
			then
				continue
			elif [[ "$_nick_alt_tried" == "no" ]] && [[ -n "$_nick_alt" ]]
			then
				echo "Nickname collision, trying alternate nick..."
				echo -e "NICK ${_nick_alt}\\r" >&"${ifuproc[1]}" 2>/dev/null
				_nick_alt_tried="yes"
				_nick="$_nick_alt"
			else
				echo -e "{BLINK}FATAL:${RESET}\\tErroneous nickname, no other nick to try"
				return 1
			fi
		fi
		# Nickname Changed Too Fast error 438
		if [[ "${server_string^^}" == ":${_remote_server^^} 438 "* ]] && [[ "${server_string^^}" == *":NICK CHANGE TOO FAST."* ]]
		then
			_nick_flood_blocked="yes"
			_nick_flood_block_pre="$(date +%s%N)"
			echo "Delaying changing nick for '$_nick_flood_block_timeout' seconds..."
		fi

		# Process if we are using --wait-for-voice
		if [[ "$_wait_for_voice" == "yes" ]]
		then
			if [[ "${server_string^^}" == *" MODE ${_channel^^} +V ${_nick^^}"* ]]
			then
				echo "Voice was given..."
				_voice_block="no"
			fi
			if [[ "${server_string^^}" == *" MODE ${_channel^^} -V ${_nick^^}"* ]]
			then
				echo "Voice was removed..."
				_voice_block="yes"
				_ifu_sending="no"
			fi
		fi

		# Launch Code
		# If the launch code is sent,
		# Unset the variable so that sending will begin
		if [[ -n "$_launch_code" ]]
		then
			if [[ "${server_string^^}" == *" :${_launch_code^^}"* ]]
			then
				echo "Launch code received..."
				_launch_code=
			fi
		fi

		# Initial message from server - 001
		# (376 is end of motd, but not all nets use it)
		# Handle joining the channel and/or identifying with NickServ

		# Either start trying to identify with nickserv or join channel
		if [[ "$server_string" == ":$_remote_server 001 "* ]]
		then
			if [[ -n "$_nickserv_password" ]]
			then
				echo -e "PRIVMSG ${_nickserv} :identify ${_nickserv_password}\\r" >&"${ifuproc[1]}" 2>/dev/null
				if [[ "$_verbose" == "yes" ]]
				then
					echo -e "${DIM}${FG_GREEN}PRIVMSG $_nickserv :identify ${_nickserv_password}${RESET}"
				fi
				_nickserv_time_sent="$(date +%s)"
				_nickserv_waiting="yes"
				_delay_join_channel="yes"
				echo "Attempting to identify with ${_nickserv}..."
			else
				if [[ -z "$_channel_key" ]]
				then
					echo -e "JOIN ${_channel}\\r" >&"${ifuproc[1]}" 2>/dev/null
					if [[ "$_verbose" == "yes" ]]
					then
						echo -e "${DIM}${FG_GREEN}JOIN ${_channel}${RESET}"
					fi
				else
					echo -e "JOIN $_channel ${_channel_key}\\r" >&"${ifuproc[1]}" 2>/dev/null
					if [[ "$_verbose" == "yes" ]]
					then
						echo -e "${DIM}${FG_GREEN}JOIN $_channel ${_channel_key}${RESET}"
					fi
				fi
				echo "Sent JOIN to channel..."
				_sent_join="yes"
			fi
		fi
		# If the server sends us a list of names or the end of names
		# list for channel (RFC codes 353 or 366), or a channel 
		# topic or notopic reply (RFC 331 and 332)
		# - then we have successfully joined
		if [[ "$_sent_join" == "yes" ]] && [[ "$_joined_channel" == "no" ]] && [[ ( "$server_string" == ":${_remote_server} 353 "* ) || ( "$server_string" == ":${_remote_server} 366 "* ) || ( "$server_string" == ":${_remote_server} 331 "* ) || ( "$server_string" == ":${_remote_server} 332 "* ) ]]
		then
			echo "Successfully joined channel..."
			_joined_channel="yes"
		fi
		# Otherwise, handle nickserv messages:
		# Not registered:
		if [[ "$_nickserv_logged_in" == "no" ]] && [[ ( "${server_string^^}" == ":${_remote_server^^} 401 ${_nick^^} NICKSERV: NO SUCH NICK"* ) || ( ( "${server_string^^}" == *" NOTICE "* ) && ( "${server_string^^}" == *" IS NOT A REGISTERED NICKNAME"* ) ) || ( ( "${server_string^^}" == *" NOTICE "* ) && ( "${server_string^^}" == *" IS NOT REGISTERED"* ) ) ]]
		then
			echo "Nick '$_nick' is not registered - bypassing NickServ"
			_nickserv_logged_in="yes"
			_nickserv_waiting="no"
		fi
		# Mode set +R - login successful
		if [[ "$_nickserv_logged_in" == "no" ]] && [[ "${server_string^^}" == *" MODE ${_nick^^} :+R"* ]]
		then
			echo "Mode set for registered nick - successfully identified with NickServ"
			_nickserv_logged_in="yes"
			_nickserv_waiting="no"
		fi
		# Password Incorrect
		if [[ "$_nickserv_logged_in" == "no" ]] && [[ ( "${server_string^^}" == *" NOTICE ${_nick^^} :PASSWORD INCORRECT"* ) || ( "${server_string^^}" == *" NOTICE ${_nick^^} :INVALID PASSWORD"* ) || ( ( "${server_string^^}" == *" NOTICE ${_nick^^} :THE PASSWORD SUPPLIED FOR"* ) && ( "${server_string^^}" == *"IS INCORRECT"* ) ) ]]
		then
			echo -e "${BLINK}FATAL:${RESET}\\tNickServ password incorrect"
			return 1
		fi
		# Password Accepted
		if [[ "$_nickserv_logged_in" == "no" ]] && [[ ( "${server_string^^}" == *" NOTICE ${_nick^^} :PASSWORD ACCEPTED"* ) || ( "${server_string^^}" == *" NOTICE ${_nick^^} :YOU ARE SUCCESSFULLY IDENTIFIED"* ) || ( "${server_string^^}" == *" NOTICE ${_nick^^} :YOU ARE NOW IDENTIFIED"* ) ]]
		then
			echo "NickServ password accepted"
			_nickserv_logged_in="yes"
			_nickserv_waiting="no"
		fi
		# NickServ Bot Name is Different error 487
		if [[ "$_nickserv_logged_in" == "no" ]] && [[ "$_nickserv_waiting" == "yes" ]] && [[ "${server_string^^}" == ":${_remote_server^^} 487 ${_nick^^} :ERROR! "* ]]
		then
			echo "This server requires a non-generic name for NickServ"
			echo "Next time, specify the full bot name NickServ@network.fqdn using --nickserv-bot <botname>"
			echo "Here is the server error:"
			if [[ "$_verbose" == "no" ]]
			then
				echo "$server_string" | tr -d $'\r' | tr -d $'\x03' | tr -d $'\x02' | tr -d $'\x15' | tr -d $'\x1D' | tr -d $'\x1F' | tr -d $'\x15' | tr -d $'\x0F'
			fi
			echo -e "${BLINK}FATAL:${RESET}\\tNickServ error"
			return 1
		fi
		# Timeout expired waiting for NickServ, bypass it
		current_time=
		if [[ "$_nickserv_logged_in" == "no" ]] && [[ "$_nickserv_waiting" == "yes" ]]
		then
			current_time="$(date +%s)"
		fi
		if [[ "$_nickserv_logged_in" == "no" ]] && [[ "$_nickserv_waiting" == "yes" ]] && [[ "$(( current_time - _nickserv_time_sent ))" -gt "$_nickserv_timeout" ]]
		then
			echo "NickServ timeout expired, bypassing identification..."
			_nickserv_logged_in="yes"
			_nickserv_waiting="no"
		fi
		# If we have now identified with NickServ, join channel
		if [[ "$_delay_join_channel" == "yes" ]] && [[ "$_sent_join" == "no" ]] && [[ "$_nickserv_waiting" == "no" ]] && [[ "$_nickserv_logged_in" == "yes" ]]
		then
			if [[ -z "$_channel_key" ]]
			then
				echo -e "JOIN ${_channel}\\r" >&"${ifuproc[1]}" 2>/dev/null
				if [[ "$_verbose" == "yes" ]]
				then
					echo -e "${DIM}${FG_GREEN}JOIN ${_channel}${RESET}"
				fi
			else
				echo -e "JOIN $_channel ${_channel_key}\\r" >&"${ifuproc[1]}" 2>/dev/null
				if [[ "$_verbose" == "yes" ]]
				then
					echo -e "${DIM}${FG_GREEN}JOIN $_channel ${_channel_key}${RESET}"
				fi
			fi
			echo "Sent JOIN to channel..."
			_sent_join="yes"
			if [[ -n "$_nickserv_filename" ]]
			then
				sed -i.backup -e "${_nickserv_file_line_selected}d" "$_nickserv_filename" 2>/dev/null
				echo "Removed NickServ file entry..."
			fi
		fi

		# Check for any channel joining or sending errors:

		# No Such Channel error 403:
		if [[ "$server_string" == ":$_remote_server 403 "* ]]
		then
			echo -e "${BLINK}FATAL:${RESET}\\tNo such channel (invalid channel name?)"
			return 1
		fi
		# There is no point in addressing a channel ban
		#Correction:  if you get +b, you can perhaps try to part the
		# channel, change nick, then rejoin
		#Just detect if it's a nick or a host ban, if nick, do this
		#If host or nick+host, do nothing
		# TODO ^
		# Kicked from channel:
		if [[ "$server_string" == ":"* ]] && [[ "$(echo \'$server_string\' | cut -d ' ' -f 2)" == *"KICK"* ]] && [[ "$(echo \'${server_string^^}\' | cut -d ' ' -f 3)" == *"${_channel^^}"* ]]
		then
			echo "Kicked from channel..."
			_ifu_sending="no"
			_joined_channel="no"
			if [[ -z "$_channel_key" ]]
			then
				echo -e "JOIN ${_channel}\\r" >&"${ifuproc[1]}" 2>/dev/null
				if [[ "$_verbose" == "yes" ]]
				then
					echo -e "${DIM}${FG_GREEN}JOIN ${_channel}${RESET}"
				fi
			else
				echo -e "JOIN $_channel ${_channel_key}\\r" >&"${ifuproc[1]}" 2>/dev/null
				if [[ "$_verbose" == "yes" ]]
				then
					echo -e "${DIM}${FG_GREEN}JOIN $_channel ${_channel_key}${RESET}"
				fi
			fi
			echo "Sent JOIN to channel..."
		fi
		# Cannot Send to Channel error 404
		if [[ "$server_string" == ":$_remote_server 404 "* ]]
		then
			if [[ "$_dont_give_up" == "yes" ]]
			then
				echo "Cannot send to channel (muted? voiced/registered nicks only? banned?)"
				_current_line_number="$_last_line_number"
			else
				echo -e "${BLINK}FATAL:${RESET}\\tCannot send to channel (muted? voiced/registered nicks only? banned?)"
				return 1
			fi
		fi
		# Channel Full error 471
		if [[ "$server_string" == ":$_remote_server 471 "* ]]
		then
			echo -e "${BLINK}FATAL:${RESET}\\tChannel is full"
			return 1
		fi
		# Channel Invite-Only error 473
		if [[ "$server_string" == ":$_remote_server 473 "* ]]
		then
			echo -e "${BLINK}FATAL:${RESET}\\tChannel is invite-only"
			return 1
		fi
		# Banned From Channel error 474
		if [[ "$server_string" == ":$_remote_server 474 "* ]]
		then
			echo -e "${BLINK}FATAL:${RESET}\\tBanned from this channel - cannot join"
			return 1
		fi
		# Invalid Channel Key error 475
		if [[ "$server_string" == ":$_remote_server 475 "* ]]
		then
			echo -e "${BLINK}FATAL:${RESET}\\tInvalid channel key/password"
			return 1
		fi
		# Channel Requires Registered Nick error 477
		if [[ "$server_string" == ":$_remote_server 477 "* ]]
		then
			echo -e "${BLINK}FATAL:${RESET}\\tChannel requires a registered nick"
			return 1
		fi
		
		# Handle what happens at the end of the loop

		# Are we registering a nick?

		if [[ "$_register_nick" == "yes" ]] && [[ "$_joined_channel" == "yes" ]] && [[ -z "$_launch_code" ]]
		then
			current_time="$(date +%s)"
			if [[ "$_ifu_registering" == "no" ]]
			then
				_ifu_registering="yes"
				_register_nick_time_sent="$(date +%s)"
				echo "Waiting $_register_nick_time seconds before registering nick ${BOLD}${_nick}${RESET}..."
			elif [[ "$(( current_time - _register_nick_time_sent ))" -gt "$_register_nick_time" ]]
			then
				if [[ "$_ifu_registration_sent" == "no" ]]
				then
					echo -e "PRIVMSG ${_nickserv} :REGISTER ${_register_nick_password} ${_register_nick_email}\\r" >&"${ifuproc[1]}" 2>/dev/null
					if [[ "$_verbose" == "yes" ]]
					then
						echo -e "${DIM}${FG_GREEN}PRIVMSG ${_nickserv} :REGISTER ${_register_nick_password} ${_register_nick_email}${RESET}"
					fi
					_ifu_registration_sent="yes"
					echo "Sent NickServ registration attempt..."
					echo "YOU ARE NOW IN INPUT MODE"
					echo -e "You can type ${BOLD}PRIVMSG ${_nickserv} :confirm <code>${RESET} to verify the code emailed to you"
					echo -e "You can also type ${BOLD}PRIVMSG ${_channel} :Some chat text${RESET} to not appear as an idling bot while you are completing this process"
					echo -e "Each prompt lasts one second, but input will be carried over until you press ${BOLD}ENTER${RESET}/${BOLD}RETURN${RESET}"
					echo -e "TYPE ${BOLD}CONFIRM${RESET} IF YOU WANT TO SAVE THIS REGISTRATION AND EXIT"
					echo -e "Otherwise, press ${BOLD}CTRL + C${RESET} to exit"
					echo "Enjoy!"
					_verbose="yes"
				else
					if [[ -z "${server_string}" ]]
					then
						read -r -t 1 input_data
						if [[ "${input_data^^}" == "CONFIRM" ]]
						then
							echo -e "Successfully registered ${BOLD}${_nick}:${_register_nick_password}${RESET}"
							if [[ -n "$_nickserv_filename" ]]
							then
								echo "${_nick}:${_register_nick_password}" >> "$_nickserv_filename"
								echo "Appended entry to '$_nickserv_filename'"
							fi
							exit 0
						fi
						if [[ -n "$input_data" ]]
						then
							echo -e "$(echo "$input_data" | tr -d '\n')\\r" >&"${ifuproc[1]}" 2>/dev/null
							if [[ "$_verbose" == "yes" ]]
							then
								echo -e "${DIM}${FG_GREEN}${input_data}${RESET}"
							fi
						fi
					fi
				fi
			fi
		fi

		# Are we sending?

		if [[ "$_joined_channel" == "yes" ]] && [[ "$_ifu_sending" == "no" ]] && [[ -z "$_launch_code" ]] && [[ "$_register_nick" == "no" ]]
		then
			if [[ "$_voice_block" == "no" ]]
			then
				if [[ -n "$_delay" ]] && [[ "$_have_delayed" == "no" ]]
				then
					echo "Sleeping for '$_delay' seconds before sending..."
					if [[ "$_verbose" == "yes" ]]
					then
						echo -e "${DIM}${RED}sleep ${_delay}${RESET}"
					fi
					sleep "$_delay"
					_have_delayed="yes"
				fi
				echo "Sending data..."
				_ifu_sending="yes"
			fi
		fi
	done
}
###############################################################################
# Run the program:
###############################################################################
if [[ "$_loop" == "no" ]]
then
	if [[ -n "$_preexec" ]]
	then
		$_preexec
	fi
	ifu
	if [[ -n "$_postexec" ]]
	then
		$_postexec
	fi
else
	while true
	do
		if [[ -n "$_preexec" ]]
		then
			$_preexec
		fi
		ifu
		ifu_exit
		if [[ -n "$_postexec" ]]
		then
			$_postexec
		fi
	done
fi
