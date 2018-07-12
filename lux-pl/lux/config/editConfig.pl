#!/usr/bin/perl

use CGI;
require "config.pl";
require "../html.pl";
require "../classes/notes.pm";

my ($cgi) = new CGI;
my ($strExtensions);

foreach $extension(keys %fileExtensions)
{
        $strExtensions = $strExtensions . $fileExtensions{$extension} . ", ";
}

$strExtensions =~ s/,\s$//;

if($boolHitDisk eq true)
{
	$boolHitDisk = "checked";
}
else
{
	$boolHitDisk = "";
}

print "Content-type: text/html\n\n";

printHTMLheader("", "", "Lux PHP - Configuration", "config.gif", false, $wwwRoot, $cgiRoot);

# Inline JS is messy but necessary for the user to set up things painlessly the first time.
print "         <script type=\"text/javascript\">\n";
print "            //Set the correct location of our config.pl script.\n";
print "            //Should be something like /cgi-bin/lux/config.pl\n";
print "            //This is so we can save the configuration info the user has entered\n";
print "            function saveLuxConfig(luxConfig)\n";
print "            {\n";
print "               luxConfig.action = luxConfig.cgiRoot.value + \"/config/saveConfig.pl\"\n";
print "            }\n";
print "         </script>\n";

#print "      <img src=\"$wwwRoot/images/gear_icon.jpg\" align=\"right\" id=\"gearIconImg\">\n";
print "      <br /><br /><br />\n";
print "      <!-- Please note this default action value will be overwritten by javascript with what you enter in for cgi root -->\n";
print "      <form name=\"luxConfig\" action=\"$cgiRoot/config/saveConfig.pl\" method=\"POST\">\n";
print "      <br>Please do not include any trailing slashes on these directories.\n";
print "      <table cellspacing=\"10\" cellpadding=\"0\" border=\"0\">\n";
print "         <tr>\n";
print "            <td>Search root: </td>\n";
print "            <td><input class=\"inputbox\" size=\"40\" type=\"text\" name=\"searchRoot\" value=\"$searchRoot\"></td>\n";
print "         </tr>\n";
print "         <tr>\n";
print "            <td>Index root: </td>\n";
print "            <td><input class=\"inputbox\" size=\"40\" type=\"text\" name=\"indexRoot\" value=\"$indexRoot\"></td>\n";
print "         </tr>\n";
print "         <tr>\n";
print "            <td>Web root: </td>\n";
print "            <td><input class=\"inputbox\" size=\"40\" type=\"text\" name=\"wwwRoot\" value=\"$wwwRoot\"></td>\n";
print "         </tr>\n";
print "         <tr>\n";
print "            <td>Cgi root: </td>\n";
print "            <td><input class=\"inputbox\" size=\"40\" type=\"text\" name=\"cgiRoot\" value=\"$cgiRoot\"></td>\n";
print "         </tr>\n";
print "         <tr>\n";
print "            <td>File extensions: </td>\n";
print "            <td><input class=\"inputbox\" size=\"40\" type=\"text\" name=\"fileExtensions\" value=\"$strExtensions\"></td>\n";
print "         </tr>\n";
print "         <tr>\n";
print "            <td>Database: </td>\n";
print "            <td><input class=\"inputbox\" size=\"20\" type=\"text\" name=\"database\" value=\"$database\"></td>\n";
print "         </tr>\n";
print "         <tr>\n";
print "            <td>DB host: </td>\n";
print "            <td><input class=\"inputbox\" size=\"20\" type=\"text\" name=\"host\" value=\"$host\"></td>\n";
print "         </tr>\n";
print "         <tr>\n";
print "            <td>DB port: </td>\n";
print "            <td><input class=\"inputbox\" size=\"20\" type=\"text\" name=\"port\" value=\"$port\"></td>\n";
print "         </tr>\n";
print "         <tr>\n";
print "            <td>DB username: </td>\n";
print "            <td><input class=\"inputbox\" size=\"20\" type=\"text\" name=\"username\" value=\"$username\"></td>\n";
print "         </tr>\n";
print "         <tr>\n";
print "            <td>DB password: </td>\n";
print "            <td><input class=\"inputbox\" size=\"20\" type=\"text\" name=\"password\" value=\"$password\"></td>\n";
print "         </tr>\n";
print "         <tr>\n";
print "            <td align=\"right\"><input type=\"checkbox\" name=\"boolHitDisk\" $boolHitDisk>";
print "            <td>Disable MySQL based search (and hit disk instead)</td>\n";
print "         </tr>\n";
print "      </table>\n";
print "      <br />\n";
print "      <table width=\"250\">\n";
print "         <tr>\n";
print "            <td align=\"center\"><input class=\"button\" type=\"button\" name=\"submit\" value=\"Reset\" onClick=\"resetLuxConfig(document.luxConfig);\"></td>\n";
print "            <td align=\"center\"><input class=\"button\" type=\"submit\" name=\"submit\" value=\"Save\" onClick=\"saveLuxConfig(document.luxConfig);\"></td>\n";
print "      </table>\n";
print "      </form>\n";

printHTMLfooter();
