Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DBEF46B04F2
	for <linux-mm@kvack.org>; Thu, 17 May 2018 09:58:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w7-v6so2770504pfd.9
        for <linux-mm@kvack.org>; Thu, 17 May 2018 06:58:45 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b6-v6si4132228pgc.166.2018.05.17.06.58.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 06:58:40 -0700 (PDT)
Date: Thu, 17 May 2018 16:58:32 +0300
From: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
Message-ID: <20180517135832.GI23723@intel.com>
References: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
 <20180517132109.GU12670@dhcp22.suse.cz>
 <20180517133629.GH23723@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180517133629.GH23723@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 17, 2018 at 04:36:29PM +0300, Ville Syrjala wrote:
> On Thu, May 17, 2018 at 03:21:09PM +0200, Michal Hocko wrote:
> > On Thu 17-05-18 15:59:59, Ville Syrjala wrote:
> > > From: Ville Syrjala <ville.syrjala@linux.intel.com>
> > > 
> > > This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.
> > > 
> > > Make x86 with HIGHMEM=y and CMA=y boot again.
> > 
> > Is there any bug report with some more details? It is much more
> > preferable to fix the issue rather than to revert the whole thing
> > right away.
> 
> The machine I have in front of me right now didn't give me anything.
> Black screen, and netconsole was silent. No serial port on this
> machine unfortunately.

Booted on another machine with serial:

[    0.000000] Linux version 4.17.0-rc5-elk+ () (gcc version 6.4.0 (Gentoo 6.4.0-r1 p1.3)) #145 SMP Thu May 17 16:48:20 EEST 2018
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009abff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009ac00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000db65efff] usable
[    0.000000] BIOS-e820: [mem 0x00000000db65f000-0x00000000db67efff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000db67f000-0x00000000db76efff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000db76f000-0x00000000dbffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000dde00000-0x00000000dfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed10000-0x00000000fed13fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed18000-0x00000000fed19fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ff800000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x0000000117ffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.6 present.
[    0.000000] DMI: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] e820: last_pfn = 0x118000 max_arch_pfn = 0x1000000
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT  
[    0.000000] RAMDISK: [mem 0x37e58000-0x37feffff]
[    0.000000] Allocated new RAMDISK: [mem 0x37666000-0x377fd7ff]
[    0.000000] Move RAMDISK from [mem 0x37e58000-0x37fef7ff] to [mem 0x37666000-0x377fd7ff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000FE300 000024 (v02 DELL  )
[    0.000000] ACPI: XSDT 0x00000000DB67DE18 000064 (v01 DELL   E2       06222004 MSFT 00010013)
[    0.000000] ACPI: FACP 0x00000000DB75FC18 0000F4 (v04 DELL   E2       06222004 MSFT 00010013)
[    0.000000] ACPI: DSDT 0x00000000DB74E018 00A1BB (v01 DELL   E2       00001001 INTL 20080729)
[    0.000000] ACPI: FACS 0x00000000DB76BF40 000040
[    0.000000] ACPI: FACS 0x00000000DB76ED40 000040
[    0.000000] ACPI: APIC 0x00000000DB67CF18 00008C (v02 DELL   E2       06222004 MSFT 00010013)
[    0.000000] ACPI: MCFG 0x00000000DB76DD18 00003C (v01 A M I  GMCH945. 06222004 MSFT 00000097)
[    0.000000] ACPI: TCPA 0x00000000DB76DC98 000032 (v02                 00000000      00000000)
[    0.000000] ACPI: HPET 0x00000000DB76DC18 000038 (v01 DELL   E2       00000001 ASL  00000061)
[    0.000000] ACPI: BOOT 0x00000000DB76DB98 000028 (v01 DELL   E2       06222004 AMI  00010013)
[    0.000000] ACPI: SLIC 0x00000000DB766818 000176 (v03 DELL   E2       06222004 MSFT 00010013)
[    0.000000] ACPI: SSDT 0x00000000DB75D018 0009F1 (v01 PmRef  CpuPm    00003000 INTL 20080729)
[    0.000000] 3592MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000] cma: Reserved 4 MiB at 0x0000000037000000
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   Normal   [mem 0x0000000001000000-0x00000000377fdfff]
[    0.000000]   HighMem  [mem 0x00000000377fe000-0x0000000117ffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x0000000000099fff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000db65efff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x0000000117ffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000117ffffff]
[    0.000000] Reserved but unavailable: 103 pages
[    0.000000] Using APIC driver default
[    0.000000] Reserving Intel graphics memory at [mem 0xde000000-0xdfffffff]
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] smpboot: 8 Processors exceeds NR_CPUS limit of 4
[    0.000000] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009a000-0x0009afff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009b000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] e820: [mem 0xe0000000-0xf7ffffff] available for PCI devices
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370452778343963 ns
[    0.000000] setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] percpu: Embedded 29 pages/cpu @(ptrval) s89256 r0 d29528 u118784
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 995080
[    0.000000] Kernel command line: drm.debug=0xe modprobe.blacklist=i915,snd_hda_intel i915.enable_fbc=1 console=ttyS0,115200 init=/bin/bash
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] microcode: microcode updated early to revision 0x4, date = 2013-06-28
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (000377fe:00118000)
[    0.000000] Initializing Movable for node 0 (00000001:00118000)
[    0.000000] BUG: Bad page state in process swapper  pfn:377fe
[    0.000000] page:f53effc0 count:0 mapcount:-127 mapping:00000000 index:0x0
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000000 ffffff80 00000000 00000100 00000200 00000001
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] Disabling lock debugging due to kernel taint
[    0.000000] BUG: Bad page state in process swapper  pfn:37800
[    0.000000] page:f53f0000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:37c00
[    0.000000] page:f53f8000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:38000
[    0.000000] page:f5400000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:38400
[    0.000000] page:f5408000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:38800
[    0.000000] page:f5410000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:38c00
[    0.000000] page:f5418000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:39000
[    0.000000] page:f5420000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:39400
[    0.000000] page:f5428000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:39800
[    0.000000] page:f5430000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:39c00
[    0.000000] page:f5438000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3a000
[    0.000000] page:f5440000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3a400
[    0.000000] page:f5448000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3a800
[    0.000000] page:f5450000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3ac00
[    0.000000] page:f5458000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3b000
[    0.000000] page:f5460000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3b400
[    0.000000] page:f5468000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3b800
[    0.000000] page:f5470000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3bc00
[    0.000000] page:f5478000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3c000
[    0.000000] page:f5480000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3c400
[    0.000000] page:f5488000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3c800
[    0.000000] page:f5490000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3cc00
[    0.000000] page:f5498000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3d000
[    0.000000] page:f54a0000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3d400
[    0.000000] page:f54a8000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3d800
[    0.000000] page:f54b0000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3dc00
[    0.000000] page:f54b8000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3e000
[    0.000000] page:f54c0000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3e400
[    0.000000] page:f54c8000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3e800
[    0.000000] page:f54d0000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3ec00
[    0.000000] page:f54d8000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3f000
[    0.000000] page:f54e0000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3f400
[    0.000000] page:f54e8000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3f800
[    0.000000] page:f54f0000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:3fc00
[    0.000000] page:f54f8000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:40000
[    0.000000] page:f5500000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:40400
[    0.000000] page:f5508000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:40800
[    0.000000] page:f5510000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:40c00
[    0.000000] page:f5518000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:41000
[    0.000000] page:f5520000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:41400
[    0.000000] page:f5528000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:41800
[    0.000000] page:f5530000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:41c00
[    0.000000] page:f5538000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:42000
[    0.000000] page:f5540000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:42400
[    0.000000] page:f5548000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:42800
[    0.000000] page:f5550000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:42c00
[    0.000000] page:f5558000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:43000
[    0.000000] page:f5560000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:43400
[    0.000000] page:f5568000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:43800
[    0.000000] page:f5570000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:43c00
[    0.000000] page:f5578000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:44000
[    0.000000] page:f5580000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:44400
[    0.000000] page:f5588000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:44800
[    0.000000] page:f5590000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:44c00
[    0.000000] page:f5598000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:45000
[    0.000000] page:f55a0000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:45400
[    0.000000] page:f55a8000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:45800
[    0.000000] page:f55b0000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:45c00
[    0.000000] page:f55b8000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] BUG: Bad page state in process swapper  pfn:46000
[    0.000000] page:f55c0000 count:0 mapcount:-127 mapping:00000000 index:0x1
[    0.000000] flags: 0x80000000()
[    0.000000] raw: 80000000 00000000 00000001 ffffff80 00000000 00000100 00000200 0000000a
[    0.000000] page dumped because: nonzero mapcount
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.000000] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.000000] Call Trace:
[    0.000000]  dump_stack+0x60/0x96
[    0.000000]  bad_page+0x9a/0x100
[    0.000000]  free_pages_check_bad+0x3f/0x60
[    0.000000]  free_pcppages_bulk+0x29d/0x5b0
[    0.000000]  free_unref_page_commit+0x84/0xb0
[    0.000000]  free_unref_page+0x3e/0x70
[    0.000000]  __free_pages+0x1d/0x20
[    0.000000]  free_highmem_page+0x19/0x40
[    0.000000]  add_highpages_with_active_regions+0xab/0xeb
[    0.000000]  set_highmem_pages_init+0x66/0x73
[    0.000000]  mem_init+0x1b/0x1d7
[    0.000000]  start_kernel+0x17a/0x363
[    0.000000]  i386_start_kernel+0x95/0x99
[    0.000000]  startup_32_smp+0x164/0x168
[    0.000000] Memory: 7001976K/3987424K available (5254K kernel code, 561K rwdata, 2156K rodata, 572K init, 9308K bss, 4291097664K reserved, 4096K cma-reserved, 7005012K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff68000 - 0xfffff000   ( 604 kB)
[    0.000000]   cpu_entry : 0xffa00000 - 0xffa9d000   ( 628 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffa00000   (2048 kB)
[    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000000]       .init : 0xc17de000 - 0xc186d000   ( 572 kB)
[    0.000000]       .data : 0xc152193c - 0xc17cd6c0   (2735 kB)
[    0.000000]       .text : 0xc1000000 - 0xc152193c   (5254 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] Running RCU self tests
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU lockdep checking is enabled.
[    0.000000] NR_IRQS: 2304, nr_irqs: 456, preallocated irqs: 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      131072
[    0.000000] ... CHAINHASH_SIZE:          65536
[    0.000000]  memory used by lock dependency info: 5935 kB
[    0.000000]  per task-struct memory footprint: 1344 bytes
[    0.000000] ACPI: Core revision 20180313
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484882848 ns
[    0.000000] APIC: Switch to symmetric I/O mode setup
[    0.003333] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.006666] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=0 pin2=0
[    0.023333] tsc: Fast TSC calibration using PIT
[    0.026666] tsc: Detected 2659.858 MHz processor
[    0.029999] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x26571dc5c81, max_idle_ns: 440795302576 ns
[    0.033336] Calibrating delay loop (skipped), value calculated using timer frequency.. 5321.37 BogoMIPS (lpj=8866193)
[    0.036668] pid_max: default: 32768 minimum: 301
[    0.040031] Security Framework initialized
[    0.043349] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.046670] Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.053413] CPU: Physical Processor ID: 0
[    0.056668] CPU: Processor Core ID: 0
[    0.060007] mce: CPU supports 9 MCE banks
[    0.063346] process: using mwait in idle threads
[    0.066673] Last level iTLB entries: 4KB 512, 2MB 7, 4MB 7
[    0.070001] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
[    0.073336] Spectre V2 : Vulnerable: Minimal generic ASM retpoline
[    0.076668] Spectre V2 : Spectre v2 mitigation: Filling RSB on context switch
[    0.080072] Freeing SMP alternatives memory: 20K
[    0.089999] smpboot: CPU0: Intel(R) Core(TM) i5 CPU       M 560  @ 2.67GHz (family: 0x6, model: 0x25, stepping: 0x5)
[    0.090102] Performance Events: PEBS fmt1+, Westmere events, 16-deep LBR, Intel PMU driver.
[    0.093336] core: CPUID marked event: 'bus cycles' unavailable
[    0.096673] ... version:                3
[    0.100001] ... bit width:              48
[    0.103334] ... generic registers:      4
[    0.106668] ... value mask:             0000ffffffffffff
[    0.110001] ... max period:             000000007fffffff
[    0.113334] ... fixed-purpose events:   3
[    0.116668] ... event mask:             000000070000000f
[    0.120048] Hierarchical SRCU implementation.
[    0.123725] NMI watchdog: Enabled. Permanently consumes one hw-PMU counter.
[    0.126684] smp: Bringing up secondary CPUs ...
[    0.130171] x86: Booting SMP configuration:
[    0.133339] .... node  #0, CPUs:      #1
[    0.003333] Initializing CPU#1
[    0.143506]  #2
[    0.003333] Initializing CPU#2
[    0.150189]  #3
[    0.003333] Initializing CPU#3
[    0.158727] smp: Brought up 1 node, 4 CPUs
[    0.160004] smpboot: Max logical packages: 1
[    0.163336] smpboot: Total of 4 processors activated (21287.48 BogoMIPS)
[    0.168526] devtmpfs: initialized
[    0.170233] Built 1 zonelists, mobility grouping on.  Total pages: 1964269
[    0.173444] random: get_random_u32 called from bucket_table_alloc+0x71/0x190 with crng_init=0
[    0.176711] PM: Registering ACPI NVS region [mem 0xdb67f000-0xdb76efff] (983040 bytes)
[    0.180048] reboot: Dell Latitude E5410 series board detected. Selecting PCI-method for reboots.
[    0.183434] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370867519511994 ns
[    0.186675] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    0.190106] RTC time: 13:50:29, date: 05/17/18
[    0.193431] NET: Registered protocol family 16
[    0.196815] audit: initializing netlink subsys (disabled)
[    0.200014] audit: type=2000 audit(1526565022.199:1): state=initialized audit_enabled=0 res=1
[    0.210007] cpuidle: using governor menu
[    0.213386] Simple Boot Flag at 0xf1 set to 0x1
[    0.216683] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    0.226669] ACPI: bus type PCI registered
[    0.230002] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.236725] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.246671] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
[    0.253335] PCI: Using MMCONFIG for extended config space
[    0.256668] PCI: Using configuration type 1 for base access
[    0.264553] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.270029] BUG: unable to handle kernel NULL pointer dereference at 00000104
[    0.276669] *pdpt = 0000000000000000 *pde = f000c520f000c500 
[    0.283337] Oops: 0002 [#1] SMP
[    0.286668] Modules linked in:
[    0.286668] CPU: 3 PID: 30 Comm: kworker/3:0 Tainted: G    B             4.17.0-rc5-elk+ #145
[    0.286668] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.303335] Workqueue: events pcpu_balance_workfn
[    0.303335] EIP: get_page_from_freelist+0x91f/0x1290
[    0.303335] EFLAGS: 00210086 CPU: 3
[    0.303335] EAX: 00000034 EBX: 00000100 ECX: 00000001 EDX: 00000200
[    0.303335] ESI: f53effd4 EDI: c17c03c0 EBP: f49e9df0 ESP: f49e9d80
[    0.303335]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[    0.336668] CR0: 80050033 CR2: 00000104 CR3: 01875000 CR4: 000006f0
[    0.336668] Call Trace:
[    0.336668]  __alloc_pages_nodemask+0xdb/0x1050
[    0.336668]  ? __kmalloc+0x30f/0x640
[    0.336668]  ? __kmalloc+0x352/0x640
[    0.336668]  ? __kmalloc+0x1c1/0x640
[    0.336668]  ? pcpu_mem_zalloc+0x5c/0x80
[    0.336668]  pcpu_populate_chunk+0x9d/0x2d0
[    0.336668]  pcpu_balance_workfn+0x315/0x620
[    0.336668]  ? process_one_work+0x1a3/0x5d0
[    0.336668]  process_one_work+0x21a/0x5d0
[    0.336668]  worker_thread+0x37/0x420
[    0.336668]  kthread+0xda/0x110
[    0.336668]  ? rescuer_thread+0x320/0x320
[    0.336668]  ? _kthread_create_worker_on_cpu+0x20/0x20
[    0.396674]  ret_from_fork+0x2e/0x38
[    0.400003] Code: 8b 5d ac 8d 14 03 03 55 e0 8b 1a 39 d3 0f 84 21 02 00 00 89 de 83 ee 14 89 75 e8 0f 84 13 02 00 00 89 de 89 5d b4 8b 1b 8b 56 04 <89> 53 04 89 1a 6b d1 34 c7 06 00 01 00 00 c7 46 04 00 02 00 00 
[    0.410004] EIP: get_page_from_freelist+0x91f/0x1290 SS:ESP: 0068:f49e9d80
[    0.426671] CR2: 0000000000000104
[    0.426671] ---[ end trace 7c42ade3a7e8517d ]---
[    0.426671] BUG: sleeping function called from invalid context at ../include/linux/percpu-rwsem.h:34
[    0.426671] in_atomic(): 1, irqs_disabled(): 1, pid: 30, name: kworker/3:0
[    0.426671] INFO: lockdep is turned off.
[    0.426671] irq event stamp: 0
[    0.426671] hardirqs last  enabled at (0): [<00000000>]   (null)
[    0.460004] hardirqs last disabled at (0): [<c104fa4c>] copy_process.part.62+0x23c/0x16e0
[    0.460004] softirqs last  enabled at (0): [<c104fa4c>] copy_process.part.62+0x23c/0x16e0
[    0.460004] softirqs last disabled at (0): [<00000000>]   (null)
[    0.460004] CPU: 3 PID: 30 Comm: kworker/3:0 Tainted: G    B D           4.17.0-rc5-elk+ #145
[    0.460004] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    0.460004] Workqueue: events pcpu_balance_workfn
[    0.460004] Call Trace:
[    0.460004]  dump_stack+0x60/0x96
[    0.460004]  ___might_sleep+0x1f3/0x220
[    0.460004]  __might_sleep+0x2e/0x80
[    0.460004]  exit_signals+0x1a/0x210
[    0.460004]  do_exit+0x7e/0xb60
[    0.526672]  ? kthread+0xda/0x110
[    0.526672]  ? rescuer_thread+0x320/0x320
[    0.533335]  rewind_stack_do_exit+0x11/0x13
[    0.536677] note: kworker/3:0[30] exited with preempt_count 1
[    0.543353] kworker/3:0 (30) used greatest stack depth: 6460 bytes left

-- 
Ville Syrjala
Intel
