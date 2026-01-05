# Ansible Playbook - Setup k3s, kubectl e Helm

Este playbook do Ansible automatiza a instalação e configuração de:
- Atualização e upgrade do sistema Ubuntu
- kubectl
- k3s (Kubernetes leve)
- Helm

## Pré-requisitos

1. Ansible instalado na máquina de controle:
   ```bash
   pip install ansible
   # ou
   sudo apt install ansible
   ```

2. Acesso SSH aos servidores Ubuntu de destino
3. Usuário com privilégios sudo nos servidores de destino

## Configuração

1. Edite o arquivo `inventory.ini` e adicione seus servidores:
   ```ini
   [servers]
   ubuntu-server ansible_host=192.168.1.100 ansible_user=ubuntu
   ```

2. (Opcional) Configure autenticação SSH:
   - Use chaves SSH: `ansible_ssh_private_key_file=~/.ssh/id_rsa`
   - Ou configure senha no arquivo de inventário

## Uso

### Executar o playbook completo:
```bash
ansible-playbook playbook.yml
```

### Executar em um servidor específico:
```bash
ansible-playbook playbook.yml -l ubuntu-server
```

### Executar com verbose:
```bash
ansible-playbook playbook.yml -v
# ou mais verboso
ansible-playbook playbook.yml -vvv
```

### Testar conexão antes de executar:
```bash
ansible all -m ping
```

## Variáveis

Você pode personalizar as versões editando as variáveis no início do playbook:

```yaml
vars:
  k3s_version: "latest"      # ou versão específica como "v1.28.0+k3s1"
  kubectl_version: "latest"  # ou versão específica como "v1.28.0"
  helm_version: "latest"     # Helm sempre instala a última versão
```

Ou crie um arquivo `vars.yml` e use:
```bash
ansible-playbook playbook.yml -e @vars.yml
```

## O que o playbook faz

1. **Atualização do sistema**: Atualiza a lista de pacotes e faz upgrade completo
2. **Instalação de dependências**: Instala pacotes necessários (curl, wget, etc.)
3. **Instalação do kubectl**: Baixa e instala o kubectl
4. **Instalação do k3s**: Instala o k3s e configura o kubeconfig
5. **Instalação do Helm**: Instala o Helm 3

## Após a execução

Após executar o playbook, você pode:

- Verificar o cluster k3s:
  ```bash
  kubectl get nodes
  ```

- Usar o Helm:
  ```bash
  helm list
  ```

- O arquivo de configuração do k3s estará em: `/etc/rancher/k3s/k3s.yaml`
- Uma cópia será criada em: `~/.kube/config` (se o usuário tiver HOME definido)

## Notas

- O playbook usa `become: yes` para executar tarefas como root
- O k3s será instalado como serviço systemd
- O kubectl será configurado automaticamente para usar o k3s
- O Helm será instalado na versão mais recente disponível

