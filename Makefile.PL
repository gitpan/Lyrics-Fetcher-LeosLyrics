use 5.008000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Lyrics::Fetcher::LeosLyrics',
    VERSION_FROM      => 'lib/Lyrics/Fetcher/LeosLyrics.pm', # finds $VERSION
    PREREQ_PM         => { 
                              'URI::Escape'             => 3.28,
							  'XML::Simple'				=> 0.1,
                              'LWP::Simple'             => 1.4,
	}, 
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Lyrics/Fetcher/LeosLyrics.pm',
       AUTHOR         => 'Edward Allen <ealleniii@cpan.org>') : ()),
);
