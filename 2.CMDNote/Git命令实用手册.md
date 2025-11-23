# Git命令实用手册

本文档整理了Git版本控制系统的核心命令及使用场景，涵盖仓库初始化、代码提交、分支管理、远程协作等日常开发常用操作，适用于开发者快速查阅和学习。

---

# 一、基础操作

基础操作包括仓库初始化、文件状态查看、代码暂存与提交等，是Git使用的入门核心。

|命令|功能说明|示例|
|---|---|---|
|`git init`|在当前目录初始化一个新的Git仓库|`mkdir my-project && cd my-project
git init`|
|`git clone <url>`|克隆远程仓库到本地|`git clone https://github.com/username/repo.git`|
|`git status`|查看工作区、暂存区文件状态（已修改/未暂存/已暂存）|`git status  # 显示红色为未暂存，绿色为已暂存`|
|`git add <file>`|将文件从工作区添加到暂存区（追踪新文件或暂存修改）|`git add index.html  # 暂存单个文件
git add src/  # 暂存整个目录
git add .  # 暂存所有修改文件`|
|`git commit -m "<message>"`|将暂存区文件提交到本地仓库，`-m`指定提交信息|`git commit -m "feat: 添加用户登录功能"`|
|`git log`|查看提交历史记录，按时间倒序排列|`git log --oneline  # 简洁显示每条提交（哈希值+信息）
git log --graph  # 图形化显示分支合并历史`|
---

# 二、分支管理

分支管理用于实现并行开发、功能隔离和版本控制，是Git的核心特性之一。

|命令|功能说明|示例|
|---|---|---|
|`git branch`|查看本地所有分支，当前分支前标`*`|`git branch  # 列出本地分支
git branch -r  # 列出远程分支
git branch -a  # 列出本地+远程所有分支`|
|`git branch <branch-name>`|创建新分支（基于当前分支）|`git branch feature/login  # 创建功能分支`|
|`git checkout <branch-name>`|切换到指定分支|`git checkout feature/login  # 切换到功能分支
git checkout -b bugfix/123  # 创建并切换到bug修复分支`|
|`git merge <branch-name>`|将指定分支的代码合并到当前分支|`git checkout main  # 切换到主分支
git merge feature/login  # 合并功能分支到主分支`|
|`git branch -d <branch-name>`|删除本地已合并的分支（未合并需用`-D`强制删除）|`git branch -d feature/login  # 删除已合并的功能分支
git branch -D feature/old  # 强制删除未合并的分支`|
|`git branch -m <old-name> <new-name>`|重命名本地分支|`git branch -m feature/login feature/user-auth`|
---

# 三、提交与撤销

用于修改提交记录、撤销工作区/暂存区修改或回滚历史版本。

|命令|功能说明|示例|
|---|---|---|
|`git commit --amend`|修改最近一次提交的信息或补充暂存文件到该提交|`git add forgotten-file.txt
git commit --amend -m "feat: 补充用户登录相关文件"`|
|`git reset --soft <commit-hash>`|回滚到指定提交，保留工作区和暂存区修改（仅撤销提交记录）|`git reset --soft a1b2c3d  # 回滚到a1b2c3d提交`|
|`git reset --hard <commit-hash>`|强制回滚到指定提交，丢弃工作区和暂存区所有修改（谨慎使用）|`git reset --hard HEAD~1  # 回滚到上一次提交（HEAD~1表示上一个版本）`|
|`git checkout -- <file>`|撤销工作区中指定文件的修改（恢复到暂存区或最近提交状态）|`git checkout -- index.html  # 撤销index.html的工作区修改`|
|`git rm <file>`|删除文件并将删除操作暂存（后续需commit）|`git rm obsolete-file.txt
git commit -m "chore: 删除过时文件"`|
|`git stash`|暂存工作区未提交的修改，用于临时切换分支（后续可恢复）|`git stash  # 暂存当前修改
git stash pop  # 恢复最近一次暂存并删除stash记录
git stash list  # 查看所有stash记录`|
---

# 四、远程仓库协作

与远程仓库（如GitHub、GitLab）进行数据同步，实现团队协作。

|命令|功能说明|示例|
|---|---|---|
|`git remote`|查看远程仓库配置|`git remote  # 列出远程仓库别名（默认通常为origin）
git remote -v  # 显示别名对应的远程URL`|
|`git remote add <name> <url>`|添加远程仓库关联|`git remote add origin https://github.com/username/repo.git`|
|`git pull`|拉取远程分支代码并合并到当前本地分支（= `git fetch + git merge`）|`git pull origin main  # 拉取远程main分支到本地当前分支`|
|`git push <remote> <branch>`|将本地分支代码推送到远程仓库|`git push origin feature/login  # 推送功能分支到远程
git push -u origin main  # 首次推送时关联分支，后续可直接git push`|
|`git fetch`|获取远程仓库最新分支信息，但不合并到本地分支|`git fetch origin  # 获取origin远程所有分支更新
git checkout -b feature/new origin/feature/new  # 基于远程分支创建本地分支`|
|`git remote remove <name>`|删除与远程仓库的关联|`git remote remove old-origin`|
---

# 五、高级操作

涵盖标签管理、差异对比、冲突解决等进阶场景。

|命令|功能说明|示例|
|---|---|---|
|`git tag`|创建、查看标签（用于版本发布标记）|`git tag v1.0.0  # 创建轻量标签
git tag -a v1.0.0 -m "Release v1.0.0"  # 创建带注释标签
git tag  # 查看所有标签
git push origin v1.0.0  # 推送标签到远程`|
|`git diff`|对比文件在不同状态下的差异|`git diff  # 对比工作区与暂存区差异
git diff --cached  # 对比暂存区与本地仓库差异
git diff branch1 branch2  # 对比两个分支的差异`|
|`git cherry-pick <commit-hash>`|将指定提交的代码单独合并到当前分支（适用于跨分支移植bug修复）|`git checkout main
git cherry-pick d4e5f6g  # 将d4e5f6g提交的修复代码合并到main`|
|`git rebase <branch>`|将当前分支基于指定分支重新提交（使提交历史更线性，区别于merge）|`git checkout feature/login
git rebase main  # 基于main分支重写feature/login的提交历史`|
|`git config`|配置Git用户信息、别名等（全局配置加`--global`）|`git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global alias.st status  # 设置别名git st=git status`|
---

# 六、常见工作流程示例

## 6.1 日常开发流程

```bash

# 1. 克隆远程仓库（首次）
git clone https://github.com/username/repo.git
cd repo

# 2. 创建并切换到功能分支
git checkout -b feature/new-function

# 3. 开发过程中提交代码
git add .
git commit -m "feat: 实现XX功能"

# 4. 定期拉取远程主分支更新，避免冲突
git checkout main
git pull
git checkout feature/new-function
git merge main

# 5. 功能完成后推送分支到远程
git push -u origin feature/new-function
```

## 6.2 版本发布流程

```bash

# 1. 切换到主分支并确保代码最新
git checkout main
git pull

# 2. 创建版本标签
git tag -a v1.1.0 -m "Release v1.1.0"

# 3. 推送标签到远程
git push origin v1.1.0
```

## 6.3 冲突解决流程

```bash

# 1. 合并分支时出现冲突
git merge feature/login  # 提示CONFLICT

# 2. 查看冲突文件（文件中标记<<<<<<< HEAD到>>>>>>> feature/login之间为冲突内容）
git status  # 显示冲突文件

# 3. 编辑冲突文件，保留正确内容并删除冲突标记
vim conflict-file.txt

# 4. 标记为已解决并完成合并
git add conflict-file.txt
git commit -m "fix: 解决合并冲突"
```

---

# 七、附录：常用术语说明

- **工作区（Working Directory）**：本地正在编辑的文件目录

- **暂存区（Stage/Index）**：临时存放待提交修改的区域

- **本地仓库（Local Repository）**：本地.git目录存储的提交历史

- **远程仓库（Remote Repository）**：服务器端存储的共享仓库（如GitHub）

- **HEAD**：指向当前所在分支的最新提交
> （注：文档部分内容可能由 AI 生成）