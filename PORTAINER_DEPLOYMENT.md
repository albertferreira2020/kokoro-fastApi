# Kokoro FastAPI - Portainer Deployment Guide

Este guia explica como fazer o deploy do Kokoro FastAPI em um servidor Linux Ubuntu usando Portainer.

## Pré-requisitos

- Servidor Linux Ubuntu com Docker instalado
- Portainer instalado e configurado
- Pelo menos 4GB de RAM disponível
- Pelo menos 2GB de espaço em disco para o modelo

## Deploy via Portainer

### Método 1: Stack Deployment (Recomendado)

1. No Portainer, vá para **Stacks** > **Add Stack**
2. Nomeie a stack como `kokoro-fastapi`
3. Cole o conteúdo do `docker-compose.yml`
4. Clique em **Deploy the stack**

### Método 2: Build from Repository

1. No Portainer, vá para **App Templates** > **Custom Templates**
2. Crie um novo template com este repositório
3. Configure as variáveis de ambiente necessárias

## Variáveis de Ambiente

- `DOWNLOAD_MODEL=true` - Download automático do modelo (recomendado)
- `USE_GPU=false` - Usar CPU (padrão)
- `MODEL_DIR=src/models` - Diretório dos modelos
- `VOICES_DIR=src/voices/v1_0` - Diretório das vozes

## Volumes Persistentes

O docker-compose cria volumes persistentes para:

- `kokoro_models` - Armazena os modelos baixados (≈400MB)
- `kokoro_temp` - Arquivos temporários de áudio
- `kokoro_web` - Interface web

## Portas

- **8880** - API FastAPI e interface web

## Healthcheck

O container inclui um healthcheck que verifica:
- Se a API está respondendo em `/health`
- Intervalo de 30 segundos
- Timeout de 10 segundos
- 3 tentativas antes de marcar como unhealthy
- 180 segundos de startup time (para download do modelo)

## Recursos

- **Limite de memória**: 4GB
- **Memória reservada**: 2GB
- **CPU**: Compartilhado (sem limite específico)

## Primeira Execução

Na primeira execução, o container irá:

1. Instalar as dependências Python
2. Baixar o modelo Kokoro (~400MB) automaticamente
3. Iniciar o servidor FastAPI

Este processo pode levar alguns minutos na primeira vez.

## Acesso

Após o deploy bem-sucedido:

- **API**: `http://seu-servidor:8880`
- **Documentação**: `http://seu-servidor:8880/docs`
- **Interface Web**: `http://seu-servidor:8880` (se disponível)

## Logs

Para visualizar os logs:
1. No Portainer, vá para **Containers**
2. Clique no container `kokoro-fastapi`
3. Vá para a aba **Logs**

## Troubleshooting

### Container não inicia
- Verifique se há RAM suficiente (mínimo 2GB)
- Verifique os logs para erros de download do modelo
- Certifique-se de que a porta 8880 está disponível

### Download do modelo falha
- Verifique a conectividade com a internet
- O container tentará várias estratégias de download
- Os modelos são baixados do GitHub Releases

### Performance lenta
- Considere aumentar os recursos de CPU
- Para melhor performance, use a versão GPU em servidores com NVIDIA GPU

## Comandos Úteis

### Atualizar o container
```bash
docker-compose pull
docker-compose up -d
```

### Verificar status
```bash
docker-compose ps
docker-compose logs -f kokoro-fastapi
```

### Backup dos modelos
```bash
docker cp kokoro-fastapi:/app/api/src/models ./backup-models
```

## Segurança

Para produção, considere:
- Usar um proxy reverso (nginx/traefik)
- Configurar HTTPS
- Limitar acesso por IP se necessário
- Configurar firewall apropriado
