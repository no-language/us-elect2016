# Generate the variables needed to estimate the fundamental forecast model of
# state-level electoral returns.
library(dplyr)
library(readr)

# State-level vote shares for presidential elections from 1972 onward
state_returns <- read_csv('./data/electoral-returns/clean/electoral_returns.csv')
# Indicator variable for whether a candidate won the popular vote in a state.
state_returns$run_state <- state_returns$ecv > 0

# Candidate information

# Presidential approval ratings for Q2 in election years from 1972 onward
approval <- read_csv('./data/approval/clean_approval.csv')
