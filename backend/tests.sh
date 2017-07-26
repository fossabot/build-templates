#!/bin/bash
set -e

if [ -z "$1" ]; then
    CURRENT_PACKAGE="$VANILLA_PACKAGE.apis"
else
    CURRENT_PACKAGE=$1
fi

echo "Launching unittests with coverage"
echo "Package: $CURRENT_PACKAGE"
sleep 1

# Avoid colors when saving tests output into files
export TESTING_FLASK="True"

# nosetests \
#     --stop \
#     --with-coverage \
#     --cover-erase --cover-package=rapydo \
#     --cover-html --cover-html-dir=/tmp/coverage

# Coverage + stop on first failure
com="nose2 -F"
option="-s tests"
cov_reports=" --coverage-report term --coverage-report html"
cov_options="--output-buffer -C --coverage ${CURRENT_PACKAGE}"
echo $com $cov_options $cov_reports

###################
## STEP 1
# Basic tests, written for generic http-api-base sake
$com $option/base --log-capture

if [ "$?" == "0" ]; then

    ###################
    ## STEP 2
    # Custom tests from the developer, if available
    $com $option/custom --log-capture

    if [ "$?" == "0" ]; then

        ###################
        ## STEP 3
        # Print coverage if everything went well so far
        echo "*** COMPUTING COVERAGE ***"
        $com $cov_options $cov_reports 2> /tmp/logfile.txt
        if [ "$?" == "0" ]; then
            grep "platform linux" -A 1000 /tmp/logfile.txt
            echo "*** COVERAGE COMPLETED ***"
        else
            echo "Failed to create coverage"
            exit 1
        fi
    else
        exit $?
    fi
else
    exit $?
fi
