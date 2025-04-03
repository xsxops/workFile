#!/bin/bash

# 设置模式变量：AUTO_MODE=true 则为自动运行模式
AUTO_MODE=false  # 默认为手动模式

# 日志文件路径和备份目录
APACHE_LOG_DIR="/var/log/httpd"  # 实际路径
ACCESS_LOG="$APACHE_LOG_DIR/access_log"  # 访问日志
ERROR_LOG="$APACHE_LOG_DIR/error_log"    # 错误日志
BACKUP_DIR="/backup/apache_logs"
MONITOR_LOG="/var/log/service_monitor.log"
RESOURCE_MONITOR_LOG="/var/log/resource_monitor.log"

# 邮件通知设置
ADMIN_EMAIL="13121423367@163.com"

# 检查和创建备份目录
function ensure_backup_dir {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi
}

# 任务1：清理和备份超过30天的日志
function backup_and_clean_logs {
    ensure_backup_dir
    echo "开始备份和清理日志..."
    find "$APACHE_LOG_DIR" -type f -name "*.log" -mtime +30 -exec tar -czf "$BACKUP_DIR/apache_logs_$(date +%Y%m%d).tar.gz" {} + -exec rm -f {} +
    echo "日志备份完成，保存在 $BACKUP_DIR。" | tee -a "$MONITOR_LOG"
}

# 任务2：实时监控服务运行状态
function monitor_services {
    echo "开始监控服务状态..."
    SERVICES=("httpd" "mariadb")  # 可根据需要调整服务名称
    for service in "${SERVICES[@]}"; do
        if ! systemctl is-active --quiet "$service"; then
            echo "$(date): 服务 $service 已停止，正在尝试重启..." | tee -a "$MONITOR_LOG"
            systemctl restart "$service"
            if ! systemctl is-active --quiet "$service"; then
                echo "$(date): 服务 $service 重启失败，通知管理员。" | tee -a "$MONITOR_LOG"
                echo "服务 $service 重启失败，请检查服务器。" | mail -s "服务故障通知" "$ADMIN_EMAIL"
            else
                echo "$(date): 服务 $service 重启成功。" | tee -a "$MONITOR_LOG"
            fi
        else
            echo "$(date): 服务 $service 正常运行。" | tee -a "$MONITOR_LOG"
        fi
    done
}

# 任务3：Apache 日志流量分析（可选功能）
function analyze_logs {
    echo "开始分析 Apache 日志..."
    if [ -f "$ACCESS_LOG" ]; then
        echo "访问最多的 IP 地址："
        awk '{print $1}' "$ACCESS_LOG" | sort | uniq -c | sort -nr | head -10

        echo "访问最多的 URL："
        awk '{print $7}' "$ACCESS_LOG" | sort | uniq -c | sort -nr | head -10

        echo "返回码统计："
        awk '{print $9}' "$ACCESS_LOG" | sort | uniq -c | sort -nr
    else
        echo "无法找到 Apache 访问日志！"
    fi
}

# 任务4：实时监控资源使用情况（修改后实现实时监控并只显示最新结果）
function monitor_resources {
    echo "开始实时监控资源使用情况..."
    > "$RESOURCE_MONITOR_LOG"  # 每次清空文件

    while true; do
        # 写入最新监控结果
        echo "====== $(date '+%Y-%m-%d %H:%M:%S') ======" > "$RESOURCE_MONITOR_LOG"
        echo "CPU 和内存使用情况：" >> "$RESOURCE_MONITOR_LOG"
        top -b -n 1 | head -n 10 >> "$RESOURCE_MONITOR_LOG"

        echo "" >> "$RESOURCE_MONITOR_LOG"
        echo "磁盘 I/O 情况：" >> "$RESOURCE_MONITOR_LOG"
        iostat -x 1 1 | tail -n +3 >> "$RESOURCE_MONITOR_LOG"

        echo "" >> "$RESOURCE_MONITOR_LOG"
        echo "网络流量：" >> "$RESOURCE_MONITOR_LOG"
        ifstat 1 1 | tail -n 1 >> "$RESOURCE_MONITOR_LOG"

        # 清屏并打印最新监控结果
        clear
        cat "$RESOURCE_MONITOR_LOG"

        # 间隔时间（例如 5 秒）
        sleep 5
    done
}

# 主菜单函数
function main_menu {
    if [ "$AUTO_MODE" = true ]; then
        # 自动运行模式
        backup_and_clean_logs
        monitor_services
        exit 0
    fi

    # 手动模式菜单
    while true; do
        echo "请选择要执行的任务："
        echo "1) Apache 日志流量分析"
        echo "2) 清理和备份 Apache 日志"
        echo "3) 实时监控资源使用情况"
        echo "4) 实时监控服务运行状态"
        echo "5) 全部执行"
        echo "6) 退出"
        read -p "输入选项 (1-6): " choice

        case $choice in
            1) analyze_logs ;;
            2) backup_and_clean_logs ;;
            3) monitor_resources ;;  # 实时监控资源
            4) monitor_services ;;
            5)
                analyze_logs
                backup_and_clean_logs
                monitor_resources &
                monitor_services
                echo "所有任务执行完成！"
                ;;
            6) exit 0 ;;
            *) echo "无效选项，请重试！" ;;
        esac
    done
}

# 启动脚本主程序
main_menu
