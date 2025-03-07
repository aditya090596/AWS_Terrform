resource "awscc_ec2_instance" "ec2_instance" {
  instance_type = var.instance_type
  image_id      = var.ami # Amazon Linux 2 AMI ID
  subnet_id     = var.subnet_id_value

 # iam_instance_profile = "First EC2 Instance"

  security_group_ids = var.security_group_id


  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 8
        volume_type           = "gp2"
        delete_on_termination = true
      }
    }
  ]
}