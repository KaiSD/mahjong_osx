#!/bin/bash

set -e

if ! test -d hacks ; then 
	echo "hacks not found"
	exit 1
fi

function wipe_dir {
	if test -d $1 ; then
		if [[ $FASTBUILD == "Y" ]] ; then
			return 1
		fi

		rm -rf $1
		return 0
	fi
}

function explain {
	ret=`echo $?`
	case $ret in
	1)
	   echo "exists, skipped";;
	*)
	   echo "Unknown exit code: $ret" ;;
	esac
}

function build_ogg {
	echo -n "Building ogg container lib ... " 
	wipe_dir libogg-1.3.0 || return 1
    echo "unpacking"
	tar xpf libogg-1.3.0.tar.gz
    echo "compiling"
	cd libogg-1.3.0
	CC="clang" CFLAGS="-arch i386 " ./configure --enable-static --disable-shared --prefix=/usr
	make -j9
	sudo make install
	cd ..
}

function build_vorbis {
	echo -n "Building vorbis lib ... " 
	wipe_dir libvorbis-1.3.2 || return 1
    echo "unpacking"
	tar xpf libvorbis-1.3.2.tar.gz 
    echo "compiling"
	cd libvorbis-1.3.2
	CC="clang" CFLAGS="-arch i386 " ./configure --enable-static --disable-shared --prefix=/usr
	make -j9
	sudo make install
	cd ..
}

function build_alure {
	echo -n "Building alure ... " 
	wipe_dir alure-1.2 || return 1
    echo "unpacking"
	tar xpf alure-1.2.tar.bz2
    echo "compiling"
	cd alure-1.2
	CC=clang CXX=clang++ cmake -DCMAKE_BUILD_TYPE=Release -DDYNLOAD=OFF -DSNDFILE_LIBRARY="" -DCMAKE_OSX_ARCHITECTURES=i386 .
	make -j9
	cd ..
}

function build_ogre {
    echo -n "Building ogre ... " 
	wipe_dir ogre || return 1
	echo "unpacking"
	tar xpf ogre-8ba11f06dcaf.tgz
	echo "adding build dependencies"
	tar xpf hacks/OgreDependencies.tgz -C ogre
	echo "patching"
	cat hacks/Ogre.patch | patch -d ogre -p1
	echo "compiling"
	cd ogre/SDK/OSX
	./make_osx.sh
	cd ../../../
}

function build_cegui {
    echo -n "Building cegui ... " 
	wipe_dir cegui_mk2 || return 1
    echo "unpacking"
	tar xpf cegui_mk2-ce3f1bd08b58.tgz
    echo "adding build dependencies"
	tar xpf hacks/CEGUIdependencies.tgz -C cegui_mk2
    echo "replacing xcode config"
	cp hacks/CEGUI.xcodeproj cegui_mk2/projects/Xcode/CEGUI.xcodeproj/project.pbxproj
    echo "compiling"
	xcodebuild -project cegui_mk2/projects/Xcode/CEGUI.xcodeproj -target CEGUIOgreRenderer -configuration Release
}

function build_mahjong {
	tar xpf ogs-mahjong-0.9.1-src.tar.bz2
}

echo
echo "-= Starting build sequence =-"
echo 

build_ogg || explain
build_vorbis || explain
build_alure || explain
build_ogre || explain
build_cegui || explain
#build_mahjong || explain
