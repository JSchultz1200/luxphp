# Fathom Database/File Class

package fathom;

eval {require DBI};
use lineSet;
use luxParser;
use notes;
use bookmarks;

sub new
{
        my ($class, $strSearchPattern, $boolIsRegExpSearch, $boolIsFile, $boolCaseSensitive, $strFile, $strDirectoryRestriction, $searchRoot, $wwwRoot, $indexRoot, $projectID, $fileExtensions, $dsn, $username, $password) = @_;

        my $self =
        {
                _arrRecordSet => [ ],
		_arrLineSet => [ ],
		_strSearchPattern => quotemeta($strSearchPattern),
		_strUnEscapedSearchPattern => $strSearchPattern,
		_strQuotesEscapedSearchPattern => undef,
		_boolCaseSensitive => $boolCaseSensitive,
		_boolIsRegExpSearch => $boolIsRegExpSearch,
		_boolIsFile => $boolIsFile,
		_strFile => $strFile,
		_strDirectoryRestriction => $strDirectoryRestriction,
		_searchRoot => $searchRoot,
		_wwwRoot => $wwwRoot,
		_indexRoot => $indexRoot,
		_projectID => $projectID,
		_fileExtensions => $fileExtensions,
		_strUsername => $username,
		_strPassword => $password,
		_dsn => $dsn, 
		_intFileCounter => 0,
		_objNotes => undef,
		_objBookmarks => undef,
	};

        bless $self, $class;

	# Replace Quotes with %22
	if($self->{_strUnEscapedSearchPattern} =~ m/\"/g)
	{
		$self->{_strQuotesEscapedSearchPattern} = $self->{_strUnEscapedSearchPattern};
		$self->{_strQuotesEscapedSearchPattern} = s/\"/\%22/g;
	}
	else
	{
		$self->{_strQuotesEscapedSearchPattern} = $self->{_strUnEscapedSearchPattern};
	}

        return $self;
}

# Queries the mysql database for a search pattern
# and stores the returned rows in a recordset array.
#

sub FathomDatabase
{
	my ($self, $boolIsFullText, $intRowsPerPage, $intCurPage) = @_;

	my ($strQuery, $x, $dbh, $sth, $strMySQLSearchPattern, $intOffset);
	my (%fileExtensions) = %{$self->{_fileExtensions}};

	# Specific File Search
	if($self->{_boolIsFile} eq true)
	{
		$strQuery = "SELECT strFile, strContent FROM fileSystem WHERE strFile='$self->{_searchRoot}$self->{_strFile}'";
	}

	# General Search
	else
	{
		# Escape % and _
		$strMySQLSearchPattern = $self->{_strSearchPattern};
		$strMySQLSearchPattern =~ s/_/\\_/g;

		# Construct the query
		if($boolIsFullText eq true)
		{
			$strQuery = "SELECT strFile, strContent FROM fileSystem WHERE match(strContent) against ('" . $strMySQLSearchPattern . "')";
		}
		else
		{
			$strQuery = "SELECT strFile, strContent FROM fileSystem WHERE strContent LIKE '%" . $strMySQLSearchPattern . "%'";

			# Append COLLATE latin1_bin for case sensitive search
			if($self->{_boolCaseSensitive} eq true)
			{
				$strQuery = $strQuery . " COLLATE latin1_bin";
			}
		}

		$x = 0;

		# Loop through file extensions and append defined extentions to WHERE clause
		foreach $extension(%fileExtensions)
		{
			if($x == 0)
			{
				$strAppendQuery = " AND (";
			}

			$strAppendQuery = $strAppendQuery . "strFile LIKE '\%$extension' OR ";

			$x++;
		}

		# Append ) and remove last OR
		$strAppendQuery = $strAppendQuery . ")";
		$strAppendQuery =~ s/ OR \)/) /o;

		# Append accepted file types to the query's WHERE clause
		$strQuery = $strQuery . $strAppendQuery;

		# No directory search restriction means we use the search root as the default 
		if($self->{_strDirectoryRestriction} eq "")
		{
			$strQuery = $strQuery . "AND (strFile LIKE '" . $self->{_searchRoot} . "%')";
		}

		# Append directory search restriction to the query's WHERE clause
		else
		{
			# User must prefix the directory restriction with a slash, i.e., dir:/users/home
			$strQuery = $strQuery . "AND (strFile LIKE '" . $self->{_searchRoot} . $self->{_strDirectoryRestriction} . "%')";
		}

		# Append QUERY LIMIT if applicable
		if($intRowsPerPage > -1)
		{
			$intOffset = ($intCurPage - 1) * $intRowsPerPage;
			$strQuery = $strQuery . " LIMIT $intOffset, $intRowsPerPage";
		}

		##  print $strQuery;
	}

	# Connect to the database
        $dbh = DBI->connect($self->{_dsn}, $self->{_strUsername}, $self->{_strPassword});

        # The text column selected in this query must
        # not be longtext or else perl dbd will try to
        # allocate 4 gigs of ram to store the result in.

	# Execute the query
        $sth = $dbh->prepare($strQuery);
        $sth->execute();

	# Loop through records and assign to recordset array
	# May want to use this method with a cursor:
	# http://archive.netbsd.se/?ml=pgsql-general&a=2005-04&t=868414
	while(my @record = $sth->fetchrow_array())
	{
		push (@{$self->{_arrRecordSet}}, [@record]);
	}

	# Finish up and disconnect 
	$sth->finish();
	$dbh->disconnect();
}

# This function queries the number of rows for a 
# specific query so we can page results appropriately
#

sub FathomDatabaseCount
{
	my ($self, $boolIsFullText) = @_;

	my ($strQuery, $x, $dbh, $sth, $strMySQLSearchPattern, $intCount);
	my (%fileExtensions) = %{$self->{_fileExtensions}};

	# Specific File Search
	if($self->{_boolIsFile} eq true)
	{
		$strQuery = "SELECT strFile, strContent FROM fileSystem WHERE strFile='$self->{_searchRoot}$self->{_strFile}'";
	}

	# General Search
	else
	{
		# Escape % and _
		$strMySQLSearchPattern = $self->{_strSearchPattern};
		$strMySQLSearchPattern =~ s/_/\\_/g;

		# Construct the query
		if($boolIsFullText eq true)
		{
			$strQuery = "SELECT COUNT(strFile) FROM fileSystem WHERE match(strContent) against ('" . $strMySQLSearchPattern . "')";
		}
		else
		{
			$strQuery = "SELECT COUNT(strFile) FROM fileSystem WHERE strContent LIKE '%" . $strMySQLSearchPattern . "%'";

			# Append COLLATE latin1_bin for case sensitive search
			if($self->{_boolCaseSensitive} eq true)
			{
				$strQuery = $strQuery . " COLLATE latin1_bin";
			}
		}

		$x = 0;

		# Loop through file extensions and append defined extentions to WHERE clause
		foreach $extension(%fileExtensions)
		{
			if($x == 0)
			{
				$strAppendQuery = " AND (";
			}

			$strAppendQuery = $strAppendQuery . "strFile LIKE '\%$extension' OR ";

			$x++;
		}

		# Append ) and remove last OR
		$strAppendQuery = $strAppendQuery . ")";
		$strAppendQuery =~ s/ OR \)/) /o;

		# Append accepted file types to the query's WHERE clause
		$strQuery = $strQuery . $strAppendQuery;

		# No directory search restriction means we use the search root as the default
		if($self->{_strDirectoryRestriction} eq "")
		{
			$strQuery = $strQuery . "AND (strFile LIKE '" . $self->{_searchRoot} . "%')";
		}

		# Append directory search restriction to the query's WHERE clause
		else
		{
			# User must prefix the directory restriction with a slash, i.e., dir:/users/home
			$strQuery = $strQuery . "AND (strFile LIKE '" . $self->{_searchRoot} . $self->{_strDirectoryRestriction} . "%')";
		}

		## print $strQuery;
	}

	# Connect to the database
	$dbh = DBI->connect($self->{_dsn}, $self->{_strUsername}, $self->{_strPassword});

	# Execute the query
	$sth = $dbh->prepare($strQuery);
	$sth->execute();

	$intCount = $sth->fetchrow();

	# Finish up and disconnect
	$sth->finish();
	$dbh->disconnect();

	return $intCount;
}

# Disk based method of executing a query.
# Result set paging is not supported.
#

sub FathomFiles
{
	my ($self) = @_;

	my ($strFile, $strContent, $strFileType, $intFileCounter, $strSearchPattern);

	$intFileCounter = $self->{_intFileCounter};

	# Search only defined file extensions
	# Reduce file.name.php to .php:
	
	$strFileType = /(\.[^.]*?)$/;
	$strFileType = $1;

	if (defined($self->{_fileExtensions}{$strFileType}))
	{
		if($self->{_boolIsRegExpSearch} eq true)
		{
			$strSearchPattern = $self->{_strUnEscapedSearchPattern};
		}
		else
		{
			$strSearchPattern = $self->{_strSearchPattern};
		}

		my $strFile = $File::Find::name;

		open(DAT, $strFile) || die("Could not open $strFile");
		@arrContent=<DAT>;

		# This code needs to be optimized later on
		# Scanning for a match twice is excessive and unnecessary

		foreach $line(@arrContent)
		{
			if ($line =~ m/$strSearchPattern/io)
			{
				# Remove leading directories
				$strFile =~ s/$self->{_searchRoot}//;

				$self->{_arrLineSet}[$intFileCounter] = new lineSet($strFile, "", \@arrContent, $strSearchPattern, $self->{_boolIsFile}, $self->{_searchRoot});
				$self->{_intFileCounter}++;
				last;
			}
		}

		close(DAT);
	}

}

# Slce contents into lines
# and push onto an array of objects
#
# This is only necessary if we are doing a database style search
#

sub SliceContents
{
	my ($self) = @_;

	my ($x, $sizeOfRecordSet, @arrMatches, $arrLineSet, $strFile);

	$sizeOfRecordSet = @{$self->{_arrRecordSet}};

	for($x = 0; $x < $sizeOfRecordSet; $x++)
	{
		# Remove leading directories
		$strFile = $self->{_arrRecordSet}[$x][0];
		$strFile =~ s/$self->{_searchRoot}//;

		$self->{_arrLineSet}[$x] = new lineSet($strFile, $self->{_arrRecordSet}[$x][1], "", $self->{_strSearchPattern}, $self->{_boolIsFile});
	}

	# Destroy results record set
	$self->{_arrRecordSet} = [ ];
}

# LuxMatches calls the main parser workhorse method: parseHTML
# and then it calls printMatch
#

sub LuxMatches
{
	my ($self) = @_;

	my ($x, $sizeOfLineSet, $objLuxParser, %hashLineStartList, %bookmarkHash, $arrBookmarks);

	$sizeOfLineSet = @{$self->{_arrLineSet}};
	$objLuxParser = new luxParser();

	# If we are loading a single file then select all notes for this file
	if($self->{_boolIsFile} eq true)
	{
		$self->{_objNotes} = new notes();
		$self->{_objNotes}->queryNotes($self->{_indexRoot} . $self->{_strFile}, $self->{_dsn}, $self->{_strUsername}, $self->{_strPassword});

		# Compile a local hash list of the annotated lines (start lines only for now)
		for($r=0; $r<$self->{_objNotes}->{_sizeOfNotesRecordSet}; $r++)
		{
			$hashLineStartList{$self->{_objNotes}->{_arrNotesRecordSet}[$r][2]} = $self->{_objNotes}->{_arrNotesRecordSet}[$r][2];
		}

		# Get list of line numbers of bookmarks for this file
		$self->{_objBookmarks} = new bookmarks($self->{_dsn}, $self->{_strUsername}, $self->{_strPassword});
		$self->{_objBookmarks}->getBookmarkLines($self->{_projectID}, $self->{_strFile});

                for($f=0; $f<$self->{_objBookmarks}->{_sizeOfBookmarkLines}; $f++)
                {
			push (@arrBookmarks, $self->{_objBookmarks}->{_arrBookmarkLines}[$f][0]);
			#$bookmarkHash{$self->{_objBookmarks}->{_arrBookmarkLines}[$f][0] = $self->{_objBookmarks}->{_arrBookmarkLines}[$f][0]};
                }
	}

	# Loop through matches array and light up the lines
	for($x = 0; $x < $sizeOfLineSet; $x++)
	{
		for($r = 0; $r < $self->{_arrLineSet}[$x]->sizeOfArrLines; $r++)
		{
			$strLux = $objLuxParser->parseHTML($self->{_arrLineSet}[$x]->{_arrLines}[$r][1], $self->{_strSearchPattern}, $self->{_strUnEscapedSearchPattern}, $self->{_boolIsRegExpSearch}, $self->{_arrLineSet}[$x]->{_arrLines}[$r][2], $self->{_projectID});
			$self->{_arrLineSet}[$x]->{_arrLines}[$r][1] = $strLux;
		}

		# Printing matches as they are being luxxed should speed the application up
		$self->printMatch($x, $r, $arrBookmarks, %hashLineStartList);
	}

	# If $boolIsFile == true then prefix the match with the bold line number html
	# Re-assign matches array[x] to what parseHTML returns
}

# Prints HTML for a search match
#

sub printMatch
{
	my ($self, $intMatch, $sizeOfArrLine, $arrBookmarks, %hashLineStartList) = @_;

	my ($strStrippedFile, $strCurrentFile, $strNextFile, $strLastFile, $strNewFileSearch, $strLineNumHTML, $x, $q, $sizeOfBookmarks, $hasBookmark);

	$hasBookmark = false;

	# Specific File Search
	if($self->{_boolIsFile} eq true)
	{
		print "<table>\n";
		print "   <tr>\n";
		print "      <td>\n";
		print "         <pre class=\"lux_pMatch\">\n";

		for($z = 0; $z < $sizeOfArrLine; $z++)
		{
			# If current line has a bookmark
			# The whole way this data is being passed (including the notes) needs to be changed
			for($f=0; $f<$self->{_objBookmarks}->{_sizeOfBookmarkLines}; $f++)
			{
				if($self->{_objBookmarks}->{_arrBookmarkLines}[$f][0] eq ($z+1))
				{
					$strLineNumHTML = "<a id=a_" . ($z+1) . " href=\"javascript:openWindow('viewBookmarks.pl?id=','viewBookmarks', 'height=250,width=600');\"><img src=\"$self->{_wwwRoot}/images/tag_red.png\" border=0 id=b_" . ($z+1) . "></a>&nbsp;";
					$hasBookmark = true;
					$f = $self->{_objBookmarks}->{_sizeOfBookmarkLines}+1;
					break; #this doesn't seem to work hence the prior line.
				}
				else
				{
					$hasBookmark = false;
				}
			}

			if($hasBookmark eq false)
			{
                                $strLineNumHTML = "<a id=a_" . ($z+1) . " href=\"javascript:addBookmark('$self->{_strFile}', $self->{_projectID}, " . ($z+1) . ",'$self->{_strSearchPattern}'," . (z+1) . ");\"><img src=\"$self->{_wwwRoot}/images/tag_blue.png\" border=0 id=b_" . ($z+1) . "></a>&nbsp;";

			}

			# If current line is annotated in the notes table then print the note type icon with a link to the note id
			if(defined($hashLineStartList{$z+1}))
			{
				for($q=0; $q < $self->{_objNotes}->{_sizeOfNotesRecordSet}; $q++)
				{
					if($self->{_objNotes}->{_arrNotesRecordSet}[$q][2] eq $z+1)
					{
						$strLineNumHTML .= "<a href=\"javascript:openWindow('$self->{_wwwRoot}/note.htm?action=edit&intNoteID=$self->{_objNotes}->{_arrNotesRecordSet}[$q][5]','noteWindow','height=345,width=820,toolbar=0,location=0,directories=0,menuBar=0,scrollbars=0,resizable=1');\"><img src=\"$self->{_wwwRoot}/images/$self->{_objNotes}->{_arrNotesRecordSet}[$q][4].png\" border=\"0\"></a>&nbsp;";
						break;
					}
				}
			}

			# Else print the default icon for "add note" with a link to the add note page, passing the line number as a parameter
			else
			{
				$strLineNumHTML .= "<a href=\"javascript:openWindow('$self->{_wwwRoot}/note.htm?action=new&intLineNumberStart=" . ($z+1) . "&file=$self->{_strFile}&p=$self->{_projectID}','noteWindow','height=345,width=820,toolbar=0,location=0,directories=0,menuBar=0,scrollbars=0,resizable=1');\"><img src=\"$self->{_wwwRoot}/images/textfield_add.png\" border=\"0\"></a>&nbsp;";
			}

			# Line has a search match -- bold the line number.
			if($self->{_arrLineSet}[0]->{_arrLines}[$z][1] =~ m/$self->{_strSearchPattern}/io && $self->{_strSearchPattern} ne "")
			{
				$strLineNumHTML .= "<font class=\"lux_lMatch\"><a name=\"line_$self->{_arrLineSet}[0]->{_arrLines}[$z][0]\">$self->{_arrLineSet}[0]->{_arrLines}[$z][0]:<\/a><\/font>";
			}

			else
			{
				$strLineNumHTML .= "<a class=\"lux_lineNumber\" name=\"line_$self->{_arrLineSet}[0]->{_arrLines}[$z][0]\">$self->{_arrLineSet}[0]->{_arrLines}[$z][0]:<\/a>";
			}

			print $strLineNumHTML . " " . $self->{_arrLineSet}[0]->{_arrLines}[$z][1];

			# Print newline if we are not at the last line
			if($z + 1 != $sizeOfArrLine)
			{
				print "\n";
			}
		}
		
		print "		</pre>\n";
		print "      </td>\n";
		print "   </tr>\n";
		print "</table>\n";
	}

	# General Search
	else
	{
		# Strip all preceeding directories from the file
		$strStrippedFile = $self->{_arrLineSet}[$intMatch]->{_strFile};
		$strStrippedFile =~ /(\/[^\/]*?)$/;
		$strStrippedFile = $1;

		#Strip out leading slash
		$strStrippedFile =~ s/[\/]//g;
		
		$_ = $self->{_arrLineSet}[$intMatch]->{_strFile};
		$strFileType = /(\.[^.]*?)$/;
		$strFileType = $1;

		# New File Search URL:
		$strNewFileSearch = "<a href=\"lux.pl?p=$self->{_projectID}&q=$strStrippedFile\"><img src=\"$self->{_wwwRoot}/images/icon$strFileType.gif\" border=\"0\"align=\"left\"></a>";

		# Print Match Header
		# > Filename
		# Indenting these lines will add extra space to the header and make it look too large
		print "<div class=\"arrow\">";
		print "<img src=\"$self->{_wwwRoot}/images/arrow-down.gif\" style=\"vertical-align:text-top\" border=\"0\" name=\"arrow-down.gif\" id=\"arrow-$intMatch\"";
		print " onmouseover=this.style.cursor='pointer'; onclick=\"SlideRows('arrow-$intMatch', 'd$intMatch','$self->{_wwwRoot}');\">";

		print "<a href=\"$self->{_wwwRoot}/graphTree.htm?file=$self->{_arrLineSet}[$intMatch]->{_strFile}\"><img src=\"$self->{_wwwRoot}/images/chart.gif\" border=\"0\"></a>";
		print "<span class=\"lux_mHeader\">&nbsp;&nbsp;";
		print "<a class=\"lux_mHeader\" href=\"lux.pl?p=$self->{_projectID}&q=$self->{_strQuotesEscapedSearchPattern}\&file=$self->{_arrLineSet}[$intMatch]->{_strFile}\">$self->{_arrLineSet}[$intMatch]->{_strFile}</a>";
		print "</span>\n";
		print "</div>\n";

		print "<div id=\"d$intMatch\">\n";

		# Loop through matches and print them out
		for($z = 0; $z < $sizeOfArrLine; $z++)
		{
			print "   <table width=\"100%\">\n";
			print "      <tr>\n";
			print "         <td>\n";
			print "            <pre class=\"lux_sMatch\">";

			print "$strNewFileSearch <a class=\"lux_lNum\" href=\"lux.pl?p=$self->{_projectID}&q=$self->{_strQuotesEscapedSearchPattern}\&file=$self->{_arrLineSet}[$intMatch]->{_strFile}\#line_$self->{_arrLineSet}[$intMatch]->{_arrLines}[$z][0]\">";
			print "$self->{_arrLineSet}[$intMatch]->{_arrLines}[$z][0]</a>: $self->{_arrLineSet}[$intMatch]->{_arrLines}[$z][1]";
			
			# If this </pre> is indented it will add a whole extra line to the line match
			print "</pre>\n";
			print "         </td>\n";
			print "      </tr>\n";
			print "   </table>\n";
		}

		print "</div>\n\n";
	}
}

1;
