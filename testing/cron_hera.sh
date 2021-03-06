#!/bin/bash --login
# cron_hera.sh
# - check if JEDI repositories have been updated
#   if so:
#   - build
#   - ctest
#   if all tests pass:
#   - move to 'stable' directory

# define vars
JEDIENV=/scratch1/NCEPDEV/stmp4/Cory.R.Martin/hofxcs/src/hofx/cfg/platform/hera/JEDI
stable_dir=/scratch1/NCEPDEV/da/Cory.R.Martin/JEDI/stable/intel/
test_dir=/scratch1/NCEPDEV/da/Cory.R.Martin/JEDI/testing/intel/
script_dir=/scratch1/NCEPDEV/da/Cory.R.Martin/JEDI/utils/JEDI-T2O/testing/
PEOPLE="Cory.R.Martin@noaa.gov"
BUILD_BIN=/scratch1/NCEPDEV/stmp4/Cory.R.Martin/hofxcs/src/hofx/bin/buildJEDI.sh
BUNDLE_YAML=/scratch1/NCEPDEV/stmp4/Cory.R.Martin/hofxcs/src/hofx/cfg/hofxbundle.yaml
USER_YAML=$test_dir/develop_ci.yaml
BODY=$test_dir/msg.txt

# source JEDI environment
source $JEDIENV

# check to see if any repo has been updated
$script_dir/check_update.sh $stable_dir/build $test_dir/bundle $stable_dir/commits

if [[ $? == 0 ]]; then
  exit 0
fi

# get todays date
today=`date '+%Y%m%d'`

mkdir -p $test_dir

cat > $USER_YAML << EOF
user:
  build_dir: $test_dir/build-$today
  bundle_dir: $test_dir/bundle
  account: da-cpu
  clean_build: YES
  clean_bundle: NO
  update_jedi: YES
  test_jedi: YES
EOF

$BUILD_BIN $USER_YAML $BUNDLE_YAML

if [[ $? == 0 ]]; then
  # tests pass successfully
  # figure out path of old build to remove
  oldbuild=`readlink $stable_dir/build`
  # remove symlink to stable build
  unlink $stable_dir/build
  ln -s $test_dir/build-$today $stable_dir/build
  # remove old build
  rm -rf $oldbuild
  # prepare to send a success email, remove later?
  SUBJECT="SUCCESS of JEDI develop CI on Hera"
  now=`date`
  cat > $BODY << EOF
The develop branches of JEDI build on Hera and all tests pass successfully.
Tests completed at $now
Intel stable directory $stable_dir/build now points to $test_dir/build-$today
EOF
  # update the hashes for 'stable'
  rm -rf $stable_dir/commits
  $script_dir/get_hashes.sh $test_dir/bundle $stable_dir/commits
else
  # There is a problem...
  SUBJECT="FAILURE of JEDI develop CI on Hera"
  now=`date`
  cat > $BODY << EOF
The develop branches of JEDI did not either build successfully or tests failed.
Please check me at $test_dir/build-$today ASAP
Tests completed at $now
The following tests FAILED:
EOF
  cat $test_dir/build-$today/Testing/Temporary/LastTestsFailed.log >> $BODY
fi

mail -r "jedi.bot@noaa.gov" -s "$SUBJECT" "$PEOPLE" < $BODY
rm -rf $BODY
