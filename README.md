# bdkcypherapp

Unofficial Dockerfile containerizing [bdk-cli](https://github.com/bitcoindevkit/bdk-cli) towards easy plugin as a [cypherapp](https://github.com/SatoshiPortal/cyphernode) to your custom `cyphernodenet`. 

Full instructions to setup as a cypherapp will be available soon. 

Currently useful for testing versions of bdk-cli based on a git repo and branch.

## init

The Dockerfile contains a few `ENV` variables that you should set yourself to get the version of bdk-cli you want.

- `CPU_CORES`: If you do not limit this, all of your CPU will belong to rustc during build. Use `nproc` to see your local max cores.

- `REPO`: The git repo to use

- `BRANCH`: The git branch to use

- `FEATURES`: The bdk-cli --features to add

```
git clone https://github.com/vmenond/bdkcypherapp

# light-weight option for --features=compiler
cd bdkcypherapp/scratch
# larger image currently required for --features=compact_filters
cd bdkcypherapp/alpine

docker build -t bdk-cli .

# for compute only
echo "alias bcli='docker run bdk-cli'" >> ~/.bashrc && source ~/.bashrc
# for compute only (within cyphernodenet)
echo "alias bcli='docker run --network cyphernodenet bdk-cli'" >> ~/.bashrc && source ~/.bashrc


# persistance currently requies chmod 777 on local ~/.bdk-bitcoin 
# successive updates will allow using a fixed uid for bdk which can be set as the group for ~/.bdk-bitcoin
# for persistent storage (only alpine container supports volume - use path on host to .bdk-bitcoin)
echo "alias bcli='docker run -v /home/youruser/.bdk-bitcoin:/home/bdk/.bdk-bitcoin bdk-cli'" >> ~/.bashrc && source ~/.bashrc
# for persistent storage (within cyphernodenet)
echo "alias bcli='docker run --network cyphernodenet -v /home/youruser/.bdk-bitcoin:/home/bdk/.bdk-bitcoin'" >> ~/.bashrc && source ~/.bashrc

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
# local bitcoind
NODE_ADDRESS=127.0.0.1:18333
# cyphernodenet
NODE_ADDRESS=dist_bitcoin_1:18333

# sync bdk to node
bcli wallet --node $NODE_ADDRESS -w test -d $DESC sync
```

### Support

Please report bugs or inconsitencies. 
