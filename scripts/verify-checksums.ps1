# Verify SHA256 checksums for DuraShare specification release assets (Windows).
#
# Integrity only. Authenticity requires the signed git tag and detached .asc
# signatures (see scripts/verify-published-release.sh).
#
# Usage:
#   .\scripts\verify-checksums.ps1 -LocalPath CHECKSUMS.txt
#   .\scripts\verify-checksums.ps1 [-Dir DIR] [version]
#
# Fail-closed: missing files, empty/unparseable CHECKSUMS.txt, path traversal,
# and zero hashed entries are errors.

param(
    [string]$Version = "latest",
    [string]$LocalPath = "",
    [string]$Dir = ""
)

$ErrorActionPreference = "Stop"
$Repo = if ($env:DURASHARE_REPO) { $env:DURASHARE_REPO } else { "GRIFORTIS/durashare" }

function Test-UnsafeFilename([string]$Name) {
    if ([string]::IsNullOrWhiteSpace($Name)) { return $true }
    if ($Name.StartsWith("/") -or $Name.StartsWith("\") -or $Name.StartsWith("~")) { return $true }
    if ($Name.Contains("..")) { return $true }
    if ($Name.Contains(":")) { return $true }
    return $false
}

function Resolve-ListedFile([string]$Root, [string]$Listed) {
    $candidate = Join-Path $Root $Listed
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        return $candidate
    }
    $parent = Split-Path -Path $Listed -Parent
    $base = Split-Path -Path $Listed -Leaf
    if ($parent -eq "release-assets") {
        $mapped = Join-Path $Root $base
        if (Test-Path -LiteralPath $mapped -PathType Leaf) {
            return $mapped
        }
    }
    return $null
}

function Verify-ChecksumsFile([string]$ChecksumsFile, [string]$Root) {
    if (-not (Test-Path -LiteralPath $ChecksumsFile -PathType Leaf)) {
        Write-Host "✗ CHECKSUMS file not found: $ChecksumsFile" -ForegroundColor Red
        return 1
    }
    $item = Get-Item -LiteralPath $ChecksumsFile
    if ($item.Length -eq 0) {
        Write-Host "✗ CHECKSUMS file is empty: $ChecksumsFile" -ForegroundColor Red
        return 1
    }

    Write-Host "🔍 Verifying checksums in $ChecksumsFile"
    Write-Host ""

    $script:passed = 0
    $script:failed = 0
    $script:missing = 0
    $script:parsed = 0

    Get-Content -LiteralPath $ChecksumsFile | ForEach-Object {
        $line = $_
        if ([string]::IsNullOrWhiteSpace($line)) { return }
        if ($line.StartsWith("#")) { return }

        if ($line -notmatch '^([0-9A-Fa-f]{64})\s+\*?(.+)$') {
            Write-Host "✗ Unrecognized CHECKSUMS line (not GNU sha256sum format):" -ForegroundColor Red
            Write-Host "   $line"
            $script:failed++
            return
        }

        $expectedHash = $Matches[1].ToLower()
        $listed = $Matches[2].Trim()

        if (Test-UnsafeFilename $listed) {
            Write-Host "✗ Unsafe or empty filename in CHECKSUMS.txt: $listed" -ForegroundColor Red
            $script:failed++
            return
        }

        $script:parsed++
        $actualFile = Resolve-ListedFile $Root $listed
        if ($null -eq $actualFile) {
            Write-Host "✗ $listed (not found under $Root)" -ForegroundColor Red
            $script:missing++
            return
        }

        $actualHash = (Get-FileHash -LiteralPath $actualFile -Algorithm SHA256).Hash.ToLower()
        if ($expectedHash -eq $actualHash) {
            Write-Host "✓ $listed" -ForegroundColor Green
            $script:passed++
        } else {
            Write-Host "✗ $listed" -ForegroundColor Red
            Write-Host "   Expected: $expectedHash"
            Write-Host "   Got:      $actualHash"
            $script:failed++
        }
    }

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host "Results:"
    Write-Host "  Passed: $script:passed" -ForegroundColor Green
    Write-Host "  Failed: $script:failed" -ForegroundColor Red
    Write-Host "  Missing: $script:missing" -ForegroundColor Red
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if ($script:parsed -eq 0) {
        Write-Host ""
        Write-Host "✗ Checksum verification FAILED" -ForegroundColor Red
        Write-Host "  CHECKSUMS.txt contained no hash entries."
        return 1
    }
    if ($script:failed -gt 0 -or $script:missing -gt 0) {
        Write-Host ""
        Write-Host "✗ Checksum verification FAILED" -ForegroundColor Red
        Write-Host "  Listed files must all exist and match. Missing files are errors."
        return 1
    }

    Write-Host ""
    Write-Host "✓ All checksums verified successfully!" -ForegroundColor Green
    Write-Host "  The files match the published checksums."
    Write-Host "  This alone does not prove authenticity; also verify the signed tag and detached signatures."
    return 0
}

Write-Host "🔐 Verifying checksums for DuraShare Specification" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: checksum validation confirms file integrity only." -ForegroundColor Yellow
Write-Host "For authenticity, also verify the signed git tag and any detached .asc signatures." -ForegroundColor Yellow
Write-Host ""

if ($LocalPath -ne "") {
    if ($Version -ne "latest") {
        Write-Host "Use either -LocalPath CHECKSUMS.txt or a release version, not both." -ForegroundColor Red
        exit 2
    }
    $checksumsAbs = (Resolve-Path -LiteralPath $LocalPath).Path
    $root = Split-Path -Path $checksumsAbs -Parent
    exit (Verify-ChecksumsFile $checksumsAbs $root)
}

if ($Dir -eq "") {
    $Dir = "."
}
New-Item -ItemType Directory -Force -Path $Dir | Out-Null
$Dir = (Resolve-Path -LiteralPath $Dir).Path

if ($Version -eq "latest") {
    $checksumUrl = "https://github.com/$Repo/releases/latest/download/CHECKSUMS.txt"
} else {
    $checksumUrl = "https://github.com/$Repo/releases/download/$Version/CHECKSUMS.txt"
}

Write-Host "📥 Downloading checksums for version: $Version" -ForegroundColor Yellow
Write-Host "   URL: $checksumUrl"
Write-Host ""

try {
    Invoke-WebRequest -Uri $checksumUrl -OutFile (Join-Path $Dir "CHECKSUMS.txt")
    Write-Host "✓ Downloaded CHECKSUMS.txt" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download checksums" -ForegroundColor Red
    Write-Host "   Make sure the release exists and has checksums attached"
    exit 1
}

Write-Host ""
Write-Host "📝 Checksums file content:"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Get-Content -LiteralPath (Join-Path $Dir "CHECKSUMS.txt")
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host ""

exit (Verify-ChecksumsFile (Join-Path $Dir "CHECKSUMS.txt") $Dir)
