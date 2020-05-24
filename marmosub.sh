#!/bin/bash
selectChoices() {
    echo $1
    shift
    declare -a options=($@)
    select opt in "${options[@]}" "Quit"; do
        if ((REPLY == 1 + ${#options[@]})); then
            exit
        elif ((REPLY > 0 && REPLY <= ${#options[@]})); then
            break
        else
            echo "Invalid option. Try another one."
        fi
    done
    selected=${opt}
}

if [ $# -le 2 ]; then
    echo "Wrong number of args"
    echo "ex: marmosub COURSE PROJECT1 file1 file2 file3"
    exit 1
fi
course=$1
project=$2
selected=""
marmoset_cli="/u/cs_build/bin/marmoset"
shift
shift
for file in $@; do
    dos2unix $file
    if [[ $file =~ \.(c*|cpp|h)$ ]]; then
        echo "clang-formatting"
        clang-format -i $file
    fi
    if [[ -f $file ]] && [[ $(tail -c 1 $file) != "" ]]; then
        echo "Adding line to $file"
        echo >>$file
    fi
done
if [ -f Makefile ]; then
    make
    if [ $? -ne 0 ]; then
        echo Make failed
        exit 1
    fi
fi
execFile=$(find . -executable -type f)
filesFound=$(find . -name "*test*" -type d)
totalFoldersFound=$(echo $filesFound | wc -w)
totalExecFound=$(echo $execFile | wc -w)
selectedExec=$execFile
selectedFolder=$filesFound
canTest=true
if [ $totalFoldersFound -gt 1 ]; then
    selectChoices "Which test folder should be used?" ${filesFound}
    selectedFolder=$selected
elif [ $totalFoldersFound -eq 0 ]; then
    echo No test folders found.
    echo Skipping testing phase.
    canTest=false
fi
if [[ $canTest ]] && [ $totalExecFound -gt 1 ]; then
    selectChoices "Which executable should be used?" ${execFile}
    selectedExec=$selected
elif [[ $canTest ]] && [ $totalExecFound -eq 0 ]; then
    echo No executables found
    echo Skipping testing phase
    canTest=false
fi

if [[ $canTest = true ]]; then
    curDir=$(pwd)
    cd $selectedFolder
    suiteFile=$(find . -name "s*.txt" -type f)
    runSuite $suiteFile ${curDir}${selectedExec#.}
    cd $curDir
fi
echo
read -p "Submit to marmoset? "
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    marmoset_submit $course $project $@
    i=1
    while [[ $i -eq 1 ]]; do
        sleep 10
        $marmoset_cli --username=$(whoami) results $course $project last
        i=$?
    done
fi
