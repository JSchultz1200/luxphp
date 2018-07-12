#!/usr/bin/perl

use CGI;
use File::Find;
use Cwd;
push @INC, getcwd() . "/classes";

require "fathom.pm";
require "lineSet.pm";
require "projects.pm";
require "notes.pm";
require "config/config.pl";
require "html.pl";

my ($cgi) = new CGI;
my ($strSearchPattern, $strDirectoryRestriction, $boolIsRegExpSearch, $boolIsFullText, $boolCaseSensitive, $boolIsFile, $strFile, $strTitle, $projectID, $projectRoot);

#josh test:
$boolCaseSensitive = true;

# Get all our form input values
for $key ($cgi->param())
{
        $input{$key} = $cgi->param($key);
}

# Are we loading a file?
if($input{file} ne "")
{
	$boolIsFile = true;
	$strFile = $input{file};
}
else
{
	$boolIsFile = false;
}

# Regexp search:
if(index($input{q}, "regexp:") eq 0)
{
        #User has requested a regexp search -- don't quotemeta
        $strSearchPattern = $input{q};

        # Strip out "regexp:" or "regexp: "
        $strSearchPattern =~ s/^regexp\:[\s]//o;
        $strSearchPattern =~ s/^regexp\://o;

        print "no quote: $strSearchPattern\n";

        $boolIsRegExpSearch = true;
        $boolIsfullText = false;
}

# Full text search
elsif(index($input{q}, "ft:") eq 0)
{
        $strSearchPattern = $input{q};

        # Strip out "ft: "
        $strSearchPattern =~ s/^ft\:[\s]//o;
        $strSearchPattern =~ s/^ft\://o;

        $boolIsRegExpSearch = false;
        $boolIsFullText = true;
}

#LIKE %search_pattern% based query
else
{
	$strSearchPattern=$input{q};
	$boolIsRegExpSearch = false;
	$boolIsFullText = false;
}

# Directory restriction on this search
if(index($input{q}, " dir:") > 0)
{
	$_= $strSearchPattern;
	$strDirectoryRestriction = m/\sdir\:(.*?)$/;
	$strDirectoryRestriction = $1;

	$strSearchPattern =~ s/\sdir\:.*?$//;
}

print "Content-type: text/html\n\n";

# Set the correct HTML title
if($strFile ne "")
{
	$strTitle = "Lux PHP - $strFile";
}
else
{
	$strTitle = "Lux PHP";
}

# Get search and index root from dropdown
if($input{projects} ne "" || $input{p} ne "")
{
	if($input{projects} eq "")
	{
		$projectID = $input{p};
	}
	else
	{
		$projectID = $input{projects};
	}

	$objProjects = new projects($dsn, $username, $password);

	# Pull associated project root for this project ID from the db
	$projectRoot = $objProjects->getProjectRootByID($projectID);

	# Assign to old style search and index root vars
	$searchRoot = $projectRoot;
	$indexRoot = $projectRoot;
}

# No projects have been defined yet.
else
{
	$projectID = 0;
	$searchRoot = "/";
	$indexRoot = "/";
}

# Sanitize the form input for quotes
my ($strSearchFormInput) = $input{q};
$strSearchFormInput =~ s/\"/&quot;/g;

# Print the header
printHTMLheader($strFile, $strSearchFormInput, $strTitle, "lux_php.gif", true, $wwwRoot, $cgiRoot, $projectID);

print "      <div id=\"searchMatchesContainer\">\n";

if($strSearchPattern ne "" || $boolIsFile eq true)
{
	$fathom = new fathom($strSearchPattern, $boolIsRegExpSearch, $boolIsFile, $boolCaseSensitive, $strFile, $strDirectoryRestriction, $searchRoot, $wwwRoot, $indexRoot, $projectID, \%fileExtensions, $dsn, $username, $password);

	# RegExp or non MySQL based search must hit the disk
	if($boolIsRegExpSearch eq true || $boolHitDisk eq true)
	{
		find(sub {$fathom->FathomFiles();}, $searchRoot);
		$fathom->LuxMatches();
	}

	# Database style search
	else
	{
		if($input{intPage} eq "")
		{
			$input{intPage} = 1;
		}

		my ($intTotalSearchMatches) = $fathom->FathomDatabaseCount($boolIsFullText);

		if($strFile eq "")
		{
			printHTMLpaging($cgiRoot, $strSearchFormInput, $intTotalSearchMatches, 10, $input{intPage}, $projectID);
			$fathom->FathomDatabase($boolIsFullText, 10, $input{intPage});
		}
		else
		{
			$fathom->FathomDatabase($boolIsFullText);
		}

		$fathom->SliceContents();
		$fathom->LuxMatches();
	}
}

print "      </div>\n";
printHTMLfooter();
