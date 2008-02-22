package Lyrics::Fetcher::LeosLyrics;
our $VERSION = 0.02;

# Copyright (c) 2007 Edward Allen III. Some rights reserved.
#
## This program is free software; you can redistribute it and/or
## modify it under the terms of the Artistic License, distributed
## with Perl.
#
# Lyrics::Fetcher is maintained by BIGPRESH (David Precious <davidp@preshweb.co.uk>)

=pod

=head1 NAME

Lyrics::Fetcher::LeosLyrics - Get song lyrics from leoslyrics.com

=head1 SYNOPSIS

  use Lyrics::Fetcher;
  print Lyrics::Fetcher->fetch("<artist>","<song>","LeosLyrics");

  # or, if you want to use this module directly without Lyrics::Fetcher's
  # involvement:
  use Lyrics::Fetcher::LeosLyrics;
  print Lyrics::Fetcher::LeosLyrics->fetch('<artist>', '<song>');

=head1 DESCRIPTION

This module tries to get song lyrics from leoslyrics.com using the unpublished XML interface. It's designed 
to be called by Lyrics::Fetcher, but can be used directly if you'd prefer.

=cut

use 5.008000;
use strict;
use Carp;
use URI::Escape qw(uri_escape uri_escape_utf8);
use Encode;
use XML::Simple;
use LWP::Simple;

sub _url_escape {
    my $in = shift;
    $in =~ s/ /+/g;
    return uri_escape_utf8( encode( "utf8", $in ), "^A-Za-z0-9\-_.!\/?=\+" );
}

=head1 FUNCTIONS    

=over 4

=item I<fetch>($artist, $song)

Fetch lyrics for the requested song.

=cut

sub fetch {
    my $self = shift;
	my $artist = uri_escape(shift);
	my $song = uri_escape(shift);
    
    $Lyrics::Fetcher::Error = 'OK';
    
    unless ($artist && $song) {
        carp($Lyrics::Fetcher::Error = 
            'fetch() called without artist and song');
        return;
    }

    my $res = get( "http://api.leoslyrics.com/api_search.php?auth=LeosLyrics5&artist=${artist}&songtitle=${song}");
	unless ($res) {
        $Lyrics::Fetcher::Error = 'request failed';
        return;
	}

	my $xml= XML::Simple::XMLin($res);

	if ((ref $xml) &&  (exists $xml->{searchResults}) && (ref $xml->{searchResults}) && (exists $xml->{searchResults}->{result}) && (ref $xml->{searchResults}->{result}) && (exists $xml->{searchResults}->{result}->{exactMatch})) {
		if ($xml->{searchResults}->{result}->{exactMatch} eq "true") {
			my $hid = $xml->{searchResults}->{result}->{hid};
			my $lres  = get("http://api.leoslyrics.com/api_lyrics.php?auth=LeosLyrics5&hid=$hid");
			unless ($lres) {
				$Lyrics::Fetcher::Error = 'Error retrieving document';
				return;
			}
			my $lxml= XML::Simple::XMLin($lres);
			if ((ref $lxml) && (exists $lxml->{lyric}) && (ref $lxml->{lyric}) && (exists $lxml->{lyric}->{text})) {
				my $ret = $lxml->{lyric}->{text};
				if ($ret) {
					$Lyrics::Fetcher::Error = 'OK';
					return $ret;
				}
				else {
					$Lyrics::Fetcher::Error = 'Blank Lyrics Returned';
					return;
				}
			}
			else {
				$Lyrics::Fetcher::Error = 'Error processing XML';
				return;
			}
		}
		else {
			$Lyrics::Fetcher::Error = 'HID not listed in result.';
			return;
		}
	}
    else {
	    $Lyrics::Fetcher::Error = 'Lyrics not found';
        return undef;
    }

}


=pod

=back

=head1 BUGS

Most likely there is something.  LeosLyrics is poor in its unicode support.

=head1 SEE ALSO 

L<Lyrics::Fetcher>

=head1 AUTHOR 

Edward Allen III <ealleniii _at_ cpan _dot_ org>

=head1 COPYRIGHT

Copyright (c) 2007 Edward Allen III. Some rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the Artistic License, distributed
with Perl.

Legal disclaimer: I have no connection with the owners of leoslyrics.com.
Lyrics fetched by this script may be copyrighted by the authors, it's up to 
you to determine whether this is the case, and if so, whether you are entitled 
to request/use those lyrics. You will almost certainly not be allowed to use
the lyrics obtained for any commercial purposes.

=cut

1;
