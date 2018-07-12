# Line Set Class

package lineSet;

sub new
{
	my ($class, $strFile, $strContent, $arrContent, $strSearchPattern, $boolIsFile) = @_;

	my ($x, $r, $sizeOfArrLines, $boolInsidePHP, @arrTempLines);

	my $self =
	{
		_strFile => $strFile,
		_arrLines => [ ],
		_sizeOfArrLines => undef
	};

	bless $self, $class;

	# Database query
	if($strContent ne "")
	{
		# Split current recordset into array on \n
		@{$self->{_arrLines}} = split(/\n/, $strContent); 
	}

	# File based search
	else
	{
		@{$self->{_arrLines}} = @$arrContent;
	}

	# TO DO change $boolIsFile to "$boolSaveAllLines"
	#
	if($boolIsFile eq false)
	{
		$sizeOfArrLines = @{$self->{_arrLines}};
		$r = 0;

		$boolInsidePHP = false;

		for($x = 0; $x < $sizeOfArrLines; $x++)
		{
			# Determine if the line is inside a php tag
			if($self->{_arrLines}[$x] =~ m/<\?php|<\?/g)
			{
				$boolInsidePHP = true
			}

			if($strLine =~ m/\?>/g)
			{
				$boolInsidePHP = false;
			}

			# Strip out non matching lines if not loading a file
			# Todo: Line should really be abstracted to a class.
			if($self->{_arrLines}[$x] =~ m/$strSearchPattern/io)
			{
				# Assign the line number
				$arrTempLines[$r][0] = $x+1;

				# Assign the line
				$arrTempLines[$r][1] = $self->{_arrLines}[$x];
				
				# Remove any newlines, josh note: seems unnecessary now.
				#$arrTempLines[$r][1] =~ s/[\n]//o;

				# Assign whether the line is php code
				$arrTempLines[$r][2] = $boolInsidePHP;

				$r++;
			}
		}
	}

	# We are loading a whole file for display and need to save all lines
	else
	{
                $sizeOfArrLines = @{$self->{_arrLines}};
                $r = 0;

                $boolInsidePHP = false;

                for($x = 0; $x < $sizeOfArrLines; $x++)
                {
                        # Determine if the line is inside a php tag
                        if($self->{_arrLines}[$x] =~ m/<\?php|<\?/g)
                        {
                                $boolInsidePHP = true
                        }

                        if($strLine =~ m/\?>/g)
                        {
                                $boolInsidePHP = false;
                        }

                        # Assign the line number
                        $arrTempLines[$r][0] = $x+1;

                        # Assign the line
                        $arrTempLines[$r][1] = $self->{_arrLines}[$x];

			# Remove Windows' \r from lines			
			$arrTempLines[$r][1] =~ s/[\r]//o;

                        # Assign whether the line is php code
                        $arrTempLines[$r][2] = $boolInsidePHP;

                       $r++;
		}
	}
		$self->{_sizeOfArrLines} = $r--;
		$self->{_arrLines} = [ ];
		@{$self->{_arrLines}} = @arrTempLines;

	return $self;
}

sub file
{
        my ($self, $strFile) = @_;

        $self->{_strFile} = $strFile if defined($strFile);

        return $self->{_strFile};
}

sub contents
{
	my ($self, $strContents) = @_;

	$self->{_arrLines} = $strContents if defined($strContents);

	return $self->{_arrLines};
}

sub sizeOfArrLines
{
	my ($self) = @_;

	return $self->{_sizeOfArrLines};
}

1;
