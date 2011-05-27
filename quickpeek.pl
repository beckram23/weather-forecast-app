#!C:\strawberry\perl\bin\perl.exe -w

use CGI qw(:standard);
use Flickr::API;
use Flickr::API::Request;
use XML::Parser::Lite::Tree::XPath;
use Data::Dumper;
use strict;
use warnings;
require LWP::UserAgent;

my $zip="";
my $buffer="";
my @pairs;
my $pair="";
my $name="";
my $value="";
my %FORM;

my $url="";
my $response="";
my $content="";
my $ua="";
my $conditionRightNow="";
my $location="";
my $state="";
my $city="";
my $time="";
my $api="";
my $flickrrequest="";
my $flickrresponse="";
my $zipcodes="";
my $latitude="";
my $longitude="";

# Read in text
print "Content-type: text/html\n\n";

$ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
if ($ENV{'REQUEST_METHOD'} eq "POST")
	{
        read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    }else {
	$buffer = $ENV{'QUERY_STRING'};
    }
	
@pairs = split(/&/, $buffer);
foreach $pair (@pairs)
    {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%(..)/pack("C", hex($1))/eg;
	$FORM{$name} = $value;
    }
$zip=$FORM{zip};

print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>\n";
print "<html><head><link rel=\"stylesheet\" href=\"..\\style.css\" type=\"text/css\" media=\"all\" /><base href=\"http://127.0.0.1/\" />";
print "	<SCRIPT TYPE = \"text/javascript\" LANGUAGE = \"JavaScript\">
	function validateZip(form)
	{
	var zip = form.zip.value;
	var checkZip = /^[0-9]{5,}\$/;
	var error;
	if(!checkZip.test(zip))
		{
		error = \"Enter a valid zip code (minimum 5 digits).\";
		window.alert(error);
		return false;
		}
	else 
		{
		form.submit();
		}
	}
	function validateLocation(form)
	{
	var location = form.location.value;
	var checkLocation = /^([a-zA-Z])+.*(\\,{1})(\\s{1})([a-zA-Z]){2}\$/;
	var error;
	if(!checkLocation.test(location))
		{
		error = \"Please enter the search value as CITY, STATE. eg: San Francisco, Ca\";
		window.alert(error);
		return false;
		}
	else 
		{
		form.submit();
		}
	}
	function setZip(form)
	{
	var zip;
	for ( var i=0; i < form.radio.length; i++)
		{
		if ( form.radio[i].checked)
			{
			zip = form.radio[i].value;
			\/\/window.alert(zip);
			document.form1.zip.value = zip;
			}
		}
	}
	</SCRIPT>
</head><body style = \"text-align:center\">";

#print "$zip";
$ua = LWP::UserAgent->new;
$ua->timeout(120);
$url="http://www.weather.com/weather/today/$zip";
#print "<h2>$url</h2>";
$response = $ua->get($url);
$content = $response->content();
$content =~ s/[\t\n]*//g;

#print "$flickr";
print "Conditions right now - <\/br>";
if ( $content =~ /<h1 id=\"twc_loc_head\">(.*?)\(/ )
	{
	$location = $1;
	print "$location $zip : ";
	}
if( $location =~ /(.*?), (.*)/ )
	{
	$city = $1;
	$state = $2;
	}

$ua = LWP::UserAgent->new;
$ua->timeout(120);
$url="http://www.worldtimeserver.com/current_time_in_US-$state.aspx";
$url =~ s/ //g;
#print "<h2>$url</h2>";
$response = $ua->get($url);
$time = $response->content();
$time =~ s/[\t\n]*//g;

#$location = s/ /\+/g;
$ua = LWP::UserAgent->new;
$ua->timeout(120);
$url="http://www.zip-codes.com/zip-code/$zip/zip-code-$zip.asp";
#print "<h2>$url</h2>";
$response = $ua->get($url);
$zipcodes = $response->content();
$zipcodes =~ s/[\t\n]*//g;

if ( $zipcodes =~ /Latitude:<\/a><\/td><td id.*?>(.*?)<.*?Longitude:<\/a><\/td><td id.*?>(.*?)</ )
	{
	$latitude = $1;
	$longitude = $2;
	#print "$1, $2";
	}

$api = new Flickr::API({'key' => '787989c648d30298ca3a893b5122c35d'});

$flickrresponse = $api->execute_method('flickr.photos.search', {
                'lat' => $latitude,'lon'   => $longitude,'radius' => '20','radius_units' => 'km'
        });

my $debug = 1;
if ($debug)
{
	#print "Success: $flickrresponse->{success}\n";
	#print "Error code: $flickrresponse->{error_code}\n";
	#print Dumper ($flickrresponse);
}

my $xpath = new XML::Parser::Lite::Tree::XPath($flickrresponse->{tree});
my @photo = $xpath->select_nodes('/photos');

my $photosize = @photo;
print "$photosize";
#print Dumper (\@photo);
print Dumper ($photo[0]);

foreach (@photo)
	{
	#print "$_->{attributes}->{farm}, ";
	}

#print "$time<\/br>";
if ( $time =~ /<div id=\"analog-digital\">.*?>(.*?)<.*?<strong>(.*?)</ )
	{
	print "Time and Date $1, $2 -- ";
	}
while ( $content =~ /(<!-- Column 1 --><td class=\"twc-col-2 twc-forecast-when\">Tonight<\/td><!-- Column 2 -->.*)<\/table>/g )
	{
	$content = "$1";
	#print $content;
	}

if ( $content =~ /<\/tr><tr><td class=\"twc-col-1\">(.*?)<\/td>/ )
	{
	$conditionRightNow = $1;
	#print "$conditionRightNow";
	print "<b>";
	if ($conditionRightNow =~ m/showers/i)
		{
		print "Light showers. Less than 50% precipitation.<\/br>";
		}
	elsif ($conditionRightNow =~ m/rain/i)
		{
		print "Raining. Precipitation above 50%.<\/br>";
		}
	else
		{
		print "No rainfall.<\/br>";
		}
	print "<\/b>";
	}

$ua = LWP::UserAgent->new;
$ua->timeout(120);
$url="http://www.weather.com/weather/hourbyhour/graph/$zip";
#print "<h2>$url</h2>";
$response = $ua->get($url);
$content = $response->content();
$content =~ s/[\t\n]*//g;

my $i=0;
my $precipitation;
my $average=0;

while ( $content =~ /(<div class="hbhWxHour" id="hbhWxHour0">.*)<div class="hbhWxHour" id="hbhWxHour6">/g )
	{
	$content = "$1";
	#print $content;
	}



print "<\/br><h2>Precipitation forecast for the next 6 hours<\/h2><\/br>";

for ($i=0; $i<7; $i++)
	{
	if ( $content =~ /<div class="hbhWxHour" id="hbhWxHour$i">.*?<div class="hbhWxTime"><div>(.*?)<\/div>.*?Precip:<\/span><br>(.*?)<\/div>/ )
		{
		print "At $1 -> $2<\/br>";
		$precipitation = $2;
		$precipitation =~ s/%//g;
		$average += $precipitation;
		}
	}

$average = $average/6;	
#print "mean $average";

if ($average < 20)
	{
	print "Possible light showers.<\/br><\/br>";
	}
elsif ($average < 70 && $average >= 20)
	{
	print "Moderate to heavy showers.<\/br><\/br>";
	}
elsif ($average >= 70)
	{
	print "Heavy rain.<\/br><\/br>";
	}

print "<div class = \"leftalign\" ><A HREF = \"createAccount.html\"> Establish your account </A>
	<br/>
	<A HREF = \"login.html\"> Login </A>
	<\/div>
	<br/>
	<h2> Quick peek </h2>
	<FORM METHOD = \"post\" ACTION = \"/cgi-bin/quickpeek.pl\" NAME = \"form1\">
		<br/>
		<LABEL> Zip Code </LABEL>
		<INPUT TYPE = \"text\" NAME = \"zip\" size = 50px class = \"text\" />
		<br/>
		<br/>
		<INPUT TYPE = \"submit\" NAME = \"zipCode\" VALUE = \"Weather Right Now\" STYLE = \"MARGIN-LEFT: 45em\" ONCLICK = \"validateZip(this.form);return false;\"  class = \"submit\"/>
	</FORM>
	<FORM METHOD = \"post\" ACTION = \"/cgi-bin/getzip.pl\">
		<br/>
		<LABEL> Get zip code (eg: San Francisco, Ca) </LABEL>
		<INPUT TYPE = \"text\" NAME = \"location\" size = 50px class = \"text\" />
		<br/>
		<br/>
		<INPUT TYPE = \"submit\" NAME = \"getZipCode\" VALUE = \"Get Zip Code\" STYLE = \"MARGIN-LEFT: 45em\" ONCLICK = \"validateLocation(this.form);return false;\" class = \"submit\" />
	</FORM>";
print "</body>";
print "</html>";

exit;