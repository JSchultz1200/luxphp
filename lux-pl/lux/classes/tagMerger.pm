# Tag Merger Class

package TagMerger;

sub new
{
	my ($class) = @_;

	my $self =
	{
		_strOrig => undef,
		_strHref => undef,
		_strBold => undef,
		_strResultant => undef
	};

	bless $self, $class;
	return $self;
}

sub OrigString
{
	my ( $self, $strOrig ) = @_;
	$self->{_strOrig} = $strOrig if defined($strOrig);
	return $self->{_strOrig};
}

sub HrefString
{
        my ( $self, $strHref ) = @_;
        $self->{_strHref} = $strHref if defined($strHref);
        return $self->{_strHref};
}

sub BoldString
{
        my ( $self, $strBold ) = @_;
        $self->{_strBold} = $strBold if defined($strBold);
        return $self->{_strBold};
}

sub ResultantString
{
	my ( $self ) = @_;
	return $self->{_strResultant};
}

sub Merge
{

my ( $self ) = @_;

# Split lines into character arrays
my @strMyOrig = split //, $self->{_strOrig};
my @strMyHref = split //, $self->{_strHref};
my @strMyBold = split //, $self->{_strBold};

# Determine the length of each line
my $sizeOfOrig = @strMyOrig;
my $sizeOfHref = @strMyHref;
my $sizeOfBold = @strMyBold;

# Position of current comparison
my $posOrig = 0;
my $posHref = 0;
my $posBold = 0;

my $resultantString = "";
my $varTemp1 = "";
my $varTemp2 = "";

while($posOrig < $sizeOfOrig)
{
	# if we reach a < in both strings then:
	if(($strMyHref[$posHref] eq "<") && ($strMyBold[$posBold] eq "<"))
	{

		#########################
		#         CASES:	#
		#########################

		# Case 1		#
                # for (<a href..	#
                # for (<b>$size		#

		#########################

		# Case 2		#
                # for (<a href..	#
                # for <b>(</b>		#

		#########################

		# Case 3		#
                #..">$size</a>		#
                # <b>$size</b>		#

		#########################

		# Case 4		#
                #..">$size</a>		#
                #    $size<b>...	#

		#########################


		# Case 1
                # for (<a href..
                # for (<b>$size

		if($strMyHref[$posHref+1] ne "/" && $strMyBold[$posBold+1] ne "/")
		{
			#print "CASE 1\n";
			#debug();

			# read in the characters in the hrefString until the end of the tag (">) into VAR1
			while($strMyHref[$posHref] ne "\"" || $strMyHref[$posHref+1] ne ">")
			{
				$varTemp1 = $varTemp1 . $strMyHref[$posHref];
 				$posHref++;
			}

			# append VAR1 to the resultant string
			$resultantString = $resultantString . $varTemp1 . "\">";

			# append the <b> from the boldString to the resultant string
			while($strMyBold[$posBold] ne ">")
                	{
                        	$varTemp2 = $varTemp2 . $strMyBold[$posBold];
                        	$posBold++;
                	}

			$resultantString = $resultantString . $varTemp2 . ">";

			$posHref++;
                	$posHref++;
			$posBold++;
		
			$varTemp1 = "";
			$varTemp2 = "";

			#debug();
		}

		# Case 2
                # for (<a href..
                # for <b>(</b>

		elsif($strMyHref[$posHref+1] ne "/" && $strMyBold[$posBold+1] eq "/")
		{
			#print "CASE 2\n";

			# append the </b> from the boldString to the resultant string
                        while($strMyBold[$posBold] ne ">")
                        {
                                $varTemp2 = $varTemp2 . $strMyBold[$posBold];
                                $posBold++;
                        }

                        $resultantString = $resultantString . $varTemp2 . ">";

                        # read in the characters in the hrefString until the end of the tag (">) into VAR1
                        while($strMyHref[$posHref] ne "\"" || $strMyHref[$posHref+1] ne ">")
                        {
                                $varTemp1 = $varTemp1 . $strMyHref[$posHref];
                                $posHref++;
                        }

                        # append VAR1 to the resultant string
                        $resultantString = $resultantString . $varTemp1 . "\">";

			$posHref++;
                        $posHref++;
                        $posBold++;

                        $varTemp1 = "";
                        $varTemp2 = "";

			#debug();
		}

		# Case 3
                #..">$size</a>
                # <b>$size</b>

		elsif($strMyHref[$posHref+1] eq "/" && $strMyBold[$posBold+1] eq "/")
		{
			#print "CASE 3\n";

                        # append the </b> from the boldString to the resultant string
                        while($strMyBold[$posBold] ne ">")
                        {
                                $varTemp2 = $varTemp2 . $strMyBold[$posBold];
                                $posBold++;
                        }

                        $resultantString = $resultantString . $varTemp2 . ">";

                        # append the </a> from the hrefString to the resultant string
                        while($strMyHref[$posHref] ne ">")
                        {
                                $varTemp1 = $varTemp1 . $strMyHref[$posHref];
                                $posHref++;
                        }

                        $resultantString = $resultantString . $varTemp1 . ">";

			$varTemp1 = "";
			$varTemp2 = "";

			$posBold++;
			$posHref++;

			#debug();
		}

		# Case 4
                #..">$size</a>
                #    $size<b>...

		elsif($strMyHref[$posHref+1] eq "/" && $strMyBold[$posBold+1] ne "/")
		{
			#print "CASE 4\n";

                        # append the </a> from the hrefString to the resultant string
                        while($strMyHref[$posHref] ne ">")
                        {
                                $varTemp1 = $varTemp1 . $strMyHref[$posHref];
                                $posHref++;
                        }

                        $resultantString = $resultantString . $varTemp1 . ">";

                        # append the <b> from the boldString to the resultant string
                        while($strMyBold[$posBold] ne ">")
                        {
                                $varTemp2 = $varTemp2 . $strMyBold[$posBold];
                                $posBold++;
                        }

                        $resultantString = $resultantString . $varTemp2 . ">";

                        $varTemp1 = "";
                        $varTemp2 = "";

                        $posBold++;
                        $posHref++;

                        #debug();
		}
	}

	# Current character in one string is < or > but the other isn't.
	elsif( ($strMyHref[$posHref] eq "<" && $strMyBold[$posBold] ne "<") || ($strMyHref[$posHref] ne "<" && $strMyBold[$posBold] eq "<") )
	{
	    if(($strMyHref[$posHref] eq "<" || $strMyBold[$posBold] eq "<") || (($strMyHref[$posHref] eq ">" || $strMyBold[$posBold] eq ">") && ($strMyHref[$posHref-1] ne "-" && $strMyBold[$posBold-1] ne "-")))
    	    {
		# Determine if the href is the matching tag
		if($strMyHref[$posHref] eq "<")
		{
			# Inside an opening <a tag
			if($strMyHref[$posHref+1] ne "/")
			{
				# Case 5
	                        #print "CASE 5\n";

				while($strMyHref[$posHref] ne "\"" || $strMyHref[$posHref+1] ne ">")
				{
					$varTemp1 = $varTemp1 . $strMyHref[$posHref];
					$posHref++;
				}

				$resultantString = $resultantString . $varTemp1 . "\">";
				#$resultantString = $resultantString . $strMyOrig[$posOrig];

				$posHref++;
				$posHref++;

				$varTemp1 = "";
				#debug();

			}

			#Inside a closing </a tag
			else
			{
				# Case 6
				#print "CASE 6\n";

				while($strMyHref[$posHref] ne ">")
				{
					$varTemp1 = $varTemp1 . $strMyHref[$posHref];
					$posHref++;
				}

				$resultantString = $resultantString . $varTemp1 . ">";
				$posHref++;

				$varTemp1 = "";

				#debug();
			}
		}

		# Determine if the bold is the matching tag
		elsif($strMyBold[$posBold] eq "<")
		{
			# Case 7
			#print "CASE 7\n";

			while($strMyBold[$posBold] ne ">")
                	{
                        	$varTemp2 = $varTemp2 . $strMyBold[$posBold];
                        	$posBold++;
                	}

                	$resultantString = $resultantString . $varTemp2 . ">";
			$posBold++;
			
			$varTemp2 = "";
			#debug();
		}

	}
	else
	{
                $resultantString = $resultantString . $strMyOrig[$posOrig];

                $posHref++;
                $posBold++;
                $posOrig++;
	}
    }

	else
	{
		$resultantString = $resultantString . $strMyOrig[$posOrig];

		$posHref++;
		$posBold++;
		$posOrig++;
	}
}

# Append </a> to the end of the resultant
if($posHref < $sizeOfHref)
{
	while($posHref < $sizeOfHref)
	{
		$varTemp1 = $varTemp1 . $strMyHref[$posHref];
		$posHref++;
	}

	$resultantString = $resultantString . $varTemp1;
	$varTemp1 = "";
}

# Append </b> to the end of the resultant
if($posBold < $sizeOfBold)
{
	while($posBold < $sizeOfBold)
	{
		$varTemp2 = $varTemp2 . $strMyBold[$posBold];
		$posBold++;
	}

	$resultantString = $resultantString . $varTemp2;
	$varTemp2 = "";
}
	$self->{_strResultant} = $resultantString;
}

sub SanityCheck
{
	my ( $self ) = @_;
	my @strMyResultant = split //, $self->{_strResultant};

	# Determine the length of each line
	my $sizeOfResultant = @strMyResultant;

	# Position of current comparison
	my $posResultant = 0;

	# Loop through resultant string
	# If there are any <a class inside other <a class then fail the check

	$sanityCheck = "OK";
	$inHref = false;

	while($posResultant < $sizeOfResultant)
	{
		if($inHref eq true)
		{	
			# Match <a or &lt;a (close enough to &lt;a href=)
			if(($strMyResultant[$posResultant] eq "<" && $strMyResultant[$posResultant+1] eq "a")
				|| ($strMyResultant[$posResultant] eq "&" && $strMyResultant[$posResultant+1] eq "l" &&
				    $strMyResultant[$posResultant+2] eq "t" && $strMyResultant[$posResultant+3] eq ";" &&
				    $strMyResultant[$posResultant+4] eq "a"))
			{
				$inSecondHref = true;
				$sanityCheck = "FAILED";
				$posResultant = $sizeOfResultant + 1;
			}

                        elsif($strMyResultant[$posResultant] eq "\"" && $strMyResultant[$posResultant+1] eq ">")
                        {
                                $inHref = false;
                        }
		}

		else
		{
			if($strMyResultant[$posResultant] eq "<" && $strMyResultant[$posResultant+1] eq "a")
			{
				$inHref = true;
			}

			elsif($strMyResultant[$posResultant] eq "\"" && $strMyResultant[$posResultant+1] eq ">")
			{
				$inHref = false;
			}
		}

		$posResultant++;
	}

	return $sanityCheck;
}

sub debug
{

	print "Orig: Pos: $posOrig, Value: $strMyOrig[$posOrig]\n";
	print "Href: Pos: $posHref, Value: $strMyHref[$posHref]\n";
	print "Bold: Pos: $posBold, Value: $strMyBold[$posBold]\n";

	print "$resultantString\n\n";
}

sub DESTROY
{
	my $self = shift;
}

1;
