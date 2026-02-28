# Sistema de Gerenciamento de Tarefas Observável

Este projeto consiste em uma aplicação de gerenciamento de tarefas (CRUD) desenvolvida em **Ruby** com **Sinatra**, integrada ao **Prometheus** para monitoramento de métricas, tudo orquestrizado via **Docker Compose**.

A aplicação expõe métricas automáticas de requisições HTTP, permitindo o monitoramento em tempo real do desempenho e saúde do serviço.

## Tecnologias Utilizadas

*   **Linguagem:** Ruby
*   **Framework Web:** Sinatra
*   **Banco de Dados:** SQLite (via Sequel)
*   **Monitoramento:** Prometheus
*   **Orquestração:** Docker Compose
*   **Frontend:** HTML, CSS e JavaScript (Simples)

## Como Rodar

Para rodar este projeto, você precisa ter instalado em sua máquina:

*   [Docker](https://www.docker.com/)
*   [Docker Compose](https://docs.docker.com/compose/)

1.  Clone o repositório:

```bash
git clone https://gitlab.com/matheussdc/monitoramento
```

2. Crie e inicialize os containers do App e do Prometheus com Docker Compose:

```bash
docker compose up --build
```

3.  Após a inicialização, os serviços ativos estarão disponíveis nas seguintes portas:

| Serviço | URL | Descrição |
| :--- | :--- | :--- |
| **Aplicação** | `http://localhost:4567` | Interface web e API |
| **Prometheus** | `http://localhost:9090` | Coleta e armazenamento de métricas |

## Funcionalidades

### App
*   **Listagem de Tarefas:** Visualização de todas as tarefas cadastradas, ordenadas por prioridade.
*   **Cadastro de Tarefas:** Criação de novas tarefas com validação de dados.
*   **Edição e Remoção:** Atualização de detalhes ou exclusão de tarefas existentes.
*   **Persistência:** Os dados são salvos em um arquivo SQLite montado via volume, garantindo que os dados não se percam ao reiniciar o container.
*   **Validações:**
    *   Campos obrigatórios (`task`, `responsible`, `priority`).
    *   Prioridade deve ser numérica (Integer).
    *   Limite de caracteres para Tarefa (60) e Responsável (30).

### Monitoramento
*   **Coleta Automática:** Middleware do Prometheus captura métricas de requisições HTTP (contagem, latência, status codes).
*   **Scrape Config:** O Prometheus está configurado para coletar dados da própria aplicação (`application-job`) e do próprio servidor Prometheus (`prometheus-job`) a cada 5 segundos.

## API Endpoints

A API segue o padrão REST e retorna respostas em JSON.

| Método | Endpoint | Descrição |
| :--- | :--- | :--- |
| `GET` | `/` | Serve a interface frontend (`public/index.html`) |
| `GET` | `/tarefas` | Lista todas as tarefas (ordenadas por prioridade) |
| `POST` | `/tarefas` | Cria uma nova tarefa |
| `GET` | `/tarefas/:id` | Busca uma tarefa específica pelo ID |
| `PUT` | `/tarefas/:id` | Atualiza uma tarefa específica |
| `DELETE` | `/tarefas/:id` | Remove uma tarefa específica |
| `GET` | `/metrics` | Expõe as métricas para o Prometheus (automático) |

**Exemplo de Payload (POST/PUT):**
```json
{
  "task": "Consertar barulho da porta",
  "responsible": "Ana",
  "priority": 5
}
```

## Prospecções Futuras

Para evoluir este projeto, as seguintes melhorias são sugeridas:

1.  **Integração com Grafana:** Utilizar Grafana para criar dashboards visuais das métricas coletadas pelo Prometheus.
2.  **Autenticação e Autorização:** Implementar sistema de login (JWT ou Session) para proteger os endpoints.
3.  **Alertas:** Configurar o **Alertmanager** para notificar canais (WhatsApp, Email) em caso de alta latência ou queda do serviço.
4.  **Testes Automatizados:** Implementar suite de testes (RSpec) para garantir a qualidade do código.
5.  **Melhoria no Frontend:** Substituir o HTML/JS simples por um framework moderno (React, Vue ou Angular).
6.  **CI/CD:** Criar pipelines de integração e deploy contínuo para extrair o máximo do GitLab.
7.  **Logs Estruturados:** Integrar um stack de logging para correlacionar métricas com logs de erro.