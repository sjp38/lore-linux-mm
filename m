Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A51A6B04F4
	for <linux-mm@kvack.org>; Thu, 17 May 2018 10:11:52 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d9-v6so2957138plj.4
        for <linux-mm@kvack.org>; Thu, 17 May 2018 07:11:52 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a7-v6si2786756pgu.26.2018.05.17.07.11.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 07:11:48 -0700 (PDT)
Date: Thu, 17 May 2018 17:11:41 +0300
From: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
Message-ID: <20180517141141.GJ23723@intel.com>
References: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
 <20180517132109.GU12670@dhcp22.suse.cz>
 <20180517133629.GH23723@intel.com>
 <20180517135832.GI23723@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180517135832.GI23723@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 17, 2018 at 04:58:32PM +0300, Ville Syrjala wrote:
> On Thu, May 17, 2018 at 04:36:29PM +0300, Ville Syrjala wrote:
> > On Thu, May 17, 2018 at 03:21:09PM +0200, Michal Hocko wrote:
> > > On Thu 17-05-18 15:59:59, Ville Syrjala wrote:
> > > > From: Ville Syrjala <ville.syrjala@linux.intel.com>
> > > > 
> > > > This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.
> > > > 
> > > > Make x86 with HIGHMEM=y and CMA=y boot again.
> > > 
> > > Is there any bug report with some more details? It is much more
> > > preferable to fix the issue rather than to revert the whole thing
> > > right away.
> > 
> > The machine I have in front of me right now didn't give me anything.
> > Black screen, and netconsole was silent. No serial port on this
> > machine unfortunately.
> 
> Booted on another machine with serial:
> 

And here's a log with the revert:

[    0.000000] Linux version 4.17.0-rc5-elk+ () (gcc version 6.4.0 (Gentoo 6.4.0-r1 p1.3)) #146 SMP Thu May 17 16:55:26 EEST 2018
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
[    0.000000] Initializing Movable for node 0 (00000000:00000000)
[    0.000000] Memory: 3926480K/3987424K available (5254K kernel code, 561K rwdata, 2156K rodata, 572K init, 9308K bss, 56848K reserved, 4096K cma-reserved, 3078532K highmem)
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
[    0.026666] tsc: Detected 2659.950 MHz processor
[    0.029999] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles: 0x2657749ff96, max_idle_ns: 440795305409 ns
[    0.033339] Calibrating delay loop (skipped), value calculated using timer frequency.. 5322.56 BogoMIPS (lpj=8866500)
[    0.036669] pid_max: default: 32768 minimum: 301
[    0.040045] Security Framework initialized
[    0.043355] Mount-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.046671] Mountpoint-cache hash table entries: 2048 (order: 1, 8192 bytes)
[    0.050387] CPU: Physical Processor ID: 0
[    0.053337] CPU: Processor Core ID: 0
[    0.056674] mce: CPU supports 9 MCE banks
[    0.060020] process: using mwait in idle threads
[    0.063340] Last level iTLB entries: 4KB 512, 2MB 7, 4MB 7
[    0.066669] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
[    0.070003] Spectre V2 : Vulnerable: Minimal generic ASM retpoline
[    0.073335] Spectre V2 : Spectre v2 mitigation: Filling RSB on context switch
[    0.076770] Freeing SMP alternatives memory: 20K
[    0.083333] smpboot: CPU0: Intel(R) Core(TM) i5 CPU       M 560  @ 2.67GHz (family: 0x6, model: 0x25, stepping: 0x5)
[    0.083545] Performance Events: PEBS fmt1+, Westmere events, 16-deep LBR, Intel PMU driver.
[    0.086671] core: CPUID marked event: 'bus cycles' unavailable
[    0.090014] ... version:                3
[    0.093336] ... bit width:              48
[    0.096669] ... generic registers:      4
[    0.100002] ... value mask:             0000ffffffffffff
[    0.103336] ... max period:             000000007fffffff
[    0.106669] ... fixed-purpose events:   3
[    0.110002] ... event mask:             000000070000000f
[    0.113426] Hierarchical SRCU implementation.
[    0.117232] NMI watchdog: Enabled. Permanently consumes one hw-PMU counter.
[    0.120039] smp: Bringing up secondary CPUs ...
[    0.123747] x86: Booting SMP configuration:
[    0.126679] .... node  #0, CPUs:      #1
[    0.003333] Initializing CPU#1
[    0.136999]  #2
[    0.003333] Initializing CPU#2
[    0.145684]  #3
[    0.003333] Initializing CPU#3
[    0.153086] smp: Brought up 1 node, 4 CPUs
[    0.153340] smpboot: Max logical packages: 1
[    0.156671] smpboot: Total of 4 processors activated (21288.25 BogoMIPS)
[    0.163562] devtmpfs: initialized
[    0.167061] random: get_random_u32 called from bucket_table_alloc+0x71/0x190 with crng_init=0
[    0.170069] PM: Registering ACPI NVS region [mem 0xdb67f000-0xdb76efff] (983040 bytes)
[    0.173436] reboot: Dell Latitude E5410 series board detected. Selecting PCI-method for reboots.
[    0.180021] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370867519511994 ns
[    0.183344] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    0.186899] RTC time: 13:57:03, date: 05/17/18
[    0.190218] NET: Registered protocol family 16
[    0.193612] audit: initializing netlink subsys (disabled)
[    0.196691] audit: type=2000 audit(1526565422.196:1): state=initialized audit_enabled=0 res=1
[    0.203349] cpuidle: using governor menu
[    0.210070] Simple Boot Flag at 0xf1 set to 0x1
[    0.213360] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
[    0.220009] ACPI: bus type PCI registered
[    0.223337] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.230107] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.240007] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
[    0.246670] PCI: Using MMCONFIG for extended config space
[    0.253336] PCI: Using configuration type 1 for base access
[    0.260760] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.266836] ACPI: Added _OSI(Module Device)
[    0.270005] ACPI: Added _OSI(Processor Device)
[    0.273338] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.276670] ACPI: Added _OSI(Processor Aggregator Device)
[    0.280006] ACPI: Added _OSI(Linux-Dell-Video)
[    0.302187] ACPI: 2 ACPI AML tables successfully acquired and loaded
[    0.312792] ACPI: [Firmware Bug]: BIOS _OSI(Linux) query ignored
[    0.330164] ACPI: Dynamic OEM Table Load:
[    0.333345] ACPI: SSDT 0x00000000F4AD0000 000474 (v01 PmRef  Cpu0Ist  00003000 INTL 20080729)
[    0.337293] ACPI: Dynamic OEM Table Load:
[    0.340011] ACPI: SSDT 0x00000000F48A1000 000891 (v01 PmRef  Cpu0Cst  00003001 INTL 20080729)
[    0.347087] ACPI: Dynamic OEM Table Load:
[    0.350010] ACPI: SSDT 0x00000000F4AD5400 000303 (v01 PmRef  ApIst    00003000 INTL 20080729)
[    0.356784] ACPI: Dynamic OEM Table Load:
[    0.360010] ACPI: SSDT 0x00000000F4AB7A00 000119 (v01 PmRef  ApCst    00003000 INTL 20080729)
[    0.367800] ACPI: EC: EC started
[    0.370003] ACPI: EC: interrupt blocked
[    0.376910] ACPI: \_SB_.PCI0.LPCB.ECDV: Used as first EC
[    0.380006] ACPI: \_SB_.PCI0.LPCB.ECDV: GPE=0x10, EC_CMD/EC_SC=0x934, EC_DATA=0x930
[    0.383338] ACPI: \_SB_.PCI0.LPCB.ECDV: Used as boot DSDT EC to handle transactions
[    0.386669] ACPI: Interpreter enabled
[    0.390046] ACPI: (supports S0 S3 S4 S5)
[    0.393342] ACPI: Using IOAPIC for interrupt routing
[    0.396722] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.400469] ACPI: Enabled 7 GPEs in block 00 to 3F
[    0.434195] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
[    0.436676] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    0.440122] acpi PNP0A08:00: _OSC failed (AE_ERROR); disabling ASPM
[    0.444568] PCI host bridge to bus 0000:00
[    0.446673] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.450004] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.453338] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.456671] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xfeafffff window]
[    0.460005] pci_bus 0000:00: root bus resource [bus 00-3e]
[    0.469936] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.470378] pci 0000:02:00.0: enabling Extended Tags
[    0.473786] pci 0000:00:1c.1: PCI bridge to [bus 02]
[    0.480185] pci 0000:03:00.4: Enabling fixed DMA alias to 00.0
[    0.483726] pci 0000:00:1c.2: PCI bridge to [bus 03-04]
[    0.486797] pci 0000:00:1c.2: bridge has subordinate 04 but max busn 07
[    0.490162] acpiphp: Slot [1] registered
[    0.493345] pci 0000:00:1c.3: PCI bridge to [bus 05-0a]
[    0.497126] pci 0000:0b:00.0: enabling Extended Tags
[    0.503607] pci 0000:00:1c.5: PCI bridge to [bus 0b]
[    0.506802] pci 0000:00:1e.0: PCI bridge to [bus 0c] (subtractive decode)
[    0.515058] ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 7 10 12 14 15) *11
[    0.516809] ACPI: PCI Interrupt Link [LNKB] (IRQs 1 *3 4 5 6 7 11 12 14 15)
[    0.520136] ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 5 6 7 10 12 14 15) *11
[    0.523470] ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 7 11 12 14 15) *10
[    0.526802] ACPI: PCI Interrupt Link [LNKE] (IRQs 1 3 4 5 6 7 10 12 14 15) *0, disabled.
[    0.530136] ACPI: PCI Interrupt Link [LNKF] (IRQs 1 3 4 5 6 7 11 12 14 15) *0, disabled.
[    0.533470] ACPI: PCI Interrupt Link [LNKG] (IRQs 1 3 4 *5 6 7 10 12 14 15)
[    0.536802] ACPI: PCI Interrupt Link [LNKH] (IRQs 1 3 4 5 6 7 11 12 14 15) *0, disabled.
[    0.543746] ACPI: PCI Root Bridge [CPBG] (domain 0000 [bus 3f])
[    0.546674] acpi PNP0A03:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    0.550012] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.553512] PCI host bridge to bus 0000:3f
[    0.556672] pci_bus 0000:3f: root bus resource [bus 3f]
[    0.563475] ACPI: EC: interrupt unblocked
[    0.566694] ACPI: EC: event unblocked
[    0.570044] ACPI: \_SB_.PCI0.LPCB.ECDV: GPE=0x10, EC_CMD/EC_SC=0x934, EC_DATA=0x930
[    0.573357] ACPI: \_SB_.PCI0.LPCB.ECDV: Used as boot DSDT EC to handle transactions and events
[    0.583757] pci 0000:00:02.0: vgaarb: setting as boot VGA device
[    0.586666] pci 0000:00:02.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.597247] pci 0000:00:02.0: vgaarb: bridge control possible
[    0.603338] vgaarb: loaded
[    0.606946] SCSI subsystem initialized
[    0.610295] PCI: Using ACPI for IRQ routing
[    0.618098] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    0.623341] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    0.633336] clocksource: Switched to clocksource tsc-early
[    0.659590] pnp: PnP ACPI init
[    0.662961] system 00:00: [io  0x0680-0x069f] has been reserved
[    0.668885] system 00:00: [io  0x1000-0x1003] has been reserved
[    0.674797] system 00:00: [io  0x1004-0x1013] has been reserved
[    0.680712] system 00:00: [io  0xffff] has been reserved
[    0.686168] system 00:00: [io  0x0400-0x047f] has been reserved
[    0.692082] system 00:00: [io  0x0500-0x057f] has been reserved
[    0.697997] system 00:00: [io  0x164e-0x164f] has been reserved
[    0.707585] system 00:06: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.714196] system 00:06: [mem 0xfed10000-0xfed13fff] has been reserved
[    0.720804] system 00:06: [mem 0xfed18000-0xfed18fff] has been reserved
[    0.727411] system 00:06: [mem 0xfed19000-0xfed19fff] has been reserved
[    0.734017] system 00:06: [mem 0xf8000000-0xfbffffff] has been reserved
[    0.740623] system 00:06: [mem 0xfed20000-0xfed3ffff] has been reserved
[    0.747228] system 00:06: [mem 0xfed45000-0xfed8ffff] has been reserved
[    0.753837] system 00:06: [mem 0xff000000-0xffffffff] could not be reserved
[    0.760793] system 00:06: [mem 0xfee00000-0xfeefffff] could not be reserved
[    0.767748] system 00:06: [mem 0xf7d80000-0xf7d80fff] has been reserved
[    0.777492] pnp: PnP ACPI: found 7 devices
[    0.819922] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.828883] pci 0000:00:1c.0: BAR 9: assigned [mem 0xf7e00000-0xf7ffffff 64bit pref]
[    0.836621] pci 0000:00:1c.1: BAR 9: assigned [mem 0xfc000000-0xfc1fffff 64bit pref]
[    0.844358] pci 0000:00:1c.2: BAR 9: assigned [mem 0xfc200000-0xfc3fffff 64bit pref]
[    0.852095] pci 0000:00:1c.3: BAR 9: assigned [mem 0xfc400000-0xfc5fffff 64bit pref]
[    0.859831] pci 0000:00:1c.5: BAR 9: assigned [mem 0xfc600000-0xfc7fffff 64bit pref]
[    0.867566] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.872526] pci 0000:00:1c.0:   bridge window [io  0x7000-0x7fff]
[    0.878618] pci 0000:00:1c.0:   bridge window [mem 0xf6900000-0xf7cfffff]
[    0.885400] pci 0000:00:1c.0:   bridge window [mem 0xf7e00000-0xf7ffffff 64bit pref]
[    0.893139] pci 0000:00:1c.1: PCI bridge to [bus 02]
[    0.898100] pci 0000:00:1c.1:   bridge window [io  0x6000-0x6fff]
[    0.904190] pci 0000:00:1c.1:   bridge window [mem 0xf5500000-0xf68fffff]
[    0.910974] pci 0000:00:1c.1:   bridge window [mem 0xfc000000-0xfc1fffff 64bit pref]
[    0.918718] pci 0000:03:00.0: BAR 9: no space for [mem size 0x04000000 pref]
[    0.925761] pci 0000:03:00.0: BAR 9: failed to assign [mem size 0x04000000 pref]
[    0.933149] pci 0000:03:00.0: BAR 10: no space for [mem size 0x04000000]
[    0.939842] pci 0000:03:00.0: BAR 10: failed to assign [mem size 0x04000000]
[    0.946882] pci 0000:03:00.0: BAR 7: assigned [io  0x2000-0x20ff]
[    0.952966] pci 0000:03:00.0: BAR 8: assigned [io  0x2400-0x24ff]
[    0.959057] pci 0000:03:00.0: BAR 10: no space for [mem size 0x04000000]
[    0.965747] pci 0000:03:00.0: BAR 10: failed to assign [mem size 0x04000000]
[    0.972786] pci 0000:03:00.0: BAR 9: no space for [mem size 0x04000000 pref]
[    0.979824] pci 0000:03:00.0: BAR 9: failed to assign [mem size 0x04000000 pref]
[    0.987211] pci 0000:03:00.0: CardBus bridge to [bus 04]
[    0.992515] pci 0000:03:00.0:   bridge window [io  0x2000-0x20ff]
[    0.998605] pci 0000:03:00.0:   bridge window [io  0x2400-0x24ff]
[    1.004696] pci 0000:00:1c.2: PCI bridge to [bus 03-04]
[    1.009916] pci 0000:00:1c.2:   bridge window [io  0x2000-0x3fff]
[    1.016006] pci 0000:00:1c.2:   bridge window [mem 0xf0400000-0xf2cfffff]
[    1.022788] pci 0000:00:1c.2:   bridge window [mem 0xfc200000-0xfc3fffff 64bit pref]
[    1.030528] pci 0000:00:1c.3: PCI bridge to [bus 05-0a]
[    1.035748] pci 0000:00:1c.3:   bridge window [io  0x5000-0x5fff]
[    1.041846] pci 0000:00:1c.3:   bridge window [mem 0xf4100000-0xf54fffff]
[    1.048636] pci 0000:00:1c.3:   bridge window [mem 0xfc400000-0xfc5fffff 64bit pref]
[    1.056377] pci 0000:00:1c.5: PCI bridge to [bus 0b]
[    1.061340] pci 0000:00:1c.5:   bridge window [io  0x4000-0x4fff]
[    1.067432] pci 0000:00:1c.5:   bridge window [mem 0xf2d00000-0xf40fffff]
[    1.074214] pci 0000:00:1c.5:   bridge window [mem 0xfc600000-0xfc7fffff 64bit pref]
[    1.081954] pci 0000:00:1e.0: PCI bridge to [bus 0c]
[    1.087194] NET: Registered protocol family 2
[    1.091808] tcp_listen_portaddr_hash hash table entries: 512 (order: 2, 20480 bytes)
[    1.099579] TCP established hash table entries: 8192 (order: 3, 32768 bytes)
[    1.106639] TCP bind hash table entries: 8192 (order: 6, 294912 bytes)
[    1.113525] TCP: Hash tables configured (established 8192 bind 8192)
[    1.119937] UDP hash table entries: 512 (order: 3, 40960 bytes)
[    1.125907] UDP-Lite hash table entries: 512 (order: 3, 40960 bytes)
[    1.132373] NET: Registered protocol family 1
[    1.136744] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    1.146758] Unpacking initramfs...
[    1.152236] Freeing initrd memory: 1632K
[    1.157566] cryptomgr_test (48) used greatest stack depth: 7308 bytes left
[    1.159044] workingset: timestamp_bits=30 max_order=20 bucket_order=0
[    1.171619] cryptomgr_test (55) used greatest stack depth: 7016 bytes left
[    1.171778] bounce: pool size: 64 pages
[    1.178502] cryptomgr_test (56) used greatest stack depth: 6980 bytes left
[    1.182372] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    1.196633] io scheduler noop registered
[    1.200556] io scheduler deadline registered
[    1.204841] io scheduler cfq registered (default)
[    1.209545] io scheduler mq-deadline registered
[    1.214074] io scheduler kyber registered
[    1.221626] ACPI: AC Adapter [AC] (on-line)
[    1.225962] input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input0
[    1.236374] ACPI: Lid Switch [LID]
[    1.240123] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input1
[    1.248613] ACPI: Power Button [PBTN]
[    1.252533] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input2
[    1.260975] ACPI: Sleep Button [SBTN]
[    1.264845] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
[    1.272291] ACPI: Power Button [PWRF]
[    1.278067] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
y[    1.305815] 00:03: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    1.323638] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 4 ports 3 Gbps 0x23 impl SATA mode
[    1.332139] ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ems sxs apst 
[    1.389992] scsi host0: ahci
[    1.393586] scsi host1: ahci
[    1.397114] scsi host2: ahci
[    1.398034] ACPI: Battery Slot [BAT0] (battery present)
[    1.400323] scsi host3: ahci
[    1.408474] scsi host4: ahci
[    1.411603] scsi host5: ahci
[    1.414596] ata1: SATA max UDMA/133 abar m2048@0xf7d20000 port 0xf7d20100 irq 24
[    1.422002] ata2: SATA max UDMA/133 abar m2048@0xf7d20000 port 0xf7d20180 irq 24
[    1.429401] ata3: DUMMY
[    1.431859] ata4: DUMMY
[    1.434317] ata5: DUMMY
[    1.436777] ata6: SATA max UDMA/133 abar m2048@0xf7d20000 port 0xf7d20380 irq 24
[    1.444848] i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    1.453541] i8042: Warning: Keylock active
[    1.458916] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.463944] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.469815] rtc_cmos 00:01: RTC can wake from S4
[    1.475098] rtc_cmos 00:01: registered as rtc0
[    1.479694] rtc_cmos 00:01: alarms up to one year, y3k, 242 bytes nvram, hpet irqs
[    1.487513] IR NEC protocol handler initialized
[    1.487744] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input4
[    1.492065] IR RC5(x/sz) protocol handler initialized
[    1.492068] IR RC6 protocol handler initialized
[    1.492070] IR JVC protocol handler initialized
[    1.492073] IR Sony protocol handler initialized
[    1.492076] IR SANYO protocol handler initialized
[    1.492079] IR Sharp protocol handler initialized
[    1.528867] IR MCE Keyboard/mouse protocol handler initialized
[    1.534707] IR XMP protocol handler initialized
[    1.539548] NET: Registered protocol family 17
[    1.545379] microcode: sig=0x20655, pf=0x10, revision=0x4
[    1.551242] microcode: Microcode Update Driver: v2.2.
[    1.551252] Using IPI No-Shortcut mode
[    1.560117] sched_clock: Marking stable (1560072742, 0)->(1890797128, -330724386)
[    1.568797] registered taskstats version 1
[    1.573798]   Magic number: 2:93:989
[    1.577402] machinecheck machinecheck2: hash matches
[    1.582795] console [netcon0] enabled
[    1.586526] netconsole: network logging started
[    1.591303] rtc_cmos 00:01: setting system clock to 2018-05-17 13:57:04 UTC (1526565424)
[    1.758433] ata2: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    1.764760] ata6: SATA link down (SStatus 0 SControl 300)
[    1.770191] ata2.00: ATAPI: Optiarc DVD+/-RW AD-7717H, 101A, max UDMA/100
[    1.777010] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.783727] ata1.00: ACPI cmd 00/00:00:00:00:00:a0 (NOP) rejected by device (Stat=0x51 Err=0x04)
[    1.792628] ata2.00: configured for UDMA/100
[    1.796915] ata1.00: ATA-11: KINGSTON SA400S37120G, SBFK71E0, max UDMA/133
[    1.803835] ata1.00: 234441648 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    1.811460] ata1.00: ACPI cmd 00/00:00:00:00:00:a0 (NOP) rejected by device (Stat=0x51 Err=0x04)
[    1.820405] ata1.00: configured for UDMA/133
[    1.825123] scsi 0:0:0:0: Direct-Access     ATA      KINGSTON SA400S3 71E0 PQ: 0 ANSI: 5
[    1.834745] sd 0:0:0:0: [sda] 234441648 512-byte logical blocks: (120 GB/112 GiB)
[    1.836380] scsi 1:0:0:0: CD-ROM            Optiarc  DVD+-RW AD-7717H 101A PQ: 0 ANSI: 5
[    1.842298] sd 0:0:0:0: [sda] Write Protect is off
[    1.855258] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.865635]  sda: sda1 sda2 sda3
[    1.870491] sd 0:0:0:0: [sda] Attached SCSI disk
[    1.888549] VFS: Cannot open root device "(null)" or unknown-block(0,0): error -6
[    1.896082] Please append a correct "root=" boot option; here are the available partitions:
[    1.904482] 0800       117220824 sda 
[    1.904484]  driver: sd
[    1.910594]   0801          524288 sda1 a1ab8ade-01
[    1.910595] 
[    1.917017]   0802         2097152 sda2 a1ab8ade-02
[    1.917019] 
[    1.923382]   0803       114598360 sda3 a1ab8ade-03
[    1.923383] 
[    1.929799] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
[    1.938048] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.17.0-rc5-elk+ #146
[    1.944908] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    1.952202] Call Trace:
[    1.954649]  dump_stack+0x60/0x96
[    1.957964]  panic+0x8f/0x1c6
[    1.960926]  mount_block_root+0x191/0x206
[    1.964930]  mount_root+0x71/0x76
[    1.968240]  prepare_namespace+0x111/0x141
[    1.972328]  kernel_init_freeable+0x17c/0x18e
[    1.976677]  ? rest_init+0xb0/0xb0
[    1.980075]  kernel_init+0x8/0xf0
[    1.983387]  ret_from_fork+0x2e/0x38
[    1.987020] Kernel Offset: disabled
[    1.990512] ---[ end Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0) ]---
[    1.999976] ------------[ cut here ]------------
[    2.004583] sched: Unexpected reschedule of offline CPU#2!
[    2.010063] WARNING: CPU: 0 PID: 1 at ../arch/x86/kernel/smp.c:128 native_smp_send_reschedule+0x2b/0x40
[    2.019435] Modules linked in:
[    2.022486] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.17.0-rc5-elk+ #146
[    2.029346] Hardware name: Dell Inc. Latitude E5410/03VXMC, BIOS A15 07/11/2013
[    2.036641] EIP: native_smp_send_reschedule+0x2b/0x40
[    2.041680] EFLAGS: 00210086 CPU: 0
[    2.045160] EAX: 0000002e EBX: 00000003 ECX: 00000000 EDX: f4884040
[    2.051412] ESI: 00000002 EDI: 00000003 EBP: f488fdac ESP: f488fda4
[    2.057666]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[    2.063054] CR0: 80050033 CR2: 00000000 CR3: 01875000 CR4: 000006f0
[    2.069306] Call Trace:
[    2.071749]  kick_ilb+0x80/0x90
[    2.074884]  trigger_load_balance+0x108/0x370
[    2.079231]  scheduler_tick+0xa5/0xd0
[    2.082886]  update_process_times+0x3a/0x50
[    2.087061]  tick_sched_handle+0x23/0x60
[    2.090977]  tick_sched_timer+0x38/0x90
[    2.094805]  __hrtimer_run_queues+0x137/0x500
[    2.099155]  ? ktime_get_update_offsets_now+0x89/0x1d0
[    2.104283]  ? tick_sched_do_timer+0x70/0x70
[    2.108544]  hrtimer_interrupt+0x100/0x2a0
[    2.112634]  smp_apic_timer_interrupt+0x67/0x2b0
[    2.117241]  apic_timer_interrupt+0x3a/0x40
[    2.121415] EIP: panic+0x179/0x1c6
[    2.124809] EFLAGS: 00200246 CPU: 0
[    2.128289] EAX: c16a43b0 EBX: f488ff00 ECX: 00000000 EDX: 00000000
[    2.134541] ESI: 00000000 EDI: 00000000 EBP: f488ff1c ESP: f488ff08
[    2.140796]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[    2.146185]  ? debug_rt_mutex_proxy_unlock+0x2b/0x50
[    2.151139]  mount_block_root+0x191/0x206
[    2.155140]  mount_root+0x71/0x76
[    2.158448]  prepare_namespace+0x111/0x141
[    2.162535]  kernel_init_freeable+0x17c/0x18e
[    2.166883]  ? rest_init+0xb0/0xb0
[    2.170277]  kernel_init+0x8/0xf0
[    2.173585]  ret_from_fork+0x2e/0x38
[    2.177152] Code: 55 89 e5 0f a3 05 dc 9e 7c c1 73 14 8b 0d a0 c3 70 c1 ba fd 00 00 00 ff 51 18 c9 c3 8d 74 26 00 50 68 74 fc 69 c1 e8 45 98 01 00 <0f> 0b 58 5a c9 c3 eb 0d 90 90 90 90 90 90 90 90 90 90 90 90 90 
[    2.196016] irq event stamp: 815904
[    2.199498] hardirqs last  enabled at (815903): [<c10ad5f5>] console_unlock+0x565/0x690
[    2.207486] hardirqs last disabled at (815904): [<c10521fd>] panic+0x13/0x1c6
[    2.214608] softirqs last  enabled at (815898): [<c1520bee>] __do_softirq+0x32e/0x42e
[    2.222423] softirqs last disabled at (815891): [<c101bf10>] call_on_stack+0x40/0x50
[    2.230149] WARNING: CPU: 0 PID: 1 at ../arch/x86/kernel/smp.c:128 native_smp_send_reschedule+0x2b/0x40
[    2.239522] ---[ end trace 36642faeb7bb25ab ]---

-- 
Ville Syrjala
Intel
