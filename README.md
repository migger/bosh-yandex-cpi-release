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
## Создать сервисный аккаунт
```
yc iam service-account create --name cpi-robot
```
в выводе ищем
```
id: <<accountId>>
```
и выдаем на него права
```
yc resource-manager folder add-access-binding --name cloud-foundry --role editor --subject serviceAccount:<<accountId>>
```

## Создать машину jumpbox на базе ubuntu
```
yc compute instance create \
           --name jumpbox \
           --description "JumpBox host for infrastructure access" \
           --zone ru-central1-a \
           --ssh-key ~/.ssh/id_rsa.pub \
           --network-interface subnet-name=infra,nat-ip-version=ipv4,address=10.0.0.5 \
           --memory 2 \
           --cores 1 \
           --create-boot-disk image-folder-id=standard-images,image-name=ubuntu-1804-1549468804,size=6
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
sudo apt -y install git ruby
```

## Клонируем репозиторий
```
git clone git@github.com:migger/bosh-yandex-cpi-release.git
```

## Устанавливаем bosh cli
https://bosh.io/docs/cli-v2-install/

## Заходим в папку проекта
```
cd bosh-yandex-cpi-release
```
## Скачиваем блобы
```
bosh sync-blobs
```

## Создаем дев релиз
```
bosh create-release --tarball=~/tmp/bosh-yandex-cpi-release-dev.tgz
```
## Копируем нужные скрипты в свою папку
```
cp -v opfiles/*director* ../
```
## Вводим в скрипте наши данные
```
cd ..
vi director.sh
```

## Скачиваем bosh-deployment

```
git clone https://github.com/cloudfoundry/bosh-deployment.git
```

## Устанавливаем
```
sh -x director.sh
```
