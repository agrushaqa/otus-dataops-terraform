 variable "image_id" {
  type        = string
  description = "The id of the machine image."

  validation {
    condition     = length(var.image_id) > 4
    error_message = "The length image_id value must be > 4"
  }
}

 variable "zone" {
  type        = string
  description = "accessibility zone. Yandex Cloud cluster"
}

 variable "ya_cloud_token" {
  type        = string
  description = "yandex cloud token"
}

 variable "vm_name" {
  type        = string
  description = "name of virtual machine"
}

 variable "folder_id" {
  type        = string
  description = "folder id"
}

 variable "cloud_id" {
  type        = string
  description = "folder id"
}

 variable "user_password" {
  type        = string
  description = "user password"
}

 terraform {
   required_providers {
     yandex = {
       source = "yandex-cloud/yandex"
     }
   }
 }
  

 provider "yandex" {
   token  =  var.ya_cloud_token
   cloud_id  = var.cloud_id
   folder_id = var.folder_id
   zone      = var.zone
 }
 
 resource "yandex_compute_instance" "agrusha-cloud-vm-05102022" {
  name        = var.vm_name
  platform_id = "standard-v1"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

    scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_terraform_network.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_vpc_network" "terraform_network" {
    name = "grusha-terraform-network"
}

resource "yandex_vpc_subnet" "subnet_terraform_network" {
  zone       = "ru-central1-a"
  network_id = "${yandex_vpc_network.terraform_network.id}"
  v4_cidr_blocks = ["10.2.0.0/16"]
}

resource "yandex_mdb_postgresql_cluster" "postgres-1" {
  name        = "postgres-1"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.terraform_network.id

  config {
    version = 12
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 16
    }
    postgresql_config = {
      max_connections                   = 395
      enable_parallel_hash              = true
      vacuum_cleanup_index_scale_factor = 0.2
      autovacuum_vacuum_scale_factor    = 0.34
      default_transaction_isolation     = "TRANSACTION_ISOLATION_READ_COMMITTED"
      shared_preload_libraries          = "SHARED_PRELOAD_LIBRARIES_AUTO_EXPLAIN,SHARED_PRELOAD_LIBRARIES_PG_HINT_PLAN"
    }
  }
 
  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.subnet_terraform_network.id
  }
}

resource "yandex_mdb_postgresql_user" "username" {
  cluster_id = yandex_mdb_postgresql_cluster.postgres-1.id
  name = "my-name"
  password = var.user_password
  settings = {
  default_transaction_isolation = "read committed"
  log_min_duration_statement = 5000
  }
}

resource "yandex_mdb_postgresql_database" "db1" {
  cluster_id = yandex_mdb_postgresql_cluster.postgres-1.id
  name = "postgres-1"
  owner = yandex_mdb_postgresql_user.username.name
}