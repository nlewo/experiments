#!/usr/bin/env bash
set -e

TEMP=$(mktemp -d)

YAML=1
EXPR='""'
EVAL=()
VET=()
while [[ $# -gt 0 ]]
do
    # If -e EXPRESSION is provided, propageted it to the cue eval command
    if [ ${1} == "-e" ]
    then
       shift
       EVAL+=("-e")
       EVAL+=("$1")
       shift
       continue
    fi
    # If -y is provided, output a yaml instead of cue
    if [ ${1} == "-y" ]
    then
       shift
       YAML=0
       continue
    fi
    # If file have yaml suffix, first import them to cue
    if [ ${1: -5} == ".yaml" ]
    then
        cue import -o $TEMP/$1.cue $1
        EVAL+=("$TEMP/$1.cue")
    else
        EVAL+=("$1")
    fi
    VET+=("$1")
shift
done

cue vet ${VET[@]}
if [ $YAML == 1 ]
then
    cue eval ${EVAL[@]}
else
    cue eval ${EVAL[@]} > res.cue
    cue export res.cue | yq . -y
fi

rm -rf $TEMP
