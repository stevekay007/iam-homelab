<#
.SYNOPSIS
  "Mover" process: change department and title, and swap group membership.
  CSV columns: SamAccountName, NewDepartment, NewTitle
.EXAMPLE
  .\Move-LabUsers.ps1 -CsvPath .\movers.csv -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$CsvPath,
    [string]$BaseOU = "OU=Users,DC=corp,DC=lab"
)
Import-Module ActiveDirectory -ErrorAction Stop

foreach ($r in (Import-Csv $CsvPath)) {
    $sam = "$($r.SamAccountName)".Trim()
    try {
        $user = Get-ADUser -Identity $sam -Properties Department -ErrorAction Stop
        $old  = "GG-$($user.Department)"
        $new  = "GG-$($r.NewDepartment)"
        if ($PSCmdlet.ShouldProcess($sam, "Move from $old to $new")) {
            if (-not (Get-ADGroup -Filter "Name -eq '$new'")) {
                New-ADGroup -Name $new -GroupScope Global -GroupCategory Security -Path $BaseOU
            }
            Set-ADUser -Identity $user -Department $r.NewDepartment -Title $r.NewTitle
            if (Get-ADGroup -Filter "Name -eq '$old'") {
                Remove-ADGroupMember -Identity $old -Members $user -Confirm:$false
            }
            Add-ADGroupMember -Identity $new -Members $user
            Write-Host "Moved $sam to $($r.NewDepartment)" -ForegroundColor Green
        }
    }
    catch { Write-Warning "$sam : $($_.Exception.Message)" }
}
