#!/usr/bin/perl

use CGI;
use Cwd;
push @INC, getcwd() . "/classes";

require "projects.pm";
require "config/config.pl";

my ($cgi) = new CGI;
my ($strFile, $strProject);

# Get all our form input values
for $key ($cgi->param())
{
        $input{$key} = $cgi->param($key);
}

print "Content-type: text/html\n\n";

$strFile = $input{'strFile'};
$strProjectID = $input{'strProject'};

$objProject = new projects($dsn, $username, $password);
$objProject->updateProjectAssociation($strFile, $strProjectID);
