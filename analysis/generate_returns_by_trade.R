
library(tidyverse)
library(tidyquant)
library(xts)


# Get all congressional orders from all_trades_ammended
orders <- read.csv("analysis/data/all_trades_ammended.csv") %>%
  mutate(trans_date = as.Date(trans_date)) %>%
  filter(Ticker != "HTZWW") %>%
  filter(Ticker != "KPLTW")

# Get all prices into 2d array
prices <- read.csv("analysis/data/all_prices.csv") %>%
  select(c("symbol", "date", "adjusted", "volume")) %>%
  pivot_wider(date, names_from = symbol, values_from = adjusted)

# 2d array of trading volumes
trade_vol <- read.csv("analysis/data/all_prices.csv") %>%
  select(c("symbol", "date", "adjusted", "volume")) %>%
  pivot_wider(date, names_from = symbol, values_from = volume)


prices <- prices %>%
  fill(names(prices)) %>%
  fill(names(prices), .direction = "up") %>%
  mutate(date=as.Date(date))

gspc_prices <- tq_get(c("^GSPC"), get="stock.prices", from=as.Date("2016-01-04"))

trade_vol <- trade_vol %>%
  fill(names(prices)) %>%
  fill(names(prices), .direction = "up") %>%
  mutate(date=as.Date((date)))

trade_returns <- orders %>%
  select(c("trans_date", "Ticker", "Representative", "Transaction", "Amount")) %>%
  mutate(fivedayrets = 0.0) %>%
  mutate(tendayrets = 0.0) %>%
  mutate(fifteendayrets = 0.0) %>%
  mutate(thirtydayrets = 0.0) %>%
  mutate(tradevol = 0.0) %>%
  mutate(marketreturnthirty = 0.0) %>%
  mutate(prev30days = 0.0) %>%
  mutate(prev30market = 0.0)

for (i in 1:nrow(trade_returns)){
  this_return <-trade_returns[i,]
  gspc.window <- gspc_prices %>%
    filter(date >= this_return$trans_date - days(30)) %>%
    select(c(adjusted))
  prices.window <- prices %>%
    filter(date >= this_return$trans_date - days(30))
  this_volume <- trade_vol %>%
    select(c(date,this_return$Ticker)) %>%
    filter(date >= this_return$trans_date - days(30))
  trade_price <- pull(prices.window, this_return$Ticker)
  return.five <- (trade_price[36]/trade_price[31]) -1
  return.ten <- (trade_price[41]/trade_price[31]) -1
  return.fifteen <- (trade_price[46]/trade_price[31]) -1
  return.thirty <- (trade_price[61]/trade_price[31]) -1
  this_return$marketreturnthirty <- (gspc.window[61,]/gspc.window[31,]) -1
  this_return$prev30market <- (gspc.window[31,]/gspc.window[1,])-1
  this_return$fivedayrets <- return.five
  this_return$tendayrets <- return.ten
  this_return$fifteendayrets <- return.fifteen
  this_return$thirtydayrets <- return.thirty
  this_return$tradevol <- this_volume[31,] %>%
    select(this_return$Ticker)
  this_return$prev30days <- (trade_price[31]/trade_price[1])-1
  trade_returns[i,] <- this_return
}

trade_returns$Representative <- as.factor(trade_returns$Representative)
trade_returns$Ticker <- as.factor(trade_returns$Ticker)
trade_returns$tradevol <- as.numeric(trade_returns$tradevol)
trade_returns$marketreturnthirty <- as.numeric(trade_returns$marketreturnthirty)
trade_returns$prev30market <- as.numeric(trade_returns$prev30market)

write.csv(trade_returns, "analysis/data/returns_by_trade.csv")
