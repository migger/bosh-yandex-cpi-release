DISK_ID=$(jq -r '.arguments[0]' $WORKDIR/request.json)
METADATA_KV=$(jq -r '.arguments[1]' $WORKDIR/request.json | jq -r '. as $in | keys[] | "\(. | gsub("[^0-9a-z_-]"; "_") | .[0:63])=\($in[.] | gsub("[^0-9a-z_-]"; "_") | .[0:63])" ' | tr '\n' ',' | sed 's/,$//' | tr [A-Z] [a-z] | tr : _)

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute disk update \
   $DISK_ID \
   --labels $METADATA_KV \
   1>&2

if [ $? -ne 0 ]; then
       	exit 1
fi

echo '{"result": null, "error": null, "log": ""}'
