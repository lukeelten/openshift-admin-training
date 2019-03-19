#!/bin/bash

TF="keys.tf"
echo "" > "$TF"

append() {
    echo "$1" >> "$TF"
}

provider() {
    append 'provider "aws" {'
    append '  region = "eu-central-1"'
    append '  version = "1.60"'
    append '}'
    append ''
}

add_key() {
    if [[ -z "$1" ]]; then
        echo "Invalid parameter" > /dev/stderr
        exit 5
    fi
    PUB_KEY=$(cat "training${1}.pub")

    append "resource \"aws_key_pair\" \"public-key-$1\" {"
    append "  key_name = \"heinlein-training-$1\""
    append "  public_key = \"${PUB_KEY}\""
    append '}'
    append ''
}

provider

for i in {0..9}; do
    FILENAME="training$i"
    echo "Generate key $i to file: '${FILENAME}'"

    ssh-keygen -t rsa -b 4096 -C '' -P '' -f "${FILENAME}" > /dev/null
    add_key $i
done

terraform init

if [[ $? -eq 0 ]]; then
    terraform apply
fi

exit $?