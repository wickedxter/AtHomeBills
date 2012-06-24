#!Perl

use strict;
use warnings;


################################
#   AT Home Bills
#      Dancer style
#########
# filename: module_installion.pl - The one and only
# built: 03/24/2012
# version: 1.0.10
# home: https://sourceforge.net/projects/athomebills/
################################
# This is built useing dancer framework rather then
# the old style with CGI module only.
# No other dependances then Dancer and what it needed,
# going to ship athomebills buy its self for a stand alone
# web program so it can be downloaded and used like an
# GUI program.
################################

my $VERSION = 1.0.0;

############################
#this is built to give the users a way to download the needed modules
#becuase downloading and installing modules from cpan isnt easy
#for anyone who's not a perl programmer.
###########################

INSTALL_MODS();

sub INSTALL_MODS {
        print "Installing modules..\n";
        sleep (10);
        #is perl installed first?
        #lets break down the version in to usefull parts
        my $perl_v = `perl -v` or die("Cant seem to find perl, did you install it?");
        $perl_v =~ /\((.*)\)/; #this should get the version numbers
        my ($main, $sub, $mini) = split /\./, $1;
        
        print "Found your useing perl: $1\n";
        
        if($sub > 10){
            exec 'cpanm --Install Dancer DBD::SQLite DateTime YAML Dancer::Plugin::Database Template';
        }else {
            print "Sorry that perl version: $1 isn't supported, please upgrade\n";
        }
        
        
}