# Scrape the US presidential election data avaiable from:
# http://psephos.adam-carr.net/countries/u/usa/pres.shtml
from bs4 import BeautifulSoup
import urllib.request
import urllib.parse
import re

root_url = "http://psephos.adam-carr.net/countries/u/usa/pres.shtml"
with urllib.request.urlopen(root_url) as response:
    root_html = response.read()

root_soup = BeautifulSoup(root_html, "lxml")

# The page makes little use of classes/IDs. Best option is to parse the URLs
# of all links of the page to find the election data. We are looking for the
# pattern: '/countries/u/usa/pres/'.
links = [link['href'] for link in root_soup.find_all('a')]
links = [link for link in links if re.match('\/countries\/u\/usa\/pres', link)]

# Save the .txt file located at each URL.
for link in links:
    url = "http://psephos.adam-carr.net" + link
    filename = link.split('/')[-1]
    text = urllib.request.urlopen(url).read()
    
    with open('data/electoral-returns/' + filename, 'wb') as file:
        file.write(text)
