####################################
#    READ ME
####

YOU NEED PERL INSTALLED !
v5.14.2 was the dev. platform. anything under 5.10 use at own risk and report and problems.

if you dont have perl use can download it from these following locations:

http://dwimperl.com/ - this has the needed modules...(Dancer, DateTime, DBD::Sqlite) 
http://activestate.com/ - you'll have to download the dependencies that are below
http://strawberryperl.com/ - you'll have to download the dependencies that are below


Dependencies (Modules not included in downloading perl from links above, these have to be install seperate):

Dancer Framework
DateTime
DBD::Sqlite
HTML::Calendar::Simple (Included in zip)


WIN32: INSTALLION.bat

1) Run the INSTALLION.pl script which sets up the config.yml file to reflect
    the directory which it resides. Also setup's the database file in the folder ./db/database.sqlite
    
2) WIN32:
    Run the athomebills.bat file and then you can use what ever broswer and point it to:    localhost:3000

    *NIX:
    Run/execute the athomebills.pl file in command prompt.
    Check to make sure the script points to the correct perl. It's defaulted with #!/usr/bin/perl
    
thats it enjoy.....

    
IF YOU HAVE ANY PROBLEMS LEAVE A MESSAVE IN THE FOURMS AT: https://sourceforge.net/p/athomebills/discussion/
    