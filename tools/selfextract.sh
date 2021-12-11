#!/bin/bash

set -o nounset;

wrongInvocation=''
if [[ $# -eq 0 ]]; then
	interactive='true'
	help=''
elif [[ $# -eq 1 ]]; then
	if [[ $1 == '-h' || $1 == '--help' ]]; then
		interactive='true'
		help='true'
	else
		interactive=''
		help=''
	fi
else
	interactive='true'
	help='true'
	wrongInvocation='true'
fi

if [[ -n $help ]]; then
	myCommand=${0##*/}
	echo
	echo "Usage: $myCommand [ <install_dir>  | -h | --help ]"
	echo
	echo "Install Streams Toolkits Testframework Tool runTT"
	echo
	echo "If no command line parameter is specified the installation"
	echo "is done interactive"
	echo "If command line parameter <install_dir> is specified, the instalation starts standalone"
	echo "If command line parameter -h|--help is specified, this message is print"
	echo
	if [[ -n $wrongInvocation ]]; then
		exit 1
	else
		exit 0
	fi
fi

if [[ -n $interactive ]]; then
	DEFAULTINSTALLDIR='runBTF'
	installUser=$(whoami)
	if [[ $installUser == 'root' ]]; then
		destination="/opt/$DEFAULTINSTALLDIR"
	else
		destination="$HOME/$DEFAULTINSTALLDIR"
	fi
else
	destination="$1"
fi

#Get version information from own filename
declare -r commandname="${0##*/}"
declare version=''
if [[ $commandname =~ testframeInstaller_v([0-9]+)\.([0-9]+)\.([0-9]+)\.sh ]]; then
	major="${BASH_REMATCH[1]}"
	minor="${BASH_REMATCH[2]}"
	fix="${BASH_REMATCH[3]}"
	echo "Install runBTF release $major.$minor.$fix"
elif [[ $commandname =~ testframeInstaller_v([0-9]+)\.([0-9]+)\.([0-9]+.+)\.sh ]]; then
	major="${BASH_REMATCH[1]}"
	minor="${BASH_REMATCH[2]}"
	fix="${BASH_REMATCH[3]}"
	echo "Install runBTF development version $major.$minor.$fix"
else
	echo "ERROR: This is no valid install package commandname=$commandname" >&2
	exit 1
fi

if [[ -n $interactive ]]; then
	while read -p "Install into directory $destination (yes/no/exit) [y/n/e]"; do
		if [[ $REPLY == "y" || $REPLY == "Y" || $REPLY == "yes" ]]; then
			break
		elif [[ $REPLY == "n" || $REPLY == "N" || $REPLY == "no" ]]; then
			read -p "Enter installation directory:"
			eval tempdir="$REPLY"
			if [[ $tempdir != /* ]]; then
				echo "Use a absolute path not $tempdir"
			else
				destination="$tempdir"
			fi
		elif [[ $REPLY == "e" || $REPLY == "E" || $REPLY == "exit" ]]; then
			exit 2
		fi
	done

	while read -p "Install into directory $destination is this correct? (yes/exit) [y/e]"; do
		if [[ $REPLY == "y" || $REPLY == "Y" || $REPLY == "yes" ]]; then
			break
		elif [[ $REPLY == "e" || $REPLY == "E" || $REPLY == "exit" ]]; then
			exit 2
		fi
	done
fi

if [[ $destination != /* ]]; then
	echo "Use a absolute path not $destination" >&2
	exit 1
fi

versiondir="v$major.$minor"
tempdir="${destination}/tmp/${versiondir}"

#Determine the line with the archive marker
declare -i archiveline=0
declare -i line=0
while read; do
	line=$((line + 1 ))
	if [[ $REPLY == __ARCHIVE_MARKER__ ]]; then
		if [[ $archiveline -eq 0 ]]; then  # only the first marker counts
			archiveline="$line"
		fi
	fi
done < "${0}"

archiveline=$((archiveline + 1))
#echo "archiveline=$archiveline"

# Create destination folder
mkdir -p ${tempdir}

tail -n+${archiveline} "${0}" | tar xpJv -C ${tempdir}

#create target folder
mkdir -p ${bindir}
#remove old links
rm -f "${destination}/bin/runBTF"
rm -f "${destination}/bin/runBTF$major"
rm -f "${destination}/bin/runBTF$major.$minor"
#move to target
mv "$tempdir/README.md" "${destination}/${versiondir}"
mv "$tempdir/RELEASE.INFO" "${destination}/${versiondir}"
mv $tempdir/samples/* $sampledir
mv $tempdir/bin/* $bindir

#remove temp folder
rm -rf "${destination}/tmp"
#make links
mkdir -p ${destination}/bin
ln -s ${bindir}/runBTF ${destination}/bin/runBTF
ln -s ${bindir}/runBTF ${destination}/bin/runBTF$major
ln -s ${bindir}/runBTF ${destination}/bin/runBTF$major.$minor

echo "***************************************************"
echo "Installation complete. Target bin directory $bindir"
echo "You can execute the runBTF help function:"
echo "${destination}/bin/runBTF --help"
echo "${destination}/bin/runBTF$major --help"
echo "${destination}/bin/runBTF$major.$minor --help"
echo "***************************************************"

# Exit from the script with success (0)
exit 0

__ARCHIVE_MARKER__
