# LAMP架构部署



## 前言

LAMP是一个经典的开源技术栈，用于构建和运行动态网站及Web应用。它由以下四个组件组成：

1. **Linux**：操作系统，提供稳定、安全的环境，是整个架构的基础。
2. **Apache**：Web服务器，负责处理HTTP请求和响应，为用户提供静态或动态内容。
3. **MySQL**：关系型数据库管理系统，负责存储和管理网站或应用的数据。
4. **PHP/Perl/Python**：脚本语言，用于开发动态内容和后端逻辑，与数据库交互，生成动态网页。

这个架构简单、高效、稳定，是许多中小型Web应用开发的首选解决方案。



## 集群规划信息

| IP：          | 中间件 | 版本                  |
| ------------- | ------ | --------------------- |
| 192.168.0.103 | Apache | Apache/2.4.6 (CentOS) |
|               | MySQL  | 5.5.68-MariaDB        |
|               | PHP    | PHP 5.4.16            |

## 基础环境部署--操作系统

**安装包和ISO**

![image-20241223094135591](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223094135591.png)

**使用VMware Workstation创建虚拟机，选中已有的镜像文件**

![image-20241223094739660](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223094739660.png)

**硬件配额设置**

![image-20241223100140858](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223100140858.png)

**自定义文件分区目录**

![image-20241223101329157](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223101329157.png)

**将swap和home都进行删除，保留boot和/分区，将空间大小都分配给 /**

![image-20241223101424887](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223101424887.png)

![image-20241223101623251](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223101623251.png)

#### 1) 关闭Swapoff、Elinux

```bash
swapoff -a && sed -ri 's/.*swap.*/#&/' /etc/fstab
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
```



#### 2) 修改主机名称

```bash
sudo hostnamectl sethostname leijindong
bash
```

#### 3) 查看虚拟机IP地址

##### 3.1 查看内网IP

```bash
ip a ls ens33

# ens33 为网卡名称 
```

##### 3.2 查看公网IP

```bash
curl http://ip.me
```

##### 3.3 查看bash登陆用户

```bash
w
```

![image-20241223131727894](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223131727894.png)

## 1.Apache

### 1安装

#### 1.1) 配置阿里云yum源

```bash
# 备份yum源
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
# 使用阿里云 yum 源
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
# 生成缓存
yum clean all && yum makecache
```

#### 1.2) yum安装Apache：

```bash
yum install httpd -y
systemctl enable httpd --now

[root@leijindong ~]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since Sun 2024-12-22 21:21:18 PST; 6s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 59940 (httpd)
   Status: "Processing requests..."
    Tasks: 6
   CGroup: /system.slice/httpd.service
           ├─59940 /usr/sbin/httpd -DFOREGROUND
           ├─59941 /usr/sbin/httpd -DFOREGROUND
           ├─59942 /usr/sbin/httpd -DFOREGROUND
           ├─59943 /usr/sbin/httpd -DFOREGROUND
           ├─59944 /usr/sbin/httpd -DFOREGROUND
           └─59945 /usr/sbin/httpd -DFOREGROUND

Dec 22 21:21:07 leijindong systemd[1]: Starting The Apache HTTP Server...
Dec 22 21:21:13 leijindong httpd[59940]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using fe80::833:f5c5:db05:eaf3. Set the 'ServerName' directive globally to suppress this message
Dec 22 21:21:18 leijindong systemd[1]: Started The Apache HTTP Server.
```

#### 1.3) 修改防火墙规则

```bash
[root@leijindong ~]# sudo firewall-cmd --permanent --add-service=http
success
[root@leijindong ~]# sudo firewall-cmd --reload
success
```

### 2 修改访问默认页面进行验证

#### 2.1) 修改权限

```bash
echo "<h1>My Name: leijingdong</h1><p>学号: 0233545</p>" > /var/www/html/index.html
chmod 644 /var/www/html/index.html
```

#### 2.2) 访问验证

```bash
[root@leijindong ~]# curl http://localhost:80
<h1>My Name: leijingdong</h1><p>学号: 0233545</p>
[root@leijindong ~]# curl -I http://localhost:80
HTTP/1.1 200 OK
Date: Mon, 23 Dec 2024 05:32:31 GMT
Server: Apache/2.4.6 (CentOS)
Last-Modified: Mon, 23 Dec 2024 05:22:03 GMT
ETag: "34-629e92d43b9dd"
Accept-Ranges: bytes
Content-Length: 52
Content-Type: text/html; charset=UTF-8
```

![image-20241223132544718](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223132544718.png)

## 2. Mysql

### 2.1 yum安装Mysql：

```bash
yum install mariadb-server -y
systemctl enable mariadb --now

[root@leijindong ~]# systemctl enable mariadb --now
Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb.service to /usr/lib/systemd/system/mariadb.service.
[root@leijindong ~]# systemctl status mariadb
● mariadb.service - MariaDB database server
   Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; vendor preset: disabled)
   Active: active (running) since Sun 2024-12-22 21:30:46 PST; 2s ago
  Process: 60246 ExecStartPost=/usr/libexec/mariadb-wait-ready $MAINPID (code=exited, status=0/SUCCESS)
  Process: 60162 ExecStartPre=/usr/libexec/mariadb-prepare-db-dir %n (code=exited, status=0/SUCCESS)
 Main PID: 60245 (mysqld_safe)
    Tasks: 20
   CGroup: /system.slice/mariadb.service
           ├─60245 /bin/sh /usr/bin/mysqld_safe --basedir=/usr
           └─60410 /usr/libexec/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib64/mysql/plugin --log-error=/var/log/mariadb/mariadb.log --pid-file=/var/run/mariadb/mariadb.pid --socket=/var/lib/mysql/mysql.sock

Dec 22 21:30:43 leijindong mariadb-prepare-db-dir[60162]: MySQL manual for more instructions.
Dec 22 21:30:43 leijindong mariadb-prepare-db-dir[60162]: Please report any problems at http://mariadb.org/jira
Dec 22 21:30:43 leijindong mariadb-prepare-db-dir[60162]: The latest information about MariaDB is available at http://mariadb.org/.
Dec 22 21:30:43 leijindong mariadb-prepare-db-dir[60162]: You can find additional information about the MySQL part at:
Dec 22 21:30:43 leijindong mariadb-prepare-db-dir[60162]: http://dev.mysql.com
Dec 22 21:30:43 leijindong mariadb-prepare-db-dir[60162]: Consider joining MariaDB's strong and vibrant community:
Dec 22 21:30:43 leijindong mariadb-prepare-db-dir[60162]: https://mariadb.org/get-involved/
Dec 22 21:30:44 leijindong mysqld_safe[60245]: 241222 21:30:44 mysqld_safe Logging to '/var/log/mariadb/mariadb.log'.
Dec 22 21:30:44 leijindong mysqld_safe[60245]: 241222 21:30:44 mysqld_safe Starting mysqld daemon with databases from /var/lib/mysql
Dec 22 21:30:46 leijindong systemd[1]: Started MariaDB database server.
```

![image-20241223133107363](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223133107363.png)

### 2.2  配置数据库

#### 2.2.1) 安全配置

```bash
# 设置root密码，按提示完成配置。
mysql_secure_installation

#修改端口号为 13306,提高安全性
[root@leijindong ~]# cat /etc/my.cnf
[mysqld]
port=13306
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
# Settings user and group are ignored when systemd is used.
# If you need to run mysqld under a different user or group,
# customize your systemd unit file for mariadb according to the
# instructions in http://fedoraproject.org/wiki/Systemd

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d

[root@leijindong ~]# systemctl restart mariadb
[root@leijindong ~]# sudo netstat -tuln | grep 13306
tcp        0      0 0.0.0.0:13306           0.0.0.0:*               LISTEN  
```

![image-20241223133824697](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223133824697.png)

#### 2.2.2) 登录数据库：

```sql
[root@leijindong ~]# mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 2
Server version: 5.5.68-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
```

#### 2.2.3) 创建数据库和用户，插入记录：

```sql
CREATE DATABASE testdb;
USE testdb;
CREATE TABLE testtable (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100));
INSERT INTO testtable (name) VALUES ('leijindong');
MariaDB [testdb]> SELECT * FROM testtable;
+----+------------+
| id | name       |
+----+------------+
|  1 | leijindong |
+----+------------+
1 row in set (0.00 sec)
```

#### 2.3.4) 修改防火墙规则

```bash
[root@leijindong ~]# sudo firewall-cmd --permanent --add-port=13306/tcp
success
[root@leijindong ~]# sudo firewall-cmd --reload
success
[root@leijindong ~]# sudo firewall-cmd --list-ports
13306/tcp
```

#### 2.3.5) 配置远程访问

```bash
#注释掉或删除 bind-address=127.0.0.1

#授予远程权限：
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123' WITH GRANT OPTION;
FLUSH PRIVILEGES;

# 重启MySQL服务：
systemctl restart mariadb
```

![image-20241223142348015](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223142348015.png)

![image-20241223142419347](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223142419347.png)



## 3.部署PHP/Perl/Python应用

### 3.1 安装PHP

```bash
yum install php php-mysql -y
```

### 3.2 安装phpMyAdmin

```bash
yum install epel-release -y
yum install phpmyadmin -y
```

### 3.3. 配置phpMyAdmin

备份修改配置文件允许远程访问：

```bash
cp /etc/httpd/conf.d/phpMyAdmin.conf{,-bak}

sed -i -e 's/Require ip 127\.0\.0\.1/Require all granted/g' \
       -e 's/Require ip ::1/Require all granted/g' \
       -e 's/Deny from All/Allow from All/g' \
       -e 's/Allow from 127\.0\.0\.1/Allow from All/g' \
       -e 's/Allow from ::1/Allow from All/g' \
       /etc/httpd/conf.d/phpMyAdmin.conf
       
[root@leijindong ~]# grep -Ev '^\s*(#|$)' /etc/httpd/conf.d/phpMyAdmin.conf
Alias /phpMyAdmin /usr/share/phpMyAdmin
Alias /phpmyadmin /usr/share/phpMyAdmin
<Directory /usr/share/phpMyAdmin/>
   AddDefaultCharset UTF-8
   <IfModule mod_authz_core.c>
     <RequireAny>
       Require all granted
       Require all granted
     </RequireAny>
   </IfModule>
   <IfModule !mod_authz_core.c>
     Order Deny,Allow
     Allow from All
     Allow from All
     Allow from All
   </IfModule>
</Directory>
<Directory /usr/share/phpMyAdmin/setup/>
   <IfModule mod_authz_core.c>
     <RequireAny>
       Require all granted
       Require all granted
     </RequireAny>
   </IfModule>
   <IfModule !mod_authz_core.c>
     Order Deny,Allow
     Allow from All
     Allow from All
     Allow from All
   </IfModule>
</Directory>
<Directory /usr/share/phpMyAdmin/libraries/>
   <IfModule mod_authz_core.c>
     Require all denied
   </IfModule>
   <IfModule !mod_authz_core.c>
     Order Deny,Allow
     Allow from All
     Allow from None
   </IfModule>
</Directory>
<Directory /usr/share/phpMyAdmin/setup/lib/>
   <IfModule mod_authz_core.c>
     Require all denied
   </IfModule>
   <IfModule !mod_authz_core.c>
     Order Deny,Allow
     Allow from All
     Allow from None
   </IfModule>
</Directory>
<Directory /usr/share/phpMyAdmin/setup/frames/>
   <IfModule mod_authz_core.c>
     Require all denied
   </IfModule>
   <IfModule !mod_authz_core.c>
     Order Deny,Allow
     Allow from All
     Allow from None
   </IfModule>
</Directory>
```

### 3.4 创建PHP应用

##### 3.4.1 创建PHP测试文件：

```bash
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
```

##### 3.4.2 创建连接数据库的PHP脚本 ( `/var/www/html/db.php`)：

```php
cat > /var/www/html/db.php <<'EOF'
<?php
$servername = "192.168.0.103"; // 数据库服务器地址
$username = "root";            // 数据库用户名
$password = "123";             // 数据库密码
$dbname = "testdb";            // 数据库名称
$port = 13306;                 // MariaDB 端口号

// 创建连接
$conn = new mysqli($servername, $username, $password, $dbname, $port);

// 检查连接
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT * FROM testtable";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        echo "ID: " . $row["id"]. " - Name: " . $row["name"]. "<br>";
    }
} else {
    echo "0 results";
}
$conn->close();
?>
EOF
```

##### 3.4.3) 访问验证

```bash
[root@leijindong ~]# curl -I http://127.0.0.1:80/db.php
HTTP/1.1 200 OK
Date: Mon, 23 Dec 2024 07:10:55 GMT
Server: Apache/2.4.6 (CentOS) PHP/5.4.16
X-Powered-By: PHP/5.4.16
Content-Type: text/html; charset=UTF-8

[root@leijindong ~]# curl http://127.0.0.1:80/db.php
ID: 1 - Name: leijindong<br>
```

![image-20241223151122624](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223151122624.png)

![image-20241223151442713](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223151442713.png)

## 4.邮件服务

### 4.1 安装并配置自启

```bash
yum install mailx sendmail -y
systemctl enable sendmail --now
```

### 4.2 修改配置文件

```bash
cp /etc/mail.rc{,.bak}
```

```bash
cat >> /etc/mail.rc <<EOF
set smtp=smtp://smtp.163.com:25
set smtp-auth=login
set smtp-auth-user=13121423367@163.com
set smtp-auth-password=你的网易邮箱授权码
set from=13121423367@163.com
EOF
```

### 4.3 邮件测试验证

```bash
echo "测试邮件内容" | mail -s "测试邮件标题" 13121423367@163.com
```

![image-20241223163839187](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223163839187.png)

### 2.编写脚本

```
AUTO_MODE=true ./task_manager.sh
```

```bash
#!/bin/bash

# 设置模式变量：AUTO_MODE=true 则为自动运行模式
AUTO_MODE=false  # 默认为手动模式

# 日志文件路径和备份目录
APACHE_LOG_DIR="/var/log/httpd"  # 实际路径
ACCESS_LOG="$APACHE_LOG_DIR/access_log"  # 访问日志
ERROR_LOG="$APACHE_LOG_DIR/error_log"    # 错误日志
BACKUP_DIR="/backup/apache_logs"
MONITOR_LOG="/var/log/service_monitor.log"
RESOURCE_MONITOR_LOG="/var/log/resource_monitor.log"

# 邮件通知设置
ADMIN_EMAIL="13121423367@163.com"

# 检查和创建备份目录
function ensure_backup_dir {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi
}

# 任务1：清理和备份超过30天的日志
function backup_and_clean_logs {
    ensure_backup_dir
    echo "开始备份和清理日志..."
    find "$APACHE_LOG_DIR" -type f -name "*.log" -mtime +30 -exec tar -czf "$BACKUP_DIR/apache_logs_$(date +%Y%m%d).tar.gz" {} + -exec rm -f {} +
    echo "日志备份完成，保存在 $BACKUP_DIR。" | tee -a "$MONITOR_LOG"
}

# 任务2：实时监控服务运行状态
function monitor_services {
    echo "开始监控服务状态..."
    SERVICES=("httpd" "mariadb")  # 可根据需要调整服务名称
    for service in "${SERVICES[@]}"; do
        if ! systemctl is-active --quiet "$service"; then
            echo "$(date): 服务 $service 已停止，正在尝试重启..." | tee -a "$MONITOR_LOG"
            systemctl restart "$service"
            if ! systemctl is-active --quiet "$service"; then
                echo "$(date): 服务 $service 重启失败，通知管理员。" | tee -a "$MONITOR_LOG"
                echo "服务 $service 重启失败，请检查服务器。" | mail -s "服务故障通知" "$ADMIN_EMAIL"
            else
                echo "$(date): 服务 $service 重启成功。" | tee -a "$MONITOR_LOG"
            fi
        else
            echo "$(date): 服务 $service 正常运行。" | tee -a "$MONITOR_LOG"
        fi
    done
}

# 任务3：Apache 日志流量分析（可选功能）
function analyze_logs {
    echo "开始分析 Apache 日志..."
    if [ -f "$ACCESS_LOG" ]; then
        echo "访问最多的 IP 地址："
        awk '{print $1}' "$ACCESS_LOG" | sort | uniq -c | sort -nr | head -10

        echo "访问最多的 URL："
        awk '{print $7}' "$ACCESS_LOG" | sort | uniq -c | sort -nr | head -10

        echo "返回码统计："
        awk '{print $9}' "$ACCESS_LOG" | sort | uniq -c | sort -nr
    else
        echo "无法找到 Apache 访问日志！"
    fi
}

# 任务4：实时监控资源使用情况（修改后实现实时监控并只显示最新结果）
function monitor_resources {
    echo "开始实时监控资源使用情况..."
    > "$RESOURCE_MONITOR_LOG"  # 每次清空文件

    while true; do
        # 写入最新监控结果
        echo "====== $(date '+%Y-%m-%d %H:%M:%S') ======" > "$RESOURCE_MONITOR_LOG"
        echo "CPU 和内存使用情况：" >> "$RESOURCE_MONITOR_LOG"
        top -b -n 1 | head -n 10 >> "$RESOURCE_MONITOR_LOG"

        echo "" >> "$RESOURCE_MONITOR_LOG"
        echo "磁盘 I/O 情况：" >> "$RESOURCE_MONITOR_LOG"
        iostat -x 1 1 | tail -n +3 >> "$RESOURCE_MONITOR_LOG"

        echo "" >> "$RESOURCE_MONITOR_LOG"
        echo "网络流量：" >> "$RESOURCE_MONITOR_LOG"
        ifstat 1 1 | tail -n 1 >> "$RESOURCE_MONITOR_LOG"

        # 清屏并打印最新监控结果
        clear
        cat "$RESOURCE_MONITOR_LOG"

        # 间隔时间（例如 5 秒）
        sleep 5
    done
}

# 主菜单函数
function main_menu {
    if [ "$AUTO_MODE" = true ]; then
        # 自动运行模式
        backup_and_clean_logs
        monitor_services
        exit 0
    fi

    # 手动模式菜单
    while true; do
        echo "请选择要执行的任务："
        echo "1) Apache 日志流量分析"
        echo "2) 清理和备份 Apache 日志"
        echo "3) 实时监控资源使用情况"
        echo "4) 实时监控服务运行状态"
        echo "5) 全部执行"
        echo "6) 退出"
        read -p "输入选项 (1-6): " choice

        case $choice in
            1) analyze_logs ;;
            2) backup_and_clean_logs ;;
            3) monitor_resources ;;  # 实时监控资源
            4) monitor_services ;;
            5)
                analyze_logs
                backup_and_clean_logs
                monitor_resources &
                monitor_services
                echo "所有任务执行完成！"
                ;;
            6) exit 0 ;;
            *) echo "无效选项，请重试！" ;;
        esac
    done
}

# 启动脚本主程序
main_menu

```

### 3.脚本验证

#### 3.1  Apache 日志流量分析

![image-20241223170812878](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223170812878.png)

#### 3.2 清理和备份 Apache 日志

![image-20241223170834509](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223170834509.png)

#### 3.实时监控资源使用情况

![image-20241223165214330](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223165214330.png)

#### 3.4 实时监控服务运行状态

![image-20241223164441692](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223164441692.png)

#### 3.5 故障邮件通知

![image-20241223171445666](./images/Linux%E5%9F%BA%E7%A1%80%E4%B8%8E%E5%BA%94%E7%94%A8/image-20241223171445666.png)



### 1.设置crontab定时任务

#### 1.1 编写crontab 规则

```bash
crontab -e
# 每五分钟执行一次
*/5 * * * * /root/task_manager.sh >> /var/log/server_monitor_cron.log 2>&1
```

```bash
[root@leijindong ~]# crontab -l
*/5 * * * * /root/task_manager.sh >> /var/log/server_monitor_cron.log 2>&1

```

### 2.设置firewalld规则

#### 2.1 禁止被ping

```bash
firewall-cmd --permanent --add-icmp-block=echo-request

#重新加载防火墙规则
firewall-cmd --reload
```





