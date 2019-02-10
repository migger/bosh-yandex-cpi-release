STEMCELL_ID=stemcell-$(uuidgen | tr '[:upper:]' '[:lower:]')
IMAGE=$(jq -r '.arguments[0]' /tmp/.work/request.json)
cp -v $IMAGE /tmp/.work/image  1>&2
sh -x $(dirname $0)/upload.sh $STEMCELL_ID 1>&2
echo '{"result":"'$STEMCELL_ID'", "error": null, "log": ""}'
