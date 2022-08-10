library(tidyquant)

## Load Congress trades; Write unique tickers to file
congress_trades <- read.csv("all_trades.csv")
unique_tickers <- unique(congress_trades$Ticker)
write.csv(unique_tickers, file = "unique_tickers.csv")

## Grabbing data using unique tickers list - Takes forever because it's ~800 of them
start_date <- DATE(2016, 1,1)
stock_prices <- tq_get(unique_tickers, 
                       get = 'stock_prices',
                       from = start_date)


## Write data to csv -> roughly 400MB. Putting files in OneDrive. See email.
# write.csv(stock_prices, file="stock_prices_2016_present.csv")

for (i in 1:length(unique_tickers)){
  ticker = unique_tickers[i]
  filename = paste(ticker, "_prices.csv", sep="")
  write.csv(subset(stock_prices, symbol == ticker), file = filename)
}