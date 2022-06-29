#!/usr/bin/env bash

# Copyright 2022-, Semiotic AI, Inc.
# SPDX-License-Identifier: Apache-2.0

set -x
set -euo pipefail
IFS=$'\n\t'

# Variables
QUERY_LOGS_TO_PORT="${GQL_LOGS_TO_PORT:=31338}"
QUERY_LOGS_TO_HOST="${GQL_LOGS_TO_HOST:=127.0.0.1}"  # "localhost" does not seem to work
BASEDIR=/opt/autoagora/run

# For the indexer-service to log query timings to stdout
export INDEXER_SERVICE_QUERY_TIMING_LOGS=true

mkdir -p $BASEDIR

# Remove the existing name pipes just in case
rm -f $BASEDIR/{indexer_service_output,indexer_service_queries}
# Create the named pipes
mkfifo -m a+rw $BASEDIR/{indexer_service_output,indexer_service_queries}

# Reading from the indexer_service_output pipe, tee into 2 streams, run in background
# jq filter the query entries, pipe them into the indexer_service_queries pipe
# jq filter the non-query entries, pipe them out to stdout
cat $BASEDIR/indexer_service_output |
    tee >(jq -c --unbuffered '. | select(.msg == "Done executing paid query")' > $BASEDIR/indexer_service_queries) |
    jq -c --unbuffered '. | select(.msg != "Done executing paid query")' &

# Send the GQL lines out to the sidecar through UDP. Run in background
cat $BASEDIR/indexer_service_queries | nc -u $GQL_LOGS_TO_HOST $GQL_LOGS_TO_PORT &

# Start indexer-service, pipe stdout and stderr into the indexer_service_output pipe
cd /opt/indexer/packages/indexer-service
node dist/index.js start > $BASEDIR/indexer_service_output
