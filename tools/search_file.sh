#!/bin/bash
# Copyright 2025 Felix Tse
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#

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
