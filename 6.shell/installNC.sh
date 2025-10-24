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