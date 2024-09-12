# Apptainer in Podman

Forked from [https://github.com/kaczmarj/apptainer-in-docker.git](https://github.com/kaczmarj/apptainer-in-docker.git).

Changes with respect to the origin:
 - container build depends on apptainer release, not branch of main repository
 - instructions and hints of how to use with podman
 - script to use as alias of apptainer-build

## Aim

Original apptainer-in-docker used privileged mode or mounted docker.sock inside container. Changes were made to avoid using such methods.

## Podman

Note: Running apptainer in a container without privileged mode can be limiting, because some functionalities are disabled.

Example of building a container:
```bash
touch output.sif
podman run --rm --mount type=bind,src=$(pwd),dst=/work,ro=true \
    --mount type=bind,src=$(pwd)/output.sif,dst=/work/output.sif,ro=false \
    apptainer build --force output.sif test_alpine.def
```

This will create output.sif file in current working directory, build apptainer image inside podman container and overwrite output.sif with built apptainer image.

#### Problems with setuid
Personally I run into problems with setuid, while trying to build ubuntu apptainer using apt. There is a hack for that.
Removing `_apt` user will stop apt from using lock functionality and eliminate the need of setuid. It can be done by prepending `sed '/^_apt/d' -i /etc/passwd` before apt usage in def file.
