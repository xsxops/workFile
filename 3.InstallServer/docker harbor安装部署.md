# docker harbor安装部署



## yum安装docker-ce

```shell
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo

yum makecache fast
yum -y install docker-ce
systemctl start docker &&systemctl enable docker

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://zd29wsn0.mirror.aliyuncs.com"]
}
EOF
systemctl daemon-reload
systemctl restart 

yum install -y iptables-services vim lrzsz zip wget net-tools unzip wget sysdig
```



## 设置基础环境

```shell
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
yum makecache fast

selinuxdefcon 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
if egrep "7.[0-9]" /etc/redhat-release &>/dev/null; then
    systemctl stop firewalld
    systemctl disable firewalld
fi
yum install -y iptables-services vim lrzsz zip wget net-tools unzip wget sysdig
systemctl enable iptables --now

yum -y install docker-ce
systemctl start docker &&systemctl enable docker

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://zd29wsn0.mirror.aliyuncs.com"]
}
EOF
systemctl daemon-reload
systemctl restart 

if ! grep HISTTIMEFORMAT /etc/bashrc; then
    echo 'export HISTTIMEFORMAT="%F %T `whoami` "' >> /etc/bashrc
fi
if ! grep "* soft nofile 65535" /etc/security/limits.conf &>/dev/null; then
    cat >> /etc/security/limits.conf << EOF
    * soft nofile 65535
    * hard nofile 65535
EOF
fi
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_tw_buckets = 20480
net.ipv4.tcp_max_syn_backlog = 20480
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_fin_timeout = 20
EOF
echo "0" > /proc/sys/vm/swappiness
sed -i '/SELINUX/{s/permissive/disabled/}' /etc/selinux/config
setenforce 0

#https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64
curl -L "https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version
```

## 安装harbor

下载包    `https://github.com/goharbor/harbor/releases`



**1、解压**

```shell
cd /opt && wget https://github.com/goharbor/harbor/releases/download/v2.3.0/harbor-online-installer-v2.3.0.tgz
tar -zxvf  harbor-online-installer-v2.3.0.tgz
```

**2.对配置文件进行备份**

```shell
cd harbor
cp harbor.yml.tmpl harbor.yml
```

**3、对配置文件进行修改**

**修改hostname改为本机ip、注释掉https内容、修改持久化目录、修改默认初始密码**

```bash
vim harbor.yml
hostname: 192.168.154.128
harbor_admin_password: XU!@sx0629
```

**4.执行脚本安装**

```shell
sh install.sh
```

**5.将harbor仓库地址添加为Docker信任列表**

在/etc/docker/创建daemon.json文件

```shell
vim /etc/docker/daemon.json

{
  "registry-mirrors": ["https://zd29wsn0.mirror.aliyuncs.com"],

  "insecure-registries":["192.168.154.128"]
}

systemctl restart docker
```


6.登录Harbor，提交推送

```shell
# 下载jdk1.8
docker pull openjdk:8-jdk
# 验证安装版本
docker run --rm openjdk:8-jdk java -version
openjdk version "1.8.0_312"
OpenJDK Runtime Environment (build 1.8.0_312-b07)
OpenJDK 64-Bit Server VM (build 25.312-b07, mixed mode)

# 登录Harbo
docker login -u admin -p 'XU!@sx0629' 192.168.154.128

# 给镜像打标签
docker tag openjdk:8-jdk 192.168.154.128/xtyv1/jdk:1.8

# 推送镜像
docker push 192.168.154.128/xtyv1/jdk:1.8
```

7.其他服务器登录Harbor

```shell
vi /etc/docker/daemon.json
添加一行参数  "insecure-registries":["192.168.154.128"]

systemctl restart docke
docker login -u admin -p XU!@sx0629 192.168.154.128

下载镜像
docker pull 192.168.154.128/lxx/lxx-test-nginx:v1
```







