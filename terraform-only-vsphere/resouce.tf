resource "vsphere_virtual_machine" "elastic_master" {
    count            = 3
    name             = "elastic-master-${count.index + 1}"
    resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
    datastore_id     = "${data.vsphere_datastore.datastore.id}"

    num_cpus         = 6
    memory           = 4096
    guest_id         = "centos7_64Guest"

    network_interface {
        network_id   = "${data.vsphere_network.network.id}"
    }

    disk {
        label        = "disk0"
        size         = 128
        unit_number  = 0
    }

    disk {
        label        = "disk1"
        size         = 256
        unit_number  = 1
    }

    clone {
        template_uuid = "${data.vsphere_virtual_machine.centos7_template.id}"
    }
}
resource "vsphere_virtual_machine" "elastic_data" {
    count            = 3
    name             = "elastic-data-${count.index + 1}"
    resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
    datastore_id     = "${data.vsphere_datastore.datastore.id}"

    num_cpus         = 6
    memory           = 4096
    guest_id         = "centos7_64Guest"

    network_interface {
        network_id   = "${data.vsphere_network.network.id}"
    }

    disk {
        label        = "disk0"
        size         = 128
        unit_number  = 0
    }

    disk {
        label        = "disk1"
        size         = 256
        unit_number  = 1
    }

    clone {
        template_uuid = "${data.vsphere_virtual_machine.centos7_template.id}"
    }
}