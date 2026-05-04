# Rebase revanced-patched-apks repo
# https://github.com/j-hc/revanced-magisk-module

# Files that must survive the reset
$sourceFiles = @(
  "config.toml",
  "RebaseRevancedPatchedApks.ps1"
)

# Create a unique temp folder
$tempRoot = [System.IO.Path]::GetTempPath()
$tempDir = Join-Path $tempRoot ("revanced-rebase-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tempDir | Out-Null

try {
  # 1. Copy files to the unique TEMP folder
  foreach ($file in $sourceFiles) {
    Copy-Item -Path $file -Destination $tempDir -Force
  }

  # 2. Ensure upstream remote exists, then reset to upstream/main
  if (-not (git remote | Select-String -SimpleMatch "upstream")) {
    git remote add upstream "https://github.com/j-hc/revanced-magisk-module"
  }

  git fetch upstream
  git reset --hard upstream/main

  # 3. Copy files back from TEMP
  foreach ($file in $sourceFiles) {
    Copy-Item -Path (Join-Path -Path $tempDir -ChildPath $file) -Destination . -Force
  }

  # 4. Commit and push
  git add $sourceFiles
  git commit -m "Adding my config and update script"
  git push --force

  # 5. Prevent src refspec error
  git tag -d main
}
finally {
  # 6. Cleanup the unique TEMP folder completely
  if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
  }
}
