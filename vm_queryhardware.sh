#!/bin/bash
# wrote by brunne_l (2015-09-28)

#first argument: VM name (hostname)
if [ $# -lt 1 ]; then
    echo "Usage: sh $0 HOSTNAME" 1>&2
    echo "Example: sh $0 splinesonic" 1>&2
    exit
fi

base_dir=.

source ${base_dir}/vm_conf.sh

# Call query hardware script
PERL5LIB=${VMWARE_PERL} ${base_dir}/perl/vmqueryhardware.pl --url ${VSPHERE_URL} --username ${VSPHERE_USER} --password ${VSPHERE_PASSWORD} --name "$1"
