# Задача:
Создать виртуальную машину в Yandex.Cloud при помощи Terraform
Цель:

В результате у вас должен быть готова конфигурация terraform и созданная при помощи неё виртуальная машина в Yandex.Cloud

Описание/Пошаговая инструкция выполнения домашнего задания:

    Создать проект в Yandex.Cloud
    Применить промокод (если нет промокода, напишите в Slack в чат курса)
    Создать конфигурацию terraform
    Применить её
    Убедиться, что результат соответствует ожиданиям
    Загрузить код на github или любой другой репозиторий
    Скинуть ссылку на код

# Настройка:
Пошагово описана в 
https://practicum.yandex.ru/trainer/ycloud/lesson/e027d622-2926-4a4c-8231-3b6b44577c9b/
но я продублирую здесь необходимые шаги:
## Установка yc
https://cloud.yandex.ru/docs/cli/quickstart
## Сгенерировать ssh ключ:
 (опционально - если ещё не сделано)

 ssh-keygen -t rsa -b 2048

https://practicum.yandex.ru/trainer/ycloud/lesson/467fb1f2-7eb4-421c-a33c-117e1cf86b66/

Enter file in which to save the key (C:\Users\USER/.ssh/id_rsa):
## Установите Terraform.
 Дистрибутив для вашей платформы можно скачать из зеркала. После загрузки добавьте путь к папке, в которой находится исполняемый файл, в переменную PATH.
## Настройте провайдер.
https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider
В ОС Windows:


    Откройте файл конфигурации Terraform CLI terraform.rc в папке %APPDATA% вашего пользователя.

    Добавьте в него следующий блок:

    provider_installation {
      network_mirror {
        url = "https://terraform-mirror.yandexcloud.net/"
        include = ["registry.terraform.io/*/*"]
      }
      direct {
        exclude = ["registry.terraform.io/*/*"]
      }
    }
## Рядом с my-config.tf
    Создайте файл terraform.tfvars
    Он должен содержать текст вида:

    ya_cloud_token = "text"
    image_id = "text"
    zone = "ru-central1-a"
    vm_name = "agrusha-vm-05102022"
    = "text"
    cloud_id = "text"

Здесь
1) как получить ya_cloud_token описано здесь
https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
если вы зарегистрировались в Yandex Cloud, то пройдите по ссылке
https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb

2) image_id
С помощью Yandex CLI.
https://cloud.yandex.ru/docs/cli/quickstart#install
 Нужно выполнить команду
  yc compute image list --folder-id standard-images
в первой колонке будет image_id

3) vm_name - это имя виртуальной машины. Любое, главное чтобы оно было уникальное.

4) cloud_id - id облака в Yandex Cloud
Его можно узнать с помощью команды
  yc resource-manager cloud list

folder_id - id папки в Yandex Cloud
С помощью Yandex CLI.
  yc resource-manager folder create --name project-1
где project-1 - это имя папки.

Если папка уже создана, то воспользуйтесь командой
  yc resource-manager folder list

после это если выполнить
  yc config set folder-id b1111111111111111111v --profile default 
где b1111111111111111111v - folder_id
то Yandex CLI будет считать эту папку текущей

## выполнить terraform init
terraform init
решение возможных проблем:
https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider

## выполнить terraform plan
terraform plan

## выполнить terraform apply
terraform apply

 ввести yes и нажать enter

# Вход в виртуалку 
ssh ubuntu@51.250.7.35
где 51.250.7.35 - это внешний ip
Его можно узнать зайдя в 
https://console.cloud.yandex.ru
Выбрав Compute Cloud
после этого выбрав виртуальную машину

или выполнив
yc compute instance list

# Замечания:
Это тестовый пример настройки Yandex Cloud с помощью my-config.tf
Для тестов использовался образ Ubuntu 20.04
image_id = "fd8ju9iqf6g5bcq77jns"
вы можете использовать другой, но он может потребовать большего количества памяти.
В этом случае 
нужно будет поменять 
  resources {
    cores  = 2
    memory = 2
  }
здесь cores - количество ядер
memory - количество оперативной памяти (в GB)

terraform state list 
выводит стейт-файл

terraform destroy
удаляет инфраструктуру

## Ошибка
 Terraform: could not connect to registry.terraform.io 