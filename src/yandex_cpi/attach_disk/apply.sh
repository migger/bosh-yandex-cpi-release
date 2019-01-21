VM_ID=$(jq -r '.arguments[0]' .work/request.json)
DISK_ID=$(jq -r '.arguments[1]' .work/request.json)

PER_DISK_DEVICE_NAME=vol-$(head /dev/urandom | tr -dc a-z0-9 | head -c 16)

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance stop \
   $VM_ID 

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance attach-disk \
   $VM_ID \
   --disk-name $DISK_ID \
   --device-name ${PER_DISK_DEVICE_NAME} \
   1>&2

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance start \
   $VM_ID 
CODE=

while [ "$CODE" != "200" ]; do
    sleep 1
    CODE=$(curl -o /dev/null -w %{http_code} -k $YC_MBUS -X POST --data {\"method\":\"ping\"})
done

TASK_ID=$(curl -k $YC_MBUS -X POST \
	--data '{"method":"add_persistent_disk","arguments":["'${PER_DISK_DEVICE_NAME}'",{"id":"'${PER_DISK_DEVICE_NAME}'"}]}' | jq -r .value.agent_task_id)
  
echo '{}'
