#!/usr/bin/env bash

update_repo()
{
  pushd $1 > /dev/null || exit

  for repo in $2; do
    REPO_DIR_NAME=$(basename $repo)

    # https://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git
    git -C $REPO_DIR_NAME fetch

    HEAD_VERSION=$(git -C $REPO_DIR_NAME rev-parse HEAD)
    LOCAL_VERSION=$(git -C $REPO_DIR_NAME rev-parse @{u})

    if [ "$HEAD_VERSION" != "$LOCAL_VERSION" ]; then
      git -C $REPO_DIR_NAME pull
      cmake --build $REPO_DIR_NAME/cmake-build-debug --target rebuild_cache
      cmake --build $REPO_DIR_NAME/cmake-build-debug --clean-first
    else
      cmake --build $REPO_DIR_NAME/cmake-build-debug
    fi

    sudo cmake --install $REPO_DIR_NAME/cmake-build-debug
  done

  popd > /dev/null || exit
}

update_sub_repo()
{
  pushd $1 > /dev/null || exit

  for repo in $2; do
    REPO_DIR_NAME=$(basename $repo)
    git -C $REPO_DIR_NAME pull
  done

  popd > /dev/null || exit
}

if [ -z ${1} ]; then echo "usage: ./dc-install.sh <dir name to update>"; exit 1; fi

BASE_DIR="$1/dc"
REPOS_3RD_PARTY="cgreen-devs/cgreen hyperrealm/libconfig"
REPOS_LIBRARIES="bcitcstdatacomm/libdc_posix bcitcstdatacomm/libdc_util bcitcstdatacomm/libdc_fsm bcitcstdatacomm/libdc_network bcitcstdatacomm/libdc_application"
REPOS_TOOLS="bcitcstdatacomm/dc_dump"
REPOS_PROGRAMMING="bcitcstdatacomm/c_programming bcitcstdatacomm/posix_programming bcitcstdatacomm/network_programming"

echo "Setting up: $BASE_DIR"

update_repo ~/"$BASE_DIR"/3rdparty        "$REPOS_3RD_PARTY"
update_repo ~/"$BASE_DIR"/libraries       "$REPOS_LIBRARIES"
update_repo ~/"$BASE_DIR"/tools           "$REPOS_TOOLS"
update_sub_repo ~/"$BASE_DIR"/programming "$REPOS_PROGRAMMING"
