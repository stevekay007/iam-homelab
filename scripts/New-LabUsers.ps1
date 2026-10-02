<#
.SYNOPSIS
  Bulk-create Active Directory users from a CSV file (the "joiner" process).
.EXAMPLE
  .\New-LabUsers.ps1 -CsvPath .\users.csv -WhatIf    # dry run: changes nothing
  .\New-LabUsers.ps1 -CsvPath .\users.csv            # real run
.NOTES
  Run as a Domain Admin on DC01 (or a machine with RSAT). Lab use only.
  Safe to run twice: existing users are skipped, not duplicated.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$CsvPath,
    [string]$BaseOU    = "OU=Users,DC=corp,DC=lab",
    [string]$UpnSuffix = "corp.lab",
    [string]$LogPath   = ".\create-users-log.csv",
    [switch]$ForceChange      # make users change password at first logon
)

Import-Module ActiveDirectory -ErrorAction Stop

# Never store passwords in a script or CSV. Ask for one at run time.
$password = Read-Host "Initial password for new users" -AsSecureString

$rows = Import-Csv -Path $CsvPath
$log  = New-Object System.Collections.Generic.List[object]
$line = 1

foreach ($r in $rows) {
    $line++
    $sam    = "$($r.SamAccountName)".Trim()
    $first  = "$($r.FirstName)".Trim()
    $last   = "$($r.LastName)".Trim()
    $dept   = "$($r.Department)".Trim()
    $result = "Created"

    try {
        # 1. Validate the row before touching AD
        if (-not $sam -or -not $first -or -not $last -or -not $dept) {
            throw "Missing required field"
        }
        if ($sam.Length -gt 20) {
            throw "SamAccountName longer than 20 characters"
        }

        # 2. Skip users that already exist (makes the script safe to re-run)
        if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
            $result = "Skipped: already exists"
        }
        elseif ($PSCmdlet.ShouldProcess($sam, "Create user in $dept")) {
            # 3. Make sure the department group exists
            $group = "GG-$dept"
            if (-not (Get-ADGroup -Filter "Name -eq '$group'")) {
                New-ADGroup -Name $group -GroupScope Global `
                            -GroupCategory Security -Path $BaseOU
            }

            # 4. Create the user
            $params = @{
                Name                  = "$first $last"
                GivenName             = $first
                Surname               = $last
                DisplayName           = "$first $last"
                SamAccountName        = $sam
                UserPrincipalName     = "$sam@$UpnSuffix"
                Department            = $dept
                Title                 = "$($r.JobTitle)".Trim()
                Office                = "$($r.Office)".Trim()
                Path                  = $BaseOU
                AccountPassword       = $password
                Enabled               = $true
                ChangePasswordAtLogon = [bool]$ForceChange
            }
            New-ADUser @params

            # 5. Add to the department group (access by group, not by person)
            Add-ADGroupMember -Identity $group -Members $sam
        }
        else {
            $result = "WhatIf: would create"
        }
    }
    catch {
        $result = "FAILED: $($_.Exception.Message)"
    }

    $log.Add([pscustomobject]@{
        CsvLine = $line; Sam = $sam; Department = $dept; Result = $result
    })
}

$log | Export-Csv -Path $LogPath -NoTypeInformation
Write-Host "`nSummary:" -ForegroundColor Cyan
$log | Group-Object Result | Select-Object Count, Name | Format-Table -AutoSize
Write-Host "Full log saved to $LogPath"
