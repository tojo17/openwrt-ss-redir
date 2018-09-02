#!/bin/sh
# needs root privilege

# check dual-start
if [ -n "$(ps | grep /etc/shadowsocks.json | grep -v grep)" ]; then
    exit 0
fi

# wait for internet connection
while [ -n "$(ping qq.com -c 1 | grep "0 packets received")" ]
do
    sleep 1s
done

basepath=$(cd `dirname $0`; pwd)
# config ss-redir
# mkdir -p /var/c17-ss-redir
# cp -f $basepath/shadowsocks.json /var/c17-ss-redir/ss-redir.json
server_ip=$(cat /etc/shadowsocks.json | awk -F '[:]' 'gsub(/[, \"]/,"")&&$1=="server" {print $2}')
echo Server $server_ip

# SS-REDIR TCP
iptables -t nat -N SSREDIR_TCP
# Bypass ssserver and LAN
iptables -t nat -A SSREDIR_TCP -d $server_ip -j RETURN
iptables -t nat -A SSREDIR_TCP -d 0.0.0.0/8 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 10.0.0.0/8 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 127.0.0.0/8 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 169.254.0.0/16 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 172.16.0.0/12 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 192.168.0.0/16 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 224.0.0.0/4 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 240.0.0.0/4 -j RETURN

# Redirect TCP
iptables -t nat -A SSREDIR_TCP -p tcp -j REDIRECT --to-ports 1080
iptables -t nat -A PREROUTING -p tcp -j SSREDIR_TCP

# SS_REDIR UDP
ip rule add fwmark 0x02/0x02 table 100
ip route add local 0.0.0.0/0 dev lo table 100
iptables -t mangle -N SSREDIR_UDP
iptables -t mangle -A SSREDIR_UDP -d $server_ip -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 240.0.0.0/4 -j RETURN

# Redirect UDP
iptables -t mangle -A SSREDIR_UDP -p udp -j TPROXY --on-port 1080 --tproxy-mark 0x02/0x02

# Enable
iptables -t mangle -A PREROUTING -j SSREDIR_UDP

# route delete -net 0.0.0.0
# route add -net 0.0.0.0 gw 10.0.2.2 netmask 0.0.0.0 dev enp0s3

# run ss-redir
($basepath/monitor.sh > /dev/null 2>&1) &
# ss-redir -c /etc/shadowsocks.json -u -v
(ss-redir -c /etc/shadowsocks.json -u > /dev/null 2>&1) &