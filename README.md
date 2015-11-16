# Experimenter

A script to setup and experiment folder under Git source control, and link to
an additional data folder.

The purpose of this is to make it harder (but not impossible) for certain
larger filetypes from being checked into version control. This is achieved in
two ways. The first is to add the file extensions to the ```.gitignore``` file,
and the second is to monitor git commits for these files and provide additional
prompting of the user if these are added.

Since certain files are not added to version control, the repository is also
synced to a data folder for archival.

# Installation

1. Clone the repository: ```git clone https://github.com/elezar/experimenter.git```
2. Add the cloned folder to the $PATH (or use ```exp_init```
   with its location specified explicitly)

# Usage

Assuming that the project folder has been added to the path, the basic usage of
the utility is as follows:

	exp_init [folder]

where ```folder``` is an optional path specification.

The utility will perform the following steps:

1. Initialise a Git repository at ```folder```
2. Add a ```README.md``` file to the repository with a metadata header
3. Add a ```.gitignore``` file to the repository
4. Add a ```src``` folder to the repository
5. Install a pre-commit and post-commit by linking to the shell scripts in the ```git_hooks``` folder
6. Perform an initial commits

If ```folder``` is not specified, a folder name is automatically generated. The
folder name also serves as the experiment tag.

# Data Archiving

When creating the repository, the ```DATA_ROOT``` environment variable is
written to the ```README.md``` file. If this environment variable is not
defined, then no archiving will be performed. The ```README.md``` can also be
edited at a later stage to set a specific archival path.

The value of ```DATA_ROOT``` specified in the ```README.md``` file is used
together with the ```EXPERIMENT_TAG``` to construct a destination  as
```${DATA_ROOT}/${EXPERIMENT_TAG}``` for archiving the repository.

A Git post-commit hook is used to copy (using ```rsync```) all files in a repository (excluding the
```.git``` folder) to the archive destination. Here the user is prompted when
the destination folder exists, as file contents are currently for the purpose
of comparison.
