#!/usr/bin/perl

use CGI;

my ($cgi) = new CGI;
my (%fileExtensions, $strExtensions);

# Get all our form input values
for $key ($cgi->param())
{
        $input{$key} = $cgi->param($key);
}

# Open config.pl file

open(FILE, ">config.pl");

print FILE "#!/usr/bin/perl\n\n";

###########################################################################################################################################

print FILE "# Root directory for searches and indexing. No trailing slashes here please! These paths are system absolute paths.\n\n"; 
print FILE "\$searchRoot = \"" . $input{"searchRoot"} . "\";\n"; 
print FILE "\$indexRoot = \"" . $input{"indexRoot"} . "\";\n\n";

###########################################################################################################################################

print FILE "# Root directory of the files where lux.css and supporting JS will be stored. This is web relative and not system absolute.\n";
print FILE "# DO NOT INCLUDE A TRAILING SLASH AT THE END OF THIS LOCATION\n\n";
print FILE "\$wwwRoot = \"" . $input{"wwwRoot"} . "\";\n\n";

###########################################################################################################################################

print FILE "# Root directory for cgi-bin. Most likely /cgi-bin (i.e., relative to the web browser and not an absolute system path)\n\n";
print FILE "\$cgiRoot = \"" . $input{"cgiRoot"} . "\";\n\n";

###########################################################################################################################################

print FILE "# List of file types to search through. You may want to add or remove\n";
print FILE "# some of these. To add an icon association for a new file type simply\n";
print FILE "# include the icon in the images directory and name it as icon.filetype.gif\n\n";

$input{"fileExtensions"} =~ s/\s//g;
@fileExtensions = split /,/, $input{"fileExtensions"};

$strExtensions = "%fileExtensions = (";

foreach $extension(@fileExtensions)
{
	$strExtensions = $strExtensions . ", \"$extension\"" . ", \"$extension\"";
}

$strExtensions = $strExtensions . ");";

# Remove preceeding comma from the hash
$strExtensions =~ s/\(,\s/\(/;

print FILE $strExtensions . "\n\n";

############################################################################################################################################

print FILE "# Boolean determines whether to do a MySQL based search or a disk based search\n\n";
print FILE "\$boolHitDisk = ";
print FILE ($input{"boolHitDisk"} eq "on") ? "true;\n\n" : "false;\n\n";

############################################################################################################################################

print FILE "# MySQL Database Settings:\n\n";
print FILE "\$database = \"" . $input{"database"} . "\";\n";
print FILE "\$host = \"" . $input{"host"} . "\";\n";
print FILE "\$port = \"" . $input{"port"} . "\";\n";
print FILE "\$username = \"" . $input{"username"} . "\";\n";
print FILE "\$password = \"" . $input{"password"} . "\";\n\n";

print FILE "# Data source name\n\n";
print FILE "\$dsn = \"DBI:mysql:database=\$database;host=\$host;port=\$port\";\n";

#############################################################################################################################################

close(FILE);

# Save config info in javascript format
#

#open(FILE, ">" . $input{wwwRoot} "/js/lux_config.js");
#print FILE "var indexRoot = \"$input{indexRoot}\";\n";
#print FILE "var cgiRoot = \"$input{cgiRoot}\";\n";
#print FILE "var wwwRoot = \"$input{wwwRoot}\";\n";
#close(FILE);

print "Location: $input{\"cgiRoot\"}/lux.pl\n\n";
