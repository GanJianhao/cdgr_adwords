
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


tommys<-get_ga(25764841, start.date = startdate, end.date = enddate,
                
                metrics = "
                        ga:adClicks,
                        ga:impressions,
                        ga:CTR,
                        ga:CPC,
                        ga:adCost,
                        ga:adSlotPosition
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
head(tommys)
