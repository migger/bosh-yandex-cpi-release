VM_ID=$(jq -r '.arguments[0]' $WORKDIR/request.json)


yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute instance get \
   --name ${VM_ID} \
   1>&2

if [ $? -eq 0 ]; then 
  echo '{"result":true, "error": null, "log": ""}'
else
  echo '{"result":false, "error": null, "log": ""}'
fi
