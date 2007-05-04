Date: 4 May 2007 10:26:39 -0400
Message-ID: <20070504142639.6603.qmail@science.horizon.com>
From: linux@horizon.com
Subject: swapper: page allocation failure. order:0, mode:0x20
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux@horizon.com
List-ID: <linux-mm.kvack.org>

I'm not used to seeing order-0 allocation failures on lightly loaded 2 GB
(amd64, so it's all low memory) machines.

Can anyone tell me what happened?  It happened just as I was transferring
a large file to the machine for later crunching (the "sgrep" program is
a local number-crunching application that was getting alignment errors
in SSE code), and the network stopped working.  The "NETDEV WATCHDOG"
message happened a few minutes later, during the head-scratching phase.

I ended up rebooting the machine to get on with the number-crunching,
but this is a bit mysterious.  The ethernet driver is forcedeth.  Does it
appear to be at fault?

Here's a dmesg log, with /proc/*info and lspci appended.
amd64 uniprocessor, with ECC memory.  Stock 2.6.21 + linuxpps patches.

Thanks for any suggestions!


er [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard as /class/input/input2
input: PC Speaker as /class/input/input3
input: PS/2 Generic Mouse as /class/input/input4
i2c_adapter i2c-0: nForce2 SMBus adapter at 0x1c00
i2c_adapter i2c-1: nForce2 SMBus adapter at 0x1c40
it87: Found IT8712F chip at 0x290, revision 7
it87: in3 is VCC (+5V)
it87: in7 is VCCH (+5V Stand-By)
md: raid0 personality registered for level 0
md: raid1 personality registered for level 1
md: raid10 personality registered for level 10
raid6: int64x1   2052 MB/s
raid6: int64x2   2606 MB/s
raid6: int64x4   2579 MB/s
raid6: int64x8   1838 MB/s
raid6: sse2x1    2817 MB/s
raid6: sse2x2    3738 MB/s
raid6: sse2x4    4021 MB/s
raid6: using algorithm sse2x4 (4021 MB/s)
md: raid6 personality registered for level 6
md: raid5 personality registered for level 5
md: raid4 personality registered for level 4
raid5: automatically using best checksumming function: generic_sse
   generic_sse:  7089.000 MB/sec
raid5: using function: generic_sse (7089.000 MB/sec)
EDAC MC: Ver: 2.0.1 Apr 26 2007
netem: version 1.2
Netfilter messages via NETLINK v0.30.
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
NET: Registered protocol family 15
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
powernow-k8: Found 1 AMD Athlon(tm) 64 Processor 3700+ processors (version 2.00.00)
powernow-k8:    0 : fid 0xe (2200 MHz), vid 0x6
powernow-k8:    1 : fid 0xc (2000 MHz), vid 0x8
powernow-k8:    2 : fid 0xa (1800 MHz), vid 0xa
powernow-k8:    3 : fid 0x2 (1000 MHz), vid 0x12
md: Autodetecting RAID arrays.
md: autorun ...
md: considering sdf4 ...
md:  adding sdf4 ...
md: sdf3 has different UUID to sdf4
md: sdf2 has different UUID to sdf4
md: sdf1 has different UUID to sdf4
md:  adding sde4 ...
md: sde3 has different UUID to sdf4
md: sde2 has different UUID to sdf4
md: sde1 has different UUID to sdf4
md:  adding sdd4 ...
md: sdd3 has different UUID to sdf4
md: sdd2 has different UUID to sdf4
md: sdd1 has different UUID to sdf4
md:  adding sdc4 ...
md: sdc3 has different UUID to sdf4
md: sdc2 has different UUID to sdf4
md: sdc1 has different UUID to sdf4
md:  adding sdb4 ...
md: sdb3 has different UUID to sdf4
md: sdb2 has different UUID to sdf4
md: sdb1 has different UUID to sdf4
md:  adding sda4 ...
md: sda3 has different UUID to sdf4
md: sda2 has different UUID to sdf4
md: sda1 has different UUID to sdf4
md: created md5
md: bind<sda4>
md: bind<sdb4>
md: bind<sdc4>
md: bind<sdd4>
md: bind<sde4>
md: bind<sdf4>
md: running: <sdf4><sde4><sdd4><sdc4><sdb4><sda4>
raid5: device sdf4 operational as raid disk 5
raid5: device sde4 operational as raid disk 4
raid5: device sdd4 operational as raid disk 3
raid5: device sdc4 operational as raid disk 2
raid5: device sdb4 operational as raid disk 1
raid5: device sda4 operational as raid disk 0
raid5: allocated 6362kB for md5
raid5: raid level 5 set md5 active with 6 out of 6 devices, algorithm 2
RAID5 conf printout:
 --- rd:6 wd:6
 disk 0, o:1, dev:sda4
 disk 1, o:1, dev:sdb4
 disk 2, o:1, dev:sdc4
 disk 3, o:1, dev:sdd4
 disk 4, o:1, dev:sde4
 disk 5, o:1, dev:sdf4
md5: bitmap initialized from disk: read 11/11 pages, set 1 bits, status: 0
created bitmap (164 pages) for device md5
md: considering sdf3 ...
md:  adding sdf3 ...
md: sdf2 has different UUID to sdf3
md: sdf1 has different UUID to sdf3
md:  adding sde3 ...
md: sde2 has different UUID to sdf3
md: sde1 has different UUID to sdf3
md:  adding sdd3 ...
md: sdd2 has different UUID to sdf3
md: sdd1 has different UUID to sdf3
md:  adding sdc3 ...
md: sdc2 has different UUID to sdf3
md: sdc1 has different UUID to sdf3
md:  adding sdb3 ...
md: sdb2 has different UUID to sdf3
md: sdb1 has different UUID to sdf3
md:  adding sda3 ...
md: sda2 has different UUID to sdf3
md: sda1 has different UUID to sdf3
md: created md4
md: bind<sda3>
md: bind<sdb3>
md: bind<sdc3>
md: bind<sdd3>
md: bind<sde3>
md: bind<sdf3>
md: running: <sdf3><sde3><sdd3><sdc3><sdb3><sda3>
raid10: raid set md4 active with 6 out of 6 devices
md4: bitmap initialized from disk: read 8/8 pages, set 83 bits, status: 0
created bitmap (126 pages) for device md4
md: considering sdf2 ...
md:  adding sdf2 ...
md: sdf1 has different UUID to sdf2
md: sde2 has different UUID to sdf2
md: sde1 has different UUID to sdf2
md: sdd2 has different UUID to sdf2
md: sdd1 has different UUID to sdf2
md: sdc2 has different UUID to sdf2
md: sdc1 has different UUID to sdf2
md: sdb2 has different UUID to sdf2
md: sdb1 has different UUID to sdf2
md:  adding sda2 ...
md: sda1 has different UUID to sdf2
md: created md3
md: bind<sda2>
md: bind<sdf2>
md: running: <sdf2><sda2>
raid1: raid set md3 active with 2 out of 2 mirrors
md: considering sdf1 ...
md:  adding sdf1 ...
md: sde2 has different UUID to sdf1
md:  adding sde1 ...
md: sdd2 has different UUID to sdf1
md:  adding sdd1 ...
md: sdc2 has different UUID to sdf1
md:  adding sdc1 ...
md: sdb2 has different UUID to sdf1
md:  adding sdb1 ...
md:  adding sda1 ...
md: created md0
md: bind<sda1>
md: bind<sdb1>
md: bind<sdc1>
md: bind<sdd1>
md: bind<sde1>
md: bind<sdf1>
md: running: <sdf1><sde1><sdd1><sdc1><sdb1><sda1>
raid1: raid set md0 active with 6 out of 6 mirrors
md0: bitmap initialized from disk: read 8/8 pages, set 0 bits, status: 0
created bitmap (120 pages) for device md0
md: considering sde2 ...
md:  adding sde2 ...
md:  adding sdd2 ...
md: sdc2 has different UUID to sde2
md: sdb2 has different UUID to sde2
md: created md2
md: bind<sdd2>
md: bind<sde2>
md: running: <sde2><sdd2>
raid1: raid set md2 active with 2 out of 2 mirrors
md: considering sdc2 ...
md:  adding sdc2 ...
md:  adding sdb2 ...
md: created md1
md: bind<sdb2>
md: bind<sdc2>
md: running: <sdc2><sdb2>
raid1: raid set md1 active with 2 out of 2 mirrors
md: ... autorun DONE.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 220k freed
ata1.00: configured for UDMA/100
ata1: EH complete
SCSI device sda: 781422768 512-byte hdwr sectors (400088 MB)
sda: Write Protect is off
sda: Mode Sense: 00 3a 00 00
SCSI device sda: write cache: disabled, read cache: enabled, doesn't support DPO or FUA
ata2.00: configured for UDMA/100
ata2: EH complete
SCSI device sdb: 781422768 512-byte hdwr sectors (400088 MB)
sdb: Write Protect is off
sdb: Mode Sense: 00 3a 00 00
SCSI device sdb: write cache: disabled, read cache: enabled, doesn't support DPO or FUA
ata3.00: configured for UDMA/100
ata3: EH complete
SCSI device sdc: 781422768 512-byte hdwr sectors (400088 MB)
sdc: Write Protect is off
sdc: Mode Sense: 00 3a 00 00
SCSI device sdc: write cache: disabled, read cache: enabled, doesn't support DPO or FUA
ata4.00: configured for UDMA/100
ata4: EH complete
SCSI device sdd: 781422768 512-byte hdwr sectors (400088 MB)
sdd: Write Protect is off
sdd: Mode Sense: 00 3a 00 00
SCSI device sdd: write cache: disabled, read cache: enabled, doesn't support DPO or FUA
ata5.00: configured for UDMA/100
ata5: EH complete
SCSI device sde: 781422768 512-byte hdwr sectors (400088 MB)
sde: Write Protect is off
sde: Mode Sense: 00 3a 00 00
SCSI device sde: write cache: disabled, read cache: enabled, doesn't support DPO or FUA
ata6.00: configured for UDMA/100
ata6: EH complete
SCSI device sdf: 781422768 512-byte hdwr sectors (400088 MB)
sdf: Write Protect is off
sdf: Mode Sense: 00 3a 00 00
SCSI device sdf: write cache: disabled, read cache: enabled, doesn't support DPO or FUA
Adding 1951736k swap on /dev/md1.  Priority:0 extents:1 across:1951736k
Adding 1951736k swap on /dev/md2.  Priority:0 extents:1 across:1951736k
Adding 1951736k swap on /dev/md3.  Priority:0 extents:1 across:1951736k
EXT3 FS on md4, internal journal
serial_core: PPS source #0 "/dev/ttyS0" added to the system 
kjournald starting.  Commit interval 5 seconds
EXT3 FS on md5, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
EXT3 FS on md0, internal journal
sgrep[3724]: segfault at 0000000000000010 rip 000000000804a322 rsp 00000000ffe3bfa0 error 6
sgrep[3758]: segfault at 0000000000000010 rip 000000000804a322 rsp 00000000ff83d1a0 error 6
sgrep[3857]: segfault at 0000000000000010 rip 000000000804a322 rsp 00000000ff87d9e0 error 6
sgrep[3920] general protection rip:804d099 rsp:ffc4fb60 error:0
sgrep[3966] general protection rip:804d099 rsp:ffd49450 error:0
sgrep[3968] general protection rip:804d099 rsp:ffb7da80 error:0
sgrep[4081]: segfault at 0000000000000010 rip 000000000804a322 rsp 00000000ffe28d10 error 6
sgrep[4287] general protection rip:804d099 rsp:ffe9bda0 error:0
sgrep[4378] general protection rip:804d0e1 rsp:ff8740c0 error:0
sgrep[4506] general protection rip:804d0e1 rsp:ffe77ec0 error:0
swapper: page allocation failure. order:0, mode:0x20

Call Trace:
 <IRQ>  [<ffffffff8020e0ee>] __alloc_pages+0x288/0x2a1
 [<ffffffff80233114>] tcp_v4_do_rcv+0x26/0x290
 [<ffffffff8024fb45>] cache_alloc_refill+0x23f/0x45e
 [<ffffffff80298982>] __kmalloc+0x50/0x57
 [<ffffffff80228233>] __alloc_skb+0x5a/0x133
 [<ffffffff803a4a5d>] nv_alloc_rx_optimized+0x58/0x18c
 [<ffffffff803a6e30>] nv_nic_irq_optimized+0x87/0x1d9
 [<ffffffff8020f098>] handle_IRQ_event+0x25/0x53
 [<ffffffff80210374>] __do_softirq+0x46/0x90
 [<ffffffff8028ab8f>] handle_fasteoi_irq+0x5b/0x88
 [<ffffffff8025d66e>] do_IRQ+0xd7/0x132
 [<ffffffff8025ba07>] default_idle+0x0/0x3a
 [<ffffffff802509f1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8045e907>] udp_poll+0x0/0x128
 [<ffffffff8025ba2d>] default_idle+0x26/0x3a
 [<ffffffff8023e163>] cpu_idle+0x3d/0x5c
 [<ffffffff805e58e9>] start_kernel+0x294/0x2a0
 [<ffffffff805e5140>] _sinittext+0x140/0x144

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:  30   Cold: hi:   62, btch:  15 usd:  48
Active:170237 inactive:288513 dirty:24931 writeback:1 unstable:0
 free:2537 slab:47109 mapped:7013 pagetables:1123 bounce:0
DMA free:8024kB min:28kB low:32kB high:40kB active:3096kB inactive:0kB present:11164kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 2003 2003
DMA32 free:2124kB min:5712kB low:7140kB high:8568kB active:677852kB inactive:1154052kB present:2051184kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8024kB
DMA32: 1*4kB 1*8kB 0*16kB 0*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2124kB
Swap cache: add 188636, delete 61524, find 121/155, race 0+0
Free swap  = 5101816kB
Total swap = 5855208kB
Free swap:       5101816kB
524000 pages of RAM
9148 reserved pages
177075 pages shared
127112 pages swap cached
swapper: page allocation failure. order:0, mode:0x20

Call Trace:
 <IRQ>  [<ffffffff8020e0ee>] __alloc_pages+0x288/0x2a1
 [<ffffffff80233114>] tcp_v4_do_rcv+0x26/0x290
 [<ffffffff80262d04>] smp_apic_timer_interrupt+0x37/0x40
 [<ffffffff8024fb45>] cache_alloc_refill+0x23f/0x45e
 [<ffffffff80298982>] __kmalloc+0x50/0x57
 [<ffffffff80228233>] __alloc_skb+0x5a/0x133
 [<ffffffff803a4a5d>] nv_alloc_rx_optimized+0x58/0x18c
 [<ffffffff803a6e30>] nv_nic_irq_optimized+0x87/0x1d9
 [<ffffffff8020f098>] handle_IRQ_event+0x25/0x53
 [<ffffffff80210374>] __do_softirq+0x46/0x90
 [<ffffffff8028ab8f>] handle_fasteoi_irq+0x5b/0x88
 [<ffffffff8025d66e>] do_IRQ+0xd7/0x132
 [<ffffffff8025ba07>] default_idle+0x0/0x3a
 [<ffffffff802509f1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8045e907>] udp_poll+0x0/0x128
 [<ffffffff8025ba2d>] default_idle+0x26/0x3a
 [<ffffffff8023e163>] cpu_idle+0x3d/0x5c
 [<ffffffff805e58e9>] start_kernel+0x294/0x2a0
 [<ffffffff805e5140>] _sinittext+0x140/0x144

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:  30   Cold: hi:   62, btch:  15 usd:  48
Active:170237 inactive:288513 dirty:24931 writeback:1 unstable:0
 free:2537 slab:47109 mapped:7013 pagetables:1123 bounce:0
DMA free:8024kB min:28kB low:32kB high:40kB active:3096kB inactive:0kB present:11164kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 2003 2003
DMA32 free:2124kB min:5712kB low:7140kB high:8568kB active:677852kB inactive:1154052kB present:2051184kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8024kB
DMA32: 1*4kB 1*8kB 0*16kB 0*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2124kB
Swap cache: add 188636, delete 61524, find 121/155, race 0+0
Free swap  = 5101816kB
Total swap = 5855208kB
Free swap:       5101816kB
524000 pages of RAM
9148 reserved pages
177075 pages shared
127112 pages swap cached
swapper: page allocation failure. order:0, mode:0x20

Call Trace:
 <IRQ>  [<ffffffff8020e0ee>] __alloc_pages+0x288/0x2a1
 [<ffffffff80233114>] tcp_v4_do_rcv+0x26/0x290
 [<ffffffff80262d04>] smp_apic_timer_interrupt+0x37/0x40
 [<ffffffff8024fb45>] cache_alloc_refill+0x23f/0x45e
 [<ffffffff80298982>] __kmalloc+0x50/0x57
 [<ffffffff80228233>] __alloc_skb+0x5a/0x133
 [<ffffffff803a4a5d>] nv_alloc_rx_optimized+0x58/0x18c
 [<ffffffff803a6e30>] nv_nic_irq_optimized+0x87/0x1d9
 [<ffffffff8020f098>] handle_IRQ_event+0x25/0x53
 [<ffffffff80210374>] __do_softirq+0x46/0x90
 [<ffffffff8028ab8f>] handle_fasteoi_irq+0x5b/0x88
 [<ffffffff8025d66e>] do_IRQ+0xd7/0x132
 [<ffffffff8025ba07>] default_idle+0x0/0x3a
 [<ffffffff802509f1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8045e907>] udp_poll+0x0/0x128
 [<ffffffff8025ba2d>] default_idle+0x26/0x3a
 [<ffffffff8023e163>] cpu_idle+0x3d/0x5c
 [<ffffffff805e58e9>] start_kernel+0x294/0x2a0
 [<ffffffff805e5140>] _sinittext+0x140/0x144

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:  30   Cold: hi:   62, btch:  15 usd:  48
Active:170237 inactive:288513 dirty:24931 writeback:1 unstable:0
 free:2537 slab:47109 mapped:7013 pagetables:1123 bounce:0
DMA free:8024kB min:28kB low:32kB high:40kB active:3096kB inactive:0kB present:11164kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 2003 2003
DMA32 free:2124kB min:5712kB low:7140kB high:8568kB active:677852kB inactive:1154052kB present:2051184kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8024kB
DMA32: 1*4kB 1*8kB 0*16kB 0*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2124kB
Swap cache: add 188636, delete 61524, find 121/155, race 0+0
Free swap  = 5101816kB
Total swap = 5855208kB
Free swap:       5101816kB
524000 pages of RAM
9148 reserved pages
177075 pages shared
127112 pages swap cached
swapper: page allocation failure. order:0, mode:0x20

Call Trace:
 <IRQ>  [<ffffffff8020e0ee>] __alloc_pages+0x288/0x2a1
 [<ffffffff8024fb45>] cache_alloc_refill+0x23f/0x45e
 [<ffffffff80298982>] __kmalloc+0x50/0x57
 [<ffffffff80228233>] __alloc_skb+0x5a/0x133
 [<ffffffff803a4a5d>] nv_alloc_rx_optimized+0x58/0x18c
 [<ffffffff803a7291>] nv_do_rx_refill+0x0/0xa2
 [<ffffffff803a72e3>] nv_do_rx_refill+0x52/0xa2
 [<ffffffff802783b6>] run_timer_softirq+0x10d/0x161
 [<ffffffff80210374>] __do_softirq+0x46/0x90
 [<ffffffff8025119c>] call_softirq+0x1c/0x28
 [<ffffffff8025d385>] do_softirq+0x2c/0x7d
 [<ffffffff8025d6b5>] do_IRQ+0x11e/0x132
 [<ffffffff8025ba07>] default_idle+0x0/0x3a
 [<ffffffff802509f1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8025ba2d>] default_idle+0x26/0x3a
 [<ffffffff8023e163>] cpu_idle+0x3d/0x5c
 [<ffffffff805e58e9>] start_kernel+0x294/0x2a0
 [<ffffffff805e5140>] _sinittext+0x140/0x144

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:  30   Cold: hi:   62, btch:  15 usd:  61
Active:170240 inactive:288446 dirty:24932 writeback:1 unstable:0
 free:2521 slab:47140 mapped:7013 pagetables:1123 bounce:0
DMA free:8024kB min:28kB low:32kB high:40kB active:3096kB inactive:0kB present:11164kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 2003 2003
DMA32 free:2060kB min:5712kB low:7140kB high:8568kB active:677864kB inactive:1153784kB present:2051184kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8024kB
DMA32: 1*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2060kB
Swap cache: add 188636, delete 61524, find 121/155, race 0+0
Free swap  = 5101816kB
Total swap = 5855208kB
Free swap:       5101816kB
524000 pages of RAM
9148 reserved pages
177049 pages shared
127112 pages swap cached
swapper: page allocation failure. order:0, mode:0x20

Call Trace:
 <IRQ>  [<ffffffff8020e0ee>] __alloc_pages+0x288/0x2a1
 [<ffffffff80273f8c>] printk+0x4e/0x56
 [<ffffffff8024fb45>] cache_alloc_refill+0x23f/0x45e
 [<ffffffff80298982>] __kmalloc+0x50/0x57
 [<ffffffff80228233>] __alloc_skb+0x5a/0x133
 [<ffffffff803a4a5d>] nv_alloc_rx_optimized+0x58/0x18c
 [<ffffffff803a6e30>] nv_nic_irq_optimized+0x87/0x1d9
 [<ffffffff8020f098>] handle_IRQ_event+0x25/0x53
 [<ffffffff8028ab8f>] handle_fasteoi_irq+0x5b/0x88
 [<ffffffff8025d66e>] do_IRQ+0xd7/0x132
 [<ffffffff803a7291>] nv_do_rx_refill+0x0/0xa2
 [<ffffffff802509f1>] ret_from_intr+0x0/0xa
 [<ffffffff802642dc>] ioapic_retrigger_irq+0x0/0x3b
 [<ffffffff8028a518>] enable_irq+0x87/0x8c
 [<ffffffff802783b6>] run_timer_softirq+0x10d/0x161
 [<ffffffff80210374>] __do_softirq+0x46/0x90
 [<ffffffff8025119c>] call_softirq+0x1c/0x28
 [<ffffffff8025d385>] do_softirq+0x2c/0x7d
 [<ffffffff8025d6b5>] do_IRQ+0x11e/0x132
 [<ffffffff8025ba07>] default_idle+0x0/0x3a
 [<ffffffff802509f1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8025ba2d>] default_idle+0x26/0x3a
 [<ffffffff8023e163>] cpu_idle+0x3d/0x5c
 [<ffffffff805e58e9>] start_kernel+0x294/0x2a0
 [<ffffffff805e5140>] _sinittext+0x140/0x144

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:  30   Cold: hi:   62, btch:  15 usd:  61
Active:170240 inactive:288446 dirty:24932 writeback:1 unstable:0
 free:2521 slab:47140 mapped:7013 pagetables:1123 bounce:0
DMA free:8024kB min:28kB low:32kB high:40kB active:3096kB inactive:0kB present:11164kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 2003 2003
DMA32 free:2060kB min:5712kB low:7140kB high:8568kB active:677864kB inactive:1153784kB present:2051184kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8024kB
DMA32: 1*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2060kB
Swap cache: add 188636, delete 61524, find 121/155, race 0+0
Free swap  = 5101816kB
Total swap = 5855208kB
Free swap:       5101816kB
524000 pages of RAM
9148 reserved pages
177049 pages shared
127112 pages swap cached
swapper: page allocation failure. order:0, mode:0x20

Call Trace:
 <IRQ>  [<ffffffff8020e0ee>] __alloc_pages+0x288/0x2a1
 [<ffffffff80262d04>] smp_apic_timer_interrupt+0x37/0x40
 [<ffffffff8024fb45>] cache_alloc_refill+0x23f/0x45e
 [<ffffffff80298982>] __kmalloc+0x50/0x57
 [<ffffffff80228233>] __alloc_skb+0x5a/0x133
 [<ffffffff803a4a5d>] nv_alloc_rx_optimized+0x58/0x18c
 [<ffffffff803a6e30>] nv_nic_irq_optimized+0x87/0x1d9
 [<ffffffff8020f098>] handle_IRQ_event+0x25/0x53
 [<ffffffff8028ab8f>] handle_fasteoi_irq+0x5b/0x88
 [<ffffffff8025d66e>] do_IRQ+0xd7/0x132
 [<ffffffff803a7291>] nv_do_rx_refill+0x0/0xa2
 [<ffffffff802509f1>] ret_from_intr+0x0/0xa
 [<ffffffff802642dc>] ioapic_retrigger_irq+0x0/0x3b
 [<ffffffff8028a518>] enable_irq+0x87/0x8c
 [<ffffffff802783b6>] run_timer_softirq+0x10d/0x161
 [<ffffffff80210374>] __do_softirq+0x46/0x90
 [<ffffffff8025119c>] call_softirq+0x1c/0x28
 [<ffffffff8025d385>] do_softirq+0x2c/0x7d
 [<ffffffff8025d6b5>] do_IRQ+0x11e/0x132
 [<ffffffff8025ba07>] default_idle+0x0/0x3a
 [<ffffffff802509f1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8025ba2d>] default_idle+0x26/0x3a
 [<ffffffff8023e163>] cpu_idle+0x3d/0x5c
 [<ffffffff805e58e9>] start_kernel+0x294/0x2a0
 [<ffffffff805e5140>] _sinittext+0x140/0x144

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:  30   Cold: hi:   62, btch:  15 usd:  61
Active:170240 inactive:288446 dirty:24932 writeback:1 unstable:0
 free:2521 slab:47140 mapped:7013 pagetables:1123 bounce:0
DMA free:8024kB min:28kB low:32kB high:40kB active:3096kB inactive:0kB present:11164kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 2003 2003
DMA32 free:2060kB min:5712kB low:7140kB high:8568kB active:677864kB inactive:1153784kB present:2051184kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8024kB
DMA32: 1*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2060kB
Swap cache: add 188636, delete 61524, find 121/155, race 0+0
Free swap  = 5101816kB
Total swap = 5855208kB
Free swap:       5101816kB
524000 pages of RAM
9148 reserved pages
177049 pages shared
127112 pages swap cached
swapper: page allocation failure. order:0, mode:0x20

Call Trace:
 <IRQ>  [<ffffffff8020e0ee>] __alloc_pages+0x288/0x2a1
 [<ffffffff8022d145>] ip_queue_xmit+0x3d4/0x418
 [<ffffffff8024fb45>] cache_alloc_refill+0x23f/0x45e
 [<ffffffff80298982>] __kmalloc+0x50/0x57
 [<ffffffff80228233>] __alloc_skb+0x5a/0x133
 [<ffffffff80232614>] tcp_send_ack+0x23/0xf1
 [<ffffffff80218a8e>] tcp_rcv_established+0x64f/0x6ab
 [<ffffffff80233114>] tcp_v4_do_rcv+0x26/0x290
 [<ffffffff80222aee>] tcp_v4_rcv+0x7d2/0x833
 [<ffffffff8022d2ef>] ip_local_deliver+0x166/0x1f1
 [<ffffffff8022df71>] ip_rcv+0x419/0x44e
 [<ffffffff802813db>] hrtimer_wakeup+0x0/0x22
 [<ffffffff80229e3d>] process_backlog+0x7d/0xf7
 [<ffffffff8020b759>] net_rx_action+0x61/0xf0
 [<ffffffff80210374>] __do_softirq+0x46/0x90
 [<ffffffff8025119c>] call_softirq+0x1c/0x28
 [<ffffffff8025d385>] do_softirq+0x2c/0x7d
 [<ffffffff8025d6b5>] do_IRQ+0x11e/0x132
 [<ffffffff8025ba07>] default_idle+0x0/0x3a
 [<ffffffff802509f1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8025ba2d>] default_idle+0x26/0x3a
 [<ffffffff8023e163>] cpu_idle+0x3d/0x5c
 [<ffffffff805e58e9>] start_kernel+0x294/0x2a0
 [<ffffffff805e5140>] _sinittext+0x140/0x144

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:  30   Cold: hi:   62, btch:  15 usd:  61
Active:170240 inactive:288446 dirty:24932 writeback:1 unstable:0
 free:2521 slab:47140 mapped:7013 pagetables:1123 bounce:0
DMA free:8024kB min:28kB low:32kB high:40kB active:3096kB inactive:0kB present:11164kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 2003 2003
DMA32 free:2060kB min:5712kB low:7140kB high:8568kB active:677864kB inactive:1153784kB present:2051184kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8024kB
DMA32: 1*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2060kB
Swap cache: add 188636, delete 61524, find 121/155, race 0+0
Free swap  = 5101816kB
Total swap = 5855208kB
Free swap:       5101816kB
524000 pages of RAM
9148 reserved pages
177049 pages shared
127112 pages swap cached
swapper: page allocation failure. order:0, mode:0x20

Call Trace:
 <IRQ>  [<ffffffff8020e0ee>] __alloc_pages+0x288/0x2a1
 [<ffffffff8024fb45>] cache_alloc_refill+0x23f/0x45e
 [<ffffffff80298982>] __kmalloc+0x50/0x57
 [<ffffffff80228233>] __alloc_skb+0x5a/0x133
 [<ffffffff80232614>] tcp_send_ack+0x23/0xf1
 [<ffffffff80218a8e>] tcp_rcv_established+0x64f/0x6ab
 [<ffffffff80233114>] tcp_v4_do_rcv+0x26/0x290
 [<ffffffff80222aee>] tcp_v4_rcv+0x7d2/0x833
 [<ffffffff8022d2ef>] ip_local_deliver+0x166/0x1f1
 [<ffffffff8022df71>] ip_rcv+0x419/0x44e
 [<ffffffff802813db>] hrtimer_wakeup+0x0/0x22
 [<ffffffff80229e3d>] process_backlog+0x7d/0xf7
 [<ffffffff8020b759>] net_rx_action+0x61/0xf0
 [<ffffffff80210374>] __do_softirq+0x46/0x90
 [<ffffffff8025119c>] call_softirq+0x1c/0x28
 [<ffffffff8025d385>] do_softirq+0x2c/0x7d
 [<ffffffff8025d6b5>] do_IRQ+0x11e/0x132
 [<ffffffff8025ba07>] default_idle+0x0/0x3a
 [<ffffffff802509f1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8025ba2d>] default_idle+0x26/0x3a
 [<ffffffff8023e163>] cpu_idle+0x3d/0x5c
 [<ffffffff805e58e9>] start_kernel+0x294/0x2a0
 [<ffffffff805e5140>] _sinittext+0x140/0x144

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:  30   Cold: hi:   62, btch:  15 usd:  61
Active:170240 inactive:288446 dirty:24932 writeback:1 unstable:0
 free:2521 slab:47140 mapped:7013 pagetables:1123 bounce:0
DMA free:8024kB min:28kB low:32kB high:40kB active:3096kB inactive:0kB present:11164kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 2003 2003
DMA32 free:2060kB min:5712kB low:7140kB high:8568kB active:677864kB inactive:1153784kB present:2051184kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8024kB
DMA32: 1*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2060kB
Swap cache: add 188636, delete 61524, find 121/155, race 0+0
Free swap  = 5101816kB
Total swap = 5855208kB
Free swap:       5101816kB
524000 pages of RAM
9148 reserved pages
177049 pages shared
127112 pages swap cached
swapper: page allocation failure. order:0, mode:0x20

Call Trace:
 <IRQ>  [<ffffffff8020e0ee>] __alloc_pages+0x288/0x2a1
 [<ffffffff8024fb45>] cache_alloc_refill+0x23f/0x45e
 [<ffffffff80298982>] __kmalloc+0x50/0x57
 [<ffffffff80228233>] __alloc_skb+0x5a/0x133
 [<ffffffff80232614>] tcp_send_ack+0x23/0xf1
 [<ffffffff80218a8e>] tcp_rcv_established+0x64f/0x6ab
 [<ffffffff80233114>] tcp_v4_do_rcv+0x26/0x290
 [<ffffffff80222aee>] tcp_v4_rcv+0x7d2/0x833
 [<ffffffff8022d2ef>] ip_local_deliver+0x166/0x1f1
 [<ffffffff8022df71>] ip_rcv+0x419/0x44e
 [<ffffffff802813db>] hrtimer_wakeup+0x0/0x22
 [<ffffffff80229e3d>] process_backlog+0x7d/0xf7
 [<ffffffff8020b759>] net_rx_action+0x61/0xf0
 [<ffffffff80210374>] __do_softirq+0x46/0x90
 [<ffffffff8025119c>] call_softirq+0x1c/0x28
 [<ffffffff8025d385>] do_softirq+0x2c/0x7d
 [<ffffffff8025d6b5>] do_IRQ+0x11e/0x132
 [<ffffffff8025ba07>] default_idle+0x0/0x3a
 [<ffffffff802509f1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8025ba2d>] default_idle+0x26/0x3a
 [<ffffffff8023e163>] cpu_idle+0x3d/0x5c
 [<ffffffff805e58e9>] start_kernel+0x294/0x2a0
 [<ffffffff805e5140>] _sinittext+0x140/0x144

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:  30   Cold: hi:   62, btch:  15 usd:  61
Active:170240 inactive:288446 dirty:24932 writeback:1 unstable:0
 free:2521 slab:47140 mapped:7013 pagetables:1123 bounce:0
DMA free:8024kB min:28kB low:32kB high:40kB active:3096kB inactive:0kB present:11164kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 2003 2003
DMA32 free:2060kB min:5712kB low:7140kB high:8568kB active:677864kB inactive:1153784kB present:2051184kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8024kB
DMA32: 1*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2060kB
Swap cache: add 188636, delete 61524, find 121/155, race 0+0
Free swap  = 5101816kB
Total swap = 5855208kB
Free swap:       5101816kB
524000 pages of RAM
9148 reserved pages
177049 pages shared
127112 pages swap cached
swapper: page allocation failure. order:0, mode:0x20

Call Trace:
 <IRQ>  [<ffffffff8020e0ee>] __alloc_pages+0x288/0x2a1
 [<ffffffff8024fb45>] cache_alloc_refill+0x23f/0x45e
 [<ffffffff80298982>] __kmalloc+0x50/0x57
 [<ffffffff80228233>] __alloc_skb+0x5a/0x133
 [<ffffffff80232614>] tcp_send_ack+0x23/0xf1
 [<ffffffff80218a8e>] tcp_rcv_established+0x64f/0x6ab
 [<ffffffff80233114>] tcp_v4_do_rcv+0x26/0x290
 [<ffffffff80222aee>] tcp_v4_rcv+0x7d2/0x833
 [<ffffffff8022d2ef>] ip_local_deliver+0x166/0x1f1
 [<ffffffff8022df71>] ip_rcv+0x419/0x44e
 [<ffffffff802813db>] hrtimer_wakeup+0x0/0x22
 [<ffffffff80229e3d>] process_backlog+0x7d/0xf7
 [<ffffffff8020b759>] net_rx_action+0x61/0xf0
 [<ffffffff80210374>] __do_softirq+0x46/0x90
 [<ffffffff8025119c>] call_softirq+0x1c/0x28
 [<ffffffff8025d385>] do_softirq+0x2c/0x7d
 [<ffffffff8025d6b5>] do_IRQ+0x11e/0x132
 [<ffffffff8025ba07>] default_idle+0x0/0x3a
 [<ffffffff802509f1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8025ba2d>] default_idle+0x26/0x3a
 [<ffffffff8023e163>] cpu_idle+0x3d/0x5c
 [<ffffffff805e58e9>] start_kernel+0x294/0x2a0
 [<ffffffff805e5140>] _sinittext+0x140/0x144

Mem-info:
DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:  30   Cold: hi:   62, btch:  15 usd:  61
Active:170240 inactive:288446 dirty:24932 writeback:1 unstable:0
 free:2521 slab:47140 mapped:7013 pagetables:1123 bounce:0
DMA free:8024kB min:28kB low:32kB high:40kB active:3096kB inactive:0kB present:11164kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 2003 2003
DMA32 free:2060kB min:5712kB low:7140kB high:8568kB active:677864kB inactive:1153784kB present:2051184kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 0*4kB 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8024kB
DMA32: 1*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2060kB
Swap cache: add 188636, delete 61524, find 121/155, race 0+0
Free swap  = 5101816kB
Total swap = 5855208kB
Free swap:       5101816kB
524000 pages of RAM
9148 reserved pages
177049 pages shared
127112 pages swap cached
NETDEV WATCHDOG: eth0: transmit timed out
eth0: Got tx_timeout. irq: 00000037
eth0: Ring at 7f98a000
eth0: Dumping tx registers
  0: 00002037 000000ff 00000003 002903ca 00000000 00000000 00000000 00000000
 20: 06255300 ff701365 00000000 00000000 00000000 00000000 00000000 00000000
 40: 0420e20e 0000a855 00002e20 00000000 00000000 00000000 00000000 00000000
 60: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
 80: 003b0f3c 00000001 00040000 007f0028 0000061c 00000001 00200000 00007f93
 a0: 0014050f 00000016 d2290100 00008d34 005e0001 00000100 ffffffff 0000ffff
 c0: 10000002 00000001 00000001 00000001 00000001 00000001 00000001 00000001
 e0: 00000001 00000001 00000001 00000001 00000001 00000001 00000001 00000001
100: 7f98a800 7f98a000 007f00ff 00008000 00010032 00000000 00000018 7f98b040
120: 7f98a1e0 69fb6c40 a000ffeb 00000000 00000000 7f98b04c 7f98a1ec 0fe08000
140: 00304120 80002600 00000000 00000000 00000000 00000000 00000000 00000000
160: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
180: 00000016 00000008 0194796d 00008103 0000002a 00007c00 0194000f 00000003
1a0: 00000016 00000008 0194796d 00008103 0000002a 00007c00 0194000f 00000003
1c0: 00000016 00000008 0194796d 00008103 0000002a 00007c00 0194000f 00000003
1e0: 00000016 00000008 0194796d 00008103 0000002a 00007c00 0194000f 00000003
200: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
220: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
240: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
260: 00000000 00000000 fe020001 00000100 00000000 00000000 7e020001 00000100
280: 00000040 00000001 00000000 00000000 00000000 00000000 00000000 00000000
2a0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
2c0: 00000000 00000000 00000000 00000000 00000000 00000001 00000001 00000001
eth0: Dumping tx ring
000: 00000000 6594b602 22000040 // 00000000 4a210c02 22000040 // 00000000 4ddc1e02 22000040 // 00000000 4ddc1c02 22000040
004: 00000000 4ddc1202 22000040 // 00000000 4ddc1402 22000040 // 00000000 4ddc1602 22000040 // 00000000 4ddc1002 22000040
008: 00000000 4ddc1802 22000040 // 00000000 6594b802 22000040 // 00000000 4ddc1a02 22000040 // 00000000 67a90c02 22000040
00c: 00000000 67a90a02 22000040 // 00000000 67a90202 22000040 // 00000000 67a90602 22000040 // 00000000 67a90e02 22000040
010: 00000000 67a90802 22000040 // 00000000 67a90002 22000040 // 00000000 6bbf4e02 22000040 // 00000000 67a90402 22000040
014: 00000000 6bbf4a02 22000040 // 00000000 6bbf4802 22000040 // 00000000 6bbf4202 22000040 // 00000000 6bbf4402 22000040
018: 00000000 6bbf4c02 22000040 // 00000000 6bbf4002 22000040 // 00000000 03042e02 22000040 // 00000000 03042c02 22000040
01c: 00000000 03042202 22000040 // 00000000 03042402 22000040 // 00000000 03042602 22000040 // 00000000 03042a02 22000040
020: 00000000 03042002 22000040 // 00000000 6bbf4602 22000040 // 00000000 03042802 22000040 // 00000000 783b6c02 22000040
024: 00000000 783b6a02 22000040 // 00000000 783b6202 22000040 // 00000000 783b6402 22000040 // 00000000 783b6602 22000040
028: 00000000 783b6802 22000040 // 00000000 783b6002 22000040 // 00000000 48b01e02 22000040 // 00000000 783b6e02 22000040
02c: 00000000 48b01a02 22000040 // 00000000 48b01802 22000040 // 00000000 48b01202 22000040 // 00000000 48b01402 22000040
030: 00000000 48b01c02 22000040 // 00000000 48b01002 22000040 // 00000000 1982ee02 22000040 // 00000000 1982ec02 22000040
034: 00000000 1982e202 22000040 // 00000000 1982e402 22000040 // 00000000 1982e602 22000040 // 00000000 1982ea02 22000040
038: 00000000 1982e002 22000040 // 00000000 48b01602 22000040 // 00000000 1982e802 22000040 // 00000000 6b569c02 22000040
03c: 00000000 6b569a02 22000040 // 00000000 6b569602 22000040 // 00000000 6b569402 22000040 // 00000000 6b569202 22000040
040: 00000000 6b569002 22000040 // 00000000 6b569e02 22000040 // 00000000 031cee02 22000040 // 00000000 6b569802 22000040
044: 00000000 031cea02 22000040 // 00000000 031ce802 22000040 // 00000000 031ce202 22000040 // 00000000 031ce402 22000040
048: 00000000 031cec02 22000040 // 00000000 031ce002 22000040 // 00000000 7688be02 22000040 // 00000000 7688bc02 22000040
04c: 00000000 7688b202 22000040 // 00000000 7688b402 22000040 // 00000000 7688b602 22000040 // 00000000 7688ba02 22000040
050: 00000000 7688b002 22000040 // 00000000 031ce602 22000040 // 00000000 7688b802 22000040 // 00000000 4d5e4c02 22000040
054: 00000000 4d5e4a02 22000040 // 00000000 4d5e4602 22000040 // 00000000 4d5e4402 22000040 // 00000000 4d5e4202 22000040
058: 00000000 4d5e4002 22000040 // 00000000 4d5e4802 22000040 // 00000000 3a2eee02 22000040 // 00000000 3a2ee002 22000040
05c: 00000000 3a2ee202 22000040 // 00000000 3a2ee402 22000040 // 00000000 4d5e4e02 22000040 // 00000000 3a2ee802 22000040
060: 00000000 3a2eea02 22000040 // 00000000 3a2ee602 22000040 // 00000000 0310fe02 22000040 // 00000000 0310fc02 22000040
064: 00000000 3a2eec02 22000040 // 00000000 0310f802 22000040 // 00000000 0310f002 22000040 // 00000000 0310fa02 22000040
068: 00000000 0310f402 22000040 // 00000000 0310f602 22000040 // 00000000 0310f202 22000040 // 00000000 0e5bec02 22000040
06c: 00000000 0e5bea02 22000040 // 00000000 0e5be202 22000040 // 00000000 0e5be402 22000040 // 00000000 0e5be602 22000040
070: 00000000 0e5be002 22000040 // 00000000 0e5be802 22000040 // 00000000 36687e02 22000040 // 00000000 36687202 22000040
074: 00000000 36687602 22000040 // 00000000 36687802 22000040 // 00000000 36687402 22000040 // 00000000 36687c02 22000040
078: 00000000 36687002 22000040 // 00000000 36687a02 22000040 // 00000000 65078e02 22000040 // 00000000 65078c02 22000040
07c: 00000000 65078202 22000040 // 00000000 65078402 22000040 // 00000000 65078602 22000040 // 00000000 65078002 22000040
080: 00000000 65078a02 22000040 // 00000000 0e5bee02 22000040 // 00000000 65078802 22000040 // 00000000 69fb6c02 22000040
084: 00000000 7d2bc65e 20000046 // 00000000 7d2bc652 20000052 // 00000000 7eee6e52 20000052 // 00000000 7edb8252 20000052
088: 00000000 7edb8052 20000052 // 00000000 5cc95e52 20000052 // 00000000 5cc95c02 20000072 // 00000000 5cc95a02 20000040
08c: 00000000 5cc95802 22000040 // 00000000 5cc95602 22000040 // 00000000 5cc95202 22000040 // 00000000 5cc95402 22000040
090: 00000000 38ec0e02 22000040 // 00000000 5cc95002 22000040 // 00000000 6a3bf852 22000052 // 00000000 38ec0202 20000040
094: 00000000 38ec0402 22000040 // 00000000 38ec0c02 22000040 // 00000000 38ec0802 22000040 // 00000000 38ec0a02 22000040
098: 00000000 7d2bca02 22000040 // 00000000 38ec0002 22000040 // 00000000 6a3bf002 22000040 // 00000000 6a3bfa02 22000040
09c: 00000000 6a3bfc02 22000040 // 00000000 6a3bfe02 22000040 // 00000000 7d2bcc02 22000040 // 00000000 6a3bf202 22000040
0a0: 00000000 6a3bf402 22000040 // 00000000 6a3bf602 22000040 // 00000000 578eee02 22000040 // 00000000 578eec02 22000040
0a4: 00000000 38ec0602 22000040 // 00000000 578ee002 22000040 // 00000000 578ee202 22000040 // 00000000 578eea02 22000040
0a8: 00000000 578ee802 22000040 // 00000000 578ee602 22000040 // 00000000 77bd3e02 22000040 // 00000000 77bd3c02 22000040
0ac: 00000000 77bd3a02 22000040 // 00000000 77bd3602 22000040 // 00000000 77bd3802 22000040 // 00000000 77bd3202 22000040
0b0: 00000000 77bd3002 22000040 // 00000000 77bd3402 22000040 // 00000000 33af2c02 22000040 // 00000000 33af2a02 22000040
0b4: 00000000 33af2e02 22000040 // 00000000 33af2602 22000040 // 00000000 33af2402 22000040 // 00000000 33af2802 22000040
0b8: 00000000 33af2002 22000040 // 00000000 578ee402 22000040 // 00000000 77763c02 22000040 // 00000000 77763e02 22000040
0bc: 00000000 77763202 22000040 // 00000000 77763402 22000040 // 00000000 77763602 22000040 // 00000000 77763002 22000040
0c0: 00000000 77763a02 22000040 // 00000000 33af2202 22000040 // 00000000 611b0e02 22000040 // 00000000 611b0c02 22000040
0c4: 00000000 611b0a02 22000040 // 00000000 77763802 22000040 // 00000000 611b0002 22000040 // 00000000 611b0202 22000040
0c8: 00000000 611b0802 22000040 // 00000000 611b0402 22000040 // 00000000 6190ee02 22000040 // 00000000 611b0602 22000040
0cc: 00000000 6190e002 22000040 // 00000000 6190e202 22000040 // 00000000 6190ec02 22000040 // 00000000 6190e602 22000040
0d0: 00000000 6190e802 22000040 // 00000000 6190ea02 22000040 // 00000000 65bb7e02 22000040 // 00000000 65bb7a02 22000040
0d4: 00000000 65bb7002 22000040 // 00000000 65bb7202 22000040 // 00000000 65bb7402 22000040 // 00000000 65bb7802 22000040
0d8: 00000000 65bb7602 22000040 // 00000000 65bb7c02 22000040 // 00000000 6190e402 22000040 // 00000000 031a8c02 22000040
0dc: 00000000 031a8a02 22000040 // 00000000 031a8802 22000040 // 00000000 031a8602 22000040 // 00000000 031a8402 22000040
0e0: 00000000 031a8002 22000040 // 00000000 031a8202 22000040 // 00000000 62f8ae02 22000040 // 00000000 031a8e02 22000040
0e4: 00000000 62f8aa02 22000040 // 00000000 62f8a802 22000040 // 00000000 62f8a402 22000040 // 00000000 62f8a202 22000040
0e8: 00000000 62f8ac02 22000040 // 00000000 62f8a602 22000040 // 00000000 76069e02 22000040 // 00000000 76069c02 22000040
0ec: 00000000 62f8a002 22000040 // 00000000 76069802 22000040 // 00000000 76069602 22000040 // 00000000 76069202 22000040
0f0: 00000000 76069a02 22000040 // 00000000 76069402 22000040 // 00000000 76069002 22000040 // 00000000 4a210002 22000040
0f4: 00000000 4a210202 22000040 // 00000000 4a210e02 22000040 // 00000000 4a210602 22000040 // 00000000 4a210802 22000040
0f8: 00000000 4a210402 22000040 // 00000000 4a210a02 22000040 // 00000000 6594bc02 22000040 // 00000000 6594b002 22000040
0fc: 00000000 6594b202 22000040 // 00000000 6594b402 22000040 // 00000000 6594ba02 22000040 // 00000000 6594be02 22000040
### /proc/buddyinfo ###
Node 0, zone      DMA      4      1      0      1      1      0      1      1      1      1      1 
Node 0, zone    DMA32   2838    217    156     69      1      0      0      0      0      1      0 
### /proc/cpuinfo ###
processor	: 0
vendor_id	: AuthenticAMD
cpu family	: 15
model		: 39
model name	: AMD Athlon(tm) 64 Processor 3700+
stepping	: 1
cpu MHz		: 2200.000
cache size	: 1024 KB
fpu		: yes
fpu_exception	: yes
cpuid level	: 1
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 syscall nx mmxext fxsr_opt lm 3dnowext 3dnow pni lahf_lm
bogomips	: 4423.06
TLB size	: 1024 4K pages
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management: ts fid vid ttp tm stc

### /proc/meminfo ###
MemTotal:      2059408 kB
MemFree:         27944 kB
Buffers:         12276 kB
Cached:         752944 kB
SwapCached:     516040 kB
Active:         684464 kB
Inactive:      1143340 kB
SwapTotal:     5855208 kB
SwapFree:      5094224 kB
Dirty:             152 kB
Writeback:           0 kB
AnonPages:      546568 kB
Mapped:          28068 kB
Slab:           177440 kB
SReclaimable:   161220 kB
SUnreclaim:      16220 kB
PageTables:       4512 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   6884912 kB
Committed_AS:  2031232 kB
VmallocTotal: 34359738367 kB
VmallocUsed:    265356 kB
VmallocChunk: 34359472827 kB
### /proc/slabinfo ###
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
ip_fib_alias           9     59     64   59    1 : tunables  120   60    0 : slabdata      1      1      0
ip_fib_hash            9     59     64   59    1 : tunables  120   60    0 : slabdata      1      1      0
jbd_4k                 2      2   4096    1    1 : tunables   24   12    0 : slabdata      2      2      0
raid5/md5            256    259   1088    7    2 : tunables   24   12    0 : slabdata     37     37      0
rpc_buffers            8      8   2048    2    1 : tunables   24   12    0 : slabdata      4      4      0
rpc_tasks              8     12    320   12    1 : tunables   54   27    0 : slabdata      1      1      0
rpc_inode_cache        0      0    704    5    1 : tunables   54   27    0 : slabdata      0      0      0
UNIX                  18     24    640    6    1 : tunables   54   27    0 : slabdata      4      4      0
xt_hashlimit           0      0     88   44    1 : tunables  120   60    0 : slabdata      0      0      0
flow_cache            25     30    128   30    1 : tunables  120   60    0 : slabdata      1      1      0
scsi_cmd_cache        32     32    448    8    1 : tunables   54   27    0 : slabdata      4      4      0
msi_cache              4     59     64   59    1 : tunables  120   60    0 : slabdata      1      1      0
cfq_ioc_pool         139    150    152   25    1 : tunables  120   60    0 : slabdata      6      6      0
cfq_pool             145    168    160   24    1 : tunables  120   60    0 : slabdata      7      7      0
udf_inode_cache        0      0    600    6    1 : tunables   54   27    0 : slabdata      0      0      0
isofs_inode_cache      0      0    576    7    1 : tunables   54   27    0 : slabdata      0      0      0
journal_handle         2    144     24  144    1 : tunables  120   60    0 : slabdata      1      1      0
journal_head         827   1520     96   40    1 : tunables  120   60    0 : slabdata     38     38      0
revoke_table           6    202     16  202    1 : tunables  120   60    0 : slabdata      1      1      0
revoke_record          0      0     32  112    1 : tunables  120   60    0 : slabdata      0      0      0
ext3_inode_cache   35943 128085    688    5    1 : tunables   54   27    0 : slabdata  25617  25617      0
dnotify_cache          0      0     40   92    1 : tunables  120   60    0 : slabdata      0      0      0
eventpoll_pwq          2     53     72   53    1 : tunables  120   60    0 : slabdata      1      1      0
eventpoll_epi          2     20    192   20    1 : tunables  120   60    0 : slabdata      1      1      0
inotify_event_cache      0      0     40   92    1 : tunables  120   60    0 : slabdata      0      0      0
inotify_watch_cache      0      0     72   53    1 : tunables  120   60    0 : slabdata      0      0      0
kioctx                 0      0    320   12    1 : tunables   54   27    0 : slabdata      0      0      0
kiocb                  0      0    256   15    1 : tunables  120   60    0 : slabdata      0      0      0
fasync_cache           0      0     24  144    1 : tunables  120   60    0 : slabdata      0      0      0
shmem_inode_cache     24     33    712   11    2 : tunables   54   27    0 : slabdata      3      3      0
posix_timers_cache      0      0    136   28    1 : tunables  120   60    0 : slabdata      0      0      0
uid_cache              7     59     64   59    1 : tunables  120   60    0 : slabdata      1      1      0
ip_mrt_cache           0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
UDP-Lite               0      0    704   11    2 : tunables   54   27    0 : slabdata      0      0      0
tcp_bind_bucket       14    112     32  112    1 : tunables  120   60    0 : slabdata      1      1      0
inet_peer_cache        1     59     64   59    1 : tunables  120   60    0 : slabdata      1      1      0
secpath_cache          0      0     64   59    1 : tunables  120   60    0 : slabdata      0      0      0
xfrm_dst_cache         0      0    384   10    1 : tunables   54   27    0 : slabdata      0      0      0
ip_dst_cache          10     48    320   12    1 : tunables   54   27    0 : slabdata      4      4      0
arp_cache              4     15    256   15    1 : tunables  120   60    0 : slabdata      1      1      0
RAW                    2     11    704   11    2 : tunables   54   27    0 : slabdata      1      1      0
UDP                   10     11    704   11    2 : tunables   54   27    0 : slabdata      1      1      0
tw_sock_TCP            0      0    192   20    1 : tunables  120   60    0 : slabdata      0      0      0
request_sock_TCP       0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
TCP                   18     20   1472    5    2 : tunables   24   12    0 : slabdata      4      4      0
sgpool-128            32     32   4096    1    1 : tunables   24   12    0 : slabdata     32     32      0
sgpool-64             32     32   2048    2    1 : tunables   24   12    0 : slabdata     16     16      0
sgpool-32             32     36   1024    4    1 : tunables   54   27    0 : slabdata      8      9      0
sgpool-16             32     32    512    8    1 : tunables   54   27    0 : slabdata      4      4      0
sgpool-8              41     60    256   15    1 : tunables  120   60    0 : slabdata      4      4      0
scsi_io_context        0      0    112   34    1 : tunables  120   60    0 : slabdata      0      0      0
blkdev_ioc            38     67     56   67    1 : tunables  120   60    0 : slabdata      1      1      0
blkdev_queue          38     40   1448    5    2 : tunables   24   12    0 : slabdata      8      8      0
blkdev_requests       65     98    280   14    1 : tunables   54   27    0 : slabdata      7      7      0
biovec-256             7      7   4096    1    1 : tunables   24   12    0 : slabdata      7      7      0
biovec-128             7      8   2048    2    1 : tunables   24   12    0 : slabdata      4      4      0
biovec-64              7      8   1024    4    1 : tunables   54   27    0 : slabdata      2      2      0
biovec-16              7     15    256   15    1 : tunables  120   60    0 : slabdata      1      1      0
biovec-4               7     59     64   59    1 : tunables  120   60    0 : slabdata      1      1      0
biovec-1              70    202     16  202    1 : tunables  120   60    0 : slabdata      1      1      0
bio                  283    570    128   30    1 : tunables  120   60    0 : slabdata     19     19      0
sock_inode_cache      65     72    640    6    1 : tunables   54   27    0 : slabdata     12     12      0
skbuff_fclone_cache      0      0    512    7    1 : tunables   54   27    0 : slabdata      0      0      0
skbuff_head_cache    255    300    256   15    1 : tunables  120   60    0 : slabdata     20     20      0
file_lock_cache        5     23    168   23    1 : tunables  120   60    0 : slabdata      1      1      0
Acpi-Operand        1613   1652     64   59    1 : tunables  120   60    0 : slabdata     28     28      0
Acpi-ParseExt          0      0     64   59    1 : tunables  120   60    0 : slabdata      0      0      0
Acpi-Parse             0      0     40   92    1 : tunables  120   60    0 : slabdata      0      0      0
Acpi-State             0      0     80   48    1 : tunables  120   60    0 : slabdata      0      0      0
Acpi-Namespace       979   1008     32  112    1 : tunables  120   60    0 : slabdata      9      9      0
proc_inode_cache     442    539    560    7    1 : tunables   54   27    0 : slabdata     77     77      0
sigqueue              24     24    160   24    1 : tunables  120   60    0 : slabdata      1      1      0
radix_tree_node     9380  16891    552    7    1 : tunables   54   27    0 : slabdata   2413   2413      0
bdev_cache            38     40    768    5    1 : tunables   54   27    0 : slabdata      8      8      0
sysfs_dir_cache     5097   5136     80   48    1 : tunables  120   60    0 : slabdata    107    107      0
mnt_cache             22     30    256   15    1 : tunables  120   60    0 : slabdata      2      2      0
inode_cache         1148   1148    528    7    1 : tunables   54   27    0 : slabdata    164    164      0
dentry_cache       21601 199740    192   20    1 : tunables  120   60    0 : slabdata   9987   9987      0
filp                 869   1230    256   15    1 : tunables  120   60    0 : slabdata     82     82      0
names_cache            1      1   4096    1    1 : tunables   24   12    0 : slabdata      1      1      0
idr_layer_cache       94     98    528    7    1 : tunables   54   27    0 : slabdata     14     14      0
buffer_head       153834 164280    104   37    1 : tunables  120   60    0 : slabdata   4440   4440      0
mm_struct             75     99    832    9    2 : tunables   54   27    0 : slabdata     11     11      0
vm_area_struct      3331   3358    168   23    1 : tunables  120   60    0 : slabdata    146    146      0
fs_cache              74    118     64   59    1 : tunables  120   60    0 : slabdata      2      2      0
files_cache           75     78    640    6    1 : tunables   54   27    0 : slabdata     13     13      0
signal_cache         112    132    704   11    2 : tunables   54   27    0 : slabdata     12     12      0
sighand_cache         99     99   2112    3    2 : tunables   24   12    0 : slabdata     33     33      0
task_struct          164    164   1728    4    2 : tunables   24   12    0 : slabdata     41     41      0
anon_vma             963   1010     16  202    1 : tunables  120   60    0 : slabdata      5      5      0
pid                  176    177     64   59    1 : tunables  120   60    0 : slabdata      3      3      0
size-131072(DMA)       0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
size-131072            0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
size-65536(DMA)        0      0  65536    1   16 : tunables    8    4    0 : slabdata      0      0      0
size-65536             0      0  65536    1   16 : tunables    8    4    0 : slabdata      0      0      0
size-32768(DMA)        0      0  32768    1    8 : tunables    8    4    0 : slabdata      0      0      0
size-32768             0      0  32768    1    8 : tunables    8    4    0 : slabdata      0      0      0
size-16384(DMA)        0      0  16384    1    4 : tunables    8    4    0 : slabdata      0      0      0
size-16384            10     10  16384    1    4 : tunables    8    4    0 : slabdata     10     10      0
size-8192(DMA)         0      0   8192    1    2 : tunables    8    4    0 : slabdata      0      0      0
size-8192              5      6   8192    1    2 : tunables    8    4    0 : slabdata      5      6      0
size-4096(DMA)         0      0   4096    1    1 : tunables   24   12    0 : slabdata      0      0      0
size-4096             50     50   4096    1    1 : tunables   24   12    0 : slabdata     50     50      0
size-2048(DMA)         0      0   2048    2    1 : tunables   24   12    0 : slabdata      0      0      0
size-2048            388    410   2048    2    1 : tunables   24   12    0 : slabdata    205    205      0
size-1024(DMA)         0      0   1024    4    1 : tunables   54   27    0 : slabdata      0      0      0
size-1024            388    388   1024    4    1 : tunables   54   27    0 : slabdata     97     97      0
size-512(DMA)          0      0    512    8    1 : tunables   54   27    0 : slabdata      0      0      0
size-512             264    264    512    8    1 : tunables   54   27    0 : slabdata     33     33      0
size-256(DMA)          0      0    256   15    1 : tunables  120   60    0 : slabdata      0      0      0
size-256              58     60    256   15    1 : tunables  120   60    0 : slabdata      4      4      0
size-192(DMA)          0      0    192   20    1 : tunables  120   60    0 : slabdata      0      0      0
size-192             520    520    192   20    1 : tunables  120   60    0 : slabdata     26     26      0
size-128(DMA)          0      0    128   30    1 : tunables  120   60    0 : slabdata      0      0      0
size-64(DMA)           0      0     64   59    1 : tunables  120   60    0 : slabdata      0      0      0
size-64             1647   6077     64   59    1 : tunables  120   60    0 : slabdata    103    103      0
size-32(DMA)           0      0     32  112    1 : tunables  120   60    0 : slabdata      0      0      0
size-128            2915   3510    128   30    1 : tunables  120   60    0 : slabdata    117    117      0
size-32             2632   2800     32  112    1 : tunables  120   60    0 : slabdata     25     25      0
kmem_cache           119    120    128   30    1 : tunables  120   60    0 : slabdata      4      4      0
### /proc/zoneinfo ###
Node 0, zone      DMA
  pages free     2014
        min      7
        low      8
        high     10
        scanned  0 (a: 19 i: 24)
        spanned  4096
        present  2791
    nr_free_pages 2014
    nr_active    0
    nr_inactive  774
    nr_anon_pages 462
    nr_mapped    1
    nr_file_pages 312
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 104
    nr_slab_unreclaimable 11
    nr_page_table_pages 1
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 3545
        protection: (0, 2003, 2003)
  pagesets
    cpu: 0 pcp: 0
              count: 0
              high:  0
              batch: 1
    cpu: 0 pcp: 1
              count: 0
              high:  0
              batch: 1
  all_unreclaimable: 0
  prev_priority:     12
  start_pfn:         0
Node 0, zone    DMA32
  pages free     4968
        min      1428
        low      1785
        high     2142
        scanned  0 (a: 0 i: 0)
        spanned  519904
        present  512796
    nr_free_pages 4968
    nr_active    285835
    nr_inactive  170347
    nr_anon_pages 136181
    nr_mapped    7016
    nr_file_pages 320007
    nr_dirty     42
    nr_writeback 0
    nr_slab_reclaimable 40201
    nr_slab_unreclaimable 4044
    nr_page_table_pages 1127
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 250802
        protection: (0, 0, 0)
  pagesets
    cpu: 0 pcp: 0
              count: 129
              high:  186
              batch: 31
    cpu: 0 pcp: 1
              count: 15
              high:  62
              batch: 15
  all_unreclaimable: 0
  prev_priority:     12
  start_pfn:         4096
### lspci ###
00:00.0 Memory controller: nVidia Corporation CK804 Memory Controller (rev a3)
00:01.0 ISA bridge: nVidia Corporation CK804 ISA Bridge (rev a3)
00:01.1 SMBus: nVidia Corporation CK804 SMBus (rev a2)
00:02.0 USB Controller: nVidia Corporation CK804 USB Controller (rev a2)
00:02.1 USB Controller: nVidia Corporation CK804 USB Controller (rev a3)
00:06.0 IDE interface: nVidia Corporation CK804 IDE (rev a2)
00:07.0 IDE interface: nVidia Corporation CK804 Serial ATA Controller (rev a3)
00:08.0 IDE interface: nVidia Corporation CK804 Serial ATA Controller (rev a3)
00:09.0 PCI bridge: nVidia Corporation CK804 PCI Bridge (rev a2)
00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev a3)
00:0b.0 PCI bridge: nVidia Corporation CK804 PCIE Bridge (rev a3)
00:0c.0 PCI bridge: nVidia Corporation CK804 PCIE Bridge (rev a3)
00:0d.0 PCI bridge: nVidia Corporation CK804 PCIE Bridge (rev a3)
00:0e.0 PCI bridge: nVidia Corporation CK804 PCIE Bridge (rev a3)
00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
01:0a.0 Class fe02: Unknown device 5001:fe02 (rev 01)
02:00.0 Mass storage controller: Silicon Image, Inc. SiI 3132 Serial ATA Raid II Controller (rev 01)
03:00.0 Mass storage controller: Silicon Image, Inc. SiI 3132 Serial ATA Raid II Controller (rev 01)
04:00.0 Mass storage controller: Silicon Image, Inc. SiI 3132 Serial ATA Raid II Controller (rev 01)
05:00.0 VGA compatible controller: ATI Technologies Inc RV370 5B60 [Radeon X300 (PCIE)]
05:00.1 Display controller: ATI Technologies Inc RV370 [Radeon X300SE]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
