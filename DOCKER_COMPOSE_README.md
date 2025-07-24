# Docker Compose para Kokoro FastAPI

Este projeto inclui configurações Docker Compose para executar o Kokoro FastAPI usando CPU.

## Arquivos Docker Compose

### 1. docker-compose.yml (Principal)
Este arquivo usa o script `start-cpu.sh` diretamente através de um Dockerfile personalizado.

**Para usar:**
```bash
# Construir e iniciar o container
docker-compose up --build

# Executar em background
docker-compose up -d --build

# Parar o container
docker-compose down
```

### 2. docker-compose-cpu.yml (Alternativo)
Este arquivo usa o Dockerfile existente em `docker/cpu/` e replica os comandos do script start-cpu.sh.

**Para usar:**
```bash
# Construir e iniciar o container
docker-compose -f docker-compose-cpu.yml up --build

# Executar em background
docker-compose -f docker-compose-cpu.yml up -d --build

# Parar o container
docker-compose -f docker-compose-cpu.yml down
```

## Configurações

### Portas
- **8880**: Porta do servidor FastAPI (mapeada para a mesma porta no host)

### Volumes
- `./api/src/models`: Modelos do Kokoro
- `./api/temp_files`: Arquivos temporários de áudio
- `./web`: Interface web (se disponível)
- `./docker/scripts`: Scripts de download de modelos

### Variáveis de Ambiente
- `USE_GPU=false`: Desabilita GPU
- `USE_ONNX=false`: Desabilita ONNX
- `MODEL_DIR=src/models`: Diretório dos modelos
- `VOICES_DIR=src/voices/v1_0`: Diretório das vozes
- `WEB_PLAYER_PATH=/app/web`: Caminho do player web
- `ESPEAK_DATA_PATH`: Caminho dos dados do espeak-ng

## Verificação de Saúde

O container inclui um healthcheck que verifica se o servidor está respondendo na rota `/health` a cada 30 segundos.

## Logs

Para ver os logs do container:
```bash
# docker-compose.yml
docker-compose logs -f

# docker-compose-cpu.yml
docker-compose -f docker-compose-cpu.yml logs -f
```

## Notas

1. O primeiro build pode demorar devido ao download de dependências e modelos
2. O container instala automaticamente o Rust (necessário para algumas dependências)
3. Os modelos são baixados automaticamente na primeira execução
4. O servidor fica disponível em `http://localhost:8880`
