############################################
# Tools for the selftest collection
############################################

#define required variables default
setVar 'TT_expectResult' 0
setVar 'TT_runOptions' ''
setVar 'TT_caseList' ''
# variables fot the exepected results
setVar 'TT_suitesExecuted' 0 # number of suites executed
setVar 'TT_suitesSkipped' 0  # number of suites skipped
setVar 'TT_suitesError' 0    # number of suite errors
setVar 'TT_casesExecuted' 0  # number of cases executed
setVar 'TT_casesSkipped' 0   # number of cases skipped
setVar 'TT_casesFailed'  0   # number of cases failed
setVar 'TT_casesError'   0   # number of cases errors'

TTRO_help_copyAndModifyTestCollection='
#	This function copies from input dir/testCollection dir into working dir of test case
#	and renames file TTestCase.sh into TestCase.sh ..'
function copyAndModifyTestCollection {
	if [[ $# -ne 0 ]]; then printErrorAndExit "$FUNCNAME invalid no of params. Number of Params is $#" $errRt; fi
	isDebug && printDebug "$FUNCNAME $*"
	local sourceDir="$TTRO_inputDirCase/testCollection"
	local destDir="$TTRO_workDirCase"
	if [[ -d $destDir ]]; then
		cp -rp "$sourceDir" "$destDir"
		local x
		for x in $TEST_PROPERTIES $TEST_SUITE_FILE $TEST_CASE_FILE; do
			renameInSubdirs "$destDir/testCollection" "T$x" "$x"
		done
	fi
}
export -f copyAndModifyTestCollection

TTRO_help_runRunbtf='
# Execute the test freamework with input directory testCollection intercept error
#	TT_runOptions - additional options
#	TT_caseList - the case list
#	TT_expectedResult - the expected result code a number or X when to be ignored'
function runRunbtf {
	isDebug && printDebug "$FUNCNAME $*"
	local result
	if echoAndExecute $TTPRN_binDir/runbtf --directory "$TTRO_workDirCase/testCollection" $TT_runOptions $TT_caseList 2>&1 | tee STDERROUT1.log; then
		result=0
	else
		result=$?
	fi
	if [[ $TT_expectResult -eq 0 ]]; then
		if [[ $result -eq 0 ]]; then
			return 0
		else
			setFailure "result is $result. Expected is $TT_expectResult"
		fi
	elif [[ $TT_expectResult == 'X' ]]; then
		if [[ $result -ne 0 ]]; then
			return 0
		else
			printWarning "result is $result. Expected is $TT_expectResult"
			return 0
		fi
	else
		if [[ $TT_expectResult -eq $result ]]; then
			return 0
		else
			setFailure "result is $result. Expected is $TT_expectResult"
		fi
	fi
}
export -f runRunbtf

TTRO_help_checkResults='
# Function checkResults
#	checks the final results of the test run
#	TT_suitesExecuted - number of suites executed
#	TT_suitesSkipped  - number of suites skipped
#	TT_suitesError    - number of suite errors
#	TT_casesExecuted  - number of cases executed
#	TT_casesSkipped   - number of cases skipped
#	TT_casesFailed    - number of cases failed
#	TT_casesError     - number of cases errors'
function checkResults {
	linewisePatternMatchInterceptAndSuccess \
			'./STDERROUT1.log'\
			'true'\
			"*\*\*\*\*\* suites executed=$TT_suitesExecuted errors=$TT_suitesError skipped=$TT_suitesSkipped"\
			"*\*\*\*\*\* cases  executed=$TT_casesExecuted failures=$TT_casesFailed errors=$TT_casesError skipped=$TT_casesSkipped"
	return 0
}
export -f checkResults
