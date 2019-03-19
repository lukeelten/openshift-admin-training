#!/bin/bash
terraform destroy

if [[ $? -eq 0 ]]; then
    echo "Remove SSH keys"
    rm -f training* *.tfstate *.tfstate.backup keys.tf > /dev/null
    rm -rf .terraform > /dev/null
    exit 0
fi

exit $?