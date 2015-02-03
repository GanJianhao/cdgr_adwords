####################################################
############### Adwords Report #####################
####################################################

load(".RData")

library(RGA)
library(xlsx)
library(lubridate)
library(zoo)
library(ggplot2)

client.id = '543269518849-dcdk7eio32jm2i4hf241mpbdepmifj00.apps.googleusercontent.com'
client.secret = '9wSw6gyDVXtcgqEe0XazoBWG'

ga_token<-authorize(client.id, client.secret, cache = getOption("rga.cache"),
                    verbose = getOption("rga.verbose"))

accs<-list_profiles(account.id = "~all", webproperty.id = "~all",
                    start.index = NULL, max.results = NULL, ga_token,
                    verbose = getOption("rga.verbose"))

accounts<-data.frame(id = accs$id)
accounts$desc<-c('website', 'android', 'ios', 'youtube')
rm(accs)


# Start a report data.frame
# report<-data.frame(year = 0,
#                    week = 0,
#                    date = 0,
#                    adCostB = 0, 
#                    adCostNB = 0,
#                    regB = 0,
#                    regNB = 0, 
#                    clickB = 0, 
#                    clickNB = 0                   
# )

#Set Dates
# YYYY-MM-DD , today, yesterday, or 7daysAgo
today <- Sys.Date()

####################################################
############### SOS!! CHANGE DATE###################
####################################################
startdate = as.Date('2015-1-26')
# startdate = as.Date('2013-12-30')
enddate = startdate+6
weeksleft<-as.numeric(today-startdate) %/% 7

# Potential loop start
while (weeksleft!=0) {
# Fetch

adwords<-get_ga(25764841, start.date = startdate, end.date = enddate,
                
                metrics = "
                        ga:sessions,
                        ga:impressions,
                        ga:adClicks,
                        ga:adCost,
                        ga:goal1Completions,
                        ga:goal6Completions
                ",
                
                dimensions = "
                        ga:campaign
                ",
                sort = "-ga:impressions", 
                filters = NULL,
                segment = NULL, 
                sampling.level = NULL,
                start.index = NULL, 
                max.results = NULL, 
                ga_token,
                verbose = getOption("rga.verbose")
)
# adwords

# Get rid of zero impression lines
adwords <- adwords[adwords$impressions !=0,]

#Calculate CPR, CPO
adwords$cpr<-adwords$adCost / adwords$goal6Completions
adwords$cpo<-adwords$adCost / adwords$goal1Completions


# Break data frame to the three sheets
# Mobile Tab
mobile<- adwords [adwords$campaign %in% c("App. Android-Text", "App. iOS-Text"),]

# Remarketing Tab
remarketing<- adwords [adwords$campaign %in% c("Remarketing Goods offer", "Remarketing Fan", 
                                               "Remarketing Artigiano", "Remarketing Dominos"),]

# Search tab
search<-  adwords [!(adwords$campaign %in% c("Remarketing Goods offer", "Remarketing Fan", 
                                           "Remarketing Artigiano", "Remarketing Dominos", 
                                           "App. Android-Text", "App. iOS-Text")),]

# search$br_nbr<-0
# search$br_nbr[search$campaign == 'Brand'] <- "Brand"
# search$br_nbr[search$campaign != 'Brand'] <- "No_Brand"
search$cpr<-NULL
search$cpo<-NULL
search$cpr<-search$adCost / search$goal6Completions
search$cpo<-search$adCost / search$goal1Completions


#Start filling the report dataframe with weekly data
tbadded<-data.frame(year = 0,
                    week = 0,
                    date = 0,
                    adCostB = 0, 
                    adCostNB = 0,
                    regB = 0,
                    regNB = 0, 
                    clickB = 0, 
                    clickNB = 0                   
)

tbadded$year <- year(enddate)
tbadded$week <-  week(enddate)
tbadded$date <- enddate
tbadded$adCostB <- search$adCost[search$campaign == 'Brand']
tbadded$adCostNB <- sum(search$adCost[search$campaign != 'Brand'])
tbadded$regB <- search$goal6Completions[search$campaign == 'Brand']
tbadded$regNB <- sum(search$goal6Completions[search$campaign != 'Brand'])
tbadded$clickB <- search$adClicks[search$campaign == 'Brand']
tbadded$clickNB <- sum(search$adClicks[search$campaign != 'Brand'])

#Request for Android App new Installs

android<-get_ga(81060646, start.date = startdate, end.date = enddate,
                
                metrics = "
                        ga:goal1Completions, 
                        ga:newUsers
                ",
                
                dimensions = "ga:medium",
                sort ="-ga:newUsers" ,
                filters =  "ga:medium == cpc",
                segment = NULL, 
                sampling.level = NULL,
                start.index = NULL, 
                max.results = NULL, 
                ga_token,
                verbose = getOption("rga.verbose")
)


startdate=startdate+7
enddate=startdate+6

weeksleft<-as.numeric(today-startdate) %/% 7

report$cprB<-NULL
report$cprNB<-NULL

# kati se rbind       
report<-rbind(report,tbadded )       
} # Potential Loop end
        
#report<-report[-1,]  
report$cprB<-report$adCostB / report$regB
report$cprNB<-report$adCostNB / report$regNB

## Plotting

# x<-1:20
# y1<-sqrt(x)
# y2<-sqrt(x)*x
# plot(x,y1,ylim=c(0,25),col="blue")
# par(new=TRUE)
# plot(x,y2,ylim=c(0,100),col="red",axes=FALSE)
# axis(4)



# Ad Costs All campaigns
plot(report$date, report$adCostNB, type= 'h', lwd = 4, col = 'deepskyblue1', ylim = c(0,10000),
     main = "Adwords Costs per week (Brand excl.)" ,xlab="Date", ylab = "Ad Cost")
par(new=TRUE)
plot(report$date, report$regNB, type= 'l', lwd = 2, col = 'red',ylab = "",xlab = "", ylim = c(0,1000),axes=FALSE)
axis(4)
# με δύο άξονες!! Yaaayyyy!!!

# Ad Costs Brand campaign
plot(report$date, report$adCostB, type= 'h', lwd = 4, col = 'deepskyblue2', 
     main = "Brand Campaign Costs per week" ,xlab="Date", ylab = "Ad Cost")

# Registrations
# library(ggplot2)


# rm(adwords)




# Check how all data can be included in one data.frame
# check how we can retrieve data from previous weks for comparison
# Differences with previous weeks

# Print on screen the number of android installs
print("New Android App Installations")
print(android$newUsers)

# Export final dataframes

write.xlsx(x = search, file = "search.xlsx",
           sheetName = "Sheet 1", row.names = FALSE)

write.xlsx(x = mobile, file = "mobile.xlsx",
           sheetName = "Sheet 1", row.names = FALSE)

write.xlsx(x = remarketing, file = "remarketing.xlsx",
           sheetName = "Sheet 1", row.names = FALSE)

# Environment Size 
# print(paste("Size:", format(object.size(ls()), unit="Kb")))
save.image()
