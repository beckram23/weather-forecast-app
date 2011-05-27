#!C:\strawberry\perl\bin\perl.exe -w

use CGI;
use CGI qw(:standard);
use strict;
use warnings;
require LWP::UserAgent;

my $city="";
my $state="";
my $location="";
my $buffer="";
my @pairs;
my $pair="";
my $name="";
my $value="";
my %FORM;

my @url;
my $response="";
my $content="";
my $ua="";
my $pagecount=0;
my @zipcodes;
my @zipcity;
my @zipcounty;

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
$location=$FORM{location};

print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/>\n";
print "<HTML>

<HEAD>
	<TITLE>
		Weather Application
	</TITLE>
	<base href=\"http://127.0.0.1/\" />
	<link rel=\"stylesheet\" href=\"..\\style.css\" type=\"text/css\" media=\"all\" />
	<SCRIPT TYPE = \"text/javascript\" LANGUAGE = \"JavaScript\">
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
	var selectedbutton;
	for ( var i=0; i < form.radio.length; i++)
		{
		if ( form.radio[i].checked == true )
			{
			zip = form.radio[i].value;
			\/\/window.alert(zip);
			document.form1.zip.value = zip;
			selectedbutton = form.radio[i];
			}
		\/\/form.radio[i].checked=false; 
		}
	}
	</SCRIPT>
</HEAD>

<BODY>
<div class = \"leftalign\" >
	<A HREF = \"createAccount.html\"> Establish your account </A>
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
		<INPUT TYPE = \"submit\" NAME = \"zipCode\" VALUE = \"Weather Right Now\" STYLE = \"MARGIN-LEFT: 45em\" ONCLICK = \"validateZip(this.form);return false;\" class = \"submit\" />
	</FORM>
	<FORM METHOD = \"post\" ACTION = \"/cgi-bin/getzip.pl\">
		<br/>
		<LABEL> Get zip code (eg: San Francisco, Ca) </LABEL>
		<INPUT TYPE = \"text\" NAME = \"location\" size = 50px class = \"text\" />
		<br/>
		<br/>
		<INPUT TYPE = \"submit\" NAME = \"getZipCode\" VALUE = \"Get Zip Code\" STYLE = \"MARGIN-LEFT: 45em\" ONCLICK = \"validateLocation(this.form);return false;\" class = \"submit\" />
	</FORM>";

print "<h2> Zip codes for $location - <\/h2><\/br>";
if( $location =~ /(.*?), (.*)/ )
	{
	$city = $1;
	$state = $2;
	}

$city =~ s/ /\+/g;
#print "$city $state";

$ua = LWP::UserAgent->new;
$ua->timeout(120);
$url[0]="http://www.zip-codes.com/search.asp?SN=&SO=&pg=1&fld-state=$state&fld-city=$city";
#print "$url";

$response = $ua->get($url[0]);
$content = $response->content();
$content =~ s/[\t\n]*//g;

if ( $content =~ /(Viewing.*?)of (.*?)<br>/ )
	{
	$pagecount = $2;
	#print "$pagecount";
	}

my $i=0;
my $j=0;
my $m=0;
my $n=0;

for ( $i=1; $i<$pagecount; $i++)
	{
	$j = $i + 1;
	$url[$i] = "http://www.zip-codes.com/search.asp?SN=&SO=&pg=$j&fld-state=$state&fld-city=$city";
	#print "$url[$i]";
	}

$j=0;
for ( $i=0; $i<$pagecount; $i++)
	{
	if ( $content =~ /(<th>Zip Code<\/th>.*?)<\/tr><\/table>/ )
		{
		$content = $1;
		#print "found match<\/br>";
		}
	while ( $content =~ /<td class=a><a href="\/zip-code.*?">(.*?)<\/a>/g )
		{
		$zipcodes[$j] = $1;
		#print "$zipcodes[$j] ";
		$j++;
		}
	while ( $content =~ /<td class=a><a href="\/county.*?">(.*?)<\/a>/g )
		{
		$zipcounty[$m] = $1;
		#print "$zipcounty[$j] ";
		$m++;
		}
	while ( $content =~ /<td class=a><a href="\/city.*?">(.*?)<\/a>/g )
		{
		$zipcity[$n] = $1;
		#print "$zipcity[$j] ";
		$n++;
		}
	last if($i == $pagecount-1);
	$response = $ua->get($url[$i+1]);
	$content = $response->content();
	$content =~ s/[\t\n]*//g;
	}
#print "$content";

print "<div class = \"zipcodes\">";
print "<FORM>";
for ( $i=0; $i<$j; $i++)
	{
	print "<INPUT TYPE = \"radio\" NAME = \"radio\" VALUE = \"$zipcodes[$i]\" ONCLICK = \"setZip(this.form); return true;\">$zipcodes[$i]</INPUT> , <b>CITY:<\/b> $zipcity[$i], <b>COUNTY:<\/b> $zipcounty[$i]<\/br>";
	}

print "<\/div>";
print "</FORM>";
print "</body>";
print "</html>";

exit;