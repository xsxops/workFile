# **Supervisor**

 

## **1、Supervisor介绍**

Supervisor是用Python开发的一套通用的进程管理程序，能将一个普通的命令行进程变为后台daemon，并监控进程状态，异常退出时能自动重启。它是通过fork/exec的方式把这些被管理的进程当作supervisor的子进程来启动，这样只要在supervisor的配置文件中，把要管理的进程的可执行文件的路径写进去即可。

也实现当子进程挂掉的时候，父进程可以准确获取子进程挂掉的信息的，可以选择是否自己启动和报警。supervisor还提供了一个功能，可以为supervisord或者每个子进程，设置一个非root的user，这个user就可以管理它对应的进程



 

## 2、**Supervisor安装**

#### ***\*2.1 yum安装，配置好yum源后可直接进行安装\****

yum -y install supervisor

 

#### ***\*2.2 apt安装  Debian/Ubuntu操作系统\**** 

apt-get install supervisor

 

#### ***\*2.3 pip安装\****

pip install supervisor

 

#### ***\*2.4 easy_install安装\****

easy_install supervisor

 

## **3、supervisor使用**

#### ***\*supervisor配置文件：/etc/supervisord.conf\****

***\*注意：supervisor的配置文件默认是不全的，不过在大部分的情况下，基本功能已经满足\****

 

 

#### ***\*子进程配置文件路径: / etc/supervisord.d/\****

***\*注意：默认子进程配置文件为ini格式，可在supervisor主配置文件中修改\****

 

 

 

## **4、配置文件说明**

 

#### ***\*supervisor.conf配置文件说明：\****

[unix_http_server]

file=/tmp/supervisor.sock  		 ;UNIX socket 文件，supervisorctl 会使用

;chmod=0700         	;socket文件的mode，默认是0700

;chown=nobody:nogroup    	 ;socket文件的owner，格式：uid:gid

 

;[inet_http_server]    			 ;HTTP服务器，提供web管理界面

;port=127.0.0.1:9001     	;Web管理后台运行的IP和端口，如果开放到公网，需要注意安全性

;username=user       		 ;登录管理后台的用户名

;password=123        			 ;登录管理后台的密码

 

[supervisord]

logfile=/tmp/supervisord.log 			;日志文件，默认是 $CWD/supervisord.log

logfile_maxbytes=50MB    		 ;日志文件大小，超出会rotate，默认 50MB，如果设成0，表示不限制大小

logfile_backups=10      	;日志文件保留备份数量默认10，设为0表示不备份

loglevel=info         ;日志级别，默认info，其它: debug,warn,trace

pidfile=/tmp/supervisord.pid ;pid 文件

nodaemon=false        ;是否在前台启动，默认是false，即以 daemon 的方式启动

minfds=1024          ;可以打开的文件描述符的最小值，默认 1024

minprocs=200         ;可以打开的进程数的最小值，默认 200

 

[supervisorctl]

serverurl=unix:///tmp/supervisor.sock ;通过UNIX socket连接supervisord，路径与unix_http_server部分的file一致

;serverurl=http://127.0.0.1:9001 ; 通过HTTP的方式连接supervisord

 

; [program:xx]是被管理的进程配置参数，xx是进程的名称

[program:xx]

command=/opt/apache-tomcat-8.0.35/bin/catalina.sh run  ; 程序启动命令

autostart=true    ; 在supervisord启动的时候也自动启动

startsecs=10     ; 启动10秒后没有异常退出，就表示进程正常启动了，默认为1秒

autorestart=true   ; 程序退出后自动重启,可选值：[unexpected,true,false]，默认为unexpected，表示进程意外杀死后才重启

startretries=3    ; 启动失败自动重试次数，默认是3

user=tomcat      ; 用哪个用户启动进程，默认是root

priority=999     ; 进程启动优先级，默认999，值小的优先启动

redirect_stderr=true ; 把stderr重定向到stdout，默认false

stdout_logfile_maxbytes=20MB  ; stdout 日志文件大小，默认50MB

stdout_logfile_backups = 20  ; stdout 日志文件备份数，默认是10

; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动创建目录（supervisord 会自动创建日志文件）

stdout_logfile=/opt/apache-tomcat-8.0.35/logs/catalina.out

stopasgroup=false   ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程

killasgroup=false   ;默认为false，向进程组发送kill信号，包括子进程

 

;包含其它配置文件

[include]

files = relative/directory/*.ini   ;可以指定一个或多个以.ini结束的配置文件

![img](file:///C:\Users\小贤\AppData\Local\Temp\ksohtml\wps9E7A.tmp.jpg) 

 

 

#### ***\*子进程配置文件说明：\****

***\*给需要管理的子进程(程序)编写一个配置文件，放在/etc/supervisor.d/目录下，以.ini作为扩展名（每个进程的配置文件都可以单独分拆也可以把相关的脚本放一起）。如任意定义一个和脚本相关的项目名称的选项组（/etc/supervisord.d/test.conf）：\****

 

\#项目名

[program:blog]

\#脚本目录

directory=/opt/bin

\#脚本执行命令

command=/usr/bin/python /opt/bin/test.py

 

\#supervisor启动的时候是否随着同时启动，默认True

autostart=true

\#当程序exit的时候，这个program不会自动重启,默认unexpected，设置子进程挂掉后自动重启的情况，有三个选项，false,unexpected和true。如果为false的时候，无论什么情况下，都不会被重新启动，如果为unexpected，只有当进程的退出码不在下面的exitcodes里面定义的

autorestart=false

\#这个选项是子进程启动多少秒之后，此时状态如果是running，则我们认为启动成功了。默认值为1

startsecs=1

 

\#脚本运行的用户身份 

user = test

 

\#日志输出 

stderr_logfile=/tmp/blog_stderr.log 

stdout_logfile=/tmp/blog_stdout.log 

\#把stderr重定向到stdout，默认 false

redirect_stderr = true

\#stdout日志文件大小，默认 50MB

stdout_logfile_maxbytes = 20MB

\#stdout日志文件备份数

stdout_logfile_backups = 20

 

![img](file:///C:\Users\小贤\AppData\Local\Temp\ksohtml\wps9E7B.tmp.jpg) 

 

 

## **5、supervisor命令说明**

supervisorctl status     //查看所有进程的状态

supervisorctl stop es    //停止es

supervisorctl start es    //启动es

supervisorctl restart    //重启es

supervisorctl update     //配置文件修改后使用该命令加载新的配置

supervisorctl reload     //重新启动配置中的所有程序

 

 

***\*注意：把es换成all可以管理配置中所有进程。直接输入supervisorctl进入supervisorctl的shell交互界面，此时上面的命令不带supervisorctl可直接使用。\****

 

使用supervisor进程管理命令之前先启动supervisor，否则程序报错

使用命令supervisord -c /etc/supervisord.conf启动

centots7使用命令

systemctl start supervisord.service  启动supervisor并加载默认配置文件

systemctl enable supervisord.service  将supervisor加入开机启动项

 

 

## **6、常见问题**

1.unix:///var/run/supervisor.sock no such file

问题描述：安装好supervisor没有开启服务直接使用supervisorctl报的错

解决办法：supervisord -c /etc/supervisord.con

 

2.command中指定的进程已经起来，但supervisor还不断重启
问题描述：command中启动方式为后台启动，导致识别不到pid，然后不断重启，这里使用的是elasticsearch，command指定的是$path/bin/elasticsearch -d 
解决办法：supervisor无法检测后台启动进程的pid，而supervisor本身就是后台启动守护进程，因此不用担心这个



3.启动了多个supervisord服务，导致无法正常关闭服务
问题描述：在运行supervisord -c /etc/supervisord.conf之前，直接运行过supervisord -c /etc/supervisord.d/xx.conf导致有些进程被多个superviord管理，无法正常关闭进程。
解决办法：使用ps -fe | grep supervisord查看所有启动过的supervisord服务，kill相关的进程



 

 

 

 

 

 

 

 

 

 

 