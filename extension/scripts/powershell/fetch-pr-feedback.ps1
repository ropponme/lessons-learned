#!/usr/bin/env pwsh
#
# fetch-pr-feedback.ps1 - Extract PR data for the speckit.feedback agent
#
# Usage:
#   .\fetch-pr-feedback.ps1 <pr_number>
#   .\fetch-pr-feedback.ps1 -FindCurrent  # Find open PR for current branch (preferred)
#   .\fetch-pr-feedback.ps1 -FindRecent   # Find most recently merged PR
#
# Output: JSON with PR metadata, review comments, and discussion comments
#

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$PRNumber,

    [Parameter()]
    [switch]$FindCurrent,

    [Parameter()]
    [switch]$FindRecent,

    [Parameter()]
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# Helper functions for colored output
function Write-Error-Message {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

function Write-Warning-Message {
    param([string]$Message)
    Write-Host "WARNING: $Message" -ForegroundColor Yellow
}

function Write-Info-Message {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

# Check for gh CLI
function Test-GitHubCLI {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error-Message "GitHub CLI (gh) is required but not installed."
    }
}

# Check for git
function Test-Git {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error-Message "Git is required but not installed."
    }
}

# Verify authentication
function Test-GitHubAuth {
    $null = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Message "Not authenticated with GitHub. Run 'gh auth login' first."
    }
}

# Get repository info
function Get-RepoInfo {
    $repoInfo = gh repo view --json owner,name | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Message "Not in a GitHub repository."
    }
    return "$($repoInfo.owner.login)/$($repoInfo.name)"
}

# Find most recently merged PR for current branch
function Find-RecentMergedPR {
    $currentBranch = git rev-parse --abbrev-ref HEAD 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Message "Not in a git repository."
    }

    # First try to find a merged PR for the current branch
    $prList = gh pr list --state merged --head $currentBranch --json number --limit 1 | ConvertFrom-Json
    $prNumber = $null

    if ($prList -and $prList.Count -gt 0) {
        $prNumber = $prList[0].number
    }

    if (-not $prNumber) {
        # Fallback: get the most recently merged PR in the repo
        $prList = gh pr list --state merged --json number,mergedAt --limit 10 | ConvertFrom-Json
        if ($prList -and $prList.Count -gt 0) {
            $sorted = $prList | Sort-Object -Property mergedAt -Descending
            $prNumber = $sorted[0].number
        }
    }

    if (-not $prNumber) {
        Write-Error-Message "No merged PRs found for branch '$currentBranch' or in recent history."
    }

    return $prNumber
}

# Find open PR for current branch (preferred for pre-merge workflow)
function Find-CurrentPR {
    $currentBranch = git rev-parse --abbrev-ref HEAD 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Message "Not in a git repository."
    }

    # First try to find an open PR for the current branch
    $prList = gh pr list --state open --head $currentBranch --json number --limit 1 | ConvertFrom-Json
    $prNumber = $null

    if ($prList -and $prList.Count -gt 0) {
        $prNumber = $prList[0].number
        return $prNumber
    }

    # Fallback: try to find a merged PR for the current branch
    $prList = gh pr list --state merged --head $currentBranch --json number --limit 1 | ConvertFrom-Json

    if ($prList -and $prList.Count -gt 0) {
        $prNumber = $prList[0].number
        Write-Warning-Message "No open PR found, using most recently merged PR for this branch."
        return $prNumber
    }

    Write-Error-Message "No open or merged PRs found for branch '$currentBranch'."
}

# Fetch PR basic info
function Get-PRInfo {
    param([int]$PRNumber)

    $prInfo = gh pr view $PRNumber --json number,title,body,state,mergedAt,headRefName,url,author 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Message "Failed to fetch PR #$PRNumber"
    }

    return $prInfo | ConvertFrom-Json
}

# Fetch review comments via GraphQL
function Get-ReviewComments {
    param([int]$PRNumber)

    $repoInfo = Get-RepoInfo
    $parts = $repoInfo -split '/'
    $owner = $parts[0]
    $repo = $parts[1]

    $query = @"
query(`$owner: String!, `$repo: String!, `$number: Int!) {
    repository(owner: `$owner, name: `$repo) {
        pullRequest(number: `$number) {
            reviews(first: 100) {
                nodes {
                    body
                    author { login }
                    state
                    submittedAt
                    comments(first: 50) {
                        nodes {
                            body
                            path
                            line
                            author { login }
                        }
                    }
                }
            }
        }
    }
}
"@

    try {
        $result = gh api graphql -f query=$query -f owner=$owner -f repo=$repo -F number=$PRNumber 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning-Message "Failed to fetch review comments for PR #$PRNumber"
            return $null
        }
        return $result | ConvertFrom-Json
    }
    catch {
        Write-Warning-Message "Failed to fetch review comments for PR #$PRNumber"
        return $null
    }
}

# Fetch PR discussion comments
function Get-DiscussionComments {
    param([int]$PRNumber)

    try {
        $result = gh pr view $PRNumber --json comments 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning-Message "Failed to fetch discussion comments for PR #$PRNumber"
            return $null
        }
        return $result | ConvertFrom-Json
    }
    catch {
        Write-Warning-Message "Failed to fetch discussion comments for PR #$PRNumber"
        return $null
    }
}

# Main function to fetch all PR feedback data
function Get-AllFeedback {
    param([int]$PRNumber)

    Write-Info-Message "Fetching PR #$PRNumber data..."

    $prInfo = Get-PRInfo -PRNumber $PRNumber
    $reviewComments = Get-ReviewComments -PRNumber $PRNumber
    $discussionComments = Get-DiscussionComments -PRNumber $PRNumber

    # Create combined JSON object
    $combined = @{
        pr = $prInfo
        reviews = $reviewComments
        discussion = $discussionComments
    }

    return $combined | ConvertTo-Json -Depth 100 -Compress
}

# Show help
function Show-Help {
    Write-Host "Usage: .\fetch-pr-feedback.ps1 <pr_number> | -FindCurrent | -FindRecent"
    Write-Host ""
    Write-Host "Arguments:"
    Write-Host "  <pr_number>     Specific PR number to fetch feedback from"
    Write-Host "  -FindCurrent    Find and fetch the open PR for current branch (falls back to merged)"
    Write-Host "  -FindRecent     Find and fetch the most recently merged PR for current branch"
    Write-Host ""
    Write-Host "Output: JSON with PR metadata, review comments, and discussion comments"
    exit 0
}

# Main execution
if ($Help) {
    Show-Help
}

Test-GitHubCLI
Test-Git
Test-GitHubAuth

if ($FindCurrent) {
    $prNum = Find-CurrentPR
    Write-Info-Message "Found PR for current branch: #$prNum"
    Get-AllFeedback -PRNumber $prNum
}
elseif ($FindRecent) {
    $prNum = Find-RecentMergedPR
    Write-Info-Message "Found most recent merged PR: #$prNum"
    Get-AllFeedback -PRNumber $prNum
}
elseif ($PRNumber) {
    if ($PRNumber -match '^\d+$') {
        Get-AllFeedback -PRNumber ([int]$PRNumber)
    }
    else {
        Write-Error-Message "Invalid PR number: $PRNumber"
    }
}
else {
    Write-Error-Message "No PR number provided. Use '.\fetch-pr-feedback.ps1 <pr_number>', '-FindCurrent', or '-FindRecent'"
}