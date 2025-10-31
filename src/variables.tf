## cloud vars


variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "vpc_name" {
  type        = string
  default     = "netology"
  description = "VPC network name"
}  

variable "public_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "private_cidr" {
  type        = list(string)
  default     = ["192.168.20.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}


variable "vpc_subnet_name_public" {
  type        = string
  default     = "public"
  description = "VPC subnet name"
}

variable "vpc_subnet_name_private" {
  type        = string
  default     = "private"
  description = "VPC subnet name"
}

variable "bucket_name" {
  type        = string
  default     = "vladmgb-bucket-27102025"
  description = "Name of the Object Storage bucket"
}

variable "image_file_path" {
  type        = string
  default     = "./image.jpg"
  description = "Path to the image file"
}

variable "image_url" {
  description = "Public URL of the image in Object Storage"
  type        = string
  default     = "https://storage.yandexcloud.net/vladmgb-bucket-2710202/image.jpg"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/ubuntu.pub"
}

variable "vm_user" {
  description = "Username for VM access"
  type        = string
  default     = "ubuntu"
}

variable "web_page_title" {
  description = "Title for the web page"
  type        = string
  default     = "LAMP Instance Group"
}

variable "instance_count" {
  description = "Number of instances in the group"
  type        = number
  default     = 3
}

variable "web_page_styles" {
  description = "CSS styles for the web page"
  type        = string
  default     = <<-EOT
    body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
    .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    h1 { color: #333; text-align: center; }
    img { max-width: 100%; height: auto; border-radius: 8px; border: 2px solid #ddd; }
    .info { background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0; }
  EOT
}

variable "vm_resources" {
  description = "VM resources configuration"
  type = object({
    memory = number
    cores  = number
    core_fraction = number
  })
  default = {
    memory = 2
    cores  = 2
    core_fraction = 5
  }
}