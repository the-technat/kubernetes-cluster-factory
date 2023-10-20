resource "hcloud_server" "control_planes" {
  count = 1
  name  = "grapes-control-plane-${count.index}"

  image       = "ubuntu-22.04"
  server_type = "cx11"

  ssh_keys = [hcloud_ssh_key.default.id, hcloud_ssh_key.yubikey.id]
  labels = {
    provisioner = "terraform",
    node_type   = "control-plane"
  }
}

resource "hcloud_server" "agents" {
  count = 1
  name  = "grapes-agent-${count.index}"

  image       = "ubuntu-22.04"
  server_type = "cx11"

  ssh_keys = [hcloud_ssh_key.default.id, hcloud_ssh_key.yubikey.id]
  labels = {
    provisioner = "terraform",
    node_type   = "agent",
  }

  depends_on = [ hcloud_server.control_planes ]
}

resource "tls_private_key" "ed25519-provisioning" {
  algorithm = "ED25519"
}

resource "hcloud_ssh_key" "default" {
  name       = "K3S terraform module - Provisionning SSH key"
  public_key = trimspace(tls_private_key.ed25519-provisioning.public_key_openssh)
}

resource "hcloud_ssh_key" "yubikey" {
    name = "yubikey"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJov21J2pGxwKIhTNPHjEkDy90U8VJBMiAodc2svmnFC"
}