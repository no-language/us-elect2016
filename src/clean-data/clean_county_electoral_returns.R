library(dplyr)
library(stringr)

electoral_returns <- read.csv('./data/electoral-returns/raw_county_electoral_returns.csv',
                              stringsAsFactors = FALSE, na.strings = "-")

electoral_returns <- electoral_returns %>%
  mutate(state = toupper(state),
         candidate = str_replace_all(candidate, "^\\s*", ""),
         candidate = str_replace_all(candidate, "\\s*$", ""),
         votes = votes %>% str_replace_all(",", "") %>% as.numeric,
         pct = pct %>% str_replace("%", "") %>% as.numeric)

electoral_returns$party[electoral_returns$party == "GOP"] <- "REP"
electoral_returns$party[electoral_returns$party == "GRE"] <- "GRN"
electoral_returns$party[electoral_returns$candidate == "Jill Stein"] <- "GRN"

write.csv(electoral_returns,
          "./data/electoral-returns/clean_county_electoral_returns.csv",
          row.names = FALSE)
