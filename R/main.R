# Instale os pacotes necessários (apenas se ainda não instalou)
# install.packages("basedosdados")
# install.packages("tidyverse")
# install.packages("bigrquery")
# install.packages("arrow")

library(basedosdados)
library(tidyverse)
library(bigrquery)
library(arrow)

# --- ETAPA 1: Autenticação Google ---
bq_auth()  # Abre janela para login Google

# --- ETAPA 2: Definir o billing_id de forma segura ---
billing_id <- Sys.getenv("GCP_BILLING_ID")  # Defina no seu .Renviron

# Checa se o billing_id foi carregado corretamente
if (billing_id == "") stop("GCP_BILLING_ID não encontrado no .Renviron!")

set_billing_id(billing_id)

# --- ETAPA 3: Definir a consulta SQL ---
query <- "
SELECT
    dados.ano as ano,
    dados.porte_empresa as porte_empresa,
    dados.transmissao as transmissao,
    dados.acessos as acessos,
    dados.velocidade as velocidade,
    dados.produto as produto,
    dados.tecnologia as tecnologia,
    dados.sigla_uf AS sigla_uf,
    diretorio_sigla_uf.nome AS sigla_uf_nome
FROM `basedosdados.br_anatel_banda_larga_fixa.microdados` AS dados
LEFT JOIN (
    SELECT DISTINCT sigla, nome
    FROM `basedosdados.br_bd_diretorios_brasil.uf`
) AS diretorio_sigla_uf
ON dados.sigla_uf = diretorio_sigla_uf.sigla
WHERE dados.ano BETWEEN 2007 AND 2024
"

# --- ETAPA 4: Executar a consulta SQL ---
dataframe <- read_sql(query, billing_project_id = get_billing_id())

# --- ETAPA 5: Salvar os dados localmente em Parquet ---
dir.create("data", showWarnings = FALSE)  # Cria pasta se não existir
write_parquet(dataframe, "data/dados.parquet")