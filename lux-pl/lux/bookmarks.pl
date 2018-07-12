#!/usr/bin/perl

use CGI;
use Cwd;
push @INC, getcwd() . "/classes";

require "bookmarks.pm";
require "config/config.pl";

my ($cgi) = new CGI;
my ($strFile, $intProjectID, $intLineNumber, $strQuery);

# Get all our form input values
for $key ($cgi->param())
{
        $input{$key} = $cgi->param($key);
}

print "Content-type: text/html\n\n";

$strFile = $input{'strFile'};
$intProjectID = $input{'intProjectID'};
$intLineNumber = $input{'intLineNumber'};
$strQuery = $input{'strQuery'};

$objBookmark = new bookmarks($dsn, $username, $password);
$objBookmark->addBookmark($strFile, $intProjectID, $intLineNumber, $strQuery);
