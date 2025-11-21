# 📊 Projeto SIASUS — Análise Estratégica em Saúde Pública

## Secretaria Municipal de Saúde de Santa Rosa / RS

Este projeto tem como objetivo transformar grandes volumes de dados do **Sistema de Informações Ambulatoriais do SUS (SIASUS)** em informações estratégicas que auxiliem a gestão da Secretaria Municipal de Saúde de Santa Rosa na tomada de decisão, planejamento, monitoramento e avaliação dos serviços prestados à população local e regional.

Os dados analisados incluem registros de procedimentos ambulatoriais, valores financeiros, diagnósticos, estabelecimentos de saúde, profissionais envolvidos e perfil dos pacientes, possibilitando uma visão ampla do sistema de saúde municipal.

---

## 🎯 Objetivo Geral

Converter dados brutos do SIASUS em conhecimento estratégico através de:

1. **Análise Exploratória de Dados (EDA)**
2. **Limpeza e Preparação dos Dados**
3. **Análises Estratégicas Top-Down para Gestão em Saúde**

---

## 🗂 Estrutura do Projeto

```
📁 projeto-siasus
│
├── 📄 consultas.sql
├── 📄 glossario.md
├── 📓 notebook.ipynb
└── 📄 README.md
```

### 📌 Arquivos principais

- 🔗 **consultas.sql**
  Contém todas as consultas SQL utilizadas para extração, transformação e análise dos dados no banco SIASUS.

  > Acesse diretamente: **consultas.sql**

- 📘 **glossario.md**
  Documento explicativo com a definição de siglas, colunas e termos técnicos utilizados no SIASUS.

  > Acesse diretamente: **glossario.md**

- 📓 **notebook.ipynb**
  Notebook principal onde são realizadas as análises em Python com Pandas, visualizações e estudos exploratórios.

  > Acesse diretamente: **notebook.ipynb**

---

## 🧠 Contexto do Trabalho

A Secretaria Municipal de Saúde de Santa Rosa necessita monitorar a produção assistencial para garantir eficiência, qualidade e melhor alocação de recursos. No entanto, os dados do SIASUS apresentam desafios como:

- Grande volume de registros (milhões)
- Inconsistências e valores inválidos
- Dados ausentes
- Registros duplicados

Portanto, torna-se essencial realizar um processo estruturado de análise e tratamento antes de gerar insights confiáveis.

---

## 🔍 Etapas do Projeto

### 1. Análise Exploratória de Dados (EDA)

- Verificação do número de registros e colunas
- Identificação de tipos de dados
- Estatísticas descritivas
- Análise de valores ausentes e inválidos

Exemplos de verificações:

- Sexo diferente de M/F
- Idade fora da faixa válida
- CID inexistente

---

### 2. Limpeza e Preparação dos Dados

Estratégias aplicadas:

- Substituição de valores nulos por "Não informado"
- Remoção de duplicidades
- Padronização de campos categóricos
- Tratamento de inconsistências

---

### 3. Análises Estratégicas

#### 📈 3.1 Volume e Perfil dos Procedimentos

- Quantidade de procedimentos por mês, trimestre e ano
- Distribuição por especialidade
- Evolução temporal da demanda

#### 🏥 3.2 Produção por Estabelecimento

- Ranking de produção
- Procedimentos aprovados x produzidos
- Taxa de eficiência produtiva

#### 👥 3.3 Perfil Demográfico e Epidemiológico

- Distribuição por sexo e faixa etária
- Principais diagnósticos (CID)
- Doenças crônicas mais recorrentes

#### 🌎 3.4 Fluxos Regionais

- Origem dos pacientes
- Municípios atendidos por Santa Rosa
- Dependência de serviços regionais

#### 💰 3.5 Recursos Financeiros

- Valor total aprovado x produzido
- Diferença financeira
- Gasto médio por procedimento

#### 🚨 3.6 Áreas Críticas

- Oncologia
- Saúde Mental
- Atenção Básica

#### 📊 3.7 Comparações Regionais

- Santa Rosa x Ijuí x Santo Ângelo
- Tendências de crescimento
- Envelhecimento populacional e impacto na demanda

---

## 🛠 Tecnologias Utilizadas

- Python
- Pandas
- MySQL
- SQL
- Jupyter Notebook

---

## 🔄 Formas de Acesso aos Dados

1. Conexão direta com MySQL via Pandas (`pd.read_sql()`)
2. Exportação em CSV e leitura com `pd.read_csv()`

---

## ✅ Resultados Esperados

- Melhoria na qualidade dos dados
- Insights estratégicos para tomada de decisão
- Identificação de gargalos no sistema de saúde
- Otimização de recursos públicos

---

## 👨‍⚕️ Público-Alvo

- Gestores da Secretaria de Saúde
- Analistas de dados
- Planejadores de políticas públicas

---

## 📌 Observações

Este projeto pode ser expandido futuramente para incluir dashboards interativos e integração com ferramentas de BI.

---

## ✍️ Autor

Projeto acadêmico desenvolvido para análise de dados em saúde pública utilizando SIASUS como base principal.

---
