# bdk-docker
Unofficial Dockerfile for bdk-cli.

Official project repository:
[bitcoindevkit](https://github.com/bitcoindevkit.org)

## init
```
# either clone repo or copy contents of Dockerfile
docker build -t bdk -f Dockerfile
docker run bdk cli help
```

## usage examples

Usage is just like `bdk-cli`. 

### Single Sig Policy

This example will create a descriptor for a child key derived from a hardened path. 

NOTE: If you want to get a change or deposit descriptor specifically for the same hardened path, you will have to pad the normal path to the `CHILDXPUB` used in creating the policy. 

If you add the change or deposit path to the `HDPATH` it will derive the subsequent child keys at those normal paths as the `CHILDXPUB`.

This is not always what wallets expect when importing a descriptor. The key used by the wallet must be the key at the hardened path, and any normal path values will be derived by descriptor wallets themselves. 

This behaviour of `bdk-cli key derive` is to provide more flexibility in working with derived keys.

#### Create keys

```bash
HDPATH=m/84h/1h/0h
MASTERXPRV=$(docker run bdk cli key generate | jq -r ".xprv")
CHILDXPUB=$(docker run bdk cli key derive --xprv $MASTERXPRV --path $HDPATH | jq -r ".xpub")
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
DESC=$(docker run bdk cli compile $POLICY | jq -r ".descriptor")
```

#### Generate Addesses 

Since we are using a general descriptor,  bdk will use the same path for change and deposit

```
docker run bdk cli wallet -w test -d $DESC get_new_address
```

### Try out more

```
docker run bdk cli wallet -w test -d $DESC get_public_descriptor
```
If you receive funds into this address and would like to check your balance or utxos:

```
# default syncs to an electrum 
docker run bdk cli wallet -w test -d $DESC sync
# you can also sync to a node that serves compact_filers - coming soon
docker run bdk cli wallet --node $NODE_ADDRESS -w test -d $DESC sync
```
