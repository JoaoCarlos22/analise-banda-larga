# Instalar os pacotes necessários (se ainda não tiver)
install.packages("googlesheets4")
install.packages("janitor")
install.packages("tidyverse")

# Carregar os pacotes
library(googlesheets4)
library(janitor)
library(tidyverse)

# Autenticar com sua conta Google (irá abrir o navegador)
gs4_deauth()

# URL da planilha
url <- "https://docs.google.com/spreadsheets/d/1bTKacxu-y5k50ewgyxH5hNsCHfBihbLrzTZxN72jZE4"

# Ler os dados da aba específica (gid 1783520704 corresponde à aba pelo índice, mas vamos buscar o nome da aba)
sheet_names(url)  # Rode isso primeiro para ver o nome da(s) aba(s)

# Como o nome da aba se chame "respostas", use-a no código, a seguir
dados <- read_sheet(url, sheet = "respostas") |> 
  clean_names()

# Visualizar os dados
glimpse(dados)


# ---------------------------------------------------------
# Análise Exploratória de Dados com R Base
# ---------------------------------------------------------
# Este script realiza uma análise exploratória utilizando
# apenas recursos do R base, ideal para alunos iniciantes.
# ---------------------------------------------------------

# Autenticar e carregar pacotes necessários
# (Apenas se usar o googlesheets4 — ignorado aqui para fins de R Base)

# --------------------------------------------
# Etapa 1: Carregar os dados do Google Sheets
# --------------------------------------------
# Você deve já ter exportado os dados para CSV ou usar googlesheets4

# Para fins de exemplo, considere os dados já carregados como `dados`
# Por exemplo: dados <- read.csv("dados.csv")

# --------------------------------------------
# Etapa 2: Visualização da estrutura dos dados
# --------------------------------------------
str(dados)             # Exibe a estrutura das variáveis (tipos e exemplos)
# glimpse do pacote tiduverse, semelhrante ao str
summary(dados)         # Mostra um resumo estatístico geral

# --------------------------------------------
# Etapa 3: Variáveis Qualitativas
# --------------------------------------------
# Exemplo com variável gênero
table(dados$genero)                         # Frequência absoluta
prop.table(table(dados$genero)) * 100       # Frequência relativa (%)
barplot(table(dados$genero), 
        col = "lightblue", 
        main = "Distribuição de Gênero")

pie(table(dados$genero), 
        col = "lightblue", 
        main = "Distribuição de Gênero")
# --------------------------------------------
# Etapa 4: Variáveis Quantitativas
# --------------------------------------------
# Exemplo com a variável idade
hist(dados$idade,
     col = "lightgreen",
     main = "Histograma de Idade",
     xlab = "Idade")

boxplot(dados$idade,
        col = "orange",
        main = "Boxplot da Idade",
        horizontal = TRUE)

# Resumo numérico
mean(dados$idade, na.rm = TRUE)       # Média
sd(dados$idade, na.rm = TRUE)         # Desvio padrão
quantile(dados$idade, na.rm = TRUE)   # Quartis

# --------------------------------------------
# Etapa 5: Mudança de opinião (colunas 7 e 8)
# --------------------------------------------
# Captura as respostas de antes e depois
origem <- dados[[7]]
destino <- dados[[8]]

# Tabela cruzada
tabela_mudanca <- table(origem, destino)
tabela_mudanca

# Verifica se houve mudança
mudou <- origem != destino
table(mudou)  # TRUE = mudou, FALSE = manteve opinião

# Gráfico simples para visualização da mudança
cores <- ifelse(mudou, "red", "gray")
plot(origem, destino,
     col = cores,
     main = "Mudança de Opinião",
     xlab = "Antes",
     ylab = "Depois")

# --------------------------------------------
# Etapa 6: Cruzamento entre variáveis qualitativas
# --------------------------------------------
# Exemplo: Gênero x Curso
tabela_cruzada <- table(dados$genero, dados$curso)
tabela_cruzada

# Frequência relativa por linha
prop.table(tabela_cruzada, 1) * 100

# --------------------------------------------
# Etapa 7: Frequência por classe de variável contínua
# --------------------------------------------
# Exemplo com idade
breaks <- pretty(range(dados$idade, na.rm = TRUE), n = 5)
classe_idade <- cut(dados$idade, breaks = breaks, right = FALSE)

# Frequência por classe
table(classe_idade)
barplot(table(classe_idade),
        col = "lightblue",
        main = "Frequência por Faixas de Idade")

# Fim do script

