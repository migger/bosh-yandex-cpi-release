STEMCELL_ID=$(jq -r '.arguments[0]' $WORKDIR/request.json)
sh -x $(dirname $0)/delete.sh $STEMCELL_ID 1>&2

echo '{"result": null, "error": null, "log": ""}'
