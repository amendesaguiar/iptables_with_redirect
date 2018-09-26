#!/bin/bash
IPT='/sbin/iptables'

NET_EXT_ORIGIN_1='X.X.X.X'
NET_EXT_ORIGIN_2='X.X.X.X'
ALL='0.0.0.0/0'

# DESTINATION SERVERS
DST_SERVER_1='X.X.X.X'
DST_PORT_1='PORT'

DST_SERVER_2='X.X.X.X'
DST_PORT_2='PORT'


## - CLEAR RULES
$IPT -F -t nat
$IPT -X -t nat
$IPT -F
$IPT -X

echo 1 > /proc/sys/net/ipv4/ip_forward
echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
echo 200000 > /proc/sys/net/netfilter/nf_conntrack_max
echo 32768 > /sys/module/nf_conntrack/parameters/hashsize

## REDIRECT TO DESTINATION SERVER NET_EXT_ORIGIN_1
$IPT -A INPUT -p tcp -s $NET_EXT_ORIGIN_1 --dport $DST_PORT_1 -j ACCEPT
$IPT -A FORWARD -s $NET_EXT_ORIGIN_1 -p tcp --dport $DST_PORT_1 -j ACCEPT
$IPT -t nat -A PREROUTING -s $NET_EXT_ORIGIN_1 -p tcp --dport $DST_PORT_1 -j DNAT --to $DST_SERVER_1:$DST_PORT_1

## REDIRECT TO DESTINATION SERVER NET_EXT_ORIGIN_2
$IPT -A INPUT -p tcp -s $NET_EXT_ORIGIN_2 --dport $DST_PORT_2 -j ACCEPT
$IPT -A FORWARD -s $NET_EXT_ORIGIN_2 -p tcp --dport $DST_PORT_2 -j ACCEPT
$IPT -t nat -A PREROUTING -s $NET_EXT_ORIGIN_2 -p tcp --dport $DST_PORT_2 -j DNAT --to $DST_SERVER_2:$DST_PORT_2

## ALLOW ACCESS NET
$IPT -t nat -A POSTROUTING -o eth0 -s $ALL -j MASQUERADE
