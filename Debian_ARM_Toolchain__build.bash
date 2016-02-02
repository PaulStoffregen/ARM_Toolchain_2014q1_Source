#!/bin/bash -ex
start=`date`

# Check for programs that are needed

echo "Checking for necessary programs..."
APS=""


echo -n "Checking for gcc-4.8 ... "
if [ `which gcc-4.8` ]; then
    echo "ok"
else
    echo "nope"
    APS+="gcc-4.8 "
fi

echo -n "Checking for g++-4.8 ... "
if [ `which g++-4.8` ]; then
    echo "ok"
else
    echo "nope"
    APS+="g++-4.8 "
fi

echo -n "Checking for cpp-4.8 ... "
if [ `which cpp-4.8` ]; then
    echo "ok"
else
    echo "nope"
    APS+="cpp-4.8 "
fi

if [ "$APS" != "" ]; then
    echo "Ooops, Applications need .. :(~"
    echo $APS
    echo ""
    echo "Would you like me to get them for you ?? (y/n): "
    echo "Debian Default is yes"
	read resp
	if [ "$resp" = "" ] || [ "$resp" = "y" ] || [ "$resp" = "yes" ]; then
        #apt-get update
        apt-get -y install $APS
        apt-get clean
    else
        echo "Needed Application not installed"
        echo "Exiting .. :(~"
        exit 1
    fi
else
    echo "No applications needed .. :)~"
fi


if [[ ! `update-alternatives --set g++ /usr/bin/g++-4.8 | grep error:` ]]; then
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 100
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 100
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 50
    update-alternatives --install /usr/bin/cpp cpp-bin /usr/bin/cpp-4.9 100
    update-alternatives --install /usr/bin/cpp cpp-bin /usr/bin/cpp-4.8 50

    update-alternatives --set g++ /usr/bin/g++-4.8
    update-alternatives --set gcc /usr/bin/gcc-4.8
    update-alternatives --set cpp-bin /usr/bin/cpp-4.8
else
    update-alternatives --set g++ /usr/bin/g++-4.8
    update-alternatives --set gcc /usr/bin/gcc-4.8
    update-alternatives --set cpp-bin /usr/bin/cpp-4.8
fi


if [[ `nproc` > "2" ]]; then
    JOBS=$((`nproc`+1))
    # Silence is Golden
    JOBS+=" -s"
else
    JOBS="2 -s"
fi
export JOBS


cd src
find -name '*.tar.*' | xargs -I% tar -xf %
cd zlib-1.2.5
patch -p1 <../zlib-1.2.5.patch
cd ../../

./build-prerequisites.sh --skip_mingw32

prerequisites=`date`
echo -e"\n\n\n\nbuild-toolchain.sh\n\n\n\n"

./build-toolchain.sh --skip_mingw32

update-alternatives --auto g++
update-alternatives --auto gcc
update-alternatives --auto cpp-bin

echo $start
echo $prerequisites
date

exit 0

