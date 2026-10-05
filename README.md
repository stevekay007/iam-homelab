# IAM Home Lab

A hands-on identity and access management (IAM) lab built to practice the skills in enterprise
identity engineer roles: Active Directory, Group Policy, Microsoft Entra ID, PowerShell automation,
PKI, and identity threat detection.

> **Honesty note:** this is a home lab built from evaluation software, not production experience.
> Every project below is documented with what I built, what broke, and how I fixed it.

## Lab design

| Item | Value |
|---|---|
| Hypervisor | Oracle VirtualBox on Windows 11 Home (8 GB RAM) |
| Domain | `corp.lab` (NetBIOS: `CORP`) |
| DC01 | Windows Server 2022 Standard Evaluation, domain controller + DNS |
| SRV01 | Windows Server 2022 Standard Evaluation, member server |
| Lab network | VirtualBox Internal Network `labnet`, `10.0.0.0/24` |
| Internet | Second adapter on NAT (`10.0.2.15`, automatic) |

| Computer | Lab address | DNS |
|---|---|---|
| DC01 | 10.0.0.10 | 10.0.0.10 |
| SRV01 | 10.0.0.11 | 10.0.0.10 |

## Progress

**Project 1: Hybrid AD foundation** (in progress)
- [x] Built DC01 and SRV01 in VirtualBox with a private internal network
- [x] Verified connectivity between the two servers (ICMP)
- [x] Promoted DC01 to a domain controller for `corp.lab`
- [x] Ran `dcdiag` and reviewed the results
- [x] Join SRV01 to the domain
- [x] OU structure, users, groups (AGDLP), delegated password resets
- [ ] Group Policy (password policy, USB block, restricted groups)
- [ ] Sync to Microsoft Entra ID with Entra Connect
- [ ] Break/fix exercises

Planned: Project 2 (Conditional Access, SSO, RBAC, PIM), Project 3 (PowerShell and Graph automation),
Project 4 (two-tier PKI with AD CS), Project 5 (identity threat detection).

## Repository layout

- `project-1-hybrid-ad/` write-up, break/fix log, screenshots, command output
- `scripts/` PowerShell scripts for joiner, mover, leaver and audit reports (see the note inside)
- `sample-data/` **fake** sample users used for bulk-import practice

See [`project-1-hybrid-ad/break-fix-log.md`](project-1-hybrid-ad/break-fix-log.md) for the problems I hit
and how I diagnosed them.
