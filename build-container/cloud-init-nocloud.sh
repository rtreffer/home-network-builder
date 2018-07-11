#!/bin/bash

node="${1}"
file="${2}"

cat << _DATASOURCE_
disable_ec2_metadata: True
datasource_list: [ "NoCloud", "None" ]
datasource:
  NoCloud:
    fs_label: None
    user-data: !!binary |
$(base64 "${file}" | sed 's:^:      :')
    meta-data:
      instance-id: "${node}"
      local-hostname: "${node}.local"
  None:
    userdata_raw: !!binary |
$(base64 "${file}" | sed 's:^:      :')
    metadata:
      instance-id: "${node}"
      local-hostname: "${node}.local"
_DATASOURCE_
