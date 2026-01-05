# Monitor - Helm Chart de Monitoramento para k3s

Chart Helm completo e bem estruturado para monitoramento de um cluster k3s single-node (preparado para multi-node) usando Prometheus, Grafana e componentes relacionados.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Requisitos](#requisitos)
- [Componentes](#componentes)
- [Instalação](#instalação)
- [Configuração](#configuração)
- [Acesso ao Grafana](#acesso-ao-grafana)
- [Upgrade](#upgrade)
- [Desinstalação](#desinstalação)
- [Configuração de Domínio e TLS](#configuração-de-domínio-e-tls)
- [Exemplos de Uso](#exemplos-de-uso)
- [Troubleshooting](#troubleshooting)

## 🎯 Visão Geral

Este chart instala um stack completo de monitoramento baseado no [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack), que inclui:

- **Prometheus**: Coleta e armazena métricas do cluster
- **Grafana**: Visualização de métricas e dashboards
- **Alertmanager**: Gerenciamento de alertas
- **Node Exporter**: Métricas dos nós do cluster
- **kube-state-metrics**: Métricas do estado do Kubernetes

O chart é totalmente configurável via `values.yaml` e segue as melhores práticas do Helm.

## 📦 Requisitos

- Kubernetes >= 1.24
- k3s (testado em single-node, mas preparado para multi-node)
- Helm >= 3.0
- cert-manager (opcional, para TLS automático)
- Ingress Controller (Traefik padrão no k3s)

## 🧩 Componentes

### Componentes Core

| Componente | Descrição | Habilitado por Padrão |
|------------|-----------|----------------------|
| Prometheus | Coleta e armazena métricas | ✅ Sim |
| Grafana | Visualização e dashboards | ✅ Sim |
| Alertmanager | Gerenciamento de alertas | ✅ Sim |
| Node Exporter | Métricas dos nós | ✅ Sim |
| kube-state-metrics | Métricas do Kubernetes | ✅ Sim |
| Prometheus Operator | Operador do Prometheus | ✅ Sim |

Todos os componentes podem ser habilitados/desabilitados individualmente via `values.yaml`.

## 🚀 Instalação

### 1. Preparação

Certifique-se de que o repositório do Prometheus Community está adicionado:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 2. Baixar Dependências

```bash
cd helms/monitoring
helm dependency update
```

### 3. Instalação Básica

```bash
helm install monitor . --namespace monitoring --create-namespace
```

### 4. Instalação com Valores Customizados

```bash
helm install monitor . \
  --namespace monitoring \
  --create-namespace \
  --set grafanaIngress.host=grafana.seudominio.com \
  --set certManager.clusterIssuer=letsencrypt-prod
```

### 5. Instalação com Arquivo de Valores

```bash
helm install monitor . \
  --namespace monitoring \
  --create-namespace \
  -f values-custom.yaml
```

## ⚙️ Configuração

### Valores Principais

Os principais valores configuráveis estão em `values.yaml`. Principais seções:

#### Namespace

```yaml
namespace:
  name: monitoring
  create: true
```

#### Grafana Ingress

```yaml
grafanaIngress:
  enabled: true
  host: grafana.s4125.eficify.cloud
  ingressClassName: traefik
  tls:
    enabled: true
    secretName: grafana-tls
```

#### Cert-Manager Integration

```yaml
certManager:
  clusterIssuer: letsencrypt-prod
  issuerType: letsencrypt-prod
```

#### Prometheus

```yaml
kube-prometheus-stack:
  prometheus:
    prometheusSpec:
      retention: 15d
      storageSpec:
        volumeClaimTemplate:
          spec:
            resources:
              requests:
                storage: 50Gi
```

#### Grafana

```yaml
kube-prometheus-stack:
  grafana:
    adminUser: admin
    adminPassword: admin  # IMPORTANTE: Altere em produção!
    persistence:
      enabled: true
      size: 10Gi
```

### Feature Flags

Para habilitar/desabilitar componentes:

```yaml
features:
  prometheus: true
  alertmanager: true
  grafana: true
  nodeExporter: true
  kubeStateMetrics: true
  prometheusOperator: true
```

## 🌐 Acesso ao Grafana

### Via Ingress (Recomendado)

Se o Ingress estiver habilitado:

1. Acesse: `https://grafana.s4125.eficify.cloud` (ou seu domínio configurado)
2. Login:
   - **Usuário**: `admin` (ou o configurado em `kube-prometheus-stack.grafana.adminUser`)
   - **Senha**: Obtenha com:

```bash
kubectl get secret -n monitoring monitor-kube-prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d && echo
```

### Via Port-Forward

Se o Ingress não estiver habilitado:

```bash
kubectl port-forward -n monitoring svc/monitor-kube-prometheus-grafana 3000:80
```

Acesse: `http://localhost:3000`

### Onde Encontrar a Senha do Grafana

A senha do Grafana é armazenada em um Secret do Kubernetes:

```bash
# Método 1: Via kubectl
kubectl get secret -n monitoring monitor-kube-prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d && echo

# Método 2: Via helm (se instalado com helm)
kubectl get secret -n monitoring monitor-kube-prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d && echo
```

**IMPORTANTE**: Altere a senha padrão após a primeira instalação!

## 🔄 Upgrade

### Upgrade Simples

```bash
helm upgrade monitor . --namespace monitoring
```

### Upgrade com Valores Customizados

```bash
helm upgrade monitor . \
  --namespace monitoring \
  -f values-custom.yaml
```

### Upgrade com Valores Inline

```bash
helm upgrade monitor . \
  --namespace monitoring \
  --set grafanaIngress.host=novo.dominio.com
```

## 🗑️ Desinstalação

```bash
helm uninstall monitor --namespace monitoring
```

**Nota**: Os PVCs (volumes persistentes) não são removidos automaticamente. Para remover:

```bash
# Remover PVCs manualmente (CUIDADO: Isso apagará os dados!)
kubectl delete pvc -n monitoring --all
```

## 🔒 Configuração de Domínio e TLS

### Pré-requisitos

1. cert-manager instalado no cluster
2. ClusterIssuer configurado (ex: `letsencrypt-prod`)
3. Domínio apontando para o IP do cluster

### Configuração Básica

Edite `values.yaml` ou crie um arquivo de override:

```yaml
grafanaIngress:
  enabled: true
  host: grafana.seudominio.com
  ingressClassName: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  tls:
    enabled: true
    secretName: grafana-tls

certManager:
  clusterIssuer: letsencrypt-prod
```

### Verificar Certificado

```bash
# Verificar o certificado
kubectl get certificate -n monitoring

# Verificar o secret TLS
kubectl get secret grafana-tls -n monitoring

# Verificar o Ingress
kubectl describe ingress -n monitoring monitor-grafana
```

### Troubleshooting TLS

Se o certificado não for emitido:

1. Verifique o ClusterIssuer:
```bash
kubectl get clusterissuer
```

2. Verifique os eventos do cert-manager:
```bash
kubectl get events -n cert-manager --sort-by='.lastTimestamp'
```

3. Verifique os logs do cert-manager:
```bash
kubectl logs -n cert-manager -l app=cert-manager
```

## 📝 Exemplos de Uso

### Exemplo 1: Instalação Básica

```bash
helm install monitor . --namespace monitoring --create-namespace
```

### Exemplo 2: Customizar Domínio e Storage

```bash
helm install monitor . \
  --namespace monitoring \
  --create-namespace \
  --set grafanaIngress.host=grafana.seudominio.com \
  --set storage.storageClass=local-path \
  --set storage.sizes.prometheus=100Gi
```

### Exemplo 3: Desabilitar Alertmanager

```bash
helm install monitor . \
  --namespace monitoring \
  --create-namespace \
  --set features.alertmanager=false
```

### Exemplo 4: Usar Arquivo de Valores Customizado

Crie `values-production.yaml`:

```yaml
grafanaIngress:
  host: grafana.producao.com
  tls:
    enabled: true

certManager:
  clusterIssuer: letsencrypt-prod

kube-prometheus-stack:
  grafana:
    adminPassword: senha-segura-aqui
  
  prometheus:
    prometheusSpec:
      retention: 30d
      storageSpec:
        volumeClaimTemplate:
          spec:
            resources:
              requests:
                storage: 100Gi
```

Instale:

```bash
helm install monitor . \
  --namespace monitoring \
  --create-namespace \
  -f values-production.yaml
```

### Exemplo 5: Configuração para Multi-Node

```yaml
kube-prometheus-stack:
  prometheus:
    prometheusSpec:
      replicas: 2
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - prometheus
                topologyKey: kubernetes.io/hostname
```

## 🔍 Troubleshooting

### Pods não iniciam

```bash
# Verificar status dos pods
kubectl get pods -n monitoring

# Verificar logs
kubectl logs -n monitoring <pod-name>

# Verificar eventos
kubectl get events -n monitoring --sort-by='.lastTimestamp'
```

### Prometheus sem dados

1. Verifique se o Prometheus Operator está rodando:
```bash
kubectl get pods -n monitoring | grep prometheus-operator
```

2. Verifique os ServiceMonitors:
```bash
kubectl get servicemonitors -n monitoring
```

3. Verifique os targets no Prometheus:
   - Acesse o Prometheus via port-forward
   - Vá em Status > Targets

### Grafana não acessível

1. Verifique o Ingress:
```bash
kubectl get ingress -n monitoring
kubectl describe ingress -n monitoring monitor-grafana
```

2. Verifique o Service:
```bash
kubectl get svc -n monitoring | grep grafana
```

3. Teste via port-forward:
```bash
kubectl port-forward -n monitoring svc/monitor-kube-prometheus-grafana 3000:80
```

### Problemas de Storage

1. Verifique os PVCs:
```bash
kubectl get pvc -n monitoring
```

2. Verifique o StorageClass:
```bash
kubectl get storageclass
```

3. Para k3s, o StorageClass padrão geralmente é `local-path`

### Recursos Insuficientes

Se os pods estiverem em `Pending` ou `CrashLoopBackOff`:

1. Verifique os recursos disponíveis:
```bash
kubectl top nodes
kubectl top pods -n monitoring
```

2. Ajuste os recursos em `values.yaml`:
```yaml
kube-prometheus-stack:
  prometheus:
    prometheusSpec:
      resources:
        requests:
          cpu: 200m
          memory: 1Gi
```

## 📚 Recursos Adicionais

- [kube-prometheus-stack Documentation](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [cert-manager Documentation](https://cert-manager.io/docs/)

## 🤝 Contribuindo

Para contribuir com melhorias:

1. Faça um fork do repositório
2. Crie uma branch para sua feature
3. Faça commit das mudanças
4. Abra um Pull Request

## 📄 Licença

Este chart é fornecido como está, sem garantias.

## ⚠️ Notas Importantes

1. **Senha Padrão**: Altere a senha padrão do Grafana em produção!
2. **Storage**: Configure o StorageClass apropriado para seu ambiente
3. **Recursos**: Ajuste os recursos (CPU/memória) conforme a capacidade do cluster
4. **TLS**: Certifique-se de que o cert-manager está configurado corretamente
5. **Backup**: Configure backups regulares dos PVCs em produção
6. **Retenção**: Ajuste a retenção do Prometheus conforme necessário

## 🎯 Próximos Passos

Após a instalação:

1. ✅ Acesse o Grafana e altere a senha padrão
2. ✅ Configure notificações no Alertmanager
3. ✅ Importe dashboards adicionais conforme necessário
4. ✅ Configure alertas personalizados
5. ✅ Configure backup dos dados do Prometheus
6. ✅ Monitore o uso de recursos e ajuste conforme necessário

---

**Desenvolvido para k3s, preparado para crescer! 🚀**

