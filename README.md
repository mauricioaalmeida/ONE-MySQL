<div align="center">
    <h1>MySQL com Docker (Windows + WSL2) e Bancos de Exemplo</h1>
    <p>Um ambiente local com Docker para utilização do MySQL no curso ONE-Alura, contendo os Bancos de Dados de Exemplo</p>
    <img src="https://img.shields.io/badge/Docker-0DB7ED?style=flat-square&logo=docker&logoColor=0DB7ED&labelColor=2E2E2E&color=0DB7ED" alt="Docker">
    <img src="https://img.shields.io/badge/MySQL-336791?style=flat-square&logo=mysql&logoColor=white&labelColor=2E2E2E&color=0DB7ED" alt="MySQL">
    <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License">
    <img src="https://img.shields.io/badge/Version-1.00.0-blue?style=flat-square" alt="Version 1.0">
</div>
# MySQL com Docker (Windows + WSL2) e Bancos de Exemplo

Este repositório traz um guia passo-a-passo para instalar o **Docker Desktop no Windows (com WSL 2)** e rodar uma instância local do **MySQL 8.4 (LTS)** pré-carregada com bancos de exemplo oficiais:

- **Sakila** (exemplo de loja de locação de filmes)  
- **World** (base geográfica simples)  
- **Employees** (conjunto de testes da comunidade Datacharmer)

> Observação: usamos a tag `mysql:8.4` (linha LTS) para estabilidade e reprodutibilidade. Se preferir usar `latest`, troque a imagem base, mas saiba que `latest` pode acompanhar linhas mais novas com mudanças frequentes.

---

## 🚀 Pré-requisitos

- Windows 10/11 compatível com WSL 2 e virtualização habilitada.  
- WSL 2 instalado (recomenda-se a distro **Ubuntu**).  
- Docker Desktop para Windows, com integração **WSL 2** ativada.

---

## 1. Instalar/Preparar WSL 2 (resumido)

Abra **PowerShell como Administrador** e execute:

```powershell
# Instala WSL (distro padrão) e configura o kernel
wsl --install
```

Se preferir instalar manualmente ou tiver instalações antigas, siga a documentação oficial do Windows sobre WSL 2.

Se for necessário habilitar recursos manualmente:

```powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Reinicie o Windows se solicitado. Depois abra sua distro Linux (ex.: Ubuntu) e confirme que `wsl -l -v` mostra WSL 2 como padrão.

---

## 2. Instalar Docker Desktop

1. Baixe e instale o Docker Desktop para Windows.  
2. Nas configurações do Docker Desktop (Settings):
   - Em **General**: habilite **Use the WSL 2 based engine**.
   - Em **Resources → WSL Integration**: habilite a integração para sua distro (ex.: Ubuntu).  
3. Teste com:
```powershell
docker run hello-world
docker version
```

---

## 3. Estrutura do repositório (já incluída neste zip/repo)

```
mysql-exemplos/
├─ Dockerfile
├─ compose.yaml
└─ README.md
```

- `Dockerfile`: constrói uma imagem baseada em `mysql:8.4` e baixa os dumps de Sakila, World e Employees, deixando-os em `/docker-entrypoint-initdb.d` para importação automática na **primeira inicialização**.
- `compose.yaml`: serviço para facilitar o `docker compose up`.
- `README.md`: este arquivo.

---

## 4. Como funciona o Dockerfile

A imagem oficial do MySQL executa automaticamente qualquer script `.sql`, `.sh` ou `.sql.gz` presente em `/docker-entrypoint-initdb.d/` **somente** quando o diretório de dados (`/var/lib/mysql`) está vazio. O `Dockerfile` faz o download dos dumps oficiais e os copia para esse diretório com prefixos numéricos (`01_`, `02_`, ...) para garantir a ordem de importação.

**Motivo:** permitir que, ao criar um volume de dados novo, o container inicialize o MySQL e importe automaticamente os bancos de exemplo na primeira inicialização.

---

## 5. Comandos práticos (PowerShell)

1. **Build da imagem** (na pasta onde está o `Dockerfile`):

```powershell
docker build -t mysql-exemplos:8.4 .
```

2. **Criar volume para persistência**:

```powershell
docker volume create mysql_dados
```

3. **Rodar o container**:

> **NÃO** coloque senhas no Dockerfile. Passe via variável de ambiente. Substitua `TroqueEstaSenha!` por uma senha segura.

```powershell
docker run -d --name mysql-exemplos `
  -p 3306:3306 `
  -v mysql_dados:/var/lib/mysql `
  -e MYSQL_ROOT_PASSWORD=TroqueEstaSenha! `
  mysql-exemplos:8.4
```

4. **Acompanhar logs** (útil para ver a importação dos dumps):

```powershell
docker logs -f mysql-exemplos
```

5. **Verificar bancos criados** (quando o MySQL estiver pronto):

```powershell
docker exec -it mysql-exemplos mysql -uroot -pTroqueEstaSenha! -e "SHOW DATABASES;"
```

Você deve ver (além das internas): `sakila`, `world` e `employees`.

---

## 6. Usando Docker Compose

Se preferir, use o `compose.yaml` incluído. Para subir com Compose:

```powershell
docker compose up -d --build
```

Para parar e remover containers (mantendo volume):

```powershell
docker compose down
```

---

## 7. Reimportar os exemplos (reiniciar do zero)

Os scripts de `/docker-entrypoint-initdb.d` rodam **apenas** quando o datadir está vazio. Para recriar do zero e reexecutar a importação:

```powershell
docker rm -f mysql-exemplos
docker volume rm mysql_dados
# então rode novamente 'docker run' ou 'docker compose up'
```

> Aviso: isso remove permanentemente os dados do volume `mysql_dados`.

---

## 8. Boas práticas e observações

- **Segurança:** nunca commit suas senhas em repositórios. Use variáveis de ambiente, arquivos `.env` no Compose (excluídos via `.gitignore`) ou secret managers.  
- **Versão da imagem:** pinne a tag (`mysql:8.4`) para reprodutibilidade. Evite `mysql:latest` em ambientes de produção.  
- **Porta ocupada:** se `3306` estiver em uso localmente, mapeie uma porta diferente: `-p 3307:3306`.
- **Problemas de CPU/Arquitetura:** em CPUs muito antigas ou arquiteturas diferentes pode haver incompatibilidades com algumas tags oficiais. Experimente variantes baseadas em Debian ou tags mais antigas se ocorrer erro de instrução de CPU.  
- **Windows + volumes:** usar volumes nomeados (`docker volume`) evita muitos problemas de permissões comparado a bind mounts no Windows.

---

## 9. Fonte dos bancos de exemplo

- Sakila e World: downloads oficiais MySQL/Oracle (padrão)
- Employees: repositório `datacharmer/test_db` no GitHub

---

## 10. Exemplos de uso (clientes)

Conecte com qualquer cliente MySQL (MySQL Workbench, DBeaver, TablePlus):

- Host: `localhost` (ou IP da sua máquina/WSL)  
- Porta: `3306` (ou porta que mapeou)  
- Usuário: `root`  
- Senha: a que foi informada em `MYSQL_ROOT_PASSWORD`

---

## 11. Troubleshooting rápido

- **Logs mostram erros de importação:** verifique a senha, se o container terminou corretamente ou se há erros de permissão.  
- **Container inicia e fecha imediatamente:** rode `docker logs <container>` e procure por mensagens de erro (ex.: arquivos de configuração inválidos, falta de permissão no volume, etc.).  
- **Import muito lento:** em máquinas com poucos recursos a importação de `employees` pode demorar; aguarde os logs mostrarem "ready for connections".

---

## 12. Licença

Este repositório é fornecido como exemplo para fins educacionais e de teste. Os bancos de dados de exemplo são distribuídos pelas suas fontes originais (MySQL/Oracle e Datacharmer). Use-os conforme as licenças dessas fontes.

---

## 13. Contato / Autor


<div align="center">
    <img loading="lazy" src="https://avatars.githubusercontent.com/u/195226841?v=4" width=115><br>
    <h3>Desenvolvido por Mauricio A. Almeida</h3>
    <a href="https://github.com/mauricioaalmeida"><img src="https://img.shields.io/badge/GitHub-181717?style=flat-square&logo=github&logoColor=FFFFFF" alt="GitHub"></a>
    <a href="https://linkedin.com/in/mauricioaalmeida"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=flat-square&logo=linkedin&logoColor=FFFFFF" alt="LinkedIn"></a>
</div>
