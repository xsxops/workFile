# Kubernetes RBAC 权限管理详解

## 一、RBAC 简介

Kubernetes 中的 **Role-Based Access Control**（RBAC）是一个权限管理模型，旨在为集群中的资源访问控制提供灵活的授权机制。通过 RBAC，管理员可以基于用户或服务账号的角色来定义访问权限，从而确保只有经过授权的主体能够执行特定的操作。

RBAC 的核心思想是将权限划分为多个角色（Role），然后通过绑定（Binding）将这些角色与实际的用户或服务账号关联，最终实现权限控制。它不仅能提升集群的安全性，还能简化集群管理员的管理工作。

## 二、RBAC 的作用与背景

在 Kubernetes 中，集群可能会由多个团队或用户共同维护和使用，因此需要精确控制不同用户或服务账号对集群资源的访问权限。RBAC 提供了一个清晰的权限控制模型，可以在不同级别（如 Namespace 或 Cluster）和不同粒度（如资源、操作）上为不同的用户分配相应的权限。

| 功能维度       | 具体实现                                                     |
| -------------- | ------------------------------------------------------------ |
| 资源隔离       | 通过Namespace实现开发/测试/生产环境隔离                      |
| 操作细粒度控制 | 精确到具体资源类型（如Pod/Deployment）和操作动词（get/list/create） |
| 访问审计       | 所有API操作记录可追溯，关联具体用户/ServiceAccount           |
| 动态权限调整   | 无需重启组件即可更新权限策略                                 |

### 1. 权限划分的背景
随着 Kubernetes 使用的普及，越来越多的企业开始在其集群中执行复杂的多租户操作。每个团队或用户可能只关心某些特定的资源，而不应访问其他团队的数据。为此，RBAC 应运而生，它使得权限控制更加细粒度和灵活。

### 2. 权限划分的作用
- **增强安全性**：通过限制用户和服务账号的权限，减少潜在的安全风险。
- **精细化控制**：根据团队、项目、职能等维度来划分权限。
- **减少权限过度分配的风险**：避免某些用户获得过多的权限，尤其是管理员级别的权限。
- **便于审计**：权限清晰，易于审计和管理。

## 三、RBAC 的核心概念

### 1. Role 和 ClusterRole

- **Role**：定义了在某个特定 Namespace 中的权限集合。它指定了可以执行哪些操作（如 `get`、`list`、`create`、`update`、`delete`）以及可以操作哪些资源（如 Pods、Services 等）。
  
- **ClusterRole**：类似于 Role，但它在整个集群范围内有效，而不是仅限于某个 Namespace。ClusterRole 适用于需要跨多个 Namespace 访问权限的情况，或者集群级别的资源访问权限。

### 2. RoleBinding 和 ClusterRoleBinding

- **RoleBinding**：将一个 Role 绑定到一个用户或服务账户。RoleBinding 的作用范围仅限于某个 Namespace 内。
  
- **ClusterRoleBinding**：将一个 ClusterRole 绑定到一个用户或服务账户。ClusterRoleBinding 的作用范围是整个集群，适用于跨多个 Namespace 的权限管理。

### 3. 聚合 ClusterRole

聚合 ClusterRole 是通过将多个 ClusterRole 合并为一个来创建更复杂的权限配置。比如，一个用户可能同时需要多个 ClusterRole 的权限，在这种情况下，可以使用聚合 ClusterRole 将这些权限组合到一起。

> [!WARNING]
>
> **绑定规则**：
>
> - RoleBinding可以引用ClusterRole，但权限仍限定在Namespace内
> - ClusterRoleBinding必须引用ClusterRole



## 四、如何创建 RBAC 资源

下面将通过 YAML 文件来详细说明如何创建不同的 RBAC 资源：Role、ClusterRole、RoleBinding、ClusterRoleBinding。

### 1. 创建 Role 示例

```yaml
apiVersion: rbac.authorization.k8s.io/v1  # API 版本，指定使用 RBAC API
kind: Role  # 资源类型是 Role
metadata:
  namespace: default  # Role 所属的 Namespace，表示此 Role 只在 default Namespace 中有效
  name: developer-role  # Role 名称
rules:
  - apiGroups: [""]  # 资源属于核心 API 组，"" 表示没有 API 组
    resources: ["pods"]  # 可以操作的资源是 pods
    verbs: ["get", "list", "create"]  # 允许的操作是获取（get）、列出（list）和创建（create）
```

### 2. 创建 ClusterRole 示例

```yaml
apiVersion: rbac.authorization.k8s.io/v1  # API 版本
kind: ClusterRole  # 资源类型是 ClusterRole
metadata:
  name: admin-cluster-role  # ClusterRole 名称
rules:
  - apiGroups: [""]  # 资源属于核心 API 组
    resources: ["pods", "services"]  # 可以操作的资源是 pods 和 services
    verbs: ["get", "list", "create", "delete"]  # 允许的操作包括获取、列出、创建和删除
```

#### 核心区别：

- **作用域**：Role仅作用于单个Namespace，ClusterRole全局有效
- 使用场景：
  - Role：开发环境权限控制
  - ClusterRole：节点监控、存储管理等全局操作

### 3. 创建 RoleBinding 示例

```yaml
apiVersion: rbac.authorization.k8s.io/v1  # API 版本
kind: RoleBinding  # 资源类型是 RoleBinding
metadata:
  name: developer-role-binding  # RoleBinding 名称
  namespace: default  # RoleBinding 所属的 Namespace
subjects:
  - kind: User  # 绑定对象是一个用户
    name: "developer-user"  # 用户名
    apiGroup: rbac.authorization.k8s.io  # API 组
roleRef:
  kind: Role  # 绑定的角色是 Role
  name: developer-role  # 角色名称
  apiGroup: rbac.authorization.k8s.io  # API 组
```

### 4. 创建 ClusterRoleBinding 示例

```yaml
apiVersion: rbac.authorization.k8s.io/v1  # API 版本
kind: ClusterRoleBinding  # 资源类型是 ClusterRoleBinding
metadata:
  name: admin-cluster-role-binding  # ClusterRoleBinding 名称
subjects:
  - kind: User  # 绑定对象是一个用户
    name: "admin-user"  # 用户名
    apiGroup: rbac.authorization.k8s.io  # API 组
roleRef:
  kind: ClusterRole  # 绑定的角色是 ClusterRole
  name: admin-cluster-role  # ClusterRole 名称
  apiGroup: rbac.authorization.k8s.io  # API 组
```

### 5. 聚合 ClusterRole 示例

```yaml
apiVersion: rbac.authorization.k8s.io/v1  # API 版本
kind: ClusterRole  # 资源类型是 ClusterRole
metadata:
  name: aggregated-cluster-role  # 聚合后的 ClusterRole 名称
rules:
  - apiGroups: [""]  # 资源属于核心 API 组
    resources: ["pods", "services"]  # 可以操作的资源是 pods 和 services
    verbs: ["get", "list", "create", "delete"]  # 允许的操作包括获取、列出、创建和删除
  - apiGroups: ["apps"]  # 资源属于 apps API 组
    resources: ["deployments"]  # 可以操作的资源是 deployments
    verbs: ["get", "list"]  # 允许的操作是获取和列出
```

**使用场景**：

- 整合多个监控组件的权限
- 动态扩展平台功能模块权限





## 五、生产环境中的常用 RBAC 使用案例

### 1. 根据不同项目组进行权限划分

假设我们有两个团队：开发团队（Dev Team）和运维团队（Ops Team）。

- **开发团队**：我们为开发团队创建一个 Role，仅允许他们在 `dev` 命名空间中创建和修改 Pods。
- **运维团队**：我们为运维团队创建一个 ClusterRole，使他们能够在整个集群中管理 Pods 和 Services。

------

##### 💡 开发团队权限

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: dev-team-pod-manager  # Role 名称
  namespace: dev  # 作用域为 dev 命名空间
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create", "get", "update", "delete"]  # 允许开发团队创建、获取、更新和删除 Pods
    
    
---    
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-team-pod-manager-binding  # RoleBinding 名称
  namespace: dev  # 绑定作用域为 dev 命名空间
subjects:
  - kind: User
    name: dev-user  # 被绑定的用户
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: dev-team-pod-manager  # 绑定到之前创建的 dev-team-pod-manager Role
  apiGroup: rbac.authorization.k8s.io
```

------

##### 💡 运维团队权限

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ops-team-cluster-manager  # ClusterRole 名称
rules:
  - apiGroups: [""]
    resources: ["pods", "services"]
    verbs: ["get", "create", "update", "delete", "list"]  # 运维团队可以管理 Pods 和 Services
   

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ops-team-cluster-manager-binding  # ClusterRoleBinding 名称
subjects:
  - kind: User
    name: ops-user  # 被绑定的运维用户
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: ops-team-cluster-manager  # 绑定到之前创建的 ops-team-cluster-manager ClusterRole
  apiGroup: rbac.authorization.k8s.io
```





### 2. 根据不同人员进行权限划分

如果有不同的开发人员，他们可能需要不同级别的权限。例如，某些开发人员只能查看 Pods，另一些开发人员需要修改和删除 Pods。通过为每个开发人员创建不同的 RoleBinding，我们可以控制他们对资源的访问权限。

------

##### 💡 用户 A 只读权限

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-read-only
  namespace: dev  # 限制为 dev 命名空间
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]  # 只允许查看 Pods
    

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bind-pod-read-only-user
  namespace: dev
subjects:
  - kind: User
    name: user-a  # 被绑定的用户
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-read-only  # 绑定到 pod-read-only Role
  apiGroup: rbac.authorization.k8s.io
```

------

##### 💡 用户 B 编辑权限

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-editor
  namespace: dev
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "create", "update", "delete"]  # 允许修改和删除 Pods
    
    
---    
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bind-pod-editor-user
  namespace: dev
subjects:
  - kind: User
    name: user-b  # 被绑定的用户
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-editor  # 绑定到 pod-editor Role
  apiGroup: rbac.authorization.k8s.io
```



### 3. 根据不同 Namespace 进行权限划分

通过 Namespace 隔离不同的环境，针对每个 Namespace 创建不同的 Role 或 ClusterRole，来限制用户访问的权限。

假设我们有 `dev` 和 `test` 两个 Namespace，用户 `user-d` 只能访问 `test` 命名空间下的 Services。

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: svc-manager
  namespace: test  # 限制作用于 test 命名空间
rules:
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get", "create", "update", "delete", "list"]  # 允许管理 services
    
   
---   
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bind-svc-manager-user
  namespace: test
subjects:
  - kind: User
    name: user-d  # 被绑定的用户
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: svc-manager  # 绑定到 svc-manager Role
  apiGroup: rbac.authorization.k8s.io
```





### 4. 根据不同 Kubernetes 管理人员进行权限划分

集群管理员可以根据职责为不同的管理员分配不同的权限。例如，某些管理员只能管理 Namespaces 和 ResourceQuotas，而其他管理员具有完整的集群管理权限。通过 ClusterRole 和 ClusterRoleBinding，可以实现这种权限划分。

------

##### 💡 限制管理员权限（管理 Namespace 和 ResourceQuotas）

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: limited-admin
rules:
  - apiGroups: [""]
    resources: ["namespaces"]
    verbs: ["get", "create", "delete"]  # 管理命名空间
  - apiGroups: [""]
    resources: ["resourcequotas"]
    verbs: ["get", "create", "delete", "update"]  # 管理资源配额
yamlapiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: bind-limited-admin
subjects:
  - kind: User
    name: admin-a  # 被绑定的管理员
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: limited-admin  # 绑定到 limited-admin ClusterRole
  apiGroup: rbac.authorization.k8s.io
```

------

##### 💡 完整集群管理员权限（cluster-admin）

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: bind-full-admin
subjects:
  - kind: User
    name: admin-b  # 被绑定的超级管理员
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin  # Kubernetes 内置的超级管理员角色
  apiGroup: rbac.authorization.k8s.io
```

## 六、总结

Kubernetes 的 RBAC 机制通过精细化的权限管理，使得管理员能够基于角色和绑定的方式为集群资源分配权限。通过合理划分权限，可以保证 Kubernetes 集群的安全性和可管理性。在生产环境中，合理配置 Role、ClusterRole、RoleBinding 和 ClusterRoleBinding 是 Kubernetes 权限管理的核心任务。

希望本篇文档对你理解和使用 Kubernetes RBAC 权限管理有所帮助。如果你有更多问题，欢迎随时提问。