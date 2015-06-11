#!/bin/bash

function clone_and_update {
    set -x
    if [ ! -d "$2" ]; then
        git clone "$1"
    fi
    cd $2
    git remote update
    git checkout $3
    git pull origin $3
    cd ..
}

# Clone fresh repos
clone_and_update https://github.com/openstack/diskimage-builder.git diskimage-builder master
clone_and_update https://github.com/openstack/dib-utils dib-utils master
clone_and_update https://github.com/openstack/heat-templates heat-templates master
clone_and_update https://github.com/openstack/tripleo-image-elements.git tripleo-image-elements stable/icehouse

# Where to find dib-run-parts
export PATH="$PATH:${PWD}/dib-utils/bin"

# Where to find elements that do not come with diskimage-builder
export ELEMENTS_PATH="${PWD}/tripleo-image-elements/elements:${PWD}/heat-templates/hot/software-config/elements"

# Indicate data should come from ConfigDrive
export DIB_CLOUD_INIT_DATASOURCES="ConfigDrive"

# Indicate what release
export DIB_RELEASE="precise"

echo "Elements Path: ${ELEMENTS_PATH}"

diskimage-builder/bin/disk-image-create vm \
  ubuntu \
  heat-config \
  cloud-init-datasources \
  os-collect-config \
  os-refresh-config \
  os-apply-config \
  heat-config-cfn-init \
  heat-config-script \
 -o images/ubuntu-${DIB_RELEASE}-heat-elements.qcow2
