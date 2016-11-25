year <- 1990:2016
urls <- paste0("http://www.bls.gov/cew/data/files/",
               year, "/xls/", year, "_all_county_high_level.zip")

for (url in urls)
  download.file(url, basename(url))
