Step 1: Building

We will use Fraunhofer`s VTM (VVC Test Model) version of encoder:

git clone https://vcgit.hhi.fraunhofer.de/jvet/VVCSoftware_VTM.git

After that we can do the job:

cd VVCSoftware_VTM/
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4
cd ../bin                            #here will be all binaries

We receive following binaries:

ls
DecoderAnalyserAppStatic  DecoderAppStatic  EncoderAppStatic  parcatStatic  SEIRemovalAppStatic  StreamMergeAppStatic  umake


Step 2: Encoding & decoding

Now we have to check that binaries are working. We will do that by encoding and the decoding the stream. Yeah you can type ./EncoderAppStatic --help to see all available parameter and choose needed parameters but I will share with you the simple example:

./EncoderAppStatic -i vicue_test_432x240_420_8_500.yuv -wdt 432 -hgt 240 -c encoder_randomaccess_vtm.cfg -f 5 -fr 30

Where

    encoder_randomaccess_vtm.cfg is a file from VVCSoftware_VTM/cfg
    vicue_test_432x240_420_8_500.yuv is a simple source stream

Parameters

    -i- input stream
    -wdt- width of the stream
    -hgt - height of the stream
    -c- configuration file to use
    -f- number of frames to be encoded (we used only 5 to speed up our case)
    -fr- frame rate

To decode stream backwards:

./DecoderAppStatic -b str.bin -o rec_decoded.yuv

Parameters

    -b- input encoded
    -o- reconstruct output

See evaluate.sh for encoding images.

Profit! Now we can build VTM, encode and decode with it. We know basics to start researching and development in the domain of VVC and media.

Thanks for the reading. In future articles I will try to share more in-depth topics. I hope that this small note was useful for you!

How to use evaluate.sh file?
./evaluate.sh -n supertuxkart
./evaluate.sh -n 0ad
./evaluate.sh -n redeclipse
./evaluate.sh -n dota2
./evaluate.sh -n inmind
./evaluate.sh -n imhotep
