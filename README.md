# Terraform CI/CD Pipeline on Azure DevOps

An Azure DevOps YAML pipeline that validates, security-scans, plans and applies Terraform infrastructure on Azure. Security and quality checks run before every plan, and `terraform apply` is gated behind a manual approval on the `main` branch.

## Pipeline Overview

```
InitAndValidation
        │
        ├── SonarQube (code quality)
        ├── Trivy     (IaC misconfiguration scan)
        ├── Gitleaks  (secret detection)
        ├── TFLint    (linting)
        └── Checkov   (policy-as-code scan)
                │
              Plan
                │
        Manual Approval   (main only)
                │
        Terraform Apply   (main only)
```

## Stages

| Stage | Tool | Purpose |
|-------|------|---------|
| **InitAndValidation** | Terraform | Installs Terraform, runs `init` against the remote backend and `validate` |
| **SonarQube** | SonarQube | Static code quality analysis, with results published back to the SonarQube server |
| **Trivy** | Trivy | `trivy config` scan; fails the job on `HIGH` / `CRITICAL` findings |
| **Gitleaks** | Gitleaks | Scans the working directory for hard-coded secrets |
| **TFLint** | TFLint | Recursive linting of Terraform code |
| **Checkov** | Checkov | Terraform policy scan (with a documented skip list for accepted checks) |
| **Plan** | Terraform | Runs `init` and `plan` after all scans complete |
| **ManualApproval** | `ManualValidation@1` | Pauses the pipeline for a reviewer to approve the plan; rejects on timeout |
| **TerraformApply** | Terraform | Runs `init` and `apply` once approved |

## Triggers

The pipeline runs on pushes to:

- `main`
- `feature/*`

`ManualApproval` and `TerraformApply` run **only on `main`**. Feature branches stop after the `Plan` stage.

## Runtime Parameters

Every stage can be toggled when queuing a run manually:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `runInitAndValidation` | `true` | Run Terraform init and validate |
| `runSonarQube` | `true` | Run SonarQube analysis |
| `runTrivy` | `true` | Run Trivy scan |
| `runGitleaks` | `true` | Run Gitleaks scan |
| `runTflint` | `true` | Run TFLint |
| `runCheckov` | `true` | Run Checkov scan |
| `runPlan` | `true` | Run Terraform plan |
| `runManualApproval` | `true` | Require manual approval before apply |

## Pipeline Variables

| Variable | Description |
|----------|-------------|
| `terraformWorkingDir` | Folder containing the Terraform code |
| `azureServiceConnection` | Azure DevOps service connection used for authentication |
| `backendResourceGroup` | Resource group of the remote state storage account |
| `backendStorageAccount` | Storage account holding the Terraform state |
| `backendContainer` | Blob container for the state file |
| `backendKey` | State file name (blob key) |

## Prerequisites

**Azure DevOps**
- A self-hosted agent pool named `DevOps-pipeline`
- An Azure Resource Manager service connection (referenced by `azureServiceConnection`)
- A SonarQube service connection (used by the `SonarQubePrepare` task)
- Extensions installed from the Marketplace:
  - [Terraform](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)
  - [SonarQube](https://marketplace.visualstudio.com/items?itemName=SonarSource.sonarqube)

**Azure**
- A storage account and container for the remote Terraform state
- The service principal behind the service connection needs access to both the state storage account and the target subscription

**Agent tooling**
- PowerShell
- Chocolatey (Trivy is installed with `choco install trivy`)
- `gitleaks`, `tflint`, and `checkov` available on the agent `PATH`

## Setup

1. Clone this repository and place the Terraform code in the folder referenced by `terraformWorkingDir`.
2. Replace the placeholder values in the `variables` section (backend resource group, storage account, container, key).
3. Create the Azure and SonarQube service connections in **Project Settings → Service connections**.
4. In Azure DevOps, go to **Pipelines → New pipeline**, choose this repository, and select the existing YAML file.
5. Update the `notifyUsers` field in the `ManualApproval` stage with the reviewer's email address.
6. Run the pipeline.

## Security Notes

- No secrets are stored in the YAML; authentication uses the Azure service connection.
- Gitleaks and Trivy provide secret and misconfiguration detection before any plan or apply.
- Checkov skips a specific list of check IDs. Review that list periodically and remove skips that are no longer justified.
- Apply requires explicit human approval and is restricted to `main`.

## Repository Structure

```
.
├── azure-pipelines.yml   # Pipeline definition
├── <terraform code>/     # Terraform configuration (terraformWorkingDir)
└── README.md
```

## Contributing

1. Create a branch from `main` named `feature/<short-description>`.
2. Push your changes; the pipeline runs validation, scans and plan.
3. Open a pull request to `main` after the checks pass.
4. After merge, review the plan and approve the manual validation to apply.
