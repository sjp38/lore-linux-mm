Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: 2.5.59-mm5 got stuck during boot
Date: Fri, 24 Jan 2003 12:44:05 -0500
References: <20030123195044.47c51d39.akpm@digeo.com> <3E3146BC.4D0A1A64@aitel.hist.no>
In-Reply-To: <3E3146BC.4D0A1A64@aitel.hist.no>
MIME-Version: 1.0
Message-Id: <200301241244.05268.tomlins@cam.org>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On January 24, 2003 08:59 am, Helge Hafting wrote:
> Andrew Morton wrote:
> > .  -mm5 has the first cut of Nick Piggin's anticipatory I/O scheduler.
>
> Interesting, but it didn't boot completely.
> It came all the way to mount root from /dev/md0  (dirty raid1)
> freed 316k of kernel memory, and then nothing happened.
> numloc and capslock worked, and so did sysrq.
> It was as if the kernel "forgot" to run init.
> Nothing happened, but it wasn't hanging either.
>
> sysrq "show pc" told me something about default idle.
> I noticed that the root raid-1 came up dirty. (2.5.X
> seems unable to shut down a raid-1 device "clean" if
> it  happens to be the root fs.  So there's _always_
> a bootup resync that starts as soon as the raid
> is autodetected. (Before mounting root)
>
>
> This is a UP P4, preempt, no module support,
> compiled with gcc 2.95.4 from debian.
>
> Stock 2.5.59 works, the only config change is to enable
> that new CONFIG_HANGCHECK_TIMER.

Same story here - almost.  No raid, using debian and the same
compiler along with multiple disks and fs(es).

Following are the messages and a sysrq+T:

Hope this helps,
Ed Tomlinson

---------
Linux version 2.5.59-mm5 (ed@oscar) (gcc version 2.95.4 20011002 (Debian prerelease)) #1 Fri Jan 24 12:09:29 EST 2003
Video mode to be used for restore is f00
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 00000000000a0000 (usable)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000001fff0000 (usable)
 BIOS-e820: 000000001fff0000 - 000000001fff3000 (ACPI NVS)
 BIOS-e820: 000000001fff3000 - 0000000020000000 (ACPI data)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
511MB LOWMEM available.
On node 0 totalpages: 131056
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 126960 pages, LIFO batch:16
  HighMem zone: 0 pages, LIFO batch:1
Building zonelist for node : 0
Kernel command line: auto BOOT_IMAGE=Linux ro root=2103 console=tty0 console=ttyS0,38400 vga=ask idebus=33 profile=1
ide_setup: idebus=33
kernel profiling enabled
Initializing CPU#0
PID hash table entries: 2048 (order 11: 16384 bytes)
Detected 400.850 MHz processor.
Console: colour VGA+ 80x25
Calibrating delay loop... 790.52 BogoMIPS
Memory: 513308k/524224k available (1336k kernel code, 10184k reserved, 713k data, 80k init, 0k highmem)
Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
Inode-cache hash table entries: 32768 (order: 6, 262144 bytes)
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
-> /dev
-> /dev/console
-> /root
Enabling new style K6 write allocation for 511 Mb
CPU: L1 I Cache: 32K (32 bytes/line), D cache 32K (32 bytes/line)
CPU: L2 Cache: 256K (32 bytes/line)
CPU: AMD-K6(tm) 3D+ Processor stepping 01
Checking 'hlt' instruction... OK.
POSIX conformance testing by UNIFIX
Linux NET4.0 for Linux 2.4
Based upon Swansea University Computer Society NET3.039
Initializing RT netlink socket
mtrr: v2.0 (20020519)
PCI: PCI BIOS revision 2.10 entry at 0xfb520, last bus=1
PCI: Using configuration type 1
BIO: pool of 256 setup, 15Kb (60 bytes/bio)
biovec pool[0]:   1 bvecs: 256 entries (12 bytes)
biovec pool[1]:   4 bvecs: 256 entries (48 bytes)
biovec pool[2]:  16 bvecs: 256 entries (192 bytes)
biovec pool[3]:  64 bvecs: 256 entries (768 bytes)
biovec pool[4]: 128 bvecs: 256 entries (1536 bytes)
biovec pool[5]: 256 bvecs: 256 entries (3072 bytes)
Linux Plug and Play Support v0.94 (c) Adam Belay
pnp: Enabling Plug and Play Card Services.
PnPBIOS: Found PnP BIOS installation structure at 0xc00fc160
PnPBIOS: PnP BIOS version 1.0, entry 0xf0000:0xc188, dseg 0xf0000
PnPBIOS: 14 nodes reported by PnP BIOS; 14 recorded by driver
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
block request queues:
 128 requests per read queue
 128 requests per write queue
 8 requests per batch
 enter congestion at 15
 exit congestion at 17
drivers/usb/core/usb.c: registered new driver usbfs
drivers/usb/core/usb.c: registered new driver hub
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
PCI: Using IRQ router VIA [1106/0586] at 00:07.0
aio_setup: sizeof(struct page) = 40
Journalled Block Device driver loaded
Initializing Cryptographic API
Activating ISA DMA hang workarounds.
Serial: 8250/16550 driver $Revision: 1.90 $ IRQn sharing disablttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
ttyS2 at I/O 0x3e8 (irq = 4) is a 16550A
pty: 256 Unix98 ptys configured
Linux agpgart interface v0.100 (c) Dave Jones
agpgart: Detected VIA MVP3 chipset
agpgart: Maximum main memory to use for agp memory: 439M
agpgart: AGP aperture is 64M @ 0xe0000000
[drm] Initialized mga 3.1.0 20021029 on minor 0
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes
VP_IDE: IDE controller at PCI slot 00:07.1
VP_IDE: chipset revision 6
VP_IDE: not 100% native mode: will probe irqs later
VP_IDE: VIA vt82c586b (rev 47) IDE UDMA33 controller on pci00:07.1
    ide0: BM-DMA at 0xa000-0xa007, BIOS settings: hda:DMA, hdb:DMA
    ide1: eBM-DMA at 0xa00-0xa00f, BIOS settings: hdc:DMA, hdd:DMA
hda: QUANTUM FIREBALLP KA13.6, ATA DISK drive
hda: DMA disabled
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
hdc: AOPEN 16XDVD-ROM/AMH 20020328, ATAPI CD/DVD-ROM drive
hdd: HP COLORADO 20GB, ATAPI TAPE drive
hdc: DMA disabled
hdd: DMA disabled
ide1 at 0x170-0x177,0x376 on irq 15
PDC20267: IDE controller at PCI slot 00:09.0
PCI: Found IRQ 12 for device 00:09.0
PDC20267: chipset revision 2
PDC20267: not 100% native mode: will probe irqs later
PDC20267: ROM enabled at 0xeb000000
PDC20267: (U)DMA Burst Bit ENABLED Primary PCI Mode Secondary PCI Mode.
    ide2: BM-DMA at 0xbc00-0xbc07, BIOS settings: hde:DMA, hdf:pio
    ide3: BM-DMA at 0xbc08-0xbc0f, BIOS settings: hdg:DMA, hdh:DMA
hde: QUANTUM FIREBALLP AS40.0, ATA DISK drive
ide2 at 0xac00-0xac07,0xb002 on irq 12
hdg: QUANTUM FIREBALLP AS40.0, ATA DISK drive
ide3 at 0xb400-0xb407,0xb802 on irq 12
hda: host protected area => 1
hda: 27067824 sectors (13859 MB) w/371KiB Cache, CHS=26853/16/63, UDMA(33)
 hda: hda1 hda2 hda3 hda4 < hda5 >
hde: host protected area => 1
hde: 78177792 sectors (40027 MB) w/1902KiB Cache, CHS=77557/16/63, UDMA(100)
 hde: hde1 hde2 hde3 hde4 < hde5 >
hdg: host protected area => 1
hdg: 78177792 sectors (40027 MB) w/1902KiB Cache, CHS=77557/16/63, UDMA(100)
 hdg: hdg1 hdg2 hdg3 hdg4 < hdg5 >
drivers/usb/host/uhci-hcd.c: USB Universal Host Controller Interface driver v2.0
uhci-hcd 00:07.2: VIA Technologies, In USB
uhci-hcd 00:07.2: irq 10, io base 0000a400
Please use the 'usbfs' filetype instead, the 'usbdevfs' name is deprecated.
uhci-hcd 00:07.2: new USB bus registered, assigned bus number 1
hub 1-0:0: USB hub found
hub 1-0:0: 2 ports detected
mice: PS/2 mouse device common for all mice
input: AT Set 2 keyboard on isa0060/serio0
serio: i8042 KBD port at 0x60,0x64 irq 1
NET4: Linux TCP/IP 1.0 for NET4.0
IP: routing cache hash table of 4096 buckets, 32Kbytes
TCP: Hash tables configured (established 32768 bind 32768)
NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
found reiserfs format "3.6" with standard journal
hub 1-0:0: debounce: port 1: delay 100ms stable 4 status 0x101
hub 1-0:0: new USB device on port 1, assigned address 2
hub 1-1:0: USB hub found
Reiserfs journal params: device ide2(33,3), size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
reiserfs: checking transaction log (ide2(33,3)) for (ide2(33,3))
hub 1-1:0: 4 ports detected
Using r5 hash to sort names
VFS: Mounted root (reiserfs filesystem) readonly.
Freeing unused kernel memory: 80k freed
hub 1-0:0: debounce: port 2: delay 100ms stable 4 status 0x301
hub 1-0:0: new USB device on port 2, assigned address 3
SysRq : Show State

                         free                        sibling
  task             PC    stack   pid father child younger older
init          D 00000086 12112     1      0     2               (NOTLB)
Call Trace:
 [<c0113f5a>] io_schedule+0xe/0x18
 [<c0127654>] __lock_page+0x90/0xac
 [<c0114694>] autoremove_wake_function+0x0/0x38
 [<c0114694>] autoremove_wake_function+0x0/0x38
 [<c01284cb>] filemap_nopage+0x16b/0x2ac
 [<c01322d4>] do_no_page+0x78/0x2b4
 [<c013257d>e] handle_mm_fau+0x6d/0x10c
 [<c0111cb7>] do_page_fault+0x137/0x414
 [<c0111b80>] do_page_fault+0x0/0x414
 [<c013e9aa>] __fput+0xe6/0x108
 [<c0133f01>] unmap_vma+0x69/0x70
 [<c0133f1c>] unmap_vma_list+0x14/0x20
 [<c013423b>] do_munmap+0x127/0x134
 [<c013428c>] sys_munmap+0x44/0x60
 [<c0108cbd>] error_code+0x2d/0x40

ksoftirqd/0   S 00000046 4294963856     2      1             3       (L-TLB)
Call Trace:
 [<c01196e9>] ksoftirqd+0x59/0xc8
 [<c0119711>] ksoftirqd+0x81/0xc8
 [<c0119690>] ksoftirqd+0x0/0xc8
 [<c0106e45>] kernel_thread_helper+0x5/0xc

events/0      D 00000046 4294953780     3      1    12       4     2 (L-TLB)
Call Trace:
 [<c0113463>] wait_for_completion+0x1b/0xe0
 [<c01134e5>] wait_for_completion+0x9d/0xe0
 [<c01132c8>] default_wake_function+0x0/0x2c
 [<c01132c8>] default_wake_function+0x0/0x2c
 [<c0115cba>] do_fork+0x10e/0x130
 [<c0106ec5>] kernel_thread+0x79/0x94
 [<c0121758>] ____call_usermodehelper+0x0/0x3c
 [<c0106e40>] kernel_thread_helper+0x0/0xc
 [<c01217a9>] __call_usermodehelper+0x15/0x28
 [<c0121758>] ____call_usermodehelper+0x0/0x3c
 [<c0121cf2>] worker_thread+0x1fa/0x2dc
 [<c0121af8>] worker_thread+0x0/0x2dc
 [<c0121794>] __call_usermodehelper+0x0/0x28
 [<c01132c8>] default_wake_function+0x0/0x2c
 [<c01132c8>] default_wake_function+0x0/0x2c
 [<c0106e45>] kernel_thread_helper+0x5/0xc

khubd         D 00000046 4292756256     4      1             5     3 (L-TLB)
Call Trace:
 [<c0113463>] wait_for_completion+0x1b/0xe0
 [<c01134e5>] wait_for_completion+0x9d/0xe0
 [<c01132c8>] default_wake_function+0x0/0x2c
 [<c01132c8>] default_wake_function+0x0/0x2c
 [<c0121903>] call_usermodehelper+0x147/0x15c
 [<c01ec6d0>] usb_hotplug+0x0/0x1d8
 [<c0121794>] __call_usermodehelper+0x0/0x28
 [<c0121794>] __call_usermodehelper+0x0/0x28
 [<c01b0fc9>] do_hotplug+0x1e9/0x21c
 [<c01b102c>] dev_hotplug+0x30/0x3c
 [<c01ec6d0>] usb_hotplug+0x0/0x1d8
 [<c01af34e>] device_add+0x112/0x148
 [<c01ed112>] usb_new_device+0x366/0x4c4
 [<c0116a26>] printk+0x11e/0x140
 [<c01eec0f>] usb_hub_port_connect_change+0x24f/0x2e4
 [<c01eeddb>] usb_hub_events+0x137/0x2c4
 [<c01eef98>] usb_hub_thread+0x30/0xd8
 [<c01eef68>] usb_hub_thread+0x0/0xd8
 [<c01132c8>] default_wake_function+0x0/0x2c
 [<c0106e45>] kernel_thread_helper+0x5/0xc

pdflush       S 00000046 4292616332     5      1             6     4 (L-TLB)
Call Trace:
 [<c012ba65>] __pdflush+0xf5/0x1f8
 [<c012bb68>] pdflush+0x0/0x14
 [<c012bb73>] pdflush+0xb/0x14
 [<c0106e45>] kernel_thread_helper+0x5/0xc

pdflush       S 00000046 14412     6      1             7     5 (L-TLB)
Call Trace:
 [<c012ba65>] __pdflush+0xf5/0x1f8
 [<c012bb68>] pdflush+0x0/0x14
 [<c012bb73>] pdflush+0xb/0x14
 [<c0106e45>] kernel_thread_helper+0x5/0xc

kswapd0       S 00000046 4294958936     7      1             8     6 (L-TLB)
Call Trace:
 [<c012fb7a>] kswapd+0xea/0x10c
 [<c012fa90>] kswapd+0x0/0x10c
 [<c0109c3b>] math_state_restore+0x27/0x38
 [<c0108d15>] device_not_available+0x25/0x2a
 [<c010e170>] save_init_fpu+0x1c/0x38
 [<c01132b0>] preempt_schedule+0x28/0x40
 [<c0112b7c>] schedule_tail+0x1c/0x4c
 [<c0108915>] ret_from_fork+0x5/0x20
 [<c012fa90>] kswapd+0x0/0x10c
 [<c0114694>] autoremove_wake_function+0x0/0x38
 [<c0114694>] autoremove_wake_function+0x0/0x38
 [<c0106e45>] kernel_thre<ad_helper+0x5/0
aio/0         S 00000046 429488[6880     8              9     7 (L-TLB)
Call Trace:
 [<c0121c49>] worker_thread+0x151/0x2dc
 [<c0121af8>] worker_thread+0x0/0x2dc
 [<c0108915>] ret_from_fork+0x5/0x20
 [<c01132c8>] default_wake_function+0x0/0x2c
 [<c01132c8>] default_wake_function+0x0/0x2c
 [<c0106e45>] kernel_thread_helper+0x5/0xc

kpnpbiosd     T 00000046 4294880228     9      1            10     8 (L-TLB)
Call Trace:
 [<c011820c>] do_exit+0x3c4/0x3d4
 [<c0118232>] complete_and_exit+0x16/0x18
 [<c01a769d>] pnp_dock_thread+0x99/0xf4
 [<c01a7604>] pnp_dock_thread+0x0/0xf4
 [<c0106e45>] kernel_thread_helper+0x5/0xc

kseriod       S 00000046 4294112016    10      1            11     9 (L-TLB)
Call Trace:
 [<c01ff629>] serio_thread+0x9d/0x124
 [<c01ff58c>] serio_thread+0x0/0x124
 [<c01132c8>] default_wake_function+0x0/0x2c
 [<c0106e45>] kernel_thread_helper+0x5/0xc

reiserfs/0    S 00000046  8096    11      1                  10 (L-TLB)
Call Trace:
 [<c0121c49>] worker_thread+0x151/0x2dc
 [<c0121af8>] worker_thread+0x0/0x2dc
 [<c0108915>] ret_from_fork+0x5/0x20
 [<c01132c8>] default_wake_function+0x0/0x2c
 [<c01132c8>] default_wake_function+0x0/0x2c
 [<c0106e45>] kernel_thread_helper+0x5/0xc

events/0      D 00000046 4294304092    12      3                     (L-TLB)
Call Trace:
 [<c0113f5a>] io_schedule+0xe/0x18
 [<c013ec50>] __wait_on_buffer+0x78/0x94
 [<c0114694>] autoremove_wake_function+0x0/0x38
 [<c0114694>] autoremove_wake_function+0x0/0x38
 [<c013fbfc>] __bread_slow+0x6c/0x94
 [<c013fe4c>] __bread+0x28/0x30
 [<c018d5c9>] search_by_key+0x65/0xd64
 [<c01792a4>] search_by_entry_key+0x20/0x1b4
 [<c01797e9>] reiserfs_find_entry+0x7d/0x134
 [<c0179919>] reiserfs_lookup+0x79/0x168
 [<c012d14e>] kmem_cache_alloc+0x22/0x5c
 [<c01515ef>] d_alloc+0x1b/0x18c
 [<c0148b5f>] real_lookup+0x5f/0xcc
 [<c0148dfe>] do_lookup+0xb2/0x1fc
 [<c01494c7>] link_path_walk+0x57f/0x8c4
 [<c0149af4>] path_lookup+0x128/0x12c
 [<c014640b>] open_exec+0x1b/0xb8
 [<c01471ca>] do_execve+0x1e/0x204
 [<c012d14e>] kmem_cache_alloc+0x22/0x5c
 [<c014887e>] getname+0x5e/0x9c
 [<c0107584>] sys_execve+0x2c/0x64
 [<c0108a57>] syscall_call+0x7/0xb
 [<c01214e3>] exec_usermodehelper+0x333/0x360
 [<c0121785>] ____call_usermodehelper+0x2d/0x3c
 [<c0121758>] ____call_usermodehelper+0x0/0x3c
 [<c0106e45>] kernel_thread_helper+0x5/0xc

SysRq : Emergency Sync
Syncing device ide2(33,3) ... OK
Done.
SysRq : Emergency Remount R/O
Remounting device ide2(33,3) ... R/O
Done.
SysRq : Resetting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
