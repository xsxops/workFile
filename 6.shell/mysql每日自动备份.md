### mysql每日自动备份脚本

```shell
vim mysql_backup.sh

#!/bin/bash

# MySQL 用户名和密码
MYSQL_USER="root"
MYSQL_PASSWORD="password"

# 备份保存目录
BACKUP_DIR="/backup/mysql/"

# 获取数据库列表
DATABASES=$(mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|sys)")

# 备份每个数据库
for DB in $DATABASES; do
    # 备份文件名为数据库名+当前日期时间
    BACKUP_FILE="$BACKUP_DIR$DB-$(date +%Y%m%d%H%M%S).sql"

    # 使用 mysqldump 备份数据库到文件
    mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD $DB > $BACKUP_FILE

    # 如果备份成功，则输出成功信息
    if [ $? -eq 0 ]; then
        echo "Backup of database $DB completed successfully"
    else
        echo "Backup of database $DB failed"
    fi
done
```

#### 添加权限

```shell
chmod +x mysql_backup.sh

./mysql_backup.sh
```

#### 定期执行

```shell
要设置每天早上四点自动备份，你可以使用 cron 任务来执行备份脚本。在终端中输入以下命令来编辑 cron 任务列表：
crontab -e
0 4 * * * /path/to/mysql_backup.sh
```

