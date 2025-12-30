# PostgreSQL Simple Helm Chart

Um chart Helm simples e otimizado para desenvolvimento do PostgreSQL com suporte opcional ao PgBouncer.

## Características

- ✅ PostgreSQL 18.1
- ✅ Configuração simples e direta
- ✅ PgBouncer opcional
- ✅ Otimizado para desenvolvimento
- ✅ Sem complexidade desnecessária

## Instalação

```bash
# Instalar sem PgBouncer
helm install postgresql . -n postgresql --create-namespace

# Instalar com PgBouncer
helm install postgresql . -n postgresql --create-namespace \
  --set pgbouncer.enabled=true
```

## Configuração

### Valores Principais

```yaml
postgresql:
  username: postgres
  password: ""  # Auto-gerado se vazio
  database: postgres
  
  persistence:
    enabled: true
    size: 10Gi

pgbouncer:
  enabled: false  # Habilitar para usar PgBouncer
  poolMode: transaction
  maxClientConn: 100
  defaultPoolSize: 25
```

## Obter Credenciais

```bash
# Obter senha
kubectl get secret <release-name>-postgresql-simple-postgresql \
  -n postgresql \
  -o jsonpath="{.data.postgres-password}" | base64 -d && echo

# Obter usuário
kubectl get secret <release-name>-postgresql-simple-postgresql \
  -n postgresql \
  -o jsonpath="{.data.postgres-user}" | base64 -d && echo
```

## Conectar ao Banco

### Sem PgBouncer
```bash
kubectl port-forward svc/<release-name>-postgresql-simple-postgresql \
  5432:5432 -n postgresql

psql -h localhost -U postgres -d postgres
```

### Com PgBouncer
```bash
kubectl port-forward svc/<release-name>-postgresql-simple-pgbouncer \
  5432:5432 -n postgresql

psql -h localhost -U postgres -d postgres
```

## Valores Configuráveis

| Parâmetro | Descrição | Padrão |
|-----------|-----------|--------|
| `postgresql.username` | Usuário do PostgreSQL | `postgres` |
| `postgresql.password` | Senha (vazio = auto-gerado) | `""` |
| `postgresql.database` | Nome do banco | `postgres` |
| `postgresql.persistence.enabled` | Habilitar PVC | `true` |
| `postgresql.persistence.size` | Tamanho do PVC | `10Gi` |
| `postgresql.volumePermissions.enabled` | Habilitar initContainer para corrigir permissões | `false` |
| `postgresql.securityContext.enabled` | Habilitar security context | `true` |
| `postgresql.securityContext.runAsUser` | UID do usuário (não root) | `1001` |
| `postgresql.securityContext.fsGroup` | GID do grupo | `1001` |
| `pgbouncer.enabled` | Habilitar PgBouncer | `false` |
| `pgbouncer.poolMode` | Modo do pool | `transaction` |
| `service.type` | Tipo do Service | `ClusterIP` |
| `service.port` | Porta do Service | `5432` |

### Security Context

Por padrão, o chart configura o PostgreSQL para **não rodar como root**:
- `securityContext.enabled: true`
- `runAsUser: 1001` (não root)
- `fsGroup: 1001`

Se você precisar corrigir as permissões do volume (especialmente em volumes persistentes novos), habilite:
```yaml
postgresql:
  volumePermissions:
    enabled: true
```

**Nota:** A imagem oficial do PostgreSQL usa o usuário 999 por padrão. Se você usar 1001, certifique-se de que o initContainer de permissões está habilitado ou que o volume já tem as permissões corretas.

## Desinstalação

```bash
helm uninstall postgresql -n postgresql
```

## Notas

- Este chart é otimizado para **desenvolvimento** e não deve ser usado em produção sem revisão adequada
- O PgBouncer é opcional e pode ser habilitado quando necessário
- A senha é auto-gerada se não fornecida
- Os dados são persistidos em um PVC por padrão

