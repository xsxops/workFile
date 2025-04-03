### Nginx 配置 认证登录并文件目录形式访问

**安装nginx**

```shell
yum install -y nginx
 yum install -y httpd-tools
```

**创建密码文件**

```shell
htpasswd -c /etc/nginx/.htpasswd xty
输入密码
再次输入密码

#删除用户
htpasswd -D /etc/nginx/.htpasswd xty
```

**修改nginx的配置文件**

```shell
[root@hecs-131633 package]# cat /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       49999;
        listen       [::]:49999;
        server_name  _;
        root         /var/www/html/;
 	    index package;
            autoindex on;
            autoindex_exact_size off;
            autoindex_localtime on;
	
	location /package {
            auth_basic "Restricted Access";
            auth_basic_user_file /etc/nginx/.htpasswd;
        }
        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
}

```

