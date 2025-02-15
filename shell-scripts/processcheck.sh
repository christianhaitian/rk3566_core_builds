#!/bin/bash

if [ ! -z $(pgrep kodi-gbm) ]; then
  printf "Running"
elif [ ! -z $(pgrep ffplay) ]; then
  printf "Running"
else
  printf "Nothing"
fi
