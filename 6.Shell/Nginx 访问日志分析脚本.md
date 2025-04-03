**Nginx 访问访问日志按天切割**

使用方法

```
chmod +x nginx_log_rotate.sh
./nginx_log_rotate.sh
```



```shell
#!/bin/bash
LOG_DIR=/usr/local/nginx/logs
YESTERDAY_TIME=$(date -d "yesterday" +%F)
LOG_MONTH_DIR=$LOG_DIR/$(date +"%Y-%m")
LOG_FILE_LIST="default.access.log"

for LOG_FILE in $LOG_FILE_LIST; do
    [ ! -d $LOG_MONTH_DIR ] && mkdir -p $LOG_MONTH_DIR
    mv $LOG_DIR/$LOG_FILE $LOG_MONTH_DIR/${LOG_FILE}_${YESTERDAY_TIME}
done

kill -USR1 $(cat /var/run/nginx.pid)


脚本的执行过程如下：

脚本获取昨天的日期，并将其赋值给变量 YESTERDAY_TIME。

脚本定义变量 LOG_MONTH_DIR 作为存放按月分割的日志文件的目录。目录名称格式为 年-月。

对于每个日志文件，在切割之前，脚本首先检查月份的目录是否存在。如果不存在，则使用 mkdir -p 命令创建目录。

然后，脚本使用 mv 命令将日志文件移动到以昨天日期命名的文件中，该文件位于按月分割的目录下。

最后，脚本使用 kill 命令发送 USR1 信号给 Nginx 进程，使其重新打开日志文件。

通过运行该脚本，你可以在每天切割 Nginx 访问日志，并将旧日志文件存储在按月分割的目录中，同时确保 Nginx 进程使用新的日志文件进行记录。
```

