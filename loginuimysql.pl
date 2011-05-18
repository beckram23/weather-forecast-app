#!C:\strawberry\perl\bin\perl.exe -w

use CGI qw(:standard);
use DBI;
use strict;
use warnings;
require LWP::UserAgent;

print "Content-type: text/html \n\n";

#MYSQL CONFIG VARIABLES
my $host = "";
my $databasename = "";
my $tablename = "";
my $user = "";
my $pw = "";
my $connect = "";

my $loginName="";
my $passw="";

print "Content-type: text/html\n\n";

my $buffer="";
my @pairs;
my $pair="";
my $name="";
my $value="";
my %FORM;
# Read in text

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

$host = "your system name";
$databasename = "perluserinfo";
$tablename = "perlsample1";
$user = "root";
$pw = "your MySQL password";

my $stmt="";
my $sth="";
my @result;
my $ufName="";
my $ulName="";
my $uaddress="";
my $ucity="";
my $ustate="";
my $uzip="";
my $url="";
my $response="";
my $content="";
my $ua="";
 
#print "Hello, ";		# Print a message
print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>\n";
print "<html><head><link rel=\"stylesheet\" href=\"..\\style.css\" type=\"text/css\" media=\"all\" /></head><body style = \"text-align:center\">";
 
 #connect
 $connect = DBI->connect('dbi:mysql:perluserinfo','root','zzizou5') or die "Connection Error: $DBI::errstr\n";
 #$connect->do();
 $stmt = "select firstName, lastName, address, city, state, zip from perlsample1 where loginName='$loginName' and password='$passw'";

# Prepare and execute the SQL query
$sth = $connect->prepare($stmt) or die "prepare: $stmt failed. Login and password mismatch.";
$sth->execute() or die "execute: $stmt failed. Login and password mistach.";

@result = $sth->fetchrow_array();
#print "Value returned: $result->{$ufName}\n";
$uaddress=$result[2];
$ucity=$result[3];
$ustate=$result[4];
$uzip=$result[5];
print "<h2>Welcome $result[0] $result[1] !!";
print "</br>";
print "You are from $uaddress, $ucity, $ustate $uzip</h2>";


# Clean up the record set
$sth->finish();
$connect->disconnect();
#print "$stmt";


$ua = LWP::UserAgent->new;
$ua->timeout(120);
$ucity =~ s/ /\+/g;
$url="http://www.weather.com/weather/today/$ucity+$ustate+$uzip";
#print "<h2>$url</h2>";
$response = $ua->get($url);
$content = $response->content();
$content =~ s/[\t\n]*//g;
#print "$content";
print "<div class = \"centeralign\" >";
print "<h2> Climate Right Now: </h2>";
print "<table><caption><h2>The Weather for next 36 hours<h2></caption><tr><th>Time</th><th>Condition</th><th>Temperature</th><th>Feels Like</th><th>Wind</th><th>Weather</th></tr>";
while ( $content =~ /(<!-- Column 1 --><td class=\"twc-col-2 twc-forecast-when\">Tonight<\/td><!-- Column 2 -->.*)<\/table>/g )
	{
	$content = "$1";
	#print $content;
	}
my @time;
my @conditions;
my @temperature;
my @feelsLike;
my @wind;
my @weather;
my $i=0;
my $j=0;
#time
if ( $content =~ /<!-- Column 1 --><td.*?>(.*?)<\/td>/ )
	{
	$time[$i] = $1; $i++;
	}
if ( $content =~ /(.*?<!-- Column 2 --><td.*?>)(.*?)<\/td>/ )
	{
	$time[$i] = $2; $i++;
	}
if ( $content =~ /(.*?<!-- Column 3 --><td.*?>)(.*?)<\/td>/ )
	{
	$time[$i] = $2; $i++;
	}
#conditions
$i=0;
if ( $content =~ /(.*?<\/td><td class=\"twc-col-2\">)(.*?)<\/td>/ )
	{
	$conditions[$i] = $2; $i++;
	}
if ( $content =~ /(.*?<!-- Column 2 --><td class=\"twc-col-3\">)(.*?)<\/td>/ )
	{
	$conditions[$i] = $2; $i++;
	}
if ( $content =~ /(.*?<!-- Column 3 --><td class=\"twc-col-4\">)(.*?)<\/td>/ )
	{
	$conditions[$i] = $2; $i++;
	}
#temprature
$i=0;
if ( $content =~ /(.*?<td class=\"twc-col-2 twc-forecast-temperature\"><strong>)(.*?)<\/strong>/ )
	{
	$temperature[$i] = $2; $i++;
	}
if ( $content =~ /(.*?<td class=\"twc-col-3 twc-forecast-temperature\"><strong>)(.*?)<\/strong>/ )
	{
	$temperature[$i] = $2; $i++;
	}
if ( $content =~ /(.*?<td class=\"twc-col-4 twc-forecast-temperature\"><strong>)(.*?)<\/strong>/ )
	{
	$temperature[$i] = $2; $i++;
	}
#feelsLike
$i=0;
if ( $content =~ /(.*?<td class=\"twc-col-2 twc-forecast-temperature-info\">)(.*?)<\/td>/ )
	{
	$feelsLike[$i] = $2; $i++;
	}
if ( $content =~ /(.*?<td class=\"twc-col-3 twc-forecast-temperature-info\">)(.*?)<\/td>/ )
	{
	$feelsLike[$i] = $2; $i++;
	}
if ( $content =~ /(.*?<td class=\"twc-col-4 twc-forecast-temperature-info\">)(.*?)<\/td>/ )
	{
	$feelsLike[$i] = $2; $i++;
	}
#wind
$i=0;
if ( $content =~ /(.*?<td class=\"twc-col-2 twc-line-wind\">Wind:<br><strong>)(.*?)<\/strong>/ )
	{
	$wind[$i] = $2; $i++;
	}
if ( $content =~ /(.*?<td class=\"twc-col-3 twc-line-wind\">Wind:<br><strong>)(.*?)<\/strong>/ )
	{
	$wind[$i] = $2; $i++;
	}
if ( $content =~ /(.*?<td class=\"twc-col-4 twc-line-wind\">Wind:<br><strong>)(.*?)<\/strong>/ )
	{
	$wind[$i] = $2; $i++;
	}
#weather
$i=0;
if ( $content =~ /(.*?<td class=\"twc-col-2 twc-forecast-icon\"><a href.*?>)(.*?)<\/a>/ )
	{
	$weather[$i] = $2; $i++;
	}
if ( $content =~ /(.*?<td class=\"twc-col-3 twc-forecast-icon\"><a href.*?>)(.*?)<\/a>/ )
	{
	$weather[$i] = $2; $i++;
	}
if ( $content =~ /(.*?<td class=\"twc-col-4 twc-forecast-icon\"><a href.*?>)(.*?)<\/a>/ )
	{
	$weather[$i] = $2; $i++;
	}
while($j<3)
	{
	print "<tr><td>$time[$j]<\/td><td>$conditions[$j]<\/td><td>$temperature[$j]<\/td><td>$feelsLike[$j]<\/td><td>$wind[$j]<\/td><td>$weather[$j]<\/td><\/tr>";
	$j++;
	}
#print "done";

print "</table></div>Go back to <a href = \"http://127.0.0.1/perl1.html\">home page.</a>\n\n";

print "<a href = \"http://127.0.0.1/deleteAccount.html?loginName=$loginName\"> Delete </a> your account\n\n";

print "</body>";
print "</html>";
exit;

