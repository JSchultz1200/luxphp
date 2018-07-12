#!/usr/bin/perl

use CGI;
use DBI;
use File::Find;
use Cwd;
push @INC, getcwd() . "/classes";

require "config/config.pl";
require "graphTree.pm";

# Connect to the database
$dbh = DBI->connect($dsn, $username, $password);

my %hashDB;
my ($cgi) = new CGI;
my ($boolIsBrowser, $boolModifiedOnly, $boolFullIndex, $strUpdateOneFile);

# Get all our form input values
for $key ($cgi->param())
{
        $input{$key} = $cgi->param($key);
}

# We are being called from the browser
if(defined($input{"boolFullIndex"}) || defined($input{"boolModifiedOnly"}) || defined($input{"strUpdateOneFile"}))
{
	print "Content-type: text/html\n\n";
	$boolIsBrowser = true;
	$boolModifiedOnly = $input{"boolModifiedOnly"};
	$strUpdateOneFile = $input{"strUpdateOneFile"};
	$boolFullIndex = $input{"boolFullIndex"};

	if($boolModifiedOnly eq "")
        {
                $boolModifiedOnly = false;
        }

        if($boolFullIndex eq "")
        {
                $boolFullIndex = false;
        }
}

# We are being called from the command line
else
{
	$boolIsBrowser = false;

	if(!@ARGV)
	{
		showUsage();
	}

	foreach $argument(@ARGV)
	{
		if($argument =~ m/-modified=/)
		{
			$argument =~ s/-modified=//i;
			$boolModifiedOnly = $argument;
		}

		if($argument =~ m/-file=/)
		{
			$argument =~ s/-file=//i;
			$strUpdateOneFile = $argument;
		}

		if($argument =~ m/-help/ || $argument =~ m/--help/)
		{
			showUsage();
		}

		if($argument =~ m/-fullindex=/)
		{
			$argument =~ s/-fullindex=//i;
			$boolFullIndex = $argument;
		}
	}

	if($boolModifiedOnly eq "")
	{
		$boolModifiedOnly = false;
	}

	if($boolFullIndex eq "")
	{
		$boolFullIndex = false;
	}
}

##################################################################################################

# Index all files
# If we are called with no arguments this will re-index all files
if($boolModifiedOnly eq false && $strUpdateOneFile eq "" && $boolFullIndex eq true)
{
	deleteFileSystem();
	deleteEntityRelationships();
	find({ wanted => \&indexAllFiles, follow => 1, follow_skip => 2 }, $indexRoot);
}

# Index modified files
elsif($boolModifiedOnly eq true)
{
	indexModifiedFiles();
}

# Index one file
elsif($strUpdateOneFile ne "")
{
	saveIndex($strUpdateOneFile);
}

# Disconnect from the db
$dbh->disconnect();

# Re-direct to main page if necessary
if($boolIsBrowser eq true)
{
        print "Location: $cgiRoot/lux.pl\n\n";
}

###################################################################################################

# Index all files
sub indexAllFiles
{
	my ($strFile) = $File::Find::name;
	saveIndex($strFile, false);
	indexEntities($strFile, false);
}

# Index only modified files
sub indexModifiedFiles
{
	my ($strQuery, $sizeOfArrDB, $x, $sth, $timeStamp, $file);

	$strQuery = "SELECT strFile, UNIX_TIMESTAMP(dateModified) from fileSystem";
	$sth = $dbh->prepare($strQuery);
	$sth->execute();

	while(my @record = $sth->fetchrow_array())
	{
		# hashDB{filename} = time stamp
		$hashDB{$record[0]} = $record[1];
	}

	$sizeOfHashDB = keys(%hashDB);
	$sth->finish();

	# Loop through each record and open each file
	foreach $file(%hashDB)
	{
		$timeStamp = (stat($file))[9];

		# Compare the recordset timestamp with the file timestamp
		if($timeStamp ne $hashDB{$file})
		{
			# File does not exist anymore
			if($timeStamp eq "")
			{
				# If we can't stat the file then it has been deleted. remove from db
				print "removing: " . $file . "\n";
				removeIndex($file);
			}

			# File has been modified
			else
			{
				saveIndex($file, true);
				indexEntities($file, true);
			}
		}
	}

	find({ wanted => \&indexNewFiles, follow => 1, follow_skip => 2 }, $indexRoot);
}

# Index newly created files that are not in the database
sub indexNewFiles
{
	my ($strFile) = $File::Find::name;

	# File exists on disk, but not in the DB
	if(!defined( $hashDB{$strFile} ) && ! -d $strFile)
	{
		saveIndex($strFile, false);
		indexEntities($strFile, false);
	}
}

###################################################################################################

# Code handles inserting/updating a record
sub saveIndex
{
	my ($strFile, $boolIsUpdate) = @_;
	my ($strContent, $dateModified, $strQuery, $strFileType);

	# Search only defined file extensions
	# Reduce file.name.php to .php:
	$_ = $strFile;
	$strFileType = /(\.[^.]*?)$/;
	$strFileType = $1;

	if (defined($fileExtensions{$strFileType}))
	{
		local $/;
		my $boolIsOpen = open(FILE, $strFile);

		if(! $boolIsOpen)
		{
			print "Error opening file: $strFile\n";
			exit(1);
		}

		$strContent=<FILE>;

		# Escape \ ' "
		$strContent =~ s/\\/\\\\/g;
		$strContent =~ s/\'/\\\'/g;
		$strContent =~ s/\"/\\\"/g;

		# Get the modified date for the file
		# We will convert it from a unix time stamp in the query
		$dateModified = (stat(FILE))[9];

		if($boolIsUpdate eq true)
		{
			$strQuery = "UPDATE fileSystem SET dateModified=FROM_UNIXTIME('" . $dateModified . "'), strContent='" . $strContent . "' WHERE strFile='" . $strFile . "'";
			print "updating: $strFile\n";
		}
		else
		{	
			$strQuery = "INSERT INTO fileSystem (strFileID, dateModified, strFile, strContent) VALUES (md5('$strFile'),FROM_UNIXTIME('" . $dateModified . "'),'" . $strFile . "','" . $strContent . "')";
			print "inserting: $strFile\n";
		}

		$dbh->do($strQuery);

		close(FILE);
		$strContent = "";
	}
	else
	{
		print "skipping - filetype not defined: " . $strFile . ", " . $strFileType . "\n";
	}
}

# Index entities (objects, globals, files, session vars) that exist within a file
sub indexEntities
{
	my ($strFile, $boolIsUpdate) = @_;
	my ($strQuery, $strFileType);

	# Index only php files
	# Reduce file.name.php to .php:
	$_ = $strFile;
	$strFileType = /(\.[^.]*?)$/;
	$strFileType = $1;

	if($strFileType eq ".php")
	{
		$objGraphTree = new graphTree();
		$objGraphTree->createFathomTree($strFile);
	
		if($boolIsUpdate eq true)
		{
			$strQuery = "DELETE FROM entityRelationships WHERE strFileID=md5('$strFile')";
			$dbh->do($strQuery);
		}

		foreach $object(@{$objGraphTree->{_arrObjects}})
		{
			$strQuery = "INSERT INTO entityRelationships VALUES (md5('$strFile'), 'object', '$object', '', NULL)";
			$dbh->do($strQuery);
		}

		foreach $file(@{$objGraphTree->{_arrFiles}})
		{
			$strQuery = "INSERT INTO entityRelationships VALUES (md5('$strFile'), 'file', '$file', '', NULL)";
			$dbh->do($strQuery);
		}

		foreach $sessionVar(@{$objGraphTree->{_arrSessionVars}})
		{
			$strQuery = "INSERT INTO entityRelationships VALUES (md5('$strFile'), 'session', '$sessionVar', '', NULL)";
			$dbh->do($strQuery);
		}

		foreach $global(@{$objGraphTree->{_arrGlobals}})
		{
			$strQuery = "INSERT INTO entityRelationships VALUES (md5('$strFile'), 'global', '$global', '', NULL)";
			$dbh->do($strQuery);
		}
	}
}

# Removes a file entry from the database
sub removeIndex
{
	my ($strFile) = @_;
	my ($strQuery);

	$strQuery = "DELETE FROM fileSystem WHERE strFile='" . $strFile . "'";
	print "removing: $strFile from fileSystem table\n";
	$dbh->do($strQuery);

	$strQuery = "DELETE FROM entityRelationships WHERE strFileID=md5('$strFile')";
	print "removing: $strFile from entityRelationships table\n";
	$dbh->do($strQuery);
}

# Delete all records from the fileSystem table
sub deleteFileSystem
{
	my ($strQuery);

	$strQuery = "DELETE FROM fileSystem";
	print "removing all records from the fileSystem table\n";
	$dbh->do($strQuery);
}

sub deleteEntityRelationships
{
        my ($strQuery);

        $strQuery = "DELETE FROM entityRelationships";
        print "removing all records from the entityRelationships table\n";
        $dbh->do($strQuery);

	$strQuery = "ALTER TABLE entityRelationships AUTO_INCREMENT=0";
	print "reseting AUTO_INCREMENT to 0 for entityRelationships\n";
	$dbh->do($strQuery);
}

# Shows command line usage info
sub showUsage
{
        print "\nUsage: ./mysqlIndexer.pl -option=value\n";
        print "  -modified=true          -> Only update modified, deleted, or newly created files\n";
	print "  -file=/dirpath/file.php -> Re-index a single file\n";
	print "  -fullindex=true         -> Remove everything from the DB and (re-)index the entire indexRoot dir\n";
	print "  -help			  -> Show this info\n\n";
	
	exit(1);
}
