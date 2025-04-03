#!/bin/bash


# 输入命名空间，检查该命名空间内顶级资源或者po是否有配置监控检查探针


NAMESPACE=$1

if [ -z "$NAMESPACE" ]; then
  echo "请提供命名空间作为参数！"
  exit 1
fi

echo "正在检查命名空间 $NAMESPACE 下的健康检查探针..."

# 定义输出格式函数
output_format() {
  TYPE=$1
  RESOURCE=$2
  LIVENESS_PROBE=$3
  READINESS_PROBE=$4

  echo -e "  $TYPE 资源: $(tput bold)$(tput setaf 2)$RESOURCE$(tput sgr0)"
  if [ -n "$LIVENESS_PROBE" ]; then
    echo "    - 生存探针: 已配置"
  else
    echo "    - 生存探针: $(tput bold)$(tput setaf 1)未配置$(tput sgr0)"
  fi

  if [ -n "$READINESS_PROBE" ]; then
    echo "    - 就绪探针: 已配置"
  else
    echo "    - 就绪探针: $(tput bold)$(tput setaf 1)未配置$(tput sgr0)"
  fi
}

# 检查顶级资源（Deployment/StatefulSet/DaemonSet）
for TYPE in deployment statefulset daemonset; do
  RESOURCE_COUNT=$(kubectl get $TYPE -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
  if [ "$RESOURCE_COUNT" -gt 0 ]; then
    echo "正在检查 $TYPE 资源 ($RESOURCE_COUNT 个)"
    kubectl get $TYPE -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read RESOURCE; do
      LIVENESS_PROBE=$(kubectl get $TYPE $RESOURCE -n $NAMESPACE -o jsonpath='{range .spec.template.spec.containers[*]}{.livenessProbe}{"\n"}{end}' | grep -v "^$" | grep -v "null")
      READINESS_PROBE=$(kubectl get $TYPE $RESOURCE -n $NAMESPACE -o jsonpath='{range .spec.template.spec.containers[*]}{.readinessProbe}{"\n"}{end}' | grep -v "^$" | grep -v "null")
      output_format $TYPE $RESOURCE "$LIVENESS_PROBE" "$READINESS_PROBE"
    done
  else
    echo "命名空间 $NAMESPACE 下没有 $TYPE 资源。"
  fi
done

# 检查所有 Pod（包括未受顶级资源管理的 Pod）
echo "正在检查孤立 Pod（未受顶级资源管理的 Pod）..."
kubectl get pods -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read POD; do
  CONTROLLER_OWNER=$(kubectl get pod $POD -n $NAMESPACE -o jsonpath='{.metadata.ownerReferences[0].kind}' 2>/dev/null)
  if [[ "$CONTROLLER_OWNER" != "ReplicaSet" && "$CONTROLLER_OWNER" != "StatefulSet" && "$CONTROLLER_OWNER" != "DaemonSet" ]]; then
    LIVENESS_PROBE=$(kubectl get pod $POD -n $NAMESPACE -o jsonpath='{range .spec.containers[*]}{.livenessProbe}{"\n"}{end}' | grep -v "^$" | grep -v "null")
    READINESS_PROBE=$(kubectl get pod $POD -n $NAMESPACE -o jsonpath='{range .spec.containers[*]}{.readinessProbe}{"\n"}{end}' | grep -v "^$" | grep -v "null")
    output_format "孤立Pod" $POD "$LIVENESS_PROBE" "$READINESS_PROBE"
  fi
done

