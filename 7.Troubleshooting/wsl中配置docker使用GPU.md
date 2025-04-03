# 在 WSL 中配置 Docker 使用 NVIDIA GPU

### 前提条件：

- 确保您的 Windows 系统已安装了最新版本的 WSL 2。
- 安装了支持的 NVIDIA 驱动程序。
- 安装了 Docker Desktop，并在设置中启用了 WSL 2 支持。

###  1.设置 NVIDIA Docker 存储库

1.1） 确定您的 Linux 发行版和版本号：

```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
```

1.2） 添加 NVIDIA Docker 的 GPG 密钥：

```bash
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
```

1.3） 添加 NVIDIA Docker 存储库：

```bash
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```

### 2.安装 NVIDIA Container Toolkit

2.1）更新您的包索引并安装 NVIDIA Container Toolkit：

```bash
   sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
```

2.2） 重启 Docker 服务以应用更改：

```bash
   sudo systemctl restart docker
```



### 3.安装 NVIDIA CUDA Toolkit (可选)

```bash
sudo apt install nvidia-cuda-toolkit -y
```

### 4.修改docker的配置，设置默认允许容器访问 GPU。

```bash
sudo vim /etc/docker/daemon.json
   {
     "default-runtime": "nvidia",
     "runtimes": {
       "nvidia": {
         "path": "nvidia-container-runtime",
         "runtimeArgs": []
       }
     }
   }
   
sudo systemctl restart docker

```



### 5.验证安装

4.1) 运行一个简单的测试容器来验证 Docker 是否已正确配置为默认使用 NVIDIA GPU：

```bash
docker run --rm nvidia/cuda:11.0-base nvidia-smi
```

4.2） 检查 CUDA 编译器版本：

```bash
   nvcc -V
```

4.3） 检查 NVIDIA GPU 状态：

```bash
   nvidia-smi
```

