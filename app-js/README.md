# App JS Helm Chart

Um chart Helm simples para rodar aplicações JavaScript (Backend + Frontend Next.js).

## Características

- ✅ Backend Node.js configurável
- ✅ Frontend Next.js com imagem padrão
- ✅ PostgreSQL incluído para desenvolvimento
- ✅ Services separados para backend e frontend
- ✅ Exposição pública opcional do frontend
- ✅ Ingress com Traefik (HTTPS automático)
- ✅ Monitoramento Prometheus (ServiceMonitor)
- ✅ Otimizado para desenvolvimento

## Instalação

```bash
# Instalar com backend e frontend (com Ingress Traefik)
helm install app-js . -n app-js --create-namespace

# Instalar com DNS customizado
helm install app-js . -n app-js --create-namespace \
  --set ingress.frontend.host=meuapp-front.s4160.eficify.cloud \
  --set ingress.backend.host=meuapp-back.s4160.eficify.cloud

# Instalar expondo frontend via LoadBalancer (alternativa ao Ingress)
helm install app-js . -n app-js --create-namespace \
  --set exposeFrontend.enabled=true \
  --set exposeFrontend.port=80 \
  --set ingress.enabled=false
```

## Configuração

### Valores Principais

```yaml
backend:
  enabled: true
  image:
    repository: node
    tag: "20-alpine"
  port: 3000
  env:
    DATABASE_URL: "postgresql://user:pass@host:5432/db"

frontend:
  enabled: true
  image:
    repository: node
    tag: "20-alpine"
  port: 3000
  env:
    NEXT_PUBLIC_API_URL: "http://backend:3000"

postgresql:
  enabled: true
  username: postgres
  password: "" # Auto-generated if empty
  database: postgres
  persistence:
    enabled: true
    size: 10Gi

exposeFrontend:
  enabled: false
  serviceType: LoadBalancer
  port: 80
```

## Valores Configuráveis

| Parâmetro | Descrição | Padrão |
|-----------|-----------|--------|
| `backend.enabled` | Habilitar backend | `true` |
| `backend.image.repository` | Imagem do backend | `node` |
| `backend.image.tag` | Tag da imagem | `20-alpine` |
| `backend.port` | Porta do backend | `3000` |
| `backend.env` | Variáveis de ambiente do backend | `{}` |
| `frontend.enabled` | Habilitar frontend | `true` |
| `frontend.image.repository` | Imagem do frontend | `node` |
| `frontend.image.tag` | Tag da imagem | `20-alpine` |
| `frontend.port` | Porta do frontend | `3000` |
| `frontend.env` | Variáveis de ambiente do frontend | `{}` |
| `exposeFrontend.enabled` | Expor frontend via LoadBalancer | `false` |
| `exposeFrontend.serviceType` | Tipo do Service público | `LoadBalancer` |
| `exposeFrontend.port` | Porta pública | `80` |
| `ingress.enabled` | Habilitar Ingress (Traefik) | `true` |
| `ingress.className` | Ingress class name | `traefik` |
| `ingress.frontend.enabled` | Habilitar Ingress do frontend | `true` |
| `ingress.frontend.host` | DNS do frontend | `passkey-front.s4160.eficify.cloud` |
| `ingress.frontend.tls` | Habilitar HTTPS | `true` |
| `ingress.backend.enabled` | Habilitar Ingress do backend | `true` |
| `ingress.backend.host` | DNS do backend | `passkey-back.s4160.eficify.cloud` |
| `ingress.backend.tls` | Habilitar HTTPS | `true` |
| `monitoring.enabled` | Habilitar monitoramento Prometheus | `true` |
| `monitoring.serviceMonitor.enabled` | Criar ServiceMonitor | `true` |
| `monitoring.serviceMonitor.interval` | Intervalo de scraping | `30s` |
| `monitoring.serviceMonitor.scrapeTimeout` | Timeout de scraping | `10s` |
| `monitoring.backend.enabled` | Habilitar métricas do backend | `true` |
| `monitoring.backend.path` | Path das métricas do backend | `/metrics` |
| `monitoring.frontend.enabled` | Habilitar métricas do frontend | `true` |
| `monitoring.frontend.path` | Path das métricas do frontend | `/metrics` |
| `postgresql.enabled` | Habilitar PostgreSQL | `true` |
| `postgresql.image.repository` | Imagem do PostgreSQL | `postgres` |
| `postgresql.image.tag` | Tag da imagem | `18.1` |
| `postgresql.username` | Usuário do banco | `postgres` |
| `postgresql.password` | Senha (gerada automaticamente se vazio) | `""` |
| `postgresql.database` | Nome do banco | `postgres` |
| `postgresql.persistence.enabled` | Habilitar volume persistente | `true` |
| `postgresql.persistence.size` | Tamanho do volume | `10Gi` |
| `postgresql.service.port` | Porta do serviço | `5432` |

## Conectar

### Backend (interno)
```bash
kubectl port-forward svc/<release-name>-backend \
  3000:3000 -n app-js
```

### Frontend (interno)
```bash
kubectl port-forward svc/<release-name>-frontend \
  3000:3000 -n app-js
```

### Frontend (público - se habilitado via LoadBalancer)
```bash
# Obter IP externo
kubectl get svc <release-name>-frontend-public -n app-js

# Acessar via navegador
http://<EXTERNAL-IP>
```

### Frontend e Backend (via Ingress Traefik - HTTPS)
```bash
# Frontend
https://passkey-front.s4160.eficify.cloud

# Backend
https://passkey-back.s4160.eficify.cloud
```

### PostgreSQL (interno)
```bash
# Port-forward
kubectl port-forward svc/<release-name>-postgresql \
  5432:5432 -n app-js

# Connection String (interno no cluster)
postgresql://postgres:<password>@<release-name>-postgresql:5432/postgres

# Obter senha gerada automaticamente
kubectl get secret <release-name>-postgresql -n app-js \
  -o jsonpath="{.data.postgres-password}" | base64 -d && echo
```

### Usar PostgreSQL no Backend

Configure a variável de ambiente `DATABASE_URL` no backend:

```yaml
backend:
  env:
    DATABASE_URL: "postgresql://postgres:<password>@<release-name>-postgresql:5432/postgres"
```

Ou use o nome do serviço diretamente (se a senha estiver no secret):

```yaml
backend:
  env:
    DATABASE_HOST: "<release-name>-postgresql"
    DATABASE_PORT: "5432"
    DATABASE_USER: "postgres"
    DATABASE_PASSWORD: "<password-from-secret>"
    DATABASE_NAME: "postgres"
```

## Desinstalação

```bash
helm uninstall app-js -n app-js
```

## Ingress com Traefik

O chart está configurado para usar Traefik como Ingress Controller por padrão:

- **Frontend**: `https://passkey-front.s4160.eficify.cloud`
- **Backend**: `https://passkey-back.s4160.eficify.cloud`

### Configurar DNS customizado

```yaml
ingress:
  frontend:
    host: meuapp-front.s4160.eficify.cloud
  backend:
    host: meuapp-back.s4160.eficify.cloud
```

O Traefik gerencia automaticamente os certificados TLS/HTTPS.

## PostgreSQL (Desenvolvimento)

O chart inclui PostgreSQL para facilitar o desenvolvimento local. O PostgreSQL é configurado de forma simples e otimizada para desenvolvimento.

### Configuração

```yaml
postgresql:
  enabled: true
  image:
    repository: postgres
    tag: "18.1"
  username: postgres
  password: "" # Gerada automaticamente se vazio
  database: postgres
  persistence:
    enabled: true
    size: 10Gi
  service:
    type: ClusterIP
    port: 5432
```

### Desabilitar PostgreSQL

Se você já tem um PostgreSQL externo, pode desabilitar o PostgreSQL incluído:

```bash
helm install app-js . -n app-js --create-namespace \
  --set postgresql.enabled=false
```

### Usar PostgreSQL no Backend

O backend pode se conectar ao PostgreSQL usando o nome do serviço:

```yaml
backend:
  env:
    DATABASE_URL: "postgresql://postgres:<password>@<release-name>-postgresql:5432/postgres"
```

O nome do serviço será: `<release-name>-postgresql`

## Monitoramento Prometheus

O chart inclui suporte completo para monitoramento via Prometheus:

### ServiceMonitor

O chart cria automaticamente `ServiceMonitor` resources para backend e frontend quando `monitoring.enabled=true` e `monitoring.serviceMonitor.enabled=true`.

### Configuração

```yaml
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    scrapeTimeout: 10s
    labels: {}  # Labels adicionais (ex: release: prometheus)
  
  backend:
    enabled: true
    path: /metrics
    port: http
  
  frontend:
    enabled: true
    path: /metrics
    port: http
```

### Annotations nos Services

Os Services são automaticamente anotados com:
- `prometheus.io/scrape: "true"`
- `prometheus.io/port: "3000"`
- `prometheus.io/path: "/metrics"`

Isso permite que o Prometheus descubra e scrape as métricas automaticamente.

### Requisitos

- Prometheus Operator instalado no cluster
- ServiceMonitor CRD disponível
- Aplicações devem expor métricas no endpoint `/metrics` (padrão Prometheus)

### Verificar métricas

```bash
# Verificar ServiceMonitors criados
kubectl get servicemonitor -n app-js

# Verificar métricas expostas (via port-forward)
kubectl port-forward svc/<release-name>-backend 3000:3000 -n app-js
curl http://localhost:3000/metrics
```

## Notas

- Este chart usa imagens Node.js padrão por enquanto
- As aplicações precisam estar configuradas para rodar nas portas especificadas
- O backend e frontend podem ser desabilitados individualmente
- Ingress com Traefik está habilitado por padrão (HTTPS automático)
- A exposição via LoadBalancer é uma alternativa ao Ingress

