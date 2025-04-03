# FRP  快速反向代理



## 什么是FRP？

FRP（Fast Reverse Proxy）通过建立反向代理隧道来使内网服务能够在没有公网IP的情况下被外界访问。这个过程依赖于一种称为反向代理的网络服务技术，结合了隧道协议来穿透NAT和防火墙

**FRP的关键组件**

**1.FRP服务器：**

- 部署在具有公网IP的服务器上。
- 负责接收来自互联网的请求并转发给FRP客户端。

**2.FRP客户端：**

- 部署在内网环境，无需公网IP。
- 监听内网服务的端口，并等待来自FRP服务器的转发请求。

## 工作原理和技术细节

#### 1. 建立连接

- 启动过程：
  - FRP客户端在启动时，会根据配置文件中的信息主动向FRP服务器发起连接。
  - 使用WebSocket或TCP连接建立一个持久的隧道。
  - 通过这个隧道，FRP服务器和客户端之间可以持续安全地交换数据。

#### 2. 配置隧道

- 隧道类型：
  - 支持多种隧道类型，如HTTP、HTTPS、TCP、XTCP等。
  - 根据配置，FRP客户端会告知服务器哪些端口和协议需要被外部访问。

#### 3. 请求转发

- 请求的接收和转发：
  - 当外部请求到达FRP服务器的某个指定端口时，FRP服务器根据事先配置的隧道信息，通过建立的隧道将请求转发到FRP客户端。
  - FRP客户端接收到这些请求后，将它们转发到本地的内网服务。

#### 4. 数据回传

- 处理和响应：
  - 内网服务处理完成后，它的响应被发送回FRP客户端。
  - FRP客户端再将这些响应数据通过同一隧道回传给FRP服务器。
  - FRP服务器最终将响应返回给原始请求者。

**使用的协议和技术**

- **隧道技术**：主要利用TCP和WebSocket协议来维持连接，支持SSL/TLS加密保护数据安全。
- **NAT穿透**：利用已建立的隧道来实现NAT穿透，即使内网服务 behind a NAT or firewall，也能被外界访问。

## 部署方案

下载FRP  [FRP的GitHub页面](https://github.com/fatedier/frp/releases)。

### 服务端

**1.下载安装**

```bash
wget https://github.com/fatedier/frp/releases/download/v0.59.0/frp_0.59.0_linux_amd64.tar.gz -P /opt
cd /opt 
tar -xzvf frp_0.59.0_linux_amd64.tar.gz
```

**2.设置配置文件**

```bash
vim frps.toml
# 服务端与客户端通信端口
bindPort = 7000
#bindAddr = "127.0.0.1"
# 服务端将只接受 TLS链接
transport.tls.force = false

# 服务鉴权方式
auth.method = "token"
# 服务提供商提供的 token 密码
auth.token = "xty123"

# Server Dashboard，可以查看frp服务状态以及统计信息
# 后台管理地址
webServer.addr = "0.0.0.0"
# 后台管理端口
webServer.port = 7500
# 后台登录用户名
webServer.user = "admin"
# 后台登录密码
webServer.password = "Xty-2018"

# 虚拟主机端口
#vhostHTTPPort = 18080
# SSL 虚拟主机端口
#vhostHTTPSPort = 1443

# 日志配置
log.to = "/var/log/frps.log"
log.level = "debug"
log.maxDays = 3
log.disablePrintColor = false
```

**3.设置system工具管理**

```bash
vim /usr/lib/systemd/system/frps.service 

[Unit]
Description = frp server
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
ExecStart = /opt/frp/frps -c /opt/frp/frps.toml

[Install]
WantedBy = multi-user.target
```

**4.启动服务**

```bash
# 设置开机自动启动服务并立刻启动
systemctl enable frps --now
```



### 客户端

**1.下载安装**

```bash
wget https://github.com/fatedier/frp/releases/download/v0.59.0/frp_0.59.0_linux_amd64.tar.gz -P /opt
cd /opt 
tar -xzvf frp_0.59.0_linux_amd64.tar.gz
```

```bash
vim frpc.toml 

[common]
#云服务器的IP地址和端口
server_addr = "114.115.203.237"
server_port = 7000

#日志配置
[log]
#日志文件的路径
logFile = "/var/log/frpc.log"
#日志输出级别：info 表示输出信息较详细
logLevel = "debug"
#日志保留的最大天数
logMaxDays = 3
#日志文件的最大行数
logMaxLines = 1000000
#是否启用日志轮转
logRotate = true
#是否禁用日志颜色输出
disableLogColor = false
#日志输出到控制台
logConsole = "console"


[[proxies]]
name = "ssh"
type = "tcp"
local_ip = "192.168.110.159"
local_port = 22
remote_port = 6000


[[proxies]]
name = "jenkins"
type = "tcp"
local_ip = "192.168.110.159"
local_port = 8080
remote_port = 18080

# 将客户端中的80端口暴露到云服务器中的10080端口当中
[[proxies]]
name = "nginx"
type = "tcp"
local_ip = "192.168.110.159"
localPort = 80
remotePort = 10080
```

**3.设置system工具管理**

```bash
vim /usr/lib/systemd/system/frpc.service 

[Unit]
Description = frp server
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
ExecStart = /opt/frp/frpc -c /opt/frp/frpc.toml

[Install]
WantedBy = multi-user.target
```

**4.启动服务**

```bash
# 设置开机自动启动服务并立刻启动
systemctl enable frpc --now
```

## 验证服务