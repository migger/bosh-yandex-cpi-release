STEMCELL_ID=$(jq -r '.arguments[0]' /tmp/.work/request.json)
sh -x $(dirname $0)/delete.sh $STEMCELL_ID 1>&2

if [ $? -ne 0 ]; then
       	exit 1
fi

echo '{"result": null, "error": null, "log": ""}'
