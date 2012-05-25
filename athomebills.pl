#!perl


use Cwd;
use lib qw(cwd());
use strict;
use warnings;
use DateTime;
use Dancer;
use Dancer::Plugin::Database;
use Dancer::Exception qw(:all);
use HTML::Calendar::Simple;


################################
#   AT Home Bills
#      Dancer style
#########
# filename: athomebills.pl - The one and only
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

#Register Expections
#Load_Exp();

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


my $mon2 = $mon  =~ /\d{2}/ ? $mon : '0'.$mon; # this makes 2 to 02
my $mday2 = $mday =~ /\d{2}/ ? $mday : '0'.$mday; # this makes 2 to 02



my $today_date = "$days[$wday]" . ", " . "$months[$mon] " . $mday . ", " . $year;
my $am_pm = ($hour ge 12) ? 'pm' : 'am';

#since hours is in miliary time correct
$hour -= 12 if $hour > 12;

my $today_time = $hour . ":" . $min . ":" . $sec;

my $whole_date = $today_date . ' ' . $today_time;

my $search_date = $year . $mon2 . $mday2;

my $cal = HTML::Calendar::Simple->new;

my $int_date = $year . $mon2;
#Since the calendar module doesnt allow customization had to add CSS
    #to match the layouts
my $changed = $cal->calendar_month;
    $changed =~ s/\>$mday\</\>\<font class\=calender_current_day\>\>$mday\<\<\/font\>\</;
    
################
# End of date comp
################




###############
# Routes for dancer
###############
#where to travel? do we need a GPS? whos got the snacks?

###########
# Main Page Route 
get '/' => sub {
    
    ################
    #Handle new month roll-over
    #This goes thew the database resting bills for the new month
    # or adding to the unpaid bills.
    ################
    my $newMonth = CheckForNewMonth($mon);

    
    
    
    template 'main_page', {
        'todays_date' => $whole_date,
        'upcomming' => get_bills('upcomming'),
        'over_due' => get_bills('over_due'),
        'calander' => $changed,
        'News' => get_news(),
    },{ layout => undef };


};
###########
# Add Page
get '/addBills' => sub {
    
    
    
    template 'addBills_page' => {
        'todays_date' => $whole_date,
         'calander' => $changed,
         'cats' => Get_Categories(),
         'int_date' => $int_date,
    },{ layout => undef };
};
###########
# Edit Page
get '/EditBillsViewAll' => sub {
    
        my $table = current_month_table();
        my  $dbh = database->prepare("SELECT id,company,date_due  FROM $table ORDER BY id");
        
        $dbh->execute();
         
        my $bill_view_all = $dbh->fetchall_hashref('id');


        template 'edit_page',{
            'todays_date' => $whole_date,
            'AllBills' => $bill_view_all,
            'calander' => $changed,
        },{layout => undef};    
};
##########
#ViewBill/<company>
get '/ViewBill/:company' => sub {
            my $table = current_month_table();
         my $company =  params->{company};
         
        my  $dbh = database->prepare("SELECT *  FROM $table WHERE company = ? LIMIT 1");
        
        $dbh->execute($company);
         
        my $bill_values = $dbh->fetchall_hashref('id');
        my @bkey =  keys $bill_values;

        
         template 'bill_view',{
           # 'mykey' => $bkey[0],
            'calander' => $changed,
            'todays_date' => $whole_date,
            'company2' => $company,
            'company' => $bill_values->{$bkey[0]}{'company'},
            'cat' => $bill_values->{$bkey[0]}{'cat'},
            'amt_due' => $bill_values->{$bkey[0]}{'amt_due'},
            'amt_paid' => $bill_values->{$bkey[0]}{'amt_paid'},
            'date_due' => $bill_values->{$bkey[0]}{'date_due'},
            'notes' => $bill_values->{$bkey[0]}{'notes'},
            'occ' => $bill_values->{$bkey[0]}{'occ'},
            'reg_amt' => $bill_values->{$bkey[0]}{'reg_amt'},
            'cats' => Get_Categories(),
            'int_date' => $int_date,
            
        },{layout => undef};  

};
##########
#Search
post '/search' => sub {
     my $search = params->{search};
     
    template 'search',{
            'todays_date' => $whole_date,
            'searching' => $search,
            'data' => search_bills($search),
             'calander' => $changed,
    },{layout => undef};
       
};
##########
#SaveBillInfo
post '/SaveBillInfo' => sub {
    my $category;
    
    #check table for existance of company name
    my $company_check = CheckDBExists(params->{company});
    
    if(!$company_check){
        my $table = current_month_table();
        #db order: cat date_due company amt_due amt_paid date_paid notes chk_num occ overdue reg_amt    
        my  $dbh = database->prepare("INSERT INTO $table (cat,date_due,company,amt_due,
                                                                                      amt_paid,date_paid,notes,chk_numb,
                                                                                      occ,overdue,reg_amt) VALUES (?,?,?,?,?,?,?,?,?,?,?)");
            
             $category =   params->{cat} if params->{cat} and !params->{cat_other};
             $category =   params->{cat_other} if params->{cat_other} and !params->{cat};
             
             #Some SQL statements require that some data not be null have to set it to 0
            #the 0 here is the amt_paid since its just been added set it to 0
        
            $dbh->execute($category,params->{date_due},
                                    params->{company},params->{amt_due},
                                    0,params->{date_paid},
                                    params->{notes},params->{chk_num},
                                    params->{occ},params->{overdue},
                                    params->{reg_amt_due});
        
        my $company = params->{company};
        my $date_due = params->{date_due};
        WriteMainPage("Bill $company Added","the bill has been added and is due on the $date_due .");
        return redirect '/';
    }else {
        return redirect '/addBills';
    }
    
};
post '/SaveBillChanges/:companyName' => sub {
        my $table = current_month_table();
    
    # Some reason when doing updates its not pulling the params from dancer, odd...
        my $category;
        my $companyName = params->{companyName};
        
        $category = exists params->{cat} ? params->{cat} : params->{cat_other};
        my $due_date = params->{due_date}, ;
        my $name = params->{name};
        my $amt_due = params->{amt_due};
        my $amt_paid = params->{amt_paid};
        my $notes = params->{notes};
        my $chk_num = params->{chk_numb};
        my $occ = params->{occ};
        my $overdue = params->{overdue};
        my $reg_amt = params->{reg_amt};
        my $date_paid = params->{date_paid};
        
        my  $dbh = database->prepare("UPDATE $table SET cat=?,
                                                                                    date_due=?,
                                                                                    company=?,
                                                                                    amt_due=?,
                                                                                    amt_paid=?,
                                                                                    date_paid=?,
                                                                                    notes=?,
                                                                                    chk_numb=?,
                                                                                    occ=?,
                                                                                    overdue=?,
                                                                                    reg_amt=? WHERE company = ?");
        
        $dbh->execute($category,$due_date,$name,$amt_due,$amt_paid,$date_paid,$notes,$chk_num,$occ,$overdue,$reg_amt,$companyName);
        
        WriteMainPage("Changed Bill info","Changes to $companyName have been saved");
        return redirect '/';
        
};
###########
#ViewAll
get '/ViewAll' => sub {
        template 'view_all_bills',{
            'todays_date' => $whole_date,
            'calander' => $changed,
            'pass_all' => get_bills_all(),
            
    },{layout => undef};                
};
###########
#ViewLastMonth
get '/ViewLastMonth' => sub {
    
        template 'last_month',{
            'todays_date' => $whole_date,
            'calander' => $changed,
        },{layout => undef};     
};

get '/PayBill/:name' => sub {
        my $table = current_month_table();
    
    
        my $BillName = params->{name};
        my  $dbh = database->prepare("SELECT *  FROM $table WHERE company = ? LIMIT 1");
        $dbh->execute($BillName);
    
        my $bills = $dbh->fetchall_hashref('id');
        my @bkey =  keys $bills;
    
        template 'PayBill_INFO',{
            'todays_date' => $whole_date,
            'calander' => $changed,
            'company' => $bills->{$bkey[0]}{company},
            'date_due' => $bills->{$bkey[0]}{date_due},
            'amt_due' => $bills->{$bkey[0]}{amt_due},
            'amt_paid' => $bills->{$bkey[0]}{amt_paid},
        },{layout => undef};  
};
post '/SavePayment' => sub {
        my $table = current_month_table();
    
        #Sqlite -> DBI was complaning so I had to save the variables
        my $paid = params->{amt_paying};
        my $chk = params->{chk_num};
        my $notes = params->{notes};
        my $comp = params->{bill_co};
        
       my $dbh = database->prepare("UPDATE $table SET amt_paid = amt_paid + ?,chk_numb = ?,notes=? WHERE company = ?");
        
        $dbh->execute($paid,$chk,$notes,$comp);
        
        WriteMainPage("Bill Paid","Bill $comp has been paid in the ammount of $paid");
        return redirect '/';
        
};
###########
#Help
get '/Help' => sub {
    template 'help',{
            'todays_date' => $whole_date,
             'calander' => $changed,
    },{layout => undef};   
};    

###############
# Confirm Deletion of bill
get '/ConfirmDel/:coname' => sub {
    
    my $company = params->{coname};
    
    template 'confirm_del',{
            'todays_date' => $whole_date,
             'calander' => $changed,
             'co_name' => $company,
    },{layout => undef};   
};

###############
# Deletion of bill
get '/DeleteBill/:company' => sub {
    
    #access the bills company name from route
    my $company = params->{company};
    
    #get the current month table from Database
    my $table = current_month_table();
    
    my $del = database->prepare("DELETE FROM $table WHERE company = ?");
    $del->execute($company);
   
   #write news to main page
   WriteMainPage("Bill Deleted","Bill $company has been DELETED");
   
   return redirect '/';
};


#let dancer do its thing
Dancer->dance;



##########################
#
# SUBRUTINES
#
############

sub Load_Exp {
    
    #register_exception('NoPermission',
      #              message_pattern => "not enough permission: %s"
       #           );
}

#-----------------------------------------------------------------------
# current_month_table();
#-----------------------------------------------------------------------
#
# returns the table name for the table for the current monthy bills.
#
#-----------------------------------------------------------------------
sub current_month_table {
    my $table_name = 'bills_'."$months[$mon]".'_'."$year";
    return $table_name;
}

#-----------------------------------------------------------------------
# CheckDBExists(<company name>);
#-----------------------------------------------------------------------
#Supplied user info from adding bill page
#
# Checks aginst the current monthly table for the existance
# of the company name (No dupe company names allowed)
#
#returns 1 if exists and 0 for !exists
#-----------------------------------------------------------------------
sub CheckDBExists {
    my $co_name = shift;
    
    my $table_name = current_month_table();
    
    my $dbh = database->prepare("SELECT company FROM $table_name ");
          $dbh->execute();
          
          #check for the return of a matching company name
    while (my @companies = $dbh->fetchrow_array()){
        for(@companies){
            if($_ =~ /$co_name/i){
             WriteMainPage("Debug","CheckDBExists $co_name exists chooze anouther company");
                return 1;
            }
        }
        
    }   
    return 0; 
}

#-----------------------------------------------------------------------
# CheckForNewMonth(<current month>);
#-----------------------------------------------------------------------
#<current month> is the NAME of the month not diget form.
#also not abbrivations fully spelled NAMES.
#
# This is called everytime the main page is loaded.
# It compares the moth stored in the database and current month
# if it has changed it cycles threw the bills roll-overing and what not
#
#return 1
#-----------------------------------------------------------------------
sub CheckForNewMonth {
    my $current_month = shift;
    my $named_current_month = $months[$current_month];
    
    my $dbh = database->prepare("SELECT NOM FROM current_month");
    $dbh->execute();
    
    my $month_NOM = $dbh->fetch();
    chomp @$month_NOM;
    #WriteMainPage("Debug","$named_current_month &  @$month_NOM");
    
    #if the month has changed roll-over the bills
    if( $named_current_month =~ /@{$month_NOM}/){
        return 1;
    }else {
            #change the old month to the new month
           my $prep_NOM=  database->prepare("UPDATE current_month SET NOM = ?");
                $prep_NOM->execute($named_current_month);
                
            my $new_table = 'bills_'."$named_current_month".'_'."$year";
            #create new table for new month
            database->do("CREATE TABLE IF NOT EXISTS $new_table (id INTEGER PRIMARY KEY AUTOINCREMENT, 
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
                                                                              reg_amt NUMERIC)");
            
            
            #create the name of the table for last month
            my $old_month = 'bills_'."$months[$mon-1]".'_'.$year;
            
            #check to make sure an earlier month exists
            my $db_check = database->do("SELECT * FROM sqlite_master WHERE name =$old_month and type='table' ");
            my $check = $db_check->fetch();
            
            #return back because the table doesnt exist
            return if $check == 0;
            
            #if table exists cont.
            my $dbh2 = database->prepare("SELECT * FROM $old_month");
            $dbh2->execute();
            
            #now lets cycle threw the bills for the new month
            while(my(@rows) = $dbh2->fetchrow_array()){
                
                #dancer is complaning about this feild being null
                $rows[11] = 0 if !exists $rows[11] or !defined $rows[11];
                
                if($rows[9]){ #reoccuring bill
                    my ($amount_left,$rollover_amt);
                    
                    #detremine if any will be owed next month or not
                    if($rows[4] ne $rows[5]){ #amt_due and amt_paid check
                        #subtract if amt_due doesnt match amt_paid this will add to next month on top of the reg_amt
                        $amount_left = $rows[4] > $rows[5] ? $rows[4] - $rows[5] : $rows[5] - $rows[4] ;
                        $rollover_amt = $amount_left + $rows[11];
                    }else {#if paid full zero these out
                        $amount_left=0;
                        $rollover_amt= $rows[11];
                    }
                    
                    #OLD DB:      cat               0                NEW DB:         id
                    #                   date_due      1                              cat
                    #                   id                  2                              date_due
                    #               company           3                              company
                    #           amt_due              4                               amt_due
                    #               amt_paid         5                               amt_paid
                    #               date_paid         6                              date_paid
                    #               notes                7                               notes
                    #               chk_numb        8                                chk_numb
                    #               occ                  9                               occ
                    #               overdue          10                                   overdue
                    #               reg_amt         11                                reg_amt
                    
                    
                    #need to change the due date to reflect new month
                    #                       year     month  day
                    $rows[1] =~ /(\d{4})(\d{2})(\d{2})/;
                    my $new_due_date = $1 . $mon2 . $3;
                    
                    my $int1 = database->prepare("INSERT INTO $new_table (cat,date_due,company,amt_due,amt_paid,date_paid,notes,chk_numb,occ,overdue,reg_amt) VALUES (?,?,?,?,?,?,?,?,?,?,?)");
                    $int1->execute($rows[0],$new_due_date,$rows[3],$rollover_amt,'0','0',$rows[7],$rows[8],$rows[9],$rows[10],$rows[11]);
                    #non-reoccuring bill
                }else {
                    #calulate if any was paid (making sure me dont make an negative ammount)
                    my $amout_left = $rows[4] > $rows[5] ? $rows[4] - $rows[5] : $rows[5] - $rows[4] ;
                    
                    #if there's still an ammount then roll-over
                    if($amout_left){
                        #change the old month to the new month
                        $rows[1] =~ /(\d{4})(\d{2})(\d{2})/;
                        my $new_due_date1 = $1 . $mon2 . $3;
                        
                        my $int2 = database->prepare("INSERT INTO $new_table (cat,date_due,company,amt_due,amt_paid,date_paid,notes,chk_numb,occ,overdue,reg_amt) VALUES (?,?,?,?,?,?,?,?,?,?,?)");
                            $int2->execute($rows[0],$new_due_date1,$rows[3],$amout_left,'0','0',$rows[7],$rows[8],$rows[9],$rows[10],$rows[11]);
                    }else {
                        #if this bill has been paid and not reoccurring skip it
                        next;
                    }
                    
                }
            }
    WriteMainPage("A New Month","Great a new month has started and your bills have rolled-over and ready.");       
    }
    
}


#-----------------------------------------------------------------------
# Get_Categories();
#-----------------------------------------------------------------------
#
# This returns a list of categories to choose from to categories the bills.
# 
#
#-----------------------------------------------------------------------
sub Get_Categories {
    
    my @cats = ('Power', 'Mortage/Rent', 'Car/Truck Note', 'Car/Truck Insurance', 'Credit Card1', 'Credit Card2',  'Natural Gas', 'Phone', 'Student Loan','Water Bill');
    
    return \@cats;
}
#-----------------------------------------------------------------------
# WriteMainPage("<title>","<Message>");
#-----------------------------------------------------------------------
#
# This posts information to the main page to notify you of changes that have
# been made and when. System messages are posted as well. The date is
# automaticly added.
#
#-----------------------------------------------------------------------
sub WriteMainPage {
    my $title = shift;
    my $message = shift;
    my $posted = 'Posted on ' . $today_date;
    
    my $dbh = database->prepare("INSERT INTO main_page (date,title,posts) VALUES (?,?,?)");
    $dbh->execute($posted,$title,$message);
    
    return 1;
}
#-----------------------------------------------------------------------
# get_news();
#-----------------------------------------------------------------------
#
# Returns the current news items that are shown on the main page
# 25 posts limit
#
#-----------------------------------------------------------------------
sub get_news {
    
    my $dbh2 = database->prepare("SELECT count( * ) as id FROM main_page");
     $dbh2->execute();
    my $total = $dbh2->fetch();
    
    my $range = @$total - 25;
    
    my  $dbh = database->prepare("SELECT *  FROM main_page WHERE id BETWEEN ? AND ? ORDER BY id");
        
    $dbh->execute($range, @$total);
    
        
    return $dbh->fetchall_hashref('id');
}
#-----------------------------------------------------------------------
# search_bills("<text>");
#-----------------------------------------------------------------------
#
#  database access for search returns matches
#
#-----------------------------------------------------------------------
sub search_bills {
    my $search = shift;
    
    my $table = current_month_table();
    my  $dbh = database->prepare("SELECT id,company  FROM $table WHERE lower(company) LIKE '$search%'");
        
    $dbh->execute();
    
        
    return $dbh->fetchall_hashref('id');
}

#-----------------------------------------------------------------------
# get_bills_all();
#-----------------------------------------------------------------------
#
# returns everything in the bills table
#
#-----------------------------------------------------------------------
sub get_bills_all {
    
    #my $date_start = $year . $mon2 . '01';
   # my $date_end = $year . $mon2 . '31';
    
    my $table = current_month_table();
    my  $dbh = database->prepare("SELECT * FROM $table");
        
    $dbh->execute();
    
        
    return $dbh->fetchall_hashref('id');
    
}

#-----------------------------------------------------------------------
# get_bills(<which>);
#-----------------------------------------------------------------------
#
# upcomming or overdue 
# access the database and returns <$which> the bills 
#
#-----------------------------------------------------------------------
sub get_bills {
    my $which = shift;


    my $dt = DateTime->new(year    => $year,
                                            month => $mon,
                                            day     => $mday,);
    
    my $table = current_month_table();
    
    if($which eq 'upcomming'){
        
        my $saved;
        my $todays = DateTime->now();
        $todays =~ /(\d{4})-(\d+)-(\d{2})/;
        
        my $coverted_today = $1 . $2 . $3;
    
       my $projected_date = $dt->add( days => 10 ) ;
    #dateTime module returns an odd format so filter it to whats needed...2012-02-21T01:45:00PM (FORMAT)
        $projected_date =~ /(\d{4})-(\d+)-(\d{2})/;
    #                                       year   mon  mday
       #$saved = $1 . '0' . $2 . $3 if $2 =~ /^\d{1}$/;
       $saved = $1 . $2 . $3 ;

       
        # = selectrow_hashref('SELECT company, amt_due, date_due FROM bills WHERE due_date = ?', undef, $saved_date);
       my  $dbh = database->prepare("SELECT id,company,date_due,amt_due,amt_paid  FROM $table  where date_due between $coverted_today and $saved AND amt_paid < amt_due");
        
        $dbh->execute();
    

        return $dbh->fetchall_hashref('id');

        
    }elsif($which eq 'over_due'){
    
        
        my $dbh = database->prepare("SELECT  id,company,date_due,amt_due,amt_paid FROM $table WHERE  date_due <  ? AND amt_due > amt_paid");
    
        
         $dbh->execute($search_date);
    
        return $dbh->fetchall_hashref('id');

    }
}

1;
=head1 NAME

AtHomeBills.pl - Main script for Bills @ Home

=head1 SYNOPSIS

  Built useing the dancer framework it has its own server
  

=head1 DESCRIPTION

Basic functionality (for now) this helps you keep up with your
bills from month to month, but doesnt have to be just bills.


=back

=head1 AUTHOR

Aaron Yorkovitch (wickedxter@gmail.com)

=head1 COPYRIGHT

Copyright 2012. 

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 Dependant

Dancer Framework 
DateTime 
DBD::Sqlite 
HTML::Calendar::Simple 

=cut