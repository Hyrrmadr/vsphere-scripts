#!/bin/bash
# wrote by brunne_l (2015-09-29)

#first argument: VM name (hostname)
#second argument: number of processors to allocate
#third argument: quantity of RAM to allocate (in MB)
#forth argument: size of the disk to create (in KB)

if [ $# -lt 1 ]; then
    echo "Usage: sh $0 HOSTNAME PROC_NBR RAM_SIZE DISK_SIZE" 1>&2
    echo "Example: sh $0 splinesonic 1 512 41943040" 1>&2
    exit
fi

base_dir=.
tmp_dir=/tmp

source ${base_dir}/vm_conf.sh

# VM creation (copy from the regular one with a different SCSI controller)
conf_file="vmcreate.xml"
cp ${base_dir}/vm_templates/${conf_file} ${tmp_dir}/${conf_file}
sed -i "s/HOSTNAME/$1/" ${tmp_dir}/${conf_file}
sed -i "s/PROCNBR/$2/" ${tmp_dir}/${conf_file}
sed -i "s/RAMSIZE/$3/" ${tmp_dir}/${conf_file}
sed -i "s/DISKSIZE/$4/" ${tmp_dir}/${conf_file}
PERL5LIB=${VMWARE_PERL} ${base_dir}/perl/vmcreate-v2.pl --url ${VSPHERE_URL} --username ${VSPHERE_USER} --password ${VSPHERE_PASSWORD} --filename ${tmp_dir}/${conf_file} --schema ${VMWARE_SCHEMAS}/vmcreate.xsd
rm ${tmp_dir}/${conf_file}

# Change VM resource pool
conf_file="vmchangepool.xml"
cp ${base_dir}/vm_templates/${conf_file} ${tmp_dir}/${conf_file}
sed -i "s/HOSTNAME/$1/" ${tmp_dir}/${conf_file}
PERL5LIB=${VMWARE_PERL} ${base_dir}/perl/vmchangepool.pl --url ${VSPHERE_URL} --username ${VSPHERE_USER} --password ${VSPHERE_PASSWORD} --filename ${tmp_dir}/${conf_file} --schema ${base_dir}/vm_templates/vmchangepool.xsd
rm ${tmp_dir}/${conf_file}

# Power on VM
${base_dir}/vm_power.sh "$1" on
