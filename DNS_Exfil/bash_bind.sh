#!/bin/bash

# Check if two arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <start_hex> <end_hex>"
    exit 1
fi

# Assign arguments to variables
start_hex="$1"
end_hex="$2"

# Get the current date and time in YYYY-MM-DD_HH-MM-SS format
current_datetime=$(date +"%Y-%m-%d_%H-%M-%S")

# Define the output file name with the date and time
output_file="file_$current_datetime"

# Run the modified command with arguments
cat /var/named/log/queries | \
grep -oP "(?<=query: )[0-9A-Fa-f_-]+(?=\.)" | \
grep -iA 1000 "$start_hex" | \
grep -iB 1000 "$end_hex" | \
grep -iv "$start_hex" | \
grep -iv "$end_hex" | \
tr '[:upper:]' '[:lower:]' | \
uniq | \
tr -d '\n' | \
xxd -p -r > "$output_file"

echo "The output has been saved to '$output_file'."
