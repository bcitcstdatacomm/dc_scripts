#!/usr/bin/env bash

remove_file()
{
  sudo rm -f /usr/local/lib/"$1"*
}
 
remove_file libdc_application
remove_file libdc_error
remove_file libdc_fsm
remove_file libdc_network
remove_file libdc_posix
remove_file libdc_unix
remove_file libdc_util
