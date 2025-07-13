# 🦶 Sistema de Podologia - Guia de Instalação

## 📋 Pré-requisitos

### Backend (Python/FastAPI)
- Python 3.8+
- pip
- MongoDB (local ou remoto)

### Frontend (React)
- Node.js 16+
- Yarn

## 🚀 Instalação

### 1. Backend
```bash
cd backend/
pip install -r requirements.txt
```

### 2. Frontend
```bash
cd frontend/
yarn install
```

## ⚙️ Configuração

### 1. Backend (.env)
```env
MONGO_URL="mongodb://localhost:27017"
DB_NAME="podologia_database"
```

### 2. Frontend (.env)
```env
REACT_APP_BACKEND_URL=http://localhost:8001
```

## 🏃‍♂️ Execução

### 1. Iniciar Backend
```bash
cd backend/
uvicorn server:app --host 0.0.0.0 --port 8001 --reload
```

### 2. Iniciar Frontend
```bash
cd frontend/
yarn start
```

## 🌐 Acesso
- Frontend: http://localhost:3000
- Backend API: http://localhost:8001
- Documentação API: http://localhost:8001/docs

## ✨ Funcionalidades

### ✅ Implementadas
1. **📋 Cadastro de Pacientes** - Formulário completo com todos os campos obrigatórios
2. **🩺 Ficha de Anamnese** - Baseada nas fichas médicas fornecidas
3. **📝 Observações de Procedimentos** - Campo para anotações detalhadas
4. **✍️ Assinatura Digital** - Captura por touch/mouse no termo de responsabilidade
5. **🔍 Busca de Pacientes** - Por nome, CPF ou telefone
6. **📅 Sistema de Agendamento** - Calendário visual completo
7. **🔔 Notificações WhatsApp** - Lembretes automáticos:
   - 1 dia antes da consulta
   - 1h30 antes da consulta
   - Mensagens personalizadas em português
   - Links diretos para WhatsApp

### 🎨 Interface
- Design responsivo para tablets e celulares
- Modo escuro automático
- Navegação intuitiva
- Interface profissional

### 💾 Banco de Dados
- MongoDB para armazenamento
- Relacionamentos corretos entre entidades
- APIs RESTful completas

## 🔧 Estrutura do Projeto

```
podologia-system/
├── backend/
│   ├── server.py              # API FastAPI principal
│   ├── requirements.txt       # Dependências Python
│   └── .env                   # Configurações
├── frontend/
│   ├── src/
│   │   ├── App.js            # Componente React principal
│   │   ├── App.css           # Estilos
│   │   └── index.js          # Ponto de entrada
│   ├── package.json          # Dependências Node.js
│   └── .env                  # Configurações
└── README.md
```

## 📱 Como Usar

### 1. Cadastrar Paciente
- Acesse "Cadastrar Paciente"
- Preencha todos os campos obrigatórios
- Sistema redireciona automaticamente para ficha de anamnese

### 2. Preencher Anamnese
- **Dados Gerais**: Queixa principal, medicamentos, alergias, etc.
- **Dados Clínicos**: Condições médicas, diabetes, pressão, etc.
- **Observações**: Procedimentos realizados e recomendações
- **Termo de Responsabilidade**: Assinatura digital obrigatória

### 3. Agendar Consulta
- Acesse "Agendamentos"
- Clique em "+ Novo Agendamento"
- Selecione paciente, data e horário
- Sistema cria automaticamente notificações WhatsApp

### 4. Gerenciar Notificações
- Acesse "Notificações"
- Aba "Pendentes": Notificações prontas para envio
- Aba "Próximas": Notificações programadas
- Clique em "Enviar WhatsApp" para abrir com mensagem pré-formatada

## 🆘 Suporte

### Problemas Comuns

**MongoDB não conecta:**
- Verifique se MongoDB está rodando: `mongod`
- Confirme a URL no arquivo `.env`

**Frontend não carrega:**
- Execute `yarn install` no diretório frontend
- Verifique se o backend está rodando

**Notificações não aparecem:**
- Crie pelo menos um agendamento
- Aguarde alguns segundos para processamento

## 📞 Mensagens WhatsApp

### Exemplo - 1 dia antes:
```
🦶 *Lembrete de Consulta - Podologia*

Olá [Nome do Paciente]! 👋

Este é um lembrete de que você tem uma consulta agendada para *amanhã* (DD/MM/AAAA) às *HH:MM*.

Por favor, confirme sua presença respondendo:
✅ *CONFIRMO* - se você comparecerá
❌ *CANCELAR* - se precisar cancelar

📍 Não se esqueça de trazer documentos e chegar com 10 minutos de antecedência.

Obrigado!
```

### Exemplo - 1h30 antes:
```
🦶 *Lembrete de Consulta - Podologia*

Olá [Nome do Paciente]! 👋

Sua consulta está próxima! 

📅 Data: *DD/MM/AAAA*
🕐 Horário: *HH:MM*

Você tem aproximadamente *1h30* para se preparar.

Por favor, confirme que está a caminho respondendo:
✅ *A CAMINHO* - se você está se dirigindo ao local
❌ *ATRASO* - se você vai se atrasar
❌ *CANCELAR* - se não puder comparecer

📍 Lembre-se de chegar com 10 minutos de antecedência.

Até logo!
```

## 🔒 Segurança e Privacidade
- Dados armazenados localmente
- Assinaturas em formato base64
- Relacionamentos adequados entre entidades
- Validação de formulários

## 🚀 Sistema Pronto para Produção
Este sistema foi desenvolvido especificamente para consultórios de podologia e está pronto para uso profissional, incluindo todas as funcionalidades solicitadas e testadas.