#!C:\strawberry\perl\bin\perl.exe -w
#
# Program to do the obvious
#
use strict;
use warnings;
use CGI qw(:standard);
use XML::DOM;
use IO::File;
require LWP::UserAgent;
my $parser="";
my $doc="";
my $root="";
my $loginName="";
my $passw="";
my $ufName="";
my $ulName="";
my $uaddress="";
my $ucity="";
my $ustate="";
my $uzip="";
my $usernames="";
my $count=0;
my $ua="";
my $url="";
my $response="";
my $content="";

print "Content-type: text/html\n\n";

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

#print "Hello, ";		# Print a message
print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>\n";
print "<html><head><base href = \"http://www.weather.com/\"><style>table.center {margin-left:auto; margin-right: auto;} h2 {text-align: center;}</style></head><body style = \"text-align:center\">";
$parser = XML::DOM::Parser->new();
$doc = $parser->parsefile( "users.xml" );
$root = $doc->getDocumentElement();
foreach $usernames ($doc->getElementsByTagName('UserInfo')) {
		if ($usernames->getElementsByTagName('LoginName')->item(0)->getFirstChild->getNodeValue eq $loginName 
		&& $usernames->getElementsByTagName('Password')->item(0)->getFirstChild->getNodeValue eq $passw){
		$ufName = $usernames->getElementsByTagName('FirstName')->item(0)->getFirstChild->getNodeValue;
		$ulName = $usernames->getElementsByTagName('LastName')->item(0)->getFirstChild->getNodeValue;
		$uaddress = $usernames->getElementsByTagName('Address')->item(0)->getFirstChild->getNodeValue;
		$ucity = $usernames->getElementsByTagName('City')->item(0)->getFirstChild->getNodeValue;
		$ustate = $usernames->getElementsByTagName('State')->item(0)->getFirstChild->getNodeValue;
		$uzip = $usernames->getElementsByTagName('Zip')->item(0)->getFirstChild->getNodeValue;
		$count=1;
		print "<h2>Welcome $ufName $ulName !!";
		print '\\n';
		print "You are from $uaddress, $ucity, $ustate $uzip</h2>";
		}
		last if( $count==1 );
		}
if ( $count==0 ) {
	print "Username or password doesn't match. Please try again.\\n";
	}
$ua = LWP::UserAgent->new;
$ua->timeout(120);
$ucity =~ s/ /\+/g;
$url="http://www.weather.com/weather/today/$ucity+$ustate+$uzip";
#print "<h2>$url</h2>";
$response = $ua->get($url);
$content = $response->content();
$content =~ s/[\t\n]*//g;
#print "$content";
print "<table border=\"1\" class=\"center\"><caption><h2>The Weather for next 36 hours<h2></caption><tr><th>Time</th><th>Condition</th><th>Temperature</th><th>Feels Like</th><th>Wind</th><th>Weather</th></tr>";
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
print "</table>Go back to <a href = \"http://127.0.0.1/perl1.html\">home page</a>\n\n</body>";
print "</html>";
exit;