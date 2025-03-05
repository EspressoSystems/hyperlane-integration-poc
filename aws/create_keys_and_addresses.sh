export VALIDATOR_KEY_ALIAS="$AWS_USER_NAME-signer"

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

echo "KMS signing key created correctly. \n\n"
cat /tmp/key_result.json

export AWS_KMS_KEY_ID=alias/$VALIDATOR_KEY_ALIAS
export VALIDATOR_ADDRESS=`cast wallet address --aws`

# TODO maybe change at some point
export RELAYER_ADDRESS=$VALIDATOR_ADDRESS

echo "Validator address: $VALIDATOR_ADDRESS"
echo "Relayer address: $RELAYER_ADDRESS"

