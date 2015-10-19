#!/bin/bash
# wrote by brunne_l (2015-09-28)

#first argument: VM name (hostname)
#second argument: power state (on or off)
if [ $# -lt 2 ]; then
    echo "Usage: sh $0 HOSTNAME [on|off]" 1>&2
    echo "Example: sh $0 splinesonic on" 1>&2
    exit
fi

base_dir=.

source ${base_dir}/vm_conf.sh

# Call power script
PERL5LIB=${VMWARE_PERL} ${base_dir}/perl/vmpower.pl --url ${VSPHERE_URL} --username ${VSPHERE_USER} --password ${VSPHERE_PASSWORD} --name "$1" --state "$2"
