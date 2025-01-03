#####################################################
# Utilities for the core testframework script code
#
# modul is sourced in runbtf, suite.sh and case.#!/bin/sh
# user code conflicts are potential possible
#####################################################

#
# TTTF_isSkip
# returns true if the script is to skip
function TTTF_isSkip {
	if [[ ( -n $TTPRN_skip ) && ( -z $TTPRN_skipIgnore ) ]]; then
		return 0
	else
		return 1
	fi
}
readonly -f TTTF_isSkip

#
# function to execute the variants of suites
# $1 the suite index to execute
# $2 is the variant to execute
# $3 nesting level of suite (parent)
# $4 the chain of suite names delim / (parent)
# $5 the chain of suite string including variants delim :: : (parent value)
# $6 parent sworkdir
# $7 preambl error
# $8 html indexfilename
# expect TTTI_suiteVariants TTTI_suiteErrors TTTI_suiteSkip
function TTTF_exeSuite {
	isDebug && printDebug "******* ${FUNCNAME[0]} $* number args $#"
	local suite="${TTTI_suitesName[$1]}"
	local suitePath="${TTTI_suitesPath[$1]}"
	local nestingLevel=$(($3+1))
	local suiteNestingPath="$4"
	local suiteNestingString="$5"
	local preamblError="$7"
	local indexfilename="$8"
	if [[ $1 -ne 0 ]]; then
		if [[ -z $suiteNestingPath ]]; then
			suiteNestingPath+="${suite}"
		else
			suiteNestingPath+="/${suite}"
		fi
		if [[ -z $suiteNestingString ]]; then
			suiteNestingString+="$suite"
		else
			suiteNestingString+="::$suite"
		fi
	fi
	if [[ -n $2 ]]; then
		suiteNestingString+=":$2"
	fi
	if [[ -z ${TTTI_executeSuite[$1]} ]]; then
		isDebug && printDebug "${FUNCNAME[0]}: no execution of suite $suitePath: variant='$2'"
		return 0
	fi
	printInfo "**** START Suite suite='${suite}' variant='$2' in ${suitePath} START ********************"
	#make and cleanup suite work dir
	local sworkdir="$TTRO_workDir"
	if [[ -n $suiteNestingString ]]; then
		local subst1="${suiteNestingString//:://}"
		local subst2="${subst1//://}"
		sworkdir="$sworkdir/$subst2"
	fi
	isDebug && printDebug "suite workdir is $sworkdir"
	if [[ -e $sworkdir ]]; then
		if [[ $1 -ne 0 ]]; then
			printError "Suite workdir already exists! Probably duplicate variant. workdir: $sworkdir"
			TTTI_suiteErrors=$(( TTTI_suiteErrors + 1))
			builtin echo "$suiteNestingString" >> "${6}/SUITE_ERROR"
			return 0
		fi
	fi
	if [[ $1 -ne 0 ]]; then
		mkdir -p "$sworkdir"
	fi

	# count execute suites but do not count the root suite
	if [[ $nestingLevel -gt 0 ]]; then
		TTTI_suiteVariants=$((TTTI_suiteVariants+1))
		builtin echo "$suiteNestingString" >> "${6}/SUITE_EXECUTE"
	fi

	#execute suite variant
	local result=0
	if "${TTRO_scriptDir}/suite.sh" "$1" "$2" "${sworkdir}" "$nestingLevel" "$suiteNestingPath" "$suiteNestingString" "$preamblError" 2>&1 | tee -i "${sworkdir}/${TEST_LOG}"; then
		result=0;
	else
		result=$?
		if [[ $result -eq $errSigint ]]; then
			printWarning "Set SIGINT Execution of suite ${suite} variant '$2' ended with result=$result"
			TTTI_interruptReceived=$((TTTI_interruptReceived+1))
		elif [[ $result -eq $errSkip ]]; then
			printInfo "Suite skipped suite ${suite} variant '$2'"
			TTTI_suiteSkip=$(( TTTI_suiteSkip+1 ))
			{ if read -r; then :; fi; } < "${sworkdir}/REASON" #read one line from reason
			builtin echo "$suiteNestingString: $REPLY" >> "${6}/SUITE_SKIP"
		else
			if [[ $nestingLevel -gt 0 ]]; then
				printError "Execution of suite ${suite} variant '$2' ended with result=$result"
				TTTI_suiteErrors=$(( TTTI_suiteErrors + 1))
				builtin echo "$suiteNestingString" >> "${6}/SUITE_ERROR"
			else
				printErrorAndExit "Execution of root suite failed" "$errRt"
			fi
		fi
	fi

	#read result lists and append results to the own list
	local x
	if [[ $1 -ne 0 ]]; then
		for x in CASE_EXECUTE CASE_SKIP CASE_FAILURE CASE_ERROR CASE_SUCCESS SUITE_EXECUTE SUITE_SKIP SUITE_ERROR; do
			local inputFileName="${sworkdir}/${x}"
			local outputFileName="${6}/${x}"
			eval "local ${x}_Count=0"
			if [[ -e ${inputFileName} ]]; then
				{ while read -r; do
					if [[ $REPLY != \#* ]]; then
						echo "$REPLY" >> "$outputFileName"
						eval "${x}_Count=$((${x}_Count+1))"
					fi
				done } < "${inputFileName}"
			else
				if [[ $result -ne $errSkip ]]; then
					printError "No result list $inputFileName in suite $sworkdir"
				fi
			fi
		done
	fi

	# html
	if [[ $nestingLevel -gt 0 ]]; then
		TTTF_addSuiteEntry "$indexfilename" "$suiteNestingString" "$result" "$suitePath" "${sworkdir}"\
		$CASE_EXECUTE_Count $CASE_SKIP_Count $CASE_FAILURE_Count $CASE_ERROR_Count $SUITE_EXECUTE_Count $SUITE_SKIP_Count $SUITE_ERROR_Count
	fi

	printInfo "**** END Suite suite='${suite}' variant='$2' in ${suitePath} END ********************"
	return 0
} #/TTTF_exeSuite
readonly -f TTTF_exeSuite

#
# Function TTTF_fixPropsVars
#	This function fixes all ro-variables and propertie variables
#	Property and variables setting is a two step action:
#	Unset help variables if no reference is printed
#	make vars STEPS PREPS FINS read-only
#	returns:
#		success (0)
#		error	in exceptional cases
function TTTF_fixPropsVars {
	#Workaround for bash bug local vars and global ro variable exists
	local TTTT_var=""
	if [[ -z $TTRO_reference ]]; then
		for TTTT_var in "${!TTRO_help@}"; do
			unset "$TTTT_var"
		done
	fi
	for TTTT_var in "${!TT_@}"; do
		isDebug && printDebug "${FUNCNAME[0]} : TT_   $TTTT_var=${!TTTT_var}"
		export "${TTTT_var}"
	done
	for TTTT_var in "${!TTRO_@}"; do
		isDebug && printDebug "${FUNCNAME[0]} : TTRO_ $TTTT_var=${!TTTT_var}"
		readonly "${TTTT_var}"
		export "${TTTT_var}"
	done
	for TTTT_var in "${!TTPR_@}"; do
		isDebug && printDebug "${FUNCNAME[0]} : TTPR_  $TTTT_var=${!TTTT_var}"
		readonly "${TTTT_var}"
		export "${TTTT_var}"
	done
	for TTTT_var in "${!TTPRN_@}"; do
		isDebug && printDebug "${FUNCNAME[0]} : TTPRN_ $TTTT_var=${!TTTT_var}"
		if [[ -n "${!TTTT_var}" ]]; then
			readonly "${TTTT_var}"
		fi
		export "${TTTT_var}"
	done
	#fix special local vars
	for TTTT_var in 'STEPS' 'PREPS' 'FINS'; do
		if declare -p "$TTTT_var" &> /dev/null; then
			declare -r "$TTTT_var"
		fi
	done
}
readonly -f TTTF_fixPropsVars

#
# Read a test case or a test suite file and evaluate the preambl
# variantCount and variantList and conditional the type; ignore the rest
# $1 is the filename to read
# return 0 in success case
# return 1 if an invalid preambl was read;
# results are returned in global variables variantCount, variantList, timeout, exclusive
function TTTF_evalPreambl {
	isDebug && printDebug "${FUNCNAME[0]} $1"
	if [[ ! -r $1 ]]; then
		printErrorAndExit "${FUNCNAME[0]} : Can not open file=$1 for read" "${errRt}"
	fi
	variantCount=""; variantList=""; timeout=''; exclusive=''
	declare -i lineno=1
	{
		local varname=
		local value=
		local result=0
		local x
		local preamblLine=''
		local len
		while [[ result -eq 0 ]]; do
			if ! read -r; then result=1; fi
			if [[ ( result -eq 0 ) || ( ${#REPLY} -gt 0 ) ]]; then #do not eval the last and empty line
				if [[ $REPLY =~ ^[[:space:]]*\#--([[:space:]]*)(.*) ]]; then
					#echo true "'${BASH_REMATCH[0]}'" "'${BASH_REMATCH[1]}' '${BASH_REMATCH[2]}'"
					if [[ -z $preamblLine ]]; then #take the spaces only in continuation lines
						preamblLine="${preamblLine}${BASH_REMATCH[2]}"
					else
						preamblLine="${preamblLine}${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
					fi
					len=$((${#preamblLine}-1))
					if [[ ( ${#preamblLine} -gt 0 ) && ( ${preamblLine:$len} == '\' ) ]]; then
						preamblLine="${preamblLine:0:$len}"
					else
						if TTTF_SplitPreamblAssign "$preamblLine"; then
							if [[ -n $varname ]] ; then
								isDebug && printDebug "${FUNCNAME[0]} prepare for variant encoding varname=$varname value=$value"
								case $varname in
									variantCount )
										if ! eval "variantCount=${value}"; then
											printError "${FUNCNAME[0]} : Invalid value in file=$1 line=$lineno '$preamblLine'"
											return 1
										fi
										if ! isPureNumber "$variantCount"; then
											printError "${FUNCNAME[0]} : variantCount is no digit in file=$1 line=$lineno '$preamblLine'"
											return 1
										fi
										isVerbose && printVerbose "variantCount='${variantCount}'"
									;;
									variantList )
										if ! eval "variantList=${value}"; then
											printError "${FUNCNAME[0]} : Invalid value in file=$1 line=$lineno '$preamblLine'"
											return 1
										fi
										isVerbose && printVerbose "variantList='${variantList}'"
									;;
									timeout )
										if ! eval "timeout=${value}"; then
											printError "${FUNCNAME[0]} : Invalid value in file=$1 line=$lineno '$preamblLine'"
											return 1
										fi
										if ! isPureNumber "$timeout"; then
											printError "${FUNCNAME[0]} : timeout is no digit in file=$1 line=$lineno '$preamblLine'"
											return 1
										fi
										isVerbose && printVerbose "timeout='${timeout}'"
									;;
									exclusive )
										if ! eval "exclusive=${value}"; then
											printError "${FUNCNAME[0]} : Invalid value in file=$1 line=$lineno '$preamblLine'"
											return 1
										fi
										isVerbose && printVerbose "exclusive='${exclusive}'"
									;;
									* )
										#other property or variable
										printError "${FUNCNAME[0]} : Invalid preambl varname='$varname' in file $1 line=$lineno '$preamblLine'"
										return 1
									;;
								esac
							else
								printError "${FUNCNAME[0]} : Invalid preampl line case or suitefile file=$1 line=$lineno '$preamblLine'"
								return 1
							fi
						else
							return 1
						fi
						preamblLine=''
					fi
				else
					if [[ -n $preamblLine ]]; then
						printError "Invalid line after preambl continuation file=$1 line=$lineno '$preamblLine'"
						return 1
					fi
				fi
				#isDebug && printDebug "Ignore line file=$1 line=$lineno '$REPLY'"
				lineno=$((lineno+1))
			fi
		done
	} < "$1"
	return 0
}
readonly -f TTTF_evalPreambl

#
# TTTF_SplitPreamblAssign
# Split the variable name and value part of an assignement in a preambl line
# The assignemtnet must something matching [[:word:]]=
# Ingnore all other lines
#	$1 the input line (only one line without nl)
#	return variables:
#		varname
#		value
#	returns
#		success(0) if the line was sucessfully split
#					the varname is empty if there is no valid assignement in the preambl line
#		error(1)   if there was no prambl line'
function TTTF_SplitPreamblAssign {
	[[ $# -eq 1 ]] || printErrorAndExit "Wrong number of arguments $# in ${FUNCNAME[0]}" "$errRt"
	isDebug && printDebug "${FUNCNAME[0]} \$1='$1'"
	if [[ $1 =~ ^([a-zA-Z0-9_]+)=(.*) ]]; then
		varname="${BASH_REMATCH[1]}"
		value="${BASH_REMATCH[2]}"
		isDebug && printDebug "${FUNCNAME[0]} varname='$varname' value='$value'"
		return 0
	else
		varname=""
		value=""
		printError "no valid preambl line here '$1'"
		return 1
	fi
}
readonly -f TTTF_SplitPreamblAssign

#
# write protect all exported fuinctions
function TTTF_writeProtectExportedFunctions {
	local functions=$(declare -Fx)
	local IFSSave="$IFS"
	local IFS=$'\n'
	local x fname
	local functionlist=''
	for x in $functions; do
		fname="${x##* }"
		functionlist="$functionlist $fname"
	done
	IFS="$IFSSave"
	for x in $functionlist; do
		if ! isInList "$x" "$TTXX_initialExportedFunctions"; then
			readonly -f "$x"
		fi
	done
}
readonly -f TTTF_writeProtectExportedFunctions

# write list of exported functions to TTXX_initialExportedFunctions
TTTF_listExportedFunctions() {
	TTXX_initialExportedFunctions=''
	local functions=$(declare -Fx)
	local IFS=$'\n'
	local x fname
	for x in $functions; do
		fname="${x##* }"
		TTXX_initialExportedFunctions="$TTXX_initialExportedFunctions $fname"
	done
}
readonly -f TTTF_listExportedFunctions

#
# Check if test run category matches any of the atrifact categories
# TTTT_categoryArray           - the array of artifact cats
# TTTT_runCategoryPatternArray - the array of category pattern of this test run
# return true if one run category pattern matches any of the artifact cats
#        or if catecory or eval TTTT_runCategoryPatternArray is empty
#        false otherwise
function TTTF_checkCats {
	if isNotExisting 'TTTT_categoryArray'; then
		printErrorAndExit "variable TTTT_categoryArray must exist" "$errRt"
	fi
	if ! isArray 'TTTT_categoryArray'; then
		printErrorAndExit "variable TTTT_categoryArray must be an indexed array" "$errRt"
	fi
	if isDebug; then
		local dispstring=$(declare -p 'TTTT_categoryArray')
		local dispstring2=$(declare -p 'TTTT_runCategoryPatternArray')
		printDebug "$dispstring $dispstring2"
	fi
	local lenCat="${#TTTT_categoryArray[*]}"
	local lenRunPat="${#TTTT_runCategoryPatternArray[*]}"
	if [[ ( $lenCat -eq 0 ) || ( $lenRunPat -eq 0 ) ]]; then
		isVerbose && printVerbose "No artifact category set or no run category pattern set: return true"
		return 0
	fi
	local i=0
	local j=0
	while (( i < lenCat )); do
		j=0
		while (( j < lenRunPat )); do
			isDebug && printDebug "i=$i j=$j cats: ${TTTT_categoryArray[$i]} == ${TTTT_runCategoryPatternArray[$j]}"
			if [[ ${TTTT_categoryArray[$i]} == ${TTTT_runCategoryPatternArray[$j]} ]]; then
				printInfo "Run category pattern set match found: ${TTTT_categoryArray[$i]} == ${TTTT_runCategoryPatternArray[$j]}"
				return 0
			fi
			j=$((j+1))
		done
		i=$((i+1))
	done
	printInfo "No run category pattern match found: ${FUNCNAME[0]} returns false"
	return 1
}
readonly -f TTTF_checkCats

# Kill all childs
#	$1 parent pid
#	$2 optional signal  (term if none)
TTTF_killchilds() {
	local pid=$1
	local sig=${2:--TERM}
	isDebug && printDebug "${FUNCNAME[0]} pid='$pid' sig=$sig"
	local myChild
	local mylist="$(ps -o pid --no-headers --ppid ${pid} || : )"
    for myChild in $mylist; do
        TTTF_killtree ${myChild} ${sig}
    done
    return 0
}
readonly -f TTTF_killchilds

# Kill the process tree
#	$1 pid
#	$2 optional signal (term if none)
TTTF_killtree() {
    local pid=$1
    local sig=${2:--TERM}
    isDebug && printDebug "${FUNCNAME[0]} pid='$pid' sig=$sig"
    local killOk='true'
    kill -STOP ${pid} 2>/dev/null || killOk='' # needed to stop quickly forking parent
    # print command to be stopped
    local processinfo=$(ps -q ${pid} -o args= || :)
    printInfo "kill ${pid} : ${processinfo}"
    local child
    for child in $(ps -o pid --no-headers --ppid ${pid} || : ); do
        TTTF_killtree ${child} ${sig}
    done
    kill ${sig} ${pid} 2>/dev/null || killOk=''
    kill -CONT ${pid} 2>/dev/null || killOk=''
    if [[ $killOk ]]; then
		printInfo "killed pid=$pid sig=$sig"
	else
		isVerbose && printVerbose "something went wrong during kill of pid=$pid"
	fi
    return 0
}
readonly -f TTTF_killtree

# Execute the preparation-, execution-, and finalization-steps in
# case and suite
#	$1 script: Case/Suite
#	$2 name: used for printout
#	$3 varName: PREPS/STEPS/FINS is then name of the new variable
#	$4 oldVarName: the name of the old style variable
#	$5 funcname: the name of the function to execute
#	$6 breakOnFailure - loop ends if failure was seen
#	$7 supressVarName - the name of the supress variable or empty. If var exists and is true, the steps are suppressed
#	$8 counterName - the name of the counter variable
TTTF_executeSteps() {
	isDebug && printDebug "${FUNCNAME[0]} $*"
	[[ $# -eq 8 ]] || printErrorAndExit "${FUNCNAME[0]} no params is wrong $#"

	local -r script="$1"
	local -r name="$2"
	local -r varName="$3"
	local -r oldVarName="$4"
	local -r funcname="$5"
	local -r breakOnFailure="$6"
	local -r supressVarName="$7"
	local -r counterName="$8"

	# prepare the array with all commands to execute
	local -a commandArray=();
	local TTTI_name_xyza
	for TTTI_name_xyza in "$oldVarName" "$varName"; do
		if isExisting "$TTTI_name_xyza"; then
			if isArray "$TTTI_name_xyza"; then
				local TTTI_l_xyza
				eval "TTTI_l_xyza=\${#$TTTI_name_xyza[@]}"
				local TTTI_i_xyza
				for (( TTTI_i_xyza=0; TTTI_i_xyza<TTTI_l_xyza; TTTI_i_xyza++)); do
					local TTTI_step_xyza
					eval "TTTI_step_xyza=\${$TTTI_name_xyza[$TTTI_i_xyza]}"
					commandArray+=( "$TTTI_step_xyza" )
				done
			else
				local TTTI_x_xyza
				for TTTI_x_xyza in ${!TTTI_name_xyza}; do
					commandArray+=( "$TTTI_x_xyza" )
				done
			fi
		fi
	done
	if isFunction "$funcname"; then
		commandArray+=( "$funcname" )
	fi
	
	local cmd
	local i
	for ((i=0; i<${#commandArray[*]}; i++)); do
		if [[ -n $breakOnFailure ]] && isExistingAndTrue 'TTTT_failureOccurred'; then
			break
		fi
		cmd="${commandArray[$i]}"
		if isExistingAndTrue "$supressVarName"; then
			printInfo "Suppress $script $name: $cmd"
		else
			printInfo "Execute $script $name: $cmd"
			eval "$counterName=\$(($counterName+1))"
			eval "$cmd"
		fi
		TTTF_fixPropsVars
	done

	printInfo "${!counterName} $script $name steps executed"
}
readonly -f TTTF_executeSteps

#
# Create the global index.html
# $1 the file to create
# $2 elapsed time
function TTTF_createGlobalIndex {
	local suiteErrorTxt
	if [[ $SUITE_ERRORCount -ne 0 ]]; then
		suiteErrorTxt="<span style=\"color: red\">errors=$SUITE_ERRORCount</span>"
	else
		suiteErrorTxt="errors=0"
	fi
	local suiteSkipTxt
	if [[ $SUITE_SKIPCount -ne 0 ]]; then
		suiteSkipTxt="<span style=\"color: blue\">skipped=$SUITE_SKIPCount</span>"
	else
		suiteSkipTxt="skipped=0"
	fi
	local caseErrorTxt
	if [[ $CASE_ERRORCount -ne 0 ]]; then
		caseErrorTxt="<span style=\"color: red\">errors=$CASE_ERRORCount</span>"
	else
		caseErrorTxt="errors=0"
	fi
	local caseSkipTxt
	if [[ $CASE_SKIPCount -ne 0 ]]; then
		caseSkipTxt="<span style=\"color: blue\">skipped=$CASE_SKIPCount</span>"
	else
		caseSkipTxt="skipped=0"
	fi
	local caseFailureTxt
	if [[ $CASE_FAILURECount -ne 0 ]]; then
		caseFailureTxt="<span style=\"color: red\">failures=$CASE_FAILURECount</span>"
	else
		caseFailureTxt="failures=0"
	fi

	cat <<-EOF > "$1"
	<!DOCTYPE html>
	<html>
	<head>
		<meta charset='utf-8'>
		<style>h1 { background-color: gray; color: white; text-align: center; }</style>
		<title>Test Report Collection '$TTRO_collection'</title>
	</head>
	<body>
		<h1>Test Report Collection '$TTRO_collection'</h1>
		<h2>The Suite Lists</h2>
		<p>
			<ul>
				<li><a href="suite.html">Global Dummy Suite</a></li>
			</ul>
			<h2>Summary</h2>
			<p>
			<table>
				<tr><td><b>Suites</b></td><td>executed=$SUITE_EXECUTECount</td><td></td><td>$suiteErrorTxt</td><td>$suiteSkipTxt</td></tr>
				<tr><td><b>Cases</b></td><td>executed=$CASE_EXECUTECount</td><td>$caseFailureTxt</td><td>$caseErrorTxt</td><td>$caseSkipTxt</td></tr>
			</table>
			<br>
			<hr><br>
			Categories of this run: ${cats}<br><br>
			Workdir: <a href="$TTRO_workDir">$TTRO_workDir</a><br><br>
			Elapsed time : $2<br>
			</p>
		</p>
	</body>
	</html>
	EOF
}
readonly -f TTTF_createGlobalIndex

#
# Create the suite index file
# $1 the index file name
function TTTF_createSuiteIndex {
	cat <<-EOF > "$1"
	<!DOCTYPE html>
	<html>
	<head>
		<style>h1 { background-color: gray; color: white; text-align: center; }</style>
		<meta charset='utf-8'>
		<title>Test Report Collection '$TTRO_collection'</title>
	</head>
	<body>
		<h1>Test Suite '$TTRO_suiteNestingString'</h1>
		<h2>Test Case execution:</h2>
		<p>
		<ul>
	EOF
}
readonly -f TTTF_createSuiteIndex

#
# Add Case entry to suite index.html and to summary text file
# $1 File name
# $2 Case name
# $3 Case variant
# $4 Case result
# $5 Case input dir
# $6 Case work dir
# $7 Elapsed time
# $8 Summary file name
function TTTF_addCaseEntry {
	local mycasename
	local reason=''
	local part1=''
	if [[ -n $3 ]]; then
		mycasename="$2::$3"
		part1="Testcase: $2:$3 took $7"
	else
		mycasename="$2"
		part1="Testcase: $2 took $7"
	fi

	if [[ -e "$6/REASON" ]]; then
		reason=$(<"$6/REASON")
	fi
	if [[ -e "$6/TIMEOUT" ]]; then
		reason='Timeout'
	fi
	case $4 in
		SUCCESS )
			echo "<li><a href=\"$6\"><b>$mycasename</b></a> - <a href=\"$5\">InputDir</a><br>$4 - Time elapsed: $7</li>" >> "$1"
			if [[ -n $TTXX_summary  ]]; then
				echo "$part1" >> "$8"
			fi;;
		ERROR )
			echo "<li><a href=\"$6\"><b>$mycasename</b></a> - <a href=\"$5\">InputDir</a><br><span style=\"color: red\">$4 ${reason}</span> - Time elapsed: $7</li>" >> "$1"
			if [[ -n $TTXX_summary  ]]; then
				echo -e "$part1\nERROR\n" >> "$8"
			fi;;
		FAILURE )
			echo "<li><a href=\"$6\"><b>$mycasename</b></a> - <a href=\"$5\">InputDir</a><br><span style=\"color: red\">$4</span> : $reason - Time elapsed: $7</li>" >> "$1"
			if [[ -n $TTXX_summary  ]]; then
				echo -e "$part1\nFAILURE\n${reason}\n" >> "$8"
			fi;;
		SKIP )
			echo "<li><a href=\"$6\"><b>$mycasename</b></a> - <a href=\"$5\">InputDdir</a><br><span style=\"color: blue\">$4</span> : $reason - Time elapsed: $7</li>" >> "$1"
			if [[ -n $TTXX_summary  ]]; then
				echo -e "$part1\nSKIPPED\n${reason}\n" >> "$8"
			fi;;

		*)
			printErrorAndExit "Wrong result string $4" "$errRt"
	esac
}
readonly -f TTTF_addCaseEntry

#
# Start suite index and end case list
# $1 File name
function TTTF_startSuiteList {
	cat <<-EOF >> "$1"
		</ul>
		</p>
		<h2>Test Suite execution:</h2>
		<p>
		<ul>
	EOF
}
readonly -f TTTF_startSuiteList

#
# Add Suite entry to suite index.html
# $1 File name
# $2 Suite nesting string
# $3 Suite result
# $4 Suite input dir
# $5 Suite work dir
# $6 Cases executed
# $7 Cases skipped
# $8 Cases failed
# $9 Cases error
# $10 Suites executed
# $11 Suites skipped
# S12 Suites error
function TTTF_addSuiteEntry {
	if [[ $# -ne 12 ]]; then printErrorAndExit "wrong no of arguments $#" "$errRt"; fi
	case $3 in
		0 )
			echo -n "<li><a href=\"$5/suite.html\"><b>$2</b></a> - ResultCode: $3 - <a href=\"$5\">WorkDir</a> - <a href=\"$4\">InputDir</a>" >> "$1";;
		"$errSkip" )
			{ if read -r; then :; fi; } < "$5/REASON" #read one line from reason
			echo -n "<li style=\"color: blue\"><a href=\"$5/suite.html\"><b>$2</b></a> - ResulCode: $3 SKIP: $REPLY - <a href=\"$5\">WorkDir</a> - <a href=\"$4\">InputDir</a>" >> "$1";;
		"$errSigint" )
			echo -n "<li style=\"color: red\"><a href=\"$5/suite.html\"><b>$2</b></a> - ResultCode: $3 SIGINT received - <a href=\"$5\">WorkDir</a> - <a href=\"$4\">InputDir</a>" >> "$1";;
		* )
			echo -n "<li style=\"color: red\"><a href=\"$5/suite.html\"><b>$2</b></a> - ResultCode: $3 - <a href=\"$5\">WorkDir</a> - <a href=\"$4\">InputDir</a>" >> "$1"
	esac
	if [[ $3 -ne $errSkip ]]; then
		echo -n "      <br><b>Cases</b> executed=$6 " >> "$1"
		if [[ $8 -ne 0 ]]; then
			echo -n "<span style=\"color: red\">failures=$8 </span>" >> "$1"
		else
			echo -n "failures=$8 " >> "$1"
		fi
		if [[ $9 -ne 0 ]]; then
			echo -n "<span style=\"color: red\">errors=$9 </span>" >> "$1"
		else
			echo -n "errors=$9 " >> "$1"
		fi
		if [[ $7 -ne 0 ]]; then
			echo -n "<span style=\"color: blue\">skipped=$7 </span>" >> "$1"
		else
			echo -n "skipped=$7 " >> "$1"
		fi
		echo -n "<b> Suites</b> executed=${10} " >> "$1"
		if [[ ${12} -ne 0 ]]; then
			echo -n "<span style=\"color: red\">errors=${12} </span>" >> "$1"
		else
			echo -n "errors=${12} " >> "$1"
		fi
		if [[ ${11} -ne 0 ]]; then
			echo "<span style=\"color: blue\">skipped=${11}</span></li>" >> "$1"
		else
			echo "skipped=${11}</li>" >> "$1"
		fi
	else
		echo "      <br> ... </li>" >> "$1"
	fi
}
readonly -f TTTF_addSuiteEntry

#
# end suite index html
# $1 file name
# $2 elapsed time string
function TTTF_endSuiteIndex {
	cat <<-EOF >> "$1"
		</ul>
		</p>
		<h2>Summary</h2>
		<p>
			Suite input dir   <a href="$TTRO_inputDirSuite">$TTRO_inputDirSuite</a><br>
			Suite working dir <a href="$TTRO_workDirSuite">$TTRO_workDirSuite</a><br>
			<br>
			Elapsed time : $2
			<br>
		</p>
		</body>
	</html>
	EOF
}
readonly -f TTTF_endSuiteIndex
:
