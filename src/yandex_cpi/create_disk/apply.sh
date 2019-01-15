DISK_SIZE=$(jq -r '.arguments[0]' .work/request.json)
CLOUD_PROPERTIES=$(jq -r '.arguments[1]' .work/request.json)
VM_ID=$(jq -r '.arguments[2]' .work/request.json)
DISK_ID=${VM_ID}-$(head /dev/urandom | tr -dc a-z0-9 | head -c 16)

DISK_SIZE_GB=$(($DISK_SIZE / 1024))
yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute disk create \
   --name $DISK_ID \
   --size $DISK_SIZE_GB \
   1>&2
if [ "$?" != "0" ]; then
	echo "ERROR"
	exit 1
fi

echo '{"result":"'$DISK_ID'"}'

