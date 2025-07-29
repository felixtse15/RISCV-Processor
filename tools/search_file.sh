#!/bin/bash

# This is a script that takes a keyword as a parameter and returns the files that contain that keyword. 
# Usage: Provide keyword as first argument. If directory argument not provided, search in current directory

# First check if an argument is provided

if [ -z "$1" ]; then
	echo "Usage: /search_file.sh <keyword> [optional directory]"
	exit 1
fi

# Assign positional parameters. If a second parameter is not provided, default to "." current directory
keyword=$1
directory=${2:-.}

# Search for the keyword using grep

grep -rl --include="*.sv" "$keyword" "$directory"
