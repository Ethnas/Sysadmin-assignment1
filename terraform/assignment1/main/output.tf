#funker ikke
output "vm_public_ips" {
    value = [azurerm_linux_virtual_machine.webserver.*.public_ip_address]
}