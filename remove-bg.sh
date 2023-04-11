#!/bin/sh
#
# Convert an image file to a png file.
#
# * Put this file into your home binary dir: ~/thunar-actions/
# * Make it executable: chmod +x
#
#
# Required Software:
# -------------------------
#   * rembg (pip install rembg)
#
#
# Thunar Integration
# ------------------------
#
#   Command:      ~/thunar-actions/remove-bg.sh -f %f
#   File Pattern: *
#   Appear On:    Image Files
#
#
# Usage:
# -------------------------
#   remove-bg.sh -f <filename>
#
#     required:
#      -f    input filename


usage() {
	echo "$0 -f <filename>"
	echo
	echo " required:"
	echo "   -f    input filename"
	echo
}


while getopts ":f:" i; do
	case "${i}" in
		f)
			f=${OPTARG}
			;;
		*)
			echo "Error - unrecognized option $1" 1>&2;
			usage
			;;
	esac
done
shift $((OPTIND-1))

# Check if file is specified
if [ -z "${f}" ]; then
	echo "Error - no file specified" 1>&2;
	usage
	exit 1
fi

# Check if convert exists
if ! command -v rembg >/dev/null 2>&1 ; then
	echo "Error - 'rembg' not found." 1>&2
	exit 1
fi

$(which rembg) i "${f}" "${f}.rembg.png"
exit $?

