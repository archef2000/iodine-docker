# iodine
Iodine VPN over DNS server/client in docker
## Docker run/compose
### docker-compose
```yaml
services:
  iodine:
    image: archef2000/iodine:latest
    container_name: iodine
    privileged: true
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
    ports:
      - 53:53/udp
    devices:
      - /dev/net/tun:/dev/net/tun
    environment:
      - PASSWORD=***
      - DOMAIN=srv.test.com
    restart: unless-stopped
```
### docker-run
```bash
docker run --name iodine --privileged \
  --cap-add NET_ADMIN --cap-add SYS_MODULE \
  --sysctls net.ipv4.ip_forward=1 --sysctls net.ipv4.conf.all.src_valid_mark=1 \
  --port 53:53/udp -e PASSWORD=*** -e DOMAIN=srv.test.com --restart unless-stopped \
  archef2000/iodine:latest
```

## Config
### Universal
| Variable | Function |
| -------- | -------- |
| PASSWORD | Password for authentication |
| DOMAIN | The domain the iodine server is reachable at |

### Server
| Variable | Function |
| -------- | -------- |
| MTU | The MTU of the vpn interface |
| DEV_TUNNEL | Specify tunnel interface |
| LOG_LEVEL | Set debug log level to 0, 1 or 2 |
| FORWARD_DEST | Destination to forward to other |
| NETWORK | Subnet of VPN tunnel default `10.0.0.1` |

### Client
| Variable | Function |
| -------- | -------- |
| FORCE_DNS_TUNNEL | Ski raw connection mode default `false` |
| MAX_INTERVAL | Between requests to server |
| LAZY_MODE | Lower response time when enabled |
| DNS_SERVER | What DNS server to  send the requests to default `8.8.8.8` |
| HOSTNAME_SIZE | Max hostname size |
| DNS_TYPE | What DNS request type to use default autodetected |
