VM_ID=$(jq -r '.arguments[0]' $WORKDIR/request.json)
DISK_ID=$(jq -r '.arguments[1]' $WORKDIR/request.json)

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance stop \
   $VM_ID \
   1>&2

if [ $? -ne 0 ]; then
       	exit 1
fi

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance detach-disk \
   $VM_ID \
   --disk-name $DISK_ID \
   1>&2

if [ $? -ne 0 ]; then
       	exit 1
fi

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance get \
   --full $VM_ID > $WORKDIR/vm_info.json

if [ $? -ne 0 ]; then
       	exit 1
fi

IP=$(cat $WORKDIR/vm_info.json | jq -r '.network_interfaces[0].primary_v4_address.address')
cat $WORKDIR/vm_info.json  | jq -r '.metadata."user-data"' > $WORKDIR/old_metadata.json

cat $WORKDIR/old_metadata.json 1>&2

cat $WORKDIR/old_metadata.json \
	| jq 'del(.disks.persistent."'$DISK_ID'")' \
	> $WORKDIR/new_metadata.json

cat $WORKDIR/new_metadata.json 1>&2

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance update \
   $VM_ID \
   --metadata-from-file user-data=$WORKDIR/new_metadata.json \
   1>&2

if [ $? -ne 0 ]; then
       	exit 1
fi

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance start \
   $VM_ID \
   1>&2

if [ $? -ne 0 ]; then
       	exit 1
fi

nc -w 1 -z $IP 22

while [ "$?" -ne "0" ]; do
    nc -w 1 -z $IP 22
done
  
echo '{"result": null, "error": null, "log": ""}'
