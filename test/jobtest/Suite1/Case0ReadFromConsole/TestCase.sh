PREPS='myPrep'
STEPS='true'
FINS='myFin'

myPrep() {
	echo "*************** $FUNCNAME $-"
	local x=0
	echo -e -n "\a"
	echo -e "\033[31m**************************************************************************
**************************************************************************
****               press any key                                      ****
**************************************************************************
**************************************************************************\033[0m"
	if read -n 1 ; then
		echo "Read success REPLY='$REPLY'"
	else
		x=$?
		echo "Read return $x REPLY='$REPLY'"
	fi
	echo "*************** $FUNCNAME END"
	return $x
}

myFin() {
	echo "*************** $FUNCNAME $-"
	echo "$varNotInitialized"
	echo "*************** $FUNCNAME END"
}
