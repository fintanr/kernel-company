#!/usr/bin/perl -w
#
# Extract total company commits correlated by kernel release
# from data provided at http://www.remword.com/kps_result/
#
# We generate a tidy data set for use in R
#
# A lot of preprocessing has been done on the data before we 
# start to use it by Wang Chen who maintains the kps data
# so most of the heavy lifting has already been done
# 

use strict;
use HTML::TreeBuilder::XPath;
use HTML::TreeBuilder;

my %ourReleases = ();
my $baseUrl = "http://www.remword.com/kps_result/";
my $outFile = "kernel-commits-company.csv";

buildReleaseList();

foreach my $key (sort(keys(%ourReleases)) ) {
    extractCompanies($key);
}

printDataSet();

sub buildReleaseList {

    my $tree= HTML::TreeBuilder->new_from_url($baseUrl);

    my @tables = $tree->find_by_tag_name('table');
    my @trs = $tables[4]->content_list();

    foreach my $tr ( @trs ) {

        my @tds = $tr->content_list();
        
        # need to look into this, can't access tds[x] directly
        
        my $thisRelease = "";
        my $thisDate = "";

        foreach my $td ( @tds ) {
            my @content = $td->content_list();

            if ( $content[0]->tag() eq "p" && $content[0]->as_text =~ /Linux-(.*)\((\d+-\d+-\d+)\)/ ) {

                $thisRelease = $1;
                $thisDate = $2;
                $ourReleases{$thisRelease}->{'date'} = $thisDate;
                    
            } else { 

                my @hrefs = $content[0]->content_list();
                # lazy for a one off, we know the hrefs number is 14, just check for it and
                # parse
                if ( $#hrefs == 14 ) {
                    if ( $hrefs[0]->tag() eq "a" && $hrefs[0]->as_text =~/^P$/ ) {
                        my $url = $hrefs[0]->attr('href');
                        $url =~ s/\.\///;
                        if ( $url !~ /all_whole/ ) {
                            if ( grep(/^$/, $thisRelease) ) {
                                # 3.20 - this is a hack as well
                                $thisRelease = "3.20";
                                $thisDate = "2015-04-18";
                                $ourReleases{$thisRelease}->{'date'} = $thisDate;
                            }
                            $ourReleases{$thisRelease}->{'url'} = $url;
                        }
                    }
                }
            }
        } 
   }
}


sub extractCompanies {

    my ( $release ) = @_;

    print "Extracting data for $release\n";

    my $url = sprintf("%s/%s", $baseUrl, $ourReleases{$release}->{'url'});

    my $tree= HTML::TreeBuilder::XPath->new_from_url($url);
    my $nodes = $tree->findnodes('/html/body/ul/li');

    for ( my $i = 0; $i <= $#$nodes; $i++ ) {
        my $val =  $$nodes[$i]->findvalue('.');

        if ( $val =~ /^No.(\d+)\s+(.*)[\s|](\d+)\(.*\%\).*/ ) {
            my $count = $#{$ourReleases{$release}->{'commits'}};
            $count++;
            my $pos = $1;
            my $company = $2;
            my $commitCount = $3;
            $company =~ s/\,/ /g;
            $ourReleases{$release}->{'commits'}->[$count]->{'pos'} = $pos;
            $ourReleases{$release}->{'commits'}->[$count]->{'company'} = $company;
            $ourReleases{$release}->{'commits'}->[$count]->{'count'} = $commitCount;
        }
    }
}

sub printDataSet {
   
    open(OUT, ">$outFile");
    print OUT "Release,Date,Position,Company,Commit_Count\n";

    foreach my $key ( sort(keys(%ourReleases) ) ) {
        my $pre = "$key,$ourReleases{$key}->{'date'}";
        for ( my $i = 0; $i <= $#{$ourReleases{$key}->{'commits'}}; $i++ ) {
            my $pos = $ourReleases{$key}->{'commits'}->[$i]->{'pos'};
            my $company = $ourReleases{$key}->{'commits'}->[$i]->{'company'};
            my $count = $ourReleases{$key}->{'commits'}->[$i]->{'count'};
            
            print OUT "$pre,$pos,$company,$count\n";
        }
    }
    close(OUT);
}
