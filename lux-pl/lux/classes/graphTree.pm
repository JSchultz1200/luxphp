# Fathom Tree Class

package graphTree;
use DBI;

sub new
{
        my ($class) = @_;

        my $self =
        {
                _arrObjects => [ ],
                _arrFiles => [ ],
                _arrGlobals => [ ],
                _arrSessionVars => [ ],
		_strCurrentLine => undef,
		_arrEntityRecordSet => [ ],
        };

        bless $self, $class;
        return $self;
}

sub currentLine
{
        my ( $self, $strCurrentLine ) = @_;
        $self->{_strCurrentLine} = $strCurrentLine if defined($strCurrentLine);
        return $self->{_strCurrentLine};
}

# Removes duplicate entries from member arrays
# This method (foreach) preserves the order in which matches occur
#
sub uniqArrays
{
	my ($self) = @_;


	##############################################
	# Select distinct objects
	##############################################

	my @arrUnique = ();
	my %Seen   = ();

	foreach my $element(@{$self->{_arrObjects}})
	{
		next if $Seen{$element}++;
		push (@arrUnique, $element);
	}

	@{$self->{_arrObjects}} = @arrUnique;


	#############################################
	# Select distinct file includes
	#############################################

        my @arrUnique = ();
        my %Seen   = ();

        foreach my $element(@{$self->{_arrFiles}})
        {
                next if $Seen{$element}++;
                push (@arrUnique, $element);
        }

        @{$self->{_arrFiles}} = @arrUnique;


	############################################
	# Select distinct globals
	############################################

        my @arrUnique = ();
        my %Seen   = ();

        foreach my $element(@{$self->{_arrGlobals}})
	{
		next if $Seen{$element}++;
		push (@arrUnique, $element);
	}

	@{$self->{_arrGlobals}} = @arrUnique;

	###########################################
	# Select distinct session variables
	###########################################
	my @arrUnique = ();
	my %Seen   = ();

        foreach my $element(@{$self->{_arrSessionVars}})
        {
                next if $Seen{$element}++;
                push (@arrUnique, $element);
        }

	@{$self->{_arrSessionVars}} = @arrUnique;
}

###################################################
# FUNCTION: luxObjects
# DESCRIPTION: Highlights objects on the current
#	       line, i.e., "new objectName();" 
#
#
#
####################################################
sub luxObjects
{
	my ($self, $projectID) = @_;

	if($self->{_strCurrentLine} =~ m/new\s(.*?)\(.*?\)\;/)
	{
		$object = $1;

		# We can only lux objects that are not variables.
		if(index($object, "\$") == -1)
		{
			$self->{_strCurrentLine} =~ s/$object\(/<a class=\"lux_Object\" href=\"lux.pl?p=$projectID&q=$object&obj=true\">$object<\/a>\(/g;
		}
		#else
		#{
		#	print "failed object match: $object\n";
		#}
	}	
}

sub fathomObjects
{
	my ($self) = @_;

	if($self->{_strCurrentLine} =~ m/new\s(.*?)\(.*?\)\;/)
	{
		$_ = $self->{_strCurrentLine};
		my @arrObjects = m/new\s(.*?)\(.*?\)\;/g;

		foreach $object(@arrObjects)
		{
			$object =~ s/new\s//;
			$object =~ s/\(.*?\);//;

			push (@{$self->{_arrObjects}}, $object);
		}
	}
}

sub fathomFiles
{
	my ($self) = @_;

	if($self->{_strCurrentLine} =~ m/\binclude[\s]?\(/)
	{
		$_ = $self->{_strCurrentLine};
		my @arrFiles = m/\binclude[\s]?\((.*?)\)\;/g;

		foreach $file(@arrFiles)
		{
			$file =~ s/\"//g;
			$file =~ s/\'//g;

			push (@{$self->{_arrFiles}}, $file);
		}
	}
	elsif($self->{_strCurrentLine} =~ m/require[\s]\(/)
	{
		$_ = $self->{_strCurrentLine};
		my @arrFiles = m/require[\s]\((.*?)\)\;/g;

		foreach $file(@arrFiles)
		{
			$file =~ s/\"//g;
			$file =~ s/\'//g;

			push (@{$self->{_arrFiles}}, $file);
		}
	}
}

sub fathomSessionVars
{
	my ($self) = @_;

	if($self->{_strCurrentLine} =~ m/\$_SESSION\[/)
	{
		$_ = $self->{_strCurrentLine};
		my @arrSessionVars = m/(\$_SESSION\[.*?\])/g;

		foreach $session(@arrSessionVars)
		{
			#$session =~ s/\$_SESSION\[//;
			$session =~ s/\"/\\\"/g;
			$session =~ s/\'/\\\'/g;

			push (@{$self->{_arrSessionVars}}, $session);
		}
	}
}

sub fathomGlobals
{
	my ($self) = @_;
	my (@arrGlobals);

	if($self->{_strCurrentLine} =~ m/global\s(.*?)[\s,;]/)
	{
		# More than one global is being called
		if($self->{_strCurrentLine} =~ m/,/)
		{
			@arrGlobals = split(/\,/, $self->{_strCurrentLine});
		}
		else
		{
			$_ = $self->{_strCurrentLine};
			@arrGlobals = m/global\s(.*?)[\s,;]/igx;
		}

		foreach $global(@arrGlobals)
		{
			$global =~ s/global\s//g;
			$global =~ s/\;//g;
			$global =~ s/\s//g;

			push (@{$self->{_arrGlobals}}, $global);
		}
	}
}

sub createFathomTree
{
	my ($self, $strFile) = @_;

	open(FILE, $strFile) or die "Couldn't open: $strFile";
	@strContent=<FILE>;

	foreach $line(@strContent)
	{
		# Set current line
		$self->currentLine($line);

		# Search for entity types:
		$self->fathomObjects();
		$self->fathomFiles();
		$self->fathomSessionVars();
		$self->fathomGlobals();
	}

	$self->uniqArrays();

	close(FILE);
}

# Queries the database for the entity relationships
# of a single file.
sub queryEntities
{
	my ($self, $strEntity, $strEntityType, $indexRoot, $dsn, $username, $password) = @_;
	my ($strQuery, $sth);

	# Connect to the database
	$dbh = DBI->connect($dsn, $username, $password);

	if($strEntityType eq "file")
	{
		$strQuery = "SELECT * FROM entityRelationships WHERE strFileID=md5('$strEntity')";
	}
	elsif($strEntityType eq "global")
	{
		$strQuery = "SELECT entityRelationships.strFileID, strType As strEntityType, REPLACE(strFile, '$indexRoot', '') As strRelationEntity, intRelationID, strRelationType";
		$strQuery = $strQuery . " FROM entityRelationships INNER JOIN fileSystem ON fileSystem.strFileID=entityRelationships.strFileID WHERE strEntityType='global' AND strRelationEntity='$strEntity'";
	}

        # Execute the query
        $sth = $dbh->prepare($strQuery);
        $sth->execute();

        while(my @record = $sth->fetchrow_array())
	{
		push (@{$self->{_arrEntityRecordSet}}, [@record]);
	}
}

# Query the entity relationships table in an inverted style
#
sub invertedQueryEntities
{
        my ($self, $strEntity, $strEntityType, $indexRoot, $dsn, $username, $password) = @_;
        my ($strQuery, $sth);

        # Connect to the database
        $dbh = DBI->connect($dsn, $username, $password);

        if($strEntityType eq "file")
        {
                $strQuery = "SELECT * FROM entityRelationships WHERE strRelationEntity='$strEntity'";
        }
        elsif($strEntityType eq "global")
        {
                $strQuery = "SELECT entityRelationships.strFileID, strType As strEntityType, REPLACE(strFile, '$indexRoot', '') As strRelationEntity, intRelationID, strRelationType WHERE strRelationEntity='$strEntity'";
        }

        # Execute the query
        $sth = $dbh->prepare($strQuery);
        $sth->execute();

        while(my @record = $sth->fetchrow_array())
        {
                push (@{$self->{_arrEntityRecordSet}}, [@record]);
        }
}

# Converts the entity relationships for a file
# into JSON format and prints them out.
sub printEntitiesJSON
{
	my ($self) = @_;
	my ($sizeOfEntityRecordSet, $x, $strRecord, $strJSON);

	$sizeOfEntitiyRecordSet = @{$self->{_arrEntityRecordSet}};

	$strJSON = "{\"entityRelationships\":[";

	for($x = 0; $x < $sizeOfEntitiyRecordSet; $x++)
	{
		$strRecord = "{\"strEntityType\": \"" . $self->{_arrEntityRecordSet}[$x][1] . "\", ";
		$strRecord = $strRecord . "\"strRelationEntity\": \"" . $self->{_arrEntityRecordSet}[$x][2] . "\", ";
		$strRecord = $strRecord . "\"strRelationID\": \"" . $self->{_arrEntityRecordSet}[$x][3] . "\", ";
		$strRecord = $strRecord . "\"strRelationType\": \"" . $self->{_arrEntityRecordSet}[$x][4] . "\"},";

		$strJSON = $strJSON . $strRecord;
	}

	chop($strJSON);

	$strJSON = $strJSON . "]}";

	print $strJSON;
}

1;
