module "k3s" {
  source  = "xunleii/k3s/module"

  depends_on_    = hcloud_server.agents
  k3s_version    = "stable"
  cluster_domain = "grapes.technat.dev"
  cidr = {
    pods     = "10.123.0.0/16"
    services = "10.111.0.0/16"
  }
  drain_timeout  = "30s"
  managed_fields = ["label", "taint"] // ignore annotations

  k3s_install_env_vars = {}
  global_flags = [
    "--kubelet-arg cloud-provider=external", // required to use https://github.com/hetznercloud/hcloud-cloud-controller-manager
    "--secrets-encryption=true"
  ]

  servers = {
    for i in range(length(hcloud_server.control_planes)) :
    hcloud_server.control_planes[i].name => {
      ip = hcloud_server.control_planes[i].ipv4_address
      connection = {
        host        = hcloud_server.control_planes[i].ipv4_address
        private_key = trimspace(tls_private_key.ed25519-provisioning.private_key_pem)
      }
      flags       = ["--disable-cloud-controller"]
      annotations = { "server_id" : i } // theses annotations will not be managed by this module
    }
  }

  agents = {
    for i in range(length(hcloud_server.agents)) :
    "${hcloud_server.agents[i].name}_node" => {
      name = hcloud_server.agents[i].name
      ip   = hcloud_server.agents[i].ipv4_address
      connection = {
        host        = hcloud_server.agents[i].ipv4_address
        private_key = trimspace(tls_private_key.ed25519-provisioning.private_key_pem)
      }

    }
  }
}