library(dplyr)
library(lubridate)
library(jsonlite)

approval <- fromJSON('./data/approval/approval_parsed.json') %>%
  mutate(poll_start = as.Date(poll_start),
         poll_end = as.Date(poll_end)) %>%
  mutate(start_year = year(poll_start),
         start_quarter = quarter(poll_start),
         end_year = year(poll_end),
         end_quarter = quarter(poll_end)) %>%
  select(candidate_name = name, start_year, start_quarter, end_year, end_quarter,
         approve, disapprove, no_opinion, n_obs)

write.csv(approval, './data/approval/clean_approval.csv', row.names = FALSE)