# Note Class

package notes;
use DBI;

sub new
{
        my ($class) = @_;

        my $self =
        {
                _arrNotesRecordSet => [ ],
		_sizeOfNotesRecordSet => 0
        };

        bless $self, $class;
        return $self;
}
 
# Gets all notes for a particular project ID and type
sub getNotes
{
        my ($self, $intProjectID, $noteType, $dsn, $username, $password) = @_;
        my ($strQuery, $sth, $size);

        # Connect to the database
        $dbh = DBI->connect($dsn, $username, $password);
	
	# Perform another inner join to get the actual file name
	# This is messy and the fileID md5 should be replaced with the relative file name
	# and the project ID column should be added to the notes table, like the bookmarks 
	# table.

        $strQuery = "SELECT intNoteID, strTitle, strText, REPLACE(strFile, (SELECT strProjectRoot FROM projects WHERE intProjectID=" . $intProjectID . "), \"\") as strFile, intLineNumberStart, intLineNumberEnd, intProjectID, strNoteType FROM notes INNER JOIN fileSystem ON notes.strFileID=fileSystem.strFileID";
	$strQuery .= " WHERE strNoteType='" . $noteType . "' AND intProjectID=" . $intProjectID;

        # Execute the query
        $sth = $dbh->prepare($strQuery);
        $sth->execute();

        while(my @record = $sth->fetchrow_array())
        {
                push (@{$self->{_arrNotesRecordSet}}, [@record]);
        }

        # Finish up and disconnect
        $sth->finish();

        # Disconnect from the db
        $dbh->disconnect();

        $self->{_sizeOfNotesRecordSet} = @{$self->{_arrNotesRecordSet}};
}

# Gets a list of note types
sub getNoteTypes
{
	my ($self, $dsn, $username, $password) = @_;
        my ($strQuery, $sth, $size);

        # Connect to the database
        $dbh = DBI->connect($dsn, $username, $password);

        $strQuery = "SELECT DISTINCT strNoteType FROM notes";

        # Execute the query
        $sth = $dbh->prepare($strQuery);
        $sth->execute();

        while(my @record = $sth->fetchrow_array())
        {
                push (@{$self->{_arrNotesRecordSet}}, [@record]);
        }

        # Finish up and disconnect
        $sth->finish();

        # Disconnect from the db
        $dbh->disconnect();

        $self->{_sizeOfNotesRecordSet} = @{$self->{_arrNotesRecordSet}};
}

# Queries the database for the notes
# of a single file.
sub queryNotes
{
        my ($self, $intProjectID, $dsn, $username, $password) = @_;
        my ($strQuery, $sth, $size);

        # Connect to the database
        $dbh = DBI->connect($dsn, $username, $password);

        $strQuery = "SELECT strTitle, strText, intLineNumberStart, intLineNumberEnd, strNoteType, intNoteID FROM notes WHERE intProjectID=$intProjectID";

        # Execute the query
        $sth = $dbh->prepare($strQuery);
        $sth->execute();

        while(my @record = $sth->fetchrow_array())
        {
                push (@{$self->{_arrNotesRecordSet}}, [@record]);
        }

        # Finish up and disconnect
        $sth->finish();

        # Disconnect from the db
        $dbh->disconnect();

	$self->{_sizeOfNotesRecordSet} = @{$self->{_arrNotesRecordSet}};	
}

# Queries a single note based
# on the note id
sub queryNoteByID
{
        my ($self, $intNoteID, $dsn, $username, $password) = @_;
        my ($strQuery, $sth);

        # Connect to the database
        $dbh = DBI->connect($dsn, $username, $password);

        $strQuery = "SELECT strTitle, strText, intLineNumberStart, intLineNumberEnd, strNoteType, intNoteID FROM notes WHERE intNoteID='" . $intNoteID . "'";

        # Execute the query
        $sth = $dbh->prepare($strQuery);
        $sth->execute();

        while(my @record = $sth->fetchrow_array())
        {
                push (@{$self->{_arrNotesRecordSet}}, [@record]);
        }

        # Finish up and disconnect
        $sth->finish();

        # Disconnect from the db
        $dbh->disconnect();

	$self->{_sizeOfNotesRecordSet} = 1;
}

# Converts the notes for a file
# into JSON format and prints them out.
sub printNotesJSON
{
        my ($self) = @_;
        my ($sizeOfNotesRecordSet, $x, $strRecord, $strJSON);

        $sizeOfNotesRecordSet = @{$self->{_arrNotesRecordSet}};

        $strJSON = "{\"notes\":[";

        for($x = 0; $x < $sizeOfNotesRecordSet; $x++)
        {
                $strRecord = "{\"strTitle\": \"" . $self->{_arrNotesRecordSet}[$x][0] . "\",";
                $strRecord = $strRecord . "\"strText\": \"" . $self->{_arrNotesRecordSet}[$x][1] . "\",";
		$strRecord = $strRecord . "\"intLineNumberStart\": \"" . $self->{_arrNotesRecordSet}[$x][2] . "\",";
		$strRecord = $strRecord . "\"intLineNumberEnd\": \"" . $self->{_arrNotesRecordSet}[$x][3] . "\",";
		$strRecord = $strRecord . "\"strNoteType\": \"" . $self->{_arrNotesRecordSet}[$x][4] . "\",";
                $strRecord = $strRecord . "\"intNoteID\": \"" . $self->{_arrNotesRecordSet}[$x][5] . "\"},";

                $strJSON = $strJSON . $strRecord;
        }

        chop($strJSON);

        $strJSON = $strJSON . "]}";

        print $strJSON;
}

# Deletes a note from the database
#
sub deleteNote
{
	my ($self, $intNoteID, $dsn, $username, $password) = @_;
	my ($strQuery);

        # Connect to the database
        $dbh = DBI->connect($dsn, $username, $password);

	# Construct the query
	$strQuery = "DELETE FROM notes WHERE intNoteID='" . $intNoteID . "'";

	# Execute the query
	$dbh->do($strQuery);

        # Disconnect from the db
        $dbh->disconnect();
}

# Creates a note
#
sub createNote
{
        my ($self, $strTitle, $strText, $strFile, $intLineNumberStart, $intLineNumberEnd, $strNoteType, $dsn, $username, $password) = @_;
        my ($strQuery);

        # Connect to the database
        $dbh = DBI->connect($dsn, $username, $password);

        # Construct the query
        $strQuery = "INSERT INTO notes VALUES('', '" . $strTitle . "','" . $strText . "',md5('" . $strFile . "'),'" . $intLineNumberStart . "','" . $intLineNumberEnd . "','" . $strNoteType . "')";

        # Execute the query
        $dbh->do($strQuery);

        # Disconnect from the db
        $dbh->disconnect();
}

# Edits a note
#
sub editNote
{
	my ($self, $intNoteID, $strTitle, $strText, $intLineNumberStart, $intLineNumberEnd, $strNoteType, $dsn, $username, $password) = @_;
	my ($strQuery);

        # Connect to the database
        $dbh = DBI->connect($dsn, $username, $password);

        # Construct the query
        $strQuery = "UPDATE notes SET strTitle='" . $strTitle . "',"
		  . "strText='" . $strText . "',"
		  . "intLineNumberStart='" . $intLineNumberStart . "',"
		  . "intLineNumberEnd='" . $intLineNumberEnd . "',"
		  . "strNoteType='" . $strNoteType . "' "
		  . "WHERE intNoteID='" .$intNoteID . "'";

	# print $strQuery;

        # Execute the query
        $dbh->do($strQuery);

        # Disconnect from the db
        $dbh->disconnect();
}

1;
