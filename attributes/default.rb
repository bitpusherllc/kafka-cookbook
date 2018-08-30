#
# Cookbook Name:: kafka
# Attributes:: default
#

#
# Version of Kafka to install.
default['kafka']['version'] = '2.0.0'

#
# Base URL for Kafka releases. The recipes will a download URL using the
# `base_url`, `version` and `scala_version` attributes.
default['kafka']['base_url'] = 'https://archive.apache.org/dist/kafka'

#
# SHA-256 checksum of the archive to download, used by Chef's `remote_file`
# resource.
default['kafka']['checksum'] = 'b5f1539c4030e6f6e64d0c14a9acea31156e7cbf2cb66c93ca2b6ca732ba7955'

#
# MD5 checksum of the archive to download, which will be used to validate that
# the "correct" archive has been downloaded.
default['kafka']['md5_checksum'] = nil

#
# SHA512 checksum of the archive to download, which will be used to validate that
# the "correct" archive has been downloaded.
default['kafka']['sha512_checksum'] = 'b28e81705e30528f1abb6766e22dfe9dae50b1e1e93330c880928ff7a08e6b38ee71cbfc96ec14369b2dfd24293938702cab422173c8e01955a9d1746ae43f98'

#
# Scala version of Kafka.
default['kafka']['scala_version'] = '2.12'

#
# Directory where to install Kafka.
default['kafka']['install_dir'] = '/opt/kafka'

#
# Directory where to install *this* version of Kafka.
# For actual default value see `_defaults` recipe.
default['kafka']['version_install_dir'] = nil

#
# Directory where to install add-ons for *this* version of Kafka.
# For actual default value see `_defaults` recipe.
default['kafka']['version_addons_install_dir'] = nil

#
# Directory where the downloaded archive will be extracted to.
default['kafka']['build_dir'] = ::File.join(Dir.tmpdir, 'kafka-build')

#
# Directory where to store logs from Kafka.
default['kafka']['log_dir'] = '/var/log/kafka'

#
# Directory where to keep Kafka configuration files. For the
# actual default value see `_defaults` recipe.
default['kafka']['config_dir'] = nil

#
# JMX port for Kafka.
default['kafka']['jmx_port'] = 9999

#
# Prometheus-compatible metrics port for Kafka.
default['kafka']['prometheus_metrics_port'] = 7071

#
# JMX configuration options for Kafka.
default['kafka']['jmx_opts'] = %w[
  -Dcom.sun.management.jmxremote
  -Dcom.sun.management.jmxremote.authenticate=false
  -Dcom.sun.management.jmxremote.ssl=false
].join(' ')

#
# User for directories, configuration files and running Kafka.
default['kafka']['user'] = 'kafka'

#
# Should node['kafka']['user'] and node['kafka']['group'] be created?
default['kafka']['manage_user'] = true

#
# Override ID for user used for directories, configuration files and running Kafka.
default['kafka']['uid'] = nil

#
# Group for directories, configuration files and running Kafka.
default['kafka']['group'] = 'kafka'

#
# Override ID for group used for directories, configuration files and running Kafka.
default['kafka']['gid'] = nil

#
# JVM heap options for Kafka.
default['kafka']['heap_opts'] = '-Xmx1G -Xms1G'

#
# Generic JVM options for Kafka.
default['kafka']['generic_opts'] = lazy { format('-javaagent:%s=%d:%s', ::File.join(node['kafka']['version_addons_install_dir'], 'jmx_prometheus_javaagent-0.3.1.jar'), node['kafka']['prometheus_metrics_port'], ::File.join(node['kafka']['config_dir'], 'kafka-2_0_0.yml')) }

#
# GC log options for Kafka. For the actual default value
# see `_defaults` recipe.
default['kafka']['gc_log_opts'] = nil

#
# Log4j options for Kafka.
default['kafka']['log4j_opts'] = lazy { format('-Dlog4j.configuration=file:%s', ::File.join(node['kafka']['config_dir'], 'log4j.properties')) }

#
# JVM Performance options for Kafka.
default['kafka']['jvm_performance_opts'] = %w[
  -server
  -XX:+UseCompressedOops
  -XX:+UseG1GC
  -XX:+CMSClassUnloadingEnabled
  -XX:+CMSScavengeBeforeRemark
  -XX:+DisableExplicitGC
  -Djava.awt.headless=true
].join(' ')

#
# The type of "init" system to install scripts for. Valid values are currently
# :sysv, :systemd and :upstart.
default['kafka']['init_style'] = :systemd

#
# The ulimit file limit.
# If this value is not set, Kafka will use whatever the system default is.
# Depending on your system setup you might want to set this to a rather high
# value, or you will most likely run into issues with Kafka simply dying for no
# particular reason as it needs to keep a lot of file handles for socket
# connections and log files for all partitions.
default['kafka']['ulimit_file'] = nil

#
# Automatically start kafka service.
default['kafka']['automatic_start'] = false

#
# Automatically restart kafka on configuration change.
# This also implies `automatic_start` even if it's set to `false`.
# The reason for this is that I can see the need for automatically starting
# Kafka if it's not running, but not necessarily restart on configuration
# changes.
default['kafka']['automatic_restart'] = false

#
# Attribute to set the recipe to used to coordinate Kafka service start
# if nothing is set the default recipe "_coordinate" will be used
# Refer to issue #58 for details.
default['kafka']['start_coordination']['recipe'] = 'kafka::_coordinate'

#
# Attribute to set the timeout in seconds when stopping the broker
# before sending SIGKILL (or equivalent).
default['kafka']['kill_timeout'] = 10

#
# `broker` namespace for configuration of a broker.
# Initially set to an empty Hash to avoid having `fetch(:broker, {})`
# statements in helper methods and the alike.
default['kafka']['broker'] = {}

#
# Root logger level and appender.
default['kafka']['log4j']['root_logger'] = 'INFO, kafkaAppender'

#
# Appender definitions for various Kafka classes.
default['kafka']['log4j']['appenders'] = {
  'kafkaAppender' => {
    type: 'org.apache.log4j.DailyRollingFileAppender',
    date_pattern: '.yyyy-MM-dd',
    file: lazy { ::File.join(node['kafka']['log_dir'], 'kafka.log') },
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
  'stateChangeAppender' => {
    type: 'org.apache.log4j.DailyRollingFileAppender',
    date_pattern: '.yyyy-MM-dd',
    file: lazy { ::File.join(node['kafka']['log_dir'], 'kafka-state-change.log') },
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
  'requestAppender' => {
    type: 'org.apache.log4j.DailyRollingFileAppender',
    date_pattern: '.yyyy-MM-dd',
    file: lazy { ::File.join(node['kafka']['log_dir'], 'kafka-request.log') },
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
  'controllerAppender' => {
    type: 'org.apache.log4j.DailyRollingFileAppender',
    date_pattern: '.yyyy-MM-dd',
    file: lazy { ::File.join(node['kafka']['log_dir'], 'kafka-controller.log') },
    layout: {
      type: 'org.apache.log4j.PatternLayout',
      conversion_pattern: '[%d] %p %m (%c)%n',
    },
  },
}

#
# Logger definitions.
default['kafka']['log4j']['loggers'] = {
  'org.IOItec.zkclient.ZkClient' => {
    level: 'INFO',
  },
  'kafka.network.RequestChannel$' => {
    level: 'WARN',
    appender: 'requestAppender',
    additivity: false,
  },
  'kafka.request.logger' => {
    level: 'WARN',
    appender: 'requestAppender',
    additivity: false,
  },
  'kafka.controller' => {
    level: 'INFO',
    appender: 'controllerAppender',
    additivity: false,
  },
  'state.change.logger' => {
    level: 'INFO',
    appender: 'stateChangeAppender',
    additivity: false,
  },
}
