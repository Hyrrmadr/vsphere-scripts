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
   state => {
      type => "=s",
      help => "The power state to set",
      required => 1,
   },
);

Opts::add_options(%opts);
Opts::parse();
Opts::validate();
Util::connect();
my %filterhash = ();

my $power_on = Opts::get_option('state') eq "on";

my $vm_views = VMUtils::get_vms('VirtualMachine',
                                   Opts::get_option('name'),
                                   undef,
                                   undef,
                                   undef,
                                   undef,
                                   %filterhash);
my $vm_view = shift (@$vm_views);

if($vm_view) {
   power_vm();
}

Util::disconnect();


# This subroutine powers on or off a virtual machine
# ==================================================
sub power_vm {
   if ($power_on) {
      eval {
         $vm_view->PowerOnVM_Task();
      };
   } else {
      eval {
         $vm_view->PowerOffVM_Task();
      };
   }

    if ($@) {
       Util::trace(0, "\nError changing power state: ");
       if (ref($@) eq 'SoapFault') {
          if (ref($@->detail) eq 'NotEnoughLicenses') {
             Util::trace(0, "Not enough licenses to power on the virtual machine\n");
          }
          elsif (ref($@->detail) eq 'FileFault') {
             Util::trace(0, "Virtual machine unreachable on the filesystem\n");
          }
          elsif (ref($@->detail) eq 'TaskInProgress') {
             Util::trace(0, "Virtual machine is busy\n");
          }
          elsif (ref($@->detail) eq 'NotSupported') {
             Util::trace(0, "Virtual machine is a template\n");
          }
          elsif (ref($@->detail) eq 'InvalidState') {
             Util::trace(0, "The operation is not allowed in the current state\n");
          }
          elsif (ref($@->detail) eq 'InvalidPowerState') {
             Util::trace(0, "Virtual machine is already in this power state\n");
          }
          elsif (ref($@->detail) eq 'VmConfigFault') {
             Util::trace(0, "Virtual machine's configuration prevents power on\n");
          }
          elsif (ref($@->detail) eq 'InsufficientResourcesFault') {
             Util::trace(0, "This operation would violate a resource usage policy\n");
          }
          elsif (ref($@->detail) eq 'DisallowedOperationOnFailoverHost') {
             Util::trace(0, "Virtual machine is a failover host\n");
          }
          else {
             Util::trace(0, "\n" . $@ . "\n");
          }
       }
       else {
          Util::trace(0, "\n" . $@ . "\n");
       }
   }
}

__END__
