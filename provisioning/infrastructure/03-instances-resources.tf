# Define Ubuntuserver inside the public subnet
resource "aws_instance" "ubuntu" {
   ami  = "${var.ami_id}"
   instance_type = "${var.instance_type}"
   count = 2
   key_name = "${aws_key_pair.tf-key-pair.id}"

   depends_on = ["aws_vpc.vpc"]
   subnet_id = "${aws_subnet.public-subnet.0.id}"

   depends_on = ["aws_security_group.sg_externo","aws_security_group.sg_interno"]
   vpc_security_group_ids = ["${aws_security_group.sg_externo.id}","${aws_security_group.sg_interno.id}"]

   associate_public_ip_address = true
   # source_dest_check = false
   user_data = "${file("./add-ssh-user.sh")}"

   tags {
    Name = "Ubuntu 1804 - ${var.cliente}"
    Owner = "${var.user}"
  }

# "${element(aws_instance.cluster.*.public_ip, count.index)}"

  provisioner "local-exec" {
    command = <<SCRIPT
echo -e [local]\nlocalhost ansible_connection=local ansible_python_interpreter=python3 become=false gather_facts=false\n > hosts;
echo -e \n[public-ips]\n >> hosts;
echo -e \n[k8s-master]\n >> hosts;
echo -e \n[k8s-workers]\n >> hosts;
echo -e \n[workers:vars]\nK8S_MASTER_NODE_IP=\nK8S_API_SECURE_PORT=6443 >> hosts;
if [ "${count.index}" -eq 0 ];
then sed -i 's/\[k8s-master\]/a ${self.public_ip}/g' hosts;
sed -i 's/K8S_MASTER_NODE_IP=/K8S_MASTER_NODE_IP=${self.private_ip}/g' hosts;
else sed -i 's/\[k8s-workers\]/a ${self.public_ip}/g' hosts; fi;
sed -i 's/\[public-ips\]/a ${self.public_ip}/g' hosts;
SCRIPT
  }

  # lifecycle {
    # prevent_destroy = true
  # }
}
