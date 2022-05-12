#### Créer un chemin d'accès : 
os.chdir('C:/Users/acastet/Dropbox/Automat_12_05/DATA/')
path = "C:/Users/acastet/Dropbox/Automat_12_05/DATA/"

### Charger des fichiers csv : 
path_afro = "file:///" + path + "afro_s6.csv" + "?encoding=%s&delimiter=%s&xField=%s&yField=%s&crs=%s" % ("UTF-8",";", "longitude", "latitude","epsg:4326")
afro_s6 = QgsVectorLayer(path_afro, "afro_s6", "delimitedtext")
iface.addVectorLayer(path_afro,'afro_s6','delimitedtext')

### Charger des données vecteurs : 
layer = iface.addVectorLayer("tun_adm2/TUN_adm2.shp", "adm2_shp", "ogr")

### Charger des données rasters : 
layer = iface.addRasterLayer("Elevation.tif", "Elevation")


### Utiliser les commandes QGIS :
# Copier-coller directement l'historique !