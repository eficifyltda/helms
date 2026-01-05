#!/bin/bash
# Script helper para atualizar o chart monitor com hostname automático
# Uso: ./upgrade.sh [release-name] [namespace] [opções adicionais do helm]

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Obter hostname da máquina
HOSTNAME=$(hostname 2>/dev/null || echo "s4125")
if [ -z "$HOSTNAME" ] || [ "$HOSTNAME" == "localhost" ]; then
    # Tentar obter de outras fontes
    HOSTNAME=$(cat /etc/hostname 2>/dev/null || echo "s4125")
fi

echo -e "${GREEN}Detectado hostname: ${HOSTNAME}${NC}"

# Parâmetros
RELEASE_NAME="${1:-monitor}"
NAMESPACE="${2:-monitoring}"
HELM_OPTS="${@:3}"

echo -e "${GREEN}Atualizando chart monitor...${NC}"
echo -e "  Release: ${RELEASE_NAME}"
echo -e "  Namespace: ${NAMESPACE}"
echo -e "  Hostname: ${HOSTNAME}"
echo -e "  Domínio Grafana: grafana.${HOSTNAME}.eficify.cloud"

# Verificar se helm está instalado
if ! command -v helm &> /dev/null; then
    echo -e "${RED}Erro: helm não está instalado${NC}"
    exit 1
fi

# Atualizar repositórios
echo -e "${YELLOW}Atualizando repositórios...${NC}"
helm repo update

# Baixar dependências
echo -e "${YELLOW}Baixando dependências...${NC}"
helm dependency update

# Atualizar o chart
echo -e "${GREEN}Atualizando chart...${NC}"
helm upgrade "${RELEASE_NAME}" . \
    --namespace "${NAMESPACE}" \
    --set grafanaIngress.hostname="${HOSTNAME}" \
    ${HELM_OPTS}

echo -e "${GREEN}✓ Atualização concluída!${NC}"
echo -e ""
echo -e "Acesse o Grafana em: https://grafana.${HOSTNAME}.eficify.cloud"

