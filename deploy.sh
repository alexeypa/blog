#!/bin/bash

set -e
set -o pipefail

if [ ! -e public ]
then
    echo '"public" does not exist'
    exit 1
fi

if [ -e "$1" ]
then
    rm -rf "$1"
fi

mv public "$1"
cp htaccess "$1/.htaccess"
