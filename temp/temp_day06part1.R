# Day 6 Part 1 - works ... needs cleaning and move to qmd !!!
# NOTE: Lots of help from Grok

# Part 1

library(tidyverse)
library(tidyr)

data_in <- read_table(here::here("data", "day06.txt"), col_names = FALSE)
df1 <- tibble(data_in)

df2 <- df1 |>
  mutate(col = paste0("X", row_number())) |>
  pivot_longer(-col, names_to = "row") |>
  pivot_wider(names_from = col, values_from = value) |>
  select(-row) |>
  rename(process = last_col()) |>
  mutate(across(starts_with("X"), as.integer))

df3 <- df2 |>
  mutate(row_result = case_when(
    process == "+" ~ rowSums(pick(starts_with("X")), na.rm = TRUE),
    process == "*" ~ reduce(pick(starts_with("X")), `*`, .init = 1),
    TRUE           ~ NA_real_
    )
  )

x <- df3 |> pull(row_result) |> sum(na.rm = TRUE)
print(x, digits = 20)


# Part 2

