# QGIS Desktop Dockerized

Dockerized QGIS desktop application.

## Requirements

To use this script, Docker Engine has to be installed.

## Compatibility

Used only on Ubuntu 22.04. In other environments it may need some tweaking.

## Usage

```sh
./qgis.sh
```

Script will pull QGIS docker image and create application desktop entry pointing to this script.

> [!NOTE]
> Desktop entry has to be recreated every time script is moved to different path.

> [!IMPORTANT]
> Only user home directory `$HOME` is mounted to docker container, so any saving should be done there.

## License

Licensed under MIT License.
