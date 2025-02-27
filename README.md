# Hyperlane integration proof-of-concept

Example of an integration of hyperlane with Espresso.

# Development environment

Everytime you open a terminal run

```bash
> ./launch_shell
```

# AWS configuration

The validator and the relayer use AWS services.

## KMS

### Create IAM user

*TODO:* Automate with Terraform

Reference: https://docs.hyperlane.xyz/docs/operate/set-up-agent-keys#2-aws-kms

1. Go to [aws.amazon.com](aws.amazon.com) and login.
2. Go to AWS's Identity and Access Management (IAM)
3. On the left, under "Access management", click "Users".
4. Click the orange button "Add users".
5. Pick a friendly and informative username, like *hyperlane1*. 
6. Select "Attach policies directly".
7. Pick `kms_creation` and `AWSKeyManagementServicePowerUser`. Then click on the corresponding checkbox.
8. Click on "Next"
9. Click on "Create user"
10. Click on the user you created.
11. Click on "Security credentials"
8. Scroll down to "Access Keys" and click on "Create Access Key"
9. Select "Application running outside AWS" and click "Next"
10. Click "Next", no need to add a description tag
11. Click "Create access key"
12. Copy the "Access key ID" and "Secret access key" to a safe place.
13. Go to the IAM home and copy the Account ID (see panel "AWS Account" at the top right)
14. Identify your AWS region: Check at the beginning of the url e.g.: https://us-east-1.console.aws.amazon means your region is us-east-1.
    
Set the following environment variables:

```bash
export AWS_USER_NAME=<Copy the name chosen in step 5>
export AWS_ACCESS_KEY_ID=<Access key ID obtained in step 12>
export AWS_SECRET_ACCESS_KEY=<Access secret key obyained in step 12>
export AWS_ACCOUNT_ID=<Copy the account id obtained in step 13>
export AWS_DEFAULT_REGION=<See step 14>
```

### Create KMS key

Pick some alias for the key, define the AWS region name
```bash
export VALIDATOR_KEY_ALIAS=<validator signer key alias>
```

Create the signing key using aws cli:
```bash
> ./aws/create_kms_signing_key.sh
 Signing key created correctly
 {
    "KeyMetadata": {
        "AWSAccountId": "861012453243",
        "KeyId": "b661293a-6ead-452b-86e2-401c1d841e4e",
        "Arn": "arn:aws:kms:us-east-1:861012453243:key/b661293a-6ead-452b-86e2-401c1d841e4e",
        "CreationDate": "2025-02-26T14:42:10.458000-03:00",
        "Enabled": true,
        "Description": "",
        "KeyUsage": "SIGN_VERIFY",
        "KeyState": "Enabled",
        "Origin": "AWS_KMS",
        "KeyManager": "CUSTOMER",
        "CustomerMasterKeySpec": "ECC_SECG_P256K1",
        "KeySpec": "ECC_SECG_P256K1",
        "SigningAlgorithms": [
            "ECDSA_SHA_256"
        ],
        "MultiRegion": false
    }
}
```

Update some environment variables

```bash
export AWS_KMS_KEY_ID=alias/$VALIDATOR_KEY_ALIAS
export VALIDATOR_ADDRESS=`cast wallet address --aws`
```

Note that this script also generates the validator address and put it in the environment variable `VALIDATOR_ADDRESS`.

### Generate the S3 bucket

*TODO:* Automate with Terraform

Reference: https://docs.hyperlane.xyz/docs/operate/validators/validator-signatures-aws
Your Validator will post their signatures to this bucket.

1. Go to AWS's S3 in the AWS console.
2. On the right, click the orange "Create Bucket" button
3. Pick an informative bucket name.
4. Consider choosing the same region as the KMS key you created in the previous step.
5. Keep the recommended "ACLs disabled" setting for object ownership.
6. Configure public access settings so that the relayer can read your signatures
   1. Uncheck "Block all public access"
   2. Check the first two options that block access via access control lists
   3. Leave the last two options unchecked, we will be granting public read access via a bucket policy
   4. Acknowledge that these settings may result in public access to your bucket
1. The remaining default settings are fine, click the orange "Create bucket" button on the bottom

### Configure S3 bucket permissions

1. Navigate back to "Identity and Access Management (IAM)" in the AWS console
1. Under "IAM resources" you should see at least one "User", click into that
1. Click on the name of the user that you provisioned earlier (e.g. hyperlane-validator-${chain_name})
1. Copy the "User ARN" to your clipboard, it should look something like arn:aws:iam::791444913613:user/hyperlane-validator-${chain_name}
1. Navigate back to "S3" in the AWS console
1. Click on the name of the bucket you just created
1. Just under the name of the bucket, click "Permissions"
1. Scroll down to "Bucket policy" and click "Edit"
1. Enter the following contents. The Bucket ARN is shown just above where you enter the policy
   
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": ["${BUCKET_ARN}", "${BUCKET_ARN}/*"]
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${USER_ARN}"
      },
      "Action": ["s3:DeleteObject", "s3:PutObject"],
      "Resource": "${BUCKET_ARN}/*"
    }
  ]
}
```
1. Click "Save changes"


Update the environment variables that will be later used to generate some configuration files:
```bash
export VALIDATOR_BUCKET_NAME=<bucket name picked in step 3>
export CHAIN_NAME="source"
```


# Initialize the chains with the Hyperlane contracts
(Reference: https://docs.hyperlane.xyz/docs/guides/local-testnet-setup)

First delete the filesystem registry in case you already deployed some Hyperlane contracts locally:
```bash
rm -Rf ~/.hyperlane/*
```

Open new terminal and launch the source chain:
```bash
./launch_source_chain
```

Open new terminal and launch the destination chain:
```bash
./launch_destination_chain
```

Open a new terminal.
Note that the  `HYP_KEY` environment variable is set in the hookShell of nix to the first private key generated by Anvil.
This key will be use to deploy the Hyperlane contracts.

*TODO:* automate answering to the questions.

Register the chains before Hyperlane can deploy its contracts.

First the source chain:
```bash
> hyperlane registry init

? Detected rpc url as http://localhost:8545 from JSON RPC provider, is this
correct? [PUSH ENTER]
? Enter chain name (one word, lower case) source
? Enter chain display name (Source) [PUSH ENTER]
? Detected chain id as 31337 from JSON RPC provider, is this correct? (Y/n) [PUSH ENTER]
? Is this chain a testnet (a chain used for testing & development)? (Y/n) [PUSH ENTER]
? Select the chain technical stack (Use arrow keys) [PUSH ENTER]
? Detected starting block number for indexing as 30 from JSON RPC provider, is
this correct? (Y/n) [PUSH ENTER]
? Do you want to add a block explorer config for this chain (y/N) [PUSH ENTER]
? Do you want to set block or gas properties for this chain config (y/N) [PUSH ENTER]
? Do you want to set native token properties for this chain config (defaults to 
ETH) (y/N) [PUSH ENTER]
```

Then the destination chain:
```bash
> hyperlane registry init
? Detected rpc url as http://localhost:8545 from JSON RPC provider, is this
correct? n
? Enter http or https rpc url: (http://localhost:8545) http://localhost:8546
? Enter chain name (one word, lower case) destination
? Enter chain display name (Destination) [PUSH ENTER]
? Detected chain id as 31337 from JSON RPC provider, is this correct? (Y/n) [PUSH ENTER]
? Is this chain a testnet (a chain used for testing & development)? (Y/n) [PUSH ENTER]
? Select the chain technical stack (Use arrow keys) [PUSH ENTER]
? Detected starting block number for indexing as 30 from JSON RPC provider, is
this correct? (Y/n) [PUSH ENTER]
? Do you want to add a block explorer config for this chain (y/N) [PUSH ENTER]
? Do you want to set block or gas properties for this chain config (y/N) [PUSH ENTER]
? Do you want to set native token properties for this chain config (defaults to
ETH) (y/N) [PUSH ENTER]
```

Note that it is not necessary to initialize the configuration of the core contracts because it is already hardcoded in configs/core-config.yaml.
However, this file depends on the validator's address and thus needs to be generated with the following command:

```
> ./create_contracts_config.sh
OK
```

Note that this configuration considers a default ISM using a multisig of a single signer. 

Deploy the Hyperlane contracts on the source chain.
```bash
> hyperlane core deploy -o configs/core-config.yaml 
? Select network type (Use arrow keys) [PICK Testnet]
? Select chain to connect: [TYPE source]
? Do you want to use an API key to verify on this (source) chain's block 
explorer (y/N) [PUSH ENTER]
? Is this deployment plan correct? (Y/n) [PUSH ENTER]
```

Deploy the Hyperlane contracts on the destination chain.
```bash
> hyperlane core deploy -o configs/core-config.yaml
? Select network type (Use arrow keys) [PICK Testnet]
? Select chain to connect: [TYPE destination]
? Do you want to use an API key to verify on this (source) chain's block 
explorer (y/N) [PUSH ENTER]
? Is this deployment plan correct? (Y/n) [PUSH ENTER]
```


# Spin up validator and relayer

(Reference: https://docs.hyperlane.xyz/docs/operate/docker-quickstart#4-setup-validator-environment)

Send the validator some ethers from the first private key generated by anvil. Recall the validator address was generated above.

```bash
> cast send  $VALIDATOR_ADDRESS --value 1ether --private-key $HYP_KEY
```

Create the validator configuration file. Be sure all the environment variables mentioned above are correctly set. 
```
> ./create_validator_config.sh
OK
```

Launch the validator docker
```bash
> docker compose --env-file .env.source up source-validator -d
```

Check everything works, that is there are no ugly error messages.
```bash
> docker logs -f source-validator 
```


Launch the relayer docker
```bash
> docker compose --env-file .env.source up relayer -d
```

Check everything works, that is there are no ugly error messages.
```bash
> docker logs -f relayer 
```

Send a message from the source chain to the destination chain.
```bash
> hyperlane send message --relay
```

Check that the validator has successfully signed the message. The logs should contain "INFO validator::submit: Signed all queued checkpoints until index, index: 0"

# References

[Configuration reference](https://docs.hyperlane.xyz/docs/operate/config-reference)
