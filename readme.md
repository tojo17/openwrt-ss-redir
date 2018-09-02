# Run Transparent Proxy on Openwrt

## Usage

- Install [`openwrt-shadowsocks`](https://github.com/shadowsocks/openwrt-shadowsocks), `iptables-mod-tproxy`, `ip`
- Copy or add files to system
- create `/etc/shadowsocks.json` and config it
- run `chmod -R +x /usr/share/c17-ss` with root privilege
- reboot

## Note

- The LED control in `monitor.sh` is for `GL-AR300M` only