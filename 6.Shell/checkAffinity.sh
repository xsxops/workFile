while read workLoad resourceName nameSpaces; do
    echo "工作负载类型：$workLoad 资源名称：$resourceName 命名空间：$nameSpaces"
    kubectl get $workLoad $resourceName -n "$nameSpaces" -o yaml | 
    awk '/^\s*affinity:/, /containers:/ { if ($0 ~ /^\s*affinity:/ || $0 !~ /^\s*containers:/) print }'
done < list

kubectl get deployment prometheus-adapter -n monitoring -o yaml | awk '/^\s*affinity:/, /containers:/ { if ($0 ~ /^\s*affinity:/ || $0 !~ /^\s*containers:/) print }'


检查是否为数据库：
while read workLoad resourceName nameSpaces; do
    echo "工作负载类型：$workLoad 资源名称：$resourceName 命名空间：$nameSpaces"
    kubectl get $workLoad $resourceName -n "$nameSpaces" -o yaml | grep image: | egrep -i "mysql|PostgreSQL|Oracle|SQLite|Redis|Memcached|MongoDB" && \
    (echo "工作负载类型：$workLoad 资源名称：$resourceName 命名空间：$nameSpaces" >> result && kubectl get $workLoad $resourceName -n "$nameSpaces" -o yaml | grep image: | egrep -i "mysql|PostgreSQL|Oracle|SQLite|Redis|Memcached|MongoDB" >> result) || echo "没有匹配的镜像"
done < list

检查是否调度到单一节点：
while read workLoad resourceName nameSpaces; do
    echo "工作负载类型：$workLoad 资源名称：$resourceName 命名空间：$nameSpaces"
    kubectl get $workLoad $resourceName -n "$nameSpaces" -o yaml |
    awk '/^\s*affinity:/, /containers:/ { if ($0 ~ /^\s*affinity:/ || $0 !~ /^\s*containers:/) print }'
done < list
