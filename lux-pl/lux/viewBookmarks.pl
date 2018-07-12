#!/usr/bin/perl

use CGI;
use DBI;
use File::Find;
use Cwd;
push @INC, getcwd() . "/classes";

require "config/config.pl";
require "bookmarks.pm";

$objBookmarks = new bookmarks($dsn, $username, $password);
$objBookmarks->getBookmarks();

my ($cgi) = new CGI;

# Get all our form input values
for $key ($cgi->param())
{
        $input{$key} = $cgi->param($key);
}

print "Content-type: text/html\n\n";

print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n";
print "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n";
print "   <head>\n";

print "      <title>Bookmarks</title>\n";

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

print "<h3 class=\"noteH3\">Bookmarks</h3>\n";
print "<table class=\"viewBookmarks\" border=0>\n";
print " <tr id=\"bookmarkHeader\">\n";

print "  <td>&nbsp;</td>\n";
print "  <td>ID</td>\n";
print "  <td>Date</td>\n";
print "  <td>Project</td>\n";
print "  <td>Query</td>\n";
print "  <td>File</td>\n";

for($x=0;$x<$objBookmarks->{_sizeOfBookmarks}; $x++)
{
	$intBookmarkID = $objBookmarks->{_arrBookmarks}[$x][0];
	$dateBookmarked = $objBookmarks->{_arrBookmarks}[$x][1];
	$strProject = $objBookmarks->{_arrBookmarks}[$x][2];
	$intProjectID = $objBookmarks->{_arrBookmarks}[$x][3];
	$strQuery = $objBookmarks->{_arrBookmarks}[$x][4];
	$strFile = $intLineNumber = $objBookmarks->{_arrBookmarks}[$x][5];
	$intLineNumber = $objBookmarks->{_arrBookmarks}[$x][6];
	$strLine = $objBookmarks->{_arrBookmarks}[$x][7];

	print "<tr class=\"bookmarkStripe\">\n";

	print " <td><img src=\"$wwwRoot/images/tag_blue.png\">\n";
	print " <td>" . $intBookmarkID . "</td>\n";
	print " <td>" . $dateBookmarked . "</td>\n";
	print " <td>" . $strProject . "</td>\n";
	print " <td>" . $strQuery . "</td>\n";
	print " <td>" . $strFile . "</td>\n";
	print "</tr>";

	print "<tr>\n";
	print " <td colspan=5><a href=\" $cgiRoot/lux.pl?p=" . $intProjectID . "&q=" . $strQuery . "&file=" . $strFile . "#line_" . $intLineNumber . "\" target=_blank>Line: " . $intLineNumber . "</a>: <br>&nbsp;&nbsp; " . $strLine ."</td>\n";
	print "</tr>\n";
}

print "  </table>\n";
print " </body>\n";
print "</html>\n";
