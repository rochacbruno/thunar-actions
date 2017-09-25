#!/bin/bash
#
# Creates a new directory based on file selection.
#
# * Put this file into your home binary dir: ~/thunar-actions/
# * Make it executable: chmod +x
#
#
# Required Software:
# -------------------------
#   * zenity
#
#
# Thunar Integration
# ------------------------
#
#   Command:      ~/thunar-actions/new_directory_from_selection.sh %F
#   File Pattern: *
#   Appear On:    All files
#

# Define a function that launches the zenity input dialog
get_dir_name(){
    zenity --entry \
    --width=300 \
    --title="New directory from selection" \
    --text="Enter new dir name:"
}

# Ask user for directory name
foldername=$(get_dir_name) || exit

# Try to create a new directory
errorString=$( mkdir "$foldername" 2>&1 )

# If an error occurs, show dialog again
while [ -n "$errorString" ]; do
    zenity --error \
    --title="$( echo $errorString | cut -d: -f3- )" \
    --text="$( echo $errorString | cut -d: -f2- )" || exit

    # Ask user for directory name
    foldername=$(get_dir_name) || exit
    errorString=$( mkdir "$foldername" 2>&1 )
done

# Moving files to new directory
mv -t "${PWD}/${foldername}" "${@}"
