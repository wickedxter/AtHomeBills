####################################
#    READ ME
####################################
#
#
#
#
#

PLEASE VISIT THE FOLLOWING SITES FOR DIRECTIONS.

INSTALLION:
http://athomebills.wordpress.com

PROBLEMS & OTHER:
https://sourceforge.net/p/athomebills/discussion/
    


REVISION:

v1.0.11.1 
	- Bill amounts now reflect the balance owed after a payment has been made.
	- Database conncurency feature this checks a list of coulmns what should have against whats in the database
	  and if any are not found they will get added to the database. (this deletes the need for most need for a database patch/fix).
	- Bill website url is now useable, when on the paybill screen click the link and pay your bill.

						
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