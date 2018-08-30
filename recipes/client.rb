#
# Cookbook Name:: kafka
# Recipe:: client
#

include_recipe 'java::default'
include_recipe 'maven::default'
include_recipe 'kafka::_defaults'
include_recipe 'kafka::_setup'
include_recipe 'kafka::_install'
