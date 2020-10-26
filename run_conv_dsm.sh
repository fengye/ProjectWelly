#!/bin/bash

cd retile_dsm
for file in *.tif
do
	~/Projects/geotiff2raw16/gtiff2r16 -i $file -o $file.r16
done
cd ..
sync
