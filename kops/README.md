# kambly

![status-draft](https://img.shields.io/badge/Status-Draft-orange)

kOps managed K8s cluster on Infomaniak openstack

## Current Status

- [ ] [Automated Setup](https://kops.sigs.k8s.io/continuous_integration/)

## Preparation

1. Create an openstack project
2. Create a user for the openstack project (if not done at project creation)
3. Create a pair of application credentials (use unrestricted mode)
4. Create a swift container for state store
5. Export the following environment variables:
  ```bash
  export OS_AUTH_TYPE=v3applicationcredential
  export OS_AUTH_URL=https://api.pub1.infomaniak.cloud/identity
  export OS_IDENTITY_API_VERSION=3
  export OS_REGION_NAME="dc3-a"
  export OS_INTERFACE=public
  export OS_APPLICATION_CREDENTIAL_ID=<id>
  export OS_APPLICATION_CREDENTIAL_SECRET=<secret>
  export KOPS_STATE_STORE=swift://kops-state-store
  ```

## Initial creation

Either specify all flags:

```bash
kops create cluster \
  --cloud=openstack \
  --name kambly.k8s.local \
  --zones 'dc3-a-04,dc3-a-10,dc3-a-09' \
  --network-cidr 10.123.0.0/16 \
  --image 'Ubuntu 22.04 LTS Jammy Jellyfish' \
  --master-count=1 \
  --node-count=1 \
  --node-size a2-ram4-disk20-perf1 \
  --master-size a2-ram4-disk20-perf1 \
  --etcd-storage-type CEPH_1_perf1 \
  --api-loadbalancer-type public \
  --topology private \
  --ssh-public-key ~/.ssh/id_yubikey  \
  --networking cilium \
  --os-ext-net ext-floating1  \
  --os-octavia=true \
  --os-dns-servers='9.9.9.9,149.112.112.112' \
  --yes
```

Or use the file:

```bash
kops create -f kambly.yaml
```
