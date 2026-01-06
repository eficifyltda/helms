# PostgreSQL Production Helm Chart

Chart Helm otimizado para PostgreSQL em produção com **PgBouncer, Replicação de Leitura/Escrita e Backup Automático já habilitados por padrão**.

> **Proprietário**: Eficify - Este chart é proprietário da Eficify.

## Características

Este chart é uma versão otimizada para produção que já vem com:

- ✅ **PVC com nome único**: Cada release gera um PVC com hash único, evitando conflitos e perda de dados acidental

- ✅ **PgBouncer habilitado por padrão**: Connection pooler para otimização de conexões
- ✅ **Replicação de Leitura/Escrita habilitada por padrão**: Streaming replication configurado
- ✅ **Read Replica habilitada por padrão**: Réplica somente leitura para distribuir carga
- ✅ **Backup Automático habilitado por padrão**: Backups diários configurados (S3 ou disco)
- ✅ **PostgreSQL 18.1**: Banco de dados principal configurável
- ✅ **Monitoramento Prometheus**: Exportador de métricas com ServiceMonitor
- ✅ **Alta Disponibilidade**: Pod Anti-Affinity, Pod Disruption Budget
- ✅ **Segurança**: SSL/TLS, Network Policies, Service Accounts
- ✅ **Init Scripts**: Extensões úteis pré-configuradas (pg_stat_statements, uuid-ossp, pg_trgm)
- ✅ **PVC com nome único**: Cada release gera um PVC com hash único baseado no Release.Name e Namespace, evitando conflitos e perda de dados acidental

## Pré-requisitos

- Kubernetes 1.19+
- Helm 3.0+
- Prometheus Operator (para ServiceMonitor, opcional)
- StorageClass configurada (se usar persistent volumes)
- **Para backups S3**: Bucket S3 configurado ou IAM role (EKS)

## Instalação

### Instalação Básica (Recomendada)

```bash
# Instalação com valores padrão (PgBouncer, Replicação e Backup já habilitados)
helm install postgresql-prod . -n postgresql --create-namespace

# Com tamanho específico
helm install postgresql-prod . --set postgresql.sizePreset=xlarge -n postgresql

# Com senha customizada
helm install postgresql-prod . --set postgresql.password=minhasenha -n postgresql
```

**Nota**: Se você não definir uma senha, uma senha aleatória de 32 caracteres será gerada automaticamente. Para obter a senha após a instalação:

```bash
kubectl get secret <release-name>-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d
```

### Instalação com Backup S3

```bash
helm install postgresql-prod . \
  --set backup.s3.bucket=meu-bucket-producao \
  --set backup.s3.region=us-east-1 \
  --set backup.s3.accessKeyId=AKIAIOSFODNN7EXAMPLE \
  --set backup.s3.secretAccessKey=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
  -n postgresql
```

### Instalação com IAM Role (EKS)

```bash
helm install postgresql-prod . \
  --set backup.s3.bucket=meu-bucket-producao \
  --set backup.s3.region=us-east-1 \
  --set backup.s3.useIAMRole=true \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::ACCOUNT:role/postgresql-role \
  -n postgresql
```

### Instalação com Arquivo de Valores

```bash
# Criar arquivo my-values.yaml com suas configurações
helm install postgresql-prod . -f my-values.yaml -n postgresql
```

## Configuração

### Tamanhos Pré-definidos

O chart oferece 6 tamanhos pré-definidos otimizados para produção:

| Tamanho | Descrição | Memória (Request/Limit) | CPU (Request/Limit) | Storage | Uso Recomendado |
|---------|-----------|-------------------------|---------------------|---------|-----------------|
| `small` | Ambiente de desenvolvimento/teste | 512Mi / 1Gi | 250m / 500m | 10Gi | Dev, Testes |
| `medium` | Ambiente de staging | 2Gi / 4Gi | 1000m / 2000m | 50Gi | Staging |
| `large` | **Produção pequena (padrão)** | 4Gi / 8Gi | 2000m / 4000m | 100Gi | Produção pequena |
| `xlarge` | Produção média | 8Gi / 16Gi | 4000m / 8000m | 200Gi | Produção média |
| `2xlarge` | Produção grande | 16Gi / 32Gi | 8000m / 16000m | 500Gi | Produção grande |
| `4xlarge` | Produção enterprise | 32Gi / 64Gi | 16000m / 32000m | 1Ti | Produção enterprise |
| `custom` | Configuração personalizada | Definido em `postgresql.resources` | Definido em `postgresql.resources` | Definido em `postgresql.persistence.size` | Configuração manual |

**Exemplos de uso:**

```bash
# Instalar com tamanho large (padrão)
helm install postgresql-prod .

# Instalar com tamanho xlarge
helm install postgresql-prod . --set postgresql.sizePreset=xlarge

# Instalar com tamanho enterprise
helm install postgresql-prod . --set postgresql.sizePreset=4xlarge
```

### Valores Principais

| Parâmetro | Descrição | Padrão |
|-----------|-----------|--------|
| `postgresql.enabled` | Habilita PostgreSQL | `true` |
| `postgresql.sizePreset` | Tamanho pré-definido | `large` |
| `postgresql.database` | Nome do banco de dados | `postgres` |
| `postgresql.username` | Usuário do banco | `sadmin` |
| `postgresql.password` | Senha do banco | `""` (gerada automaticamente) |
| `postgresql.replication.enabled` | Habilita configuração de replicação | `true` ✅ |
| `readReplica.enabled` | Habilita réplica somente leitura | `true` ✅ |
| `postgresql.exposePublicly.enabled` | Expõe PostgreSQL publicamente | `false` ⚠️ |
| `pgbouncer.enabled` | Habilita PgBouncer | `true` ✅ |
| `pgbouncer.exposePublicly.enabled` | Expõe PgBouncer publicamente | `true` ✅ |
| `pgbouncer.exposePublicly.port` | Porta do PgBouncer quando exposto | `5432` |
| `pgbouncer.exposePublicly.serviceType` | Tipo de service (LoadBalancer/NodePort) | `LoadBalancer` |
| `backup.enabled` | Habilita backups | `true` ✅ |
| `backup.schedule` | Cron schedule para backups | `0 2 * * *` (diariamente às 2h) |
| `backup.retention` | Número de backups a manter | `30` (30 dias) |
| `backup.destination` | Destino do backup (s3/disk) | `s3` |
| `monitoring.enabled` | Habilita monitoramento | `true` |
| `monitoring.serviceMonitor.enabled` | Habilita ServiceMonitor (requer Prometheus Operator) | `false` ⚠️ |

### Configuração do PgBouncer (Já Habilitado)

O PgBouncer já vem configurado e otimizado para produção, e **exposto publicamente por padrão**:

```yaml
pgbouncer:
  enabled: true  # ✅ Já habilitado por padrão
  poolMode: transaction
  maxClientConn: 2000
  defaultPoolSize: 50
  minPoolSize: 10
  reservePoolSize: 10
  
  # Exposição pública (habilitada por padrão)
  exposePublicly:
    enabled: true  # ✅ Exposto publicamente por padrão
    serviceType: LoadBalancer  # LoadBalancer ou NodePort
    port: 5432  # Porta configurável
```

**Conexão via PgBouncer (recomendado):**
- Service: `<release-name>-pgbouncer`
- Tipo: `LoadBalancer` (por padrão, exposto publicamente)
- Porta: `5432` (configurável via `pgbouncer.exposePublicly.port`)
- Use este endpoint para todas as conexões da aplicação

**Configurar porta diferente do PgBouncer:**
```bash
helm install postgresql-prod . \
  --set pgbouncer.exposePublicly.port=15432
```

**Desabilitar exposição pública do PgBouncer:**
```bash
helm install postgresql-prod . \
  --set pgbouncer.exposePublicly.enabled=false
```

### Configuração de Replicação (Já Habilitada)

A replicação de leitura/escrita já vem habilitada:

```yaml
postgresql:
  replication:
    enabled: true  # ✅ Já habilitado por padrão
    max_wal_senders: 10
    wal_keep_size: "2GB"
    hot_standby: true
    hot_standby_feedback: true

readReplica:
  enabled: true  # ✅ Já habilitado por padrão
```

**Endpoints disponíveis:**
- **Master (escrita)**: `<release-name>-postgresql:5432`
- **Read Replica (leitura)**: `<release-name>-read-replica:5432`
- **PgBouncer (pooler)**: `<release-name>-pgbouncer:5432` (recomendado)

### Configuração de Backups (Já Habilitado)

Os backups automáticos já vêm configurados:

```yaml
backup:
  enabled: true  # ✅ Já habilitado por padrão
  schedule: "0 2 * * *"  # Diariamente às 2h
  destination: s3
  retention: 30  # Manter 30 backups (30 dias)
  compression: true
  s3:
    bucket: ""  # ⚠️ CONFIGURE com seu bucket S3
    region: "us-east-1"
    useIAMRole: false
```

**⚠️ IMPORTANTE**: Configure o bucket S3 antes de instalar:

```bash
helm install postgresql-prod . \
  --set backup.s3.bucket=meu-bucket-producao \
  --set backup.s3.region=us-east-1 \
  --set backup.s3.accessKeyId=AKIA... \
  --set backup.s3.secretAccessKey=secret...
```

### Alta Disponibilidade

```yaml
postgresql:
  affinity:
    podAntiAffinity:
      enabled: true  # ✅ Já habilitado por padrão
      type: preferred
      topologyKey: kubernetes.io/hostname

podDisruptionBudget:
  enabled: true  # ✅ Já habilitado por padrão
  minAvailable: 1
```

### Segurança

#### SSL/TLS

```yaml
postgresql:
  ssl:
    enabled: false  # Configure conforme necessário
    mode: require
    secretName: postgresql-ssl-certs
```

### Init Scripts (Pré-configurados)

Extensões úteis já vêm configuradas:

```yaml
postgresql:
  initScripts:
    enabled: true  # ✅ Já habilitado por padrão
    scripts:
      - name: init-extensions.sql
        content: |
          CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
          CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
          CREATE EXTENSION IF NOT EXISTS "pg_trgm";
```

## Arquitetura

```
┌─────────────────┐
│   Aplicações    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   PgBouncer     │ ← Connection Pooler (Recomendado)
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐ ┌──────────────┐
│ Master │ │ Read Replica │
│(Escrita)│ │  (Leitura)   │
└────────┘ └──────────────┘
    │
    ▼
┌─────────┐
│ Backup  │ ← CronJob diário (S3)
└─────────┘
```

## Uso

### Conectar ao PostgreSQL

**⚠️ IMPORTANTE**: Por padrão, apenas o **PgBouncer é exposto publicamente** (LoadBalancer). O PostgreSQL Master e Read Replica são **apenas internos** (ClusterIP) por segurança.

```bash
# Via PgBouncer (RECOMENDADO - exposto publicamente por padrão)
# Se exposto como LoadBalancer, use o IP externo do service
kubectl get svc postgresql-prod-pgbouncer
psql -h <EXTERNAL-IP> -p 5432 -U sadmin -d postgres

# Ou via port-forward (para testes locais)
kubectl port-forward svc/postgresql-prod-pgbouncer 5432:5432
psql -h localhost -U sadmin -d postgres

# Diretamente ao PostgreSQL Master (apenas interno - use port-forward)
kubectl port-forward svc/postgresql-prod-postgresql 5432:5432
psql -h localhost -U sadmin -d postgres

# Via Read Replica (apenas interno - use port-forward)
kubectl port-forward svc/postgresql-prod-read-replica 5432:5432
psql -h localhost -U sadmin -d postgres
```

### String de Conexão

**Para aplicações externas (use PgBouncer - exposto publicamente):**
```
# Se LoadBalancer, use o IP externo
postgresql://sadmin:PASSWORD@<EXTERNAL-IP>:5432/postgres

# Ou se configurou porta diferente
postgresql://sadmin:PASSWORD@<EXTERNAL-IP>:<PORTA>/postgres
```

**Para aplicações internas no cluster (use PgBouncer):**
```
postgresql://sadmin:PASSWORD@postgresql-prod-pgbouncer:5432/postgres
```

**Para escrita (Master - apenas interno):**
```
postgresql://sadmin:PASSWORD@postgresql-prod-postgresql:5432/postgres
```

**Para leitura (Read Replica - apenas interno):**
```
postgresql://sadmin:PASSWORD@postgresql-prod-read-replica:5432/postgres
```

### Verificar Status

```bash
# Ver pods
kubectl get pods -l app.kubernetes.io/name=postgresql-prod

# Ver serviços
kubectl get svc -l app.kubernetes.io/name=postgresql-prod

# Ver logs do PostgreSQL
kubectl logs -l app.kubernetes.io/component=postgresql

# Ver logs do PgBouncer
kubectl logs -l app.kubernetes.io/component=pgbouncer

# Ver logs do Read Replica
kubectl logs -l app.kubernetes.io/component=read-replica
```

### Verificar Backups

```bash
# Ver CronJobs
kubectl get cronjobs

# Ver Jobs de backup
kubectl get jobs -l app.kubernetes.io/component=backup

# Ver logs do último backup
kubectl logs -l app.kubernetes.io/component=backup --tail=100

# Listar backups no S3
aws s3 ls s3://meu-bucket-producao/ | grep postgresql-backup
```

### Verificar Replicação

```bash
# Verificar lag de replicação
kubectl exec -it <postgresql-pod> -- psql -U sadmin -d postgres -c "SELECT pg_last_wal_replay_lsn(), pg_last_wal_receive_lsn();"

# Verificar status da réplica
kubectl exec -it <read-replica-pod> -- psql -U sadmin -d postgres -c "SELECT pg_is_in_recovery();"
```

### Acessar Métricas do Prometheus

```bash
# Port-forward do exporter
kubectl port-forward svc/postgresql-prod-postgres-exporter 9187:9187

# Ver métricas
curl http://localhost:9187/metrics
```

## Métricas Disponíveis

O PostgreSQL Exporter expõe várias métricas, incluindo:

- `pg_up`: Status do PostgreSQL (1 = up, 0 = down)
- `pg_stat_database_*`: Estatísticas do banco de dados
- `pg_stat_activity_*`: Atividade de conexões
- `pg_replication_lag`: Lag de replicação (em segundos)
- `pg_stat_bgwriter_*`: Estatísticas do background writer

## Troubleshooting

### Verificar Status do PostgreSQL

```bash
kubectl get pods -l app.kubernetes.io/component=postgresql
kubectl logs -l app.kubernetes.io/component=postgresql --tail=50
```

### Verificar Status do PgBouncer

```bash
kubectl get pods -l app.kubernetes.io/component=pgbouncer
kubectl logs -l app.kubernetes.io/component=pgbouncer --tail=50

# Conectar ao admin do PgBouncer
kubectl port-forward svc/postgresql-prod-pgbouncer 9127:9127
curl http://localhost:9127/metrics
```

### Verificar Read Replica

```bash
kubectl get pods -l app.kubernetes.io/component=read-replica
kubectl logs -l app.kubernetes.io/component=read-replica --tail=50

# Verificar se está em modo recovery
kubectl exec -it <read-replica-pod> -- psql -U sadmin -d postgres -c "SELECT pg_is_in_recovery();"
```

### Problemas Comuns

1. **Erro "no matches for kind ServiceMonitor"**: O ServiceMonitor requer o Prometheus Operator. Desabilite-o no values.yaml:
   ```bash
   --set monitoring.serviceMonitor.enabled=false
   ```
   Ou no seu arquivo de valores: `monitoring.serviceMonitor.enabled: false`

2. **Backup falhando**: Verifique as credenciais S3 ou permissões do IAM role

3. **Read Replica não sincroniza**: Verifique se o master está acessível e se a replicação está habilitada

4. **PgBouncer não conecta**: Verifique se o PostgreSQL master está rodando

5. **Senha não definida**: Use `kubectl get secret` para obter a senha gerada automaticamente

6. **Volume não criado**: Verifique se o StorageClass está configurado corretamente

## Desinstalação

```bash
helm uninstall postgresql-prod
```

**⚠️ ATENÇÃO**: A desinstalação não remove os PersistentVolumeClaims por padrão. Para remover completamente:

```bash
# Remover PVCs (cada release tem um PVC único com hash)
kubectl get pvc -n database | grep postgresql-prod
kubectl delete pvc <nome-do-pvc-único> -n database

# Ou remover todos os PVCs do release
kubectl delete pvc -l app.kubernetes.io/name=postgresql-prod -n database

# Verificar backups antes de remover (IMPORTANTE!)
aws s3 ls s3://meu-bucket-producao/ | grep postgresql-backup
```

**Nota sobre PVCs únicos**: Cada release do Helm gera um PVC com um nome único contendo um hash baseado no `Release.Name` e `Namespace`. Isso garante que:
- Novos releases não sobrescrevem dados de releases anteriores
- Múltiplos releases no mesmo namespace não conflitam
- Reinstalações não acidentalmente deletam dados existentes

## Diferenças do Chart Base

Este chart de produção difere do chart base (`postgresql`) nas seguintes configurações:

| Feature | Chart Base | Chart Produção |
|---------|------------|----------------|
| PgBouncer | Opcional (`enabled: false`) | **Habilitado por padrão** ✅ |
| Replicação | Opcional (`enabled: false`) | **Habilitada por padrão** ✅ |
| Read Replica | Opcional (`enabled: false`) | **Habilitada por padrão** ✅ |
| Backup | Opcional (`enabled: true`, mas desabilitado para dev/stg) | **Habilitado por padrão** ✅ |
| Retenção de Backup | 7 backups | **30 backups** (30 dias) |
| Tamanho Padrão | `small` | `large` |
| Pod Anti-Affinity | Opcional | **Habilitado por padrão** ✅ |
| Pod Disruption Budget | Opcional | **Habilitado por padrão** ✅ |
| Init Scripts | Opcional | **Habilitado com extensões úteis** ✅ |

## Suporte

Para problemas ou questões, abra uma issue no repositório do projeto.

