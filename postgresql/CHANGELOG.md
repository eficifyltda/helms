# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.4.1] - 2024-12-19

### Implementação
- **Ingress Automático com Traefik**: Quando SSL está habilitado, o Ingress é configurado automaticamente
- **Hostname Automático**: Geração automática de hostname no formato `[random]-db.[hostname-server].eficify.cloud`
- **Traefik como padrão**: Configuração automática do Traefik como ingress controller quando SSL está habilitado

### Melhoria
- Ingress habilitado automaticamente quando `postgresql.ssl.enabled = true`
- Hostname gerado automaticamente se não especificado
- Anotações do Traefik configuradas automaticamente
- NOTES.txt atualizado com informações do Ingress

## [1.4.0] - 2024-12-19

### Implementação
- **Pod Anti-Affinity**: Distribuição de pods em nós diferentes para alta disponibilidade
- **Pod Disruption Budget**: Proteção contra interrupções durante manutenções
- **Network Policies**: Controle de tráfego de rede para segurança
- **SSL/TLS**: Suporte a conexões criptografadas com certificados
- **Init Scripts**: Execução automática de scripts SQL na inicialização
- **Service Account**: Suporte a Service Accounts com RBAC e anotações (ex: AWS IAM)
- **Backup Restore Job**: Job para restaurar backups de S3 ou disco local
- **Health Checks Configuráveis**: Parâmetros avançados para liveness e readiness probes

### Melhoria
- Configurações de health checks agora são customizáveis via values.yaml
- Init containers para executar scripts SQL antes da aplicação conectar
- Suporte a certificados SSL via Secrets
- Network policies configuráveis para controle de acesso granular
- Pod Anti-Affinity configurável (preferred ou required)

### Segurança
- SSL/TLS habilitável com diferentes modos (require, verify-ca, verify-full)
- Network Policies para isolar tráfego de rede
- Service Account com suporte a anotações para integração com IAM (AWS EKS)

### Operações
- Backup Restore Job como Helm hook para restaurar automaticamente após instalação
- Init Scripts para inicialização de schemas, extensões e dados iniciais
- Pod Disruption Budget para garantir disponibilidade durante atualizações

## [1.3.0] - 2024-12-19

### Implementação
- Aliases `dev` e `stg` para presets small e medium respectivamente
- Configuração automática para ambientes dev/stg:
  - Backups desabilitados automaticamente
  - Replicação desabilitada automaticamente
  - Apenas 1 instância (single instance)
- Opção de expor porta publicamente (LoadBalancer ou NodePort)
- Validação de segurança: porta 5432 não permitida quando exposta publicamente
- Template NOTES.txt completo mostrando informações da instalação:
  - Senha gerada (se aplicável)
  - Tamanho e configuração
  - Status dos serviços
  - Instruções de conexão
- Informações de propriedade Eficify adicionadas ao Chart.yaml e README

### Melhoria
- Helpers para mapear aliases dev/stg para small/medium
- Helpers para controlar habilitação de backup e replicação baseado no preset
- Validação automática de porta quando exposta publicamente
- Documentação completa dos novos recursos

### Segurança
- Validação que impede uso da porta 5432 quando exposta publicamente
- Porta padrão para exposição pública: 5433

## [1.2.0] - 2024-12-19

### Implementação
- Sistema de presets de tamanhos pré-definidos para PostgreSQL
- 6 tamanhos disponíveis: small, medium, large, xlarge, 2xlarge, 4xlarge
- Opção custom para configuração manual completa
- Helpers templates para aplicar presets automaticamente
- Configurações otimizadas do PostgreSQL baseadas no tamanho selecionado
- Recursos (CPU/memória) e storage ajustados automaticamente por preset

### Melhoria
- Tamanho padrão definido como "small" para ambientes de desenvolvimento
- Configurações de PostgreSQL (shared_buffers, effective_cache_size, max_connections, etc.) otimizadas por tamanho
- Storage size ajustado automaticamente baseado no preset
- Documentação completa dos tamanhos disponíveis no README

### Detalhes dos Presets

#### small (padrão)
- Ambiente: Desenvolvimento/Teste
- Recursos: 512Mi/1Gi RAM, 250m/500m CPU
- Storage: 10Gi
- Configurações otimizadas para cargas leves

#### medium
- Ambiente: Staging
- Recursos: 2Gi/4Gi RAM, 1000m/2000m CPU
- Storage: 50Gi
- Configurações para ambientes de teste intermediários

#### large
- Ambiente: Produção pequena
- Recursos: 4Gi/8Gi RAM, 2000m/4000m CPU
- Storage: 100Gi
- Para cargas de trabalho moderadas

#### xlarge
- Ambiente: Produção média
- Recursos: 8Gi/16Gi RAM, 4000m/8000m CPU
- Storage: 200Gi
- Para cargas de trabalho altas

#### 2xlarge
- Ambiente: Produção grande
- Recursos: 16Gi/32Gi RAM, 8000m/16000m CPU
- Storage: 500Gi
- Para cargas de trabalho muito altas

#### 4xlarge
- Ambiente: Produção enterprise
- Recursos: 32Gi/64Gi RAM, 16000m/32000m CPU
- Storage: 1Ti
- Para cargas de trabalho extremas

## [1.1.0] - 2024-12-19

### Melhoria
- Geração automática de senha quando não fornecida pelo usuário
- Usuário padrão alterado de "postgres" para "sadmin"
- Versão do PostgreSQL atualizada para "latest"
- Implementação de réplica somente leitura (read replica) com streaming replication
- Configuração de replicação no PostgreSQL master (wal_level, max_wal_senders, etc)
- Init container na réplica para aguardar master estar pronto e configurar replicação
- Templates completos para read replica (deployment, service, configmap, pvc)
- Helpers adicionais para read replica (labels e selectors)

### Implementação
- Helper function para gerar senha aleatória de 32 caracteres quando não fornecida
- Configuração de replicação habilitável no values.yaml
- Read replica com suporte a hot standby e streaming replication
- pg_basebackup automático na inicialização da réplica

## [1.0.0] - 2024-12-19

### Implementação
- Chart Helm completo para PostgreSQL 15.4
- Implementação do PgBouncer como connection pooler
- Sistema de backups automatizados com suporte para S3 e disco local
- Integração com Prometheus através do PostgreSQL Exporter
- ServiceMonitor para descoberta automática de métricas
- Configuração completa do PostgreSQL com parâmetros otimizados
- PersistentVolumeClaim para armazenamento de dados
- Health checks (liveness e readiness probes) para todos os componentes
- Secrets gerenciados para credenciais sensíveis
- ConfigMaps para configurações do PostgreSQL e PgBouncer
- CronJob configurável para backups agendados
- Suporte para retenção de backups (S3 e disco)
- Compressão de backups opcional
- Suporte para IAM roles do AWS (EKS)
- Suporte para S3-compatible storage (MinIO, etc)
- Métricas customizadas do PostgreSQL Exporter
- Labels e selectors padronizados para todos os recursos
- Helpers templates para reutilização de código

### Componentes Incluídos

#### PostgreSQL
- Deployment com configuração completa
- Service para acesso interno
- ConfigMap com parâmetros do PostgreSQL
- Secret para credenciais
- PersistentVolumeClaim para dados

#### PgBouncer
- Deployment com pool de conexões configurável
- Service para acesso via PgBouncer
- ConfigMap com configuração do PgBouncer
- Secret para autenticação

#### Backups
- CronJob para backups agendados
- Suporte para destino S3
- Suporte para destino em disco
- Retenção configurável de backups
- Compressão opcional
- Limpeza automática de backups antigos
- Secret para credenciais S3 (opcional)

#### Monitoramento
- PostgreSQL Exporter deployment
- Service para exposição de métricas
- ServiceMonitor para Prometheus Operator
- ConfigMap para queries customizadas
- Secret para conexão do exporter

### Configurações Padrão

- PostgreSQL 15.4
- PgBouncer 1.21.0
- PostgreSQL Exporter v0.15.0
- Backups diários às 2h (configurável)
- Retenção de 7 backups
- Volume persistente de 20Gi
- Recursos otimizados para produção

### Documentação

- README.md completo com exemplos de uso
- CHANGELOG.md para rastreamento de mudanças
- Valores padrão bem documentados no values.yaml
- Comentários nos templates para facilitar manutenção

