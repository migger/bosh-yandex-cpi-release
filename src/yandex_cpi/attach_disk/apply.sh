VM_ID=$(jq -r '.arguments[0]' .work/request.json)
DISK_ID=$(jq -r '.arguments[1]' .work/request.json)

PER_DISK_DEVICE_NAME=vol-$(head /dev/urandom | tr -dc a-z0-9 | head -c 16)

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance attach-disk \
   $VM_ID \
   --disk-name $DISK_ID \
   --device-name ${PER_DISK_DEVICE_NAME} \
   1>&2

curl -k https://mbus:qx6og3qijbn4e8nbilbq@10.0.0.6:6868/agent -X POST \
 --data '{"method": "add_persistent_disk", "payload":{"arguments":["'${PER_DISK_DEVICE_NAME}'", {"id": "'${PER_DISK_DEVICE_NAME}'"}]}}' 1>&2

echo '{}'
