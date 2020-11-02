
# pkt-electrumx

> Run a PKT Electrumx server with one command

An easily configurable Docker image for running an Electrumx server on the PKT network.

Check it out on dockerhub at [cjd1/pkt-electrumx](https://hub.docker.com/r/cjd1/pkt-electrumx).

## Usage

1. Install [pktd](https://github.com/pkt-cash/pktd)

2. Launch pktd with the following arguments:

```
pktd --addrindex --txindex --notls --rpclisten=0.0.0.0 -u x -P x
```

3. Make a data directory

```
mkdir $HOME/electrumx_data
```

4. Launch electrumx from docker:

```
HOST_IP=$(ip route|awk '/docker/ { print $7; exit 0 }')
docker run \
  -v $HOME/electrumx_data:/data \
  --ulimit nofile=262144:262144
  -e DAEMON_URL=http://x:x@${HOST_IP}:64765 \
  -p 64767:64767 \
  cjd1/pkt-electrumx
```

In this example, pktd RPC is exposed to the world with password `x`, this might allow griefters to overload your pktd instance with a large number of bogus requests. Either set a password or bind to a local IP address to prevent this.

If there's an SSL certificate/key (`electrumx.crt`/`electrumx.key`) in the `/electrumx_data` volume it'll be used. If not, one will be generated for you.

You can view all ElectrumX environment variables here: https://github.com/spesmilo/electrumx/blob/master/docs/environment.rst

### Testing
After your electrumx server has fully imported the blockchain, it will begin serving information to electrum
instances. Once it is serving, you can perform a basic check that it is in fact accessible by using openssl:

```
openssl s_client -connect host.name.of.your.server:64767
```

If it is working correctly, you should see some information about the certificate and SSL session and finally
a hung terminal, press the enter key once and you should see this message:

```
{"jsonrpc": "2.0", "error": {"code": -32700, "message": "invalid JSON"}, "id": null}
```

As a reminder, this test will not work until after electrumx has fully imported the blockchain.

### TCP Port

By default only the SSL port is exposed. You can expose the unencrypted TCP port with `-p 64766:64766`, although this is strongly discouraged.

### WebSocket Port

You can expose the WebSocket port with `-p 64719:64719`.

### RPC Port

To access RPC from your host machine, you'll also need to expose port 8252. You probably only want this available to localhost: `-p 127.0.0.1:8252:8252`.

If you're only accessing RPC from within the container, there's no need to expose the RPC port.

## License

MIT © Luke Childs
Caleb James DeLisle