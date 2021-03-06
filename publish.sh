#!/bin/sh
set -eu

#######################################################
# Requirements:
# - valid AWS credentials with permissions for
#   - S3: object PUT, bucket LIST, bucket create, bucket delete
#   - CloudFront: create invalidation
# - the aws cli (http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
#
# Usage:
#
#   TRAVIS_BRANCH='branch-in-git' ./publish.sh
#
# Publish to production:
#
#   TRAVIS_BRANCH='master' ./publish.sh
#######################################################

DEST_BUCKET="bryce-fisher-fleig-org-$TRAVIS_BRANCH"
DEST_URL="http://$DEST_BUCKET.s3-website-us-west-1.amazonaws.com/"

if [ "$TRAVIS_BRANCH" = "master" ]; then
  echo "****Publishing changes to production blog******"
  DEST_BUCKET="bryce-fisher-fleig-org"
  DEST_URL="https://bryce.fisher-fleig.org"
fi

echo "Creating bucket $DEST_BUCKET"
aws s3 mb s3://$DEST_BUCKET --region us-west-1 2> /dev/null \
  || echo "Bucket already exists!"

echo "Publishing files from ./_site/ to S3 Bucket $DEST_BUCKET"
aws s3 website s3://$DEST_BUCKET --index-document "index.html"
aws s3 sync \
    --delete \
    --acl public-read \
    --storage-class REDUCED_REDUNDANCY \
    _site/ "s3://$DEST_BUCKET"

if [ "$TRAVIS_BRANCH" = "master" ]; then
  echo 'Creating invalidation for production cloudfront'
  aws configure set preview.cloudfront true
  aws cloudfront create-invalidation --distribution-id EG9J3WOGWV9T2 --paths '/*'
fi

echo "Finished publishing to $DEST_BUCKET. See results at:"
echo $DEST_URL
