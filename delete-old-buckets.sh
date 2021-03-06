#!/bin/bash
set -e

MAX_BUCKETS=2
OLD_BUCKETS=$(aws s3 ls \
          | grep bryce-fisher-fleig-org- \
          | sort \
          | head -n -$MAX_BUCKETS \
          | awk '{ print $3 }')

for BUCKET in $OLD_BUCKETS
do
  echo "Deleting s3 bucket $BUCKET"
  aws s3 rb s3://$BUCKET --force > /dev/null
done
echo "Done deleting buckets"
