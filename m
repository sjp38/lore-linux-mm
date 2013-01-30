Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 42F276B0005
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 06:16:07 -0500 (EST)
Message-ID: <510900F3.3090702@skynet.be>
Date: Wed, 30 Jan 2013 12:16:03 +0100
From: Marleen Vanbuel <marleen.vanbuel@skynet.be>
MIME-Version: 1.0
Subject: Fwd: wifi connect probs fedora 17
References: <5108FE5A.4020003@skynet.be>
In-Reply-To: <5108FE5A.4020003@skynet.be>
Content-Type: multipart/alternative;
 boundary="------------080509040200000000010307"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------080509040200000000010307
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

by the way, I use

iwl2030-firmware-18.168.6.1-9.fc17.noarch.rpm

processor: Intel(R) Core^(TM) i3-3110M CPU @ 2.40GHz x 4
Memory: 3.3 GiB
OS: 32-bit
graphics: Intel(R) Ivybridge Mobile
disk: 978.9 GB
Gnome: Version 3.4.2

Marleen Vanbuel
Professional training  & coaching
0485/718.573

marleen.vanbuel@skynet.be

"Wer fremde Sprachen nicht kennt, weiss auch nichts von seiner
eigenen." (JW Goethe)

-------- Original Message --------
Subject: 	wifi connect probs fedora 17
Date: 	Wed, 30 Jan 2013 12:04:58 +0100
From: 	Marleen Vanbuel <marleen.vanbuel@skynet.be>
To: 	linux-mm@kvack.org



Hello,

got your email via dmesg

having probs getting my wifi going after unplugging hard-wire.
Wifi works great if I start/restart, but if I shut it off for some 
reason, or use hard-wire & unplug it, no go.

also tried:

|su-c'systemctl restart NetworkManager.service'|    --- no luck


thanks,

-- 
Marleen Vanbuel
Professional training  & coaching
0485/718.573

marleen.vanbuel@skynet.be

"Wer fremde Sprachen nicht kennt, weiss auch nichts von seiner
eigenen." (JW Goethe)

************************************
what follows results of

--- dmesg
--- /var/log/messages
--- ~/.xsession-errors
--- lsmod | grep iwl

***********************************************
dmesg:

[  429.779141] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 
mBi, 2000 mBm)
[  429.779153] cfg80211: Calling CRDA for country: BE
[  429.781645] cfg80211: Regulatory domain changed to country: BE
[  429.781649] cfg80211:   (start_freq - end_freq @ bandwidth), 
(max_antenna_gain, max_eirp)
[  429.781650] cfg80211:   (2402000 KHz - 2482000 KHz @ 40000 KHz), 
(N/A, 2000 mBm)
[  429.781652] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), 
(N/A, 2000 mBm)
[  429.781653] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz), 
(N/A, 2000 mBm)
[  429.781654] cfg80211:   (5490000 KHz - 5710000 KHz @ 40000 KHz), 
(N/A, 2700 mBm)
[  430.250666] iwlwifi 0000:03:00.0: RF_KILL bit toggled to disable radio.
[  477.421916] r8169 0000:02:00.0 p1p1: link down
[  477.421968] IPv6: ADDRCONF(NETDEV_UP): p1p1: link is not ready
[  533.256662] r8169 0000:02:00.0 p1p1: link down
[  533.256713] IPv6: ADDRCONF(NETDEV_UP): p1p1: link is not ready
[  811.566000] r8169 0000:02:00.0 p1p1: link up
[  811.566026] IPv6: ADDRCONF(NETDEV_CHANGE): p1p1: link becomes ready
[ 1199.679672] r8169 0000:02:00.0 p1p1: link down
[ 1403.792824] ICMPv6: process `sysctl' is using deprecated sysctl 
(syscall) net.ipv6.neigh.default.base_reachable_time - use 
net.ipv6.neigh.default.base_reachable_time_ms instead
[ 1403.795504] nr_pdflush_threads exported in /proc is scheduled for removal
[ 1403.795614] sysctl: The scan_unevictable_pages sysctl/node-interface 
has been disabled for lack of a legitimate use case.  If you have one, 
please send an email to linux-mm@kvack.org.
[ 1514.823973] r8169 0000:02:00.0 p1p1: link down
[ 1514.824041] IPv6: ADDRCONF(NETDEV_UP): p1p1: link is not ready

******************************

sudo less /var/log/messages:

Jan 30 11:20:37 localhost dbus[718]: [system] Activating service 
name='org.freed
esktop.nm_dispatcher' (using servicehelper)
Jan 30 11:20:37 localhost dbus-daemon[718]: dbus[718]: [system] 
Activating servi
ce name='org.freedesktop.nm_dispatcher' (using servicehelper)
Jan 30 11:20:37 localhost dbus-daemon[718]: dbus[718]: [system] 
Successfully act
ivated service 'org.freedesktop.nm_dispatcher'
Jan 30 11:20:37 localhost dbus[718]: [system] Successfully activated 
service 'or
g.freedesktop.nm_dispatcher'
Jan 30 11:20:37 localhost chronyd[709]: Source 77.243.184.65 online
Jan 30 11:20:37 localhost chronyd[709]: Source 85.234.197.2 online
Jan 30 11:20:37 localhost chronyd[709]: Source 81.95.123.221 online
Jan 30 11:20:37 localhost chronyd[709]: Source 194.50.97.34 online
Jan 30 11:21:55 localhost systemd-tmpfiles[1819]: 
stat(/run/user/marleen/gvfs) f
ailed: Permission denied
Jan 30 11:23:52 localhost chronyd[709]: Selected source 81.95.123.221
Jan 30 11:26:57 localhost kernel: [ 1199.679672] r8169 0000:02:00.0 
p1p1: link d
own
Jan 30 11:26:57 localhost NetworkManager[1675]: <info> (p1p1): carrier 
now OFF (
device state 100, deferring action for 4 seconds)
Jan 30 11:27:01 localhost NetworkManager[1675]: <info> (p1p1): device 
state chan
ge: activated -> unavailable (reason 'carrier-changed') [100 20 40]
Jan 30 11:27:02 localhost NetworkManager[1675]: <info> (p1p1): 
deactivating devi
ce (reason 'carrier-changed') [40]
Jan 30 11:27:02 localhost NetworkManager[1675]: <info> (p1p1): canceled 
DHCP tra
nsaction, DHCP client pid 1750
Jan 30 11:27:02 localhost avahi-daemon[698]: Withdrawing address record 
for 192.
168.2.104 on p1p1.
Jan 30 11:27:02 localhost avahi-daemon[698]: Leaving mDNS multicast 
group on interface p1p1.IPv4 with address 192.168.2.104.
Jan 30 11:27:02 localhost avahi-daemon[698]: Interface p1p1.IPv4 no 
longer relevant for mDNS.
Jan 30 11:27:02 localhost dbus-daemon[718]: dbus[718]: [system] 
Activating service name='org.freedesktop.nm_dispatcher' (using 
servicehelper)
Jan 30 11:27:02 localhost dbus[718]: [system] Activating service 
name='org.freedesktop.nm_dispatcher' (using servicehelper)
Jan 30 11:27:02 localhost dbus-daemon[718]: dbus[718]: [system] 
Successfully activated service 'org.freedesktop.nm_dispatcher'
Jan 30 11:27:02 localhost dbus[718]: [system] Successfully activated 
service 'org.freedesktop.nm_dispatcher'
Jan 30 11:27:02 localhost systemd[1]: PID file /run/sendmail.pid not 
readable (yet?) after start.
Jan 30 11:27:02 localhost chronyd[709]: Source 77.243.184.65 offline
Jan 30 11:27:02 localhost chronyd[709]: Source 85.234.197.2 offline
Jan 30 11:27:02 localhost chronyd[709]: Source 194.50.97.34 offline
Jan 30 11:27:02 localhost chronyd[709]: Source 81.95.123.221 offline
Jan 30 11:27:04 localhost NetworkManager[1675]: <info> (wlan0): bringing 
up device.
Jan 30 11:27:04 localhost NetworkManager[1675]: <info> WiFi hardware 
radio set enabled
Jan 30 11:30:21 localhost kernel: [ 1403.792824] ICMPv6: process 
`sysctl' is using deprecated sysctl (syscall) 
net.ipv6.neigh.default.base_reachable_time - use 
net.ipv6.neigh.default.base_reachable_time_ms instead
Jan 30 11:30:21 localhost kernel: [ 1403.795504] nr_pdflush_threads 
exported in /proc is scheduled for removal
Jan 30 11:30:21 localhost kernel: [ 1403.795614] sysctl: The 
scan_unevictable_pages sysctl/node-interface has been disabled for lack 
of a legitimate use case.  If you have one, please send an email to 
linux-mm@kvack.org.
Jan 30 11:32:12 localhost NetworkManager[1675]: <info> caught signal 15, 
shutting down normally.
Jan 30 11:32:12 localhost NetworkManager[1675]: <info> (p1p1): now unmanaged
Jan 30 11:32:12 localhost NetworkManager[1675]: <info> (p1p1): device 
state change: unavailable -> unmanaged (reason 'removed') [20 10 36]
Jan 30 11:32:12 localhost NetworkManager[1675]: <info> (p1p1): cleaning 
up...
Jan 30 11:32:12 localhost NetworkManager[1675]: <info> (p1p1): taking 
down device.
Jan 30 11:32:12 localhost avahi-daemon[698]: Withdrawing address record 
for fe80::226:2dff:fecc:ab6a on p1p1.
Jan 30 11:32:12 localhost NetworkManager[1675]: <info> (wlan0): now 
unmanaged
Jan 30 11:32:12 localhost NetworkManager[1675]: <info> (wlan0): device 
state change: unavailable -> unmanaged (reason 'removed') [20 10 36]
Jan 30 11:32:12 localhost NetworkManager[1675]: <info> exiting (success)
Jan 30 11:32:12 localhost dbus-daemon[718]: dbus[718]: [system] 
Activating via systemd: service name='org.freedesktop.NetworkManager' 
unit='dbus-org.freedesktop.NetworkManager.service'
Jan 30 11:32:12 localhost dbus[718]: [system] Activating via systemd: 
service name='org.freedesktop.NetworkManager' 
unit='dbus-org.freedesktop.NetworkManager.service'
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> NetworkManager 
(version 0.9.6.4-3.fc17) is starting...
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> Read config file 
/etc/NetworkManager/NetworkManager.conf
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> WEXT support is 
enabled
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> VPN: loaded 
org.freedesktop.NetworkManager.openconnect
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> VPN: loaded 
org.freedesktop.NetworkManager.openvpn
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> VPN: loaded 
org.freedesktop.NetworkManager.pptp
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> VPN: loaded 
org.freedesktop.NetworkManager.vpnc
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: Acquired 
D-Bus service com.redhat.ifcfgrh1
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> Loaded plugin 
ifcfg-rh: (c) 2007 - 2010 Red Hat, Inc.  To report bugs please use the 
NetworkManager mailing list.
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> Loaded plugin 
keyfile: (c) 2007 - 2010 Red Hat, Inc.  To report bugs please use the 
NetworkManager mailing list.
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-telenet-DE330 ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'telenet-DE330'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-wirelessleuven-STP ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'wirelessleuven-STP'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-bbox2-d966 ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'bbox2-d966'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-bbox2-5008 ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'bbox2-5008'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-SAFEGE ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'SAFEGE'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-bbox2-ba44 ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'bbox2-ba44'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-Auto_Wifi_Noe_van_Oordt ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'Auto Wifi Noe van Oordt'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-LEUVEN_LANGUES_LOUNGE_ ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'LEUVEN LANGUES LOUNGE '
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-Guest1 ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'Guest1'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-Welcome ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'Welcome'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-Mireille ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'Mireille'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-Auto_MondialGuest ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'Auto MondialGuest'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-lo ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-TELENETHOMESPOT ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'TELENETHOMESPOT'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-p1p1 ...
Jan 30 11:32:13 localhost NetworkManager[2039]: <warn> failed to 
allocate link cache: (-10) Operation not supported
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'System p1p1'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-Auto_linksys ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'Auto linksys'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-Sappi_Free_Access ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'Sappi_Free_Access'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-bbox2-21e4 ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'bbox2-21e4'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-Auto_CP-Guest ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'Auto CP-Guest'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'GUEST'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-Auto_belkin.797.guests ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'Auto belkin.797.guests'
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: parsing 
/etc/sysconfig/network-scripts/ifcfg-Auto_gun-bxl ...
Jan 30 11:32:13 localhost NetworkManager[2039]:    ifcfg-rh: read 
connection 'Auto gun-bxl'
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> modem-manager is 
now available
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> monitoring kernel 
firmware directory '/lib/firmware'.
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> rfkill2: found 
WiFi radio killswitch (at 
/sys/devices/pci0000:00/0000:00:1c.3/0000:03:00.0/ieee80211/phy0/rfkill2) (driver 
iwlwifi)
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> rfkill0: found 
WiFi radio killswitch (at /sys/devices/platform/acer-wmi/rfkill/rfkill0) 
(platform driver acer-wmi)
Jan 30 11:32:13 localhost dbus-daemon[718]: dbus[718]: [system] 
Successfully activated service 'org.freedesktop.NetworkManager'
Jan 30 11:32:13 localhost dbus[718]: [system] Successfully activated 
service 'org.freedesktop.NetworkManager'
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> WiFi disabled by 
radio killswitch; enabled by state file
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> WWAN enabled by 
radio killswitch; enabled by state file
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> WiMAX enabled by 
radio ki
llswitch; enabled by state file
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> Networking is 
enabled by
state file
Jan 30 11:32:13 localhost NetworkManager[2039]: <warn> failed to 
allocate link cache: (-10) Operation not supported
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (p1p1): carrier 
is OFF
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (p1p1): new 
Ethernet device (driver: 'r8169' ifindex: 2)
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (p1p1): exported 
as /org/freedesktop/NetworkManager/Devices/0
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (p1p1): now managed
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (p1p1): device 
state change: unmanaged -> unavailable (reason 'managed') [10 20 2]
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (p1p1): bringing 
up device.
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (p1p1): preparing 
device.
Jan 30 11:32:13 localhost kernel: [ 1514.823973] r8169 0000:02:00.0 
p1p1: link down
Jan 30 11:32:13 localhost kernel: [ 1514.824041] IPv6: 
ADDRCONF(NETDEV_UP): p1p1: link is not ready
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (p1p1): 
deactivating device (reason 'managed') [2]
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (wlan0): using 
nl80211 for WiFi device control
Jan 30 11:32:13 localhost NetworkManager[2039]: <warn> (wlan0): driver 
supports Access Point (AP) mode
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (wlan0): new 
802.11 WiFi device (driver: 'iwlwifi' ifindex: 3)
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (wlan0): exported 
as /org/freedesktop/NetworkManager/Devices/1
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (wlan0): now managed
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (wlan0): device 
state cha
nge: unmanaged -> unavailable (reason 'managed') [10 20 2]
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (wlan0): bringing 
up devi
ce.
Jan 30 11:32:13 localhost NetworkManager[2039]: <info> (wlan0): 
deactivating dev
ice (reason 'managed') [2]
Jan 30 11:32:13 localhost NetworkManager[2039]: <warn> 
/sys/devices/virtual/net/
lo: couldn't determine device driver; ignoring...
Jan 30 11:32:13 localhost NetworkManager[2039]: <warn> 
/sys/devices/virtual/net/
lo: couldn't determine device driver; ignoring...
Jan 30 11:32:19 localhost NetworkManager[2039]: <info> (wlan0): bringing 
up devi
ce.
Jan 30 11:32:19 localhost NetworkManager[2039]: <info> WiFi hardware 
radio set e
nabled
Jan 30 11:32:35 localhost avahi-daemon[698]: Got SIGTERM, quitting.
Jan 30 11:32:35 localhost avahi-daemon[698]: avahi-daemon 0.6.31 exiting.
Jan 30 11:32:35 localhost dbus-daemon[718]: dbus[718]: [system] 
Activating via s
ystemd: service name='org.freedesktop.Avahi' 
unit='dbus-org.freedesktop.Avahi.se
rvice'
Jan 30 11:32:35 localhost dbus[718]: [system] Activating via systemd: 
service na
me='org.freedesktop.Avahi' unit='dbus-org.freedesktop.Avahi.service'
Jan 30 11:32:35 localhost avahi-daemon[2048]: Process 698 died: No such 
process;
  trying to remove PID file. (/var/run/avahi-daemon//pid)
Jan 30 11:32:35 localhost avahi-daemon[2048]: Found user 'avahi' (UID 
70) and gr
oup 'avahi' (GID 70).
Jan 30 11:32:35 localhost avahi-daemon[2048]: Successfully dropped root 
privileg
es.
Jan 30 11:32:35 localhost avahi-daemon[2048]: avahi-daemon 0.6.31 
starting up.
Jan 30 11:32:35 localhost dbus-daemon[718]: dbus[718]: [system] 
Successfully act
ivated service 'org.freedesktop.Avahi'
Jan 30 11:32:35 localhost dbus[718]: [system] Successfully activated 
service 'or
g.freedesktop.Avahi'
Jan 30 11:32:35 localhost avahi-daemon[2048]: Successfully called chroot().
Jan 30 11:32:35 localhost avahi-daemon[2048]: Successfully dropped 
remaining capabilities.
Jan 30 11:32:35 localhost avahi-daemon[2048]: Loading service file 
/services/udisks.service.
Jan 30 11:32:35 localhost avahi-daemon[2048]: System host name is set to 
'localhost'. This is not a suitable mDNS host name, looking for 
alternatives.
Jan 30 11:32:35 localhost avahi-daemon[2048]: Network interface 
enumeration completed.
Jan 30 11:32:35 localhost avahi-daemon[2048]: Registering HINFO record 
with values 'I686'/'LINUX'.
Jan 30 11:32:35 localhost avahi-daemon[2048]: Server startup complete. 
Host name is linux.local. Local service cookie is 960404764.
Jan 30 11:32:35 localhost avahi-daemon[2048]: Service "linux" 
(/services/udisks.service) successfully established.
Jan 30 11:32:40 localhost NetworkManager[2039]: <info> (wlan0): bringing 
up device.
Jan 30 11:32:40 localhost NetworkManager[2039]: <info> WiFi hardware 
radio set enabled
Jan 30 11:32:44 localhost NetworkManager[2039]: <info> (wlan0): bringing 
up device.
Jan 30 11:32:44 localhost NetworkManager[2039]: <info> WiFi hardware 
radio set enabled

*************************************************
~/.xsession-errors

(gnome-shell:1274): Clutter-CRITICAL **: clutter_text_get_text: 
assertion `CLUTT
ER_IS_TEXT (self)' failed

(gnome-shell:1274): Clutter-CRITICAL **: clutter_text_set_text: 
assertion `CLUTT
ER_IS_TEXT (self)' failed

(gnome-control-center:1640): GLib-GObject-CRITICAL **: g_object_unref: 
assertion
  `G_IS_OBJECT (object)' failed
** Message: applet now removed from the notification area
** Message: NM disappeared
** Message: applet now embedded in the notification area

(gnome-shell:1274): Clutter-CRITICAL **: clutter_text_get_editable: 
assertion `C
LUTTER_IS_TEXT (self)' failed

(gnome-shell:1274): Clutter-CRITICAL **: clutter_text_get_text: 
assertion `CLUTT
ER_IS_TEXT (self)' failed

******************************************

[marleen@localhost ~]$ lsmod | grep iwl
iwldvm                219970  0
mac80211              461829  1 iwldvm
iwlwifi                91876  1 iwldvm
cfg80211              171182  3 iwlwifi,mac80211,iwldvm





--------------080509040200000000010307
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>

    <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    by the way, I use <br>
    <br>
    iwl2030-firmware-18.168.6.1-9.fc17.noarch.rpm <br>
    <br>
    <div class="moz-forward-container">processor: Intel&reg; Core&#8482; i3-3110M
      CPU @ 2.40GHz &times; 4 <br>
      Memory: 3.3 GiB<br>
      OS: 32-bit<br>
      graphics: Intel&reg; Ivybridge Mobile&nbsp; <br>
      disk: 978.9 GB<br>
      Gnome: Version 3.4.2<br>
      <pre class="moz-signature" cols="72">Marleen Vanbuel
Professional training  &amp; coaching
0485/718.573

<a class="moz-txt-link-abbreviated" href="mailto:marleen.vanbuel@skynet.be">marleen.vanbuel@skynet.be</a>

"Wer fremde Sprachen nicht kennt, wei&szlig; auch nichts von seiner
eigenen." (JW Goethe) 

</pre>
      -------- Original Message --------
      <table class="moz-email-headers-table" border="0" cellpadding="0"
        cellspacing="0">
        <tbody>
          <tr>
            <th align="RIGHT" nowrap="nowrap" valign="BASELINE">Subject:
            </th>
            <td>wifi connect probs fedora 17</td>
          </tr>
          <tr>
            <th align="RIGHT" nowrap="nowrap" valign="BASELINE">Date: </th>
            <td>Wed, 30 Jan 2013 12:04:58 +0100</td>
          </tr>
          <tr>
            <th align="RIGHT" nowrap="nowrap" valign="BASELINE">From: </th>
            <td>Marleen Vanbuel <a class="moz-txt-link-rfc2396E" href="mailto:marleen.vanbuel@skynet.be">&lt;marleen.vanbuel@skynet.be&gt;</a></td>
          </tr>
          <tr>
            <th align="RIGHT" nowrap="nowrap" valign="BASELINE">To: </th>
            <td><a class="moz-txt-link-abbreviated" href="mailto:linux-mm@kvack.org">linux-mm@kvack.org</a></td>
          </tr>
        </tbody>
      </table>
      <br>
      <br>
      <meta http-equiv="content-type" content="text/html;
        charset=ISO-8859-1">
      Hello, <br>
      <br>
      got your email via dmesg<br>
      <br>
      having probs getting my wifi going after unplugging hard-wire.<br>
      Wifi works great if I start/restart, but if I shut it off for some
      reason, or use hard-wire &amp; unplug it, no go.<br>
      <br>
      also tried: <br>
      <pre class="prettyprint"><code><span class="pln">su </span><span class="pun">-</span><span class="pln">c </span><span class="str">'systemctl restart NetworkManager.service'</span></code>   --- no luck
</pre>
      <br>
      thanks,<br>
      <pre class="moz-signature" cols="72">-- 
Marleen Vanbuel
Professional training  &amp; coaching
0485/718.573

<a moz-do-not-send="true" class="moz-txt-link-abbreviated" href="mailto:marleen.vanbuel@skynet.be">marleen.vanbuel@skynet.be</a>

"Wer fremde Sprachen nicht kennt, wei&szlig; auch nichts von seiner
eigenen." (JW Goethe) 

</pre>
      ************************************<br>
      what follows results of <br>
      <br>
      --- dmesg<br>
      --- /var/log/messages<br>
      --- ~/.xsession-errors<br>
      --- lsmod | grep iwl<br>
      <br>
      ***********************************************<br>
      dmesg:<br>
      <br>
      [&nbsp; 429.779141] cfg80211:&nbsp;&nbsp; (5735000 KHz - 5835000 KHz @ 40000
      KHz), (300 mBi, 2000 mBm)<br>
      [&nbsp; 429.779153] cfg80211: Calling CRDA for country: BE<br>
      [&nbsp; 429.781645] cfg80211: Regulatory domain changed to country: BE<br>
      [&nbsp; 429.781649] cfg80211:&nbsp;&nbsp; (start_freq - end_freq @ bandwidth),
      (max_antenna_gain, max_eirp)<br>
      [&nbsp; 429.781650] cfg80211:&nbsp;&nbsp; (2402000 KHz - 2482000 KHz @ 40000
      KHz), (N/A, 2000 mBm)<br>
      [&nbsp; 429.781652] cfg80211:&nbsp;&nbsp; (5170000 KHz - 5250000 KHz @ 40000
      KHz), (N/A, 2000 mBm)<br>
      [&nbsp; 429.781653] cfg80211:&nbsp;&nbsp; (5250000 KHz - 5330000 KHz @ 40000
      KHz), (N/A, 2000 mBm)<br>
      [&nbsp; 429.781654] cfg80211:&nbsp;&nbsp; (5490000 KHz - 5710000 KHz @ 40000
      KHz), (N/A, 2700 mBm)<br>
      [&nbsp; 430.250666] iwlwifi 0000:03:00.0: RF_KILL bit toggled to
      disable radio.<br>
      [&nbsp; 477.421916] r8169 0000:02:00.0 p1p1: link down<br>
      [&nbsp; 477.421968] IPv6: ADDRCONF(NETDEV_UP): p1p1: link is not ready<br>
      [&nbsp; 533.256662] r8169 0000:02:00.0 p1p1: link down<br>
      [&nbsp; 533.256713] IPv6: ADDRCONF(NETDEV_UP): p1p1: link is not ready<br>
      [&nbsp; 811.566000] r8169 0000:02:00.0 p1p1: link up<br>
      [&nbsp; 811.566026] IPv6: ADDRCONF(NETDEV_CHANGE): p1p1: link becomes
      ready<br>
      [ 1199.679672] r8169 0000:02:00.0 p1p1: link down<br>
      [ 1403.792824] ICMPv6: process `sysctl' is using deprecated sysctl
      (syscall) net.ipv6.neigh.default.base_reachable_time - use
      net.ipv6.neigh.default.base_reachable_time_ms instead<br>
      [ 1403.795504] nr_pdflush_threads exported in /proc is scheduled
      for removal<br>
      [ 1403.795614] sysctl: The scan_unevictable_pages
      sysctl/node-interface has been disabled for lack of a legitimate
      use case.&nbsp; If you have one, please send an email to <a
        moz-do-not-send="true" class="moz-txt-link-abbreviated"
        href="mailto:linux-mm@kvack.org">linux-mm@kvack.org</a>.<br>
      [ 1514.823973] r8169 0000:02:00.0 p1p1: link down<br>
      [ 1514.824041] IPv6: ADDRCONF(NETDEV_UP): p1p1: link is not ready<br>
      <br>
      ******************************<br>
      <br>
      sudo less /var/log/messages:<br>
      <br>
      Jan 30 11:20:37 localhost dbus[718]: [system] Activating service
      name='org.freed<br>
      esktop.nm_dispatcher' (using servicehelper)<br>
      Jan 30 11:20:37 localhost dbus-daemon[718]: dbus[718]: [system]
      Activating servi<br>
      ce name='org.freedesktop.nm_dispatcher' (using servicehelper)<br>
      Jan 30 11:20:37 localhost dbus-daemon[718]: dbus[718]: [system]
      Successfully act<br>
      ivated service 'org.freedesktop.nm_dispatcher'<br>
      Jan 30 11:20:37 localhost dbus[718]: [system] Successfully
      activated service 'or<br>
      g.freedesktop.nm_dispatcher'<br>
      Jan 30 11:20:37 localhost chronyd[709]: Source 77.243.184.65
      online<br>
      Jan 30 11:20:37 localhost chronyd[709]: Source 85.234.197.2 online<br>
      Jan 30 11:20:37 localhost chronyd[709]: Source 81.95.123.221
      online<br>
      Jan 30 11:20:37 localhost chronyd[709]: Source 194.50.97.34 online<br>
      Jan 30 11:21:55 localhost systemd-tmpfiles[1819]:
      stat(/run/user/marleen/gvfs) f<br>
      ailed: Permission denied<br>
      Jan 30 11:23:52 localhost chronyd[709]: Selected source
      81.95.123.221<br>
      Jan 30 11:26:57 localhost kernel: [ 1199.679672] r8169
      0000:02:00.0 p1p1: link d<br>
      own<br>
      Jan 30 11:26:57 localhost NetworkManager[1675]: &lt;info&gt;
      (p1p1): carrier now OFF (<br>
      device state 100, deferring action for 4 seconds)<br>
      Jan 30 11:27:01 localhost NetworkManager[1675]: &lt;info&gt;
      (p1p1): device state chan<br>
      ge: activated -&gt; unavailable (reason 'carrier-changed') [100 20
      40]<br>
      Jan 30 11:27:02 localhost NetworkManager[1675]: &lt;info&gt;
      (p1p1): deactivating devi<br>
      ce (reason 'carrier-changed') [40]<br>
      Jan 30 11:27:02 localhost NetworkManager[1675]: &lt;info&gt;
      (p1p1): canceled DHCP tra<br>
      nsaction, DHCP client pid 1750<br>
      Jan 30 11:27:02 localhost avahi-daemon[698]: Withdrawing address
      record for 192.<br>
      168.2.104 on p1p1.<br>
      Jan 30 11:27:02 localhost avahi-daemon[698]: Leaving mDNS
      multicast group on interface p1p1.IPv4 with address 192.168.2.104.<br>
      Jan 30 11:27:02 localhost avahi-daemon[698]: Interface p1p1.IPv4
      no longer relevant for mDNS.<br>
      Jan 30 11:27:02 localhost dbus-daemon[718]: dbus[718]: [system]
      Activating service name='org.freedesktop.nm_dispatcher' (using
      servicehelper)<br>
      Jan 30 11:27:02 localhost dbus[718]: [system] Activating service
      name='org.freedesktop.nm_dispatcher' (using servicehelper)<br>
      Jan 30 11:27:02 localhost dbus-daemon[718]: dbus[718]: [system]
      Successfully activated service 'org.freedesktop.nm_dispatcher'<br>
      Jan 30 11:27:02 localhost dbus[718]: [system] Successfully
      activated service 'org.freedesktop.nm_dispatcher'<br>
      Jan 30 11:27:02 localhost systemd[1]: PID file /run/sendmail.pid
      not readable (yet?) after start.<br>
      Jan 30 11:27:02 localhost chronyd[709]: Source 77.243.184.65
      offline<br>
      Jan 30 11:27:02 localhost chronyd[709]: Source 85.234.197.2
      offline<br>
      Jan 30 11:27:02 localhost chronyd[709]: Source 194.50.97.34
      offline<br>
      Jan 30 11:27:02 localhost chronyd[709]: Source 81.95.123.221
      offline<br>
      Jan 30 11:27:04 localhost NetworkManager[1675]: &lt;info&gt;
      (wlan0): bringing up device.<br>
      Jan 30 11:27:04 localhost NetworkManager[1675]: &lt;info&gt; WiFi
      hardware radio set enabled<br>
      Jan 30 11:30:21 localhost kernel: [ 1403.792824] ICMPv6: process
      `sysctl' is using deprecated sysctl (syscall)
      net.ipv6.neigh.default.base_reachable_time - use
      net.ipv6.neigh.default.base_reachable_time_ms instead<br>
      Jan 30 11:30:21 localhost kernel: [ 1403.795504]
      nr_pdflush_threads exported in /proc is scheduled for removal<br>
      Jan 30 11:30:21 localhost kernel: [ 1403.795614] sysctl: The
      scan_unevictable_pages sysctl/node-interface has been disabled for
      lack of a legitimate use case.&nbsp; If you have one, please send an
      email to <a moz-do-not-send="true"
        class="moz-txt-link-abbreviated"
        href="mailto:linux-mm@kvack.org">linux-mm@kvack.org</a>.<br>
      Jan 30 11:32:12 localhost NetworkManager[1675]: &lt;info&gt;
      caught signal 15, shutting down normally.<br>
      Jan 30 11:32:12 localhost NetworkManager[1675]: &lt;info&gt;
      (p1p1): now unmanaged<br>
      Jan 30 11:32:12 localhost NetworkManager[1675]: &lt;info&gt;
      (p1p1): device state change: unavailable -&gt; unmanaged (reason
      'removed') [20 10 36]<br>
      Jan 30 11:32:12 localhost NetworkManager[1675]: &lt;info&gt;
      (p1p1): cleaning up...<br>
      Jan 30 11:32:12 localhost NetworkManager[1675]: &lt;info&gt;
      (p1p1): taking down device.<br>
      Jan 30 11:32:12 localhost avahi-daemon[698]: Withdrawing address
      record for fe80::226:2dff:fecc:ab6a on p1p1.<br>
      Jan 30 11:32:12 localhost NetworkManager[1675]: &lt;info&gt;
      (wlan0): now unmanaged<br>
      Jan 30 11:32:12 localhost NetworkManager[1675]: &lt;info&gt;
      (wlan0): device state change: unavailable -&gt; unmanaged (reason
      'removed') [20 10 36]<br>
      Jan 30 11:32:12 localhost NetworkManager[1675]: &lt;info&gt;
      exiting (success)<br>
      Jan 30 11:32:12 localhost dbus-daemon[718]: dbus[718]: [system]
      Activating via systemd: service
      name='org.freedesktop.NetworkManager'
      unit='dbus-org.freedesktop.NetworkManager.service'<br>
      Jan 30 11:32:12 localhost dbus[718]: [system] Activating via
      systemd: service name='org.freedesktop.NetworkManager'
      unit='dbus-org.freedesktop.NetworkManager.service'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      NetworkManager (version 0.9.6.4-3.fc17) is starting...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt; Read
      config file /etc/NetworkManager/NetworkManager.conf<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt; WEXT
      support is enabled<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt; VPN:
      loaded org.freedesktop.NetworkManager.openconnect<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt; VPN:
      loaded org.freedesktop.NetworkManager.openvpn<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt; VPN:
      loaded org.freedesktop.NetworkManager.pptp<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt; VPN:
      loaded org.freedesktop.NetworkManager.vpnc<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      Acquired D-Bus service com.redhat.ifcfgrh1<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      Loaded plugin ifcfg-rh: (c) 2007 - 2010 Red Hat, Inc.&nbsp; To report
      bugs please use the NetworkManager mailing list.<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      Loaded plugin keyfile: (c) 2007 - 2010 Red Hat, Inc.&nbsp; To report
      bugs please use the NetworkManager mailing list.<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-telenet-DE330 ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'telenet-DE330'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-wirelessleuven-STP
      ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'wirelessleuven-STP'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-bbox2-d966 ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'bbox2-d966'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-bbox2-5008 ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'bbox2-5008'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-SAFEGE ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'SAFEGE'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-bbox2-ba44 ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'bbox2-ba44'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing
      /etc/sysconfig/network-scripts/ifcfg-Auto_Wifi_Noe_van_Oordt ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'Auto Wifi Noe van Oordt'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing
      /etc/sysconfig/network-scripts/ifcfg-LEUVEN_LANGUES_LOUNGE_ ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'LEUVEN LANGUES LOUNGE '<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-Guest1 ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'Guest1'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-Welcome ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'Welcome'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-Mireille ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'Mireille'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-Auto_MondialGuest ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'Auto MondialGuest'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-lo ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-TELENETHOMESPOT ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'TELENETHOMESPOT'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-p1p1 ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;warn&gt;
      failed to allocate link cache: (-10) Operation not supported<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'System p1p1'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-Auto_linksys ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'Auto linksys'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-Sappi_Free_Access ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'Sappi_Free_Access'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-bbox2-21e4 ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'bbox2-21e4'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-Auto_CP-Guest ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'Auto CP-Guest'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'GUEST'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing
      /etc/sysconfig/network-scripts/ifcfg-Auto_belkin.797.guests ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'Auto belkin.797.guests'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:
      parsing /etc/sysconfig/network-scripts/ifcfg-Auto_gun-bxl ...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]:&nbsp;&nbsp;&nbsp; ifcfg-rh:&nbsp;&nbsp;&nbsp;&nbsp;
      read connection 'Auto gun-bxl'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      modem-manager is now available<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      monitoring kernel firmware directory '/lib/firmware'.<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      rfkill2: found WiFi radio killswitch (at
      /sys/devices/pci0000:00/0000:00:1c.3/0000:03:00.0/ieee80211/phy0/rfkill2)

      (driver iwlwifi)<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      rfkill0: found WiFi radio killswitch (at
      /sys/devices/platform/acer-wmi/rfkill/rfkill0) (platform driver
      acer-wmi)<br>
      Jan 30 11:32:13 localhost dbus-daemon[718]: dbus[718]: [system]
      Successfully activated service 'org.freedesktop.NetworkManager'<br>
      Jan 30 11:32:13 localhost dbus[718]: [system] Successfully
      activated service 'org.freedesktop.NetworkManager'<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt; WiFi
      disabled by radio killswitch; enabled by state file<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt; WWAN
      enabled by radio killswitch; enabled by state file<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt; WiMAX
      enabled by radio ki<br>
      llswitch; enabled by state file<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      Networking is enabled by <br>
      state file<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;warn&gt;
      failed to allocate link cache: (-10) Operation not supported<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (p1p1): carrier is OFF<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (p1p1): new Ethernet device (driver: 'r8169' ifindex: 2)<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (p1p1): exported as /org/freedesktop/NetworkManager/Devices/0<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (p1p1): now managed<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (p1p1): device state change: unmanaged -&gt; unavailable (reason
      'managed') [10 20 2]<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (p1p1): bringing up device.<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (p1p1): preparing device.<br>
      Jan 30 11:32:13 localhost kernel: [ 1514.823973] r8169
      0000:02:00.0 p1p1: link down<br>
      Jan 30 11:32:13 localhost kernel: [ 1514.824041] IPv6:
      ADDRCONF(NETDEV_UP): p1p1: link is not ready<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (p1p1): deactivating device (reason 'managed') [2]<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (wlan0): using nl80211 for WiFi device control<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;warn&gt;
      (wlan0): driver supports Access Point (AP) mode<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (wlan0): new 802.11 WiFi device (driver: 'iwlwifi' ifindex: 3)<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (wlan0): exported as /org/freedesktop/NetworkManager/Devices/1<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (wlan0): now managed<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (wlan0): device state cha<br>
      nge: unmanaged -&gt; unavailable (reason 'managed') [10 20 2]<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (wlan0): bringing up devi<br>
      ce.<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;info&gt;
      (wlan0): deactivating dev<br>
      ice (reason 'managed') [2]<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;warn&gt;
      /sys/devices/virtual/net/<br>
      lo: couldn't determine device driver; ignoring...<br>
      Jan 30 11:32:13 localhost NetworkManager[2039]: &lt;warn&gt;
      /sys/devices/virtual/net/<br>
      lo: couldn't determine device driver; ignoring...<br>
      Jan 30 11:32:19 localhost NetworkManager[2039]: &lt;info&gt;
      (wlan0): bringing up devi<br>
      ce.<br>
      Jan 30 11:32:19 localhost NetworkManager[2039]: &lt;info&gt; WiFi
      hardware radio set e<br>
      nabled<br>
      Jan 30 11:32:35 localhost avahi-daemon[698]: Got SIGTERM,
      quitting.<br>
      Jan 30 11:32:35 localhost avahi-daemon[698]: avahi-daemon 0.6.31
      exiting.<br>
      Jan 30 11:32:35 localhost dbus-daemon[718]: dbus[718]: [system]
      Activating via s<br>
      ystemd: service name='org.freedesktop.Avahi'
      unit='dbus-org.freedesktop.Avahi.se<br>
      rvice'<br>
      Jan 30 11:32:35 localhost dbus[718]: [system] Activating via
      systemd: service na<br>
      me='org.freedesktop.Avahi'
      unit='dbus-org.freedesktop.Avahi.service'<br>
      Jan 30 11:32:35 localhost avahi-daemon[2048]: Process 698 died: No
      such process;<br>
      &nbsp;trying to remove PID file. (/var/run/avahi-daemon//pid)<br>
      Jan 30 11:32:35 localhost avahi-daemon[2048]: Found user 'avahi'
      (UID 70) and gr<br>
      oup 'avahi' (GID 70).<br>
      Jan 30 11:32:35 localhost avahi-daemon[2048]: Successfully dropped
      root privileg<br>
      es.<br>
      Jan 30 11:32:35 localhost avahi-daemon[2048]: avahi-daemon 0.6.31
      starting up.<br>
      Jan 30 11:32:35 localhost dbus-daemon[718]: dbus[718]: [system]
      Successfully act<br>
      ivated service 'org.freedesktop.Avahi'<br>
      Jan 30 11:32:35 localhost dbus[718]: [system] Successfully
      activated service 'or<br>
      g.freedesktop.Avahi'<br>
      Jan 30 11:32:35 localhost avahi-daemon[2048]: Successfully called
      chroot().<br>
      Jan 30 11:32:35 localhost avahi-daemon[2048]: Successfully dropped
      remaining capabilities.<br>
      Jan 30 11:32:35 localhost avahi-daemon[2048]: Loading service file
      /services/udisks.service.<br>
      Jan 30 11:32:35 localhost avahi-daemon[2048]: System host name is
      set to 'localhost'. This is not a suitable mDNS host name, looking
      for alternatives.<br>
      Jan 30 11:32:35 localhost avahi-daemon[2048]: Network interface
      enumeration completed.<br>
      Jan 30 11:32:35 localhost avahi-daemon[2048]: Registering HINFO
      record with values 'I686'/'LINUX'.<br>
      Jan 30 11:32:35 localhost avahi-daemon[2048]: Server startup
      complete. Host name is linux.local. Local service cookie is
      960404764.<br>
      Jan 30 11:32:35 localhost avahi-daemon[2048]: Service "linux"
      (/services/udisks.service) successfully established.<br>
      Jan 30 11:32:40 localhost NetworkManager[2039]: &lt;info&gt;
      (wlan0): bringing up device.<br>
      Jan 30 11:32:40 localhost NetworkManager[2039]: &lt;info&gt; WiFi
      hardware radio set enabled<br>
      Jan 30 11:32:44 localhost NetworkManager[2039]: &lt;info&gt;
      (wlan0): bringing up device.<br>
      Jan 30 11:32:44 localhost NetworkManager[2039]: &lt;info&gt; WiFi
      hardware radio set enabled<br>
      <br>
      *************************************************<br>
      ~/.xsession-errors<br>
      <br>
      (gnome-shell:1274): Clutter-CRITICAL **: clutter_text_get_text:
      assertion `CLUTT<br>
      ER_IS_TEXT (self)' failed<br>
      <br>
      (gnome-shell:1274): Clutter-CRITICAL **: clutter_text_set_text:
      assertion `CLUTT<br>
      ER_IS_TEXT (self)' failed<br>
      <br>
      (gnome-control-center:1640): GLib-GObject-CRITICAL **:
      g_object_unref: assertion<br>
      &nbsp;`G_IS_OBJECT (object)' failed<br>
      ** Message: applet now removed from the notification area<br>
      ** Message: NM disappeared<br>
      ** Message: applet now embedded in the notification area<br>
      <br>
      (gnome-shell:1274): Clutter-CRITICAL **:
      clutter_text_get_editable: assertion `C<br>
      LUTTER_IS_TEXT (self)' failed<br>
      <br>
      (gnome-shell:1274): Clutter-CRITICAL **: clutter_text_get_text:
      assertion `CLUTT<br>
      ER_IS_TEXT (self)' failed<br>
      <br>
      ******************************************<br>
      <br>
      [marleen@localhost ~]$ lsmod | grep iwl<br>
      iwldvm&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 219970&nbsp; 0 <br>
      mac80211&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 461829&nbsp; 1 iwldvm<br>
      iwlwifi&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 91876&nbsp; 1 iwldvm<br>
      cfg80211&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 171182&nbsp; 3 iwlwifi,mac80211,iwldvm<br>
      <br>
      <br>
      <br>
    </div>
    <br>
  </body>
</html>

--------------080509040200000000010307--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
