###############################################
# Definitions and constants for testframework
#
###############################################

#exit code definitions
declare -r errTestFail=20 errSkip=21 errTestError=25 errSuiteError=26
declare -r errVersion=30 errInvocation=40 errScript=50 errRt=60 errEnv=70
declare -r errSigint=130

#constants
declare -r DEFAULT_WORKDIR='workdir'
declare -r TEST_PROPERTIES="TestProperties.sh"
declare -r TEST_SUITE_FILE="TestSuite.sh"
declare -r TEST_CASE_FILE="TestCase.sh"
#declare -r TEST_TOOLS_FILE="TestTools.sh"
declare -r TEST_ENVIRONMET_LOG="ENVIRONMENT.log"
declare -r TEST_LOG="STDERROUT.log"

declare -ri defaultTimeout=240
declare -ri defaultAdditionalTime=60
