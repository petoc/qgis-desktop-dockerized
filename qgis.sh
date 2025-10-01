#!/bin/bash

if [ ! -x "$(command -v docker)" ]; then
    echo "missing docker" 1>&2
    exit 1
fi

QGIS_DOCKER_TAG=3.40

DOCKER_IMAGE="qgis/qgis:${QGIS_DOCKER_TAG}"
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "x$1" = "xexec" ]; then
    docker run --rm -it \
        -u ${UID} \
        -e DISPLAY=${DISPLAY} \
        -e XDG_RUNTIME_DIR=/run/user/${UID} \
        -v /etc/passwd:/etc/passwd:ro \
        -v ${HOME}:${HOME} \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v ${HOME}/.Xauthority:${HOME}/.Xauthority \
        -v /run/user/${UID}:/run/user/${UID}:ro \
        ${DOCKER_IMAGE} \
        qgis
    exit 0
fi

SCRIPT_NAME="$(basename "$0")"
ICON_NAME="qgis.svg"
ICON_FILE="${HOME}/.local/share/icons/hicolor/scalable/apps/${ICON_NAME}"
DESKTOP_DIR="${HOME}/.local/share/applications"
DESKTOP_FILE="${DESKTOP_DIR}/qgis-desktop-dockerized.desktop"

echo "pulling docker image ${DOCKER_IMAGE}"
docker pull ${DOCKER_IMAGE}

echo "extracting icon from ${DOCKER_IMAGE}"
mkdir -p "$(dirname "${ICON_FILE}")"
docker run --rm -it ${DOCKER_IMAGE} cat "/usr/share/icons/hicolor/scalable/apps/${ICON_NAME}" > "${ICON_FILE}"
if [ $? -ne 0 ]; then
    echo "failed to extract icon" >&2
    exit 1
fi

DESKTOP_FILE_CONTENT="$(echo "[Desktop Entry]
Type=Application
Name=QGIS Desktop Dockerized
GenericName=Geographic Information System
Icon=${ICON_FILE}
TryExec=${BASE_DIR}/${SCRIPT_NAME}
Exec=gnome-terminal -- sh -c '${BASE_DIR}/${SCRIPT_NAME} exec %F'
Terminal=false
StartupNotify=false
Categories=Qt;Education;Science;Geography;
MimeType=application/x-qgis-project;application/x-qgis-project-container;application/x-qgis-layer-settings;application/x-qgis-layer-definition;application/x-qgis-composer-template;image/tiff;image/jpeg;image/jp2;application/x-raster-aig;application/x-raster-ecw;application/x-raster-mrsid;application/x-mapinfo-mif;application/x-esri-shape;application/vnd.google-earth.kml+xml;application/vnd.google-earth.kmz;application/geopackage+sqlite3;
Keywords=map;globe;postgis;wms;wfs;ogc;osgeo;
StartupWMClass=QGIS3Docker
")"

echo "$([ -f "${DESKTOP_FILE}" ] && echo -n "updating" || echo -n "creating") desktop entry ${DESKTOP_FILE}"
echo "${DESKTOP_FILE_CONTENT}" > "${DESKTOP_FILE}"

echo "updating desktop database ${DESKTOP_DIR}"
update-desktop-database ${DESKTOP_DIR}
