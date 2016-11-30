library(dplyr)

unzip_year <- function(year, industry) {
  root <- "./data/county-employment/raw/"
  filename <- paste0(year, "_qtrly_by_industry")
  inner_root <- paste0(year, ".q1-q4.by_industry/")

  unz(paste0(root, filename, ".zip"),
      paste0(inner_root, year, ".q1-q4 ", industry, ".csv"))
}
  
total <- "10 Total, all industries"
years <- 1990:2015

cnty_emp <- lapply(years, function(year) read.csv(unzip_year(year, total)))
cnty_emp <- bind_rows(cnty_emp)

write.csv(cnty_emp, 
          './data/county-employment/raw/county_employment_all_years.csv',
          row.names = FALSE)
