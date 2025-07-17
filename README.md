# Portal da Educação

Este projeto é uma aplicação de desktop para gerenciar um sistema de portal de educação, permitindo matricular alunos, cadastrar turmas, disciplinas e instituições.

## Tecnologias

* **Backend:** Python
* **Banco de Dados:** PostgreSQL
* **GUI:** PyQt6

## Como Executar

Existem duas maneiras de executar este projeto: com Docker (recomendado) ou configurando o ambiente localmente.

### Opção 1: Com Docker

Esta abordagem gerencia o banco de dados PostgreSQL e o pgAdmin em contêineres, simplificando a configuração.

**Pré-requisitos:**
* Python 3.10+
* Docker
* Docker Compose

**Passos:**

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/seu-usuario/seu-repositorio.git
   cd seu-repositorio
   ```

2. **Suba os contêineres do banco de dados e pgAdmin:**
   O comando a seguir irá baixar as imagens necessárias e iniciar os serviços em segundo plano. O banco de dados será populado com os dados iniciais do arquivo `init/init.sql`.
   ```bash
   docker-compose up -d
   ```

3. **Crie e ative um ambiente virtual:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

4. **Instale as dependências do Python:**
   ```bash
   pip install -r requirements.txt
   ```

5. **Execute a aplicação:**
   ```bash
   python3 app_gui.py
   ```

### Opção 2: Sem Docker (Ambiente Local)

Esta abordagem requer que você tenha o PostgreSQL instalado e configurado em sua máquina local.

**Pré-requisitos:**
* Python 3.10+
* PostgreSQL instalado e em execução.

**Passos:**

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/seu-usuario/seu-repositorio.git
   cd seu-repositorio
   ```

2. **Configure o Banco de Dados:**
   - Crie um banco de dados no PostgreSQL chamado `portal_educacao`.
   - Crie um usuário (role) com nome `admin` e senha `admin`, e dê a ele permissões para acessar e modificar o banco `portal_educacao`.
   - Execute o script `init/init.sql` para criar as tabelas e popular os dados iniciais. Você pode usar uma ferramenta como `psql` ou o pgAdmin para isso.
     ```bash
     psql -U admin -d portal_educacao -a -f init/init.sql
     ```

3. **Ajuste as credenciais no código:**
   - Abra o arquivo `app_gui.py`.
   - Se suas credenciais do banco de dados (usuário, senha, host, porta) forem diferentes do padrão (`admin`/`admin` em `localhost:5432`), atualize as constantes no topo do arquivo:
     ```python
     DB_HOST = "seu_host"
     DB_PORT = "sua_porta"
     DB_NAME = "portal_educacao"
     DB_USER = "seu_usuario"
     DB_PASS = "sua_senha"
     ```

4. **Crie e ative um ambiente virtual:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

5. **Instale as dependências:**
   ```bash
   pip install -r requirements.txt
   ```

6. **Execute a aplicação:**
   ```bash
   python3 app_gui.py
   ```

## Acesso ao pgAdmin

Se você usou a opção com Docker, pode acessar o pgAdmin para gerenciar o banco de dados:

* **URL:** http://localhost:5050
* **Email:** admin@admin.com
* **Senha:** admin

Ao fazer login pela primeira vez, você precisará registrar um novo servidor para se conectar ao banco de dados `portal_educacao`:
* **Host name/address:** `postgres` (este é o nome do serviço no `docker-compose.yaml`)
* **Port:** `5432`
* **Username:** `admin`
* **Password:** `admin`# Portal_Educacao
