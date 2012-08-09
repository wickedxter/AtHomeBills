@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!/usr/bin/perl
#line 15

use strict;
use warnings;


################################
#   AT Home Bills
#      Dancer style
#########
# filename: module_installion.pl - The one and only
# built: 03/24/2012
# version: 1.0.13.2
# home: https://sourceforge.net/projects/athomebills/
################################
# This is built useing dancer framework rather then
# the old style with CGI module only.
# No other dependances then Dancer and what it needed,
# going to ship athomebills buy its self for a stand alone
# web program so it can be downloaded and used like an
# GUI program.
################################

my $VERSION = 1.0.1;

############################
#this is built to give the users a way to download the needed modules
#becuase downloading and installing modules from cpan isnt easy
#for anyone who's not a perl programmer.
###########################

INSTALL_MODS();

sub INSTALL_MODS {
        print "Installing modules..\n";
        #sleep (10);
        #is perl installed first?
        #lets break down the version in to usefull parts
        my $perl_v = `perl -v` or die("Cant seem to find perl, did you install it?");
        $perl_v =~ /\(v(\d+\.\d+\.\d+)\)/; #this should get the version numbers
        my ($main, $sub, $mini) = split /\./, $1;
        
        print "Found your useing perl: v$1\n";
        
        if($sub >= 10){
            print "Perl version is good installing....\n\n";
            
            exec 'cpan Install Dancer DBD::SQLite DateTime YAML Dancer::Plugin::Database Template HTML::Calendar::Simple';
            
        }else {
            print "Sorry that perl version: $1 isn't supported, please upgrade\n";
        }
        
}
__END__
:endofperl
