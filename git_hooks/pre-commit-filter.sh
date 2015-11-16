#!/bin/bash

# A script to filter a set of files from a git commit. The filter is applied
# only to new files (although this can be exetended to others states).
#
# If files that match the filter are added to the git index, the user is
# prompted whether these files should really be added to the git repository.
# If this is not required, then these files are unstaged.

# The following REGEXP is used to filter the file names.
filter_regexp="\S+\.(caffemodel|solverstate|npy|caffetrace\S*)\b"

# Determing whether the HEAD is a valid reference.
if git rev-parse --verify HEAD >/dev/null 2>&1
then
	REF=HEAD
else
	# Initial commit: diff against an empty tree object
	REF=`git hash-object -t tree /dev/null`
fi

# Usage: print_files desc [file_list,]
# Prints some debug information for a list of files.
function print_files {
	local desc=$1
	shift
	local files=$*
	echo ""
	if [ x"$files" != x"" ]
	then
		echo "Files $desc in this commit"
		echo $files
	else
		echo "No files $desc in this commit"
	fi
	echo ""
}


# Usage: get_file_list MODE [grep options]
# Get a list of files of a particular mode in
function get_file_list {
	local filter=$1
	if [ "$filter" == "ALL" ]
	then
		filter=""
	else
		filter="--diff-filter=$filter"
	fi
	shift
	local file_list=`git diff-index --cached --name-only $filter $REF`
	if [ $# -gt 0 ]
	then
		echo $file_list | grep -oE $*
	else
		echo $file_list
	fi
}


# Get the list of files.
added_files=`get_file_list A`
added_blacklist_files=`get_file_list A $filter_regexp`

modified_files=`get_file_list M`
modified_blacklist_files=`get_file_list M $filter_regexp`

deleted_files=`get_file_list D`

# print_files "added" $added_files
# print_files "added(blacklist)" $added_blacklist_files
# print_files "modified" $modified_files
# print_files "modified(blacklist)" $modified_blacklist_files
# print_files "deleted" $deleted_files

if [ x"$added_blacklist_files" != x"" ]
then
	old_stdin=$stdin
	echo ""
	echo "The following files were added, but are marked to be filtered out:"
	echo "	"$added_blacklist_files
	echo ""
	{
		read -p "Should these be checked in in any case? y/[N]: " response
	} < /dev/tty
	response=${response:-N}

	if [ "${response}" != "y" ]
	then
		for f in $added_blacklist_files
		do
			echo ""
			echo "Unstaging $f (git reset $REF)"
			git reset $REF $f
		done
		echo ""

		remaining_files=`get_file_list ALL`
		if [ x"$remaining_files" == x"" ]
		then
			echo "Nothing to commit."
			# Exit with a non-zero exit code to ensure that the commit is
			# aborted.
			exit 1
		fi
	fi

fi
