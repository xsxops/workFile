# NextCloud部署

## 前言

Nextcloud 通过客户端与服务器端的交互，实现文件同步、存储和管理，并通过多种安全措施保证数据的私密性和完整性，同时提供灵活的权限管理和协作功能。它提供了一种灵活的云存储和协作解决方案，用户可以完全控制自己的数据，并且能够通过各种客户端设备同步和共享文件。它的核心优点在于开放性、扩展性和自托管性，使得企业和个人用户能够建立一个安全、私密且可定制的云平台。此外，Nextcloud 支持大量的扩展功能，能够满足各种不同的使用场景，从简单的文件存储到复杂的企业级协作应用。

[TOC]



## 环境说明

| 操作系统       | CentOS Linux release 7.6       |
| -------------- | ------------------------------ |
| IP             | 49.235.129.167                 |
| docker-ce      | Docker version 26.1.4          |
| docker-compose | Docker Compose version v2.27.0 |
| NextCloud      | latest                         |
| AppUrl         | http://49.235.129.167:8080     |



**shell脚本**

```bash
cat > lsfile.sh << EOF
#!/bin/bash

ls -la
EOF
```

执行脚本

```bash
bash lsfile.sh
```

![image-20241226154632950](./images/NextCloud%20%E9%83%A8%E7%BD%B2/image-20241226154632950.png)

**防火墙和SE Linux状态**

> [!CAUTION]
>
> 腾讯云默认不开启 防火墙和SE Linux

```bash
# 查看 firewalld状态
systemctl status firewalld

# 查看 iptables 状态
systemctl status iptables

# 查看 SELinux 状态
sestatus
```

![image-20241227101422182](./images/NextCloud%20%E9%83%A8%E7%BD%B2/image-20241227101422182.png)

## 部署步骤

### 1.yum源配置

#### 1.1) 安装基础工具

```bash
yum install -y yum-utils device-mapper-persistent-data lvm2

# yum-utils：这是一个工具集，包含一些实用的命令，可以帮助你管理 YUM 仓库、包、缓存等。比如它包括了 yum-config-manager 命令，用于配置和管理 YUM 仓库
# device-mapper-persistent-data：这是 Docker 所需要的一个库，用于持久化存储设备映射的相关信息。它用于创建和管理 Docker 镜像存储的设备映射
# lvm2：这是 Linux 上的逻辑卷管理工具，Docker 在创建存储驱动时可能会用到 LVM（逻辑卷管理）技术，用于高效地管理存储。
```

####  1.2) 添加 Docker 的镜像源

```bash
#添加docker的源
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

#修改 Docker 仓库的 URL 为阿里云镜像源
sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo

# 更新YUmmy缓存
yum makecache fast
```

### 2 安装docker-ce

#### 2.1) yum 下载docker

```bash
yum -y install docker-ce
```

#### 2.2) 配置docker-ce 镜像下载地址

```bash
# 创建 docker 的配置目录
mkdir -p /etc/docker

# 为了防止镜像源不可用，下载镜像失败。百度搜集一些镜像仓库地址，多添加一些
cat > /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://hub.atomgit.com",
    "https://zd29wsn0.mirror.aliyuncs.com",
    "https://docker.m.daocloud.io",
    "https://dockerproxy.com",
    "https://mirror.baidubce.com",
    "https://docker.nju.edu.cn",
    "https://mirror.iscas.ac.cn",
    "https://dockerpull.org",
    "https://docker.1panel.dev",
    "https://docker.foreverlink.love",
    "https://docker.fxxk.dedyn.io",
    "https://docker.xn--6oq72ry9d5zx.cn",
    "https://docker.zhai.cm",
    "https://docker.5z5f.com",
    "https://a.ussh.net",
    "https://docker.cloudlayer.icu",
    "https://hub.littlediary.cn",
    "https://hub.crdz.gq",
    "https://docker.unsee.tech",
    "https://docker.kejilion.pro",
    "https://registry.dockermirror.com",
    "https://hub.rat.dev",
    "https://dhub.kubesre.xyz",
    "https://docker.nastool.de",
    "https://docker.udayun.com",
    "https://docker.rainbond.cc",
    "https://hub.geekery.cn",
    "https://docker.1panelproxy.com",
    "https://atomhub.openatom.cn",
    "https://docker.m.daocloud.io",
    "https://docker.1ms.run",
    "https://docker.linkedbus.com"
   ]
}
EOF

# 修改配置后重新加载使其生效
systemctl daemon-reload
```

#### 2.3) 启动docker

```bash
systemctl enable docker --now
```

#### 2.4) 检查服务状态

```bash
[root@VM-12-2-centos ~]# systemctl status docker.service 
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2024-12-26 16:06:18 CST; 5s ago
     Docs: https://docs.docker.com
 Main PID: 7262 (dockerd)
    Tasks: 8
   Memory: 29.3M
   CGroup: /system.slice/docker.service
           └─7262 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

Dec 26 16:06:18 VM-12-2-centos systemd[1]: Starting Docker Application Container Engine...
Dec 26 16:06:18 VM-12-2-centos dockerd[7262]: time="2024-12-26T16:06:18.245230084+08:00" level=info msg="Starting up"
Dec 26 16:06:18 VM-12-2-centos dockerd[7262]: time="2024-12-26T16:06:18.305665096+08:00" level=info msg="Loading containers: start."
Dec 26 16:06:18 VM-12-2-centos dockerd[7262]: time="2024-12-26T16:06:18.481441902+08:00" level=info msg="Loading containers: done."
Dec 26 16:06:18 VM-12-2-centos dockerd[7262]: time="2024-12-26T16:06:18.503414397+08:00" level=info msg="Docker daemon" commit=de5c9cf containerd-snapshotter=false storage-driver=overlay2 version=26.1.4
Dec 26 16:06:18 VM-12-2-centos dockerd[7262]: time="2024-12-26T16:06:18.503537709+08:00" level=info msg="Daemon has completed initialization"
Dec 26 16:06:18 VM-12-2-centos dockerd[7262]: time="2024-12-26T16:06:18.569183697+08:00" level=info msg="API listen on /run/docker.sock"
Dec 26 16:06:18 VM-12-2-centos systemd[1]: Started Docker Application Container Engine.

```

![image-20241226160640979](./images/NextCloud%20%E9%83%A8%E7%BD%B2/image-20241226160640979.png)

### 3.docker-compose安装

#### 3.1) 使用 curl 下载 二进制

```bash
# 使用 curl 下载 docker-compose 二进制文件
curl -L "https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose


curl：这是一个常用的命令行工具，用于从网络上下载文件。它支持多种协议，包括 HTTP 和 HTTPS。
-L：这个选项告诉 curl 如果遇到重定向（如 URL 发生变化）时自动跟随重定向。
"https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-$(uname -s)-$(uname -m)"：这是 Docker Compose 的下载地址。该 URL 动态地根据你的系统平台（操作系统和架构）来选择正确的二进制文件：
$(uname -s) 会被替换为操作系统的名称（例如，Linux、Darwin 等）。
$(uname -m) 会被替换为硬件架构（例如，x86_64、arm64 等）。
v2.27.0 是 Docker Compose 的版本号，表示你正在下载版本 2.27.0 的 Docker Compose。
-o /usr/local/bin/docker-compose：这是指定下载文件保存的位置。在这里，Docker Compose 的二进制文件将被保存到 /usr/local/bin/docker-compose。将其放在 /usr/local/bin/ 目录下是因为这个目录通常包含可执行文件，并且该目录通常已包含在系统的 PATH 环境变量中，允许用户从任何地方调用该命令。
```

#### 3.2) 增加权限

```bash
# 为 docker-compose 二进制文件添加执行权限
chmod +x /usr/local/bin/docker-compose
# 创建符号链接（软链接）,docker-compose 可以在系统的任何地方被调用，而不需要提供完整的路径。即使 /usr/local/bin 不在默认的 PATH 环境变量中，通过软链接到 /usr/bin，也能确保可以从命令行直接运行 docker-compos
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# 查看版本
docker-compose --version
```

![image-20241226161739226](./images/NextCloud%20%E9%83%A8%E7%BD%B2/image-20241226161739226.png)

### 4. 部署nextcloud

#### 4.1) 编写yaml 文件 

```yaml
cat > docker-compose.yml << EOF
version: '3.8'

services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: Ez123456789
      MYSQL_PASSWORD: Ez123456789
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextclouduser
    restart: always

  app:
    image: nextcloud:latest
    ports:
      - 10080:80
    volumes:
      - nextcloud_data:/var/www/html
    depends_on:
      - db
    environment:
      NEXTCLOUD_ADMIN_USER: admin
      NEXTCLOUD_ADMIN_PASSWORD: Ez123456789
    restart: always

volumes:
  db_data:
  nextcloud_data:

EOF
```

#### 4.2) YAML文件解释

```yaml
version: '3.8'  

services:     # 声明服务
  db:		  # 名称为DB
    image: mysql:5.7    #使用镜像为mysql5.7
    volumes:            # 数据库挂载到 /var/lib/mysql
      - db_data:/var/lib/mysql
    environment:		# 指定环境变量
      MYSQL_ROOT_PASSWORD: Ez123456789
      MYSQL_PASSWORD: Ez123456789
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextclouduser
    restart: always   # 重启规则设置为一直重启，如果容器遇到故障，则会总是重启
  app:
    image: nextcloud:latest   # nextcloud 的最新版镜像
    ports:
      - 10080:80              # 将端口通过 10080 进行暴露
    volumes:
      - nextcloud_data:/var/www/html        # 数据库挂载到/var/www/html这个目录是 Nextcloud 应用的数据存储位置。
    depends_on:                             # 声明启动顺序，先启动 db在启动app
      - db
    environment:                            # 指定环境变量
      NEXTCLOUD_ADMIN_USER: admin           # 管理员账号
      NEXTCLOUD_ADMIN_PASSWORD: Ez123456789 # 密码
    restart: always   # 重启规则设置为一直重启，如果容器遇到故障，则会总是重启
volumes:
  db_data:                  #db_data：用于 MySQL 数据库数据的持久化。
  nextcloud_data:           # nextcloud_data：用于存储 Nextcloud 应用数据（如文件、上传等）的持久化。
```

#### 4.3) 通过 docker-compose 启动服务

```bash
docker-compose up -d
```

#### 4.4) 查看容器是否部署成功

```bash
docker-compose ps
```

![image-20241226162336720](./images/NextCloud%20%E9%83%A8%E7%BD%B2/image-20241226162336720.png)

#### 4.5) 测试本机是否能够服务访问

```bash
curl -I http://127.0.0.1:10080
```

### 5.Nginx

#### 5.1) Nginx 部署

```bash
yum install -y nginx
```

#### 5.2) 配置nextcloud的 代理转发

```bash
# 将 nginx的8080 端口转发到本机的10080端口

cat > /etc/nginx/conf.d/nextcloud.conf << 'EOF'
# HTTP 重定向到 HTTPS
server {
    listen 8080;
    listen [::]:8080;
 #   server_name www.xxx.com;     # 输入域名，需要进行域名主体备案

    location / {
    #    return 301 https://$host$request_uri;
        proxy_pass http://localhost:10080;    # 直接代理到 Docker 的 10080 端口
        proxy_set_header Host $host;          # 保持原始请求的主机名
        proxy_set_header X-Real-IP $remote_addr;  # 传递客户端的真实 IP 地址
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  # 添加客户端 IP 到 X-Forwarded-For 头
        proxy_set_header X-Forwarded-Proto $scheme;  # 设置原始请求的协议（HTTP 或 HTTPS）
        # 解决 Nextcloud 的重定向问题
        proxy_set_header X-Forwarded-Port 8080;  # 指定使用的端口
    }
}
EOF
```

#### 5.3)  Nginx启动

```bash
# 检查配置文件是否存在问题
nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

# 启动nginx 并配置开机自启动
systemctl enable nginx --now

# 检查nginx 的运行状态
[root@VM-12-2-centos ~]# systemctl status nginx.service 
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2024-12-27 09:05:58 CST; 7s ago
  Process: 2948 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 2945 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 2943 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 2950 (nginx)
    Tasks: 3
   Memory: 2.1M
   CGroup: /system.slice/nginx.service
           ├─2950 nginx: master process /usr/sbin/nginx
           ├─2951 nginx: worker process
           └─2952 nginx: worker process

Dec 27 09:05:58 VM-12-2-centos systemd[1]: Starting The nginx HTTP and reverse proxy server...
Dec 27 09:05:58 VM-12-2-centos nginx[2945]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Dec 27 09:05:58 VM-12-2-centos nginx[2945]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Dec 27 09:05:58 VM-12-2-centos systemd[1]: Started The nginx HTTP and reverse proxy server.
```



### 6.使用 NextCloud

#### 6.1) 设置白名单安全组 开放 8080端口

![912731537f3937d5b39d9d427679fb3](./images/NextCloud%20%E9%83%A8%E7%BD%B2/912731537f3937d5b39d9d427679fb3.png)

#### 6.2) 修改NextCloud 信任域

```bash
cat > /var/www/html/config/config.php << 'EOF'
<?php
$CONFIG = array (
  'htaccess.RewriteBase' => '/',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' => 
  array (
    0 => 
    array (
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 => 
    array (
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
  'instanceid' => 'ocfo5f9yri09',
  'passwordsalt' => 'Iq6iwXwDkrcdRNHG8moMsi7g6pYKaQ',
  'secret' => 'IZXFYEfDlLHrHzvaS95mivz2/tCr9bipg2WuHXxj91d/6E3z',
  'trusted_domains' => 
  array (
    0 => 'localhost',
    1 => '49.235.129.167',
  ),
  'datadirectory' => '/var/www/html/data',
  'dbtype' => 'sqlite3',
  'version' => '27.0.2.1',
  'overwrite.cli.url' => 'http://49.235.129.167:8080',
  'overwritehost' => '49.235.129.167:8080',
  'installed' => true,
);
EOF

# 主要修改的这个区域，添加受信任的IP
  'trusted_domains' => 
  array (
    0 => 'localhost',
    1 => '49.235.129.167',
  ),
  
# 填写这个以防止转发错误  
    'overwritehost' => '49.235.129.167:8080',
```

![image-20241227091116541](./images/NextCloud%20%E9%83%A8%E7%BD%B2/image-20241227091116541.png)

#### 6.3) 访问服务 `http://49.235.129.167:8080`

> [!NOTE]
>
> User:           admin
>
> Passwd:      Ez123456789

![image-20241226174806980](./images/NextCloud%20%E9%83%A8%E7%BD%B2/image-20241226174806980.png)

#### 6.4) 上传文件目录

![image-20241226175243774](./images/NextCloud%20%E9%83%A8%E7%BD%B2/image-20241226175243774.png)

### 7.shell 脚本 一键部署

```shell
#!/bin/bash

# 获取服务器公网 IP
IP=$(curl -s ip.me)

# 1.关闭防火墙和SElinux
systemctl disable firewalld --now
systemctl disable iptables --now
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config


# 2. 更新系统并安装必要的工具
echo "正在更新系统并安装必要的工具..."
yum install -y yum-utils device-mapper-persistent-data lvm2 &> /dev/null

# 3. 配置 Docker 的国内镜像源
echo "正在配置 Docker 的国内镜像源..."
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo &> /dev/null
sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo &> /dev/null
yum makecache fast &> /dev/null

# 4. 安装 Docker CE
echo "正在安装 Docker CE..."
yum install -y docker-ce &> /dev/null

# 5. 配置 Docker 镜像加速器
echo "正在配置 Docker 镜像加速器..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << 'EOF'
{
  "registry-mirrors": [
    "https://hub.atomgit.com",
    "https://zd29wsn0.mirror.aliyuncs.com",
    "https://docker.m.daocloud.io",
    "https://dockerproxy.com",
    "https://mirror.baidubce.com",
    "https://docker.nju.edu.cn",
    "https://mirror.iscas.ac.cn",
    "https://dockerpull.org",
    "https://docker.1panel.dev",
    "https://docker.foreverlink.love",
    "https://docker.fxxk.dedyn.io",
    "https://docker.xn--6oq72ry9d5zx.cn",
    "https://docker.zhai.cm",
    "https://docker.5z5f.com",
    "https://a.ussh.net",
    "https://docker.cloudlayer.icu",
    "https://hub.littlediary.cn",
    "https://hub.crdz.gq",
    "https://docker.unsee.tech",
    "https://docker.kejilion.pro",
    "https://registry.dockermirror.com",
    "https://hub.rat.dev",
    "https://dhub.kubesre.xyz",
    "https://docker.nastool.de",
    "https://docker.udayun.com",
    "https://docker.rainbond.cc",
    "https://hub.geekery.cn",
    "https://docker.1panelproxy.com",
    "https://atomhub.openatom.cn",
    "https://docker.m.daocloud.io",
    "https://docker.1ms.run",
    "https://docker.linkedbus.com"
  ]
}
EOF

# 6. 重载 Docker 配置并启动 Docker 服务
echo "正在重载 Docker 配置并启动 Docker 服务..."
systemctl daemon-reload &> /dev/null
systemctl enable docker --now &> /dev/null

# 7. 安装 Docker Compose
echo "正在安装 Docker Compose..."
wget https://docker-compose-1333823419.cos.ap-guangzhou.myqcloud.com/docker-compose -O /usr/local/bin/docker-compose &> /dev/null
chmod +x /usr/local/bin/docker-compose &> /dev/null
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose &> /dev/null

# 8. 创建目录并生成 docker-compose.yml 文件
echo "正在创建目录并生成 docker-compose.yml 文件..."
mkdir -p /root/nextcloud &> /dev/null
cat > /root/nextcloud/docker-compose.yml << EOF
version: '3.8'

services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: Ez123456789
      MYSQL_PASSWORD: Ez123456789
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextclouduser
    restart: always

  app:
    image: nextcloud:latest
    ports:
      - 10080:80
    volumes:
      - nextcloud_data:/var/www/html
    depends_on:
      - db
    environment:
      NEXTCLOUD_ADMIN_USER: admin
      NEXTCLOUD_ADMIN_PASSWORD: Ez123456789
    restart: always

volumes:
  db_data:
  nextcloud_data:
EOF

# 9. 使用 Docker Compose 启动 Nextcloud 服务
echo "正在启动 Nextcloud 服务..."
cd /root/nextcloud && docker-compose up -d &> /dev/null

# 10. 安装 Nginx
echo "正在安装 Nginx..."
yum install -y nginx &> /dev/null

# 11. 配置 Nginx 代理 Nextcloud
echo "正在配置 Nginx 代理 Nextcloud..."
cat > /etc/nginx/conf.d/nextcloud.conf << EOF
server {
    listen 8080;
    listen [::]:8080;

    location / {
        proxy_pass http://localhost:10080;    # 直接代理到 Docker 的 10080 端口
        proxy_set_header Host ${IP}:8080;  # 强制设置为外部 IP 和端口
        proxy_set_header X-Real-IP \$remote_addr;  # 传递客户端的真实 IP 地址
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;  # 添加客户端 IP 到 X-Forwarded-For 头
        proxy_set_header X-Forwarded-Proto \$scheme;  # 设置原始请求的协议（HTTP 或 HTTPS）
        proxy_set_header X-Forwarded-Port 8080;  # 指定使用的端口
    }
}
EOF


# 12. 启动 Nginx 服务
echo "正在启动 Nginx 服务..."
systemctl enable nginx --now &> /dev/null

# 13. 输出安装完成
echo "Nextcloud 部署完成，访问: http://$IP:8080"
```





## FAQ

### docker 命令

#### docker 常用参数

```bash
attach: 连接到正在运行的容器。
build: 构建 Docker 镜像。
commit: 保存修改后的容器副本为一个新的镜像。
cp: 复制文件或目录到和从容器中的文件系统。
create: 创建一个新的容器。
exec: 在正在运行的容器中执行命令。
images: 列出 Docker 镜像。
kill: 终止指定的容器进程。
logs: 显示容器的日志输出。
pause: 暂停容器中的所有进程。
port: 查看映射端口。
ps: 列出容器。
pull: 从 Docker Registry 下载镜像。
push: 将本地的 Docker 镜像上传到 Docker Registry。
rename: 重命名容器。
restart: 重启容器。
rm: 删除一个或多个容器。
rmi: 删除一个或多个镜像。
run: 创建并运行一个新的容器。
start: 启动一个或多个已经存在的容器。
stop: 停止一个或多个正在运行的容器。
tag: 标记本地镜像。
top: 显示容器的进程信息。
unpause: 恢复容器中的所有进程。
version: 显示 Docker 版本信息。
```

#### 常用命令

##### 1) 容器相关命令

```bash
# 启动容器  启动一个已停止的容器。
docker start <container_id_or_name>

# 停止容器  停止运行中的容器。
docker stop <container_id_or_name>

#　重启容器 重启一个正在运行的容器。
docker restart <container_id_or_name>

# 查看容器状态 查看当前正在运行的容器。
docker ps

# 查看所有容器（包括停止的） 显示所有容器，不管它们是否处于运行状态。
docker ps -a

# 进入容器内部（交互模式） 进入容器内部，并启动一个  shell。
docker exec -it <container_id_or_name> 

# 查看容器日志 查看容器的输出日志。
docker logs <container_id_or_name>

#删除容器 删除一个停止的容器。如果容器正在运行，先停止它。
docker rm <container_id_or_name>

# 强制删除正在运行的容器
docker rm -f <container_id_or_name>
```

##### 2) 镜像相关命令

```bash
#列出所有镜像 查看本地的所有镜像。
docker images

# 拉取镜像 从 Docker Hub 或其他镜像仓库拉取镜像。
docker pull <image_name>

#删除镜像 删除本地镜像。如果该镜像被容器使用，则删除前需要先停止并删除容器。
docker rmi <image_name_or_id>

# 查看镜像详细信息
docker inspect <image_name_or_id>
```

##### 3) 网络相关命令

```bash
# 列出所有网络 查看当前存在的 Docker 网络。
docker network ls

# 查看网络详情
docker network inspect <network_name>

#创建网络
docker network create <network_name>
```

##### 4) 容器与镜像管理

```bash
# 查看所有镜像和容器信息 查看磁盘使用情况，包括镜像、容器、卷和构建缓存。
docker system df

#清理未使用的资源（镜像、容器、卷等） 删除所有未使用的容器、网络、未标记的镜像和构建缓存。
docker system prune

#清理未使用的镜像
docker image prune
```

### docker-compose 常用命令

```bash
docker-compose -h：查看帮助信息，包括可用的命令和选项。

docker-compose up：启动所有在docker-compose文件中定义的服务，并将日志输出到控制台。

docker-compose up -d：启动所有docker-compose服务并后台运行。

docker-compose down：停止并删除容器、网络、卷、镜像。

docker-compose exec <service-id> <command>：进入容器实例内部。例如：docker-compose exec docker-compose yml文件中写的服务id /bin/bash

docker-compose ps：展示当前docker-compose编排过的运行的所有容器。

docker-compose top：展示当前docker-compose编排过的容器进程。

docker-compose logs <service-id>：查看特定服务的容器输出日志。

docker-compose config：检查配置是否正确，如果有问题会有输出。

docker-compose config -g：检查配置并输出结果。

docker-compose restart：重启服务。

docker-compose start：启动服务。

docker-compose stop：停止服务。
```

