# Generate the variables needed to estimate the fundamental forecast model of
# state-level electoral returns.
library(dplyr)
library(readr)

# State-level vote shares for presidential elections from 1972 onward
state_returns <- read_csv('./data/electoral-returns/clean/electoral_returns.csv')
# Indicator variable for whether a candidate won the popular vote in a state.
state_returns$run_state <- state_returns$ecv > 0

# Candidate information
candidates <- read_csv('./data/electoral-returns/clean/candidates.csv')
party_abbv <- read_csv('./data/party_names.csv')

candidates <- left_join(candidates, party_abbv, by = 'party')

# Presidential approval ratings for Q2 in election years from 1972 onward
approval <- read_csv('./data/approval/clean_approval.csv') %>%
  mutate(net_approval = approve - disapprove) %>%
  filter(end_year %in% seq(1972, 2016, 4), end_quarter == 2, !is.na(n_obs)) %>%
  group_by(candidate_name, end_year) %>%
  summarise(avg_approval = weighted.mean(approve, n_obs),
            avg_net_approval = weighted.mean(net_approval, n_obs))
