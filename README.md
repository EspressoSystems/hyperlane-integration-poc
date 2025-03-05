# Hyperlane integration proof-of-concept

This project allows to send a message between two chains deployed locally using Hyperlane. 
More specifically by following the steps below you will:
1. Spin up a local chain with Anvil and a local Caffeinated node (using [nitro-testnode](https://github.com/EspressoSystems/nitro-testnode))
2. Deploy Hyperlane contracts on both chains configured in such way it supports a MultiSig ISM with one signer.
3. Configure AWS objects (signing keys, buckets) to be used by the Hyperlane agents (i.e. the relayer and validator).
4. Spin up a relayer and a validator using docker.
5. Deploy an app on both source chain and destination chain that can send message to the other chain and increments a counter when a message is received.
6. Run a script to send a message from the source app to the destination app and check that the message was sent correctly.

# Development environment

Everytime you open a terminal run

```bash
> ./launch_shell.sh
```

# AWS configuration

The validator and the relayer use AWS services.

## Create IAM user

1. Go to [aws.amazon.com](aws.amazon.com) and login.
1. Go to AWS's Identity and Access Management (IAM)
1. On the left, under "Access management", click "Policies".
1. Click "Create policy"
1. In the tab "Policy editor" click "JSON"
1. Copy the content of `aws/user-policy.json` inside the editor.
1. Click "Next".
1. Add a policy name (Field below "Policy details"), e.g "hyperlane-policy-XYZ"
1. Click create policy.
1. Go back to IAM home page 
1. On the left, under "Access management", click "Users".
1. Click the orange button "Create user".
1. Pick a friendly and informative username, like *hyperlane1*. 
1. Select "Attach policies directly". 
1. Select the policy you created above using its name, e.g. "hyperlane-policy-XYZ".
1. Click on "Create user"
1. Click on the user you created.
1. Click on "Security credentials"
1. Scroll down to "Access Keys" and click on "Create Access Key"
1. Select "Application running outside AWS" and click "Next"
1. Click "Next", no need to add a description tag
1. Click "Create access key"
1. Copy the "Access key ID" and "Secret access key" to a safe place.
1. Go to the IAM home and copy the Account ID (see panel "AWS Account" at the top right)
1. Identify your AWS region: Check at the beginning of the url e.g.: https://us-east-1.console.aws.amazon means your region is *us-east-1*.
    
Set the following environment variables:

```bash
./launch_shell
export AWS_USER_NAME=<Copy the name chosen in step 13>
export AWS_ACCESS_KEY_ID=<Access key ID obtained in step 23>
export AWS_SECRET_ACCESS_KEY=<Access secret key obyained in step 12>
export AWS_ACCOUNT_ID=<Copy the account id obtained in step 24>
export AWS_DEFAULT_REGION=<See step 25>
```

## Create KMS key and related addresses

Note the syntax of the command below! This script must update the environment variables of the shell.

```bash
> . aws/create_keys_and_addresses.sh
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
Validator address: 0x726402Ed21c3a7BaABc500f9486CE76b30158636
Relayer address: 0x726402Ed21c3a7BaABc500f9486CE76b30158636
```

## Generate the S3 bucket

Create the bucket and configure the policy of the bucket.
(Note the syntax of the command! This script must update the environment variables of the shell.)
```
> . aws/create_bucket.sh 
```

# Initialize the chains with the Hyperlane contracts

Do a bit of cleanup if you already followed the steps of this document.
```bash
cleanup.sh
```

## Launch source chain (Caff node)

In another terminal follow these steps in order to deploy a local Caff nodes.
(See also https://github.com/EspressoSystems/nitro-testnode?tab=readme-ov-file#running-the-smoke-tests-for-the-caffeinated-node)

```bash
> git clone git@github.com:EspressoSystems/nitro-testnode.git
> cd nitro-testnode
> git submodule update --init
```
Create a Github Personal Access Token (PAT) following [Creating a personal access token (classic)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic).

Provide Docker with the PAT.
```bash
> export CR_PAT=<your PAT>
> echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

Launch the Caffeinated node.
```bash
> ./launch-test-caff-node.bash
...
*** Caff node launched successfully. ***
```

Wait for the script to finish (until you get "*** Caff node launched successfully. ***"). It takes a while.

## Launch destination chain (Vanilla Anvil node)

Open new terminal and launch the destination chain:
```bash
./launch_shell.sh
launch_destination_chain.sh
```

*TODO:* automate answering to the questions.

Let us now register the chains before Hyperlane can deploy its contracts.
Go back to the terminal you used to create the AWS signing key and buckets.

First the source chain:
```bash
> hyperlane registry init

```bash
> hyperlane registry init
? Detected rpc url as http://localhost:8545 from JSON RPC provider, is this
correct? n
? Enter http or https rpc url: (http://localhost:8545) http://localhost:8547 
? Enter chain name (one word, lower case) destination
? Enter chain display name (Destination) [PUSH ENTER]
? Detected chain id as 412346 from JSON RPC provider, is this correct? (Y/n) [PUSH ENTER]
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
? Enter http or https rpc url: (http://localhost:8545) http://localhost:8549 
? Enter chain name (one word, lower case) destination
? Enter chain display name (Destination) [PUSH ENTER]
? Detected chain id as 31338 from JSON RPC provider, is this correct? (Y/n) [PUSH ENTER]
? Is this chain a testnet (a chain used for testing & development)? (Y/n) [PUSH ENTER]
? Select the chain technical stack (Use arrow keys) [PUSH ENTER]
? Detected starting block number for indexing as 30 from JSON RPC provider, is
this correct? (Y/n) [PUSH ENTER]
? Do you want to add a block explorer config for this chain (y/N) [PUSH ENTER]
? Do you want to set block or gas properties for this chain config (y/N) [PUSH ENTER]
? Do you want to set native token properties for this chain config (defaults to
ETH) (y/N) [PUSH ENTER]
```

Note that it is not necessary to initialize the configuration of the core contracts because it is already hardcoded in `configs/core-config.yaml`.
However, this file depends on the agents' addresses and thus needs to be generated with the following command:

```
> create_contracts_config.sh
OK
```

Note that this configuration considers a default ISM using a multisig of a single signer. 

Fund the relevant addresses.

```bash
> fund_addresses.sh
Hyperlane address 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  on source chain funded correctly.
Relayer address 0xaC6D5182Db016360067cf7C5b16d5311f8D7C3Ba  on destination chain funded correctly.
Validator address 0xaC6D5182Db016360067cf7C5b16d5311f8D7C3Ba  on source chain funded correctly.
```

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
? Do you want to use an API key to verify on this (destination) chain's block 
explorer (y/N) [PUSH ENTER]
? Is this deployment plan correct? (Y/n) [PUSH ENTER]
```

Deploy the Espresso app contracts on both chains:
```bash
> . deploy_espresso_app_contracts.sh
Espresso app contract successfully deployed on the source chain at address 0x322813Fd9A801c5507c9de605d63CEA4f2CE6c44.
Espresso app contract successfully deployed on the destination chain at address 0x4ed7c70F96B99c776995fB64377f0d4aB3B0e1C1.
```

# Spin up a validator and a relayer

Create the validator configuration file. Be sure all the environment variables mentioned above are correctly set. 
```
> create_agent_config.sh
OK
```

Launch the validator docker
```bash
> docker compose --env-file .env up source-validator -d
```

Check everything works, that is there are no ugly error messages.
```bash
> docker logs -f source-validator 
```


Launch the relayer docker.
```bash
> docker compose --env-file .env up relayer -d
```

Check everything works, that is there are no ugly error messages.
```bash
> docker logs -f relayer 
```

# Sending messages

## Send a test message between two chains

Send a test message from the source chain to the destination chain.
```bash
> hyperlane send message
  [ SELECT Testnet > source ]
  [ SELECT Testnet > destination ]
 ...   
Waiting for message delivery on destination chain...
Message 0x4c3794595f32d13fb8bd27dc783d79eae4ffd4568b778182332ea1db81024025 was processed
All messages processed for tx 0xeca30dd44c3a3a765a0d73f58b64449260134c3d029e3492f6c37e23cceb16de
```

## Send a message between Espresso apps deployed on different chains

Check the counter value on the destination app before sending the message

```bash
> check_counter_destination_chain.sh 
0x0000000000000000000000000000000000000000000000000000000000000000
```

```bash
> send_message.sh
```


Wait a few seconds and check the counter value on the destination app again. It should be incremented by one.

```bash
> check_counter_destination_chain.sh 
0x0000000000000000000000000000000000000000000000000000000000000001
```

# Shutdown

Once you are done you can shut down the docker containers like this:
* In the `nitro-testnode` repository/directory.

```bash
> docker compose down
```
* In this repository/directory

```bash
> docker compose down
```

* Close the terminal running the anvil node (destination chain).

# References

[Configuration reference](https://docs.hyperlane.xyz/docs/operate/config-reference)
