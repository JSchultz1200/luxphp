#!/usr/bin/perl

use CGI;
require "config/config.pl";
require "html.pl";
require "classes/notes.pm";
require "classes/projects.pm";

my ($cgi) = new CGI;

print "Content-type: text/html\n\n";

printHTMLheader("", "", "Lux PHP - Web Indexer", "indexing.gif", false, $wwwRoot, $cgiRoot);

# TO DO: include "select project" dropdown to choose the indexRoot
#
# Create a new projects object
#$objProjects = new projects($dsn, $username, $password);

# Get all the projects defined in the database
#$objProjects->getProjects();
 
# Print projects selection dropdown
#$objProjects->printProjectsDropDownSearch(2);

print "<br>";
print "      <table cellpadding=10 id=\"webIndexerTable\">\n";
print "         <tr>\n";
print "            <td><a href=\"#\" onClick=\"displayElement('singleFileIndexInput');\" onmouseout=\"MM_swapImgRestore()\" onmouseover=\"MM_swapImage('webIndexerSingleImg','','$wwwRoot/images/orange_single.jpg',1)\">";

print "<img src=\"$wwwRoot/images/blue_single.jpg\" id=\"webIndexerSingleImg\" border=\"0\"></td>\n";

print "            <td><a href=\"$cgiRoot/mysqlIndexer.pl?boolModifiedOnly=true\" onmouseout=\"MM_swapImgRestore()\" onmouseover=\"MM_swapImage('webIndexerModifiedImg','','$wwwRoot/images/orange_modified.jpg',1)\">";
print "<img src=\"$wwwRoot/images/blue_modified.jpg\" id=\"webIndexerModifiedImg\" border=\"0\"></a></td>\n"; 

print "            <td><a href=\"$cgiRoot/mysqlIndexer.pl?boolFullIndex=true\" onmouseout=\"MM_swapImgRestore()\" onmouseover=\"MM_swapImage('webIndexerFullImg','','$wwwRoot/images/orange_full.jpg',1)\">";
print "<img src=\"$wwwRoot/images/blue_full.jpg\" id=\"webIndexerFullImg\" border=\"0\"></a></td>\n";

print "         </tr>\n";
print "         <tr>\n";
print "            <td valign=\"top\">Index or re-index a <b>single</b> file of your choice.</td>\n";
print "            <td>Index <b>modified</b> only files, which includes files that have been<br/>changed, deleted, or created.</td>\n";
print "            <td>Do a <b>full index</b> on the entire indexRoot. This will first delete everything from the database.</td>\n";
print "         </tr>\n";
print "        <tr>\n";

print "           <td colspan=\"3\">\n";
print "              <table id=\"singleFileIndexInput\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\">\n";
print "                 <tr>\n";
print "                    <td>\n";
print "                       <form name=\"index\" action=\"mysqlIndexer.pl\" method=\"GET\">\n";
print "                          Enter the relative location of the file: <input class=\"inputbox\" type=\"text\" size=\"50\" name=\"strUpdateOneFile\">\n";
print "                          <input class=\"button\" type=\"submit\" value=\"Index\">\n";
print "                       </form>\n";
print "                    </td>\n";
print "                 </tr>\n";
print "              </table>\n";
print "           </td>\n";

print "         </tr>\n";
print "      </table>\n";

printHTMLfooter();
