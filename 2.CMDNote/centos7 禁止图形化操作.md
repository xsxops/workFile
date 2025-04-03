# centos7 禁止图形化操作

#### 1.1 **查看当前运行目标**

```bash
systemctl get-default
```

#### 1.2 **切换到 multi-user.target**

要禁用图形界面并启用命令行模式，可以将默认目标切换为 `multi-user.target`。可以通过以下命令来完成：

```bash
sudo systemctl set-default multi-user.target
```

#### 1.3 **立即切换到 multi-user.target（不重启）**

如果你想立即切换到命令行模式，可以使用以下命令：

```bash
sudo systemctl isolate multi-user.target
```

此命令会将当前会话从图形界面切换到命令行模式，而不需要重启系统。