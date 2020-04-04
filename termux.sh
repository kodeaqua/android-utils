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

# Img2sdat wrapper
au_img2sdat(){
    python ${AU}/share/img2sdat/img2sdat.py "$1" "$2" "$3" "$4" "$5";
}

# Sdat2img wrapper
au_sdat2img(){
    python ${AU}/share/sdat2img/sdat2img.py "$1" "$2" "$3";
}

# Unpack
au_unpack(){
    echo "==> Preparing...";
    START=$(date +%s);

    echo "==> Cleaning build environment...";
    for junk in $(find . -type d)
      do
        rm -rf ${junk} >/dev/null 2>&1;
    done

    echo "==> Unpacking...";
    if [ -f ./system.new.dat.br ];
      then
        echo "    [1/3] decompressing system brotli...";
        brotli -d ./system.new.dat.br;
        if [ -f ./system.new.dat ];
          then
            echo "    [1/3] done!";
          else
            echo "    [1/3] failed!";
        fi;
      elif [ -f ./vendor.new.dat.br ];
        then
          echo "    [1/3] decompressing vendor brotli...";
          brotli -d ./vendor.new.dat.br;
          if [ -f ./vendor.new.dat ];
            then
              echo "    [1/3] done!";
            else
              echo "    [1/3] failed!";
          fi;
      else
        echo "    [1/3] skipped brotli task!";
    fi;
    if [ -f ./system.new.dat ];
      then
        echo "    [2/3] converting system dat...";
        au_sdat2img ./system.transfer.list ./system.new.dat ./system.img >/dev/null 2>&1;
        if [ -f ./system.img ];
          then
            echo "    [2/3] done!";
          else
            echo "    [2/3] failed!";
        fi;
      elif [ -f ./vendor.new.dat ];
        then
          echo "    [2/3] converting vendor dat...";
          au_sdat2img ./vendor.transfer.list ./vendor.new.dat ./vendor.img >/dev/null 2>&1;
          if [ -f ./vendor.img ];
            then
              echo "    [2/3] done!";
            else
              echo "    [2/3] failed!";
          fi;
      else
        echo "    [2/3] skipped convert task!";
    fi;
    if [ -f ./system.img ];
      then
        du -b ./system.img | cut -f -1 > ./.size;
        echo "    [3/3] extracting system image...";
        mkdir -p ./{system,tmp}
        losetup /dev/block/loop3 ./system.img;
        mount -t ext4 /dev/block/loop3 ./system;
        cp -rfp ./system ./tmp;
        losetup -d /dev/block/loop3;
        umount /dev/block/loop3;
        mv ./tmp/system .;
        rm -rf ./{system.img,tmp};
        if [ -d ./system ];
          then
            echo "    [3/3] done!";
          else
            echo "    [3/6] failed!";
        fi;
      elif [ -f ./vendor.img ];
        then
          du -b ./vendor.img | cut -f -1 > ./.size;
          echo "    [3/3] extracting vendor image...";
          mkdir -p ./{vendor,tmp}
          losetup /dev/block/loop3 ./vendor.img;
          mount -t ext4 /dev/block/loop3 ./vendor.img;
          cp -rfp ./vendor ./tmp;
          losetup -d /dev/block/loop3;
          umount /dev/block/loop3;
          mv ./tmp/vendor .;
          rm -rf ./{vendor.img,tmp};
          if [ -d ./vendor ];
            then
              echo "    [3/3] done!";
            else
              echo "    [3/3] failed!";
          fi;
      else
        echo "    [3/3] skipped image extracting!";
    fi;

    echo "==> Task completed in";
    END=$(date +%s);
    TIME=$((${END} - ${START}));
    echo "    $((${TIME} / 60)) minute(s) and $((${TIME} % 60)) seconds";
    
    echo "==> Press enter to continue...";
    read;    
}

au_repack(){
    au_header;

    echo "==> Checking stuff before building...";
    if [ $(find -type d -not -path . | cut --complement -d "/" -f -1) == "system" ];
      then
        BUILD_PARTITION="system";
        echo "    [1/4] partition: ${BUILD_PARTITION}";
      elif [ $(find -type d -not -path . | cut --complement -d "/" -f -1) == "vendor" ];
        then
          BUILD_PARTITION="vendor";
          echo "    [1/4] partition: ${BUILD_PARTITION}";
        else
          echo "    [1/4] failed!";
    fi;

    if [ -f ./.size ];
      then
        BUILD_SIZE=$(cat ./.size | cut -f -1);
        echo "    [2/4] size: ${BUILD_SIZE}";
      else
        echo "    [2/4] failed!";
    fi;

    if [ -f ./file_contexts.bin ];
      then
        echo "    [3/4] converting contexts binary...";
        sefparse ./file_contexts.bin -o ./file_contexts;
        if [ -f ./file_contexts ];
          then
            BUILD_CONTEXTS=1;
            echo "    [3/4] done!";
          else
            echo "    [3/4] failed!";
        fi;
      elif [ -f ./file_contexts ];
        then
          BUILD_CONTEXTS=1;
          echo "    [3/4] skipped convert task!";
        else
          BUILD_CONTEXTS=0;
          echo "    [3/4] failed!";
    fi;

    if [ -f ./.var ];
      then
        if [ $(cat ./.var | cut --complement -d "." -f -2) == "dat" ];
          then
            BUILD_VAR="dat";
            echo "    [4/4] build variant: ${BUILD_VAR}";
          elif [ $(cat ./.var | cut --complement -d "." -f -2) == "dat.br" ];
            then
              BUILD_VAR="dat.br";
              echo "    [4/4] build variant: ${BUILD_VAR}";
            else
              echo "    [4/4] failed!";
        fi;

    echo "==> Building image...";
    echo "    [1/4] cleaning junks...";
    find ${BUILD_PARTITION} -type d -empty -exec rm -rf {} \;
    echo "    [1/4] done!";

    echo "    [2/4] resetting timestamp...";
    find ${BUILD_PARTITION} -exec touch -a -m -h -d 2009-01-01T07:00:00 {} \;
    echo "    [2/4] done!";

    echo "    [3/4] creating ${BUILD_PARTITION} image";
    if [ ${BUILD_CONTEXTS} == 1 ];
      then
        make_ext4fs -s -T -1 -S ./file_contexts -L ${BUILD_PARTITION} -l ${BUILD_SIZE} -a ${BUILD_PARTITION} ./${BUILD_PARTITION}.img ./${BUILD_PARTITION} ./${BUILD_PARTITION};
        if [ -f ${BUILD_PARTITION}.new.dat ];
          then
            echo "    [3/4] done!";
          else
            echo "    [3/4] failed!";
        fi;
      elif [ ${BUILD_CONTEXTS} == 0 ];
        then
          make_ext4fs -s -T -1 -L ${BUILD_PARTITION} -l ${BUILD_SIZE} -a ${BUILD_PARTITION} ./${BUILD_PARTITION}.img ./${BUILD_PARTITION} ./${BUILD_PARTITION};
          if [ -f ${BUILD_PARTITION}/new.dat ];
            then
              echo "    [3/4] done!";
            else
              echo "    [3/4] failed!";
           fi;
        else
          echo "    [3/4] failed!";
    fi;
    
    if [ ${BUILD_VAR} == "dat.br" ];
      then
        echo "    [4/4] compressing dat with brotli...";
        brotli -q 6 ./${BUILD_PARTITION}.new.dat;
        if [ -f ./${BUILD_PARTITION}.new.dat.br ];
          then
            echo "    [4/4] done!";
          else
            echo "    [4/4] failed!";
        fi;
      elif [ ${BUILD_VAR} == "dat" ];
        then
          echo "    [4/4] skipped brotli task!";
        else
          echo "    [4/4] skipped brotli task!";
    fi;

    echo "==> Moving image to storage...";
    tsudo mkdir -p ${AU_EX}/prods/${DATE};
    tsudo mv ./${BUILD_PARTITION}.new.${BUILD_VAR}; ${AU_EX}/prods/${DATE};
    if [ -f ${AU_EX}/prods/${DATE}/${BUILD_PARTITION}.new.${BUILD_VAR} ];
      then
        echo "    done!";
      else
        echo "    failed!";
    fi;

    echo "==> Task completed in";
    END=$(date +%s);
    TIME=$((${END} - ${START}));
    echo "    $((${TIME} / 60)) minute(s) and $((${TIME} % 60)) seconds";

    echo "==> Press enter to continue...";
    read;
}

# AU menu
au_menu(){
    au_header;

    echo "Warning: AU menu is under construction! try again later!"
}

# Start
au_start;
