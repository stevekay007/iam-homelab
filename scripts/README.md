# Scripts

PowerShell scripts for the account lifecycle (joiner, mover, leaver) and audit reports.

> **Status:** drafts. Not yet tested against my lab domain. Always run with `-WhatIf` first, take a VM
> snapshot before a real run, and update this note once tested.

| Script | Purpose |
|---|---|
| `New-LabUsers.ps1` | Create users from a CSV (joiner), with validation and a log |
| `Move-LabUsers.ps1` | Change department and swap group (mover) |
| `Disable-LabUsers.ps1` | Disable, strip groups, move to a Disabled OU (leaver) |
| `Get-IdentityReports.ps1` | Stale accounts, never-logged-on, privileged group members |
| `New-EntraCloudUsers.ps1` | Create cloud-only users through Microsoft Graph |
| `make_users.py` | Generate fake users with Faker |

Passwords are never stored in the scripts. They are entered at run time.
