#!/bin/bash

# Prerequisity
docker pull osgeo/gdal:ubuntu-full-latest

DSM_FILENAME=lds-wellington-city-lidar-1m-dsm-2019-GTiff
DSM_FILENAME_ESCAPED=\\/home\\/$DSM_FILENAME\\/

SED_REPLACE="s/^/${DSM_FILENAME_ESCAPED}/"
# 1 pixel : 1 meter
RETILE_RESOLUTION=720

EXTERNAL_STORAGE=/mnt/sdg1/data
EXTERNAL_STORAGE_TARGET_FILE_HOST=$EXTERNAL_STORAGE/merged_dsm.tif
EXTERNAL_STORAGE_TARGET_FILE_CTNR=/data/merged_dsm.tif

if [ ! -d $DSM_FILENAME ]; then
	echo $DSM_FILENAME not found, unzipping...
	unzip $DSM_FILENAME.zip -d $DSM_FILENAME	
	sync
fi

# Generate file list
cd $DSM_FILENAME
ls *.tif |  sed $SED_REPLACE > list.txt
cd ..

# Merge into a enormous geotiff
if [ ! -f $EXTERNAL_STORAGE_TARGET_FILE_HOST ]; then
	echo $EXTERNAL_STORAGE_TARGET_FILE_HOST not found, merge it from original DSM tiles. It could take up to 1 minute.
	docker run --rm -it -v $PWD:/home -v $EXTERNAL_STORAGE:/data osgeo/gdal:ubuntu-full-latest /bin/python3 /bin/gdal_merge.py -v -of GTiff -o $EXTERNAL_STORAGE_TARGET_FILE_CTNR --optfile /home/$DSM_FILENAME/list.txt
	sync
fi

# Retile
rm -rf retile_dsm
mkdir -p retile_dsm
sync
echo Retiling...
docker run --rm -it -v $PWD:/home -v $EXTERNAL_STORAGE:/data osgeo/gdal:ubuntu-full-latest /bin/python3 /bin/gdal_retile.py -v -ps $RETILE_RESOLUTION $RETILE_RESOLUTION -tileIndex tile_index -targetDir /home/retile_dsm -csv Retile.csv -csvDelim , -of GTiff $EXTERNAL_STORAGE_TARGET_FILE_CTNR
sync

# Show geoinfo
docker run --rm -it -v $PWD:/home -v $EXTERNAL_STORAGE:/data osgeo/gdal:ubuntu-full-latest /bin/bash /home/ctnr_gdalinfojson.sh $EXTERNAL_STORAGE_TARGET_FILE_CTNR /home/merged_dsm.json
docker run --rm -it -v $PWD:/home -v $EXTERNAL_STORAGE:/data osgeo/gdal:ubuntu-full-latest /bin/gdalinfo -nomd $EXTERNAL_STORAGE_TARGET_FILE_CTNR

