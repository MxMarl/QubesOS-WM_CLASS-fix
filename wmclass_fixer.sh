#!/bin/bash

#https://github.com/mxmarl


#COLORS
NC="\033[0m"
Gray="\033[1;30m"
BRed="\033[1;31m"
BBlue="\033[1;34m"
BGreen="\033[1;32m"
BYellow="\033[1;33m"
info="${BYellow}[i]${NC}"
error="${BRed}[✗]${NC}"
tick="${BGreen}[✓]${NC}"
done="${BGreen} done!${NC}"



printf "\033c"
echo -e "$info Please $BYellow click $NC in the wanted window..."
XPROP_MAIN=$(xprop | grep 'WM_CLASS\|WM_CLIENT_MACHINE')
XPROP=$(echo $XPROP_MAIN | grep WM_CLASS | awk '{print $4}' | tr -d '"' )
IS_DOM0=$(echo $XPROP_MAIN | grep WM_CLIENT_MACHINE | awk '{print $3}' | tr -d '"')
CLASS=$(echo $XPROP | sed 's/^.*://')
IS_FILE=$(find . -iname "*$CLASS*" | cut -c 3-)





SHOW_RESULT(){
	case $PRINT_MODE in
		1)
		echo -e "$tick Class $BBlue $CLASS $NC successfully imported into $BBlue $i $NC"
		;;

		2)
		echo -e "$error Class $CLASS already in $BBlue $i $NC"
		;;

		3)
		echo -e "$info Files/s for class import are available ...\n"
		;;

		4)
		echo -e "$error No files were found for class $BBlue $CLASS $NC to import"
		exit 1
		;;

		5)
		echo -e "$info SUMMARY: $BYellow $(($COUNT_A - $COUNT_B)) $NC OF $BYellow $COUNT_A $NC changed! "
		exit 0
		;;

		6)
		echo -e "$error Sorry, please don't use dom0 windows!"
		exit 1
		;;

		*)
		echo -e "$error $BRed Unknown error appeared! $NC"
		exit 1
		;;

	esac
}



INSERT_CLASS_IN(){
	COUNT_A=0
	COUNT_B=0

for i in $IS_FILE;
do
	let COUNT_A++

	#Fix for diff Debian (Firefox ESR) and Fedora (Firefox)
	if [[ $(grep -Rw "Name" $i | awk '{print $2, $3}') == "Firefox ESR" ]]; then
		APP_VM=$(grep -Rw "Name" $i | awk '{print $1}' | sed 's/^[^=]*=//')
		VALUE="StartupWMClass=$APP_VM$CLASS-esr"
	#Fix for exotic classes (some)
	elif [[ "$MODE" == "CUS" ]]; then
		APP_VM=$(grep -Rw "Name" $i | awk '{print $1}' | sed 's/^[^=]*=//')
		CUS_VAL=$(grep -Rw "Name" $i | awk '{print $2, $3}')
		VALUE="StartupWMClass=$APP_VM$CUS_VAL"
	else
		APP_VM=$(grep -Rw "Name" $i | awk '{print $1}' | sed 's/^[^=]*=//')
		VALUE="StartupWMClass=$APP_VM$CLASS"
	fi

	if grep --quiet -Rw $VALUE $i; then
		let COUNT_B++
		PRINT_MODE=2
		SHOW_RESULT
	else
		echo "$VALUE" >> $i
		PRINT_MODE=1
		SHOW_RESULT
	fi
done
}


if [[ "$IS_DOM0" == "dom0" ]]; then
	PRINT_MODE=6
	SHOW_RESULT
fi

#Custom App_VMs/Class will be grep'ed from a csv file in the future
if [[ "$CLASS" == "draw.io" ]]; then
	CLASS="drawio"
	IS_FILE=$(find . -iname "*$CLASS*" | cut -c 3-)
	MODE="CUS"
	INSERT_CLASS_IN

elif [[ "$CLASS" == "jetbrains-pycharm-ce" ]]; then
		CLASS="pycharm"
		IS_FILE=$(find . -iname "*$CLASS*" | cut -c 3-)
		MODE="CUS"
		INSERT_CLASS_IN

elif [[ -n $IS_FILE ]]; then
		PRINT_MODE=3
		SHOW_RESULT
		INSERT_CLASS_IN
else
	PRINT_MODE=4
	SHOW_RESULT
fi


PRINT_MODE=5
SHOW_RESULT
