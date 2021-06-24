#!/bin/bash
# check_update.sh
# check to see if JEDI repos have been updated
# returns exit 0 if no need to compile/test
# returns exit 3 if one should compile/test
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 /path/to/build /path/to/bundle /path/to/hashfile" >&2
  exit 1
fi

MYPATH=`readlink -f "$0"`
MYDIR=`dirname "$MYPATH"`
build_dir=$1
bundle_dir=$2
commits=$3

# run make update on build to update bundle
cd $build_dir
make update

# check hashes of bundle
for repo in `ls $bundle_dir`; do
  if [[ -d $bundle_dir/$repo ]] ; then
     cd $bundle_dir/$repo
     commit=`git rev-parse HEAD`
     echo "$repo: $commit" >> ${commits}.tmp
  fi
done

# compare hashes
diff $commits ${commits}.tmp

if [[ $? == 0 ]]; then
   # no need to recompile/test
   rm -rf ${commits}.tmp
   exit 0
elif [[ $? == 1 ]]; then
   # return with 'error' to compile/test
   rm -rf ${commits}.tmp
   exit 3
fi
