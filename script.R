####################################################
############### Adwords Report #####################
####################################################

library(RGA)

client.id = '543269518849-dcdk7eio32jm2i4hf241mpbdepmifj00.apps.googleusercontent.com'
client.secret = '9wSw6gyDVXtcgqEe0XazoBWG'

ga_token<-authorize(client.id, client.secret, cache = getOption("rga.cache"),
                    verbose = getOption("rga.verbose"))

#Set Dates
# YYYY-MM-DD , today, yesterday, or 7daysAgo
startdate='2015-01-12'
enddate='2015-01-18'


accs<-list_profiles(account.id = "~all", webproperty.id = "~all",
                    start.index = NULL, max.results = NULL, ga_token,
                    verbose = getOption("rga.verbose"))

accounts<-data.frame(id = accs$id)
accounts$desc<-c('website', 'android', 'ios', 'youtube')
rm(accs)


# Initial fetch

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
adwords

# Get rid of zero impression lines
adwords <- adwords[adwords$impressions !=0,]

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