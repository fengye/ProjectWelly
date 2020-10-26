#!/bin/bash

# NOTE: only runs in container, for some reason it's not okay to pass the redirection operator in docker's command line thus this helper script
/bin/gdalinfo -nomd -json $1 > $2