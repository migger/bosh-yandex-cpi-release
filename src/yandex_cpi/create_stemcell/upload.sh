JSON=$(yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   iam access-key create --service-account-name $YC_ROBOT_ACCOUNT) 

ID=$(echo $JSON | jq -r .access_key.id)
KEY_ID=$(echo $JSON | jq -r .access_key.key_id)
SECRET=$(echo $JSON | jq -r .secret)

echo [default] > .work/.s3cfg
echo access_key = $KEY_ID >> .work/.s3cfg
echo secret_key = $SECRET >> .work/.s3cfg 
echo bucket_location = us-east-1 >> .work/.s3cfg
echo host_base = storage.yandexcloud.net >> .work/.s3cfg
echo 'host_bucket = %(bucket)s.storage.yandexcloud.net' >> .work/.s3cfg

cd .work
cat ./image | tar -x 1>&2
ls -l 1>&2
mv -v root.vhd $1 1>&2

s3cmd --config .s3cfg put $1 s3://$YC_BUCKET_NAME/stemcells/$1 1>&2

IMAGE_URL=$(s3cmd --config .s3cfg signurl s3://$YC_BUCKET_NAME/stemcells/$1 +100000)


cd ..

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute image create --name $1 --source-uri $IMAGE_URL 1>&2

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   iam access-key delete --id $ID 1>&2

