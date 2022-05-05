###########################################################################
###########################################################################
###                                                                     ###
###                             AUTOMAT #9                              ###
###                                                                     ###
###########################################################################
###########################################################################

##-------------------------------------------------------------------------
##         Géolocalisation avec R                                         -
##-------------------------------------------------------------------------

#Je mets le chemin d'accès.
setwd("C:/Users/acastet/Dropbox/Automat_05_05/")

#Je charge ggmap
library(ggmap)

#Je renseigne ma clé API Google.
register_google(key = "AIzaSyAmPpePPSPeJgl55ki6_T6q16bLuCqYtWI")


# Je charge mon fichier.
Labo <- read.csv2('Exemple awesome.csv')

#Je crée une variable avec l'adresse qui combine la rue et la ville.

Labo$Adresse <- paste(Labo$Rue,Labo$Ville, sep=", ")

Labo$GPS <- geocode(Labo$Adresse)











##-------------------------------------------------------------------------
##         Cartographie sur R et Rmarkdown                     -
##-------------------------------------------------------------------------

library(sf)
library(tidyverse)
library(raster)
library(sp)

#------------------------------------------------------

setwd('C:/Users/jbgui/Dropbox/Automat_05_05')

afro_s6 <- read.csv2("DATA/afro_s6_ter.csv")

adm1_shp <- sf::st_read("DATA/tun_adm1/TUN_adm1.shp")
#adm0_shp <- sf::st_read("DATA/tunisia_administrative/tunisia_administrative.shp")

plot(st_geometry(adm1_shp))

mtq_reproj <- st_transform(adm1_shp, 2154)
plot(st_geometry(mtq_reproj))
#title("RGF93 / Lambert-93")


afro_s6 <-  afro_s6 %>%
  mutate(internet_use = case_when(
    q92b == 9 ~ "NA",
    q92b %in% c(0,1) ~ "0",
    q92b %in% c(2,3,4) ~ "1"),
    longitude = as.numeric(longitude),
    latitude = as.numeric(latitude))

afro_s6$internet_use <- as.numeric(afro_s6$internet_use)
int_use_region <- afro_s6 %>%
  mutate(int_use_w = internet_use*as.numeric(withinwt)) %>%
  group_by(loc_areas_adm1) %>%
  summarise(mean_int = mean(int_use_w,na.rm=T) )

int_use_region <- merge(int_use_region, adm1_shp, by.x='loc_areas_adm1',by.y="ID_1")

int_use_region <- st_as_sf(int_use_region)

ggplot()+
  geom_sf(data = int_use_region, aes(fill = mean_int),color="white",size=.2)




