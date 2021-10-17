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

export VIRTUALBOX_NAME="alpine-brew-virtualbox-${VERSION_DATE}"
export TEMP_BOX_FILE="./package-tmp.box"

export BOX_VMDK_FILE="./box-disk001.vmdk"
export BOX_OVF_FILE="./box.ovf"

export VAGRANT_ORIG_FILE="../vagrantfile-virtualbox-box.rb"
export VAGRANT_FILE="./Vagrantfile"

export METADATA_ORIG_FILE="../metadata-virtualbox-box.json"
export METADATA_FILE="./metadata.json"

export PACKAGE_BOX="./package-${VERSION_DATE}.box"

export PACKAGE_ORIG_JSON="../alpine-brew-virtualbox-box.json"
export PACKAGE_JSON="./alpine-brew-virtualbox-${VERSION_DATE}.json"

(${VAGRANT} box add --force ${BASEBOX} && \
 ${VAGRANT} destroy && \
 ${VAGRANT} up --provider virtualbox 2>&1 | ${TEE} ${LOGFILE}) || exit 255

${RM} -rf ${RELEASE_DIR}
${MKDIR} -p ${RELEASE_DIR}

(${CD} ${RELEASE_DIR} && \
 ${VAGRANT} package --output ${TEMP_BOX_FILE} ${VIRTUALBOX_NAME} && \
 ${TAR} -xvf ${TEMP_BOX_FILE} && \
 ${CP} -prv ${VAGRANT_ORIG_FILE} ${VAGRANT_FILE} && \
 ${CP} -prv ${METADATA_ORIG_FILE} ${METADATA_FILE} && \
 ${TAR} -zcvf ${PACKAGE_BOX} ${VAGRANT_FILE} ${METADATA_FILE} ${BOX_VMDK_FILE} ${BOX_OVF_FILE} && \
 ${RM} -f ${VAGRANT_FILE} ${METADATA_FILE} ${BOX_VMDK_FILE} ${BOX_OVF_FILE} ${TEMP_BOX_FILE}) || exit 255

(${CD} ${RELEASE_DIR} && \
 ${SED} -e "s/%VERSION_DATE%/${VERSION_DATE}/g" ${PACKAGE_ORIG_JSON} > ${PACKAGE_JSON}) || exit 255
