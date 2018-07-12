# Lux Parser Package

package luxParser;
use graphTree;
use tagMerger;
require "phpFunctions.pl";

sub new
{
	my ($class) = @_;

	my $self =
	{
		_blank => undef
	};

	bless $self, $class;
	return $self;
}

######################################################
# FUNCTION: parseHTML
# DESCRIPTION: Parses a php line into html.
#               This function is used for
#               both initial search query
#               matches as well as full
#               document parsing.
#
# RETURNS: A parsed php line of code into html
#
######################################################
sub parseHTML
{
        # Replace all $variables with href links to new queries
        # Replace all < and > with HTML codes
        #
        # TO DO:
        # 1. Replace all file includes to links to the files
        # 2. Add support for <<< EOF and EOT
        # 3. Keyword highlighting:
        #       if, else, while, do, exit, for, echo, true, false, null
        #       private, public, new, global, return
        ################################################################

	my ($self, $strLine, $strSearchPattern, $strUnEscapedSearchPattern, $boolIsRegExpSearch, $boolInsidePHP, $projectID) = @_;
	my ($strOrig, $strBold, $strHref, $objGraphTree, $objTagMerger, $strLineMerged, @linkMatches, $numLinks, $function);

        # Replace html < and >
        $strLine =~ s/[<]/\&lt\;/g;
        $strLine =~ s/(?<!-)>/\&gt\;/g;

        $strOrig = $strLine;
        $strBold = $strLine;

	# Highlight any objects on this line
        $objGraphTree = new graphTree();
        $objGraphTree->currentLine($strLine);
        $objGraphTree->luxObjects($projectID);
        $strLine = $objGraphTree->currentLine();

        # Object member variable or function replacement:
        if($strLine =~ m/->\$/g)
        {
                # For now suport is limited (does not match $var->$var)
        }
        else
        {
                $strLine =~ s/\$(\w*?\-\>.*?)([-+=\s(){},.;*\/?&\n\\:!`])/\<a class=\"lux_Variable\" href=\"lux.pl?p=$projectID&m=true&q=joshTest__36279$1\">joshTest__36279$1\<\/a\>$2/g;
        }

        # Variable replacement inside ' ' or " "
        #$strLine =~ s/'\$(.*?)([-+=\s(){},.;*\/?&\\:\[!`])(?<!\<)\'/'\<a class=\"lux_Variable\" href=\"lux.pl?p=$projectID&q=$1\"\>joshTest__36279$1\<\/a\>'/g;
        #$strLine =~ s/\"\$(.*?)([-+=\s(){},.;*\/?&\\:\[!`](?<!\[))(?<!\<)\"/\"\<a class=\"lux_Variable\" href=\"lux.pl?p=$projectID&q=$1\"\>joshTest__36279$1\<\/a\>\"/g;

        # Normal variable replacement

        # We have an inner $variable->[
        if( $strLine =~ m/\[<a class=\"lux_/g)
        {
                $strLine =~ s/(?<!\[)(\$.*?)([-+=\s(){},.;*\/?&\\:\[!`])(?<!\<)/\<a class=\"lux_Variable\" href=\"lux.pl?p=$projectID&q=$1\"\>$1\<\/a\>$2/g;
        }
        else
        {
                $strLine =~ s/(?<!\[)(\$.*?)([-+=\s(){},.;*\/?&\\:!`])(?<!\<)/\<a class=\"lux_Variable\" href=\"lux.pl?p=$projectID&q=$1\"\>$1\<\/a\>$2/g;
        }

        # Put back $
        $strLine =~ s/joshTest__36279/\$/g;

        # Functions TODO: add public, private
        $strLine =~ s/(function\s)(.*?)(\(.*?\))/$1<a class=\"lux_functionDefinition\" href=\"lux.pl?p=$projectID&q=$2&function=true\">$2<\/a>$3/ig;
        #$strLine =~ s/(function\s)(.*?)(\(.*?\)\s*{)/$1<a class=\"lux_functionDefinition\" href=\"lux.pl?p=$projectID&q=$2&function=true\">$2<\/a>$3/ig;

        $_ = $strLine;
        if(my (@functionMatches) = m/(\w+)\s*\(/g)
        {
                foreach $function(@functionMatches)
                {
                        if(defined($phpFunctions{$function}))
                        {
                                $strLine =~ s/($function)(\s*\()/<a class=\"lux_phpFunction\" href=\"http:\/\/www.php.net\/manual\/en\/function.$phpFunctions{$function}.php\" target=\"_blank\">$1<\/a>$2/g;
                        }
                }
        }

        # Bold all matches of $strSearchPattern (even those WITHIN links)
        if($boolIsRegExpSearch eq true)
        {
		my (@strMatches, $intTotalMatches,  @alreadyMatched, $numAlreadyMatched, $quoteRegExpMatch, $boldThisMatch, $regExpMatch, $x);

                $_ = $strBold;
		@strMatches = m/$strUnEscapedSearchPattern/igx;
                $intTotalMatches = @strMatches;

                @alreadyMatched = ();

                foreach $regExpMatch(@strMatches)
                {
                        $numAlreadyMatched = @alreadyMatched;
                        $quoteRegExpMatch = quotemeta($regExpMatch);
                        $boldThisMatch = true;

                        #Bold only one occurance (globally) of each match
                        #Otherwise we will be left with <b><b>match</b></b> and so on
                        for($x=0; $x<$numAlreadyMatched; $x++)
                        {
                                if($alreadyMatched[$x] eq $quoteRegExpMatch)
                                {
                                        $boldThisMatch = false;
                                }
                        }

                        if($boldThisMatch eq true)
                        {
                                $strBold =~ s/$quoteRegExpMatch/<b>$regExpMatch<\/b>/g;
                        }

                        push(@alreadyMatched, $quoteRegExpMatch);
                }
        }
        else
        {
		if($strSearchPattern ne "")
		{
			$strBold =~ s/$strSearchPattern/<b>$strUnEscapedSearchPattern<\/b>/ig;
		}
        }

	# Only merge lines if there is a bold and href both present
        if((index($strBold, "<b>") != -1) && (index($strLine, "<a class=") != -1))
        {
                $objTagMerger = new TagMerger();

                $objTagMerger->OrigString($strOrig);
                $objTagMerger->HrefString($strLine);
                $objTagMerger->BoldString($strBold);

                $strLineMerged = $objTagMerger->Merge();

                @linkMatches = m/<a class=/g;
                $numLinks = @linkMatches;

                # If the number of links is greater than one we
                # must do a sanity check on the links.
                if($numLinks > 0)
                {
                        if($objTagMerger->SanityCheck() eq "OK")
                        {
                                $strLine = $strLineMerged;
                        }
                        else
                        {
                                #print "sanity check failed:\n";
                                $strLine = $strBold;
                        }
                }
                else
                {
                        $strLine = $strLineMerged;
                }

                $objTagMerger = "";

		# Remove $var' and $var" from hrefs
		# Cannot execute these regexps prior to Merge
		# since it changes the comparison of the original line
		#
		$strLine =~ s/\"\">/\">/g;
		$strLine =~ s/\"<\/a>/<\/a>\"/g;

		$strLine =~ s/'\">/\">/g;
		$strLine =~ s/'<\/a>/<\/a>'/g;
	}

	# There are no href links in this line 
	elsif(index($strBold, "<b>") != -1 && index($strLine, "<a>") == -1)
	{
                $strLine = $strBold;
        }

        # Replace quotes inside $variable[""] with html
        $strLine =~ s/\[\"/\[\&quot\;/g;
        $strLine =~ s/\"\]/\&quot\;\]/g;

        # Comment highlighting
        # We should only highlight if inside <? ?> or <?php ?>
        # Will not work on single line php comment, i.e., <? //comment ?>
        if($boolInsidePHP eq true)
        {
                # Multi-line comment highlighting
                $strLine =~ s/(\/\*)/<font class=\"lux_phpComment\">$1/g;
                $strLine =~ s/(\*\/)/$1<\/font>/g;

                # Single line comment highlighting
                $strLine =~ s/(?<!http:)(?<!https:)(\/\/.*)/<font class=\"lux_phpComment\">$1<\/font>/o;
        }

	return $strLine;
}

1;
