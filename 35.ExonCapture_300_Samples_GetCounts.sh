#!/bin/bash
#########################################
# 35.ExonCapture_300_Samples_GetCounts.sh

# Paul bailey		24.1.2015
#########################################

# This script uses the hard coded values - check them before use!
onTargSiz=95373308				# Original value for CSS v1 reference = 102152087; IWGSC_v2_ChrU.fa = 95373308 (minus any 3B contigs) 
basesInGenomeRef=9500075743		# Number of bases in the CSS v1 reference = 10138701012; IWGSC_v2_ChrU.fa = 9500075743 (minus any 3B contigs)


printf '%b' "		Lane\tSampleID\tDescription\tReadMates\tCadenzaNo\t \
readsR1\treadsR2\tadaptorContamR1_%\tadaptorContamR2_%\tgoodQualTrimR1_%FullLen\tgoodQualTrimR2_%FullLen\t \
BWA_FragLen_bp\tDupRate_%\tOpticalDups\tOpticalDups_%\tNon-dupReads\tNon-dupReads_%\tAlnReadMates\tAlnReadPairs_%\t \
On-targReadPairs\tOn-targReadPairs_%\t \
AvOn-targCovPerBase\tOn-targBases1xCov\tOn-targBases1xCov_%\tOn-targBases6xCov\tOn-targBases6xCov_%\tOn-targBases10xCov\tOn-targBases10xCov_%\t \
On-targBases15xCov\tOn-targBases15xCov_%\tOn-targBases20xCov\tOn-targBases20xCov_%\tOn-targBases30xCov\tOn-targBases30xCov_%\tOn-targBases100xCov\tOn-targtBases100xCov_%\t \
GenomeCovBases1xCov\tGenomeCovBases1xCov_%\tGenomeCovBases6xCov\tGenomeCovBases6xCov_%\tGenomeCovBases10xCov\tGenomeCovBases10xCov_%\tGenomeCovBases20xCov\tGenomeCovBases20xCov_%\n" \
> ExonCapture_alignment_results.txt
#On-targReadPairs_q>=20\tOn-targReadPairs_q>=20_%\t
#> ExonCapture_alignment_results_52_test_samples.txt
#> ExonCapture_alignment_results.txt
#>  35.ExonCapture_alignment_results.txt

# For looking at the qPCR tests:
#printf '%b' "Lane\tSampleID\tDescription \
#avOnTargCovPerBase	avOnTargCovperBase_Norm	avOnTargCovPerBase_IWGSP1_EnsemblPlnts22	avOnTargCovPerBase_JoseRef	\
#avOnTargCovPerBase_Rubsico_MDH	avOnTargCovPerBase_Rubsico_MDH_Norm	Rubsico_MDH_EF	\
#GenomeCovBases1xCov_%	\
#avOffTargCovPerBase	OnTarg_EF	avOffTargCovPerBase_IWGSP1_EnsemblPlnts22	OnTarg_IWGSP1_EnsemblPlnts22_EF	avOffTargCovPerBase_JoseRef	OnTarg_JoseRef_EF"
#> 35.ExonCapture_alignment_results.txt
### NB - this header doesn't print! Why not?


# Prepare table without the header:
plateToDo='LIB15674'
#plateToDo='PlateH\|PlateI\|PlateN'
#plateToDo='-v LIB5780\|LIB5782'
#tail -n +2 /tgac/workarea/group-cg/baileyp/WheatLoLa/35.ExonCapture_300_Samples/35.ExonCapture_PreparingTable.txt | grep $plateToDo |
#tail -n +2 /tgac/workarea/group-cg/baileyp/WheatLoLa/35.ExonCapture_myIWGSC_v2_chrU_ref/54_test_samples/35.ExonCapture_PreparingTable_54_TestSamples.txt | grep $plateToDo |
tail -n +2 /tgac/workarea/group-cg/baileyp/WheatLoLa/39.ExonCapture_PlateH2N/ExonCapture_PlateH2N.txt | grep $plateToDo |
while read line; do

	lane=`echo $line | cut -d ' ' -f 1`	
	sampleID=`echo $line | cut -d ' ' -f 2` 
	description=`echo $line | cut -d ' ' -f 3` 
	numbrReads=`echo $line | cut -d ' ' -f 4`
	paths_to_libs=`echo $line | cut -d ' ' -f 5` 
	CadenzaNo=`echo $line | cut -d ' ' -f 6`	# | sed s/\n//`
	
	# Prepare basic library name:
	lib=`echo $sampleID | sed s/^...._// | sed s/_LDI....$// `
	
	# Total number of reads:
	readsR1=`cat $paths_to_libs/R1_scythe.stderr | grep 'contaminated:' | awk '{print $6}'`
	readsR2=`cat $paths_to_libs/R2_scythe.stderr | grep 'contaminated:' | awk '{print $6}'`
	
	# Adaptor contamination rates:
	adaptorContamR1=`cat $paths_to_libs/R1_scythe.stderr | grep 'contamination rate:' | awk '{print $3}'`
	adaptorContamR1Pc=`awk -vadaptorContamR1=$adaptorContamR1 'BEGIN{printf "%.2f", adaptorContamR1 * 100}'`
	adaptorContamR2=`cat $paths_to_libs/R2_scythe.stderr | grep 'contamination rate:' | awk '{print $3}'`
	adaptorContamR2Pc=`awk -vadaptorContamR2=$adaptorContamR2 'BEGIN{printf "%.2f", adaptorContamR2 * 100}'`
	
	# Number of full length reads after quality trimming:
	qualTrimR1=`cat $paths_to_libs/trimmed_R1_len.txt | grep '^101' | awk '{print $2}'`
	goodQualTrimR1Pc=`awk -vreadsR1=$readsR1 -vqualTrimR1=$qualTrimR1 'BEGIN{printf "%.2f", (qualTrimR1/readsR1) * 100}'`
	qualTrimR2=`cat $paths_to_libs/trimmed_R2_len.txt | grep '^101' | awk '{print $2}'` 
	goodQualTrimR2Pc=`awk -vreadsR2=$readsR2 -vqualTrimR2=$qualTrimR2 'BEGIN{printf "%.2f", (qualTrimR2/readsR2) * 100}'`
	
	### mapped read count (includes proper pairs and single mates):
	###tail -n 1  $lib/sampe_mapped_count.log | grep -P '^\d'

	# look at the fragment length sizes for each library:
	### 4.8.2015 - NB - it would probably be best to issue this command in the main script and save the result in a separate file
	### which can then be counted here:
	#fragSize=`head -n 3000 $paths_to_libs/sampe_sort_markdup_rm_filter_-f2.log | grep 'inferred external isize from' | head -n 1| awk '{print $8}'`
	# For the UV's:
	fragSize=`head -n 3000 $paths_to_libs/LIB*.e* | grep 'inferred external isize from' | head -n 1| awk '{print $8}'`
	
	# Get Picard's PERCENT_DUPLICATION column:
	dupRate=`cat $paths_to_libs/sampe_sort_markdup_metrics | grep '^Unknown' | awk '{print $9*100}'`
	
	
	# Get Picard's READ_PAIR_OPTICAL_DUPLICATES column:
	opticalDups=`cat $paths_to_libs/sampe_sort_markdup_metrics | grep '^Unknown' | awk '{print $8}'`
	opticalDupsPc=`awk -vnumbrReads=$numbrReads -vopticalDups=$opticalDups 'BEGIN{printf "%.2f", (opticalDups/numbrReads)*100}' `

		
	# Number of non-duplicated reads:
	nonDupReads=`tail -n 1  $paths_to_libs/sampe_sort_markdup_rm_count.log | grep -P '^\d'`
	nonDupReadsPc=`awk -vnumbrReads=$numbrReads -vnonDupReads=$nonDupReads 'BEGIN{printf "%.2f", (nonDupReads/numbrReads)*100}' `

		
	#Number of concordantly aligned read mates:
	alnReadMates=`tail -n 1  $paths_to_libs/sampe_sort_markdup_rm_filter_-f2_count.log | grep -P '^\d' `
	alnReadPairsPc=`awk -vnumbrReads=$numbrReads -valnReadMates=$alnReadMates 'BEGIN{printf "%.2f", (alnReadMates/numbrReads)*100}' `

	
	# Number of properly paired reads on-target:
	onTargReadPairs=`tail -n 1  $paths_to_libs/sampe_sort_markdup_rm_filter_-f2_ontarget_orig_ref_count_read_pairs.log | grep -P '^\d'`
	onTargReadPairsPc=`awk -vnumbrReads=$numbrReads -vonTargReadPairs=$onTargReadPairs 'BEGIN{printf "%.2f", (onTargReadPairs/(numbrReads/2))*100}' `

		
	### Count of number of read mates on-target: 
	### May want to calculate the percent here as well to 2 d.p.'s
	###printf '%b' `tail -n 1  $lib/sampe_sort_markdup_rm_filter_-f2_ontarget_orig_ref_count_read_mates.log | grep -P '^\d'` "\t"

	
	# Properly paired reads on-target count, -q >= 20:
#	onTargReadPairs_q20=`tail -n 1  $paths_to_libs/sampe_sort_markdup_rm_filter_-f2_ontarget_orig_ref_-q20_count.log | grep -P '^\d'`
#	onTargReadPairs_q20Pc=`awk -vnumbrReads=$numbrReads -vonTargReadPairs_q20=$onTargReadPairs_q20 'BEGIN{printf "%.2f", (onTargReadPairs_q20/(numbrReads/2))*100}' `
	
	
	# Av_cov and on-target coverages:
	avCov_Ontarg=`tail -n 1  $paths_to_libs/sampe_sort_markdup_rm_filter_-f2_covBed_orig_ref_more_1_6_10_15_20_25_100x_covs.log`
	avCov_OntargPc=`echo $avCov_Ontarg | awk -vonTargSiz=$onTargSiz '{print $1 \
	"\t" $2 "\t" ($2/onTargSiz)*100 "\t" $3 "\t" ($3/onTargSiz)*100 "\t" $4 "\t" ($4/onTargSiz)*100 "\t" $5 "\t" ($5/onTargSiz)*100 "\t" \
	$6 "\t" ($6/onTargSiz)*100 "\t" $7 "\t" ($7/onTargSiz)*100 "\t" $8 "\t" ($8/onTargSiz)*100 }' `


	# genomecov coverage results:
	genomecov=`tail -n 1  $paths_to_libs/sampe_sort_markdup_rm_filter_-f2_bedT_genomecov_-d_more_1_6_10_20x_covs.log`
	genomecovPc=`echo $genomecov | awk -vbasesInGenomeRef=$basesInGenomeRef '{print $1 "\t" ($1/basesInGenomeRef)*100 \
	"\t" $2 "\t" ($2/basesInGenomeRef)*100 "\t" $3 "\t" ($3/basesInGenomeRef)*100 "\t" $4 "\t" ($4/basesInGenomeRef)*100 }'` 

	# Values for the qPCR tests: 
	avCov_Ontarg=`awk -vnumbrReads=$numbrReads '{print $1}' $paths_to_libs/sampe_sort_markdup_rm_filter_-f2_covBed_orig_ref_more_1_6_10_15_20_25_100x_covs.log`
	avCov_Ontarg_Norm=`awk -vavCov_Ontarg=$avCov_Ontarg -vnumbrReads=$numbrReads 'BEGIN{printf "%.2f", (avCov_Ontarg/numbrReads)*10000000}'`
#	avCov_Ontarg_IWGSP1_EnsemblPlnts22=`awk '{print $1}' $paths_to_libs/sampe_sort_markdup_rm_filter_-f2_covBed_IWGSP1_EnsemblPlnts22_ref_more_1_6_10_15_20_25_100x_covs.log`
#	avCov_Ontarg_JoseRef=`awk '{print $1}' $paths_to_libs/sampe_sort_markdup_rm_filter_-f2_covBed_Jose_ref_more_1_6_10_15_20_25_100x_covs.log`
	avCov_Ontarg_Rubsico5ABDL_MDH=`awk '{print $1}' $paths_to_libs/sampe_sort_markdup_rm_filter_-f2_bedT_coverage_-d_for_qPCR.log`
	avCov_Ontarg_Rubsico5ABDL_MDH_Norm=`awk -vavCov_Ontarg=$avCov_Ontarg_Rubsico5ABDL_MDH -vnumbrReads=$numbrReads 'BEGIN{printf "%.2f", (avCov_Ontarg/numbrReads)*10000000}'`
	
#	genome1xcovPc=`echo $genomecov | awk -vbasesInGenomeRef=10138701012 '{print ($1/basesInGenomeRef)*100}'`
	
	avCov_Offtarg=`awk '{print $1}' $paths_to_libs/sampe_sort_markdup_rm_filter_-f2_covBed_off-targ_orig_ref_more_1_6_10_15_20_25_100x_covs.log`
	avCov_Offtarg_EF=`awk -vavCov_Ontarg=$avCov_Ontarg -vavCov_Offtarg=$avCov_Offtarg 'BEGIN{printf "%.2f", (avCov_Ontarg/avCov_Offtarg)}'`
	avCov_Offtarg_Rubsico5ABDL_MDH_EF=`awk -vavCov_Ontarg=$avCov_Ontarg_Rubsico5ABDL_MDH -vavCov_Offtarg=$avCov_Offtarg 'BEGIN{printf "%.2f", (avCov_Ontarg/avCov_Offtarg)}'`
#	avCov_Offtarg_IWGSP1_EnsemblPlnts22=`awk '{print $1}' $paths_to_libs/sampe_sort_markdup_rm_filter_-f2_covBed_off-targ_IWGSP1_EnsemblPlnts22_ref_more_1_6_10_15_20_25_100x_covs.log`
#	avCov_Offtarg_IWGSP1_EnsemblPlnts22_EF=`awk -vavCov_Ontarg=$avCov_Ontarg_IWGSP1_EnsemblPlnts22 -vavCov_Offtarg=$avCov_Offtarg_IWGSP1_EnsemblPlnts22 'BEGIN{printf "%.2f", (avCov_Ontarg/avCov_Offtarg)}'`
#	avCov_Offtarg_JoseRef=`awk '{print $1}' $paths_to_libs/sampe_sort_markdup_rm_filter_-f2_covBed_off-targ_Jose_ref_more_1_6_10_15_20_25_100x_covs.log`
#	avCov_Offtarg_IWGSP1_EnsemblPlnts22_EF=`awk -vavCov_Ontarg=$avCov_Ontarg_JoseRef -vavCov_Offtarg=$avCov_Offtarg_JoseRef 'BEGIN{printf "%.2f", (avCov_Ontarg/avCov_Offtarg)}'`
	
	

#	echo "$sampleID	$avCov_Ontarg	$avCov_Ontarg_Norm	$avCov_Ontarg_IWGSP1_EnsemblPlnts22	$avCov_Ontarg_JoseRef	\
#	$avCov_Ontarg_Rubsico5ABDL_MDH	$avCov_Ontarg_Rubsico5ABDL_MDH_Norm	$avCov_Offtarg_Rubsico5ABDL_MDH_EF	\
#	$genome1xcovPc	\
#	$avCov_Offtarg	$avCov_Offtarg_EF	$avCov_Offtarg_IWGSP1_EnsemblPlnts22	$avCov_Offtarg_IWGSP1_EnsemblPlnts22_EF	$avCov_Offtarg_JoseRef	$avCov_Offtarg_IWGSP1_EnsemblPlnts22_EF"

	# Print the data I need here:
echo "		$lane	$sampleID	$description	$numbrReads	$CadenzaNo	\
$readsR1	$readsR2	$adaptorContamR1Pc	$adaptorContamR2Pc	$goodQualTrimR1Pc	$goodQualTrimR2Pc	\
$fragSize	$dupRate	$opticalDups	$opticalDupsPc	$nonDupReads	$nonDupReadsPc	\
$alnReadMates	$alnReadPairsPc	\
$onTargReadPairs	$onTargReadPairsPc	\
$avCov_OntargPc	$genomecovPc	\
$avCov_Ontarg	$avCov_Ontarg_Norm	$avCov_Offtarg	$avCov_Offtarg_EF	\
$avCov_Ontarg_Rubsico5ABDL_MDH	$avCov_Ontarg_Rubsico5ABDL_MDH_Norm	$avCov_Offtarg_Rubsico5ABDL_MDH_EF"
# $onTargReadPairs_q20  $onTargReadPairs_q20Pc
done \
>> ExonCapture_alignment_results.txt
#>> ExonCapture_alignment_results_52_test_samples.txt
#>> 35.ExonCapture_alignment_results.txt
#>> 35.ExonCapture_alignment_results_qPCR_cols_only.txt


# Transfer to Excel and table should be ready to send.
# Now just adding the rows for the new data to a global 
#table so that the red marks are not destroyed each time 
# data is added
# Look for any unusual patterns and mark in red.

### To do:
### 1. Some of the frag lengths aren't coming in so need to increase head -n - done - still check

### 2. Change Reads to ReadPairs but will need to change other calculations


