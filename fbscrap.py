import json
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.by import By
import os 
import time
from selenium.webdriver.chrome.options import Options

def facebook_login(mail, pwd):
    chrome_options = Options()
    chrome_options.add_argument('--headless')  # Add this line to enable headless mode
    chrome_options.add_argument('--disable-gpu')  # Add this line to disable GPU acceleration
    chrome_options.add_argument('--user-agent=Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1')
    driver = webdriver.Chrome(options=chrome_options)
    driver.get('https://free.facebook.com')

    form = driver.find_element(By.ID, 'login_form')
    if form:
        email_input = form.find_element(By.NAME, 'email')
        password_input = form.find_element(By.NAME, 'pass')

        email_input.send_keys(mail)
        password_input.send_keys(pwd)
        password_input.submit()
        return driver

    else:
        print("Form not found.")
        driver.quit()
        return None

def perform_search(driver, search_query):
    if driver:
        search_url = 'https://free.facebook.com/search/top/'
        driver.get(search_url + f'?q={search_query}')
        return driver
    else:
        print("Driver not available.")
        return None

driver = facebook_login("", "")
search_query = 'Beauty tips'
perform_search(driver, search_query)
time.sleep(2)
article_div_strings = []
formatted_content = []
extracted_content = []

scroll_times = 5
index_start=1
for _ in range(scroll_times):
    driver.execute_script("window.scrollBy(0, window.innerHeight);")
    time.sleep(2)
    try:
        see_more_div = driver.find_element(By.ID, "see_more_pager")
        see_more_link = see_more_div.find_element(By.TAG_NAME, "a")
        if see_more_link.is_displayed():
            see_more_link.click()
            time.sleep(2)
    except Exception:
        pass
    dynamic_content = driver.page_source
    soup = BeautifulSoup(dynamic_content, 'html.parser')
    target_div_elements = soup.find_all('div', attrs={'role': 'article'})
    for index, div in enumerate(target_div_elements, start=index_start):

        div_text = div.get_text(strip=True)


        a_tags = div.find_all('a')
        a_links = [a.get('href') for a in a_tags]


        content_dict = {
            'index': index,
            'div_content': div_text,
            'a_links': a_links
        }
        extracted_content.append(content_dict)


output_folder = "formatted_content"
os.makedirs(output_folder, exist_ok=True)
output_file_path = os.path.join(output_folder, "formatted_content.json")

with open(output_file_path, "w", encoding="utf-8") as output_file:
    json.dump(extracted_content, output_file, indent=4, ensure_ascii=False)

print(f"Formatted content saved to {output_file_path}")
 
