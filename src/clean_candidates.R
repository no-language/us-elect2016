library(dplyr)
library(stringr)

######################################
# CANDIDATE BIOGRAPHICAL INFORMATION #
######################################
# Extract the names, parties, and home states of each presidential candidate.
files <- paste0('./data/electoral-returns/raw/', seq(1972, 2012, 4), '.txt')
raw <- lapply(files, scan, what = 'character', sep = '\n')

parse_raw_candidates <- function(raw_year) {
  # Prior to 2000, candidate names begin 2 lines below "POPULAR VOTE AND  
  # ELECTORAL COLLEGE VOTE BY STATE" and continue for three lines.
  start <- grep("POPULAR VOTE AND ELECTORAL COLLEGE", raw_year) + 2
  raw_candidates <- raw_year[seq(start, start + 2)]
  
  raw_candidates <- raw_candidates %>%
    str_replace('^\\s+', '') %>%
    str_split('\\s{2,}')
  
  # The first entry contains first names, the second surnames, the third
  # an entry formatted '(PARTY, STATE ABBREVIATION)'.
  party <- raw_candidates[[3]] %>%
    str_match('^\\((\\w+),') %>%
    `[`( , 2)
  state <- raw_candidates[[3]] %>%
    str_match(', (\\w{2})') %>%
    `[`( , 2)
  
  data.frame(
    first_name = raw_candidates[[1]],
    last_name = raw_candidates[[2]],
    party = party,
    state = state
  )
}

parse_candidate_summary <- function(raw_year) {
  # Parse candidate information from text files that contain a summary of the
  # performance of each candidate in a given election year.
  
  # Begins 4 lines after the header SUMMARY OF...
  start <- grep('SUMMARY OF POPULAR AND ELECTORAL COLLEGE VOTE', raw_year) + 4
  # Ends one line before the first dashed line after the start point.
  end <- grep('^-+', raw_year[start:length(raw_year)])[1] + start - 2
  
  raw_year <- raw_year[start:end] %>%
    str_split('\\s{2,}') %>%
    lapply(`[`, 1:3)
  raw_year <- do.call(rbind, raw_year[seq(1, length(raw_year) - 1)])
  
  candidate_name <- str_split(raw_year[, 1], '\\s{1}')
  first_name <- lapply(candidate_name, function(i) {
    paste(i[seq(1, length(i) - 1)], collapse = ' ')
  })
  last_name <- lapply(candidate_name, function(i) i[length(i)])
  
  data.frame(
    first_name = unlist(first_name),
    last_name = unlist(last_name),
    party = raw_year[, 2],
    state = raw_year[, 3]
  )
}

parse_candidates <- function(year) {
  if (year == 2004) {
    stop('The 2004 electoral returns file does not contain the full set ',
         'of candidate information.')
  }
  file <- paste0('./data/electoral-returns/raw/', year, '.txt')
  raw <- scan(file, what = 'character', sep = '\n')
  
  if (year < 2000) return(parse_raw_candidates(raw))
  else return(parse_candidate_summary(raw))
}