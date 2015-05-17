#!/bin/bash

bash /opt/stack/scripts/update-profile.sh "$1" "$2"

salt-cloud -P -m /opt/stack/templates/salt-cloud/map -y
salt '*' state.highstate -t 90
