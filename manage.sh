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
  if [ "$?" -ne 0 ]; then
    printf "ERROR building %s" $2
    exit 1
  fi
}

# $1 directory path
cmake_install()
{
  sudo cmake --install "$1"/cmake-build-debug

  if command -v ldconfig &> /dev/null
  then
    sudo ldconfig
  fi
}

# $1 directory path
cmake_remove()
{
  rm -rf "$1"/cmake-build-debug
}

remove_library()
{
  if [ -d "/usr/local/lib/$1" ];
  then
    sudo rm -rf /usr/local/lib/$1
  else
    sudo rm -f /usr/local/lib/$1
  fi
}

remove_includes()
{
  if [ -d "/usr/local/include/$1" ];
  then
    sudo rm -rf /usr/local/include/$1
  else
    sudo rm -f /usr/local/include/$1
  fi
}

remove_tool()
{
  sudo rm -f /usr/local/bin/$1
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
# $3 c_compiler
# $4 cpp_compiler
do_build()
{
    cmake_init "$1" "$2" "$3"
    cmake_build "$1"
    cmake_install "$1"
    cmake_remove "$1"
}

# $1 rootdir path
# $2 repofile
# $3 c_compiler
# $4 cpp_compiler
do_build_all()
{
  while read line; do
    parts=( ${line} )
    base="${parts[0]}"
    repo="${parts[1]}"
    cmake_remove $dirpath
    dirpath=$1/$base/$(basename $repo)
    do_build "$dirpath" "$3" "$4"
  done < "$2"
}

do_delete()
{
  while read line; do
    parts=( ${line} )
    kind="${parts[0]}"
    binary="${parts[2]}"

    if [[ "${kind}" == "3rdparty" ]] || [[ "${kind}" == "libraries" ]]
    then
      include="${parts[3]}"
      remove_library $binary
      remove_includes $include
    else
      remove_tool $binary
    fi
  done < "$2"
}

# $1 optional message
usage()
{
  if [[ $# -eq 1 ]]
  then
    echo "$1"
  fi

  printf "Usage: %s: -r root-dir-path [-i compiler-family] [-u compiler-family] [-b compiler-family] [-d] [-f repo-file-path]\n" $0
  printf "Where:\n"
  printf "\t -r root-dir-path   - the location of the installation\n"
  printf "\t -i compiler-family - install using gcc or clang\n"
  printf "\t -u compiler-family - updated using gcc or clang\n"
  printf "\t -b compiler-family - build using gcc or clang\n"
  printf "\t -d                 - delete installed file (/usr/local/bin, /usr/local/include)\n"
  printf "\t -f repo-file-path  - the list of repositiries to use (default ./repos.txt)\n"
  exit 2
}

command=
rootdir=
repofile=repos.txt

while getopts di:u:b:r:f: name
do
  case $name in
    i) command="install"
       compiler="$OPTARG";;
    u) command="update"
       compiler="$OPTARG";;
    b) command="build"
       compiler="$OPTARG";;
    d) command="delete";;
    r) rootdir="$OPTARG";;
    f) repofile="$OPTARG";;
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
  install) do_install   "${rootdir}" "${repofile}" "${c_compiler}" "${cpp_compiler}";;
  update)  do_update    "${rootdir}" "${repofile}" "${c_compiler}" "${cpp_compiler}";;
  build)   do_build_all "${rootdir}" "${repofile}" "${c_compiler}" "${cpp_compiler}";;
  delete)  do_delete    "${rootdir}" "${repofile}";;
esac
