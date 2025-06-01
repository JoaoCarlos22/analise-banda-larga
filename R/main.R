# instalar os pacotes: basedosdados, tidyverse, bigrquery

library(basedosdados)
library(tidyverse)
library(bigrquery)

# Etapa 1: Autenticar com sua conta Google
bq_auth()

# Etapa 2: Definir o id do seu projeto no Google Cloud
basedosdados::set_billing_id("projetofinalgr03-461420")

# Etapa 3: Definir a consulta SQL
query <- "
SELECT
    dados.ano as ano,
    dados.porte_empresa as porte_empresa,
    dados.transmissao as transmissao,
    dados.acessos as acessos,
    dados.velocidade as velocidade,
    dados.produto as produto,
    dados.tecnologia as tecnologia
FROM `basedosdados.br_anatel_banda_larga_fixa.microdados` AS dados
"

# Etapa 4: Executar a consulta e salvar os dados
dataframe <- basedosdados::read_sql(query, billing_project_id = get_billing_id())

# Etapa 5: Armazenar os dados localmente
write_csv(dataframe, "data/dataframe.csv")
