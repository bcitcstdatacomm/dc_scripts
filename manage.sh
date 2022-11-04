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

# $1 directory path
repo_update()
{
  pushd "$1" || exit
  git pull
  popd || exit
}

# $1 directory path
# $2 c compiler
# $3 c++ compiler
cmake_init()
{
  cmake -DCMAKE_C_COMPILER="$2" -DCMAKE_CXX_COMPILER="$3" -S "$1" -B "$1"/cmake-build-debug
}

# $1 directory path
cmake_build()
{
  cmake --build "$1"/cmake-build-debug
}

# $1 directory path
cmake_install()
{
  sudo cmake --install "$1"/cmake-build-debug
}

# $1 directory path
cmake_remove()
{
  rm -rf "$1"/cmake-build-debug
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
    cmake_init $dirpath "$3" "$4"
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
    cmake_remove $dirpath
    repo_update $dirpath
    cmake_init $dirpath "$3" "$4"
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
    cmake_remove $dirpath
    dirpath=$1/$base/$(basename $repo)
    cmake_init $dirpath "$3" "$4"
    cmake_build $dirpath
    cmake_install $dirpath
    cmake_remove $dirpath
  done < "$2"
}

# $1 optional message
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
