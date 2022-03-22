# Terraform Hello World

## AWS Provider

O [Terraform](https://www.terraform.io/) é uma ferramenta para construir, alterar e controlar a infraestrutura de forma segura e eficiente. O Terraform pode gerenciar provedores de serviços existentes e populares como OpenStack, Azure, AWS, Digital Ocean, entre outras, bem como soluções internas personalizadas.

Os arquivos de configuração do Terraform descrevem os componentes necessários para executar um único aplicativo ou todo o *datacenter*, gerando um plano de execução que descreve o que será feito para alcançar o estado desejado e, em seguida, executá-lo para construir a infraestrutura descrita. À medida que a configuração muda, o Terraform é capaz de determinar o que mudou e criar planos de execução incrementais que podem ser aplicados.

A infraestrutura que o Terraform pode gerenciar inclui componentes de baixo nível, como instâncias de computação, armazenamento e redes, bem como componentes de alto nível, como entradas DNS, recursos SaaS, etc.

## Pre-req Terraform

1. Fazer o *download* do Terraform em https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_windows_386.zip
    
2. Descomprimir o arquivo baixado no diretório C:\Windows\System32
   
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

1. Abrir o AWS Academy e iniciar o ambiente SandBox.

2. Capturar as credenciais de acesso da conta SandBox.

    ```
    $ cat ~/.aws/credentials 
    [default]
    aws_access_key_id=ASIAY7VWXB2OOVWYLAGN
    aws_secret_access_key=KBIiKTVfM4weELy/fnyo2whIX1CU1rIzRGAuKrIY
    ```
    
3. Configurar a região correta (ignorar o resto dos campos):

    ```
    $ aws configure
    AWS Access Key ID [****************Q5QG]: 
    AWS Secret Access Key [****************aqWs]: 
    Default region name [None]: us-east-1
    Default output format [None]:
    ```

## Pre-req Visual Studio Code com plugi-in GitHub

1. Abrir o Visual Studio Code e instalar o plug-in GitHub.

2. Baixar o *template*:

    ```
    $ git clone https://github.com/FIAP/iac
    Cloning into 'fiap'...
    remote: Enumerating objects: 10, done.
    remote: Counting objects: 100% (10/10), done.
    remote: Compressing objects: 100% (10/10), done.
    remote: Total 3716 (delta 4), reused 0 (delta 0), pack-reused 3706
    Receiving objects: 100% (3716/3716), 44.63 MiB | 3.88 MiB/s, done.
    Resolving deltas: 100% (1862/1862), done.
    Checking connectivity... done.
    
    $ cd iac/hello/
    ```

3. Conferir o conteúdo do [template](https://github.com/FIAP/iac/blob/master/hello/main.tf):

    ```
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
    ```

4. Inicializar o Terraform e o correspondente *provider* (plugin) de AWS:

    ```
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
    
6. Inspecionar e criar a infraestrutura virtual:

    ```
    $ terraform apply

    Terraform used the selected providers to generate the following execution plan. Resource actions are
    indicated with the following symbols:
      + create

    Terraform will perform the following actions:
    ...
    ```
    
7. Validar a criação da instância pelo AWS Console.

    
## Clean-up

1. Deletar o plano:

    ```
    $ terraform destroy
    Terraform used the selected providers to generate the following execution plan. Resource actions are
    indicated with the following symbols:
      - destroy
      ...
    ```

