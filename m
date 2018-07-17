Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3186F6B0006
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 06:49:49 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v205-v6so551746oie.20
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 03:49:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d5-v6si435489oib.333.2018.07.17.03.49.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 03:49:48 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6HAnhWq018281
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 06:49:47 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k9avfj6ae-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 06:49:44 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <abdhalee@linux.vnet.ibm.com>;
	Tue, 17 Jul 2018 06:49:01 -0400
Subject: Re: [next-20180711][Oops] linux-next kernel boot is broken on
 powerpc
From: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
Date: Tue, 17 Jul 2018 16:18:52 +0530
In-Reply-To: <20180714105500.3694b93f@canb.auug.org.au>
References: <1531416305.6480.24.camel@abdul.in.ibm.com>
	 <CAGM2rebtisZda0kqhg0u92fTDxC+=zMNNgKFBLH38osphk0fdA@mail.gmail.com>
	 <1531473191.6480.26.camel@abdul.in.ibm.com>
	 <20180714105500.3694b93f@canb.auug.org.au>
Content-Type: multipart/mixed; boundary="=-gZT1PxkJfh1DZnpqjXDy"
Mime-Version: 1.0
Message-Id: <1531824532.15016.30.camel@abdul.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, sachinp@linux.vnet.ibm.com, Michal Hocko <mhocko@suse.com>, sim@linux.vnet.ibm.com, venkatb3@in.ibm.com, LKML <linux-kernel@vger.kernel.org>, manvanth@linux.vnet.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, linux-next@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org


--=-gZT1PxkJfh1DZnpqjXDy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Sat, 2018-07-14 at 10:55 +1000, Stephen Rothwell wrote:
> Hi Abdul,
> 
> On Fri, 13 Jul 2018 14:43:11 +0530 Abdul Haleem <abdhalee@linux.vnet.ibm.com> wrote:
> >
> > On Thu, 2018-07-12 at 13:44 -0400, Pavel Tatashin wrote:
> > > > Related commit could be one of below ? I see lots of patches related to mm and could not bisect
> > > >
> > > > 5479976fda7d3ab23ba0a4eb4d60b296eb88b866 mm: page_alloc: restore memblock_next_valid_pfn() on arm/arm64
> > > > 41619b27b5696e7e5ef76d9c692dd7342c1ad7eb mm-drop-vm_bug_on-from-__get_free_pages-fix
> > > > 531bbe6bd2721f4b66cdb0f5cf5ac14612fa1419 mm: drop VM_BUG_ON from __get_free_pages
> > > > 479350dd1a35f8bfb2534697e5ca68ee8a6e8dea mm, page_alloc: actually ignore mempolicies for high priority allocations
> > > > 088018f6fe571444caaeb16e84c9f24f22dfc8b0 mm: skip invalid pages block at a time in zero_resv_unresv()  
> > > 
> > > Looks like:
> > > 0ba29a108979 mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> > > 
> > > This patch is going to be reverted from linux-next. Abdul, please
> > > verify that issue is gone once  you revert this patch.  
> > 
> > kernel booted fine when the above patch is reverted.
> 
> And it has been removed from linux-next as of next-20180713.  (Friday
> the 13th is not all bad :-))

Hi Stephen,

After reverting 0ba29a108979, our bare-metal machines boot fails with
kernel panic, is this related ?

I have attached the boot logs.

-- 
Regard's

Abdul Haleem
IBM Linux Technology Centre



--=-gZT1PxkJfh1DZnpqjXDy
Content-Disposition: attachment; filename="bootlogs.txxt"
Content-Type: text/plain; name="bootlogs.txxt"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

 4456.423887] kexec: waiting for cpu 1 (physical 9) to enter OPAL
[ 4456.425185] kexec: waiting for cpu 4 (physical 12) to enter OPAL
[ 4456.426402] kexec: waiting for cpu 9 (physical 17) to enter OPAL
[ 4456.428606] kexec: waiting for cpu 10 (physical 18) to enter OPAL
[ 4512.471375957,5] OPAL: Switch to big-endian OS
[ 4458.021223] kexec: Starting switchover sequence.
[ 4517.298269913,5] OPAL: Switch to little-endian OS
[    0.000000] hash-mmu: Page sizes from device-tree:
[    0.000000] hash-mmu: base_shift=12: shift=12, sllp=0x0000, avpnm=0x00000000, tlbiel=1, penc=0
[    0.000000] hash-mmu: base_shift=12: shift=16, sllp=0x0000, avpnm=0x00000000, tlbiel=1, penc=7
[    0.000000] hash-mmu: base_shift=12: shift=24, sllp=0x0000, avpnm=0x00000000, tlbiel=1, penc=56
[    0.000000] hash-mmu: base_shift=16: shift=16, sllp=0x0110, avpnm=0x00000000, tlbiel=1, penc=1
[    0.000000] hash-mmu: base_shift=16: shift=24, sllp=0x0110, avpnm=0x00000000, tlbiel=1, penc=8
[    0.000000] hash-mmu: base_shift=20: shift=20, sllp=0x0130, avpnm=0x00000000, tlbiel=0, penc=2
[    0.000000] hash-mmu: base_shift=24: shift=24, sllp=0x0100, avpnm=0x00000001, tlbiel=0, penc=0
[    0.000000] hash-mmu: base_shift=34: shift=34, sllp=0x0120, avpnm=0x000007ff, tlbiel=0, penc=3
[    0.000000] Using 1TB segments
[    0.000000] hash-mmu: Initializing hash mmu with SLB
[    0.000000] Linux version 4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3 (root@ltc-garri5.pok.stglabs.ibm.com) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-28) (GCC)) #2 SMP Tue Jul 17 06:30:00 EDT 2018
[    0.000000] Found initrd at 0xc000000002970000:0xc000000003f0b50c
[    0.000000] OPAL: Found non-mapped LPC bus on chip 0
[    0.000000] Using PowerNV machine description
[    0.000000] bootconsole [udbg0] enabled
[    0.000000] CPU maps initialized for 8 threads per core
[    0.000000] -----------------------------------------------------
[    0.000000] ppc64_pft_size    = 0x0
[    0.000000] phys_mem_size     = 0x4000000000
[    0.000000] dcache_bsize      = 0x80
[    0.000000] icache_bsize      = 0x80
[    0.000000] cpu_features      = 0x000000ff8f5db1a7
[    0.000000]   possible        = 0x0000ffffcf5fb1a7
[    0.000000]   always          = 0x00000003800081a1
[    0.000000] cpu_user_features = 0xdc0065c2 0xef000000
[    0.000000] mmu_features      = 0x7c006001
[    0.000000] firmware_features = 0x0000000110000000
[    0.000000] htab_address      = 0x(____ptrval____)
[    0.000000] htab_hash_mask    = 0x1fffff
[    0.000000] -----------------------------------------------------
[    0.000000] cma: Reserved 13120 MiB at 0x0000003cac000000
[    0.000000] numa:   NODE_DATA [mem 0x1fff972300-0x1fff97bfff]
[    0.000000] numa:   NODE_DATA [mem 0x3fff0c8300-0x3fff0d1fff]
[    0.000000] rfi-flush: ori type flush available
[    0.000000] barrier-nospec: using ORI speculation barrier
[    0.000000] stf-barrier: hwsync barrier available
[    0.000000] Initializing IODA2 PHB (/pciex@3fffe40000000)
[    0.000000] PCI host bridge /pciex@3fffe40000000 (primary) ranges:
[    0.000000]  MEM 0x00003fe000000000..0x00003fe07ffeffff -> 0x0000000080000000 
[    0.000000]  MEM 0x0000200000000000..0x000020ffffffffff -> 0x0000200000000000 (M64 #0..15)
[    0.000000]  Using M64 #15 as default window
[    0.000000]   256 (255) PE's M32: 0x80000000 [segment=0x800000]
[    0.000000]                  M64: 0x10000000000 [segment=0x100000000]
[    0.000000]   Allocated bitmap for 2040 MSIs (base IRQ 0x800)
[    0.000000] Initializing IODA2 PHB (/pciex@3fffe40100000)
[    0.000000] PCI host bridge /pciex@3fffe40100000  ranges:
[    0.000000]  MEM 0x00003fe080000000..0x00003fe0fffeffff -> 0x0000000080000000 
[    0.000000]  MEM 0x0000210000000000..0x000021ffffffffff -> 0x0000210000000000 (M64 #0..15)
[    0.000000]  Using M64 #15 as default window
[    0.000000]   256 (255) PE's M32: 0x80000000 [segment=0x800000]
[    0.000000]                  M64: 0x10000000000 [segment=0x100000000]
[    0.000000]   Allocated bitmap for 2040 MSIs (base IRQ 0x1000)
[    0.000000] Initializing IODA2 PHB (/pciex@3fffe40200000)
[    0.000000] PCI host bridge /pciex@3fffe40200000  ranges:
[    0.000000]  MEM 0x00003fe100000000..0x00003fe17ffeffff -> 0x0000000080000000 
[    0.000000]  MEM 0x0000220000000000..0x000022ffffffffff -> 0x0000220000000000 (M64 #0..15)
[    0.000000]  Using M64 #15 as default window
[    0.000000]   256 (255) PE's M32: 0x80000000 [segment=0x800000]
[    0.000000]                  M64: 0x10000000000 [segment=0x100000000]
[    0.000000]   Allocated bitmap for 2040 MSIs (base IRQ 0x1800)
[    0.000000] Initializing IODA2 PHB (/pciex@3fffe40300000)
[    0.000000] PCI host bridge /pciex@3fffe40300000  ranges:
[    0.000000]  MEM 0x00003fe180000000..0x00003fe1fffeffff -> 0x0000000080000000 
[    0.000000]  MEM 0x0000230000000000..0x000023ffffffffff -> 0x0000230000000000 (M64 #0..15)
[    0.000000]  Using M64 #15 as default window
[    0.000000]   256 (255) PE's M32: 0x80000000 [segment=0x800000]
[    0.000000]                  M64: 0x10000000000 [segment=0x100000000]
[    0.000000]   Allocated bitmap for 2040 MSIs (base IRQ 0x2000)
[    0.000000] Initializing IODA2 PHB (/pciex@3fffe40400000)
[    0.000000] PCI host bridge /pciex@3fffe40400000  ranges:
[    0.000000]  MEM 0x00003fe200000000..0x00003fe27ffeffff -> 0x0000000080000000 
[    0.000000]  MEM 0x0000240000000000..0x000024ffffffffff -> 0x0000240000000000 (M64 #0..15)
[    0.000000]  Using M64 #15 as default window
[    0.000000]   256 (255) PE's M32: 0x80000000 [segment=0x800000]
[    0.000000]                  M64: 0x10000000000 [segment=0x100000000]
[    0.000000]   Allocated bitmap for 2040 MSIs (base IRQ 0x4800)
[    0.000000] Initializing IODA2 PHB (/pciex@3fffe40500000)
[    0.000000] PCI host bridge /pciex@3fffe40500000  ranges:
[    0.000000]  MEM 0x00003fe280000000..0x00003fe2fffeffff -> 0x0000000080000000 
[    0.000000]  MEM 0x0000250000000000..0x000025ffffffffff -> 0x0000250000000000 (M64 #0..15)
[    0.000000]  Using M64 #15 as default window
[    0.000000]   256 (255) PE's M32: 0x80000000 [segment=0x800000]
[    0.000000]                  M64: 0x10000000000 [segment=0x100000000]
[    0.000000]   Allocated bitmap for 2040 MSIs (base IRQ 0x5000)
[    0.000000] Initializing IODA2 PHB (/pciex@3fffe40600000)
[    0.000000] PCI host bridge /pciex@3fffe40600000  ranges:
[    0.000000]  MEM 0x00003fe300000000..0x00003fe37ffeffff -> 0x0000000080000000 
[    0.000000]  MEM 0x0000260000000000..0x000026ffffffffff -> 0x0000260000000000 (M64 #0..15)
[    0.000000]  Using M64 #15 as default window
[    0.000000]   256 (255) PE's M32: 0x80000000 [segment=0x800000]
[    0.000000]                  M64: 0x10000000000 [segment=0x100000000]
[    0.000000]   Allocated bitmap for 2040 MSIs (base IRQ 0x5800)
[    0.000000] Initializing IODA2 PHB (/pciex@3fffe40700000)
[    0.000000] PCI host bridge /pciex@3fffe40700000  ranges:
[    0.000000]  MEM 0x00003fe380000000..0x00003fe3fffeffff -> 0x0000000080000000 
[    0.000000]  MEM 0x0000270000000000..0x000027ffffffffff -> 0x0000270000000000 (M64 #0..15)
[    0.000000]  Using M64 #15 as default window
[    0.000000]   256 (255) PE's M32: 0x80000000 [segment=0x800000]
[    0.000000]                  M64: 0x10000000000 [segment=0x100000000]
[    0.000000]   Allocated bitmap for 2040 MSIs (base IRQ 0x6000)
[    0.000000] Initializing NPU_NVLINK PHB (/pciex@3fff000400000)
[    0.000000] PCI host bridge /pciex@3fff000400000  ranges:
[    0.000000]  MEM 0x0003fff000410000..0x0003fff00049ffff -> 0x0003fff000410000 
[    0.000000]   Not support M64 window
[    0.000000]   004 (000) PE's M32: 0xa0000 [segment=0x28000]
[    0.000000] Initializing NPU_NVLINK PHB (/pciex@3fff001400000)
[    0.000000] PCI host bridge /pciex@3fff001400000  ranges:
[    0.000000]  MEM 0x0003fff001410000..0x0003fff00149ffff -> 0x0003fff001410000 
[    0.000000]   Not support M64 window
[    0.000000]   004 (000) PE's M32: 0xa0000 [segment=0x28000]
[    0.000000] OPAL nvram setup, 589824 bytes
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000000000-0x0000003fffffffff]
[    0.000000]   DMA32    empty
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000000000-0x0000001fffffffff]
[    0.000000]   node   1: [mem 0x0000002000000000-0x0000003fffffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x0000001fffffffff]
[    0.000000] Initmem setup node 1 [mem 0x0000002000000000-0x0000003fffffffff]
[    0.000000] percpu: Embedded 4 pages/cpu @(____ptrval____) s167064 r0 d95080 u262144
[    0.000000] Built 2 zonelists, mobility grouping on.  Total pages: 4190208
[    0.000000] Policy zone: DMA
[    0.000000] Kernel command line: rw root=/dev/mapper/ca_ltc--garri5-root 
[    0.000000] log_buf_len individual max cpu contribution: 8192 bytes
[    0.000000] log_buf_len total cpu_extra contributions: 1302528 bytes
[    0.000000] log_buf_len min size: 262144 bytes
[    0.000000] log_buf_len: 2097152 bytes
[    0.000000] early log buf free: 250928(95%)
[    0.000000] Memory: 254168064K/268435456K available (10240K kernel code, 1600K rwdata, 2688K rodata, 2560K init, 1392K bss, 832512K reserved, 13434880K cma-reserved)
[    0.000000] SLUB: HWalign=128, Order=0-3, MinObjects=0, CPUs=160, Nodes=2
[    0.000000] rcu: Hierarchical RCU implementation.
[    0.000000] rcu: 	RCU restricting CPUs from NR_CPUS=2048 to nr_cpu_ids=160.
[    0.000000] 	Tasks RCU enabled.
[    0.000000] rcu: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=160
[    0.000000] NR_IRQS: 512, nr_irqs: 512, preallocated irqs: 16
[    0.000000] ICS OPAL backend registered
[    0.000004] clocksource: timebase: mask: 0xffffffffffffffff max_cycles: 0x761537d007, max_idle_ns: 440795202126 ns
[    0.001234] clocksource: timebase mult[1f40000] shift[24] registered
[    0.002679] Console: colour dummy device 80x25
[    0.003208] console [hvc0] enabled
[    0.003208] console [hvc0] enabled
[    0.003773] bootconsole [udbg0] disabled
[    0.003773] bootconsole [udbg0] disabled
[    0.004695] mempolicy: Enabling automatic NUMA balancing. Configure with numa_balancing= or the kernel.numa_balancing sysctl
[    0.004926] pid_max: default: 163840 minimum: 1280
[    0.016544] Dentry cache hash table entries: 16777216 (order: 11, 134217728 bytes)
[    0.021667] Inode-cache hash table entries: 8388608 (order: 10, 67108864 bytes)
[    0.022303] Mount-cache hash table entries: 262144 (order: 5, 2097152 bytes)
[    0.022653] Mountpoint-cache hash table entries: 262144 (order: 5, 2097152 bytes)
[    0.025476] EEH: PowerNV platform initialized
[    0.025689] POWER8 performance monitor hardware support registered
[    0.025862] rcu: Hierarchical SRCU implementation.
[    0.030139] smp: Bringing up secondary CPUs ...
[    1.257894] smp: Brought up 2 nodes, 160 CPUs
[    1.258174] numa: Node 0 CPUs: 0-79
[    1.258390] numa: Node 1 CPUs: 80-159
[    1.258449] Using standard scheduler topology
[    1.299592] devtmpfs: initialized
[    1.373319] random: get_random_u32 called from bucket_table_alloc+0xa0/0x220 with crng_init=0
[    1.375214] kworker/u321:0 (816) used greatest stack depth: 12400 bytes left
[    1.375650] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
[    1.375926] futex hash table entries: 65536 (order: 7, 8388608 bytes)
[    1.400617] NET: Registered protocol family 16
[    1.402517] audit: initializing netlink subsys (disabled)
[    1.403114] audit: type=2000 audit(1.400:1): state=initialized audit_enabled=0 res=1
[    1.404545] cpuidle: using governor menu
[    1.404924] pstore: Registered nvram as persistent store backend
[    1.426265] kworker/u321:3 (887) used greatest stack depth: 11696 bytes left
[    1.504118] random: fast init done
[    1.586019] PCI: Probing PCI hardware
[    1.586303] PCI host bridge to bus 0000:00
[    1.586498] pci_bus 0000:00: root bus resource [mem 0x3fe000000000-0x3fe07ffeffff] (bus address [0x80000000-0xfffeffff])
[    1.586729] pci_bus 0000:00: root bus resource [mem 0x200000000000-0x20fdffffffff 64bit pref]
[    1.586839] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.608289] pci 0000:00:00.0: PCI bridge to [bus 01-ff]
[    1.608770] PCI host bridge to bus 0001:00
[    1.608890] pci_bus 0001:00: root bus resource [mem 0x3fe080000000-0x3fe0fffeffff] (bus address [0x80000000-0xfffeffff])
[    1.609014] pci_bus 0001:00: root bus resource [mem 0x210000000000-0x21fdffffffff 64bit pref]
[    1.609122] pci_bus 0001:00: root bus resource [bus 00-ff]
[    1.621060] pci 0001:01:00.0: BAR0 [mem size 0x00001000 64bit]: requesting alignment to 0x10000
[    1.621376] pci 0001:01:00.0: BAR2 [mem size 0x00004000 64bit]: requesting alignment to 0x10000
[    1.622584] pci 0001:01:00.1: BAR0 [mem size 0x00001000 64bit]: requesting alignment to 0x10000
[    1.622891] pci 0001:01:00.1: BAR2 [mem size 0x00004000 64bit]: requesting alignment to 0x10000
[    1.633753] pci 0001:00:00.0: PCI bridge to [bus 01]
[    1.634340] PCI host bridge to bus 0002:00
[    1.634531] pci_bus 0002:00: root bus resource [mem 0x3fe100000000-0x3fe17ffeffff] (bus address [0x80000000-0xfffeffff])
[    1.634726] pci_bus 0002:00: root bus resource [mem 0x220000000000-0x22fdffffffff 64bit pref]
[    1.635049] pci_bus 0002:00: root bus resource [bus 00-ff]
[    1.656895] pci 0002:00:00.0: PCI bridge to [bus 01]
[    1.657371] PCI host bridge to bus 0003:00
[    1.657563] pci_bus 0003:00: root bus resource [mem 0x3fe180000000-0x3fe1fffeffff] (bus address [0x80000000-0xfffeffff])
[    1.657782] pci_bus 0003:00: root bus resource [mem 0x230000000000-0x23fdffffffff 64bit pref]
[    1.658064] pci_bus 0003:00: root bus resource [bus 00-ff]
[    1.679163] pci 0003:00:00.0: PCI bridge to [bus 01-ff]
[    1.679543] PCI host bridge to bus 0008:00
[    1.679736] pci_bus 0008:00: root bus resource [mem 0x3fe200000000-0x3fe27ffeffff] (bus address [0x80000000-0xfffeffff])
[    1.680097] pci_bus 0008:00: root bus resource [mem 0x240000000000-0x24fdffffffff 64bit pref]
[    1.680380] pci_bus 0008:00: root bus resource [bus 00-ff]
[    1.704915] pci 0008:00:00.0: PCI bridge to [bus 01]
[    1.705577] PCI host bridge to bus 0009:00
[    1.705771] pci_bus 0009:00: root bus resource [mem 0x3fe280000000-0x3fe2fffeffff] (bus address [0x80000000-0xfffeffff])
[    1.706159] pci_bus 0009:00: root bus resource [mem 0x250000000000-0x25fdffffffff 64bit pref]
[    1.706268] pci_bus 0009:00: root bus resource [bus 00-ff]
[    1.728260] pci 0009:00:00.0: PCI bridge to [bus 01-07]
[    1.741926] pci 0009:01:00.0: PCI bridge to [bus 02-07]
[    1.743049] pci 0009:03:00.0: BAR2 [mem size 0x00002000 64bit]: requesting alignment to 0x10000
[    1.753773] pci 0009:02:01.0: PCI bridge to [bus 03]
[    1.754691] pci 0009:04:00.0: BAR5 [mem size 0x00000800]: requesting alignment to 0x10000
[    1.765355] pci 0009:02:02.0: PCI bridge to [bus 04]
[    1.776530] pci 0009:02:03.0: PCI bridge to [bus 05-06]
[    1.776998] pci_bus 0009:06: extended config space not accessible
[    1.787983] pci 0009:05:00.0: PCI bridge to [bus 06]
[    1.800430] pci 0009:02:04.0: PCI bridge to [bus 07]
[    1.800974] PCI host bridge to bus 000a:00
[    1.801164] pci_bus 000a:00: root bus resource [mem 0x3fe300000000-0x3fe37ffeffff] (bus address [0x80000000-0xfffeffff])
[    1.801551] pci_bus 000a:00: root bus resource [mem 0x260000000000-0x26fdffffffff 64bit pref]
[    1.801659] pci_bus 000a:00: root bus resource [bus 00-ff]
[    1.823554] pci 000a:00:00.0: PCI bridge to [bus 01]
[    1.824044] PCI host bridge to bus 000b:00
[    1.824235] pci_bus 000b:00: root bus resource [mem 0x3fe380000000-0x3fe3fffeffff] (bus address [0x80000000-0xfffeffff])
[    1.824449] pci_bus 000b:00: root bus resource [mem 0x270000000000-0x27fdffffffff 64bit pref]
[    1.824558] pci_bus 000b:00: root bus resource [bus 00-ff]
[    1.845990] pci 000b:00:00.0: PCI bridge to [bus 01-ff]
[    1.846402] PCI host bridge to bus 0004:00
[    1.846588] pci_bus 0004:00: root bus resource [mem 0x3fff000410000-0x3fff00049ffff]
[    1.846751] pci_bus 0004:00: root bus resource [bus 00-ff]
[    1.858858] PCI host bridge to bus 0005:00
[    1.859055] pci_bus 0005:00: root bus resource [mem 0x3fff001410000-0x3fff00149ffff]
[    1.859239] pci_bus 0005:00: root bus resource [bus 00-ff]
[    1.871356] pci 0000:00     : [PE# fe] Secondary bus 0 associated with PE#fe
[    1.872212] pci 0000:00:00.0: PCI bridge to [bus 01-ff]
[    1.872555] pci 0001:00:00.0: BAR 8: assigned [mem 0x3fe080000000-0x3fe0807fffff]
[    1.872871] pci 0001:01:00.0: BAR 6: assigned [mem 0x3fe080000000-0x3fe08003ffff pref]
[    1.873141] pci 0001:01:00.1: BAR 6: assigned [mem 0x3fe080040000-0x3fe08007ffff pref]
[    1.873412] pci 0001:01:00.0: BAR 0: assigned [mem 0x3fe080080000-0x3fe080080fff 64bit]
[    1.873714] pci 0001:01:00.0: BAR 2: assigned [mem 0x3fe080090000-0x3fe080093fff 64bit]
[    1.874012] pci 0001:01:00.1: BAR 0: assigned [mem 0x3fe0800a0000-0x3fe0800a0fff 64bit]
[    1.874517] pci 0001:01:00.1: BAR 2: assigned [mem 0x3fe0800b0000-0x3fe0800b3fff 64bit]
[    1.874814] pci 0001:01:00.0: BAR 4: no space for [io  size 0x0100]
[    1.875069] pci 0001:01:00.0: BAR 4: failed to assign [io  size 0x0100]
[    1.875149] pci 0001:01:00.1: BAR 4: no space for [io  size 0x0100]
[    1.875421] pci 0001:01:00.1: BAR 4: failed to assign [io  size 0x0100]
[    1.875715] pci 0001:00     : [PE# fe] Secondary bus 0 associated with PE#fe
[    1.876603] pci 0001:01     : [PE# fd] Secondary bus 1 associated with PE#fd
[    1.877476] pci 0001:01     : [PE# fd] Setting up 32-bit TCE table at 0..80000000
[    1.897581] IOMMU table initialized, virtual merging enabled
[    1.897836] pci 0001:01     : [PE# fd] Setting up window#0 0..7fffffff pg=1000
[    1.897959] pci 0001:01     : [PE# fd] Enabling 64-bit DMA bypass
[    1.898047] iommu: Adding device 0001:01:00.0 to group 0
[    1.898118] iommu: Adding device 0001:01:00.1 to group 0
[    1.898184] pci 0001:00:00.0: PCI bridge to [bus 01]
[    1.898264] pci 0001:00:00.0:   bridge window [mem 0x3fe080000000-0x3fe0ffefffff]
[    1.898380] pci_bus 0001:00: Some PCI device resources are unassigned, try booting with pci=realloc
[    1.898742] pci 0002:00:00.0: BAR 9: assigned [mem 0x220000000000-0x2205ffffffff 64bit pref]
[    1.898853] pci 0002:00:00.0: BAR 8: assigned [mem 0x3fe100000000-0x3fe100ffffff]
[    1.899125] pci 0002:01:00.0: BAR 1: assigned [mem 0x220000000000-0x2203ffffffff 64bit pref]
[    1.899470] pci 0002:01:00.0: BAR 3: assigned [mem 0x220400000000-0x220401ffffff 64bit pref]
[    1.899782] pci 0002:01:00.0: BAR 0: assigned [mem 0x3fe100000000-0x3fe100ffffff]
[    1.900060] pci 0002:00     : [PE# fe] Secondary bus 0 associated with PE#fe
[    1.901195] pci 0002:01     : [PE# 00] Secondary bus 1 associated with PE#0
[    1.902340] pci 0002:01     : [PE# 00] Setting up 32-bit TCE table at 0..80000000
[    1.923325] pci 0002:01     : [PE# 00] Setting up window#0 0..7fffffff pg=1000
[    1.923622] pci 0002:01     : [PE# 00] Enabling 64-bit DMA bypass
[    1.923927] iommu: Adding device 0002:01:00.0 to group 1
[    1.923993] pci 0002:00:00.0: PCI bridge to [bus 01]
[    1.924072] pci 0002:00:00.0:   bridge window [mem 0x3fe100000000-0x3fe17fefffff]
[    1.924349] pci 0002:00:00.0:   bridge window [mem 0x220000000000-0x22fdfff0ffff 64bit pref]
[    1.924906] pci 0003:00     : [PE# fe] Secondary bus 0 associated with PE#fe
[    1.925872] pci 0003:00:00.0: PCI bridge to [bus 01-ff]
[    1.926204] pci 0008:00:00.0: BAR 9: assigned [mem 0x240000000000-0x2400ffffffff 64bit pref]
[    1.926316] pci 0008:00:00.0: BAR 8: assigned [mem 0x3fe200000000-0x3fe2007fffff]
[    1.926422] pci 0008:01:00.0: BAR 0: assigned [mem 0x240000000000-0x2400007fffff 64bit pref]
[    1.926734] pci 0008:01:00.0: BAR 2: assigned [mem 0x240000800000-0x240000ffffff 64bit pref]
[    1.926874] pci 0008:01:00.1: BAR 0: assigned [mem 0x240001000000-0x2400017fffff 64bit pref]
[    1.927015] pci 0008:01:00.1: BAR 2: assigned [mem 0x240001800000-0x240001ffffff 64bit pref]
[    1.927210] pci 0008:01:00.2: BAR 0: assigned [mem 0x240002000000-0x2400027fffff 64bit pref]
[    1.927495] pci 0008:01:00.2: BAR 2: assigned [mem 0x240002800000-0x240002ffffff 64bit pref]
[    1.927635] pci 0008:01:00.3: BAR 0: assigned [mem 0x240003000000-0x2400037fffff 64bit pref]
[    1.927776] pci 0008:01:00.3: BAR 2: assigned [mem 0x240003800000-0x240003ffffff 64bit pref]
[    1.927916] pci 0008:01:00.0: BAR 6: assigned [mem 0x3fe200000000-0x3fe20003ffff pref]
[    1.928013] pci 0008:01:00.1: BAR 6: assigned [mem 0x3fe200040000-0x3fe20007ffff pref]
[    1.928108] pci 0008:01:00.2: BAR 6: assigned [mem 0x3fe200080000-0x3fe2000bffff pref]
[    1.928204] pci 0008:01:00.3: BAR 6: assigned [mem 0x3fe2000c0000-0x3fe2000fffff pref]
[    1.928299] pci 0008:01:00.0: BAR 4: assigned [mem 0x240004000000-0x24000400ffff 64bit pref]
[    1.928614] pci 0008:01:00.1: BAR 4: assigned [mem 0x240004010000-0x24000401ffff 64bit pref]
[    1.928755] pci 0008:01:00.2: BAR 4: assigned [mem 0x240004020000-0x24000402ffff 64bit pref]
[    1.928895] pci 0008:01:00.3: BAR 4: assigned [mem 0x240004030000-0x24000403ffff 64bit pref]
[    1.929038] pci 0008:00     : [PE# fe] Secondary bus 0 associated with PE#fe
[    1.929952] pci 0008:01     : [PE# 00] Secondary bus 1 associated with PE#0
[    1.930794] pci 0008:01     : [PE# 00] Setting up 32-bit TCE table at 0..80000000
[    1.953514] pci 0008:01     : [PE# 00] Setting up window#0 0..7fffffff pg=1000
[    1.953695] pci 0008:01     : [PE# 00] Enabling 64-bit DMA bypass
[    1.953784] iommu: Adding device 0008:01:00.0 to group 2
[    1.953854] iommu: Adding device 0008:01:00.1 to group 2
[    1.953924] iommu: Adding device 0008:01:00.2 to group 2
[    1.953994] iommu: Adding device 0008:01:00.3 to group 2
[    1.954060] pci 0008:00:00.0: PCI bridge to [bus 01]
[    1.954138] pci 0008:00:00.0:   bridge window [mem 0x3fe200000000-0x3fe27fefffff]
[    1.954240] pci 0008:00:00.0:   bridge window [mem 0x240000000000-0x24fdfff0ffff 64bit pref]
[    1.954617] pci 0009:00:00.0: BAR 9: assigned [mem 0x250000000000-0x2500ffffffff 64bit pref]
[    1.954729] pci 0009:00:00.0: BAR 8: assigned [mem 0x3fe280000000-0x3fe282ffffff]
[    1.954828] pci 0009:01:00.0: BAR 9: assigned [mem 0x250000000000-0x2500ffffffff 64bit pref]
[    1.954939] pci 0009:01:00.0: BAR 8: assigned [mem 0x3fe280000000-0x3fe2827fffff]
[    1.955036] pci 0009:01:00.0: BAR 0: assigned [mem 0x3fe282800000-0x3fe28283ffff]
[    1.955138] pci 0009:01:00.0: BAR 7: no space for [io  size 0x2000]
[    1.955219] pci 0009:01:00.0: BAR 7: failed to assign [io  size 0x2000]
[    1.955305] pci 0009:02:04.0: BAR 9: assigned [mem 0x250000000000-0x2500ffffffff 64bit pref]
[    1.955416] pci 0009:02:01.0: BAR 8: assigned [mem 0x3fe280000000-0x3fe2807fffff]
[    1.955513] pci 0009:02:02.0: BAR 8: assigned [mem 0x3fe280800000-0x3fe280ffffff]
[    1.955607] pci 0009:02:03.0: BAR 8: assigned [mem 0x3fe281000000-0x3fe2827fffff]
[    1.955701] pci 0009:02:02.0: BAR 7: no space for [io  size 0x1000]
[    1.955782] pci 0009:02:02.0: BAR 7: failed to assign [io  size 0x1000]
[    1.955863] pci 0009:02:03.0: BAR 7: no space for [io  size 0x1000]
[    1.955942] pci 0009:02:03.0: BAR 7: failed to assign [io  size 0x1000]
[    1.956027] pci 0009:03:00.0: BAR 0: assigned [mem 0x3fe280000000-0x3fe28000ffff 64bit]
[    1.956156] pci 0009:03:00.0: BAR 2: assigned [mem 0x3fe280010000-0x3fe280011fff 64bit]
[    1.956283] pci 0009:00     : [PE# fe] Secondary bus 0 associated with PE#fe
[    1.956950] pci 0009:03     : [PE# fd] Secondary bus 3 associated with PE#fd
[    1.957836] pci 0009:03     : [PE# fd] Setting up 32-bit TCE table at 0..80000000
[    1.979686] pci 0009:03     : [PE# fd] Setting up window#0 0..7fffffff pg=1000
[    1.979784] pci 0009:03     : [PE# fd] Enabling 64-bit DMA bypass
[    1.979872] iommu: Adding device 0009:03:00.0 to group 3
[    1.979939] pci 0009:02:01.0: PCI bridge to [bus 03]
[    1.980019] pci 0009:02:01.0:   bridge window [mem 0x3fe280000000-0x3fe2807fffff]
[    1.980142] pci 0009:04:00.0: BAR 5: assigned [mem 0x3fe280800000-0x3fe2808007ff]
[    1.980248] pci 0009:04:00.0: BAR 6: assigned [mem 0x3fe280810000-0x3fe28081ffff pref]
[    1.980343] pci 0009:04:00.0: BAR 4: no space for [io  size 0x0020]
[    1.980423] pci 0009:04:00.0: BAR 4: failed to assign [io  size 0x0020]
[    1.980504] pci 0009:04:00.0: BAR 0: no space for [io  size 0x0008]
[    1.980585] pci 0009:04:00.0: BAR 0: failed to assign [io  size 0x0008]
[    1.980664] pci 0009:04:00.0: BAR 2: no space for [io  size 0x0008]
[    1.980747] pci 0009:04:00.0: BAR 2: failed to assign [io  size 0x0008]
[    1.980827] pci 0009:04:00.0: BAR 1: no space for [io  size 0x0004]
[    1.980907] pci 0009:04:00.0: BAR 1: failed to assign [io  size 0x0004]
[    1.980988] pci 0009:04:00.0: BAR 3: no space for [io  size 0x0004]
[    1.981068] pci 0009:04:00.0: BAR 3: failed to assign [io  size 0x0004]
[    1.981154] pci 0009:04     : [PE# fc] Secondary bus 4 associated with PE#fc
[    1.981833] pci 0009:04     : [PE# fc] Setting up 32-bit TCE table at 0..80000000
[    2.002372] pci 0009:04     : [PE# fc] Setting up window#0 0..7fffffff pg=1000
[    2.002468] pci 0009:04     : [PE# fc] Enabling 64-bit DMA bypass
[    2.002555] iommu: Adding device 0009:04:00.0 to group 4
[    2.002622] pci 0009:02:02.0: PCI bridge to [bus 04]
[    2.002702] pci 0009:02:02.0:   bridge window [mem 0x3fe280800000-0x3fe280ffffff]
[    2.002824] pci 0009:05:00.0: BAR 8: assigned [mem 0x3fe281000000-0x3fe2827fffff]
[    2.002918] pci 0009:05:00.0: BAR 7: no space for [io  size 0x1000]
[    2.028705] pci 0009:05:00.0: BAR 7: failed to assign [io  size 0x1000]
[    2.029278] pci 0009:06:00.0: BAR 0: assigned [mem 0x3fe281000000-0x3fe281ffffff]
[    2.029906] pci 0009:06:00.0: BAR 1: assigned [mem 0x3fe282000000-0x3fe28201ffff]
[    2.030446] pci 0009:06:00.0: BAR 2: no space for [io  size 0x0080]
[    2.031462] pci 0009:06:00.0: BAR 2: failed to assign [io  size 0x0080]
[    2.032023] pci 0009:06     : [PE# fb] Secondary bus 6..6 associated with PE#fb
[    2.033379] pci 0009:06     : [PE# fb] Setting up 32-bit TCE table at 0..80000000
[    2.057821] pci 0009:06     : [PE# fb] Setting up window#0 0..7fffffff pg=1000
[    2.057917] pci 0009:06     : [PE# fb] Enabling 64-bit DMA bypass
[    2.058214] iommu: Adding device 0009:06:00.0 to group 5
[    2.058281] pci 0009:05:00.0: PCI bridge to [bus 06]
[    2.058534] pci 0009:05:00.0:   bridge window [mem 0x3fe281000000-0x3fe2827fffff]
[    2.058847] pci 0009:05     : [PE# fa] Secondary bus 5 associated with PE#fa
[    2.059916] pci 0009:02:03.0: PCI bridge to [bus 05-06]
[    2.059996] pci 0009:02:03.0:   bridge window [mem 0x3fe281000000-0x3fe2827fffff]
[    2.060295] pci 0009:07:00.0: BAR 0: assigned [mem 0x250000000000-0x25000000ffff 64bit pref]
[    2.060617] pci 0009:07:00.0: BAR 2: assigned [mem 0x250000010000-0x25000001ffff 64bit pref]
[    2.060941] pci 0009:07:00.0: BAR 4: assigned [mem 0x250000020000-0x25000002ffff 64bit pref]
[    2.061264] pci 0009:07:00.1: BAR 0: assigned [mem 0x250000030000-0x25000003ffff 64bit pref]
[    2.061413] pci 0009:07:00.1: BAR 2: assigned [mem 0x250000040000-0x25000004ffff 64bit pref]
[    2.061736] pci 0009:07:00.1: BAR 4: assigned [mem 0x250000050000-0x25000005ffff 64bit pref]
[    2.062266] pci 0009:07     : [PE# 00] Secondary bus 7 associated with PE#0
[    2.063192] pci 0009:07     : [PE# 00] Setting up 32-bit TCE table at 0..80000000
[    2.086330] pci 0009:07     : [PE# 00] Setting up window#0 0..7fffffff pg=1000
[    2.086426] pci 0009:07     : [PE# 00] Enabling 64-bit DMA bypass
[    2.086511] iommu: Adding device 0009:07:00.0 to group 6
[    2.086582] iommu: Adding device 0009:07:00.1 to group 6
[    2.086647] pci 0009:02:04.0: PCI bridge to [bus 07]
[    2.086914] pci 0009:02:04.0:   bridge window [mem 0x250000000000-0x2500ffffffff 64bit pref]
[    2.087044] pci 0009:02     : [PE# f9] Secondary bus 2 associated with PE#f9
[    2.087708] pci 0009:01:00.0: PCI bridge to [bus 02-07]
[    2.087788] pci 0009:01:00.0:   bridge window [mem 0x3fe280000000-0x3fe2ffefffff]
[    2.087894] pci 0009:01:00.0:   bridge window [mem 0x250000000000-0x25fdfff0ffff 64bit pref]
[    2.088023] pci 0009:01     : [PE# f8] Secondary bus 1 associated with PE#f8
[    2.088688] pci 0009:00:00.0: PCI bridge to [bus 01-07]
[    2.088767] pci 0009:00:00.0:   bridge window [mem 0x3fe280000000-0x3fe2ffefffff]
[    2.088880] pci 0009:00:00.0:   bridge window [mem 0x250000000000-0x25fdfff0ffff 64bit pref]
[    2.089003] pci_bus 0009:00: Some PCI device resources are unassigned, try booting with pci=realloc
[    2.089247] pci 000a:00:00.0: BAR 9: assigned [mem 0x260000000000-0x2605ffffffff 64bit pref]
[    2.089358] pci 000a:00:00.0: BAR 8: assigned [mem 0x3fe300000000-0x3fe300ffffff]
[    2.089456] pci 000a:01:00.0: BAR 1: assigned [mem 0x260000000000-0x2603ffffffff 64bit pref]
[    2.089595] pci 000a:01:00.0: BAR 3: assigned [mem 0x260400000000-0x260401ffffff 64bit pref]
[    2.089733] pci 000a:01:00.0: BAR 0: assigned [mem 0x3fe300000000-0x3fe300ffffff]
[    2.089839] pci 000a:00     : [PE# fe] Secondary bus 0 associated with PE#fe
[    2.090517] pci 000a:01     : [PE# 00] Secondary bus 1 associated with PE#0
[    2.091210] pci 000a:01     : [PE# 00] Setting up 32-bit TCE table at 0..80000000
[    2.112169] pci 000a:01     : [PE# 00] Setting up window#0 0..7fffffff pg=1000
[    2.112265] pci 000a:01     : [PE# 00] Enabling 64-bit DMA bypass
[    2.112351] iommu: Adding device 000a:01:00.0 to group 7
[    2.112416] pci 000a:00:00.0: PCI bridge to [bus 01]
[    2.112495] pci 000a:00:00.0:   bridge window [mem 0x3fe300000000-0x3fe37fefffff]
[    2.112599] pci 000a:00:00.0:   bridge window [mem 0x260000000000-0x26fdfff0ffff 64bit pref]
[    2.112793] pci 000b:00     : [PE# fe] Secondary bus 0 associated with PE#fe
[    2.113455] pci 000b:00:00.0: PCI bridge to [bus 01-ff]
[    2.113579] pci 0004:00:00.0: BAR 0: assigned [mem 0x3fff000420000-0x3fff00043ffff 64bit]
[    2.113697] pci 0004:00:00.1: BAR 0: assigned [mem 0x3fff000440000-0x3fff00045ffff 64bit]
[    2.113816] pci 0004:00:01.0: BAR 0: assigned [mem 0x3fff000460000-0x3fff00047ffff 64bit]
[    2.135399] pci 0004:00:01.1: BAR 0: assigned [mem 0x3fff000480000-0x3fff00049ffff 64bit]
[    2.143350] pci 0005:00:00.0: BAR 0: assigned [mem 0x3fff001420000-0x3fff00143ffff 64bit]
[    2.145197] pci 0005:00:00.1: BAR 0: assigned [mem 0x3fff001440000-0x3fff00145ffff 64bit]
[    2.151003] pci 0005:00:01.0: BAR 0: assigned [mem 0x3fff001460000-0x3fff00147ffff 64bit]
[    2.156612] pci 0005:00:01.1: BAR 0: assigned [mem 0x3fff001480000-0x3fff00149ffff 64bit]
[    2.166402] pci 0004:00:00.0: [PE# 03] Associated device to PE
[    2.189134] pci 0004:00:00.1: Associating to existing PE 3
[    2.189714] pci 0004:00:01.0: [PE# 02] Associated device to PE
[    2.190918] pci 0004:00:01.1: Associating to existing PE 2
[    2.196634] pci 0005:00:00.0: [PE# 03] Associated device to PE
[    2.226346] pci 0005:00:00.1: Associating to existing PE 3
[    2.226444] pci 0005:00:01.0: [PE# 02] Associated device to PE
[    2.232433] pci 0005:00:01.1: Associating to existing PE 2
[    2.240697] pci 0002:01     : [PE# 00] Attached NPU 0004:00:01.0
[    2.245147] iommu: Adding device 0004:00:01.0 to group 1
[    2.245220] pci 0002:01     : [PE# 00] Attached NPU 0004:00:01.1
[    2.249113] iommu: Adding device 0004:00:01.1 to group 1
[    2.249237] pci 000a:01     : [PE# 00] Attached NPU 0005:00:01.0
[    2.251981] iommu: Adding device 0005:00:01.0 to group 7
[    2.252072] pci 000a:01     : [PE# 00] Attached NPU 0005:00:01.1
[    2.253333] iommu: Adding device 0005:00:01.1 to group 7
[    2.263275] EEH: PCI Enhanced I/O Error Handling Enabled
[    2.274155] powernv-rng: Registering arch random hook.
[    2.280637] HugeTLB registered 16.0 MiB page size, pre-allocated 0 pages
[    2.280686] HugeTLB registered 16.0 GiB page size, pre-allocated 0 pages
[    2.281696] random: crng init done
[    2.282851] pci 0009:06:00.0: vgaarb: VGA device added: decodes=io+mem,owns=none,locks=none
[    2.282909] pci 0009:06:00.0: vgaarb: bridge control possible
[    2.282952] pci 0009:06:00.0: vgaarb: setting as boot device (VGA legacy resources not available)
[    2.283009] vgaarb: loaded
[    2.283236] SCSI subsystem initialized
[    2.283381] usbcore: registered new interface driver usbfs
[    2.283429] usbcore: registered new interface driver hub
[    2.283883] usbcore: registered new device driver usb
[    2.283967] pps_core: LinuxPPS API ver. 1 registered
[    2.284011] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    2.284210] PTP clock support registered
[    2.285421] clocksource: Switched to clocksource timebase
[    2.303766] NET: Registered protocol family 2
[    2.304657] tcp_listen_portaddr_hash hash table entries: 65536 (order: 4, 1048576 bytes)
[    2.304859] TCP established hash table entries: 524288 (order: 6, 4194304 bytes)
[    2.306449] TCP bind hash table entries: 65536 (order: 4, 1048576 bytes)
[    2.306744] TCP: Hash tables configured (established 524288 bind 65536)
[    2.306965] UDP hash table entries: 65536 (order: 5, 2097152 bytes)
[    2.307282] UDP-Lite hash table entries: 65536 (order: 5, 2097152 bytes)
[    2.307918] NET: Registered protocol family 1
[    2.308366] RPC: Registered named UNIX socket transport module.
[    2.308411] RPC: Registered udp transport module.
[    2.308445] RPC: Registered tcp transport module.
[    2.308478] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    2.308587] pci 0009:00:00.0: enabling device (0101 -> 0103)
[    2.308635] pci 0009:01:00.0: enabling device (0141 -> 0143)
[    2.308686] pci 0009:02:01.0: enabling device (0141 -> 0143)
[    2.308733] pci 0009:03:00.0: enabling device (0140 -> 0142)
[    2.324919] pci 0009:03:00.0: xHCI HW did not halt within 16000 usec status = 0x0
[    2.324978] pci 0009:03:00.0: quirk_usb_early_handoff+0x0/0xd20 took 16010 usecs
[    2.325133] Trying to unpack rootfs image as initramfs...
[    2.689954] Freeing initrd memory: 22080K
[    2.695672] workingset: timestamp_bits=39 max_order=22 bucket_order=0
[    2.701251] NFS: Registering the id_resolver key type
[    2.701429] Key type id_resolver registered
[    2.701529] Key type id_legacy registered
[    2.701662] pstore: using deflate compression
[    2.702363] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
[    2.702611] io scheduler noop registered
[    2.702637] io scheduler deadline registered
[    2.702813] io scheduler cfq registered (default)
[    2.702955] io scheduler mq-deadline registered
[    2.702988] io scheduler kyber registered
[    2.704888] pci 0009:02:03.0: enabling device (0141 -> 0143)
[    2.705079] pci 0009:05:00.0: enabling device (0141 -> 0143)
[    2.705142] pci 0009:06:00.0: enabling device (0141 -> 0143)
[    2.705192] Using unsupported 1024x768 vga at 3fe281010000, depth=32, pitch=4096
[    2.839148] Console: switching to colour frame buffer device 128x48
[    2.970907] fb0: Open Firmware frame buffer device on /pciex@3fffe40500000/pci@0/pci@0/pci@3/pci@0/vga@0
[    2.986418] hvc0: raw protocol on /ibm,opal/consoles/serial@0 (boot console)
[    2.986633] hvc0: No interrupts property, using OPAL event
[    2.987066] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    2.990800] brd: module loaded
[    3.000806] loop: module loaded
[    3.000866] Uniform Multi-Platform E-IDE driver
[    3.001139] ide-gd driver 1.18
[    3.001243] ide-cd driver 5.00
[    3.001369] ipr: IBM Power RAID SCSI Device Driver version: 2.6.4 (March 14, 2017)
[    3.001720] pci 0009:02:02.0: enabling device (0141 -> 0143)
[    3.001776] ahci 0009:04:00.0: enabling device (0541 -> 0543)
[    3.001915] ahci 0009:04:00.0: Using 64-bit DMA iommu bypass
[    3.012048] ahci 0009:04:00.0: AHCI 0001.0000 32 slots 4 ports 6 Gbps 0xf impl SATA mode
[    3.012103] ahci 0009:04:00.0: flags: 64bit ncq sntf led only pmp fbs pio slum part sxs 
[    3.012767] scsi host0: ahci
[    3.013025] scsi host1: ahci
[    3.013162] scsi host2: ahci
[    3.013294] scsi host3: ahci
[    3.013369] ata1: SATA max UDMA/133 abar m2048@0x3fe280800000 port 0x3fe280800100 irq 482
[    3.013440] ata2: SATA max UDMA/133 abar m2048@0x3fe280800000 port 0x3fe280800180 irq 482
[    3.013493] ata3: SATA max UDMA/133 abar m2048@0x3fe280800000 port 0x3fe280800200 irq 482
[    3.013546] ata4: SATA max UDMA/133 abar m2048@0x3fe280800000 port 0x3fe280800280 irq 482
[    3.013744] libphy: Fixed MDIO Bus: probed
[    3.013793] tg3.c:v3.137 (May 11, 2014)
[    3.013828] pci 0009:02:04.0: enabling device (0141 -> 0143)
[    3.013880] tg3 0009:07:00.0: enabling device (0140 -> 0142)
[    3.040828] tg3 0009:07:00.0: Using 64-bit DMA iommu bypass
[    3.041087] tg3 0009:07:00.0 eth0: Tigon3 [partno(BCM95718) rev 5717100] (PCI Express) MAC address 70:e2:84:14:0a:92
[    3.041169] tg3 0009:07:00.0 eth0: attached PHY is 5718C (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[1])
[    3.041242] tg3 0009:07:00.0 eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]
[    3.041295] tg3 0009:07:00.0 eth0: dma_rwctrl[00000000] dma_mask[64-bit]
[    3.041457] tg3 0009:07:00.1: enabling device (0140 -> 0142)
[    3.075063] tg3 0009:07:00.1: Using 64-bit DMA iommu bypass
[    3.075365] tg3 0009:07:00.1 eth1: Tigon3 [partno(BCM95718) rev 5717100] (PCI Express) MAC address 70:e2:84:14:0a:93
[    3.075444] tg3 0009:07:00.1 eth1: attached PHY is 5718C (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[1])
[    3.075514] tg3 0009:07:00.1 eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]
[    3.075568] tg3 0009:07:00.1 eth1: dma_rwctrl[00000000] dma_mask[64-bit]
[    3.075845] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    3.075902] e100: Copyright(c) 1999-2006 Intel Corporation
[    3.075954] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    3.076011] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    3.076072] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
[    3.076121] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[    3.076191] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    3.076238] ehci-pci: EHCI PCI platform driver
[    3.076284] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    3.076331] ohci-pci: OHCI PCI platform driver
[    3.076635] mousedev: PS/2 mouse device common for all mice
[    3.336533] ata3: SATA link down (SStatus 0 SControl 300)
[    3.336614] ata4: SATA link down (SStatus 0 SControl 300)
[    3.435359] rtc-opal opal-rtc: rtc core: registered rtc-opal as rtc0
[    3.437513] device-mapper: uevent: version 1.0.3
[    3.437714] device-mapper: ioctl: 4.39.0-ioctl (2018-04-03) initialised: dm-devel@redhat.com
[    3.437788] powernv-cpufreq: cpufreq pstate min 0xffffffc5 nominal 0xffffffdd max 0x0
[    3.437838] powernv-cpufreq: Workload Optimized Frequency is enabled in the platform
[    3.442024] nx_compress_powernv: coprocessor found on chip 0, CT 3 CI 1
[    3.442071] nx_compress_powernv: coprocessor found on chip 1, CT 3 CI 2
[    3.442718] usbcore: registered new interface driver usbhid
[    3.442766] usbhid: USB HID core driver
[    3.442800] oprofile: using timer interrupt.
[    3.443208] ipip: IPv4 and MPLS over IPv4 tunneling driver
[    3.443545] NET: Registered protocol family 17
[    3.443622] Key type dns_resolver registered
[    3.443713] drmem: No dynamic reconfiguration memory found
[    3.444131] registered taskstats version 1
[    3.444431] console [netcon0] enabled
[    3.444458] netconsole: network logging started
[    3.465427] rtc-opal opal-rtc: setting system clock to 2018-07-17 10:38:12 UTC (1531823892)
[    3.505354] ata2: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    3.505431] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    3.506376] ata2.00: ATA-10: ST1000NX0313         00LY266 00LY265IBM, BE33, max UDMA/133
[    3.506602] ata2.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth 32), AA
[    3.506660] ata1.00: ATA-10: ST1000NX0313         00LY266 00LY265IBM, BE33, max UDMA/133
[    3.506722] ata1.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth 32), AA
[    3.507214] ata2.00: configured for UDMA/133
[    3.507348] ata1.00: configured for UDMA/133
[    3.507617] scsi 0:0:0:0: Direct-Access     ATA      ST1000NX0313     BE33 PQ: 0 ANSI: 5
[    3.508125] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    3.508209] sd 0:0:0:0: [sda] 1953525168 512-byte logical blocks: (1.00 TB/932 GiB)
[    3.508286] sd 0:0:0:0: [sda] 4096-byte physical blocks
[    3.508368] sd 0:0:0:0: [sda] Write Protect is off
[    3.508443] scsi 1:0:0:0: Direct-Access     ATA      ST1000NX0313     BE33 PQ: 0 ANSI: 5
[    3.508474] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    3.509057] sd 1:0:0:0: [sdb] 1953525168 512-byte logical blocks: (1.00 TB/932 GiB)
[    3.509109] sd 1:0:0:0: Attached scsi generic sg1 type 0
[    3.509155] sd 1:0:0:0: [sdb] 4096-byte physical blocks
[    3.509306] sd 1:0:0:0: [sdb] Write Protect is off
[    3.511791] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    3.530032]  sda: sda1 sda2 sda3
[    3.530695] sd 0:0:0:0: [sda] Attached SCSI removable disk
[    3.541431] sd 1:0:0:0: [sdb] Attached SCSI removable disk
[    3.541669] Freeing unused kernel memory: 2560K
[    3.541711] This architecture does not have kernel memory protection.
[    3.545630] systemd[1]: Failed to insert module 'autofs4'
[    3.556395] systemd[1]: systemd 219 running in system mode. (+PAM +AUDIT +SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ -LZ4 -SECCOMP +BLKID +ELFUTILS +KMOD +IDN)
[    3.586336] systemd[1]: Detected architecture ppc64-le.
[    3.593471] systemd[1]: Running in initial RAM disk.

Welcome to CentOS Linux 7 (AltArch) dracut-033-535.el7 (Initramfs)!

[    3.635439] systemd[1]: Set hostname to <localhost.localdomain>.
[  OK  ] Reached target Local File Systems.
[    3.683293] systemd[1]: Reached target Local File Systems.
[    3.683347] systemd[1]: Starting Local File Systems.
[  OK  ] Reached target Swap.
[    3.683739] systemd[1]: Reached target Swap.
[    3.683791] systemd[1]: Starting Swap.
[  OK  ] Reached target Timers.
[    3.684027] systemd[1]: Reached target Timers.
[    3.684078] systemd[1]: Starting Timers.
[  OK  ] Created slice Root Slice.
[  OK  ] Created slice System Slice.
[  OK  ] Listening on udev Kernel Socket.
[  OK  ] Listening on Journal Socket.
         Starting dracut cmdline hook...
         Starting Journal Service...
         Starting Setup Virtual Console...
         Starting Create list of required st... nodes for the current kernel...
[  OK  ] Reached target Slices.
[  OK  ] Listening on udev Control Socket.
[  OK  ] Reached target Sockets.
         Starting Apply Kernel Variables...
[  OK  ] Started Create list of required sta...ce nodes for the current kernel.
         Starting Create Static Device Nodes in /dev...
[[    3.828683] s  OK  etfont (2760) used greatest stack depth: 10832 bytes left
] Started Apply Kernel Variables.
[  OK  ] Started Create Static Device Nodes in /dev.
[  OK  ] Started Journal Service.
[  OK  ] Started dracut cmdline hook.
         Starting dracut pre-udev hook...
[  OK  ] Started dracut pre-udev hook.
         Starting udev Kernel Device Manager...
[  OK  ] Started udev Kernel Device Manager.
         Starting udev Coldplug all Devices...
[  OK  ] Started Setup Virtual Console.
[    3.948050] tg3 0009:07:00.1 enP9p7s0f1: renamed from eth1
[    3.950177] bnx2x: QLogic 5771x/578xx 10/20-Gigabit Ethernet Driver bnx2x 1.712.30-0 (2014/02/10)
[    3.950620] bnx2x 0008:01:00.0: msix capability found
[    3.950855] pci 0008:00:00.0: enabling device (0101 -> 0103)
[    3.958152] Emulex LightPulse Fibre Channel SCSI driver 12.0.0.5
[    3.958364] Copyright (C) 2017-2018 Broadcom. All Rights Reserved. The term "Broadcom" refers to Broadcom Inc. and/or its subsidiaries.
[    3.958768] pci 0001:00:00.0: enabling device (0101 -> 0103)
[    3.958840] lpfc 0001:01:00.0: enabling device (0140 -> 0142)
[    3.958967] lpfc 0001:01:00.0: Using 64-bit DMA iommu bypass
[    3.960403] scsi host4: Emulex LPe12000 PCIe Fibre Channel Adapter on PCI bus 01 device 00 irq 493
[    3.968973] synth uevent: /devices/vio: failed to send uevent
[    3.968976] vio vio: uevent: failed to send synthetic uevent
[    3.975336] bnx2x 0008:01:00.0: enabling device (0140 -> 0142)
[    3.975466] bnx2x 0008:01:00.0: Using 64-bit DMA iommu bypass
[    3.975560] bnx2x 0008:01:00.0: part number 0-0-0-0
[  OK  ] Started udev Coldplug all Devices.
         Starting Show Plymouth Boot Screen...
         Starting dracut initqueue hook...
[  OK  ] Reached target System Initialization.
[  OK  ] Started Show Plymouth Boot Screen.
[  OK  ] Reached target Paths.
[  OK  ] Reached target Basic System.
[    4.169826] bnx2x 0008:01:00.0: 32.000 Gb/s available PCIe bandwidth (5 GT/s x8 link)
[    4.169877] tg3 0009:07:00.0 enP9p7s0f0: renamed from eth0
[    4.170003] bnx2x 0008:01:00.1: msix capability found
[    4.195353] bnx2x 0008:01:00.1: enabling device (0140 -> 0142)
[    4.195441] bnx2x 0008:01:00.1: Using 64-bit DMA iommu bypass
[    4.195485] bnx2x 0008:01:00.1: part number 0-0-0-0
[    4.378706] bnx2x 0008:01:00.1: 32.000 Gb/s available PCIe bandwidth (5 GT/s x8 link)
[    4.379078] bnx2x 0008:01:00.2: msix capability found
[    4.405343] bnx2x 0008:01:00.2: enabling device (0140 -> 0142)
[    4.405637] bnx2x 0008:01:00.2: Using 64-bit DMA iommu bypass
[    4.405869] bnx2x 0008:01:00.2: part number 0-0-0-0
[    4.498847] bnx2x 0008:01:00.2: 32.000 Gb/s available PCIe bandwidth (5 GT/s x8 link)
[    4.499209] bnx2x 0008:01:00.3: msix capability found
[    4.525338] bnx2x 0008:01:00.3: enabling device (0140 -> 0142)
[    4.525625] bnx2x 0008:01:00.3: Using 64-bit DMA iommu bypass
[    4.525855] bnx2x 0008:01:00.3: part number 0-0-0-0
[    4.608719] bnx2x 0008:01:00.3: 32.000 Gb/s available PCIe bandwidth (5 GT/s x8 link)
[    4.610092] bnx2x 0008:01:00.1 enP8p1s0f1: renamed from eth0
[    4.685457] bnx2x 0008:01:00.0 enP8p1s0f0: renamed from eth1
[    4.815428] bnx2x 0008:01:00.3 enP8p1s0f3: renamed from eth3
[    4.925401] bnx2x 0008:01:00.2 enP8p1s0f2: renamed from eth2
[    6.820010] lpfc 0001:01:00.1: enabling device (0140 -> 0142)
[    6.820277] lpfc 0001:01:00.1: Using 64-bit DMA iommu bypass
[    6.821251] scsi host5: Emulex LPe12000 PCIe Fibre Channel Adapter on PCI bus 01 device 01 irq 494
[    7.520761] lpfc 0001:01:00.0: 0:1303 Link Up Event x1 received Data: x1 x1 x20 x0 x0 x0 0
[    7.580412] scsi 4:0:0:0: Direct-Access     IBM      2145             0000 PQ: 0 ANSI: 6
[    7.581321] sd 4:0:0:0: Power-on or device reset occurred
[    7.581339] sd 4:0:0:0: Attached scsi generic sg2 type 0
[    7.582133] scsi 4:0:1:0: Direct-Access     IBM      2145             0000 PQ: 0 ANSI: 6
[    7.582320] sd 4:0:0:0: [sdc] 209715200 512-byte logical blocks: (107 GB/100 GiB)
[    7.582492] sd 4:0:0:0: [sdc] Write Protect is off
[    7.582769] sd 4:0:1:0: Power-on or device reset occurred
[    7.582771] sd 4:0:1:0: Attached scsi generic sg3 type 0
[    7.582774] sd 4:0:0:0: [sdc] Write cache: disabled, read cache: enabled, supports DPO and FUA
[    7.583939] sd 4:0:1:0: [sdd] 209715200 512-byte logical blocks: (107 GB/100 GiB)
[    7.584199] sd 4:0:1:0: [sdd] Write Protect is off
[    7.584747] sd 4:0:1:0: [sdd] Write cache: disabled, read cache: enabled, supports DPO and FUA
[    7.587435]  sdd: sdd1 sdd2 sdd3
[    7.589036] sd 4:0:1:0: [sdd] Attached SCSI disk
[    7.726589]  sdc: sdc1 sdc2 sdc3
[    7.727907] sd 4:0:0:0: [sdc] Attached SCSI disk
[    9.586309] sd 4:0:1:0: Power-on or device reset occurred
[    9.586497] sd 4:0:0:0: Power-on or device reset occurred
[  OK  ] Found device /dev/mapper/ca_ltc--garri5-root.
         Starting File System Check on /dev/mapper/ca_ltc--garri5-root...
[  OK  ] Started File System Check on /dev/mapper/ca_ltc--garri5-root.
[  OK  ] Started dracut initqueue hook.
         Mounting /sysroot...
[  OK  ] Reached target Remote File Systems (Pre).
[  OK  ] Reached target Remote File Systems.
[   10.192770] SGI XFS with ACLs, security attributes, no debug enabled
[   10.200795] XFS (dm-5): Mounting V5 Filesystem
[   10.280831] lpfc 0001:01:00.1: 1:1303 Link Up Event x1 received Data: x1 x1 x20 x0 x0 x0 0
[   10.349522] scsi 5:0:0:0: Direct-Access     IBM      2145             0000 PQ: 0 ANSI: 6
[   10.350384] sd 5:0:0:0: Power-on or device reset occurred
[   10.350407] sd 5:0:0:0: Attached scsi generic sg4 type 0
[   10.351177] scsi 5:0:1:0: Direct-Access     IBM      2145             0000 PQ: 0 ANSI: 6
[   10.351593] sd 5:0:0:0: [sde] 209715200 512-byte logical blocks: (107 GB/100 GiB)
[   10.351787] sd 5:0:0:0: [sde] Write Protect is off
[   10.351897] sd 5:0:1:0: Power-on or device reset occurred
[   10.351910] sd 5:0:1:0: Attached scsi generic sg5 type 0
[   10.352061] sd 5:0:0:0: [sde] Write cache: disabled, read cache: enabled, supports DPO and FUA
[   10.352989] sd 5:0:1:0: [sdf] 209715200 512-byte logical blocks: (107 GB/100 GiB)
[   10.353453] sd 5:0:1:0: [sdf] Write Protect is off
[   10.353559] XFS (dm-5): Starting recovery (logdev: internal)
[   10.353814] sd 5:0:1:0: [sdf] Write cache: disabled, read cache: enabled, supports DPO and FUA
[   10.355027]  sde: sde1 sde2 sde3
[   10.357063]  sdf: sdf1 sdf2 sdf3
[   10.357068] sd 5:0:0:0: [sde] Attached SCSI disk
[   10.358899] sd 5:0:1:0: [sdf] Attached SCSI disk
[   10.660009] XFS (dm-5): Ending recovery (logdev: internal)
[   10.660529] mount (6202) used greatest stack depth: 9744 bytes left
[  OK  ] Mounted /sysroot.
[  OK  ] Reached target Initrd Root File System.
         Starting Reload Configuration from the Real Root...
[  OK  ] Started Reload Configuration from the Real Root.
[  OK  ] Reached target Initrd File Systems.
[  OK  ] Reached target Initrd Default Target.
         Starting dracut pre-pivot and cleanup hook...
[  OK  ] Started dracut pre-pivot and cleanup hook.
         Starting Cleaning Up and Shutting Down Daemons...
         Starting Plymouth switch root service...
[  OK  ] Stopped target Timers.
[  OK  ] Stopped Cleaning Up and Shutting Down Daemons.
[  OK  ] Stopped dracut pre-pivot and cleanup hook.
         Stopping dracut pre-pivot and cleanup hook...
[  OK  ] Stopped target Remote File Systems.
[  OK  ] Stopped target Remote File Systems (Pre).
[  OK  ] Stopped dracut initqueue hook.
         Stopping dracut initqueue hook...
[  OK  ] Stopped target Initrd Default Target.
[  OK  ] Stopped target Basic System.
[  OK  ] Stopped target Sockets.
[  OK  ] Stopped target System Initialization.
[  OK  ] Stopped target Local File Systems.
[  OK  ] Stopped Apply Kernel Variables.
         Stopping Apply Kernel Variables...
[  OK  ] Stopped udev Coldplug all Devices.
         Stopping udev Coldplug all Devices...
[  OK  ] Stopped target Swap.
         Stopping udev Kernel Device Manager...
[  OK  ] Stopped target Paths.
[  OK  ] Stopped target Slices.
[  OK  ] Started Plymouth switch root service.
[  OK  ] Stopped udev Kernel Device Manager.
[  OK  ] Stopped Create Static Device Nodes in /dev.
         Stopping Create Static Device Nodes in /dev...
[  OK  ] Stopped Create list of required sta...ce nodes for the current kernel.
         Stopping Create list of required st... nodes for the current kernel...
[  OK  ] Stopped dracut pre-udev hook.
         Stopping dracut pre-udev hook...
[  OK  ] Stopped dracut cmdline hook.
         Stopping dracut cmdline hook...
[  OK  ] Closed udev Kernel Socket.
[  OK  ] Closed udev Control Socket.
         Starting Cleanup udevd DB...
[  OK  ] Started Cleanup udevd DB.
[  OK  ] Reached target Switch Root.
         Starting Switch Root...
[   11.325274] systemd-journald[2757]: Received SIGTERM from PID 1 (systemd).
[   11.454950] systemd: 24 output lines suppressed due to ratelimiting
[   12.026865] systemd[1]: Inserted module 'autofs4'
[   12.084052] systemd[1]: Inserted module 'ip_tables'

Welcome to CentOS Linux 7 (AltArch)!

[  OK  ] Stopped Switch Root.
[  OK  ] Stopped Journal Service.
         Starting Journal Service...
         Mounting POSIX Message Queue File System...
         Mounting Huge Pages File System...
[  OK  ] Created slice system-serial\x2dgetty.slice.
[  OK  ] Set up automount Arbitrary Executab...ats File System Automount Point.
[  OK  ] Stopped File System Check on Root Device.
         Stopping File System Check on Root Device...
         Starting Create list of required st... nodes for the current kernel...
[  OK  ] Listening on udev Control Socket.
[  OK  ] Listening on LVM2 metadata daemon socket.
[  OK  ] Created slice system-getty.slice.
[  OK  ] Stopped target Switch Root.
[  OK  ] Stopped target Initrd Root File System.
[  OK  ] Created slice system-selinux\x2dpol...grate\x2dlocal\x2dchanges.slice.
         Starting Replay Read-Ahead Data...
[  OK  ] Listening on LVM2 poll daemon socket.
[  OK  ] Reached target Host and Network Name Lookups.
[  OK  ] Created slice User and Session Slice.
[  OK  ] Reached target Slices.
         Mounting NFSD configuration filesystem...
[  OK  ] Listening on Device-mapper event daemon FIFOs.
         Starting Monitoring of LVM2 mirrors... dmeventd or progress polling...
         Starting Collect Read-Ahead Data...
[  OK  ] Listening on /dev/initctl Compatibility Named Pipe.
[  OK  ] Listening on udev Kernel Socket.
         Mounting Debug File System...
[  OK  ] Listening on Delayed Shutdown Socket.
[  OK  ] Stopped target Initrd File Systems.
[  OK  ] Mounted POSIX Message Queue File System.
[  OK  ] Mounted Huge Pages File System.
[  OK  ] Started Create list of required sta...ce nodes for the current kernel.
[  OK  ] Started Journal Service.
[   13.724529] systemd-readahead[6451]: Failed to create fanotify object: Function not implemented
[  OK  ] Started Collect Read-Ahead Data.
[  OK  ] Started Replay Read-Ahead Data.
         Starting Remount Root and Kernel File Systems...
         Starting Create Static Device Nodes in /dev...
         Starting Apply Kernel Variables...
         Starting Set Up Additional Binary Formats...
         Starting Load legacy module configuration...
[  OK  ] Mounted Debug File System.
[  OK  ] Started Remount Root and Kernel File Systems.
[  OK  ] Started Apply Kernel Variables.
         Mounting Arbitrary Executable File Formats File System...
         Starting udev Coldplug all Devices...
         Starting Load/Save Random Seed...
         Starting Flush Journal to Persistent Storage...
         Starting Configure read-only root support...
[  OK  ] Mounted Arbitrary Executable File Formats File System.
[   14.165587] synth uevent: /devices/vio: failed to send uevent
[   14.165592] vio vio: uevent: failed to send synthetic uevent
[   14.177029] WARNING: CPU: 56 PID: 6471 at fs/buffer.c:1965 __block_write_begin_int+0x188/0x770
[   14.177351] Modules linked in: binfmt_misc ip_tables x_tables autofs4 xfs lpfc bnx2x crc_t10dif crct10dif_generic nvme_fc nvme_fabrics mdio libcrc32c nvme_core crct10dif_common
[   14.177604] CPU: 56 PID: 6471 Comm: systemd-random- Not tainted 4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3 #2
[   14.177856] NIP:  c0000000003662d8 LR: c000000000366230 CTR: c00000000039e6a0
[   14.177966] REGS: c000001fdd4876f0 TRAP: 0700   Not tainted  (4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3)
[   14.178169] MSR:  90000000000[  OK  ]29033 <SF,HV,EE, Started udev CoME,IR,DR,RI,LE>  CR: 24282824  XlER: 20000000
[   14.178453] CFAR: c0000000003662a0 IRQMASK: 0
 
[   14.178453] GPR00: c000000000366230 c000001fdd487970 c00000000105b100 c000001fd5aa05a0 
[   14.178453] GPR04: c000001fb60535b8 c000001fd5aa05a0 0000000000000000 c000001fdd487b90 
[   14.178453] GPR08: 0000000000000000 0000000000000001 0000000000000000 c000001fdd487d70 
[   14.178453] GPR12: 0000000000002200 c000001ffffd0c80 f000000007f06d40 0000000000000400 
[   14.178453] GPR16: 0000000000000000 0000000000000000 c000001fd5aa05a0 0000000000000000 
[   14.178453] GPR20: 00000000d5aa05e0 c000001fdd487990 c000001fdd487b90 00000000d5aa05e0 
[   14.178453] GPR24: c000001fb60535b8 0000000000000000 0000000000000001 0000000000000040 
[   14.178453] GPR28: 0000000000000000 0000000000000000 00000000d5aa05e0 00000000d5aa05e0 
[   14.180035] NIP [c0000000003662d8] __block_write_begin_int+0x188/0x770
[   14.180040] LR [c000000000366230] __block_write_begin_int+0xe0/0x770
         Startin[   14.180309] Call Trace:
g[   14.180342] [c000001fdd487970] [c000000000366230] __block_write_begin_int+0xe0/0x770 (unreliable)
 udev Wait for C[   14.180577] [c000001fdd487a50] [c00000000039dof30] iomap_write_begin.constprop.28+0xd0/0x330
mplete Device In[   14.180814] [c000001fdd487ae0] [c00000000039e770] iomap_write_actor+0xd0/0x210
i[   14.180885] [c000001fdd487b70] [c00000000039e9c0] iomap_apply+0x110/0x1f0
[   14.181103] [c000001fdd487c20] [c00000000039eea0] iomap_file_buffered_write+0x90/0x110

[   14.181206] [c000001fdd487c70] [d0000000117ae308] xfs_file_buffered_aio_write+0xf8/0x3a0 [xfs]
[   14.181393] [c000001fdd487d00] [c000000000313cf0] __vfs_write+0x130/0x1e0
[   14.181445] [c000001fdd487d90] [c000000000313fe8] vfs_write+0xc8/0x240
[   14.181657] [c000001fdd487de0] [c00000000031435c] ksys_write+0x5c/0x100
[   14.181710] [c000001fdd487e30] [c00000000000b9e4] system_call+0x5c/0x70
[   14.181954] Instruction dump:
[   14.181986] 7cc6d878 7cc049ad 40c2fff4 e8a10030 e9250000 792adfe3 40820058 e9250020 
[   14.182206] 7ee94a78 7d290074 7929d182 69290001 <0b090000> 41920304 7f2903a6 7f03c378 
[   14.182433] ---[ end trace 170e435bc8a21925 ]---
[   14.182478] Unable to handle kernel paging request for data at address 0x0000ffff
[   14.182689] Faulting instruction address: 0xc0000000003663cc
[   14.182741] Oops: Kernel access of bad area, sig: 11 [#1]
[   14.182936] LE SMP NR_CPUS=2048 NUMA PowerNV
[   14.182979] Modules linked in: binfmt_misc ip_tables x_tables autofs4 xfs lpfc bnx2x crc_t10dif crct10dif_generic nvme_fc nvme_fabrics mdio libcrc32c nvme_core crct10dif_common
[   14.183257] CPU: 56 PID: 6471 Comm: systemd-random- Tainted: G        W         4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3 #2
[   14.183491] NIP:  c0000000003663cc LR: c000000000366230 CTR: c00000000039e6a0
[   14.183552] REGS: c000001fdd4876f0 TRAP: 0300   Tainted: G        W          (4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3)
[   14.183793] MSR:  9000000000009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 44282828  XER: 00000000
[   14.184008] CFAR: c000000000008934 DAR: 000000000000ffff DSISR: 40000000 IRQMASK: 0 
[   14.184008] GPR00: c000000000366230 c000001fdd487970 c00000000105b100 0000000654464000 
[   14.184008] GPR04: 0000000654464000 0000000000000020 000000000000ffff c000001fdd487b90 
[   14.184008] GPR08: 0000000000000000 003ffff80000100d 0000000000000001 c000001fdd487d70 
[   14.184008] GPR12: 0000000000002200 c000001ffffd0c80 f000000007f06d40 0000000000000400 
[   14.184008] GPR16: 0000000000000000 0000000000000000 c000001fd5aa05a0 000000002a55fa20 
[   14.184008] GPR20: 00000000ab540bc0 c000001fdd487990 c000001fdd487b90 00000000d5aa05e0 
[   14.184008] GPR24: c000001fb60535b8 0000000000000000 0000000000000001 0000000000000040 
[   14.184008] GPR28: 0000000000000001 00000000d5aa05e0 00000000d5aa05e0 00000000ab540bc0 
[   14.185363] NIP [c0000000003663cc] __block_write_begin_int+0x27c/0x770
[   14.185564] LR [c000000000366230] __block_write_begin_int+0xe0/0x770
[   14.185608] Call Trace:
[   14.185627] [c000001fdd487970] [c000000000366230] __block_write_begin_int+0xe0/0x770 (unreliable)
[   14.185827] [c000001fdd487a50] [c00000000039df30] iomap_write_begin.constprop.28+0xd0/0x330
[   14.185877] [c000001fdd487ae0] [c00000000039e770] iomap_write_actor+0xd0/0x210
[   14.186062] [c000001fdd487b70] [c00000000039e9c0] iomap_apply+0x110/0x1f0
[   14.186105] [c000001fdd487c20] [c00000000039eea0] iomap_file_buffered_write+0x90/0x110
[   14.186179] [c000001fdd487c70] [d0000000117ae308] xfs_file_buffered_aio_write+0xf8/0x3a0 [xfs]
[   14.186382] [c000001fdd487d00] [c000000000313cf0] __vfs_write+0x130/0x1e0
[   14.186428] [c000001fdd487d90] [c000000000313fe8] vfs_write+0xc8/0x240
[   14.186610] [c000001fdd487de0] [c00000000031435c] ksys_write+0x5c/0x100
[   14.186654] [c000001fdd487e30] [c00000000000b9e4] system_call+0x5c/0x70
[   14.186694] Instruction dump:
[   14.186719] 79530020 79140020 419cfeec e8ce0008 7dc97378 78c807e1 40c204d4 e9290000 
[   14.186773] 792aefe3 41820160 7c2004ac e8c10030 <e8a60000> 7cc93378 78a807e1 4082ff98 
[   14.186828] ---[ end trace 170e435bc8a21926 ]---
[   14.336023] 
         Starting Device-Mapper Multipath Device Controller...
[  OK  ] Started Set Up Additional Binary Formats.
[FAILED] Failed to start Load/Save Random Seed.
See 'systemctl status systemd-random-seed.service' for details.
[   14.383895] systemd-journald[6436]: Received request to flush runtime journal from PID 1
[  OK  ] Started Flush Journal to Persistent Storage.
[  OK  ] Started Create Static Device Nodes in /dev.
         Starting udev Kernel Device Manager...
[  OK  ] Started LVM2 metadata daemon.
         Starting LVM2 metadata daemon...
[   14.884347] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[  OK  ] Mounted NFSD configuration filesystem.
[  OK  ] Started Configure read-only root support.
[  OK  ] Started Device-Mapper Multipath Device Controller.
[   15.493551] sd 5:0:0:0: Power-on or device reset occurred
[   15.526608] sd 5:0:1:0: Power-on or device reset occurred
[  OK  ] Started udev Kernel Device Manager.
[  OK  ] Started Load legacy module configuration.
[  OK  ] Found device /dev/hvc0.
[   15.915106] powernv_rng: Registered powernv hwrng.
[   16.111261] crypto_register_alg 'aes' = 0
[   16.111496] crypto_register_alg 'cbc(aes)' = 0
[   16.111724] crypto_register_alg 'ctr(aes)' = 0
[   16.111881] crypto_register_alg 'xts(aes)' = 0
[   16.505358] tg3 0009:07:00.0 net0: renamed from enP9p7s0f0
[  OK  ] Found device /dev/mapper/ca_ltc--garri5-home.
[  OK  ] Found device /dev/mapper/ca_ltc--garri5-swap.
         Activating swap /dev/mapper/ca_ltc--garri5-swap...
[   16.801645] Adding 4194240k swap on /dev/mapper/ca_ltc--garri5-swap.  Priority:-2 extents:1 across:4194240k 
[  OK  ] Activated swap /dev/mapper/ca_ltc--garri5-swap.
[  OK  ] Reached target Swap.
[   16.831345] device-mapper: multipath service-time: version 0.3.0 loaded
[   16.892917] device-mapper: table: 253:6: multipath: error getting device
[   16.893146] device-mapper: ioctl: error adding target to table
[  OK  ] Created slice system-lvm2\x2dpvscan.slice.
         Starting LVM2 PV scan on device 253:9...
[  OK  ] Found device ST1000NX0313_00LY266_00LY265IBM 2.
         Starting LVM2 PV scan on device 8:3...
[  OK  ] Started Monitoring of LVM2 mirrors,...ng dmeventd or progress polling.
[  OK  ] Reached target Local File Systems (Pre).
         Mounting /home...
         Mounting /boot...
[   17.376649] XFS (dm-4): Mounting V5 Filesystem
[  OK  ] Started LVM2 PV scan on device 8:3.
[   17.397100] XFS (sda2): Mounting V5 Filesystem
[  OK  ] Started udev Wait for Complete Device Initialization.
         Starting Activation of DM RAID sets...
[   17.894482] device-mapper: table: 253:6: multipath: error getting device
[   17.894740] device-mapper: ioctl: error adding target to table
[  OK  ] Started Activation of DM RAID sets.
[  OK  ] Reached target Encrypted Volumes.
[   18.896316] device-mapper: table: 253:6: multipath: error getting device
[   18.896545] device-mapper: ioctl: error adding target to table
[   18.991254] XFS (sda2): Starting recovery (logdev: internal)
[   18.993192] XFS (dm-4): Starting recovery (logdev: internal)
[  OK  ] Started LVM2 PV scan on device 253:9.
[   19.232775] XFS (sda2): Ending recovery (logdev: internal)
[  OK  ] Mounted /boot.
[   19.235922] XFS (dm-4): Ending recovery (logdev: internal)
[  OK  ] Mounted /home.
[  OK  ] Reached target Local File Systems.
         Starting Preprocess NFS configuration...
         Starting Import network configuration from initramfs...
         Starting Tell Plymouth To Write Out Runtime Data...
[  OK  ] Started Preprocess NFS configuration.
[   19.430061] Unable to handle kernel paging request for data at address 0x0000ffff
[   19.430315] Faulting instruction address: 0xc0000000003663cc
[   19.430534] Oops: Kernel access of bad area, sig: 11 [#2]
[   19.430574] LE SMP NR_CPUS=2048 NUMA PowerNV
[   19.430618] Modules linked in: dm_mirror dm_region_hash dm_log dm_service_time vmx_crypto powernv_rng rng_core kvm_hv kvm nfsd dm_multipath binfmt_misc ip_tables x_tables autofs4 xfs lpfc bnx2x crc_t10dif crct10dif_generic nvme_fc nvme_fabrics mdio libcrc32c nvme_core crct10dif_common
[   19.430979] CPU: 17 PID: 5323 Comm: plymouthd Tainted: G      D W         4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3 #2
[   19.431229] NIP:  c0000000003663cc LR: c000000000366230 CTR: c00000000039e6a0
[   19.431440] REGS: c000001fd348b6f0 TRAP: 0300   Tainted: G      D W          (4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3)
[   19.431527] MSR:  9000000000009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 44282824  XER: 20000000
[   19.431755] CFAR: c000000000008934 DAR: 000000000000ffff DSISR: 40000000 IRQMASK: 0 
[   19.431755] GPR00: c000000000366230 c000001fd348b970 c00000000105b100 c000003c9dcd1b80 
[   19.431755] GPR04: c000001fb6552eb8 0000000000000000 000000000000ffff c000001fd348bb90 
[   19.431755] GPR08: 0000000000000000 003ffff800001029 0000000000000001 c000001fd348bd70 
[   19.431755] GPR12: 0000000000002200 c000001fffff1b00 f000000007e8e000 0000000000005000 
[   19.431755] GPR16: 0000000000000000 0000000000004951 c000003c9dcd1b80 0000000000004951 
[   19.431755] GPR20: 0000000000000000 c000001fd348b990 c000001fd348bb90 0000000000000000 
[   19.431755] GPR24: c000001fb6552eb8 0000000000000000 0000000000000001 0000000000000040 
[   19.431755] GPR28: 0000000000000001 0000000000000000 0000000000000000 0000000000000000 
[   19.433076] NIP [c0000000003663cc] __block_write_begin_int+0x27c/0x770
[   19.433278] LR [c000000000366230] __block_write_begin_int+0xe0/0x770
[   19.433328] Call Trace:
[   19.433351] [c000001fd348b970] [c000000000366230] __block_write_begin_int+0xe0/0x770 (unreliable)
[   19.433572] [c000001fd348ba50] [c00000000039df30] iomap_write_begin.constprop.28+0xd0/0x330
[   19.433789] [c000001fd348bae0] [c00000000039e770] iomap_write_actor+0xd0/0x210
[   19.433851] [c000001fd348bb70] [c00000000039e9c0] iomap_apply+0x110/0x1f0
[   19.434054] [c000001fd348bc20] [c00000000039eea0] iomap_file_buffered_write+0x90/0x110
[   19.434150] [c000001fd348bc70] [d0000000117ae308] xfs_file_buffered_aio_write+0xf8/0x3a0 [xfs]
[   19.434369] [c000001fd348bd00] [c000000000313cf0] __vfs_write+0x130/0x1e0
[   19.434424] [c000001fd348bd90] [c000000000313fe8] vfs_write+0xc8/0x240
[   19.434621] [c000001fd348bde0] [c00000000031435c] ksys_write+0x5c/0x100
[   19.434674] [c000001fd348be30] [c00000000000b9e4] system_call+0x5c/0x70
[   19.434912] Instruction dump:
[   19.434943] 79530020 79140020 419cfeec e8ce0008 7dc97378 78c807e1 40c204d4 e9290000 
[   19.435161] 792aefe3 41820160 7c2004ac e8c10030 <e8a60000> 7cc93378 78a807e1 4082ff98 
[   19.435376] ---[ end trace 170e435bc8a21927 ]---
[   19.586238] 
[  OK  ] Started Tell Plymouth To Write Out Runtime Data.
[  OK  ] Started Create Volatile Files and Directories.
         Mounting RPC Pipe File System...
         Starting Security Auditing Service...
[  OK  ] Mounted RPC Pipe File System.
[  OK  ] Reached target rpc_pipefs.target.
         Starting NFSv4 ID-name mapping service...
[  OK  ] Started NFSv4 ID-name mapping service.
[   20.574238] WARNING: CPU: 70 PID: 12026 at fs/iomap.c:132 iomap_page_release+0x7c/0x90
[   20.574504] Modules linked in: dm_mirror dm_region_hash dm_log dm_service_time vmx_crypto powernv_rng rng_core kvm_hv kvm nfsd dm_multipath binfmt_misc ip_tables x_tables autofs4 xfs lpfc bnx2x crc_t10dif crct10dif_generic nvme_fc nvme_fabrics mdio libcrc32c nvme_core crct10dif_common
[   20.574870] CPU: 70 PID: 12026 Comm: rm Tainted: G      D W         4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3 #2
[   20.574951] NIP:  c00000000039b7cc LR: d00000001179d050 CTR: c00000000039d700
[   20.575168] REGS: c000001fa000f820 TRAP: 0700   Tainted: G      D W          (4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3)
[   20.575257] MSR:  9000000000029033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 48002824  XER: 20000000
[   20.575486] CFAR: c00000000039b788 IRQMASK: 0 
[   20.575486] GPR00: d00000001179d050 c000001fa000faa0 c00000000105b100 c000001fb6990618 
[   20.575486] GPR04: ffffffffffffffff ffffffffffffffc0 0000001ff6020000 ffffffffffffff83 
[   20.575486] GPR08: 0000000000001000 f000000007ea21c0 0000000000000223 d0000000117fd578 
[   20.575486] GPR12: c00000000039d700 c000001ffffc4f80 0000000000000000 0000000000000000 
[   20.575486] GPR16: 000000001000dba8 000000001000d888 c000001fa000fbe8 0000000000000000 
[   20.575486] GPR20: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 
[   20.575486] GPR24: c000001fa000fbe0 c000001fa000fc60 0000000000000001 c000001fb6980138 
[   20.575486] GPR28: 0000000000010000 0000000000000000 f000000007ea21c0 f000000007ea21c0 
[   20.576610] NIP [c00000000039b7cc] iomap_page_release+0x7c/0x90
[   20.576696] LR [d00000001179d050] xfs_vm_invalidatepage+0x50/0x130 [xfs]
[   20.576748] Call Trace:
[   20.576770] [c000001fa000faa0] [c000001f00000000] 0xc000001f00000000 (unreliable)
[   20.576865] [c000001fa000fac0] [d00000001179d050] xfs_vm_invalidatepage+0x50/0x130 [xfs]
[   20.576929] [c000001fa000fb10] [c00000000025f918] truncate_cleanup_page+0x98/0x140
[   20.576992] [c000001fa000fb40] [c00000000026076c] truncate_inode_pages_range+0x21c/0x970
[   20.577055] [c000001fa000fd50] [c00000000033a138] evict+0x1f8/0x230
[   20.577109] [c000001fa000fd90] [c00000000032b848] do_unlinkat+0x1e8/0x320
[   20.577162] [c000001fa000fe30] [c00000000000b9e4] system_call+0x5c/0x70
[   20.577213] Instruction dump:
[   20.577246] 7d0048a8 7d085078 7d0049ad 40c2fff4 39400000 f9490028 4bf45a65 60000000 
[   20.577312] 38210020 e8010010 7c0803a6 4e800020 <0fe00000> 4bffffbc 0fe00000 4bffffc0 
[   20.577379] ---[ end trace 170e435bc8a21928 ]---
[  OK  ] Started Security Auditing Service.
         Starting Update UTMP about System Boot/Shutdown...
[   20.600245] Unable to handle kernel paging request for data at address 0x0000ffff
[   20.600303] Faulting instruction address: 0xc0000000003663cc
[   20.600352] Oops: Kernel access of bad area, sig: 11 [#3]
[   20.600388] LE SMP NR_CPUS=2048 NUMA PowerNV
[   20.600427] Modules linked in: dm_mirror dm_region_hash dm_log dm_service_time vmx_crypto powernv_rng rng_core kvm_hv kvm nfsd dm_multipath binfmt_misc ip_tables x_tables autofs4 xfs lpfc bnx2x crc_t10dif crct10dif_generic nvme_fc nvme_fabrics mdio libcrc32c nvme_core crct10dif_common
[   20.600615] CPU: 74 PID: 12030 Comm: systemd-update- Tainted: G      D W         4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3 #2
[   20.600695] NIP:  c0000000003663cc LR: c000000000366230 CTR: c00000000039e6a0
[   20.600749] REGS: c000000002f536f0 TRAP: 0300   Tainted: G      D W          (4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3)
[   20.600831] MSR:  9000000000009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 44282824  XER: 20000000
[   20.600891] CFAR: c000000000008934 DAR: 000000000000ffff DSISR: 40000000 IRQMASK: 0 
[   20.600891] GPR00: c000000000366230 c000000002f53970 c00000000105b100 c000003c9dcd2020 
[   20.600891] GPR04: c000001fb6557f38 0000000000000000 000000000000ffff c000000002f53b90 
[   20.600891] GPR08: 0000000000000000 003ffff800001029 0000000000000001 c000000002f53d70 
[   20.600891] GPR12: 0000000000002200 c000001ffffc1980 f000000007e53c40 0000000000009b00 
[   20.600891] GPR16: 0000000000000000 0000000000009980 c000003c9dcd2020 0000000000009980 
[   20.600891] GPR20: 0000000000000000 c000000002f53990 c000000002f53b90 0000000000000000 
[   20.600891] GPR24: c000001fb6557f38 0000000000000000 0000000000000001 0000000000000040 
[   20.600891] GPR28: 0000000000020001 0000000000000000 0000000000000000 0000000000000000 
[   20.601386] NIP [c0000000003663cc] __block_write_begin_int+0x27c/0x770
[   20.601435] LR [c000000000366230] __block_write_begin_int+0xe0/0x770
[   20.601480] Call Trace:
[   20.601501] [c000000002f53970] [c000000000366230] __block_write_begin_int+0xe0/0x770 (unreliable)
[   20.601567] [c000000002f53a50] [c00000000039df30] iomap_write_begin.constprop.28+0xd0/0x330
[   20.601624] [c000000002f53ae0] [c00000000039e770] iomap_write_actor+0xd0/0x210
[   20.601680] [c000000002f53b70] [c00000000039e9c0] iomap_apply+0x110/0x1f0
[   20.601728] [c000000002f53c20] [c00000000039eea0] iomap_file_buffered_write+0x90/0x110
[   20.603711] [c000000002f53c70] [d0000000117ae308] xfs_file_buffered_aio_write+0xf8/0x3a0 [xfs]
[   20.604255] [c000000002f53d00] [c000000000313cf0] __vfs_write+0x130/0x1e0
[   20.605241] [c000000002f53d90] [c000000000313fe8] vfs_write+0xc8/0x240
[   20.605801] [c000000002f53de0] [c00000000031435c] ksys_write+0x5c/0x100
[   20.606362] [c000000002f53e30] [c00000000000b9e4] system_call+0x5c/0x70
[   20.611530] Instruction dump:
[   20.613916] 79530020 79140020 419cfeec e8ce0008 7dc97378 78c807e1 40c204d4 e9290000 
[   20.616559] 792aefe3 41820160 7c2004ac e8c10030 <e8a60000> 7cc93378 78a807e1 4082ff98 
[   20.619672] ---[ end trace 170e435bc8a21929 ]---
[   20.772598] 
[FAILED] Failed to start Update UTMP about System Boot/Shutdown.
See 'systemctl status systemd-update-utmp.service' for details.
[DEPEND] Dependency failed for Update UTMP about System Runlevel Changes.
[  OK  ] Reached target System Initialization.
[  OK  ] Listening on Virtual machine log manager socket.
[  OK  ] Listening on Virtual machine lock manager socket.
[  OK  ] Listening on RPCbind Server Activation Socket.
[  OK  ] Listening on Open-iSCSI iscsiuio Socket.
[  OK  ] Reached target Timers.
[  OK  ] Listening on D-Bus System Message Bus Socket.
[  OK  ] Listening on Open-iSCSI iscsid Socket.
[  OK  ] Reached target Sockets.
[  OK  ] Reached target Paths.
[  OK  ] Reached target Basic System.
         Starting NTP client/server...
[  OK  ] Started libstoragemgmt plug-in server daemon.
         Starting libstoragemgmt plug-in server daemon...
         Starting Resets System Activity Logs...
         Starting System Logging Service...
         Starting Authorization Manager...
[  OK  ] Started ABRT Automated Bug Reporting Tool.
         Starting ABRT Automated Bug Reporting Tool...
[  OK  ] Started ABRT kernel log watcher.
         Starting ABRT kernel log watcher...
[  OK  ] Started D-Bus System Message Bus.
         Starting D-Bus System Message Bus...
         Starting Ipmievd Daemon...
         Starting GSSAPI Proxy Daemon...
[  OK  ] Started Hardware RNG Entropy Gatherer Daemon.
         Starting Hardware RNG Entropy Gatherer Daemon...
[  OK  ] Started Self Monitoring and Reporting Technology (SMART) Daemon.
         Starting Self Monitoring and Reporting Technology (SMART) Daemon...
         Starting Rollback uncommitted netcf...rk config change transactions...
[  OK  ] Started irqbalance daemon.
         Starting irqbalance daemon...
         Starting Install ABRT coredump hook...
         Starting Login Service...
         Starting Dump dmesg to /var/log/dmesg...
[  OK  ] Started System Logging Service.
[  OK  ] Started Resets System Activity Logs.
[  OK  ] Started Rollback uncommitted netcf network config change transactions.
         Starting Network Manager...
[  OK  ] Started Login Service.
[  OK  ] Started Dump dmesg to /var/log/dmesg.
[  OK  ] Started NTP client/server.
[FAILED] Failed to start Ipmievd Daemon.
See 'systemctl status ipmievd.service' for details.
[  OK  ] Started GSSAPI Proxy Daemon.
[  OK  ] Reached target NFS client services.
[  OK  ] Started Install ABRT coredump hook.
[   23.912577] Unable to handle kernel paging request for data at address 0x0000ffff
[   23.912648] Faulting instruction address: 0xc0000000003663cc
[   23.912702] Oops: Kernel access of bad area, sig: 11 [#4]
[   23.912742] LE SMP NR_CPUS=2048 NUMA PowerNV
[   23.912788] Modules linked in: dm_mirror dm_region_hash dm_log dm_service_time vmx_crypto powernv_rng rng_core kvm_hv kvm nfsd dm_multipath binfmt_misc ip_tables x_tables autofs4 xfs lpfc bnx2x crc_t10dif crct10dif_generic nvme_fc nvme_fabrics mdio libcrc32c nvme_core crct10dif_common
[   23.912998] CPU: 48 PID: 12046 Comm: rs:main Q:Reg Tainted: G      D W         4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3 #2
[   23.913088] NIP:  c0000000003663cc LR: c000000000366230 CTR: c00000000039e6a0
[   23.913148] REGS: c000001fa09d36f0 TRAP: 0300   Tainted: G      D W          (4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3)
[   23.913237] MSR:  9000000000009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 44282824  XER: 20000000
[   23.913305] CFAR: c000000000008934 DAR: 000000000000ffff DSISR: 40000000 IRQMASK: 0 
[   23.913305] GPR00: c000000000366230 c000001fa09d3970 c00000000105b100 c000003c9dcd4cc0 
[   23.913305] GPR04: c000001fb690f2b8 0000000000000000 000000000000ffff c000001fa09d3b90 
[   23.913305] GPR08: 0000000000000000 003ffff800001029 0000000000000001 c000001fa09d3d70 
[   23.913305] GPR12: 0000000000002200 c000001ffffd7880 f000000007e4f6c0 0000000000000c73 
[   23.913305] GPR16: 00007fff88420000 0000000000000c16 c000003c9dcd4cc0 0000000000000c16 
[   23.913305] GPR20: 0000000000000000 c000001fa09d3990 c000001fa09d3b90 0000000000000000 
[   23.913305] GPR24: c000001fb690f2b8 0000000000000000 0000000000000001 0000000000000040 
[   23.913305] GPR28: 0000000000020001 0000000000000000 0000000000000000 0000000000000000 
[   23.913848] NIP [c0000000003663cc] __block_write_begin_int+0x27c/0x770
[   23.913851] LR [c000000000366230] __block_write_begin_int+0xe0/0x770
[   23.913854] Call Trace:
[   23.913987] [c000001fa09d3970] [c000000000366230] __block_write_begin_int+0xe0/0x770 (unreliable)
[   23.914061] [c000001fa09d3a50] [c00000000039df30] iomap_write_begin.constprop.28+0xd0/0x330
[[   23.914128] [  OK  c000001fa09d3ae0] [c00000000039e770] iomap_write_actor+0xd0/0x210
] [   23.914211] [c000001fa09d3b70] [c00000000039e9c0] iomap_apply+0x110/0x1f0
Started Authoriz[   23.914272] [c000001fa09d3c20] [c00000000039eea0] iomap_file_buffered_write+0x90/0x110
ation Manager.
[   23.914374] [c000001fa09d3c70] [d0000000117ae308] xfs_file_buffered_aio_write+0xf8/0x3a0 [xfs]
[   23.914446] [c000001fa09d3d00] [c000000000313cf0] __vfs_write+0x130/0x1e0
[   23.914498] [c000001fa09d3d90] [c000000000313fe8] vfs_write+0xc8/0x240
[   23.914553] [c000001fa09d3de0] [c00000000031435c] ksys_write+0x5c/0x100
[   23.914607] [c000001fa09d3e30] [c00000000000b9e4] system_call+0x5c/0x70
[   23.914657] Instruction dump:
[   23.914690] 79530020 79140020 419cfeec e8ce0008 7dc97378 78c807e1 40c204d4 e9290000 
[   23.914755] 792aefe3 41820160 7c2004ac e8c10030 <e8a60000> 7cc93378 78a807e1 4082ff98 
[   24.208971] ---[ end trace 170e435bc8a2192a ]---
[  OK  ] Started Network Manager.
         Starting Network Manager Script Dispatcher Service...
         [   24.364532] 
Starting Network Manager Wait Online...
[  OK  ] Started Network Manager Script Dispatcher Service.
         Starting Hostname Service...
[  OK  ] Started Hostname Service.
[   27.056446] bnx2x 0008:01:00.0 enP8p1s0f0: using MSI-X  IRQs: sp 483  fp[0] 485 ... fp[7] 508
[   27.285354] bnx2x 0008:01:00.0 enP8p1s0f0: NIC Link is Up, 10000 Mbps full duplex, Flow control: ON - receive & transmit
[   27.896441] bnx2x 0008:01:00.1 enP8p1s0f1: using MSI-X  IRQs: sp 509  fp[0] 454 ... fp[7] 426
[   28.125349] bnx2x 0008:01:00.1 enP8p1s0f1: NIC Link is Up, 10000 Mbps full duplex, Flow control: ON - receive & transmit
[   28.346366] bnx2x 0008:01:00.2 enP8p1s0f2: using MSI-X  IRQs: sp 427  fp[0] 429 ... fp[7] 436
[   28.856305] bnx2x 0008:01:00.3 enP8p1s0f3: using MSI-X  IRQs: sp 437  fp[0] 439 ... fp[7] 446
[   29.057709] tg3 0009:07:00.0 net0: Link is up at 1000 Mbps, full duplex
[   29.057765] tg3 0009:07:00.0 net0: Flow control is on for TX and on for RX
[   29.057814] tg3 0009:07:00.0 net0: EEE is disabled
[***   ] A start job is running for Network ...ger Wait Online (18s / no limit)[   31.755353] bnx2x 0008:01:00.2 enP8p1s0f2: NIC Link is Up, 1000 Mbps full duplex, Flow control: none
[   32.185349] bnx2x 0008:01:00.3 enP8p1s0f3: NIC Link is Up, 1000 Mbps full duplex, Flow control: none
[FAILED] Failed to start Network Manager Wait Online.
See 'systemctl status NetworkManager-wait-online.service' for details.
         Starting LSB: Bring up/down networking...
[  OK  ] Started LSB: Bring up/down networking.
[  OK  ] Reached target Network.
         Starting Logout off all iSCSI sessions on shutdown...
         Starting OpenSSH server daemon...
         Starting Dynamic System Tuning Daemon...
[  OK  ] Reached target Network is Online.
         Starting (null)...
         Starting NFS Mount Daemon...
         Starting NFS status monitor for NFSv2/3 locking....
         Starting Postfix Mail Transport Agent...
[  OK  ] Started Logout off all iSCSI sessions on shutdown.
         Starting Availability of block devices...
[  OK  ] Reached target Remote File Systems (Pre).
[  OK  ] Reached target Remote File Systems.
         Starting Crash recovery kernel arming...
         Starting Virtualization daemon...
         Starting The nginx HTTP and reverse proxy server...
         Starting Permit User Sessions...
[  OK  ] Started OpenSSH server daemon.
[  OK  ] Started Availability of block devices.
[  OK  ] Started Permit User Sessions.
[  OK  ] Started Command Scheduler.
         Starting Command Scheduler...
[  OK  ] Started IBM Performance Management for PowerLinux Systems.
         Starting IBM Performance Management for PowerLinux Systems...
         Starting Wait for Plymouth Boot Screen to Quit...
[  OK  ] Started Job spooling tools.
         Starting Job spooling tools...
         Starting Terminate Plymouth Boot Screen...
[  OK  ] Started Wait for Plymouth Boot Screen to Quit.
[  OK  ] Started Getty on tty1.
         Starting Getty on tty1...
[  OK  ] Started Serial Getty on hvc0.
         Starting Serial Getty on hvc0...
[  OK  ] Reached target Login Prompts.
         Starting RPC bind service...
[FAILED] Failed to start Crash recovery kernel arming.
See 'systemctl status kdump.service' for details.
[  OK  ] Started Terminate Plymouth Boot Screen.
[  OK  ] Started RPC bind service.
[   56.281011] aliasesdb (13368) used greatest stack depth: 9696 bytes left
[  OK  ] Started NFS status monitor for NFSv2/3 locking..
[  OK  ] Started NFS Mount Daemon.
         Starting NFS server and services...
[  OK  ] Started Virtualization daemon.
[  OK  ] Started (null).
[   56.981544] Unable to handle kernel paging request for data at address 0x0000ffff
[   56.981753] Faulting instruction address: 0xc0000000003663cc
[   56.981796] Oops: Kernel access of bad area, sig: 11 [#5]
[   56.981832] LE SMP NR_CPUS=2048 NUMA PowerNV
[   56.981867] Modules linked in: dm_mirror dm_region_hash dm_log dm_service_time vmx_crypto powernv_rng rng_core kvm_hv kvm nfsd dm_multipath binfmt_misc ip_tables x_tables autofs4 xfs lpfc bnx2x crc_t10dif crct10dif_generic nvme_fc nvme_fabrics mdio libcrc32c nvme_core crct10dif_common
[   56.982192] CPU: 10 PID: 13284 Comm: tuned Tainted: G      D W         4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3 #2
[   56.982256] NIP:  c0000000003663cc LR: c000000000366230 CTR: c00000000039e6a0
[   56.982366] REGS: c000001fcfa2b6f0 TRAP: 0300   Tainted: G      D W          (4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3)
[   56.982558] MSR:  9000000000009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 44282424  XER: 20000000
[   56.982613] CFAR: c000000000008934 DAR: 000000000000ffff DSISR: 40000000 IRQMASK: 0 
[   56.982613] GPR00: c000000000366230 c000001fcfa2b970 c00000000105b100 c000003c9dcd0b00 
[   56.982613] GPR04: c000001f8c407f38 0000000000000000 000000000000ffff c000001fcfa2bb90 
[   56.982613] GPR08: 0000000000000000 003ffff800001029 0000000000000001 c000001fcfa2bd70 
[   56.982613] GPR12: 0000000000002200 c000001fffff7980 f000000007eb8800 0000000000009e5d 
[   56.982613] GPR16: 000001000c5246a0 0000000000009dfe c000003c9dcd0b00 0000000000009dfe 
[   56.982613] GPR20: 0000000000000000 c000001fcfa2b990 c000001fcfa2bb90 0000000000000000 
[   56.982613] GPR24: c000001f8c407f38 0000000000000000 0000000000000001 0000000000000040 
[   56.982613] GPR28: 0000000000000001 0000000000000000 0000000000000000 0000000000000000 
[   56.983479] NIP [c0000000003663cc] __block_write_begin_int+0x27c/0x770
[   56.983662] LR [c000000000366230] __block_write_begin_int+0xe0/0x770
[   56.983703] Call Trace:
[   56.983721] [c000001fcfa2b970] [c000000000366230] __block_write_begin_int+0xe0/0x770 (unreliable)
[   56.983911] [c000001fcfa2ba50] [c00000000039df30] iomap_write_begin.constprop.28+0xd0/0x330
[   56.983965] [c000001fcfa2bae0] [c00000000039e770] iomap_write_actor+0xd0/0x210
[   56.984015] [c000001fcfa2bb70] [c00000000039e9c0] iomap_apply+0x110/0x1f0
[   56.984060] [c000001fcfa2bc20] [c00000000039eea0] iomap_file_buffered_write+0x90/0x110
[   56.984135] [c000001fcfa2bc70] [d0000000117ae308] xfs_file_buffered_aio_write+0xf8/0x3a0 [xfs]
[   56.984331] [c000001fcfa2bd00] [c000000000313cf0] __vfs_write+0x130/0x1e0
[   56.984373] [c000001fcfa2bd90] [c000000000313fe8] vfs_write+0xc8/0x240
[   56.984416] [c000001fcfa2bde0] [c00000000031435c] ksys_write+0x5c/0x100
[   56.984461] [c000001fcfa2be30] [c00000000000b9e4] system_call+0x5c/0x70
[   56.984646] Instruction dump:
[   56.984673] 79530020 79140020 419cfeec e8ce0008 7dc97378 78c807e1 40c204d4 e9290000 
[   56.984726] 792aefe3 41820160 7c2004ac e8c10030 <e8a60000> 7cc93378 78a807e1 4082ff98 
[   56.984928] ---[ end trace 170e435bc8a2192b ]---
[   56.989025] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[   57.060585] NFSD: starting 45-second grace period (net f000001f)
[  OK  ] Started NFS server and services.
[   57.136252] 
         Starting Notify NFS peers of a restart...
[FAILED] Failed to start Dynamic System Tuning Daemon.
See 'systemctl status tuned.service' for details.
[  OK  ] Started Notify NFS peers of a restart.
[   57.561652] Unable to handle kernel paging request for data at address 0xd000001ff5c31208
[   57.561908] Faulting instruction address: 0xd000000011fa1a84
[   57.562110] Oops: Kernel access of bad area, sig: 11 [#6]
[   57.562152] LE SMP NR_CPUS=2048 NUMA PowerNV
[   57.562197] Modules linked in: iptable_filter dm_mirror dm_region_hash dm_log dm_service_time vmx_crypto powernv_rng rng_core kvm_hv kvm nfsd dm_multipath binfmt_misc ip_tables x_tables autofs4 xfs lpfc bnx2x crc_t10dif crct10dif_generic nvme_fc nvme_fabrics mdio libcrc32c nvme_core crct10dif_common
[   57.562567] CPU: 17 PID: 13522 Comm: iptables Tainted: G      D W         4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3 #2
[   57.562842] NIP:  d000000011fa1a84 LR: d000000011fa19ac CTR: c0000000009d18d0
[   57.562973] REGS: c0000000029cf8a0 TRAP: 0300   Tainted: G      D W          (4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3)
[   57.563145] MSR:  9000000000009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 84008884  XER: 20000000
[   57.563362] CFAR: d000000011fa19f4 DAR: d000001ff5c31208 DSISR: 40000000 IRQMASK: 0 
[   57.563362] GPR00: d000000011fa19ac c0000000029cfb20 d000000011fac900 0000000000000000 
[   57.563362] GPR04: 0000000000000800 0000000000000000 000000005b22018e 0000000000000001 
[   57.563362] GPR08: ffffffffffffffff c000000000d9b000 c000001ff5c3b000 d000000011fa3bd8 
[   57.563362] GPR12: c0000000009d18d0 c000001fffff1b00 0000000000000000 0000000010014f80 
[   57.563362] GPR16: 00000100349c0010 00007fff857604f0 00007fffecc4ab28 0000000000000000 
[   57.563362] GPR20: 0000000000000003 c000000001091ee0 c000001fd48ca040 0000000000000000 
[   57.563362] GPR24: c00000000108db70 0000000000000000 c000000001092214 d000001ff5c31208 
[   57.563362] GPR28: c000001fd48ca000 d00000001a5e0000 0000000000000000 c000001fd48ca040 
[   57.564646] NIP [d000000011fa1a84] alloc_counters.isra.11+0x164/0x200 [ip_tables]
[   57.564706] LR [d000000011fa19ac] alloc_counters.isra.11+0x8c/0x200 [ip_tables]
[   57.564947] Call Trace:
[   57.564971] [c0000000029cfb20] [d000000011fa19ac] alloc_counters.isra.11+0x8c/0x200 [ip_tables] (unreliable)
[   57.565204] [c0000000029cfba0] [d000000011fa2108] do_ipt_get_ctl+0x258/0x390 [ip_tables]
[   57.565266] [c0000000029cfc80] [c0000000008f79e0] nf_getsockopt+0x80/0xc0
[   57.565469] [c0000000029cfcd0] [c000000000907a68] ip_getsockopt+0xc8/0x150
[   57.565521] [c0000000029cfd30] [c000000000939030] raw_getsockopt+0x40/0x80
[   57.565724] [c0000000029cfd50] [c00000000087b80c] sock_common_getsockopt+0x2c/0x40
[   57.565785] [c0000000029cfd70] [c000000000878494] __sys_getsockopt+0x84/0xf0
[   57.566004] [c0000000029cfdd0] [c00000000087b1d8] sys_socketcall+0x1f8/0x370
[   57.566065] [c0000000029cfe30] [c00000000000b9e4] system_call+0x5c/0x70
[   57.566270] Instruction dump:
[   57.566301] 39290040 7fff5214 7d3c4a14 7fbf4840 409cff3c 813a0000 2b890001 395f0060 
[   57.566515] 409d0010 7d58c82a e93f0060 7d495214 <813b0000> 792807e1 41e2ff74 7c210b78 
[   57.566581] ---[ end trace 170e435bc8a2192c ]---
[   57.727659] 
[FAILED] Failed to start The nginx HTTP and reverse proxy server.
See 'systemctl status nginx.service' for details.
[  OK  ] Started Wok - Webserver Originated from Kimchi.
         Starting Wok - Webserver Originated from Kimchi...
[   57.769018] Unable to handle kernel paging request for data at address 0xd000003ff4c31208
[   57.769273] Faulting instruction address: 0xd000000011fa02d0
[   57.769490] Oops: Kernel access of bad area, sig: 11 [#7]
[   57.769532] LE SMP NR_CPUS=2048 NUMA PowerNV
[   57.769578] Modules linked in: iptable_filter dm_mirror dm_region_hash dm_log dm_service_time vmx_crypto powernv_rng rng_core kvm_hv kvm nfsd dm_multipath binfmt_misc ip_tables x_tables autofs4 xfs lpfc bnx2x crc_t10dif crct10dif_generic nvme_fc nvme_fabrics mdio libcrc32c nvme_core crct10dif_common
[   57.770083] CPU: 80 PID: 0 Comm: swapper/80 Tainted: G      D W         4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3 #2
[   57.770252] NIP:  d000000011fa02d0 LR: d00000001a5a0088 CTR: d000000011fa01f0
[   57.770482] REGS: c000003fff70f640 TRAP: 0300   Tainted: G      D W          (4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3)
[   57.770727] MSR:  9000000000009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 42004022  XER: 20000000
[   57.770878] CFAR: d000000011fa06ec DAR: d000003ff4c31208 DSISR: 40000000 IRQMASK: 0 
[   57.770878] GPR00: d00000001a5a0088 c000003fff70f8c0 d000000011fac900 c000003c960f0c00 
[   57.770878] GPR04: c000003fff70fa10 c000001fe91d07e0 0000000000000002 0000000000000002 
[   57.770878] GPR08: 0000003ff3ea0000 d000000000d91208 0000000000000300 d00000001a5a0328 
[   57.770878] GPR12: d000000011fa01f0 c000003fff7ff300 c000003c96181200 0000000000010000 
[   57.770878] GPR16: 0000000000000000 0000000000000059 c000003c9ab83410 c000003c960f0c00 
[   57.770878] GPR20: 0000000000000001 0000000000000059 0000000000000040 d000000000d91208 
[   57.770878] GPR24: 000000000000077a 0000000000000000 c000001fb7d72b80 d000000011fa4f80 
[   57.770878] GPR28: c000003c96180000 c000003c960f0c00 c000001fe9320380 0000000000000000 
[   57.772095] NIP [d000000011fa02d0] ipt_do_table+0xe0/0x540 [ip_tables]
[   57.772307] LR [d00000001a5a0088] iptable_filter_hook+0x28/0x40 [iptable_filter]
[   57.772370] Call Trace:
[   57.772394] [c000003fff70f8c0] [c000003fff70f960] 0xc000003fff70f960 (unreliable)
[   57.772622] [c000003fff70f980] [d00000001a5a0088] iptable_filter_hook+0x28/0x40 [iptable_filter]
[   57.772697] [c000003fff70f9a0] [c0000000008f5238] nf_hook_slow+0x68/0x140
[   57.772933] [c000003fff70f9f0] [c0000000008ff1ec] ip_local_deliver+0xcc/0x130
[   57.773158] [c000003fff70fa50] [c0000000008febe8] ip_rcv_finish+0x58/0x80
[   57.773213] [c000003fff70fa80] [c0000000008ff29c] ip_rcv+0x4c/0x110
[   57.773426] [c000003fff70faf0] [c00000000089e4c0] __netif_receive_skb_one_core+0x60/0x80
[   57.773489] [c000003fff70fb30] [c0000000008a6970] netif_receive_skb_internal+0x30/0x110
[   57.773719] [c000003fff70fb70] [c0000000008a7c3c] napi_gro_receive+0x11c/0x1c0
[   57.773945] [c000003fff70fbb0] [c000000000702bfc] tg3_poll_work+0x5fc/0x1060
[   57.774010] [c000003fff70fcb0] [c0000000007036b4] tg3_poll_msix+0x54/0x210
[   57.774216] [c000003fff70fd00] [c0000000008a728c] net_rx_action+0x31c/0x490
[   57.774272] [c000003fff70fe10] [c0000000009f4b4c] __do_softirq+0x15c/0x3b4
[   57.774481] [c000003fff70ff00] [c0000000000fabf8] irq_exit+0xf8/0x110
[   57.774536] [c000003fff70ff20] [c000000000016fb8] __do_irq+0x98/0x200
[   57.774756] [c000003fff70ff90] [c000000000028964] call_do_irq+0x14/0x24
[   57.774812] [c000003ca947fa50] [c0000000000171b4] do_IRQ+0x94/0x110
[   57.775027] [c000003ca947faa0] [c000000000008db8] hardware_interrupt_common+0x158/0x160
[   57.775095] --- interrupt: 501 at replay_interrupt_return+0x0/0x4
[   57.775095]     LR = arch_local_irq_restore+0x74/0x90
[   57.775361] [c000003ca947fd90] [c00000000083ed0c] menu_select+0x7c/0x790 (unreliable)
[   57.775583] [c000003ca947fdb0] [c00000000083ccd8] cpuidle_enter_state+0x108/0x3c0
[   57.775645] [c000003ca947fe10] [c0000000001336e4] call_cpuidle+0x44/0x80
[   57.775862] [c000003ca947fe30] [c000000000133c78] do_idle+0x2f8/0x3a0
[   57.775917] [c000003ca947fec0] [c000000000133ef4] cpu_startup_entry+0x34/0x40
[   57.776154] [c000003ca947fef0] [c000000000044024] start_secondary+0x4d4/0x520
[   57.776366] [c000003ca947ff90] [c00000000000b270] start_secondary_prolog+0x10/0x14
[   57.776428] Instruction dump:
[   57.776462] f8810030 554a16ba 9141003c 0b090000 78290464 8149000c 394a0200 9149000c 
[   57.776683] e90d0030 3ee20000 eaf78008 7ee9bb78 <7ce9402e> 3b070001 571807fe 7ce7c214 
[   57.776754] ---[ end trace 170e435bc8a2192d ]---
[   57.935316] 
[   57.995582] Unable to handle kernel paging request for data at address 0xd000001ff6a71208
[   57.995852] Faulting instruction address: 0xd000000011fa02d0
[   57.995904] Oops: Kernel access of bad area, sig: 11 [#8]
[   57.995946] LE SMP NR_CPUS=2048 NUMA PowerNV
[   57.995991] Modules linked in: iptable_filter dm_mirror dm_region_hash dm_log dm_service_time vmx_crypto powernv_rng rng_core kvm_hv kvm nfsd dm_multipath binfmt_misc ip_tables x_tables autofs4 xfs lpfc bnx2x crc_t10dif crct10dif_generic nvme_fc nvme_fabrics mdio libcrc32c nvme_core crct10dif_common
[   57.996362] CPU: 57 PID: 13579 Comm: chronyd Tainted: G      D W         4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3 #2
[   57.996453] NIP:  d000000011fa02d0 LR: d00000001a5a0088 CTR: d000000011fa01f0
[   57.996514] REGS: c000001fce8d7400 TRAP: 0300   Tainted: G      D W          (4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3)
[   57.996603] MSR:  9000000000009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 48242428  XER: 00000000
[   57.996671] CFAR: d000000011fa06e0 DAR: d000001ff6a71208 DSISR: 40000000 IRQMASK: 0 
[   57.996671] GPR00: d00000001a5a0088 c000001fce8d7680 d000000011fac900 c000001fd5d44d00 
[   57.996671] GPR04: c000001fce8d77d0 c000001fe91d07e0 0000000000000008 0000000000000008 
[   57.996671] GPR08: 0000001ff5ce0000 d000000000d91208 0000000000000200 d00000001a5a0328 
[   57.996671] GPR12: d000000011fa01f0 c000001ffffcff00 00007fffa62dc390 0000000000000000 
[   57.996671] GPR16: 000000000100007f 000000000100007f c000001fd844bc10 0000000000003500 
[   57.996671] GPR20: 0000000000000003 c000001fb5ff2b80 c000001fb5ff2b80 d000000000d91208 
[   57.996671] GPR24: 000000000100007f 0000000000000027 0000000000000000 c000001ff4198000 
[   57.996671] GPR28: d000000011fa4f80 c000001fd5d44d00 c000001fe9320680 0000000000000000 
[   57.997219] NIP [d000000011fa02d0] ipt_do_table+0xe0/0x540 [ip_tables]
[   57.997271] LR [d00000001a5a0088] iptable_filter_hook+0x28/0x40 [iptable_filter]
[   57.997333] Call Trace:
[   57.997358] [c000001fce8d7680] [c000000000903c80] ip_generic_getfrag+0xc0/0xe0 (unreliable)
[   57.997421] [c000001fce8d7740] [d00000001a5a0088] iptable_filter_hook+0x28/0x40 [iptable_filter]
[   57.997493] [c000001fce8d7760] [c0000000008f5238] nf_hook_slow+0x68/0x140
[   57.997545] [c000001fce8d77b0] [c000000000904dec] __ip_local_out+0xdc/0x130
[   57.997598] [c000001fce8d7820] [c000000000904e70] ip_local_out+0x30/0x80
[   57.997651] [c000001fce8d7860] [c00000000090666c] ip_send_skb+0x2c/0xb0
[   57.997703] [c000001fce8d7890] [c00000000093e338] udp_send_skb.isra.39+0x168/0x4b0
[   57.997765] [c000001fce8d78e0] [c00000000093ec48] udp_sendmsg+0x518/0x950
[   57.997818] [c000001fce8d7ac0] [c00000000094c4a4] inet_sendmsg+0x54/0x110
[   57.997871] [c000001fce8d7b00] [c0000000008774ec] sock_sendmsg+0x2c/0x60
[   57.997923] [c000001fce8d7b20] [c00000000087917c] ___sys_sendmsg+0x21c/0x320
[   57.997985] [c000001fce8d7cb0] [c00000000087a8b8] __sys_sendmmsg+0xd8/0x250
[   57.998037] [c000001fce8d7e10] [c00000000087aa58] sys_sendmmsg+0x28/0x40
[   57.998093] [c000001fce8d7e30] [c00000000000b9e4] system_call+0x5c/0x70
[   57.998144] Instruction dump:
[   57.998176] f8810030 554a16ba 9141003c 0b090000 78290464 8149000c 394a0200 9149000c 
[   57.998243] e90d0030 3ee20000 eaf78008 7ee9bb78 <7ce9402e> 3b070001 571807fe 7ce7c214 
[   57.998310] ---[ end trace 170e435bc8a2192e ]---
[   58.149518] 
[   58.415391] Unable to handle kernel paging request for data at address 0xd000001ff6d71208
[   58.415640] Faulting instruction address: 0xd000000011fa02d0
[   58.415842] Oops: Kernel access of bad area, sig: 11 [#9]
[   58.415882] LE SMP NR_CPUS=2048 NUMA PowerNV
[   58.415926] Modules linked in: iptable_filter dm_mirror dm_region_hash dm_log dm_service_time vmx_crypto powernv_rng rng_core kvm_hv kvm nfsd dm_multipath binfmt_misc ip_tables x_tables autofs4 xfs lpfc bnx2x crc_t10dif crct10dif_generic nvme_fc nvme_fabrics mdio libcrc32c nvme_core crct10dif_common
[   58.416299] CPU: 69 PID: 0 Comm: swapper/69 Tainted: G      D W         4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3 #2
[   58.416533] NIP:  d000000011fa02d0 LR: d00000001a5a0088 CTR: d000000011fa01f0
[   58.416594] REGS: c000001fed737160 TRAP: 0300   Tainted: G      D W          (4.18.0-rc4-next-20180712-autotest-00001-g3ec3df3)
[   58.416878] MSR:  9000000000009033 <SF,HV,EE,ME,IR,DR,RI,LE>  CR: 42004022  XER: 20000000
[   58.416946] CFAR: d000000011fa06ec DAR: d000001ff6d71208 DSISR: 40000000 IRQMASK: 0 
[   58.416946] GPR00: d00000001a5a0088 c000001fed7373e0 d000000011fac900 c000001fcd3dfe00 
[   58.416946] GPR04: c000001fed737530 c000001fe91d07e0 0000000000000002 0000000000000002 
[   58.416946] GPR08: 0000001ff5fe0000 d000000000d91208 0000000000000300 d00000001a5a0328 
[   58.416946] GPR12: d000000011fa01f0 c000001ffffc5d00 c000003c96180c00 0000000000010000 
[   58.416946] GPR16: 0000000000000000 00000000000000f5 c000001fa2a00390 c000001fcd3dfe00 
[   58.416946] GPR20: 0000000000000001 00000000000000f5 0000000000000036 d000000000d91208 
[   58.416946] GPR24: 00000000000007a3 0000000000000000 c000001fb4b5cd00 d000000011fa4f80 
[   58.416946] GPR28: c000003c96180000 c000001fcd3dfe00 c000001fe9320380 0000000000000000 
[   58.417496] NIP [d000000011fa02d0] ipt_do_table+0xe0/0x540 [ip_tables]
[   58.417550] LR [d00000001a5a0088] iptable_filter_hook+0x28/0x40 [iptable_filter]
[   58.417609] Call Trace:
[   58.417633] [c000001fed7374a0] [d00000001a5a0088] iptable_filter_hook+0x28/0x40 [iptable_filter]
[   58.417704] [c000001fed7374c0] [c0000000008f5238] nf_hook_slow+0x68/0x140
[   58.417756] [c000001fed737510] [c0000000008ff1ec] ip_local_deliver+0xcc/0x130
[   58.417822] [c000001fed737570] [c0000000008febe8] ip_rcv_finish+0x58/0x80
[   58.417874] [c000001fed7375a0] [c0000000008ff29c] ip_rcv+0x4c/0x110
[   58.417927] [c000001fed737610] [c00000000089e4c0] __netif_receive_skb_one_core+0x60/0x80
[   58.417989] [c000001fed737650] [c0000000008a6970] netif_receive_skb_internal+0x30/0x110
[   58.418051] [c000001fed737690] [c0000000008a7c3c] napi_gro_receive+0x11c/0x1c0
[   58.418114] [c000001fed7376d0] [c000000000702bfc] tg3_poll_work+0x5fc/0x1060
[   58.418179] [c000001fed7377d0] [c0000000007036b4] tg3_poll_msix+0x54/0x210
[   58.418231] [c000001fed737820] [c0000000008a728c] net_rx_action+0x31c/0x490
[   58.418286] [c000001fed737930] [c0000000009f4b4c] __do_softirq+0x15c/0x3b4
[   58.418339] [c000001fed737a20] [c0000000000fabf8] irq_exit+0xf8/0x110
[   58.418391] [c000001fed737a40] [c0000000000230b8] timer_interrupt+0x128/0x2e0
[   58.418453] [c000001fed737aa0] [c000000000009398] decrementer_common+0x158/0x160
[   58.418517] --- interrupt: 901 at replay_interrupt_return+0x0/0x4
[   58.418517]     LR = arch_local_irq_restore+0x74/0x90
[   58.418598] [c000001fed737d90] [c00000000083ed0c] menu_select+0x7c/0x790 (unreliable)
[   58.418660] [c000001fed737db0] [c00000000083ccd8] cpuidle_enter_state+0x108/0x3c0
[   58.418723] [c000001fed737e10] [c0000000001336e4] call_cpuidle+0x44/0x80
[   58.418775] [c000001fed737e30] [c000000000133c78] do_idle+0x2f8/0x3a0
[   58.418827] [c000001fed737ec0] [c000000000133ef4] cpu_startup_entry+0x34/0x40
[   58.418888] [c000001fed737ef0] [c000000000044024] start_secondary+0x4d4/0x520
[   58.418949] [c000001fed737f90] [c00000000000b270] start_secondary_prolog+0x10/0x14
[   58.419009] Instruction dump:
[   58.419042] f8810030 554a16ba 9141003c 0b090000 78290464 8149000c 394a0200 9149000c 
[   58.419108] e90d0030 3ee20000 eaf78008 7ee9bb78 <7ce9402e> 3b070001 571807fe 7ce7c214 
[   58.419178] ---[ end trace 170e435bc8a2192f ]---
[   58.570980] 
[   58.935398] Kernel panic - not syncing: Fatal exception in interrupt
[   60.133284] Rebooting in 10 seconds..
[ 4591.064629377,5] OPAL: Reboot request...
  3.27626|Ignoring boot flags, incorrect version 0x0
  3.34487|ISTEP  6. 3


--=-gZT1PxkJfh1DZnpqjXDy--
