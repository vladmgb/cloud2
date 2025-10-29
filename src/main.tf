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

# Storage bucket

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