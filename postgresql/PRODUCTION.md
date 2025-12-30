# Guia de Instalação em Produção

Este guia descreve como usar o arquivo `values-production.yaml` para instalar o PostgreSQL em ambientes de produção.

## Pré-requisitos

Antes de instalar, certifique-se de:

1. **Configurar o bucket S3 para backups**
   ```yaml
   backup:
     s3:
       bucket: "seu-bucket-postgresql-backups"
       region: "us-east-1"
   ```

2. **Configurar certificados SSL/TLS** (recomendado)
   ```bash
   # Criar Secret com certificados
   kubectl create secret generic postgresql-ssl-certs \
     --from-file=server.crt \
     --from-file=server.key \
     --from-file=ca.crt
   ```
   
   Depois configure no values-production.yaml:
   ```yaml
   postgresql:
     ssl:
       secretName: postgresql-ssl-certs
   ```

3. **Ajustar o tamanho conforme sua carga**
   - `large`: Produção pequena (4Gi/8Gi RAM, 2-4 CPU)
   - `xlarge`: Produção média (8Gi/16Gi RAM, 4-8 CPU)
   - `2xlarge`: Produção grande (16Gi/32Gi RAM, 8-16 CPU)
   - `4xlarge`: Produção enterprise (32Gi/64Gi RAM, 16-32 CPU)

## Instalação

### Instalação Básica

```bash
helm install postgresql . -f values-production.yaml
```

### Instalação com Overrides

```bash
# Sobrescrever configurações específicas
helm install postgresql . -f values-production.yaml \
  --set postgresql.sizePreset=xlarge \
  --set backup.s3.bucket=meu-bucket-producao \
  --set postgresql.ssl.secretName=postgresql-ssl-certs
```

### Instalação com Senha Customizada

```bash
helm install postgresql . -f values-production.yaml \
  --set postgresql.password=MinhaSenhaSegura123!
```

## Configurações Importantes

### 1. Alta Disponibilidade

O arquivo já vem com:
- ✅ Pod Anti-Affinity habilitado
- ✅ Pod Disruption Budget configurado
- ✅ Read Replica habilitada

### 2. Segurança

- ✅ SSL/TLS habilitado (configure o secretName)
- ✅ Network Policies habilitadas
- ✅ Service Account configurado

### 3. Backups

- ✅ Backups diários às 2h da manhã
- ✅ Retenção de 30 backups (1 mês)
- ✅ Compressão habilitada
- ⚠️ **Configure o bucket S3 antes de instalar**

### 4. Monitoramento

- ✅ Prometheus Exporter habilitado
- ✅ ServiceMonitor configurado
- ✅ Métricas customizadas para produção

## Pós-Instalação

### 1. Verificar Status

```bash
# Verificar pods
kubectl get pods -l app.kubernetes.io/name=postgresql

# Verificar serviços
kubectl get svc -l app.kubernetes.io/name=postgresql

# Verificar backups
kubectl get cronjobs
```

### 2. Obter Senha

```bash
# Se a senha foi gerada automaticamente
kubectl get secret postgresql-postgresql \
  -o jsonpath="{.data.postgres-password}" | base64 -d && echo
```

### 3. Conectar ao Banco

```bash
# Via PgBouncer (recomendado)
kubectl port-forward svc/postgresql-pgbouncer 5432:5432

# Em outro terminal
psql -h localhost -U sadmin -d postgres
```

### 4. Verificar Métricas

```bash
# Port-forward do exporter
kubectl port-forward svc/postgresql-postgres-exporter 9187:9187

# Ver métricas
curl http://localhost:9187/metrics
```

## Ajustes Recomendados

### Para Cargas Altas

Se sua aplicação tem carga alta, ajuste:

```yaml
postgresql:
  sizePreset: xlarge # ou 2xlarge, 4xlarge

pgbouncer:
  maxClientConn: 5000
  defaultPoolSize: 100
```

### Para Máxima Segurança

```yaml
postgresql:
  ssl:
    mode: verify-full # Verificação completa de certificados

networkPolicy:
  enabled: true
  # Configure ingress específicos para sua arquitetura
```

### Para Disaster Recovery

```yaml
backup:
  retention: 90 # Manter 3 meses de backups

backupRestore:
  enabled: false # Habilitar apenas quando necessário
```

## Troubleshooting

### Pods não estão distribuídos em nós diferentes

```yaml
postgresql:
  affinity:
    podAntiAffinity:
      type: required # Mude de 'preferred' para 'required'
```

### Backups não estão funcionando

1. Verifique as credenciais S3:
```bash
kubectl get secret postgresql-backup-s3 -o yaml
```

2. Verifique os logs:
```bash
kubectl logs -l app.kubernetes.io/component=backup --tail=100
```

### SSL não está funcionando

1. Verifique se o Secret existe:
```bash
kubectl get secret postgresql-ssl-certs
```

2. Verifique se os arquivos estão corretos:
```bash
kubectl get secret postgresql-ssl-certs -o jsonpath="{.data.server\.crt}" | base64 -d
```

## Manutenção

### Atualizar Chart

```bash
helm upgrade postgresql . -f values-production.yaml
```

### Escalar Read Replica

```yaml
readReplica:
  replicas: 2 # Adicionar mais réplicas se necessário
```

### Ajustar Recursos

```bash
helm upgrade postgresql . -f values-production.yaml \
  --set postgresql.sizePreset=2xlarge
```

## Checklist de Produção

Antes de considerar a instalação pronta para produção, verifique:

- [ ] Bucket S3 configurado e acessível
- [ ] Certificados SSL/TLS configurados (se usar SSL)
- [ ] Network Policies ajustadas para sua arquitetura
- [ ] Tamanho do preset adequado para a carga esperada
- [ ] Backups testados e funcionando
- [ ] Monitoramento configurado e alertas criados
- [ ] Senha segura configurada (não usar senha gerada automaticamente em produção crítica)
- [ ] Read Replica testada e sincronizando
- [ ] Pod Anti-Affinity funcionando (pods em nós diferentes)
- [ ] Documentação de acesso e credenciais atualizada

## Suporte

Para problemas ou questões, consulte o README.md principal ou entre em contato com a equipe Eficify.

