/**
* # tf-vault-aws-temp-creds-iam
* 
* The purpose of this module is to create a vault policy that allows principle in a vault namespace to generate temporary credentials to aws roles using an aws secrets engine role.
* 
* ## Usage
* 
* See [referencing a GitLab terraform module registry module](https://docs.gitlab.com/ee/user/packages/terraform_module_registry/#reference-a-terraform-module).
* 
* ```tf
* module "aws_temp_creds_iam_infra_provisioner_read_write" {
*     source = "gitlab.example.com/engineering/tf-vault-aws-temp-creds-iam/vault"
*     version = "1.0.0"
* 
*     aws_secret_backend_path      = "aws"
*     aws_role_arn                 = var.aws_infra_provisioner_read_write_role_arn
*   
*     attributes = [
*       "infra-provisioner",
*       "read-write"
*     ]
*   
*     context = module.this.context
* }
* 
* module "gitlab_vault_temp_creds_iam_infra_provisioner_read_write" {
*     source = "gitlab.example.com/engineering/tf-vault-gitlab-vault-temp-creds-iam"
*     version = "1.0.0"
* 
*     gitlab_jwt_auth_backend_path = "gitlab_v2"
*     bound_claims_project_id      = var.gitlab_infra_project_id
*     bound_claims_ref_type        = "branch"
*     bound_claims_ref_protected   = var.gitlab_infra_project_ref_protected
*     bound_claims_environment     = var.gitlab_infra_project_environment
*     bound_claims_deployment_tier = var.gitlab_infra_project_deployment_tier
*     policies = [ aws_temp_creds_iam_infra_provisioner_read_write.policy_name ]
* 
*     attributes = [
*       "vault-infra-provisioner",
*       "read-write"
*     ]
* 
*     context = module.this.context
* }
* ```
*/

resource "vault_aws_secret_backend_role" "main" {
  backend         = var.aws_secret_backend_path
  name            = module.this.id
  credential_type = "assumed_role"
  role_arns = [
    var.aws_role_arn
  ]
  default_sts_ttl = 900
  max_sts_ttl     = 900
}

data "vault_policy_document" "main" {
  rule {
    path         = "${var.aws_secret_backend_path}/creds/${vault_aws_secret_backend_role.main.name}"
    capabilities = ["read"]
  }
}

resource "vault_policy" "main" {
  name = "${module.this.id}-allow-generate-temp-aws-credentials"

  policy = data.vault_policy_document.main.hcl
}