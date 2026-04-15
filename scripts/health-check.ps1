# scripts/health-check.ps1
# Health check script for containers

param(
    [Parameter(Mandatory=$true)]
    [string]$ContainerName,
    
    [Parameter(Mandatory=$false)]
    [int]$MaxRetries = 30,
    
    [Parameter(Mandatory=$false)]
    [int]$RetryDelaySeconds = 2,
    
    [Parameter(Mandatory=$false)]
    [string]$HealthEndpoint = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowLogsOnFailure
)

$ErrorActionPreference = "Continue"

$Green = "`e[32m"
$Red = "`e[31m"
$Yellow = "`e[33m"
$Reset = "`e[0m"

function Write-Success { Write-Host "${Green}✅${Reset} $args" }
function Write-Error { Write-Host "${Red}❌${Reset} $args" }
function Write-Info { Write-Host "${Yellow}⏳${Reset} $args" }

Write-Host ""
Write-Host "========================================"
Write-Host "Health Check: $ContainerName"
Write-Host "========================================"

$retryCount = 0
$isHealthy = $false

# Check container exists
$containerExists = docker ps -a --filter "name=$ContainerName" --format "{{.Names}}" | Select-String -Pattern "^$ContainerName$"
if (-not $containerExists) {
    Write-Error "Container '$ContainerName' does not exist"
    exit 1
}

# Wait for container to be healthy
while ($retryCount -lt $MaxRetries) {
    $retryCount++
    
    # Get container status
    $state = docker inspect $ContainerName --format "{{.State.Status}}"
    $health = docker inspect $ContainerName --format "{{.State.Health.Status}}" 2>$null
    
    Write-Info "Status: $state, Health: $health (Attempt $retryCount/$MaxRetries)"
    
    if ($state -ne "running") {
        Write-Error "Container is not running (Status: $state)"
        if ($ShowLogsOnFailure) {
            Write-Host "`nContainer logs:"
            docker logs $ContainerName --tail 50
        }
        break
    }
    
    if ($health -eq "healthy") {
        $isHealthy = $true
        Write-Success "Container is healthy!"
        break
    }
    
    if ($health -eq "unhealthy") {
        Write-Error "Container is unhealthy"
        if ($ShowLogsOnFailure) {
            Write-Host "`nContainer logs:"
            docker logs $ContainerName --tail 50
        }
        break
    }
    
    Start-Sleep -Seconds $RetryDelaySeconds
}

if (-not $isHealthy) {
    Write-Error "Health check failed after $MaxRetries attempts"
    exit 1
}

# Optional HTTP endpoint check
if ($HealthEndpoint) {
    Write-Host ""
    Write-Info "Checking HTTP endpoint: $HealthEndpoint"
    
    $httpRetries = 0
    $httpSuccess = $false
    
    while ($httpRetries -lt 10) {
        try {
            $response = Invoke-WebRequest -Uri $HealthEndpoint -UseBasicParsing -TimeoutSec 5
            if ($response.StatusCode -eq 200) {
                Write-Success "HTTP endpoint is healthy (Status: $($response.StatusCode))"
                $httpSuccess = $true
                break
            } else {
                Write-Info "HTTP endpoint returned $($response.StatusCode)"
            }
        } catch {
            Write-Info "Waiting for HTTP endpoint... ($httpRetries/10)"
        }
        $httpRetries++
        Start-Sleep -Seconds 2
    }
    
    if (-not $httpSuccess) {
        Write-Error "HTTP health check failed"
        exit 1
    }
}

Write-Success "All health checks passed!"
exit 0