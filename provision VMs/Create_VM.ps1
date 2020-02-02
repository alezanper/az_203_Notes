# Install AzureRm.Netcore in PowerShell Core
Install-Module AzureRm.Netcore

# Start a connection with Azure
Connect-AzureRmAccount 

# For creating a new resourcegroup
New-AzureRmResourceGroup `
   -Name 'myrg' `
   -Location 'Centralus'

# For getting the resourcegroup
$rg = Get-AzureRmResourceGroup `
    -Name 'myrg' `
    -Location 'Centralus'

$rg

# For Creating a subnet configuration
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
    -Name 'subnet-1' `
    -AddressPrefix '10.2.1.0/24' `

$subnetConfig

# For Creating a virtual network
$vnet = New-AzureRmVirtualNetwork `
    -ResourceGroupName $rg.ResourceGroupName `
    -Location $rg.Location `
    -Name 'vnet-1' `
    -AddressPrefix '10.2.0.0/16' `
    -subnet $subnetConfig

$vnet

# For creating a public Ip
$pip = New-AzureRmPublicIpAddress `
    -ResourceGroupName $rg.ResourceGroupName `
    -Location $rg.Location `
    -Name 'pip-1' `
    -AllocationMethod Static

$pip

# For Creating a network security group rule for SSH
$rule1 = New-AzureRmNetworkSecurityRuleConfig `
    -Name ssh-rule `
    -Description 'Allow SSH' `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 22

$rule1

# For Creating a network security group with the rule
$nsg = New-AzureRmNetworkSecurityGroup `
    -ResourceGroupName $rg.ResourceGroupName `
    -Location $rg.Location `
    -Name 'ngs-1' `
    -SecurityRules $rule1

$nsg | more

$vnet.Subnets

# For Creating a virtual network card and associate with public IP address and NSG
$subnet = $vnet.Subnets | Where-Object { $_.Name -eq 'subnet-1'}

$subnet

# For creating the network interface card
$nic = New-AzureRmNetworkInterface `
    -ResourceGroupName $rg.ResourceGroupName `
    -Location $rg.Location `
    -Name 'Nic-1' `
    -Subnet $subnet `
    -PublicIpAddress $pip `
    -NetworkSecurityGroup $nsg

$nic

# For Creating the virtual machine configuration
$LinuxVmConfig = New-AzureRmVMConfig `
    -VMName 'mylinux' `
    -VMSize 'Standard_B1ms'

$password = ConvertTo-SecureString 'myComplexPassword2020*' -AsPlainText -Force
$LinuxCred = New-Object System.Management.Automation.PSCredential ('alezanper', $password)

$LinuxVmConfig = Set-AzureRmVMOperatingSystem `
    -VM $LinuxVmConfig `
    -Linux `
    -ComputerName 'mylinux' `
    #-DisablePasswordAuthentication `
    -Credential $LinuxCred

# Optional adding SSH key
$sshPublicKey = Get-Content "~/.ssh/id_rsa.pub"
Add-AzureRmVMSshPublicKey `
    -VM $LinuxVmConfig `
    -KeyData $sshPublicKey `
    -Path "/home/alezanper/.ssh/authorized_keys"

# Checking for images 
Get-AzureRmVMImageSku -Location $rg.Location -PublisherName "Redhat" -Offer "rhel"

# Configure the OS
$LinuxVmConfig = Set-AzureRmVMSourceImage `
    -VM $LinuxVmConfig `
    -PublisherName 'Redhat' `
    -Offer 'rhel' `
    -Skus '7.4' `
    -Version 'Latest'

# Adding NIC
$LinuxVmConfig = Add-AzureRmVMNetworkInterface `
    -VM $LinuxVmConfig `
    -Id $nic.Id

# For creating the VM
New-AzureRmVM `
    -ResourceGroupName $rg.ResourceGroupName `
    -Location $rg.Location `
    -VM $LinuxVmConfig

# Getting Ip address
$publicIp = Get-AzureRmPublicIpAddress -Name $pip.Name -ResourceGroupName $rg.ResourceGroupName

$publicIp.IpAddress