#!/bin/bash

bash /opt/stack/scripts/bootstrap/update-profile.sh "$1" "$2" "$3"

salt-cloud -P -m /opt/stack/templates/salt-cloud/map -y
sleep 30
salt '*' state.highstate -t 90
