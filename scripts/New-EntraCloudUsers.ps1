<#
.SYNOPSIS
  Create CLOUD-ONLY users in Microsoft Entra ID from a CSV using Microsoft Graph.
  Use a different set of users than the ones synced from on-prem AD.
.EXAMPLE
  .\New-EntraCloudUsers.ps1 -CsvPath .\users_cloud.csv
.NOTES
  First time only:  Install-Module Microsoft.Graph -Scope CurrentUser
#>
param([Parameter(Mandatory)][string]$CsvPath)

Connect-MgGraph -Scopes "User.ReadWrite.All" -NoWelcome
$domain = (Get-MgDomain | Where-Object IsDefault).Id
$secure = Read-Host "Initial password for cloud users" -AsSecureString
$plain  = [System.Net.NetworkCredential]::new("", $secure).Password

foreach ($r in (Import-Csv $CsvPath)) {
    $upn = "$($r.SamAccountName)@$domain"
    try {
        if (Get-MgUser -Filter "userPrincipalName eq '$upn'") {
            Write-Host "Skipped (exists): $upn" -ForegroundColor Yellow
            continue
        }
        New-MgUser -DisplayName $r.DisplayName -GivenName $r.FirstName `
            -Surname $r.LastName -UserPrincipalName $upn `
            -MailNickname $r.SamAccountName -Department $r.Department `
            -JobTitle $r.JobTitle -OfficeLocation $r.Office -AccountEnabled `
            -UsageLocation "US" `
            -PasswordProfile @{ Password = $plain; ForceChangePasswordNextSignIn = $true } |
            Out-Null
        Write-Host "Created: $upn" -ForegroundColor Green
    }
    catch { Write-Warning "$upn : $($_.Exception.Message)" }
}
Disconnect-MgGraph | Out-Null
