{
 "cells": [
  {
   "cell_type": "markdown",
   "id": "522e5ef9-258c-4799-a0cd-5ff9f162fd1b",
   "metadata": {},
   "source": [
    "<h1>Scarping Hotel Details of a City on TripAdvisor</h1>"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "d4bd2288-81d8-4c3a-bf44-f4720003d997",
   "metadata": {},
   "source": [
    "![](https://i.imgur.com/G96GAVs.png)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "d2477506-20fd-4c5a-8ef0-cb302aedfe10",
   "metadata": {},
   "source": [
    "**Data** has become a major part of our day-to-day lives. we have tons of unstructured data available freely over the web. one can use automatic methods such as **Web-Scraping** to collect this unstructured data and convert it to structured data"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "e55be1ee-d1fe-4af6-a967-b583a50be312",
   "metadata": {},
   "source": [
    "<h2>What is web-scraping?</h2>"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "097059eb-5d92-463b-8e86-60a20e5d5d93",
   "metadata": {},
   "source": [
    "- Web scraping is an automatic method to obtain large amounts of data from websites.Most of this data is unstructured data in an HTML format which is then converted into structured data in a spreadsheet or a database so that it can be used in various applications."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "b5970f43-dc49-4b4a-802e-8e24f7e2d9a2",
   "metadata": {},
   "source": [
    "Here we are scraping the [TripAdvisor](https://www.tripadvisor.com/) website to parse the Hotel prices offered by different websites for the same hotel in a given city."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "99cd5e2b-f21b-4d5c-a022-232fe35f5523",
   "metadata": {},
   "source": [
    "**TripAdvisor** is a travel guide website that offers its users from planning to booking to taking a trip. we are using the below tools to complete this project.\n",
    "\n",
    "* **Python** is one of the most popular languages for web scraping as it has a variety of libraries that are specifically created for Web Scraping.\n",
    "* **Beautiful soup** is another Python library that is highly suitable for Web Scraping, It creates a parse tree that can be used to extract data from HTML on a website.\n",
    "* **Selenium Webdriver** is a tool for testing the front end of an application, it is used to perform browser manipulation in web scraping\n",
    "* **Pandas** is a tool used to read and manipulate the data"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f7c81ede-1015-4a65-a97f-625020e47a09",
   "metadata": {},
   "source": [
    "![](https://i.imgur.com/wMBkdtA.png)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "3a806345-da2e-4f1b-9d7f-9c9124ad0c8c",
   "metadata": {},
   "source": [
    "<h3>Project Outline :</h3>\n",
    "\n",
    "- Install and Import the required packages.\n",
    "- Defining the global variables\n",
    "- Create the selenium webdriver object\n",
    "- By providing required inputs to the driver crawl to the hotel's page\n",
    "- Create a BeautifulSoup object from the loaded page source and Parse the Hotel's details from BeautifulSoup object\n",
    "- Write the Parsed data to a CSV file using Pandas\n",
    "- Defining a main function to run all the above steps\n",
    "- Open the CSV file and View the data using pandas pandas"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "25fb9868-0933-4a36-b6a9-dd26f9542314",
   "metadata": {},
   "source": [
    "<h4>Install and Import the required packages.</h4>\n",
    "\n",
    "- PIP is the standard package mangement system in Python, below are the packages we need to install for this project.\n",
    "\n",
    "below are the libraries that are imported"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 9,
   "id": "8f488dea-a225-42e1-aa3f-a50dfee8060a",
   "metadata": {},
   "outputs": [],
   "source": [
    "!pip install beautifulsoup4 selenium pandas -q"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 10,
   "id": "ccedac2a-5bba-4e78-80ff-3fa15d1ed285",
   "metadata": {},
   "outputs": [],
   "source": [
    "from selenium import webdriver\n",
    "from selenium.webdriver.chrome.service import Service\n",
    "from selenium.webdriver.common.by import By\n",
    "from selenium.webdriver.common.keys import Keys\n",
    "from selenium.webdriver.support.ui import WebDriverWait\n",
    "from selenium.webdriver.support import expected_conditions as EC\n",
    "from bs4 import BeautifulSoup\n",
    "import pandas as pd\n",
    "import time"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "631fe10d-7403-4bb3-b976-403b64143ffd",
   "metadata": {},
   "source": [
    "<h4>Defining the global variables.</h4>"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 33,
   "id": "169b88f3-409d-4517-9ba2-b1dbabbc1e81",
   "metadata": {},
   "outputs": [],
   "source": [
    "SCRAPING_URL = \"https://www.tripadvisor.com/\"\n",
    "\n",
    "\n",
    "#INPUTS\n",
    "CITY = \"Hyderabad\"\n",
    "CHECK_IN = \"Tue December 25 2023\"\n",
    "CHECK_OUT = \"Wed December 26 2023\"\n",
    "NO_OF_PAGES = 5\n",
    "\n",
    "#Global Variables\n",
    "HOTELS_LIST = []\n",
    "HOTELS_DF = None"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "fdd7a780-c31a-4e71-89ed-f4695bfa57f0",
   "metadata": {},
   "source": [
    "<h4>Create the selenium webdriver object.</h4>\n",
    "\n",
    "- we have to create the webdriver instance of the required browser type by providing path to the chromedriver and required additional options."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 34,
   "id": "9c1fbf5a-6756-41e9-8e63-8bb74dfe8fa0",
   "metadata": {},
   "outputs": [],
   "source": [
    "def get_driver_object():\n",
    "    \"\"\"\n",
    "    Creates and returns the selenium webdriver object \n",
    "    Returns:\n",
    "        Chromedriver object: This driver object can be used to simulate the webbrowser\n",
    "    \"\"\"\n",
    "\n",
    "    # Creating the ChromeOptions object to pass the additional arguments to webdriver\n",
    "    options = webdriver.ChromeOptions()\n",
    "    # Adding the arguments to ChromeOptions object\n",
    "    options.headless = True ##To run the chrome without GUI\n",
    "    options.add_argument(\"start-maximized\") #To start the window maximised\n",
    "    options.add_argument(\"--disable-extensions\")   #To disable all the browser extensions\n",
    "    options.add_argument(\"--log=level=3\") #To to capture the logs from level 3 or above\n",
    "    options.add_experimental_option(\n",
    "        \"prefs\", {\"profile.managed_default_content_settings.images\":2}  #To to capture the logs from level 3 or above\n",
    "    )\n",
    "\n",
    "     # Creating the Webdriver object of type Chrome by passing service and options arguments\n",
    "    driver_object = webdriver.Chrome(options=options)\n",
    "    return driver_object\n",
    "    "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "c3b084d2-e88a-4c47-8a8b-72d8a0418a95",
   "metadata": {},
   "source": [
    "- we have to open website by passing URL to the webdriver instance with get() method."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 35,
   "id": "83868efe-161b-4a0d-a99b-5df519711f7e",
   "metadata": {},
   "outputs": [],
   "source": [
    "def get_website_driver(driver=get_driver_object(), url=SCRAPING_URL):\n",
    "    \"\"\"it will get the chromedriver object and opens the given URL\n",
    "    Args:\n",
    "        driver (Chromedriver): _description_. Defaults to get_driver_object().\n",
    "        url (str, optional): URL of the website. Defaults to SCRAPING_URL.\n",
    "    Returns:\n",
    "        Chromedriver: The driver where the given url is opened.\n",
    "    \"\"\"\n",
    "# Opening the URL with the created driver object\n",
    "    print(\"Webdriver is created\")\n",
    "    driver.get(url)\n",
    "    print(f\"The url '{url}' is opened\")\n",
    "    return driver"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "4838a84a-667d-4d3d-918a-2e38dbc52b67",
   "metadata": {},
   "source": [
    "<h4>By providing required inputs to the driver crawl to the hotel's page</h4>\n",
    "\n",
    "- The name of the CITY is provided as input in the search field using send_keys(\"input_text\") method."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "e4924f9e-90a3-46a3-8333-a58518586890",
   "metadata": {},
   "source": [
    "![\"Entering name of city\"](https://i.imgur.com/v93Q8dt.png)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "5728b778-a27d-46b5-95cc-1a123b1dc9e5",
   "metadata": {},
   "source": [
    "- The Hotels tab is seleceted in the loaded in page after giving the city as input."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "098b8df2-569c-4f1b-9ab9-a01ad8056157",
   "metadata": {},
   "source": [
    "![](https://i.imgur.com/foi2Z0w.png)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 14,
   "id": "230cc79e-7afa-4db5-8b0d-fb5a2b510653",
   "metadata": {},
   "outputs": [],
   "source": [
    "def open_hotels_tab(driver):\n",
    "    \"\"\" Opens the Hotels link with city provided\n",
    "    Args:\n",
    "        driver (Chromedriver): The driver where the url is opened.\n",
    "    \"\"\"\n",
    "    #Finding the Input Tag for to enter the CITY name\n",
    "    city_input_tag = driver.find_element(by=By.XPATH, value=\"//input[@placeholder='Places to go, things to do, hotels...']\")\n",
    "\n",
    "    #providing the charaters in the CITY one by one as the search is dynamically loaded\n",
    "    for letter in CITY:\n",
    "        city_input_tag.send_keys(letter)\n",
    "    time.sleep(5)\n",
    "\n",
    "  # selecting the top search result based on the input provided\n",
    "    city_input_tag.send_keys(keys.ARROW_DOWN)\n",
    "    city_input_tag.send_keys(keys.ENTER)\n",
    "    time.sleep(5)\n",
    "\n",
    "     # selecting the type as Hotels in the webpage that is loaded\n",
    "    wait = WbDriverWait(driver, 10)\n",
    "    for _ in range(3):\n",
    "        try:\n",
    "            select_hotels_tag = wait.until(EC.presence_of_element_located((By.XPATH,'//span[contains(text(),\"Hotels\")]')))\n",
    "            driver.execute_script(\"arguments[0].click();\", select_hotels_tag)\n",
    "            break\n",
    "        except:\n",
    "            time.sleep(2)\n",
    "            continue\n",
    "    print(\"The Hotels window with the provided city is opened\")\n",
    "    "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "9be23359-0f2b-4b46-921a-075ff1ccb176",
   "metadata": {},
   "source": [
    "- Check in and Check out dates are loaded in the page"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "fbcfeadf-d81f-45d0-a90f-55270815dccb",
   "metadata": {},
   "source": [
    "![](https://i.imgur.com/Mt0Jnwg.png)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 27,
   "id": "210b75f7-0236-4967-afe6-cfb6a806fb59",
   "metadata": {},
   "outputs": [],
   "source": [
    "def select_check_in(driver):\n",
    "    \"\"\"The check in date is selected in the list the dates available \n",
    "    Args:\n",
    "        driver (Chromedriver): The driver instance where the Hotels page is loaded\n",
    "    \"\"\"\n",
    "    # Check in Date element is selected\n",
    "    check_in_dates = driver.find_elements(By.CLASS_NAME,\"tuqBW\")\n",
    "    \n",
    "    # Selecting the check in date in the available dates\n",
    "    for date in check_in_date:\n",
    "        date_value = date.get_attribute('aria-lable')\n",
    "        if date_value == CHECK_IN and date.is_enable():\n",
    "            driver.execute_scripts(\"argument[0].click()\", date_value)\n",
    "            print('check in date is selected')\n",
    "\n",
    "def select_check_out(driver):\n",
    "    \"\"\"The check out date is selected in the list the dates available \n",
    "    Args:\n",
    "        driver (Chromedriver): The driver instance where the Hotels page is loaded\n",
    "    \"\"\"\n",
    "    #  After the check in date is selected the wep-page loads in the backgound the chances of getting \n",
    "    #  stale element exceptions are more to avoid this we can use implicit or explicit wait\n",
    "\n",
    "    wait = WebDriverWait(driver,10)\n",
    "    # check out date element is selected\n",
    "    check_out_dates = wait.until(EC.presence_of_all_elements_located((BY.CLASS_NAME,\"tuqBW\")))\n",
    "    \n",
    "    \n",
    "    # selecting the check out date in available dates\n",
    "    for date in check_out_dates:\n",
    "        date_value = date.get_attribute('aria-lable')\n",
    "        if date_value == CHECK_OUT and date.is_enable():\n",
    "            driver.implicitly_wait(10)\n",
    "            # searching the check out date element in the wep page to avoid Stale Element exception\n",
    "            date_element = wait.until(EC.presence_of_element_located((By.XPATH,f\"//div/[@aria-label = '{date_value}']\")))\n",
    "            driver.execute_scripts(\"argument[0].click()\", date_value)\n",
    "            print(\"check out date is selected\")\n",
    "            break\n",
    "\n",
    "def select_check_in_out_dates(driver):\n",
    "    \"\"\"The check in and check out dates are selected in the webpage loaded\n",
    "    Args:\n",
    "        driver (webdriver): The driver instance where the hotels page is loaded with provided city\n",
    "    \"\"\"\n",
    "    # Moving to the first month that is available\n",
    "\n",
    "\n",
    "    # Select check in Date\n",
    "    select_check_in(driver)\n",
    "    time.sleep(10)\n",
    "    \n",
    "    # Select Check out Date\n",
    "    select_check_out(driver)\n",
    "    time.sleep(10)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "9c0693e1-2127-4763-b664-39485951f118",
   "metadata": {},
   "source": [
    "![\"update button in guest room box\"](https://i.imgur.com/GzrTr8Z.png)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 42,
   "id": "d0e33916-1609-4ed2-965f-3e5dfaa9490a",
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "The page is loaded with check in and check out dates\n"
     ]
    }
   ],
   "source": [
    "def update_driver(driver):\n",
    "    \"\"\"The check in , check out details are updated to populate the hotel results\n",
    "    Args:\n",
    "        driver (Chromedriver): The driver instance where check in and check out dates are selected\n",
    "    \"\"\"\n",
    "     # The webpage is dyanmically loading in the background once check in date\n",
    "for _ in range(10):\n",
    "    try:\n",
    "        driver.find_element(By.XPATH, f\"//button[@class='rmyCe _G B- z _S c Wc wSSLS jWkoZ sOtnj']\").click()\n",
    "        break\n",
    "    except:\n",
    "        time.sleep(5)\n",
    "print(\"The page is loaded with check in and check out dates\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "3cc6e8b7-28e5-48ed-8aa4-e7a1f3450a0b",
   "metadata": {},
   "source": [
    "<h3>Create a BeautifulSoup object from the loaded page source and Parse the Hotel's details from BeautifulSoup object</h3>\n",
    "\n",
    "- The driver.page_source is passed to BeautifulSoup Class to create a BeautifulSoup object.\n",
    "- The various hotel details are parsed from this soup object.\n",
    "- parse_hotel_details(hotel) is function which takes hotel DIV element and parses the hotel information marked below."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "b8b65293-b188-4c95-9c22-3efea04e1f28",
   "metadata": {},
   "source": [
    "![\"first search result of hotel\"](https://i.imgur.com/211hpen.png)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 1,
   "id": "65bd92c8-d27f-4128-a1ab-871c63d1d2c6",
   "metadata": {},
   "outputs": [],
   "source": [
    "def parse_best_offer(hotel):\n",
    "    \"\"\"Parse the best offer hotel details given on tripadvisor\n",
    "\n",
    "    Args:\n",
    "        hotel (Beautifulsoup object): The hotel div element which contains hotel details\n",
    "    \n",
    "    Returns:\n",
    "        Dict: returns dictionary containing best offer hotel details. \n",
    "    \"\"\"\n",
    "    hotel_name = hotel.find(\"a\",class_=\"property_title\").text.strip()[3:]\n",
    "    hotel_price = hotel.find(\"div\",class_=\"price\").text\n",
    "    best_price_offered_element = hotel.find(\"img\",class_=\"provider_logo\")\n",
    "    best_price_offered_by = best_price_offered_element[\"alt\"] if best_price_offered_element is not None else None\n",
    "    review_count = hotel.find(\"a\",class_=\"review_count\").text \n",
    "    return  {\n",
    "        \"Hotel_Name\" : hotel_name,\n",
    "        \"Hotel_Price\" : hotel_price,\n",
    "        \"Best_Deal_By\" : best_price_offered_by,\n",
    "        \"Review_Count\" : review_count,\n",
    "    }"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "8d2d697b-79e9-410f-a30f-691f0e007e7c",
   "metadata": {},
   "source": [
    "- The details of the other offers listed for a hotel is parsed in the below function."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "b60dac56-71f5-49b6-b20f-31a5159ac253",
   "metadata": {},
   "source": [
    "![](https://i.imgur.com/PTRuly0.png)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 3,
   "id": "72991c54-00aa-41da-8924-dd56aba7a547",
   "metadata": {},
   "outputs": [],
   "source": [
    "def parse_other_offers(hotel,hotel_details):\n",
    "    \"\"\"Parse the hotel details of other deals given on tripadvisor and to the hotel_details dictionary\n",
    "\n",
    "    Args:\n",
    "        hotel (Beautifulsoup object): The hotel div element which contains hotel details\n",
    "        hotel_details : Dictionary containing the best hotel details\n",
    "    Returns:\n",
    "        Dict: returns dictionary containing all offer's hotel details. \n",
    "    \"\"\"\n",
    "    other_deals = hotel.find(\"div\",class_=\"text-links\",).find_all(\"div\",recursive=False)\n",
    "    for i in range(3):\n",
    "        try : \n",
    "            deal_name_tag = other_deals[i].find(\"span\",class_=\"vendorInner\")\n",
    "            deal_name = deal_name_tag.text if deal_name_tag is not None else None\n",
    "            hotel_details[f\"next_deal_{i+1}\"] = deal_name\n",
    "\n",
    "            deal_price_tag = other_deals[i].find(\"div\",class_=\"price\")\n",
    "            deal_price = deal_price_tag.text if deal_price_tag is not None else None\n",
    "            hotel_details[f\"next_deal_{i+1}_price\"] = deal_price\n",
    "        except:\n",
    "            hotel_details[f\"next_deal_{i+1}\"] = None\n",
    "            hotel_details[f\"next_deal_{i+1}_price\"] = None\n",
    "    return hotel_details"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 4,
   "id": "6329efe6-841e-4afb-b52b-542ce88d826d",
   "metadata": {},
   "outputs": [],
   "source": [
    "def parse_hotel_details(hotel):\n",
    "    \"\"\"Parse the hotel details from the given hotel div element\n",
    "\n",
    "    Args:\n",
    "        hotel (Beautifulsoup object): The hotel div element which contains hotel details\n",
    "    \"\"\"\n",
    "    #declaring the global variables\n",
    "    global HOTELS_LIST\n",
    "\n",
    "    #Parsing the best offer Hotel Details\n",
    "    best_offer_deals = parse_best_offer(hotel)\n",
    "    \n",
    "    #Parsing the other offers Hotel Details \n",
    "    hotel_details = parse_other_offers(hotel,best_offer_deals)\n",
    "    \n",
    "    # Apending the data to the hotels list\n",
    "    HOTELS_LIST.append(hotel_details)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "e6750de8-7ee2-4d7d-bd51-7d50b3b612a2",
   "metadata": {},
   "source": [
    "- Function to create and parse the Hotel details."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 5,
   "id": "65ad1f20-511c-4e75-8bd4-d20c4ef942b2",
   "metadata": {},
   "outputs": [],
   "source": [
    "def parse_hotels(driver):\n",
    "    \"\"\" To parse th web page using the BeautifulSoup\n",
    "\n",
    "    Args:\n",
    "        driver (Chromedriver): The driver instance where the hotel details are loaded\n",
    "    \"\"\"\n",
    "    # Getting the HTML page source\n",
    "    html_source = driver.page_source\n",
    "\n",
    "    # Creating the BeautifulSoup object with the html source\n",
    "    soup = BeautifulSoup(html_source,\"html.parser\")\n",
    "    \n",
    "    # Finding all the Hotel Div's in the BeautifulSoup object \n",
    "    hotel_tags = soup.find_all(\"div\",{\"data-prwidget-name\":\"meta_hsx_responsive_listing\"})\n",
    "    \n",
    "    # Parsing the hotel details \n",
    "    for hotel in hotel_tags:\n",
    "        # condition to check if the hotel is sponsered, ignore this hotel if it is sponsered\n",
    "        sponsered = False if hotel.find(\"span\",class_=\"ui_merchandising_pill\") is None else True\n",
    "        if not sponsered:\n",
    "            parse_hotel_details(hotel)\n",
    "    print(\"The Hotels details in the current page are parsed\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "1a4a45ad-91cc-49b6-b786-23b3de1ead8b",
   "metadata": {},
   "source": [
    "- Next page is loaded after the details in the current page is parsed by clicking on the next page button."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "d8fb1cc7-b29d-4bbb-a3e7-73b40504feab",
   "metadata": {},
   "source": [
    "![](https://i.imgur.com/WpnAJMp.png)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 6,
   "id": "097fe29f-87b8-4580-aed1-a733f2834d82",
   "metadata": {},
   "outputs": [],
   "source": [
    "def next_page(driver) -> bool:\n",
    "    \"\"\"To load the next webpage if it is available\n",
    "\n",
    "    Args:\n",
    "        driver (Chromedriver): The driver instance where the hotel details are loaded\n",
    "\n",
    "    Returns:\n",
    "        bool: returns True if the page is loaded \n",
    "    \"\"\"\n",
    "    # Finding the element to load the next page\n",
    "    next_page_element = driver.find_element(By.XPATH,value='.//a[@class=\"nav next ui_button primary\"]')\n",
    "    \n",
    "    # click on the next page element if it is avialable\n",
    "    if next_page_element.is_enabled():\n",
    "        driver.execute_script(\"arguments[0].click();\", next_page_element)\n",
    "        time.sleep(30)\n",
    "        return True\n",
    "    return False"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "c45af227-8ab9-4741-a9e8-b4960bf05b98",
   "metadata": {},
   "source": [
    "<h4>Write the Parsed data to a CSV file using Pandas</h3>"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "6f29c0e1-f265-4644-8191-4f8ddf1de61b",
   "metadata": {},
   "source": [
    "- Create a Pandas DataFrame object with the list of Hotel details.\r\n",
    "- \r\n",
    "Write the data to a CSV file using pandas.DataFrame.to_csv() method."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 7,
   "id": "1c553aff-8bd3-4ed5-b2f7-0eb08cc4ad43",
   "metadata": {},
   "outputs": [],
   "source": [
    "def write_to_csv():\n",
    "    \"\"\"To Write the hotels data in to a CSV file using pandas\n",
    "    \"\"\"\n",
    "    #declaring the global variables\n",
    "    global HOTELS_LIST,HOTELS_DF\n",
    "\n",
    "    # Creating the pandas DataFrame object\n",
    "    HOTELS_DF = pd.DataFrame(HOTELS_LIST,index=None)\n",
    "\n",
    "    # Viewing the DataFrame\n",
    "    print(f\"The number of columns parsed is {HOTELS_DF.shape[1]}\")\n",
    "    print(f\"The number of rows parsed is {HOTELS_DF.shape[0]}\")\n",
    "\n",
    "    # Conveting the DataFrame to CSV file\n",
    "    HOTELS_DF.to_csv(\"hotels_list.csv\",index=False)\n",
    "    print(\"The CSV file is created at hotels_list.csv\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "47e27803-92bc-40a1-8b9a-35ec2e21c878",
   "metadata": {},
   "source": [
    "<h4>Defining a main function to run all the above steps.</h4>"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 8,
   "id": "e0a205a1-c085-48ef-9a0a-c4392a5cd04d",
   "metadata": {},
   "outputs": [],
   "source": [
    "def main():\n",
    "    # Create the driver and load the website\n",
    "    driver = get_website_driver()\n",
    "    \n",
    "    # open the website with details provided   \n",
    "    search_hotels(driver)\n",
    "    time.sleep(30)\n",
    "    \n",
    "    # Parse the hotel details for the given no of pages\n",
    "    parse_hotels(driver)\n",
    "    for page in range(NO_OF_PAGES):\n",
    "        if next_page(driver):\n",
    "            print(f\"The next page is loaded : Page No - {page+2}\")\n",
    "            parse_hotels(driver)\n",
    "    \n",
    "    # write the parsed data in to a CSV file\n",
    "    write_to_csv()\n",
    "    \n",
    "    # close the driver once the parsing is completed\n",
    "    driver.close()\n",
    "    print(\"The driver is closed\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "721815a4-27f1-467a-94f5-2c1705b5de38",
   "metadata": {},
   "outputs": [],
   "source": [
    "main()"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "aedf19d8-dd29-489b-bde1-22d9c1aef05e",
   "metadata": {},
   "source": [
    "<h4>Open the CSV file and View the data using pandas</h4>"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "2a8b045e-68bd-4cb5-bfd5-be5fbe258bba",
   "metadata": {},
   "outputs": [],
   "source": [
    "hotels_csv_file = pd.read_csv(\"hotels_list.csv\")\n",
    "hotels_csv_file.head()"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "87259494-64d6-49bd-a040-f8752cce7adc",
   "metadata": {},
   "source": [
    "<h2>Summary</h2>lysis."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "b877b81b-5997-4fa0-a03f-d734e88070a8",
   "metadata": {},
   "source": [
    "- To summarise we have opened the TripAdvisor website and crawled our way to the Hotel listings by providing the required information to the selenium webdriver which mimicked the human actions and opened the website for us.\n",
    "\n",
    "- Now to parse the details in the loaded page we have used Beautiful Soup, which allowed us to get the required hotel details from the HTML page source.\n",
    "\n",
    "- we have used pandas to save the data into a CSV file by converting our data to DataFrame object.\n",
    "\n",
    "- we can use this same technique to collect the other details available on the website using the above functions with some modifications,The data collected can be used for further analysis."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "dedb6fdf-d8a7-45eb-a998-9bdde737c67a",
   "metadata": {},
   "source": [
    "<h3>References</h3>"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "275f9ab8-0997-4c4e-9e1d-26cccb9a1d17",
   "metadata": {},
   "source": [
    "- [Workshop - Web Scraping with Selenium & AWS](https://jovian.com/learn/zero-to-data-analyst-bootcamp/lesson/workshop-web-scraping-with-selenium-aws) - Basics of Selenium and webscraping.\n",
    "- [HTML Topics ](https://www.w3schools.com/html/default.asp) - Basics of HTML Tags\n",
    "- [CSS](https://www.w3schools.com/css/default.asp) - Basics of CSS Selectors.\n",
    "- [BeautifulSoup Topics.](https://www.geeksforgeeks.org/navigation-with-beautifulsoup/) -  Basics of BeautifulSoup.\n",
    "- [Selenium with Python Playlist](https://www.youtube.com/watch?v=IYILCEV5j6s&list=PLUDwpEzHYYLvx6SuogA7Zhb_hZl3sln66) - By SDET- QA Automation\n",
    "- [Web Scraping and REST APIs](https://jovian.com/learn/zero-to-data-analyst-bootcamp)- By Jovian"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "ee4765d9-3a5a-4506-b3de-a8306e7e87ef",
   "metadata": {},
   "source": [
    "<h3>Future work</h3>"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "a73fbb1e-1ae9-4b6d-b076-09c260591dec",
   "metadata": {},
   "source": [
    "- same parsing technique can be applied to get other details in a city such as restaurants, fight deals, car rentals etc.\n",
    "- Parsing the each individual hotel details by visting the websites that offers this deals.\n",
    "- comparison analysis how the prices vary from one wesite to another."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "87733f50-920a-4842-83f6-908a4b61d635",
   "metadata": {},
   "outputs": [],
   "source": [
    "import jovian"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "e55fb821-e159-441f-bac1-c395cbbbbd23",
   "metadata": {},
   "outputs": [],
   "source": [
    "jovian.commit(files=[\"hotels_list.csv\"])"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3 (ipykernel)",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.11.5"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
