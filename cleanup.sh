#!/bin/bash

DSM_FILENAME=lds-wellington-city-lidar-1m-dsm-2019-GTiff
AERIAL_FILENAME=lds-wellington-010m-urban-aerial-photos-2017-JPEG

EXTERNAL_STORAGE=/mnt/sdg1/data
EXTERNAL_STORAGE_AERIAL_MOSAIC=$EXTERNAL_STORAGE/merged_aerial.tif
EXTERNAL_STORAGE_DSM_MOSAIC=$EXTERNAL_STORAGE/merged_dsm.tif

rm -rf $DSM_FILENAME
rm -rf $AERIAL_FILENAME

rm -rf retile_dsm
rm -rf retile_aerial

rm -f $EXTERNAL_STORAGE_DSM_MOSAIC
rm -f $EXTERNAL_STORAGE_AERIAL_MOSAIC
