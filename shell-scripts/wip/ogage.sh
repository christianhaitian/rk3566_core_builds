#!/bin/bash

# Script used to quickly modify and build various branches of the ogage keydaemon
# rust program used in ArkOS.
# Usage:
# To modify builds - Update the cur_string and new_string variables with current string that should be matched and new string respectively.
# Then do ogage.sh build.  New builds will be placed in ogage-temp/ogage-batch directory.
# To commit changes and push them to the repo - Do ogage.sh commit "Commit message".  "Commit message" is options and if
# not included, commit message will default to "Update"

cur_wd="$PWD"
# Branches of ogage to be pulled and worked with
branches=( "master" "gameforce-chi" "rg351mp" "rg351v" "rgb10max" "rk2020" )
# Current cur_string variable to be sed matched for possible replacement with new_string
cur_string="for s in \["
# Update new_string variable for what existing cur_string matched should be replaced with
new_string="for s in [\"\/dev\/input\/event10\", \"\/dev\/input\/event9\", \"\/dev\/input\/event8\", \"\/dev\/input\/event7\", \"\/dev\/input\/event6\", \"\/dev\/input\/event5\", \"\/dev\/input\/event4\", \"\/dev\/input\/event3\", \"\/dev\/input\/event2\", \"\/dev\/input\/event1\", \"\/dev\/input\/event0\"].iter() {"

if [ ! -d "ogage-temp/" ]; then
  mkdir ogage-temp
fi

if [[ "$1" == "commit" ]]; then

for branch in "${branches[@]}"
do
  cd "$cur_wd/ogage-temp"
  if [ -d "ogage-$branch/" ]; then
    cd ogage-$branch
    git add src/main.rs
    if [ ! -z "$2" ]; then
      git commit -m "$2"
    else
      git commit -m "Update"
    fi
    pushit.sh
  fi
done

elif [[ "$1" == "build" ]]; then

for branch in "${branches[@]}"
do
  cd "$cur_wd/ogage-temp"
  if [ ! -d "ogage-$branch/" ]; then
    git clone --recursive https://github.com/christianhaitian/ogage.git -b $branch ogage-$branch
    if [[ $? != "0" ]]; then
      echo ""
      echo "There was an error while cloning the $branch branch of the ogage git.  Is Internet active or did the git location change?  Stopping here."
      echo ""
      exit 1
    fi
    cd ogage-$branch
    sed -i "/$cur_string/c\\$new_string" src/main.rs
    cargo build --release
    strip target/release/ogage
    if [ ! -d "../ogage-batch/" ]; then
      mkdir ../ogage-batch
    fi
    if [[ $branch == "master" ]]; then
      cp target/release/ogage ../ogage-batch/ogage-rgb10
    else
      cp target/release/ogage ../ogage-batch/ogage-$branch
    fi
  fi
done

else
echo ""
echo "What do you want me to do? commit or build."
echo ""
fi
