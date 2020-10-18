server_ip=13.66.165.220
local_port=12345
# 新建一个名为chnip的ipset
ipset -N chnip hash:ip

# 新建 nat/PROXY-TCP 链，用于透明代理本机/内网 tcp 流量
iptables -t nat -N PROXY-TCP
# 放行环回地址，保留地址，特殊地址
iptables -t nat -A PROXY-TCP -d 0/8 -j RETURN
iptables -t nat -A PROXY-TCP -d 127/8 -j RETURN
iptables -t nat -A PROXY-TCP -d 10/8 -j RETURN
iptables -t nat -A PROXY-TCP -d 169.254/16 -j RETURN
iptables -t nat -A PROXY-TCP -d 172.16/12 -j RETURN
iptables -t nat -A PROXY-TCP -d 192.168/16 -j RETURN
iptables -t nat -A PROXY-TCP -d 224/4 -j RETURN
iptables -t nat -A PROXY-TCP -d 240/4 -j RETURN
# 放行发往 PROXY 服务器的数据包，注意替换为你的服务器IP
iptables -t nat -A PROXY-TCP -d $server_ip -j RETURN
# 放行大陆地址段
iptables -t nat -A PROXY-TCP -m set --match-set chnip dst -j RETURN
# 重定向 tcp 数据包至local_port监听端口
iptables -t nat -A PROXY-TCP -p tcp -j REDIRECT --to-ports $local_port
# 本机 tcp 数据包流经 PROXY-TCP 链
iptables -t nat -A OUTPUT -p tcp -j PROXY-TCP

# 内网 tcp 数据包流经 PROXY-TCP 链
#iptables -t nat -A PREROUTING -p tcp -s 192.168/16 -j PROXY-TCP

# 内网数据包源 NAT
#iptables -t nat -A POSTROUTING -s 192.168/16 -j MASQUERADE

# 新建 mangle/PROXY-UDP 链，用于透明代理内网 udp 流量
iptables -t mangle -N PROXY-UDP

# 放行保留地址、环回地址、特殊地址
iptables -t mangle -A PROXY-UDP -d 0/8 -j RETURN
iptables -t mangle -A PROXY-UDP -d 127/8 -j RETURN
iptables -t mangle -A PROXY-UDP -d 10/8 -j RETURN
iptables -t mangle -A PROXY-UDP -d 169.254/16 -j RETURN
iptables -t mangle -A PROXY-UDP -d 172.16/12 -j RETURN
iptables -t mangle -A PROXY-UDP -d 192.168/16 -j RETURN
iptables -t mangle -A PROXY-UDP -d 224/4 -j RETURN
iptables -t mangle -A PROXY-UDP -d 240/4 -j RETURN

# 放行发往 PROXY 服务器的数据包，注意替换为你的服务器IP
iptables -t mangle -A PROXY-UDP -d $server_ip -j RETURN

# 放行大陆地址
iptables -t mangle -A PROXY-UDP -m set --match-set chnip dst -j RETURN

# 重定向 udp 数据包至 local_port 监听端口
iptables -t mangle -A PROXY-UDP -p udp -j TPROXY --tproxy-mark 0x2333/0x2333 --on-ip 127.0.0.1 --on-port $local_port

# 内网 udp 数据包流经 PROXY-UDP 链
#iptables -t mangle -A PREROUTING -p udp -s 192.168/16 -j PROXY-UDP

# 持久化 iptables 规则
#iptables-save > /etc/iptables.tproxy
