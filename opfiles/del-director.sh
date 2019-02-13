bosh delete-env bosh-deployment/bosh.yml \
                                          --state=xxx-state.json \
                                          --vars-store=xxx-creds.yml \
                                          -o yandex.opfile.yml \
                                          -v director_name=bosh-1 \
                                          -v internal_ip=10.0.0.6 \
                                          -v internal_cidr=10.0.0.0/24 \
                                          -v internal_gw=10.0.0.1 \
