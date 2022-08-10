import quiverquant, time
import pandas as pd

# get list of tickers
tickers = pd.read_csv("ticker_list.csv")

# set token, connect
quiver = quiverquant.quiver("bd515dcb6fbff4d0462e47c5e3a057a67f8eed8e")

# instantiate dataframe and counter
all_data = pd.DataFrame(columns=["ReportDate","TransactionDate","Ticker","Representative","Transaction","Amount","House","Range"])
i=1

# get data and write files
for ticker in tickers["Symbol"]:
    print(i, ticker) # print progress info
    i += 1
    time.sleep(0.02) # avoid rate limiting
    try:
        congress = quiver.congress_trading(ticker=ticker)
        all_data = pd.concat([all_data, congress], axis=0, ignore_index=True)
    except:
        pass

all_data.to_csv(f"all_trades.csv")