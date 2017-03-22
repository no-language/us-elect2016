library(dplyr)
library(readr)

cnty_emp <- read_csv('./data/county-employment/raw/county_employment_all_years.csv')

cnty_emp <- cnty_emp %>% 
  mutate(oty_total_qtrly_wages_chg = as.numeric(oty_total_qtrly_wages_chg),
         avg_qtrly_emplvl = (month1_emplvl + month2_emplvl + month3_emplvl) / 3) %>%
  filter(agglvl_code %in% c(50, 70))

cnty_emp <- select(cnty_emp, area_fips, year, qtr, area_title, 
                   total_qtrly_wages, avg_wkly_wage, avg_qtrly_emplvl)

write.csv(cnty_emp, './data/county-employment/clean/clean_county_employment.csv')