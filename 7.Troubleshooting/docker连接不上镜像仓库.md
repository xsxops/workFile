正常运行环境突然连接不到镜像仓库

![img](file:///C:/Users/csy/AppData/Local/Temp/msohtmlclip1/01/clip_image001.png)

 

1.检查本地网络是否正常

Ping www.baidu.com

 

2.检查防火墙是否关闭

Systemctl status firewalld

Systemctl status networking    

Systemctl status ufw      

 

3.指定其他镜像仓库地址看能否正常使用

docker pull daocloud.io/library/nginx



4.修改默认仓库地址 

Vim /etc/docker/daemon.json

 

{

 "registry-mirrors":["https://6kx4zyno.mirror.aliyuncs.com"]

}

 

 

 

 

 