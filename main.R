## Name: Maarten van Doornik
## Date: 16-01-2017

#download files
download.file(url='http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip',
              destfile="data/places.zip", method="auto")
download.file(url='http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip', 
              destfile="data/railways.zip", method="auto")

#unzip files
unzip('data/places.zip', exdir='data')
unzip('data/railways.zip', exdir='data')

#load libraries
library(rgdal)
library(rgeos)

#load files into workspace
places <- readOGR(dsn="data", layer="places")
railways <- readOGR(dsn="data", layer="railways")

#transform from WGS84 to RD_New (necessary to make the 1000m buffer)
prj_string_RD <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +units=m +no_defs")
places <- spTransform(places, prj_string_RD)
railways <- spTransform(railways, prj_string_RD)

#select the industrial railways
industrial_railways <- subset(railways, type=='industrial')

#make a 1000 m buffer around the industrial railways
buff <- gBuffer(industrial_railways, byid=T, width=1000)

#find the place that intersects with the buffer zone
buffplace <- gIntersection(places, buff, id=as.character(places$osm_id), byid=T)
buffplace <- places[places$osm_id == rownames(buffplace@coords),]

#plot buffer, points and the name of the city
plot(buff, col='skyblue', main="Buffer of 1000 meter around the industrial railway")
plot(buffplace, lwd=2, pch = 19, col='red', add=T)
box()
legend('bottomright', legend='1000m buffer zone', fill='skyblue')
text(buffplace@coords[1]+150, buffplace@coords[2]+100, labels=as.character(buffplace$name), cex=1.1)

#write down the name of the city and the population
paste("The name of the city is", buffplace$name, "and the population is", buffplace$population)
