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
  default     = "vladmgb_bucket_27102025"
  description = "Name of the Object Storage bucket"
}

variable "image_file_path" {
  type        = string
  default     = "./image.jpg"
  description = "Path to the image file"
}
