Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C657590016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 06:19:19 -0400 (EDT)
Message-ID: <4E01C19F.20204@draigBrady.com>
Date: Wed, 22 Jun 2011 11:19:11 +0100
From: =?ISO-8859-15?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: sandy bridge kswapd0 livelock with pagecache
References: <4E0069FE.4000708@draigBrady.com> <20110621103920.GF9396@suse.de> <4E0076C7.4000809@draigBrady.com> <20110621113447.GG9396@suse.de> <4E008784.80107@draigBrady.com> <20110621130756.GH9396@suse.de> <4E00A96D.8020806@draigBrady.com> <20110622094401.GJ9396@suse.de>
In-Reply-To: <20110622094401.GJ9396@suse.de>
Content-Type: multipart/mixed;
 boundary="------------080109040106070607080406"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------080109040106070607080406
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit

On 22/06/11 10:44, Mel Gorman wrote:
> I haven't started looking at this properly yet (stuck with other
> bugs unfortunately) but I glanced at the sysrq message and on a 2G
> 64-bit machine, you have a tiny Normal zone! This is very unexpected.
> Can you boot with mminit_loglevel=4 loglevel=9 and post your full
> dmesg please? I want to see what the memory layout of this thing
> looks like to see in the future if there is a correlation between
> this type of bug and a tiny highest zone.

Note this machine has 3G RAM
dmesg attached

> 
> Broadly speaking though from seeing that, it reminds me of a
> similar bug where small zones could keep kswapd alive for high-order
> allocations reclaiming slab constantly. I suspect on your machine
> that the Normal zone cannot be balanced for order-0 allocations and
> is keeping kswapd awake.
> 
> Can you try booting with mem=1792M and if the Normal zone disappears,
> try reproducing the bug?
> 

I tried mem=1792M but grub gave an ENOSPC error
Maybe I need to supply a memmap= too?

cheers,
Padraig.

--------------080109040106070607080406
Content-Type: text/plain;
 name="mm-debug.dmesg"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mm-debug.dmesg"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.38.8-32.fc15.x86_64 (padraig@pb-n5110) (gcc version 4.6.0 20110509 (Red Hat 4.6.0-7) (GCC) ) #5 SMP Tue Jun 21 16:24:12 IST 2011
[    0.000000] Command line: ro root=UUID=da48811c-7aeb-4514-8c75-a56a82bba9fa rd_NO_LUKS rd_NO_LVM rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrheb-sun16 KEYTABLE=uk rhgb quiet mminit_loglevel=4 loglevel=9
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009d400 (usable)
[    0.000000]  BIOS-e820: 000000000009d400 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 0000000020000000 (usable)
[    0.000000]  BIOS-e820: 0000000020000000 - 0000000020200000 (reserved)
[    0.000000]  BIOS-e820: 0000000020200000 - 0000000040000000 (usable)
[    0.000000]  BIOS-e820: 0000000040000000 - 0000000040200000 (reserved)
[    0.000000]  BIOS-e820: 0000000040200000 - 00000000b9ce3000 (usable)
[    0.000000]  BIOS-e820: 00000000b9ce3000 - 00000000b9d26000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000b9d26000 - 00000000b9f92000 (usable)
[    0.000000]  BIOS-e820: 00000000b9f92000 - 00000000ba167000 (reserved)
[    0.000000]  BIOS-e820: 00000000ba167000 - 00000000ba3a9000 (usable)
[    0.000000]  BIOS-e820: 00000000ba3a9000 - 00000000ba568000 (reserved)
[    0.000000]  BIOS-e820: 00000000ba568000 - 00000000ba7e8000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000ba7e8000 - 00000000ba800000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000bb000000 - 00000000bf200000 (reserved)
[    0.000000]  BIOS-e820: 00000000f8000000 - 00000000fc000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed00000 - 00000000fed04000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed20000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff000000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 0000000100600000 (usable)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.6 present.
[    0.000000] DMI: Dell Inc. Inspiron N5110/034W60, BIOS A03 03/16/2011
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] No AGP bridge found
[    0.000000] last_pfn = 0x100600 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-CFFFF write-protect
[    0.000000]   D0000-E7FFF uncachable
[    0.000000]   E8000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F00000000 write-back
[    0.000000]   1 base 100000000 mask FFFC00000 write-back
[    0.000000]   2 base 100400000 mask FFFE00000 write-back
[    0.000000]   3 base 0BB000000 mask FFF000000 uncachable
[    0.000000]   4 base 0BC000000 mask FFC000000 uncachable
[    0.000000]   5 base 0C0000000 mask FC0000000 uncachable
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] original variable MTRRs
[    0.000000] reg 0, base: 0GB, range: 4GB, type WB
[    0.000000] reg 1, base: 4GB, range: 4MB, type WB
[    0.000000] reg 2, base: 4100MB, range: 2MB, type WB
[    0.000000] reg 3, base: 2992MB, range: 16MB, type UC
[    0.000000] reg 4, base: 3008MB, range: 64MB, type UC
[    0.000000] reg 5, base: 3GB, range: 1GB, type UC
[    0.000000] total RAM covered: 2998M
[    0.000000] Found optimal setting for mtrr clean up
[    0.000000]  gran_size: 64K 	chunk_size: 128M 	num_reg: 6  	lose cover RAM: 0G
[    0.000000] New variable MTRRs
[    0.000000] reg 0, base: 0GB, range: 2GB, type WB
[    0.000000] reg 1, base: 2GB, range: 1GB, type WB
[    0.000000] reg 2, base: 2992MB, range: 16MB, type UC
[    0.000000] reg 3, base: 3008MB, range: 64MB, type UC
[    0.000000] reg 4, base: 4GB, range: 4MB, type WB
[    0.000000] reg 5, base: 4100MB, range: 2MB, type WB
[    0.000000] e820 update range: 00000000bb000000 - 0000000100000000 (usable) ==> (reserved)
[    0.000000] last_pfn = 0xba3a9 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [ffff8800000fd1e0] fd1e0
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] init_memory_mapping: 0000000000000000-00000000ba3a9000
[    0.000000]  0000000000 - 00ba200000 page 2M
[    0.000000]  00ba200000 - 00ba3a9000 page 4k
[    0.000000] kernel direct mapping tables up to ba3a9000 @ 1fffb000-20000000
[    0.000000] init_memory_mapping: 0000000100000000-0000000100600000
[    0.000000]  0100000000 - 0100600000 page 2M
[    0.000000] kernel direct mapping tables up to 100600000 @ ba3a3000-ba3a9000
[    0.000000] RAMDISK: 1f1ad000 - 1fff0000
[    0.000000] ACPI: RSDP 00000000000f0410 00024 (v02   DELL)
[    0.000000] ACPI: XSDT 00000000ba7e8078 0006C (v01 DELL    WN09    01072009 AMI  00010013)
[    0.000000] ACPI: FACP 00000000ba7f1c40 000F4 (v04   DELL     WN09 01072009 AMI  00010013)
[    0.000000] ACPI: DSDT 00000000ba7e8170 09ACE (v02   DELL     WN09 00000000 INTL 20051117)
[    0.000000] ACPI: FACS 00000000ba7e3f80 00040
[    0.000000] ACPI: APIC 00000000ba7f1d38 00072 (v03   DELL     WN09 01072009 AMI  00010013)
[    0.000000] ACPI: MCFG 00000000ba7f1db0 0003C (v01   DELL     WN09 01072009 MSFT 00000097)
[    0.000000] ACPI: SSDT 00000000ba7f1df0 004B0 (v01 TrmRef PtidDevc 00001000 INTL 20091112)
[    0.000000] ACPI: SLIC 00000000ba7f22a0 00176 (v01 DELL    WN09    01072009 AMI  00010013)
[    0.000000] ACPI: HPET 00000000ba7f2418 00038 (v01   DELL     WN09 01072009 AMI. 00000004)
[    0.000000] ACPI: SSDT 00000000ba7f2450 0090C (v01  PmRef  Cpu0Ist 00003000 INTL 20051117)
[    0.000000] ACPI: SSDT 00000000ba7f2d60 00996 (v01  PmRef    CpuPm 00003000 INTL 20051117)
[    0.000000] ACPI: OSFR 00000000ba7f36f8 00086 (v01 DELL    M08     07DB0310 ASL  00000061)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-0000000100600000
[    0.000000] mminit::memory_register Entering add_active_range(0, 0x10, 0x9d) 0 entries of 25600 used
[    0.000000] mminit::memory_register Entering add_active_range(0, 0x100, 0x20000) 1 entries of 25600 used
[    0.000000] mminit::memory_register Entering add_active_range(0, 0x20200, 0x40000) 2 entries of 25600 used
[    0.000000] mminit::memory_register Entering add_active_range(0, 0x40200, 0xb9ce3) 3 entries of 25600 used
[    0.000000] mminit::memory_register Entering add_active_range(0, 0xb9d26, 0xb9f92) 4 entries of 25600 used
[    0.000000] mminit::memory_register Entering add_active_range(0, 0xba167, 0xba3a9) 5 entries of 25600 used
[    0.000000] mminit::memory_register Entering add_active_range(0, 0x100000, 0x100600) 6 entries of 25600 used
[    0.000000] Initmem setup node 0 0000000000000000-0000000100600000
[    0.000000]   NODE_DATA [00000001005ec000 - 00000001005fffff]
[    0.000000]  [ffffea0000000000-ffffea00039fffff] PMD -> [ffff88001b600000-ffff88001e1fffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x00100600
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[7] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009d
[    0.000000]     0: 0x00000100 -> 0x00020000
[    0.000000]     0: 0x00020200 -> 0x00040000
[    0.000000]     0: 0x00040200 -> 0x000b9ce3
[    0.000000]     0: 0x000b9d26 -> 0x000b9f92
[    0.000000]     0: 0x000ba167 -> 0x000ba3a9
[    0.000000]     0: 0x00100000 -> 0x00100600
[    0.000000] mminit::pageflags_layout_widths Section 0 Node 9 Zone 2 Flags 25
[    0.000000] mminit::pageflags_layout_shifts Section 19 Node 9 Zone 2
[    0.000000] mminit::pageflags_layout_offsets Section 0 Node 55 Zone 53
[    0.000000] mminit::pageflags_layout_zoneid Zone ID: 53 -> 64
[    0.000000] mminit::pageflags_layout_usage location: 64 -> 53 unused 53 -> 25 flags 25 -> 0
[    0.000000] On node 0 totalpages: 762654
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3919 pages, LIFO batch:0
[    0.000000] mminit::memmap_init Initialising map node 0 zone 0 pfns 16 -> 4096
[    0.000000]   DMA32 zone: 14280 pages used for memmap
[    0.000000]   DMA32 zone: 742857 pages, LIFO batch:31
[    0.000000] mminit::memmap_init Initialising map node 0 zone 1 pfns 4096 -> 1048576
[    0.000000]   Normal zone: 21 pages used for memmap
[    0.000000]   Normal zone: 1515 pages, LIFO batch:0
[    0.000000] mminit::memmap_init Initialising map node 0 zone 2 pfns 1048576 -> 1050112
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] SMP: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009d000 - 000000000009e000
[    0.000000] PM: Registered nosave memory: 000000000009e000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
[    0.000000] PM: Registered nosave memory: 0000000020000000 - 0000000020200000
[    0.000000] PM: Registered nosave memory: 0000000040000000 - 0000000040200000
[    0.000000] PM: Registered nosave memory: 00000000b9ce3000 - 00000000b9d26000
[    0.000000] PM: Registered nosave memory: 00000000b9f92000 - 00000000ba167000
[    0.000000] PM: Registered nosave memory: 00000000ba3a9000 - 00000000ba568000
[    0.000000] PM: Registered nosave memory: 00000000ba568000 - 00000000ba7e8000
[    0.000000] PM: Registered nosave memory: 00000000ba7e8000 - 00000000ba800000
[    0.000000] PM: Registered nosave memory: 00000000ba800000 - 00000000bb000000
[    0.000000] PM: Registered nosave memory: 00000000bb000000 - 00000000bf200000
[    0.000000] PM: Registered nosave memory: 00000000bf200000 - 00000000f8000000
[    0.000000] PM: Registered nosave memory: 00000000f8000000 - 00000000fc000000
[    0.000000] PM: Registered nosave memory: 00000000fc000000 - 00000000fec00000
[    0.000000] PM: Registered nosave memory: 00000000fec00000 - 00000000fec01000
[    0.000000] PM: Registered nosave memory: 00000000fec01000 - 00000000fed00000
[    0.000000] PM: Registered nosave memory: 00000000fed00000 - 00000000fed04000
[    0.000000] PM: Registered nosave memory: 00000000fed04000 - 00000000fed1c000
[    0.000000] PM: Registered nosave memory: 00000000fed1c000 - 00000000fed20000
[    0.000000] PM: Registered nosave memory: 00000000fed20000 - 00000000fee00000
[    0.000000] PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
[    0.000000] PM: Registered nosave memory: 00000000fee01000 - 00000000ff000000
[    0.000000] PM: Registered nosave memory: 00000000ff000000 - 0000000100000000
[    0.000000] Allocating PCI resources starting at bf200000 (gap: bf200000:38e00000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:256 nr_cpumask_bits:256 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88001ee00000 s83200 r8192 d23296 u524288
[    0.000000] pcpu-alloc: s83200 r8192 d23296 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 
[    0.000000] mminit::zonelist general 0:DMA = 0:DMA 
[    0.000000] mminit::zonelist general 0:DMA32 = 0:DMA32 0:DMA 
[    0.000000] mminit::zonelist general 0:Normal = 0:Normal 0:DMA32 0:DMA 
[    0.000000] mminit::zonelist thisnode 0:DMA = 0:DMA 
[    0.000000] mminit::zonelist thisnode 0:DMA32 = 0:DMA32 0:DMA 
[    0.000000] mminit::zonelist thisnode 0:Normal = 0:Normal 0:DMA32 0:DMA 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 748291
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: ro root=UUID=da48811c-7aeb-4514-8c75-a56a82bba9fa rd_NO_LUKS rd_NO_LVM rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrheb-sun16 KEYTABLE=uk rhgb quiet mminit_loglevel=4 loglevel=9
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave/xrstor: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 2910064k/4200448k available (4601k kernel code, 1149832k absent, 140552k reserved, 6925k data, 948k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	RCU-based detection of stalled CPUs is disabled.
[    0.000000] NR_IRQS:16640 nr_irqs:712 16
[    0.000000] Extended CMOS year: 2000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] allocated 32768000 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.001000] Detected 2095.510 MHz processor.
[    0.000003] Calibrating delay loop (skipped), value calculated using timer frequency.. 4191.02 BogoMIPS (lpj=2095510)
[    0.000202] pid_max: default: 32768 minimum: 301
[    0.000327] Security Framework initialized
[    0.000430] SELinux:  Initializing.
[    0.000533] SELinux:  Starting in permissive mode
[    0.001243] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.002631] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.003230] Mount-cache hash table entries: 256
[    0.003464] Initializing cgroup subsys ns
[    0.003564] ns_cgroup deprecated: consider using the 'clone_children' flag without the ns_cgroup.
[    0.003734] Initializing cgroup subsys cpuacct
[    0.003836] Initializing cgroup subsys memory
[    0.003946] Initializing cgroup subsys devices
[    0.004045] Initializing cgroup subsys freezer
[    0.004144] Initializing cgroup subsys net_cls
[    0.004242] Initializing cgroup subsys blkio
[    0.004373] CPU: Physical Processor ID: 0
[    0.004470] CPU: Processor Core ID: 0
[    0.004572] mce: CPU supports 7 MCE banks
[    0.004691] CPU0: Thermal monitoring enabled (TM1)
[    0.004797] using mwait in idle threads.
[    0.005439] ACPI: Core revision 20110112
[    0.022531] ftrace: allocating 23799 entries in 94 pages
[    0.032404] Not enabling x2apic, Intr-remapping init failed.
[    0.032507] Setting APIC routing to flat
[    0.032969] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.043058] CPU0: Intel(R) Core(TM) i3-2310M CPU @ 2.10GHz stepping 07
[    0.144445] Performance Events: PEBS fmt1+, SandyBridge events, Intel PMU driver.
[    0.144720] ... version:                3
[    0.144817] ... bit width:              48
[    0.144914] ... generic registers:      4
[    0.145011] ... value mask:             0000ffffffffffff
[    0.145111] ... max period:             000000007fffffff
[    0.145210] ... fixed-purpose events:   3
[    0.145306] ... event mask:             000000070000000f
[    0.145789] NMI watchdog enabled, takes one hw-pmu counter.
[    0.145982] Booting Node   0, Processors  #1
[    0.236456] NMI watchdog enabled, takes one hw-pmu counter.
[    0.236745]  #2
[    0.327288] NMI watchdog enabled, takes one hw-pmu counter.
[    0.327579]  #3 Ok.
[    0.418147] NMI watchdog enabled, takes one hw-pmu counter.
[    0.418279] Brought up 4 CPUs
[    0.418376] Total of 4 processors activated (16760.87 BogoMIPS).
[    0.421342] sizeof(vma)=184 bytes
[    0.421441] sizeof(page)=56 bytes
[    0.421536] sizeof(inode)=600 bytes
[    0.421633] sizeof(dentry)=192 bytes
[    0.421728] sizeof(ext3inode)=816 bytes
[    0.421824] sizeof(ext4inode)=920 bytes
[    0.421921] sizeof(buffer_head)=104 bytes
[    0.422020] sizeof(skbuff)=240 bytes
[    0.422116] sizeof(task_struct)=5928 bytes
[    0.422367] devtmpfs: initialized
[    0.426572] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    0.426706] Time: 10:01:01  Date: 06/22/11
[    0.426836] NET: Registered protocol family 16
[    0.427106] ACPI: bus type pci registered
[    0.427279] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.427436] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
[    0.435759] PCI: Using configuration type 1 for base access
[    0.436908] bio: create slab <bio-0> at 0
[    0.438620] ACPI: EC: Look up EC in DSDT
[    0.440353] ACPI: Executed 1 blocks of module-level executable AML code
[    0.446149] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.453775] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.454357] ACPI: SSDT 00000000ba551698 0064F (v01  PmRef  Cpu0Cst 00003001 INTL 20051117)
[    0.454987] ACPI: Dynamic OEM Table Load:
[    0.455166] ACPI: SSDT           (null) 0064F (v01  PmRef  Cpu0Cst 00003001 INTL 20051117)
[    0.458346] ACPI: SSDT 00000000ba552a98 00303 (v01  PmRef    ApIst 00003000 INTL 20051117)
[    0.459024] ACPI: Dynamic OEM Table Load:
[    0.459202] ACPI: SSDT           (null) 00303 (v01  PmRef    ApIst 00003000 INTL 20051117)
[    0.463155] ACPI: SSDT 00000000ba550d98 00119 (v01  PmRef    ApCst 00003000 INTL 20051117)
[    0.463773] ACPI: Dynamic OEM Table Load:
[    0.463953] ACPI: SSDT           (null) 00119 (v01  PmRef    ApCst 00003000 INTL 20051117)
[    0.468687] ACPI: Interpreter enabled
[    0.468787] ACPI: (supports S0 S1 S3 S4 S5)
[    0.469115] ACPI: Using IOAPIC for interrupt routing
[    0.504148] ACPI: No dock devices found.
[    0.504247] HEST: Table not found.
[    0.504344] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.504897] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
[    0.505573] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.505676] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.505779] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
[    0.505937] pci_root PNP0A08:00: host bridge window [mem 0x000d0000-0x000d3fff]
[    0.506091] pci_root PNP0A08:00: host bridge window [mem 0x000d4000-0x000d7fff]
[    0.506245] pci_root PNP0A08:00: host bridge window [mem 0x000d8000-0x000dbfff]
[    0.506397] pci_root PNP0A08:00: host bridge window [mem 0x000dc000-0x000dffff]
[    0.506549] pci_root PNP0A08:00: host bridge window [mem 0x000e0000-0x000e3fff]
[    0.506703] pci_root PNP0A08:00: host bridge window [mem 0x000e4000-0x000e7fff]
[    0.506859] pci_root PNP0A08:00: host bridge window [mem 0xbf200000-0xfeafffff]
[    0.507011] pci_root PNP0A08:00: host bridge window [mem 0xfed40000-0xfed44fff]
[    0.507175] pci 0000:00:00.0: [8086:0104] type 0 class 0x000600
[    0.507312] pci 0000:00:02.0: [8086:0116] type 0 class 0x000300
[    0.507422] pci 0000:00:02.0: reg 10: [mem 0xf6800000-0xf6bfffff 64bit]
[    0.507529] pci 0000:00:02.0: reg 18: [mem 0xe0000000-0xefffffff 64bit pref]
[    0.507635] pci 0000:00:02.0: reg 20: [io  0xf000-0xf03f]
[    0.507788] pci 0000:00:16.0: [8086:1c3a] type 0 class 0x000780
[    0.507913] pci 0000:00:16.0: reg 10: [mem 0xf7f0a000-0xf7f0a00f 64bit]
[    0.508078] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    0.508182] pci 0000:00:16.0: PME# disabled
[    0.508315] pci 0000:00:1a.0: [8086:1c2d] type 0 class 0x000c03
[    0.508436] pci 0000:00:1a.0: reg 10: [mem 0xf7f08000-0xf7f083ff]
[    0.508613] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    0.508716] pci 0000:00:1a.0: PME# disabled
[    0.508841] pci 0000:00:1b.0: [8086:1c20] type 0 class 0x000403
[    0.508959] pci 0000:00:1b.0: reg 10: [mem 0xf7f00000-0xf7f03fff 64bit]
[    0.510503] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.510607] pci 0000:00:1b.0: PME# disabled
[    0.510726] pci 0000:00:1c.0: [8086:1c10] type 1 class 0x000604
[    0.510895] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.510999] pci 0000:00:1c.0: PME# disabled
[    0.511120] pci 0000:00:1c.1: [8086:1c12] type 1 class 0x000604
[    0.511285] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.511388] pci 0000:00:1c.1: PME# disabled
[    0.511509] pci 0000:00:1c.3: [8086:1c16] type 1 class 0x000604
[    0.511674] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    0.511779] pci 0000:00:1c.3: PME# disabled
[    0.511902] pci 0000:00:1c.4: [8086:1c18] type 1 class 0x000604
[    0.512069] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    0.512171] pci 0000:00:1c.4: PME# disabled
[    0.512295] pci 0000:00:1c.7: [8086:1c1e] type 1 class 0x000604
[    0.512458] pci 0000:00:1c.7: PME# supported from D0 D3hot D3cold
[    0.512562] pci 0000:00:1c.7: PME# disabled
[    0.512688] pci 0000:00:1d.0: [8086:1c26] type 0 class 0x000c03
[    0.512810] pci 0000:00:1d.0: reg 10: [mem 0xf7f07000-0xf7f073ff]
[    0.512991] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    0.513095] pci 0000:00:1d.0: PME# disabled
[    0.513217] pci 0000:00:1f.0: [8086:1c4b] type 0 class 0x000601
[    0.513439] pci 0000:00:1f.2: [8086:1c03] type 0 class 0x000106
[    0.513559] pci 0000:00:1f.2: reg 10: [io  0xf0b0-0xf0b7]
[    0.513665] pci 0000:00:1f.2: reg 14: [io  0xf0a0-0xf0a3]
[    0.513772] pci 0000:00:1f.2: reg 18: [io  0xf090-0xf097]
[    0.513882] pci 0000:00:1f.2: reg 1c: [io  0xf080-0xf083]
[    0.513988] pci 0000:00:1f.2: reg 20: [io  0xf060-0xf07f]
[    0.514095] pci 0000:00:1f.2: reg 24: [mem 0xf7f06000-0xf7f067ff]
[    0.514230] pci 0000:00:1f.2: PME# supported from D3hot
[    0.514332] pci 0000:00:1f.2: PME# disabled
[    0.514446] pci 0000:00:1f.3: [8086:1c22] type 0 class 0x000c05
[    0.514562] pci 0000:00:1f.3: reg 10: [mem 0xf7f05000-0xf7f050ff 64bit]
[    0.514685] pci 0000:00:1f.3: reg 20: [io  0xf040-0xf05f]
[    0.514866] pci 0000:00:1c.0: PCI bridge to [bus 03-04]
[    0.514970] pci 0000:00:1c.0:   bridge window [io  0xf000-0x0000] (disabled)
[    0.515078] pci 0000:00:1c.0:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
[    0.515236] pci 0000:00:1c.0:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    0.515459] pci 0000:05:00.0: [10ec:8136] type 0 class 0x000200
[    0.515578] pci 0000:05:00.0: reg 10: [io  0xe000-0xe0ff]
[    0.515712] pci 0000:05:00.0: reg 18: [mem 0xf1104000-0xf1104fff 64bit pref]
[    0.515837] pci 0000:05:00.0: reg 20: [mem 0xf1100000-0xf1103fff 64bit pref]
[    0.516004] pci 0000:05:00.0: supports D1 D2
[    0.516102] pci 0000:05:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.516208] pci 0000:05:00.0: PME# disabled
[    0.517876] pci 0000:00:1c.1: PCI bridge to [bus 05-06]
[    0.518022] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.518123] pci 0000:00:1c.1:   bridge window [mem 0xfff00000-0x000fffff] (disabled)
[    0.518283] pci 0000:00:1c.1:   bridge window [mem 0xf1100000-0xf11fffff 64bit pref]
[    0.518633] pci 0000:09:00.0: [8086:008a] type 0 class 0x000280
[    0.518895] pci 0000:09:00.0: reg 10: [mem 0xf7e00000-0xf7e01fff 64bit]
[    0.519570] pci 0000:09:00.0: PME# supported from D0 D3hot D3cold
[    0.519704] pci 0000:09:00.0: PME# disabled
[    0.521980] pci 0000:00:1c.3: PCI bridge to [bus 09-0a]
[    0.522097] pci 0000:00:1c.3:   bridge window [io  0xf000-0x0000] (disabled)
[    0.522202] pci 0000:00:1c.3:   bridge window [mem 0xf7e00000-0xf7efffff]
[    0.522309] pci 0000:00:1c.3:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    0.522534] pci 0000:0b:00.0: [1033:0194] type 0 class 0x000c03
[    0.522660] pci 0000:0b:00.0: reg 10: [mem 0xf7d00000-0xf7d01fff 64bit]
[    0.522875] pci 0000:0b:00.0: PME# supported from D0 D3hot D3cold
[    0.522980] pci 0000:0b:00.0: PME# disabled
[    0.524860] pci 0000:00:1c.4: PCI bridge to [bus 0b-0c]
[    0.525006] pci 0000:00:1c.4:   bridge window [io  0xf000-0x0000] (disabled)
[    0.525110] pci 0000:00:1c.4:   bridge window [mem 0xf7d00000-0xf7dfffff]
[    0.525217] pci 0000:00:1c.4:   bridge window [mem 0xfff00000-0x000fffff pref] (disabled)
[    0.525419] pci 0000:00:1c.7: PCI bridge to [bus 11-1f]
[    0.525521] pci 0000:00:1c.7:   bridge window [io  0xc000-0xdfff]
[    0.525624] pci 0000:00:1c.7:   bridge window [mem 0xf6c00000-0xf7cfffff]
[    0.525732] pci 0000:00:1c.7:   bridge window [mem 0xf0000000-0xf10fffff 64bit pref]
[    0.525915] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.526224] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP01._PRT]
[    0.526371] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP02._PRT]
[    0.526518] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP04._PRT]
[    0.526663] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP05._PRT]
[    0.526813] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP08._PRT]
[    0.527085]  pci0000:00: Requesting ACPI _OSC control (0x1d)
[    0.527345]  pci0000:00: ACPI _OSC control (0x1d) granted
[    0.531992] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14 15)
[    0.532582] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 *5 6 10 11 12 14 15)
[    0.533177] ACPI: PCI Interrupt Link [LNKC] (IRQs *3 4 5 6 10 11 12 14 15)
[    0.533761] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 11 12 14 15)
[    0.534352] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.535076] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.535797] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 *5 6 10 11 12 14 15)
[    0.536388] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 *5 6 10 11 12 14 15)
[    0.537023] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.537184] vgaarb: loaded
[    0.537357] SCSI subsystem initialized
[    0.537505] libata version 3.00 loaded.
[    0.537650] usbcore: registered new interface driver usbfs
[    0.537763] usbcore: registered new interface driver hub
[    0.537896] usbcore: registered new device driver usb
[    0.538060] PCI: Using ACPI for IRQ routing
[    0.538159] PCI: pci_cache_line_size set to 64 bytes
[    0.538391] reserve RAM buffer: 000000000009d400 - 000000000009ffff 
[    0.538444] reserve RAM buffer: 00000000b9ce3000 - 00000000bbffffff 
[    0.538586] reserve RAM buffer: 00000000b9f92000 - 00000000bbffffff 
[    0.538730] reserve RAM buffer: 00000000ba3a9000 - 00000000bbffffff 
[    0.538877] reserve RAM buffer: 0000000100600000 - 0000000103ffffff 
[    0.539114] NetLabel: Initializing
[    0.539300] NetLabel:  domain hash size = 128
[    0.539398] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.539507] NetLabel:  unlabeled traffic allowed by default
[    0.539663] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    0.540128] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    0.542245] Switching to clocksource hpet
[    0.542807] Switched to NOHz mode on CPU #0
[    0.542933] Switched to NOHz mode on CPU #2
[    0.542939] Switched to NOHz mode on CPU #3
[    0.542955] Switched to NOHz mode on CPU #1
[    0.550650] pnp: PnP ACPI init
[    0.550768] ACPI: bus type pnp registered
[    0.551178] pnp 00:00: [bus 00-3e]
[    0.551276] pnp 00:00: [io  0x0000-0x0cf7 window]
[    0.551375] pnp 00:00: [io  0x0cf8-0x0cff]
[    0.551482] pnp 00:00: [io  0x0d00-0xffff window]
[    0.551582] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    0.551683] pnp 00:00: [mem 0x000c0000-0x000c3fff window]
[    0.551783] pnp 00:00: [mem 0x000c4000-0x000c7fff window]
[    0.551883] pnp 00:00: [mem 0x000c8000-0x000cbfff window]
[    0.551983] pnp 00:00: [mem 0x000cc000-0x000cffff window]
[    0.552083] pnp 00:00: [mem 0x000d0000-0x000d3fff window]
[    0.552183] pnp 00:00: [mem 0x000d4000-0x000d7fff window]
[    0.552283] pnp 00:00: [mem 0x000d8000-0x000dbfff window]
[    0.552390] pnp 00:00: [mem 0x000dc000-0x000dffff window]
[    0.552490] pnp 00:00: [mem 0x000e0000-0x000e3fff window]
[    0.552589] pnp 00:00: [mem 0x000e4000-0x000e7fff window]
[    0.552689] pnp 00:00: [mem 0x000e8000-0x000ebfff window]
[    0.552789] pnp 00:00: [mem 0x000ec000-0x000effff window]
[    0.552889] pnp 00:00: [mem 0x000f0000-0x000fffff window]
[    0.552988] pnp 00:00: [mem 0xbf200000-0xfeafffff window]
[    0.553088] pnp 00:00: [mem 0xfed40000-0xfed44fff window]
[    0.553267] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    0.553440] pnp 00:01: [io  0x0000-0x001f]
[    0.553537] pnp 00:01: [io  0x0081-0x0091]
[    0.553635] pnp 00:01: [io  0x0093-0x009f]
[    0.553732] pnp 00:01: [io  0x00c0-0x00df]
[    0.553830] pnp 00:01: [dma 4]
[    0.553957] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.554066] pnp 00:02: [mem 0xff000000-0xffffffff]
[    0.554188] pnp 00:02: Plug and Play ACPI device, IDs INT0800 (active)
[    0.554375] pnp 00:03: [mem 0xfed00000-0xfed003ff]
[    0.554509] pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.554622] pnp 00:04: [io  0x002e-0x002f]
[    0.554719] pnp 00:04: [io  0x004e-0x004f]
[    0.554815] pnp 00:04: [io  0x0061]
[    0.554914] pnp 00:04: [io  0x0063]
[    0.555010] pnp 00:04: [io  0x0065]
[    0.555106] pnp 00:04: [io  0x0067]
[    0.555202] pnp 00:04: [io  0x0070]
[    0.555298] pnp 00:04: [io  0x0080]
[    0.555403] pnp 00:04: [io  0x0092]
[    0.555499] pnp 00:04: [io  0x00b2-0x00b3]
[    0.555596] pnp 00:04: [io  0x0680-0x069f]
[    0.555692] pnp 00:04: [io  0x1000-0x100f]
[    0.555790] pnp 00:04: [io  0xffff]
[    0.555886] pnp 00:04: [io  0xffff]
[    0.555982] pnp 00:04: [io  0x0400-0x0453]
[    0.556080] pnp 00:04: [io  0x0458-0x047f]
[    0.556177] pnp 00:04: [io  0x0500-0x057f]
[    0.556275] pnp 00:04: [io  0x164e-0x164f]
[    0.556429] system 00:04: [io  0x0680-0x069f] has been reserved
[    0.556530] system 00:04: [io  0x1000-0x100f] has been reserved
[    0.556632] system 00:04: [io  0xffff] has been reserved
[    0.556732] system 00:04: [io  0xffff] has been reserved
[    0.556832] system 00:04: [io  0x0400-0x0453] has been reserved
[    0.556932] system 00:04: [io  0x0458-0x047f] has been reserved
[    0.557034] system 00:04: [io  0x0500-0x057f] has been reserved
[    0.557135] system 00:04: [io  0x164e-0x164f] has been reserved
[    0.558626] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.558734] pnp 00:05: [io  0x0070-0x0077]
[    0.558839] pnp 00:05: [irq 8]
[    0.558961] pnp 00:05: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.559092] pnp 00:06: [io  0x0454-0x0457]
[    0.559226] system 00:06: [io  0x0454-0x0457] has been reserved
[    0.559328] system 00:06: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
[    0.559495] pnp 00:07: [io  0x00f0-0x00ff]
[    0.559597] pnp 00:07: [irq 13]
[    0.559720] pnp 00:07: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.559837] pnp 00:08: [io  0x0010-0x001f]
[    0.559934] pnp 00:08: [io  0x0022-0x003f]
[    0.560032] pnp 00:08: [io  0x0044-0x005f]
[    0.560129] pnp 00:08: [io  0x0068-0x006f]
[    0.560226] pnp 00:08: [io  0x0072-0x007f]
[    0.560323] pnp 00:08: [io  0x0080]
[    0.560427] pnp 00:08: [io  0x0084-0x0086]
[    0.560525] pnp 00:08: [io  0x0088]
[    0.560621] pnp 00:08: [io  0x008c-0x008e]
[    0.560719] pnp 00:08: [io  0x0090-0x009f]
[    0.560816] pnp 00:08: [io  0x00a2-0x00bf]
[    0.560913] pnp 00:08: [io  0x00e0-0x00ef]
[    0.561010] pnp 00:08: [io  0x04d0-0x04d1]
[    0.561106] pnp 00:08: [mem 0xfe800000-0xfe802fff]
[    0.561249] system 00:08: [io  0x04d0-0x04d1] has been reserved
[    0.561353] system 00:08: [mem 0xfe800000-0xfe802fff] has been reserved
[    0.561463] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.561582] pnp 00:09: [irq 12]
[    0.561704] pnp 00:09: Plug and Play ACPI device, IDs DLL04b0 SYN0600 SYN0002 PNP0f13 (active)
[    0.561873] pnp 00:0a: [io  0x0060]
[    0.561970] pnp 00:0a: [io  0x0064]
[    0.562067] pnp 00:0a: [io  0x0062]
[    0.562163] pnp 00:0a: [io  0x0066]
[    0.562263] pnp 00:0a: [irq 1]
[    0.562394] pnp 00:0a: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.562722] pnp 00:0b: [mem 0xfed1c000-0xfed1ffff]
[    0.562821] pnp 00:0b: [mem 0xfed10000-0xfed17fff]
[    0.562922] pnp 00:0b: [mem 0xfed18000-0xfed18fff]
[    0.563021] pnp 00:0b: [mem 0xfed19000-0xfed19fff]
[    0.563120] pnp 00:0b: [mem 0xf8000000-0xfbffffff]
[    0.563218] pnp 00:0b: [mem 0xfed20000-0xfed3ffff]
[    0.563317] pnp 00:0b: [mem 0xfed90000-0xfed93fff]
[    0.563423] pnp 00:0b: [mem 0xfed45000-0xfed8ffff]
[    0.563522] pnp 00:0b: [mem 0xff000000-0xffffffff]
[    0.563619] pnp 00:0b: [mem 0xfee00000-0xfeefffff]
[    0.563718] pnp 00:0b: [mem 0xbf200000-0xbf200fff]
[    0.563874] system 00:0b: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.563977] system 00:0b: [mem 0xfed10000-0xfed17fff] has been reserved
[    0.564080] system 00:0b: [mem 0xfed18000-0xfed18fff] has been reserved
[    0.564184] system 00:0b: [mem 0xfed19000-0xfed19fff] has been reserved
[    0.564287] system 00:0b: [mem 0xf8000000-0xfbffffff] has been reserved
[    0.564400] system 00:0b: [mem 0xfed20000-0xfed3ffff] has been reserved
[    0.564503] system 00:0b: [mem 0xfed90000-0xfed93fff] has been reserved
[    0.564606] system 00:0b: [mem 0xfed45000-0xfed8ffff] has been reserved
[    0.564708] system 00:0b: [mem 0xff000000-0xffffffff] has been reserved
[    0.564811] system 00:0b: [mem 0xfee00000-0xfeefffff] could not be reserved
[    0.564914] system 00:0b: [mem 0xbf200000-0xbf200fff] has been reserved
[    0.565018] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.565278] pnp 00:0c: [mem 0x20000000-0x201fffff]
[    0.565385] pnp 00:0c: [mem 0x40000000-0x401fffff]
[    0.565544] system 00:0c: [mem 0x20000000-0x201fffff] has been reserved
[    0.565647] system 00:0c: [mem 0x40000000-0x401fffff] has been reserved
[    0.565749] system 00:0c: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.565902] pnp: PnP ACPI: found 13 devices
[    0.565999] ACPI: ACPI bus type pnp unregistered
[    0.572612] pci 0000:00:1c.0: PCI bridge to [bus 03-04]
[    0.572710] pci 0000:00:1c.0:   bridge window [io  disabled]
[    0.572814] pci 0000:00:1c.0:   bridge window [mem disabled]
[    0.572916] pci 0000:00:1c.0:   bridge window [mem pref disabled]
[    0.573022] pci 0000:00:1c.1: PCI bridge to [bus 05-06]
[    0.573123] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.573227] pci 0000:00:1c.1:   bridge window [mem disabled]
[    0.573330] pci 0000:00:1c.1:   bridge window [mem 0xf1100000-0xf11fffff 64bit pref]
[    0.573495] pci 0000:00:1c.3: PCI bridge to [bus 09-0a]
[    0.573595] pci 0000:00:1c.3:   bridge window [io  disabled]
[    0.573699] pci 0000:00:1c.3:   bridge window [mem 0xf7e00000-0xf7efffff]
[    0.573805] pci 0000:00:1c.3:   bridge window [mem pref disabled]
[    0.573912] pci 0000:00:1c.4: PCI bridge to [bus 0b-0c]
[    0.574010] pci 0000:00:1c.4:   bridge window [io  disabled]
[    0.574114] pci 0000:00:1c.4:   bridge window [mem 0xf7d00000-0xf7dfffff]
[    0.574220] pci 0000:00:1c.4:   bridge window [mem pref disabled]
[    0.574326] pci 0000:00:1c.7: PCI bridge to [bus 11-1f]
[    0.574434] pci 0000:00:1c.7:   bridge window [io  0xc000-0xdfff]
[    0.574539] pci 0000:00:1c.7:   bridge window [mem 0xf6c00000-0xf7cfffff]
[    0.574644] pci 0000:00:1c.7:   bridge window [mem 0xf0000000-0xf10fffff 64bit pref]
[    0.574816] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.574922] pci 0000:00:1c.0: setting latency timer to 64
[    0.575032] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    0.575137] pci 0000:00:1c.1: setting latency timer to 64
[    0.575247] pci 0000:00:1c.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    0.575359] pci 0000:00:1c.3: setting latency timer to 64
[    0.575463] pci 0000:00:1c.4: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.575568] pci 0000:00:1c.4: setting latency timer to 64
[    0.575675] pci 0000:00:1c.7: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    0.575779] pci 0000:00:1c.7: setting latency timer to 64
[    0.575881] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.575981] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.576081] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.576183] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000d3fff]
[    0.576284] pci_bus 0000:00: resource 8 [mem 0x000d4000-0x000d7fff]
[    0.576393] pci_bus 0000:00: resource 9 [mem 0x000d8000-0x000dbfff]
[    0.576495] pci_bus 0000:00: resource 10 [mem 0x000dc000-0x000dffff]
[    0.576597] pci_bus 0000:00: resource 11 [mem 0x000e0000-0x000e3fff]
[    0.576698] pci_bus 0000:00: resource 12 [mem 0x000e4000-0x000e7fff]
[    0.576800] pci_bus 0000:00: resource 13 [mem 0xbf200000-0xfeafffff]
[    0.576901] pci_bus 0000:00: resource 14 [mem 0xfed40000-0xfed44fff]
[    0.577003] pci_bus 0000:05: resource 0 [io  0xe000-0xefff]
[    0.577103] pci_bus 0000:05: resource 2 [mem 0xf1100000-0xf11fffff 64bit pref]
[    0.577256] pci_bus 0000:09: resource 1 [mem 0xf7e00000-0xf7efffff]
[    0.577363] pci_bus 0000:0b: resource 1 [mem 0xf7d00000-0xf7dfffff]
[    0.577465] pci_bus 0000:11: resource 0 [io  0xc000-0xdfff]
[    0.577565] pci_bus 0000:11: resource 1 [mem 0xf6c00000-0xf7cfffff]
[    0.577667] pci_bus 0000:11: resource 2 [mem 0xf0000000-0xf10fffff 64bit pref]
[    0.577839] NET: Registered protocol family 2
[    0.578078] IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.579241] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
[    0.581360] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.581710] TCP: Hash tables configured (established 524288 bind 65536)
[    0.581812] TCP reno registered
[    0.581918] UDP hash table entries: 2048 (order: 4, 65536 bytes)
[    0.582041] UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
[    0.582237] NET: Registered protocol family 1
[    0.582354] pci 0000:00:02.0: Boot video device
[    0.818125] PCI: CLS 64 bytes, default 64
[    0.818292] Trying to unpack rootfs image as initramfs...
[    1.140879] Freeing initrd memory: 14604k freed
[    1.143012] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.143119] Placing 64MB software IO TLB between ffff880017600000 - ffff88001b600000
[    1.143273] software IO TLB at phys 0x17600000 - 0x1b600000
[    1.144072] Intel AES-NI instructions are not detected.
[    1.144281] audit: initializing netlink socket (disabled)
[    1.144390] type=2000 audit(1308736860.954:1): initialized
[    1.158281] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.160565] VFS: Disk quotas dquot_6.5.2
[    1.160707] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.161285] msgmni has been set to 5712
[    1.161432] SELinux:  Registering netfilter hooks
[    1.161802] NET: Registered protocol family 38
[    1.161949] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    1.162130] io scheduler noop registered
[    1.162229] io scheduler deadline registered
[    1.162365] io scheduler cfq registered (default)
[    1.162576] pcieport 0000:00:1c.0: setting latency timer to 64
[    1.162726] pcieport 0000:00:1c.0: irq 40 for MSI/MSI-X
[    1.162903] pcieport 0000:00:1c.1: setting latency timer to 64
[    1.163045] pcieport 0000:00:1c.1: irq 41 for MSI/MSI-X
[    1.163220] pcieport 0000:00:1c.3: setting latency timer to 64
[    1.163362] pcieport 0000:00:1c.3: irq 42 for MSI/MSI-X
[    1.163543] pcieport 0000:00:1c.4: setting latency timer to 64
[    1.163686] pcieport 0000:00:1c.4: irq 43 for MSI/MSI-X
[    1.163866] pcieport 0000:00:1c.7: setting latency timer to 64
[    1.164007] pcieport 0000:00:1c.7: irq 44 for MSI/MSI-X
[    1.164218] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
[    1.164326] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
[    1.164445] pcieport 0000:00:1c.1: Signaling PME through PCIe PME interrupt
[    1.164562] pci 0000:05:00.0: Signaling PME through PCIe PME interrupt
[    1.164668] pcie_pme 0000:00:1c.1:pcie01: service driver pcie_pme loaded
[    1.164787] pcieport 0000:00:1c.3: Signaling PME through PCIe PME interrupt
[    1.164890] pci 0000:09:00.0: Signaling PME through PCIe PME interrupt
[    1.164994] pcie_pme 0000:00:1c.3:pcie01: service driver pcie_pme loaded
[    1.165113] pcieport 0000:00:1c.4: Signaling PME through PCIe PME interrupt
[    1.165216] pci 0000:0b:00.0: Signaling PME through PCIe PME interrupt
[    1.165321] pcie_pme 0000:00:1c.4:pcie01: service driver pcie_pme loaded
[    1.165441] pcieport 0000:00:1c.7: Signaling PME through PCIe PME interrupt
[    1.165561] pcie_pme 0000:00:1c.7:pcie01: service driver pcie_pme loaded
[    1.165677] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.165821] pciehp 0000:00:1c.7:pcie04: HPC vendor_id 8086 device_id 1c1e ss_vid 1028 ss_did 4b0
[    1.165996] pciehp 0000:00:1c.7:pcie04: service driver pciehp loaded
[    1.166105] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    1.167609] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    1.168109] intel_idle: MWAIT substates: 0x21120
[    1.168208] intel_idle: v0.4 model 0x2A
[    1.168304] intel_idle: lapic_timer_reliable_states 0xffffffff
[    1.168494] ACPI: Deprecated procfs I/F for AC is loaded, please retry with CONFIG_ACPI_PROCFS_POWER cleared
[    1.168700] ACPI: AC Adapter [AC] (on-line)
[    1.168914] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input0
[    1.186458] ACPI: Lid Switch [LID0]
[    1.186650] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input1
[    1.186807] ACPI: Power Button [PWRB]
[    1.186948] input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input2
[    1.187104] ACPI: Sleep Button [SBTN]
[    1.187245] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
[    1.187399] ACPI: Power Button [PWRF]
[    1.187716] ACPI: acpi_idle yielding to intel_idle
[    1.196667] thermal LNXTHERM:00: registered as thermal_zone0
[    1.196768] ACPI: Thermal Zone [THM] (54 C)
[    1.196878] ERST: Table is not found!
[    1.197087] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.210991] ACPI: Deprecated procfs I/F for battery is loaded, please retry with CONFIG_ACPI_PROCFS_POWER cleared
[    1.211154] ACPI: Battery Slot [BAT0] (battery present)
[    1.215062] Non-volatile memory driver v1.3
[    1.215161] Linux agpgart interface v0.103
[    1.215338] agpgart-intel 0000:00:00.0: Intel Sandybridge Chipset
[    1.215544] agpgart-intel 0000:00:00.0: detected gtt size: 2097152K total, 262144K mappable
[    1.216782] agpgart-intel 0000:00:00.0: detected 65536K stolen memory
[    1.216997] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xe0000000
[    1.218374] brd: module loaded
[    1.219045] loop: module loaded
[    1.219224] ahci 0000:00:1f.2: version 3.0
[    1.219332] ahci 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    1.219488] ahci 0000:00:1f.2: irq 45 for MSI/MSI-X
[    1.219613] ahci: SSS flag set, parallel bus scan disabled
[    1.230428] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x31 impl SATA mode
[    1.230624] ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pio slum part ems sxs apst 
[    1.230784] ahci 0000:00:1f.2: setting latency timer to 64
[    1.235111] scsi0 : ahci
[    1.235298] scsi1 : ahci
[    1.235485] scsi2 : ahci
[    1.235651] scsi3 : ahci
[    1.235817] scsi4 : ahci
[    1.235987] scsi5 : ahci
[    1.236491] ata1: SATA max UDMA/133 abar m2048@0xf7f06000 port 0xf7f06100 irq 45
[    1.236645] ata2: DUMMY
[    1.236739] ata3: DUMMY
[    1.236833] ata4: DUMMY
[    1.236928] ata5: SATA max UDMA/133 abar m2048@0xf7f06000 port 0xf7f06300 irq 45
[    1.237082] ata6: SATA max UDMA/133 abar m2048@0xf7f06000 port 0xf7f06380 irq 45
[    1.237341] Fixed MDIO Bus: probed
[    1.237529] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.237646] ehci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    1.237763] ehci_hcd 0000:00:1a.0: setting latency timer to 64
[    1.237866] ehci_hcd 0000:00:1a.0: EHCI Host Controller
[    1.238021] ehci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
[    1.239458] ehci_hcd 0000:00:1a.0: debug port 2
[    1.243451] ehci_hcd 0000:00:1a.0: cache line size of 64 is not supported
[    1.243571] ehci_hcd 0000:00:1a.0: irq 16, io mem 0xf7f08000
[    1.253365] ehci_hcd 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    1.253529] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.253632] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.253784] usb usb1: Product: EHCI Host Controller
[    1.253883] usb usb1: Manufacturer: Linux 2.6.38.8-32.fc15.x86_64 ehci_hcd
[    1.253986] usb usb1: SerialNumber: 0000:00:1a.0
[    1.254198] hub 1-0:1.0: USB hub found
[    1.254298] hub 1-0:1.0: 2 ports detected
[    1.254487] ehci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    1.254602] ehci_hcd 0000:00:1d.0: setting latency timer to 64
[    1.254705] ehci_hcd 0000:00:1d.0: EHCI Host Controller
[    1.254846] ehci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    1.255439] ehci_hcd 0000:00:1d.0: debug port 2
[    1.259450] ehci_hcd 0000:00:1d.0: cache line size of 64 is not supported
[    1.259565] ehci_hcd 0000:00:1d.0: irq 23, io mem 0xf7f07000
[    1.269340] ehci_hcd 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    1.269505] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    1.269608] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.269761] usb usb2: Product: EHCI Host Controller
[    1.269860] usb usb2: Manufacturer: Linux 2.6.38.8-32.fc15.x86_64 ehci_hcd
[    1.269963] usb usb2: SerialNumber: 0000:00:1d.0
[    1.270160] hub 2-0:1.0: USB hub found
[    1.270259] hub 2-0:1.0: 2 ports detected
[    1.270436] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.270549] uhci_hcd: USB Universal Host Controller Interface driver
[    1.270713] i8042: PNP: PS/2 Controller [PNP0303:KBC,PNP0f13:PS2] at 0x60,0x64 irq 1,12
[    1.273218] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.273327] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.273525] mousedev: PS/2 mouse device common for all mice
[    1.273836] rtc_cmos 00:05: RTC can wake from S4
[    1.274008] rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
[    1.274136] rtc0: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
[    1.274347] device-mapper: uevent: version 1.0.3
[    1.274521] device-mapper: ioctl: 4.19.1-ioctl (2011-01-07) initialised: dm-devel@redhat.com
[    1.274864] cpuidle: using governor ladder
[    1.275176] cpuidle: using governor menu
[    1.275430] usbcore: registered new interface driver usbhid
[    1.275531] usbhid: USB HID core driver
[    1.275658] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[    1.275885] ip_tables: (C) 2000-2006 Netfilter Core Team
[    1.275995] TCP cubic registered
[    1.276091] Initializing XFRM netlink socket
[    1.276201] NET: Registered protocol family 17
[    1.276324] Registering the dns_resolver key type
[    1.276525] PM: Hibernation image not present or could not be loaded.
[    1.276635] registered taskstats version 1
[    1.276856] IMA: No TPM chip found, activating TPM-bypass!
[    1.277270]   Magic number: 15:672:22
[    1.277462] rtc_cmos 00:05: setting system clock to 2011-06-22 10:01:02 UTC (1308736862)
[    1.277684] Initalizing network drop monitor service
[    1.289756] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input4
[    1.541007] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.547670] ata1.00: ACPI cmd 00/00:00:00:00:00:a0 (NOP) rejected by device (Stat=0x51 Err=0x04)
[    1.548050] ata1.00: ATA-8: SAMSUNG HM321HI, 2AJ10003, max UDMA/133
[    1.548167] ata1.00: 625142448 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    1.554984] ata1.00: ACPI cmd 00/00:00:00:00:00:a0 (NOP) rejected by device (Stat=0x51 Err=0x04)
[    1.555315] ata1.00: configured for UDMA/133
[    1.555970] usb 1-1: new high speed USB device using ehci_hcd and address 2
[    1.557123] scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG HM321HI  2AJ1 PQ: 0 ANSI: 5
[    1.557487] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    1.557606] sd 0:0:0:0: [sda] 625142448 512-byte logical blocks: (320 GB/298 GiB)
[    1.557901] sd 0:0:0:0: [sda] Write Protect is off
[    1.558001] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.558135] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.559730] alps.c: Enabled hardware quirk, falling back to psmouse-core
[    1.573115] input: ImPS/2 ALPS GlidePoint as /devices/platform/i8042/serio1/input/input5
[    1.627416]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 >
[    1.628061] sd 0:0:0:0: [sda] Attached SCSI disk
[    1.670220] usb 1-1: New USB device found, idVendor=8087, idProduct=0024
[    1.670346] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    1.670792] hub 1-1:1.0: USB hub found
[    1.670959] hub 1-1:1.0: 6 ports detected
[    1.773619] usb 2-1: new high speed USB device using ehci_hcd and address 2
[    1.861558] ata5: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.887894] usb 2-1: New USB device found, idVendor=8087, idProduct=0024
[    1.888021] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    1.888490] hub 2-1:1.0: USB hub found
[    1.888746] hub 2-1:1.0: 8 ports detected
[    1.952600] usb 1-1.4: new full speed USB device using ehci_hcd and address 3
[    1.974478] ata5.00: ATA-9: OCZ-VERTEX3, 2.02, max UDMA/133
[    1.974614] ata5.00: 234441648 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    2.042747] usb 1-1.4: New USB device found, idVendor=8086, idProduct=0189
[    2.042882] usb 1-1.4: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    2.117354] usb 1-1.5: new high speed USB device using ehci_hcd and address 4
[    2.125543] ata5.00: configured for UDMA/133
[    2.125775] scsi 4:0:0:0: Direct-Access     ATA      OCZ-VERTEX3      2.02 PQ: 0 ANSI: 5
[    2.126102] sd 4:0:0:0: [sdb] 234441648 512-byte logical blocks: (120 GB/111 GiB)
[    2.126153] sd 4:0:0:0: Attached scsi generic sg1 type 0
[    2.126490] sd 4:0:0:0: [sdb] Write Protect is off
[    2.126589] sd 4:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    2.126719] sd 4:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.143060] Refined TSC clocksource calibration: 2095.240 MHz.
[    2.143205] Switching to clocksource tsc
[    2.148484]  sdb: sdb1 sdb2 sdb3
[    2.148962] sd 4:0:0:0: [sdb] Attached SCSI disk
[    2.319963] usb 1-1.5: New USB device found, idVendor=1bcf, idProduct=2880
[    2.320103] usb 1-1.5: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    2.320256] usb 1-1.5: Product: Laptop_Integrated_Webcam_HD
[    2.320355] usb 1-1.5: Manufacturer: CN0T3NPC72487149A78ZA00
[    2.430700] ata6: SATA link down (SStatus 0 SControl 300)
[    2.432876] Freeing unused kernel memory: 948k freed
[    2.433096] Write protecting the kernel read-only data: 10240k
[    2.439586] Freeing unused kernel memory: 1524k freed
[    2.446886] Freeing unused kernel memory: 1724k freed
[    2.474303] dracut: dracut-009-11.fc15
[    2.482062] dracut: rd.luks=0: removing cryptoluks activation
[    2.484343] dracut: rd.lvm=0: removing LVM activation
[    2.489332] udev[119]: starting version 167
[    2.529435] [drm] Initialized drm 1.1.0 20060810
[    2.546809] i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    2.546917] i915 0000:00:02.0: setting latency timer to 64
[    2.565474] usb 2-1.6: new high speed USB device using ehci_hcd and address 3
[    2.592842] i915 0000:00:02.0: irq 46 for MSI/MSI-X
[    2.592949] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    2.593053] [drm] Driver supports precise vblank timestamp query.
[    2.693247] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
[    2.737971] fbcon: inteldrmfb (fb0) is primary device
[    2.797986] Console: switching to colour frame buffer device 170x48
[    2.801819] fb0: inteldrmfb frame buffer device
[    2.801848] drm: registered panic notifier
[    2.803375] acpi device:33: registered as cooling_device4
[    2.803782] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A08:00/LNXVIDEO:00/input/input6
[    2.803931] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post: no)
[    2.804122] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
[    2.817975] dracut: Starting plymouth daemon
[    2.896753] usb 2-1.6: New USB device found, idVendor=0bda, idProduct=0138
[    2.896848] usb 2-1.6: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    2.896913] usb 2-1.6: Product: USB2.0-CRW
[    2.896948] usb 2-1.6: Manufacturer: Generic
[    2.896976] usb 2-1.6: SerialNumber: 20090516388200000
[    2.905691] usbcore: registered new interface driver uas
[    2.909469] Initializing USB Mass Storage driver...
[    2.909602] scsi6 : usb-storage 2-1.6:1.0
[    2.909752] usbcore: registered new interface driver usb-storage
[    2.909810] USB Mass Storage support registered.
[    2.930897] dracut: rd.dm=0: removing DM RAID activation
[    2.934053] dracut: rd.md=0: removing MD RAID activation
[    3.583000] EXT4-fs (sdb2): mounted filesystem with ordered data mode. Opts: (null)
[    3.601054] dracut: Checking filesystems
[    3.601078] dracut: fsck -T -t noopts=_netdev -A -a
[    3.605961] dracut: _Fedora-15-x86_6: clean, 127634/835584 files, 2829300/3328000 blocks
[    3.606083] dracut: Remounting /dev/disk/by-uuid/da48811c-7aeb-4514-8c75-a56a82bba9fa with -o ro,
[    3.608859] EXT4-fs (sdb2): mounted filesystem with ordered data mode. Opts: (null)
[    3.611325] dracut: Mounted root filesystem /dev/sdb2
[    3.682043] dracut: Switching root
[    3.727020] type=1404 audit(1308736864.952:2): enforcing=1 old_enforcing=0 auid=4294967295 ses=4294967295
[    3.762988] SELinux: 2048 avtab hash slots, 220461 rules.
[    3.841753] SELinux: 2048 avtab hash slots, 220461 rules.
[    3.910380] scsi 6:0:0:0: Direct-Access     Generic- Multi-Card       1.00 PQ: 0 ANSI: 0 CCS
[    3.910876] sd 6:0:0:0: Attached scsi generic sg2 type 0
[    3.916490] sd 6:0:0:0: [sdc] Attached SCSI removable disk
[    4.193059] SELinux:  9 users, 13 roles, 3605 types, 191 bools, 1 sens, 1024 cats
[    4.193064] SELinux:  81 classes, 220461 rules
[    4.201241] SELinux:  Completing initialization.
[    4.201243] SELinux:  Setting up existing superblocks.
[    4.201251] SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
[    4.201257] SELinux: initialized (dev rootfs, type rootfs), uses genfs_contexts
[    4.201269] SELinux: initialized (dev bdev, type bdev), uses genfs_contexts
[    4.201275] SELinux: initialized (dev proc, type proc), uses genfs_contexts
[    4.201283] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    4.201322] SELinux: initialized (dev devtmpfs, type devtmpfs), uses transition SIDs
[    4.201808] SELinux: initialized (dev sockfs, type sockfs), uses task SIDs
[    4.201813] SELinux: initialized (dev debugfs, type debugfs), uses genfs_contexts
[    4.202543] SELinux: initialized (dev pipefs, type pipefs), uses task SIDs
[    4.202551] SELinux: initialized (dev anon_inodefs, type anon_inodefs), uses genfs_contexts
[    4.202555] SELinux: initialized (dev devpts, type devpts), uses transition SIDs
[    4.202571] SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses transition SIDs
[    4.202589] SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
[    4.202614] SELinux: initialized (dev selinuxfs, type selinuxfs), uses genfs_contexts
[    4.202627] SELinux: initialized (dev usbfs, type usbfs), uses genfs_contexts
[    4.202633] SELinux: initialized (dev securityfs, type securityfs), uses genfs_contexts
[    4.202637] SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
[    4.203121] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    4.203134] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    4.203728] SELinux: initialized (dev sdb2, type ext4), uses xattr
[    4.205819] type=1403 audit(1308736865.431:3): policy loaded auid=4294967295 ses=4294967295
[    4.321191] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    4.321807] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.443148] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.451703] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.452215] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.456755] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.461744] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.466714] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.472014] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.478719] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.484705] SELinux: initialized (dev cgroup, type cgroup), uses genfs_contexts
[    4.490975] systemd[1]: systemd 26 running in system mode. (+PAM +LIBWRAP +AUDIT +SELINUX +SYSVINIT +LIBCRYPTSETUP; fedora)
[    4.542997] NET: Registered protocol family 10
[    4.543982] systemd[1]: Set hostname to <pb-n5110>.
[    4.747152] SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
[    4.750040] SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
[    4.750724] SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
[    4.750991] SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
[    4.751767] SELinux: initialized (dev autofs, type autofs), uses genfs_contexts
[    4.801196] SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
[    4.849644] EXT4-fs (sdb2): re-mounted. Opts: (null)
[    5.122175] udev[410]: starting version 167
[    5.245298] wmi: Mapper loaded
[    5.298630] xhci_hcd 0000:0b:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    5.298676] xhci_hcd 0000:0b:00.0: setting latency timer to 64
[    5.298684] xhci_hcd 0000:0b:00.0: xHCI Host Controller
[    5.307882] iTCO_vendor_support: vendor-support=0
[    5.314320] xhci_hcd 0000:0b:00.0: new USB bus registered, assigned bus number 3
[    5.321745] xhci_hcd 0000:0b:00.0: irq 16, io mem 0xf7d00000
[    5.322316] xhci_hcd 0000:0b:00.0: irq 47 for MSI/MSI-X
[    5.322325] xhci_hcd 0000:0b:00.0: irq 48 for MSI/MSI-X
[    5.322332] xhci_hcd 0000:0b:00.0: irq 49 for MSI/MSI-X
[    5.322339] xhci_hcd 0000:0b:00.0: irq 50 for MSI/MSI-X
[    5.322346] xhci_hcd 0000:0b:00.0: irq 51 for MSI/MSI-X
[    5.325227] usb usb3: No SuperSpeed endpoint companion for config 1  interface 0 altsetting 0 ep 129: using minimum values
[    5.325243] usb usb3: New USB device found, idVendor=1d6b, idProduct=0003
[    5.325248] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    5.325251] usb usb3: Product: xHCI Host Controller
[    5.325254] usb usb3: Manufacturer: Linux 2.6.38.8-32.fc15.x86_64 xhci_hcd
[    5.325257] usb usb3: SerialNumber: 0000:0b:00.0
[    5.325449] xHCI xhci_add_endpoint called for root hub
[    5.325452] xHCI xhci_check_bandwidth called for root hub
[    5.325511] hub 3-0:1.0: USB hub found
[    5.325518] hub 3-0:1.0: 4 ports detected
[    5.337235] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.06
[    5.337374] iTCO_wdt: Found a Cougar Point TCO device (Version=2, TCOBASE=0x0460)
[    5.337503] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[    5.347268] i801_smbus 0000:00:1f.3: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    5.347277] ACPI: resource 0000:00:1f.3 [io  0xf040-0xf05f] conflicts with ACPI region SMBI [io 0xf040-0xf04f]
[    5.347280] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    5.347761] Linux video capture interface: v2.00
[    5.352609] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    5.352649] r8169 0000:05:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    5.352716] r8169 0000:05:00.0: setting latency timer to 64
[    5.352723] r8169 0000:05:00.0: (unregistered net_device): unknown MAC, using family default
[    5.352797] r8169 0000:05:00.0: irq 52 for MSI/MSI-X
[    5.353024] r8169 0000:05:00.0: eth0: RTL8101e at 0xffffc9000509e000, 78:2b:cb:f0:e8:52, XID 00a00000 IRQ 52
[    5.390966] mtp-probe[545]: checking bus 2, device 3: "/sys/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.6"
[    5.394100] mtp-probe[545]: bus: 2, device: 3 was not an MTP device
[    5.535828] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[    5.544998] microcode: CPU0 sig=0x206a7, pf=0x10, revision=0x14
[    5.545011] microcode: CPU1 sig=0x206a7, pf=0x10, revision=0x14
[    5.545026] microcode: CPU2 sig=0x206a7, pf=0x10, revision=0x14
[    5.545037] microcode: CPU3 sig=0x206a7, pf=0x10, revision=0x14
[    5.545782] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    5.577921] uvcvideo: Found UVC 1.00 device Laptop_Integrated_Webcam_HD (1bcf:2880)
[    5.586532] input: Dell WMI hotkeys as /devices/virtual/input/input7
[    5.595404] input: Laptop_Integrated_Webcam_HD as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.5/1-1.5:1.0/input/input8
[    5.595561] usbcore: registered new interface driver uvcvideo
[    5.595564] USB Video Class driver (v1.0.0)
[    5.608624] Bluetooth: Core ver 2.15
[    5.608651] NET: Registered protocol family 31
[    5.608654] Bluetooth: HCI device and connection manager initialized
[    5.608657] Bluetooth: HCI socket layer initialized
[    5.610210] cfg80211: Calling CRDA to update world regulatory domain
[    5.611670] Bluetooth: Generic Bluetooth USB driver ver 0.6
[    5.614248] usbcore: registered new interface driver btusb
[    5.637852] cfg80211: World regulatory domain updated:
[    5.637857] cfg80211:     (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[    5.637863] cfg80211:     (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    5.637867] cfg80211:     (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[    5.637871] cfg80211:     (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[    5.637875] cfg80211:     (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    5.637878] cfg80211:     (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    5.644001] microcode: CPU0 updated to revision 0x17, date = 2011-04-07
[    5.644649] microcode: CPU1 updated to revision 0x17, date = 2011-04-07
[    5.645258] microcode: CPU2 updated to revision 0x17, date = 2011-04-07
[    5.645905] microcode: CPU3 updated to revision 0x17, date = 2011-04-07
[    5.819396] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    5.819508] HDA Intel 0000:00:1b.0: irq 53 for MSI/MSI-X
[    5.819560] HDA Intel 0000:00:1b.0: setting latency timer to 64
[    5.819775] udev[430]: renamed network interface eth0 to p34p1
[    5.840962] iwlagn: Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:d
[    5.840967] iwlagn: Copyright(c) 2003-2010 Intel Corporation
[    5.841083] iwlagn 0000:09:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[    5.841093] iwlagn 0000:09:00.0: setting latency timer to 64
[    5.841146] iwlagn 0000:09:00.0: Detected Intel(R) Centrino(R) Wireless-N 1030 BGN, REV=0xB0
[    5.857793] iwlagn 0000:09:00.0: device EEPROM VER=0x716, CALIB=0x6
[    5.857797] iwlagn 0000:09:00.0: Device SKU: 0X9
[    5.857799] iwlagn 0000:09:00.0: Valid Tx ant: 0X1, Valid Rx ant: 0X3
[    5.857820] iwlagn 0000:09:00.0: Tunable channels: 13 802.11bg, 0 802.11a channels
[    5.857911] iwlagn 0000:09:00.0: irq 54 for MSI/MSI-X
[    5.860612] iwlagn 0000:09:00.0: loaded firmware version 17.168.5.1 build 33993
[    6.790672] Adding 1507324k swap on /dev/sdb3.  Priority:0 extents:1 across:1507324k SS
[    6.805215] cfg80211: Calling CRDA for country: IE
[    6.810137] cfg80211: Regulatory domain changed to country: IE
[    6.810142] cfg80211:     (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[    6.810146] cfg80211:     (2402000 KHz - 2482000 KHz @ 40000 KHz), (N/A, 2000 mBm)
[    6.810150] cfg80211:     (5170000 KHz - 5250000 KHz @ 40000 KHz), (N/A, 2000 mBm)
[    6.810153] cfg80211:     (5250000 KHz - 5330000 KHz @ 40000 KHz), (N/A, 2000 mBm)
[    6.810157] cfg80211:     (5490000 KHz - 5710000 KHz @ 40000 KHz), (N/A, 2700 mBm)
[    6.811635] ieee80211 phy0: Selected rate control algorithm 'iwl-agn-rs'
[    6.816123] ALSA sound/pci/hda/hda_codec.c:4633: autoconfig: line_outs=1 (0xd/0x0/0x0/0x0/0x0)
[    6.816129] ALSA sound/pci/hda/hda_codec.c:4637:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
[    6.816132] ALSA sound/pci/hda/hda_codec.c:4641:    hp_outs=1 (0xb/0x0/0x0/0x0/0x0)
[    6.816135] ALSA sound/pci/hda/hda_codec.c:4642:    mono: mono_out=0x0
[    6.816138] ALSA sound/pci/hda/hda_codec.c:4646:    inputs:
[    6.816140] ALSA sound/pci/hda/hda_codec.c:4652: 
[    6.816351] ALSA sound/pci/hda/patch_sigmatel.c:3073: stac92xx: dac_nids=1 (0x13/0x0/0x0/0x0/0x0)
[    6.828786] input: HDA Intel PCH Mic at Ext Right Jack as /devices/pci0000:00/0000:00:1b.0/sound/card0/input9
[    6.828894] input: HDA Intel PCH HP Out at Ext Right Jack as /devices/pci0000:00/0000:00:1b.0/sound/card0/input10
[    6.851570] systemd-fsck[636]: /dev/sdb1: clean, 285227/6406144 files, 21811502/25600000 blocks
[    6.920810] EXT4-fs (sdb1): mounted filesystem with ordered data mode. Opts: (null)
[    6.920821] SELinux: initialized (dev sdb1, type ext4), uses xattr
[    7.844840] NetworkManager[735]: <info> NetworkManager (version 0.8.9997-2.git20110531.fc15) is starting...
[    7.844853] NetworkManager[735]: <info> Read config file /etc/NetworkManager/NetworkManager.conf
[    7.863248] ntpd[736]: ntpd 4.2.6p3@1.2290-o Fri May  6 16:26:49 UTC 2011 (1)
[    7.863527] ntpd[736]: proto: precision = 0.068 usec
[    7.863593] ntpd[736]: 0.0.0.0 c01d 0d kern kernel time sync enabled
[    7.864011] ntpd[736]: ntp_io: estimated max descriptors: 1024, initial socket boundary: 16
[    7.864286] ntpd[736]: Listen and drop on 0 v4wildcard 0.0.0.0 UDP 123
[    7.866166] ntpd[736]: Listen and drop on 1 v6wildcard :: UDP 123
[    7.866611] ntpd[736]: Listen normally on 2 lo 127.0.0.1 UDP 123
[    7.866680] ntpd[736]: Listen normally on 3 lo ::1 UDP 123
[    7.866727] ntpd[736]: peers refreshed
[    7.866878] ntpd[736]: Listening on routing socket on fd #20 for interface updates
[    7.869202] ntpd[736]: Deferring DNS for 0.fedora.pool.ntp.org 1
[    7.869937] ntpd[736]: Deferring DNS for 1.fedora.pool.ntp.org 1
[    7.870148] ntpd[736]: Deferring DNS for 2.fedora.pool.ntp.org 1
[    7.870358] ntpd[736]: Deferring DNS for 3.fedora.pool.ntp.org 1
[    7.870628] ntpd[736]: 0.0.0.0 c016 06 restart
[    7.870644] ntpd[736]: 0.0.0.0 c012 02 freq_set kernel 8.514 PPM
[    7.870755] ntpd[738]: signal_no_reset: signal 17 had flags 4000000
[    7.950807] avahi-daemon[746]: Found user 'avahi' (UID 70) and group 'avahi' (GID 70).
[    7.951160] avahi-daemon[746]: Successfully dropped root privileges.
[    7.951441] avahi-daemon[746]: avahi-daemon 0.6.30 starting up.
[    7.975015] smartd[747]: smartd 5.40 2010-10-16 r3189 [x86_64-redhat-linux-gnu] (local build)
[    7.975033] smartd[747]: Opened configuration file /etc/smartd.conf
[    7.975178] smartd[747]: Configuration file /etc/smartd.conf was parsed, found DEVICESCAN, scanning devices
[    7.984309] smartd[747]: Device: /dev/sda, type changed from 'scsi' to 'sat'
[    7.984394] smartd[747]: Device: /dev/sda [SAT], opened
[    7.999299] smartd[747]: Device: /dev/sda [SAT], not found in smartd database.
[    8.319868] dbus[762]: avc:  netlink poll: error 4
[    8.333641] NetworkManager[735]: <info> VPN: loaded org.freedesktop.NetworkManager.openvpn
[    8.333840] NetworkManager[735]: <info> VPN: loaded org.freedesktop.NetworkManager.pptp
[    8.333962] NetworkManager[735]: <info> VPN: loaded org.freedesktop.NetworkManager.openconnect
[    8.334073] NetworkManager[735]: <info> VPN: loaded org.freedesktop.NetworkManager.vpnc
[    8.335257] abrtd[743]: Init complete, entering main loop
[    8.337073] avahi-daemon[746]: Successfully called chroot().
[    8.337125] avahi-daemon[746]: Successfully dropped remaining capabilities.
[    8.337514] avahi-daemon[746]: Loading service file /services/ssh.service.
[    8.337676] avahi-daemon[746]: Loading service file /services/udisks.service.
[    8.338479] avahi-daemon[746]: Network interface enumeration completed.
[    8.338587] avahi-daemon[746]: Registering HINFO record with values 'X86_64'/'LINUX'.
[    8.338758] avahi-daemon[746]: Server startup complete. Host name is pb-n5110.local. Local service cookie is 2886347264.
[    8.338841] avahi-daemon[746]: Service "pb-n5110" (/services/udisks.service) successfully established.
[    8.338878] avahi-daemon[746]: Service "pb-n5110" (/services/ssh.service) successfully established.
[    8.339567] NetworkManager[735]: ifcfg-rh: Acquired D-Bus service com.redhat.ifcfgrh1
[    8.339613] NetworkManager[735]: <info> Loaded plugin ifcfg-rh: (c) 2007 - 2010 Red Hat, Inc.  To report bugs please use the NetworkManager mailing list.
[    8.340038] NetworkManager[735]: <info> Loaded plugin keyfile: (c) 2007 - 2010 Red Hat, Inc.  To report bugs please use the NetworkManager mailing list.
[    8.340315] NetworkManager[735]: ifcfg-rh: parsing /etc/sysconfig/network-scripts/ifcfg-lo ...
[    8.340433] NetworkManager[735]: ifcfg-rh: parsing /etc/sysconfig/network-scripts/ifcfg-Auto_pixelbeat.wds ...
[    8.344432] NetworkManager[735]: ifcfg-rh:     read connection 'Auto pixelbeat.wds'
[    8.348972] NetworkManager[735]: <info> trying to start the modem manager...
[    8.349615] dbus[762]: [system] Activating service name='org.freedesktop.ModemManager' (using servicehelper)
[    8.366535] modem-manager[775]: <info>  ModemManager (version 0.4-8.git20110427.fc15) starting...
[    8.369956] dbus[762]: [system] Activating service name='org.freedesktop.PolicyKit1' (using servicehelper)
[    8.371216] dbus[762]: [system] Successfully activated service 'org.freedesktop.ModemManager'
[    8.372244] modem-manager[775]: <info>  Loaded plugin SimTech
[    8.372471] modem-manager[775]: <info>  Loaded plugin Generic
[    8.372680] modem-manager[775]: <info>  Loaded plugin MotoC
[    8.372915] modem-manager[775]: <info>  Loaded plugin ZTE
[    8.373149] modem-manager[775]: <info>  Loaded plugin Nokia
[    8.373356] modem-manager[775]: <info>  Loaded plugin AnyData
[    8.373570] modem-manager[775]: <info>  Loaded plugin Ericsson MBM
[    8.373786] modem-manager[775]: <info>  Loaded plugin Linktop
[    8.373990] modem-manager[775]: <info>  Loaded plugin Option
[    8.374200] modem-manager[775]: <info>  Loaded plugin Gobi
[    8.374404] modem-manager[775]: <info>  Loaded plugin Option High-Speed
[    8.374628] modem-manager[775]: <info>  Loaded plugin X22X
[    8.374959] modem-manager[775]: <info>  Loaded plugin Longcheer
[    8.375114] modem-manager[775]: <info>  Loaded plugin Sierra
[    8.375321] modem-manager[775]: <info>  Loaded plugin Wavecom
[    8.375528] modem-manager[775]: <info>  Loaded plugin Samsung
[    8.375772] modem-manager[775]: <info>  Loaded plugin Huawei
[    8.375980] modem-manager[775]: <info>  Loaded plugin Novatel
[    8.406943] polkitd[779]: started daemon version 0.101 using authority implementation `local' version `0.101'
[    8.409251] dbus[762]: [system] Successfully activated service 'org.freedesktop.PolicyKit1'
[    8.414474] NetworkManager[735]: <info> monitoring kernel firmware directory '/lib/firmware'.
[    8.416132] NetworkManager[735]: <info> found WiFi radio killswitch rfkill3 (at /sys/devices/pci0000:00/0000:00:1c.3/0000:09:00.0/ieee80211/phy0/rfkill3) (driver (unknown))
[    8.416258] NetworkManager[735]: <info> found WiFi radio killswitch rfkill0 (at /sys/devices/platform/dell-laptop/rfkill/rfkill0) (driver dell-laptop)
[    8.417277] dbus[762]: [system] Activating via systemd: service name='org.bluez' unit='dbus-org.bluez.service'
[    8.418772] NetworkManager[735]: <info> WiFi enabled by radio killswitch; enabled by state file
[    8.418789] NetworkManager[735]: <info> WWAN enabled by radio killswitch; enabled by state file
[    8.418802] NetworkManager[735]: <info> WiMAX enabled by radio killswitch; enabled by state file
[    8.418827] NetworkManager[735]: <info> Networking is enabled by state file
[    8.421314] NetworkManager[735]: <info> (p34p1): carrier is OFF
[    8.421609] NetworkManager[735]: <info> (p34p1): new Ethernet device (driver: 'r8169' ifindex: 2)
[    8.421655] NetworkManager[735]: <info> (p34p1): exported as /org/freedesktop/NetworkManager/Devices/0
[    8.422707] NetworkManager[735]: <info> (p34p1): now managed
[    8.422720] NetworkManager[735]: <info> (p34p1): device state change: unmanaged -> unavailable (reason 'managed') [10 20 2]
[    8.422731] NetworkManager[735]: <info> (p34p1): bringing up device.
[    8.438460] r8169 0000:05:00.0: p34p1: link down
[    8.439079] ADDRCONF(NETDEV_UP): p34p1: link is not ready
[    8.440998] NetworkManager[735]: <info> (p34p1): preparing device.
[    8.441012] NetworkManager[735]: <info> (p34p1): deactivating device (reason: 2).
[    8.441613] NetworkManager[735]: <info> Added default wired connection 'Wired connection 1' for /sys/devices/pci0000:00/0000:00:1c.1/0000:05:00.0/net/p34p1
[    8.443431] NetworkManager[735]: <info> (wlan0): driver supports SSID scans (scan_capa 0x01).
[    8.443892] NetworkManager[735]: <info> (wlan0): new 802.11 WiFi device (driver: 'iwlagn' ifindex: 3)
[    8.443978] NetworkManager[735]: <info> (wlan0): exported as /org/freedesktop/NetworkManager/Devices/1
[    8.444052] NetworkManager[735]: <info> (wlan0): now managed
[    8.444114] NetworkManager[735]: <info> (wlan0): device state change: unmanaged -> unavailable (reason 'managed') [10 20 2]
[    8.444173] NetworkManager[735]: <info> (wlan0): bringing up device.
[    8.468051] /usr/sbin/crond[750]: (CRON) INFO (running with inotify support)
[    8.587062] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[    8.598160] dbus[762]: [system] Activation via systemd failed for unit 'dbus-org.bluez.service': Unit dbus-org.bluez.service failed to load: No such file or directory. See system logs and 'systemctl status' for details.
[    8.610717] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    8.734716] systemd[1]: cgconfig.service: control process exited, code=exited status=1
[    8.751326] systemd[1]: Unit cgconfig.service entered failed state.
[    9.238464] auditd (865): /proc/865/oom_adj is deprecated, please use /proc/865/oom_score_adj instead.
[   10.001491] RPC: Registered udp transport module.
[   10.001496] RPC: Registered tcp transport module.
[   10.001498] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   10.029975] SELinux: initialized (dev rpc_pipefs, type rpc_pipefs), uses genfs_contexts
[   10.035886] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
[   10.035892] All bugs added by David S. Miller <davem@redhat.com>
[   10.125248] Bridge firewalling registered
[   10.587622] Ebtables v2.0 registered
[   10.856220] SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
[   10.856351] SELinux: initialized (dev proc, type proc), uses genfs_contexts
[   10.875765] SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
[   10.877668] SELinux: initialized (dev proc, type proc), uses genfs_contexts
[   10.895207] wlan0: authenticate with 00:18:39:d4:0d:31 (try 1)
[   10.897370] wlan0: authenticated
[   10.913755] wlan0: associate with 00:18:39:d4:0d:31 (try 1)
[   10.916321] wlan0: RX AssocResp from 00:18:39:d4:0d:31 (capab=0x411 status=0 aid=2)
[   10.916330] wlan0: associated
[   10.929040] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[   17.322909] fuse init (API version 7.16)
[   17.341840] SELinux: initialized (dev fuse, type fuse), uses genfs_contexts
[   17.381113] SELinux: initialized (dev fusectl, type fusectl), uses genfs_contexts
[   21.224527] wlan0: no IPv6 routers present

--------------080109040106070607080406--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
