#!/usr/bin/perl

use CGI;
use Cwd;
push @INC, getcwd() . "/classes";

require "graphTree.pm";
require "config/config.pl";

my ($cgi) = new CGI;
my ($strEntity, $strEntityType);

# Get all our form input values
for $key ($cgi->param())
{
        $input{$key} = $cgi->param($key);
}

print "Content-type: text/html\n\n";

if($input{file} ne "")
{
	$strEntity = $indexRoot . $input{file};
	$strEntityType = "file";
}
elsif($input{global} ne "")
{
	$strEntity = $input{global};
	$strEntityType = "global";
}

$objGraphTree = new graphTree();

if($input{action} eq "queryEntities")
{
	$objGraphTree->queryEntities($strEntity, $strEntityType, $indexRoot, $dsn, $username, $password);
	$objGraphTree->printEntitiesJSON();
}
