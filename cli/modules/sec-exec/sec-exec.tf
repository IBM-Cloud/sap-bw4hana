resource "null_resource" "sec-exec" {
  
  provisioner "local-exec" {
     command = "sed -i  's/${var.SAP_MAIN_PASSWORD}/xxxxxxxx/' terraform.tfstate"
    }
  provisioner "local-exec" {
     command = "sed -i  's/${var.HANA_MAIN_PASSWORD}/xxxxxxxx/' terraform.tfstate"
    }
  provisioner "local-exec" {
   command = "sleep 20; rm -rf  ansible/*-vars.yml; rm -f ansible/hana_volume_layout.json"
  }
}
