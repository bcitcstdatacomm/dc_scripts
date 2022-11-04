#!/usr/bin/env bash

# $1 https://github.com/???
# $2 directory
repo_clone()
{
  mkdir -p $2
  pushd "$2" || exit
  git clone $1.git
  popd || exit
}

# $1 directory
repo_update()
{
  pushd "$1" || exit
  git pull
  popd || exit
}

# $1
# $2
# $3
cmake_init()
{
  cmake -S $1 -B $1/cmake-build-debug
}

# $1
# $2
# $3
cmake_build()
{
  cmake --build $1/cmake-build-debug
}

# $1
# $2
# $3
cmake_install()
{
  sudo cmake --install $1/cmake-build-debug
}

# $1
# $2
# $3
cmake_remove()
{
  rm -rf $1/cmake-build-debug
}

# $1 rootdir path
# $2 repofile
# $3 c_compiler
# $4 cpp_compiler
do_install()
{
  while read line; do
    parts=( ${line} )
    base="${parts[0]}"
    repo="${parts[1]}"
    dirpath=$1/$base/$(basename $repo)
    repo_clone $repo $1/$base
    cmake_init $dirpath
    cmake_build $dirpath
    cmake_install $dirpath
    cmake_remove $dirpath
  done < "$2"
}

# $1 rootdir path
# $2 repofile
# $3 c_compiler
# $4 cpp_compiler
do_update()
{
  while read line; do
    parts=( ${line} )
    base="${parts[0]}"
    repo="${parts[1]}"
    dirpath=$1/$base/$(basename $repo)
    repo_update dirpath
    cmake_init $dirpath
    cmake_build $dirpath
    cmake_install $dirpath
    cmake_remove $dirpath
  done < "$2"
}

# $1 rootdir path
# $2 repofile
# $3 c_compiler
# $4 cpp_compiler
do_build()
{
  while read line; do
    parts=( ${line} )
    base="${parts[0]}"
    repo="${parts[1]}"
    dirpath=$1/$base/$(basename $repo)
    cmake_init $dirpath
    cmake_build $dirpath
    cmake_install $dirpath
    cmake_remove $dirpath
  done < "$2"
}

usage()
{
  if [[ $# -eq 1 ]]
  then
    echo "$1"
  fi

  printf "Usage: %s: [-i compiler] [-u compiler] [-b compiler] -d dir [-r repofile] \n" $0
  exit 2
}

command=
rootdir=
repofile=repos.txt

while getopts i:u:b:d:r: name
do
  case $name in
    i) command="install"
       compiler="$OPTARG";;
    u) command="update"
       compiler="$OPTARG";;
    b) command="build"
       compiler="$OPTARG";;
    d) rootdir="$OPTARG";;
    r) repofile="$OPTARG";;
    ?) usage;;
  esac
done

if [ -z ${command} ];
then
  usage
fi

if [ -z ${rootdir} ];
then
  usage
fi

if [[ "${command}" == "install" ]] || [[ "${command}" == "update" ]] || [[ "${command}" == "build" ]];
then
  if [[ "${compiler}" = "gcc" ]];
  then
    c_compiler=gcc
    cpp_compiler=g++
  elif [[ "${compiler}" = "clang" ]];
  then
    c_compiler=clang
    cpp_compiler=clang++
  else
    usage "compiler must be 'gcc' or 'clang'"
  fi
fi

case $command in
  install) do_install "${rootdir}" "${repofile}" "${c_compiler}" "${cpp_compiler}";;
  update)  do_update  "${rootdir}" "${repofile}" "${c_compiler}" "${cpp_compiler}";;
  build)   do_build   "${rootdir}" "${repofile}" "${c_compiler}" "${cpp_compiler}";;
esac
