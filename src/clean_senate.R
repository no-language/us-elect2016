library(dplyr)
library(purrr)
library(readr)
library(lubridate)

cols <- c('name', 'state', 'party', 'start_date', 'end_date', 'birth_year',
          'death_year')
senate <- read_fwf('./data/senate/senate_raw.txt', 
                   fwf_widths(widths = c(33, 4, 8, 12, 12, 6, 4),
                              col_names = cols),
                   skip = 9)

# Remove blank rows.
senate <- senate[!apply(is.na(senate), 1, all), ]

# Parse dates, do some housekeeping.
senate <- senate %>%
  mutate(start_date = as.Date(start_date, "%Y.%m.%d"),
         end_date = as.Date(end_date, "%Y.%m.%d")) %>%
  select(everything(), -birth_year, -death_year) %>%
  filter(year(end_date) >= 1972)

# Include an entry for each quarter a senator was in office.
senate_full <- senate %>%
  split(senate$name) %>%
  map_df(function(senator) {
    data.frame(name = senator$name,
               state = senator$state,
               party = senator$party,
               period = seq.Date(senator$start_date, senator$end_date, 'quarter'))
  }) %>%
  mutate(year = year(period),
         period = quarter(period, with_year = TRUE))

# OUTPUT
write.csv(senate_full, './data/senate/senate_clean.txt', row.names = FALSE)