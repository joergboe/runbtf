#--variantCount=4

PREPS='copyAndModifyTestCollection'
STEPS='getOptions TT_expectResult=0 runRunbtf TT_suitesExecuted=6 TT_casesExecuted=4 checkResults'

declare -a options=( '--noprompt --no-browser' '-j 1 --noprompt --no-browser' '-j 1 -v --noprompt --no-browser' '-j 1 -v -d --noprompt --no-browser' )

function getOptions {
	TT_runOptions="${options[$TTRO_variantCase]}"
}