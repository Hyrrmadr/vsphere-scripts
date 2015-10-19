#!/usr/bin/perl -w
#
# By Louis Brunner (2015-09-28) based on vmcreate.pl and vmreconfig.pl
#

use strict;
use warnings;

use lib "/usr/lib/vmware-vcli/apps/";

use VMware::VIRuntime;
use AppUtil::HostUtil;
use AppUtil::VMUtil;

$Util::script_version = "1.0";

sub parse_xml;

my %opts = (
   name => {
      type => "=s",
      help => "The name of the virtual machine",
      required => 1,
   },
);

Opts::add_options(%opts);
Opts::parse();
Opts::validate();
Util::connect();
my %filterhash = ();

my $vm_views = VMUtils::get_vms('VirtualMachine',
                                   Opts::get_option('name'),
                                   undef,
                                   undef,
                                   undef,
                                   undef,
                                   %filterhash);
my $vm_view = shift (@$vm_views);

if ($vm_view) {
   query_hardware();
}

Util::disconnect();


# This subroutine queries the hardware of a virtual machine
# =========================================================
sub query_hardware {
   no warnings 'uninitialized';
   my $devices = $vm_view->config->hardware->device;
   foreach my $device (@$devices) {
      print $device->deviceInfo->label;
      print " [" . ref($device) . "]";
      print " - (";
      if (ref($device->backing) eq 'VirtualEthernetCardDistributedVirtualPortBackingInfo') {
	 print $device->backing->port->portKey . " - " . $device->backing->port->portgroupKey . " - {" . $device->backing->port->switchUuid . "} ";
      }
      print "[" . ref($device->backing) . "]";
      print ")";
      print " - [" . $device->key . ", " . $device->unitNumber . ", " . $device->controllerKey . "]";
      print " - " . $device->deviceInfo->summary;
      print "\n";
   }
}

__END__
