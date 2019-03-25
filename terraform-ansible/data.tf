data "vsphere_datacenter" "dc" {
    name          = "${var.vsphere_datacenter}"
}

data "vsphere_datastore" "datastore" {
    name          = "${var.vsphere_datastore}"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
    name          = "${var.vsphere_compute_cluster}"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
    name          = "${var.vsphere_resource_pool}"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
    name          = "${var.vsphere_network}"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "centos7_template" {
    name          = "CentOS-7-Template"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}