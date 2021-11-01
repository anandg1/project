# PROJECT
[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)]()

## Pre-requesites:

- AWS Command Line Interface installed and configured on the localhost.
- Ansible installed.
- Terraform installed.

## Changes to make before running the code: 

1) Clone the repo to your localhost.
2) Enter your aws secret key and access key in 'terraform.tfvars' file in the '/project/terraform/' directory
3) Generate keypair using 'ssh-keygen' command and store the key as 'tfkey' in '/project/terraform/' directory

```sh
root@xx:~/project/terraform# ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): tfkey
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in tfkey
Your public key has been saved in tfkey.pub
The key fingerprint is:
SHA256:ajSsETowXRekmf/NgXAO8neazdqZ4+9syygVqvIIT1M root@AG
The key's randomart image is:
+---[RSA 3072]----+
|    ..+.         |
| . . =           |
|o . * o .        |
| o . * = ..      |
|  o . E S.o.     |
|   . = =.O..     |
|  . + o.+.=      |
|   +.+. .o.*.    |
|    oo. .o*=*.   |
+----[SHA256]-----+
rootxx:~/project/terraform# ls -l
total 80
-rw-r--r-- 1 root root  9950 Nov  1 22:39 main.tf
-rw-r--r-- 1 root root   105 Nov  1 22:39 provider.tf
-rw-r--r-- 1 root root 35634 Nov  1 23:12 terraform.tfstate
-rw-r--r-- 1 root root   303 Nov  1 23:10 terraform.tfvars
-rw------- 1 root root  2590 Nov  1 23:21 tfkey
-rw-r--r-- 1 root root   561 Nov  1 23:21 tfkey.pub
-rw-r--r-- 1 root root   188 Nov  1 22:39 variables.tf
```
4) Change permission of key file into 400
```sh
root@xx:~/project/terraform# chmod 400 tfkey
```
## How to deploy the project:

Only need to run the playbook 'main.yml' in 'project' directory using the following command:
```sh
ansible-playbook main.yml
```

 
 ## Output
 ```sh
 root@xx:~/project# ansible-playbook main.yml

[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'
[WARNING]: Could not match supplied host pattern, ignoring: proxy_host
[WARNING]: Could not match supplied host pattern, ignoring: flask_host
[WARNING]: Could not match supplied host pattern, ignoring: database_host

PLAY [Creating InfraStructure And Dynamic Inventory] ************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************
ok: [localhost]

TASK [init the terraform] ***************************************************************************************************************************************************
changed: [localhost]

TASK [Creating AWS instances with Terraform] ********************************************************************************************************************************
changed: [localhost]

TASK [Pause for 3 minutes for instances to get ready] ***********************************************************************************************************************
Pausing for 180 seconds
(ctrl+C then 'C' = continue early, ctrl+C then 'A' = abort)
Press 'C' to continue the play or 'A' to abort
ok: [localhost]

TASK [Creating host for webserver] ******************************************************************************************************************************************
changed: [localhost]

TASK [Creating host for database] *******************************************************************************************************************************************
changed: [localhost]

TASK [Creating host for flask] **********************************************************************************************************************************************
changed: [localhost]

TASK [Creating host for flask(private)] *************************************************************************************************************************************
changed: [localhost]

PLAY [Configuring Reverse Proxy Server] *************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************
ok: [proxy_host]

TASK [Installing Nginx Reverse Proxy] ***************************************************************************************************************************************
changed: [proxy_host]

TASK [Generating nginx conf from template] **********************************************************************************************************************************
changed: [proxy_host]

TASK [Setting Flask Host Variable] ******************************************************************************************************************************************
ok: [proxy_host]

TASK [Delete existing default vhost] ****************************************************************************************************************************************
changed: [proxy_host]

TASK [Generating new default vhost from template] ***************************************************************************************************************************
changed: [proxy_host]

TASK [restart nginx] ********************************************************************************************************************************************************
changed: [proxy_host]

PLAY [Deploying FlaskApplication] *******************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************
ok: [flask_host]

TASK [Creating Python and pip3] *********************************************************************************************************************************************
changed: [flask_host]

TASK [Creating Application User flaskapp] ***********************************************************************************************************************************
changed: [flask_host]

TASK [Creating Application User flaskapp home directory] ********************************************************************************************************************
changed: [flask_host]

TASK [Uploading Application Content to app Directory] ***********************************************************************************************************************
changed: [flask_host]

TASK [Installing Flaskapp requirements.txt] *********************************************************************************************************************************
changed: [flask_host]

TASK [Creating Systemd Unit File for flaskapp] ******************************************************************************************************************************
changed: [flask_host]

TASK [Systemd daemon reload flaskapp] ***************************************************************************************************************************************
changed: [flask_host]

PLAY [Configuring MySQL Server] *********************************************************************************************************************************************

TASK [Gathering Facts] ******************************************************************************************************************************************************
ok: [database_host]

TASK [Mysql Installation] ***************************************************************************************************************************************************
changed: [database_host]

TASK [Restarting/Enabling Mysql Service] ************************************************************************************************************************************
changed: [database_host]

TASK [Sets the root password] ***********************************************************************************************************************************************
[WARNING]: Module did not set no_log for update_********
changed: [database_host]

TASK [Removing test database] ***********************************************************************************************************************************************
ok: [database_host]

TASK [Removing anonymous users] *********************************************************************************************************************************************
ok: [database_host]

TASK [Creating new database] ************************************************************************************************************************************************
changed: [database_host]

TASK [Creating a new user] **************************************************************************************************************************************************
changed: [database_host]

PLAY RECAP ******************************************************************************************************************************************************************
database_host              : ok=8    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
flask_host                 : ok=8    changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=8    changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
proxy_host                 : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
