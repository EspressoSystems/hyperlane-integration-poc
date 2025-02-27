aws s3api create-bucket --bucket $VALIDATOR_BUCKET_NAME --region $AWS_DEFAULT_REGION
aws s3api put-public-access-block --bucket $VALIDATOR_BUCKET_NAME --public-access-block-configuration \
  "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
envsubst < aws/bucket-policy.json.template > aws/bucket-policy.json
aws s3api put-bucket-policy --bucket $VALIDATOR_BUCKET_NAME --policy file://./aws/bucket-policy.json

echo "Bucket created and configured."
