#!C:\strawberry\perl\bin\perl.exe -w
#
# Program to do the obvious
#
use strict;
use warnings;
use CGI qw(:standard);
use XML::Writer;
use XML::DOM;
use XML::Simple;
use Data::Dumper;
use IO::File;
my $xmldb="";
my $writer="";
my $xml="";
my $fName="";
my $mName="";
my $lName="";
my $address="";
my $city="";
my $state="";
my $zip="";
my $loginName="";
my $passw="";
my $doc = "";
my $root = "";
my $parser="";
my $new_user="";
my $new_fName="";
my $new_mName="";
my $new_lName="";
my $new_address="";
my $new_city="";
my $new_state="";
my $new_zip="";
my $new_loginName="";
my $new_passw="";
my $new_fNameVal="";
my $new_mNameVal="";
my $new_lNameVal="";
my $new_addressVal="";
my $new_cityVal="";
my $new_stateVal="";
my $new_zipVal="";
my $new_loginNameVal="";
my $new_passwVal="";
my $usernames="";

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
$fName=$FORM{fName};
$mName=$FORM{mName};
$lName=$FORM{lName};
$address=$FORM{address};
$city=$FORM{city};
$state=$FORM{state};
$zip=$FORM{zip};
$loginName=$FORM{loginName};
$passw=$FORM{passw};

print "Hello $fName, ";		# Print a message
if(-e "users.xml")
	{
	#print 'file exists\n';
	$xml = new XML::Simple;
	$parser = XML::DOM::Parser->new();
	$doc = $parser->parsefile( "users.xml" );
	$root = $doc->getDocumentElement();
	#print 'hi 1';
	#print $root->toString();
	foreach $usernames ($doc->getElementsByTagName('UserInfo')) {
		if ($usernames->getElementsByTagName('LoginName')->item(0)->getFirstChild->getNodeValue eq $loginName){
		print "Login name exists. Please go <a href = \"../createAccount.html\">back</a> and choose a different login name.";
		exit;
		}	}
	$new_user = $doc->createElement('UserInfo');
	$new_fName = $doc->createElement('FirstName');
	$new_fNameVal = $doc->createTextNode($fName);
	$new_fName->appendChild($new_fNameVal);
	$new_user->appendChild($new_fName);
	$new_mName = $doc->createElement('MiddleName');
	$new_mNameVal = $doc->createTextNode($mName);
	$new_mName->appendChild($new_mNameVal);
	$new_user->appendChild($new_mName);
	$new_lName = $doc->createElement('LastName');
	$new_lNameVal = $doc->createTextNode($lName);
	$new_lName->appendChild($new_lNameVal);
	$new_user->appendChild($new_lName);
	$new_address = $doc->createElement('Address');
	$new_addressVal = $doc->createTextNode($address);
	$new_address->appendChild($new_addressVal);
	$new_user->appendChild($new_address);
	$new_city = $doc->createElement('City');
	$new_cityVal = $doc->createTextNode($city);
	$new_city->appendChild($new_cityVal);
	$new_user->appendChild($new_city);
	$new_state = $doc->createElement('State');
	$new_stateVal = $doc->createTextNode($state);
	$new_state->appendChild($new_stateVal);
	$new_user->appendChild($new_state);
	$new_zip = $doc->createElement('Zip');
	$new_zipVal = $doc->createTextNode($zip);
	$new_zip->appendChild($new_zipVal);
	$new_user->appendChild($new_zip);
	$new_state = $doc->createElement('State');
	$new_stateVal = $doc->createTextNode($state);
	$new_state->appendChild($new_stateVal);
	$new_user->appendChild($new_state);
	$new_loginName = $doc->createElement('LoginName');
	$new_loginNameVal = $doc->createTextNode($loginName);
	$new_loginName->appendChild($new_loginNameVal);
	$new_user->appendChild($new_loginName);
	$new_passw = $doc->createElement('Password');
	$new_passwVal = $doc->createTextNode($passw);
	$new_passw->appendChild($new_passwVal);
	$new_user->appendChild($new_passw);
	$root->appendChild($new_user);
	#print $doc->toString();
	$doc->printToFile ("users.xml");
	$doc->dispose;
	}
else
	{
	#print 'doesnt exist\n';
	$xmldb = new IO::File(">>users.xml");
	$writer = new XML::Writer( OUTPUT => $xmldb, DATA_MODE => 1, DATA_INDENT=>2);
	$writer->xmlDecl( 'UTF-8' );
	$writer->comment( 'XML UserInfo page' );
	$writer->startTag("xmldb");
	$writer->startTag("UserInfo");           
	$writer->dataElement( 'FirstName', "$fName");
	$writer->dataElement( 'MiddleName', "$mName");
	$writer->dataElement( 'LastName', "$lName");
	$writer->dataElement( 'Address', "$address");
	$writer->dataElement( 'City', "$city");
	$writer->dataElement( 'State', "$state");
	$writer->dataElement( 'Zip', "$zip");
	$writer->dataElement( 'LoginName', "$loginName");
	$writer->dataElement( 'Password', "$passw");
	$writer->endTag( "UserInfo");
	$writer->endTag("xmldb");
	$writer->end();  
	close $xmldb;
	}

print "Go back to <a href = \"../perl1.html\">home page</a>\n\n";
exit;