#!/bin/bash

set -e
set -o pipefail

if [[ $# -lt 2 ]]; then
    echo "Wrong parameters" > /dev/stderr
    echo "Usage: $0 <architecture> <number of instances>"
    exit 1
fi

ARCH="$1"
COUNT="$2"
PWD=$(pwd)

CONF="${PWD}/architecture/${ARCH}.json"
ARCH_DIR="${PWD}/architecture/${ARCH}"

if [[ ! -d "${ARCH_DIR}" || ! -f "${CONF}" ]]; then
    echo "Architecture: ${ARCH}" > /dev/stderr
    echo "Missing architecture or configuration file" > /dev/stderr
    exit 2
fi

if [[ ${COUNT} -lt 0 || ${COUNT} -gt 99 ]]; then    
    echo "Invalid count given: ${COUNT}" > /dev/stderr
    exit 3
fi

STATE_PATH="states"
mkdir -p "${STATE_PATH}"

cd "${ARCH_DIR}"

ACTION="apply"
ACTION_NAME="Build"
if [[ ${COUNT} -eq 0 ]]; then
    ACTION="destroy"
    ACTION_NAME="Cleanup"
    COUNT=$(find "${STATE_PATH}" -type f | grep "tfstate$" | sort | uniq | tail -1 | sed -r 's/.*\/state-([[:digit:]])\.tfstate$/\1/')
    if [[ ! -f "${STATE_PATH}/state-${COUNT}.tfstate" ]]; then
        echo "Cannot correctly determine count. Calculated: ${COUNT}" > /dev/stderr
        exit 5
    fi
fi

echo "Init terraform"
terraform init -input=false > /dev/null

echo
echo "${ACTION_NAME} ${COUNT} architectures of type ${ARCH}"

for i in $(seq 0 "${COUNT}"); do
    echo "${ACTION_NAME} architecture ${i}"
    terraform ${ACTION} -var-file="${CONF}" -var "Training=${i}" -state="${STATE_PATH}/state-${i}.tfstate" -input=false -auto-approve > /dev/null
done

echo "Finished"
cd "${PWD}"
exit 0