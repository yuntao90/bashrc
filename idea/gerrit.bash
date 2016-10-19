#!/bin/bash

GERRIT_ADDRESS=
GERRIT_DELEGATE_OWNER=
GERRIT_PORT=29418

# --submit-type
DEFAULT_SUBMIT_TYPE=REBASE_IF_NECESSARY

# params 
function gerrit_create_project
{
    local input="$@"
    local project=$1
    local others=$(echo $input | sed -e "s?$project??g")
    ssh -p $GERRIT_PORT $GERRIT_DELEGATE_OWNER@$GERRIT_ADDRESS gerrit create-project $project --submit-type $DEFAULT_SUBMIT_TYPE --empty-commit $others
}


echo 'ssh -p $GERRIT_PORT $GERRIT_DELEGATE_OWNER@$GERRIT_ADDRESS gerrit create-project $project --submit-type $DEFAULT_SUBMIT_TYPE --empty-commit $others'

