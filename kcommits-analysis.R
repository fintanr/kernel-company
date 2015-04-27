#
# kernel commits to stockprice analysis
#
# @fintanr, April 26th/27th 2015
#

library(quantmod)
library(timeDate)
library(ggplot2)

kernelCommitsData <- "kernel-commits-company.csv"
tickersData <- "tickers.csv"

# closed stock exchange dates
exchangeClosed <- as.Date(holidayNYSE(2004:2015), format="%Y-%m-%d")

loadKernelCommits <- function() {
    if ( file.exists(kernelCommitsData)) {
        df <- read.csv(kernelCommitsData, header = TRUE)
        df$Date <- as.Date(df$Date)
    } else {
        quit()
    }
    return(df)
}


getTickerDataByKernelReleaseDates <- function(ticker, df) {
    
    # extract our prices over the range of dates this company
    # has done commits for. We use quantmod and extract our 
    # data from google finance. Yahoo throws back an error
    # for older data
    #
    # these dates are just an approximation
    
    startDate = min(df$Date)
    # we add a week on here to get enough data to extract ticker prices
    endDate = max(df$Date) + 7
    
    tickerData <- getSymbols(ticker, auto.assign=FALSE, src="google",
                             from=startDate, to=endDate)
    
    kDates <- getTickerKDates(df$Date)
    
    specificTickerData <- tickerData[kDates]
    return(specificTickerData)
}

getTickerKDates <- function(df) {
    # kernel releases happen on the weekend and holidays, 
    # pretty frequently as it happens, so we 
    # as an arbitary day that markets are generally open)

    weekDayMatches <- as.Date(sapply(df, changeDay))
    return(weekDayMatches)
}

changeDay <- function(date) {
    thisWeekDay <- weekdays(date)
    
    if ( thisWeekDay == "Saturday" | thisWeekDay == "Sunday") {
        date <- date + 2
    }

    # check if its a holiday, and if it is add 1 on
    # this is really just an approximation
    
    if ( date %in% exchangeClosed ) {
        date <- date + 1
    } 
    
    return(date)
} 

createCompanyDf <- function(name) {
    thisDf <- df[df$Company == name, ]
    thisDf <- thisDf[order(thisDf$Date), ]
    return(thisDf)
}

percentAndValDiff <- function(df) {
    # ,4 is the closing price of the ticker
    latestPrice <- as.numeric(df[,4])[length(df[,4])]
    firstPrice <- as.numeric(df[,4])[1]
    thisVal <- latestPrice - firstPrice
    
    thisPercent <- round( (thisVal/firstPrice) * 100, digits = 2)
    
    return(c(thisPercent, thisVal, latestPrice, firstPrice ))
}

df <- loadKernelCommits()
ticker <- read.csv(tickersData)
# we are going to build a df using a for loop, its lazy, easy
# and the data set is small (and its a Sunday night)

theVals <- data.frame(Company = character(),
                      Ticker = character(),
                      PriceDiff = numeric(),
                      PercentDiff = numeric(),
                      LatestPrice = numeric(),
                      FirstPrice = numeric(),
                      Commit_Count = numeric())

for ( i in 1:length(ticker[,1])) {
    company <- as.character(ticker[i,1])
    stockTicker <- as.character(ticker[i,2])

    print(stockTicker)
    
    cdf <- createCompanyDf(company)
    tdf <- getTickerDataByKernelReleaseDates(stockTicker, cdf)
    tmpVals <- percentAndValDiff(tdf)
    commitCount <- sum(cdf$Commit_Count)
    
    newRow <- data.frame( Company = company,
                          Ticker = stockTicker,
                          PriceDiff = as.numeric(tmpVals[2]),
                          PercentDiff = as.numeric(tmpVals[1]),
                          LatestPrice = as.numeric(tmpVals[3]),
                          FirstPrice = as.numeric(tmpVals[4]),
                          Commit_Count = as.numeric(commitCount))
    
    theVals <- rbind(theVals, newRow)
}

spearman <- cor.test(theVals$Commit_Count, theVals$PercentDiff, 
                             method="spearman")


print(theVals[order(theVals$PercentDiff, decreasing=T),])
print(spearman)

graph1 <- subset(theVals, select = c(Company, PercentDiff))
graph2 <- subset(theVals, select = c(Company, Commit_Count))

g1 <- qplot(x=Company, y=PercentDiff, data=graph1, 
            fill=PercentDiff, geom="bar", stat="identity", 
            position="dodge", xlab="Company", 
            ylab="% Stock Price Diff")
g1 <- g1 + ggtitle("% Stock Price Change from first Kernel Commit to 3.20")
g1 <- g1 + theme(text = element_text(size=15), 
                 axis.text.x = element_text(angle=45, hjust=1))

ggsave("stockprice-percent-diff.png", g1)

g2 <- qplot(x=Company, y=Commit_Count, data=graph2, 
            fill=Commit_Count, geom="bar", stat="identity", 
            position="dodge", xlab="Company", 
            ylab="Total Kernel Commits")
g2 <- g2 + ggtitle("Total Kernel Commits by Company")
g2 <- g2 + theme(text = element_text(size=15), 
                 axis.text.x = element_text(angle=45, hjust=1))

ggsave("total-kernel-commits.png", g2)
