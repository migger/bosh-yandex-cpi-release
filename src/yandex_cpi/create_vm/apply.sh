VM_ID=vm-$(uuidgen | tr '[:upper:]' '[:lower:]')
AGENT_NAME=$(jq -r '.arguments[0]' /tmp/.work/request.json)
STEMCELL_ID=$(jq -r '.arguments[1]' /tmp/.work/request.json)
CLOUD_PROPERTIES=$(jq -r '.arguments[2]' /tmp/.work/request.json)
NETWORKS=$(jq -r '.arguments[3]' /tmp/.work/request.json)
DISKS=$(jq -r '.arguments[4]' /tmp/.work/request.json)
ENVIRONMENT=$(jq -r '.arguments[5]' /tmp/.work/request.json)

IP=$(echo $NETWORKS | jq -r .default.ip)

echo $CLOUD_PROPERTIES | grep zone > /dev/null
if [ "$?" -ne "0" ]; then
	ZONE=$YC_ZONE
else
	ZONE=$(echo $CLOUD_PROPERTIES | jq -r .zone )
fi
echo $CLOUD_PROPERTIES | grep cpu > /dev/null
if [ "$?" -ne "0" ]; then
        CPU=1
else
	CPU=$(echo $CLOUD_PROPERTIES | jq -r .cpu )
fi

echo $CLOUD_PROPERTIES | grep disk > /dev/null
if [ "$?" -ne "0" ]; then
        DISK=12288
else
	DISK=$(echo $CLOUD_PROPERTIES | jq -r .disk )
fi

echo $CLOUD_PROPERTIES | grep ram > /dev/null
if [ "$?" -ne "0" ]; then
        RAM=2048
else
	RAM=$(echo $CLOUD_PROPERTIES | jq -r .ram )
fi

DISK_GB=$(($DISK/1024))
RAM_GB=$(($RAM/1024))

SYS_DISK_DEVICE_NAME=vol-$(head /dev/urandom | tr -dc a-z0-9 | head -c 16)

echo '{' > /tmp/.work/user-data.json
echo '	"agent_id": "'$AGENT_NAME'",' >> /tmp/.work/user-data.json
echo '	"disks": {' >> /tmp/.work/user-data.json
echo '		"system": "/dev/disk/by-id/'$SYS_DISK_DEVICE_NAME'-part1"' >> /tmp/.work/user-data.json
echo '	},' >> /tmp/.work/user-data.json
echo '	"env": ' >> /tmp/.work/user-data.json
jq -r '.arguments[5]' /tmp/.work/request.json >> /tmp/.work/user-data.json
echo '	,' >> /tmp/.work/user-data.json
echo '	"networks": ' >> /tmp/.work/user-data.json
echo '	   '$NETWORKS >> /tmp/.work/user-data.json
echo '	,' >> /tmp/.work/user-data.json
echo '	"vm": {' >> /tmp/.work/user-data.json
echo '		"name": "'$VM_ID'"' >> /tmp/.work/user-data.json
echo '	}' >> /tmp/.work/user-data.json
echo '}' >> /tmp/.work/user-data.json


jq -s '.[0].cloud.properties.agent * .[1]' $YC_ENV_JSON /tmp/.work/user-data.json > /tmp/.work/user-data-merged.json

cat /tmp/.work/user-data-merged.json 1>&2

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance create \
   --zone $ZONE \
   --name $VM_ID \
   --create-boot-disk name=${VM_ID}-system,device-name=${SYS_DISK_DEVICE_NAME},image-name=${STEMCELL_ID},size=$DISK_GB \
   --memory $RAM_GB \
   --cores $CPU \
   --core-fraction 5 \
   --hostname $VM_ID \
   --metadata-from-file user-data=/tmp/.work/user-data-merged.json \
   --network-interface subnet-name=${YC_SUBNETWORK},address=${IP},nat-ip-version=ipv4\
   1>&2

if [ $? -ne 0 ]; then
	exit 1
fi

echo '{"result":"'$VM_ID'", "error": null, "log": ""}'
