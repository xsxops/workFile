# 磁盘空间清理

```bash
du -hT /
```



使用du 命令查看 / 空间

```bash
du -xh --max-depth=1 |sort -hr |grep [MGR] |head


-x：仅查看当前文件系统。
--max-depth=1：显示根目录下每个子目录的磁盘使用情况。
sort -hr：按磁盘使用量排序。
grep [MGR]：过滤出单位为 M, G, 或 T 的行。
```

经过一步一步定位发现是 /var/lib/rancher 空间使用率比较高,这里所以定位容器。

查看是否有none的镜像

```bash
# 查看所有的镜像
crictl images
# 查看未被使用的镜像
crictl images --filter "dangling=true"
```

查看状态为 exited状态的容器

```bash
crictl ps -a --state=exited
```

查看是那个镜像运行的容器

```bash
crictl images
[root@master01 ~]# crictl ps -a --image registry.cn-beijing.aliyuncs.com/dotbalo/node:v3.26.1

CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD                 NAMESPACE
0fa4934f79bc7       8065b798a4d67       3 hours ago         Running             calico-node         12                  09513c80fe88e       calico-node-7xxv5   kube-system
9d07f68a40ec3       8065b798a4d67       3 hours ago         Exited              mount-bpffs         0                   09513c80fe88e       calico-node-7xxv5   kube-system
4fedec398d923       8065b798a4d67       3 weeks ago         Exited              calico-node         11                  3f435a0bcfd20       calico-node-7xxv5   kube-system
```

删除镜像

```bash
# 删除指定的ID镜像  
crictl rmi containerd_id  
# 删除所有未被使用的镜像
crictl rmi --prune
```

删除容器

```bash
crictl rm $(crictl ps -aq --state=exited)
```









