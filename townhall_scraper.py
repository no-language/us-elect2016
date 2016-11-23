import requests
from bs4 import BeautifulSoup

# Retrieve the state abbreviations used in the Townhall urls.
state_page = requests.get('http://townhall.com/election/2016/president/')
state_soup = BeautifulSoup(state_page.text, 'html.parser')
state_links = state_soup.find('ul', 'state-columns')
state_links = state_links.find_all('a')
state_links = [link['href'] for link in state_links]
state_abbrs = [link.split('/')[-1] for link in state_links]

def parse_results_table(results_table):
    rows = results_table.find_all('tr')[2:-1]
    data = []

    county_entries = results_table.find_all('td', 'ec-jurisdiction')
    rowspans = [county_entry['rowspan'] for county_entry in county_entries]
    county_names = [county_entry['name'] for county_entry in county_entries]

    return county_entries

    
def parse_row(row):
    row = row.find_all('td')
            
def scrape_county_page(state_abbr, year):
    page_url = 'http://townhall.com/election/{}/president/{}/county'
    page_url = page_url.format(year, state_abbr)

    page = requests.get(page_url)
    page_soup = BeautifulSoup(state_page.text, 'html.parser')

    results_table = page_soup.find_all('table', 'ec-table')[-1]
