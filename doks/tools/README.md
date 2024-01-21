# CI-Setup

For our ansible jobs we use our own [ci-image](https://code.immerda.ch/k8s_at_hetzner/ci-image). It's based on debian bullseye and installs python and pip globally. Ansible is also installed by default, globally.

If we use this image in our CI pipeline and use a venv to cache pip dependencies we need to install ansible again in the venv, and we need to tell ansible to use the python interpreter of the venv.

Therefore ansilbe is installed in the first CI job that has the `.common_ansible` job sourced.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->