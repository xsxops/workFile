配置加密密码管理被控端机器

```shell
[hwc]
test ansible_host=114.115.203.237 ansible_user=root ansible_ssh_pass='{{ ansible_ssh_pass_test }}'
```

创建加密的 Credentials 文件

1. **创建加密的 Ansible Vault 文件**：

```
ansible-vault create credentials.yml
```

2. **添加密码变量**：

在打开的编辑器中，添加您的密码变量，例如：

```
ansible_ssh_passwd: 'XU!@sx0629'
```

修改hosts文件，使用变量

```
   [hwc]
   test ansible_host=114.115.203.237 ansible_user=root ansible_ssh_pass='{{ ansible_ssh_passwd }}'
```

执行