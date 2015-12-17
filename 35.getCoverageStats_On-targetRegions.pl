#!/usr/bin/perl
use strict;
use warnings;

my $onTargetSize = 0;
my $sumOfCoverages = 0;
my @covCounts;
while(my $line = <>)     {
     my @fields = split "\t", $line;
     my $cov = $fields[4];
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
# Print average coverage to 2 d.p.'s:
printf("%.2f", $sumOfCoverages/$onTargetSize);
print "\t";

# Get counts at each coverage:
my $covCountsArraySize = @covCounts;
my @coverages = (1, 6, 10, 15, 20, 30, 100);     # 0, 5, 9, 14, 19, 29, 99
foreach my $cov (@coverages)     {
     
     my $sum = 0;
     for(my $i=$cov; $i < $covCountsArraySize; $i++)          {

          if($covCounts[$i])     {
               $sum = $sum + $covCounts[$i];  
          }
     }
     print $sum, "\t";
}
print $onTargetSize, "\t";
