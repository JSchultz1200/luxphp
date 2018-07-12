# Projects Class

package bookmarks;

eval {require DBI};

sub new
{
	my ($class, $dsn, $username, $password) = @_;

	my $self =
	{
		_arrBookmarks => [],
		_sizeOfBookmarks => 0,
		_arrBookmarkLines => [],
		_sizeOfBookmarkLines => 0,
		_dsn => $dsn,
		_strUsername => $username,
		_strPassword => $password
	};

	bless $self, $class;
}

# Gets the list of projects that have been defined in the database
sub getBookmarks
{
	my ($self) = @_;
	my ($strQuery, $dbh, $sth);

	# Connect to the database
	$dbh = DBI->connect($self->{_dsn}, $self->{_strUsername}, $self->{_strPassword});

	# Construct the query
	$strQuery = "SELECT intBookmarkID,dateBookmarked,strProject,bookmarks.intProjectID,strQuery,strFile,intLineNumber,strLine FROM bookmarks ";
	$strQuery .= "INNER JOIN projects ON projects.intProjectID=bookmarks.intProjectID ORDER BY intBookmarkID";

	# Prepare and execute the command
	$sth = $dbh->prepare($strQuery);
	$sth->execute();

        while(my @record = $sth->fetchrow_array())
        {
                push (@{$self->{_arrBookmarks}}, [@record]);
        }
 
	# Finish up and disconnect
	$sth->finish();
	$dbh->disconnect();

	$self->{_sizeOfBookmarks} = @{$self->{_arrBookmarks}};
}

sub getBookmarkLines
{
	my ($self, $intProjectID, $strFile) = @_;
	my ($strQuery, $dbh, $sth);

	# Connect to the database
        $dbh = DBI->connect($self->{_dsn}, $self->{_strUsername}, $self->{_strPassword});

        # Construct the query
        $strQuery = "SELECT DISTINCT intLineNumber FROM bookmarks WHERE strFile='" . $strFile . "' AND intProjectID=" . $intProjectID;

        # Prepare and execute the command
        $sth = $dbh->prepare($strQuery);
        $sth->execute();

        while(my @record = $sth->fetchrow_array())
        {
                push (@{$self->{_arrBookmarkLines}}, [@record]);
        }

        # Finish up and disconnect
        $sth->finish();
        $dbh->disconnect();

	$self->{_sizeOfBookmarkLines} = @{$self->{_arrBookmarkLines}};
}

sub addBookmark
{
	my ($self, $strFile, $intProjectID, $intLineNumber, $strSearchQuery) = @_;
	my ($strQuery, $dbh, $sth);

	# Connect to the database
	$dbh = DBI->connect($self->{_dsn}, $self->{_strUsername}, $self->{_strPassword});
	
	$strQuery = "INSERT INTO bookmarks SELECT '', NULL, false, Now(), " . $intProjectID . ",'" . $strSearchQuery  . "','" . $strFile . "'," . $intLineNumber . ",";
	$strQuery .= "(SELECT substring_index(substring_index(strContent, '\\n'," . $intLineNumber . "), '\\n', -1) FROM fileSystem WHERE "; 
	$strQuery .= "strFile=CONCAT((SELECT strProjectRoot FROM projects WHERE intProjectID=" . $intProjectID . "), '" . $strFile . "'))";

	print $strQuery;
	# Execute the query
	$dbh->do($strQuery);

	# Disconnect
	$dbh->disconnect();
}

1;
