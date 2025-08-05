terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.26.0"
    }
  }
}

provider "vultr" {
  api_key = var.vultr_api_key
}

resource "vultr_instance" "kamal_vps" {
  plan    = "vc2-1c-1gb"
  region  = "lhr"
  os_id = "391" # Fedora CoreOS
  user_data = file("server.ign")
  label   = "kamal-vps"
}

output "ip_information" {
  description = "IP information the Kamal VPS"
  value = <<-EOT
  You have successfully created a Kamal VPS instance.
  Please use the following IP to target the server.

    IP Address: ${vultr_instance.kamal_vps.main_ip}

  EOT
}
