#!/bin/bash

set -o errexit; set -o nounset;

source bin/version.sh

declare -r releasedir='releases'
declare -r docdir='docs'

echo
echo "Build release package version v$TTRO_version"
echo

while read -p "Is this correct: y/e "; do
	if [[ $REPLY == "y" || $REPLY == "Y" ]]; then
		break
	elif [[ $REPLY == "e" || $REPLY == "E" ]]; then
		exit 2
	fi
done

commitstatus=$(git status --porcelain)
if [[ $commitstatus ]]; then
	echo "Repository has uncommited changes:"
	echo "$commitstatus"
	read -p "To produce the release anyway press y/Y";
	if [[ $REPLY != "y" && $REPLY != "Y" ]]; then
		echo "Abort"
		exit 1
	fi
fi

mkdir -p "$docdir"
cd bin
./runBTF --man | grep -v '===' > "../${docdir}/manpage.md"
./runBTF --ref '' > ../${docdir}/utils.txt.tmp
while read -r; do
	if [[ $REPLY =~ \#[[:space:]] ]]; then
		echo "${REPLY:1}"
	else
		echo "$REPLY"
	fi;
done < ../${docdir}/utils.txt.tmp > ../${docdir}/utils.txt
rm ../${docdir}/utils.txt.tmp
cd -

commithash=$(git rev-parse HEAD)
echo "RELEASE.INFO commithash=$commithash"
echo "commithash=$commithash" > RELEASE.INFO

mkdir -p "$releasedir"

fname="testframeInstaller_v${TTRO_version}.sh"

tar cvJf "$releasedir/tmp.tar.xz" --exclude=.apt_generated --exclude=.toolkitList --exclude=.gitignore bin samples README.md RELEASE.INFO

cat tools/selfextract.sh releases/tmp.tar.xz > "$releasedir/$fname"

chmod +x "$releasedir/$fname"

rm "$releasedir/tmp.tar.xz"

echo
echo "*************************************************"
echo "Success build release package '$releasedir/$fname'"
echo "*************************************************"

exit 0
