Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D60F6B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 07:46:25 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id g124so171556025qkd.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 04:46:25 -0700 (PDT)
Received: from mail-ua0-x236.google.com (mail-ua0-x236.google.com. [2607:f8b0:400c:c08::236])
        by mx.google.com with ESMTPS id b30si5961601uaa.16.2016.08.16.04.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Aug 2016 04:46:23 -0700 (PDT)
Received: by mail-ua0-x236.google.com with SMTP id n59so116748736uan.2
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 04:46:23 -0700 (PDT)
MIME-Version: 1.0
From: Anatoly Pugachev <matorola@gmail.com>
Date: Tue, 16 Aug 2016 14:46:22 +0300
Message-ID: <CADxRZqxj=NjrPDDdXkFRp98MBqXZxf5tF0CpoyF-hfX8oDw1hA@mail.gmail.com>
Subject: [sparc64] git kernel TPC and OOPS after enabling CONFIG_DEBUG_SLAB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sparclinux@vger.kernel.org
Cc: linux-mm@kvack.org, debian-sparc <debian-sparc@lists.debian.org>

Hello!

I'm getting kernel (git describe v4.8-rc2-6-g3684b03) TPC and OOPS
after enabling CONFIG_DEBUG_SLAB=y on my test sparc64 debian sid
machine.
I wasn't able to trace back when it was introduced, but 4.6 and 4.7
kernels is also affected.

Boot log (dmesg):


[    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 4.33.6.g 2016/03/11 06:05'
[    0.000000] PROMLIB: Root node compatible: sun4v
[    0.000000] Linux version 4.8.0-rc2+ (mator@nvg5120) (gcc version
6.1.1 20160802 (Debian 6.1.1-11) ) #73 SMP Tue Aug 16 14:15:35 MSK
2016
[    0.000000] debug: skip boot console de-registration.
[    0.000000] bootconsole [earlyprom0] enabled
[    0.000000] ARCH: SUN4V
[    0.000000] Ethernet address: 00:14:4f:ac:4a:18
[    0.000000] MM: PAGE_OFFSET is 0xffff800000000000 (max_phys_bits == 39)
[    0.000000] MM: VMALLOC [0x0000000100000000 --> 0x0000600000000000]
[    0.000000] MM: VMEMMAP [0x0000600000000000 --> 0x0000c00000000000]
[    0.000000] Kernel: Using 2 locked TLB entries for main kernel image.
[    0.000000] Remapping the kernel... done.
[    0.000000] OF stdout device is: /virtual-devices@100/console@1
[    0.000000] PROM: Built device tree with 195069 bytes of memory.
[    0.000000] MDESC: Size is 61728 bytes.
[    0.000000] PLATFORM: banner-name [SPARC Enterprise T5120]
[    0.000000] PLATFORM: name [SUNW,SPARC-Enterprise-T5120]
[    0.000000] PLATFORM: hostid [84ac4a18]
[    0.000000] PLATFORM: serial# [00ab4130]
[    0.000000] PLATFORM: stick-frequency [457646c0]
[    0.000000] PLATFORM: mac-address [144fac4a18]
[    0.000000] PLATFORM: watchdog-resolution [1000 ms]
[    0.000000] PLATFORM: watchdog-max-timeout [31536000000 ms]
[    0.000000] PLATFORM: max-cpus [64]
[    0.000000] Top of RAM: 0x3ffb16000, Total RAM: 0x3f76ac000
[    0.000000] Memory hole size: 132MB
[    0.000000] Allocated 16384 bytes for kernel page tables.
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x0000000008400000-0x00000003ffb15fff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000008400000-0x00000003ffa89fff]
[    0.000000]   node   0: [mem 0x00000003ffa9a000-0x00000003ffaadfff]
[    0.000000]   node   0: [mem 0x00000003ffb08000-0x00000003ffb15fff]
[    0.000000] Initmem setup node 0 [mem 0x0000000008400000-0x00000003ffb15fff]
[    0.000000] On node 0 totalpages: 2079574
[    0.000000]   Normal zone: 18278 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 2079574 pages, LIFO batch:15
[    0.000000] Booting Linux...
[    0.000000] CPU CAPS: [flush,stbar,swap,muldiv,v9,blkinit,n2,mul32]
[    0.000000] CPU CAPS: [div32,v8plus,popc,vis,vis2,ASIBlkInit]
[    0.000000] percpu: Embedded 9 pages/cpu @ffff8003ff000000 s34200
r8192 d31336 u131072
[    0.000000] pcpu-alloc: s34200 r8192 d31336 u131072 alloc=1*4194304
[    0.000000] pcpu-alloc: [0] 00 01 02 03 04 05 06 07 08 09 10 11 12
13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
[    0.000000] pcpu-alloc: [0] 32 33 34 35 36 37 38 39 40 41 42 43 44
45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63
[    0.000000] SUN4V: Mondo queue sizes [cpu(8192) dev(16384) r(8192) nr(256)]
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
Total pages: 2061296
[    0.000000] Kernel command line: root=/dev/mapper/vg1-root ro
zswap.enabled=1 keep_bootcon console=ttyS0 noresume
[    0.000000] log_buf_len individual max cpu contribution: 4096 bytes
[    0.000000] log_buf_len total cpu_extra contributions: 258048 bytes
[    0.000000] log_buf_len min size: 131072 bytes
[    0.000000] log_buf_len: 524288 bytes
[    0.000000] early log buf free: 127576(97%)
[    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 2097152 (order: 11,
16777216 bytes)
[    0.000000] Inode-cache hash table entries: 1048576 (order: 10,
8388608 bytes)
[    0.000000] Sorting __ex_table...
[    0.000000] Memory: 16433256K/16636592K available (4999K kernel
code, 481K rwdata, 1320K rodata, 304K init, 984K bss, 203336K
reserved, 0K cma-reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  Build-time adjustment of leaf fanout to 64.
[    0.000000]  RCU restricting CPUs from NR_CPUS=256 to nr_cpu_ids=64.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=64
[    0.000000] NR_IRQS:2048 nr_irqs:2048 1
[    0.000000] SUN4V: Using IRQ API major 1, cookie only virqs disabled
[1349360.944214] clocksource: stick: mask: 0xffffffffffffffff
max_cycles: 0x10cc5ac4c8a, max_idle_ns: 440795218862 ns
[1349360.950803] clocksource: mult[dbabc5] shift[24]
[1349360.952989] clockevent: mult[952b25d1] shift[31]
[1349360.956004] Console: colour dummy device 80x25
[1349361.068108] Calibrating delay using timer specific routine..
2336.45 BogoMIPS (lpj=4672908)
[1349361.069084] pid_max: default: 65536 minimum: 512
[1349361.071178] Security Framework initialized
[1349361.071509] Yama: becoming mindful.
[1349361.071921] AppArmor: AppArmor disabled by boot time parameter
[1349361.073047] Mount-cache hash table entries: 32768 (order: 5, 262144 bytes)
[1349361.073567] Mountpoint-cache hash table entries: 32768 (order: 5,
262144 bytes)
[1349361.364309] Brought up 64 CPUs
[1349361.403569] devtmpfs: initialized
[1349361.483269] Performance events:
[1349361.483927] Testing NMI watchdog ...
[1349361.564324] OK.
[1349361.564645] Supported PMU type is 'niagara2'
[1349361.610417] ldc.c:v1.1 (July 22, 2008)
[1349361.612259] clocksource: jiffies: mask: 0xffffffff max_cycles:
0xffffffff, max_idle_ns: 7645041785100000 ns
[1349361.646594] prandom: seed boundary self test passed
[1349361.651476] prandom: 100 self tests passed
[1349361.705082] NET: Registered protocol family 16
[1349361.793993] VIO: Adding device channel-devices
[1349361.795504] VIO: Adding device vlds-port-0-0
[1349361.796811] VIO: Adding device vldc-port-3-0
[1349361.798987] VIO: Adding device vldc-port-3-1
[1349361.800399] VIO: Adding device vldc-port-3-2
[1349361.803845] VIO: Adding device vldc-port-3-3
[1349361.804808] VIO: Adding device vldc-port-3-4
[1349361.805899] VIO: Adding device vldc-port-3-5
[1349361.807377] VIO: Adding device vldc-port-2-0
[1349361.810069] VIO: Adding device vldc-port-0-0
[1349361.811813] VIO: Adding device vldc-port-0-1
[1349361.813495] VIO: Adding device vldc-port-0-2
[1349361.814576] VIO: Adding device vldc-port-1-0
[1349361.815736] VIO: Adding device vldc-port-3-7
[1349361.816892] VIO: Adding device vldc-port-3-8
[1349361.818067] VIO: Adding device ds-1
[1349361.819178] VIO: Adding device ds-0
[1349361.880708] pci_sun4v: Registered hvapi major[1] minor[0]
[1349361.881851] /pci@0: SUN4V PCI Bus Module
[1349361.882154] /pci@0: On NUMA node -1
[1349361.882571] /pci@0: PCI IO[c0f0000000] MEM[c100000000] MEM64[c200000000]
[1349361.883162] /pci@0: Unable to request IOMMU resource.
[1349361.934299] /pci@0: Imported 3 TSB entries from OBP
[1349361.952558] /pci@0: MSI Queue first[0] num[36] count[128] devino[0x18]
[1349361.953395] /pci@0: MSI first[0] num[256] mask[0xff] width[32]
[1349361.953838] /pci@0: MSI addr32[0x7fff0000:0x10000]
addr64[0x3ffff0000:0x10000]
[1349361.954366] /pci@0: MSI queues at RA [00000003f1800000]
[1349361.954777] PCI: Scanning PBM /pci@0
[1349361.955967] pci_sun4v f028ca10: PCI host bridge to bus 0000:02
[1349361.956455] pci_bus 0000:02: root bus resource [io
0xc0f0000000-0xc0ffffffff] (bus address [0x0000-0xfffffff])
[1349361.957200] pci_bus 0000:02: root bus resource [mem
0xc100000000-0xc17ffeffff] (bus address [0x00000000-0x7ffeffff])
[1349361.957978] pci_bus 0000:02: root bus resource [mem
0xc200000000-0xc3fffeffff] (bus address [0x100000000-0x2fffeffff])
[1349361.958761] pci_bus 0000:02: root bus resource [bus 02-12]
[1349361.959886] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[1349361.963073] pci 0000:03:01.0: PME# supported from D0 D3hot D3cold
[1349361.965915] pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
[1349361.968762] pci 0000:05:01.0: PME# supported from D0 D3hot D3cold
[1349361.971549] pci 0000:06:00.0: supports D1
[1349361.971560] pci 0000:06:00.0: PME# supported from D0 D1 D3hot
[1349361.974310] pci 0000:07:00.0: supports D1 D2
[1349361.974321] pci 0000:07:00.0: PME# supported from D0 D1 D2 D3hot
[1349361.976157] pci 0000:07:00.1: supports D1 D2
[1349361.976168] pci 0000:07:00.1: PME# supported from D0 D1 D2 D3hot
[1349361.978085] pci 0000:07:00.2: supports D1 D2
[1349361.978096] pci 0000:07:00.2: PME# supported from D0 D1 D2 D3hot
[1349361.980034] pci 0000:05:02.0: PME# supported from D0 D3hot D3cold
[1349361.982873] pci 0000:08:00.0: PME# supported from D0 D3hot
[1349361.984857] pci 0000:08:00.1: PME# supported from D0 D3hot
[1349361.986901] pci 0000:05:03.0: PME# supported from D0 D3hot D3cold
[1349361.989699] pci 0000:09:00.0: PME# supported from D0 D3hot
[1349361.991704] pci 0000:09:00.1: PME# supported from D0 D3hot
[1349361.993692] pci 0000:03:02.0: PME# supported from D0 D3hot D3cold
[1349361.996470] pci 0000:0a:00.0: supports D1 D2
[1349361.998441] pci 0000:03:08.0: PME# supported from D0 D3hot D3cold
[1349362.001278] pci 0000:0b:00.0: PME# supported from D0 D3hot D3cold
[1349362.004075] pci 0000:0c:01.0: PME# supported from D0 D3hot D3cold
[1349362.006937] pci 0000:0c:02.0: PME# supported from D0 D3hot D3cold
[1349362.009750] pci 0000:0c:08.0: PME# supported from D0 D3hot D3cold
[1349362.012579] pci 0000:0c:09.0: PME# supported from D0 D3hot D3cold
[1349362.015433] pci 0000:0c:0a.0: PME# supported from D0 D3hot D3cold
[1349362.018301] pci 0000:03:09.0: PME# supported from D0 D3hot D3cold
[1349362.106793] HugeTLB registered 8 MB page size, pre-allocated 0 pages
[1349362.319141] vgaarb: loaded
[1349362.330135] SUN4V: Reboot data supported (maj=1,min=0).
[1349362.331623] ds.c:v1.0 (Jul 11, 2007)
[1349362.335468] clocksource: Switched to clocksource stick
[1349362.354866] ds-1: Registered pri service.
[1349362.360214] ds-1: Registered var-config-backup service.
[1349362.391808] VFS: Disk quotas dquot_6.6.0
[1349362.407642] VFS: Dquot-cache hash table entries: 1024 (order 0, 8192 bytes)
[1349362.603527] NET: Registered protocol family 2
[1349362.767627] TCP established hash table entries: 131072 (order: 7,
1048576 bytes)
[1349362.773218] TCP bind hash table entries: 65536 (order: 7, 1048576 bytes)
[1349362.778030] TCP: Hash tables configured (established 131072 bind 65536)
[1349362.782433] UDP hash table entries: 8192 (order: 5, 262144 bytes)
[1349362.784643] UDP-Lite hash table entries: 8192 (order: 5, 262144 bytes)
[1349362.843614] NET: Registered protocol family 1
[1349362.844611] PCI: CLS mismatch (64 != 512), using 64 bytes
[1349362.849212] Unpacking initramfs...
[1349364.383024] Freeing initrd memory: 15272K (ffff80000c800000 -
ffff80000d6ea000)
[1349364.445112] futex hash table entries: 16384 (order: 7, 1048576 bytes)
[1349364.460369] audit: initializing netlink subsys (disabled)
[1349364.461363] audit: type=2000 audit(3.467:1): initialized
[1349364.465105] workingset: timestamp_bits=46 max_order=21 bucket_order=0
[1349364.465963] zbud: loaded
[1349364.668471] Block layer SCSI generic (bsg) driver version 0.4
loaded (major 252)
[1349364.669942] io scheduler noop registered
[1349364.670259] io scheduler deadline registered
[1349364.700291] io scheduler cfq registered (default)
[1349364.722355] crc32: CRC_LE_BITS = 64, CRC_BE BITS = 64
[1349364.723037] crc32: self tests passed, processed 225944 bytes in
2964349 nsec
[1349364.725772] crc32c: CRC_LE_BITS = 64
[1349364.726395] crc32c: self tests passed, processed 225944 bytes in
919103 nsec
[1349364.846284] crc32_combine: 8373 self tests passed
[1349364.966640] crc32c_combine: 8373 self tests passed
[1349365.072120] f0286d78: ttyS0 at I/O 0x0 (irq = 17, base_baud =
115200) is a SUN4V HCONS
[1349365.077468] f0298d00: ttyS1 at MMIO 0xfff0ca0000 (irq = 24,
base_baud = 115387) is a 16550A
[1349365.078086] Console: ttyS1 (SU)
[1349365.078366] console [ttyS0] enabled
[1349365.154673] mousedev: PS/2 mouse device common for all mice
[1349365.231740] rtc-sun4v rtc-sun4v: rtc core: registered sun4v as rtc0
[1349365.314995] ledtrig-cpu: registered to indicate activity on CPUs
[1349365.520577] NET: Registered protocol family 10
[1349365.644890] mip6: Mobile IPv6
[1349365.683819] NET: Registered protocol family 17
[1349365.741060] Key type ceph registered
[1349365.832688] libceph: loaded (mon/osd proto 15/24)
[1349365.896748] registered taskstats version 1
[1349366.012190] zswap: loaded using pool lzo/zbud
[1349366.073473] rtc-sun4v rtc-sun4v: setting system clock to
2016-08-16 11:26:58 UTC (1471346818)
[1349366.183512] This architecture does not have kernel memory protection.
[1349366.454934] random: systemd-udevd: uninitialized urandom read (16
bytes read)
[1349366.466435] random: udevadm: uninitialized urandom read (16 bytes read)
[1349366.467183] random: udevadm: uninitialized urandom read (16 bytes read)
[1349366.657533] random: udevadm: uninitialized urandom read (16 bytes read)
[1349366.657721] random: udevadm: uninitialized urandom read (16 bytes read)
[1349366.660497] random: udevadm: uninitialized urandom read (16 bytes read)
[1349366.663009] random: udevadm: uninitialized urandom read (16 bytes read)
[1349366.663204] random: udevadm: uninitialized urandom read (16 bytes read)
[1349366.666193] random: udevadm: uninitialized urandom read (16 bytes read)
[1349366.668659] random: udevadm: uninitialized urandom read (16 bytes read)
[1349368.090344] Fusion MPT base driver 3.04.20
[1349368.143531] Copyright (c) 1999-2008 LSI Corporation
[1349368.251376] SCSI subsystem initialized
[1349368.315355] Fusion MPT SAS Host driver 3.04.20
[1349368.374174] mptbase: ioc0: Initiating bringup
[1349369.438003] ioc0: LSISAS1068E B1: Capabilities={Initiator}
[1349385.828627] scsi host0: ioc0: LSISAS1068E B1, FwRev=011b0000h,
Ports=1, MaxQ=277, IRQ=22
[1349386.017108] mptsas: ioc0: attaching ssp device: fw_channel 0,
fw_id 0, phy 0, sas_addr 0x5000c5000a5c8715
[1349386.147852] scsi 0:0:0:0: Direct-Access     SEAGATE
ST914602SSUN146G 0603 PQ: 0 ANSI: 5
[1349386.289769] mptsas: ioc0: attaching ssp device: fw_channel 0,
fw_id 1, phy 1, sas_addr 0x5000c5000ee01681
[1349386.419114] scsi 0:0:1:0: Direct-Access     SEAGATE
ST914602SSUN146G 0603 PQ: 0 ANSI: 5
[1349386.657797] sd 0:0:0:0: [sda] 286739329 512-byte logical blocks:
(147 GB/137 GiB)
[1349386.752880] sd 0:0:1:0: [sdb] 286739329 512-byte logical blocks:
(147 GB/137 GiB)
[1349386.754473] sd 0:0:0:0: [sda] Write Protect is off
[1349386.754487] sd 0:0:0:0: [sda] Mode Sense: e3 00 10 08
[1349386.756359] sd 0:0:0:0: [sda] Write cache: disabled, read cache:
enabled, supports DPO and FUA
[1349386.779190]  sda: sda1 sda2 sda3
[1349386.795104] sd 0:0:0:0: [sda] Attached SCSI disk
[1349387.122697] sd 0:0:1:0: [sdb] Write Protect is off
[1349387.184055] sd 0:0:1:0: [sdb] Mode Sense: e3 00 10 08
[1349387.185907] sd 0:0:1:0: [sdb] Write cache: disabled, read cache:
enabled, supports DPO and FUA
[1349387.322000]  sdb: sdb1 sdb2 sdb3
[1349387.380095] sd 0:0:1:0: [sdb] Attached SCSI disk
[1349387.573529] random: fast init done
[1349387.785221] md: bind<sda2>
[1349387.844309] md: bind<sdb2>
[1349387.905840] md: raid1 personality registered for level 1
[1349387.976692] md/raid1:md0: active with 2 out of 2 mirrors
[1349388.045361] created bitmap (1 pages) for device md0
[1349388.109117] md0: bitmap initialized from disk: read 1 pages, set
0 of 2182 bits
[1349388.212816] md0: detected capacity change from 0 to 146415419392
[1349388.724925] device-mapper: uevent: version 1.0.3
[1349388.813687] device-mapper: ioctl: 4.35.0-ioctl (2016-06-23)
initialised: dm-devel@redhat.com
[1349389.680635] md: linear personality registered for level -1
[1349389.776472] md: multipath personality registered for level -4
[1349389.867519] md: raid0 personality registered for level 0
[1349389.970481] xor: automatically using best checksumming function:
[1349390.085422]    Niagara   :   302.000 MB/sec
[1349390.213546] raid6: int64x1  gen()   203 MB/s
[1349390.333565] raid6: int64x1  xor()   165 MB/s
[1349390.453686] raid6: int64x2  gen()   333 MB/s
[1349390.573710] raid6: int64x2  xor()   200 MB/s
[1349390.693703] raid6: int64x4  gen()   317 MB/s
[1349390.813807] raid6: int64x4  xor()   190 MB/s
[1349390.933884] raid6: int64x8  gen()   213 MB/s
[1349391.053908] raid6: int64x8  xor()   146 MB/s
[1349391.109175] raid6: using algorithm int64x2 gen() 333 MB/s
[1349391.178339] raid6: .... xor() 200 MB/s, rmw enabled
[1349391.241085] raid6: using intx1 recovery algorithm
[1349391.320654] md: raid6 personality registered for level 6
[1349391.388814] md: raid5 personality registered for level 5
[1349391.456561] md: raid4 personality registered for level 4
[1349391.573305] md: raid10 personality registered for level 10
[1349391.645342] random: crng init done
[1349392.842428] EXT4-fs (dm-0): mounted filesystem with ordered data
mode. Opts: (null)
[1349394.290573] systemd[1]: systemd 231 running in system mode. (+PAM
+AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP
+GCRYPT +GNUTLS +ACL +XZ -LZ4 -SECCOMP +BLKID +ELFUTILS +KMOD +IDN)
[1349394.515897] systemd[1]: Detected architecture sparc64.
[1349394.658419] systemd[1]: Set hostname to <nvg5120>.
[1349396.540809] systemd[1]: Listening on /dev/initctl Compatibility Named Pipe.
[1349396.712304] systemd[1]: Created slice User and Session Slice.
[1349396.861573] systemd[1]: Started Forward Password Requests to Wall
Directory Watch.
[1349397.047290] systemd[1]: Created slice System Slice.
[1349397.171477] systemd[1]: Created slice system-systemd\x2dfsck.slice.
[1349397.329859] systemd[1]: Started Dispatch Password Requests to
Console Directory Watch.
[1349397.525184] systemd[1]: Listening on udev Control Socket.
[1349398.300754] RPC: Registered named UNIX socket transport module.
[1349398.391039] RPC: Registered udp transport module.
[1349398.466968] RPC: Registered tcp transport module.
[1349398.527661] RPC: Registered tcp NFSv4.1 backchannel transport module.
[1349399.345405] systemd[1]: Listening on udev Kernel Socket.
[1349399.473462] systemd[1]: Listening on LVM2 metadata daemon socket.
[1349399.657917] systemd[1]: Starting Monitoring of LVM2 mirrors,
snapshots etc. using dmeventd or progress polling...
[1349399.881978] systemd[1]: Listening on Journal Socket (/dev/log).
[1349400.062043] systemd[1]: Starting Journal Service...
[1349400.169781] systemd[1]: Listening on fsck to fsckd communication Socket.
[1349400.378089] systemd[1]: Starting Remount Root and Kernel File Systems...
[1349400.454582] EXT4-fs (dm-0): re-mounted. Opts: errors=remount-ro
[1349400.658487] systemd[1]: Mounted RPC Pipe File System.
[1349400.782049] systemd[1]: Mounted POSIX Message Queue File System.
[1349400.929757] systemd[1]: Mounted Huge Pages File System.
[1349403.185443] systemd-journald[1287]: Received request to flush
runtime journal from PID 1
[1349403.892923] n2rng.c:v0.2 (July 27, 2011)
[1349403.959049] n2rng f0286a1c: Registered RNG HVAPI major 2 minor 0
[1349404.049432] n2rng f0286a1c: Found single-unit RNG, units: 1
[1349404.084343] sha1_sparc64: sparc64 sha1 opcode not available.
[1349404.180148] sha256_sparc64: sparc64 sha256 opcode not available.
[1349404.196346] sha512_sparc64: sparc64 sha512 opcode not available.
[1349404.209767] md5_sparc64: sparc64 md5 opcode not available.
[1349404.416424] n2_crypto: n2_crypto.c:v0.2 (July 28, 2011)
[1349404.418488] n2rng f0286a1c: Selftest passed on unit 0
[1349404.418504] n2rng f0286a1c: RNG ready
[1349404.503649] aes_sparc64: sparc64 aes opcodes not available.
[1349404.678954] pps_core: LinuxPPS API ver. 1 registered
[1349404.678959] pps_core: Software ver. 5.3.6 - Copyright 2005-2007
Rodolfo Giometti <giometti@linux.it>
[1349404.696111] sd 0:0:0:0: Attached scsi generic sg0 type 0
[1349404.697124] sd 0:0:1:0: Attached scsi generic sg1 type 0
[1349404.761319] des_sparc64: sparc64 des opcodes not available.
[1349404.792182] PTP clock support registered
[1349404.821769] camellia_sparc64: sparc64 camellia opcodes not available.
[1349405.240215] n2_crypto: Found N2CP at /virtual-devices@100/n2cp@7
[1349405.316654] n2_crypto: Registered NCS HVAPI version 2.0
[1349405.496170] n2_crypto: md5 alg registration failed
[1349405.557588] n2cp f028681c: /virtual-devices@100/n2cp@7: Unable to
register algorithms.
[1349405.659148] n2cp: probe of f028681c failed with error -22
[1349405.745746] n2_crypto: Found NCP at /virtual-devices@100/ncp@6
[1349405.833992] n2_crypto: Registered NCS HVAPI version 2.0
[1349405.916680] Kernel unaligned access at TPC[573034]
kmem_cache_alloc+0x74/0x160
[1349406.022577] Unable to handle kernel paging request in mna handler
[1349406.097893]  at virtual address 6b6aeb6f6a324b6b
[1349406.097897] current->{active_,}mm->context = 00000000000006c7
[1349406.097901] current->{active_,}mm->pgd = ffff80000cbb6000
[1349406.097905]               \|/ ____ \|/
                               "@'/ .. \`@"
                               /_| \__/ |_\
                                  \__U_/
[1349406.097910] systemd-udevd(1504): Oops [#1]
[1349406.097921] CPU: 59 PID: 1504 Comm: systemd-udevd Not tainted
4.8.0-rc2+ #73
[1349406.097928] task: ffff8003f1ac4940 task.stack: ffff8003f017c000
[1349406.097935] TSTATE: 0000004411e01605 TPC: 0000000000573034 TNPC:
0000000000573038 Y: 00000000    Not tainted
[1349406.097956] TPC: <kmem_cache_alloc+0x74/0x160>
[1349406.097962] g0: 0000000000b3f0e0 g1: 6b6b6b6b6b6b6b6b g2:
00000000102f3ed8 g3: 000000000000cee0
[1349406.097968] g4: ffff8003f1ac4940 g5: ffff8003fec6e000 g6:
ffff8003f017c000 g7: ffff8003ffa28000
[1349406.097974] o0: 0000000000000000 o1: 00000000102f3040 o2:
0000000000000000 o3: ffff8003f1bf8620
[1349406.097980] o4: ffff80000cd56b18 o5: 0000000000000011 sp:
ffff8003f017eb51 ret_pc: 000000000043a778
[1349406.097997] RPC: <mdesc_get_property+0xb8/0x100>
[1349406.098004] l0: ffff8003ffa28030 l1: 000000000000d5c0 l2:
0000000000000032 l3: 0000000000a52c00
[1349406.098010] l4: 0000000000000000 l5: 0000000000b1e800 l6:
0000000000b1e800 l7: 0000000000b1e802
[1349406.098016] i0: ffff8003f1d2a000 i1: 00000000024080c0 i2:
00000000102f3030 i3: 0000000000000000
[1349406.098022] i4: 00000000102f1d5c i5: 0000000000000000 i6:
ffff8003f017ec01 i7: 00000000102f1d5c
[1349406.098062] I7: <spu_mdesc_scan+0x45c/0x4a0 [n2_crypto]>
[1349406.098065] Call Trace:
[1349406.098083]  [00000000102f1d5c] spu_mdesc_scan+0x45c/0x4a0 [n2_crypto]
[1349406.098100]  [00000000102f2094] n2_mau_probe+0x134/0x1e0 [n2_crypto]
[1349406.098120]  [0000000000748f14] platform_drv_probe+0x14/0x60
[1349406.098130]  [000000000074712c] driver_probe_device+0x16c/0x3c0
[1349406.098138]  [0000000000747414] __driver_attach+0x94/0x120
[1349406.098147]  [0000000000744ebc] bus_for_each_dev+0x3c/0xa0
[1349406.098155]  [00000000007463f0] bus_add_driver+0xf0/0x280
[1349406.098164]  [0000000000747aa8] driver_register+0xa8/0x100
[1349406.098174]  [0000000000749168] __platform_register_drivers+0x68/0x160
[1349406.098183]  [0000000000426d00] do_one_initcall+0x80/0x160
[1349406.098202]  [000000000051c1b8] do_init_module+0x4c/0x1b4
[1349406.098210]  [00000000004d3394] load_module+0x1eb4/0x2640
[1349406.098218]  [00000000004d3d74] SyS_finit_module+0xb4/0x120
[1349406.098234]  [00000000004061f4] linux_sparc_syscall+0x34/0x44
[1349406.098237] Disabling lock debugging due to kernel taint
[1349406.098260] Caller[00000000102f1d5c]: spu_mdesc_scan+0x45c/0x4a0
[n2_crypto]
[1349406.098276] Caller[00000000102f2094]: n2_mau_probe+0x134/0x1e0 [n2_crypto]
[1349406.098289] Caller[0000000000748f14]: platform_drv_probe+0x14/0x60
[1349406.098298] Caller[000000000074712c]: driver_probe_device+0x16c/0x3c0
[1349406.098307] Caller[0000000000747414]: __driver_attach+0x94/0x120
[1349406.098315] Caller[0000000000744ebc]: bus_for_each_dev+0x3c/0xa0
[1349406.098323] Caller[00000000007463f0]: bus_add_driver+0xf0/0x280
[1349406.098332] Caller[0000000000747aa8]: driver_register+0xa8/0x100
[1349406.098342] Caller[0000000000749168]:
__platform_register_drivers+0x68/0x160
[1349406.098349] Caller[0000000000426d00]: do_one_initcall+0x80/0x160
[1349406.098361] Caller[000000000051c1b8]: do_init_module+0x4c/0x1b4
[1349406.098369] Caller[00000000004d3394]: load_module+0x1eb4/0x2640
[1349406.098376] Caller[00000000004d3d74]: SyS_finit_module+0xb4/0x120
[1349406.098387] Caller[00000000004061f4]: linux_sparc_syscall+0x34/0x44
[1349406.098392] Caller[ffff800100382290]: 0xffff800100382290
[1349406.098417] Instruction DUMP: 7ffad31e  90122348  91d02005
<c4004005> 80a0a000  0240000f  ba004005  8400bfff  86102001
[1349406.674976] sha512_sparc64: sparc64 sha512 opcode not available.
[1349407.234161] md5_sparc64: sparc64 md5 opcode not available.
[1349407.236556] camellia_sparc64: sparc64 camellia opcodes not available.
[1349407.413714] aes_sparc64: sparc64 aes opcodes not available.
[1349407.746087] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
[1349407.746091] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[1349407.746381] PCI: Enabling device: (0000:08:00.0), cmd 146
[1349407.747093] e1000e 0000:08:00.0: Interrupt Throttling Rate
(ints/sec) set to dynamic conservative mode
[1349407.934675] e1000e 0000:08:00.0 eth0: (PCI Express:2.5GT/s:Width
x4) 00:14:4f:ac:4a:18
[1349407.934684] e1000e 0000:08:00.0 eth0: Intel(R) PRO/1000 Network Connection
[1349407.934772] e1000e 0000:08:00.0 eth0: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[1349407.934976] PCI: Enabling device: (0000:08:00.1), cmd 146
[1349407.935568] e1000e 0000:08:00.1: Interrupt Throttling Rate
(ints/sec) set to dynamic conservative mode
[1349408.122536] e1000e 0000:08:00.1 eth1: (PCI Express:2.5GT/s:Width
x4) 00:14:4f:ac:4a:19
[1349408.122546] e1000e 0000:08:00.1 eth1: Intel(R) PRO/1000 Network Connection
[1349408.122633] e1000e 0000:08:00.1 eth1: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[1349408.122815] PCI: Enabling device: (0000:09:00.0), cmd 146
[1349408.123438] e1000e 0000:09:00.0: Interrupt Throttling Rate
(ints/sec) set to dynamic conservative mode
[1349408.185050] md5_sparc64: sparc64 md5 opcode not available.
[1349408.310561] e1000e 0000:09:00.0 eth2: (PCI Express:2.5GT/s:Width
x4) 00:14:4f:ac:4a:1a
[1349408.310570] e1000e 0000:09:00.0 eth2: Intel(R) PRO/1000 Network Connection
[1349408.310657] e1000e 0000:09:00.0 eth2: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[1349408.310860] PCI: Enabling device: (0000:09:00.1), cmd 146
[1349408.311471] e1000e 0000:09:00.1: Interrupt Throttling Rate
(ints/sec) set to dynamic conservative mode
[1349408.465352] aes_sparc64: sparc64 aes opcodes not available.
[1349408.465510] des_sparc64: sparc64 des opcodes not available.
[1349408.473303] camellia_sparc64: sparc64 camellia opcodes not available.
[1349408.498854] e1000e 0000:09:00.1 eth3: (PCI Express:2.5GT/s:Width
x4) 00:14:4f:ac:4a:1b
[1349408.498864] e1000e 0000:09:00.1 eth3: Intel(R) PRO/1000 Network Connection
[1349408.498951] e1000e 0000:09:00.1 eth3: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[1349408.625977] e1000e 0000:09:00.0 enp9s0f0: renamed from eth2
[1349408.757298] e1000e 0000:09:00.1 enp9s0f1: renamed from eth3
[1349408.905379] e1000e 0000:08:00.1 enp8s0f1: renamed from eth1
[1349409.053406] e1000e 0000:08:00.0 enp8s0f0: renamed from eth0
[1349409.310581] des_sparc64: sparc64 des opcodes not available.
[1349409.310585] camellia_sparc64: sparc64 camellia opcodes not available.
[1349409.930432] camellia_sparc64: sparc64 camellia opcodes not available.
[1349414.027064] Adding 5836792k swap on /dev/mapper/vg1-swap_1.
Priority:-1 extents:1 across:5836792k FS
[1349415.046052] EXT4-fs (sdb1): mounting ext2 file system using the
ext4 subsystem
[1349415.176515] EXT4-fs (sdb1): mounted filesystem without journal.
Opts: (null)
[1349416.260484] IPv6: ADDRCONF(NETDEV_UP): enp8s0f0: link is not ready
[1349417.512258] e1000e: enp8s0f0 NIC Link is Up 100 Mbps Full Duplex,
Flow Control: None
[1349417.622843] e1000e 0000:08:00.0 enp8s0f0: 10/100 speed: disabling TSO
[1349417.719823] IPv6: ADDRCONF(NETDEV_CHANGE): enp8s0f0: link becomes ready

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
