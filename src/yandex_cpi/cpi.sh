#!/bin/sh
export PATH=$PATH:/Users/i.mihailyuk/Downloads/s3cmd-2.0.2

export PATH=$PATH:$BOSH_PACKAGES_DIR/yandex-cloud-cli/bin:$BOSH_PACKAGES_DIR/jq/bin
export BASEDIR=$(dirname $0)

export YC_PASSPORT_TOKEN=$1
shift
export YC_CLOUD_NAME=$1
shift
export YC_FOLDER_NAME=$1
shift
export YC_BUCKET_NAME=$1
shift
export YC_ROBOT_ACCOUNT=$1
shift
export YC_ZONE=$1
shift
export YC_NETWORK=$1
shift
export YC_SUBNETWORK=$1
shift

mkdir -p .work
export HOME=$(pwd)/.work

cat > .work/request.json

METHOD=$(jq -r .method .work/request.json)
if [ ! -e $BASEDIR/$METHOD/apply.sh ]; then
	echo '{"error":{"type": "Bosh::Clouds::CloudError","message": "method `'$METHOD'` not suported","ok_to_retry":false}}'
else
    export YC_CLOUD_ID=$(yc --token $YC_PASSPORT_TOKEN --format json resource-manager cloud get --name $YC_CLOUD_NAME | jq -r '.id')
	sh -x $BASEDIR/$METHOD/apply.sh
fi

#export YC_FOLDER_ID=$(yc --token $YC_PASSPORT_TOKEN --format json resource-manager --cloud-id $YC_CLOUD_ID folder get --name $YC_FOLDER_NAME | jq -r '.id')

rm -rf .work
