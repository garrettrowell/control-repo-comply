#
# @summary Profile for enforcing compliance based on configured releases.
#
# @param configured_releases
#   An array of configured releases for compliance enforcement.
# @param enforce
#   Whether to enforce compliance or not.
#
class profile::compliance (
  Array[String[1]] $configured_releases,
  Boolean          $enforce = true,
) {
  # local helper variables
  $kern = $facts['kernel'].downcase
  $detected_release = "${facts['os']['name']} ${facts['os']['release']['major']}"

  if $enforce {
    case $kern {
      'linux', 'windows': {
        if $detected_release in $configured_releases {
          include "sce_${kern}"
        } else {
          $msg = @("MSGEND"/L)

            Compliance enforcement is enabled, but the detected release
            '${detected_release}' is not in the list of configured releases:
            ${configured_releases}.
            Blindly enforcing the default compliance profile will almost certainly break the system.
            Please configure the appropriate compliance profile for this release.
            | MSGEND

          echo { 'compliance_unconfigured':
            message => $msg,
          }
        }
      }
      default: {
        echo { 'compliance_unsupported':
          message => "Compliance enforcement is not supported on ${kern}.",
        }
      }
    }
  } else {
    echo { 'compliance_disabled':
      message => 'Compliance enforcement is disabled.',
    }
  }
}
