mkdir /etc/salt/cloud.providers.d/
mkdir /etc/salt/cloud.profiles.d/

HTTP_GROUP=`ec2-describe-group --filter="tag:Name=sgAllowHTTPAnywhere" | egrep ^GROUP | awk '{ print $2 }'`
SSH_GROUP=`ec2-describe-group --filter="tag:Name=sgAllowSSH" | egrep ^GROUP | awk '{ print $2 }'`
RTMP_GROUP=`ec2-describe-group --filter="tag:Name=sgAllowRTMPAnywhere" | egrep ^GROUP | awk '{ print $2 }'`
HTTP_ALT_GROUP=`ec2-describe-group --filter="tag:Name=sgAllowHTTPAltAnywhere" | egrep ^GROUP | awk '{ print $2 }'`
DEFAULT_SUBNET=`aws ec2 describe-subnets --region=us-east-1 --filters Name=defaultForAz,Values=true Name=availabilityZone,Values=us-east-1a |  python -c 'import json,sys;obj=json.load(sys.stdin);print obj["Subnets"][0]["SubnetId"]'`

QUERY_STRING="http_alt_group=$HTTP_ALT_GROUP&http_group=$HTTP_GROUP&ssh_group=$SSH_GROUP&rtmp_group=$RTMP_GROUP&default_subnet=$DEFAULT_SUBNET"


pushd /opt/stack/templates/salt-cloud/cloud.profiles.d/
echo "$QUERY_STRING" | /usr/local/bin/jinja2 --format=querystring debian_ec2_public.conf.tmpl > /etc/salt/cloud.profiles.d/debian_ec2_public.conf
popd


SALT_MASTER_IP=`ifconfig | awk '/inet addr/{print substr($2,6)}' | head -n 1`
KEYPAIR_NAME="$1"
EC2_ID="$2"
EC2_KEY="$3"

QUERY_STRING2="salt_master=$SALT_MASTER_IP&keypair_name=$KEYPAIR_NAME&EC2_ID=$EC2_ID&EC2_KEY=$EC2_KEY"
pushd /opt/stack/templates/salt-cloud/cloud.providers.d/
echo "$QUERY_STRING2" | /usr/local/bin/jinja2 --format=querystring ec2-public.conf.tmpl > /etc/salt/cloud.providers.d/ec2-public.conf
popd