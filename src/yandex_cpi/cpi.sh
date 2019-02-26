#!/bin/sh
export BOSH_PACKAGES_DIR=$pkgs_dir

export PATH=$PATH:$BOSH_PACKAGES_DIR/yandex-cloud-cli/bin:$BOSH_PACKAGES_DIR/jq/bin:$BOSH_PACKAGES_DIR/s3cmd/bin:$BOSH_PACKAGES_DIR/uuidgen/bin
export BASEDIR=$(dirname $0)

export YC_ENV_JSON=$1
shift
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

export WORKDIR=/tmp/.work_$(head /dev/urandom | tr -dc a-z0-9 | head -c 16)

mkdir -p $WORKDIR
export HOME=$WORKDIR

cat > $WORKDIR/request.json

METHOD=$(jq -r .method $WORKDIR/request.json)
if [ ! -e $BASEDIR/$METHOD/apply.sh ]; then
	echo '{"error":{"type": "Bosh::Clouds::CloudError","message": "method `'$METHOD'` not suported","ok_to_retry":false}}'
else
    export YC_CLOUD_ID=$(yc --token $YC_PASSPORT_TOKEN --format json resource-manager cloud get --name $YC_CLOUD_NAME | jq -r '.id')
	sh -x $BASEDIR/$METHOD/apply.sh
fi

rm -rf $WORKDIR
