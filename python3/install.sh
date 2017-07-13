#!/bin/sh

#SETUP:
source config.sh

# Get current working dir:
SCRIPT_DIR='$(pwd)'

# Accept the Apple Developer license
sudo xcodebuild -license

# Install Apple Command Line Tools
sudo xcode-select --install

# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Update brew package definitions
brew update

# Update ~/.bash_profile with Homebrew
echo "" >> ~/.bash_profile
echo "# Homebrew" >> ~/.bash_profile
echo "export PATH=/usr/local/bin:$PATH" >> ~/.bash_profile

# Reload bash_profile
source ~/.bash_profile

# Install Python 3:
brew install python3

# Create some symbolic links
brew linkapps python3

# Check python path:
which python3

# Install virtualenv and virtualenvwrapper
sudo pip install virtualenv virtualenvwrapper --ignore-installed six

# Update ~/.bash_profile with Virtualenv and VirtualenvWrapper
echo "" >> ~/.bash_profile
echo "# Virtualenv/VirtualenvWrapper" >> ~/.bash_profile
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bash_profile

# Reload bash_profile
source ~/.bash_profile

# Create cv virtualenv with Python 3 installed
mkvirtualenv cv -p python3

# Workon new env:
workon cv

# Install NumPy
pip install numpy

# Install OpenCV prerequisites
brew install cmake pkg-config
brew install jpeg libpng libtiff openexr
brew install eigen tbb

# Download OpenCV tagged release 3.2.0 and OpenCV Contrib:
mkdir ~/$OPENCV_INSTALL_DIR
cd ~/$OPENCV_INSTALL_DIR
git clone https://github.com/opencv/opencv.git --branch ${OPENCV_VERSION} --single-branch
git clone https://github.com/opencv/opencv_contrib --branch ${OPENCV_VERSION} --single-branch

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
sudo make install

# Rename wrong .so file
cd /usr/local/lib/python3.*/site-packages/
mv cv2.*m-darwin.so cv2.so

# Sym-link OpenCV bindings into the cv virtual environment for Python 3.5
cd ~/.virtualenvs/cv/lib/python3.*/site-packages/
ln -s /usr/local/lib/python3.*/site-packages/cv2.so cv2.so

cd $SCRIPT_DIR
python py_install_test.py

echo ""
echo ""
echo "Don't forget to remove temporary files after install at:"
echo "      ~/$OPENCV_INSTALL_DIR"
echo ""
echo "Done!"
cd $SCRIPT_DIR
