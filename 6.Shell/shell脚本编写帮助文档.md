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

