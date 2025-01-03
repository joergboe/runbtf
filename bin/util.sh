######################################################
# Utilities for testframework
# (public utilities)
######################################################

TT_evaluationFile='./EVALUATION.log' # the standard log file for evaluation
TTTT_result=-1 # the global result var

TTRO_help_setFailure='
# Function setFailure
#	set the user defined failure condition in a test case script
#	to be used in failed test case steps only
# Parameters:
#	$1 - the user defined failure text
# Returns:
#	success
# Exits:
#	if called from a test suite script
#	if called with empty argument $1'
function setFailure {
	if isExisting 'TTRO_variantCase'; then # this is a case
		if [[ $TTTT_executionState != 'execution' ]]; then
			printWarning "${FUNCNAME[0]} called in phase $TTTT_executionState. Use this function only in phase 'execution'"
		fi
		if [[ $# -gt 0 ]]; then
			if [[ -z $1 ]]; then
				printErrorAndExit "${FUNCNAME[0]} must not be called with empty argument \$1" "${errRt}"
			fi
			TTTT_failureOccurred="$1"
		else
			TTTT_failureOccurred='unspecified'
		fi
		printError "${FUNCNAME[0]} : $TTTT_failureOccurred"
		return 0
	else # this is not a case
		printErrorAndExit "Do not call the function ${FUNCNAME[0]} in a test suite context" "${errRt}"
	fi
}
readonly -f setFailure

TTRO_help_setCategory='
# Function setCategory
#	set the assigned categories of a test case or suite
#	Use this function in initialization phase of case or suite only
#	If this function is not used, a
#		suite has no category assigned
#		a case has the category "default"
#	If this function is called with no parameters, the list
#	with the assigned categories becomes the empty list.
#	$1 ... the category identifieres of this atrifact'
function setCategory {
	if [[ $TTTT_executionState != 'initializing' ]]; then
		printErrorAndExit "${FUNCNAME[0]} must be called in state 'initializing' state now: $TTTT_executionState" "${errRt}"
	fi
	TTTT_categoryArray=()
	local i=0
	while [[ $# -ge 1 ]]; do
		TTTT_categoryArray[$i]="$1"
		i=$((i+1))
		shift
	done
}
readonly -f setCategory

TTRO_help_setSkip='
# Function setSkip
#	set the skip condition TTPRN_skip in initialization phase of case or suite
#	use the supplied value or unspecified
# Params:
#	$1 - optional the reason to skip this value must not be empty
# Returns:
#	success
# Exits:
#	if called in another phase than initializing
#	if called with empty argument $1'
function setSkip {
	if [[ $TTTT_executionState != 'initializing' ]]; then
		printErrorAndExit "${FUNCNAME[0]} must be called in state 'initializing' state now: $TTTT_executionState" "${errRt}"
	fi
	if [[ $# -gt 0 ]]; then
		if [[ -z $1 ]]; then
			printErrorAndExit "${FUNCNAME[0]} must not be called with empty argument \$1" "${errRt}"
		fi
		setVar 'TTPRN_skip' "$1"
	else
		setVar 'TTPRN_skip' 'unspecified'
	fi
	printInfo "${FUNCNAME[0]} : $TTPRN_skip"
}
readonly -f setSkip

TTRO_help_printErrorAndExit="
# Function printErrorAndExit
# 	prints an error message and exits
#	\$1 the error message to print
#	\$2 optional exit code, default is ${errRt}
#	returns: never"
function printErrorAndExit {
	printError "$1"
	local errcode="${errRt}"
	if [[ $# -gt 1 ]]; then errcode="$2"; fi
	echo -e "\033[31m EXIT: $errcode ***************"
	local -i i=0;
	while caller $i; do
		i=$((i+1))
	done
	echo -e "************************************************\033[0m"
	exit "$errcode"
}
readonly -f printErrorAndExit

TTRO_help_printError="
# Function printError
#	prints an error message
#	\$1 the error message to print
#	returns:
#		success (0)
#		error	in exceptional cases"
function printError {
	local dd; dd=$(date "+%T %N")
	echo -e "\033[31m$dd ERROR: $1\033[0m" >&2
}
readonly -f printError

TTRO_help_printWarning="
# Function printWarning
#	prints an warning message
#	\$1 the warning to print
#	returns:
#		success (0)
#		error	in exceptional cases"
function printWarning {
	local dd; dd=$(date "+%T %N")
	echo -e "\033[33m$dd WARNING: $1\033[0m" >&2
}
readonly -f printWarning

TTRO_help_printDebug="
# Function printDebug
#	prints debug info
#	\$1 the debug info to print
#	returns:
#		success (0)
#		error	in exceptional cases"
function printDebug {
	local -i i
	local stackInfo=''
	local dd; dd=$(date "+%T %N")
	for ((i=${#FUNCNAME[@]}-1; i>0; i--)); do
		stackInfo="$stackInfo ${FUNCNAME[$i]}"
	done
	echo -e "\033[32m$dd DEBUG: ${TTTI_commandname}${stackInfo}: ${1}\033[0m"
}
readonly -f printDebug

TTRO_help_printDebugn="
# Function printDebugn
#	prints debug info without newline
#	\$1 the debug info to print
#	returns:
#		success (0)
#		error	in exceptional cases"
function printDebugn {
	local -i i
	local stackInfo=''
	local dd; dd=$(date "+%T %N")
	for ((i=${#FUNCNAME[@]}-1; i>0; i--)); do
		stackInfo="$stackInfo ${FUNCNAME[$i]}"
	done
	echo -en "\033[32m$dd DEBUG:${TTTI_commandname}${stackInfo}: ${1}\033[0m"
}
readonly -f printDebugn

TTRO_help_printInfo="
# Function printInfo
#	prints info info
#	\$1 the info to print
#	returns:
#		success (0)
#		error	in exceptional cases"
function printInfo {
	local dd; dd=$(date "+%T %N")
	echo -e "$dd INFO: ${1}"
}
readonly -f printInfo

TTRO_help_printInfon="
# Function printInfon
#	prints info info without newline
#	\$1 the info to print
#	returns:
#		success (0)
#		error	in exceptional cases"
function printInfon {
	local dd; dd=$(date "+%T %N")
	echo -en "$dd INFO: ${1}"
}
readonly -f printInfon

TTRO_help_printVerbose="
# Function printVerbose
#	prints verbose info
#	\$1 the info to print
#	returns:
#		success (0)
#		error	in exceptional cases"
function printVerbose {
	local dd; dd=$(date "+%T %N")
	echo -e "$dd VERBOSE: ${1}"
}
readonly -f printVerbose

TTRO_help_printVerbosen="
# Function printVerbosen
#	prints verbose info without newline
#	\$1 the info to print
#	returns:
#		success (0)
#		error	in exceptional cases"
function printVerbosen {
	local dd; dd=$(date "+%T %N")
	echo -en "$dd VERBOSE: ${1}"
}
readonly -f printVerbosen

TTRO_help_isDebug="
# Function isDebug
# 	returns:
#		success(0) if debug is enabled
#		error(1)   otherwise "
function isDebug {
	if [[ -n $TTPRN_debug && -z $TTPRN_debugDisable ]]; then
		return 0	# 0 is true in bash
	else
		return 1
	fi
}
readonly -f isDebug

TTRO_help_isVerbose="
# Function isVerbose
#	returns
#		success(0) if debug is enabled
#		error(1)   otherwise "
function isVerbose {
	if [[ ( -n $TTPRN_verbose && -z $TTPRN_verboseDisable ) || (-n $TTPRN_debug && -z $TTPRN_debugDisable) ]]; then
		return 0
	else
		return 1
	fi
}
readonly -f isVerbose

TTRO_help_printTestframeEnvironment="
# Function printTestframeEnvironment
# 	print special testrame environment
#	returns:
#		success (0)
#		error	in exceptional cases"
function printTestframeEnvironment {
	echo "**** Testframe Environment ****"
	echo "PWD=$PWD"
	local x
	for x in 'PREPS' 'STEPS' 'FINS'; do
		if declare -p "$x" &> /dev/null; then
			declare -p "$x"
		fi
	done
	for x in "${!TT_@}"; do
		echo "${x}='${!x}'"
	done
	for x in "${!TTRO_@}"; do
		if [[ $x != TTRO_help* ]]; then
			echo "${x}='${!x}'"
		fi
	done
	for x in "${!TTPR_@}"; do
		echo "${x}='${!x}'"
	done
	for x in "${!TTPRN_@}"; do
		echo "${x}='${!x}'"
	done
	for x in "${!TTXX_@}"; do
		echo "${x}='${!x}'"
	done
	echo "*******************************"
}
readonly -f printTestframeEnvironment

TTRO_help_dequote='
# Removes the sorounding quotes
#	and prints result to stdout
#	to be used withg care unquoted whitespaces are removed
#	$1 the value to dequote
#	returns:
#		success (0)
#		error	in exceptional cases'
function dequote {
	#eval printf %s "$1" 2> /dev/null
	eval printf %s "$1"
}
readonly -f dequote

TTRO_help_isPureNumber='
# Checks whether the input string is a ubsigned number [0-9]+
# $1 the string to check
# returns
#	success(0)  if the input are digits only
#	error(1)    otherwise'
function isPureNumber {
	if [[ $1 =~ [0-9]+ ]]; then
		if [[ "${BASH_REMATCH[0]}" == "$1" ]]; then
			isDebug && printDebug "${FUNCNAME[0]} '$1' return 0"
			return 0
		fi
	fi
	isDebug && printDebug "${FUNCNAME[0]} '$1' return 1"
	return 1
}
readonly -f isPureNumber

TTRO_help_isNumber='
# Checks whether the input string is a signed or unsigned number ([-+])[0-9]+
# $1 the string to check
# returns
#	success(0)  if the input is a number
#	error(1)    otherwise'
function isNumber {
	if [[ $1 =~ [0-9]+ ]]; then
		if [[ "${BASH_REMATCH[0]}" == "$1" ]]; then
			isDebug && printDebug "${FUNCNAME[0]} '$1' return 0"
			return 0
		fi
	elif [[ $1 =~ [-+][0-9]+ ]]; then
		if [[ "${BASH_REMATCH[0]}" == "$1" ]]; then
			isDebug && printDebug "${FUNCNAME[0]} '$1' return 0"
			return 0
		fi
	fi
	isDebug && printDebug "${FUNCNAME[0]} '$1' return 1"
	return 1
}
readonly -f isNumber

TTRO_help_setVar='
# Function setVar
#	Set framework variable or property at runtime
#	The name of the variable must startg with TT_, TTRO_, TTPR_ or TTPRN_
# Parameters:
#	$1 - the name of the variable to set
#	$2 - the value
# Returns
#	success (0) - if the variable could be set or if an property value is ignored
# Exits:
#	if variable is not of type TT_, TTRO_, TTPR_ or TTPRN_
#	or if the variable could not be set (e.g a readonly variable was already set
#	ignored property values do not generate an error'
function setVar {
	if [[ $# -ne 2 ]]; then printErrorAndExit "${FUNCNAME[0]} missing params. Number of Params is $#" "${errRt}"; fi
	isDebug && printDebug "${FUNCNAME[0]} $1 $2"
	case $1 in
		TTPRN_* )
			#set property only if it is unset or null an make it readonly
			if ! declare -p ${1} &> /dev/null || [[ -z ${!1} ]]; then
				if ! eval export \'${1}\'='"${2}"'; then
					printErrorAndExit "${FUNCNAME[0]} : Invalid expansion in varname=${1} value=${2}" ${errRt}
				else
					isVerbose && printVerbose "${FUNCNAME[0]} : ${1}='${!1}'"
				fi
				if [[ -n ${!1} ]]; then
					readonly ${1}
				fi
			else
				isVerbose && printVerbose "${FUNCNAME[0]} ignore value for ${1}"
			fi
		;;
		TTPR_* )
			#set property only if it is unset an make it readonly
			if ! declare -p "${1}" &> /dev/null; then
				if ! eval export \'${1}\'='"${2}"'; then
					printErrorAndExit "${FUNCNAME[0]} : Invalid expansion varname=${1} value=${2}" ${errRt}
				else
					isVerbose && printVerbose "${FUNCNAME[0]} : ${1}='${!1}'"
				fi
				readonly ${1}
			else
				isVerbose && printVerbose "${FUNCNAME[0]} ignore value for ${1}"
			fi
		;;
		TTRO_* )
			#set a global readonly variable
			if eval export \'${1}\'='"${2}"'; then
				isVerbose && printVerbose "${FUNCNAME[0]} : ${1}='${!1}'"
			else
				printErrorAndExit "${FUNCNAME[0]} : Invalid expansion varname=${1} value=${2}" ${errRt}
			fi
			readonly ${1}
		;;
		TT_* )
			#set a global variable
			if ! eval export \'${1}\'='"${2}"'; then
				printErrorAndExit "${FUNCNAME[0]} : Invalid expansion varname=${1} value=${2}" ${errRt}
			else
				isVerbose && printVerbose "${FUNCNAME[0]} : ${1}='${!1}'"
			fi
		;;
		* )
			#other variables
			printErrorAndExit "${FUNCNAME[0]} : Invalid property or variable varname=${1} value=${2}" ${errRt}
		;;
	esac
	:
}
readonly -f setVar

TTRO_help_isExisting='
# Function isExisting
#	check if variable exists
# Parameters:
#	$1 - variable name to be checked
# Returns:
#		success(0)    if the variable exists
#		error(1)      otherwise
# Exits
#	if called without argument'
function isExisting {
	if declare -p "${1}" &> /dev/null; then
		isDebug && printDebug "${FUNCNAME[0]} $1 return 0"
		return 0
	else
		isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
		return 1
	fi
}
readonly -f isExisting

TTRO_help_isNotExisting='
# Function isNotExisting
#	check if variable not exists
# Parameters:
#	$1 - variable name to be checked
# Returns:
#	success(0) - if the variable not exists
#	error(1)   -   otherwise
# Exits
#	if called without argument'
function isNotExisting {
	if declare -p "${1}" &> /dev/null; then
		isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
		return 1
	else
		isDebug && printDebug "${FUNCNAME[0]} $1 return 0"
		return 0
	fi
}
readonly -f isNotExisting

TTRO_help_isExistingAndTrue='
# Function isExistingAndTrue
#	check if variable exists and has a non empty value
# Parameters:
#	$1 - var name to be checked
# Returns
#	success(0) - the variable exists and has a non empty value
#	error(1)   - otherwise
# Exits
#	if called without argument'
function isExistingAndTrue {
	if declare -p "${1}" &> /dev/null; then
		if [[ -n ${!1} ]]; then
			isDebug && printDebug "${FUNCNAME[0]} $1 return 0"
			return 0
		else
			isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
			return 1
		fi
	else
		isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
		return 1
	fi
}
readonly -f isExistingAndTrue

TTRO_help_isExistingAndFalse='
# Function isExistingAndFalse
#	check if variable exists and has an empty value
# Parameters:
#	$1 - var name to be checked
# Returns
#	success(0) - exists and has an empty value
#	error(1)   - otherwise
# Exits
#	if called without argument'
function isExistingAndFalse {
	if declare -p "${1}" &> /dev/null; then
		if [[ -z ${!1} ]]; then
			isDebug && printDebug "${FUNCNAME[0]} $1 return 0"
			return 0
		else
			isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
			return 1
		fi
	else
		isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
		return 1
	fi
}
readonly -f isExistingAndFalse

TTRO_help_isTrue='
# Function isTrue
#	check if a variable has a non empty value
# Parameters:
#	$1 - var name to be checked
# Returns
#	success(0) - variable exists and has a non empty value
#	error(1)   - variable exists and has a empty value
# Exits:
#	if variable not exists
#	if called without argument'
function isTrue {
	if declare -p "${1}" &> /dev/null; then
		if [[ -n ${!1} ]]; then
			isDebug && printDebug "${FUNCNAME[0]} $1 return 0"
			return 0
		else
			isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
			return 1
		fi
	else
		printErrorAndExit "Variable $1 not exists" "${errRt}"
	fi
}
readonly -f isTrue

TTRO_help_isFalse='
# Function isFalse
#	check if a variable has an empty value
# Parameters:
#	$1 - var name to be checked
# Returns
#	success(0)  - if the variable exists and has a empty value
#	error(1)    - if the variable exists and has an non empty value
# Exits:
#	if variable not exists
#	if called without argument'
function isFalse {
	if declare -p "${1}" &> /dev/null; then
		if [[ -z ${!1} ]]; then
			isDebug && printDebug "${FUNCNAME[0]} $1 return 0"
			return 0
		else
			isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
			return 1
		fi
	else
		printErrorAndExit "Variable $1 not exists" "${errRt}"
	fi
}
readonly -f isFalse

TTRO_help_isArray='
# Function isArray
#	checks whether an variable exists and is an indexed array
# Parameters:
#	$1 - var name to be checked
# Returns
#	success(0) - if the variable exists and is an indexed array
#	error(1)   -  otherwise
# Exits:
#	if called without argument'
function isArray {
	local v
	if v=$(declare -p "${1}" 2> /dev/null); then
		if [[ $v == declare\ -a* ]]; then
			isDebug && printDebug "${FUNCNAME[0]} $1 return 0"
			return 0
		else
			isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
			return 1
		fi
	else
		isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
		return 1
	fi
}
readonly -f isArray

TTRO_help_isAssociativeArray='
# Function isAssociativeArray
#	checks whether an variable exists and is an associative array
# Parameters:
#	$1 - var name to be checked
# Returns
#	success(0) - if the variable exists and is an indexed array
#	error(1)   - otherwise
# Exits:
#	if called without argument'
function isAssociativeArray {
	local v
	if v=$(declare -p "${1}" 2> /dev/null); then
		if [[ $v == declare\ -A* ]]; then
			isDebug && printDebug "${FUNCNAME[0]} $1 return 0"
			return 0
		else
			isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
			return 1
		fi
	else
		isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
		return 1
	fi
}
readonly -f isAssociativeArray

TTRO_help_isFunction='
# Function isFunction
#	checks whether an given name is defined as function
# Parameters:
#	$1 - name to be checked
# Returns:
#	success(0)  - if the function exists
#	error(1)    - otherwise
# Exits:
#	if called without argument'
function isFunction {
	if declare -F "$1" &> /dev/null; then
		isDebug && printDebug "${FUNCNAME[0]} $1 return 0"
		return 0
	else
		isDebug && printDebug "${FUNCNAME[0]} $1 return 1"
		return 1
	fi
}
readonly -f isFunction

TTRO_help_arrayHasKey='
# Function arrayHasKey
#	check is an array has key
# Parameters:
#	$1 the array name
#	$2 the key value to search must not contain spaces
# Returns:
#	success(0) - if key exists in array
#	error(1)   -   otherwise
# Exits:
#	exits if called with wrong number of arguments'
function arrayHasKey {
	if [[ $# -ne 2 ]]; then printErrorAndExit "${FUNCNAME[0]} must have 2 aruments" "${errRt}"; fi
	isDebug && printDebug "${FUNCNAME[0]} $1 $2"
	if ! isArray "$1" && ! isAssociativeArray "$1"; then
		printErrorAndExit "variable $1 is not an array"
	fi
	eval "keys=\"\${!$1[@]}\"" #indirect array access with eval
	local in=1
	local key
	for key in $keys; do
		if [[ $key == $2 ]]; then
			in=0
			break
		fi
	done
	isDebug && printDebug "${FUNCNAME[0]} $1 return $in"
	return $in
}
readonly -f arrayHasKey

TTRO_help_copyAndTransform='
# Function copyAndTransform
#	Copy and change all files from input directory into workdir
#	Filenames that match one of the transformation pattern are transformed. All other files are copied.
#	In case of transformation the pattern //_<varid>_ is removed if varid equals $3
#	In case of transformation the pattern //!<varid>_ is removed if varid is different than $3
#	If the variant identifier is empty, the pattern list sould be also empty and the function is a pure copy function
#	If $3 is empty and $4 .. do not exist, this function is a pure copy
#	$1 - input dir
#	$2 - output dir
#	$3 - the variant identifier
#	$4 ... pattern for file names to be transformed
#	returns
#		success(0)
#	exits  if called with wrong arguments'
function copyAndTransform {
	printWarning "${FUNCNAME[0]} is deprecated use function 'copyAndMorph'"
	if [[ $# -lt 3 ]]; then printErrorAndExit "${FUNCNAME[0]} missing params. Number of Params is $#" "${errRt}"; fi
	isDebug && printDebug "${FUNCNAME[0]} $*"
	if [[ -z $3 && ( $# -gt 3 ) ]]; then
		printWarning "${FUNCNAME[0]}: Empty variant identifier but there are pattern for file transformation"
	fi
	local -a transformPattern=()
	local -i max=$(($#+1))
	local -i j=0
	local -i i
	for ((i=4; i<max; i++)); do
		transformPattern[j]="${!i}"
		j=$((j+1))
	done
	if isDebug; then
		local display; display=$(declare -p transformPattern);
		printDebug "$display"
	fi
	local dest=""
	for x in "$1"/**; do #first create dir structure
		isDebug && printDebug "${FUNCNAME[0]} item to process step1: $x"
		if [[ -d $x ]]; then
			dest="${x#$1}"
			dest="$2/$dest"
			echo "$dest"
			if isVerbose; then
				mkdir -pv "$dest"
			else
				mkdir -p "$dest"
			fi
		fi
	done
	local match=0
	local x
	for x in "$1"/**; do
		if [[ ! -d $x ]]; then
			isDebug && printDebug "${FUNCNAME[0]} item to process step2: $x"
			for ((i=0; i<${#transformPattern[@]}; i++)); do
				isDebug && printDebug "${FUNCNAME[0]}: check transformPattern[$i]=${transformPattern[$i]}"
				match=0
				if [[ $x == ${transformPattern[$i]} ]]; then
					isDebug && printDebug "${FUNCNAME[0]}: check transformPattern[$i]=${transformPattern[$i]} Match found"
					match=1
				fi
			done
			dest="${x#$1}"
			dest="$2/$dest"
			if [[ match -eq 1 ]]; then
				isVerbose && printVerbose "transform $x to $dest"
				#if ! sed -e "s/\/\/*_${3}//g" "$x" > "$dest"; then
				#	printErrorAndExit "${FUNCNAME[0]} Can not transform input=$x dest=$dest variant=$4" "${errRt}"
				#fi
				{
					local readResult=0
					local outline part1 part2 partx
					while [[ $readResult -eq 0 ]]; do
						if ! read -r; then readResult=1; fi
						part1="${REPLY%%//_$3_*}"
						if [[ $part1 != $REPLY ]]; then
							#isDebug && printDebug "${FUNCNAME[0]}: match line='$REPLY'"
							part2="${REPLY#*//_$3_}"
							#isDebug && printDebug "${FUNCNAME[0]}: part2='$part2'"
							outline="${part1}${part2}"
						else
							part1="${REPLY%%//\!*_*}"
							if [[ $part1 != $REPLY ]]; then
								#isDebug && printDebug "${FUNCNAME[0]}: 2nd match line='$REPLY'"
								partx="${REPLY%%//\!$3_*}"
								if [[ $partx != $REPLY ]]; then
									#isDebug && printDebug "${FUNCNAME[0]}: negative match line='$REPLY' '$partx'"
									outline="$REPLY"
								else
									part2="${REPLY#*//\!*_}"
									#isDebug && printDebug "${FUNCNAME[0]}: part2='$part2'"
									outline="${part1}${part2}"
								fi
							else
								#isDebug && printDebug "${FUNCNAME[0]}: no match line='$REPLY'"
								outline="$REPLY"
							fi
						fi
						if [[ $readResult -eq 0 ]]; then
							echo "$outline" >> "$dest"
						else
							echo -n "$outline" >> "$dest"
						fi
					done
				} < "$x"
			else
				if isVerbose; then
					cp -pv "$x" "$dest"
				else
					cp -p "$x" "$dest"
				fi
			fi
		fi
	done
	return 0
}
readonly -f copyAndTransform

TTRO_help_copyAndMorph='
# Function copyAndMorph
#	Copy and change all files from input directory into workdir
#	Filenames that match one of the transformation file name pattern are transformed. All other files are copied.
#	The transformation  of the files is done with function "morphFile"
#	If the variant identifier is empty, the pattern list sould be also empty and the function is a pure copy function
#	If $3 is empty and $4 .. do not exist, this function is a pure copy
#	$1 - input dir
#	$2 - output dir
#	$3 - the variant identifier
#	$4 ... pattern for file names to be transformed
#	returns
#		success(0)
#	exits  if called with wrong arguments'
function copyAndMorph {
	if [[ $# -lt 3 ]]; then printErrorAndExit "${FUNCNAME[0]} missing params. Number of Params is $#" "${errRt}"; fi
	isDebug && printDebug "${FUNCNAME[0]} $*"
	if [[ -z $3 && ( $# -gt 3 ) ]]; then
		printWarning "${FUNCNAME[0]}: Empty variant identifier but there are pattern for file transformation"
	fi
	local -a transformPattern=()
	local -i max=$(($#+1))
	local -i j=0
	local -i i
	for ((i=4; i<max; i++)); do
		transformPattern[j]="${!i}"
		j=$((j+1))
	done
	if isDebug; then
		local display; display=$(declare -p transformPattern);
		printDebug "$display"
	fi
	local dest=""
	local x
	for x in "$1"/**; do #first create dir structure
		if [[ -d $x ]]; then
			isDebug && printDebug "${FUNCNAME[0]} item to process step1 create dir structure: $x"
			dest="${x#$1}"
			dest="$2/$dest"
			echo $dest
			if isVerbose; then
				mkdir -pv "$dest"
			else
				mkdir -p "$dest"
			fi
		fi
	done
	local match=""
	for x in "$1"/**; do
		if [[ ! -d $x ]]; then
			isDebug && printDebug "${FUNCNAME[0]} item to process step2 copy/transform: $x"
			match=''
			for ((i=0; i<${#transformPattern[@]}; i++)); do
				isDebug && printDebug "${FUNCNAME[0]}: check transformPattern[$i]=${transformPattern[$i]}"
				if [[ $x == ${transformPattern[$i]} ]]; then
					isDebug && printDebug "${FUNCNAME[0]}: check transformPattern[$i]=${transformPattern[$i]} Match found"
					match='true'
					break;
				fi
			done
			dest="${x#$1}"
			dest="$2/$dest"
			if [[ -n $match ]]; then
				isVerbose && printVerbose "transform $x to $dest"
				morphFile "$x" "$dest" "$3"
			else
				if isVerbose; then
					cp -pv "$x" "$dest"
				else
					cp -p "$x" "$dest"
				fi
			fi
		fi
	done
	return 0
}
readonly -f copyAndMorph

TTRO_help_morphFile='
# morphes a file
#	Lines like:
#	^[[:space:]]*//<varid1 varid2..> are effective if the argument $3 equal one of the varid1, or varid2..
#	^[[:space:]]*//<!varid1 varid2..> are not effective if the argument $3 equal one of the varid1, or varid2..
#	and patterns like <#$varname#> are replaced with the expansion of $varname
#	Effective means that the pattern //<varid1 varid2..> or //<!varid1 varid2..> is removed
#	$1 - input file
#	$2 - output file
#	$3 - the variant identifier
#	returns
#		success(0)
#	exits  if called with wrong arguments'
function morphFile {
	if [[ $# -ne 3 ]]; then printErrorAndExit "${FUNCNAME[0]} missing params. Number of Params is $#" "${errRt}"; fi
	if [[ -z $3 ]]; then printErrorAndExit "${FUNCNAME[0]} wrong params. Empty variant identifier" "${errRt}"; fi
	isDebug && printDebug "${FUNCNAME[0]} $*"
	rm -f "$2"
	{
		local readResult=0
		local negate=''
		local -i linenumber=0
		local templine writeLine ident varidlist code
		local trans varname outline2
		while [[ $readResult -eq 0 ]]; do
			linenumber=$((linenumber+1))
			templine=''; writeLine=''; negate=''
			if ! read -r; then readResult=1; fi
			if [[ $REPLY =~ ^([[:space:]]*)//\<([^\>]+)\>(.*) ]]; then
				ident="${BASH_REMATCH[1]}"
				varidlist="${BASH_REMATCH[2]}"
				code="${BASH_REMATCH[3]}"
				if [[ ( -n $varidlist ) && ( ${varidlist:0:1} == '!' ) ]]; then
					varidlist="${varidlist:1}"
					negate='true'
				fi
				if isInPatternList "$3" "$varidlist"; then
					if [[ -z $negate ]]; then
						templine="${ident}${code}"
						writeLine='true'
					fi
				else
					if [[ -n $negate ]]; then
						templine="${ident}${code}"
						writeLine='true'
					fi
				fi
			else
				templine="$REPLY"
				writeLine='true'
			fi
			if [[ -n $writeLine ]]; then
				outline2=''
				while [[ $templine =~ \<\#\$([^#\>]+)\#\>(.*) ]]; do
					local match="${BASH_REMATCH[0]}"
					local lmatch=${#match}
					local ltempline=${#templine}
					local splitat=$((ltempline-lmatch))
					local part1="${templine:0:$splitat}"
					local part2="${templine:$splitat}"
					outline2="${outline2}${part1}"
					varname="${BASH_REMATCH[1]}"
					templine="${BASH_REMATCH[2]}"
					if [[ $varname =~ [[:space:]] ]]; then
						printErrorAndExit "Invalid variable name: $varname in file: $1 linenumber: $linenumber line: $REPLY" "${errRt}"
					else
						if trans=$(eval echo -n "\"\$$varname\""); then
							outline2="${outline2}${trans}"
						else
							printErrorAndExit "Invalid assignemtnet: \"\$$varname\" in file: $1 linenumber: $linenumber line: $REPLY" "${errRt}"
						fi
					fi
				done
				outline2="${outline2}${templine}"
				#write output
				if [[ $readResult -eq 0 ]]; then
					echo "$outline2" >> "$2"
				else
					echo -n "$outline2" >> "$2"
				fi
			fi
		done
	} < "$1"
	return 0
}
readonly -f morphFile

TTRO_help_copyOnly='
# Function copyOnly
#	Copy all files from input directory to workdir'
function copyOnly {
	copyAndMorph "$TTRO_inputDirCase" "$TTRO_workDirCase" "$TTRO_variantCase"
}
readonly -f copyOnly

TTRO_help_linewisePatternMatch='
# Function linewisePatternMatch
#	Line pattern validator
#	$1 - the input file
#	$2 - if set to "true" all pattern must generate a match
#	$3 .. - the pattern to match
#	returns
#		success(0)   if file exist and one patten matches (if $2 is false)
#		             if file exist and all patten matche  (if $2 is true)
#	return false if no complete pattern match was found or the file not exists'
declare -a TTTT_patternList=()
function linewisePatternMatch {
	if [[ $# -lt 3 ]]; then printErrorAndExit "${FUNCNAME[0]} missing params. Number of Params is $#" "${errRt}"; fi
	isDebug && printDebug "${FUNCNAME[0]} $*"
	local -i max=$#
	local -i i
	local -i noPattern=0
	TTTT_patternList=()
	for ((i=3; i<=max; i++)); do
		TTTT_patternList[noPattern]="${!i}"
		noPattern=$((noPattern+1))
	done
	if linewisePatternMatchArray "$1" "$2"; then
		return 0
	else
		return $?
	fi
}
readonly -f linewisePatternMatch

TTRO_help_linewisePatternMatchAndIntercept='
# Function linewisePatternMatchAndIntercept
#	Execute the function linewisePatternMatch guarded and return the result code in TTTT_result
#	Line pattern validator
#	$1 - the input file
#	$2 - if set to "true" all pattern must generate a match
#	$3 .. - the pattern to match
#	returns succes
#	and the result code from linewisePatternMatch in TTTT_result'
function linewisePatternMatchAndIntercept {
	if linewisePatternMatch "$@" 2>&1; then
		TTTT_result=0
	else
		TTTT_result=$?
	fi
	return 0
}
readonly -f linewisePatternMatchAndIntercept

TTRO_help_linewisePatternMatchInterceptAndSuccess='
# Function linewisePatternMatchInterceptAndSuccess
#	Execute the function linewisePatternMatch guarded and return the result code in TTTT_result
#	Expect success (match found), set failure otherwise
#	Line pattern validator
#	$1 - the input file
#	$2 - if set to "true" all pattern must generate a match
#	$3 .. - the pattern to match
#	returns
#	and the result code from linewisePatternMatch in TTTT_result'
function linewisePatternMatchInterceptAndSuccess {
	if linewisePatternMatch "$@"; then
		TTTT_result=0
	else
		TTTT_result=$?
		setFailure "Not enough matches: '${FUNCNAME[0]} $1 $2 ...'"
	fi
	return 0
}
readonly -f linewisePatternMatchInterceptAndSuccess

TTRO_help_linewisePatternMatchInterceptAndError='
# Function linewisePatternMatchInterceptAndError
#	Execute the function linewisePatternMatch guarded and return the result code in TTTT_result
#	Expect failure (no match found), set failure otherwise
#	Line pattern validator
#	$1 - the input file
#	$2 - if set to "true" all pattern must generate a match
#	$3 .. - the pattern to match
#	returns
#	and the result code from linewisePatternMatch in TTTT_result'
function linewisePatternMatchInterceptAndError {
	if linewisePatternMatch "$@" 3>&1 1>&2 2>&3; then
		TTTT_result=0
		setFailure "Match found: '${FUNCNAME[0]} $1 $2 ...'"
	else
		TTTT_result=$?
	fi
	return 0
}
readonly -f linewisePatternMatchInterceptAndError

TTRO_help_linewisePatternMatchArray='
# Function linewisePatternMatchArray
#	Line pattern validator with array input variable
#	the pattern to match as array 0..n are expected to be in TTTT_patternList array variable
#	$1 - the input file
#	$2 - if set to "true" all pattern must generate a match
#	$TTTT_patternList the indexed array with the pattern to search
#		success(0)   if file exist and one patten matches (if $2 is false)
#		             if file exist and all patten matche  (if $2 is true)
#	return false if no complete pattern match was found or the file not exists
#	exits if TTTT_patternList is empty or not existent'
function linewisePatternMatchArray {
	if [[ $# -ne 2 ]]; then printErrorAndExit "${FUNCNAME[0]} invalid no of params. Number of Params is $#" "${errRt}"; fi
	isDebug && printDebug "${FUNCNAME[0]} $*"
	local -i i
	local -i noPattern=${#TTTT_patternList[@]}
	local -a patternMatched=()
	if [[ $noPattern -eq 0 ]]; then printErrorAndExit "${FUNCNAME[0]} TTTT_patternList must not be empty" "${errRt}"; fi
	for ((i=0; i<noPattern; i++)); do
		patternMatched[i]=''
	done
	if isDebug; then
		local display; display=$(declare -p TTTT_patternList);
		printDebug "$display"
	fi
	if [[ -f $1 ]]; then
		local -i matches=0
		local -i line=0
		{
			local result=0;
			line=0
			while [[ result -eq 0 ]]; do
				if ! read -r; then result=1; fi
				if [[ ( result -eq 0 ) || ( ${#REPLY} -gt 0 ) ]]; then
					line=$((line+1))
					isDebug && printDebug "$REPLY"
					for ((i=0; i<noPattern; i++)); do
						if [[ -z ${patternMatched[$i]} && ( $REPLY == ${TTTT_patternList[$i]} ) ]]; then
							patternMatched[i]='true'
							matches=$((matches+1))
							echo "${FUNCNAME[0]} : Patternmatch: file=$1 line=$line Pattern[$i]='${TTTT_patternList[$i]}'"
							if [[ -z $2 ]]; then
								break 2
							fi
						fi
						if [[ $matches -eq $noPattern ]]; then
							break 2
						fi
					done
				fi
			done
		} < "$1"
		if [[ $2 == 'true' ]]; then
			if [[ $matches -eq $noPattern ]]; then
				echo "${FUNCNAME[0]} : $matches matches found in file=$1"
				return 0
			else
				local noMatchIn=''
				for ((i=0; i<noPattern; i++)); do
					if [[ -z ${patternMatched[$i]} ]]; then
						noMatchIn="$noMatchIn $i"
					fi
				done
				echo "${FUNCNAME[0]} : Only $matches of $noPattern pattern matches found in file=$1" >&2
				echo "${FUNCNAME[0]} no matches for pattern $noMatchIn" >&2
				local x
				for i in ${noMatchIn}; do
					echo "${FUNCNAME[0]} FAILURE: no match for pattern ${TTTT_patternList[$i]}" >&2
				done
				return "$errTestFail"
			fi
		else
			if [[ $matches -gt 0 ]]; then
				echo "${FUNCNAME[0]} : $matches matches found in file=$1"
				return 0
			else
				echo "${FUNCNAME[0]} : No match found in file=$1"
				for ((i=0; i<noPattern; i++)); do
					echo "${FUNCNAME[0]} FAILURE: no match for pattern ${TTTT_patternList[$i]}" >&2
				done
				return $errTestFail
			fi
		fi
	else
		echo "${FUNCNAME[0]}: can not open file $1" >&2
		return "$errTestFail"
	fi
}
readonly -f linewisePatternMatchArray

TTRO_help_echoAndExecute='
# Function echoAndExecute
#	echo and execute a command with variable arguments
#	success is expected and no further evaluation of the output is required
# Parameters:
#	$1    - the command string
#	$2 .. - optional the parameters of the command
# Returns:
#	the result code of the executed command
# Exits:
#	if no command string is given or the command is empty
#	if the function is not guarded with conditional statement and the executed command returns an error code'
function echoAndExecute {
	if [[ $# -lt 1 || -z $1 ]]; then
		printErrorAndExit "${FUNCNAME[0]} called with no or empty command" "${errRt}"
	fi
	local cmd="$1"
	shift
	local disp0="${FUNCNAME[1]} -> ${FUNCNAME[0]}: "
	printInfo "$disp0 $cmd $*"
	"$cmd" "$@"
}
readonly -f echoAndExecute

TTRO_help_echoExecuteAndIntercept='
# Function echoExecuteAndIntercept
#	echo and execute the command line
#	the command execution is guarded and the result code is stored
# Parameters:
#	$1    - the command string
#	$2 .. - optional the parameters of the command
# Returns:
#	success
# Exits:
#	if no command string is given or the command is empty
# Side Effects:
#	TTTT_result - the result code of the executed command'
function echoExecuteAndIntercept {
	if [[ $# -lt 1 || -z $1 ]]; then
		printErrorAndExit "${FUNCNAME[0]} called with no or empty command" "${errRt}"
	fi
	local cmd="$1"
	shift
	local disp0="${FUNCNAME[1]} -> ${FUNCNAME[0]}: "
	printInfo "$disp0 $cmd $*"
	if "$cmd" "$@"; then
		TTTT_result=0
	else
		TTTT_result=$?
	fi
	printInfo "$cmd returns $TTTT_result"
	return 0
}
readonly -f echoExecuteAndIntercept

TTRO_help_echoExecuteInterceptAndSuccess='
# Function echoExecuteInterceptAndSuccess
#	echo and execute the command line
#	a successfull command execution is expected
#	the failure condition is set in case of failure
# Parameters:
#	$1    - the command string
#	$2 .. - optional the parameters of the command
# Returns
#	success
# Exits:
#	if no command string is given or the command is empty
# Side Effects:
#	TTTT_result - the result code of the executed command
#	The failure condition is set if the command returns failure'
function echoExecuteInterceptAndSuccess {
	if [[ $# -lt 1 || -z $1 ]]; then
		printErrorAndExit "${FUNCNAME[0]} called with no or empty command" "${errRt}"
	fi
	local cmd="$1"
	shift
	local disp0="${FUNCNAME[1]} -> ${FUNCNAME[0]}: "
	printInfo "$disp0 $cmd $*"
	if "$cmd" "$@"; then
		TTTT_result=0
	else
		TTTT_result=$?
		setFailure "$TTTT_result : returned from $cmd"
	fi
	printInfo "$TTTT_result : returned from $cmd"
	return 0
}
readonly -f echoExecuteInterceptAndSuccess

TTRO_help_echoExecuteInterceptAndError='
# Function echoExecuteInterceptAndError
#	echo and execute the command line
#	a failure code is expected in the command return
#	the failure condition is set in case of cmd success
# Parameters:
#	$1    - the command string
#	$2 .. - optionally the parameters of the command
# Returns:
#	success
# Exits:
#	if no command string is given or the command is empty
# Side Effects_
#	TTTT_result - the result code of the executed command
#	The failure condition is set if the command returns success'
function echoExecuteInterceptAndError {
	if [[ $# -lt 1 || -z $1 ]]; then
		printErrorAndExit "${FUNCNAME[0]} called with no or empty command" "${errRt}"
	fi
	local cmd="$1"
	shift
	local disp0="${FUNCNAME[1]} -> ${FUNCNAME[0]}: "
	printInfo "$disp0 $cmd $*"
	if "$cmd" "$@"; then
		TTTT_result=0
		setFailure "$TTTT_result : returned from $cmd"
	else
		TTTT_result=$?
	fi
	printInfo "$TTTT_result : returned from $cmd"
	return 0
}
readonly -f echoExecuteInterceptAndError

TTRO_help_echoExecuteAndIntercept2='
# Function echoExecuteAndIntercept2
#	echo and execute the command line
#	additionally the expected returncode is checked
#	if the expected result is not received the failure condition is set
#	the function returns success(0)
#	the function exits if an input parameter is wrong
# Parameters:
#	$1 success - returncode 0 expected
#	   error   - returncode ne 0 expected
#	   X       - any return value is accepted
#	   number  - the numeric return code is expected
#	$2 - the command string
#	$3 .. - optional the parameters for the command
# Returns:
#	success
# Exits:
#	If the number of parameters is -lt 2 ot the command is empty
# Side Effects:
#'
function echoExecuteAndIntercept2 {
	if [[ $# -lt 2 || -z $2 ]]; then
		printErrorAndExit "${FUNCNAME[0]} called with no or empty command" "${errRt}"
	fi
	if [[ $1 != success && $1 != error && $1 != X ]]; then
		if ! isNumber "$1"; then
			printErrorAndExit "${FUNCNAME[0]} called with wrong parameters: $*" "${errRt}"
		fi
	fi
	local code="$1"
	shift
	local cmd="$1"
	shift
	local myresult=''
	local disp0="${FUNCNAME[1]} -> ${FUNCNAME[0]}: "
	printInfo "$disp0 $cmd $*"
	if "$cmd" "$@"; then
		myresult=0
	else
		myresult=$?
	fi
	case "$code" in
		success)
			if [[ $myresult -eq 0 ]]; then
				isDebug && printDebug "${FUNCNAME[0]} success"
			else
				setFailure "${FUNCNAME[0]} Unexpected failure $myresult in cmd $*"
			fi;;
		error)
			if [[ $myresult -eq 0 ]]; then
				setFailure "${FUNCNAME[0]} Unexpected success in cmd $*"
			else
				isDebug && printDebug "${FUNCNAME[0]} success"
			fi;;
		X)
			isDebug && printDebug "${FUNCNAME[0]} success";;
		*)
			if [[ $myresult -eq $code ]]; then
				isDebug && printDebug "${FUNCNAME[0]} success"
			else
				setFailure "${FUNCNAME[0]} wrong failure code $myresult in cmd $*"
			fi;;
	esac
	return 0
}
readonly -f echoExecuteAndIntercept2

TTRO_help_executeAndLog='
# Function executeAndLog
#	echo and execute a command
#	the command execution is guarded and the result code is stored
#	the std- and error-out is logged into a file for further evaluation
# Parameters:
#	$1    - the command string
#	$2 .. - optional the parameters of the command
#	$TT_evaluationFile - the file name of the log file default is ./EVALUATION.log
# Returns:
#	success
# Exits:
#	if no command string is given or the command is empty
# Side Effects:
#	TTTT_result - the result code of the executed command'
function executeAndLog {
	if [[ $# -lt 1 || -z $1 ]]; then
		printErrorAndExit "${FUNCNAME[0]} called with no or empty command" "${errRt}"
	fi
	local cmd="$1"
	shift
	local disp0="${FUNCNAME[1]} -> ${FUNCNAME[0]}: "
	printInfo "$disp0 $cmd $*"
	if "$cmd" "$@" 2>&1 | tee "$TT_evaluationFile"; then
		TTTT_result=0
	else
		TTTT_result=$?
	fi
	printInfo "$TTTT_result : returned from $cmd"
	return 0
}
readonly -f executeAndLog

TTRO_help_executeLogAndSuccess='
# Function executeLogAndSuccess
#	echo and execute a command
#	the command execution is guarded and the result code is stored
#	the std- and error-out is logged into a file for further evaluation
#	a successfull command execution is expected, otherwise the failure condition is set
# Parameters:
#	$1    - the command string
#	$2 .. - optional the parameters of the command
#	$TT_evaluationFile - the file name of the log file default is ./EVALUATION.log
# Returns:
#	success
# Exits:
#	if no command string is given or the command is empty
# Side Effects:
#	TTTT_result - the result code of the executed command
#	The failure condition is set if the command returns failure'
function executeLogAndSuccess {
	if [[ $# -lt 1 || -z $1 ]]; then
		printErrorAndExit "${FUNCNAME[0]} called with no or empty command" "${errRt}"
	fi
	local cmd="$1"
	shift
	local disp0="${FUNCNAME[1]} -> ${FUNCNAME[0]}: "
	printInfo "$disp0 $cmd $*"
	if "$cmd" "$@" 2>&1 | tee "$TT_evaluationFile"; then
		TTTT_result=0
	else
		TTTT_result=$?
		setFailure "$TTTT_result : returned from $cmd"
	fi
	printInfo "$TTTT_result : returned from $cmd"
	return 0
}
readonly -f executeLogAndSuccess

TTRO_help_executeLogAndError='
# Function executeLogAndError
#	echo and execute a command
#	the command execution is guarded and the result code is stored
#	the std- and error-out is logged into a file for further evaluation
#	an error command execution is expected, otherwise the failure condition is set
# Parameters:
#	$1    - the command string
#	$2 .. - optional the parameters of the command
#	$TT_evaluationFile - the file name of the log file default is ./EVALUATION.log
# Returns:
#	success
# Exits:
#	if no command string is given or the command is empty
# Side Effects:
#	TTTT_result - the result code of the executed command
#	The failure condition is set if the command returns success'
function executeLogAndError {
	if [[ $# -lt 1 || -z $1 ]]; then
		printErrorAndExit "${FUNCNAME[0]} called with no or empty command" "${errRt}"
	fi
	local cmd="$1"
	shift
	local disp0="${FUNCNAME[1]} -> ${FUNCNAME[0]}: "
	printInfo "$disp0 $cmd $*"
	if "$cmd" "$@" 2>&1 | tee "$TT_evaluationFile"; then
		TTTT_result=0
		setFailure "$TTTT_result : returned from $cmd"
	else
		TTTT_result=$?
	fi
	printInfo "$TTTT_result : returned from $cmd"
	return 0
}
readonly -f executeLogAndError

TTRO_help_renameInSubdirs='
# Function renameInSubdirs
#	Renames a special file name in all base directory and in all sub directories
#	$1 the base directory
#	$2 the source filename
#	$3 the destination filename'
function renameInSubdirs {
	if [[ $# -ne 3 ]]; then printErrorAndExit "${FUNCNAME[0]} invalid no of params. Number of Params is $#" "${errRt}"; fi
	isDebug && printDebug "${FUNCNAME[0]} $*"
	local x mdir destf
	for x in $1/**/$2; do
		mdir="${x%/*}"
		destf="${mdir}/$3"
		mv -v "$x" "$destf"
	done
	return 0
}
readonly -f renameInSubdirs

TTRO_help_isInList='
# check whether the pattern $1 matches one of the tokens in a space separated list of tokens
#	$1 the pattern to search. It must not contain whitespaces
#	$2 the space separated list of tokens
#	returns true if the token was in the list; false otherwise
#	exits if called with wrong parameters'
function isInList {
	if [[ $# -ne 2 ]]; then printErrorAndExit "${FUNCNAME[0]} invalid no of params. Number of Params is $#" "${errRt}"; fi
	isDebug && printDebug "${FUNCNAME[0]} $*"
	if [[ $1 == *[[:space:]]* ]]; then
		printErrorAndExit "The token \$1 must not be empty and must not have spaces \$1='$1'" "${errRt}"
	else
		local x
		local isFound=''
		for x in $2; do
			if [[ $x == $1 ]]; then
				isFound="true"
				break
			fi
		done
		if [[ -n $isFound ]]; then
			isDebug && printDebug "${FUNCNAME[0]} return 0"
			return 0
		else
			isDebug && printDebug "${FUNCNAME[0]} return 1"
			return 1
		fi
	fi
}
readonly -f isInList

TTRO_help_isInPatternList='
# check whether the token $1 matches one of the pattern in a space separated list of patterns
#	$1 the token to search. It must not contain whitespaces
#	$2 the space separated list of patterns
#	returns true if the token was in the list; false otherwise
#	exits if called with wrong parameters'
function isInPatternList {
	if [[ $# -ne 2 ]]; then printErrorAndExit "${FUNCNAME[0]} invalid no of params. Number of Params is $#" "${errRt}"; fi
	isDebug && printDebug "${FUNCNAME[0]} $*"
	if [[ $1 == *[[:space:]]* ]]; then
		printErrorAndExit "The token \$1 must not be empty and must not have spaces \$1='$1'" "${errRt}"
	else
		local x
		local isFound=''
		set -f
		for x in $2; do
			if [[ $1 == $x ]]; then
				isFound="true"
				break
			fi
		done
		set +f
		if [[ -n $isFound ]]; then
			isDebug && printDebug "${FUNCNAME[0]} return 0"
			return 0
		else
			isDebug && printDebug "${FUNCNAME[0]} return 1"
			return 1
		fi
	fi
}
readonly -f isInPatternList

TTRO_help_isInListSeparator='
# check whether a token is in a list of tokens with a special separator
#	$1 the token to search. It must not contain any of the separator tokens
#	$2 the list
#	$3 the separators
#	returns true if the token was in the list; false otherwise
#	exits if called with wrong parameters'
function isInListSeparator {
	if [[ $# -ne 3 ]]; then printErrorAndExit "${FUNCNAME[0]} invalid no of params. Number of Params is $#" "${errRt}"; fi
	isDebug && printDebug "${FUNCNAME[0]} $*"
	if [[ $1 == *[$3]* ]]; then
		printErrorAndExit "The token \$1 must not be empty and must not have separator characters \$1='$1'" "${errRt}"
	else
		local x
		local isFound=''
		local IFS="$3"
		for x in $2; do
			if [[ $x == $1 ]]; then
				isFound="true"
				break
			fi
		done
		if [[ -n $isFound ]]; then
			isDebug && printDebug "${FUNCNAME[0]} return 0"
			return 0
		else
			isDebug && printDebug "${FUNCNAME[0]} return 1"
			return 1
		fi
	fi
}
readonly -f isInListSeparator

TTRO_help_import='
# Function import
#	Treats the input as filename and adds it to TT_tools if not already there
#	sources the file if it was not in TT_tools
#	return the result code of the source command'
function import {
	isDebug && printDebug "${FUNCNAME[0]} $*"
	[[ $# -ne 1 ]] && printErrorAndExit "${FUNCNAME[0]} invalid no of params. Number of Params is $#" "${errRt}"
	local TTTT_trim
	trim "$1"
	local componentName="${TTTT_trim##*/}"
	if isInList "$componentName" "$TTXX_modulesImported"; then
		printWarning "file $componentName is already registerd in TTXX_modulesImported=$TTXX_modulesImported"
		return 0
	fi
	local filename=''
	if [[ ${TTTT_trim:0:1} == '/' ]]; then
		if [[ -r $TTTT_trim ]]; then
			filename="$TTTT_trim"
		fi
	else
		isDebug && printDebug "\$TTXX_searchPath=$TTXX_searchPath"
		local x
		for x in $TTXX_searchPath; do
			local composite="$x/$TTTT_trim"
			if [[ -r $composite ]]; then
				filename="$composite"
				break
			fi
		done
	fi
	if [[ -z $filename ]]; then
		printErrorAndExit "${FUNCNAME[0]}: no readable file found for module '$TTTT_trim' in search path '$TTXX_searchPath'" "${errRt}"
	else
		printInfo "Module $componentName import found here: $filename"
		TTXX_modulesImported="$TTXX_modulesImported $componentName"
		export TTXX_modulesImported
		source "$filename"
		TTTF_fixPropsVars
		TTTF_writeProtectExportedFunctions
	fi
}
readonly -f import

TTRO_help_waitForFileToAppear='
# Function waitForFileToAppear
#	Wait until a file appears
# Parameters:
#	$1 - the file name to check
#	$2 - optional the check interval default is 3 sec.
# Returns:
#	success if the file was found
# Exits:
# if the function was called with invalid parameters'
function waitForFileToAppear {
	if [[ ( $# -lt 1 ) || ( $# -gt 2 ) ]]; then printErrorAndExit "${FUNCNAME[0]} invalid no of params. Number of Params is $#" "${errRt}"; fi
	local timeoutValue=3
	if [[ $# -eq 2 ]]; then
		timeoutValue="$2"
	fi
	while ! [[ -e $1 ]]; do
		printInfo "Wait for file to appear $1"
		sleep "$timeoutValue"
	done
	printInfo "File to appear $1 exists"
	return 0
}
readonly -f waitForFileToAppear

TTRO_help_getLineCount='
# Function getLineCount
#	Get the number of lines in a file
# Parameters:
#	$1 the file name
# Returns:
#	the status of the ececuted commands
# Exits:
# if the function was called with invalid parameters
# Side Effects:
#	TTTT_lineCount - the number of lines in the file'
function getLineCount {
	if [[ $# -ne 1 ]]; then printErrorAndExit "${FUNCNAME[0]} invalid no of params. Number of Params is $#" "${errRt}"; fi
	TTTT_lineCount=$(wc -l "$1" | cut -f 1 -d ' ')
}
readonly -f getLineCount

TTRO_help_promptYesNo='
# Function promptYesNo
#	Write prompt and wait for user input y/n
#	optional $1 the text for the prompt
#	honors TTRO_noPrompt
#	returns
#		success(0) if y/Y was enterd
#		error(1) if n/N was entered
#	exits id ^C was pressed'
function promptYesNo {
	if [[ -n $TTRO_noPrompt ]]; then return 0; fi
	local pr="Continue or not? y/n "
	if [[ $# -gt 0 ]]; then
		pr="$1"
	fi
	local inputWasY=''
	while read -r -p "$pr"; do
		if [[ $REPLY == y* || $REPLY == Y* || $REPLY == c* || $REPLY == C* ]]; then
			inputWasY='true'
			break
		elif [[ $REPLY == e* || $REPLY == E* || $REPLY == n* || $REPLY == N* ]]; then
			inputWasY=''
			break
		fi
	done
	if [[ -n $inputWasY ]]; then
		return 0
	else
		return 1
	fi
}
readonly -f promptYesNo

TTRO_help_getSystemLoad='
# Function get the current system load
#	returns the load value in TTTT_systemLoad'
function getSystemLoad {
	local v1=$(</proc/loadavg)
	TTTT_systemLoad="${v1%% *}"
}
readonly -f getSystemLoad

TTRO_help_getSystemLoad100='
# Function get the current system load as integer
#	system load x 100
#	returns the load value in TTTT_systemLoad100'
function getSystemLoad100 {
	getSystemLoad
	local integer=${TTTT_systemLoad%%.*}
	[[ -z $integer ]] && printErrorAndExit "No valid TTTT_systemLoad : $TTTT_systemLoad" "${errRt}"
	local fraction=0
	if [[ $TTTT_systemLoad != $integer ]]; then
		fraction=${TTTT_systemLoad#*.}
		if [[ -z $fraction ]]; then
			fraction=0
		elif [[ ${#fraction} -eq 1 ]]; then
			fraction="${fraction}0"
		elif [[ ${#fraction} -gt 2 ]]; then
			fraction="${fraction:0:2}"
		fi
		fraction=$((10#$fraction))
	fi
	integer=$((integer*100))
	TTTT_systemLoad100=$((integer+fraction))
}
readonly -f getSystemLoad100

TTRO_help_timeFromSeconds='
# Function timeFromSeconds
#	returns a formated string hh:mm:ss from seconds
#	parameters
#		$1   input in seconds
#	return
#		TTTT_timeFromSeconds the formated string
#		success'
function timeFromSeconds {
	if [[ $# -ne 1 ]]; then printErrorAndExit "${FUNCNAME[0]} invalid no of params. Number of Params is $#" "${errRt}"; fi
	local seconds="$1"
	local sec=$((seconds%60))
	if [[ ${#sec} -eq 1 ]]; then sec="0$sec"; fi
	local hour=$((seconds/60))
	local minutes=$((hour%60))
	if [[ ${#minutes} -eq 1 ]]; then minutes="0$minutes"; fi
	hour=$((hour/60))
	if [[ ${#hour} -eq 1 ]]; then hour="0$hour"; fi
	TTTT_timeFromSeconds="${hour}:${minutes}:${sec}"
	return 0
}
readonly -f timeFromSeconds

TTRO_help_getElapsedTime='
# Function get the elapsed time string in TTTT_elapsedTime
#	parameters
#		$1 the start time in seconds
#	return
#		TTTT_elapsedTime'
function getElapsedTime {
	if [[ $# -ne 1 ]]; then printErrorAndExit "${FUNCNAME[0]} : wrong no of arguments $#" "${errRt}"; fi
	local psres; psres="$errSigint"
	local now=''
	while [[ $psres -eq $errSigint ]]; do
		psres=0
		now=$(date -u +%s) || psres="$?"
	done
	local diff=$((now-$1))
	timeFromSeconds "$diff"
	TTTT_elapsedTime="$TTTT_timeFromSeconds"
	return 0
}
readonly -f getElapsedTime


TTRO_help_checkAllFilesExist='
# Function checks whether all files exists
#	and sets the failure condition if one file is missing
#	parameters
#		$1 the prefix for all files
#		$2 the space separated list of files to check
# Exits:
#	if no called with wrong number of arguments
# Side Effects_
#	The failure condition is set one file is missing'
checkAllFilesExist() {
	if [[ $# -ne 2 ]]; then printErrorAndExit "${FUNCNAME[0]} : wrong number of params $#" "${errRt}"; fi
	local x
	for x in $2; do
		if [[ -e "$1/$x" ]]; then
			printInfo "${FUNCNAME[0]} : Found file $1/$x"
		else
			setFailure "${FUNCNAME[0]} : File not found $1/$x"
			break
		fi
	done
	return 0
}
readonly -f checkAllFilesExist

TTRO_help_checkAllFilesEqual='
# Function checks whether all files are equal
#	and sets the failure condition if one file is missing or differs
#	parameters
#		$1 the prefix #1 (directory) for all files
#		$2 the prefix #2 (directory) for all files
#		$3 the space separated list of files to check
# Exits:
#	if no called with wrong number of arguments
# Side Effects_
#	The failure condition is set one file is missing or differs'
checkAllFilesEqual() {
	if [[ $# -ne 3 ]]; then printErrorAndExit "${FUNCNAME[0]} : wrong number of params $#" "${errRt}"; fi
	local x f1 f2
	for x in $3; do
		f1="$1/$x"
		f2="$2/$x"
		if diff "$f1" "$f2"; then
			printInfo "${FUNCNAME[0]} : Files equal $f1 $f2"
		else
			setFailure "${FUNCNAME[0]} : Files not equal $f1 $f2"
			break
		fi
	done
	return 0
}
readonly -f checkAllFilesEqual

TTRO_help_checkLineCount='
# Function checks whether the line count in a file equals a specific number
#	and sets the failure condition if the count differs
#	parameters
#		$1 the file name
#		$2 the expected line count
# Exits:
#	if no called with wrong number of arguments
# Side Effects_
#	The failure condition is set if the line count is not the expected or the file does not exists'
checkLineCount() {
	if [[ $# -ne 2 ]]; then printErrorAndExit "${FUNCNAME[0]} : wrong number of params $#" "${errRt}"; fi
	if [[ -f $1 ]]; then
		local x; x=$(wc -l "$1" | cut -f 1 -d ' ')
		if [[ $x -eq $2 ]]; then
			printInfo "${FUNCNAME[0]} : Expected line count in file $1 is correct $2"
		else
			setFailure "${FUNCNAME[0]} : Expected line count in file $1 is $2 ; but line count is $x"
		fi
	else
		setFailure "${FUNCNAME[0]} : File not found $1 or is no regular file"
	fi
	return 0
}
readonly -f checkLineCount

TTRO_help_findTokenInFiles='
# Function findTokenInFiles
#	Find a token in files
# Parameters:
#	$1 - if true, the function exits if no files are scanned
#	$2 - the token to find
#	$3... the list of files to check
# Returns:
#	true - if token found
#	false - otherwise
# Exits:
#	if called with wrong params
#	a file is not readable
#	if no files are scanned and $2 was true'
findTokenInFiles() {
	if [[ $# -lt 2 ]]; then printErrorAndExit "${FUNCNAME[0]} : wrong number of params $#" "${errRt}"; fi
	if [[ -z $2 ]]; then printErrorAndExit "${FUNCNAME[0]} : the token \$2 must not be empty" "${errRt}"; fi
	local exitOnZeroFiles="$1"; shift
	local token="$1"; shift
	local filesChecked=''
	local myfile
	local fcount=0;
	for myfile in "$@"; do
		if [[ -r $myfile ]]; then
			fcount=$((fcount+1))
			filesChecked="$filesChecked $myfile"
			if grep "$token" "$myfile"; then
				printInfo "Token: '$token' found in file: $myfile"
				return 0
			fi
		else
			printErrorAndExit "${FUNCNAME[0]} : file: '$myfile' does not exist or is not readable"  "${errRt}"
		fi
	done
	if [[ $fcount -eq 0 ]]; then
		if [[ $exitOnZeroFiles ]]; then
			printErrorAndExit "${FUNCNAME[0]} : No files to search" "${errRt}"
		else
			printWarning "Token '$token' not found in $fcount files. Checked files: $filesChecked"
		fi
	else
		printInfo "Token: '$token' not found in $fcount files. Checked files: $filesChecked"
	fi
	return 1
}
readonly -f findTokenInFiles

TTRO_help_findTokenInDirs='
# Function findTokenInDirs
#	Find a token in files in a number of directories
# Parameters:
#	$1 - if true, the function exits if no files are scanned
#	$2 - the token to find
#	$3 - the file wildcard
#	$4 - the space separated list of directories to check
# Returns:
#	true - if token found
#	false - otherwise
# Exits:
#	if called with wrong params
#	a file is not readable
if no files are scanned and $3 was true'
findTokenInDirs() {
	if [[ $# -lt 3 ]]; then printErrorAndExit "${FUNCNAME[0]} : wrong number of params $#" "${errRt}"; fi
	if [[ -z $2 ]]; then printErrorAndExit "${FUNCNAME[0]} : \$2 must not be empty" "${errRt}"; fi
	if [[ -z $3 ]]; then printErrorAndExit "${FUNCNAME[0]} : \$3 must not be empty" "${errRt}"; fi
	local exitOnZeroFiles="$1";
	local token="$2";
	local wildcard="$3"
	shift 3
	local fileList=''
	local mydir
	local myfile
	for mydir in "$@"; do
		if [[ -d ${mydir} ]]; then
			for myfile in ${mydir}/${wildcard}; do
				fileList="$fileList $myfile"
			done
		else
			printErrorAndExit "Directory '$mydir' does not exists or is not a direcrtory" "${errRt}"
		fi
	done
	if findTokenInFiles "$exitOnZeroFiles" "$token" $fileList; then
		return 0
	else
		return 1
	fi
}
readonly -f findTokenInDirs

TTRO_help_checkTokenIsInFiles='
# Function checkTokenIsInFiles
#	Check if a token is in one of these files
# Parameters:
#	$1 - if true, the function exits if no files are scanned
#	$2 - the token to find
#	$3... the list of files to check
# Returns:
#	true
#	Set failure if token was not found
# Exits:
#	if called with wrong params
#	a file is not readable
#	if no files are scanned and $2 was true'
checkTokenIsInFiles() {
	isDebug && printDebug "${FUNCNAME[0]} $*"
	local cond="$1"
	local tok="$2"
	shift 2
	if findTokenInFiles "$cond" "$tok" "$@"; then
		return 0
	else
		setFailure "Token $tok was not in one of these files: $*"
		return 0
	fi
}
readonly -f checkTokenIsInFiles

TTRO_help_checkTokenIsNotInFiles='
# Function checkTokenIsNotInFiles
#	Check if a token is not in one of these files
# Parameters:
#	$1 - if true, the function exits if no files are scanned
#	$2 - the token to find
#	$3... the list of files to check
# Returns:
#	true
#	Set failure if token was found in one of the files
# Exits:
#	if called with wrong params
#	a file is not readable
#	if no files are scanned and $2 was true'
checkTokenIsNotInFiles() {
	isDebug && printDebug "${FUNCNAME[0]} $*"
	local cond="$1"
	local tok="$2"
	shift 2
	if findTokenInFiles "$cond" "$tok" "$@"; then
		setFailure "Token $tok was not in one of these files: $*"
		return 0
	else
		return 0
	fi
}
readonly -f checkTokenIsNotInFiles

TTRO_help_checkTokenIsInDirs='
# Function checkTokenIsInDirs
#	Check if a token is in files in directories
# Parameters:
#	$1 - if true, the function exits if no files are scanned
#	$2 - the token to find
#	$3 - the file wildcard
#	$4 - the space separated list of directories to check
# Returns:
#	true
#	Set failure if the token wa not in one of the input directories
# Exits:
#	if called with wrong params
#	a file is not readable
if no files are scanned and $3 was true'
checkTokenIsInDirs() {
	isDebug && printDebug "${FUNCNAME[0]} $*"
	local cond="$1"
	local tok="$2"
	local wc="$3"
	shift 3
	if findTokenInDirs "$cond" "$tok" "$wc" "$@"; then
		return 0
	else
		setFailure "Token $tok was not in one of these directories: $*"
		return 0
	fi
}
readonly -f checkTokenIsInDirs

TTRO_help_checkTokenIsNotInDirs='
# Function checkTokenIsNotInDirs
#	Check if a token is not in files in directories
# Parameters:
#	$1 - if true, the function exits if no files are scanned
#	$2 - the token to find
#	$3 - the file wildcard
#	$4 - the space separated list of directories to check
# Returns:
#	true
#	Set failure if the token was in on of the files in directories
# Exits:
#	if called with wrong params
#	a file is not readable
if no files are scanned and $3 was true'
checkTokenIsNotInDirs() {
	isDebug && printDebug "${FUNCNAME[0]} $*"
	local cond="$1";
	local tok="$2";
	local wc="$3"
	shift 3
	if findTokenInDirs "$cond" "$tok" "$wc" "$@"; then
		setFailure "Token $tok was found in one of these directories: $*"
		return 0
	else
		return 0
	fi
}
readonly -f checkTokenIsNotInDirs

TTRO_help_arrayAppend='
# Function arrayAppend appends values on an indexed array
# Parameters:
#	$1 The name of the array to append
# $2 First value to appends
# ... optional more values to append may follow'
arrayAppend() {
	[[ $# -lt 2 ]] && printErrorAndExit "${FUNCNAME[0]}: not enough parameters" "${errRt}"
	isArray "$1" || printErrorAndExit "${FUNCNAME[0]}: $1 must be an indexed array" "${errRt}"
	local arrname="$1"
	shift
	while [[ $# -gt 0 ]]; do
		eval "$arrname+=( \"\$1\" )"
		shift
	done
}
readonly -f arrayAppend

TTRO_help_arrayInsert='
# Function arrayInsert inserts values into an indexed array
# Parameters:
#	$1 The name of the array
# $2 Index where to insert (this element is replaced with the first value to insert)
# $3 First value to inserts
# ... optional more elements to insert'
arrayInsert() {
	[[ $# -lt 3 ]] && printErrorAndExit "${FUNCNAME[0]}: parameters!" "${errRt}"
	isArray "$1" || printErrorAndExit "${FUNCNAME[0]}: $1 must be an indexed array" "${errRt}"
	local arrname="$1"
	local first="$2"
	local num=$(( $# - 2 ))
	eval "local arrlen=\${#$arrname[@]}"
	[[ $first -gt $arrlen ]] && printErrorAndExit "${FUNCNAME[0]} index to insert $first must not be greater than array len $arrlen" "${errRt}"
	# move elements num places forward
	local i
	local fromIndex=$first
	local toIndex=$(( first + num ))
	for ((i=arrlen-1; i>=first; i--)); do
		local newIndex=$((i+num))
		eval "$arrname[\$newIndex]=\${$arrname[\$i]}"
	done
	# insert
	shift; shift
	while [[ $# -gt 0 ]]; do
		eval "$arrname[\$first]=\"\$1\""
		first=$((first+1))
		shift
	done
}
readonly -f arrayInsert

TTRO_help_arrayDelete='
# Function arrayDelete deletes a value from an indexed array
# Parameters:
#	$1 The name of the array
# $2 Index to delete'
arrayDelete() {
	[[ $# -ne 2 ]] && printErrorAndExit "${FUNCNAME[0]}: parameters!" "${errRt}"
	isArray "$1" || printErrorAndExit "${FUNCNAME[0]}: $1 must be an indexed array" "${errRt}"
	local arrname="$1"
	local first="$2"
	eval "local arrlen=\${#$arrname[@]}"
	[[ $first -ge $arrlen ]] && printWarning "${FUNCNAME[0]} index to delete $first must not be greater or equal the array len $arrlen"
	local i
	for ((i=first; i<arrlen; i++)); do
		local nextindex=$((i+1))
		if [[ $nextindex -lt $arrlen ]]; then
			eval "${arrname}[\$i]=\${${arrname}[\${nextindex}]}"
		else
			eval "unset -v '${arrname}[\$i]'"
		fi
	done
}
readonly -f arrayDelete

TTRO_help_trim='
# Function trim removes leading and trailing whitespace characters
#	$1	the input string
#	returns the result string in TTTT_trim'
function trim {
	if [[ $# -ne 1 ]]; then printErrorAndExit "${FUNCNAME[0]} invalid no of params. Number of Params is $#" "${errRt}"; fi
	local locvar="$1"
	locvar="${locvar#${locvar%%[![:space:]]*}}"
	TTTT_trim="${locvar%${locvar##*[![:space:]]}}"
	return 0
}
readonly -f trim

#Guard for the last statement - make returncode always 0
:
