#!/usr/bin/perl

use CGI;
use DBI;
use File::Find;
use Cwd;
push @INC, getcwd() . "/classes";

require "config/config.pl";
require "notes.pm";

my ($cgi) = new CGI;

# Get all our form input values
for $key ($cgi->param())
{
        $input{$key} = $cgi->param($key);
}

$projectID = $input{'p'};
$noteType = $input{'type'};

# To do: put DSN connection in object instantiation. 
# Make queries consistent accross functions

print "Content-type: text/html\n\n";

$objNotes = new notes();
$objNotes->getNotes($projectID, $noteType, $dsn, $username, $password);

print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n";
print "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n";
print "   <head>\n";

print "      <title>$noteType list</title>\n";

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

print "<h3 class=\"noteH3\">$noteType list</h3>\n";
print "<table class=\"viewNotes\" border=0>\n";
print " <tr id=\"noteHeader\">\n";
print "  <td>&nbsp;</td>";
print "  <td>ID</td>\n";
#print "  <td>Date</td>\n";
print "  <td>File</td>\n";
print "  <td>Title</td>\n";

for($x=0;$x<$objNotes->{_sizeOfNotesRecordSet}; $x++)
{
	$intNoteID = $objNotes->{_arrNotesRecordSet}[$x][0];
	#$dateNoteed = $objNotes->{_arrNotesRecordSet}[$x][1];
	#$intProjectID = $objNotes->{_arrNotesRecordSet}[$x][3];
	$strTitle = $objNotes->{_arrNotesRecordSet}[$x][1];
	$strText = $objNotes->{_arrNotesRecordSet}[$x][2];
	$strFile = $intLineNumber = $objNotes->{_arrNotesRecordSet}[$x][3];
	$intLineNumberStart = $objNotes->{_arrNotesRecordSet}[$x][4];
	$intLineNumberEnd = $objNotes->{_arrNotesRecordSet}[$x][5];

	print "<tr class=\"noteStripe\">\n";

	print " <td><a href=\"javascript:openWindow('/lux/note.htm?action=edit&intNoteID=" . $intNoteID . "','noteWindow','height=345,width=820,toolbar=0,location=0,directories=0,menuBar=0,scrollbars=0,resizable=1');\"><img src=\"$wwwRoot/images/$noteType.png\" border=\"0\"></a>\n";
	print " <td>" . $intNoteID . "</td>\n";
	#print " <td>" . $dateNoteed . "</td>\n";
	print " <td>" . $strFile . "</td>\n";
	print " <td>" . $strTitle . "</td>\n";
	print "</tr>";

	print "<tr>\n";

	if($intLineNumberStart eq $intLineNumberEnd)
	{
		print " <td colspan=5><a href=\" $cgiRoot/lux.pl?p=" . $projectID . "&file=" . $strFile . "#line_" . $intLineNumberStart . "\" target=_blank>Line: " . $intLineNumberStart . "</a>: <br>&nbsp;&nbsp; " . $strText ."</td>\n";
	}
	else
	{
		print " <td colspan=5><a href=\" $cgiRoot/lux.pl?p=" . $projectID . "&file=" . $strFile . "#line_" . $intLineNumberStart . "\" target=_blank>Line: " . $intLineNumberStart . " to " . $intLineNumberEnd . "</a>: <br>&nbsp;&nbsp; " . $strText ."</td>\n";
	}

	print "</tr>\n";
}

print "  </table>\n";
print " </body>\n";
print "</html>\n";
