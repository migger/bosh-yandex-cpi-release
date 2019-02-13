JSON=$(yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   iam access-key create --service-account-name $YC_ROBOT_ACCOUNT) 

if [ $? -ne 0 ]; then
	exit 1
fi

ID=$(echo $JSON | jq -r .access_key.id)
KEY_ID=$(echo $JSON | jq -r .access_key.key_id)
SECRET=$(echo $JSON | jq -r .secret)

echo [default] > /tmp/.work/.s3cfg
echo access_key = $KEY_ID >> /tmp/.work/.s3cfg
echo secret_key = $SECRET >> /tmp/.work/.s3cfg 
echo bucket_location = us-east-1 >> /tmp/.work/.s3cfg
echo host_base = storage.yandexcloud.net >> /tmp/.work/.s3cfg
echo 'host_bucket = %(bucket)s.storage.yandexcloud.net' >> /tmp/.work/.s3cfg
EX=`pwd`
cd /tmp/.work
cat ./image | tar -xz 1>&2
ls -l 1>&2
mv -v root.img $1 1>&2

s3cmd --config .s3cfg put $1 s3://$YC_BUCKET_NAME/stemcells/$1 1>&2

if [ $? -ne 0 ]; then
        s3cmd --config .s3cfg mb s3://$YC_BUCKET_NAME 1>&2
	if [ $? -ne 0 ]; then
        	exit 1
	fi
	s3cmd --config .s3cfg put $1 s3://$YC_BUCKET_NAME/stemcells/$1 1>&2
	if [ $? -ne 0 ]; then
        	exit 1
	fi
fi

IMAGE_URL=$(s3cmd --config .s3cfg signurl s3://$YC_BUCKET_NAME/stemcells/$1 +100000 | sed 's/\([^\/]*\)[.]\(storage[.]yandexcloud[.]net\)/\2\/\1/')

if [ $? -ne 0 ]; then
        exit 1
fi

cd $EX

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   compute image create --name $1 --source-uri $IMAGE_URL 1>&2

if [ $? -ne 0 ]; then
        exit 1
fi

yc --token $YC_PASSPORT_TOKEN \
   --cloud-id $YC_CLOUD_ID \
   --folder-name $YC_FOLDER_NAME \
   --format json \
   iam access-key delete --id $ID 1>&2

if [ $? -ne 0 ]; then
        exit 1
fi
