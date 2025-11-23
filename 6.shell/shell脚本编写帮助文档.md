# Shell脚本条件测试参数手册

本文档详细整理了Bash脚本中常用的条件测试参数及用法，涵盖字符串、整数、文件、复合条件、模式匹配及正则表达式等场景。

---

## 字符串测试

| 参数        | 说明                              | 示例                                         |
| ----------- | --------------------------------- | -------------------------------------------- |
| `= 或 ==`   | 字符串相等                        | `if [ "$str" = "hello" ]; then ...`          |
| `!=`        | 字符串不相等                      | `if [ "$str" != "world" ]; then ...`         |
| `-z STRING` | 字符串为空（长度为0）             | `if [ -z "$str" ]; then echo "空字符串"; fi` |
| `-n STRING` | 字符串非空（长度非0）             | `if [ -n "$str" ]; then echo "非空"; fi`     |
| `>` 或 `<`  | 按字典序比较（需在`[[ ]]`中使用） | `if [[ "apple" > "banana" ]]; then ...`      |

**注意**：`= 和 ==`在`[ ]`中仅支持`=`，在`[[ ]]`中两者等效。

---

## 整数比较

| 参数  | 说明                | 示例                               |
| ----- | ------------------- | ---------------------------------- |
| `-eq` | 等于（equal）       | `if [ "$a" -eq 5 ]; then ...`      |
| `-ne` | 不等于（not equal） | `if [ "$a" -ne 10 ]; then ...`     |
| `-lt` | 小于（less than）   | `if [ "$a" -lt "$b" ]; then ...`   |
| `-le` | 小于等于            | `if [ "$a" -le 20 ]; then ...`     |
| `-gt` | 大于                | `if [[ "$a" -gt 3 ]]; then ...`    |
| `-ge` | 大于等于            | `if [[ "$a" -ge "$b" ]]; then ...` |

**提示**：在`(( ))`中可直接用数学符号（如`if (( a > b )); then ...`）。

---

## 文件测试

| 参数      | 说明                   | 示例                                            |
| --------- | ---------------------- | ----------------------------------------------- |
| `-e FILE` | 文件存在               | `if [ -e "/path/file" ]; then ...`              |
| `-f FILE` | 是普通文件             | `if [[ -f "$file" ]]; then echo "普通文件"; fi` |
| `-d FILE` | 是目录                 | `if [ -d "/tmp" ]; then ...`                    |
| `-r FILE` | 文件可读               | `if [ -r "$file" ]; then ...`                   |
| `-w FILE` | 文件可写               | `if [[ -w "$file" ]]; then ...`                 |
| `-x FILE` | 文件可执行             | `if [ -x "/bin/bash" ]; then ...`               |
| `-s FILE` | 文件非空               | `if [ -s "data.txt" ]; then ...`                |
| `-L FILE` | 是符号链接             | `if [[ -L "/path/link" ]]; then ...`            |
| `-p FILE` | 是命名管道（FIFO）     | `if [ -p "/tmp/pipe" ]; then ...`               |
| `-S FILE` | 是套接字文件           | `if [[ -S "/var/run/socket" ]]; then ...`       |
| `-N FILE` | 文件自上次读取后被修改 | `if [ -N "$logfile" ]; then ...`                |

---

## 复合条件

| 操作符 | 说明                 | 示例                                            |
| ------ | -------------------- | ----------------------------------------------- |
| `&&`   | 逻辑与（全部为真）   | `if [ -f "$file" ] && [ -r "$file" ]; then ...` |
| `||`   | 逻辑或（至少一个真） | `if [ "$a" -eq 1 ] || [ "$b" -eq 2 ]; then ...` |
| `!`    | 逻辑非               | `if ! [ -d "$dir" ]; then echo "非目录"; fi`    |

**注意**：在`[[ ]]`中可直接使用`&&`和`||`，例如：
```bash
if [[ -f "$file" && -r "$file" ]]; then ...
```

---

## 进程测试

| 参数 | 说明                     | 示例                                                         |
| ---- | ------------------------ | ------------------------------------------------------------ |
| `-G` | 检查进程是否属于某个组   | `if pgrep -G "www-data" "nginx"; then echo "Nginx running"; fi` |
| `-U` | 检查进程是否属于某个用户 | `if pgrep -U "root" "ssh"; then echo "SSH running"; fi`      |
| `-x` | 检查进程是否存在         | `if pgrep -x "cron"; then echo "Cron running"; fi`           |
| `-f` | 检查进程是否匹配模式     | `if pgrep -f "python script.py"; then echo "Script running"; fi` |

---

## 命令测试

| 参数         | 说明             | 示例                                                         |
| ------------ | ---------------- | ------------------------------------------------------------ |
| `command -v` | 检查命令是否存在 | `if command -v git; then echo "Git installed"; fi`           |
| `hash`       | 检查命令是否可用 | `if hash curl 2>/dev/null; then echo "Curl available"; fi`   |
| `type`       | 检查命令类型     | `if type -t "ls" >/dev/null; then echo "ls is a command"; fi` |

---

## 网络测试

| 参数 | 说明                 | 示例                                                         |
| ---- | -------------------- | ------------------------------------------------------------ |
| `-z` | 检查端口是否开放     | `if nc -z 127.0.0.1 80; then echo "Port 80 open"; fi`        |
| `-w` | 检查网络连接是否成功 | `if wget --spider http://example.com 2>/dev/null; then echo "Site up"; fi` |

---

## 用户和组测试

| 参数     | 说明           | 示例                                                         |
| -------- | -------------- | ------------------------------------------------------------ |
| `id -u`  | 检查用户ID     | `if [ $(id -u) -eq 0 ]; then echo "Root user"; fi`           |
| `id -g`  | 检查组ID       | `if [ $(id -g) -eq 1000 ]; then echo "User group"; fi`       |
| `id -nG` | 检查用户所属组 | `if [[ " $(id -nG) " == *"sudo"* ]]; then echo "In sudo group"; fi` |

---

## 其他测试

| 参数                              | 说明                     | 示例                                                    |
| --------------------------------- | ------------------------ | ------------------------------------------------------- |
| `[[ $var =~ ^[0-9]+$ ]]`          | 检查变量是否为数字       | `if [[ $var =~ ^[0-9]+$ ]]; then echo "Is number"; fi`  |
| `[[ $var == *@(value1|value2) ]]` | 检查变量是否为多个值之一 | `if [[ $var == *@(start|end) ]]; then echo "Valid"; fi` |

---



# 流程控制结构详解

### 1. for 循环：固定次数与遍历场景的首选

#### 适用场景

1. 已知循环次数：明确需要执行的迭代次数（如遍历数组、文件列表）。

2. 结构化数据处理：适用于处理列表、数组、通配符匹配的文件集合。

3. 数值范围迭代：通过计数器控制循环（如从 1 到 100 的累加）。

#### 语法与示例

```bash
for variable in item1 item2 ... itemN
do
    command1
    command2
    ...
    commandN
done
```

示例：遍历当前目录下所有`.log`文件并输出文件名

```bash
for file in *.log
do
    if [ -f "$file" ]; then
        echo "Processing file: $file"
    fi
done
```

上述示例中，通过通配符`*.log`匹配目标文件，循环体内结合文件测试`[ -f "$file" ]`确保操作有效性，适合日志归档、数据备份等场景。

### 2. while 循环：条件驱动的动态循环

#### 适用场景

1. 未知循环次数：依赖动态条件终止（如等待服务启动、用户输入校验）。

2. 流式数据处理：逐行处理文件或命令输出（如日志分析、实时监控）。

3. 交互式逻辑：需要持续交互直至满足退出条件（如菜单循环）。

#### 语法与示例

```bash
while condition
do
    command1
    command2
    ...
    commandN
done
```

示例：检测某个端口是否被占用，若未被占用则退出循环

```bash
port=8080
while netstat -an | grep ":$port " > /dev/null; do
    echo "Port $port is in use, waiting..."
    sleep 1
done
echo "Port $port is available."
```

此示例通过`netstat -an | grep ":$port " > /dev/null`检测端口状态，条件为假时退出循环，适用于服务健康检查、网络连接验证等场景。

#### for 与 while 核心区别

| 特性         | for 循环                      | while 循环                                |
| ------------ | ----------------------------- | ----------------------------------------- |
| 循环控制依据 | 计数器 / 列表遍历（次数明确） | 条件表达式（动态判断，次数未知）          |
| 执行顺序     | 先初始化，再执行循环体        | 先判断条件，再执行循环体（可能 0 次执行） |
| 典型应用场景 | 批量文件操作、数组遍历        | 服务监听、输入校验、流式处理              |

### 3. case 语句：多分支条件匹配的高效方案

#### 适用场景

1. 交互式脚本：根据用户输入执行不同操作（如 CLI 工具、菜单系统）。

2. 状态机逻辑：基于变量值的多分支处理（如服务启停、环境检测）。

3. 模式匹配：支持精确匹配、通配符（*/?）及逻辑或（|）。

#### 语法与示例

```bash
case variable in
    pattern1)
        command1
        command2
        ...
        ;;
    pattern2|pattern3)
        command4
        command5
        ...
        ;;
    *)
        commandN
        ;;
esac
```

示例：根据用户输入执行不同的系统操作

```bash
read -p "Enter action (start/stop/restart/status): " action
case $action in
    start)
        systemctl start httpd
        ;;
    stop)
        systemctl stop httpd
        ;;
    restart)
        systemctl restart httpd
        ;;
    status)
        systemctl status httpd
        ;;
    *)
        echo "Invalid action"
        ;;
esac
```

通过`case`匹配用户输入，避免多层`if - else`嵌套，提升代码可读性，适用于自动化运维脚本。

### 4. 函数（fun）：代码复用与模块化核心

#### 适用场景

1. 逻辑封装：重复使用的代码块（如系统信息获取、文件操作函数）。

2. 参数化处理：根据输入参数动态执行逻辑（如计算函数、配置生成）。

3. 脚本分层：将复杂逻辑拆分为可复用的函数，提高维护性。

#### 语法与示例

```bash
function_name() {
    local var1 var2  # 定义局部变量
    # 函数逻辑
    command1
    command2
    ...
    return value     # 返回状态码
}
```

示例：定义一个函数计算两个数的和

```bash
add_numbers() {
    local num1=$1
    local num2=$2
    local result=$((num1 + num2))
    echo $result
    return 0
}
sum=$(add_numbers 3 5)
echo "The sum is: $sum"
```

通过`local`隔离变量作用域，利用`return`返回状态码，适合复杂逻辑拆分和工具函数库开发。

## 二、Shell 脚本常用命令速查表

| 命令                                                         | 功能概述                                                     | 示例                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| pgrep                                                        | 按进程名 / 用户 / 组查找进程 PID，支持正则匹配               | pgrep firefox （精确匹配进程名）                             |
| pgrep -u root sshd （查找 root 用户的 sshd 进程）            |                                                              |                                                              |
| pkill                                                        | 按进程名终止进程，支持信号发送（默认 SIGTERM， -9 为强制终止） | pkill -9 python （强制终止所有 python 进程）                 |
| pkill -f "[script.py](script.py)" （匹配命令行包含 [script.py](script.py) 的进程） |                                                              |                                                              |
| find -exec                                                   | 查找文件并对匹配结果执行命令，避免循环遍历提升效率           | find /var/log -type f -name "*.log" -mtime +7 -exec rm {} ; （删除 7 天前的日志文件） |
| dirname                                                      | 获取文件路径的目录部分                                       | dirname /path/to/file.txt （输出：/path/to）                 |
| dirname "$0" （获取脚本所在目录）                            |                                                              |                                                              |
| basename                                                     | 获取文件路径的文件名部分                                     | basename /path/to/file.txt （输出：file.txt）                |
| basename /path/to/dir/ （输出：dir）                         |                                                              |                                                              |
| xargs                                                        | 将标准输入转换为命令参数，处理含空格的文件名                 | find . -name "*.txt"-print0                                  |
| find . -name "* *" -print0                                   | xargs -0 rm -f （安全删除含空格的文件）                      |                                                              |
| timeout                                                      | 限制命令执行时间，超时后终止进程                             | timeout 10 wget [http://example.com](http://example.com) （10 秒未完成则取消下载） |
| timeout -s SIGTERM 60 -k 5 tar -cvf backup.tar/data （1 分钟后发 TERM 信号，5 秒后发 KILL） |                                                              |                                                              |
| sleep                                                        | 暂停脚本执行指定时间（秒 / 毫秒 / 分钟）                     | sleep 5 （暂停 5 秒）                                        |
| sleep 0.5 （暂停 500 毫秒）                                  |                                                              |                                                              |
| sleep 60 （暂停 1 分钟）                                     |                                                              |                                                              |
