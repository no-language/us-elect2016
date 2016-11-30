year <- 2001:2015
urls <- paste0("http://www.bls.gov/cew/data/files/",
               year, "/csv/", year, "_qtrly_by_industry.zip")

for (url in urls)
  download.file(url, paste0('./data/county-employment/raw/', basename(url)))
