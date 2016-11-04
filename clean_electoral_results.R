library(dplyr)
library(reshape2)
library(stringr)

scan_raw <- function(year, skip) {
  scan(paste0('./data/electoral-returns/raw/', year, '.txt'), 
       what = 'character', sep = '\n', skip = skip, nlines = 51)
}

parse_state_names <- function(states) {
  states %>%
    toupper() %>%
    str_replace('NTH\\b', 'NORTH') %>%
    str_replace('STH\\b', 'SOUTH') %>%
    str_replace('D.* OF COL.*', 'DISTRICT OF COLUMBIA')
}

clean_state <- function(raw_year) {
  # Extract the state name from each row in the raw data, and remove leading
  # and trailing whitespace.
  raw_year %>%
    str_match('^[\\w\\s{1}]+\\s+') %>%
    str_replace('\\s{2,}', '') %>% 
    str_replace('\\s$', '') %>%
    as.character() %>%
    parse_state_names
}

clean_vote_data <- function(raw_year) {
  # Extract the vote data from each row in the raw data.
  # Remove excess whitespace, remove commas within numbers, replace '-'s
  # signifying 0 electoral votes with the number 0, and remove leading/trailing
  # whitespace.
  out <- raw_year %>%
    str_match('\\s{2,}\\d.*$') %>%
    str_replace_all('\\s{2,}', ' ') %>%
    str_replace_all(',', '') %>%
    str_replace_all('-', '0') %>%
    str_replace('^\\s+', '') %>%
    str_replace('\\s+$', '')
  
  # Detect number of columns needed.
  n <- length(str_split(out[1], '\\s')[[1]])
  
  # Split each row into columns as appropriate, convert each column to
  # a numeric vector.
  out <- out %>%
    str_split_fixed('\\s', n) %>%
    as.data.frame() %>%
    lapply(as.character) %>%
    lapply(as.numeric) %>%
    as.data.frame()
  
  # Drop the totals column if it exists (the last column if the number
  # of columns is not divisible by three).
  if (n %% 3 != 0) {
    out <- out[seq(1, length(out) - 1)]
    n <- n - 1
  }
  
  vars <- c("votes", "pct", "ecv")
  if (n == 6) {
    colnames(out) <- paste(rep(c("dem", "rep"), each = 3), vars, sep = "_")
  } else if (n == 9) {
    colnames(out) <- paste(rep(c("dem", "rep", "other"), each = 3), vars, sep = "_")
  }
  
  out
}

clean_year <- function(raw_year) {
  state <- clean_state(raw_year)
  vote_data <- clean_vote_data(raw_year)
  
  out <- cbind(state, vote_data)
  out %>%
    melt(id = 'state') %>%
    mutate(party = gsub('_.*$', '', variable),
           variable = gsub('^.*_', '', variable))
}

############
# CLEANING #
############
# The raw text files from 1972 to 1996 are formatted mostly identically.
raw <- lapply(seq(1972, 1996, 4), scan_raw, 14)
names(raw) <- seq(1972, 1996, 4)

# The file from 2000 requires special consideration.
raw[['2000']] <- scan_raw(2000, 40)

# 2008 and 2012 have similar formats, although they differ from all other years.
raw[['2008']] <- scan_raw(2008, 26)
raw[['2012']] <- scan_raw(2012, 25)

# 2004 is a disaster, it needs to be handled separately.
y2004 <- scan('./data/electoral-returns/raw/2004.txt', what = 'character', 
              sep = '\n', skip = 8)
# Entries are separated by ASCII dividers consisting of repeated '=' chars.
# State names are located on the line above the dividers. On the third line 
# after the dividers, electoral return data starts. Each state has three 
# entries, one for the dem and rep candidates, and one for other.
dividers <- grep('=+', y2004)
state <- y2004[dividers - 1] %>%
  parse_state_names()
vote_data <- y2004[unlist(lapply(dividers, function(i) seq(i + 3, i + 5)))] %>%
  str_replace('\\s+$', '') %>%
  str_replace_all(',', '') %>%
  str_replace_all('-', '0') %>%
  str_split('\\s{2,}') %>%
  lapply(function(i) i[seq(length(i) - 2, length(i))])

vote_data <- do.call(rbind.data.frame, vote_data) %>%
  lapply(as.character) %>%
  lapply(as.numeric) %>%
  as.data.frame()

colnames(vote_data) <- c("votes", "pct", "ecv")
vote_data$party <- c("dem", "rep", "other")
y2004 <- cbind(state = rep(state, each = 3), vote_data) %>%
  melt(id = c("state", "party"))

clean <- lapply(raw, clean_year)
clean[['2004']] <- y2004

for (yr in seq(1972, 2012, 4)) {
  clean[[as.character(yr)]]$year <- yr
}

electoral_returns <- bind_rows(clean)
electoral_returns <- dcast(electoral_returns, year + state + party ~ variable)

##########
# OUTPUT #
##########
write.csv(electoral_returns, 
          file = './data/electoral-returns/clean/electoral_returns.csv',
          row.names = FALSE)
