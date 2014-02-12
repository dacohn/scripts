#!/usr/bin/env bash

dayone=`which dayone`
file=$1
newentry=.new-day-one-entry.txt;
gitdir=$(git rev-parse --git-dir)

# Make sure dayone is in our PATH
if [[ ! -x ${dayone} ]];
then
		echo "Please put dayone into your PATH"
		exit
fi

# Make sure we have a file name to add to a Day One entry
if [ $# -ne 1 ];
then
		echo "Usage: $1 <file name>"
		exit
fi

# Make sure we are currently inside of a git repo
if [ -z ${gitdir} ];
then
		echo "Not inside of a git repo!"
		exit
fi

# Figure out the base name of the folder containing the git repo
if [ "${gitdir}" == ".git" ];
then
		repo=`basename $PWD`
else
		repo=`basename ${gitdir}`
fi

# Figure out the branch name
branch=`git branch | grep \* | awk '{ print $2 }'`

# Make sure the file containing the Day One log exists and is readable
# Then add the entry
if [ -e "${file}" -a -r "${file}" ];
then
		echo -e "New git commit to ${repo}(${branch})\n\n" > ${newentry}
		cat ${file} | grep -v ^\# >> ${newentry}
		${dayone} new < ${newentry} > /dev/null
		echo "Added commit message to Day One!"
		rm ${newentry}
else
		echo "Could not read file '${file}'"
		exit;
fi

