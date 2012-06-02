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


REVISION:
						
v1.010.3
	-= Worked fixing the bugs that poped up for Perl 5.10
	-= Once new month rolled around the bills didnt roll-over, it should be fixed across the bord. Ill roll out a database fix.
	-= Moved the HTML::Calendar::Simple in to the ' lib ' folder since now useing Find::Bin module.
	-= Tested with perl v5.16 and no problems.
						
v1.010<br />
	-= Added a function to delete bills

v1.09.2<br />
	-= Bug was found in the installion script that created the database and populated it.
	-= Occurance is now a drop down box with Yes or No selections rather then and empty input box
					
v1.09<br />
	-= Rewrote it to use Dancer framework, new layout and 
	    new features. Search and the calendar. Also switched 
	    from a flat-file database to SQLite database. Even tho its a rewrite I still have
	    alot of reimplamentation of behind the seane functions to match what was from
	    the older versions.<br />
						
						
v1.0.0 - v 1.0.8<br />
	This was the old version (unsupported)