# Terraform Hello World


## AWS Provider

O [Terraform](https://www.terraform.io/) é uma ferramenta para construir, alterar e controlar a infraestrutura de forma segura e eficiente. O Terraform pode gerenciar provedores de serviços existentes e populares como OpenStack, Azure, AWS, Digital Ocean, entre outras, bem como soluções internas personalizadas.

Os arquivos de configuração do Terraform descrevem os componentes necessários para executar um único aplicativo ou todo o *datacenter*, gerando um plano de execução que descreve o que será feito para alcançar o estado desejado e, em seguida, executá-lo para construir a infraestrutura descrita. À medida que a configuração muda, o Terraform é capaz de determinar o que mudou e criar planos de execução incrementais que podem ser aplicados.

A infraestrutura que o Terraform pode gerenciar inclui componentes de baixo nível, como instâncias de computação, armazenamento e redes, bem como componentes de alto nível, como entradas DNS, recursos SaaS, etc.


## Pre-req Terraform

1. Fazer o *download* do Terraform em https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_windows_386.zip
    
2. Descomprimir o arquivo baixado no diretório *C:\Windows\System32*
   
3. Testar a instalação, abrindo o terminal de comando e digitando *terraform -h* como no exemplo abaixo.

    ```
    $ terraform -h
    Usage: terraform [global options] <subcommand> [args]

    The available commands for execution are listed below.
    The primary workflow commands are given first, followed by
    less common or more advanced commands.

    Main commands:
      init          Prepare your working directory for other commands
      validate      Check whether the configuration is valid
      plan          Show changes required by the current configuration
      apply         Create or update infrastructure
      destroy       Destroy previously-created infrastructure

    All other commands:
      console       Try Terraform expressions at an interactive command prompt
      fmt           Reformat your configuration in the standard style
      force-unlock  Release a stuck lock on the current workspace
      get           Install or upgrade remote Terraform modules
      graph         Generate a Graphviz graph of the steps in an operation
      import        Associate existing infrastructure with a Terraform resource
      login         Obtain and save credentials for a remote host
      logout        Remove locally-stored credentials for a remote host
      output        Show output values from your root module
      providers     Show the providers required for this configuration
      refresh       Update the state to match remote systems
      show          Show the current state or a saved plan
      state         Advanced state management
      taint         Mark a resource instance as not fully functional
      test          Experimental support for module integration testing
      untaint       Remove the 'tainted' state from a resource instance
      version       Show the current Terraform version
      workspace     Workspace management

    Global options (use these before the subcommand, if any):
      -chdir=DIR    Switch to a different working directory before executing the
                    given subcommand.
      -help         Show this help output, or the help for a specified subcommand.
      -version      An alias for the "version" subcommand.
    ```


## Pre-req Conta AWS

1. Abrir o *AWS Academy* e iniciar o ambiente SandBox.

2. Capturar as credenciais de acesso da conta SandBox e guardar essa info para uma etapa posterior.

    ```
    $ cat ~/.aws/credentials 
    [default]
    aws_access_key_id = ASIAV2XAOBJRRVNBXJL2
    aws_secret_access_key = ew0xROrRLYino1QRx9ds1UXM7iJUjwnx9E3T
    aws_session_token = FwoGZXIvYXdzEKv//////////wEaDF0S2MnqCAf5Z8Ov6yK9AaQG4G7B/TiV4VCqyJqJr9YA3n7802QTr92WYxKppnODY8d/8efpvPbUX+MspFfCo+szvoqW7fqIh00s/lJTwbQ0HZRboKjNnoEXF5+c+8soOUfKEXjtuU8BLKi73Hq1GEiubqHdHbxTUgWL5nwF9UnC+ilc/n//1qSbuH+Ltbhc6VgUb6ZbQf9Pn1z/6t46wUofOmHZu8qO37qfNh1K9G9qZjTQ/dvGSSnoSzk93uzbOgw4/KPnSjd0uSRBjIt3NiZ7TlpR/ie4GLu3r4k3YPBB3u4UoYbe3VBzxZ/OhBp1bVvH9FaCi4R8sN1
    ```
 

## Pre-req Visual Studio Code com extensão do GitHub

1. Abrir o *Visual Studio Code* e instalar a extensão *GitHub Pull Requests and Issues*.

   ![GitHub Extension](/hello/images/vscode-extension-github.png)

2. Clonar o repositório *https://github.com/FIAP/iac*

   - Pelo Visual Studio Code:
    ![Clone Repository](/hello/images/clone-repository.png)

   - Pelo terminal:
    ```
    $ git clone https://github.com/FIAP/iac
    Cloning into 'iac'...
    remote: Enumerating objects: 10, done.
    remote: Counting objects: 100% (10/10), done.
    remote: Compressing objects: 100% (10/10), done.
    remote: Total 3716 (delta 4), reused 0 (delta 0), pack-reused 3706
    Receiving objects: 100% (3716/3716), 44.63 MiB | 3.88 MiB/s, done.
    Resolving deltas: 100% (1862/1862), done.
    Checking connectivity... done.
    $
    ```

3. Conferir o conteúdo do [template](https://github.com/FIAP/iac/blob/master/hello/main.tf):

   - Pelo Visual Studio Code:
   ![main.tf file](/hello/images/main-file.png)

   - Pelo terminal:
    ```
    $ cd hello/
    $ cat main.tf 
    # PROVIDER
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 3.0"
        }
      }
    }

    # REGION
    provider "aws" {
        region = "us-east-1"
        shared_credentials_file = ".aws/credentials"
    }

    # VPC
    resource "aws_vpc" "Hello_VPC" {
        cidr_block           = "10.0.0.0/16"
        enable_dns_hostnames = "true"

        tags = {
            Name = "Hello VPC"  
        }
    }

    # INTERNET GATEWAY
    resource "aws_internet_gateway" "Hello_IGW" {
        vpc_id = aws_vpc.Hello_VPC.id

        tags = {
            Name = "Hello IGW"
        }
    }

    # SUBNET
    resource "aws_subnet" "Hello_Public_Subnet" {
        vpc_id                  = aws_vpc.Hello_VPC.id
        cidr_block              = "10.0.0.0/24"
        map_public_ip_on_launch = "true"
        availability_zone       = "us-east-1a"

        tags = {
            Name = "Hello Public Subnet"
        }
    }

    # ROUTE TABLE
    resource "aws_route_table" "Hello_Public_Route_Table" {
        vpc_id = aws_vpc.Hello_VPC.id

        route {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.Hello_IGW.id
        }

        tags = {
            Name = "Hello Public Route Table"
        }
    }

    # SUBNET ASSOCIATION
    resource "aws_route_table_association" "a" {
      subnet_id      = aws_subnet.Hello_Public_Subnet.id
      route_table_id = aws_route_table.Hello_Public_Route_Table.id
    }

    # SECURITY GROUP
    resource "aws_security_group" "Hello_Security_Group" {
        name        = "Hello_Security_Group"
        description = "Hello Security Group"
        vpc_id      = aws_vpc.Hello_VPC.id

        egress {
            description = "All to All"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
            description = "All from 10.0.0.0/16"
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["10.0.0.0/16"]
        }

        ingress {
            description = "TCP/22 from All"
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
            description = "TCP/80 from All"
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }

        tags = {
            Name = "Work Security Group"
        }
    }

    # EC2 INSTANCE
    resource "aws_instance" "hello-isntance" {
        ami                    = "ami-0c02fb55956c7d316"
        instance_type          = "t2.micro"
        subnet_id              = aws_subnet.Hello_Public_Subnet.id
        vpc_security_group_ids = [aws_security_group.Hello_Security_Group.id]

        tags = {
            Name = "hellow-isntance"
        }
    }
    ```

4. Abrir o Terminal do Visual Studio Code e inicializar o Terraform com o correspondente *provider* de AWS:

    ```
    $ cd hello/
    $ terraform init

    Initializing the backend...

    Initializing provider plugins...
    - Finding hashicorp/aws versions matching "~> 3.27"...
    - Installing hashicorp/aws v3.58.0...
    - Installed hashicorp/aws v3.58.0 (signed by HashiCorp)

    Terraform has created a lock file .terraform.lock.hcl to record the provider
    selections it made above. Include this file in your version control repository
    so that Terraform can guarantee to make the same selections by default when
    you run "terraform init" in the future.

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
    ```
    
5. Validar os templates:

    ```
    $ terraform validate
    Success! The configuration is valid.
    ```

6. Configurar as credenciais de acesso para acesso à conta AWS do Sandbox:

   - Criar arquivo que contém as credenciais de acesso.

    ```
    $ mkdir .aws/
    $ touch .aws/credentials
    ```
    
    - Colar as credenciais de acesso do SandBox dentro do arquivo *.aws/credentials*. O arquivo deverá ficar conforme exemplo abaixo.

    ```
    $ cat .aws/credentials
    [default]
aws_access_key_id = ASIAV2XAOBJRRVNBXJL2
aws_secret_access_key = ew0xROrRLYino1QRxs1UXM7iMMIjJUjwnx9E3T
aws_session_token = FwoGZXIvYXdzEJL//////////wEaDIgc/c1Uyie+Bt3GYiK9Af2HbYTytOORZ54uaoi28dLKhyTbQ8vmaSt9JySBxyAG0Yjx6WTr7L1YkW5CwWI0PpxMP7QzuiTBoAJ/54kHgH1H2MtXk15BO+iFScMcz714LU3MvkTa5F1kWWwxPgHHXG69A0nEOu3ECO252RNOQmlbGwNNCaOoC7LUFPETu40LEjeMTgD4RrzV/MP6LqyYRIYZyrGkP3tViAM4TZnEx80Zx+vR3VWF0dogcTa/z3GE8Phyj1gd+RBjItYJmSVMFxDoIzkZtZs4h5OCDnqmzlAGpvmW5wMk1jvytcrvtRWo3tL/H0PbG9
    ```

7. Inspecionar e criar a infraestrutura virtual:

    ```
    $ terraform plan

    Terraform used the selected providers to generate the following execution plan. Resource actions are
    indicated with the following symbols:
      + create

    Terraform will perform the following actions:

      # aws_instance.hello-isntance will be created
      + resource "aws_instance" "hello-isntance" {
          + ami                                  = "ami-0c02fb55956c7d316"
          + arn                                  = (known after apply)
          + associate_public_ip_address          = (known after apply)
          + availability_zone                    = (known after apply)
          + cpu_core_count                       = (known after apply)
          + cpu_threads_per_core                 = (known after apply)
          + disable_api_termination              = (known after apply)
          + ebs_optimized                        = (known after apply)
          + get_password_data                    = false
          + host_id                              = (known after apply)
          + id                                   = (known after apply)
          + instance_initiated_shutdown_behavior = (known after apply)
          + instance_state                       = (known after apply)
          + instance_type                        = "t2.micro"
          + ipv6_address_count                   = (known after apply)
          + ipv6_addresses                       = (known after apply)
          + key_name                             = (known after apply)
          + monitoring                           = (known after apply)
          + outpost_arn                          = (known after apply)
          + password_data                        = (known after apply)
          + placement_group                      = (known after apply)
          + placement_partition_number           = (known after apply)
          + primary_network_interface_id         = (known after apply)
          + private_dns                          = (known after apply)
          + private_ip                           = (known after apply)
          + public_dns                           = (known after apply)
          + public_ip                            = (known after apply)
          + secondary_private_ips                = (known after apply)
          + security_groups                      = (known after apply)
          + source_dest_check                    = true
          + subnet_id                            = (known after apply)
          + tags                                 = {
              + "Name" = "hellow-isntance"
            }
          + tags_all                             = {
              + "Name" = "hellow-isntance"
            }
          + tenancy                              = (known after apply)
          + user_data                            = (known after apply)
          + user_data_base64                     = (known after apply)
          + vpc_security_group_ids               = (known after apply)

          + capacity_reservation_specification {
              + capacity_reservation_preference = (known after apply)

              + capacity_reservation_target {
                  + capacity_reservation_id = (known after apply)
                }
            }

          + ebs_block_device {
              + delete_on_termination = (known after apply)
              + device_name           = (known after apply)
              + encrypted             = (known after apply)
              + iops                  = (known after apply)
              + kms_key_id            = (known after apply)
              + snapshot_id           = (known after apply)
              + tags                  = (known after apply)
              + throughput            = (known after apply)
              + volume_id             = (known after apply)
              + volume_size           = (known after apply)
              + volume_type           = (known after apply)
            }

          + enclave_options {
              + enabled = (known after apply)
            }

          + ephemeral_block_device {
              + device_name  = (known after apply)
              + no_device    = (known after apply)
              + virtual_name = (known after apply)
            }

          + metadata_options {
              + http_endpoint               = (known after apply)
              + http_put_response_hop_limit = (known after apply)
              + http_tokens                 = (known after apply)
              + instance_metadata_tags      = (known after apply)
            }

          + network_interface {
              + delete_on_termination = (known after apply)
              + device_index          = (known after apply)
              + network_interface_id  = (known after apply)
            }

          + root_block_device {
              + delete_on_termination = (known after apply)
              + device_name           = (known after apply)
              + encrypted             = (known after apply)
              + iops                  = (known after apply)
              + kms_key_id            = (known after apply)
              + tags                  = (known after apply)
              + throughput            = (known after apply)
              + volume_id             = (known after apply)
              + volume_size           = (known after apply)
              + volume_type           = (known after apply)
            }
        }

      # aws_internet_gateway.Hello_IGW will be created
      + resource "aws_internet_gateway" "Hello_IGW" {
          + arn      = (known after apply)
          + id       = (known after apply)
          + owner_id = (known after apply)
          + tags     = {
              + "Name" = "Hello IGW"
            }
          + tags_all = {
              + "Name" = "Hello IGW"
            }
          + vpc_id   = (known after apply)
        }

      # aws_route_table.Hello_Public_Route_Table will be created
      + resource "aws_route_table" "Hello_Public_Route_Table" {
          + arn              = (known after apply)
          + id               = (known after apply)
          + owner_id         = (known after apply)
          + propagating_vgws = (known after apply)
          + route            = [
              + {
                  + carrier_gateway_id         = ""
                  + cidr_block                 = "0.0.0.0/0"
                  + destination_prefix_list_id = ""
                  + egress_only_gateway_id     = ""
                  + gateway_id                 = (known after apply)
                  + instance_id                = ""
                  + ipv6_cidr_block            = ""
                  + local_gateway_id           = ""
                  + nat_gateway_id             = ""
                  + network_interface_id       = ""
                  + transit_gateway_id         = ""
                  + vpc_endpoint_id            = ""
                  + vpc_peering_connection_id  = ""
                },
            ]
          + tags             = {
              + "Name" = "Hello Public Route Table"
            }
          + tags_all         = {
              + "Name" = "Hello Public Route Table"
            }
          + vpc_id           = (known after apply)
        }

      # aws_route_table_association.a will be created
      + resource "aws_route_table_association" "a" {
          + id             = (known after apply)
          + route_table_id = (known after apply)
          + subnet_id      = (known after apply)
        }

      # aws_security_group.Hello_Security_Group will be created
      + resource "aws_security_group" "Hello_Security_Group" {
          + arn                    = (known after apply)
          + description            = "Hello Security Group"
          + egress                 = [
              + {
                  + cidr_blocks      = [
                      + "0.0.0.0/0",
                    ]
                  + description      = "All to All"
                  + from_port        = 0
                  + ipv6_cidr_blocks = []
                  + prefix_list_ids  = []
                  + protocol         = "-1"
                  + security_groups  = []
                  + self             = false
                  + to_port          = 0
                },
            ]
          + id                     = (known after apply)
          + ingress                = [
              + {
                  + cidr_blocks      = [
                      + "0.0.0.0/0",
                    ]
                  + description      = "TCP/22 from All"
                  + from_port        = 22
                  + ipv6_cidr_blocks = []
                  + prefix_list_ids  = []
                  + protocol         = "tcp"
                  + security_groups  = []
                  + self             = false
                  + to_port          = 22
                },
              + {
                  + cidr_blocks      = [
                      + "0.0.0.0/0",
                    ]
                  + description      = "TCP/80 from All"
                  + from_port        = 80
                  + ipv6_cidr_blocks = []
                  + prefix_list_ids  = []
                  + protocol         = "tcp"
                  + security_groups  = []
                  + self             = false
                  + to_port          = 80
                },
              + {
                  + cidr_blocks      = [
                      + "10.0.0.0/16",
                    ]
                  + description      = "All from 10.0.0.0/16"
                  + from_port        = 0
                  + ipv6_cidr_blocks = []
                  + prefix_list_ids  = []
                  + protocol         = "-1"
                  + security_groups  = []
                  + self             = false
                  + to_port          = 0
                },
            ]
          + name                   = "Hello_Security_Group"
          + name_prefix            = (known after apply)
          + owner_id               = (known after apply)
          + revoke_rules_on_delete = false
          + tags                   = {
              + "Name" = "Work Security Group"
            }
          + tags_all               = {
              + "Name" = "Work Security Group"
            }
          + vpc_id                 = (known after apply)
        }

      # aws_subnet.Hello_Public_Subnet will be created
      + resource "aws_subnet" "Hello_Public_Subnet" {
          + arn                                            = (known after apply)
          + assign_ipv6_address_on_creation                = false
          + availability_zone                              = "us-east-1a"
          + availability_zone_id                           = (known after apply)
          + cidr_block                                     = "10.0.0.0/24"
          + enable_dns64                                   = false
          + enable_resource_name_dns_a_record_on_launch    = false
          + enable_resource_name_dns_aaaa_record_on_launch = false
          + id                                             = (known after apply)
          + ipv6_cidr_block_association_id                 = (known after apply)
          + ipv6_native                                    = false
          + map_public_ip_on_launch                        = true
          + owner_id                                       = (known after apply)
          + private_dns_hostname_type_on_launch            = (known after apply)
          + tags                                           = {
              + "Name" = "Hello Public Subnet"
            }
          + tags_all                                       = {
              + "Name" = "Hello Public Subnet"
            }
          + vpc_id                                         = (known after apply)
        }

      # aws_vpc.Hello_VPC will be created
      + resource "aws_vpc" "Hello_VPC" {
          + arn                                  = (known after apply)
          + cidr_block                           = "10.0.0.0/16"
          + default_network_acl_id               = (known after apply)
          + default_route_table_id               = (known after apply)
          + default_security_group_id            = (known after apply)
          + dhcp_options_id                      = (known after apply)
          + enable_classiclink                   = (known after apply)
          + enable_classiclink_dns_support       = (known after apply)
          + enable_dns_hostnames                 = true
          + enable_dns_support                   = true
          + id                                   = (known after apply)
          + instance_tenancy                     = "default"
          + ipv6_association_id                  = (known after apply)
          + ipv6_cidr_block                      = (known after apply)
          + ipv6_cidr_block_network_border_group = (known after apply)
          + main_route_table_id                  = (known after apply)
          + owner_id                             = (known after apply)

    kleds@basbor911 MINGW64 ~/github/iac/hello (master)
    $ terraform plan

    Terraform used the selected providers to generate the following execution plan. Resource actions are
    indicated with the following symbols:
      + create

    Terraform will perform the following actions:

      # aws_instance.hello-isntance will be created
      + resource "aws_instance" "hello-isntance" {
          + ami                                  = "ami-0c02fb55956c7d316"
          + arn                                  = (known after apply)
          + associate_public_ip_address          = (known after apply)
          + availability_zone                    = (known after apply)
          + cpu_core_count                       = (known after apply)
          + cpu_threads_per_core                 = (known after apply)
          + disable_api_termination              = (known after apply)
          + ebs_optimized                        = (known after apply)
          + get_password_data                    = false
          + host_id                              = (known after apply)
          + id                                   = (known after apply)
          + instance_initiated_shutdown_behavior = (known after apply)
          + instance_state                       = (known after apply)
          + instance_type                        = "t2.micro"
          + ipv6_address_count                   = (known after apply)
          + ipv6_addresses                       = (known after apply)
          + key_name                             = (known after apply)
          + monitoring                           = (known after apply)
          + outpost_arn                          = (known after apply)
          + password_data                        = (known after apply)
          + placement_group                      = (known after apply)
          + placement_partition_number           = (known after apply)
          + primary_network_interface_id         = (known after apply)
          + private_dns                          = (known after apply)
          + private_ip                           = (known after apply)
          + public_dns                           = (known after apply)
          + public_ip                            = (known after apply)
          + secondary_private_ips                = (known after apply)
          + security_groups                      = (known after apply)
          + source_dest_check                    = true
          + subnet_id                            = (known after apply)
          + tags                                 = {
              + "Name" = "hellow-isntance"
            }
          + tags_all                             = {
              + "Name" = "hellow-isntance"
            }
          + tenancy                              = (known after apply)
          + user_data                            = (known after apply)
          + user_data_base64                     = (known after apply)
          + vpc_security_group_ids               = (known after apply)

          + capacity_reservation_specification {
              + capacity_reservation_preference = (known after apply)

              + capacity_reservation_target {
                  + capacity_reservation_id = (known after apply)
                }
            }

          + ebs_block_device {
              + delete_on_termination = (known after apply)
              + device_name           = (known after apply)
              + encrypted             = (known after apply)
              + iops                  = (known after apply)
              + kms_key_id            = (known after apply)
              + snapshot_id           = (known after apply)
              + tags                  = (known after apply)
              + throughput            = (known after apply)
              + volume_id             = (known after apply)
              + volume_size           = (known after apply)
              + volume_type           = (known after apply)
            }

          + enclave_options {
              + enabled = (known after apply)
            }

          + ephemeral_block_device {
              + device_name  = (known after apply)
              + no_device    = (known after apply)
              + virtual_name = (known after apply)
            }

          + metadata_options {
              + http_endpoint               = (known after apply)
              + http_put_response_hop_limit = (known after apply)
              + http_tokens                 = (known after apply)
              + instance_metadata_tags      = (known after apply)
            }

          + network_interface {
              + delete_on_termination = (known after apply)
              + device_index          = (known after apply)
              + network_interface_id  = (known after apply)
            }

          + root_block_device {
              + delete_on_termination = (known after apply)
              + device_name           = (known after apply)
              + encrypted             = (known after apply)
              + iops                  = (known after apply)
              + kms_key_id            = (known after apply)
              + tags                  = (known after apply)
              + throughput            = (known after apply)
              + volume_id             = (known after apply)
              + volume_size           = (known after apply)
              + volume_type           = (known after apply)
            }
        }

      # aws_internet_gateway.Hello_IGW will be created
      + resource "aws_internet_gateway" "Hello_IGW" {
          + arn      = (known after apply)
          + id       = (known after apply)
          + owner_id = (known after apply)
          + tags     = {
              + "Name" = "Hello IGW"
            }
          + tags_all = {
              + "Name" = "Hello IGW"
            }
          + vpc_id   = (known after apply)
        }

      # aws_route_table.Hello_Public_Route_Table will be created
      + resource "aws_route_table" "Hello_Public_Route_Table" {
          + arn              = (known after apply)
          + id               = (known after apply)
          + owner_id         = (known after apply)
          + propagating_vgws = (known after apply)
          + route            = [
              + {
                  + carrier_gateway_id         = ""
                  + cidr_block                 = "0.0.0.0/0"
                  + destination_prefix_list_id = ""
                  + egress_only_gateway_id     = ""
                  + gateway_id                 = (known after apply)
                  + instance_id                = ""
                  + ipv6_cidr_block            = ""
                  + local_gateway_id           = ""
                  + nat_gateway_id             = ""
                  + network_interface_id       = ""
                  + transit_gateway_id         = ""
                  + vpc_endpoint_id            = ""
                  + vpc_peering_connection_id  = ""
                },
            ]
          + tags             = {
              + "Name" = "Hello Public Route Table"
            }
          + tags_all         = {
              + "Name" = "Hello Public Route Table"
            }
          + vpc_id           = (known after apply)
        }

      # aws_route_table_association.a will be created
      + resource "aws_route_table_association" "a" {
          + id             = (known after apply)
          + route_table_id = (known after apply)
          + subnet_id      = (known after apply)
        }

      # aws_security_group.Hello_Security_Group will be created
      + resource "aws_security_group" "Hello_Security_Group" {
          + arn                    = (known after apply)
          + description            = "Hello Security Group"
          + egress                 = [
              + {
                  + cidr_blocks      = [
                      + "0.0.0.0/0",
                    ]
                  + description      = "All to All"
                  + from_port        = 0
                  + ipv6_cidr_blocks = []
                  + prefix_list_ids  = []
                  + protocol         = "-1"
                  + security_groups  = []
                  + self             = false
                  + to_port          = 0
                },
            ]
          + id                     = (known after apply)
          + ingress                = [
              + {
                  + cidr_blocks      = [
                      + "0.0.0.0/0",
                    ]
                  + description      = "TCP/22 from All"
                  + from_port        = 22
                  + ipv6_cidr_blocks = []
                  + prefix_list_ids  = []
                  + protocol         = "tcp"
                  + security_groups  = []
                  + self             = false
                  + to_port          = 22
                },
              + {
                  + cidr_blocks      = [
                      + "0.0.0.0/0",
                    ]
                  + description      = "TCP/80 from All"
                  + from_port        = 80
                  + ipv6_cidr_blocks = []
                  + prefix_list_ids  = []
                  + protocol         = "tcp"
                  + security_groups  = []
                  + self             = false
                  + to_port          = 80
                },
              + {
                  + cidr_blocks      = [
                      + "10.0.0.0/16",
                    ]
                  + description      = "All from 10.0.0.0/16"
                  + from_port        = 0
                  + ipv6_cidr_blocks = []
                  + prefix_list_ids  = []
                  + protocol         = "-1"
                  + security_groups  = []
                  + self             = false
                  + to_port          = 0
                },
            ]
          + name                   = "Hello_Security_Group"
          + name_prefix            = (known after apply)
          + owner_id               = (known after apply)
          + revoke_rules_on_delete = false
          + tags                   = {
              + "Name" = "Work Security Group"
            }
          + tags_all               = {
              + "Name" = "Work Security Group"
            }
          + vpc_id                 = (known after apply)
        }

      # aws_subnet.Hello_Public_Subnet will be created
      + resource "aws_subnet" "Hello_Public_Subnet" {
          + arn                                            = (known after apply)
          + assign_ipv6_address_on_creation                = false
          + availability_zone                              = "us-east-1a"
          + availability_zone_id                           = (known after apply)
          + cidr_block                                     = "10.0.0.0/24"
          + enable_dns64                                   = false
          + enable_resource_name_dns_a_record_on_launch    = false
          + enable_resource_name_dns_aaaa_record_on_launch = false
          + id                                             = (known after apply)
          + ipv6_cidr_block_association_id                 = (known after apply)
          + ipv6_native                                    = false
          + map_public_ip_on_launch                        = true
          + owner_id                                       = (known after apply)
          + private_dns_hostname_type_on_launch            = (known after apply)
          + tags                                           = {
              + "Name" = "Hello Public Subnet"
            }
          + tags_all                                       = {
              + "Name" = "Hello Public Subnet"
            }
          + vpc_id                                         = (known after apply)
        }

      # aws_vpc.Hello_VPC will be created
      + resource "aws_vpc" "Hello_VPC" {
          + arn                                  = (known after apply)
          + cidr_block                           = "10.0.0.0/16"
          + default_network_acl_id               = (known after apply)
          + default_route_table_id               = (known after apply)
          + default_security_group_id            = (known after apply)
          + dhcp_options_id                      = (known after apply)
          + enable_classiclink                   = (known after apply)
          + enable_classiclink_dns_support       = (known after apply)
          + ipv6_cidr_block_network_border_group = (known after apply)
          + main_route_table_id                  = (known after apply)
          + owner_id                             = (known after apply)
          + tags                                 = {
              + "Name" = "Hello VPC"
            }
          + tags_all                             = {
              + "Name" = "Hello VPC"
            }
        }

    Plan: 7 to add, 0 to change, 0 to destroy.

    ────────────────────────────────────────────────────────────────────────────────────────────────────────── 

    Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these 
    actions if you run "terraform apply" now.    
    ```
    
7. Validar a criação dos recursos pela AWS Console.


## Clean-up

1. Deletar o plano:

    ```
    $ terraform destroy
    Terraform used the selected providers to generate the following execution plan. Resource actions are
    indicated with the following symbols:
      - destroy
      ...
    ```

