cat .work/request.json

VM_ID=vm-$(uuidgen | tr '[:upper:]' '[:lower:]')
AGENT_NAME=$(jq -r '.arguments[0]' .work/request.json)
STEMCELL_ID=$(jq -r '.arguments[1]' .work/request.json)
CLOUD_PROPERTIES=$(jq -r '.arguments[2]' .work/request.json)
NETWORKS=$(jq -r '.arguments[3]' .work/request.json)
DISKS=$(jq -r '.arguments[4]' .work/request.json)
ENVIRONMENT=$(jq -r '.arguments[5]' .work/request.json)

IP=$(echo $NETWORKS | jq -r .default.ip)

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance create \
   --zone $YC_ZONE \
   --name $VM_ID \
   --create-boot-disk name=disk1,image-name=${STEMCELL_ID} \
   --memory 1 \
   --cores 1 \
   --core-fraction 5 \
   --hostname $VM_ID \
   --network-interface subnet-name=${YC_SUBNETWORK},address=${IP}\
   1>&2

echo '{"result":"'$VM_ID'"}'
