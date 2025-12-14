<#
.NOTES
	RUNNING SCRIPTS CARRIES RISK. ALWAYS REVIEW SCRIPTS BEFORE RUNNING THEM ON YOUR SYSTEM.
	IF IN DOUBT, COPY AND PASTE THE SCRIPT INTO A SERVICE LIKE CHATGPT AND ASK IF IT COULD BE HARMFUL.

.SYNOPSIS
	Clone a git repo, using only the latest head.
	Remove git history and re-initialise as a new repo.

.DESCRIPTION
	Clone a git repo, using only the latest head.
	Remove git history and re-initialise as a new repo.
	Intended for using an existing repo as a template for a new project.

.PARAMETER RepoUrl
	URL to the Git repo to use as template

.PARAMETER NewName
	Name for the new folder containing the new copy of the repo

.NOTES
	Author      : Stuart Bell
	License     : MIT
	Repository  : https://github.com/stu-bell/powershell-scripts

.LINK
	https://github.com/stu-bell/powershell-scripts
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoUrl,

    [Parameter(Mandatory=$true)]
    [string]$NewName
)

# Clone repo. --depth 1 avoids pulling the project history
Write-Host "Cloning $RepoUrl into $NewName..."
git clone --single-branch --depth 1 $RepoUrl $NewName

# Remove the cloned .git directory
Set-Location $NewName
Remove-Item -Path ".git" -Recurse -Force

# Initialise new repo
git init
git add .
git commit -m "Init from $RepoUrl"

Write-Host "Git copy complete"

