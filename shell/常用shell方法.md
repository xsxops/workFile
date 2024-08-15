## 常用shell方法

##### 判断结果是否成功

```shell
function check_out() {
    #判断操作是否成功
    if [[ $? -eq 0 ]]; then
        echo_color success "${1} 成功"
    else
        echo_color failed "${1} 失败"
        exit 1
    fi
}
check_out()：这是一个函数的定义，函数名为check_out。
if [[ $? -eq 0 ]]; then：这是一个条件语句，判断上一条命令的返回值（$?）是否等于0，即上一条命令是否执行成功。
echo_color success "${1} 成功"：如果上一条命令执行成功（返回值为0），则输出带有颜色标识的成功提示信息，其中${1}表示传递给函数的第一个参数。
echo_color failed "${1} 失败"：如果上一条命令执行失败（返回值不为0），则输出带有颜色标识的失败提示信息，并使用exit 1命令退出脚本执行，返回状态码1。
脚本中未提供echo_color函数的具体实现和功能，因此无法确定其具体作用。
```

##### 判断目录是否存在不存在则创建

```shell
function MkdirPath() {
    if [ ! -d ${1} ]; then
        mkdir -p ${1}
        #判断操作是否成功
        check_out "创建 目录 ${1}"
    fi
}

MkdirPath()：这是一个函数的定义，函数名为MkdirPath。
if [ ! -d ${1} ]; then：这是一个条件语句，判断${1}是否为一个不存在的目录。
mkdir -p ${1}：如果目录${1}不存在，则执行mkdir -p命令创建该目录。-p选项表示如果上级目录不存在也会一并创建。
check_out "创建 目录 ${1}"：这是一个函数或命令调用，调用了名为check_out的函数或命令，并传递了参数"创建 目录 ${1}"。根据代码提供的内容，无法确定check_out函数或命令的具体实现和功能。
```

