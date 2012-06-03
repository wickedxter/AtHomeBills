#!Perl


##############################
#
# This is a database patch that resets the table "current_month"
# and sets the NOM to the last month.
#
# IF YOU DIDNT INSTALL AND USE ANY VERSION BELOW v1.0.10.3 YOU WILL BE FINE.
# ANYTHING BELOW YOU WILL NEED TO USE THIS PATCH.
#
########


use Cwd;
use strict;
use warnings;
use Dancer;
use Dancer::Plugin::Database;


#######################
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$mon += 1;
#$mday -= 1;
#$wday -= 1;
#date months
my @months = ('', 'January', 'Febuary', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
#date weekdays
my @days = qw(Sunday Monday Tuesday Wednsday Thrusday Friday Saturday);
# fix year
$year += 1900;
#########################

#get base directory
my $base = cwd();
my $db = "$base/db/database.sqlite";
my $file_chk = 0;

print "ONLY USE THIS IF YOU HAVE INSTALLED VERSION OF ATHOMEBILLS BELOW 1.0.10.3 AND HAVE USED IT. YOU MUST RUN THIS PATCH BEFORE RUNNING
THE VERSION V1.0.10.3 OR YOU MIGHT END UP WITH DUPELICATES.\n";
print "\n this will reset the the table current_month and alter NOM back to last month.\n";


#check for database file
$file_chk = 1 if(-e "$db");
    

if($file_chk){
    print "\nAre you sure you want to alter the table(y or n): ";

    my $Y_or_N = <>;
    chomp $Y_or_N;
    
    if($Y_or_N eq "y" or $Y_or_N eq "yes"){
    print "\n Plz wait while the table is being altered... \n";
       #get the last month 
          my $reset_month = $months[$mon-1];
    
          my   $prep_NOM=  database->prepare("UPDATE current_month SET NOM = ?");
                $prep_NOM->execute($reset_month);
            
          my $set_new_month = 'bills_'.$months[$mon]."_$year";        
               #this drops the table because some times it makes dupeicates
                database->do("DROP TABLE $set_new_month");
    
     print "\n done\n exiting....";
    }else {
      exit;
    }
}else {
    print "Sorry can't locate the database file in $base/db/database.sqlite";
    exit;
}

1;