DISK_ID=$(jq -r '.arguments[0]' .work/request.json)

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute disk delete \
   $DISK_ID \
   1>&2

echo {}

