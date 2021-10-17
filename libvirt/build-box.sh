#!/bin/bash

export CD="cd"
export CP=$(which cp)
export RM=$(which rm)
export MKDIR=$(which mkdir)
export TAR=$(which tar)
export TEE=$(which tee)
export SED=$(which sed)
export VAGRANT=$(which vagrant)
export VIRSH=$(which virsh)

export LOGFILE="./alpine-brew.log"
export RELEASE_DIR="./release"

export BASEBOX="alpine/alpine64"
export VERSION_DATE_FILE="../lib/version_date.rb"
export VERSION_DATE=$(${SED} -e '/^VersionDate = "[0-9-]*"/!d' -e 's/^VersionDate = "\([0-9-]*\)"/\1/g' ${VERSION_DATE_FILE})

export VOLNAME="libvirt_alpine-brew-libvirt-${VERSION_DATE}.img"
export BOXIMG_FILE="./box.img"

export VAGRANT_ORIG_FILE="../vagrantfile-libvirt-box.rb"
export VAGRANT_FILE="./Vagrantfile"

export METADATA_ORIG_FILE="../metadata-libvirt-box.json"
export METADATA_FILE="./metadata.json"

export PACKAGE_BOX="./package-${VERSION_DATE}.box"

export PACKAGE_ORIG_JSON="../alpine-brew-libvirt-box.json"
export PACKAGE_JSON="./alpine-brew-libvirt-${VERSION_DATE}.json"

(${VAGRANT} mutate --force --input-provider virtualbox ${BASEBOX} libvirt && \
 ${VAGRANT} destroy && \
 ${VAGRANT} up 2>&1 | ${TEE} ${LOGFILE}) || exit 255

${RM} -rf ${RELEASE_DIR}
${MKDIR} -p ${RELEASE_DIR}

(${CD} ${RELEASE_DIR} && \
 ${VIRSH} vol-download --pool default --vol ${VOLNAME} ${BOXIMG_FILE} && \
 ${CP} -prv ${VAGRANT_ORIG_FILE} ${VAGRANT_FILE} && \
 ${CP} -prv ${METADATA_ORIG_FILE} ${METADATA_FILE} && \
 ${TAR} -zcvf ${PACKAGE_BOX} ${VAGRANT_FILE} ${METADATA_FILE} ${BOXIMG_FILE} && \
 ${RM} -f ${VAGRANT_FILE} ${METADATA_FILE} ${BOXIMG_FILE}) || exit 255

(${CD} ${RELEASE_DIR} && \
 ${SED} -e "s/%VERSION_DATE%/${VERSION_DATE}/g" ${PACKAGE_ORIG_JSON} > ${PACKAGE_JSON}) || exit 255
