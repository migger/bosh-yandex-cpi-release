VM_ID=$(jq -r '.arguments[0]' /tmp/.work/request.json)
DISK_ID=$(jq -r '.arguments[1]' /tmp/.work/request.json)

GEN_ID=asdasd

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance stop \
   $VM_ID \
   1>&2

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance attach-disk \
   $VM_ID \
   --disk-name $DISK_ID \
   --device-name ${GEN_ID} \
   1>&2

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance get \
   --full $VM_ID > /tmp/.work/vm_info.json

IP=$(cat /tmp/.work/vm_info.json | jq -r '.network_interfaces[0].primary_v4_address.address')
cat /tmp/.work/vm_info.json  | jq -r '.metadata."user-data"' > /tmp/.work/old_metadata.json

cat /tmp/.work/old_metadata.json 1>&2

cat /tmp/.work/old_metadata.json \
	| jq '.disks.persistent."'$DISK_ID'".id="'virtio-$GEN_ID'"' \
	| jq '.disks.persistent."'$DISK_ID'".path="'/dev/disk/by-id/virtio-$GEN_ID'"' \
	> /tmp/.work/new_metadata.json

cat /tmp/.work/new_metadata.json 1>&2

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance update \
   $VM_ID \
   --metadata-from-file user-data=/tmp/.work/new_metadata.json \
   1>&2

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance start \
   $VM_ID \
   1>&2

CODE=000

while [ "$CODE" -eq "000" ]; do
    sleep 1
    CODE=$(curl -o /dev/null -w %{http_code} -k https://$IP:6868/agent -X POST --data {\"method\":\"ping\"})
done

  
echo '{"result": null, "error": null, "log": ""}'
