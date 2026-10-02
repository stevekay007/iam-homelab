# Break/Fix Log

Format: **Symptom, diagnosis, root cause, fix, what I would do to prevent it.**
(Edit these entries so they are in your own words and add dates.)

## 1. Windows Setup showed old partitions on a new VM
- **Symptom:** The "Where do you want to install" screen listed three existing partitions on SRV01's disk.
- **Diagnosis:** Checked the VM's storage settings to confirm which virtual disk file was attached.
- **Root cause:** The disk had been used already, so Setup saw an old layout.
- **Fix:** Attached a brand-new blank virtual disk and reinstalled onto its unallocated space.
- **Prevention:** Create a fresh disk for each VM and never delete partitions until I know which disk it is.

## 2. DC01 had the wrong operating system
- **Symptom:** The VM showed a Windows 11 login and "Windows cannot find Server Manager".
- **Diagnosis:** Version and install type showed a client OS, and the login screen was Windows 11.
- **Root cause:** The VM was installed from the Windows 11 ISO instead of the Windows Server 2022 ISO.
- **Fix:** Replaced the disk, attached the Server ISO, and reinstalled with the Desktop Experience edition.
- **Prevention:** Check the ISO name under VM Settings > Storage before first boot.

## 3. Ping failed: "Destination host unreachable" from my own address
- **Symptom:** `ping 10.0.0.10` from SRV01 returned "Destination host unreachable" with replies from 10.0.0.11 (itself).
- **Diagnosis:** `ipconfig /all` showed the lab address on the card whose MAC matched VirtualBox Adapter 2 (NAT), not Adapter 1 (`labnet`).
- **Root cause:** Windows adapter names ("Ethernet 2") do not always match VirtualBox adapter numbers. The static IP was set on the NAT card.
- **Fix:** Matched cards by MAC address, put the NAT card back to DHCP, and set `10.0.0.11` on the `labnet` card.
- **Prevention:** Always identify adapters by MAC address.

## 4. Ping failed: "Request timed out"
- **Symptom:** After fixing the cards, ping to DC01 timed out.
- **Diagnosis:** `netsh advfirewall firewall show rule name="Ping"` on DC01 returned "No rules match".
- **Root cause:** The ICMP allow rule had been added on the wrong computer, and the first attempt had a space after the comma that made the command invalid.
- **Fix:** Added the inbound ICMPv4 rule on DC01, then confirmed ping replied from 10.0.0.10.
- **Prevention:** The rule belongs on the machine that receives the ping.

## 5. dcdiag failed SystemLog and DFSREvent
- **Symptom:** `dcdiag /q` reported failed SystemLog and DFSREvent tests.
- **Diagnosis:** Read the events: unexpected shutdown, dump file created, bugcheck 0xA.
- **Root cause:** DC01 crashed and rebooted after earlier unclean shutdowns. The tests only report events from the last day.
- **Fix:** Confirmed SYSVOL and NETLOGON shares exist and that core services ran. Shut VMs down cleanly from Windows from now on.
- **Prevention:** Use Start > Power > Shut down, and watch host memory when running two VMs on 8 GB.

## Open issue: DC01 has no internet through the NAT adapter
- **Symptom:** DNS forwarders show red X marks; `ping 10.0.2.2` fails and `arp -a` has no entry for the gateway.
- **Status:** Investigating (adapter reset and restart attempts). Not required until Entra Connect.
