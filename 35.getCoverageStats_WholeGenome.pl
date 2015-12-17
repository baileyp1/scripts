#!/usr/bin/perl
use strict;
use warnings;

my $numbrBasesInIWGSC_v1=shift;
my $onTargetSize = 0;
my $sumOfCoverages = 0;
my @covCounts;
while(my $line = <>)     {
     my @fields = split "\t", $line;
     my $cov = $fields[2];	# Differs here from 35.getCoverageStats_On-targetRegions.pl 
     if( $covCounts[$cov] )     {
          $covCounts[$cov]++;
     }
     else     {
          $covCounts[$cov] = 1;
     }

     # For calculating average coverage:
     $sumOfCoverages = $sumOfCoverages + $cov;

     $onTargetSize++;
}
# line 23
# Print average coverage and total number of bases:
print "Av.cov (w.r.t. rows in file):\t";
printf("%.2f", $sumOfCoverages/$onTargetSize);
print "\tTotal number of bases (rows in file): ", $onTargetSize;
print "\tAv.cov(w.r.t. total genome size: $numbrBasesInIWGSC_v1 bp):\t"; 
printf("%.2f", $sumOfCoverages/$numbrBasesInIWGSC_v1);
print  "\n";

# Get counts at each coverage:
my $covCountsArraySize = @covCounts;
my @coverages = (1, 6, 10, 20);	# Differs here from 35.getCoverageStats_On-targetRegions.pl  
foreach my $cov (@coverages)     {
     
     my $sum = 0;
     for(my $i=$cov; $i < $covCountsArraySize; $i++)          {

          if($covCounts[$i])     {
               $sum = $sum + $covCounts[$i];  
          }
     }
     print $sum, "\t";
}
