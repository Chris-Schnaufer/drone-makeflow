#!/bin/bash

WORKING_DIR=`pwd`

# Copy the files to where we want them to be
echo "Copying source files from current folder (${WORKING_DIR}) to target location"
mkdir -p /scif/data/odm_workflow/images/
cp -v ./* /scif/data/odm_workflow/images/
mkdir -p /input
mkdir -p /output

# Discover the image file and the plot shapes file
echo "Discovering source image file and possible plot shapes file (.shp, or .json)"
SOURCE_IMAGE=""
PLOT_SHAPE=""
for ONE_FILE in `find "${WORKING_DIR}" -type f`
do
  case "${ONE_FILE: -4}" in
  ".tif" | ".tiff")
    SOURCE_IMAGE="${ONE_FILE}"
    ;;
  ".shp" | ".json")
    PLOT_SHAPE=${ONE_FILE#"$(dirname ${ONE_FILE})/"}
    ;;
  esac
done

# Determine if there's a URL in the command line if there isn't a file
if [[ "${PLOT_SHAPE}" == "" ]]; then
  echo "Searching parameters for BETYdb URL"
  for ONE_PARAM in "${@}"
  do
    if [[ "${ONE_PARAM:0:4}" == "http" ]]; then
      PLOT_SHAPE="${ONE_PARAM}"
    fi
  done
fi

# Get the desired file name format for the image
echo "Manipulating image file name for processing: ${SOURCE_IMAGE}"
if [[ "${SOURCE_IMAGE}" != "" ]]; then
  BASE_NAME=${SOURCE_IMAGE#"$(dirname ${SOURCE_IMAGE})/"}
  echo "  BASE NAME: ${BASE_NAME}"
  SOURCE_IMAGE=${BASE_NAME%.*}
  echo "  final: ${SOURCE_IMAGE}"
fi

# Run the command
echo "Running short workflow with image and plot shape source: \"${SOURCE_IMAGE}\" and \"${PLOT_SHAPE}\" "
scif run short_workflow "${SOURCE_IMAGE}" "${PLOT_SHAPE}"

# Copy the results back to where they'll get picked up
cp -r /output/* "${WORKING_DIR}/"
