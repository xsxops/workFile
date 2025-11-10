## docker、compose参数

#### docker参数

```
Docker 命令的全部参数有很多，以下是一些常用的参数列表：

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
以上是一些常见的 Docker 命令及其参数。
```





#### Docker Compose命令及其用途：

```

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

