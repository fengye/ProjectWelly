#!/bin/bash

# Prerequisity
docker pull osgeo/gdal:ubuntu-full-latest

AERIAL_FILENAME=lds-wellington-010m-urban-aerial-photos-2017-JPEG
AERIAL_FILENAME_ESCAPED=\\/home\\/$AERIAL_FILENAME\\/

SED_REPLACE="s/^/${AERIAL_FILENAME_ESCAPED}/"
# Within 8192 and based on 1 pixel : 0.1 meter
RETILE_RESOLUTION=7200

EXTERNAL_STORAGE=/mnt/sdg1/data
EXTERNAL_STORAGE_TARGET_FILE_HOST=$EXTERNAL_STORAGE/merged_aerial.tif
EXTERNAL_STORAGE_TARGET_FILE_CTNR=/data/merged_aerial.tif

if [ ! -d $AERIAL_FILENAME ]; then
	echo $AERIAL_FILENAME not found. Unzipping...
	unzip $AERIAL_FILENAME.zip -d $AERIAL_FILENAME
	sync
fi

# Generate file list
cd $AERIAL_FILENAME
ls *.jpg |  sed $SED_REPLACE > list.txt
cd ..

# Important: read UL_LR from merged DSM json
UL_X=`cat merged_dsm.json | jq -r .cornerCoordinates.upperLeft[0]`
UL_Y=`cat merged_dsm.json | jq -r .cornerCoordinates.upperLeft[1]`
LR_X=`cat merged_dsm.json | jq -r .cornerCoordinates.lowerRight[0]`
LR_Y=`cat merged_dsm.json | jq -r .cornerCoordinates.lowerRight[1]`
echo DSM dimension is upper left: $UL_X $UL_Y, lower right: $LR_X $LR_Y

if [ ! -f $EXTERNAL_STORAGE_TARGET_FILE_HOST ]; then
	echo $EXTERNAL_STORAGE_TARGET_FILE_HOST not found, merge it from original aerial photo tiles. It could take up to 10 minutes.
	docker run --rm -it -v $PWD:/home -v $EXTERNAL_STORAGE:/data osgeo/gdal:ubuntu-full-latest /bin/python3 /bin/gdal_merge.py -v -ul_lr $UL_X $UL_Y $LR_X $LR_Y -of GTiff -o $EXTERNAL_STORAGE_TARGET_FILE_CTNR --optfile /home/$AERIAL_FILENAME/list.txt
	sync
fi

# Retile
rm -rf retile_aerial
mkdir -p retile_aerial
sync
echo Retiling... Note this can take up more than 1.5 hours!
docker run --rm -it -v $PWD:/home -v $EXTERNAL_STORAGE:/data osgeo/gdal:ubuntu-full-latest /bin/python3 /bin/gdal_retile.py -v -ps $RETILE_RESOLUTION $RETILE_RESOLUTION -tileIndex tile_index -targetDir /home/retile_aerial -csv Retile.csv -csvDelim , -of png $EXTERNAL_STORAGE_TARGET_FILE_CTNR
sync

# Show geoinfo
docker run --rm -it -v $PWD:/home -v $EXTERNAL_STORAGE:/data osgeo/gdal:ubuntu-full-latest /bin/gdalinfo $EXTERNAL_STORAGE_TARGET_FILE_CTNR
