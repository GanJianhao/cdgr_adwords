####################################################
##########  Monthly ## Adwords Report ##############
####################################################


setwd("C:/Users/tantonakis/Google Drive/Scripts/AnalyticsProj/cdgr_adwords/Monthly")

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


####################################################
############### SOS!! CHANGE DATE###################
####################################################
startdate = as.Date('2015-1-1')
enddate = as.Date('2015-1-31')


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
                ga_token
)
# adwords

# Get rid of zero impression lines
adwords <- adwords[adwords$impressions !=0,]

#Calculate CPR, CPO
adwords$cpr<-adwords$adCost / adwords$goal6Completions
adwords$cpo<-adwords$adCost / adwords$goal1Completions



write.xlsx(x = adwords, file = "MonthlyAdwords.xlsx",row.names = FALSE)

# Environment Size 
# print(paste("Size:", format(object.size(ls()), unit="Kb")))
save.image()
