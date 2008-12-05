Message-ID: <49389B69.9010902@cn.fujitsu.com>
Date: Fri, 05 Dec 2008 11:09:29 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [memcg BUG ?] failed to boot on IA64 with CONFIG_DISCONTIGMEM=y
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Kernel version: 2.6.28-rc7
Arch: IA64
Memory model: DISCONTIGMEM

ELILO boot: Uncompressing Linux... done
Loading file initrd-2.6.28-rc7-lizf.img...done
(frozen)


Booted successfully with cgroup_disable=memory, here is the dmesg:

...
Number of logical nodes in system = 16
Number of memory chunks in system = 18
SMP: Allowing 128 CPUs, 120 hotplug CPUs
Initial ramdisk at: 0xe00000006afbc000 (4644000 bytes)
SAL 3.20: FUJITSU LIMITED PRIMEQUEST version 3.4
SAL Platform features: None
SAL: AP wakeup using external interrupt vector 0xf0
ACPI: Local APIC address c0000000fee00000
PLATFORM int CPEI (0x3): GSI 22 (level, low) -> CPU 0 (0x0000) vector 30
8 CPUs available, 128 CPUs total
MCA related initialization done
Virtual mem_map starts at 0xa07fffffc0c80000
Zone PFN ranges:
  DMA      0x00000100 -> 0x00010000
  Normal   0x00010000 -> 0x01210000
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000100 -> 0x00006d00
    0: 0x00408000 -> 0x00410000
    1: 0x01200400 -> 0x01210000
On node 0 totalpages: 60416
free_area_init_node: node 0, pgdat e0000000011c0000, node_mem_map a07fffffc0c83800
  DMA zone: 56 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 27592 pages, LIFO batch:1
  Normal zone: 3584 pages used for memmap
  Normal zone: 29184 pages, LIFO batch:1
  Movable zone: 0 pages used for memmap
On node 1 totalpages: 64512
free_area_init_node: node 1, pgdat e0000120040d0080, node_mem_map a07fffffffc8e000
  DMA zone: 0 pages used for memmap
  Normal zone: 56 pages used for memmap
  Normal zone: 64456 pages, LIFO batch:1
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 2
On node 2 totalpages: 0
free_area_init_node: node 2, pgdat e000004080180100, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 3
On node 3 totalpages: 0
free_area_init_node: node 3, pgdat e0000040802d0180, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 4
On node 4 totalpages: 0
free_area_init_node: node 4, pgdat e0000040804a0200, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 5
On node 5 totalpages: 0
free_area_init_node: node 5, pgdat e0000040805f0280, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 6
On node 6 totalpages: 0
free_area_init_node: node 6, pgdat e0000040807c0300, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 7
On node 7 totalpages: 0
free_area_init_node: node 7, pgdat e000004080910380, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 8
On node 8 totalpages: 0
free_area_init_node: node 8, pgdat e000004080ad0400, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 9
On node 9 totalpages: 0
free_area_init_node: node 9, pgdat e000004080c10480, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 10
On node 10 totalpages: 0
free_area_init_node: node 10, pgdat e000004080dd0500, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 11
On node 11 totalpages: 0
free_area_init_node: node 11, pgdat e000004080f10580, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 12
On node 12 totalpages: 0
free_area_init_node: node 12, pgdat e0000040810d0600, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 13
On node 13 totalpages: 0
free_area_init_node: node 13, pgdat e000004081210680, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 14
On node 14 totalpages: 0
free_area_init_node: node 14, pgdat e0000040813d0700, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Could not find start_pfn for node 15
On node 15 totalpages: 0
free_area_init_node: node 15, pgdat e000004081510780, node_mem_map a07fffffc0c80000
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Built 16 zonelists in Zone order, mobility grouping on.  Total pages: 121232
Policy zone: Normal
Kernel command line: BOOT_IMAGE=scsi0:EFI\redhat\vmlinuz-2.6.28-rc7-lizf  console=ttyS0 rhgb cgroup_disable=memory root=/dev/sda2 ro
Disabling memory control group subsystem
PID hash table entries: 4096 (order: 12, 32768 bytes)
CPU 0: base freq=266.666MHz, ITC ratio=6/4, ITC freq=399.999MHz
Console: colour VGA+ 80x25
Placing software IO TLB between 0x53d0000 - 0x93d0000
Memory: 7870144k/7970368k available (6617k code, 125248k reserved, 5996k data, 1728k init)
SLUB: Genslabs=17, HWalign=128, Order=0-3, MinObjects=0, CPUs=128, Nodes=1024
Calibrating delay loop... 3186.68 BogoMIPS (lpj=1593344)
Security Framework initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
Dentry cache hash table entries: 1048576 (order: 7, 8388608 bytes)
Inode-cache hash table entries: 524288 (order: 6, 4194304 bytes)
Mount-cache hash table entries: 4096
Initializing cgroup subsys debug
Initializing cgroup subsys ns
Initializing cgroup subsys cpuacct
Initializing cgroup subsys memory
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
ACPI: Core revision 20080926
Boot processor id 0x0/0x0
Fixed BSP b0 value from CPU 1
CPU 1: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 139 cycles)
CPU 1: base freq=266.666MHz, ITC ratio=6/4, ITC freq=399.999MHz
CPU 2: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 139 cycles)
CPU 2: base freq=266.666MHz, ITC ratio=6/4, ITC freq=399.999MHz
CPU 3: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 139 cycles)
CPU 3: base freq=266.666MHz, ITC ratio=6/4, ITC freq=399.999MHz
CPU 4: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 512 cycles)
CPU 4: base freq=266.666MHz, ITC ratio=6/4, ITC freq=399.999MHz
CPU 5: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 513 cycles)
CPU 5: base freq=266.666MHz, ITC ratio=6/4, ITC freq=399.999MHz
CPU 6: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 512 cycles)
CPU 6: base freq=266.666MHz, ITC ratio=6/4, ITC freq=399.999MHz
CPU 7: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 512 cycles)
CPU 7: base freq=266.666MHz, ITC ratio=6/4, ITC freq=399.999MHz
Brought up 8 CPUs
Total of 8 processors activated (25493.50 BogoMIPS).
...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
