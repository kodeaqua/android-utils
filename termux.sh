#!/data/data/com.termux/files/usr/bin/bash
# Android Utils
# Version 0.1
# Written by: Adam Najmi Zidan
# Special Thanks to: 1. Andrei Conache (xpirt)
#                    2. Jake Valleta (jakev)
#                    3. Google, StackOverFlow, and many more!
# This is broken build, because still WIP
# Don't ever clone this build if i didn't delete this yet
# ATTENTION: This script compatible with Android 8.1 below only, because of Pie Above remove their make_ext4fs

# Constants
export AU=${PREFIX}/share/au;
export AU_EX=${EXTERNAL_STORAGE}/au;

# List functions
# Launch action
au_start(){
    if [ $(which au) ];
      then
        au_menu;
      else
        au_setup;
    fi;
}

# AU proprietaries
au_self(){
    if ! [ -d ${AU} ];
      then
        mkdir -p ${AU};
        mkdir -p ${AU}/{bin,share};
    fi;
    if ! [ -d ${AU_EX} ];
      then
        tsudo mkdir -p ${AU_EX};
        tsudo mkdir -p ${AU_EX}/{logs,prods};
    fi;
}

# Package(s) checking
au_pkg(){
    if ! [ $(which tsu) ];
      then
        PACKAGES="tsu";
    fi

    if ! [ $(which git) ];
      then
        PACKAGES=${PACKAGES}" git";
    fi;

    if ! [ $(which python) ];
      then
        PACKAGES=${PACKAGES}" python";
    fi;

    if ! [ $(which brotli) ];
      then
        PACKAGES=${PACKAGES}" brotli";
    fi;

    if ! [ $(which 7z) ];
      then
        PACKAGES=${PACKAGES}" p7zip";
    fi;

    pkg update -y && pkg upgrade -y;
    pkg install ${PACKAGES} -y;
}

# Img2sdat installer
au_img2sdat(){
    git clone https://github.com/xpirt/img2sdat.git ${AU}/share/img2sdat;
    find ${AU}/share/img2sdat -type f -name "*.py" -exec chmod +x {} \;
}

# Sdat2img installer
au_sdat2img(){
    git clone https://github.com/xpirt/sdat2img.git ${AU}/share/sdat2img;
    find ${AU}/share/sdat2img -type f -name "*.py" -exec chmod +x {} \;
}

# Sefparse installer
au_sefparse(){
    git clone https://github.com/jakev/sefcontext-parser.git ${AU}/share/sefcontext-parser;
    cd ${AU}/share/sefcontext-parser;
    chmod +x setup.py && python setup.py install;
}

# Make_ext4fs installer
au_make_ext4fs(){
    if [ -f ${ANDROID_ROOT}/bin/make_ext4fs ];
      then
        cp ${ANDROID_ROOT}/bin/make_ext4fs ${AU}/bin/make_ext4fs
        chmod +x ${AU}/bin/make_ext4fs;
        tsudo ln -sf ${AU}/bin/make_ext4fs ${PREFIX}/bin/make_ext4fs;
    fi
}

# Header
au_header(){
    clear;
    echo "************************************************";
    echo "                Android Utils                   ";
    echo "************************************************";
    sleep 1;
}

# Setup
au_setup(){
    au_header;

    echo "==> Check and installing required packages...";
    au_pkg >/dev/null 2>&1;

    echo "==> Initializing project...";
    au_self >/dev/null 2>&1;

    echo "==> Checking tools...";
    echo "    [1/4] img2sdat";
    if [ -d ${AU}/share/img2sdat ];
      then
        echo "          already installed!";
      else
        echo "          installing...";
        au_img2sdat >/dev/null 2>&1;
        if [ -d ${AU}/share/img2sdat ];
          then
            echo "          installed!";
          else
            echo "          failed!";
        fi;
    fi;

    echo "    [2/4] sdat2img";
    if [ -d ${AU}/share/sdat2img ];
      then
        echo "          already installed!";
      else
        echo "          installing...";
        au_sdat2img >/dev/null 2>&1;
        if [ -d ${AU}/share/sdat2img ];
          then
            echo "          installed!";
          else
            echo "          failed!";
        fi;
    fi;

    echo "    [3/4] sefcontext-parser";
    if [ -d ${AU}/share/sefcontext-parser ];
      then
        echo "          already installed!";
      else
        echo "          installing...";
        au_sefparse >/dev/null 2>&1;
        if [ -d ${AU}/share/sefcontext-parser ];
          then
            echo "          installed!";
          else
            echo "          failed!";
        fi;
    fi;

    echo "    [4/4] make_ext4fs";
    if [ $(which make_ext4fs) ];
      then
        echo "          already installed!";
      else
        echo "          installing...";
        au_make_ext4fs >/dev/null 2>&1;
        if [ $(which make_ext4fs) ];
          then
            echo "          installed!";
          else
            echo "          failed!";
        fi;
    fi;
}

# AU menu
au_menu(){
    au_header;

    echo "Warning: AU menu is under construction! try again later!"
}

# Start
au_start;
