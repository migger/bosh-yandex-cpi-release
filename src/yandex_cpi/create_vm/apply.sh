VM_ID=vm-$(uuidgen | tr '[:upper:]' '[:lower:]')
AGENT_NAME=$(jq -r '.arguments[0]' .work/request.json)
STEMCELL_ID=$(jq -r '.arguments[1]' .work/request.json)
CLOUD_PROPERTIES=$(jq -r '.arguments[2]' .work/request.json)
NETWORKS=$(jq -r '.arguments[3]' .work/request.json)
DISKS=$(jq -r '.arguments[4]' .work/request.json)
ENVIRONMENT=$(jq -r '.arguments[5]' .work/request.json)

IP=$(echo $NETWORKS | jq -r .default.ip)

SYS_DISK_DEVICE_NAME=vol-$(head /dev/urandom | tr -dc a-z0-9 | head -c 16)

echo '{' > .work/user-data.json
echo '	"agent_id": "'$AGENT_NAME'",' >> .work/user-data.json
echo '	"disks": {' >> .work/user-data.json
echo '		"system": "/dev/disk/by-id/'$SYS_DISK_DEVICE_NAME'-part1"' >> .work/user-data.json
echo '	},' >> .work/user-data.json
echo '	"env": ' >> .work/user-data.json
jq -r '.arguments[5]' .work/request.json >> .work/user-data.json
echo '	,' >> .work/user-data.json
echo '	"networks": ' >> .work/user-data.json
echo '	   '$NETWORKS >> .work/user-data.json
echo '	,' >> .work/user-data.json
echo '	"vm": {' >> .work/user-data.json
echo '		"name": "'$VM_ID'"' >> .work/user-data.json
echo '	}' >> .work/user-data.json
echo '}' >> .work/user-data.json


jq -s '.[0].cloud.properties.agent * .[1]' $YC_ENV_JSON .work/user-data.json > .work/user-data-merged.json

cat .work/user-data-merged.json 1>&2

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance create \
   --zone $YC_ZONE \
   --name $VM_ID \
   --create-boot-disk name=system,device-name=${SYS_DISK_DEVICE_NAME},image-name=${STEMCELL_ID},size=6 \
   --memory 4 \
   --cores 4 \
   --core-fraction 50 \
   --hostname $VM_ID \
   --metadata-from-file user-data=.work/user-data-merged.json \
   --network-interface subnet-name=${YC_SUBNETWORK},address=${IP},nat-ip-version=ipv4\
   1>&2

if [ $? -ne 0 ]; then
	exit 1
fi

echo '{"result":"'$VM_ID'"}'
