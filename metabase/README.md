# Metabase Helm Chart

Este chart Helm instala o [Metabase](https://www.metabase.com/) com PostgreSQL otimizado para uso com Metabase.

## Pré-requisitos

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner para suporte a armazenamento persistente (quando habilitado)

## Instalação

```bash
helm install my-metabase ./metabase
```

## Desinstalação

```bash
helm uninstall my-metabase
```

## Configuração

Os valores configuráveis estão documentados no arquivo `values.yaml`. Alguns parâmetros importantes:

### Metabase

- `metabase.image.repository`: Imagem do Metabase (padrão: `metabase/metabase`)
- `metabase.image.tag`: Tag da imagem (padrão: `v0.50.0`)
- `metabase.resources`: Recursos de CPU e memória
- `metabase.javaOptions`: Opções JVM para o Metabase

### PostgreSQL

- `postgresql.enabled`: Habilita/desabilita PostgreSQL (padrão: `true`)
- `postgresql.image.repository`: Imagem do PostgreSQL (padrão: `postgres`)
- `postgresql.image.tag`: Tag da imagem (padrão: `18.1`)
- `postgresql.username`: Usuário do banco de dados (padrão: `metabase`)
- `postgresql.password`: Senha do banco (se vazio, será gerada automaticamente)
- `postgresql.database`: Nome do banco de dados (padrão: `metabase`)
- `postgresql.persistence.size`: Tamanho do volume persistente (padrão: `20Gi`)
- `postgresql.resources`: Recursos de CPU e memória

### Ingress

- `ingress.enabled`: Habilita Ingress (padrão: `true`)
- `ingress.host`: Hostname para o Ingress
- `ingress.className`: Classe do Ingress (padrão: `traefik`)
- `ingress.tls`: Habilita TLS (padrão: `true`)

## Exemplo de instalação com valores customizados

Crie um arquivo `my-values.yaml`:

```yaml
metabase:
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
  host: metabase.example.com
```

Instale com:

```bash
helm install my-metabase ./metabase -f my-values.yaml
```

## Notas

- O PostgreSQL é configurado automaticamente com parâmetros otimizados para Metabase
- A senha do PostgreSQL é gerada automaticamente se não for fornecida
- O Metabase se conecta automaticamente ao PostgreSQL usando as credenciais configuradas
- O primeiro acesso ao Metabase pode levar alguns minutos para inicializar o banco de dados

## Recursos

- [Metabase Documentation](https://www.metabase.com/docs/)
- [Metabase Docker Image](https://hub.docker.com/r/metabase/metabase)

