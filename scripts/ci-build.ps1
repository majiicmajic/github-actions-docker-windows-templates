# scripts/ci-build.ps1
# Complete CI build script for Windows

param(
    [Parameter(Mandatory=$false)]
    [string]$ImageTag = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Registry = "docker.io",
    
    [Parameter(Mandatory=$false)]
    [string]$Dockerfile = "Dockerfile",
    
    [Parameter(Mandatory=$false)]
    [switch]$PushToRegistry,
    
    [Parameter(Mandatory=$false)]
    [string]$BuildArgs = ""
)

$ErrorActionPreference = "Stop"

# Colors for output
$Green = "`e[32m"
$Red = "`e[31m"
$Yellow = "`e[33m"
$Reset = "`e[0m"

function Write-Success {
    Write-Host "${Green}[SUCCESS]${Reset} $args"
}

function Write-Error {
    Write-Host "${Red}[ERROR]${Reset} $args"
}

function Write-Info {
    Write-Host "${Yellow}[INFO]${Reset} $args"
}

function Write-Header {
    Write-Host ""
    Write-Host "========================================"
    Write-Host $args
    Write-Host "========================================"
}

# Main execution
try {
    Write-Header "CI Build Script Starting"
    
    # Set image tag
    if ([string]::IsNullOrEmpty($ImageTag)) {
        $ImageTag = $env:GITHUB_SHA
        if ([string]::IsNullOrEmpty($ImageTag)) {
            $ImageTag = "latest"
        }
    }
    
    $ImageName = Split-Path (Get-Location) -Leaf
    $FullImage = "$Registry/$env:DOCKER_USERNAME/$ImageName`:$ImageTag"
    
    Write-Info "Building: $FullImage"
    Write-Info "Dockerfile: $Dockerfile"
    
    # Build image
    Write-Header "Building Docker Image"
    $buildCmd = "docker build -f $Dockerfile -t $FullImage"
    
    if (![string]::IsNullOrEmpty($BuildArgs)) {
        $buildCmd += " --build-arg $($BuildArgs -replace ',', ' --build-arg ')"
    }
    
    $buildCmd += " ."
    Write-Info "Command: $buildCmd"
    Invoke-Expression $buildCmd
    
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed with exit code $LASTEXITCODE"
    }
    Write-Success "Build completed"
    
    # Run tests if test script exists
    if (Test-Path "package.json") {
        Write-Header "Running Tests"
        docker run --rm $FullImage npm test
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Tests failed with exit code $LASTEXITCODE"
        } else {
            Write-Success "Tests passed"
        }
    }
    
    # Push to registry if requested
    if ($PushToRegistry) {
        Write-Header "Pushing to Registry"
        
        # Login
        if ($env:DOCKER_TOKEN) {
            Write-Info "Logging into Docker Hub..."
            $env:DOCKER_TOKEN | docker login --username $env:DOCKER_USERNAME --password-stdin
        }
        
        # Push image
        docker push $FullImage
        if ($LASTEXITCODE -ne 0) {
            throw "Push failed with exit code $LASTEXITCODE"
        }
        Write-Success "Image pushed: $FullImage"
        
        # Push latest tag
        if ($ImageTag -ne "latest") {
            $LatestImage = "$Registry/$env:DOCKER_USERNAME/$ImageName`:latest"
            docker tag $FullImage $LatestImage
            docker push $LatestImage
            Write-Success "Also pushed: $LatestImage"
        }
    }
    
    # Output summary
    Write-Header "Build Summary"
    Write-Host "Image: $FullImage"
    Write-Host "Size: $(docker images $FullImage --format '{{.Size}}')"
    Write-Host ""
    Write-Success "CI build completed successfully!"
    
} catch {
    Write-Error "Build failed: $_"
    exit 1
}