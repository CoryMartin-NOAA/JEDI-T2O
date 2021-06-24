#!/bin/bash
PEOPLE="Cory.R.Martin@noaa.gov"
CI_ROOT=/scratch2/NCEPDEV/stmp1/Cory.R.Martin/JEDI_CI/
BUILD_BIN=/scratch1/NCEPDEV/stmp4/Cory.R.Martin/hofxcs/src/hofx/bin/buildJEDI.sh
BUNDLE_YAML=/scratch1/NCEPDEV/stmp4/Cory.R.Martin/hofxcs/src/hofx/cfg/hofxbundle.yaml
USER_YAML=$CI_ROOT/develop_ci.yaml
BODY=$CI_ROOT/msg.txt

mkdir -p $CI_ROOT

cat > $USER_YAML << EOF
user:
  build_dir: $CI_ROOT/build
  bundle_dir: $CI_ROOT/bundle
  account: da-cpu
  clean_build: YES
  clean_bundle: NO
  update_jedi: YES
  test_jedi: NO 
EOF

$BUILD_BIN $USER_YAML $BUNDLE_YAML
if [ $? -eq 0 ]
then
# Build and CTests look good
SUBJECT="SUCCESS of JEDI develop CI on Hera"
now=`date`
cat > $BODY << EOF
The develop branches of JEDI build on Hera and all tests pass successfully.
Tests completed at $now
EOF
else
# There is a problem...
SUBJECT="FAILURE of JEDI develop CI on Hera"
now=`date`
cat > $BODY << EOF
The develop branches of JEDI did not either build successfully or tests failed.
Please check me at $CI_ROOT/build ASAP
Tests completed at $now
The following tests FAILED:
EOF
cat $CI_ROOT/build/Testing/Temporary/LastTestsFailed.log >> $BODY
fi

mail -r "jedi.bot@noaa.gov" -s "$SUBJECT" "$PEOPLE" < $BODY
rm -rf $BODY
