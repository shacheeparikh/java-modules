#!/bin/sh
#================================================================
# HEADER
#================================================================
#% DESCRIPTION
#%    This script will pull down any changes from a repo
#%    and progpogate the changes to children repositories.
#%
#% EXAMPLES
#%    ${SCRIPT_NAME} -o DEFAULT arg1 arg2
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} 0.0.1
#-    author          Keith Groves
#-    copyright       Copyright (c) The League of Amazing Programmers
#-    script_id       100001
#================================================================
#TODO change to relative path.
MODULES="/home/ec2-user/java-module-updater-DO_NOT_MOVE/java-modules"
destination="/home/ec2-user/java-module-updater-DO_NOT_MOVE/destination"
cd ${MODULES}
git pull https://github.com/League-central/java-modules.git
rsync -av --exclude='.git/' --delete "${MODULES}" "${destination}" 

cd "${destination}/java-modules"
#Save current directory so we can restore it later
cur=$PWD
#Save command line arguments so functions can access it
args=("$@")

#changes color
cecho(){
    RED="\033[0;31m"
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    # ... ADD MORE COLORS
    NC='\033[0m' # No Color

    printf "${!1}${2} ${NC}\n"
}
#function is executed in each sub directory
#To access command line arguments use syntax ${args[1]} etc
function dir_command {
    #This example command implements doing git status for folder
    cd $1
    if [ "${args[0]}" == "gitignore" ]
    then
    cecho "GREEN" "creating gitignore in $1"
    curl https://gitignore.io/api/java -o .gitignore
    fi
    pwd
    echo $1
    git status
    git add .
    cecho "GREEN" "commiting changes"
    git commit -m "update from league central"
    cecho "GREEN" "pushing changes"
    git push
    cd ..
}
echo "moving through directories"
#This loop will go to each immediate child and execute dir_command
find . -maxdepth 1 -type d \( ! -name . \) -name 'Level*' | while read dir; do
   dir_command "$dir/"
   
done

#Restore the folder
cd "$cur"
