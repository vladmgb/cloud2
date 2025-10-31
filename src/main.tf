###### Networks

resource "yandex_vpc_network" "netology" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = var.vpc_subnet_name_public
  zone           = var.default_zone
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.public_cidr
}

resource "yandex_vpc_subnet" "private" {
  name           = var.vpc_subnet_name_private
  zone           = var.default_zone
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.private_cidr
  route_table_id = yandex_vpc_route_table.nat_route_table.id
}

###### NAT

resource "yandex_compute_instance" "nat_instance" {
  name        = "nat-instance"
  hostname    = "nat-instance"
  platform_id = "standard-v3"
  zone        =  var.default_zone
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"                 
    nat        = true                              
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/ubuntu.pub")}"
  }

  scheduling_policy {
    preemptible = true  
  }
}

####### Public Vm

resource "yandex_compute_instance" "public_vm" {
  name        = "public-vm"
  hostname    = "public-vm"
  platform_id = "standard-v1"
  zone        =  var.default_zone

  resources {
    cores  = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd86rorl7r6l2nq3ate6"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.10"                 
    nat        = true                              
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/ubuntu.pub")}"
  }

  scheduling_policy {
    preemptible = true  
  }
}

####### Route table

resource "yandex_vpc_route_table" "nat_route_table" {
  name       = "nat-route-table"
  network_id = yandex_vpc_network.netology.id

    static_route {
    destination_prefix = "0.0.0.0/0"           
    next_hop_address   = "192.168.10.254"      
  }

  labels = {
    purpose = "nat-routing"
  }
}

####### Private Vm

resource "yandex_compute_instance" "private_vm" {
  name        = "private-vm"
  hostname    = "private-vm"
  platform_id = "standard-v1"
  zone        =  var.default_zone

  resources {
    cores  = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd86rorl7r6l2nq3ate6"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.private.id
    ip_address = "192.168.20.10"                 
                                
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/ubuntu.pub")}"
  }

  scheduling_policy {
    preemptible = true  
  }
}

# Object Storage

resource "yandex_storage_bucket" "my-bucket" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  max_size = 1073741824

  anonymous_access_flags {
    read = true
    list = true
  }
}

resource "yandex_storage_object" "my-image" {
  bucket = yandex_storage_bucket.my-bucket.id
  key    = "image.jpg"
  source = var.image_file_path
  acl    = "public-read"

  depends_on = [
    yandex_storage_bucket.my-bucket
  ]
}


# Instance Group

resource "yandex_iam_service_account" "vm-sa" {
  name        = "vm-service-account"
  description = "Service account for VMs"
}

resource "yandex_resourcemanager_folder_iam_member" "vm-sa-role" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.vm-sa.id}"
}


resource "yandex_compute_instance_group" "lamp-group" {
  name               = "lamp-instance-group-new"
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.vm-sa.id
  deletion_protection = false

  instance_template {
    platform_id = "standard-v1"
    name        = "lamp-vm-{instance.index}" 
    hostname    = "lamp-vm-{instance.index}" 
    resources {
      memory = 2
      cores  = 2
      core_fraction = 5
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd85i2h4n9msqf3e3jl4" # LAMP image
        size     = 20
        type     = "network-hdd"
      }
    }

    network_interface {
      subnet_ids  = [yandex_vpc_subnet.public.id]             
      nat        = true                              
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/ubuntu.pub")}"
      user-data = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - apache2
      runcmd:
        - systemctl enable apache2
        - systemctl start apache2
        - echo '<!DOCTYPE html><html><head><title>LAMP Instance</title><style>body { font-family: Arial, sans-serif; margin: 40px; } img { max-width: 100%; }</style></head><body><h1>🚀 LAMP Instance Group</h1><p>Instance: {instance.index}</p><img src="${var.image_url}" alt="Image from Object Storage"><p><a href="${var.image_url}" target="_blank">Open original image</a></p></body></html>' > /var/www/html/index.html
        - chown www-data:www-data /var/www/html/index.html
        - systemctl restart apache2
  EOF
}

    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  # Health Check
  health_check {
    timeout   = 3
    interval  = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    
    http_options {
      port = 80
      path = "/"
    }
  }

  depends_on = [
    yandex_storage_object.my-image
  ]
}




resource "yandex_compute_instance" "lamp" {
  name               = "lamp-instance"
  folder_id          = var.folder_id
  zone                = var.default_zone
  

  resources {
      memory = 2
      cores  = 2
      core_fraction = 5
  }

    boot_disk {

      initialize_params {
        image_id = "fd85i2h4n9msqf3e3jl4" # LAMP image
        size     = 20
        type     = "network-hdd"
      }
    }

    network_interface {
      subnet_id  = yandex_vpc_subnet.public.id            
      nat        = true                              
    }

    metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/ubuntu.pub")}"
    user-data = <<-EOF
    #cloud-config
    write_files:
    - path: /var/www/html/index.html
      owner: www-data:www-data
      permissions: '0644'
      content: |
        <!DOCTYPE html>
        <html lang="ru">
        <head>
            <meta charset="UTF-8">
            <title>LAMP Instance</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
                .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                h1 { color: #333; text-align: center; }
                img { max-width: 100%; height: auto; border-radius: 8px; border: 2px solid #ddd; }
                .info { background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>LAMP Instance Group</h1>
                <div class="info">
                    <p><strong>Instance:</strong> $(hostname)</p>
                    <p><strong>Image URL:</strong> https://storage.yandexcloud.net/vladmgb-bucket-27102025/image.jpg</p>
                </div>
                <div style="text-align: center;">
                    <a href="https://storage.yandexcloud.net/vladmgb-bucket-27102025/image.jpg" target="_blank">
                        <img src="https://storage.yandexcloud.net/vladmgb-bucket-27102025/image.jpg" alt="Image from Object Storage">
                    </a>
                    <p><a href="https://storage.yandexcloud.net/vladmgb-bucket-27102025/image.jpg" target="_blank">📎 Открыть изображение в новой вкладке</a></p>
                </div>
            </div>
        </body>
        </html>
    runcmd:
      - systemctl enable apache2
      - systemctl start apache2
      - systemctl restart apache2
  EOF
  }

    scheduling_policy {
      preemptible = true
    }
  }

