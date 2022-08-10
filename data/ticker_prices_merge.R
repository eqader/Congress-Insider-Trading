## Code to merge all of the trade price data files into one
library(vroom)
library(data.table)

file_vec <- fs::dir_ls(path = './price_data/', glob = '*_prices.csv')

merged <- vroom(file_vec)

fwrite(merged, 'all_prices.csv', sep = ',')