setwd(file.path(Sys.getenv("USERPROFILE"),"Downloads"))
death<-read.csv("WB_HCP_PROBDEATH_NCD.CSV")
smoke<-read.csv("WB_WDI_SH_PRV_SMOK.CSV")
head(death)
head(smoke)
names(death)
names(smoke)
dim(death)
dim(smoke)
str(death)
str(smoke)
colSums(is.na(death))
colSums(is.na(smoke))
library(dplyr)
death_clean<-death%>%
  select(country = REF_AREA_LABEL,year = TIME_PERIOD,
         sex = SEX_LABEL,death_prob = OBS_VALUE)
smoke_clean <-smoke%>%
  select(country = REF_AREA_LABEL,year =TIME_PERIOD,
         sex = SEX_LABEL,smoke_rate = OBS_VALUE)
head(death_clean)
head(smoke_clean)
unique(death_clean$sex)
unique(smoke_clean$sex)
merged<-inner_join(
  death_clean%>% select(-sex),
  smoke_clean%>%select(-sex),
  by=c("country","year")
)
dim(merged)
head(merged)
colSums(is.na(merged))
summary(merged)
n_distinct(merged$country)
table(merged$year)
merged %>%
  distinct(country)%>%
  arrange(desc(nchar(country)))%>%
  head(40)
  install.packages("countrycode")
library(countrycode)  
merged$ iso3<-countrycode(merged$country,"country.name","iso3c") 
merged %>%
  filter(is.na(iso3))%>%
  distinct(country)%>%
  pull(country)
merged_country<-merged%>%filter(!is.na(iso3))
dim(merged_country)
n_distinct(merged_country$country)
merged_country %>%
  group_by(year) %>%
  summarise(avg_death=mean(death_prob),
            avg_smoke=mean(smoke_rate))
library(ggplot2)
ggplot(merged_country,aes(x=smoke_rate,y=death_prob))+
  geom_point()+
  geom_smooth(method="lm")+
  facet_wrap(~year)
cor(merged_country$smoke_rate,merged_country$death_prob)
names(death)
unique(death$INDICATOR_LABEL)
unique(death$UNIT_MEASURE_LABEL)
unique(death$AGE_LABEL)
merged_country %>%
  filter(country %in% c("Bangladesh","United States","Niger"))%>%
  arrange(country,year)
merged_country <- merged_country %>% rename(ncd_share = death_prob)
model<-lm(ncd_share~smoke_rate,data=merged_country)
summary(model)
merged_country %>% 
  filter(country %in% c("Bangladesh","United States","Niger"))%>%
  ggplot(aes(x=year,y=ncd_share,color=country))+
  geom_line() +
  geom_point()
unique(smoke$INDICATOR_LABEL)
merged_country <- merged_country %>% rename(ncd_mortality = ncd_share)
model<-lm(ncd_mortality~smoke_rate,data=merged_country)
summary(model)
class(merged_country$year)
model2<-lm(ncd_mortality~smoke_rate+year,data=merged_country)
summary(model2)
anova(model,model2)
summary(model)$adj.r.squared
summary(model2)$adj.r.squared
plot(model2,which=1)
model3<-lm(ncd_mortality~smoke_rate+year+country,data=merged_country)
summary<-(model3)$adj.r.squared
summary<-(model2)$adj.r.squared
plot(model3,which=1)
summary(model3)$adj.r.squared
rm(summary)
summary(model3)$adj.r.squared
coef(summary(model3))[c("smoke_rate","year"),]
chart1<-ggplot(merged_country,aes(x=smoke_rate,y=ncd_mortality))+
  geom_point(color="grey70",alpha=0.5)+
  geom_smooth(aes(group=country),method = "lm",se=FALSE,
linewidth=0.3,color="steelblue",alpha=0.5)+
  geom_smooth(method="lm",se=FALSE,color="red",linewidth=1.5)+
  labs(title="Smoking and NCD mortality:overall vs within -country",
x="tobacco use (% of adults)",
y="probablity of dying from NCD ,age 30-70(%)")+
  theme_minimal()
chart1
chart2<-merged_country%>%
  filter(country %in% c("Bangladesh","United States","Niger")) %>%
  ggplot(aes(x=year,y=ncd_mortality,color=country))+
  geom_line()+
  geom_point()+
  labs(title="NCD mortality over time",x="year",
       y="probablity of dying from NCD (%)",color="country")+
  theme_minimal()
chart2
ggsave("chart1.png",chart1,width=7,height=5)
ggsave("chart2.png",chart2,width=7,height=5)
