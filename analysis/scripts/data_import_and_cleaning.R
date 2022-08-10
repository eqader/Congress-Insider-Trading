##########################
#Data Import and Cleaning#
##########################


# Trade Data Import and Cleaning ------------------------------------------
trades <- read.csv('data/all_trades.csv') %>% 
        separate(ReportDate, c('report_date', NA), sep = ' ') %>% 
        separate(TransactionDate, c('trans_date', NA), sep = ' ')

trades$report_date <- ymd(trades$report_date)
trades$trans_date <- ymd(trades$trans_date)

# Fix report date before transaction date
flipped_ind <- which((trades$report_date < trades$trans_date) & !is.na(trades$trans_date))
filtered <- trades[flipped_ind,]
report <- filtered$trans_date
trans <- filtered$report_date
filtered$report_date <- report
filtered$trans_date <- trans
trades[flipped_ind,] <- filtered

trades <- trades %>% 
        mutate(report_lag = as.numeric(report_date - trans_date),
               overdue = ifelse(report_lag >45, report_lag - 45, 0)) %>% 
        filter(Transaction %in% c('Purchase', 'Sale'))

trades$Representative <- str_trim(trades$Representative, 'both')

trade_tickers <- unique(trades$Ticker)

# Assign Did Not Report ---------------------------------------------------

trades <- trades %>% 
        mutate(DNR = ifelse(is.na(report_date), 1, 0))

# Member Data Import and Cleaning -----------------------------------------
members_raw <- read.csv('data/members.csv')
members <- members_raw %>% 
        select(first_name, last_name, party) %>% 
        filter(party != "I") %>% 
        distinct() %>% 
        mutate(name = paste(first_name, last_name, sep = ' '))

members$name <- str_replace_all(members$name, c('A. McEachin' = 'Donald McEachin'))



# Price Data Import and Restructuring -------------------------------------
all_prices <- fread(input = '../data/all_prices.csv', sep = ',', header = TRUE)
all_prices <- all_prices[,-1]

price_list <- list()
tickers <- unique(all_prices$symbol)
for(ticker in tickers){
        df <- filter(all_prices, symbol == ticker)
        price_list[ticker] <-  list(df)
}


# Congressman Name Cleanup ------------------------------------------------

trades$Representative <- str_replace(trades$Representative,' [a-zA-Z]{1}\\.* ', ' ') # remove single middle initials
trades$Representative <- str_replace(trades$Representative,' Jr\\.*', '') # remove all 'Jr.'
trades$Representative <- str_replace(trades$Representative, ' Dr ', ' ') # remove all Dr
trades$Representative <- str_replace(trades$Representative, 'Mrs*\\.{1} ', '') # remove Mr. and Mrs
trades$Representative <- str_replace(trades$Representative, ' I[a-z]{1}$', '') # remove numbered suffixes
trades$Representative <- str_replace(trades$Representative, '  ', ' ') # remove double spaces
trades$Representative <- str_replace(trades$Representative, '^A\\. ', '') # remove mitch mcconnell's first initial
trades$Representative <- str_replace(trades$Representative, ' \\\"Bobby\\\" ', ' ')
trades$Representative <- str_replace(trades$Representative, ' Hon ', ' ') # Remove 'Hon'

#specific name replacement
trades$Representative <- str_replace_all(trades$Representative, c('Patrick Fallon' = 'Pat Fallon',
                                                                  'Michael Simpson' = 'Mike Simpson',
                                                                  'Michael Garcia' = 'Mike Garcia',
                                                                  'K. Michael Conaway' = 'K. Conaway',
                                                                  'James Langevin' = 'Jim Langevin',
                                                                  'Mckinley' = 'McKinley',
                                                                  'Nicholas Van Taylor' = 'Van Taylor',
                                                                  'Donald Sternoff Beyer' = 'Donald Beyer',
                                                                  'Marjorie Taylor Greene' = 'Marjorie Greene',
                                                                  'Ashley Hinson Arenholz' = 'Ashley Hinson',
                                                                  'Christopher Jacobs' = 'Chris Jacobs',
                                                                  'Joseph Morelle' = 'Joe Morelle',
                                                                  'Sean Patrick Maloney' = 'Sean Maloney',
                                                                  'Michael John Gallagher' = 'Mike Gallagher',
                                                                  'Elizabeth Fletcher' = 'Lizzie Fletcher',
                                                                  'Lobiondo' = 'LoBiondo',
                                                                  'Thomas Rooney' = 'Tom Rooney',
                                                                  'Shelley Moore Capito' = 'Shelley Capito',
                                                                  'Pat Toomey' = 'Patrick Toomey',
                                                                  'John Reed' = 'Jack Reed',
                                                                  'Chris Coons' = 'Christopher Coons',
                                                                  'Cindy Axne' = 'Cynthia Axne',
                                                                  'Richard Allen' = 'Rick Allen',
                                                                  'William Keating' = 'Bill Keating',
                                                                  'Thomas Macarthur' = 'Tom MacArthur',
                                                                  'Carol Devine Miller' = 'Carol Miller',
                                                                  'Bradley Schneider' = 'Brad Schneider',
                                                                  'David Madison Cawthorn' = 'Madison Cawthorn',
                                                                  'Bryan George Steil' = 'Bryan Steil',
                                                                  'August Lee Pfluger' = 'August Pfluger',
                                                                  'Michael Patrick Guest' = 'Michael Guest',
                                                                  'David Joyce' = 'Dave Joyce', 
                                                                  'Kenneth Buck' = 'Ken Buck',
                                                                  'Mitchell Mcconnell' = 'Mitch McConnell',
                                                                  'Mitchell McConnell' = 'Mitch McConnell',
                                                                  'David Trott' = 'Dave Trott',
                                                                  'Suzan Delbene' = 'Suzan DelBene',
                                                                  'Rodney Leland Blum' = 'Rod Blum',
                                                                  'Aston Donald Mceachin' = 'Donald McEachin',
                                                                  'Nicholas Taylor' = 'Van Taylor',
                                                                  'James French Hill' = 'French Hill',
                                                                  'Daniel Crenshaw' = 'Dan Crenshaw',
                                                                  'James Banks' = 'Jim Banks',
                                                                  'David Cheston Rouzer' = 'David Rouzer'
))


# Fix Duplicated Transactions ---------------------------------------------
#David Perdue double reported many transactions from 2020-04-14. The first report date
#Was in May of 2020 and the second report date was May 2021. We assume that this was an error
#And only kept the earliest report date for each transaction
per_ind <- which((trades$Representative == 'David Perdue') & (trades$trans_date == '2020-04-14') & (trades$Transaction == 'Sale') & (trades$report_lag > 100))
trades <- trades[-per_ind,]


# Trade Data Merge and Export ---------------------------------------------
trades <- trades %>% 
        left_join(members, by = c('Representative' = 'name')) %>% 
        select(-X) %>% 
        filter(party %in% c('R', 'D'))

if(file.exists('data/all_trades_ammended.csv')==FALSE){
        write.csv(trades, 'data/all_trades_ammended.csv')
}


