
function testPreparation {
	echo "*********************************************************"
	echo " this suite tests helper functions and expected result is"
	echo "cases  executed=174 failures=22 errors=31 skipped=0"
	echo "*********************************************************"
	echo
	echo "Expected failures are:"
	echo
	echo "**** CASE_FAILURE List : ****"
echo "#suite[:variant][::suite[:variant]..]::case[:variant]"
echo "Collection::Functions::echoAndExecute:falseCheck"
echo "Collection::Functions::echoExecuteAndIntercept2:expectSuccFails"
echo "Collection::Functions::echoExecuteAndIntercept2:expectErrorFails"
echo "Collection::Functions::echoExecuteAndIntercept2:simpleCommands27Fails"
echo "Collection::Functions::echoExecuteInterceptAndError:succ"
echo "Collection::Functions::echoExecuteInterceptAndError:simpleCommands1Succ"
echo "Collection::Functions::echoExecuteInterceptAndError:simpleCommands2Succ"
echo "Collection::Functions::echoExecuteInterceptAndSuccess:wrongCommand"
echo "Collection::Functions::echoExecuteInterceptAndSuccess:fails"
echo "Collection::Functions::echoExecuteInterceptAndSuccess:simpleCommands27"
echo "Collection::Functions::executeLogAndError:succ"
echo "Collection::Functions::executeLogAndError:simpleCommands1Succ"
echo "Collection::Functions::executeLogAndError:simpleCommands2Succ"
echo "Collection::Functions::executeLogAndSuccess:wrongCommand"
echo "Collection::Functions::executeLogAndSuccess:fails"
echo "Collection::Functions::executeLogAndSuccess:simpleCommands27"
echo "Collection::Functions::findTokenInDirs:checkTokenIsInDirsFail: Token ERROXR was not in one of these directories:..."
echo "Collection::Functions::findTokenInDirs:scheckTokenIsNotInDirsFail: Token ERROR was found in one of these directories:..."
echo "Collection::Functions::findTokenInFiles:checkTokenIsInFilesFailure: Token ERROXR was not in one of these files:..."
echo "Collection::Functions::findTokenInFiles:checkTokenIsNotInFilesFailure: Token ERROR was not in one of these files:..."
echo "Collection::Functions::linewisePatternMatch:matchSuccessFail: Not enough matches: 'linewisePatternMatchInterceptAndSuccess ...'"
echo "Collection::Functions::linewisePatternMatch:matchErrorFail: Match found: 'linewisePatternMatchInterceptAndError ...'"

echo
echo "**** CASE_ERROR List : ****"
echo "#suite[:variant][::suite[:variant]..]::case[:variant]"
echo "Collection::Functions::arrayInsert:pasteEnd"
echo "Collection::Functions::echoAndExecute:noParm"
echo "Collection::Functions::echoAndExecute:emptyCommand"
echo "Collection::Functions::echoAndExecute:false"
echo "Collection::Functions::echoAndExecute:emptyCommandCheck"
echo "Collection::Functions::echoAndExecute:noParmCheck"
echo "Collection::Functions::echoExecuteAndIntercept:noParm"
echo "Collection::Functions::echoExecuteAndIntercept:emptyCommand"
echo "Collection::Functions::echoExecuteAndIntercept2:noParm"
echo "Collection::Functions::echoExecuteAndIntercept2:wrongCode"
echo "Collection::Functions::echoExecuteAndIntercept2:emptyCommand"
echo "Collection::Functions::echoExecuteInterceptAndError:noParm"
echo "Collection::Functions::echoExecuteInterceptAndError:emptyCommand"
echo "Collection::Functions::echoExecuteInterceptAndSuccess:noParm"
echo "Collection::Functions::echoExecuteInterceptAndSuccess:emptyCommand"
echo "Collection::Functions::executeAndLog:noParm"
echo "Collection::Functions::executeAndLog:emptyCommand"
echo "Collection::Functions::executeLogAndError:noParm"
echo "Collection::Functions::executeLogAndError:emptyCommand"
echo "Collection::Functions::executeLogAndSuccess:noParm"
echo "Collection::Functions::executeLogAndSuccess:emptyCommand"
echo "Collection::Functions::findTokenInDirs:noDirsError"
echo "Collection::Functions::findTokenInDirs:wrongDirname"
echo "Collection::Functions::findTokenInDirs:fileNotReadable"
echo "Collection::Functions::findTokenInFiles:noFilesError"
echo "Collection::Functions::findTokenInFiles:wrongFilename"
echo "Collection::Functions::isExisting:noArgumentIs"
echo "Collection::Functions::isExisting:noArgumentNot"
echo "Collection::Functions::isFalse:varNotExists"
echo "Collection::Functions::isTrue:varNotExists"
echo "Collection::Functions::setVar::setVar:2"

	promptYesNo
}