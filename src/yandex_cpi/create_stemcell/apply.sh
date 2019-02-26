STEMCELL_ID=stemcell-$(uuidgen | tr '[:upper:]' '[:lower:]')
IMAGE=$(jq -r '.arguments[0]' $WORKDIR/request.json)
cp -v $IMAGE $WORKDIR/image  1>&2
sh -x $(dirname $0)/upload.sh $STEMCELL_ID 1>&2

if [ $? -ne 0 ]; then
       	exit 1
fi

echo '{"result":"'$STEMCELL_ID'", "error": null, "log": ""}'
