library(tidyverse)
library(stringr)

bls_area <- read_csv('./data/economic/raw/bls_area_codes.csv', n_max = 52)
unempl <- read_csv('./data/economic/raw/state_unemployment.csv')
personal_income <- read_csv('./data/economic/raw/personal_income.csv', 
                            skip = 4, n_max = 159)
gdp_sic <- read_csv('./data/economic/raw/state_gdp_1963_1997.csv',
                    skip = 4, n_max = 53)
gdp_naics <- read_csv('./data/economic/raw/state_gdp_1997_2015.csv',
                      skip = 4, n_max = 53)

# UNEMPLOYMENT
bls_area <- select(bls_area, area_code, state = area_text)

unempl <- unempl %>%
  gather(period, unempl_rate, `Jan 1976`:`Dec 2016`) %>%
  rename(series = `Series ID`) %>%
  mutate(measure = str_extract(series, '^\\w{3}'),
         area_code = series %>% 
           str_extract('\\w{2}\\d+$') %>%
           str_trunc(15, ellipsis = "")) %>%
  mutate(measure = ifelse(measure == "LAS", "seasonally adjusted",
                          "not seasonally adjusted")) %>%
  left_join(bls_area, by = 'area_code') %>%
  select(state, period, measure, unempl_rate)

# Improve date formatting
unempl$period <- unempl$period %>% paste ("01") %>% as.Date("%b %Y %d")
unempl <- unempl %>%
  mutate(year = year(period),
         month = month(period),
         quarter = quarter(period, with_year = TRUE))

# PERSONAL INCOME
personal_income <- personal_income %>%
  gather(period, value, `1948Q1`:`2016Q2`) %>%
  select(state = GeoName, description = Description, period, value)

# Remove non-word/whitespace characters from state names.
personal_income$state <- str_replace_all(personal_income$state, 
                                         '[^\\w\\s]', '')

# Create variable names to match variable descriptions.
desc <- data.frame(
  description = unique(personal_income$description),
  variable = c("personal_income", "population", "personal_income_pc")
)

personal_income <- left_join(personal_income, desc, by = 'description')

# Create separate identifiers for years and quarters.
personal_income <- personal_income %>%
  mutate(year = as.numeric(str_replace(period, 'Q\\d', '')),
         quarter = str_replace(period, '^\\d+', '')) %>%
  select(state, period, year, quarter, variable, description, value)

# GDP
gdp_sic <- gdp_sic %>%
  gather(year, gdp, `1963`:`1997`) %>%
  select(state = Area, year, gdp) %>%
  mutate(year = as.numeric(year)) %>%
  filter(year < 1997)

gdp_naics <- gdp_naics %>%
  gather(year, gdp, `1997`:`2015`) %>%
  select(state = Area, year, gdp) %>%
  mutate(year = as.numeric(year))

gdp <- rbind(gdp_sic, gdp_naics)

# OUTPUT
write.csv(unempl, './data/economic/clean/unemployment.csv', 
          row.names = FALSE)
write.csv(personal_income, './data/economic/clean/personal_income.csv',
          row.names = FALSE)
write.csv(gdp, './data/economic/clean/gdp.csv', row.names = FALSE)
