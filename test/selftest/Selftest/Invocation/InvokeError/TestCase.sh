
#--variantCount=4

STEPS='executeCase myEvaluate'

declare -ar prameterArray=("-zt" "--properties" "--link --no-start" "-Dbla=xx")

declare -ar outputValidation=("*ERROR: Invalid argument*" "*ERROR: Missing Option argument*" "*ERROR: Invalid argument \'--link\'*" "*ERROR: Invalid argument \'-Dbla=xx\'*")


function executeCase {
	local tmp="${prameterArray[$TTRO_variantCase]}"
	if $TTPRN_binDir/runbtf $tmp 2>&1 | tee STDERROUT1.log; then
		return $errTestFail
	else
		result=$?
		if [[ $result -ne $errInvocation ]]; then
			return $errTestFail
		else
			return 0
		fi
	fi
}

function myEvaluate {
	local tmp="${outputValidation[$TTRO_variantCase]}"
	linewisePatternMatch './STDERROUT1.log' "" "$tmp"
}