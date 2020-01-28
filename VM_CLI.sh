az login --suscription "subscription name"

az group create \
    --name "myrg" \
    --location "centralus"

az group list -o table

az network vnet create \
    --resource-group "myrg" \
    --name "vnet-1" \
    --address-prefix "10.1.1.0/16" \
    --subnet-name "subnet-1" \
    --subnet-prefix "10.1.1.0/24"

az network vnet list -o table

az network public-ip create \
    --resource-group "myrg" \
    --name "pip-1"

az network ngs create \
    --resource-group "myrg" \
    --name "nsg-1"

az network ngs list -o table

az network nic create \
    --resource-group "myrg" \
    --name "nic-1" \
    --vnet-name "vnet-1" \
    --subnet "subnet-1" \
    --network-security-group "nsg-1" \
    --public-ip-address "pip-1"

az network nic list -o table

# For windows machine
az vm create \
    --resource-group "myrg" \
    --location "centralus" \
    --name "myvm" \
    --nics "nic-1" \
    --image "win2016datacenter" \
    --admin-username "alezanper" \
    --admin-password "mycomplexpassword2020*"
    

az vm create \
    --resource-group "myrg" \
    --location "centralus" \
    --name "myvm" \
    --nics "nic-1" \
    --image "rhel" \
    --admin-username "alezanper" \
    --ssh-key-value ~/.ssh/id_rsa.pub

az vm open-port \
    --resource-group "myrg" \
    --name "linux-1"
    --port "22"

az vm list-ip-addressses --name "linux-1" --o table

ssh -l alezanper x.y.x.w

az vm create \
    --resource-group "myrg" \
    --name "ubuntuTS" \
    --admin.username "alezanper" \
    --authentication-type "ssh" \
    --ssh-key-value ~/.ssh/id_rsa.pub

az vm open-port \
    --resource-group "myrg" \
    --name "myvm" \
    --port "22"

az vm list-ip-addressses --name "myvm" --output table