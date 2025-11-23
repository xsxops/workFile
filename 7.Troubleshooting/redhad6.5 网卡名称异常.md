## redhad6.5 网卡名称异常

1.红帽6.5 服务器重启后 网卡名称从 eth0  1 2 3 变成了  4 5 6 7

```bash
# 查看现在的网卡名称
ip link show  
ip a

# 查看IP和MAC以及name
cat /etc/sysconfig/network-scripts/ifcfg-eth{0..3}|grep -E "^NAME|HWADDR"

# 备份net-rules 文件
cp /etc/udev/rules.d/70-persistent-net.rules /etc/udev/rules.d/70-persistent-net.rules-bak

#修改
vim /etc/udev/rules.d/70-persistent-net.rules
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:11:22:33:44:55", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"
# ATTR{address}=="网卡MAC地址" 
# NAME 修改为你希望的设备名称 比如 NAME="eth0"
# 确保修改正确后执行，让其修改生效，然后重新启动
dracut -f
reboot
```

