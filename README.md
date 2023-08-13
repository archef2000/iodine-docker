# iodine
Iodine VPN over DNS server/client in docker
# Docker run/compose
## docker-ompose
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
## run
```bash
docker run --name iodine --privileged \
  --cap-add NET_ADMIN --cap-add SYS_MODULE \
  --sysctls net.ipv4.ip_forward=1 --sysctls net.ipv4.conf.all.src_valid_mark=1 \
  --port 53:53/udp -e PASSWORD=*** -e DOMAIN=srv.test.com --restart unless-stopped \
  archef2000/iodine:latest
```
