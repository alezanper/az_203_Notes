#"Logged into azure powershell, with connect-AzureRmAxxount"

#Install AzureRm.Netcore in PowerShell Core
sudo PowerShell
Install-Module AzureRm.Netcore

exit

#Start a connection with Azure
Connect-AzureRmAccount -Subscription 'Demostration Account'

#Create a Linux VM 
$rg = Get-AzureRmResourceGroup `
    -Name 'myrg'
    -Location 'Centralus'

$rg

#Create a subnet configuration
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig `
    -Name 'subnet-2' `
    -AddressPrefix '10.2.1.0/24' `

$subnetConfig

#Create a virtual network
$vnet = New-AzureRmVirtualNetwork `
    -ResourceGroupName $rg.ResourceGroupName `
    -Location $rg.Location
    -Name 'vnet-2' `
    -AddressPrefix '10.2.0.0/16' `
    -subnet $subnetConfig

$vnet

#Create an Ip
$pip = New-AzureRmPublicIpAddress `
    -ResourceGroupName $rg.ResourceGroupName `
    -Location $rg.Location `
    -Name 'pip-2' `
    -AllocationMethod Static

$pip

#Create a networ security group rule for SSH
$rule1 = New-AzureRmNetworkSecurityRuleConfig `
    -Name ssh-rule `
    -Description 'Allow SSH' `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix Intenert `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 22

$rule1

#Create network security group with the rule
$nsg = New-AzureRmNetworkSecurityGroup `
    -ResourceGroupName $rg.ResourceGroupName `
    -Location $rg.Location `
    -Name 'ngs-2' `
    -SecurityRules $rule1

$nsg | more

#Create a virtual network card and associate with public IP address and NSG
$subnet = $vnet.Subnets | Where-Object { $_.Name -eq 'subnet-2'}

$nic = New-AzureRmNetworkInterface
    -ResourceGroupName $rg.ResourceGroupName `
    -Location $rg.Location `
    -Name 'Nic-2' `
    -Subnet $subnet `
    -PublicIpAddress $pip `
    -NetworkSecurityGroup $nsg

$nic

#Create a virtual machine configuration
$LinuxVmConfig = New-AzureRmVMConfig `
    -VMName 'linux-2'
    -VMSize 'Standard-D1'

$password = ConvertTo-SecureString 'myComplexPassword2020*' -AsPlainText -Force
$LinuxCred = New-Object System.Management.Automation.PSCredential ('alezanper', $password)

$LinuxVmConfig = Set-AzureRmVMOperatingSystem `
    -VM $LinuxVmConfig `
    -Linux `
    -ComputeName 'linux-2' `
    -DisablePasswordAuthentication `
    -Credential $LinuxCred

$sshPublicKey = Get-Content "~/.ssh/id_rsa.pub"
Add-AzureRmVMSshPublicKey `
    -VM $LinuxVmConfig `
    -KeyData $sshPublicKey `
    -Path "/home/alezanper/.ssh/authorized_keys"

Get-AzureRmVMImageSku -Location $rg.Location -PublisherName "Redhat" -Offer "rhel"

$LinuxVmConfig = Set-AzureRmVMSourceImage `
    -VM $LinuxVmConfig `
    -PublisherName 'Redhat' `
    -Offer 'rhel' `
    -Skus '7.4' `
    -Version 'Latest'

$LinuxVmConfig = Add-AzureRmVMNetworkInterface `
    -VM $LinuxVmConfig`
    -Id $nic.Id

New-AzureRmVM `
    -ResourceGroupName $rg.ResourceGroupName `
    -Location $rg.Location `
    -VM $LinuxVmConfig

$MyIp = Get-AzureRmPublicIpAddress `
    -ResourceGroupName $rg.ResourceGroupName `
    -Name $pip.Name | Select-Object -ExpandProperty AzureRmPublicIpAddress

$MyIP

ssh -l alezanper $MyIP











