# Hyperlane integration proof-of-concept

Example of an integration of hyperlane with Espresso.

# Development environment

Everytime you open a terminal run

```bash
> ./launch_shell
```

# AWS configuration

The validator uses AWS service for handling the signing key and storing its signatures in an AWS bucket.

## KMS

### Create IAM user

*TODO:* Automate with Terraform

Reference: https://docs.hyperlane.xyz/docs/operate/set-up-agent-keys#2-aws-kms

1. Go to [aws.amazon.com](aws.amazon.com) and login.
2. Go to AWS's Identity and Access Management (IAM)
3. On the left, under "Access management", click "Users".
4. Click the orange button "Add users".
5. Pick a friendly and informative username, like hyperlane-validator-${chain_name} or hyperlane-relayer-${chain_name}. **This username will be referenced in future steps, so if you choose a different username be sure to use your correct username in the future.**
6. Click "Next", you do not need to assign the user any permissions.
7. Click "Create user".
8. Click into the user that you just created
9. Click the "Security Credentials" tab
10. Scroll down to "Access Keys" and click "Create Access Key"
11. Select "Application running outside AWS" and click "Next"
12. Click "Next", no need to add a description tag
13. Click "Create access key"
14. Copy the "Access key ID" and "Secret access key" to a safe place. **These will be passed to your Hyperlane Relayer as environment variables.**
    Set the following environment variables:

```bash
export AWS_ACCESS_KEY_ID=<Access key ID obtained in step 14>
export AWS_SECRET_ACCESS_KEY=<Access secret key obyained in step 14>
```


### Create KMS key
1. Go to AWS's Key Management Service (KMS) in the AWS console.
1. Ensure you are in the region you want to create the key in. This can be confirmed by viewing the region at the top right of the console, or by finding the name in the URL's subdomain (e.g. us-west-2.console.aws.amazon.com means you're operating in the region us-west-2).
1. On the left, click "Customer managed keys".
1. Click "Create key".
1. Select the "Asymmetric" key type.
1. Select the "Sign and verify" key usage.
1. Select the ECC_SECG_P256K1 key spec.
1. Click "Next".
1. Set the Alias to something friendly and informative.
1. While not necessary, feel free to write a description and add any tags that you think will be useful.
1. Click "Next".
1. A key administrator is not required, but if you want, you can select one.
1. Click "Next".
1. Give usage permissions to the IAM user you created in section #1.
1. Click "Next".
1. In the Review page, scroll to the "Key policy". The generated key policy is acceptable, but you can make the access even less permissive if you wish by:
   1. Removing the kms:DescribeKey and kms:Verify actions from the statement whose "Sid" is "Allow use of the key"
   1. Removing the entire statement whose "Sid" is "Allow attachment of persistent resources".
1. Click "Finish"

Set the following environment variable with the alias picked in step 9.

```bash
export VALIDATOR_KEY_ALIAS=<validator signer key alias picked in step 9>
```

### Generate the validator address

Using the values generated in the previous step run this command in order to create the validator address.

``` bash
> export AWS_REGION=<region>
> export AWS_KMS_KEY_ID=alias/$VALIDATOR_KEY_ALIAS
> export VALIDATOR_ADDRESS=`cast wallet address --aws`
```

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



Update the environment variables that will be later used to generate some configuration files:
```bash
export VALIDATOR_BUCKET_NAME=<bucket name picked in step 3>
export CHAIN_NAME="source"
```


# Initialize the chains with the Hyperlane contracts
(Reference: https://docs.hyperlane.xyz/docs/guides/local-testnet-setup)

Open new terminal and launch the source chain:
```bash
./launch_source_chain
```

Open new terminal and launch the destination chain:
```bash
./launch_destination_chain
```

Open a new terminal.
Set the first private key autogenerated by anvil in the HYP_KEY environment variable.
This key will be use to deploy the Hyperlane contracts.
```bash
> export HYP_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

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
However this file depends on the validator's address and thus needs to be generated with the following command:

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


# Spin up a validator


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

Check everything works. You should see an INFO message "INFO validator::validator: Successfully announced validator..."
```bash
> docker logs -f source-validator 
```

Send a message from the source chain to the destination chain.
```bash
> hyperlane send message --relay


```

Check that the validator has successfully signed the message. The logs should contain "INFO validator::submit: Signed all queued checkpoints until index, index: 0"

# References

[Configuration reference](https://docs.hyperlane.xyz/docs/operate/config-reference)
