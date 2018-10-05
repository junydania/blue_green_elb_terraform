variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "public_key_path" {
  description = "Path to the SSH public key to be used for authentication. Ensure this keypair is added to your local SSH agent so provisioners can connect. Example: ~/.ssh/terraform.pub"
}
