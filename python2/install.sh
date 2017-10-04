#!/bin/sh

#SETUP:
source config.sh

printf "${COLOR_RED}OpenCV3 + python2 installer${COLOR_NO}\n"
read -n 1 -s -r -p "Press any key to continue"
echo ""

# Get current working dir:
SCRIPT_DIR="$(pwd)"

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

# Check python path:
which python

# Install virtualenv and virtualenvwrapper
sudo pip install virtualenv virtualenvwrapper --ignore-installed six

# Update ~/.bash_profile with Virtualenv and VirtualenvWrapper
echo "" >> ~/.bash_profile
echo "# Virtualenv/VirtualenvWrapper" >> ~/.bash_profile
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bash_profile

# Reload bash_profile
source ~/.bash_profile

# Create cv virtualenv with Python 3 installed
mkvirtualenv cv

# Workon new env:
workon cv

# Install NumPy
pip install numpy

# Install OpenCV prerequisites
brew install cmake pkg-config
brew install jpeg libpng libtiff openexr
brew install eigen tbb

# If found install dir
cd ~
if [ -d "$OPENCV_INSTALL_DIR" ]; then
  # Update local storage:
  echo "Install dir found, resetting to needed version"
  cd ~/$OPENCV_INSTALL_DIR/opencv
  git fetch origin $OPENCV_VERSION
  git reset --hard $OPENCV_VERSION

  cd ~/$OPENCV_INSTALL_DIR/opencv_contrib
  git fetch origin $OPENCV_VERSION
  git reset --hard $OPENCV_VERSION
  git checkout $OPENCV_VERSION
else
  # Download OpenCV tagged release 3.2.0 and OpenCV Contrib:
  echo "Install dir not found, cloning from GitHub..."
  mkdir ~/$OPENCV_INSTALL_DIR
  cd ~/$OPENCV_INSTALL_DIR
  git clone https://github.com/opencv/opencv.git --branch ${OPENCV_VERSION} --single-branch
  git clone https://github.com/opencv/opencv_contrib --branch ${OPENCV_VERSION} --single-branch
fi


cd ~/$OPENCV_INSTALL_DIR/opencv
mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local \
	-D PYTHON2_PACKAGES_PATH=~/.virtualenvs/cv/lib/python2.7*/site-packages \
	-D PYTHON2_LIBRARY=/usr/local/Cellar/python/2.7*/Frameworks/Python.framework/Versions/2.7*/bin \
	-D PYTHON2_INCLUDE_DIR=/usr/local/Frameworks/Python.framework/Headers \
	-D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON \
	-D BUILD_EXAMPLES=ON \
	-D OPENCV_EXTRA_MODULES_PATH=~/$OPENCV_INSTALL_DIR/opencv_contrib/modules ..


  make -j4
  sudo make install

  echo ""
  echo ""
  echo "Don't forget to remove temporary files after install at:"
  echo "      ~/$OPENCV_INSTALL_DIR"
  echo ""
  echo "Done!"
  cd ${SCRIPT_DIR}
  echo ""
  python test_install.py
