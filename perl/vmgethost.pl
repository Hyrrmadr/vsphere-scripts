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
   print_host();
}

Util::disconnect();


# This subroutine prints the host of a virtual machine
# ====================================================
sub print_host {
   my $host_views = Vim::find_entity_views(view_type => "HostSystem", begin_entity => $vm_view->{runtime}->{host});

   my $host_view = shift (@$host_views);

   if ($host_view) {
      print $host_view->{name} . "\n";
   }
}

__END__
