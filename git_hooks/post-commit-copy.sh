#!/bin/bash

# DUMMY Script

echo ""
echo "##########################"
echo "Executing post-commit copy"
echo "Parameters: " $*
echo "##########################"
echo ""


function copy_data {
	local SRC=$1
	local DEST=$2

	if [ ! -d $DEST ]
	then
		mkdir -p $DEST
	else
		echo ""
		echo "Destination folder exists:"
		echo "    $DEST"
		echo ""
		{
			read -p "Continue with copy [Y/n]: " response
		} < /dev/tty
		response=${response:-Y}
		if [ ${response:-Y} != "Y" ]
		then
			perform_copy="N"
		fi
		echo ""
	fi

	if [ ${perform_copy:-Y} == "Y" ]
	then
		echo "Syncing data from '$SRC' to '$DEST':"
		rsync -avz --delete --exclude='.git/' $SRC/ $DEST/
		echo ""
	fi

}


# Get the repo root.
REPO_ROOT=$(git rev-parse --show-toplevel)

README_FILE=$REPO_ROOT/README.md

experiment_tag_line=`head -7 $README_FILE | grep -oE "EXPERIMENT_TAG=\S+"`
data_root_line=`head -7 $README_FILE | grep -oE "DATA_ROOT=\S+"`

EXPERIMENT_TAG=${experiment_tag_line/*=/}
DATA_ROOT=${data_root_line/*=/}

DEST_DIR=$DATA_ROOT/$EXPERIMENT_TAG

copy_data $REPO_ROOT $DEST_DIR

