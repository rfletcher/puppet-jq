# == Class: jq
#
# Installs (or removes) the jq utility
#
# === Parameters
#
# [*ensure*]
#   present, absent
#
# [*latest*]
#   The latest version of jq available at $source.
#
# [*source*]
#   The URL of the jq binary
#
# === Examples
#
#  include jq
#
# === Authors
#
# Rick Fletcher <fletch@pobox.com>
#
# === Copyright
#
# Copyright 2015 Rick Fletcher
#
class jq (
  $ensure = present,
  $latest = '1.4',
  $source = undef,
) {
  $version = $ensure ? {
    present => $latest,
    absent  => $latest,
    latest  => $latest,
    default => $ensure,
  }

  if versioncmp("$version", '1.4') > 0 {
    $url = "https://github.com/stedolan/jq/releases/download/jq-${version}/jq-linux64"
  }else{
    $url = "https://github.com/stedolan/jq/releases/download/jq-${version}/jq-linux-x86_64"
  }

  $binary_path = "/usr/local/bin/jq-${version}"

  if $ensure != 'absent' {
    $real_source = $source ? { undef => $url, default => $source }

    wget::fetch { $real_source:
      source      => $real_source,
      destination => $binary_path,
      timeout     => 0,
      verbose     => false,
      before      => File[$binary_path],
    }
  }

  file { $binary_path:
    ensure => $ensure ? { absent => $ensure, default => present },
    mode   => '0755',
  } ->

  file { '/usr/local/bin/jq':
    ensure => $ensure ? { absent => $ensure, default => link },
    target => $binary_path,
  }
}
