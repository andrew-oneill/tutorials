provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

resource "aws_lightsail_instance" "app" {
  name              = "${var.name}"
  availability_zone = "${var.region}b"
  blueprint_id      = "${var.aws_instance_image}"
  bundle_id         = "${var.aws_instance_model}"

  connection {
    host        = "${self.public_ip_address}"
    user        = "${var.ssh_user}"
    private_key = "${file(var.pvt_key)}"
  }

  provisioner "file" {
    source      = "hello.js"
    destination = "~/hello.js"
  }

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
