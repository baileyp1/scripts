#!/usr/bin/perl
##########################################
my $script='39.homoeologTriadsWithKOs.pl';

# Paul Bailey	15.12.2015
##########################################

use strict;
use warnings;
use Getopt::Long;

my ($triadsFile, $geneList, $usage);

$usage="
-----------------------------------------------------
Usage: perl $script -f <triads file> -g <gene list>

Required options:
-f or --infile:		homoeolog triads table file
-g or --genelist:	gene list
-----------------------------------------------------
";

GetOptions(
       'f|triadsfile:s'    => \$triadsFile,
       'g|genelist:s'    => \$geneList,                                         
       'h|help:s'    => die $usage
       );


my $geneListCountr = 0;
my $triadCountr = 0;
my $threeGenesCountr = 0;
my $twoGenesCountr = 0;
my $oneGeneCountr = 0;
my $noGenesCountr = 0;


open GENE_LIST, $geneList or die "Error opening file $geneList: $!\n\n$usage";
my %geneListHash;
while(my $line = <GENE_LIST>)	{

	chomp $line;
	$geneListHash{$line} = 0;
	$geneListCountr++;
}
	

open TRIADS_FILE, $triadsFile or die "Error opening $triadsFile: $!\n\n$usage";
my $headr =  <TRIADS_FILE>;
while(my $line = <TRIADS_FILE>)	{

	chomp $line;
	my($tribeId, $n_total_members, $n_conf_members, $tribe_genome_configuration, $tribe_chromosome_configuration, $members_a, $members_b, $members_c) = split '\t', $line;
	
	
	if( exists $geneListHash{$members_a} && exists $geneListHash{$members_b} && exists $geneListHash{$members_c} )	{$threeGenesCountr++}
 	elsif( (exists $geneListHash{$members_a} && !exists $geneListHash{$members_b} && exists $geneListHash{$members_c}))		{$twoGenesCountr++}
 	elsif( (exists $geneListHash{$members_a} && exists $geneListHash{$members_b} && !exists $geneListHash{$members_c}))		{$twoGenesCountr++}
 	elsif( (!exists $geneListHash{$members_a} && exists $geneListHash{$members_b} && exists $geneListHash{$members_c}))		{$twoGenesCountr++}
	elsif(( exists $geneListHash{$members_a} && !exists $geneListHash{$members_b} && !exists $geneListHash{$members_c}) )	{$oneGeneCountr++}
	elsif(( !exists $geneListHash{$members_a} && exists $geneListHash{$members_b} && !exists $geneListHash{$members_c}) )	{$oneGeneCountr++}
	elsif(( !exists $geneListHash{$members_a} && !exists $geneListHash{$members_b} && exists $geneListHash{$members_c}) )	{$oneGeneCountr++}
	elsif(( !exists $geneListHash{$members_a} && !exists $geneListHash{$members_b} && !exists $geneListHash{$members_c}) )	{$noGenesCountr++}
 	$triadCountr++;
}


print "\n# genes in list: $geneListCountr";
print "\n# gene triads in set: $triadCountr";
print "\n# triads with all genes present: $threeGenesCountr";
print "\n# triads with two genes present: $twoGenesCountr";
print "\n# triads with one gene present: $oneGeneCountr";
print "\n# triads with no gene present: $noGenesCountr";
print "\n";