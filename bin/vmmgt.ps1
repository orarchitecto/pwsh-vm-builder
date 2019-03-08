<#
.SYNOPSIS
    Program to Automate Build Virtual Machines Lab Creation - Similar to Terraform
.DESCRIPTION
    Program to Terraform a VM Server
.PARAMETER plan
    Validate Manifest file
.PARAMETER apply
    Build / Update VM Environment 
.PARAMETER destroy
    Destroy VM Environment
.PARAMETER status
    Check Status of VM Environment
.EXAMPLE
    vmmgt.ps1 -ManifestName test -Plan
.EXAMPLE
    vmmgt.ps1 -ManifestName test -Apply
.EXAMPLE
    vmmgt.ps1 -ManifestName test -Destroy
.EXAMPLE
    vmmgt.ps1 -ManifestName test -Status
.INPUTS
    Manifest File 
.OUTPUTS
    No Outputs
.NOTES
   Additional information about the script.
.COMPONENT
   This program requires Ansible, Vagrant, VirtualBox installed.
   File structure
.FUNCTIONALITY
   Terraform VM Environments
#>

# Init
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ManifestName,
    [Parameter(Mandatory = $false)][switch]$Plan,
    [Parameter(Mandatory = $false)][switch]$Apply,
    [Parameter(Mandatory = $false)][switch]$Destroy,
    [Parameter(Mandatory = $false)][switch]$Status
)

# Global Variables
$manifest_file_loc    = "/home/acortinas/Development/vmlab/manifests"
$state_file_loc       = "/home/acortinas/Development/vmlab/bin"
$template_loc         = "/home/acortinas/Development/vmlab/templates"
$manifest_file_exists = 0
$state_file_exists    = 0
$new_state            = 0


# Functions
function Replace-TextInFile
{
    # Source Code by Martin Brandl
    # https://about-azure.com/
    Param(
        [string]$FilePath,
        [string]$Pattern,
        [string]$Replacement
    )

    [System.IO.File]::WriteAllText(
        $FilePath,
        ([System.IO.File]::ReadAllText($FilePath) -replace $Pattern, $Replacement)
    )
}

# Main

# Read Manifest
$manifest_file = Join-Path -Path $manifest_file_loc -ChildPath $ManifestName
$vagrant_file =  Join-Path -Path $template_loc -ChildPath "Vagrantfile"

if (Test-Path $manifest_file -PathType Leaf) { 
    $manifest = Get-Content (Join-Path -Path $manifest_file_loc -ChildPath $ManifestName)| ConvertFrom-Json -AsHashtable; 
    $manifest_file_exists = 1; 
}

<# # Read Current State Manifest
if (Test-Path $state_file_loc -PathType Leaf) { 
    $vmstate = Get-Content (Join-Path -Path $state_file_loc -ChildPath $ManifestName) | ConvertFrom-Json -AsHashtable; 
    $state_file_exists = 1; 
}

# If current state file doesn't exist, then this is a new environment
if ( $state_file_exists -eq 0 ) {
    $new_state = 1;
}
Else {
    If (Compare-Object -ReferenceObject $(Get-Content $manifest_file_loc) -DifferenceObject $(Get-Content $vmstate)) {
        Write-Output "No observable changes in current configuration";
        $new_state = 0;
    }
    Else {
        Write-Output "Implementing changes";
        $new_state = 1;
    }
} #>

# Create Config Files
# VM Manifest should exist in the current directory
$manifest
$vagrant_file

# Create Vagrant Template

Copy-Item -Path $vagrant_file -Destination "$vagrant_file.new"
Replace-TextInFile -FilePath "$vagrant_file.new" -Pattern  ":os.distribution:" -Replacement $manifest.vm_group1.db_server.os.distribution
Replace-TextInFile -FilePath "$vagrant_file.new" -Pattern  ":os.major_relase:" -Replacement $manifest.vm_group1.db_server.os.major_release
Replace-TextInFile -FilePath "$vagrant_file.new" -Pattern  ":os.minor_relase:" -Replacement $manifest.vm_group1.db_server.os.minor_release
Replace-TextInFile -FilePath "$vagrant_file.new" -Pattern  ":hostname:"        -Replacement $manifest.vm_group1.db_server.hostname
Replace-TextInFile -FilePath "$vagrant_file.new" -Pattern  ":mem:"             -Replacement $manifest.vm_group1.db_server.resources.mem
Replace-TextInFile -FilePath "$vagrant_file.new" -Pattern  ":cpus:"            -Replacement $manifest.vm_group1.db_server.resources.cpus


# Create VMs with Vagrant

# Make VM Modifications

# Privision VMs

# Update Current State Manifest