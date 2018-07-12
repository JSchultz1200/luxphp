# Projects Class

package projects;

eval {require DBI};

sub new
{
	my ($class, $dsn, $username, $password) = @_;

	my $self =
	{
		_arrProjects => [ ],
		_intAssociation => undef,
		_dsn => $dsn,
		_strUsername => $username,
		_strPassword => $password
	};

	bless $self, $class;
}

# Gets the list of projects that have been defined in the database
sub getProjects
{
	my ($self) = @_;

	my ($strQuery, $dbh, $sth, $strProject);

	# Connect to the database
	$dbh = DBI->connect($self->{_dsn}, $self->{_strUsername}, $self->{_strPassword});

	# Construct the query
	$strQuery = "SELECT * FROM projects ORDER BY intDisplayOrder";

	# Prepare and execute the command
	$sth = $dbh->prepare($strQuery);
	$sth->execute();

        while(my @record = $sth->fetchrow_array())
        {
                push (@{$self->{_arrProjects}}, [@record]);
        }

	# Finish up and disconnect
	$sth->finish();
	$dbh->disconnect();
}

# Gets the project association for a particular file
sub getAssociation
{
	my ($self, $strFile, $indexRoot) = @_;
	my ($strQuery, $dbh, $sth, $result);

        # Connect to the database
        $dbh = DBI->connect($self->{_dsn}, $self->{_strUsername}, $self->{_strPassword});

	$strQuery = "SELECT intProjectID FROM fileSystem WHERE strFile='" . $indexRoot . $strFile . "'";

	# Prepare and execute the query
        $sth = $dbh->prepare($strQuery);
        $sth->execute();

        $self->{_intAssociation} = $sth->fetchrow();

        # Finish up and disconnect
        $sth->finish();
        $dbh->disconnect();
}

# Prints a drop down selection menu with a list of all the defined projects
# This is for the display file page
sub printProjectsDropDown
{
	my ($self, $strFile, $selectedProjectRoot) = @_;
	my ($isSelected, $project, $projectRoot);

	# If we have at least one project then print the drop down

	print "<div class=\"lux_projectsDropDown\">\n";
	print "File Association: <select name=\"projects\">\n";

        $sizeOfProjects = @{$self->{_arrProjects}};

        for($x = 0; $x < $sizeOfProjects; $x++)
        {
		$projectID = $self->{_arrProjects}[$x][0];
		$project = $self->{_arrProjects}[$x][2];
		$projectRoot = $self->{_arrProjects}[$x][3];

		$isSelected = ($selectedProjectRoot eq $projectRoot) ? " selected" : "";
		print "   <option name=\"$project\" value=\"$projectID\" onClick=\"updateProjectAssociation('$selectedProjectRoot/$strFile', '$projectID');\"" . $isSelected . ">$project</option>\n";
	}

	print "</select>\n";
	print "</div>\n";
}

# This prints a dropdown for the index page
#
sub printProjectsDropDownSearch
{
        my ($self, $selectedProjectID) = @_;
        my ($isSelected, $project, $projectRoot);

        # If we have at least one project then print the drop down

        print "<div class=\"lux_projectsDropDownSearch\">\n";
        print "Search Project: <select name=\"projects\" id=\"lux_projectsDropDownSearchID\">\n";

        $sizeOfProjects = @{$self->{_arrProjects}};

        for($x = 0; $x < $sizeOfProjects; $x++)
        {
		$projectID = $self->{_arrProjects}[$x][0];
		$project = $self->{_arrProjects}[$x][2];
		$projectRoot = $self->{_arrProjects}[$x][3];

                $isSelected = ($selectedProjectID eq $projectID) ? " selected" : "";
                print "   <option name=\"$project\" value=\"$projectID\"" . $isSelected . ">$project</option>\n";
        }

        print "</select>\n";
        print "</div>\n";
}

sub updateProjectAssociation
{
	my ($self, $strFile, $intProjectID) = @_;
	my ($strQuery, $dbh, $sth);

	# Connect to the database
	$dbh = DBI->connect($self->{_dsn}, $self->{_strUsername}, $self->{_strPassword});
	
	$strQuery = "UPDATE fileSystem SET intProjectID='" . $intProject . "' WHERE strFile='" . $strFile . "'";

	# Execute the query
	$dbh->do($strQuery);

	# Disconnect
	$dbh->disconnect();
}

sub getProjectRootByID
{
	my ($self, $projectID) = @_;
	my ($strQuery, $dbh, $sth, $result);

	# Connect to the database
	$dbh = DBI->connect($self->{_dsn}, $self->{_strUsername}, $self->{_strPassword});

	$strQuery = "SELECT strProjectRoot FROM projects WHERE intProjectID=" . $projectID;

        # Prepare and execute the query
        $sth = $dbh->prepare($strQuery);
        $sth->execute();

        $result = $sth->fetchrow();

        # Finish up and disconnect
        $sth->finish();
        $dbh->disconnect();

	return $result;
}
1;
