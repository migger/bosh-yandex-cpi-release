VM_ID=$(jq -r '.arguments[0]' .work/request.json)
DISK_ID=$(jq -r '.arguments[1]' .work/request.json)

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
   --full $VM_ID \
   | jq -r '.metadata."user-data"' > .work/old_metadata.json

cat .work/old_metadata.json 1>&2

cat .work/old_metadata.json | jq '.disks.persistent."'$GEN_ID'".id="'virtio-$GEN_ID'"' > .work/new_metadata.json

cat .work/new_metadata.json 1>&2

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance update \
   $VM_ID \
   --metadata-from-file user-data=.work/new_metadata.json \
   1>&2

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance start \
   $VM_ID \
   1>&2

CODE=

while [ "$CODE" != "200" ]; do
    sleep 1
    CODE=$(curl -o /dev/null -w %{http_code} -k $YC_MBUS/agent -X POST --data {\"method\":\"ping\"})
done

  
echo '{}'
