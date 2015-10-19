vsphere-scripts
===================

This repository contains different scripts to create, edit and manage vSphere virtual machines using **Perl**.

Copyright
---------------

The perl scripts (in the *perl/* directory) are based on **VMware, Inc.** scripts (*vmcreate.pl* and *vmreconfig.pl*).

The modifications and the rest of the scripts were made by *Louis Brunner*, licensed under MIT license.

Configuration
--------------

You must first configure your vSphere environment by editing the *vm_conf.sh* and replacing the default values with the correct ones adapted to your installation.

Usage
-------------

You must be in the scripts directory to execute them.

    ./vm_create.sh example 2 512 100000

   You can easily add more customization by adding *sed* rules in the *.sh* scripts to replace strings in the templates located in the *vm_templates /* directory (e.g. to change the datacenter of the VM).
