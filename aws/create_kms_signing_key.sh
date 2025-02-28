# Instantiate the policy
envsubst < aws/key_policy.json.template > aws/key_policy.json

# Create the KEY
aws kms create-key \
    --description "" \
    --key-usage SIGN_VERIFY \
    --key-spec ECC_SECG_P256K1 \
    --region $AWS_DEFAULT_REGION \
    --output json \
    --policy file://./aws/key_policy.json > /tmp/key_result.json

export KEY_ID=`jq -r ".KeyMetadata.KeyId" /tmp/key_result.json`

# Add the alias to the key
aws kms create-alias \
--alias-name alias/$VALIDATOR_KEY_ALIAS \
--target-key-id $KEY_ID \
--region $AWS_DEFAULT_REGION

echo "Key created correctly."
cat /tmp/key_result.json


