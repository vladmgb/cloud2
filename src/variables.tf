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

variable "user_data_template" {
  description = "User data template for VM initialization"
  type        = string
  default     = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - apache2
    write_files:
    - path: /var/www/html/index.html
      owner: www-data:www-data
      permissions: '0644'
      content: |
        <!DOCTYPE html>
        <html lang="ru">
        <head>
            <meta charset="UTF-8">
            <title>${web_page_title}</title>
            <style>${web_page_styles}</style>
        </head>
        <body>
            <div class="container">
                <h1>${web_page_title}</h1>
                <div class="info">
                    <p><strong>Instance:</strong> $(hostname)</p>
                    <p><strong>Image URL:</strong> ${image_url}</p>
                </div>
                <div style="text-align: center;">
                    <a href="${image_url}" target="_blank">
                        <img src="${image_url}" alt="Image from Object Storage">
                    </a>
                    <p><a href="${image_url}" target="_blank">📎 Открыть изображение в новой вкладке</a></p>
                </div>
            </div>
        </body>
        </html>
    runcmd:
      - systemctl enable apache2
      - systemctl start apache2
      - systemctl restart apache2
  EOT
}