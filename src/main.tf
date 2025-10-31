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
      memory = var.vm_resources.memory
      cores  = var.vm_resources.cores
      core_fraction = var.vm_resources.core_fraction
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
    ssh-keys = "${var.vm_user}:${file(var.ssh_public_key_path)}"
    user-data = templatefile("${path.module}/user-data.tftpl", {
    web_page_title  = var.web_page_title
    image_url       = var.image_url
    })
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
    zones = [var.default_zone]
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
}

