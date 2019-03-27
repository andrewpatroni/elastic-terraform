resource "vsphere_virtual_machine" "elastic_master" {
    count            = 3
    name             = "elastic-master-${count.index + 1}"
    resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
    datastore_id     = "${data.vsphere_datastore.datastore.id}"

    num_cpus         = 6
    memory           = 6144
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
    provisioner "local-exec" {
        command = "sleep 30 && ansible-galaxy --roles-path=.ansible/ install elastic.elasticsearch && ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -u root --private-key ../../../andrewpatroni-github -i '${self.default_ip_address},'  elasticsearch-lvm.yml && ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -u root --private-key ../../../andrewpatroni-github -i '${self.default_ip_address},' --extra-vars 'prihost=${vsphere_virtual_machine.elastic_master.0.default_ip_address} hname=${self.name}' elasticsearch-master.yml"
    }  
}
resource "vsphere_virtual_machine" "elastic_data" {
    count            = 3
    name             = "elastic-data-${count.index + 1}"
    resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
    datastore_id     = "${data.vsphere_datastore.datastore.id}"

    num_cpus         = 6
    memory           = 6144
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
    provisioner "local-exec" {
        command = "sleep 30 && ansible-galaxy --roles-path=.ansible/ install elastic.elasticsearch && ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -u root --private-key ../../../andrewpatroni-github -i '${self.default_ip_address},'  elasticsearch-lvm.yml && ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -u root --private-key ../../../andrewpatroni-github -i '${self.default_ip_address},' --extra-vars 'prihost=${vsphere_virtual_machine.elastic_master.0.default_ip_address} hname=${self.name}' elasticsearch-data.yml"
    }
}