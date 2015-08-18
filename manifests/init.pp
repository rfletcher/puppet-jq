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
# [*path*]
#   The location where jq should be installed
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
  $path   = '/usr/bin'
) {
  $version = $ensure ? {
    present => $latest,
    absent  => $latest,
    latest  => $latest,
    default => $ensure,
  }

  if $ensure == present or $ensure == $latest {
    $url = 'http://stedolan.github.io/jq/download/linux64/jq'
  } else {
    $url = "http://stedolan.github.io/jq/download/linux64/jq-${version}/jq"
  }

  $binary_path = "${path}/jq-${version}"

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

  $present_ensure = $ensure ? {
    absent  => $ensure,
    default => present
  }

  file { $binary_path:
    ensure => $ensure,
    mode   => '0755',
  }

  $path_ensure = $ensure ? {
    absent  => $ensure,
    default => link
  }

  file { "${path}/jq":
    ensure  => $path_ensure,
    target  => $binary_path,
    require => File[$binary_path],
  }
}
