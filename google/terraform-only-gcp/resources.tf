resource "random_id" "instance_id" {
  byte_length     = 8
}

resource "google_compute_disk" "masters" {
  count = "${var.google_node_count}"
  name  = "es-master-${count.index}"
  type  = "pd-standard"
  zone  = "${var.google_zone}"
  size  = "50"
}


resource "google_compute_instance" "elastic-master" {
    count         = "${var.google_node_count}"
    name          = "test-vm-${random_id.instance_id.hex}-${count.index}"
    machine_type  = "${var.google_machine_type}"
    boot_disk {
        initialize_params {
            image = "${var.google_instance_image}"
        }
    }
    zone          = "${var.google_zone}"
    network_interface {
        network   = "default"
        access_config {

        }
    }
    metadata {
        sshKeys   = "centos:${file("${var.google_ssh_key}")}"
    }
    attached_disk {
        source      = "${element(google_compute_disk.masters.*.self_link, count.index)}"
        device_name = "${element(google_compute_disk.masters.*.name, count.index)}"
    }
}

