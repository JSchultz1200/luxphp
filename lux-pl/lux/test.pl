#!/usr/bin/perl

use Cwd;
push @INC, getcwd() . "/classes";

require "fathomTree.pm";
require "fathom.pm";
require "config/config.pl";
use CGI;

my ($cgi) = new CGI;
my ($strFile);

# Get all our form input values
for $key ($cgi->param())
{
        $input{$key} = $cgi->param($key);
}

print "Content-type: text/html\n\n";

#$strFile = $input{'strFile'};
#$objFathomTree = new fathomTree();
#$objFathomTree->createFathomTree($strFile);

#foreach $line(@strContent)
#{
#	# Set current line
#	$objFathomTree->currentLine($line);
#
#	# Search for entity types:
#	$objFathomTree->fathomObjects();
#	$objFathomTree->fathomFiles();
#	$objFathomTree->fathomSessionVars();
#	$objFathomTree->fathomGlobals();
#}

#$objFathomTree->uniqArrays();

#foreach $object(@{$objFathomTree->{_arrObjects}})
#{
#	print "object: $object\n";
#}

#foreach $file(@{$objFathomTree->{_arrFiles}})
#{
#        print "file: $file\n";
#}

#foreach $sessionVar(@{$objFathomTree->{_arrSessionVars}})
#{
#        print "session: $sessionVar\n";
#}

#foreach $global(@{$objFathomTree->{_arrGlobals}})
#{
#        print "global: $global\n";
#}

#$objFathomTree->queryEntities($strFile, $dsn, $username, $password);
#$objFathomTree->printEntitiesJSON();
