# Template Reference

Detailed documentation for all available workflow templates.

## Basic Templates

### `basic-ci.yml`
Simple CI pipeline that builds and tests on every push.

**Triggers:** Push, Pull Request
**Jobs:** Build & Test

**Usage:**
```yaml
name: CI
on: [push, pull_request]
jobs:
  build:
    uses: yourusername/github-actions-docker-windows-templates/.github/workflows/basic-ci.yml@main
build-push.yml
Builds and pushes to container registry.

Triggers: Push to main, Tags
Secrets Required: DOCKER_USERNAME, DOCKER_TOKEN

Customization:

yaml
with:
  image-tag: custom-tag
  platforms: linux/amd64,windows/amd64
full-cicd.yml
Complete CI/CD pipeline with build, test, security scan, and deployment.

Jobs:

Build & Test

Security Scan

Deploy to Staging

Deploy to Production

security-scan.yml
Vulnerability and secret scanning.

Scans:

Docker image vulnerabilities (Trivy)

Secrets in code (Gitleaks)

Dependency vulnerabilities

release.yml
Automated GitHub release creation.

Features:

Automatic changelog generation

Docker image export

Release artifact attachment

nightly-build.yml
Scheduled builds for testing.

Schedule: Daily at 2 AM UTC
Features:

Performance benchmarking

Automatic issue creation on failure

Optional Slack notifications

multi-environment.yml
Multi-environment deployment workflow.

Environments:

Development (automatic)

Staging (requires 1 approval)

Production (requires 2 approvals)

Inputs Reference
Common Inputs
Input	Description	Default
image-tag	Docker image tag	github.sha
registry	Container registry	docker.io
build-args	Docker build arguments	""
push-latest	Push as latest tag	true
Secrets Reference
Secret	Required For	Description
DOCKER_USERNAME	Push to Docker Hub	Docker Hub username
DOCKER_TOKEN	Push to Docker Hub	Docker Hub access token
GHCR_TOKEN	Push to GHCR	GitHub token with packages:write
SLACK_WEBHOOK	Notifications	Slack webhook URL
Examples
Basic CI with Custom Registry
yaml
name: CI
on: [push]

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build and push
        uses: yourusername/github-actions-docker-windows-templates/composites/build-and-push@main
        with:
          registry: ghcr.io
          image-tag: ${{ github.sha }}
        env:
          DOCKER_USERNAME: ${{ github.actor }}
          DOCKER_TOKEN: ${{ secrets.GHCR_TOKEN }}
Multi-Platform Build
yaml
- name: Build multi-platform
  run: |
    docker buildx build --platform linux/amd64,windows/amd64 -t myapp:latest .
Deployment with Custom Health Check
yaml
- name: Deploy
  run: docker run -d --name app myapp:latest

- name: Health check
  uses: yourusername/github-actions-docker-windows-templates/composites/health-check@main
  with:
    container-name: app
    max-retries: 60
    health-endpoint: http://localhost:8080/health
Troubleshooting
Common Issues
"Docker not found"

Ensure runner is windows-latest

Use setup-windows-docker composite action

"Access denied" to registry

Verify secrets are set correctly

Check token has necessary permissions

Build fails on Windows

Check line endings (CRLF vs LF)

Ensure paths use backslashes or forward slashes consistently

For more help, see the Troubleshooting Guide.

# Template Reference

Detailed documentation for all available workflow templates.

## Basic Templates

### `basic-ci.yml`
Simple CI pipeline that builds and tests on every push.

**Triggers:** Push, Pull Request
**Jobs:** Build & Test

**Usage:**
```yaml
name: CI
on: [push, pull_request]
jobs:
  build:
    uses: yourusername/github-actions-docker-windows-templates/.github/workflows/basic-ci.yml@main
build-push.yml
Builds and pushes to container registry.

Triggers: Push to main, Tags
Secrets Required: DOCKER_USERNAME, DOCKER_TOKEN

Customization:

yaml
with:
  image-tag: custom-tag
  platforms: linux/amd64,windows/amd64
full-cicd.yml
Complete CI/CD pipeline with build, test, security scan, and deployment.

Jobs:

Build & Test

Security Scan

Deploy to Staging

Deploy to Production

security-scan.yml
Vulnerability and secret scanning.

Scans:

Docker image vulnerabilities (Trivy)

Secrets in code (Gitleaks)

Dependency vulnerabilities

release.yml
Automated GitHub release creation.

Features:

Automatic changelog generation

Docker image export

Release artifact attachment

nightly-build.yml
Scheduled builds for testing.

Schedule: Daily at 2 AM UTC
Features:

Performance benchmarking

Automatic issue creation on failure

Optional Slack notifications

multi-environment.yml
Multi-environment deployment workflow.

Environments:

Development (automatic)

Staging (requires 1 approval)

Production (requires 2 approvals)

Inputs Reference
Common Inputs
Input	Description	Default
image-tag	Docker image tag	github.sha
registry	Container registry	docker.io
build-args	Docker build arguments	""
push-latest	Push as latest tag	true
Secrets Reference
Secret	Required For	Description
DOCKER_USERNAME	Push to Docker Hub	Docker Hub username
DOCKER_TOKEN	Push to Docker Hub	Docker Hub access token
GHCR_TOKEN	Push to GHCR	GitHub token with packages:write
SLACK_WEBHOOK	Notifications	Slack webhook URL
Examples
Basic CI with Custom Registry
yaml
name: CI
on: [push]

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build and push
        uses: yourusername/github-actions-docker-windows-templates/composites/build-and-push@main
        with:
          registry: ghcr.io
          image-tag: ${{ github.sha }}
        env:
          DOCKER_USERNAME: ${{ github.actor }}
          DOCKER_TOKEN: ${{ secrets.GHCR_TOKEN }}
Multi-Platform Build
yaml
- name: Build multi-platform
  run: |
    docker buildx build --platform linux/amd64,windows/amd64 -t myapp:latest .
Deployment with Custom Health Check
yaml
- name: Deploy
  run: docker run -d --name app myapp:latest

- name: Health check
  uses: yourusername/github-actions-docker-windows-templates/composites/health-check@main
  with:
    container-name: app
    max-retries: 60
    health-endpoint: http://localhost:8080/health
Troubleshooting
Common Issues
"Docker not found"

Ensure runner is windows-latest

Use setup-windows-docker composite action

"Access denied" to registry

Verify secrets are set correctly

Check token has necessary permissions

Build fails on Windows

Check line endings (CRLF vs LF)

Ensure paths use backslashes or forward slashes consistently

For more help, see the Troubleshooting Guide.

text

### **File 19: .github/workflows/test-templates.yml**

```yaml
# .github/workflows/test-templates.yml
# CI for the templates repository itself

name: Test Templates

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  validate-templates:
    name: Validate YAML Syntax
    runs-on: windows-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Validate YAML files
        shell: powershell
        run: |
          Get-ChildItem -Recurse -Filter *.yml | ForEach-Object {
            Write-Host "Validating: $_"
            $content = Get-Content $_.FullName -Raw
            try {
              $null = $content | ConvertFrom-Yaml
              Write-Host "✅ Valid: $_"
            } catch {
              Write-Host "❌ Invalid: $_"
              throw $_
            }
          }
  
  test-composite-actions:
    name: Test Composite Actions
    runs-on: windows-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Test setup-windows-docker
        uses: ./composites/setup-windows-docker
      
      - name: Verify installations
        shell: cmd
        run: |
          docker --version
          make --version || echo "Make not installed (optional)"
      
      - name: Test health-check (mock)
        shell: cmd
        run: |
          docker run -d --name test-nginx -p 8080:80 nginx:alpine
          timeout /t 5
          curl -f http://localhost:8080 || exit 1
          docker stop test-nginx
          docker rm test-nginx
📁 Final Step: Push to GitHub
bash
# Initialize repository
git init
git add .
git commit -m "Initial commit: GitHub Actions Docker Windows Templates

- Added 7 workflow templates
- Added 5 composite actions
- Added PowerShell scripts
- Added comprehensive documentation
- Includes examples for Node.js, Python, .NET"

# Add remote (replace with your username)
git remote add origin https://github.com/YOUR_USERNAME/github-actions-docker-windows-templates.git

# Push to GitHub
git branch -M main
git push -u origin main

# Create first release
git tag -a v1.0.0 -m "First stable release"
git push origin v1.0.0
📊 Repository Checklist
Now your repository has:

✅ Templates (7 files)
basic-ci.yml

build-push.yml

full-cicd.yml

security-scan.yml

release.yml

nightly-build.yml

multi-environment.yml

✅ Composite Actions (5 files)
setup-windows-docker/action.yml

build-and-push/action.yml

health-check/action.yml

docker-compose-up/action.yml

cleanup/action.yml

✅ Scripts (2 files)
ci-build.ps1

health-check.ps1

✅ Documentation (3 files)
README.md

docs/templates.md

examples/nodejs-app/README.md

✅ CI for the repo itself
.github/workflows/test-templates.yml