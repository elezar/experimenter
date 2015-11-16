#!/bin/bash

# This commit hook copies files (excluding the .git folder) from the repository
# to the data folder specified in README.md. If README.md does not exist in the
# root of the repository, the script does not do anything.

README_FILENAME='README.md'


function copy_data {
	local SRC=$1
	local DEST=$2

	if [ $SRC == $DEST ]
	then
		return 0
	fi

	if [ ! -d $DEST ]
	then
		mkdir -p $DEST
	else
		echo ""
		echo "Destination folder exists:"
		echo "    $DEST"
		echo ""
		echo "Files may be overwritten."
		echo ""
		{
			read -p "Continue with copy [Y]/n: " response
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
		rsync -avz --exclude='.git/' $SRC/ $DEST/
		echo ""

		# Add a log file
		copy_log_file=$DEST/_experiment.copy.log
		echo "Automatically synced with $SRC at $(date)" >> $copy_log_file
		echo "Commit: $(git log -n 1 --pretty=format:"%H")" >> $copy_log_file
	fi

}


# Determine whether this is a valid git repository.
if git rev-parse --verify HEAD >/dev/null 2>&1
then
	:
else
	# This is an empty repository.
	exit 0
fi


# Get the root directory if the repository.
REPO_ROOT=$(git rev-parse --show-toplevel)

README_FILE=$REPO_ROOT/$README_FILENAME

if [ ! -f $README_FILE ]
then
	echo ""
	echo "The file $README_FILE could not be found"
	echo "Unable to determine DATA_ROOT"
	echo ""
	exit 0
fi

# Process the README.md file to determine where the files should be copied.
experiment_tag_line=`head -7 $README_FILE | grep -oE "EXPERIMENT_TAG=\S+"`
data_root_line=`head -7 $README_FILE | grep -oE "DATA_ROOT=\S+"`

EXPERIMENT_TAG=${experiment_tag_line/*=/}
DATA_ROOT=${data_root_line/*=/}

# Append the experiment tag to the data root.
DEST_DIR=$DATA_ROOT/$EXPERIMENT_TAG

# Copy the data.
copy_data $REPO_ROOT $DEST_DIR
