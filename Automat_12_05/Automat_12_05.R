###########################################################################
###########################################################################
###                                                                     ###
###                             AUTOMAT #10                              ###
###                                                                     ###
###########################################################################
###########################################################################



##-------------------------------------------------------------------------
##         Qgis                                                           -
##-------------------------------------------------------------------------

#### Ajouter un fond de carte : Explorateur -> XYZ Tiles (clic droit) -> Nouvelle connexion 
# Nom -> Le nom que vous souhaitez donner.
# Url -> L'url du fond souhaité. Ce site en propose une liste : https://socalgis.org/2019/11/06/add-google-maps-to-qgis-3/


#### Accéder à la console Python : Extensions -< Console Python -> Afficher l'éditeur.



##-------------------------------------------------------------------------
##         Qgis avec Python                                               -
##-------------------------------------------------------------------------

#### Créer un chemin d'accès : 
#os.chdir('C:/Users/acastet/Dropbox/Automat_12_05/DATA/')
#path = "C:/Users/acastet/Dropbox/Automat_12_05/DATA/"

### Charger des fichiers csv : 
#path_afro = "file:///" + path + "afro_s6.csv" + "?encoding=%s&delimiter=%s&xField=%s&yField=%s&crs=%s" % ("UTF-8",";", "longitude", "latitude","epsg:4326")
#afro_s6 = QgsVectorLayer(path_afro, "afro_s6", "delimitedtext")
#iface.addVectorLayer(path_afro,'afro_s6','delimitedtext')

### Charger des données vecteurs : 
#layer = iface.addVectorLayer("tun_adm2/TUN_adm2.shp", "adm2_shp", "ogr")

### Charger des données rasters : 
#layer = iface.addRasterLayer("Elevation.tif", "Elevation")


### Utiliser les commandes QGIS :
# Copier-coller directement l'historique !



##-------------------------------------------------------------------------
##         Qgis avec R                                         -
##-------------------------------------------------------------------------

#Je mets le chemin d'accès.
setwd("C:/Users/acastet/Dropbox/Automat_12_05/DATA/")

#Je charge les packages
#install.packages("sf")
#install.packages("raster")
#install.packages("ggplot2")
#install.packages("qgisprocess")

library(sf)
library(raster)
library(ggplot2)
library(qgisprocess)


##         Chargement et projection des données.                                      -
##-------------------------------------------------------------------------

##### Données GPS des clusters tunisiens d'Afrobarometer (CSV).
#Charger le CSV
afro_s6 <- read.csv2("afro_s6.csv")

#Transformer en shapefile.
afro_s6_4326 <- st_as_sf(afro_s6, coords = c("longitude","latitude"), crs = 4326)

#Sauvegarder le shapefile.
st_write(afro_s6_4326,
         "Modif/afro_s6_4326.shp", delete_layer = TRUE, append = FALSE)

#Reprojecter le shapefile.
qgis_run_algorithm(
  "native:reprojectlayer",
   INPUT = 'Modif/afro_s6_4326.shp',
   TARGET_CRS = 'EPSG:4087',
   OPERATION = '+proj=pipeline +step +proj=unitconvert +xy_in=deg +xy_out=rad +step +proj=eqc +lat_ts=0 +lat_0=0 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84',
   OUTPUT = 'Modif/afro_s6_4087.shp'
)





##### Données des contours administratifs (SHP).
#Charger le vecteur.
adm1_shp <- st_read("tun_adm2/TUN_adm2.shp")

#Reprojecter le vecteur.
qgis_run_algorithm(
  "native:reprojectlayer",
  INPUT = "tun_adm2/TUN_adm2.shp",
  TARGET_CRS = 'EPSG:4087',
  OPERATION = '+proj=pipeline +step +proj=unitconvert +xy_in=deg +xy_out=rad +step +proj=eqc +lat_ts=0 +lat_0=0 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84',
  OUTPUT = "Modif/TUN_adm2_4087.shp" 
)

#Charger le vecteur reprojecté.
adm2_shp_4087 <- st_read("Modif/TUN_adm2_4087.shp")





##### Données de l'altitude (Tif).
#Charger le raster.
Elevation <- raster("Elevation.tif")

#Reprojecter le raster.
qgis_run_algorithm(
  "gdal:warpreproject", 
  INPUT = 'Elevation.tif',
  SOURCE_CRS = 'EPSG:4326',
  TARGET_CRS = 'EPSG:4087',
  RESAMPLING = 0,
  OUTPUT = 'Modif/Elevation_4087.tif'
)

#Charger le raster reprojecté.
Elevation_4087 <- raster("Modif/Elevation_4087.tif")







##         Traitement spatial.                                      -
##-------------------------------------------------------------------------

#Réaliser la création de la zone tampon. 
qgis_run_algorithm(
  "native:buffer",
  INPUT = 'Modif/afro_s6_4087.shp',
  DISTANCE = 10000,
  OUTPUT = 'Modif/Tampon_cluster.shp'
  )

Tampon_cluster <- st_read("Modif/Tampon_cluster.shp")


#Réaliser le calcul d'une zone statistiques. 
qgis_run_algorithm(
  "native:zonalstatisticsfb",
  INPUT = 'Modif/Tampon_cluster.shp',
  INPUT_RASTER = 'Elevation.tif',
  RASTER_BAND = 1,
  COLUMN_PREFIX = "_",
  STATISTICS = c(1,2,3,4,5),
  OUTPUT = 'Modif/Elevation_cluster.shp'
)

Elevation_cluster <- st_read("Modif/Elevation_cluster.shp")


#Réaliser le calcul d'une deuxième zone statistiques. 
qgis_run_algorithm(
  "native:zonalstatisticsfb",
  INPUT = 'tun_adm2/TUN_adm2.shp',
  INPUT_RASTER = 'Elevation.tif',
  RASTER_BAND = 1,
  COLUMN_PREFIX = "_",
  STATISTICS = c(1,2,3,4,5),
  OUTPUT = 'Modif/Elevation_district.shp'
)

Elevation_district <- st_read("Modif/Elevation_district.shp")


#Réaliser une carte.
ggplot() +
  geom_sf(data = Elevation_district, aes(fill = X_mean)) +
  scale_fill_gradient(low= "white", high = "tan4")

