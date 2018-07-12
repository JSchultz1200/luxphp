#!/usr/bin/perl

# Root directory for searches and indexing. No trailing slashes here please! These paths are system absolute paths.

$searchRoot = "/home/josh/projects";
$indexRoot = "/home/josh/projects";

# Root directory of the files where lux.css and supporting JS will be stored. This is web relative and not system absolute.
# DO NOT INCLUDE A TRAILING SLASH AT THE END OF THIS LOCATION

$wwwRoot = "/lux";

# Root directory for cgi-bin. Most likely /cgi-bin (i.e., relative to the web browser and not an absolute system path)

$cgiRoot = "/pl/lux";

# List of file types to search through. You may want to add or remove
# some of these. To add an icon association for a new file type simply
# include the icon in the images directory and name it as icon.filetype.gif

%fileExtensions = (".php", ".php");

# Boolean determines whether to do a MySQL based search or a disk based search

$boolHitDisk = false;

# MySQL Database Settings:

$database = "luxphp";
$host = "localhost";
$port = "3306";
$username = "";
$password = "";

# Data source name

$dsn = "DBI:mysql:database=$database;host=$host;port=$port";
