#!/bin/bash

# Function to rename files with inner ordering
rename_with_inner_order() {
  local level=$1
  local counter=1

  # Get all files with the current complexity level prefix, sort them alphabetically
  for file in $(ls ${level}_*.sql | sort); do
    # Extract the part of the filename after the complexity level prefix
    filename=${file#${level}_}

    # Create the new filename with inner ordering
    new_filename="${level}_${counter}_${filename}"

    # Rename the file
    mv "$file" "$new_filename"
    echo "Renamed: $file -> $new_filename"

    # Increment the counter
    ((counter++))
  done
}

# Process files for each complexity level
for level in {1..5}; do
  echo "Processing level $level files..."
  rename_with_inner_order $level
  echo ""
done

echo "All files have been renamed with inner ordering."
