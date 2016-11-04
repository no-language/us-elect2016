library(readr)

# widths = c(33, 4, 8, 12, 12, 6, 4)
cols <- c('name', 'state', 'party', 'start_date', 'end_date', 'birth_year',
          'death_year')
senate <- read_fwf('./data/senate/senate_raw.txt', 
                   fwf_widths(widths = c(33, 4, 8, 12, 12, 6, 4),
                              col_names = cols),
                   skip = 9)

# Remove blank rows.
senate <- senate[!apply(is.na(senate), 1, all), ]