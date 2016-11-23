import requests
import csv
from bs4 import BeautifulSoup


def parse_results_table(results_table, state, year):
    rows = results_table.find_all('tr')[2:-1]
    data = []

    county_entries = results_table.find_all('td', 'ec-jurisdiction')
    rowspans = [int(county_entry['rowspan']) for county_entry in county_entries]
    county_names = [county_entry.find('div').text for county_entry in county_entries]
    
    start_block = 0
    end_block = 0
    for i in range(0, len(county_names)):
        end_block += rowspans[i]
        block = rows[start_block:end_block]
        block = parse_block(block, state, county_names[i], year)
        data += block
        start_block = end_block

    return data
    
def parse_block(block, state, county, year):
    out = []
    for row in block:
        entry = { 'state': state, 'county': county, 'year': year }
        cols = row.find_all('td')

        if 'ec-jurisdiction' in cols[0]['class']:
            cols.pop(0)
        
        entry['party'] = cols[0]['class'][0]
        entry['candidate'] = cols[0].text
        entry['votes'] = cols[1].text
        entry['pct'] = cols[2].text
        
        out.append(entry)

    return out
            
def scrape_county_page(state_abbr, year):
    page_url = 'http://townhall.com/election/{}/president/{}/county'
    page_url = page_url.format(year, state_abbr)

    page = requests.get(page_url)
    page_soup = BeautifulSoup(page.text, 'html.parser')

    results_table = page_soup.find_all('table', 'ec-table')[-1]
    return parse_results_table(results_table, state_abbr, year)

if __name__ == "__main__":
    # Retrieve the state abbreviations used in the Townhall urls.
    state_page = requests.get('http://townhall.com/election/2016/president/')
    state_soup = BeautifulSoup(state_page.text, 'html.parser')
    state_links = state_soup.find('ul', 'state-columns')
    state_links = state_links.find_all('a')
    state_links = [link['href'] for link in state_links]
    state_abbrs = [link.split('/')[-1] for link in state_links]

    results = []
    for year in (2004, 2008, 2012, 2016):
        for state in state_abbrs:
            results += scrape_county_page(state, year)

    with open('county_electoral_results.csv', 'w') as csvfile:
        fieldnames = ['state', 'county', 'year', 'party', 'candidate',
                      'votes', 'pct']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        for row in results:
            writer.writerow(row)

