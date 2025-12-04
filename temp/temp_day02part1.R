# Day 2 Part 1 and 2 - works ... needs cleaning and move to qmd !!!
# NOTE: Lots of help from Grok

data_in <- read_lines(here::here("data", "day02.txt"))
tibble(data_in)

# Starting from your tibble with start/end columns
df1 <- tibble(range = data_in) |>
  separate_longer_delim(range, delim = ",") |>
  mutate(range = str_trim(range)) |>
  separate(range, into = c("start", "end"), sep = "-", convert = TRUE)

df2 <- df1 |>
  rowwise() |>                          # work row-by-row
  mutate(x_num = list(start:end)) |>   # create a list-column of sequences
  unnest(x_num) |>                     # turn list-column into rows
  select(x_num)                         # keep only the number column (optional)

df3 <- df2 |>
  mutate(across(c(x_num), as.character)) |>
  rename(x_char = x_num) |>
  mutate(abc = str_length(x_char),
         def = abc %% 2) |>
  filter(def == 0) |>
  mutate(x_char_half_length = abc / 2) |>
  mutate(x_char1 = str_sub(x_char, 1, x_char_half_length),
         x_char2 = str_sub(x_char, x_char_half_length + 1)) |>
  filter(x_char1 == x_char2)

result <- df3 %>%
  mutate(across(c(x_char), as.numeric)) |>
  pull(x_char) %>% sum(na.rm = TRUE)

result

# Part 2

has_repeating_block <- function(strings) {
  map_lgl(strings, function(s) {
    n <- nchar(s)
    if (n <= 1) return(FALSE)

    # Try block sizes from 1 to n/2
    for (i in 1:(n %/% 2)) {
      if (n %% i == 0) {  # only if i evenly divides n
        block <- substr(s, 1, i)
        if (str_dup(block, n / i) == s) {
          return(TRUE)
        }
      }
    }
    FALSE
  })
}

df4 <- df2 |>
  mutate(across(c(x_num), as.character))

# Use it
df5 <- df4 %>%
  mutate(is_repeating = has_repeating_block(x_num)) |>
  filter(is_repeating == TRUE)

result <- df5 %>%
  mutate(across(c(x_num), as.numeric)) |>
  pull(x_num) %>% sum(na.rm = TRUE)

result
