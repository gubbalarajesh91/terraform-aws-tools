module "jenkins" {
    source = "terraform-aws-modules/ec2-instance/aws"
    name = "jenkins-tf"
    instance_type = "t3.small"
    vpc_security_group_ids = ["sg-0b2fc2c3bbd8e8c3a"]
    subnet_id = "subnet-05c3ef0bbeeec1cc2"
    ami = data.aws_ami.ami_info.id
    user_data = file("jenkins.sh")
    tags = {
        Name = "jenkins-tf"
    }
  
}

module "Jenkins_agent" {
    source = "terraform-aws-modules/ec2-instance/aws"
    name = "jenkins-agent"
    instance_type = "t3.small"
    vpc_security_group_ids = ["sg-0b2fc2c3bbd8e8c3a"]
    subnet_id = "subnet-05c3ef0bbeeec1cc2"
    ami = data.aws_ami.ami_info.id
    user_data = file("jenkins-agent.sh")
    tags = {
        Name = "jenkins-agent"
    }
  
}

resource "aws_key_pair" "nexus" {
  key_name = "nexus"
  public_key = file("~/.ssh/nexus.pub")
  # ~ means windows home dir
  #ssh-keygen -f nexus
  #public_key = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE1PlSAYSHlTCb9aFjjNUFC9qUfaLq6+a3OlDcYG1Zw6 User@RajeshGubbala
  
}

module "nexus" {
    source = "terraform-aws-modules/ec2-instance/aws"
    name = "nexus"
    instance_type = "t3.medium"
    vpc_security_group_ids = ["sg-0b2fc2c3bbd8e8c3a"]
    subnet_id = "subnet-05c3ef0bbeeec1cc2"
    key_name = aws_key_pair.nexus.key_name ## attach key name
    ami = data.aws_ami.nexus_ami_info.id
    tags = {
        Name = "nexus"
    }
  
}



module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.Jenkins_agent.private_ip
      ]
    },
    {
      name    = "nexus"
      type    = "A"
      ttl     = 1
      records = [
        module.nexus.private_ip
      ]
    }
  ]
}