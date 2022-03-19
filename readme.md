# Bootstrap GWLB enabled Palo Alto 10 in AWS

Folder structure
```
- main.tf
  providers.tf
  readme.md
  variables.tf
  - bootstrap
    |_ bootstrap.xml
    |_ init-cfg.txt
```    

Under bootstrap folder, there are two files that's essential to Palo Alto's bootstrapping

## bootstrap.xml
The optional bootstrap.xml file contains a complete configuration for the firewall. If you are not using Panorama to centrally manage your firewalls, the bootstrap.xml file provides a way to automate the process of deploying firewalls that are configured at launch.

bootstrap.xml can be generated after you have configured Palo Alto firewall, then **Device** > **Setup** > **Operations** > **Save** > **Save named configuration snapshot** > Give it a name

After that **Device** > **Setup** > **Operations** > **Export** > **Export Named Configuration Snapshot** > name the file as **bootstrap.xml**

## init-cfg.txt
Contains basic information for configuring the management interface on the firewall, such as the IP address type (static or DHCP), IP address (IPv4 only or both IPv4 and IPv6), netmask, and default gateway. The DNS server IP address, Panorama IP address and device group and template stack parameters are optional.

In this example, since we are not using Panorama, we are depends on bootstrap.xml to configure everything in the firewall. Hence most of key/value pair have empty value.

This line is necessory to make sure Firewall will have GWLB enabled:
plugin-op-commands=aws-gwlb-inspect:enable

## What if there's configuration conflict between the two files?
When you include init-cfg.txt file and the bootstrap.xml file in the bootstrap package, the firewall merges the configurations of those files, and if any settings overlap, the firewall uses the values defined in the init-cfg.txt file.

https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-configuration-files.html

## What else gets created?
The terraform files will also create:
1. S3 bucket
2. Role and policy that will allow the firewall to list and read objects within the created S3 bucket
3. Folder structures
```
|_ config
    |_ bootstrap.xml
    |_ init-cfg.txt
|_ content
|_ license
|_ software
```
4. Place **bootstrap.xml** and **init-cfg.txt** under **config** folder
5. Firewall provisioned with provided bootstrap.xml script will:
    * Have default user name: **admin**
    * Have password: **yGNaoO3gzRtzwnzp** (you should configure and generate new bootstrap.xml with desired admin name and password)
    * Have eth 1/2 configured as:
        * layer3
        * use default router
        * LAN security zone
        * DHCP client
        * Disabled: **Automatically create default route pointing to default gateway provided by server**
        * Enabled **HTTPS** health check
    * Firewall on a stick / One armed mode with only eth 1/2 enabled
    * Allow all security polciy configured from all zones to all zones with all applications

## Reference: 
https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-aws.html
