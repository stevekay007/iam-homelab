# Project 1: Hybrid Active Directory Foundation

## Goal
Stand up a small Active Directory environment that I can break, fix, and extend. Later in this
project it is synced to Microsoft Entra ID.

## Business problem this models
Without a central directory, every computer keeps its own list of accounts. Access cannot be
managed or removed in one place, and leavers can keep access. A domain controller gives the business
one source of truth for who is allowed in.

## What is built so far
1. Two Windows Server 2022 evaluation VMs (DC01, SRV01) on VirtualBox.
2. A private internal network (`labnet`, `10.0.0.0/24`) plus a NAT adapter for internet.
3. Static addresses on the lab adapters and ping verified between servers.
4. DC01 promoted to a domain controller for `corp.lab`.
5. Health check with `dcdiag`. SYSVOL and NETLOGON shares confirmed present.

## Evidence
Put screenshots in `screenshots/` and command output in `outputs/`.
Suggested names:
- `01-virtualbox-network-adapters.png`
- `02-ipconfig-dc01.png`
- `03-ping-success.png`
- `04-dcdiag-output.png`
- `05-net-share-sysvol-netlogon.png`

## Open items
- DC01's NAT adapter has no working internet path yet (see the break/fix log). Not needed until Entra Connect.
