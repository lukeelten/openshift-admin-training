#!/bin/bash

TF="keys.tf"
echo "" > "$TF"
NUM=${1:-10}

append() {
    echo "$1" >> "$TF"
}

provider() {
    append 'provider "aws" {'
    append '  region = "eu-central-1"'
    append '  version = "~> 2.0"'
    append '}'
    append ''
}

add_key() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Invalid parameter" > /dev/stderr
        exit 5
    fi
    PUB_KEY="${2}"

    append "resource \"aws_key_pair\" \"public-key-$1\" {"
    append "  key_name = \"heinlein-training-$1\""
    append "  public_key = \"${PUB_KEY}\""
    append '}'
    append ''
}

provider

HOST_KEY=$(cat "$HOME/.ssh/id_rsa.pub")
add_key "0" "$HOST_KEY"

for i in $(seq 1 $NUM); do
    FILENAME="training$i"
    echo "Generate key $i to file: '${FILENAME}'"

    ssh-keygen -t rsa -b 4096 -C '' -P '' -f "${FILENAME}" > /dev/null
    PUB_KEY=$(cat "training${i}.pub")
    add_key "$i" "${PUB_KEY}" 
done

terraform init

if [[ $? -eq 0 ]]; then
    terraform apply
fi

exit $?
