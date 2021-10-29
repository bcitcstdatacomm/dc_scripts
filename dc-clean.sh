#!/usr/bin/env bash

remove_file()
{
  sudo rm -f /usr/local/lib/"$1"*
}
 
remove_file libdc_application
remove_file libdc_error libdc_application
remove_file libdc_fsm libdc_application
remove_file libdc_network libdc_application
remove_file libdc_posix libdc_application
remove_file libdc_util libdc_application
