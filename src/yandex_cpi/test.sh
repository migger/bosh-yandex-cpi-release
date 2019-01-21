export YC_PASSPORT_TOKEN='AQAAAAAByO4AAATuwSSVTMTTa0Bhpymd34oRwdg'
export YC_CLOUD_NAME='cloud-b1glho6pdsm66b'
export YC_FOLDER_NAME='cpi-test'

export PATH=$PATH:~/yandex-cloud/bin:/Users/i.mihailyuk/Downloads/s3cmd-2.0.2
export YC_ZONE=ru-central1-a
export YC_NETWORK=default
export YC_SUBNETWORK=infra

cat ./$1/test.json | sh -x cpi.sh '' $YC_PASSPORT_TOKEN $YC_CLOUD_NAME $YC_FOLDER_NAME 'cloud-foundry' 'cpi-robot' $YC_ZONE $YC_NETWORK $YC_SUBNETWORK

