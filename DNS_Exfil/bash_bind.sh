#!/bin/bash

# Check if two arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <start_hex> <end_hex>"
    exit 1
fi

# Assign arguments to variables
start_hex="$1"
end_hex="$2"

# Get the current date in YYYY-MM-DD format (you can customize this as needed)
current_date=$(date +"%Y-%m-%d")

# Define the output file name with the date
output_file="file_$current_date"

# Run the modified command with arguments
cat /var/named/log/queries | \
grep -oP "(?<=query: )[0-9A-Fa-f]+(?=\.)" | \
grep -iA 1000 "$start_hex" | \
grep -iB 1000 "$end_hex" | \
tr '[:upper:]' '[:lower:]' | \
uniq | \
tr -d '\n' | \
xxd -p -r > "$output_file"

echo "The output has been saved to '$output_file'."
