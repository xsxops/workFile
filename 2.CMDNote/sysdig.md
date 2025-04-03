# sysdig命令



### 1、安装命令

```
tee /etc/yum.repos.d/draios.repo <<EOF
[draios]
name=Draios
baseurl=https://download.sysdig.com/stable/rpm/x86_64
enabled=1
gpgcheck=1
gpgkey=https://download.sysdig.com/DRAIOS-GPG-KEY.public
EOF

yum makecache fast
yum install -y sysdig
```

### 2、基础用法

```shell
# 查看所有系统事件：
sysdig
# 列出所有可用的 Sysdig chisels（小工具），这些都是 Sysdig 的扩展脚本
sysdig -c list
# 显示消耗 CPU 最多的进程列表：
sysdig -c topprocs_cpu
# 显示网络 I/O 最多的进程列表：
sysdig -c topprocs_net
#显示文件 I/O 最多的进程列表
sysdig -c topprocs_file
# 提供类似于 netstat 的输出，显示网络连接和状态
sysdig -c netstat
# 提供类似于 ps 的输出，显示当前运行的进程列表和它们的状态
sysdig -c ps
#捕获所有涉及到路径中包含 /opt 的文件描述符的事件。这对于监控对特定目录的文件操作非常有用
sysdig fd.name contains /opt
# 显示系统上的实时用户活动，类似于 strace
sysdig -c spy_users
# 将捕获的事件保存到文件 output.scap，以便之后可以进行回放和分析
sysdig -w output.scap
# 从文件 output.scap 读取并分析之前保存的事件
sysdig -r output.scap
# 以自定义的输出格式显示所有打开文件操作的进程名称和文件路径
sysdig -p"%proc.name %fd.name" evt.type=open
```



