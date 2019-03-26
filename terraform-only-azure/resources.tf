resource "azurerm_resource_group" "test_resource_group" {
    name     = "production"
    location = "West US"
}

resource "azurerm_virtual_network" "test_net" {
    name                = "production-network"
    resource_group_name = "${azurerm_resource_group.test_resource_group.name}"
    location            = "${azurerm_resource_group.test_resource_group.location}"
    address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
    name                 = "internal"
    resource_group_name  = "${azurerm_resource_group.test_resource_group.name}"  
    virtual_network_name = "${azurerm_virtual_network.test_net.name}"
    address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "main" {
    name                = "${var.prefix}-nic"
    location            = "${azurerm_resource_group.test_resource_group.location}"
    resource_group_name = "${azurerm_resource_group.test_resource_group.name}"
    ip_configuration {
        name                          = "testconfiguration1"
        subnet_id                     = "${azurerm_subnet.internal.id}"
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_virtual_machine" "test-vm" {
    name                             = "${var.prefix}-vm"
    location                         = "${azurerm_resource_group.test_resource_group.location}"
    resource_group_name              = "${azurerm_resource_group.test_resource_group.name}"
    vm_size                          = "Standard_DS1_v2"
    delete_data_disks_on_termination = true
    delete_os_disk_on_termination    = true
    storage_image_reference {
        publisher = ""
        offer     = ""
        sku       = ""
        version   = ""
    }
    storage_os_disk {
        name              = "myosdisk1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    storage_data_disk {
        name              = "myosdisk1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "${azurerm_virtual_machine.test-vm.name}"
        admin_username = "andrew"
        admin_password = "adminmeplease"
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
    tags = {
        environment = "Staging"
    }
}

