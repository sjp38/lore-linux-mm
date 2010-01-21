Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F38CF6B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 16:48:13 -0500 (EST)
Date: Thu, 21 Jan 2010 14:47:49 -0700
From: Alex Chiang <achiang@hp.com>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-ID: <20100121214749.GJ17684@ldl.fc.hp.com>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001151358110.6590@router.home> <1263587721.20615.255.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.1001151730350.10558@router.home> <alpine.DEB.2.00.1001191252370.25101@router.home> <20100119200228.GE11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191427370.26683@router.home> <20100119212935.GG11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191545170.26683@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001191545170.26683@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph sent me another debug patch off-list.

Here is another dump of dmesg. I tried to trim it a little bit
where it made sense.

ELILO boot: achiang slub_debug
Uncompressing Linux... done
Loading file initrd-2.6.33-rc3-next-20100111-dirty...done
Initializing cgroup subsys cpuset
Linux version 2.6.33-rc3-next-20100111-dirty (root@coffee0) (gcc version 4.3.2 [gcc-4_3-branch revision 141291] (SUSE Linux) ) #21 SMP Thu Jan 21 13:44:31 MST 2010

[...]

16 CPUs available, 16 CPUs total
ACPI: SLIT table looks invalid. Not used.
Number of logical nodes in system = 3
Number of memory chunks in system = 5
SMP: Allowing 16 CPUs, 0 hotplug CPUs
warning: skipping physical page 0
warning: skipping physical page 0
warning: skipping physical page 0
warning: skipping physical page 0
Initial ramdisk at: 0xe0000787fa9c6000 (6058234 bytes)
SAL 3.20: HP Orca/IPF version 9.48
SAL Platform features: None
SAL: AP wakeup using external interrupt vector 0xff
ACPI: Local APIC address c0000000fee00000
GSI 16 (level, low) -> CPU 0 (0x0000) vector 49
MCA related initialization done
warning: skipping physical page 0
Virtual mem_map starts at 0xa07ffffe5a400000
Zone PFN ranges:
  DMA      0x00000001 -> 0x00010000
  Normal   0x00010000 -> 0x0787fc00
Movable zone start PFN for each node
early_node_map[5] active PFN ranges
    2: 0x00000001 -> 0x00001ffe
    0: 0x07002000 -> 0x07005db7
    0: 0x07005db8 -> 0x0707fb00
    1: 0x07800000 -> 0x0787fbd9
    1: 0x0787fbe8 -> 0x0787fbfd
On node 0 totalpages: 514815
free_area_init_node: node 0, pgdat e000070020080000, node_mem_map a07fffffe2470000
  Normal zone: 440 pages used for memmap
  Normal zone: 514375 pages, LIFO batch:1
On node 1 totalpages: 523246
free_area_init_node: node 1, pgdat e000078000090080, node_mem_map a07ffffffe400000
  Normal zone: 448 pages used for memmap
  Normal zone: 522798 pages, LIFO batch:1
On node 2 totalpages: 8189
free_area_init_node: node 2, pgdat e000000000120100, node_mem_map a07ffffe5a400000
  DMA zone: 7 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 8182 pages, LIFO batch:0
pcpu-alloc: s43032 r8192 d14312 u65536 alloc=1*65536
pcpu-alloc: [0] 00 [0] 01 [0] 02 [0] 03 [0] 04 [0] 05 [0] 06 [0] 07 
pcpu-alloc: [1] 08 [1] 09 [1] 10 [1] 11 [1] 12 [1] 13 [1] 14 [1] 15 
Built 3 zonelists in Zone order, mobility grouping on.  Total pages: 1045355
Policy zone: Normal
Kernel command line: BOOT_IMAGE=scsi1:\efi\SuSE\vmlinuz-2.6.33-rc3-next-20100111-dirty root=/dev/disk/by-id/scsi-35001d38000048bd8-part2  debug slub_debug
PID hash table entries: 4096 (order: -1, 32768 bytes)
Memory: 66849344k/66910528k available (8033k code, 110720k reserved, 10804k data, 1984k init)
SLUB: Unable to allocate memory from node 2
SLUB: Allocating a useless per node structure in order to be able to continue
Creating slab kmem_cache_node size=64 realsize=136 order=0 offset=72 flags=0
Creating slab kmalloc-96 size=96 realsize=168 order=0 offset=104 flags=0
Creating slab kmalloc-192 size=192 realsize=264 order=0 offset=200 flags=0
Creating slab kmalloc size=8 realsize=80 order=0 offset=16 flags=0
Creating slab kmalloc size=16 realsize=88 order=0 offset=24 flags=0
Creating slab kmalloc size=32 realsize=104 order=0 offset=40 flags=0
Creating slab kmalloc size=64 realsize=136 order=0 offset=72 flags=0
Creating slab kmalloc size=128 realsize=200 order=0 offset=136 flags=0
Creating slab kmalloc size=256 realsize=328 order=0 offset=264 flags=0
Creating slab kmalloc size=512 realsize=584 order=0 offset=520 flags=0
Creating slab kmalloc size=1024 realsize=1096 order=0 offset=1032 flags=0
Creating slab kmalloc size=2048 realsize=2120 order=0 offset=2056 flags=0
Creating slab kmalloc size=4096 realsize=4168 order=1 offset=4104 flags=0
Creating slab kmalloc size=8192 realsize=8264 order=2 offset=8200 flags=0
Creating slab kmalloc size=16384 realsize=16456 order=3 offset=16392 flags=0
Creating slab kmalloc size=32768 realsize=32840 order=3 offset=32776 flags=0
Creating slab kmalloc size=65536 realsize=65608 order=3 offset=65544 flags=0
Creating slab kmalloc size=131072 realsize=131144 order=3 offset=131080 flags=0
SLUB: Genslabs=18, HWalign=128, Order=0-3, MinObjects=0, CPUs=16, Nodes=1024
Hierarchical RCU implementation.
NR_IRQS:1024
CPU 0: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
Console: colour dummy device 80x25
Creating slab idr_layer_cache size=544 realsize=616 order=0 offset=552 flags=40000
Creating slab numa_policy size=264 realsize=336 order=0 offset=272 flags=40000
Creating slab shared_policy_node size=48 realsize=120 order=0 offset=56 flags=40000
Calibrating delay loop... 3194.88 BogoMIPS (lpj=6389760)
Creating slab pid size=80 realsize=256 order=0 offset=88 flags=42000
Creating slab anon_vma size=24 realsize=96 order=0 offset=32 flags=c0000
Creating slab cred_jar size=104 realsize=256 order=0 offset=112 flags=42000
Creating slab sighand_cache size=1576 realsize=1664 order=0 offset=1584 flags=c2000
Creating slab signal_cache size=808 realsize=896 order=0 offset=816 flags=42000
Creating slab files_cache size=768 realsize=896 order=0 offset=776 flags=42000
Creating slab fs_cache size=48 realsize=128 order=0 offset=56 flags=42000
Creating slab mm_struct size=1280 realsize=1408 order=0 offset=1288 flags=42000
Creating slab vm_area_struct size=176 realsize=248 order=0 offset=184 flags=40000
Creating slab buffer_head size=104 realsize=176 order=0 offset=112 flags=160000
Creating slab names_cache size=4096 realsize=4224 order=1 offset=4104 flags=42000
Creating slab dentry size=192 realsize=264 order=0 offset=200 flags=160000
Dentry cache hash table entries: 8388608 (order: 10, 67108864 bytes)
Creating slab inode_cache size=536 realsize=608 order=0 offset=544 flags=160000
Inode-cache hash table entries: 4194304 (order: 9, 33554432 bytes)
Creating slab filp size=184 realsize=256 order=0 offset=192 flags=42000
Creating slab mnt_cache size=232 realsize=384 order=0 offset=240 flags=42000
Mount-cache hash table entries: 4096
Creating slab sysfs_dir_cache size=80 realsize=152 order=0 offset=88 flags=0
Creating slab bdev_cache size=784 realsize=896 order=0 offset=792 flags=162000
Creating slab radix_tree_node size=552 realsize=624 order=0 offset=560 flags=60000
Creating slab sigqueue size=160 realsize=232 order=0 offset=168 flags=40000
Creating slab proc_inode_cache size=584 realsize=656 order=0 offset=592 flags=160000
ACPI: Core revision 20091214
Creating slab Acpi-Namespace size=32 realsize=104 order=0 offset=40 flags=0
Creating slab Acpi-State size=80 realsize=152 order=0 offset=88 flags=0
Creating slab Acpi-Parse size=48 realsize=120 order=0 offset=56 flags=0
Creating slab Acpi-ParseExt size=72 realsize=144 order=0 offset=80 flags=0
Creating slab Acpi-Operand size=72 realsize=144 order=0 offset=80 flags=0
Boot processor id 0x0/0x0
Fixed BSP b0 value from CPU 1

[...]

Total of 16 processors activated (51118.08 BogoMIPS).
Creating slab shmem_inode_cache size=744 realsize=816 order=0 offset=752 flags=40000
DMI 2.5 present.
Creating slab file_lock_cache size=176 realsize=248 order=0 offset=184 flags=40000
Creating slab skbuff_head_cache size=200 realsize=384 order=0 offset=208 flags=42000
Creating slab skbuff_fclone_cache size=404 realsize=512 order=0 offset=408 flags=42000
Creating slab sock_inode_cache size=608 realsize=768 order=0 offset=616 flags=122000
NET: Registered protocol family 16
ACPI: bus type pci registered
Creating slab biovec-16 size=256 realsize=384 order=0 offset=264 flags=42000
Creating slab biovec-64 size=1024 realsize=1152 order=0 offset=1032 flags=42000
Creating slab biovec-128 size=2048 realsize=2176 order=0 offset=2056 flags=42000
Creating slab biovec-256 size=4096 realsize=4224 order=1 offset=4104 flags=42000
Creating slab bio-0 size=168 realsize=256 order=0 offset=176 flags=2000
bio: create slab <bio-0> at 0
Creating slab fsnotify_event size=112 realsize=184 order=0 offset=120 flags=40000
Creating slab fsnotify_event_holder size=24 realsize=96 order=0 offset=32 flags=40000
Creating slab blkdev_ioc size=80 realsize=152 order=0 offset=88 flags=40000
Creating slab blkdev_requests size=336 realsize=408 order=0 offset=344 flags=40000
Creating slab blkdev_queue size=2184 realsize=2256 order=0 offset=2192 flags=40000
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled

[... PCI info]

vgaarb: device added: PCI:0000:8d:03.0,decodes=io+mem,owns=none,locks=none
vgaarb: loaded
Creating slab scsi_data_buffer size=24 realsize=96 order=0 offset=32 flags=0
Creating slab sgpool-8 size=256 realsize=384 order=0 offset=264 flags=2000
Creating slab sgpool-16 size=512 realsize=640 order=0 offset=520 flags=2000
Creating slab sgpool-32 size=1024 realsize=1152 order=0 offset=1032 flags=2000
Creating slab sgpool-64 size=2048 realsize=2176 order=0 offset=2056 flags=2000
Creating slab sgpool-128 size=4096 realsize=4224 order=1 offset=4104 flags=2000
SCSI subsystem initialized
libata version 3.00 loaded.
IOC: sx2000 0.1 HPA 0xf8020002000 IOVA space 1024Mb at 0x40000000
IOC: sx2000 0.1 HPA 0xf8020003000 IOVA space 1024Mb at 0x40000000
IOC: sx2000 0.1 HPA 0xf8120002000 IOVA space 1024Mb at 0x40000000
IOC: sx2000 0.1 HPA 0xf8120003000 IOVA space 1024Mb at 0x40000000
DMA-API: preallocated 65536 debug entries
DMA-API: debugging enabled by kernel config
Switching to clocksource itc
Creating slab eventpoll_epi size=128 realsize=256 order=0 offset=136 flags=42000
Creating slab eventpoll_pwq size=72 realsize=144 order=0 offset=80 flags=40000
pnp: PnP ACPI init
ACPI: bus type pnp registered
GSI 17 (level, low) -> CPU 2 (0x0400) vector 50
GSI 18 (edge, low) -> CPU 3 (0x0500) vector 51
GSI 19 (edge, low) -> CPU 4 (0x0800) vector 52
GSI 20 (edge, low) -> CPU 5 (0x0900) vector 53
GSI 23 (level, low) -> CPU 6 (0x0c00) vector 54
GSI 126 (edge, low) -> CPU 15 (0x0d01) vector 55
GSI 127 (edge, low) -> CPU 8 (0x0001) vector 56
GSI 128 (edge, low) -> CPU 9 (0x0101) vector 57
pnp: PnP ACPI: found 36 devices
ACPI: ACPI bus type pnp unregistered
Creating slab TCP size=1440 realsize=1536 order=0 offset=1448 flags=82000
Creating slab request_sock_TCP size=96 realsize=256 order=0 offset=104 flags=2000
Creating slab tw_sock_TCP size=152 realsize=256 order=0 offset=160 flags=82000
Creating slab UDP size=712 realsize=896 order=0 offset=720 flags=82000
Creating slab RAW size=688 realsize=768 order=0 offset=696 flags=2000
NET: Registered protocol family 2
Creating slab arp_cache size=212 realsize=384 order=0 offset=216 flags=42000
Creating slab ip_dst_cache size=328 realsize=512 order=0 offset=336 flags=42000
IP route cache hash table entries: 524288 (order: 6, 4194304 bytes)
Creating slab ip_fib_hash size=72 realsize=144 order=0 offset=80 flags=40000
Creating slab ip_fib_alias size=32 realsize=104 order=0 offset=40 flags=40000
Creating slab xfrm_dst_cache size=360 realsize=512 order=0 offset=368 flags=42000
Creating slab secpath_cache size=56 realsize=128 order=0 offset=64 flags=42000
Creating slab inet_peer_cache size=64 realsize=192 order=0 offset=72 flags=42000
Creating slab tcp_bind_bucket size=32 realsize=128 order=0 offset=40 flags=42000
TCP established hash table entries: 524288 (order: 7, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 4, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
UDP hash table entries: 32768 (order: 4, 1048576 bytes)
UDP-Lite hash table entries: 32768 (order: 4, 1048576 bytes)
Creating slab UDP-Lite size=712 realsize=896 order=0 offset=720 flags=82000
Creating slab UNIX size=672 realsize=768 order=0 offset=680 flags=2000
NET: Registered protocol family 1
PCI: CLS 128 bytes, default 128
Trying to unpack rootfs image as initramfs...
Freeing initrd memory: 5824kB freed
perfmon: version 2.0 IRQ 238
perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
Creating slab ia64_partial_page_cache size=48 realsize=120 order=0 offset=56 flags=40000
Please use IA-32 EL for executing IA-32 binaries
Creating slab uid_cache size=80 realsize=256 order=0 offset=88 flags=42000
Creating slab posix_timers_cache size=144 realsize=216 order=0 offset=152 flags=40000
Creating slab nsproxy size=48 realsize=120 order=0 offset=56 flags=40000
HugeTLB registered 256 MB page size, pre-allocated 0 pages
Creating slab fasync_cache size=24 realsize=96 order=0 offset=32 flags=40000
Creating slab dnotify_struct size=32 realsize=104 order=0 offset=40 flags=40000
Creating slab dnotify_mark size=128 realsize=200 order=0 offset=136 flags=40000
Creating slab inotify_inode_mark size=128 realsize=200 order=0 offset=136 flags=40000
Creating slab inotify_event_private_data size=32 realsize=104 order=0 offset=40 flags=40000
Creating slab fsnotify_mark size=120 realsize=192 order=0 offset=128 flags=40000
Creating slab fanotify_response_event size=32 realsize=104 order=0 offset=40 flags=40000
Creating slab kiocb size=200 realsize=384 order=0 offset=208 flags=42000
Creating slab kioctx size=320 realsize=512 order=0 offset=328 flags=42000
Creating slab ext3_xattr size=88 realsize=160 order=0 offset=96 flags=120000
Creating slab ext3_inode_cache size=768 realsize=840 order=0 offset=776 flags=120000
Creating slab ext2_xattr size=88 realsize=160 order=0 offset=96 flags=120000
Creating slab ext2_inode_cache size=744 realsize=816 order=0 offset=752 flags=120000
Creating slab revoke_record size=24 realsize=96 order=0 offset=32 flags=22000
Creating slab revoke_table size=16 realsize=88 order=0 offset=24 flags=20000
Creating slab journal_head size=112 realsize=184 order=0 offset=120 flags=20000
Creating slab journal_handle size=24 realsize=96 order=0 offset=32 flags=20000
Creating slab hugetlbfs_inode_cache size=552 realsize=624 order=0 offset=560 flags=0
Creating slab fat_cache size=32 realsize=104 order=0 offset=40 flags=120000
Creating slab fat_inode_cache size=616 realsize=688 order=0 offset=624 flags=120000
msgmni has been set to 32768
Creating slab mqueue_inode_cache size=824 realsize=896 order=0 offset=832 flags=2000
alg: No test for stdrng (krng)
io scheduler noop registered
io scheduler deadline registered
Creating slab cfq_queue size=272 realsize=344 order=0 offset=280 flags=0
Creating slab cfq_io_context size=136 realsize=208 order=0 offset=144 flags=0
io scheduler cfq registered (default)
hpet0: at MMIO 0xffff6030000, IRQs 51, 52, 53
hpet0: 3 comparators, 64-bit 267.000025 MHz counter
hpet1: at MMIO 0xffff60b0000, IRQs 55, 56, 57
hpet1: 3 comparators, 64-bit 267.000025 MHz counter
EFI Time Services Driver v0.4
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
00:03: ttyS0 at MMIO 0xffc30064000 (irq = 54) is a 16550A
console [ttyS0] enabled, bootconsole disabled
console [ttyS0] enabled, bootconsole disabled
brd: module loaded
Uniform Multi-Platform E-IDE driver
ide-gd driver 1.18
ide-cd driver 5.00
Creating slab sd_ext_cdb size=32 realsize=104 order=0 offset=40 flags=0
Intel(R) PRO/1000 Network Driver - version 7.3.21-k5-NAPI

[...]

Fusion MPT base driver 3.04.13
Copyright (c) 1999-2008 LSI Corporation
Fusion MPT SPI Host driver 3.04.13
GSI 25 (level, low) -> CPU 6 (0x0c00) vector 94
mptspi 0000:00:02.0: PCI INT A -> GSI 25 (level, low) -> IRQ 94
mptbase: ioc0: Initiating bringup
ioc0: LSI53C1030 C0: Capabilities={Initiator,Target}
scsi0 : ioc0: LSI53C1030 C0, FwRev=01032346h, Ports=1, MaxQ=255, IRQ=94
Creating slab scsi_cmd_cache size=232 realsize=384 order=0 offset=240 flags=2000
Creating slab scsi_sense_cache size=96 realsize=256 order=0 offset=104 flags=2000
scsi 0:0:6:0: Direct-Access     HP 73.4G ST373455LC       HPC8 PQ: 0 ANSI: 3
 target0:0:6: Beginning Domain Validation
 target0:0:6: Ending Domain Validation
 target0:0:6: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI WRFLOW PCOMP (6.25 ns, offset 127)
sd 0:0:6:0: [sda] 143374738 512-byte logical blocks: (73.4 GB/68.3 GiB)
sd 0:0:6:0: [sda] Write Protect is off
sd 0:0:6:0: [sda] Mode Sense: d3 00 10 08
sd 0:0:6:0: [sda] Write cache: disabled, read cache: enabled, supports DPO and FUA
 sda:
GSI 26 (level, low) -> CPU 7 (0x0d00) vector 95
mptspi 0000:00:02.1: PCI INT B -> GSI 26 (level, low) -> IRQ 95
mptbase: ioc1: Initiating bringup
ioc1: LSI53C1030 C0: Capabilities={Initiator,Target}
scsi1 : ioc1: LSI53C1030 C0, FwRev=01032346h, Ports=1, MaxQ=255, IRQ=95
 sda1 sda2 sda3
sd 0:0:6:0: [sda] Attached SCSI disk
scsi 1:0:2:0: CD-ROM            Optiarc  DVD RW AD-5170A  1.32 PQ: 0 ANSI: 2
 target1:0:2: Beginning Domain Validation
 target1:0:2: Domain Validation skipping write tests
 target1:0:2: Ending Domain Validation
 target1:0:2: FAST-20 WIDE SCSI 40.0 MB/s ST (50 ns, offset 14)
GSI 27 (level, low) -> CPU 0 (0x0000) vector 96

[...]

mice: PS/2 mouse device common for all mice
EFI Variables Facility v0.08 2004-May-17
Creating slab flow_cache size=96 realsize=168 order=0 offset=104 flags=40000
TCP cubic registered
NET: Registered protocol family 17
Freeing unused kernel memory: 1984kB freed
doing fast boot
FATAL: Module mptspi not found.
FATAL: Module jbd not found.
FATAL: Module ext3 not found.
preping 03-storage.sh
running 03-storage.sh
preping 04-udev.sh
running 04-udev.sh
Creating device nodes with udev
udevd version 128 started

[...]

fsck succeeded. Mounting root device read-write.
Mounting root /dev/disk/by-id/scsi-35001d38000048bd8-part2
mount -o rw,acl,user_xattr -t ext3 /dev/disk/by-id/scsi-35001d38000048bd8-part2 /root
kjournald starting.  Commit interval 5 seconds
EXT3-fs (sdb2): using internal journal
EXT3-fs (sdb2): mounted filesystem with writeback data mode
preping 82-remount.sh
running 82-remount.sh
preping 91-createfb.sh
running 91-createfb.sh
preping 91-killblogd.sh
running 91-killblogd.sh
preping 91-killudev.sh
running 91-killudev.sh
preping 91-shell.sh
running 91-shell.sh
preping 92-killblogd2.sh
running 92-killblogd2.sh
preping 93-boot.sh
running 93-boot.sh
mount: can't find /root/proc in /etc/fstab or /etc/mtab
INIT: version 2.86 booting
System Boot Control: Running /etc/init.d/boot
Mounting procfs at /proc                                             done
Mounting sysfs at /sys                                               done
Remounting tmpfs at /dev                                             done
Initializing /dev                                                    done
Mounting devpts at /dev/pts                                          done
Starting udevd: udevd version 128 started
                                                                     done
Loading drivers, configuring devices: input: Power Button as /class/input/input2
ACPI: Power Button [PWRB]
input: Sleep Button as /class/input/input3
ACPI: Sleep Button [SLPF]
sd 0:0:6:0: Attached scsi generic sg0 type 0
scsi 1:0:2:0: Attached scsi generic sg1 type 5
sd 2:0:6:0: Attached scsi generic sg2 type 0
sd 4:0:6:0: Attached scsi generic sg3 type 0
scsi 5:0:2:0: Attached scsi generic sg4 type 5
sd 6:0:6:0: Attached scsi generic sg5 type 0
Creating slab kmalloc_dma-512 size=512 realsize=584 order=0 offset=520 flags=40004000
sr0: scsi3-mmc drive: 48x/48x writer cd/rw xa/form2 cdda tray
Bad address on kfree a=e00007861f1b0000 page=a07fffffff96cde8

Call Trace:
 [<a000000100016950>] show_stack+0x50/0xa0
                                sp=e0000706296ffc20 bsp=e0000706296f1278
 [<a0000001007d00a0>] dump_stack+0x30/0x50
                                sp=e0000706296ffdf0 bsp=e0000706296f1260
 [<a0000001001ae8e0>] kfree+0xe0/0x260
                                sp=e0000706296ffdf0 bsp=e0000706296f1230
 [<a000000207dd1df0>] sr_probe+0xad0/0xf20 [sr_mod]
                                sp=e0000706296ffdf0 bsp=e0000706296f11c8
 [<a00000010048ac40>] driver_probe_device+0x180/0x300
                                sp=e0000706296ffe20 bsp=e0000706296f1190
 [<a00000010048aea0>] __driver_attach+0xe0/0x140
                                sp=e0000706296ffe20 bsp=e0000706296f1160
 [<a0000001004898a0>] bus_for_each_dev+0xa0/0x140
                                sp=e0000706296ffe20 bsp=e0000706296f1128
 [<a00000010048a860>] driver_attach+0x40/0x60
                                sp=e0000706296ffe30 bsp=e0000706296f1108
 [<a000000100488780>] bus_add_driver+0x180/0x520
                                sp=e0000706296ffe30 bsp=e0000706296f10c0
 [<a00000010048b660>] driver_register+0x260/0x400
                                sp=e0000706296ffe30 bsp=e0000706296f1078
 [<a0000001004df640>] scsi_register_driver+0x40/0x60
                                sp=e0000706296ffe30 bsp=e0000706296f1058
 [<a000000207e00070>] init_sr+0x70/0x140 [sr_mod]
                                sp=e0000706296ffe30 bsp=e0000706296f1038
 [<a00000010000a960>] do_one_initcall+0xe0/0x360
                                sp=e0000706296ffe30 bsp=e0000706296f0ff0
 [<a000000100106040>] sys_init_module+0x1e0/0x4c0
                                sp=e0000706296ffe30 bsp=e0000706296f0f78
 [<a00000010000c700>] ia64_ret_from_syscall+0x0/0x20
                                sp=e0000706296ffe30 bsp=e0000706296f0f78
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=e000070629700000 bsp=e0000706296f0f78
Uniform CD-ROM driver Revision: 3.20
sr 1:0:2:0: Attached scsi CD-ROM sr0
modprobe[6067]: NaT consumption 17179869216 [1]
Modules linked in: sr_mod(+) sg button container(+) usbhid ohci_hcd ehci_hcd usbcore fan thermal processor thermal_sys

Pid: 6067, CPU 9, comm:             modprobe
psr : 0000101008522010 ifs : 8000000000000814 ip  : [<a0000001001ac900>]    Not tainted (2.6.33-rc3-next-20100111-dirty)
ip is at __slab_alloc+0x80/0xca0
unat: 0000000000000000 pfs : 000000000000038c rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : aa99aaa6aa565699
ldrs: 0000000000000000 ccv : 00000000000000c2 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001af8e0 b6  : a0000001003623a0 b7  : a00000010046df40
f6  : 1003e0000000000000000 f7  : 1003e0a7c5ac471b47843
f8  : 1003e0000000000000000 f9  : 1003effffffffffffff98
f10 : 10003b7ffffffff158148 f11 : 1003e0000000000000000
r1  : a0000001014480f0 r2  : 0000000000000009 r3  : a00000010125f6c0
r8  : a0000001010375f0 r9  : 0000000000000001 r10 : ffffffffffff6690
r11 : 00000000003fffff r12 : e0000706296ffde0 r13 : e0000706296f0000
r14 : e000078000026698 r15 : e000078000030000 r16 : a0000001011553a8
r17 : 0000000000000f3d r18 : 0000000000000800 r19 : e000078603e3d6a0
r20 : 0000000000000000 r21 : 0000000000000031 r22 : a000000101037608
r23 : 0000000afffffffb r24 : 0000000000000005 r25 : 0000000000000000
r26 : 0000000000000000 r27 : 0000000000000000 r28 : 0000000000000001
r29 : 0000000000000000 r30 : 0000000000000000 r31 : 0000000000000000

Call Trace:
 [<a000000100016950>] show_stack+0x50/0xa0
                                sp=e0000706296ff830 bsp=e0000706296f1430
 [<a0000001000171c0>] show_regs+0x820/0x860
                                sp=e0000706296ffa00 bsp=e0000706296f13d0
 [<a00000010003bc40>] die+0x1a0/0x300
                                sp=e0000706296ffa00 bsp=e0000706296f1390
 [<a00000010003bdf0>] die_if_kernel+0x50/0x80
                                sp=e0000706296ffa00 bsp=e0000706296f1360
 [<a00000010003cfe0>] ia64_fault+0x11c0/0x1280
                                sp=e0000706296ffa00 bsp=e0000706296f1308
 [<a00000010000c8a0>] ia64_native_leave_kernel+0x0/0x270
                                sp=e0000706296ffc10 bsp=e0000706296f1308
 [<a0000001001ac900>] __slab_alloc+0x80/0xca0
                                sp=e0000706296ffde0 bsp=e0000706296f1268
 [<a0000001001af8e0>] __kmalloc+0x1c0/0x280
                                sp=e0000706296ffdf0 bsp=e0000706296f1230
 [<a000000207dd16d0>] sr_probe+0x3b0/0xf20 [sr_mod]
                                sp=e0000706296ffdf0 bsp=e0000706296f11c8
 [<a00000010048ac40>] driver_probe_device+0x180/0x300
                                sp=e0000706296ffe20 bsp=e0000706296f1190
 [<a00000010048aea0>] __driver_attach+0xe0/0x140
                                sp=e0000706296ffe20 bsp=e0000706296f1160
 [<a0000001004898a0>] bus_for_each_dev+0xa0/0x140
                                sp=e0000706296ffe20 bsp=e0000706296f1128
 [<a00000010048a860>] driver_attach+0x40/0x60
                                sp=e0000706296ffe30 bsp=e0000706296f1108
 [<a000000100488780>] bus_add_driver+0x180/0x520
                                sp=e0000706296ffe30 bsp=e0000706296f10c0
 [<a00000010048b660>] driver_register+0x260/0x400
                                sp=e0000706296ffe30 bsp=e0000706296f1078
 [<a0000001004df640>] scsi_register_driver+0x40/0x60
                                sp=e0000706296ffe30 bsp=e0000706296f1058
 [<a000000207e00070>] init_sr+0x70/0x140 [sr_mod]
                                sp=e0000706296ffe30 bsp=e0000706296f1038
 [<a00000010000a960>] do_one_initcall+0xe0/0x360
                                sp=e0000706296ffe30 bsp=e0000706296f0ff0
 [<a000000100106040>] sys_init_module+0x1e0/0x4c0
                                sp=e0000706296ffe30 bsp=e0000706296f0f78
 [<a00000010000c700>] ia64_ret_from_syscall+0x0/0x20
                                sp=e0000706296ffe30 bsp=e0000706296f0f78
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=e000070629700000 bsp=e0000706296f0f78
Disabling lock debugging due to kernel taint
udevd-event[6066]: '/sbin/modprobe' abnormal exit

                                                                     done
Loading required kernel modules                                      done
Activating swap-devices in /etc/fstab...
Adding 2104384k swap on /dev/sda2.  Priority:-1 extents:1 across:2104done 
Setting up the hardware clock                                        done
Activating device mapper...
Creating slab dm_io size=40 realsize=112 order=0 offset=48 flags=0
Creating slab dm_target_io size=24 realsize=96 order=0 offset=32 flags=0
Creating slab dm_rq_target_io size=376 realsize=448 order=0 offset=384 flags=0
Creating slab dm_rq_clone_bio_info size=16 realsize=88 order=0 offset=24 flags=0
Creating slab io size=64 realsize=192 order=0 offset=72 flags=0
Creating slab kcopyd_job size=384 realsize=456 order=0 offset=392 flags=0
device-mapper: ioctl: 4.16.0-ioctl (2009-11-05) initialised: dm-devel@redhat.com
                                                                     done
Checking file systems...
fsck 1.41.1 (01-Sep-2008)
Checking all file systems.                                           done
                                                                     done
Mounting local file systems...

[...]

Welcome to SUSE Linux Enterprise Server 11 (ia64) - Kernel 2.6.33-rc3-next-20100111-dirty (console).


coffee0 login: 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
