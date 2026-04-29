# Azure GitHub Actions Template

A production-ready template for deploying Azure infrastructure using GitHub Actions, Bicep, and Azure Deployment Stacks with OIDC authentication.

## 🚀 Features

- **Infrastructure as Code**: Bicep templates for Azure resources
- **Deployment Stacks**: Azure feature for managing resource lifecycle and deletion
- **GitHub Actions Workflows**: Automated CI/CD for infrastructure
- **OIDC Authentication**: Secure, credential-free authentication to Azure
- **PR What-If**: Preview infrastructure changes before merging
- **Multi-Environment Ready**: Easily extend to staging and production

## 📋 Quick Start

### Prerequisites

- Azure CLI: [Install](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Git and GitHub CLI (optional)
- Azure subscription with Contributor or higher permissions

### 1. Setup Azure Infrastructure

Follow the comprehensive setup guide:

```bash
# See docs/AZURE_SETUP.md for detailed step-by-step instructions
# This includes:
# - Creating a resource group
# - Creating a service principal
# - Setting up OIDC federated credentials
# - Configuring GitHub Secrets
```

**Quick summary**:
```bash
# Set your values
export AZURE_SUBSCRIPTION_ID="your-sub-id"
export AZURE_TENANT_ID="your-tenant-id"
export AZURE_RESOURCE_GROUP="rg-myapp-dev"
export GITHUB_ORG="your-org"
export GITHUB_REPO="your-repo"

# Create resource group
az group create --name "${AZURE_RESOURCE_GROUP}" --location eastus

# Create service principal
az ad sp create-for-rbac \
  --name "sp-github-myapp-dev" \
  --role Contributor \
  --scopes "/subscriptions/${AZURE_SUBSCRIPTION_ID}"

# Create federated credentials (see AZURE_SETUP.md for full commands)
```

### 2. Add GitHub Secrets

Add these repository secrets (Settings → Secrets and variables → Actions):
- `AZURE_TENANT_ID`
- `AZURE_CLIENT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `RESOURCE_GROUP_NAME`

### 3. Customize Infrastructure

Edit the Bicep parameters for your environment:

```bash
# Edit dev environment parameters
vim infra/main.parameters.dev.json

# Update values:
# - location: Azure region for deployment
# - projectName: Your application name
# - orgPrefix: Your organization prefix
```

### 4. Deploy

Create a PR to trigger the what-if validation:

```bash
git checkout -b feature/my-changes
# Make changes to infra/
git push origin feature/my-changes
# Create PR in GitHub
```

The PR workflow (`deploy-what-if.yml`) will:
- ✅ Validate Bicep syntax
- ✅ Run deployment what-if preview
- ✅ Comment on the PR with expected changes

Merge the PR to deploy to dev:

```bash
# After PR is approved and merged to main
# The deploy-stack.yml workflow triggers automatically
# Monitor in Actions tab
```

## 📁 Repository Structure

```
.
├── .github/
│   ├── workflows/
│   │   ├── deploy-what-if.yml    # PR validation workflow
│   │   └── deploy-stack.yml      # Main branch deployment workflow
│   └── copilot-instructions.md   # Copilot configuration
├── docs/
│   └── AZURE_SETUP.md            # Comprehensive setup guide
├── infra/
│   ├── main.bicep                # Main orchestration template
│   ├── variables.bicep           # Naming conventions and variables
│   ├── outputs.bicep             # Output definitions
│   ├── modules/
│   │   └── storage.bicep         # Storage account module
│   ├── main.parameters.dev.json  # Dev environment parameters
│   └── README.md                 # Infrastructure documentation
├── README.md
└── LICENSE
```

## 🔐 Security

- **OIDC Federated Credentials**: No static credentials stored in GitHub Secrets
- **Short-Lived Tokens**: GitHub Issues OIDC tokens valid for 10 minutes
- **Least Privilege**: Service principal scoped to specific subscription and actions
- **Secure Communication**: All communication over HTTPS with verified tokens

[Learn more about OIDC security](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)

## 🛠️ Workflows

### deploy-what-if.yml

Triggered on: Pull requests to `main` (when infra changes detected)

Steps:
1. Validates Bicep syntax
2. Checks parameter files exist
3. Authenticates to Azure via OIDC
4. Runs `az deployment group what-if`
5. Comments PR with expected changes
6. Validates template would deploy successfully

### deploy-stack.yml

Triggered on:
- Push to `main` branch (after PR merge)
- Manual workflow dispatch via GitHub UI

Steps:
1. Authenticates to Azure via OIDC
2. Validates resource group exists
3. Validates Bicep template
4. Creates or updates deployment stack
5. Outputs deployment information

## 📦 Deployment Stacks

Azure Deployment Stacks manage resource lifecycle:
- **Create**: Initial deployment creates a stack
- **Update**: Subsequent deployments update the stack
- **Delete**: Stack can cleanly remove managed resources

Benefits:
- Prevents accidental deletion of managed resources
- Tracks all resources created by a stack
- Supports deny assignments for protection

## 🌍 Multi-Environment Deployment

To add staging or production environments:

1. **Create parameter file**:
   ```bash
   cp infra/main.parameters.dev.json infra/main.parameters.prod.json
   ```

2. **Update parameters** for your environment

3. **Create GitHub environment** (Settings → Environments)

4. **Update workflows** to support environment selection:
   ```yaml
   - Update deploy-stack.yml to parameterize environment
   - Add approval rules in GitHub Environments if desired
   ```

See [Multi-Environment Setup](docs/AZURE_SETUP.md#multi-environment-setup) for detailed instructions.

## 📚 Documentation

- **[docs/AZURE_SETUP.md](docs/AZURE_SETUP.md)** - Complete setup guide with CLI commands
- **[infra/README.md](infra/README.md)** - Infrastructure template documentation
- **[.github/copilot-instructions.md](.github/copilot-instructions.md)** - Copilot AI guidelines

## 🔧 Troubleshooting

### Workflow fails with OIDC error

See [OIDC Troubleshooting](docs/AZURE_SETUP.md#oidc-token-not-exchanged) in the setup guide.

### Service Principal lacks permissions

See [Permissions Troubleshooting](docs/AZURE_SETUP.md#service-principal-lacks-permissions) in the setup guide.

### Bicep validation fails

See [Bicep Troubleshooting](docs/AZURE_SETUP.md#bicep-validation-fails) in the setup guide.

## 🔗 Resources

- [Azure Deployment Stacks](https://learn.microsoft.com/en-us/azure/azure-resource-manager/deployment-stacks/overview)
- [GitHub OIDC Integration](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Azure Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 📝 License

This project is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.