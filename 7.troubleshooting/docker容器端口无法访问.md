### 1. 检查端口是否被监听

```bash
sudo ss -tulnp | grep ':15672'
```



### 2. 服务是否正常运行

```bash
sudo docker ps | grep rabbitmq
```

```bash
sudo docker ps -f name=rabbitmq
```



### 3. Docker 是否正常映射端口

```bash
sudo docker port rabbitmq
```



### 4. 关闭防火墙

对于默认的 `ufw` 防火墙：

```bash
sudo ufw disable
```

如果使用 `iptables`:

```bash
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F
```

### 5. 关闭 SELinux

在 Ubuntu 上，默认不安装 SELinux，通常安装的是 AppArmor。如果确实安装了 SELinux，可以使用以下命令暂时关闭：

```bash
sudo setenforce 0
```

如果你想要永久关闭它（不推荐），你需要编辑 `/etc/selinux/config` 文件。



### 6. 本地访问 web 地址测试是否正常

在本地浏览器中打开以下地址：

```plaintext
http://localhost:15672/
```

或者使用 `curl` 测试：

```bash
curl -I http://localhost:15672/
```

![image-20240625225759943](./images/MQ无法访问管理界面/image-20240625225759943.png)

### 7.可以看到本地访问正常，但是外界却无法访问。这里可以得出安全组没有进行放行（云服务器）