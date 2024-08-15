随着云计算、物联网（IoT）和远程办公等技术的发展，VPN的重要性更加凸显，并且现有的网络带宽质量也越来越好，很多企业和用户都选择了VPN解决方案来实现多地的互联（相对传统的专线，经济实惠），很多企业和用户选择建设VPN主要用于以下几个场景：

- **云计算业务的发展：**虽然现在“上云”和“下云”的争议仍然不休，并且很多大企业确实在“下云”，但是对中小企业和个人来说，前期业务部署云上确实具备较高的性价比。而VPN也是在上云过程中必不可少的建设项目之一。
- **物联网（IoT）：**随着互联网的智能设备数量不断增加，边缘计算的发展，特别是对于家庭自动化系统、智能城市设施和工业控制系统等关键基础设施，VPN可以提供重要的安全保障和便捷的网络连接。
- **远程办公：**远程工作越来越普遍，VPN可以确保远程员工能够安全地访问公司网络和资源，此外，VPN+堡垒机还可以帮助企业管理远程访问权限，确保只有授权人员可以访问敏感信息。

综上所述，VPN就像水和空气，虽然很常见，但是很重要的一环。所以很多企业在建设网络时，VPN是必不可少的一项。常见的VPN有IPSec和OpenVPN，在介绍之前，我们有必要了解下这三种VPN的对比：



| **特点**       | **WireGuard**                      | **IPSec**                        | **OpenVPN**                      |
| -------------- | ---------------------------------- | -------------------------------- | -------------------------------- |
| **优点**       | 简单性、高性能、安全性强           | 成熟、广泛支持、灵活性好         | 成熟稳定、跨平台、广泛支持       |
| **缺点**       | 相对较新、生态系统仍在发展         | 配置复杂、性能较低               | 较高的延迟、复杂性高             |
| **安全性**     | 现代密码学、简单设计               | 强大的加密和认证机制             | 强大的加密和认证机制             |
| **性能**       | 高性能、低延迟                     | 由于复杂性可能导致性能下降       | 中等性能、较高的延迟             |
| **配置和部署** | 简单、易于配置和部署               | 配置复杂、需要专业知识           | 配置较复杂、但可通过图形界面简化 |
| **社区支持**   | 得到广泛社区支持和积极发展         | 成熟稳定、有大量的文档和支持社区 | 成熟稳定、有大量的文档和支持社区 |
| **适用场景**   | 适用于对性能和简洁性要求较高的场景 | 适用于企业级网络和专业用户       | 适用于各种网络环境和使用情况     |

而我们今天主要介绍的是WireGuard的部署和管理工具：wg-easy

**01** 

**—** 

#  wg-easy 介绍 

**一段话介绍wg-easy：一个专为简化 WireGuard VPN配置和管理而设计的工具，提供了界面化的管理，进一步降低了 WireGuard 的使用门槛，让用户无需深入了解其底层工作原理即可轻松部署和管理 WireGuard VPN。**

![img](https://mmbiz.qpic.cn/mmbiz_png/kgXibFxsv0e1zIXML5mFvZlN9ibMFZkRtLXhPH5axiaP6PDyQzrKL4U9DCcFKRSHyGfo6tx5mHomL8J0DKlL0qcNA/640?wx_fmt=png&from=appmsg)

**🏠 项目信息**

```
# wg-easy github地址https://github.com/wg-easy/wg-easy# WireGuard 项目地址https://github.com/WireGuard# WireGuard 项目官网https://www.wireguard.com/
```

![img](https://mmbiz.qpic.cn/mmbiz_png/kgXibFxsv0e1zIXML5mFvZlN9ibMFZkRtLaLKUT123UTBdG3Rj1SltPkicRLkB33l8volSQJ8hE6cX7HXGCTpAlkw/640?wx_fmt=png&from=appmsg)

## 🚀**功能特性**

- **自动化配置：**wg-easy的核心特性在于其自动化配置 WireGuard 过程，使得用户无需深入了解WireGuard的底层工作原理就能进行设置。
- **一体化能力：**wg-easy不仅提供WireGuard的配置和管理功能，还集成了Web UI，使得用户可以通过网页界面方便地列出、创建、编辑、删除、启用和禁用客户端，以及查看连接的客户端的统计信息和Tx/Rx图表。
- **灵活的扩展性：**虽然wg-easy本身已经提供了丰富的功能，但其模块化设计也允许用户根据需要自定义功能，或者通过插件系统扩展其功能。



**02**

**—**

#  wg-easy 安装 

wg-easy提供Docker安装，需要先安装Docker环境。本次环境采用了一台腾讯云主机（OpenCloudOS 9 操作系统，2C2G,20G磁盘，带公网IP）

**快速安装Docker：**

```
sudo yum makecache
sudo yum install -y docker 
sudo systemctl enable docker --now
```

**快速安装wg-easy:**

```
sudo docker run -d \
  --name=wg-easy \
  -e LANG=de \
  -e WG_DEFAULT_DNS=114.114.114.114 \
  -e WG_HOST=114.115.203.237 \
  -e PASSWORD='XU!@sx0629' \
  -e PORT=51821 \
  -e WG_PORT=51820 \
  -v ~/.wg-easy:/etc/wireguard \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy
```

**部署如果出现以下错误，说明部署的主机内核版本偏低，需要升级内核（如采用本文的操作系统则不会遇到此问题）：**

```shell
This usually means that your host's kernel does not support WireGuard!
```

```shell
# WireGuard 需要 Linux 内核版本为 5.6 或更高。执行以下命令检查内核版本：
uname -r
# 如果内核版本低于 5.6，需要升级内核。安装 WireGuard 内核模块 在 CentOS 或 RHEL 系统上，执行以下命令安装 WireGuard 内核模块：


sudo yum install -y epel-release
sudo yum install -y elrepo-release
sudo yum install -y yum-plugin-elrepo
sudo yum install -y kmod-wireguard wireguard-tools

# 安装完成后，确保 WireGuard 模块已加载：
 sudo modprobe wireguard
lsmod | grep wireguard

#重启容器

docker restart wg-easy

```





部署完成后，访问   `http://hotsIP:51821` 访问界面：

![img](https://mmbiz.qpic.cn/mmbiz_jpg/kgXibFxsv0e1zIXML5mFvZlN9ibMFZkRtLMXCjvLMRFiacHgu87mu2Rj2cibbtA3fiaBUxc0sTkAU4cCPIGf7TYoBQQ/640?wx_fmt=jpeg&from=appmsg)



**03**

**—**

#  wg-easy 使用 

# 

本次部署的网络示意图如下：

![img](https://mmbiz.qpic.cn/mmbiz_png/kgXibFxsv0e1zIXML5mFvZlN9ibMFZkRtLh7joAdOIibcjJdHIWGOyV9q5Z2fpZHZlibz1fTmQDdhzLreVibcqH8icBQ/640?wx_fmt=png&from=appmsg)

其中组网IP是部署wg-easy后，所有设备获取的WireGuard分配的虚拟网络IP地址。通过这个地址实现所有设备的点对点互通。



- **客户端下载：**

访问以下地址，按照不同操作系统类型下载和安装客户端安装包下载：

```
https://www.wireguard.com/install/
```

![img](https://mmbiz.qpic.cn/mmbiz_png/kgXibFxsv0e1zIXML5mFvZlN9ibMFZkRtLKIG3uOGA5KrWSHaRcoJ6Z4TkUumZpMlslroA723XguW95aesMiaib4EA/640?wx_fmt=png&from=appmsg)

- **服务器创建客户端：**

![img](https://mmbiz.qpic.cn/mmbiz_jpg/kgXibFxsv0e1zIXML5mFvZlN9ibMFZkRtLHXliaEzCRgWFxJibicezMgUnvMdiaicTZ0LlLtx32T6AvhI8RbqgBM88kHQ/640?wx_fmt=jpeg&from=appmsg)

- **Windows客户端配置：**
-  [wireguard-installer.exe](..\..\..\Downloads\wireguard-installer.exe) 

在服务端下载配置文件后，客户端中导入：

![img](https://mmbiz.qpic.cn/mmbiz_jpg/kgXibFxsv0e1zIXML5mFvZlN9ibMFZkRtL4icN6JaKoVeIPwhhdGNUHhia0uetVx1PUnvcZahclPeOiaRCFzx1FKY4g/640?wx_fmt=jpeg&from=appmsg)

- **Linux客户端配置：**

Linux 安装完成后，在/etc/wireguard目录中创建wg0.conf 配置文件，配置的信息同客户端中下载的配置文件一致即可

- **手机客户端配置：**

手机端配置比较简单，手机安装好客户端APP后，直接扫码即可。

- **效果测试：**

咋任意的一台客户端机器上ping网络，发现已经可以访问了：

![img](https://mmbiz.qpic.cn/mmbiz_jpg/kgXibFxsv0e1zIXML5mFvZlN9ibMFZkRtLztHOB2JaLibKupRdhh2M87icDyda2IqY1PWNE8VVqxKVgBZhS7S7hUZg/640?wx_fmt=jpeg&from=appmsg)



直接远程也可以使用：

![img](https://mmbiz.qpic.cn/mmbiz_jpg/kgXibFxsv0e1zIXML5mFvZlN9ibMFZkRtLuWThLMXdCp62TIfvrjZI461zu0PY0tM63FWPQCHhz24R3Zj4MNeLng/640?wx_fmt=jpeg&from=appmsg)



并且在服务端也可以查看到连接的网络流量信息：

![img](https://mmbiz.qpic.cn/mmbiz_jpg/kgXibFxsv0e1zIXML5mFvZlN9ibMFZkRtLrppg3wFNz6AdDElc6vTEBgk1bTZicZx4nFL2qEy5bv3pggialNqOYyAQ/640?wx_fmt=jpeg&from=appmsg)



**04**

**—**

#  最后 

总的来说，wg-easy 提供了一个简单、快速且安全的方式来配置和管理 WireGuard VPN连接，使得用户能够更轻松地享受到VPN带来的安全和隐私保护。无论现在采用的是 IPSec或者OpenVPN，还是已经用上了WireGuard VPN，如果你也觉得现有的VPN配置管理比较麻烦的话，不妨试试wg-easy吧。