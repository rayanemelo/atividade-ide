# 🛡️ Identidade Eletrônica com Keycloak, Terraform e Docker

Este projeto demonstra a criação de um ambiente de **Identidade Eletrônica** utilizando **Keycloak**, **PostgreSQL**, **Terraform** e um **Service Provider OIDC**.  
A solução é totalmente automatizada via **Docker Compose** e garante **persistência de dados** usando volumes.

---

## Estrutura do Projeto

- **`docker-compose.yml`**  
  Define os serviços:
  - `postgres`: banco de dados usado pelo Keycloak, persistente via volume `postgres_data`.
  - `keycloak`: servidor de identidade, configurado em modo `start-dev`.
  - `terraform`: aplica automaticamente as configurações no Keycloak quando o serviço está saudável.
  - `auth-oidc`: simula um **Service Provider (SP)** que consome tokens do realm configurado.

- **`main.tf`**  
  Script do **Terraform** que cria e configura recursos no Keycloak:
  - Realm **IDP** (provedor de identidade principal).
  - Client **SP** (Service Provider confidencial).
  - Configuração de **TOTP** como ação obrigatória (MFA).
  - Usuário `ray` com senha temporária.
  - Integração com provedores externos (**Google** e **GitHub**).

---

## Como Rodar

### 1. Configurar variáveis de ambiente
Após clonar o projeto, crie um arquivo `.env` na raiz com:

```env
KC_ADMIN_PASSWORD=admin
KC_SECRET_KEY=senha-secreta

GOOGLE_CLIENT_ID=seu-client-id
GOOGLE_CLIENT_SECRET=sua-secret

GITHUB_CLIENT_ID=seu-client-id
GITHUB_CLIENT_SECRET=sua-secret
```

### 2. Subir os serviços
```
docker compose up -d
```

### 3. Acessar o Keycloak
- URL: http://localhost:8080
- Admin Console: usuário admin / senha definida no .env

 