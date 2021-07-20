#!/usr/bin/env bash

clone_repo()
{
  pushd $1 > /dev/null || exit

  for repo in $2; do
    git clone https://github.com/$repo.git
    REPO_DIR_NAME=$(basename $repo)
    mkdir $REPO_DIR_NAME/cmake-build-debug
    cmake -DCMAKE_C_COMPILER="$3" -DCMAKE_CXX_COMPILER="$4" -S $REPO_DIR_NAME -B $REPO_DIR_NAME/cmake-build-debug
    cmake --build $REPO_DIR_NAME/cmake-build-debug
    sudo cmake --install $REPO_DIR_NAME/cmake-build-debug

    if command -v ldconfig &> /dev/null
    then
      sudo ldconfig
    fi
  done

  popd > /dev/null || exit
}

clone_sub_repo()
{
  pushd $1 > /dev/null || exit

  for repo in $2; do
    git clone https://github.com/$repo.git
  done

  popd > /dev/null || exit
}

if [ -z ${3} ]; then echo "usage: ./dc-install.sh <dir name to install to> <c compiler> <c++ compiler>"; exit 1; fi

BASE_DIR="$1/dc"
ROOT_DIRS="3rdparty libraries tools programming"
REPOS_3RD_PARTY="cgreen-devs/cgreen hyperrealm/libconfig"
REPOS_LIBRARIES="bcitcstdatacomm/libdc_posix bcitcstdatacomm/libdc_util bcitcstdatacomm/libdc_fsm bcitcstdatacomm/libdc_network bcitcstdatacomm/libdc_application"
REPOS_TOOLS="bcitcstdatacomm/dc_dump"
REPOS_PROGRAMMING="bcitcstdatacomm/c_programming bcitcstdatacomm/posix_programming bcitcstdatacomm/network_programming"

echo "Setting up: $BASE_DIR"

mkdir -p ~/$BASE_DIR

for dir in $ROOT_DIRS; do
	mkdir ~/"$BASE_DIR"/$dir
done

#clone_repo ~/"$BASE_DIR"/3rdparty        "$REPOS_3RD_PARTY"   "$2" "$3"
#clone_repo ~/"$BASE_DIR"/libraries       "$REPOS_LIBRARIES"   "$2" "$3"
#clone_repo ~/"$BASE_DIR"/tools           "$REPOS_TOOLS"       "$2" "$3"
clone_sub_repo ~/"$BASE_DIR"/programming "$REPOS_PROGRAMMING" "$2" "$3"
