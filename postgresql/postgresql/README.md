# PostgreSQL Helm Chart

Chart Helm completo para PostgreSQL com PgBouncer, backups automatizados e monitoramento Prometheus.

> **Proprietário**: Eficify - Este chart é proprietário da Eficify.

## Características

- **PostgreSQL latest**: Banco de dados principal configurável
- **Usuário padrão**: `sadmin` (configurável)
- **Senha automática**: Geração automática de senha se não fornecida
- **PgBouncer**: Connection pooler para otimização de conexões
- **Read Replica**: Réplica somente leitura com streaming replication
- **Redis Data Integration**: Sincronização em tempo real PostgreSQL -> Redis
- **Backups Automatizados**: Suporte para S3 e disco local com retenção configurável
- **Backup Restore**: Job para restaurar backups automaticamente
- **Monitoramento Prometheus**: Exportador de métricas com ServiceMonitor
- **Alta Disponibilidade**: Pod Anti-Affinity, Pod Disruption Budget
- **Segurança**: SSL/TLS, Network Policies, Service Accounts
- **Init Scripts**: Execução automática de scripts SQL na inicialização
- **Alta Configurabilidade**: Parâmetros de PostgreSQL, recursos e storage configuráveis

## Pré-requisitos

- Kubernetes 1.19+
- Helm 3.0+
- Prometheus Operator (para ServiceMonitor, opcional)
- StorageClass configurada (se usar persistent volumes)

## Instalação

### Instalação Básica

```bash
# Com valores padrão (tamanho small, senha será gerada automaticamente)
helm install postgresql .

# Com tamanho específico
helm install postgresql . --set postgresql.sizePreset=large

# Com senha customizada
helm install postgresql . --set postgresql.password=minhasenha

# Com arquivo de valores customizado
helm install postgresql . -f my-values.yaml
```

**Nota**: Se você não definir uma senha, uma senha aleatória de 32 caracteres será gerada automaticamente. Para obter a senha após a instalação:

```bash
kubectl get secret <release-name>-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d
```

### Instalação com PgBouncer

```bash
helm install postgresql . \
  --set pgbouncer.enabled=true
```

### Instalação com Read Replica

```bash
helm install postgresql . \
  --set postgresql.replication.enabled=true \
  --set readReplica.enabled=true
```

### Instalação com Backups S3

```bash
helm install postgresql . \
  --set backup.enabled=true \
  --set backup.destination=s3 \
  --set backup.s3.bucket=meu-bucket \
  --set backup.s3.region=us-east-1 \
  --set backup.s3.accessKeyId=AKIAIOSFODNN7EXAMPLE \
  --set backup.s3.secretAccessKey=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

### Instalação com Monitoramento

```bash
helm install postgresql . \
  --set monitoring.enabled=true \
  --set monitoring.serviceMonitor.enabled=true
```

### Instalação com Redis Data Integration

```bash
helm install postgresql . \
  --set redis.enabled=true \
  --set redisDataIntegration.enabled=true
```

Isso irá:
- Instalar um servidor Redis
- Configurar sincronização em tempo real do PostgreSQL para Redis
- Usar Debezium para capturar mudanças via WAL do PostgreSQL

## Configuração

### Tamanhos Pré-definidos

O chart oferece 6 tamanhos pré-definidos otimizados para diferentes cargas de trabalho. Use `postgresql.sizePreset` para selecionar:

| Tamanho | Descrição | Memória (Request/Limit) | CPU (Request/Limit) | Storage | Uso Recomendado | Observações |
|---------|-----------|-------------------------|---------------------|---------|-----------------|------------|
| `dev` | Ambiente de desenvolvimento | 512Mi / 1Gi | 250m / 500m | 10Gi | Dev | **Sem backup, sem replicação, 1 instância** |
| `stg` | Ambiente de staging | 2Gi / 4Gi | 1000m / 2000m | 50Gi | Staging | **Sem backup, sem replicação, 1 instância** |
| `small` | Ambiente de desenvolvimento/teste | 512Mi / 1Gi | 250m / 500m | 10Gi | Dev, Testes | |
| `medium` | Ambiente de staging | 2Gi / 4Gi | 1000m / 2000m | 50Gi | Staging | |
| `large` | Produção pequena | 4Gi / 8Gi | 2000m / 4000m | 100Gi | Produção pequena | |
| `xlarge` | Produção média | 8Gi / 16Gi | 4000m / 8000m | 200Gi | Produção média | |
| `2xlarge` | Produção grande | 16Gi / 32Gi | 8000m / 16000m | 500Gi | Produção grande | |
| `4xlarge` | Produção enterprise | 32Gi / 64Gi | 16000m / 32000m | 1Ti | Produção enterprise | |
| `custom` | Configuração personalizada | Definido em `postgresql.resources` | Definido em `postgresql.resources` | Definido em `postgresql.persistence.size` | Configuração manual | |

**Nota**: Os presets `dev` e `stg` são aliases para `small` e `medium` respectivamente, mas com configurações especiais:
- Backups desabilitados automaticamente
- Replicação desabilitada automaticamente
- Apenas 1 instância (single instance)

**Exemplos de uso:**

```bash
# Instalar com tamanho small (padrão)
helm install postgresql .

# Instalar ambiente dev (sem backup, sem replicação)
helm install postgresql . --set postgresql.sizePreset=dev

# Instalar ambiente stg (sem backup, sem replicação)
helm install postgresql . --set postgresql.sizePreset=stg

# Instalar com tamanho large
helm install postgresql . --set postgresql.sizePreset=large

# Instalar com tamanho enterprise
helm install postgresql . --set postgresql.sizePreset=4xlarge

# Expor porta publicamente (LoadBalancer)
helm install postgresql . \
  --set postgresql.sizePreset=large \
  --set postgresql.exposePublicly.enabled=true \
  --set postgresql.exposePublicly.serviceType=LoadBalancer \
  --set postgresql.exposePublicly.port=5433

# Usar configuração custom
helm install postgresql . --set postgresql.sizePreset=custom \
  --set postgresql.resources.requests.memory=6Gi \
  --set postgresql.resources.requests.cpu=3000m \
  --set postgresql.persistence.size=150Gi
```

**Importante**: Quando expor a porta publicamente, a porta **não pode ser 5432** por segurança. Use uma porta diferente (ex: 5433).

Cada preset inclui configurações otimizadas do PostgreSQL (shared_buffers, effective_cache_size, max_connections, etc.) baseadas no tamanho selecionado.

### Valores Principais

| Parâmetro | Descrição | Padrão |
|-----------|-----------|--------|
| `postgresql.enabled` | Habilita PostgreSQL | `true` |
| `postgresql.sizePreset` | Tamanho pré-definido (small, medium, large, xlarge, 2xlarge, 4xlarge, custom) | `small` |
| `postgresql.image.repository` | Imagem do PostgreSQL | `postgres` |
| `postgresql.image.tag` | Tag da imagem | `latest` |
| `postgresql.database` | Nome do banco de dados | `postgres` |
| `postgresql.username` | Usuário do banco | `sadmin` |
| `postgresql.password` | Senha do banco | `""` (gerada automaticamente se vazio) |
| `postgresql.replication.enabled` | Habilita configuração de replicação | `false` |
| `readReplica.enabled` | Habilita réplica somente leitura | `false` |
| `postgresql.persistence.enabled` | Usar volume persistente | `true` |
| `postgresql.persistence.size` | Tamanho do volume (usado apenas com custom) | `20Gi` |
| `pgbouncer.enabled` | Habilita PgBouncer | `true` |
| `backup.enabled` | Habilita backups | `true` |
| `backup.schedule` | Cron schedule para backups | `0 2 * * *` |
| `backup.destination` | Destino do backup (s3/disk) | `s3` |
| `monitoring.enabled` | Habilita monitoramento | `true` |

### Configuração do PostgreSQL

Os parâmetros do PostgreSQL podem ser ajustados em `postgresql.config`:

```yaml
postgresql:
  config:
    max_connections: 100
    shared_buffers: "256MB"
    effective_cache_size: "1GB"
    # ... mais parâmetros
```

### Alta Disponibilidade

```yaml
postgresql:
  affinity:
    podAntiAffinity:
      enabled: true
      type: preferred # ou required
      topologyKey: kubernetes.io/hostname

podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

### Segurança

#### SSL/TLS

```yaml
postgresql:
  ssl:
    enabled: true
    mode: require # disable, allow, prefer, require, verify-ca, verify-full
    secretName: postgresql-ssl-certs # Secret com server.crt, server.key, ca.crt
```

#### Network Policies

```yaml
networkPolicy:
  enabled: true
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            name: app-namespace
      ports:
      - protocol: TCP
        port: 5432
```

### Init Scripts

Execute scripts SQL automaticamente na inicialização:

```yaml
postgresql:
  initScripts:
    enabled: true
    scripts:
      - name: init-schema.sql
        content: |
          CREATE SCHEMA IF NOT EXISTS app_schema;
          CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
          CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
```

### Backup Restore

Restaurar backups automaticamente após instalação:

```yaml
backupRestore:
  enabled: true
  restoreFromS3:
    bucket: "my-backup-bucket"
    key: "backups/postgresql-backup-20241219.sql.gz"
    region: "us-east-1"
  options:
    dropBeforeRestore: false
    createDatabase: true
```

### Redis Data Integration

Sincronizar dados do PostgreSQL para Redis em tempo real:

```yaml
redis:
  enabled: true
  password: "" # Gerada automaticamente se vazio
  persistence:
    enabled: true
    size: 10Gi

redisDataIntegration:
  enabled: true
  sync:
    # Sincronizar tabelas específicas
    tables:
      - schema: public
        table: users
        key: id
        redisKey: "user:{id}"
      - schema: public
        table: products
        key: product_id
        redisKey: "product:{product_id}"
    mode: realtime # realtime ou snapshot
    format: json # json, hash, string
    keyPrefix: "pg:"
```

**Nota**: O Redis Data Integration sincroniza dados do PostgreSQL para Redis. 
- **Modo realtime**: Polling rápido (1 segundo) para sincronização quase em tempo real
- **Modo polling**: Sincronização periódica conforme intervalo configurado
- O PostgreSQL é configurado automaticamente com `wal_level = logical` quando Redis Data Integration está habilitado
- Suporta múltiplos formatos: JSON, Hash ou String no Redis
- Chaves no Redis seguem o padrão: `{prefix}{schema}:{table}:{primary_key}`

### Configuração do PgBouncer

```yaml
pgbouncer:
  enabled: true
  poolMode: transaction # session, transaction, statement
  maxClientConn: 1000
  defaultPoolSize: 25
  minPoolSize: 5
```

### Configuração de Backups

#### Backups para S3

```yaml
backup:
  enabled: true
  schedule: "0 2 * * *" # Diariamente às 2h
  destination: s3
  retention: 7 # Manter 7 backups
  compression: true
  s3:
    bucket: "meu-bucket"
    region: "us-east-1"
    accessKeyId: "AKIA..."
    secretAccessKey: "secret..."
    # Ou usar IAM role (EKS)
    useIAMRole: false
```

#### Backups para Disco

```yaml
backup:
  enabled: true
  schedule: "0 2 * * *"
  destination: disk
  retention: 7
  disk:
    path: "/backups"
    retentionDays: 7
```

### Configuração de Monitoramento

```yaml
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
  postgresExporter:
    enabled: true
    image:
      repository: quay.io/prometheuscommunity/postgres-exporter
      tag: "v0.15.0"
```

### Ingress Automático com Traefik (SSL)

Quando SSL está habilitado, o Ingress com Traefik é configurado automaticamente:

```yaml
postgresql:
  ssl:
    enabled: true
    mode: require

ingress:
  hostnameServer: "k8s-prod" # Ajuste conforme seu ambiente
  # Hostname será gerado automaticamente: [random]-db.[hostname-server].eficify.cloud
  # Exemplo: a1b2c3d4-db.k8s-prod.eficify.cloud
```

O hostname é gerado automaticamente no formato: `[random]-db.[hostname-server].eficify.cloud`

**Quando Read Replica está habilitada:**
- Um Ingress adicional é criado automaticamente para a réplica de leitura
- Hostname da réplica: `[random]-db-ra.[hostname-server].eficify.cloud`
- O sufixo `-ra` identifica que é a réplica de leitura (Read Replica)

**Exemplo de uso:**

```bash
# Com SSL habilitado, o Ingress será criado automaticamente
helm install postgresql . \
  --set postgresql.ssl.enabled=true \
  --set ingress.hostnameServer=k8s-prod

# Com Read Replica, dois Ingress serão criados:
helm install postgresql . \
  --set postgresql.ssl.enabled=true \
  --set postgresql.replication.enabled=true \
  --set readReplica.enabled=true \
  --set ingress.hostnameServer=k8s-prod

# Hostnames gerados:
# Master: a1b2c3d4-db.k8s-prod.eficify.cloud
# Read Replica: x9y8z7w6-db-ra.k8s-prod.eficify.cloud
```

## Uso

### Conectar ao PostgreSQL

```bash
# Via PgBouncer (recomendado)
kubectl port-forward svc/postgresql-pgbouncer 5432:5432
psql -h localhost -U sadmin -d postgres

# Diretamente ao PostgreSQL
kubectl port-forward svc/postgresql-postgresql 5432:5432
psql -h localhost -U sadmin -d postgres

# Via Read Replica (somente leitura)
kubectl port-forward svc/postgresql-read-replica 5432:5432
psql -h localhost -U sadmin -d postgres
```

### Verificar Backups

```bash
# Listar backups no S3
aws s3 ls s3://meu-bucket/ | grep postgresql-backup

# Ver logs do último backup
kubectl logs -l app.kubernetes.io/component=backup --tail=50
```

### Acessar Métricas do Prometheus

```bash
# Port-forward do exporter
kubectl port-forward svc/postgresql-postgres-exporter 9187:9187

# Ver métricas
curl http://localhost:9187/metrics
```

## Métricas Disponíveis

O PostgreSQL Exporter expõe várias métricas, incluindo:

- `pg_up`: Status do PostgreSQL (1 = up, 0 = down)
- `pg_stat_database_*`: Estatísticas do banco de dados
- `pg_stat_activity_*`: Atividade de conexões
- `pg_stat_bgwriter_*`: Estatísticas do background writer
- `pg_replication_*`: Métricas de replicação (se configurado)

## Troubleshooting

### Verificar Status do PostgreSQL

```bash
kubectl get pods -l app.kubernetes.io/component=postgresql
kubectl logs -l app.kubernetes.io/component=postgresql
```

### Verificar Status do PgBouncer

```bash
kubectl get pods -l app.kubernetes.io/component=pgbouncer
kubectl logs -l app.kubernetes.io/component=pgbouncer
```

### Verificar Backups

```bash
# Ver CronJobs
kubectl get cronjobs

# Ver Jobs de backup
kubectl get jobs -l app.kubernetes.io/component=backup

# Ver logs do último backup
kubectl logs -l app.kubernetes.io/component=backup --tail=100
```

### Problemas Comuns

1. **Senha não definida**: Se não definir uma senha, uma será gerada automaticamente. Use `kubectl get secret` para obtê-la
2. **Volume não criado**: Verifique se o StorageClass está configurado corretamente
3. **Backup falhando**: Verifique as credenciais S3 ou permissões do IAM role
4. **Métricas não aparecem**: Verifique se o Prometheus Operator está instalado e o ServiceMonitor foi criado
5. **Read Replica não sincroniza**: Certifique-se de que `postgresql.replication.enabled=true` está configurado no master

## Desinstalação

```bash
helm uninstall postgresql
```

**Atenção**: A desinstalação não remove os PersistentVolumeClaims por padrão. Para remover completamente:

```bash
kubectl delete pvc -l app.kubernetes.io/name=postgresql
```

## Suporte

Para problemas ou questões, abra uma issue no repositório do projeto.

