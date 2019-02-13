# Начало работы
## Установить yandex cloud cli
```https://cloud.yandex.ru/docs/cli/quickstart```

# Что бы все заработало

1. Создать jumpbox штатными средствами Яндекс Облака (У меня это Ubuntu 18)
2. Склонировать проект
3. Из директори проекта выполнить
```
bosh create-release --tarball=/opt/tmp/bosh-yandex-cpi-release-dev.tgz
```
4. Что бы раскатить
```
bosh create-env bosh-deployment/bosh.yml \
                                          --state=xxx-state.json \
                                          --vars-store=xxx-creds.yml \
                                          -o bosh-yandex-cpi-release/opfiles/yandex.opfile.yml \
                                          -v director_name=bosh-1 \
                                          -v internal_ip=10.0.0.6 \
                                          -v internal_cidr=10.0.0.0/24 \
                                          -v internal_gw=10.0.0.1 
```

В процессе установки надо будет поставить необходимые зависимотри типа руби и еще чего то...
