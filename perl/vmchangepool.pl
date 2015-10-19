#!/usr/bin/perl -w
#
# By Louis Brunner (2015-09-28) based on vmcreate.pl and vmreconfig.pl
#

use strict;
use warnings;

use lib "/usr/lib/vmware-vcli/apps/";

use VMware::VIRuntime;
use XML::LibXML;
use AppUtil::XMLInputUtil;
use AppUtil::HostUtil;
use AppUtil::VMUtil;

$Util::script_version = "1.0";

sub parse_xml;

my %opts = (
   filename => {
      type => "=s",
      help => "The location of the input xml file",
      required => 0,
      default => "vm_templates/vmchangepool.xml",
   },
   schema => {
      type => "=s",
      help => "The location of the schema file",
      required => 0,
      default => "vm_templates/vmchangepool.xsd",
   },
);

Opts::add_options(%opts);
Opts::parse();
Opts::validate(\&validate);

Util::connect();
my %reconfig_hash = parse_xml();
my %filterhash = ();

my $vm_views = VMUtils::get_vms('VirtualMachine',
                                   $reconfig_hash{Name},
                                   undef,
                                   undef,
                                   undef,
				   undef,
                                   %filterhash);
my $vm_view = shift (@$vm_views);

if($vm_view) {
   reconfig_vm();
}

Util::disconnect();


# This subroutine reconfigures a virtual machine
# ==============================================
sub reconfig_vm {
   if ($reconfig_hash{'Change-Pool'}{'Name'}) {
      my $rp_name = $reconfig_hash{'Change-Pool'}{'Name'};
      my $rp_views = Vim::find_entity_views (view_type => 'ResourcePool',
                                                 filter => {name => $rp_name});
      unless (@$rp_views) {
         Util::trace(0, "Resource pool $rp_name not found.\n");
         return;
      }

      my $rp_view = shift (@$rp_views);

      if ($rp_view) {
	 my @vms = ($vm_view);
         $rp_view->MoveIntoResourcePool(list => @vms);
      }
   }
}


sub parse_xml() {
   my %reconfig_hash = ();
   my $filename = Opts::get_option('filename');
   my $parser = XML::LibXML->new();
   my $tree = $parser->parse_file($filename);
   my $xc = XML::LibXML::XPathContext->new($tree);
   my $root = 'Reconfigure-Virtual-Machine';

   $reconfig_hash{Name} = ($xc->find("/$root/Name"))->string_value();

   # Change Pool
   $reconfig_hash{'Change-Pool'}{'Name'}
      = ($xc->find("/$root/Change-Pool/Name"))->string_value();

   return %reconfig_hash;
}


# check the XML file
# =====================
sub validate {
   my $valid = XMLValidation::validate_format(Opts::get_option('filename'));
   if ($valid == 1) {
      $valid = XMLValidation::validate_schema(Opts::get_option('filename'),
                                             Opts::get_option('schema'));
   }
   return $valid;
}

__END__
