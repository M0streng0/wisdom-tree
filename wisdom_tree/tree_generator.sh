#!/usr/bin/env bash

# I'm a bonsai-making machine!

#################################################
##
# original author:  John Allbritten
# adapted by:  Henrique Oliveira - M0streng0
# license: GPLv3
# repo:    https://gitlab.com/jallbrit/bonsai.sh
#
#  this script is constantly being updated, so
#  check repo for most up-to-date version.
##
#################################################

# ------ vars ------

folder="res/steps"

seed="$RANDOM"
RANDOM=$seed

leafStrs='&'
baseType=$((RANDOM % 4 + 1))

multiplier=5
lifeStart=28

# Initialize step counter
stepCounter=1

# ensure locale is correct
LC_ALL="en_US.UTF-8"

if [ -f "$folder/p1.txt" ]; then
    rm $folder/p*.txt
fi

# ensure Bash version >= 4.0
if ((BASH_VERSINFO[0] < 4)); then
	printf '%s\n' "Error: bonsai.sh requires Bash v4.0 or higher. You have version $BASH_VERSION." 1>&2
	exit 2
fi

# ensure MacOS compatibility with GNU getopt
if [[ "$OSTYPE" == 'darwin'* ]]; then
    GGETOPT="/usr/local/Cellar/gnu-getopt/*/bin/getopt" # should find gnu-getopt
    if [ ! -x $GGETOPT ]; then # file is not executable
        printf '%s\n' 'Error: Running on MacOS requires an executable gnu getopt.' 1>&2
        exit 2
    fi
    shopt -s expand_aliases
    alias getopt='$GGETOPT' # replace getopt with gnu getopt
fi

IFS=$'\n'	# delimit by newline
tabs 4

# define colors
BOLD="$(tput bold)"
RESET="$(tput sgr0)"
BROWN='\e[38;5;172m'
DARK_BROWN='\e[38;5;130m'
DARK_GREEN='\e[38;5;142m'
GREEN='\e[38;5;106m'
GRAY='\e[38;5;243m'

# create ascii base in lines
case "$baseType" in
	1)
		width=15
		art="\
${GRAY}:${GREEN}___________${DARK_BROWN}./~~\\.${GREEN}___________${GRAY}:
 \\                          /
  \\________________________/
  (_)                    (_)"
		;;

	2)
		width=7
		art="\
${GRAY}(${GREEN}---${DARK_BROWN}./~~\\.${GREEN}---${GRAY})
 (          )
  (________)"
		;;

	3)
		width=15
		art="\
${GRAY}╓${GREEN}───────────${DARK_BROWN}╭╱⎨⏆╲╮${GREEN}───────────${GRAY}╖
║                            ║
╟────────────────────────────╢
╟────────────────────────────╢
╚════════════════════════════╝"
		;;

	*)  art="" ;;
esac

# get base height
baseHeight=0
for line in $art; do
	baseHeight=$(( baseHeight + 1 ))
done

# create leafArray
declare -A leafArray
leafArrayLen=0
# parse each string in comma-separated $leafStrs
for str in ${leafStrs//,/$'\n'}; do

	leafArray[$leafArrayLen,0]=${#str} 	# first item in sub-array is length

	# for character in string, add to the sub-array
	for (( i=0; i < ${#str}; i++ )); do
		leafArray[$leafArrayLen,$((i+1))]="${str:$i:1}"
	done
	leafArrayLen=$((leafArrayLen+1))
done

setGeometry() {
	geometry="$COLUMNS,$LINES"	# these vars automatically update
	cols="$(printf '%s' "$geometry" | cut -d ',' -f1)"	# width; X
	rows="$(printf '%s' "$geometry" | cut -d ',' -f2)"	# height; Y

	rows=$((rows - baseHeight)) 	# so we don't grow a tree on top of the base
}

init() {
	IFS=$'\n'	# delimit strings by newline
	# add spaces before base so that it's in the middle of the terminal
	base=""
	iter=1
	for line in $art; do
		filler=""
		for (( i=0; i <= (cols / 2 - width); i++)); do
			filler+=" "
		done
		base+="${filler}${line}"
		[ $iter -ne $baseHeight ] && base+='\n'
		iter=$((iter+1))
	done
	unset IFS	# reset delimiter

	# declare vars
	branches=0
	shoots=0

	branchesMax=$((multiplier * 110))
	shootsMax=$multiplier

	# fill grid full of spaces
	declare -Ag grid
	for (( row=0; row <= rows; row++ )); do
		listChanged[$row]=0
		for (( col=0; col < cols; col++ )); do
			grid[$row,$col]=' '
		done
	done

	stty_settings="$(stty -g)"
	stty -echo 				# don't echo stdin
	# printf '%b' '\e[?25l\e[?7l\e[2J' 	# hide cursor, disable line wrapping, clear screen and move to 0,0
}

grow() {
	local x=$((cols / 2))	# start halfway across the screen
	local y="$rows"		# start just above the base
	branch "$x" "$y" trunk "$lifeStart"
}

branch() {
	# declarations
	local x=$1
	local y=$2
	local type=$3
	local life=$4
	local dx=0
	local dy=0
	local chars=()

	branches=$((branches + 1))

	# as long as we're alive...
	while [ "$life" -gt 0 ]; do

		life=$((life - 1))	# ensure life ends

		# set dy based on type
		case $type in
			shoot*)	# trend horizontal/downward growth
				case "$((RANDOM % 10))" in
					[0-1]) dy=-1 ;;
					[2-7]) dy=0 ;;
					[8-9]) dy=1 ;;
				esac
				;;

			dying) # discourage vertical growth
				case "$((RANDOM % 10))" in
					[0-1]) dy=-1 ;;
					[2-8]) dy=0 ;;
					[9-10]) dy=1 ;;
				esac
				;;

			*)	# grow up/not at all
				dy=0
				[ "$life" -ne "$lifeStart" ] && [ $((RANDOM % 10)) -gt 2 ] && dy=-1
				;;
		esac
		# if we're about to hit the ground, cut it off
		[ "$dy" -gt 0 ] && [ "$y" -gt $(( rows - 1 )) ] && dy=0
		[ "$type" = "trunk" ] && [ "$life" -lt 4 ] && dy=0

		# set dx based on type
		case $type in
			shootLeft)	# tend left: dx=[-2,1]
				case $(( RANDOM % 10 )) in
					[0-1]) dx=-2 ;;
					[2-5]) dx=-1 ;;
					[6-8]) dx=0 ;;
					[9]) dx=1 ;;
				esac ;;

			shootRight)	# tend right: dx=[-1,2]
				case $(( RANDOM % 10 )) in
					[0-1]) dx=2 ;;
					[2-5]) dx=1 ;;
					[6-8]) dx=0 ;;
					[9]) dx=-1 ;;
				esac ;;

			dying)	# tend left/right: dx=[-3,3]
				dx=$(( (RANDOM % 7) - 3)) ;;

			*)	# tend equal: dx=[-1,1]
				dx=$(( (RANDOM % 3) - 1)) ;;

		esac

		# re-branch upon conditions
		if [ $branches -lt $branchesMax ]; then

			# branch is dead
			if [ $life -lt 3 ]; then
				branch "$x" "$y" dead "$life"

			# branch is dying and needs to branch into leaves
			elif [ "$type" = trunk ] && [ "$life" -lt $((multiplier + 2)) ]; then
				branch "$x" "$y" dying "$life"

			elif [[ $type = "shoot"* ]] && [ "$life" -lt $((multiplier + 2)) ]; then
				branch "$x" "$y" dying "$life"

			# re-branch if: not close to the base AND (pass a chance test OR be a trunk, not have too many shoots already, and not be about to die)
			elif [[ $type = trunk && $life -lt $((lifeStart - 8)) \
			&& ( $(( RANDOM % (16 - multiplier) )) -eq 0 \
			|| ($type = trunk && $(( life % 5 )) -eq 0 && $life -gt 5) ) ]]; then

				# if a trunk is splitting and not about to die, chance to create another trunk
				if [ $((RANDOM % 3)) -eq 0 ] && [ $life -gt 7 ]; then
					branch "$x" "$y" trunk "$life"

				elif [ "$shoots" -lt "$shootsMax" ]; then

					# give the shoot some life
					tmpLife=$(( life + multiplier - 2 ))
					[ $tmpLife -lt 0 ] && tmpLife=0

					# first shoot is randomly directed
					if [ $shoots -eq 0 ]; then
						tmpType="shootLeft"
						[ $((RANDOM % 2)) -eq 0 ] && tmpType="shootRight"

					# secondary shoots alternate from the first
					else
						case "$tmpType" in
							shootLeft) # last shoot was left, shoot right
								tmpType="shootRight" ;;
							shootRight) # last shoot was right, shoot left
								tmpType="shootLeft" ;;
						esac
					fi
					branch "$x" "$y" "$tmpType" "$tmpLife"
					shoots=$((shoots + 1))
				fi
			fi
		else # we're past max branches but want to branch
			chars=('<->')
		fi

		# implement dx,dy
		x=$((x + dx))
		y=$((y + dy))

		# choose color
		case $type in
			trunk|shoot*)
				color=$DARK_BROWN
				[ $(( RANDOM % 4 )) -eq 0 ] && color=$BROWN
				;;

			dying) color=$DARK_GREEN ;;

			dead) color=$GREEN ;;
		esac

		# choose branch character
		case $type in
			trunk)
				if [ $dx -lt 0 ]; then
					chars=('\\')
				elif [ $dx -eq 0 ]; then
					chars=('/' '|')
				elif [ $dx -gt 0 ]; then
					chars=('/')
				fi
				[ $dy -eq 0 ] && chars=('/' '~')	# not growing
				#[ $dy -lt 0 ] && chars=('/' '~')	# growing
				;;

			# shoots tend to look horizontal
			shootLeft)
				case $dx in
					[-3,-1]) 	chars=('\\' '|') ;;
					[0]) 		chars=('/' '|') ;;
					[1,3]) 		chars=('/') ;;
				esac
				#[ $dy -lt 0 ] && chars=('/' '~')	# growing up
				[ $dy -gt 0 ] && chars=('/')	# growing down
				[ $dy -eq 0 ] && chars=('\\' '_')	# not growing
				;;

			shootRight)
				case $dx in
					[-3,-1]) 	chars=('\\' '|') ;;
					[0]) 		chars=('/' '|') ;;
					[1,3]) 		chars=('/') ;;
				esac
				#[ $dy -lt 0 ] && chars=('')	# growing up
				[ $dy -gt 0 ] && chars=('\\')	# growing down
				[ $dy -eq 0 ] && chars=('_' '/')	# not growing
				;;
		esac

		# randomly choose leaf character
		if [ $life -lt 4 ]; then
			chars=()
			randIndex=$((RANDOM % leafArrayLen))

			# add each char in our randomly chosen list to our chars
			for (( i=0; i < ${leafArray[$randIndex,0]}; i++)); do
				chars+=("${leafArray[$randIndex,$((i+1))]}")
			done
		fi

		# add character(s) to our grid
		index=0
		for char in "${chars[@]}"; do
			newX=$((x+index))
			grid[$y,$newX]="${color}${char}${RESET}"

			# ensure we keep track of last column
			[ ${y:-0} -gt 0 ] && [ -n "${listChanged[$y]}" ] && [ ${newX:-0} -gt ${listChanged[$y]} ] && listChanged[$y]=$newX
			index=$((index+1))
		done
	done
    display "$stepCounter" # Pass current step number to display
    stepCounter=$((stepCounter + 1)) # Increment step counter
}

display() {
    local stepNumber=$1 # Capture the step number passed as an argument
    local output=""
    local filename="$folder/p${stepNumber}.txt" # Define filename based on step number

	# parse grid for output
	for (( row=0; row < rows; row++)); do
		lineArray=()

		# only parse to the last known column with a char in it
		for (( col=0; col <= listChanged[row]; col++ )); do

			# grab the character from our grid
			lineArray["$col"]="${grid[$row,$col]}"
		done
		line="${lineArray[*]}" 	# combine array elements into a string

		IFS=''
		output+="$line\\n"
	done

	output+="$base" 	# add the ascii-art base we generated earlier
	printf '%b' "$output"
    wait 0.001
    echo -e "$output" > "$filename" # Write output to file
}

quit() {
	stty "$stty_settings"
	printf '%b\n' '\e[?25h\e[?7h'"$RESET" 	# show cursor, enable line wrapping, reset colors
	tabs -8
	exit 0
}

main() {
	setGeometry
	init
	grow
	# display
}

main
quit
