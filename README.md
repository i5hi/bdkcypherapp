# bdk-docker
Unofficial Dockerfile for testing bdk-cli versions.

Official project repository:

[bitcoindevkit](https://github.com/bitcoindevkit)

## init

The Dockerfile contains a few `ENV` variables that you should set yourself to get the version of bdk-cli you want.

- `CPU_CORES`: If you do not limit this, all of your CPU will belong to rustc during build.
If you want speed, make number go up. Use `nproc` to see your local max cores.

- `REPO`: The git repo to use

- `BRANCH`: The git branch to use

- `FEATURES`: The bdk-cli --features to add

```
git clone https://github.com/vmenond/bdk-docker
cd bdk-docker
docker build -t bdk .
echo "alias bcli='docker run bdk'" >> ~/.bashrc && source ~/.bashrc
bcli help 
```

## usage examples

Usage is just like `bdk-cli`. 

### Single Sig Policy

This example will create a descriptor for a child key derived from a hardened path. 

- <b>NOTE ON DESCRIPTORS & HDKEYS</b>: If you want to get a change or deposit descriptor for a specific key, you will have to pad the normal path to the `CHILDXPUB` while creating the policy. 

If you add the change or deposit path to the `HDPATH` it will derive the subsequent child keys at those normal paths as the `CHILDXPUB`.
You will notice if you add normal paths to the `HDPATH` variable, the resulting normal path will be <b>prefixed</b> to the `CHILDXPUB` as `[fingerprint/h/d/path/normal/path]xpub/*` - while a decriptor just pointing to change and descriptor paths (which what most wallets like core want) will have the normal path <b>suffixed</b> to the xpub like so `[fingerprint/h/d/path]xpub/normal/path/*`

This behaviour of `bdk-cli key derive` is to provide more flexibility in working with derived keys.

For most use cases - derivation of a child key is done only upto hardened paths and further derivation is offloaded to the wallet.

#### Create keys

```bash
HDPATH=m/84h/1h/0h
MASTERXPRV=$(bcli key generate | jq -r ".xprv")
CHILDXPUB=$(bcli key derive --xprv $MASTERXPRV --path $HDPATH | jq -r ".xpub")
```

#### Create a policy
```bash
GENERAL_POLICY="pk($CHILDXPUB)"
DEPOSIT_POLICY="pk($(echo $CHILDXPUB | rev | cut -c3- | rev)/0/*)"
CHANGE_POLICY="pk($(echo $CHILDXPUB | rev | cut -c3- | rev)/1/*)"
```

#### Compile into a descriptor

We just use the general descriptor; without specifying change or deposit.

```bash
DESC=$(bcli compile $POLICY | jq -r ".descriptor")
```

#### Generate Addesses 

Since we are using a general descriptor,  bdk will use the same path for change and deposit

```
bcli wallet -w test -d $DESC get_new_address
```

### Try out more

```
bcli wallet -w test -d $DESC get_public_descriptor
```
If you receive funds into this address and would like to check your balance or utxos:

```
# default syncs to an electrum 
bcli wallet -w test -d $DESC sync
# you can also sync to a node that serves compact_filers - coming soon
bcli wallet --node $NODE_ADDRESS -w test -d $DESC sync
```

### Support

Please report bugs or inconsitencies. 
