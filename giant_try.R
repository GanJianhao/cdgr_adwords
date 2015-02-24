####################################################
############### Adwords Report #####################
####################################################

load("C:/Users/tantonakis/Google Drive/Scripts/AnalyticsProj/cdgr_adwords/adwords_database.RData")

# Set timer
ptm <- proc.time()

library(RGA)
library(xlsx)
library(lubridate)
library(zoo)
library(ggplot2)
library(dplyr)
library(manipulate)

client.id = '543269518849-dcdk7eio32jm2i4hf241mpbdepmifj00.apps.googleusercontent.com'
client.secret = '9wSw6gyDVXtcgqEe0XazoBWG'

# ga_token<-authorize(client.id, client.secret, cache = getOption("rga.cache"),
#                     verbose = getOption("rga.verbose"))
ga_token<-authorize(client.id, client.secret, cache = getOption("rga.cache"))


# accs<-list_profiles(account.id = "~all", webproperty.id = "~all",
#                     start.index = NULL, max.results = NULL, ga_token,
#                     verbose = getOption("rga.verbose"))
accs<-list_profiles(account.id = "~all", webproperty.id = "~all",
                    start.index = NULL, max.results = NULL, ga_token)

accounts<-data.frame(id = accs$id)
accounts$desc<-c('website', 'android', 'ios', 'youtube')
rm(accs)

####################################################
############### SOS!! CHANGE DATE###################
####################################################
startdate = as.Date('2015-2-19')
# enddate = as.Date('2015-12-31')
# enddate = as.Date('yesterday')

fetch<-get_ga(25764841, start.date = startdate, end.date = "yesterday",
                
                metrics = "
                        ga:sessions,
                        ga:impressions,
                        ga:adClicks,
                        ga:adCost,
                        ga:CPC,
                        ga:goal1Completions,
                        ga:goal6Completions
                ",
                
                dimensions = "
                        ga:date,
                        ga:yearWeek,
                        ga:campaign, 
                        ga:adGroup, 
                        ga:keyword
                ",
                sort = "-ga:impressions", 
                filters = NULL,
                segment = NULL, 
                sampling.level = NULL,
                start.index = NULL, 
                max.results = NULL, 
                ga_token
)
database_keyword<-rbind(database_keyword, fetch)
database_keyword<-distinct(database_keyword)

fetch<-get_ga(25764841, start.date = startdate, end.date = "yesterday",
              
              metrics = "
                        ga:sessions,
                        ga:impressions,
                        ga:adClicks,
                        ga:adCost,
                        ga:CPC,
                        ga:goal1Completions,
                        ga:goal6Completions
                ",
              
              dimensions = "
                        ga:date,
                        ga:yearWeek,
                        ga:campaign, 
                        ga:adGroup
                ",
              sort = "-ga:impressions", 
              filters = NULL,
              segment = NULL, 
              sampling.level = NULL,
              start.index = NULL, 
              max.results = NULL, 
              ga_token
)
database_adgroup<-rbind(database_adgroup, fetch)
database_adgroup<-distinct(database_adgroup)

fetch<-get_ga(25764841, start.date = startdate, end.date = "yesterday",
              
              metrics = "
                        ga:sessions,
                        ga:impressions,
                        ga:adClicks,
                        ga:adCost,
                        ga:CPC,
                        ga:goal1Completions,
                        ga:goal6Completions
                ",
              
              dimensions = "
                        ga:date,
                        ga:yearWeek,
                        ga:campaign
                ",
              sort = "-ga:impressions", 
              filters = NULL,
              segment = NULL, 
              sampling.level = NULL,
              start.index = NULL, 
              max.results = NULL, 
              ga_token
)
database_campaign<-rbind(database_campaign, fetch)
database_campaign<-distinct(database_campaign)
database_keyword<-database_keyword[order(database_keyword$date),]
database_adgroup<-database_adgroup[order(database_adgroup$date),]
database_campaign<-database_campaign[order(database_campaign$date),]
rm(total)
save.image("C:/Users/tantonakis/Google Drive/Scripts/AnalyticsProj/cdgr_adwords/adwords_database.RData")

# Plot per keyword
plot(database_keyword$date[database_keyword$keyword == "dominos"], database_keyword$ad.cost[database_keyword$keyword == "dominos"], type="l", 
     main= "Cost per Day for the selected keyword", xlab="Dates", ylab="Cost")

# Plot per Ad Group
plot(database_adgroup$date[database_adgroup$ad.group == "General_Ioa"], database_adgroup$ad.cost[database_adgroup$ad.group == "General_Ioa"], type="l", 
     main= "Cost per Day for the selected Ad Group", xlab="Dates", ylab="Cost")

# Plot per Campaign
plot(database_campaign$date[database_campaign$campaign == "Competitors"], database_campaign$ad.cost[database_campaign$campaign == "Competitors"], 
     type="l", main= "Cost per Day for the selected Campaign", xlab="Dates", ylab="Cost")

# manipulate slider for timeframe
manipulate(
        plot(database_campaign[database_campaign$campaign == cmp, 1], 
             database_campaign[database_campaign$campaign == cmp, metric], 
             type="l", main= paste("Per Day for the selected", cmp, "campaign"),
             xlim=c(x.min,x.max), xlab="Dates", ylab= metric)
        
        ,
        # Options
        x.min = slider(as.numeric(min(database_campaign$date)), as.numeric(max(database_campaign$date)), 
                        step = 1, initial = as.numeric(min(database_campaign$date)), label = "Start Date"), 
        x.max = slider(as.numeric(min(database_campaign$date)), as.numeric(max(database_campaign$date)), 
                        step = 1, initial = as.numeric(max(database_campaign$date)), label = "Start Date"), 
        cmp = picker("Brand", "Competitors", "Ch.Pizza_Fan", label = "Campaign"),
        metric = picker( "Sessions" = 4, "Impressions" = 5, "Clicks"=6, "Cost" = 7, 
                         "CPC" = 8, "Orders" = 9, "Registrations"= 10, label = "Metric")
        
        )


# Stop timer
proc.time() - ptm

distinct(database_keyword$campaign)