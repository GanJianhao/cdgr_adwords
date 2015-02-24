####################################################
############### Adwords Report #####################
####################################################

# load(".RData")

library(RGA)
library(xlsx)
library(lubridate)
library(zoo)
# library(ggplot2)

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


####################################################
startdate = as.Date('2015-1-5')
# startdate = as.Date('2013-12-30')
enddate = as.Date('2015-2-8')

adwords<-get_ga(25764841, start.date = startdate, end.date = enddate,
                
                metrics = "
                        ga:sessions,
                        ga:users,
                        ga:newUsers,
                        ga:goal1Completions,
                        ga:goal1ConversionRate,
                        ga:goal6Completions,
                        ga:goal6ConversionRate,
                        ga:bounceRate,
                        ga:pageviewsPerSession, 
                        ga:avgSessionDuration
                ",
                
                dimensions = "
                        ga:date,
                        ga:campaign
                ",
                sort = "-ga:sessions", 
                filters = NULL,
                segment = NULL, 
                sampling.level = NULL,
                start.index = NULL, 
                max.results = NULL, 
                ga_token,
                verbose = getOption("rga.verbose")
)
# adwords
# Export final dataframes

write.xlsx(x = adwords, file = "adwords_giant.xlsx",
           sheetName = "Sheet 1", row.names = FALSE)