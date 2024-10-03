#! /bin/sh

# This script is a bit bloated but the function is to clone an application and update a specific go module version and
# push it back to github.

# Define the filename
ver_lst="version.txt"
# curl cmd on line 6 url is just a dummy. Shld be replaced with an actual tag link url
# app_ver="$(curl -s https://github.com/J4yM1l/redis/tags |grep -Eo "$Version v[0-9]{1,2}.[0-9]{1,2}.[0-9]{1,2}"|sort -r|head -n1 | tr -d '[:space:]')"
latest_ver="v1.43.2"
echo "test $latest_ver"
srvcs=("srvc-1" "srvc-2" "srvc-3")
old_ver=""
repo="https://github.com/J4yM1l/redis@"
result=1
upgradeVersion(){
if [ -n "$latest_ver" ]; then
    # function to check for newer version
    checkVersion
    # When no new version is available
    if [ "$result" -eq 1 ]; then
        echo "No new version available with a return code of $result"
        # exit 1
    else
        # when there's a new app version to update.
        cwd="$(pwd)"
        # if versionUpdate dir does exist tell us
        if [ -d "$cwd/versionUpdate" ]; then
            echo "versionUpdate directory exist"
            # Always remove old directories before fresh run
            rm -rf "$cwd/versionUpdate"
        else
            # if versionUpdate directory does not exist create one.
            mkdir versionUpdate
        
        fi
        # iterate through all three services to update there app version
            for srvc in ${srvcs[@]}; do
                echo "====== Running app Upgrade for $srvc service ====="
                # check if service directory is present in the versionUpdate folder, if not create it.
                if [ -z "$(ls -A ${cwd}/versionUpdate/)" ]; then
                    echo "Directory is empty"
                    mkdir -p ${cwd}/versionUpdate/${srvc}
                else
                    # check if a service folder has already been created.
                    if [ -d "$cwd/versionUpdate/${srvc}" ]; then
                        echo "versionUpdate directory is not empty"
                        echo "${srvc} directory exist in versionUpdate folder"
                    else
                        # if a service folder has not been created then create one.
                        mkdir -p ${cwd}/versionUpdate/${srvc}
                    fi
                fi
                # check if a service repo has already been cloned
                if [ -z "$(ls -A ${cwd}/versionUpdate/${srvc}/)" ]; then
                    cd ${cwd}/versionUpdate/${srvc}/
                    if [ "$srvc" == "srvc-1" ]; then
                        git clone "https://github.com/J4yM1l/data-entry.git"
                        cd ${cwd}/versionUpdate/${srvc}/data-entry.git
                    elif [ "$srvc" == "srvc-2" ]; then
                        git clone "https://github.com/J4yM1l/data-entry.git"
                        cd ${cwd}/versionUpdate/${srvc}/data-entry.git
                    else
                        git clone "https://github.com/J4yM1l/data-entry.git"
                        cd ${cwd}/versionUpdate/${srvc}/data-entry.git
                    fi
                else
                # if a service repo has already been cloned tell me.
                    echo "${srvc} directory in versionUpdate dir is present"
                    if [ "$srvc" == "srvc-1" ]; then                       
                        cd ${cwd}/versionUpdate/${srvc}/srvc-1
                    elif [ "$srvc" == "srvc-2" ]; then                       
                        cd ${cwd}/versionUpdate/${srvc}/srvc-2
                    else                        
                        cd ${cwd}/versionUpdate/${srvc}/srvc-3
                    fi
                fi
               # function to run git operation
                branchOut
            done
            
            # cd to dir with go mod file
            # git switch -c app_latest_ver master
            # run go get -u githubURL@latest_ver
            # run go mod tidy
            # run git add
            # run git commit
            # run git push
            # branch name syntax app_latest_ver
            # rm -rf ${cwd}/versionUpdate/
            
    fi
    echo "version: $latest_ver"
else
    echo "Variable is Empty!"
fi
}

function checkVersion(){
# Define a local variable
local latest_ver_str
# remove all characters from version and just merge numbers
version=(`echo "$latest_ver" | grep -o '[^v.]'`)
# loop through the numbers and concat to a string.
for i in "${version[@]}"; do
  latest_ver_str+="$i"
done
# convert to integer
latest_ver_num=$((latest_ver_str))
# Read the file line by line
while IFS= read -r curr_ver; do
    echo "Current value of $curr_ver"
    # check for non empty read from file.
    if [ -n "$curr_ver" ]; then
    # Get the version from file and assign to another var: will be used later.
        old_ver="$curr_ver" 
        # if no change in version skip
        if [ "$curr_ver" == "$latest_ver" ]; then
            echo "No new app version available"       
            return
        else
        # if version are diferent, get the most recent.
        version=$(echo "$cv" | grep -o '[^v.]')
        curr_ver_lst=(`echo "$curr_ver" | grep -o '[^v.]'`)
        for i in "${curr_ver_lst[@]}"; do
            curr_ver_str+="$i"
        done
        curr_ver_num=$((curr_ver_str))
        echo "$curr_ver_num"
         # update latest version to file
        if [ $latest_ver_num -gt $curr_ver_num ]; then       
        echo "$latest_ver" > $ver_lst
        fi
        # echo ${version[0]}
        # array=( `echo "v1.43" | grep -o . ` )
        result=0
        return
        fi
    else
        echo "file is empty - adding version to file"
        echo "$latest_ver" > $ver_lst
        result=0
    fi
done < "$ver_lst"
echo "$latest_ver" > $ver_lst
result=0
echo "All lines have been processed."


}

branchOut(){
    old_branch=$(git rev-parse --abbrev-ref HEAD)
    remote_branch=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
    git checkout $(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
    echo "rem: $remote_branch"
    # git pull origin
    if [ $old_branch != 'master' ] && [ $old_branch != 'main' ]; then
        if [ $old_ver != $latest_ver ]; then
            git branch -D $old_branch
            echo "Deleted the branch name $old_branch"
            echo "git checkout the new branch"   
            git switch -c "app_${latest_ver}" "${remote_branch}"
            # git checkout -b "app_${latest_ver}"
        else
            #  git checkout -b $1              
            # git checkout $(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
            git switch "app_${old_ver}"
            echo "git checkout the old branch"                   
        fi
    else
        git switch -c "appa_${latest_ver}" "${remote_branch}"
    fi
    # git checkout -b $1
    # git switch -c "app_${latest_ver}" $remote_branch
    go get -u "${repo}${latest_ver}"
    # (`cd "data-entry/excel-data-entry"`)
    # pwd
    go mod tidy
    # git add . && git commit -m "app $latest_ver update"
    # && git push --force
    # git push --set-upstream origin "appa_${latest_ver}"
    echo "====== app Upgrade for $srvc service is completed ====="
    printf "End of upgrade for app Version: %s\n" "${latest_ver}"
    echo "=========================================================="
}

upgradeVersion