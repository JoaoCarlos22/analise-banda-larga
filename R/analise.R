# Carregando pacotes essenciais
library(tidyverse)
library(arrow)
library(scales)
library(skimr)

# Abrindo o dataset Parquet sem carregar tudo na RAM
dados <- open_dataset("data/dados.parquet")

# --- EXPLORAÇÃO INICIAL ---

# 1. Amostra pequena para inspeção visual
amostra <- dados |>  head(100) |>  collect()
View(amostra)

# 2. Resumo de variáveis categóricas 
tecnologias_unicas <- dados |>  select(tecnologia) |>  distinct()  |>  collect()
skim(tecnologias_unicas)

transmissao_unicas <- dados |> select(transmissao) |> distinct() |> collect()
skim(transmissao_unicas)

# 3. Frequência por ano (tabela de frequência)
contagem_ano <- dados |>  count(ano, sort = TRUE)  |>  collect()
print(contagem_ano)

# --- ANÁLISES AGREGADAS E GRÁFICOS ---

# 4. Total de acessos por ano
acessos_ano <- dados |> 
  group_by(ano) |> 
  summarise(total_acessos = sum(acessos, na.rm = TRUE))  |> 
  collect()

ggplot(acessos_ano, aes(x = ano, y = total_acessos)) +
  geom_line(color = "blue", linewidth = 1) +
  geom_point(color = "red", size = 2) +
  labs(title = "Total de acessos por ano", x = "Ano", y = "Acessos") +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  theme_minimal()

# 5. Total de acessos por tecnologia (top 10 para visualização)
acessos_tecnologia <- dados |> 
  group_by(tecnologia) |> 
  summarise(total_acessos = sum(acessos, na.rm = TRUE))  |> 
  arrange(desc(total_acessos)) |> 
  collect()

ggplot(acessos_tecnologia |>  slice_max(total_acessos, n = 10),
       aes(x = reorder(tecnologia, -total_acessos), y = total_acessos)) +
  geom_bar(stat = "identity") +
  labs(title = "Top 10 tecnologias por acessos", x = "Tecnologia", y = "Total de acessos") +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 6. Total de acessos por estado (top 10 para visualização)
acessos_estado <- dados |> 
  group_by(sigla_uf_nome) |> 
  summarise(total_acessos = sum(acessos, na.rm = TRUE))  |> 
  arrange(desc(total_acessos))  |> 
  collect()

ggplot(acessos_estado |>  slice_max(total_acessos, n = 10),
       aes(x = reorder(sigla_uf_nome, -total_acessos), y = total_acessos)) +
  geom_bar(stat = "identity") +
  labs(title = "Top 10 estados por acessos", x = "Estado", y = "Total de acessos") +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 7. Evolução dos acessos das 5 principais tecnologias
top_tecnologias <- acessos_tecnologia  |> 
  slice_max(total_acessos, n = 5) |> 
  pull(tecnologia)

acessos_ano_tecnologia <- dados |> 
  filter(tecnologia %in% top_tecnologias, !is.na(acessos))  |> 
  group_by(ano, tecnologia)  |> 
  summarise(total_acessos = sum(acessos, na.rm = TRUE), .groups = "drop")  |> 
  collect()

ggplot(acessos_ano_tecnologia,
       aes(x = ano, y = total_acessos, color = tecnologia)) +
  geom_line(linewidth = 1) +
  labs(title = "Evolução dos acessos das 5 principais tecnologias", x = "Ano", y = "Total de acessos") +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  theme_minimal()

# 8. Evolução dos acessos por porte de empresa
acessos_porte <- dados  |> 
  filter(!is.na(acessos), !is.na(porte_empresa))  |> 
  group_by(ano, porte_empresa) |> 
  summarise(total_acessos = sum(acessos, na.rm = TRUE), .groups = "drop") |> 
  collect()

ggplot(acessos_porte, aes(x = ano, y = total_acessos, color = porte_empresa)) +
  geom_line(linewidth = 1) +
  labs(title = "Evolução dos acessos por porte de empresa", x = "Ano", y = "Total de acessos") +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  theme_minimal()

# 9. Histograma dos acessos (até 500) - amostra limitada
ggplot(dados |>  filter(acessos <= 500, !is.na(acessos))  |>  head(10000)  |>  collect(),
       aes(x = acessos)) +
  geom_histogram(bins = 100, fill = "steelblue", color = "white") +
  labs(title = "Distribuição dos acessos (até 500)", x = "Acessos", y = "Frequência") +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  theme_minimal()

# 10. Total de acessos por faixa de velocidade (top 10)
acessos_velocidade <- dados |> 
  filter(!is.na(acessos), !is.na(velocidade))  |> 
  group_by(velocidade) |> 
  summarise(total_acessos = sum(acessos, na.rm = TRUE))  |> 
  arrange(desc(total_acessos)) |> 
  collect()

ggplot(acessos_velocidade |>  slice_max(total_acessos, n = 10),
       aes(x = reorder(velocidade, -total_acessos), y = total_acessos)) +
  geom_bar(stat = "identity") +
  labs(title = "Top 10 faixas de velocidade por acessos", x = "Velocidade", y = "Total de acessos") +
  scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# 11. Histograma de acessos por tecnologia (top 5)
acessos_tecnologia_barras <- acessos_tecnologia  |> 
  slice_max(total_acessos, n = 5) |> 
  mutate(perc = total_acessos / sum(total_acessos) * 100,
         label = paste0(tecnologia, " (", round(perc, 1), "%)"))

ggplot(acessos_tecnologia_barras, aes(x = reorder(tecnologia, perc), y = perc, fill = tecnologia)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(title = "Proporção dos acessos (top 5 tecnologias)", x = "Tecnologia", y = "Percentual (%)") +
  theme_minimal()

# 12. Gráfico de pizza por porte de empresa
acessos_porte_pizza <- acessos_porte |> 
  group_by(porte_empresa) |> 
  summarise(total_acessos = sum(total_acessos))  |> 
  mutate(perc = total_acessos / sum(total_acessos) * 100,
         label = paste0(porte_empresa, " (", round(perc, 1), "%)"))

ggplot(acessos_porte_pizza, aes(x = "", y = total_acessos, fill = porte_empresa)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y") +
  labs(title = "Participação dos acessos por porte de empresa") +
  theme_void() +
  theme(legend.position = "right")

