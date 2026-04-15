
# GitHub Actions for Docker on Windows

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Windows Compatible](https://img.shields.io/badge/Windows-0078D6?logo=windows&logoColor=white)](https://github.com/actions/runner-images)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com)

Reusable GitHub Actions workflows, templates, and composite actions for building, testing, and deploying Docker containers on **Windows runners**.

## 🎯 What's Inside

| Component | Description | Use Case |
|-----------|-------------|----------|
| **Templates** | Ready-to-use workflow files | Copy-paste into your `.github/workflows/` |
| **Composite Actions** | Reusable action building blocks | Reference in custom workflows |
| **Examples** | Complete working examples | Learn by seeing real projects |
| **Scripts** | PowerShell/CMD helper scripts | Local testing and debugging |

## 🚀 Quick Start (30 seconds)

### Option 1: Copy a template

```bash
# Basic CI pipeline
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/github-actions-docker-windows-templates/main/templates/basic-ci.yml
mkdir -p .github/workflows
mv basic-ci.yml .github/workflows/ci.yml
git add .github/workflows/ci.yml
git commit -m "Add CI pipeline"
git push
Option 2: Use a composite action
yaml
name: CI
on: [push]

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: YOUR_USERNAME/github-actions-docker-windows-templates/composites/setup-windows-docker@main
      
      - name: Build
        run: docker build -t myapp .
Option 3: Reference a reusable workflow
yaml
name: CI
on: [push]

jobs:
  build:
    uses: YOUR_USERNAME/github-actions-docker-windows-templates/.github/workflows/docker-build-push.yml@main
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}
📋 Available Templates
Basic Workflows
Template	Path	What it does
Basic CI	templates/basic-ci.yml	Build + test on push/PR
Build & Push	templates/build-push.yml	Build and push to registry
Full CI/CD	templates/full-cicd.yml	Complete pipeline with deployment
Security Scan	templates/security-scan.yml	Vulnerability scanning
Release	templates/release.yml	Automated GitHub releases
Nightly Build	templates/nightly-build.yml	Scheduled builds
Language-Specific Examples
Language	Path
Node.js	examples/nodejs-app/
Python	examples/python-app/
.NET Core	examples/dotnet-app/
Go	examples/go-app/
🔧 Composite Actions
Action	Path	Inputs
Setup Windows Docker	composites/setup-windows-docker/	None
Build and Push	composites/build-and-push/	image-tag, registry, build-args
Health Check	composites/health-check/	service-name, max-retries
Docker Compose Up	composites/docker-compose-up/	compose-file, services
📚 Usage Examples
Example 1: Basic CI for Node.js App
yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Docker
        uses: YOUR_USERNAME/github-actions-docker-windows-templates/composites/setup-windows-docker@main
      
      - name: Build
        run: docker build -t myapp .
      
      - name: Test
        run: docker run --rm myapp npm test
Example 2: Build and Push to Docker Hub
yaml
name: Publish
on:
  push:
    tags: ['v*']

jobs:
  publish:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: YOUR_USERNAME/github-actions-docker-windows-templates/composites/setup-windows-docker@main
      
      - uses: YOUR_USERNAME/github-actions-docker-windows-templates/composites/build-and-push@main
        with:
          image-tag: ${{ github.ref_name }}
        env:
          DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
          DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}
Example 3: Multi-Environment Deployment
yaml
name: Deploy
on:
  push:
    branches: [main, develop]

jobs:
  deploy-staging:
    if: github.ref == 'refs/heads/develop'
    runs-on: windows-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to staging
        run: |
          docker build -t myapp:staging .
          docker run -d -p 80:3000 myapp:staging
  
  deploy-production:
    if: github.ref == 'refs/heads/main'
    runs-on: windows-latest
    environment: production
    needs: deploy-staging
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to production
        run: |
          docker build -t myapp:production .
          docker run -d -p 443:3000 myapp:production
🔐 Required Secrets
For registry operations, add these to your repository:

Secret	Description	Required For
DOCKER_USERNAME	Docker Hub username	Push to Docker Hub
DOCKER_TOKEN	Docker Hub access token	Push to Docker Hub
GHCR_TOKEN	GitHub Packages token	Push to GHCR
DEPLOY_HOST	Server hostname	Remote deployment
DEPLOY_KEY	SSH private key	Remote deployment
🧪 Testing Your Workflows Locally
bash
# Install act to test GitHub Actions locally
choco install act-cli

# Test a workflow
act -j build -W .github/workflows/basic-ci.yml

# List all jobs
act -l
📖 Documentation
Template Reference

Composite Actions Reference

Examples Gallery

Troubleshooting Guide

🤝 Contributing
See CONTRIBUTING.md

📄 License
MIT - Use freely in personal and commercial projects

Built for Windows Docker developers 🐳

text

### **File 2: .gitignore**

```gitignore
# Windows
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/
*.cab
*.msi
*.msm
*.exe
*.dll
*.pdb

# Docker
*.tar.gz
*.log
exports/
.docker/
docker-compose.override.yml

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Test outputs
test-results/
coverage/
*.trx
*.xml
*.html

# Environment
.env
.env.local
.env.*.local
*.pem
*.key

# GitHub Actions
action-temp/
__pycache__/
*.pyc

# Temporary files
temp/
tmp/
*.tmp
File 3: LICENSE (MIT)
txt
MIT License

Copyright (c) 2024 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.