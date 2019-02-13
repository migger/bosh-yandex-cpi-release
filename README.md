# Начало работы
## Установить yandex cloud cli
https://cloud.yandex.ru/docs/cli/quickstart

## Доабвить в путь
```
export PATH=$PATH:$HOME/yandex-cloud/bin/
```
Проверить
```
~> yc version
Yandex.Cloud CLI 0.13.3 darwin/amd64
```
## Инициализировать клиента 
Следовать диалогу, **новую папку**. Зону можно не создавать
```
yc init
```

Токен можно получить по адресу
https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb

## Создаем сеть в которой будем работать
### Приватная сеть(которая объеденят сети между зонами доступности)
```
yc vpc network create \
            --name default \
            --description "Default network for cloud foundry"
```
 *Если сеть уже создана - можно использовать ее*

### Подсеть(диапазон адресов, который действует только в рамках зоны досупности)
```
yc vpc subnet create \
            --name infra \
            --description "Network for bosh and other dev tools" \
            --zone ru-central1-a \
            --network-name default \
            --range 10.0.0.0/24
```


## Создать машину jumpbox на базе ubuntu
```
yc compute instance create \
           --name jumpbox \
           --description "JumpBox host for infrastructure access" \
           --zone ru-central1-a \
           --ssh-key ~/.ssh/id_rsa.pub \
           --network-interface subnet-name=infra,nat-ip-version=ipv4,address=10.0.0.5 \
           --create-boot-disk image-folder-id=standard-images,image-name=ubuntu-1804-1549468804
```
В выводе ищем
```
    one_to_one_nat:
      address: 84.201.130.87
```

## Заходим на машину

```
ssh yc-user@84.201.130.87
```

## Создаем папку с bosh
```
mkdir bosh
```

## Устанавливаем необходимые программы и библиотеки

```
sudo apt update
sudo apt -y install git
```

## Клонируем репозиторий
```
git clone git@github.com:migger/bosh-yandex-cpi-release.git
```

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
