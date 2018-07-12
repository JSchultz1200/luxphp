#!/usr/bin/perl

use POSIX qw(ceil);

# This file includes common html functions
# for each page, namely the header and footer.
# Eventually it should be moved to an embeded perl format

# Prints the page header
#

sub printHTMLheader
{
        my ($strFile, $strSearchFormInput, $strTitle, $strHeaderImage, $boolPrintQueryForm, $wwwRoot, $cgiRoot, $projectID) = @_;

        print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n";
        print "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n";
        print "   <head>\n";

        print "      <title>" . $strTitle . "</title>\n";

        print "         <link rel=\"stylesheet\" href=\"$wwwRoot/lux.css\" type=\"text/css\">\n";

        print "         <script src=\"$wwwRoot/js/lib/prototype.js\" type=\"text/javascript\"></script>\n";
        print "         <script src=\"$wwwRoot/js/src/scriptaculous.js\" type=\"text/javascript\"></script>\n";
        print "         <link rel=\"stylesheet\" type=\"text/css\" href=\"$wwwRoot/js/yui/build/tabview/assets/tabview.css\">\n";
        print "         <link rel=\"stylesheet\" type=\"text/css\" href=\"$wwwRoot/js/yui/build/tabview/assets/border_tabs.css\">\n";
        print "         <script type=\"text/javascript\" src=\"$wwwRoot/js/yui/build/yahoo/yahoo.js\"></script>\n";
        print "         <script type=\"text/javascript\" src=\"$wwwRoot/js/yui/build/event/event.js\"></script>\n";
        print "         <script type=\"text/javascript\" src=\"$wwwRoot/js/yui/build/dom/dom.js\"></script>\n";
        print "         <script type=\"text/javascript\" src=\"$wwwRoot/js/yui/build/connection/connection.js\"></script>\n";
        print "         <script type=\"text/javascript\" src=\"$wwwRoot/js/yui/build/element/element-beta.js\"></script>\n";
        print "         <script type=\"text/javascript\" src=\"$wwwRoot/js/yui/build/tabview/tabview.js\"></script>\n";

        print "         <script src=\"$wwwRoot/js/lux.js\" type=\"text/javascript\"></script>\n";

        print "   </head>\n";
        print "   <body>\n";
	print "      <div id=\"lux_content\">\n\n";

        print "      <div id=\"lux_headerLinks\">\n";
        print "         <img src=\"$wwwRoot/images/logo.gif\" id=\"lux_logoImg\"><br>\n";
	print "         <a class=\"lux_headerLink\" href=\"$cgiRoot/lux.pl\">Lux PHP</a>&nbsp;&nbsp;|&nbsp;&nbsp;\n";
        print "         <a class=\"lux_headerLink\" href=\"$cgiRoot/webIndexer.pl\">Web Indexer</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"lux_headerLink\" href=\"$cgiRoot/config/editConfig.pl\">Configuration</a>\n";
        print "      </div>\n";

        print "      <div class=\"lux_pageHeader\">\n";
        print "         <img src=\"$wwwRoot/images/$strHeaderImage\" id=\"lux_logoText\">\n";
        # vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv.////////////nhmhh

	if($boolPrintQueryForm eq true)
	{
        	print "         <form name=\"luxSearch\" action=\"$cgiRoot/lux.pl\">Query:&nbsp;&nbsp;\n";
        	print "            <input class=\"inputbox\" type=\"text\" size=\"36\" name=\"q\" value=\"$strSearchFormInput\" />&nbsp;&nbsp;\n";
        	print "            <input class=\"button\" type=\"submit\" name=\"submit\" value=\"Search\" />\n";

        	# Print the projects search dropdown

                # Create a new projects object
               	$objProjects = new projects($dsn, $username, $password);

                # Get all the projects defined in the database
                $objProjects->getProjects();

               	# Print projects selection dropdown
               	$objProjects->printProjectsDropDownSearch($projectID);

        	print "         </form>\n";
	}

	print "      </div>\n";

	# Note: This should be outdated with the new project association system
	# Files can no longer be singly associated manually with different projects. 
	# Only TLD and all their sub-directories/files can be associated with a project

        # Show project association if displaying a file
        if($strFile ne "")
        {
                # Create a new projects object
                #$objProjects = new projects($dsn, $username, $password);

                # Get all the projects defined in the database
                #$objProjects->getProjects();

                # Get the project association of this file
                #$objProjects->getAssociation($strFile, $indexRoot);

		#$projectRoot = $objProjects->getProjectRootByID($projectID);

                # Print projects selection dropdown
                #$objProjects->printProjectsDropDown($strFile, $projectRoot);
		
		print "      <div class=\"lux_resultsText\">Results for <font class=\"lux_headerMatch\">$input{q}</font> ($strSearchPattern) in $indexRoot$strFile</div>\n";
        }
	elsif($boolPrintQueryForm eq true)
	{
		print "      <div class=\"lux_resultsText\">Results for <font class=\"lux_headerMatch\">$input{q}</font> ($strSearchPattern) in $indexRoot</div>\n";
	}

        $objNotes = new notes();
        $objNotes->getNoteTypes($dsn, $username, $password);

	print "<div class=\"noteLinks\">\n";

	print "<a href=\"javascript:openBookmarksWindow('viewBookmarks.pl?', 'viewBookmarks', 'height=250,width=600');\"><img src=\"$wwwRoot/images/tag_blue.png\" border=\"0\"></a>&nbsp;&nbsp;\n";

	for($x=0;$x<$objNotes->{_sizeOfNotesRecordSet}; $x++)
	{	
        	print "<a href=\"javascript:openNotesWindow('viewNotes.pl?type=" . $objNotes->{_arrNotesRecordSet}[$x][0] . "', 'view" . $objNotes->{_arrNotesRecordSet}[$x][0] . "', 'height=250,width=600');\"><img src=\"$wwwRoot/images/$objNotes->{_arrNotesRecordSet}[$x][0].png\" border=\"0\"></a>\n";
		print "&nbsp;&nbsp;\n";
	}

	print "</div>";
}

# Prints the page footer
# 

sub printHTMLfooter
{
	#print "        <div id=\"lux_footer\"><a class=\"lux_headerLink\" href=\"http://www.luxphp.net/main.php\">luxphp.net</a> - v1.0.17</div>\n";

	# End content div
	print "        </div>\n";

        print "   </body>\n";
        print "</html>\n";
}

# Prints the result set paging
# for a query with many matches
#

sub printHTMLpaging
{
	my ($cgiRoot, $strSearchPattern, $intTotalSearchMatches, $intRowsPerPage, $intCurrentPage, $intProjectID) = @_;
	my ($intMaxPages) = ceil($intTotalSearchMatches / $intRowsPerPage);
	my ($x, $strPageLinks);

	print "<div class=\"lux_paging\">Pages: ";

	for($x = 1; $x <= $intMaxPages; $x++)
	{
		if($x eq $intCurrentPage)
		{
			$strPageLinks = $strPageLinks . "$x, ";
		}
		else
		{
			$strPageLinks = $strPageLinks . "<a href=\"$cgiRoot/lux.pl?q=$strSearchPattern&intPage=$x&projects=$intProjectID\">$x</a>, ";
		}
	}

	chop($strPageLinks);
	chop($strPageLinks);

	print $strPageLinks;

	print "</div>";
}

sub includeHTML {
local(*FILE); # filehandle
local($file); # file path
local($HTML); # HTML data

$file = $_[0] || die "There was no file specified!\n";

open(FILE, "<$file") || die "Couldn't open $file!\n";
$HTML = do { local $/; <FILE> }; #read whole file in through slurp #mode (by setting $/ to undef)
close(FILE);

return $HTML;
}

1;
