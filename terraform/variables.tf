variable "public_key_path" {
  type        = "string"
  description = <<EOF
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can connect.
Default: ~/.ssh/id_rsa.pub
EOF
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  type        = "string"
  description = <<EOF
Path to the SSH private key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can connect.
Default: ~/.ssh/id_rsa
EOF
  default     = "~/.ssh/id_rsa"
}
