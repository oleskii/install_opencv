#!/bin/sh
#SETUP:
source config.sh

# Remove folders:
rm -rf ~/$OPENCV_INSTALL_DIR

# Remove OpenCV:
mkdir ~/$OPENCV_INSTALL_DIR
cd ~/$OPENCV_INSTALL_DIR
git clone https://github.com/opencv/opencv.git --branch ${OPENCV_VERSION} --single-branch

PYTHON3_LIBRARY="$(ls /usr/local/Cellar/python3/3.*/Frameworks/Python.framework/Versions/3.*/lib/python3.*/config-3.*/libpython3.*.dylib | sed -n 1p)"
PYTHON3_INCLUDE_DIR="$(ls -d /usr/local/Cellar/python3/3.*/Frameworks/Python.framework/Versions/3.*/include/python3.*/ | sed -n 1p)"

cd ~/$OPENCV_INSTALL_DIR/opencv
mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=~/$OPENCV_INSTALL_DIR/opencv_contrib/modules \
    -D PYTHON3_LIBRARY=$PYTHON3_LIBRARY \
    -D PYTHON3_INCLUDE_DIR=$PYTHON3_INCLUDE_DIR \
    -D PYTHON3_EXECUTABLE=$VIRTUAL_ENV/bin/python \
    -D BUILD_opencv_python2=OFF \
    -D BUILD_opencv_python3=ON \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=ON ..

make -j4
sudo make uninstall

# Remove Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
