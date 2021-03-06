####################################################
##########  Monthly ## Adwords Report ##############
####################################################
ptm <- proc.time()

setwd("C:/Users/tantonakis/Google Drive/Scripts/AnalyticsProj/cdgr_adwords/Budget")

library(RGA)
library(RMySQL)
library(xlsx)
library(tidyr)
library(plyr)
library(dplyr)

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
startdate = as.Date('2015-01-01')
enddate = as.Date('2015-02-28')


adwords_init<-get_ga(25764841, start.date = startdate, end.date = enddate,
                
                metrics = "
                        ga:impressions,
                        ga:adClicks,
                        ga:sessions,
                        ga:newUsers,
                        ga:adCost,
                        ga:goal6Completions
                ",
                
                dimensions = "
                        ga:campaign,
                        ga:yearMonth
                ",
                sort = "
                        ga:yearMonth,
                        -ga:impressions
                ", 
                filters = NULL,
                segment = NULL, 
                sampling.level = NULL,
                start.index = NULL, 
                max.results = NULL, 
                ga_token
)
# adwords

# Get rid of zero impression lines
adwords_init <- adwords_init[adwords_init$impressions !=0,]


impressions<-select(adwords_init, campaign, year.month, impressions) %>% spread(year.month, impressions)
impressions$metric<-'impressions'

adClicks<-select(adwords_init, campaign, year.month, ad.clicks) %>% spread(year.month, ad.clicks)
adClicks$metric<-'adClicks'

sessions<-select(adwords_init, campaign, year.month, sessions) %>% spread(year.month, sessions)
sessions$metric<-'sessions'

newUsers<-select(adwords_init, campaign, year.month, new.users) %>% spread(year.month, new.users)
newUsers$metric<-'newUsers'

adCost<-select(adwords_init, campaign, year.month, ad.cost) %>% spread(year.month, ad.cost)
adCost$metric<-'adCost'

reg<-select(adwords_init, campaign, year.month, goal6Completions) %>% spread(year.month, goal6Completions)
reg$metric<-'registrations'

report<- rbind(impressions, adClicks, sessions, newUsers,adCost, reg  )
report[is.na(report)]<-0

report$cat<-0
report$cat[grep("Remarketing", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Remarketing"
report$cat[grep("DSP", report$campaign , ignore.case=TRUE, fixed=FALSE)]<-"Display"
report$cat[grep("App. Android", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Android"
report$cat[grep("App. iOS", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"iOS"
report$cat[grep("Brand", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Brand"

report$cat[grep("Mundial", report$campaign , ignore.case=TRUE, fixed=FALSE)]<-"Remarketing"
report$cat[grep("mundo", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Remarketing"
report$cat[grep("DSP Dominos Triti", report$campaign , ignore.case=TRUE, fixed=FALSE)]<-"Remarketing"
report$cat[grep("DSP Dominos Triti Similar", report$campaign , ignore.case=TRUE, fixed=FALSE)]<-"Remarketing"
report$cat[grep("DSP Goody's", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Remarketing"
report$cat[grep("DSP Goody's Similar", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Display"
report$cat[grep("DSP Pizza Fan 2", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Remarketing"
report$cat[grep("DSP Pizza_Fan", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Remarketing"
report$cat[grep("DSP_Chains", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Remarketing"
report$cat[grep("Dsp_Retarg_Test", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Remarketing"
report$cat[grep("Hut remarketing", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Remarketing"
report$cat[grep("mundo sports", report$campaign , ignore.case=FALSE, fixed=TRUE)]<-"Display"

report$cat[grep("Mundobasket", report$campaign , ignore.case=TRUE, fixed=FALSE)]<-"Youtube"
report$cat[grep("TV #match_day_offer", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Youtube"
report$cat[grep("TV generic", report$campaign , ignore.case=FALSE, fixed=FALSE)]<-"Youtube"
report$cat[grep("Goody's 1+1", report$campaign , ignore.case=FALSE, fixed=TRUE)]<-"Youtube"

report$cat[report$cat==0]<-"Rest"
report<-report[,c(1,(ncol(report)-1), ncol(report), 2:(ncol(report)-2))]
rm(adwords_init)


free_seg<-get_ga(25764841, start.date = startdate, end.date = enddate,
                     
                     metrics = "
                        ga:impressions,
                        ga:adClicks,
                        ga:sessions,
                        ga:newUsers,
                        ga:adCost,
                        ga:goal6Completions
                ",
                     
                     dimensions = "
                        ga:channelGrouping,
                        ga:yearMonth
                ",
                     sort = "
                        ga:yearMonth,
                        -ga:impressions
                ", 
                     filters = NULL,
                     segment = NULL, 
                     sampling.level = NULL,
                     start.index = NULL, 
                     max.results = NULL, 
                     ga_token
)
# free_seg
free_seg<-select(free_seg,channel.grouping, year.month, sessions, new.users, goal6Completions)

sessions<-select(free_seg,channel.grouping, year.month, sessions) %>% spread(year.month, sessions)
sessions$metric<-'sessions'

newUsers<-select(free_seg,channel.grouping, year.month, new.users) %>% spread(year.month, new.users)
newUsers$metric<-'newUsers'

registrations<-select(free_seg,channel.grouping, year.month, goal6Completions) %>% spread(year.month, goal6Completions)
registrations$metric<-'registrations'

web_free_seg<- rbind(sessions, newUsers, registrations)
web_free_seg[is.na(web_free_seg)]<-0
web_free_seg<-web_free_seg[,c(1,ncol(web_free_seg), 2:(ncol(web_free_seg)-1))]

rm(accounts, adClicks, adCost,  free_seg, impressions, newUsers, reg, registrations, sessions)


and_free<-get_ga(81060646, start.date = startdate, end.date = enddate,
                     
                     metrics = "
                        ga:sessions,
                        ga:users,
                        ga:newUsers
                ",
                     
                     dimensions = "
                        ga:yearMonth
                ",
                     sort = "
                        ga:yearMonth                        
                ", 
                     filters = NULL,
                     segment = NULL, 
                     sampling.level = NULL,
                     start.index = NULL, 
                     max.results = NULL, 
                     ga_token
)
and_free$app<-'android'


ios_free<-get_ga(81074931, start.date = startdate, end.date = enddate,
                 
                 metrics = "
                        ga:sessions,
                        ga:users,
                        ga:newUsers
                ",
                 
                 dimensions = "
                        ga:yearMonth
                ",
                 sort = "
                        ga:yearMonth                        
                ", 
                 filters = NULL,
                 segment = NULL, 
                 sampling.level = NULL,
                 start.index = NULL, 
                 max.results = NULL, 
                 ga_token
)
ios_free$app<-'ios'

mob_free<-rbind(and_free, ios_free)
rm(and_free, ios_free)

sessions<-select(mob_free, app, year.month, sessions) %>% spread(year.month, sessions)
sessions$cat<-'sessions'
users<-select(mob_free, app, year.month, users) %>% spread(year.month, users)
users$cat<-'users'
newUsers<-select(mob_free, app, year.month, new.users) %>% spread(year.month, new.users)
newUsers$cat<-'newUsers'
mob_free<-rbind(sessions,users, newUsers)
mob_free<-mob_free[,c(1,ncol(mob_free),2:(ncol(mob_free)-1))]
rm(newUsers, users,sessions)

# Facebook Web 
fbweb<-get_ga(25764841, start.date = startdate, end.date = enddate,
                     
                     metrics = "
                        ga:sessions,
                        ga:newUsers,
                        ga:goal6Completions
                     ",
                     
                     dimensions = "
                     ga:source,
                     ga:yearMonth
                     ",
                     sort = "
                     ga:yearMonth,
                     -ga:sessions
                     ", 
                     filters = NULL,
                     segment = NULL, 
                     sampling.level = NULL,
                     start.index = NULL, 
                     max.results = NULL, 
                     ga_token
)
# Facebook
names(fbweb)<-c("src", "yearMonth", "sessions", "newUsers", "registrations")
sessions<-select(fbweb, src, yearMonth, sessions) %>% spread(yearMonth, sessions)
sessions$cat<-'sessions'
newUsers<-select(fbweb, src, yearMonth, newUsers) %>% spread(yearMonth, newUsers)
newUsers$cat<-'newusers'
registrations<-select(fbweb, src, yearMonth, registrations) %>% spread(yearMonth, registrations)
registrations$cat<-'registrations'



facebook_web<-rbind(sessions,newUsers, registrations)
facebook_web<-facebook_web[,c(1, ncol(facebook_web), 2:(ncol(facebook_web)-1))]
rm(newUsers, sessions,registrations, fbweb)
facebook_web[is.na(facebook_web)]<-0
facebook_web<-facebook_web[grep("facebook", facebook_web$src , ignore.case=FALSE, fixed=FALSE),]


gc()
proc.time() - ptm
write.xlsx(x = report, file = "adwords.xlsx", row.names = FALSE)
write.xlsx(x = web_free_seg, file = "web_free.xlsx", row.names = FALSE)
write.xlsx(x = mob_free, file = "mob_free.xlsx", row.names = FALSE)
write.xlsx(x = facebook_web, file = "facebook.xlsx", row.names = FALSE)
proc.time() - ptm
# Environment Size 
# print(paste("Size:", format(object.size(ls()), unit="Kb")))

###########################################################
################# mySQL calculations ######################
###########################################################

# Open VPN !!!

###################
# Verifications
###################

#
# exw allaksei to i_date se u_date
#

# Establish connection
con <- dbConnect(RMySQL::MySQL(), host = '172.20.0.1', port = 3307, dbname = "beta",
                 user = "tantonakis", password = "2secret4usAll!")
# Send query
rs <- dbSendQuery(con,"

SELECT            MONTH(FROM_UNIXTIME(`user_master`.`u_date`)) as MONTH,
                  `user_master`.`referal_source` AS SOURCE ,
                  COUNT(*) AS VERIFIED_USERS
                  FROM `user_master`
                  WHERE `user_master`.`verification_date` >= UNIX_TIMESTAMP('2015-01-01')
                  AND `user_master`.`verification_date` < UNIX_TIMESTAMP('2015-03-01')
                  AND `user_master`.`status` = 'VERIFIED'
                  AND `user_master`.`is_deleted` = 'N'
                  GROUP BY `user_master`.`referal_source`, MONTH(FROM_UNIXTIME(`user_master`.`u_date`))
                  
                  ")
# Fetch query results (n=-1) means all results
verified_src <- dbFetch(rs, n=-1) 

# close connection
dbDisconnect(con)
# Stop timer
proc.time() - ptm


############################################################################
# Registrations
############################################################################
# Establish connection
con <- dbConnect(RMySQL::MySQL(), host = '172.20.0.1', port = 3307, dbname = "beta",
                 user = "tantonakis", password = "2secret4usAll!")
# Send query
rs <- dbSendQuery(con,"
                  
SELECT MONTH(FROM_UNIXTIME(`user_master`.`i_date`)) as MONTH,
                `user_master`.`referal_source` AS SOURCE,
                COUNT(*) AS REGISTERED_USERS
                FROM `user_master`
		WHERE `user_master`.`i_date` >= UNIX_TIMESTAMP('2015-01-01')
		AND `user_master`.`i_date` < UNIX_TIMESTAMP('2015-03-01')
		AND `user_master`.`is_deleted` = 'N'
		GROUP BY `user_master`.`referal_source`, MONTH(FROM_UNIXTIME(`user_master`.`i_date`))
                  
                  
                  ")
# Fetch query results (n=-1) means all results
registered_src <- dbFetch(rs, n=-1) 

# close connection
dbDisconnect(con)
# Stop timer
proc.time() - ptm
# Clean UP
gc()

#########################################
# Orders From mySQL
#########################################

# Establish connection
con <- dbConnect(RMySQL::MySQL(), host = '172.20.0.1', port = 3307, dbname = "beta",
                 user = "tantonakis", password = "2secret4usAll!")
# Send query
rs <- dbSendQuery(con,"
                  
                  SELECT MONTH(FROM_UNIXTIME(`order_master`.`i_date`)) as MONTH,
                       `order_master`.`order_referal` AS SOURCE ,
                         COUNT(*) AS VERIFIED_ORDERS
                  FROM `order_master`

                  WHERE `order_master`.`i_date` >= UNIX_TIMESTAMP('2015-01-01')
                  AND `order_master`.`i_date` < UNIX_TIMESTAMP('2015-03-01')
                  AND `order_master`.`status` IN ('VERIFIED', 'REJECTED')
                  AND `order_master`.`is_deleted` = 'N'
                  GROUP BY  `order_master`.`order_referal`, MONTH(FROM_UNIXTIME(`order_master`.`i_date`))
                  
                  ")
# Fetch query results (n=-1) means all results
orders_src <- dbFetch(rs, n=-1) 
# close connection
dbDisconnect(con)
# Stop timer
proc.time() - ptm
# Clean UP
gc()
 
registered_src$cat<-""
verified_src$cat<-""
orders_src$cat<-""

# Android
registered_src$cat[registered_src$SOURCE == "Android"]<-"android" #1
verified_src$cat[verified_src$SOURCE == "Android"]<-"android"
orders_src$cat[orders_src$SOURCE == "Android"]<-"android"
# iOS
registered_src$cat[registered_src$SOURCE == "IOS"]<-"ios" #2
verified_src$cat[verified_src$SOURCE == "IOS"]<-"ios"
orders_src$cat[orders_src$SOURCE == "IOS"]<-"ios"

# Paid Facebook
registered_src$cat[grep("facebook", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Paid Facebook" #3
verified_src$cat[grep("facebook", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Paid Facebook" #3
orders_src$cat[grep("facebook", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Paid Facebook" #3

# Social
registered_src$cat[grep("facebook.com", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Social" #4
verified_src$cat[grep("facebook.com", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Social" #4
orders_src$cat[grep("facebook.com", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"Social" #4

# # Direct 
registered_src$cat[registered_src$SOURCE == ""]<-"direct" #5
registered_src$cat[grep("clikdeliv", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"direct" #6
registered_src$cat[grep("direct", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"direct" #7
registered_src$cat[grep("clickdelivery", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"direct" #8
verified_src$cat[verified_src$SOURCE == ""]<-"direct" #5
verified_src$cat[grep("clikdeliv", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"direct" #6
verified_src$cat[grep("direct", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"direct" #7
verified_src$cat[grep("clickdelivery", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"direct" #8
orders_src$cat[orders_src$SOURCE == ""]<-"direct" #5
orders_src$cat[grep("clikdeliv", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"direct" #6
orders_src$cat[grep("direct", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"direct" #7
orders_src$cat[grep("clickdelivery", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"direct" #8

# Adwords
registered_src$cat[grep("google", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"adwords" #9
registered_src$cat[grep("google|cpc|Brand", registered_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"brand" #10
registered_src$cat[grep("remar", registered_src$SOURCE , ignore.case=TRUE, fixed=FALSE)]<-"remarketing" #11
registered_src$cat[grep("google|display|", registered_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"display" #19
verified_src$cat[grep("google", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"adwords" #9
verified_src$cat[grep("google|cpc|Brand", verified_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"brand" #10
verified_src$cat[grep("remar", verified_src$SOURCE , ignore.case=TRUE, fixed=FALSE)]<-"remarketing" #11
verified_src$cat[grep("google|display|", verified_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"display" #19
orders_src$cat[grep("google", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"adwords" #9
orders_src$cat[grep("google|cpc|Brand", orders_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"brand" #10
orders_src$cat[grep("remar", orders_src$SOURCE , ignore.case=TRUE, fixed=FALSE)]<-"remarketing" #11
orders_src$cat[grep("google|display|", orders_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"display" #19

# Organic
registered_src$cat[grep("google.", registered_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"organic" #12
registered_src$cat[grep("search", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic" #13
registered_src$cat[grep("yahoo", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic" #14
registered_src$cat[grep("bing", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic" #17
verified_src$cat[grep("google.", verified_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"organic" #12
verified_src$cat[grep("search", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic" #13
verified_src$cat[grep("yahoo", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic" #14
verified_src$cat[grep("bing", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic" #17
orders_src$cat[grep("google.", orders_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"organic" #12
orders_src$cat[grep("search", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic" #13
orders_src$cat[grep("yahoo", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic" #14
orders_src$cat[grep("bing", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"organic" #17

# Newsletter
registered_src$cat[grep("newsletter", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"newsletter" #18
verified_src$cat[grep("newsletter", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"newsletter" #18
orders_src$cat[grep("newsletter", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"newsletter" #18

# Affiliate
registered_src$cat[grep("linkwise", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"affiliate" # 15
verified_src$cat[grep("linkwise", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"affiliate" # 15
orders_src$cat[grep("linkwise", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"affiliate" # 15

# Youtube
registered_src$cat[grep("youtube", registered_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"youtube" # 16
verified_src$cat[grep("youtube", verified_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"youtube" # 16
orders_src$cat[grep("youtube", orders_src$SOURCE , ignore.case=FALSE, fixed=FALSE)]<-"youtube" # 16

# Referral
registered_src$cat[registered_src$cat == ""]<-"referral" #5
verified_src$cat[verified_src$cat == ""]<-"referral" #5
orders_src$cat[orders_src$cat == ""]<-"referral" #5

# Google+
registered_src$cat[grep("plus.url.google", registered_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"Social" #4
verified_src$cat[grep("plus.url.google", verified_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"Social" #4
orders_src$cat[grep("plus.url.google", orders_src$SOURCE , ignore.case=FALSE, fixed=TRUE)]<-"Social" #4

# Summarize
registered_src<-ddply(registered_src,c("cat", "MONTH"), summarize, registration=sum(REGISTERED_USERS))
verified_src<-ddply(verified_src,c("cat", "MONTH"), summarize, verifications=sum(VERIFIED_USERS))
orders_src<-ddply(orders_src,c("cat", "MONTH"), summarize, orders=sum(VERIFIED_ORDERS))

registered_src<-registered_src %>% spread(MONTH, registration)
registered_src$metric<-'registrations'
verified_src<-verified_src %>% spread(MONTH, verifications)
verified_src$metric<-'verifications'
orders_src<-orders_src %>% spread(MONTH, orders)
orders_src$metric<-'orders'
registered_src[is.na(registered_src)]<-0
verified_src[is.na(verified_src)]<-0
orders_src[is.na(orders_src)]<-0
#verified_src$'3'<-NULL
#verified_src$'10'<-NULL

sql<-rbind(registered_src, verified_src, orders_src)
sql<-sql[,c(1,ncol(sql), 2:(ncol(sql)-1))]

rm(registered_src, verified_src, orders_src)
# Export final dataframes
write.xlsx(x = sql, file = "sql.xlsx",
           sheetName = "Sheet 1", row.names = FALSE)


# save.image()
proc.time() - ptm
gc()