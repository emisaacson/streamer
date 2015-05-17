HTTP_GROUP=`ec2-describe-group --filter="tag:Name=sgAllowHTTPAnywhere" | egrep ^GROUP | awk '{ print $2 }'`
SSH_GROUP=`ec2-describe-group --filter="tag:Name=sgAllowSSH" | egrep ^GROUP | awk '{ print $2 }'`
RTMP_GROUP=`ec2-describe-group --filter="tag:Name=sgAllowRTMPAnywhere" | egrep ^GROUP | awk '{ print $2 }'`
HTTP_ALT_GROUP=`ec2-describe-group --filter="tag:Name=sgAllowHTTPAltAnywhere" | egrep ^GROUP | awk '{ print $2 }'`

QUERY_STRING="http_alt_group=$HTTP_ALT_GROUP&http_group=$HTTP_GROUP&ssh_group=$SSH_GROUP&rtmp_group=$RTMP_GROUP"

pushd /opt/stack/templates/salt-cloud/cloud.profiles.d/
echo "$QUERY_STRING" | /usr/local/bin/jinja2 --format=querystring debian_ec2_public.conf.tmpl > /etc/salt/cloud.profiles.d/debian_ec2_public.conf
popd


SALT_MASTER_IP=`ifconfig | awk '/inet addr/{print substr($2,6)}' | head -n 1`
KEYPAIR_NAME="$1"
EC2_ID="$2"

QUERY_STRING2="salt_master=$SALT_MASTER_IP&keypair_name=$KEYPAIR_NAME&EC2_ID=$EC2_ID"
pushd /opt/stack/templates/salt-cloud/cloud.providers.d/
echo "$QUERY_STRING" | /usr/local/bin/jinja2 --format=querystring ec2-public.conf.tmpl > /etc/salt/cloud.profiles.d/ec2-public.conf
popd