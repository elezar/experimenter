#!/bin/bash

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
		echo $file_list | grep $*
	else
		echo $file_list
	fi
}



# The following file extensions are blacklisted
blacklist="\S+\.(caffemodel|solverstate|npy)\b"

added_files=`get_file_list A`
added_blacklist_files=`get_file_list A -oE $blacklist`

modified_files=`get_file_list M`
modified_blacklist_files=`get_file_list M -oE "$blacklist"`

deleted_files=`get_file_list D`

# print_files "added" $added_files 
# print_files "added(blacklist)" $added_blacklist_files
# print_files "modified" $modified_files 
# print_files "modified(blacklist)" $modified_blacklist_files
# print_files "deleted" $deleted_files

if [ x"$added_blacklist_files" != x"" ]
then
	exec < /dev/tty
	echo "The following files were added, but are blacklisted:"
	echo $added_blacklist_files
	echo ""
	read -p "Should these be checked in in any case? y/[N]: " response
	response=${response:-N}

	if [ "${response}" != "y" ]
	then
		for f in $added_blacklist_files
		do
			echo "Removing $f from the list of file added (git reset $REF)"
			echo "$PWD"
			echo "git reset HEAD $f"
			git reset HEAD $f
			git status
		done

		remaining_files=`get_file_list ALL`
		if [ x"$remaining_files" == x"" ]
		then
			echo "Nothing to commit."
			exit 1
		fi
	fi

fi
