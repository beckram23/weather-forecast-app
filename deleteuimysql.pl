#!C:\strawberry\perl\bin\perl.exe -w

use CGI qw(:standard);
use DBI;
use strict;
use warnings;

print "Content-type: text/html \n\n";

#MYSQL CONFIG VARIABLES
my $host = "";
my $databasename = "";
my $tablename = "";
my $user = "";
my $pw = "";
my $connect = "";

$host = "your system name";
$databasename = "perluserinfo";
$tablename = "perlsample1";
$user = "root";
$pw = "your MySQL password";

my $loginName="";
my $passw="";

my $buffer="";
my @pairs;
my $pair="";
my $name="";
my $value="";
my %FORM;
# Read in text
print "Content-type: text/html\n\n";

$ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
if ($ENV{'REQUEST_METHOD'} eq "POST")
	{
        read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    }else {
	$buffer = $ENV{'QUERY_STRING'};
    }
# Split information into name/value pairs
#print "buffer $buffer\\n";
@pairs = split(/&/, $buffer);
foreach $pair (@pairs)
    {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%(..)/pack("C", hex($1))/eg;
	$FORM{$name} = $value;
    }
$loginName=$FORM{loginName};
$passw=$FORM{passw};

my $stmt="";
my $sth="";
 
 #connect
 $connect = DBI->connect('dbi:mysql:perluserinfo','root','zzizou5') or die "Connection Error: $DBI::errstr\n";
 #$connect->do();
 $stmt = "delete from perlsample1 where loginName='$loginName' and password='$passw'";

# Prepare and execute the SQL query
$sth = $connect->prepare($stmt) or die "prepare: $stmt failed. please choose a different login name.";
$sth->execute() or die "execute: $stmt failed. please choose a different login name.";

# INSERT does not return records

# Clean up the record set
$sth->finish();
#print "$stmt";
print "Account deleted. Go back to <a href = \"../perl1.html\">home page</a>\n\n";
 exit;
 