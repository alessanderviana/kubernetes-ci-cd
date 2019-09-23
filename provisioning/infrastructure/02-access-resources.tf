# Define SSH key pair for our instances
resource "aws_key_pair" "tf-key-pair" {
  key_name = "key-pair-${var.cliente}"
  public_key = "${file("${var.ssh_key}")}"
}

resource "aws_iam_user" "tf-iam-user" {
  name = "${substr("${var.cliente}", 0, 10)}"
  path = "/"
}

resource "aws_iam_user_ssh_key" "tf-key-user" {
  username   = "${aws_iam_user.tf-iam-user.name}"
  encoding   = "SSH"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHdy8fTUvaQ0sTsVZbrcirh3z0wcv9caobd4o7ief2RUSWRwBvfFkRvrvo7bYKswceSCzJJuuvklClEBfmlZg+YxPnK5gfX8Y+t43gSevpzdnuicN6bwoZScS8J0wOZ3e6wBZ3wpPMPfmI/iJFprmxRM3umhZ8U/9XpbhGZkK5WwMEqQi6yQiP0owq8UVoEOyfg5wquRPL4iQhoYLjQCW9fDXvX4IqkBn+5PCE+dxUng1vTIOgVmVd6HNrub9R15fJ7eBXHpzC9ydABSuo+Ie5aSgQ49FfVecQNDDCasZskp+srL5Yb/SuVBvOlUzih/1TgA0s5tbqTBYfLOx4DNeb"
}
