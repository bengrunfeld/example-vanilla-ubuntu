#!/bin/sh -e

# check usage
if [ -z $1 ] ; then
  port=8000
else
  port=$1
fi

# change into public directory
cd public

# server up the directory on the specified application port
python -m SimpleHTTPServer $port

