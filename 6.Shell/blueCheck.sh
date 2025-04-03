#!/bin/bash
# version 1
#xsx 

changes=()								# 定义数组，将需要输出的内容都输出到这里


chkPwdPol() {
#用户密码相关项检查												

    echo '开始检查系统中用户相关安全配置...'

    # 检查是否存在非必要用户并确认密码设置.
    mapfile -t users < <(awk -F: '/bin\/bash/{print $1}' /etc/passwd)     #这里条件以/bin/bash 为条件筛选
    for user in "${users[@]}"; do
        if ! grep -qE "^${user}:[^:*\!]+:" /etc/shadow; then
            changes+=("用户 ${user} 未设置有效密码或密码被锁定，存在风险！")         # 输出到数组中
        fi
    done
# mapfile -t users 将标准输出结果存储到数组中 
# for user in "${users[@]}" users 数组中的每个用户。

    # 检查密码复杂度设置
    if ! grep -q 'pam_cracklib.so' /etc/pam.d/system-auth; then
        echo 'password    requisite     pam_cracklib.so try_first_pass retry=5 minlen=8 ucredit=-1 lcredit=-1 dcredit=-2 ocredit=-2 difok=3' >> /etc/pam.d/system-auth
        changes+=("密码复杂度策略已添加")
    fi

    # 检查用户登录错误尝试限制
    if ! grep -q 'deny=5' /etc/pam.d/system-auth; then
        echo 'auth required pam_tally2.so onerr=fail deny=5 unlock_time=300' >> /etc/pam.d/system-auth
        changes+=("登录尝试限制已添加")
    fi

    # 检查密码有效期设置
    if ! grep -q '^PASS_MAX_DAYS[[:space:]]*90' /etc/login.defs; then
        sed -i -e 's/^PASS_MAX_DAYS/#PASS_MAX_DAYS/;/^#PASS_MAX_DAYS/aPASS_MAX_DAYS 90' /etc/login.defs
        changes+=("最大密码有效期已设置为90天")
    fi
    if ! grep -q '^PASS_MIN_DAYS[[:space:]]*10' /etc/login.defs; then
        sed -i -e 's/^PASS_MIN_DAYS/#PASS_MIN_DAYS/;/^#PASS_MIN_DAYS/aPASS_MIN_DAYS 10' /etc/login.defs
        changes+=("最小密码有效期已设置为10天")
    fi
    if ! grep -q 'PASS_WARN_AGE[[:space:]]*30' /etc/login.defs; then
        sed -i -e 's/^PASS_WARN_AGE/#PASS_WARN_AGE/;/^#PASS_WARN_AGE/aPASS_WARN_AGE 30' /etc/login.defs
        changes+=("密码过期警告已设置为30天前")
    fi

    # 检查远程会话超时参数设置
    if ! grep -Eq 'TMOUT=600|TMOUT=300' /etc/profile; then
        echo 'export TMOUT=600' >> /etc/profile
        changes+=("远程会话超时已设置为600秒")
		source /etc/profile
    fi
}


chkSysSrv() {
    # 检查SELinux状态
    local sel_cfg="/etc/selinux/config"

    if [ -f "$sel_cfg" ]; then
        if grep -q "^SELINUX=disabled" "$sel_cfg"; then
			changes+=("SElinux 为禁用状态")
        else
			changes+=("SElinux 为启用状态，请检查整改")
        fi
    else
        changes+=("SElinux 为禁用状态")
    fi

    # 使用 pgrep 检查NTP或Chrony进程是否在运行
    if pgrep chronyd > /dev/null; then
        changes+=("Chrony 服务正常启动")
    elif pgrep ntpd > /dev/null; then
        changes+=("NTP 服务正常启动")
    else
        changes+=("NTP 和 Chrony 服务未启动，请检查整改")
    fi
}


chkJavaSrv() {
    # 查找运行Java进程的用户
    local jarUsers=$(ps -o user= -C java | sort | uniq)

    if [ -z "$jarUsers" ]; then
        changes+=("没有运行Java服务")
    else
        # 定义sudoers文件及其包含目录的数组
        local sudoersFiles=("/etc/sudoers" /etc/sudoers.d/*)

        for user in $jarUsers; do
            local hasSudo=false  # 标志变量，默认设置为false

            # 遍历sudoers文件及其包含目录
            for file in "${sudoersFiles[@]}"; do
                # 检查文件是否存在并且grep用户
                if [ -e "$file" ] && grep -q "^$user" "$file"; then
                    changes+=("运行Java服务的  $user 用户具有sudo权限，请整改！！！")
                    hasSudo=true  # 设置标志变量为true
                    break  # 找到后可跳出循环，避免重复检查
                fi
            done

            # 如果没有sudo权限，则提示用户权限正常
            if [ "$hasSudo" = false ]; then
                changes+=("运行java服务的 $user 用户权限为正常")
            fi
        done
    fi

    ps -ef | egrep -q "[t]omcat|[w]eblogic" && df -hT || changes+=("并无运行WebLogic、Tomcat，跳过检查")
}
rptChgs() {
#报告信息
    echo "经检查蓝线审核条目，结果如下："
    for change in "${changes[@]}"; do
        echo "    -- $change"		
    done
	echo "检查完成，祝您工作愉快 ~OVO~"
}

chkPwdPol
chkSysSrv
chkJavaSrv
rptChgs