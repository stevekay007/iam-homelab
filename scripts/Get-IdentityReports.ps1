<#
.SYNOPSIS
  Audit reports every IAM team runs: stale accounts, never-logged-on
  accounts, passwords that never expire, and privileged group members.
  Writes CSV files to the current folder.
#>
Import-Module ActiveDirectory -ErrorAction Stop
$days = 90

Write-Host "1. Accounts inactive for $days+ days" -ForegroundColor Cyan
Search-ADAccount -AccountInactive -UsersOnly -TimeSpan "$days.00:00:00" |
    Select-Object Name, SamAccountName, Enabled, LastLogonDate |
    Export-Csv .\report-stale-accounts.csv -NoTypeInformation

Write-Host "2. Enabled accounts that have never logged on" -ForegroundColor Cyan
Get-ADUser -Filter 'Enabled -eq $true' -Properties LastLogonDate, Created |
    Where-Object { -not $_.LastLogonDate } |
    Select-Object Name, SamAccountName, Created |
    Export-Csv .\report-never-logged-on.csv -NoTypeInformation

Write-Host "3. Accounts with passwords that never expire" -ForegroundColor Cyan
Search-ADAccount -PasswordNeverExpires -UsersOnly |
    Select-Object Name, SamAccountName, Enabled |
    Export-Csv .\report-password-never-expires.csv -NoTypeInformation

Write-Host "4. Members of privileged groups" -ForegroundColor Cyan
$priv = "Domain Admins", "Enterprise Admins", "Schema Admins", "Administrators"
$priv | ForEach-Object {
    $g = $_
    Get-ADGroupMember -Identity $g -Recursive |
        Select-Object @{n = "Group"; e = { $g }}, Name, SamAccountName, objectClass
} | Export-Csv .\report-privileged-members.csv -NoTypeInformation

Write-Host "Done. Open the report-*.csv files." -ForegroundColor Green
