# Terraform Basic Tutorial

[Terraform](https://www.terraform.io/) is piece of server provisioning software. It allows you to write and plan your server infrastructure in code, and then create/modify it in one or a few small operations; depending on how you wish to create your infrastructure.

In this tutorial we will use terraform to provision a server instance in [Amazon Lightsail](https://aws.amazon.com/lightsail/), and install a [Node.js](https://nodejs.org/en/) application on it.

If anything does not make sense, the [terraform documentation](https://www.terraform.io/docs/index.html) is very helpful.

## Installation

Install [Homebrew](https://brew.sh/), [Terraform](https://www.terraform.io/) and [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) if you don't have them installed:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install terraform
brew install awscli
```

Download the ssh key for the us-east-1 region from within lightsail and set the appropriate permissions:

1. Log into [Amazon Lightsail](https://lightsail.aws.amazon.com/ls/webapp/home/instances)
2. Goto the Account menu in the top right and click Account
3. Click the SSH keys tab
4. Download the Virginia (us-east-1) key
5. Put the key in a `.keys` folder within your home directory. E.g. `~/.keys`
6. Set the permissions on the key: `chmod 600 ~/.keys/LightsailDefaultPrivateKey-us-east-1.pem`

## Setup

Configure your aws-cli, substituting your aws credentials in place of the angled brackets:

```
$ aws configure --profile <your aws profile name>
AWS Access Key ID [None]: <your access key>
AWS Secret Access Key [None]: <your secret access key>
Default region name [None]: us-east-1
Default output format [None]: json
```

## Tutorial

Create a directory in your preferred location on your machine to write the terraform files and open that directory in your code editor of choice.

### Terraform Modules

Modules are self contained terraform configurations that can be re-used. For instance you could create a terraform module that creates a server, or another module that creates a database.

For this tutorial we are going to make a single module that creates all of our infrastructure.

The standard module structure for terraform consists of three files:

- **main.tf**. This contains the code that creates our resources
- **variables.tf**. This holds any variables that the user can change when running the module.
- **output.tf**. This contains any output parameters we would like other terraform modules to use. E.g. if you create a server in a module and would like a second module to use the IP of the created server, you can output the server's IP so it can be used in the second module.

This is all we will use for this tutorial. If you wish to read more about terraform modules and their structure, you can check the [terraform module documentation](https://www.terraform.io/docs/modules/index.html).

**Create all three of these files in your code directory and leave them blank.**

### 1. Variables

We're going add variables to this file as we go. These variables can be overidden by the user, but we'll set some sensible defaults so that we don't have to enter every variable every time.

Add the following to variables.tf:

```hcl
variable "profile" {
  default = "<your aws profile name>"
}

variable "region" {
  default = "us-east-1"
}
```

### 2. Providers

The first thing we need to do is specify a provider. A provider is responsible for understanding interacting with APIs of various cloud providers and controlling your local machine. We need to use the following provider for this tutorial:

- **[AWS Provider](https://www.terraform.io/docs/providers/aws/index.html)**. This allows us to interact with AWS and manipulate AWS resources.

Add the follow to main.tf:

```hcl
provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

provider "null" {}
```

You'll notice that we're using the two variables we added to variables.tf. This is how you use variables in terraform: you place them inside a string using `${}` and then calling them via `var.<variable>`.

### 3. Terraform State

Terraform is able to make iterative changes to your infrastructure. For instance if you want to change the name of a server, it can do this without having to destroy the existing server or create a new one. For this to be possble, terraform stores a **state file** that keeps track of the resources it has created.

When you want to update your infrastructure, terraform compares its' state file against the live infrastrure to make sure its' state is up to date. Following this it compares the changes you wish to make against its' updated state file to determine what parts of the live infrastructure need to be modified.

This state file can be stored locally or remotely. Generally storing the state in an S3 bucket is a good solution so that everyone on the team has access to the same terraform state. However for this tutorial we are simply going to store the state locally in your tutorial directory, called **terraform.tfstate**. This is the default place terraform stores its' state, so we don't need to configure anything for this.

### 4. Server

#### Instance Specification

We're almost ready to create our first server. Before we do, let's create a few more variables to use when making our server.

Add the following to variables.tf, changing `<your first name>` for your first name:

```hcl
variable "name" {
  default = "<your first name>-terraform-tutorial"
}

# Server operating system image
variable "aws_instance_image" {
  default = "ubuntu_16_04_1"
}

# Size of the server we want to make
variable "aws_instance_model" {
  default = "micro_1_0"
}
```

Now we can specify our server. Any component created by terraform is called a [resource](https://www.terraform.io/docs/configuration/resources.html). We're going to use the `aws_lightsail_instance` resource to create a lightsail instance (a server).

Add the following to main.tf:

```hcl
resource "aws_lightsail_instance" "app" {
  name              = "${var.name}"
  availability_zone = "${var.region}b"
  blueprint_id      = "${var.aws_instance_image}"
  bundle_id         = "${var.aws_instance_model}"
}
```

As you can see we have used variables to specify the parameters for the resource.

- We've given the server a **name** within terraform called `app`.
- We've given it a **lightsail name** so we can identify it in the AWS Web Console
- We've specified in which **availabliity zone** we want to it be placed (each aws region has a number of availability zones from. us-east-1 has from a-e)
- We've specified the **image blueprint** we want to be installed on it
- We've specified the **instance model (bundle)** we want to use.

One last thing before we test out our server is to create an output variable so we can easily grab the public IP address of our server so that we can visit it in the browser at the end.

Add the following to outputs.tf:

```hcl
output "server_ip" {
  value = "${aws_lightsail_instance.app.public_ip_address}"
}
```

As you can see, we are grabbing the `public_ip_address` output value of the `aws_lightsail_instance` resource and outputting it from our module. Because our module is the root module, the outputs will appear in our terminal after applying our terraform plan.

#### Instance Creation

Now that we've written the basic code we need to create a bare bones server, we can try it out! First we're going to do a test run using `terraform plan`.

Run following in your terminal:

```bash
# Set the active aws profile so that the server is created in your aws account
export AWS_PROFILE=<your aws profile name>
export TF_VAR_profile=$AWS_PROFILE

# First we need to initialize the providers we specified in step 1
terraform init

# Plan the create of our servers
terraform plan
```

This will output a plan of what terraform intends to create. It tells you exactly what it is going to do. If the plan looks good then we can run the follow to create the server. Type 'yes' exactly into the prompt when prompted to do so.

```bash
terraform apply
```

If you now visit the [Amazon Lightsail Web Console](https://lightsail.aws.amazon.com/ls/webapp/home/instances) you should be able to see your instance.

### 5. Provisioning

#### Connection

Now that we have the server created, we need to provision it, copy an application and start said application. To do this, we're going to use terraform [provisioners](https://www.terraform.io/docs/provisioners/index.html). These can be inserted into particular resources and used to perform additional procedures on those resources after they've been created. We're going to create a provider that copies our application to the server, and then another provider that starts the application.

So that we our provisioners can connect to the server we just created, we need to add a [connection](https://www.terraform.io/docs/provisioners/connection.html) block. For this we're going to add two new variables to variables.tf that specify:

- the ssh-key for the provisioner to use
- the user to log into the server as

Add the following to your variables.tf file:

```hcl
variable "pvt_key" {
  default = "~/.keys/LightsailDefaultPrivateKey-us-east-1.pem"
}

variable "ssh_user" {
  default = "ubuntu"
}
```

Then add the following within the `aws_lightsail_instance` resource block at the bottom. Note that telling the connect to connect to the server its' embedded within, and we're using the [file](https://www.terraform.io/docs/configuration/interpolation.html#file-path-) interpolation function to load the contents of our private key, into the private key property:

```hcl
resource "aws_lightsail_instance" "app" {
  # ...

  connection {
    host        = "${self.public_ip_address}"
    user        = "${var.ssh_user}"
    private_key = "${file(var.pvt_key)}"
  }
}
```

#### Creating App

We're going to write a basic hello world nodejs application. Simply create a file called hello.js and put the following in it:

```javascript
// hello.js
var http = require('http');
http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World\n');
}).listen(8080);
console.log('Server running at http://localhost:8080/');
```

This application starts a basic http server and when visiting it, displays 'Hello World' to the user.

#### Copying App

Next we're going to copy the application onto the newly created server. To do so, add the a [file](https://www.terraform.io/docs/provisioners/file.html) provisioner within the `aws_lightsail_instance` resource block at the bottom:

```hcl
resource "aws_lightsail_instance" "app" {
  # ...

  # Copies all files and folders in apps/app1 to D:/IIS/webapp1
  provisioner "file" {
    source      = "hello.js"
    destination = "~/hello.js"
  }
}
```

#### Provisioning the Server and Starting the App

The next step is to provision the server with the software we need and start the application. We'll use the [remote-exec](https://www.terraform.io/docs/provisioners/remote-exec.html) provisioner to execute a script on the server once its up and running. We'll use [heredoc](https://en.wikipedia.org/wiki/Here_document) syntax so that we can write the script inline. However you could also specify it in an external file using the [file function](https://www.terraform.io/docs/configuration/interpolation.html#file-path-).

We're going to use [NVM](https://github.com/creationix/nvm) to install nodejs and [PM2](https://github.com/Unitech/pm2) to start the app. PM2 is a node process manager that will make sure the node app restarts in the event that it errors and crashes. We're also going to have pm2 add the application as an item to be run on startup, so that if the server crashes and restarts, the node app will start up automatically when the server comes back up.

Add the following remote_exec provisioner below the file provisioner within the `aws_lightsail_instance` resource block:

```hcl
resource "aws_lightsail_instance" "app" {
  # ...

  provisioner "remote-exec" {
    inline = [
      <<EOF
      # Install NVM
      curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

      # Make NVM available in the current shell
      export NVM_DIR="$HOME/.nvm"
      \. "$NVM_DIR/nvm.sh"

      # Install latest long term support release of node, npm and pm2
      nvm install --lts
      npm install -g npm
      npm install -g pm2
      chown ubuntu.ubuntu -R ~/.config

      pm2 start hello.js
      pm2 startup | tail -1 | \. /dev/stdin
      pm2 save
      EOF
      ,
    ]
  }
}
```

#### Opening Ports

The last step we have to do is open the necessary ports to view the application. Because the app runs on port 8080, we'll need to open that port to view it in our browser.

We can use a [local-exec](https://www.terraform.io/docs/provisioners/local-exec.html) provisioner to run the aws-cli we have installed on our local machine to open the necessary ports on our instance. We'll open the standard http and https ports (80 and 443), and port 8080.

Add the following local-exec provisioner below the file provisioner within the `aws_lightsail_instance` resource block:

```hcl
resource "aws_lightsail_instance" "app" {
  # ...

  provisioner "local-exec" {
    command = <<EOF
      aws lightsail open-instance-public-ports --instance-name ${self.name} --port-info fromPort=8080,toPort=8080,protocol=tcp --region ${var.region}  \
      && aws lightsail open-instance-public-ports --instance-name ${self.name} --port-info fromPort=80,toPort=80,protocol=tcp --region ${var.region} \
      && aws lightsail open-instance-public-ports --instance-name ${self.name} --port-info fromPort=443,toPort=443,protocol=tcp --region ${var.region}
      EOF

    environment {
      AWS_PROFILE = "${var.profile}"
      AWS_REGION  = "${var.region}"
    }
  }
}
```

This should be all we need to run the node app! Run `terraform apply` again to make the changes. You'll see that terraform will tell you that changing the lightsail resource as we have requires a new instance. It will destroy our old instance and create a new instance.

Once complete visit the IP address that was output in your terminal in your browser on port 8080, and you should be able to see the site!

### 6. Server Takedown

Once we're finished with our server we can bring it down. Running the following in your terminal we can destroy the server:

```bash
# Set the active aws profile so that the server is created in your aws account
export AWS_PROFILE=<your aws profile name>
export TF_VAR_profile=$AWS_PROFILE

terraform destroy
```

Type 'yes' at the prompt and terraform will bring down your server!

*Note: On destroy you may receive an error caused by the outputs.tf variables. This is cause by a terraform [issue](https://github.com/hashicorp/terraform/issues/522) but it does not affect the destruction process and can be ignored.*

## Next Steps

This is only scratching the very surface of what terraform can do. Terraform can create entire VPC networks, it can change DNS settings in Route53, and it can also work with lots of other cloud providers such as Google Cloud Platform and Digital Ocean. Perhaps expand out from lightsail and move into EC2. It's a bit jump but it's great knowledge to have. Good luck!

Remember: Always use terraform to modify infrastructure created with terraform. **DO NOT CHANGE INFRASTRUCTURE CREATED WITH TERRAFORM IN ONLINE WEB CONSOLES.**