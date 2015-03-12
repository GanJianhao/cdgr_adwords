library(RGA)
library(xlsx)

client.id = '543269518849-dcdk7eio32jm2i4hf241mpbdepmifj00.apps.googleusercontent.com'
client.secret = '9wSw6gyDVXtcgqEe0XazoBWG'

ga_token<-authorize(client.id, client.secret, cache = getOption("rga.cache"))

accs<-list_profiles(account.id = "~all", webproperty.id = "~all",
                    start.index = NULL, max.results = NULL, ga_token)

accounts<-data.frame(id = accs$id)
accounts$desc<-c('website', 'android', 'ios', 'youtube')
rm(accs)

# startdate = as.Date('2015--16')
startdate = as.Date('2015-3-9')
enddate = as.Date('2015-3-15')

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
                        ga:date,
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
# adwords

# Change the time zone of the date in order to export correct dates
adwords$date<- as.POSIXct(format(adwords$date,tz="EET"),tz="GMT")


# as.POSIXct(format(adwords$date[1],tz="EET"),tz="GMT")

write.xlsx(x = adwords, file = 'adwords_pivot.xlsx')

