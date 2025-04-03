### MegaCli概念

```
我们在使用服务器自带的远程管理卡查看磁盘的信息时，实际上我们只能看到磁盘的工作状态，而无法看到磁盘具体的使用情况，例如有没有坏道或是否松动，这时候我们就可以使用megacli工具来判断，磁盘是否真的需要更换而不是磁盘松动导致的工作状态异常，当然它的功能不止如此。

MegaCli是LSI公司官方提供的SCSI卡管理工具。由于被收购变成了现在的Broadcom，所以现在想下载MegaCli，需要去Broadcom官网查找Legacy产品支持，搜索MegaRAID。

它一款用于管理维护硬件RAID软件，可以查看当前raid卡的所有信息：raid卡的型号，raid的阵列类型，raid 的磁盘状态；
可以对raid进行管理：在线添加磁盘，创建磁盘阵列、删除阵列等。
```



### 常见参数含义

```shell
一般通过 MegaCli 的Media Error Count 、Other Error Count、Predictive Failure Count来确定阵列中磁盘是否有问题

Slot Number：	# slot号，应该跟机器外观上的标识一致。（磁盘位置）
Inquiry Data: 	# 磁盘的序列号，跟磁盘标签上一致。（磁盘标签需要拔盘才能看到）
Firmware state: 	# 这磁盘的状态，Online是最好的状态，除此之外还有 Unconfigured Offline Failed
Medai Error Count 	# 不为0，表示磁盘可能错误，可能是磁盘有坏道，数值越大，危险系数越高
Other Error Count 	# 不为0，表示磁盘可能存在松动，可能需要重新再插入
Predictive Failure Count：	# 表示监控硬盘的预报错误数量，不为0要更换
Last Predictive Failure Event Seq Number：	# 最后一条预警的时间序列号
Raw Size：	# 磁盘大小
Firmware state：	# 磁盘目前的状态。
```



### 磁盘状态

```shell
Unconfigured Good ：未配置好。 RAID控制器可访问的驱动器，但未配置为虚拟驱动器或热备分
Online：在线
Rebuild ：重建。写入数据的驱动器，以恢复虚拟驱动器的完全冗余
Failed ：失败
Unconfigured Bad：未配置的坏-驱动器上的固件检测不可恢复的错误；驱动器无法初始化Unconfigured Good或驱动器
Missing：失踪。在线驱动，但已从其位置移除
Offline：脱机-驱动器是虚拟驱动器的一部分，但在RAID中具有无效数据或未配置。
Hot Spare：热备份
None：具有不支持标志集的驱动器。具有未配置的良好或离线驱动器，完成了搬迁作业的准备工作。

# RAID Level对应关系
RAID Level : Primary-1, Secondary-0, RAID Level Qualifier-0 RAID 1
RAID Level : Primary-0, Secondary-0, RAID Level Qualifier-0 RAID 0
RAID Level : Primary-5, Secondary-0, RAID Level Qualifier-3 RAID 5
RAID Level : Primary-1, Secondary-3, RAID Level Qualifier-0 RAID 10
```





### 安装命令

```shell
rpm -ivh MegaCli-8.07.10-1.noarch.rpm 
ls /opt/
ln -s /opt/MegaRAID/MegaCli/MegaCli64 /usr/local/bin/megacli
```

### 查看是否有磁盘错误，并查看磁盘ID

```shell
# 查看磁盘卡槽号和是否有错误，并显示每个盘的大小类型
megacli -PDList -aALL |grep -E 'Slot Number:|^Coerced Size:|Count:|Firmware state'
Slot Number: 0
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Coerced Size: 837.75 GB [0x68b80000 Sectors]
Firmware state: Online, Spun Up
Slot Number: 1
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Coerced Size: 837.75 GB [0x68b80000 Sectors]
Firmware state: Online, Spun Up
Slot Number: 2
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Coerced Size: 1.745 TB [0xdf7c0000 Sectors]
Firmware state: Online, Spun Up
Slot Number: 3
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Coerced Size: 5.457 TB [0x2ba900000 Sectors]
Firmware state: Online, Spun Up
Slot Number: 4
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Coerced Size: 5.457 TB [0x2ba900000 Sectors]
Firmware state: Online, Spun Up
Slot Number: 5
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Coerced Size: 5.457 TB [0x2ba900000 Sectors]
Firmware state: Online, Spun Up
Slot Number: 6
Media Error Count: 0
Other Error Count: 0
Predictive Failure Count: 0
Coerced Size: 5.457 TB [0x2ba900000 Sectors]
Firmware state: Online, Spun Up
Slot Number: 7
Media Error Count: 2
Other Error Count: 0
Predictive Failure Count: 0
Coerced Size: 5.457 TB [0x2ba900000 Sectors]
Firmware state: Online, Spun Up

# 较上条命令做了一筛选，显示好的可用的盘符数量
megacli -PDList -aALL |grep -E 'Slot Number:|^Coerced Size:|Count:|Firmware state' |grep -v 'Count: 0' |grep 'Slot Number'|wc -l8
8

```

### 查看硬盘状态并显示ID号

```shell
megacli -PDList -aAll -NoLog | egrep 'Slot Number|Firmware state'

Slot Number: 0
Firmware state: Online, Spun Up
Slot Number: 1
Firmware state: Online, Spun Up
Slot Number: 2
Firmware state: Unconfigured(good), Spun Up
Slot Number: 3
Firmware state: Online, Spun Up
Slot Number: 4
Firmware state: Online, Spun Up
Slot Number: 5
Firmware state: Online, Spun Up
Slot Number: 6
Firmware state: Unconfigured(good), Spun Up
Slot Number: 7
Firmware state: Unconfigured(good), Spun Up
Slot Number: 8
Firmware state: Unconfigured(good), Spun Up
Slot Number: 9
Firmware state: Unconfigured(good), Spun Up
Slot Number: 10
Firmware state: Unconfigured(good), Spun Up
Slot Number: 11
Firmware state: Unconfigured(good), Spun Up
Slot Number: 12
Firmware state: Unconfigured(good), Spun Up
Slot Number: 13
Firmware state: Unconfigured(good), Spun Up
Slot Number: 14
Firmware state: Unconfigured(good), Spun Up
Slot Number: 15
Firmware state: Unconfigured(good), Spun Up
Slot Number: 16
Firmware state: Unconfigured(good), Spun Up
Slot Number: 17
Firmware state: Unconfigured(good), Spun Up
Slot Number: 18
Firmware state: Unconfigured(good), Spun Up
Slot Number: 19
Firmware state: Unconfigured(good), Spun Up
Slot Number: 20
Firmware state: Unconfigured(good), Spun Up
Slot Number: 21
Firmware state: Unconfigured(good), Spun Up
Slot Number: 22
Firmware state: Unconfigured(good), Spun Up
Slot Number: 23
Firmware state: Unconfigured(good), Spun Up
Slot Number: 24
Firmware state: Unconfigured(good), Spun Up
Slot Number: 25
Firmware state: Unconfigured(bad)

#将Unconfigured(bad)调整为可用的good状态

```

### 扫描外来配置的个数

```bash
megacli -cfgforeign -scan -a0

There are 1 foreign configuration(s) on controller 0.   # 控制器 0 上有 1 个外部配置。
```

### 导入外来配置，恢复磁虚拟磁盘组

```shell
megacli -cfgforeign -import -a0

Foreign configuration is imported on controller 0.		# 在控制器 0 上导入外部配置。
```

### 清除外来配置

```shell
megacli -cfgforeign -clear -a0
```

### 查看当前的磁盘设备

```shell
megacli -PDlist -a0 | grep -e 'Enclosure Device ID:' -e '^Slot Number:' -e 'Device Id'
```

### 查看本机的raid配置和磁盘信息

```shell
megacli -cfgdsply -aALL
```

### 查看RAID卡日志

```bash
#查看RAID卡日志
megacli -FwTermLog -Dsply -aALL 

#保存RAID卡日志到文件中
megacli AdpEventLog -GetEvents -f raid.envent.log -a0

#清楚日志
megacli -AdpEventLog -Clear –a0
```

### 创建raid0

```shell
# 将32机箱上2号磁盘做raid0
megacli -CfgLdAdd -R0 [32:9] WB RA Cached -strpsz64 -a0
Adapter 0: Created VD 1
Adapter 0: Configured the Adapter!!

# 将43号机箱上的3，4，5做raid0
megacli -CfgLdAdd -R0 [32:3,32:4,32:5] WB RA Cached -strpsz64 -a0
Adapter 0: Created VD 1
Adapter 0: Configured the Adapter!!
```

### 创建raid5指定热备盘为32：6

```shell
megacli -CfgLdAdd -r5 [32:3,32:4,32:5] WB Direct -Hsp[32:6] -a0

Adapter 0: Created VD 2
Adapter: 0: Set Physical Drive at EnclId-32 SlotId-6 as Hot Spare Success.
Adapter 0: Configured the Adapter!!
```

### 创建raid5不做热备

```shell
megacli -CfgLdAdd -r5 [32:7,32:8,32:9,32:10,32:11,32:12] WB Direct -a0                                 

Adapter 0: Created VD 3
Adapter 0: Configured the Adapter!!
Exit Code: 0x00
```

### 查看raid级别和iD

```shell
# 检查机器服务器型号
dmidecode -t1

megacli -PDList -aAll -NoLog |grep -E 'Slot Number:|Group|Firmware state'

Slot Number: 0							# 磁盘卡槽号
Drive's position: DiskGroup: 0, Span: 0, Arm: 0			# RAID 级别里的ID
Firmware state: Online, Spun Up							# 启用状态
Slot Number: 1
Drive's position: DiskGroup: 0, Span: 0, Arm: 1			# RAID 级别里的ID  和卡槽0 同属一个RAID，目前看不到raid级别 只能看到他和谁一组的
Firmware state: Online, Spun Up
Slot Number: 2
Firmware state: Unconfigured(good), Spun Up
Slot Number: 3
Firmware state: Unconfigured(good), Spun Up
Slot Number: 4
Firmware state: Unconfigured(good), Spun Up
Slot Number: 5
Firmware state: Unconfigured(good), Spun Up

megacli -LDInfo -Lall -aALL |grep -E 'Virtual Drive|RAID Level'

Virtual Drive: 0 (Target Id: 0)				# 这个就是RAID ID，和上条命令里对应
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0    #primary1 RAID等级为 raid1
Virtual Drive: 1 (Target Id: 1)
RAID Level          : Primary-0, Secondary-0, RAID Level Qualifier-0    #primary0  raid0
```

### 删除指定raid 

```shell
# 删除raid l1 
megacli -CfgLdDel -L1 -force -a0
Adapter 0: Deleted Virtual Drive-1(target id-1)

# 删除raid l2
megacli -CfgLdDel -L1 -force -a3
```

### 创建raid10

```shell
# 查看磁盘状态
megacli -PDList -aAll -NoLog |grep -E 'Slot Number:|Group|Firmware state'

# 查看raid级别
megacli -LDInfo -Lall -aALL |grep -E 'Virtual Drive|RAID Level'

# 创建raid10  重启服务器生效
megacli -CfgSpanAdd -r10 -Array0[32:7,32:8] -Array1[32:9,32:10] WB Direct -a0
                                     
Adapter 0: Created VD 2
Adapter 0: Configured the Adapter!!
Exit Code: 0x00

#命令解释：
CfgSpanAdd：创建RAID命令
-r10 :RAID10，如果创建RAID5，则为-r5
-Array0[32:6,32:7] : RAID10相当于RAID1+RAID0，本例中为磁盘编号为4的物理磁盘和编号为5的物理磁盘组成一个RAID1，磁盘编号为6的物理磁盘和编号为7的物理磁盘组成一个RAID1，然后两个RAID1组成一个RAID0。（其中32为第一步取得的）
-Array1[32:8,32:9]同上解释
WB ：缓存策略，支持的策略可以使用以下命令查看：

# 查看缓存策略
megacli -LDGetProp -Cache -L0 -a0
```

### 设置全局热备

```bash
megacli -pdhsp -set -physdrv[32:10] -a0
```

### 查看磁盘缓存

```shell
# 查看磁盘缓存
megacli -LDinfo -lall -a0 |grep -E 'Virtual Drive:|RAID Level|Disk Cache Policy'
Virtual Drive: 0 (Target Id: 0)
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Disk Cache Policy   : Disk's Default
Virtual Drive: 1 (Target Id: 1)
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Disk Cache Policy   : Disk's Default
Virtual Drive: 2 (Target Id: 2)
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Disk Cache Policy   : Disk's Default
Virtual Drive: 3 (Target Id: 3)
RAID Level          : Primary-5, Secondary-0, RAID Level Qualifier-3
Disk Cache Policy   : Disk's Default
# Disk Cache Policy: Default —默认设置，与厂家有关系，不确定是开启还是关闭
# Disk Cache Policy: Enabled —开启
# Disk Cache Policy: Disabled —关闭

# 开启磁盘缓存
megacli -LDSetProp -EnDskCache -lall -a0

# 关闭磁盘缓存
megacli -LDSetProp -DisDskCache -lall -a0
```

### 修改RAID缓存选项

```bash
# 查看磁盘缓存策略(查看vd的)
megacli -LDGetProp -Cache -LALL -aALL
# 查看磁盘缓存策略(查看pd的)
megacli -LDGetProp -DskCache -LALL -aALL

# 关闭缓存
megacli -LDSetProp -DisDskCache -L0 -a0
```

### RAID缓存选项

```shell
RAID卡缓存策略

# 不同的RAID卡缓存策略对IO的性能影响较大，常见的策略有：
1、写操作策略，可设置为WriteBack或WriteThrough
	 WriteBack：进行写操作时，将数据写入RAID卡缓存，并直接返回，RAID卡控制器将在系统负载低或者Cache满了的情况下把数据写入硬盘。该设置会大大提升RAID卡写性能，绝大多数的情况下会降低系统IO负载。 数据的可靠性由RAID卡的BBU(Battery Backup Unit)进行保证。
	WriteThrough: 数据写操作不使用缓存，数据直接写入磁盘。RAID卡写性能下降，在大多数情况下该设置会造成系统IO负载上升。

2、读操作策略，可选参数：ReadAheadNone, ReadAdaptive, ReadAhead
	ReadAheadNone: 不开启预读。这是默认的设置
	ReadAhead: 在读操作时，预先把后面顺序的数据加载入Cache，在顺序读取时，能提高性能，相反会降低随机读的性能。
	ReadAdaptive: 自适应预读，当Cache memory和IO空闲时，采取顺序预读，平衡了连续读性能及随机读的性能，需要消耗一定的计算能力。

3、缓存策略，可选参数： Direct, Cached
	Direct: Direct IO模式，读操作不缓存到cache memory中，数据将同时传输到controller cache中和应用系统中，如果接下来要读取相同的数据块，则直接从controller cache中获取. Direct IO是默认的设置
	Cached: Cached IO模式，所有读操作都会缓存到cache memory中。

4、BBU不可用时策略，可选参数： Write Cache OK if Bad BBU 和No Write Cache if Bad BBU
	No Write Cache if Bad BBU: 如果BBU出问题，则关闭Write Cache。由WriteBack自动切换到WriteThrough模式。如果没有特殊要求，强烈建议采用该设置，以确保数据的安全。
	Write Cache OK if Bad BBU: 如果BBU出问题，依然启用Write Cache. 这是不推荐的设置，BBU出问题将无法保证断电情况下数据的正常，如果此时依然采用WriteBack模式，遇到断电将发生数据丢失。除非有UPS作额外保证，不然不推荐采用这个设置。
```







## 在操作系统中查看内存硬件状态，以及修复

- 了解目录结构
- 关注 uecount、cecount
- 查看相关计数



```bash
cd /sys && grep [0-9] /sys/devices/system/edac/mc/mc*/*count
cat /sys/devices/system/edac/mc/mc*/csrow*/ch*_ce_count | awk '{sum+=$1}END{print sum}'
grep [0-9] /sys/devices/system/edac/mc/mc*/csrow*/ch*_ce_count
```





- 计数清零

​	[root@compute58 ~]# echo 0 > /sys/devices/system/edac/mc/mc0/reset_counters
​	[root@compute58 ~]# echo 0 > /sys/devices/system/edac/mc/mc1/reset_counters

- 查看计数清零时间

​	[root@compute58 ~]# cat  /sys/devices/system/edac/mc/mc0/seconds_since_reset
​	1578
​	[root@compute58 ~]# cat  /sys/devices/system/edac/mc/mc1/seconds_since_reset
​	10







Raid1 
