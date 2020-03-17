#!/bin/bash
#
# Resize images to given dimensions.
#
# * Put this file into some dir ex: ~/thunar-actions/
# * Make it executable: chmod +x
#
#
# Required Software:
# -------------------------
#   * convert
#
#
# Thunar Integration
# ------------------------
#
#   Command:      ~/thunar-actions/image_resizer.sh %F
#   File Pattern: *
#   Appear On:    Image Files
#
#
# Usage:
# -------------------------
#   convert-to-jpg.sh -f <filename>
#
#     required:
#      -f    input filename
#

guitool=zenity

exit_me(){
    rm -rf ${tempdir}
    exit 1
}

trap "exit_me 0" 0 1 2 5 15

LOCKFILE="/tmp/.${USER}-$(basename $0).lock"
[[ -r $LOCKFILE ]] && PROCESS=$(cat $LOCKFILE) || PROCESS=" "

if (ps -p $PROCESS) >/dev/null 2>&1
then
    echo "E: $(basename $0) is already running"
    $guitool --error --text="$(basename $0) is already running"
    exit 1
else
    rm -f $LOCKFILE
    echo $$ > $LOCKFILE
fi

# Dialog box to choose thumb's size
SIZE="$( $guitool --list --height=300 --title="Choose the thumbnail's size" --text="Select the resolution for the images to convert" --radiolist --column=$"Check" --column=$"Size" "" "Auto (for photos)" "" "Same" "" "20x15" "" "40x30" "" "80x60" "" "160x120" "" "250x250" "" "320x240" "" "640x480" "" "800x600" "" "1024x768" "" "2048x1080" "" "4096x2160" "" "7680x4320" "" "28x28" "" "56x56" "" "112x112" || echo cancel )"
[[ "$SIZE" = "cancel" ]] && exit
if [[ "$SIZE" = "" ]]; then
    $guitool --error --text="Size not defined by user. Please choose a size to use. "
    exit 1
fi

QUALITY="$( $guitool --entry --entry-text="85" --title="Quality" --text="Choose the quality value (85 for photos, 90 for screenshots)" || echo cancel )"

[[ "$QUALITY" = "cancel" ]] && exit
[[ -z "$QUALITY" ]] && QUALITY=85



# precache
PROGRESS=0
NUMBER_OF_FILES="$#"
let "INCREMENT=100/$NUMBER_OF_FILES"

( for i in "$@"
do
    echo "$PROGRESS"
    file="$i"

    # precache
    dd if="$file" of=/dev/null 2>/dev/null

    # increment progress
    let "PROGRESS+=$INCREMENT"
done
) | $guitool  --progress --title "Precaching..." --percentage=0 --auto-close --auto-kill


# Creating thumbnails. Specific work on picture should be add there as convert's option

# How many files to make the progress bar
PROGRESS=0
NUMBER_OF_FILES="$#"
let "INCREMENT=100/$NUMBER_OF_FILES"

mkdir -p "_resized"

( for i in "$@"
   do
       echo "$PROGRESS"
       file="$i"
       filename="${file##*/}"
       ext="${filename##*.}"
       filenameraw="${filename%.*}"
       echo -e "# Converting: \t ${filename}"

       if [[ "$SIZE" = "Same" ]] ; then
	   convert -quality $QUALITY "${file}" "_resized/${filename%\.*}_${SIZE}.${ext}"
       else
	   if [[ "$SIZE" = "Auto (for photos)" ]] ; then
	       size_horiz="$( identify "$file" | tr ' ' '\n' | grep -E "[[:digit:]]+x[[:digit:]]+" | head -1 | sed -e 's|x.*$||g' )"
	       if [[ "$size_horiz" -lt 2400 ]] ; then
		   # no need to resize images smaller than 2400
		   convert -quality $QUALITY "${file}" "_resized/${filename%\.*}_${SIZE}.${ext}"
	       else
		   # 2 / 3 of the original size
		   size_horiz_resized="$( echo "( $size_horiz / 3 ) * 2" | bc -l | sed -e 's|\.*$||g' )"
		   convert -resize ${size_horiz_resized}x${size_horiz_resized} -quality $QUALITY "${file}" "_resized/${filename%\.*}_${SIZE}.${ext}"
	       fi
	   else
	       convert -resize $SIZE -quality $QUALITY "${file}" "_resized/${filename%\.*}_${SIZE}.${ext}"
	   fi
       fi


       let "PROGRESS+=$INCREMENT"
   done
   ) | $guitool  --progress --title "Creating thumbnails..." --percentage=0 --auto-close --auto-kill

$guitool --info --text="Finished, you can found them in the directory '_resized'"


## THUNAR IMAGE RESIZER
## command: /path/to/image_resizer %F
## set appearance conditions to 'image files'

## TODO: make it possible to select 'square' in dialog
# mkdir -p ./Resized/$1
# for file
#     do
#     if [ ! -e $file ]
#         then
#         continue
#     fi
#     toname="./Resized/"$1"/"$( echo $file | cut -f1 -d.)"_"$1".jpg"
#     convert -geometry $1x$1 -quality 90 "${file}" "${toname}"
# done
