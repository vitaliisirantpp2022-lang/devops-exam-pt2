terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.30"
    }
  }

  # Вимога: tfstate-файл розміщений у хмарі
  backend "s3" {
    endpoint                    = "fra1.digitaloceanspaces.com"
    region                      = "us-east-1" # Для S3 backend у DO завжди залишаємо us-east-1 для сумісності API
    bucket                      = "fedorychko-tfstate" # Бакет, який ви створили на Етапі 1
    key                         = "infrastructure/terraform.tfstate"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
  }
}

provider "digitalocean" {
  # Токен буде підтягуватися автоматично через змінні оточення у GitHub Actions
}