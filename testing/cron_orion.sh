#!/bin/bash
# cron_orion.sh
# - check if JEDI repositories have been updated
#   if so:
#   - build
#   - ctest
#   if all tests pass:
#   - move to 'stable' directory

# define vars
JEDIENV=/work/noaa/stmp/Cory.R.Martin/jedi/hofxcs/src/hofx/cfg/platform/orion/JEDI
stable_dir=/work/noaa/da/cmartin/JEDI/stable/intel/
test_dir=/work/noaa/da/cmartin//JEDI/testing/intel/
script_dir=/work/noaa/da/Cory.R.Martin/noscrub/JEDI/utils/JEDI-T2O/testing/
PEOPLE="Cory.R.Martin@noaa.gov"
BUILD_BIN=/work/noaa/stmp/Cory.R.Martin/jedi/hofxcs/src/hofx/bin/buildJEDI.sh
BUNDLE_YAML=/work/noaa/stmp/Cory.R.Martin/jedi/hofxcs/src/hofx/cfg/hofxbundle.yaml
USER_YAML=$test_dir/develop_ci.yaml

# source JEDI environment
source ~/.bash_profile
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

# orion does not seem to do email msg

if [[ $? == 0 ]]; then
  # tests pass successfully
  # remove symlink to stable build
  unlink $stable_dir/build
  ln -s $test_dir/build-$today $stable_dir/build
  # update the hashes for 'stable'
  rm -rf $stable_dir/commits
  $script_dir/get_hashes.sh $test_dir/bundle $stable_dir/commits
fi
