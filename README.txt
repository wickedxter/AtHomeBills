####################################
#    READ ME
####

You Need perl 5.14.2.
AtHomeBills was built using 5.14.2 anything below errors will happen.

if you dont have perl use can download it from these following locations:

http://dwimperl.com/ - this has the needed modules...(Dancer, DateTime, DBD::Sqlite) 
http://activestate.com/ - you'll have to download the dependencies that are below
http://strawberryperl.com/ - you'll have to download the dependencies that are below


Dependencies (Modules not included in downloading perl from links above, these have to be install seperate):

(install the newest version)

Dancer
Dancer::Plugin::Database
DateTime
DBD::Sqlite
YAML

Make sure that these modules are install first before going any futher.

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
    