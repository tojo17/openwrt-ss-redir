# Run Transparent Proxy on Openwrt

## Usage

- Install [`openwrt-shadowsocks`](https://github.com/shadowsocks/openwrt-shadowsocks), `iptables-mod-tproxy`, and `ip` .
- Copy files in `usr` folder to system.
- Add or override settings accroding to files in `etc` folder, **DO NOT OVERRIDE THE WHOLE FILE!**
- Config `/etc/shadowsocks.json` with your own server info.
- Run `chmod -R +x /usr/share/c17-ss` with root privilege.
- Reboot.

### Or (RECOMMENDED)

- Install [`luci-app-shadowsocks`](https://github.com/shadowsocks/luci-app-shadowsocks) in addition to packages above.
- *On GL-iNet routers*, change system language to non-Chinese, and Install `gl-ss` in addition to packages above in plugin menu.
- Copy only files related to `monitor.sh` to your system.
- Add only the `monitor.sh` command to your `rc.local`
- No need to config `/etc/config/shadowsocks.json`, instead, config it on `service -> Shadowsocks` page of Luci. *On GL-iNet routers*, config your server in VPN -> SS Client menu

## Note

- The LED control in `monitor.sh` is for `GL-AR300M` only, if the service runs successfully, the center LED will be on.
- This project is only tested on [this](http://download.gl-inet.com/firmware/ar300m/nand/testing/) firmware, which is based on OpenWrt 18.06.

## About DNS Poisoning in PRC

As we all know there is GFW in PRC, direct DNS query via UDP protocol will be poisoned.

ss-redir running on router cannot forward UDP packages sent from local server (local router), it can only forward UDP packages of devices under it. So setting `DNS forwarding` in `Network` -> `DHCP and DNS` page of OpenWRT will **NOT** work.

We have different ways to solve it:

### 1. Run a `ss-tunnel` to forward local 53 port (or another port) to `8.8.8.8:53`

`sudo ss-tunnel -c /etc/shadowsocks.json -l 53 -b 0.0.0.0 -L 8.8.8.8:53 -u`

OpenWRT has a own DNS server called `Dnsmasq` running on port 53, to avoid port conflicts, you can either:

- Change the DNS port of `Dnsmasq` to another one. Change  `Network` -> `DHCP and DNS` -> `Server Settings` -> `Advanced Settings` -> `DNS server port` in Luci.

or

- Use another local port for fowarding, and set `DNS forwarding` in `Network` -> `DHCP and DNS` to `127.0.0.1:your_port` in Luci.

### 2. Tell the devices connecting to this router to use `8.8.8.8` directly **(used by this project)**

As I said above, ss-redir can only forward UDP packages of devices under it. So direct DNS query on connected devices is okay.

Configurations in `/etc/config/dhcp` is for this purpose. Or you can set it manually in Luci at `Network` -> `Interfaces` -> `LAN` -> `DHCP Server` -> `Advanced Settings` -> `DHCP-Options`. The setting `6,8.8.8.8,8.8.4.4` advertises different DNS servers to clients. Or use `uci add_list dhcp.lan.dhcp_option='6,8.8.8.8,8.8.4.4' && uci commit` to commit. Check [OpenWrt Wiki](https://openwrt.org/docs/guide-user/base-system/dhcp) or [List of Options](http://www.networksorcery.com/enp/protocol/bootp/options.htm) for more details.