# ProjectWelly
Converting LINZ GIS data to Unreal Engine usable landscape tile

## Prerequisities
- Linux OS
- Docker
- apt install jq (for Shell parsing .json files)
- Compiled geotiff2raw16 toolkit, which is submoduled in this repo

## Getting the Data
- Go to LINZ website: https://data.linz.govt.nz/
- Download DSM/DEM data, the one I used is https://data.linz.govt.nz/layer/105024-wellington-city-lidar-1m-dsm-2019/, download GeoTIFF as format and copy to this directory
- Download satellite image or aerial image data, the one I used is https://data.linz.govt.nz/layer/95524-wellington-010m-urban-aerial-photos-2017/, download JPEG as format and copy to this directory
- You might want to change the filename defined at the top of `run_merge_aerial.sh` and `run_merge_dsm.sh`

## Running the Data
- As current approach uses gdal_merge to create a giant mosaic image to align DSM and colour map, it needs a decent amount of disk space. Prepare your hard drive and modify `EXTERNAL_STORAGE` in `run_merge_aerial.sh` and `run_merge_dsm.sh`. The mosaic of those data will be around 105GB and 1.4GB respectively.
- `./run_merge_dsm.sh # will create DSM mosaic and retile it into 720x720 tiles`
- `./run_merge_aerial.sh # will create aerial image mosaic and retile it into 7200x7200 tiles`
- `./run_conv_dsm.sh # will convert retiled .tif(GeoTIFF) into .r16 format which uses 16bit integers`
- `./cleanup.sh # will cleanup all the generated files except downloaded data zips`

## Importing into Unreal Engine 4
