# n8n Helm Chart

Este chart Helm instala o [n8n](https://n8n.io/) com PostgreSQL otimizado para uso com n8n.

## Pré-requisitos

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner para suporte a armazenamento persistente (quando habilitado)

## Instalação

```bash
helm install my-n8n ./n8n
```

## Desinstalação

```bash
helm uninstall my-n8n
```

## Configuração

Os valores configuráveis estão documentados no arquivo `values.yaml`. Alguns parâmetros importantes:

### n8n

- `n8n.image.repository`: Imagem do n8n (padrão: `n8nio/n8n`)
- `n8n.image.tag`: Tag da imagem (padrão: `2.1.4`)
- `n8n.resources`: Recursos de CPU e memória
- `n8n.env`: Variáveis de ambiente do n8n

### PostgreSQL

- `postgresql.enabled`: Habilita/desabilita PostgreSQL (padrão: `true`)
- `postgresql.image.repository`: Imagem do PostgreSQL (padrão: `postgres`)
- `postgresql.image.tag`: Tag da imagem (padrão: `18.1`)
- `postgresql.username`: Usuário do banco de dados (padrão: `n8n`)
- `postgresql.password`: Senha do banco (se vazio, será gerada automaticamente)
- `postgresql.database`: Nome do banco de dados (padrão: `n8n`)
- `postgresql.persistence.size`: Tamanho do volume persistente (padrão: `20Gi`)
- `postgresql.resources`: Recursos de CPU e memória

### Ingress

- `ingress.enabled`: Habilita Ingress (padrão: `true`)
- `ingress.host`: Hostname para o Ingress (padrão: `n8n.s4160.eficify.cloud`)
- `ingress.className`: Classe do Ingress (padrão: `traefik`)
- `ingress.tls`: Habilita TLS (padrão: `true`)

## Exemplo de instalação com valores customizados

Crie um arquivo `my-values.yaml`:

```yaml
n8n:
  resources:
    requests:
      memory: "1Gi"
      cpu: "1000m"
    limits:
      memory: "4Gi"
      cpu: "4000m"

postgresql:
  persistence:
    size: 50Gi
  resources:
    requests:
      memory: "1Gi"
      cpu: "1000m"
    limits:
      memory: "4Gi"
      cpu: "4000m"

ingress:
  host: n8n.example.com
```

Instale com:

```bash
helm install my-n8n ./n8n -f my-values.yaml
```

## Notas

- O PostgreSQL é configurado automaticamente com parâmetros otimizados para n8n
- A senha do PostgreSQL é gerada automaticamente se não for fornecida
- O n8n se conecta automaticamente ao PostgreSQL usando as credenciais configuradas
- O primeiro acesso ao n8n pode levar alguns minutos para inicializar o banco de dados
- O WEBHOOK_URL é configurado automaticamente baseado no ingress quando habilitado

## Recursos

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Docker Image](https://hub.docker.com/r/n8nio/n8n)

