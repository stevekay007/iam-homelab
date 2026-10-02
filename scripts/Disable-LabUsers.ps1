<#
.SYNOPSIS
  "Leaver" process: disable accounts listed in a CSV, strip group access,
  and move them to a Disabled OU. CSV needs one column: SamAccountName
.EXAMPLE
  .\Disable-LabUsers.ps1 -CsvPath .\leavers.csv -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$CsvPath,
    [string]$DisabledOU = "OU=Disabled,DC=corp,DC=lab"
)
Import-Module ActiveDirectory -ErrorAction Stop

if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$DisabledOU'")) {
    if ($PSCmdlet.ShouldProcess($DisabledOU, "Create Disabled OU")) {
        New-ADOrganizationalUnit -Name "Disabled" -Path "DC=corp,DC=lab" `
            -ProtectedFromAccidentalDeletion $false
    }
}

foreach ($r in (Import-Csv $CsvPath)) {
    $sam = "$($r.SamAccountName)".Trim()
    try {
        $user = Get-ADUser -Identity $sam -Properties MemberOf -ErrorAction Stop
        if ($PSCmdlet.ShouldProcess($sam, "Disable, remove groups, move to Disabled OU")) {
            Disable-ADAccount -Identity $user
            foreach ($g in $user.MemberOf) {
                Remove-ADGroupMember -Identity $g -Members $user -Confirm:$false
            }
            Set-ADUser -Identity $user `
                -Description "Disabled $(Get-Date -Format 'yyyy-MM-dd') by $env:USERNAME"
            Move-ADObject -Identity $user.DistinguishedName -TargetPath $DisabledOU
            Write-Host "Disabled $sam" -ForegroundColor Green
        }
    }
    catch { Write-Warning "$sam : $($_.Exception.Message)" }
}
