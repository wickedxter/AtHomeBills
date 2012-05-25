#!perl

################################
#   AT Home Bills
#      Dancer style
#########
# filename: INSTALLION.pl - installion script for athomebills
# built: 04/27/2012
# version: 0.0.1 alpha
################################
# This is built useing dancer framework rather then
# the old style with CGI module only.
# No other dependances then Dancer and what it needed
# going to ship athomebills buy its self for a stand alone
# web program so it can be downloaded and used like an
# GUI program.
################################


use strict;
use Cwd;
use YAML;
use YAML::Loader;
use DBI;
use feature qw(say);
use Carp;

#path where file is being executed from
my $base = cwd();


#################
# Date and time
#################
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



say "Welcome to AtHomeBills v1.0.9 setup v1.0.0..";

say "Base Dir: $base is being used for setup..";

#read the config.yml file
open my $FH ,"$base/config.yml" or carp("Can't find config.yml");
my $config = YAML::LoadFile($FH);


#change the database file location
$config->{plugins}{Database}{database} = "$base/db/database.sqlite";

say "Processed config.yml file and updated  the dabase location to reflect its location..";

#save the change and update the config.yml file
open my $FH2, '>', "$base/config.yml" or carp("Can't find config.yml");

print $FH2 Dump($config);

close $FH2;
close $FH;

say "Creating database....";

my $db_name = "$base/db/database.sqlite";
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_name","","") or say "Connection Failed ....";

my $new_table = 'bills_'."$months[$mon]".'_'."$year";
$dbh->do("CREATE TABLE IF NOT EXISTS $new_table (id INTEGER PRIMARY KEY AUTOINCREMENT, 
                                                                              cat TEXT,
                                                                              date_due TEXT,
                                                                              company TEXT,
                                                                              amt_due NUMERIC,
                                                                              amt_paid NUMERIC,
                                                                              date_paid TEXT,
                                                                              notes TEXT,
                                                                              chk_numb NUMERIC,
                                                                              occ NUMERIC,
                                                                              overdue NUMERIC,
                                                                              reg_amt NUMERIC)") or say "Error Creating Table\n";
say "created table $new_table";
$dbh->do("CREATE TABLE IF NOT EXISTS main_page (id INTEGER PRIMARY KEY AUTOINCREMENT, 
                                                                              date TEXT,
                                                                              title TEXT,
                                                                              posts TEXT)") or say "Error Creating Table main_page\n";
say "created table main_page";
$dbh->do("CREATE TABLE IF NOT EXISTS current_month (NOM text)") or say "Error Creating Table\n";
say "creating table companies";
$dbh->do("CREATE TABLE IF NOT EXISTS companies (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                                                  company TEXT,
                                                                                  website TEXT,)") or say "Error Creating Table\n";

my $sth = $dbh->prepare("INSERT INTO current_month ('NOM') VALUES (?) ") or say "Error updateing table current_month\n";
$sth->execute($months[$mon]);

say "created current_month";

print "Done...\n";