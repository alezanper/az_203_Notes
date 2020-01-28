az login --subscription "subscription name"

az vm list-ip-addresses --name "myvm" --output table

ssh alezanper@a.b.c.d

sudo waagent -deprovision+user -force

az vm deallocate \
    --resource-group "myrg" \
    --name "myvm"

az vm list \
    --show-details \
    --output table

az vm generalize \
    --resource-group "myrg"
    --name "myvm"

az image create \
    --resource-group "myrg"
    --name "myvm-ci"
    --source "myvm"

az image list \
    --output table

az vm create \
    --resource-group "myrg" \
    --location "centralus" \
    --name "new-vm" \
    --image "myvm-ci" \
    --admin-username "alezanper" \
    --authentication-type "ssh" \
    --ssh-key-value ~/.ssh/id_rsa.pub

az vm list \
    --show-details \
    --output table


# You cannot create a vm outside the region where the image resides