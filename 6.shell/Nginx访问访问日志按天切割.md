### Nginx访问日志按天切割



#### 使用方法

```bash
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

这个脚本是用来按天切割 Nginx 访问日志，并通知 Nginx 重新打开日志文件的。让我来逐步解释一下：

#!/bin/bash：这是脚本的 shebang 行，指定了脚本解释器为 Bash。

LOG_DIR=/usr/local/nginx/logs：定义了 Nginx 日志文件所在的目录。

YESTERDAY_TIME=$(date -d "yesterday" +%F)：使用 date 命令获取昨天的日期，并以 %F 格式（年-月-日）赋值给变量 YESTERDAY_TIME。

LOG_MONTH_DIR=$LOG_DIR/$(date +"%Y-%m")：定义了存放按月分割的日志文件的目录路径，格式为 年-月。

LOG_FILE_LIST="default.access.log"：定义了需要切割的日志文件列表。在这里只有一个默认的访问日志文件。

for LOG_FILE in $LOG_FILE_LIST; do ... done：遍历日志文件列表，对每个日志文件执行以下操作：

[ ! -d $LOG_MONTH_DIR ] && mkdir -p $LOG_MONTH_DIR：检查按月分割的目录是否存在，如果不存在则创建。

mv $LOG_DIR/$LOG_FILE $LOG_MONTH_DIR/${LOG_FILE}_${YESTERDAY_TIME}：将昨天的日志文件移动到按月分割的目录中，并在文件名末尾添加昨天的日期。

kill -USR1 $(cat /var/run/nginx.pid)：发送 USR1 信号给 Nginx 进程，通知其重新打开日志文件。
```

