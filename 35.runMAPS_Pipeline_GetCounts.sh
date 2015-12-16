#!/bin/bash

##################################
# 33.runMAPS_Pipeline_GetCounts.sh
#
# Paul Bailey	21.1.2015
#
##################################

hetMinCov=$1
homMinCov=$2
mapsPart2File=$3
mapsPart2ResultsFile=$4
infoTable=$5


# Extract the number of SNP calls from the maps-part2_*.txt files.
# Prepare the input sample info table without the header:
#tail -n +2 35.ExonCapture_PreparingTable.txt |
tail -n +2 $infoTable |
while read line; do

	lane=`echo $line | cut -d ' ' -f 1`	
	sampleID=`echo $line | cut -d ' ' -f 2` 
	description=`echo $line | cut -d ' ' -f 3` 
	CadenzaNo=`echo $line | cut -d ' ' -f 6` 
	
	lib=`echo $sampleID | sed 's/^[0-9]\{3,\}_//' | sed 's/_LDI[0-9]\{4,\}$//' `

	# Check results file exists for this hetMinCov.
	echo "$lib: hetMinCov = $hetMinCov" 
	ls $mapsPart2File
	ls $mapsPart2ResultsFile
		
	printf '%b' $lane "\t" $lib "\t" $description "\t" $CadenzaNo "\t" >> $mapsPart2ResultsFile

	totalSNPs=`cat $mapsPart2File | grep $lib | wc -l`
	homSNPs=`cat $mapsPart2File | grep $lib | grep 'hom' | wc -l`
	hetSNPs=`cat $mapsPart2File | grep $lib | grep 'het' | wc -l`
	hetHomRatio=`awk -vp=$hetSNPs -vq=$homSNPs 'BEGIN{printf "%.2f\n" , p / q}'`

	printf '%b' $totalSNPs "\t" $hetSNPs "\t" $homSNPs "\t" $hetHomRatio "\t" >> $mapsPart2ResultsFile
	
	GA=`cat $mapsPart2File | grep $lib | awk -v awkBaseChange=GA  '$11 ~ awkBaseChange {print $0}' | wc -l`
	CT=`cat $mapsPart2File | grep $lib | awk -v awkBaseChange=CT  '$11 ~ awkBaseChange {print $0}' | wc -l`
	AG=`cat $mapsPart2File | grep $lib | awk -v awkBaseChange=AG  '$11 ~ awkBaseChange {print $0}' | wc -l`
	TC=`cat $mapsPart2File | grep $lib | awk -v awkBaseChange=TC  '$11 ~ awkBaseChange {print $0}' | wc -l`
	AC=`cat $mapsPart2File | grep $lib | awk -v awkBaseChange=AC  '$11 ~ awkBaseChange {print $0}' | wc -l`
	AT=`cat $mapsPart2File | grep $lib | awk -v awkBaseChange=AT  '$11 ~ awkBaseChange {print $0}' | wc -l`
	CA=`cat $mapsPart2File | grep $lib | awk -v awkBaseChange=CA  '$11 ~ awkBaseChange {print $0}' | wc -l`
	CG=`cat $mapsPart2File | grep $lib | awk -v awkBaseChange=CG  '$11 ~ awkBaseChange {print $0}' | wc -l`
	GC=`cat $mapsPart2File | grep $lib | awk -v awkBaseChange=GC  '$11 ~ awkBaseChange {print $0}' | wc -l`
	GT=`cat $mapsPart2File | grep $lib | awk -v awkBaseChange=GT  '$11 ~ awkBaseChange {print $0}' | wc -l`
	TA=`cat $mapsPart2File | grep $lib | awk -v awkBaseChange=TA  '$11 ~ awkBaseChange {print $0}' | wc -l`
	TG=`cat $mapsPart2File | grep $lib | awk -v awkBaseChange=TG  '$11 ~ awkBaseChange {print $0}' | wc -l`

	EMS_Ts=`awk -v ga=$GA -v ct=$CT 'BEGIN{print ga + ct}'`
	EMS_Ts_Percent=`awk -v totalSNPs=$totalSNPs -v ga=$GA -v ct=$CT 'BEGIN{printf "%.2f", ((ga + ct)/totalSNPs)*100}'`
	nonEMS_Ts=`awk -v ag=$AG -v tc=$TC 'BEGIN{print ag + tc}'`
	nonEMS_Ts_Percent=`awk -v totalSNPs=$totalSNPs -v nonEMS_Ts=$nonEMS_Ts 'BEGIN{printf "%.2f", (nonEMS_Ts/totalSNPs)*100}'`
	nonEMS_Tv=`awk -v ac=$AC -v at=$AT -v ca=$CA -v cg=$CG -v gc=$GC -v gt=$GT -v ta=$TA -v tg=$TG 'BEGIN{print ac + at + ca + cg + gc + gt + ta + tg}'`
	nonEMS_Tv_Percent=`awk -v totalSNPs=$totalSNPs -v nonEMS_Tv=$nonEMS_Tv 'BEGIN{printf "%.2f", (nonEMS_Tv/totalSNPs)*100}'`
		
	printf '%b' $GA "\t" $CT "\t" $AG "\t" $TC "\t" $AC "\t" $AT "\t" $CA "\t" $CG "\t" $GC "\t" $GT "\t" $TA "\t" $TG "\t" \
	$EMS_Ts "\t" $EMS_Ts_Percent "\t" \
	$nonEMS_Ts "\t" $nonEMS_Ts_Percent "\t" \
	$nonEMS_Tv "\t" $nonEMS_Tv_Percent "\t.\t" \
	>> $mapsPart2ResultsFile

	printf '%b' "\n" >> $mapsPart2ResultsFile
done