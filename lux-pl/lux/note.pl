#!/usr/bin/perl

use CGI;
use Cwd;
push @INC, getcwd() . "/classes";

require "notes.pm";
require "projects.pm";
require "config/config.pl";

my ($cgi) = new CGI;
my ($strEntity, $strEntityType, $intProjectID);

# Get all our form input values
for $key ($cgi->param())
{
        $input{$key} = $cgi->param($key);
}

print "Content-type: text/html\n\n";

if($input{file} ne "")
{
	$intProjectID = $input{p};

	$objProjects = new projects($dsn, $username, $password);
	$strProjectRoot = $objProjects->getProjectRootByID($intProjectID);

	$strFile = $strProjectRoot . $input{file};
	$strEntityType = "file";
}

$objNote = new notes();

if($input{action} eq "createNote")
{
	$objNote->createNote($input{strTitle}, $input{strText}, $strFile, $input{intLineNumberStart}, $input{intLineNumberEnd}, $input{strNoteType}, $dsn, $username, $password);
}
elsif($input{action} eq "editNote")
{
	$objNote->editNote($input{intNoteID}, $input{strTitle}, $input{strText}, $input{intLineNumberStart}, $input{intLineNumberEnd}, $input{strNoteType}, $dsn, $username, $password);
}
elsif($input{action} eq "queryNotes")
{
	$objNote->queryNotes($intProjectID, $dsn, $username, $password);
	$objNote->printNotesJSON();
}
elsif($input{action} eq "queryNoteByID")
{
	$objNote->queryNoteByID($input{intNoteID}, $dsn, $username, $password);
	$objNote->printNotesJSON();
}
elsif($input{action} eq "deleteNote")
{
	$objNote->deleteNote($input{intNoteID}, $dsn, $username, $password);
}
