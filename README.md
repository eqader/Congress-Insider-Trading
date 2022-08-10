# Team 062 Congressional Insider Trading Project MGT-6203

TL;DR
The final project report is located in the 'final_report/' folder and is named 'team062FinalReport.pdf'
All of the main code to verify our results is located in the 'analysis/' folder under the 'graphs.Rmd', 'generate_returns_by_trade.R', and 'returns_clustering.Rmd' files.

All for this project data was pulled from publicly available datasets online.
Data for congressional trades
 1. https://api.quiverquant.com/
 2. Auth Token: bd515dcb6fbff4d0462e47c5e3a057a67f8eed8e

Data for historical ticker prices
 1. Pulled using the Tidyquant package in R

Congressional Member metadata
 1. https://projects.propublica.org/api-docs/congress-api/
 2. Key: z7YTk9TlqV7c6CnCPYfZKpeWbL8D8bsmldik4dLI
 3. Pulled using a curl script

## Gathering all data

All code to request and gather the data using the APIs listed above is in the folder "./data_gathering". 
* Data for the congressional trades was pulled using the script 'pull_congressional_trades_data.py'
* Data for the ticker prices was pulled using the 'retrieve_tq_ticker_data.R'
* Metadata for congressional members was pulled using 'pro_publica_curl_api.txt' in the command line.

Data was aggregated using the following scripts
* Aggregating and saving congressional metadata: './data_gathering/members_json2df.py'
* Aggregating congressional trades data: './data/trades_merge.R'
* Aggregating ticker data: './data/ticker_prices_merge.R'

## Data Cleaning

All code used to clean and preprocess the data is stored in './analysis/scripts'
These scripts are both called in the main markdown file './analysis/graphs.Rmd'

## EDA and clustering
Open the project 'MGT_6203_project.Rproj' in the './analysis/' folder and import the 'graphs.Rmd' markdown file.
Run the scripts to view all of the EDA and clustering

## Member Returns and Returns clustering
In the analysis folder, run the code in 'generate_returns_by_trade.R' and 'returns_clustering.Rmd' to see the all of the results from the congressional trading.


Clustering methods for financial data: https://arxiv.org/pdf/1609.08520

And this one:
https://www.imperial.ac.uk/media/imperial-college/faculty-of-natural-sciences/department-of-mathematics/math-finance/Lu_Yilang_01407813.pdf

Webpage on kmeans clustering and pca for price movements. Applicable to portfolio daily returns: https://www.mlq.ai/stock-market-clustering-with-k-means/

Github repo and python library for congress info: https://github.com/unitedstates/congress-legislators

Reuters article about SEC insider trading detection. It's a little vague, but if you read between the lines, it sounds like they are doing clustering then investigating the clusters for similarities and suspicious activity: https://www.reuters.com/article/bc-finreg-data-analytics-idUSKBN19L28C
