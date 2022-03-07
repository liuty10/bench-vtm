#!/bin/bash
############################################################
# Help                                                     #
############################################################
usage()
{
   # Display Usage
   echo "Usage: $0 [-n <string>] [-m <string>] [-t <string>] [-o <string>] [-p]"

   echo "Evaluate compression efficiency with specified model(s) and test dataset of one game."
   echo
   echo "Example: $0 -m \"./models/supertuxkart*\" -t \"../datasets/GameImage_dataset/test/supertuxkart*/*.png\" -o \"./results/supertuxkart/\""
   echo "Example: $0 -n supertuxkart/0ad/redeclipse/dota2/inmind/imhotep"
   echo
   echo "options:"
   echo "-n     game name. If we only input game name, then, -m -t -o would have default parameters, also plot figure(-p) is enabled"
   echo "-m     model path and name in GLOB patterns. e.g., ./models/stk*"
   echo "-t     testing data path and name in GLOB patterns."
   echo "-o     output path is a directory, and each model would generate an csv file."
   echo "-p     plot rate-distortion figure."
   echo "-h     Print this message and exit."
   echo
   exit 1
}

# large, median, small, xsmall
model_size="vtm"

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options

while getopts "hn:m:t:o:p" flag
do
    case "${flag}" in
        n) gamename=${OPTARG};;
        m) modelpath=${OPTARG};;
        t) testpath=${OPTARG};;
        o) outputpath=${OPTARG};;
        p) plotfigure=1;;
	*) usage;;
    esac
done

if [ -n "${gamename}" ]; then
	if [ -z "${modelpath}" ]; then
		modelpath="./models/${model_size}/${gamename}*"
	fi
	if [ -z "${testpath}" ]; then
		testpath="../datasets/GameImage_dataset/test/${gamename}*/*.png"
	fi
	if [ -z "${outputpath}" ]; then
		outputpath="./results/${gamename}"
	fi
	plotfigure=1
elif [ -z "${modelpath}" ] || [ -z "${testpath}" ] || [ -z "${outputpath}" ]; then
	usage
else
	gamename="default"
fi

[ -e ${outputpath} ] || mkdir -p ${outputpath}

echo "Gamename: $gamename";
echo "modelpath: $modelpath";
echo "testpath: $testpath";
echo "outputpath: $outputpath";
echo "plotfigure: $plotfigure";


############################################################
############################################################
# Main program                                             #
############################################################
############################################################

echo "model,name,shape,binsize,enc,bpp,dec,psnr,ms_ssim,ms_db" > ${model_size}_${gamename}.csv
for qp_value in {25,30,35,40,45,50}
do
    echo "qp: $qp_value"
    for inpng in ${testpath}; do
        echo $inpng
        width=`identify -format '%w' ${inpng}`
        height=`identify -format '%h' ${inpng}`
        start1=$(date +%s.%6N)
        ffmpeg -i ${inpng} -pix_fmt yuv420p out_${gamename}.yuv
        ./bin/EncoderAppStatic -i out_${gamename}.yuv -wdt ${width} -hgt ${height} -c ./cfg/encoder_intra_vtm.cfg -f 1 -fr 1 -q ${qp_value} -cf 420 -b out_${gamename}.vtm -o rec_${gamename}.yuv
        start2=$(date +%s.%6N)
        ./bin/DecoderAppStatic -d 8 -b out_${gamename}.vtm -o dec_${gamename}.yuv
        ffmpeg -pixel_format yuv420p -video_size ${width}x${height} -framerate 1 -i dec_${gamename}.yuv out_${gamename}.png
        start3=$(date +%s.%6N)
        enc_time=$(echo "scale=6; $start2 - $start1" | bc)
        dec_time=$(echo "scale=6; $start3 - $start2" | bc)
        python3 msssim.py ${inpng} out_${gamename}.png ${model_size}_${gamename}.csv ${qp_value} ${enc_time} ${dec_time} out_${gamename}.vtm
        rm dec_${gamename}.yuv out_${gamename}.png out_${gamename}.vtm out_${gamename}.yuv rec_${gamename}.yuv
    done
done


############################################################
# Output CSV and Plot figure                               #
############################################################
