#!/bin/bash
# get_hashes.sh
# for an input bundle directory $1
# cat to a file $2 a list of hashes
# for the current commit of each repo
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 /path/to/bundle /path/to/outfile" >&2
  exit 1
fi

bundle_dir=$1
outfile=$2

for repo in `ls $bundle_dir`; do
  if [[ -d $bundle_dir/$repo ]] ; then
     cd $bundle_dir/$repo
     commit=`git rev-parse HEAD`
     echo "$repo: $commit" >> $outfile
  fi
done
