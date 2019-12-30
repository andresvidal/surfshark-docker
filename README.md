# Surfshark Docker Container

**IMPORTANT** The following instructions are based on an ARMv7l architecture (arm32v7/alpine:latest), like the Raspberry Pi.

Find it on:

- https://github.com/andresvidal/surfshark-docker
- https://hub.docker.com/r/andresvidal/openvpn-armv7l

## Quick Start

1. Sign up for a Sharksurf account, of course! 
2. Get Service Credentials and update your `credentials.txt` with the username on the 1st line and password on the 2nd line. 
    - Credentials: https://account.surfshark.com/setup/manual (bottom of page)
3. Run:

```
docker run -d \
    --name vpn \
    --init \
    --cap-add=NET_ADMIN \
    --device /dev/net/tun \
    -v `pwd`/prod.surfshark.com.ovpn:/vpn/servers.ovpn \
    -v `pwd`/credentials.txt:/vpn/auth.txt \
    andresvidal/openvpn-armv7l --config /vpn/servers.ovpn --auth-user-pass /vpn/auth.txt
```

## Updating server hostnames and protocols for .ovpn config

Get the latest OpenVPN confirguration files from either location

- https://account.surfshark.com/api/v1/server/configurations (all zipped)
- https://account.surfshark.com/setup/manual

... and update `prod.surfshark.com.ovpn` config with remote servers. The format is `remote <hostname> <port> <proto>`. You can use or modify the following cli command to quickly output the hostnames formatted. 

``` bash
# This example will output the `UDP` connections for `US` servers found in the connection files stored in a relative `surfshark` folder.

$ ls -l surfshark/us*udp.ovpn | awk -F'[/.]' '{print "remote " $2"."$3"."$4".com 1194 udp"}'

...
remote us-atl.prod.surfshark.com 1194 udp
remote us-bdn.prod.surfshark.com 1194 udp
remote us-bos.prod.surfshark.com 1194 udp
...
```

The `remote-random` directive in the `.ovpn` config file will randomly rotate between servers. OpenVPN will also scroll through servers when a connection fails. 

## Docker Setup

### Build Locally (arm32v7 architecture)

``` bash
$ docker build -t andresvidal/openvpn-armv7l .
```

### Starting an OpenVPN Client Instance (Once)

``` bash
docker run -it --rm \
    --name vpn \
    --init \
    --cap-add=NET_ADMIN \
    --device /dev/net/tun \
    -v `pwd`/prod.surfshark.com.ovpn:/vpn/servers.ovpn \
    -v `pwd`/credentials.txt:/vpn/auth.txt \
    andresvidal/openvpn-armv7l --config /vpn/servers.ovpn --auth-user-pass /vpn/auth.txt
```

### Starting an OpenVPN Client Instance (Daemon)

``` bash
docker run -d \
    --name vpn \
    --init \
    --cap-add=NET_ADMIN \
    --device /dev/net/tun \
    -v `pwd`/prod.surfshark.com.ovpn:/vpn/servers.ovpn \
    -v `pwd`/credentials.txt:/vpn/auth.txt \
    andresvidal/openvpn-armv7l --config /vpn/servers.ovpn --auth-user-pass /vpn/auth.txt
```

### Connect to internet through OpenVPN container

Once VPN container is up other containers can be started using its network connection using `--net=container:vpn` where `vpn` is the name of the OpenVPN container:

``` bash
$ docker run -it --net=container:vpn -d some/docker-container
```

### Check if IP has changed in the OpenVPN container

Check your IP address first and compare to the output from:

``` bash
# Local Public IP
$ docker run -it --rm andresvidal/curl-armv7l https://api.ipify.org/

# OpenVPN Container Public IP
$ docker run -it --rm --net=container:vpn andresvidal/curl-armv7l https://api.ipify.org/

113.134.235.235
```