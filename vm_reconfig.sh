#!/bin/bash
# wrote by brunne_l (2015-09-28)

#first argument: VM name (hostname)
if [ $# -lt 1 ]; then
    echo "Usage: sh $0 HOSTNAME" 1>&2
    echo "Example: sh $0 splinesonic" 1>&2
    exit
fi

base_dir=.
tmp_dir=/tmp

source ${base_dir}/vm_conf.sh

host=$(${base_dir}/vm_gethost.sh "$1")

# Power off VM
${base_dir}/vm_power.sh "$1" off

# Reconfigure Network switch
conf_file="vmreconfig.xml"
cp ${base_dir}/vm_templates/${conf_file} ${tmp_dir}/${conf_file}
sed -i "s/HOSTNAME/$1/" ${tmp_dir}/${conf_file}
sed -i "s/VSPHERE_HOST/$host/" ${tmp_dir}/${conf_file}
PERL5LIB=${VMWARE_PERL} ${base_dir}/perl/vmreconfig-v2.pl --url ${VSPHERE_URL} --username ${VSPHERE_USER} --password ${VSPHERE_PASSWORD} --filename ${tmp_dir}/${conf_file} --schema ${VMWARE_SCHEMAS}/vmreconfig.xsd
rm ${tmp_dir}/${conf_file}

# Power on VM
${base_dir}/vm_power.sh "$1" on
