Date: Wed, 23 Jan 2008 13:14:59 +0100
From: Olaf Hering <olaf@aepfle.de>
Subject: Re: crash in kmem_cache_init
Message-ID: <20080123121459.GA18631@aepfle.de>
References: <20080117211511.GA25320@aepfle.de> <Pine.LNX.4.64.0801181043290.30348@schroedinger.engr.sgi.com> <20080118213011.GC10491@csn.ul.ie> <Pine.LNX.4.64.0801181414200.8924@schroedinger.engr.sgi.com> <20080118225713.GA31128@aepfle.de> <20080122195448.GA15567@csn.ul.ie> <20080122214505.GA15674@aepfle.de> <Pine.LNX.4.64.0801221417480.1912@schroedinger.engr.sgi.com> <20080123075821.GA17713@aepfle.de> <20080123105044.GD21455@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20080123105044.GD21455@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, hanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lee.schermerhorn@hp.com, Linux MM <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, Mel Gorman wrote:

> Sorry this is dragging out. Can you post the full dmesg with loglevel=8 of the
> following patch against 2.6.24-rc8 please? It contains the debug information
> that helped me figure out what was going wrong on the PPC64 machine here,
> the revert and the !l3 checks (i.e. the two patches that made machines I
> have access to work). Thanks

It boots with your change.


boot: x
Please wait, loading kernel...
Allocated 00a00000 bytes for kernel @ 00200000
   Elf64 kernel loaded...
OF stdout device is: /vdevice/vty@30000000
Hypertas detected, assuming LPAR !
command line: debug xmon=on panic=1 loglevel=8 
memory layout at init:
  alloc_bottom : 0000000000ac1000
  alloc_top    : 0000000010000000
  alloc_top_hi : 00000000da000000
  rmo_top      : 0000000010000000
  ram_top      : 00000000da000000
Looking for displays
found display   : /pci@800000020000002/pci@2/pci@1/display@0, opening ... done
instantiating rtas at 0x000000000f6a1000 ... done
0000000000000000 : boot cpu     0000000000000000
0000000000000002 : starting cpu hw idx 0000000000000002... done
0000000000000004 : starting cpu hw idx 0000000000000004... done
0000000000000006 : starting cpu hw idx 0000000000000006... done
copying OF device tree ...
Building dt strings...
Building dt structure...
Device tree strings 0x0000000000cc2000 -> 0x0000000000cc34e4
Device tree struct  0x0000000000cc4000 -> 0x0000000000cd6000
Calling quiesce ...
returning from prom_init
Partition configured for 8 cpus.
Starting Linux PPC64 #52 SMP Wed Jan 23 13:05:38 CET 2008
-----------------------------------------------------
ppc64_pft_size                = 0x1c
physicalMemorySize            = 0xda000000
htab_hash_mask                = 0x1fffff
-----------------------------------------------------
Linux version 2.6.24-rc8-ppc64 (olaf@lingonberry) (gcc version 4.1.2 20070115 (prerelease) (SUSE Linux)) #52 SMP Wed Jan 23 13:05:38 CET 2008
[boot]0012 Setup Arch
EEH: PCI Enhanced I/O Error Handling Enabled
PPC64 nvram contains 8192 bytes
Zone PFN ranges:
  DMA             0 ->   892928
  Normal     892928 ->   892928
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    1:        0 ->   892928
Could not find start_pfn for node 0
[boot]0015 Setup Done
Built 2 zonelists in Node order, mobility grouping on.  Total pages: 880720
Policy zone: DMA
Kernel command line: debug xmon=on panic=1 loglevel=8 
[boot]0020 XICS Init
xics: no ISA interrupt controller
[boot]0021 XICS Done
PID hash table entries: 4096 (order: 12, 32768 bytes)
time_init: decrementer frequency = 275.070000 MHz
time_init: processor frequency   = 2197.800000 MHz
clocksource: timebase mult[e8ab05] shift[22] registered
clockevent: decrementer mult[466a] shift[16] cpu[0]
Console: colour dummy device 80x25
console handover: boot [udbg-1] -> real [hvc0]
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
freeing bootmem node 1
Memory: 3496632k/3571712k available (6188k kernel code, 75080k reserved, 1324k data, 1220k bss, 304k init)
Online nodes
o 0
o 1
Nodes with regular memory
o 1
Current running CPU 0 is associated with node 0
Current node is 0
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 0
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 1
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 2
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 3
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 4
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 5
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 6
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 7
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 8
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 9
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 10
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 11
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 12
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 13
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 14
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 15
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 16
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 17
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 18
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 19
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 20
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 21
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 22
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 23
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 24
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 25
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 26
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 27
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 28
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 29
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 30
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 31
 o kmem_list3_init
kmem_cache_init Setting kmem_cache NULL 32
kmem_cache_init Setting kmem_cache NULL 0
kmem_cache_init Setting kmem_cache initkmem_list3 0
set_up_list3s size-32 index 1
set_up_list3s size-32 index 1
set_up_list3s size-32 index 1
set_up_list3s size-128 index 17
set_up_list3s size-128 index 17
set_up_list3s size-128 index 17
setup_cpu_cache size-32(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-64
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-64(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-128(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-256
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-256(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-512
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-512(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-1024
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-1024(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-2048
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-2048(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-4096
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-4096(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-8192
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-8192(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-16384
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-16384(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-32768
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-32768(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-65536
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-65536(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-131072
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-131072(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-262144
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-262144(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-524288
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-524288(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-1048576
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-1048576(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-2097152
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-2097152(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-4194304
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-4194304(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-8388608
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-8388608(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-16777216
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
setup_cpu_cache size-16777216(DMA)
 o allocated node 0
 o kmem_list3_init
 o allocated node 1
 o kmem_list3_init
init_list RESETTING kmem_cache node 0
init_list RESETTING size-32 node 0
init_list RESETTING size-128 node 0
init_list RESETTING size-32 node 1
init_list RESETTING size-128 node 1
alloc_kmemlist size-16777216(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-16777216
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-8388608(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-8388608
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-4194304(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-4194304
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-2097152(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-2097152
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-1048576(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-1048576
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-524288(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-524288
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-262144(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-262144
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-131072(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-131072
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-65536(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-65536
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-32768(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-32768
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-16384(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-16384
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-8192(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-8192
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-4096(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-4096
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-2048(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-2048
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-1024(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-1024
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-512(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-512
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-256(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-256
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-128(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-64(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-64
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-32(DMA)
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-128
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist size-32
 o node 0
 o l3 exists
 o node 1
 o l3 exists
alloc_kmemlist kmem_cache
 o node 0
 o l3 exists
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D802FA00
alloc_kmemlist numa_policy
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D802FC00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D802FD80
alloc_kmemlist shared_policy_node
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D802FF00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D803E180
Calibrating delay loop... 548.86 BogoMIPS (lpj=2744320)
alloc_kmemlist pid_1
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D803E300
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D803E480
alloc_kmemlist pid_namespace
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D803E600
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D803E780
alloc_kmemlist pgd_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D803E900
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D803EA80
alloc_kmemlist pud_pmd_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D803EC00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D803ED80
alloc_kmemlist anon_vma
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D803EF00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D804C180
alloc_kmemlist task_struct
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D804C300
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D804C480
alloc_kmemlist sighand_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D804C600
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D804C780
alloc_kmemlist signal_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D804C900
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D804CA80
alloc_kmemlist files_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D804CC00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D804CD80
alloc_kmemlist fs_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D804CF00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8057180
alloc_kmemlist vm_area_struct
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8057300
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8057480
alloc_kmemlist mm_struct
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8057600
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8057780
alloc_kmemlist buffer_head
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8057900
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8057A80
alloc_kmemlist idr_layer_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8057C80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8057E00
alloc_kmemlist key_jar
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8057F80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8066200
Security Framework initialized
Capability LSM initialized
Failure registering Root Plug module with the kernel
Failure registering Root Plug  module with primary security module.
alloc_kmemlist names_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8066380
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8066500
alloc_kmemlist filp
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8066680
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8066800
alloc_kmemlist dentry
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8066980
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8066B00
alloc_kmemlist inode_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8066C80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8066E00
alloc_kmemlist mnt_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8066F80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8074200
Mount-cache hash table entries: 256
alloc_kmemlist sysfs_dir_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8074380
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8074500
alloc_kmemlist bdev_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8074700
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8074880
alloc_kmemlist radix_tree_node
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8074A00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8074B80
alloc_kmemlist sigqueue
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8074D00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8074E80
alloc_kmemlist proc_inode_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D808E100
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D808E280
alloc_kmemlist taskstats
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D808E400
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D808E580
alloc_kmemlist task_delay_info
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D808E700
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D808E880
cpuup_prepare 1
clockevent: decrementer mult[466a] shift[16] cpu[1]
Processor 1 found.
cpuup_prepare 2
clockevent: decrementer mult[466a] shift[16] cpu[2]
Processor 2 found.
cpuup_prepare 3
clockevent: decrementer mult[466a] shift[16] cpu[3]
Processor 3 found.
cpuup_prepare 4
clockevent: decrementer mult[466a] shift[16] cpu[4]
Processor 4 found.
cpuup_prepare 5
clockevent: decrementer mult[466a] shift[16] cpu[5]
Processor 5 found.
cpuup_prepare 6
clockevent: decrementer mult[466a] shift[16] cpu[6]
Processor 6 found.
cpuup_prepare 7
clockevent: decrementer mult[466a] shift[16] cpu[7]
Processor 7 found.
Brought up 8 CPUs
Node 0 CPUs: 0-3
Node 1 CPUs: 4-7
net_namespace: 120 bytes
alloc_kmemlist file_lock_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D82C6680
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D82C6800
alloc_kmemlist skbuff_head_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D82C6980
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D82C6B00
alloc_kmemlist skbuff_fclone_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D82C6D00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D82C6E80
alloc_kmemlist sock_inode_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8372180
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8372300
NET: Registered protocol family 16
IBM eBus Device Driver
PCI: Probing PCI hardware
IOMMU table initialized, virtual merging enabled
PCI: Probing PCI hardware done
Registering pmac pic with sysfs...
alloc_kmemlist bio
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D83E9580
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D83E9700
alloc_kmemlist biovec-1
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D83E9880
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D83E9A00
alloc_kmemlist biovec-4
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D83E9B80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D83E9D00
alloc_kmemlist biovec-16
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D83E9E80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D83F4100
alloc_kmemlist biovec-64
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D83F4300
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D83F4480
alloc_kmemlist biovec-128
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D83F4600
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D83F4780
alloc_kmemlist biovec-256
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D83F4900
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D83F4A80
alloc_kmemlist blkdev_requests
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8401580
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8401700
alloc_kmemlist blkdev_queue
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8401880
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8401A00
alloc_kmemlist blkdev_ioc
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8401B80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8401D00
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
alloc_kmemlist eventpoll_epi
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8439A80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8439C00
alloc_kmemlist eventpoll_pwq
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8439D80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8439F00
alloc_kmemlist TCP
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8486380
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8486500
alloc_kmemlist request_sock_TCP
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8486680
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8486800
alloc_kmemlist tw_sock_TCP
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8486980
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8486B00
alloc_kmemlist UDP
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8486D00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D8486E80
alloc_kmemlist RAW
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D849D180
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D849D300
NET: Registered protocol family 2
Time: timebase clocksource has been installed.
Switched to high resolution mode on CPU 0
Switched to high resolution mode on CPU 1
Switched to high resolution mode on CPU 2
Switched to high resolution mode on CPU 3
Switched to high resolution mode on CPU 4
Switched to high resolution mode on CPU 5
Switched to high resolution mode on CPU 6
Switched to high resolution mode on CPU 7
alloc_kmemlist arp_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D849D480
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D849D600
alloc_kmemlist ip_dst_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D849DC80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D849DE00
IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
alloc_kmemlist xfrm_dst_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D84A8300
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D84A8480
alloc_kmemlist secpath_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D84A8600
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D84A8780
alloc_kmemlist inet_peer_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D84A8900
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D84A8A80
alloc_kmemlist tcp_bind_bucket
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D84A8C00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D84A8D80
TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
alloc_kmemlist UDP-Lite
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D84A8F80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D84C6200
alloc_kmemlist ip_mrt_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D84C6380
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D84C6500
alloc_kmemlist rtas_flash_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D8294880
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D84E5F80
alloc_kmemlist hugepte_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D84EA800
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D84EA680
alloc_kmemlist uid_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D84EA400
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D84EA280
alloc_kmemlist posix_timers_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D84EA100
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D84EAF00
alloc_kmemlist nsproxy
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D85BB180
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D85BB300
audit: initializing netlink socket (disabled)
audit(1201090162.460:1): initialized
RTAS daemon started
RTAS: event: 88, Type: Platform Error, Severity: 2
Total HugeTLB memory allocated, 0
alloc_kmemlist shmem_inode_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D85BB680
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D85BB800
alloc_kmemlist fasync_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D85BBA00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D85BBB80
alloc_kmemlist kiocb
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D85BBD00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D85BBE80
alloc_kmemlist kioctx
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D85EF180
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D85EF300
alloc_kmemlist inotify_watch_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D85EF880
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D85EFA00
alloc_kmemlist inotify_event_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D85EFB80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D85EFD00
VFS: Disk quotas dquot_6.5.1
alloc_kmemlist dquot
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D85EFE80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D85FD100
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
alloc_kmemlist dnotify_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D85FD280
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D85FD400
alloc_kmemlist reiser_inode_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D85FD600
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D85FD780
alloc_kmemlist ext3_xattr
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D85FD980
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D85FDB00
alloc_kmemlist ext3_inode_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D85FDD00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D85FDE80
alloc_kmemlist revoke_record
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6036100
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6036280
alloc_kmemlist revoke_table
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6036400
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6036580
alloc_kmemlist journal_head
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6036700
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6036880
alloc_kmemlist journal_handle
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6036A00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6036B80
alloc_kmemlist ext2_xattr
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6036D80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6036F00
alloc_kmemlist ext2_inode_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6046200
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6046380
alloc_kmemlist hugetlbfs_inode_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6046580
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6046700
alloc_kmemlist fat_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6046900
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6046A80
alloc_kmemlist fat_inode_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6046C80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6046E00
alloc_kmemlist isofs_inode_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6052100
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6052280
alloc_kmemlist mqueue_inode_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6052500
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6052680
alloc_kmemlist bsg_cmd
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6052880
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6052A00
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
alloc_kmemlist cfq_queue
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6052C00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6052D80
alloc_kmemlist cfq_io_context
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D6052F00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D6070180
io scheduler cfq registered (default)
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
rpaphp: RPA HOT Plug PCI Controller Driver version: 0.1
rpaphp: Slot [0001:00:02.0](PCI location=U7879.001.DQD04M6-P1-C3) registered
rpaphp: Slot [0001:00:02.2](PCI location=U7879.001.DQD04M6-P1-C4) registered
rpaphp: Slot [0001:00:02.4](PCI location=U7879.001.DQD04M6-P1-C5) registered
rpaphp: Slot [0001:00:02.6](PCI location=U7879.001.DQD04M6-P1-C6) registered
rpaphp: Slot [0002:00:02.0](PCI location=U7879.001.DQD04M6-P1-C1) registered
rpaphp: Slot [0002:00:02.6](PCI location=U7879.001.DQD04M6-P1-C2) registered
matroxfb: Matrox G450 detected
PInS data found at offset 31168
PInS memtype = 5
matroxfb: 640x480x8bpp (virtual: 640x26214)
matroxfb: framebuffer at 0x40178000000, mapped to 0xd000080080080000, size 33554432
Console: switching to colour frame buffer device 80x30
fb0: MATROX frame buffer device
matroxfb_crtc2: secondary head of fb0 was registered as fb1
vio_register_driver: driver hvc_console registering
HVSI: registered 0 devices
Generic RTC Driver v1.07
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
pmac_zilog: 0.6 (Benjamin Herrenschmidt <benh@kernel.crashing.org>)
input: Macintosh mouse button emulation as /devices/virtual/input/input0
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ehci_hcd 0000:c8:01.2: EHCI Host Controller
ehci_hcd 0000:c8:01.2: new USB bus registered, assigned bus number 1
ehci_hcd 0000:c8:01.2: irq 85, io mem 0x400a0002000
ehci_hcd 0000:c8:01.2: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 5 ports detected
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd 0000:c8:01.0: OHCI Host Controller
ohci_hcd 0000:c8:01.0: new USB bus registered, assigned bus number 2
ohci_hcd 0000:c8:01.0: irq 85, io mem 0x400a0001000
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 3 ports detected
ohci_hcd 0000:c8:01.1: OHCI Host Controller
ohci_hcd 0000:c8:01.1: new USB bus registered, assigned bus number 3
ohci_hcd 0000:c8:01.1: irq 85, io mem 0x400a0000000
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
mice: PS/2 mouse device common for all mice
EDAC MC: Ver: 2.1.0 Jan 23 2008
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
/home/olaf/kernel/git/linux-2.6.24-rc8/drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
oprofile: using ppc64/power5+ performance monitoring.
alloc_kmemlist flow_cache
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D612FA80
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D612FC00
alloc_kmemlist UNIX
 o node 0
 o allocing l3
 o kmem_list3_init
 o setting node 0 0xC0000000D612FE00
 o node 1
 o allocing l3
 o kmem_list3_init
 o setting node 1 0xC0000000D612FF80
NET: Registered protocol family 1
NET: Registered protocol family 17
NET: Registered protocol family 15
registered taskstats version 1
md: Autodetecting RAID arrays.
md: Scanned 0 and added 0 devices.
md: autorun ...
md: ... autorun DONE.
VFS: Cannot open root device "<NULL>" or unknown-block(0,0)
Please append a correct "root=" boot option; here are the available partitions:
Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
Rebooting in 1 seconds..    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
