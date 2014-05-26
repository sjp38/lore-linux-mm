Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id F08C16B0036
	for <linux-mm@kvack.org>; Mon, 26 May 2014 12:27:01 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id i50so12165365qgf.17
        for <linux-mm@kvack.org>; Mon, 26 May 2014 09:27:01 -0700 (PDT)
Received: from ikrg.com (ikrg.com. [2606:df00:2::fb1c:efb6])
        by mx.google.com with ESMTPS id g4si14121332qai.6.2014.05.26.09.26.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 26 May 2014 09:27:00 -0700 (PDT)
Message-ID: <53836B51.5020105@dougmorse.org>
Date: Mon, 26 May 2014 11:26:57 -0500
From: Doug Morse <dm@dougmorse.org>
MIME-Version: 1.0
Subject: Re: lshw sees 12GB RAM but system only using 8GB
References: <20140525224237.GA4869@ikrg.com> <20140526081414.GA16685@dhcp22.suse.cz>
In-Reply-To: <20140526081414.GA16685@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org

Hi Michael,

Certainly.  Please see below.

Thanks!
Doug

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.15.0-031500rc6-generic (apw@gomeisa) (gcc
version 4.6.3 (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #201405211835 SMP Wed May
21 22:35:54 UTC 2014
[    0.000000] Command line:
BOOT_IMAGE=/boot/vmlinuz-3.15.0-031500rc6-generic
root=UUID=45c2a972-2497-11e2-88ea-50e549361dd3 ro quiet splash vt.handoff=7
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009e7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009e800-0x000000000009ffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff]
reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000ae482fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000ae483000-0x00000000aea40fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000aea41000-0x00000000aee38fff]
ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000aee39000-0x00000000af158fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000af159000-0x00000000af159fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000af15a000-0x00000000af35ffff]
ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000af360000-0x00000000af7fffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec10000-0x00000000fec10fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec20000-0x00000000fec20fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed00fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed61000-0x00000000fed70fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed80000-0x00000000fed8ffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fef00000-0x00000000ffffffff]
reserved
[    0.000000] BIOS-e820: [mem 0x0000000100001000-0x000000024fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: Gigabyte Technology Co., Ltd. To be filled by
O.E.M./970A-UD3, BIOS FC 01/28/2013
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x250000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF write-through
[    0.000000]   C0000-CFFFF write-protect
[    0.000000]   D0000-EBFFF uncachable
[    0.000000]   EC000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000000 mask FFFF80000000 write-back
[    0.000000]   1 base 000080000000 mask FFFFC0000000 write-back
[    0.000000]   2 base 0000AF800000 mask FFFFFF800000 uncachable
[    0.000000]   3 base 0000B0000000 mask FFFFF0000000 uncachable
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] TOM2: 0000000250000000 aka 9472M
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new
0x7010600070106
[    0.000000] original variable MTRRs
[    0.000000] reg 0, base: 0GB, range: 2GB, type WB
[    0.000000] reg 1, base: 2GB, range: 1GB, type WB
[    0.000000] reg 2, base: 2808MB, range: 8MB, type UC
[    0.000000] reg 3, base: 2816MB, range: 256MB, type UC
[    0.000000] total RAM covered: 2808M
[    0.000000] Found optimal setting for mtrr clean up
[    0.000000]  gran_size: 64K     chunk_size: 16M     num_reg: 4     
lose cover RAM: 0G
[    0.000000] New variable MTRRs
[    0.000000] reg 0, base: 0GB, range: 2GB, type WB
[    0.000000] reg 1, base: 2GB, range: 512MB, type WB
[    0.000000] reg 2, base: 2560MB, range: 256MB, type WB
[    0.000000] reg 3, base: 2808MB, range: 8MB, type UC
[    0.000000] e820: update [mem 0xaf800000-0xffffffff] usable ==> reserved
[    0.000000] e820: last_pfn = 0xaf800 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fd860-0x000fd86f] mapped
at [ffff8800000fd860]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000098000] 98000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01fe2000, 0x01fe2fff] PGTABLE
[    0.000000] BRK [0x01fe3000, 0x01fe3fff] PGTABLE
[    0.000000] BRK [0x01fe4000, 0x01fe4fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x24fe00000-0x24fffffff]
[    0.000000]  [mem 0x24fe00000-0x24fffffff] page 2M
[    0.000000] BRK [0x01fe5000, 0x01fe5fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x24c000000-0x24fdfffff]
[    0.000000]  [mem 0x24c000000-0x24fdfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x200000000-0x24bffffff]
[    0.000000]  [mem 0x200000000-0x23fffffff] page 1G
[    0.000000]  [mem 0x240000000-0x24bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0xae482fff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
[    0.000000]  [mem 0x40000000-0x7fffffff] page 1G
[    0.000000]  [mem 0x80000000-0xae3fffff] page 2M
[    0.000000]  [mem 0xae400000-0xae482fff] page 4k
[    0.000000] init_memory_mapping: [mem 0xaf159000-0xaf159fff]
[    0.000000]  [mem 0xaf159000-0xaf159fff] page 4k
[    0.000000] BRK [0x01fe6000, 0x01fe6fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0xaf360000-0xaf7fffff]
[    0.000000]  [mem 0xaf360000-0xaf3fffff] page 4k
[    0.000000]  [mem 0xaf400000-0xaf7fffff] page 2M
[    0.000000] BRK [0x01fe7000, 0x01fe7fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x100001000-0x1ffffffff]
[    0.000000]  [mem 0x100001000-0x1001fffff] page 4k
[    0.000000]  [mem 0x100200000-0x13fffffff] page 2M
[    0.000000]  [mem 0x140000000-0x1ffffffff] page 1G
[    0.000000] RAMDISK: [mem 0x35e48000-0x36f1bfff]
[    0.000000] ACPI: RSDP 0x00000000000F0490 000024 (v02 ALASKA)
[    0.000000] ACPI: XSDT 0x00000000AEE1C078 00006C (v01 ALASKA A M I   
01072009 AMI  00010013)
[    0.000000] ACPI: FACP 0x00000000AEE22708 0000F4 (v04 ALASKA A M I   
01072009 AMI  00010013)
[    0.000000] ACPI BIOS Warning (bug): Optional FADT field
Pm2ControlBlock has zero address or length: 0x0000000000000000/0x1
(20140214/tbfadt-634)
[    0.000000] ACPI: DSDT 0x00000000AEE1C178 006590 (v02 ALASKA A M I   
00000000 INTL 20051117)
[    0.000000] ACPI: FACS 0x00000000AEE33F80 000040
[    0.000000] ACPI: APIC 0x00000000AEE22800 00007E (v03 ALASKA A M I   
01072009 AMI  00010013)
[    0.000000] ACPI: FPDT 0x00000000AEE22880 000044 (v01 ALASKA A M I   
01072009 AMI  00010013)
[    0.000000] ACPI: MCFG 0x00000000AEE228C8 00003C (v01 ALASKA A M I   
01072009 MSFT 00010013)
[    0.000000] ACPI: HPET 0x00000000AEE22908 000038 (v01 ALASKA A M I   
01072009 AMI  00000005)
[    0.000000] ACPI: SSDT 0x00000000AEE22940 0008BC (v01 AMD    POWERNOW
00000001 AMD  00000001)
[    0.000000] ACPI: MATS 0x00000000AEE23200 000034 (v02 ALASKA A M I   
00000002 w?x2 00000000)
[    0.000000] ACPI: IVRS 0x00000000AEE23238 0000D8 (v01 AMD    RD890S  
00202031 AMD  00000000)
[    0.000000] ACPI: BGRT 0x00000000AEE23310 000038 (v00 ALASKA A M I   
01072009 AMI  00010013)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] Scanning NUMA topology in Northbridge 24
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000024fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x24fffffff]
[    0.000000]   NODE_DATA [mem 0x24fff7000-0x24fffbfff]
[    0.000000]  [ffffea0000000000-ffffea00093fffff] PMD ->
[ffff880247600000-ffff88024f5fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x24fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009dfff]
[    0.000000]   node   0: [mem 0x00100000-0xae482fff]
[    0.000000]   node   0: [mem 0xaf159000-0xaf159fff]
[    0.000000]   node   0: [mem 0xaf360000-0xaf7fffff]
[    0.000000]   node   0: [mem 0x100001000-0x24fffffff]
[    0.000000] On node 0 totalpages: 2091200
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 11109 pages used for memmap
[    0.000000]   DMA32 zone: 710948 pages, LIFO batch:31
[    0.000000]   Normal zone: 21504 pages used for memmap
[    0.000000]   Normal zone: 1376255 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x05] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 5, version 33, address 0xfec00000, GSI
0-23
[    0.000000] ACPI: IOAPIC (id[0x06] address[0xfec20000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 6, version 33, address 0xfec20000, GSI
24-55
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x43538210 base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 72
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009efff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xae483000-0xaea40fff]
[    0.000000] PM: Registered nosave memory: [mem 0xaea41000-0xaee38fff]
[    0.000000] PM: Registered nosave memory: [mem 0xaee39000-0xaf158fff]
[    0.000000] PM: Registered nosave memory: [mem 0xaf15a000-0xaf35ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xaf800000-0xf7ffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xf8000000-0xfbffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfec00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec01000-0xfec0ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec10000-0xfec10fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec11000-0xfec1ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec20000-0xfec20fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec21000-0xfecfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfed00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed01000-0xfed60fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed61000-0xfed70fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed71000-0xfed7ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed80000-0xfed8ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed90000-0xfeefffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfef00000-0xffffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x100000000-0x100000fff]
[    0.000000] e820: [mem 0xaf800000-0xf7ffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:256 nr_cpumask_bits:256
nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 29 pages/cpu @ffff88024fc00000 s86656
r8192 d23936 u524288
[    0.000000] pcpu-alloc: s86656 r8192 d23936 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on. 
Total pages: 2058502
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line:
BOOT_IMAGE=/boot/vmlinuz-3.15.0-031500rc6-generic
root=UUID=45c2a972-2497-11e2-88ea-50e549361dd3 ro quiet splash vt.handoff=7
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Node 0: aperture @ f8000000 size 64 MB
[    0.000000] Memory: 8133320K/8364800K available (7665K kernel code,
1147K rwdata, 3624K rodata, 1356K init, 1432K bss, 231480K reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]     RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000]     RCU restricting CPUs from NR_CPUS=256 to nr_cpu_ids=4.
[    0.000000]     Offload RCU callbacks from all CPUs
[    0.000000]     Offload RCU callbacks from CPUs: 0-3.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=4
[    0.000000] NR_IRQS:16640 nr_irqs:1024 16
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] allocated 33554432 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't
want memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2812.845 MHz processor
[    0.000031] Calibrating delay loop (skipped), value calculated using
timer frequency.. 5625.69 BogoMIPS (lpj=11251380)
[    0.000034] pid_max: default: 32768 minimum: 301
[    0.000041] ACPI: Core revision 20140214
[    0.002937] ACPI: All ACPI Tables successfully acquired
[    0.003205] Security Framework initialized
[    0.003217] AppArmor: AppArmor initialized
[    0.003218] Yama: becoming mindful.
[    0.003834] Dentry cache hash table entries: 1048576 (order: 11,
8388608 bytes)
[    0.006600] Inode-cache hash table entries: 524288 (order: 10,
4194304 bytes)
[    0.007922] Mount-cache hash table entries: 16384 (order: 5, 131072
bytes)
[    0.007933] Mountpoint-cache hash table entries: 16384 (order: 5,
131072 bytes)
[    0.008205] Initializing cgroup subsys memory
[    0.008210] Initializing cgroup subsys devices
[    0.008212] Initializing cgroup subsys freezer
[    0.008214] Initializing cgroup subsys net_cls
[    0.008215] Initializing cgroup subsys blkio
[    0.008217] Initializing cgroup subsys perf_event
[    0.008219] Initializing cgroup subsys net_prio
[    0.008220] Initializing cgroup subsys hugetlb
[    0.008239] tseg: 00af800000
[    0.008242] CPU: Physical Processor ID: 0
[    0.008243] CPU: Processor Core ID: 0
[    0.008245] mce: CPU supports 6 MCE banks
[    0.008250] LVT offset 0 assigned for vector 0xf9
[    0.008254] process: using AMD E400 aware idle routine
[    0.008257] Last level iTLB entries: 4KB 512, 2MB 16, 4MB 8
[    0.008257] Last level dTLB entries: 4KB 512, 2MB 128, 4MB 64, 1GB 0
[    0.008257] tlb_flushall_shift: 6
[    0.008342] Freeing SMP alternatives memory: 28K (ffffffff81e73000 -
ffffffff81e7a000)
[    0.009041] ftrace: allocating 31839 entries in 125 pages
[    0.101594] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.141275] smpboot: CPU0: AMD Athlon(tm) II X4 630 Processor (fam:
10, model: 05, stepping: 03)
[    0.247644] Performance Events: AMD PMU driver.
[    0.247648] ... version:                0
[    0.247650] ... bit width:              48
[    0.247650] ... generic registers:      4
[    0.247651] ... value mask:             0000ffffffffffff
[    0.247652] ... max period:             00007fffffffffff
[    0.247653] ... fixed-purpose events:   0
[    0.247654] ... event mask:             000000000000000f
[    0.249062] NMI watchdog: enabled on all CPUs, permanently consumes
one hw-PMU counter.
[    0.249147] x86: Booting SMP configuration:
[    0.249149] .... node  #0, CPUs:      #1
[    0.262241] process: System has AMD C1E enabled
[    0.262252] process: Switch to broadcast mode on CPU1
[    0.262275]  #2
[    0.275367] process: Switch to broadcast mode on CPU2
[    0.275388]  #3
[    0.288429] x86: Booted up 1 node, 4 CPUs
[    0.288431] smpboot: Total of 4 processors activated (22502.76 BogoMIPS)
[    0.288475] process: Switch to broadcast mode on CPU3
[    0.289101] process: Switch to broadcast mode on CPU0
[    0.289421] devtmpfs: initialized
[    0.293957] evm: security.selinux
[    0.293958] evm: security.SMACK64
[    0.293959] evm: security.ima
[    0.293960] evm: security.capability
[    0.294149] PM: Registering ACPI NVS region [mem
0xaea41000-0xaee38fff] (4161536 bytes)
[    0.294207] PM: Registering ACPI NVS region [mem
0xaf15a000-0xaf35ffff] (2121728 bytes)
[    0.295276] pinctrl core: initialized pinctrl subsystem
[    0.295358] regulator-dummy: no parameters
[    0.295382] RTC time: 16:17:15, date: 05/26/14
[    0.295431] NET: Registered protocol family 16
[    0.295561] cpuidle: using governor ladder
[    0.295562] cpuidle: using governor menu
[    0.295566] node 0 link 0: io port [b000, ffff]
[    0.295568] TOM: 00000000b0000000 aka 2816M
[    0.295571] Fam 10h mmconf [mem 0xe0000000-0xefffffff]
[    0.295572] node 0 link 0: mmio [b0000000, fef0ffff] ==> [b0000000,
dfffffff] and [f0000000, fef0ffff]
[    0.295576] TOM2: 0000000250000000 aka 9472M
[    0.295578] bus: [bus 00-1f] on node 0 link 0
[    0.295579] bus: 00 [io  0x0000-0xffff]
[    0.295580] bus: 00 [mem 0xb0000000-0xdfffffff]
[    0.295581] bus: 00 [mem 0xf0000000-0xffffffff]
[    0.295582] bus: 00 [mem 0x250000000-0xfcffffffff]
[    0.295656] ACPI: bus type PCI registered
[    0.295659] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.295716] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
0xe0000000-0xefffffff] (base 0xe0000000)
[    0.295719] PCI: not using MMCONFIG
[    0.295720] PCI: Using configuration type 1 for base access
[    0.295721] PCI: Using configuration type 1 for extended access
[    0.297911] ACPI: Added _OSI(Module Device)
[    0.297916] ACPI: Added _OSI(Processor Device)
[    0.297917] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.297918] ACPI: Added _OSI(Processor Aggregator Device)
[    0.299509] ACPI: Executed 3 blocks of module-level executable AML code
[    0.302777] ACPI: Interpreter enabled
[    0.302786] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep
State [\_S1_] (20140214/hwxface-580)
[    0.302791] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep
State [\_S2_] (20140214/hwxface-580)
[    0.302802] ACPI: (supports S0 S3 S4 S5)
[    0.302804] ACPI: Using IOAPIC for interrupt routing
[    0.302919] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
0xe0000000-0xefffffff] (base 0xe0000000)
[    0.302953] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in
ACPI motherboard resources
[    0.314453] PCI: Using host bridge windows from ACPI; if necessary,
use "pci=nocrs" and report a bug
[    0.352453] ACPI: \_PR_.P005: failed to get CPU APIC ID.
[    0.352458] ACPI: \_PR_.P006: failed to get CPU APIC ID.
[    0.352462] ACPI: \_PR_.P007: failed to get CPU APIC ID.
[    0.352466] ACPI: \_PR_.P008: failed to get CPU APIC ID.
[    0.352607] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.352612] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM
ClockPM Segments MSI]
[    0.352617] acpi PNP0A08:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.352965] PCI host bridge to bus 0000:00
[    0.352967] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.352969] pci_bus 0000:00: root bus resource [io  0x0000-0x03af]
[    0.352971] pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7]
[    0.352973] pci_bus 0000:00: root bus resource [io  0x03b0-0x03df]
[    0.352974] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.352976] pci_bus 0000:00: root bus resource [mem
0x000a0000-0x000bffff]
[    0.352977] pci_bus 0000:00: root bus resource [mem
0x000c0000-0x000dffff]
[    0.352979] pci_bus 0000:00: root bus resource [mem
0xb0000000-0xffffffff]
[    0.352990] pci 0000:00:00.0: [1002:5a14] type 00 class 0x060000
[    0.353091] pci 0000:00:00.2: [1002:5a23] type 00 class 0x080600
[    0.353182] pci 0000:00:02.0: [1002:5a16] type 01 class 0x060400
[    0.353212] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    0.353251] pci 0000:00:02.0: System wakeup disabled by ACPI
[    0.353287] pci 0000:00:04.0: [1002:5a18] type 01 class 0x060400
[    0.353316] pci 0000:00:04.0: PME# supported from D0 D3hot D3cold
[    0.353353] pci 0000:00:04.0: System wakeup disabled by ACPI
[    0.353391] pci 0000:00:09.0: [1002:5a1c] type 01 class 0x060400
[    0.353420] pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
[    0.353456] pci 0000:00:09.0: System wakeup disabled by ACPI
[    0.353489] pci 0000:00:0a.0: [1002:5a1d] type 01 class 0x060400
[    0.353517] pci 0000:00:0a.0: PME# supported from D0 D3hot D3cold
[    0.353555] pci 0000:00:0a.0: System wakeup disabled by ACPI
[    0.353598] pci 0000:00:11.0: [1002:4391] type 00 class 0x010601
[    0.353612] pci 0000:00:11.0: reg 0x10: [io  0xf040-0xf047]
[    0.353619] pci 0000:00:11.0: reg 0x14: [io  0xf030-0xf033]
[    0.353626] pci 0000:00:11.0: reg 0x18: [io  0xf020-0xf027]
[    0.353633] pci 0000:00:11.0: reg 0x1c: [io  0xf010-0xf013]
[    0.353640] pci 0000:00:11.0: reg 0x20: [io  0xf000-0xf00f]
[    0.353647] pci 0000:00:11.0: reg 0x24: [mem 0xfeb0b000-0xfeb0b3ff]
[    0.353742] pci 0000:00:12.0: [1002:4397] type 00 class 0x0c0310
[    0.353752] pci 0000:00:12.0: reg 0x10: [mem 0xfeb0a000-0xfeb0afff]
[    0.353823] pci 0000:00:12.0: System wakeup disabled by ACPI
[    0.353862] pci 0000:00:12.2: [1002:4396] type 00 class 0x0c0320
[    0.353876] pci 0000:00:12.2: reg 0x10: [mem 0xfeb09000-0xfeb090ff]
[    0.353935] pci 0000:00:12.2: supports D1 D2
[    0.353936] pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
[    0.353974] pci 0000:00:12.2: System wakeup disabled by ACPI
[    0.354013] pci 0000:00:13.0: [1002:4397] type 00 class 0x0c0310
[    0.354023] pci 0000:00:13.0: reg 0x10: [mem 0xfeb08000-0xfeb08fff]
[    0.354094] pci 0000:00:13.0: System wakeup disabled by ACPI
[    0.354132] pci 0000:00:13.2: [1002:4396] type 00 class 0x0c0320
[    0.354146] pci 0000:00:13.2: reg 0x10: [mem 0xfeb07000-0xfeb070ff]
[    0.354205] pci 0000:00:13.2: supports D1 D2
[    0.354206] pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
[    0.354249] pci 0000:00:13.2: System wakeup disabled by ACPI
[    0.354318] pci 0000:00:14.0: [1002:4385] type 00 class 0x0c0500
[    0.354425] pci 0000:00:14.2: [1002:4383] type 00 class 0x040300
[    0.354441] pci 0000:00:14.2: reg 0x10: [mem 0xfeb00000-0xfeb03fff 64bit]
[    0.354488] pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
[    0.354524] pci 0000:00:14.2: System wakeup disabled by ACPI
[    0.354558] pci 0000:00:14.3: [1002:439d] type 00 class 0x060100
[    0.354663] pci 0000:00:14.4: [1002:4384] type 01 class 0x060401
[    0.354719] pci 0000:00:14.4: System wakeup disabled by ACPI
[    0.354754] pci 0000:00:14.5: [1002:4399] type 00 class 0x0c0310
[    0.354764] pci 0000:00:14.5: reg 0x10: [mem 0xfeb06000-0xfeb06fff]
[    0.354836] pci 0000:00:14.5: System wakeup disabled by ACPI
[    0.354876] pci 0000:00:15.0: [1002:43a0] type 01 class 0x060400
[    0.354929] pci 0000:00:15.0: supports D1 D2
[    0.354969] pci 0000:00:15.0: System wakeup disabled by ACPI
[    0.355004] pci 0000:00:16.0: [1002:4397] type 00 class 0x0c0310
[    0.355014] pci 0000:00:16.0: reg 0x10: [mem 0xfeb05000-0xfeb05fff]
[    0.355085] pci 0000:00:16.0: System wakeup disabled by ACPI
[    0.355124] pci 0000:00:16.2: [1002:4396] type 00 class 0x0c0320
[    0.355138] pci 0000:00:16.2: reg 0x10: [mem 0xfeb04000-0xfeb040ff]
[    0.355197] pci 0000:00:16.2: supports D1 D2
[    0.355198] pci 0000:00:16.2: PME# supported from D0 D1 D2 D3hot
[    0.355236] pci 0000:00:16.2: System wakeup disabled by ACPI
[    0.355274] pci 0000:00:18.0: [1022:1200] type 00 class 0x060000
[    0.355337] pci 0000:00:18.1: [1022:1201] type 00 class 0x060000
[    0.355397] pci 0000:00:18.2: [1022:1202] type 00 class 0x060000
[    0.355457] pci 0000:00:18.3: [1022:1203] type 00 class 0x060000
[    0.355520] pci 0000:00:18.4: [1022:1204] type 00 class 0x060000
[    0.355622] pci 0000:01:00.0: [1002:68d8] type 00 class 0x030000
[    0.355633] pci 0000:01:00.0: reg 0x10: [mem 0xc0000000-0xcfffffff
64bit pref]
[    0.355642] pci 0000:01:00.0: reg 0x18: [mem 0xfea20000-0xfea3ffff 64bit]
[    0.355648] pci 0000:01:00.0: reg 0x20: [io  0xe000-0xe0ff]
[    0.355658] pci 0000:01:00.0: reg 0x30: [mem 0xfea00000-0xfea1ffff pref]
[    0.355687] pci 0000:01:00.0: supports D1 D2
[    0.355729] pci 0000:01:00.1: [1002:aa60] type 00 class 0x040300
[    0.355740] pci 0000:01:00.1: reg 0x10: [mem 0xfea40000-0xfea43fff 64bit]
[    0.355791] pci 0000:01:00.1: supports D1 D2
[    0.362350] pci 0000:00:02.0: PCI bridge to [bus 01]
[    0.362357] pci 0000:00:02.0:   bridge window [io  0xe000-0xefff]
[    0.362360] pci 0000:00:02.0:   bridge window [mem 0xfea00000-0xfeafffff]
[    0.362363] pci 0000:00:02.0:   bridge window [mem
0xc0000000-0xcfffffff 64bit pref]
[    0.362437] pci 0000:02:00.0: [1b6f:7023] type 00 class 0x0c0330
[    0.362453] pci 0000:02:00.0: reg 0x10: [mem 0xfe900000-0xfe907fff 64bit]
[    0.362523] pci 0000:02:00.0: supports D1 D2
[    0.362524] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.370350] pci 0000:00:04.0: PCI bridge to [bus 02]
[    0.370358] pci 0000:00:04.0:   bridge window [mem 0xfe900000-0xfe9fffff]
[    0.370448] pci 0000:03:00.0: [10ec:8168] type 00 class 0x020000
[    0.370460] pci 0000:03:00.0: reg 0x10: [io  0xd000-0xd0ff]
[    0.370479] pci 0000:03:00.0: reg 0x18: [mem 0xd0004000-0xd0004fff
64bit pref]
[    0.370491] pci 0000:03:00.0: reg 0x20: [mem 0xd0000000-0xd0003fff
64bit pref]
[    0.370554] pci 0000:03:00.0: supports D1 D2
[    0.370556] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.370590] pci 0000:03:00.0: System wakeup disabled by ACPI
[    0.378349] pci 0000:00:09.0: PCI bridge to [bus 03]
[    0.378356] pci 0000:00:09.0:   bridge window [io  0xd000-0xdfff]
[    0.378360] pci 0000:00:09.0:   bridge window [mem
0xd0000000-0xd00fffff 64bit pref]
[    0.378428] pci 0000:04:00.0: [1b6f:7023] type 00 class 0x0c0330
[    0.378444] pci 0000:04:00.0: reg 0x10: [mem 0xfe800000-0xfe807fff 64bit]
[    0.378513] pci 0000:04:00.0: supports D1 D2
[    0.378514] pci 0000:04:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.386347] pci 0000:00:0a.0: PCI bridge to [bus 04]
[    0.386355] pci 0000:00:0a.0:   bridge window [mem 0xfe800000-0xfe8fffff]
[    0.386439] pci 0000:05:0e.0: [1106:3044] type 00 class 0x0c0010
[    0.386458] pci 0000:05:0e.0: reg 0x10: [mem 0xfe700000-0xfe7007ff]
[    0.386469] pci 0000:05:0e.0: reg 0x14: [io  0xc000-0xc07f]
[    0.386544] pci 0000:05:0e.0: supports D2
[    0.386546] pci 0000:05:0e.0: PME# supported from D2 D3hot D3cold
[    0.386609] pci 0000:00:14.4: PCI bridge to [bus 05] (subtractive decode)
[    0.386612] pci 0000:00:14.4:   bridge window [io  0xc000-0xcfff]
[    0.386615] pci 0000:00:14.4:   bridge window [mem 0xfe700000-0xfe7fffff]
[    0.386619] pci 0000:00:14.4:   bridge window [io  0x0000-0x03af]
(subtractive decode)
[    0.386620] pci 0000:00:14.4:   bridge window [io  0x03e0-0x0cf7]
(subtractive decode)
[    0.386622] pci 0000:00:14.4:   bridge window [io  0x03b0-0x03df]
(subtractive decode)
[    0.386623] pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
[    0.386625] pci 0000:00:14.4:   bridge window [mem
0x000a0000-0x000bffff] (subtractive decode)
[    0.386627] pci 0000:00:14.4:   bridge window [mem
0x000c0000-0x000dffff] (subtractive decode)
[    0.386628] pci 0000:00:14.4:   bridge window [mem
0xb0000000-0xffffffff] (subtractive decode)
[    0.386688] pci 0000:06:00.0: [1002:68f9] type 00 class 0x030000
[    0.386705] pci 0000:06:00.0: reg 0x10: [mem 0xb0000000-0xbfffffff
64bit pref]
[    0.386717] pci 0000:06:00.0: reg 0x18: [mem 0xfe620000-0xfe63ffff 64bit]
[    0.386724] pci 0000:06:00.0: reg 0x20: [io  0xb000-0xb0ff]
[    0.386738] pci 0000:06:00.0: reg 0x30: [mem 0xfe600000-0xfe61ffff pref]
[    0.386789] pci 0000:06:00.0: supports D1 D2
[    0.386843] pci 0000:06:00.1: [1002:aa68] type 00 class 0x040300
[    0.386862] pci 0000:06:00.1: reg 0x10: [mem 0xfe640000-0xfe643fff 64bit]
[    0.386953] pci 0000:06:00.1: supports D1 D2
[    0.394348] pci 0000:00:15.0: PCI bridge to [bus 06]
[    0.394356] pci 0000:00:15.0:   bridge window [io  0xb000-0xbfff]
[    0.394359] pci 0000:00:15.0:   bridge window [mem 0xfe600000-0xfe6fffff]
[    0.394364] pci 0000:00:15.0:   bridge window [mem
0xb0000000-0xbfffffff 64bit pref]
[    0.394391] pci_bus 0000:00: on NUMA node 0
[    0.394690] ACPI: PCI Interrupt Link [LNKA] (IRQs 4 7 10 11 14 15) *0
[    0.394744] ACPI: PCI Interrupt Link [LNKB] (IRQs 4 7 10 11 14 15) *0
[    0.394797] ACPI: PCI Interrupt Link [LNKC] (IRQs 4 7 10 11 14 15) *0
[    0.394850] ACPI: PCI Interrupt Link [LNKD] (IRQs 4 7 10 11 14 15) *0
[    0.394892] ACPI: PCI Interrupt Link [LNKE] (IRQs 4 10 11 14 15) *0
[    0.394926] ACPI: PCI Interrupt Link [LNKF] (IRQs 4 10 11 14 15) *0
[    0.394959] ACPI: PCI Interrupt Link [LNKG] (IRQs 4 10 11 14 15) *0
[    0.394993] ACPI: PCI Interrupt Link [LNKH] (IRQs 4 10 11 14 15) *0
[    0.395204] vgaarb: device added:
PCI:0000:01:00.0,decodes=io+mem,owns=io+mem,locks=none
[    0.395210] vgaarb: device added:
PCI:0000:06:00.0,decodes=io+mem,owns=none,locks=none
[    0.395211] vgaarb: loaded
[    0.395212] vgaarb: bridge control possible 0000:06:00.0
[    0.395213] vgaarb: bridge control possible 0000:01:00.0
[    0.395408] SCSI subsystem initialized
[    0.395506] libata version 3.00 loaded.
[    0.395526] ACPI: bus type USB registered
[    0.395547] usbcore: registered new interface driver usbfs
[    0.395556] usbcore: registered new interface driver hub
[    0.395703] usbcore: registered new device driver usb
[    0.395967] PCI: Using ACPI for IRQ routing
[    0.401906] PCI: pci_cache_line_size set to 64 bytes
[    0.401969] e820: reserve RAM buffer [mem 0x0009e800-0x0009ffff]
[    0.401970] e820: reserve RAM buffer [mem 0xae483000-0xafffffff]
[    0.401972] e820: reserve RAM buffer [mem 0xaf15a000-0xafffffff]
[    0.401973] e820: reserve RAM buffer [mem 0xaf800000-0xafffffff]
[    0.402076] NetLabel: Initializing
[    0.402077] NetLabel:  domain hash size = 128
[    0.402078] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.402089] NetLabel:  unlabeled traffic allowed by default
[    0.402185] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.402189] hpet0: 3 comparators, 32-bit 14.318180 MHz counter
[    0.404274] Switched to clocksource hpet
[    0.410013] AppArmor: AppArmor Filesystem Enabled
[    0.410048] pnp: PnP ACPI init
[    0.410068] ACPI: bus type PNP registered
[    0.410202] system 00:00: [mem 0xe0000000-0xefffffff] has been reserved
[    0.410206] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.410438] system 00:01: [io  0x040b] has been reserved
[    0.410441] system 00:01: [io  0x04d6] has been reserved
[    0.410443] system 00:01: [io  0x0c00-0x0c01] has been reserved
[    0.410445] system 00:01: [io  0x0c14] has been reserved
[    0.410447] system 00:01: [io  0x0c50-0x0c51] has been reserved
[    0.410448] system 00:01: [io  0x0c52] has been reserved
[    0.410450] system 00:01: [io  0x0c6c] has been reserved
[    0.410452] system 00:01: [io  0x0c6f] has been reserved
[    0.410453] system 00:01: [io  0x0cd0-0x0cd1] has been reserved
[    0.410455] system 00:01: [io  0x0cd2-0x0cd3] has been reserved
[    0.410457] system 00:01: [io  0x0cd4-0x0cd5] has been reserved
[    0.410458] system 00:01: [io  0x0cd6-0x0cd7] has been reserved
[    0.410460] system 00:01: [io  0x0cd8-0x0cdf] has been reserved
[    0.410462] system 00:01: [io  0x0800-0x089f] could not be reserved
[    0.410464] system 00:01: [io  0x0b20-0x0b3f] has been reserved
[    0.410465] system 00:01: [io  0x0900-0x090f] has been reserved
[    0.410467] system 00:01: [io  0x0910-0x091f] has been reserved
[    0.410469] system 00:01: [io  0xfe00-0xfefe] has been reserved
[    0.410471] system 00:01: [mem 0xfec00000-0xfec00fff] could not be
reserved
[    0.410473] system 00:01: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.410475] system 00:01: [mem 0xfed80000-0xfed8ffff] has been reserved
[    0.410477] system 00:01: [mem 0xfed61000-0xfed70fff] has been reserved
[    0.410479] system 00:01: [mem 0xfec10000-0xfec10fff] has been reserved
[    0.410481] system 00:01: [mem 0xfed00000-0xfed00fff] has been reserved
[    0.410482] system 00:01: [mem 0xffc00000-0xffffffff] has been reserved
[    0.410485] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.410602] system 00:02: [io  0x0220-0x0227] has been reserved
[    0.410604] system 00:02: [io  0x0228-0x0237] has been reserved
[    0.410606] system 00:02: [io  0x0a20-0x0a2f] has been reserved
[    0.410608] system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.410822] pnp 00:03: [dma 0 disabled]
[    0.410869] pnp 00:03: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.410879] pnp 00:04: [dma 4]
[    0.410900] pnp 00:04: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.410930] pnp 00:05: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.410953] pnp 00:06: Plug and Play ACPI device, IDs PNP0800 (active)
[    0.411006] system 00:07: [io  0x04d0-0x04d1] has been reserved
[    0.411008] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.411036] pnp 00:08: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.411074] system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.411198] system 00:0a: [mem 0xfeb20000-0xfeb23fff] could not be
reserved
[    0.411201] system 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.411306] system 00:0b: [mem 0xfec20000-0xfec200ff] could not be
reserved
[    0.411309] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.411429] pnp 00:0c: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.411432] pnp: PnP ACPI: found 13 devices
[    0.411433] ACPI: bus type PNP unregistered
[    0.418323] pci 0000:00:02.0: PCI bridge to [bus 01]
[    0.418328] pci 0000:00:02.0:   bridge window [io  0xe000-0xefff]
[    0.418330] pci 0000:00:02.0:   bridge window [mem 0xfea00000-0xfeafffff]
[    0.418333] pci 0000:00:02.0:   bridge window [mem
0xc0000000-0xcfffffff 64bit pref]
[    0.418336] pci 0000:00:04.0: PCI bridge to [bus 02]
[    0.418338] pci 0000:00:04.0:   bridge window [mem 0xfe900000-0xfe9fffff]
[    0.418342] pci 0000:00:09.0: PCI bridge to [bus 03]
[    0.418344] pci 0000:00:09.0:   bridge window [io  0xd000-0xdfff]
[    0.418347] pci 0000:00:09.0:   bridge window [mem
0xd0000000-0xd00fffff 64bit pref]
[    0.418350] pci 0000:00:0a.0: PCI bridge to [bus 04]
[    0.418352] pci 0000:00:0a.0:   bridge window [mem 0xfe800000-0xfe8fffff]
[    0.418356] pci 0000:00:14.4: PCI bridge to [bus 05]
[    0.418358] pci 0000:00:14.4:   bridge window [io  0xc000-0xcfff]
[    0.418362] pci 0000:00:14.4:   bridge window [mem 0xfe700000-0xfe7fffff]
[    0.418368] pci 0000:00:15.0: PCI bridge to [bus 06]
[    0.418370] pci 0000:00:15.0:   bridge window [io  0xb000-0xbfff]
[    0.418374] pci 0000:00:15.0:   bridge window [mem 0xfe600000-0xfe6fffff]
[    0.418377] pci 0000:00:15.0:   bridge window [mem
0xb0000000-0xbfffffff 64bit pref]
[    0.418381] pci_bus 0000:00: resource 4 [io  0x0000-0x03af]
[    0.418383] pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7]
[    0.418385] pci_bus 0000:00: resource 6 [io  0x03b0-0x03df]
[    0.418386] pci_bus 0000:00: resource 7 [io  0x0d00-0xffff]
[    0.418388] pci_bus 0000:00: resource 8 [mem 0x000a0000-0x000bffff]
[    0.418389] pci_bus 0000:00: resource 9 [mem 0x000c0000-0x000dffff]
[    0.418391] pci_bus 0000:00: resource 10 [mem 0xb0000000-0xffffffff]
[    0.418393] pci_bus 0000:01: resource 0 [io  0xe000-0xefff]
[    0.418394] pci_bus 0000:01: resource 1 [mem 0xfea00000-0xfeafffff]
[    0.418396] pci_bus 0000:01: resource 2 [mem 0xc0000000-0xcfffffff
64bit pref]
[    0.418398] pci_bus 0000:02: resource 1 [mem 0xfe900000-0xfe9fffff]
[    0.418400] pci_bus 0000:03: resource 0 [io  0xd000-0xdfff]
[    0.418401] pci_bus 0000:03: resource 2 [mem 0xd0000000-0xd00fffff
64bit pref]
[    0.418403] pci_bus 0000:04: resource 1 [mem 0xfe800000-0xfe8fffff]
[    0.418405] pci_bus 0000:05: resource 0 [io  0xc000-0xcfff]
[    0.418406] pci_bus 0000:05: resource 1 [mem 0xfe700000-0xfe7fffff]
[    0.418408] pci_bus 0000:05: resource 4 [io  0x0000-0x03af]
[    0.418409] pci_bus 0000:05: resource 5 [io  0x03e0-0x0cf7]
[    0.418411] pci_bus 0000:05: resource 6 [io  0x03b0-0x03df]
[    0.418412] pci_bus 0000:05: resource 7 [io  0x0d00-0xffff]
[    0.418414] pci_bus 0000:05: resource 8 [mem 0x000a0000-0x000bffff]
[    0.418416] pci_bus 0000:05: resource 9 [mem 0x000c0000-0x000dffff]
[    0.418417] pci_bus 0000:05: resource 10 [mem 0xb0000000-0xffffffff]
[    0.418419] pci_bus 0000:06: resource 0 [io  0xb000-0xbfff]
[    0.418420] pci_bus 0000:06: resource 1 [mem 0xfe600000-0xfe6fffff]
[    0.418422] pci_bus 0000:06: resource 2 [mem 0xb0000000-0xbfffffff
64bit pref]
[    0.418454] NET: Registered protocol family 2
[    0.418632] TCP established hash table entries: 65536 (order: 7,
524288 bytes)
[    0.418890] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.419226] TCP: Hash tables configured (established 65536 bind 65536)
[    0.419282] TCP: reno registered
[    0.419295] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    0.419354] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    0.419468] NET: Registered protocol family 1
[    0.744556] pci 0000:01:00.0: Boot video device
[    0.744760] PCI: CLS 64 bytes, default 64
[    0.744826] Trying to unpack rootfs image as initramfs...
[    1.027398] Freeing initrd memory: 17232K (ffff880035e48000 -
ffff880036f1c000)
[    1.027880] AMD-Vi: Found IOMMU at 0000:00:00.2 cap 0x40
[    1.027882] AMD-Vi: Interrupt remapping enabled
[    1.027896] pci 0000:00:00.2: irq 72 for MSI/MSI-X
[    1.038042] AMD-Vi: Lazy IO/TLB flushing enabled
[    1.118135] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.118138] software IO TLB [mem 0xaa483000-0xae483000] (64MB) mapped
at [ffff8800aa483000-ffff8800ae482fff]
[    1.118356] LVT offset 1 assigned for vector 0x400
[    1.118361] IBS: LVT offset 1 assigned
[    1.118385] perf: AMD IBS detected (0x0000001f)
[    1.118422] Scanning for low memory corruption every 60 seconds
[    1.118726] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    1.118748] Initialise system trusted keyring
[    1.118764] audit: initializing netlink subsys (disabled)
[    1.118783] audit: type=2000 audit(1401121035.932:1): initialized
[    1.143436] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.144870] zbud: loaded
[    1.145213] VFS: Disk quotas dquot_6.5.2
[    1.145250] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.145861] fuse init (API version 7.23)
[    1.145999] msgmni has been set to 15919
[    1.146062] Key type big_key registered
[    2.116171] tsc: Refined TSC clocksource calibration: 2812.852 MHz
[    3.120187] Switched to clocksource tsc
[    3.120213] Key type asymmetric registered
[    3.120214] Asymmetric key parser 'x509' registered
[    3.120285] Block layer SCSI generic (bsg) driver version 0.4 loaded
(major 252)
[    3.120408] io scheduler noop registered
[    3.120413] io scheduler deadline registered (default)
[    3.120480] io scheduler cfq registered
[    3.120859] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    3.120873] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    3.120918] vesafb: mode is 1400x1050x32, linelength=5632, pages=0
[    3.120920] vesafb: scrolling: redraw
[    3.120921] vesafb: Truecolor: size=0:8:8:8, shift=0:16:8:0
[    3.121180] vesafb: framebuffer at 0xc0000000, mapped to
0xffffc90010e80000, using 5824k, total 5824k
[    3.136261] Console: switching to colour frame buffer device 175x65
[    3.151130] fb0: VESA VGA frame buffer device
[    3.151237] input: Power Button as
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
[    3.151241] ACPI: Power Button [PWRB]
[    3.151279] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    3.151281] ACPI: Power Button [PWRF]
[    4.115934] ACPI: processor limited to max C-state 1
[    4.116445] GHES: HEST is not enabled!
[    4.116584] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
[    4.136942] 00:03: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200)
is a 16550A
[    4.138520] Linux agpgart interface v0.103
[    4.140387] brd: module loaded
[    4.141261] loop: module loaded
[    4.141686] libphy: Fixed MDIO Bus: probed
[    4.141780] tun: Universal TUN/TAP device driver, 1.6
[    4.141781] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    4.141871] PPP generic driver version 2.4.2
[    4.141911] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    4.141915] ehci-pci: EHCI PCI platform driver
[    4.142019] QUIRK: Enable AMD PLL fix
[    4.142045] ehci-pci 0000:00:12.2: EHCI Host Controller
[    4.142051] ehci-pci 0000:00:12.2: new USB bus registered, assigned
bus number 1
[    4.142055] ehci-pci 0000:00:12.2: applying AMD
SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    4.142064] ehci-pci 0000:00:12.2: debug port 1
[    4.142110] ehci-pci 0000:00:12.2: irq 17, io mem 0xfeb09000
[    4.151906] ehci-pci 0000:00:12.2: USB 2.0 started, EHCI 1.00
[    4.151964] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    4.151966] usb usb1: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    4.151968] usb usb1: Product: EHCI Host Controller
[    4.151970] usb usb1: Manufacturer: Linux 3.15.0-031500rc6-generic
ehci_hcd
[    4.151971] usb usb1: SerialNumber: 0000:00:12.2
[    4.152140] hub 1-0:1.0: USB hub found
[    4.152147] hub 1-0:1.0: 5 ports detected
[    4.152375] ehci-pci 0000:00:13.2: EHCI Host Controller
[    4.152381] ehci-pci 0000:00:13.2: new USB bus registered, assigned
bus number 2
[    4.152384] ehci-pci 0000:00:13.2: applying AMD
SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    4.152393] ehci-pci 0000:00:13.2: debug port 1
[    4.152422] ehci-pci 0000:00:13.2: irq 17, io mem 0xfeb07000
[    4.163904] ehci-pci 0000:00:13.2: USB 2.0 started, EHCI 1.00
[    4.163988] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    4.163989] usb usb2: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    4.163991] usb usb2: Product: EHCI Host Controller
[    4.163992] usb usb2: Manufacturer: Linux 3.15.0-031500rc6-generic
ehci_hcd
[    4.163994] usb usb2: SerialNumber: 0000:00:13.2
[    4.164156] hub 2-0:1.0: USB hub found
[    4.164162] hub 2-0:1.0: 5 ports detected
[    4.164386] ehci-pci 0000:00:16.2: EHCI Host Controller
[    4.164392] ehci-pci 0000:00:16.2: new USB bus registered, assigned
bus number 3
[    4.164395] ehci-pci 0000:00:16.2: applying AMD
SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    4.164404] ehci-pci 0000:00:16.2: debug port 1
[    4.164434] ehci-pci 0000:00:16.2: irq 17, io mem 0xfeb04000
[    4.175903] ehci-pci 0000:00:16.2: USB 2.0 started, EHCI 1.00
[    4.175980] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[    4.175982] usb usb3: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    4.175983] usb usb3: Product: EHCI Host Controller
[    4.175985] usb usb3: Manufacturer: Linux 3.15.0-031500rc6-generic
ehci_hcd
[    4.175986] usb usb3: SerialNumber: 0000:00:16.2
[    4.176141] hub 3-0:1.0: USB hub found
[    4.176150] hub 3-0:1.0: 4 ports detected
[    4.176273] ehci-platform: EHCI generic platform driver
[    4.176285] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    4.176288] ohci-pci: OHCI PCI platform driver
[    4.176384] ohci-pci 0000:00:12.0: OHCI PCI host controller
[    4.176389] ohci-pci 0000:00:12.0: new USB bus registered, assigned
bus number 4
[    4.176419] ohci-pci 0000:00:12.0: irq 18, io mem 0xfeb0a000
[    4.235999] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    4.236003] usb usb4: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    4.236004] usb usb4: Product: OHCI PCI host controller
[    4.236006] usb usb4: Manufacturer: Linux 3.15.0-031500rc6-generic
ohci_hcd
[    4.236007] usb usb4: SerialNumber: 0000:00:12.0
[    4.236179] hub 4-0:1.0: USB hub found
[    4.236188] hub 4-0:1.0: 5 ports detected
[    4.236396] ohci-pci 0000:00:13.0: OHCI PCI host controller
[    4.236401] ohci-pci 0000:00:13.0: new USB bus registered, assigned
bus number 5
[    4.236427] ohci-pci 0000:00:13.0: irq 18, io mem 0xfeb08000
[    4.295943] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    4.295947] usb usb5: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    4.295948] usb usb5: Product: OHCI PCI host controller
[    4.295950] usb usb5: Manufacturer: Linux 3.15.0-031500rc6-generic
ohci_hcd
[    4.295951] usb usb5: SerialNumber: 0000:00:13.0
[    4.296123] hub 5-0:1.0: USB hub found
[    4.296131] hub 5-0:1.0: 5 ports detected
[    4.296348] ohci-pci 0000:00:14.5: OHCI PCI host controller
[    4.296353] ohci-pci 0000:00:14.5: new USB bus registered, assigned
bus number 6
[    4.296380] ohci-pci 0000:00:14.5: irq 18, io mem 0xfeb06000
[    4.355936] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[    4.355939] usb usb6: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    4.355941] usb usb6: Product: OHCI PCI host controller
[    4.355942] usb usb6: Manufacturer: Linux 3.15.0-031500rc6-generic
ohci_hcd
[    4.355943] usb usb6: SerialNumber: 0000:00:14.5
[    4.356107] hub 6-0:1.0: USB hub found
[    4.356115] hub 6-0:1.0: 2 ports detected
[    4.356288] ohci-pci 0000:00:16.0: OHCI PCI host controller
[    4.356293] ohci-pci 0000:00:16.0: new USB bus registered, assigned
bus number 7
[    4.356319] ohci-pci 0000:00:16.0: irq 18, io mem 0xfeb05000
[    4.415935] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[    4.415938] usb usb7: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    4.415940] usb usb7: Product: OHCI PCI host controller
[    4.415942] usb usb7: Manufacturer: Linux 3.15.0-031500rc6-generic
ohci_hcd
[    4.415943] usb usb7: SerialNumber: 0000:00:16.0
[    4.416111] hub 7-0:1.0: USB hub found
[    4.416120] hub 7-0:1.0: 4 ports detected
[    4.416241] ohci-platform: OHCI generic platform driver
[    4.416252] uhci_hcd: USB Universal Host Controller Interface driver
[    4.416350] xhci_hcd 0000:02:00.0: xHCI Host Controller
[    4.416355] xhci_hcd 0000:02:00.0: new USB bus registered, assigned
bus number 8
[    4.416461] xhci_hcd 0000:02:00.0: irq 73 for MSI/MSI-X
[    4.416520] usb usb8: New USB device found, idVendor=1d6b, idProduct=0002
[    4.416522] usb usb8: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    4.416523] usb usb8: Product: xHCI Host Controller
[    4.416525] usb usb8: Manufacturer: Linux 3.15.0-031500rc6-generic
xhci_hcd
[    4.416526] usb usb8: SerialNumber: 0000:02:00.0
[    4.416694] hub 8-0:1.0: USB hub found
[    4.416703] hub 8-0:1.0: 2 ports detected
[    4.416785] xhci_hcd 0000:02:00.0: xHCI Host Controller
[    4.416788] xhci_hcd 0000:02:00.0: new USB bus registered, assigned
bus number 9
[    4.416823] usb usb9: New USB device found, idVendor=1d6b, idProduct=0003
[    4.416825] usb usb9: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    4.416826] usb usb9: Product: xHCI Host Controller
[    4.416828] usb usb9: Manufacturer: Linux 3.15.0-031500rc6-generic
xhci_hcd
[    4.416829] usb usb9: SerialNumber: 0000:02:00.0
[    4.416959] hub 9-0:1.0: USB hub found
[    4.416966] hub 9-0:1.0: 2 ports detected
[    4.417079] xhci_hcd 0000:04:00.0: xHCI Host Controller
[    4.417083] xhci_hcd 0000:04:00.0: new USB bus registered, assigned
bus number 10
[    4.417182] xhci_hcd 0000:04:00.0: irq 74 for MSI/MSI-X
[    4.417234] usb usb10: New USB device found, idVendor=1d6b,
idProduct=0002
[    4.417236] usb usb10: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    4.417237] usb usb10: Product: xHCI Host Controller
[    4.417239] usb usb10: Manufacturer: Linux 3.15.0-031500rc6-generic
xhci_hcd
[    4.417240] usb usb10: SerialNumber: 0000:04:00.0
[    4.417368] hub 10-0:1.0: USB hub found
[    4.417377] hub 10-0:1.0: 2 ports detected
[    4.417457] xhci_hcd 0000:04:00.0: xHCI Host Controller
[    4.417460] xhci_hcd 0000:04:00.0: new USB bus registered, assigned
bus number 11
[    4.417493] usb usb11: New USB device found, idVendor=1d6b,
idProduct=0003
[    4.417494] usb usb11: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    4.417496] usb usb11: Product: xHCI Host Controller
[    4.417497] usb usb11: Manufacturer: Linux 3.15.0-031500rc6-generic
xhci_hcd
[    4.417499] usb usb11: SerialNumber: 0000:04:00.0
[    4.417654] hub 11-0:1.0: USB hub found
[    4.417664] hub 11-0:1.0: 2 ports detected
[    4.417785] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    4.418143] serio: i8042 KBD port at 0x60,0x64 irq 1
[    4.418149] serio: i8042 AUX port at 0x60,0x64 irq 12
[    4.418300] mousedev: PS/2 mouse device common for all mice
[    4.418417] rtc_cmos 00:05: RTC can wake from S4
[    4.418546] rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
[    4.418568] rtc_cmos 00:05: alarms up to one month, y3k, 114 bytes
nvram, hpet irqs
[    4.418620] device-mapper: uevent: version 1.0.3
[    4.418757] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30)
initialised: dm-devel@redhat.com
[    4.418768] ledtrig-cpu: registered to indicate activity on CPUs
[    4.418851] TCP: cubic registered
[    4.418952] NET: Registered protocol family 10
[    4.419219] NET: Registered protocol family 17
[    4.419228] Key type dns_resolver registered
[    4.419584] Loading compiled-in X.509 certificates
[    4.420543] Loaded X.509 cert 'Magrathea: Glacier signing key:
ea48b932ca3552e65a3696b617c2f91b124e9f38'
[    4.420557] registered taskstats version 1
[    4.425068] Key type trusted registered
[    4.427555] Key type encrypted registered
[    4.430010] AppArmor: AppArmor sha1 policy hashing enabled
[    4.430015] ima: No TPM chip found, activating TPM-bypass!
[    4.430462]   Magic number: 14:364:288
[    4.430505] tty tty21: hash matches
[    4.430590] rtc_cmos 00:05: setting system clock to 2014-05-26
16:17:19 UTC (1401121039)
[    4.430799] acpi-cpufreq: overriding BIOS provided _PSD data
[    4.430958] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    4.430959] EDD information not available.
[    4.431028] PM: Hibernation image not present or could not be loaded.
[    4.432448] Freeing unused kernel memory: 1356K (ffffffff81d20000 -
ffffffff81e73000)
[    4.432451] Write protecting the kernel read-only data: 12288k
[    4.433962] Freeing unused kernel memory: 516K (ffff88000177f000 -
ffff880001800000)
[    4.435247] Freeing unused kernel memory: 472K (ffff880001b8a000 -
ffff880001c00000)
[    4.456890] udevd[118]: starting version 175
[    4.520682] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    4.520692] r8169 0000:03:00.0: can't disable ASPM; OS doesn't have
ASPM control
[    4.520923] r8169 0000:03:00.0: irq 75 for MSI/MSI-X
[    4.521116] r8169 0000:03:00.0 eth0: RTL8168evl/8111evl at
0xffffc90000c5c000, 94:de:80:c3:b2:95, XID 0c900800 IRQ 75
[    4.521118] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200
bytes, tx checksumming: ko]
[    4.527822] ahci 0000:00:11.0: version 3.0
[    4.528155] ahci 0000:00:11.0: AHCI 0001.0200 32 slots 6 ports 6 Gbps
0x3f impl SATA mode
[    4.528159] ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo
pmp pio slum part
[    4.531961] scsi0 : ahci
[    4.534817] scsi1 : ahci
[    4.535189] scsi2 : ahci
[    4.535297] scsi3 : ahci
[    4.535575] scsi4 : ahci
[    4.535778] scsi5 : ahci
[    4.535851] ata1: SATA max UDMA/133 abar m1024@0xfeb0b000 port
0xfeb0b100 irq 19
[    4.535854] ata2: SATA max UDMA/133 abar m1024@0xfeb0b000 port
0xfeb0b180 irq 19
[    4.535856] ata3: SATA max UDMA/133 abar m1024@0xfeb0b000 port
0xfeb0b200 irq 19
[    4.535859] ata4: SATA max UDMA/133 abar m1024@0xfeb0b000 port
0xfeb0b280 irq 19
[    4.535861] ata5: SATA max UDMA/133 abar m1024@0xfeb0b000 port
0xfeb0b300 irq 19
[    4.535863] ata6: SATA max UDMA/133 abar m1024@0xfeb0b000 port
0xfeb0b380 irq 19
[    4.595897] firewire_ohci 0000:05:0e.0: added OHCI v1.10 device as
card 0, 4 IR + 8 IT contexts, quirks 0x11
[    4.859885] ata5: SATA link down (SStatus 0 SControl 300)
[    4.859934] ata6: SATA link down (SStatus 0 SControl 300)
[    4.859963] ata4: SATA link down (SStatus 0 SControl 300)
[    5.027840] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    5.028387] ata1.00: ATA-9: SAMSUNG SSD 830 Series, CXM03B1Q, max
UDMA/133
[    5.028391] ata1.00: 250069680 sectors, multi 16: LBA48 NCQ (depth
31/32), AA
[    5.028730] ata1.00: configured for UDMA/133
[    5.028949] scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG SSD 830 
CXM0 PQ: 0 ANSI: 5
[    5.029402] sd 0:0:0:0: [sda] 250069680 512-byte logical blocks: (128
GB/119 GiB)
[    5.029425] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    5.029588] sd 0:0:0:0: [sda] Write Protect is off
[    5.029595] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    5.029720] sd 0:0:0:0: [sda] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    5.031796] ata2: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    5.031828] ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    5.031892]  sda: sda1 < sda5 sda6 sda7 sda8 > sda2
[    5.032960] sd 0:0:0:0: [sda] Attached SCSI disk
[    5.033025] ata2.00: ATA-8: ST31000524AS, JC45, max UDMA/133
[    5.033030] ata2.00: 1953525168 sectors, multi 16: LBA48 NCQ (depth
31/32)
[    5.034344] ata3.00: ATAPI: ATAPI   iHAS124   B, AL0Q, max UDMA/100
[    5.034551] ata2.00: configured for UDMA/133
[    5.034751] scsi 1:0:0:0: Direct-Access     ATA      ST31000524AS    
JC45 PQ: 0 ANSI: 5
[    5.035150] ata3.00: configured for UDMA/100
[    5.035194] sd 1:0:0:0: Attached scsi generic sg1 type 0
[    5.035203] sd 1:0:0:0: [sdb] 1953525168 512-byte logical blocks:
(1.00 TB/931 GiB)
[    5.035362] sd 1:0:0:0: [sdb] Write Protect is off
[    5.035366] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    5.035503] sd 1:0:0:0: [sdb] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    5.037170] scsi 2:0:0:0: CD-ROM            ATAPI    iHAS124   B     
AL0Q PQ: 0 ANSI: 5
[    5.056739] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw
xa/form2 cdda tray
[    5.056744] cdrom: Uniform CD-ROM driver Revision: 3.20
[    5.056946] sr 2:0:0:0: Attached scsi CD-ROM sr0
[    5.057085] sr 2:0:0:0: Attached scsi generic sg2 type 5
[    5.095913] firewire_core 0000:05:0e.0: created device fw0: GUID
0049e550b54d0c00, S400
[    5.099624]  sdb: sdb1 < sdb5 sdb6 sdb7 sdb8 sdb9 >
[    5.100123] sd 1:0:0:0: [sdb] Attached SCSI disk
[    5.207827] usb 5-2: new full-speed USB device number 2 using ohci-pci
[    5.209976] random: nonblocking pool is initialized
[    5.586836] usb 5-2: New USB device found, idVendor=0a12, idProduct=0001
[    5.586840] usb 5-2: New USB device strings: Mfr=0, Product=0,
SerialNumber=0
[    5.851725] usb 5-3: new full-speed USB device number 3 using ohci-pci
[    6.024780] usb 5-3: New USB device found, idVendor=046d, idProduct=c52b
[    6.024784] usb 5-3: New USB device strings: Mfr=1, Product=2,
SerialNumber=0
[    6.024786] usb 5-3: Product: USB Receiver
[    6.024788] usb 5-3: Manufacturer: Logitech
[    6.033462] hidraw: raw HID events driver (C) Jiri Kosina
[    6.046870] usbcore: registered new interface driver usbhid
[    6.046874] usbhid: USB HID core driver
[    6.055022] logitech-djreceiver 0003:046D:C52B.0003: hiddev0,hidraw0:
USB HID v1.11 Device [Logitech USB Receiver] on usb-0000:00:13.0-3/input2
[    6.110158] input: Logitech Unifying Device. Wireless PID:4024 as
/devices/pci0000:00/0000:00:13.0/usb5/5-3/5-3:1.2/0003:046D:C52B.0003/0003:046D:C52B.0004/input/input4
[    6.110308] logitech-djdevice 0003:046D:C52B.0004: input,hidraw1: USB
HID v1.11 Keyboard [Logitech Unifying Device. Wireless PID:4024] on
usb-0000:00:13.0-3:1
[    6.547642] usb 7-2: new low-speed USB device number 2 using ohci-pci
[    6.716700] usb 7-2: New USB device found, idVendor=046d, idProduct=c517
[    6.716704] usb 7-2: New USB device strings: Mfr=1, Product=2,
SerialNumber=0
[    6.716706] usb 7-2: Product: USB Receiver
[    6.716707] usb 7-2: Manufacturer: Logitech
[    6.737166] input: Logitech USB Receiver as
/devices/pci0000:00/0000:00:16.0/usb7/7-2/7-2:1.0/0003:046D:C517.0005/input/input5
[    6.737308] logitech 0003:046D:C517.0005: input,hidraw2: USB HID
v1.10 Keyboard [Logitech USB Receiver] on usb-0000:00:16.0-2/input0
[    6.737320] logitech 0003:046D:C517.0006: fixing up Logitech keyboard
report descriptor
[    6.737770] input: Logitech USB Receiver as
/devices/pci0000:00/0000:00:16.0/usb7/7-2/7-2:1.1/0003:046D:C517.0006/input/input6
[    6.737949] logitech 0003:046D:C517.0006: input,hiddev0,hidraw3: USB
HID v1.10 Mouse [Logitech USB Receiver] on usb-0000:00:16.0-2/input1
[    6.971681] usb 9-2: new SuperSpeed USB device number 2 using xhci_hcd
[    6.988216] usb 9-2: New USB device found, idVendor=1058, idProduct=0748
[    6.988220] usb 9-2: New USB device strings: Mfr=1, Product=2,
SerialNumber=5
[    6.988222] usb 9-2: Product: My Passport 0748
[    6.988223] usb 9-2: Manufacturer: Western Digital
[    6.988225] usb 9-2: SerialNumber: 575843314332325336333737
[    6.992786] usb-storage 9-2:1.0: USB Mass Storage device detected
[    6.993205] scsi6 : usb-storage 9-2:1.0
[    6.993322] usbcore: registered new interface driver usb-storage
[    6.994813] usbcore: registered new interface driver uas
[    7.991773] scsi 6:0:0:0: Direct-Access     WD       My Passport 0748
1010 PQ: 0 ANSI: 6
[    7.992007] scsi 6:0:0:1: Enclosure         WD       SES Device      
1010 PQ: 0 ANSI: 6
[    7.993252] sd 6:0:0:0: Attached scsi generic sg3 type 0
[    7.993498] scsi 6:0:0:1: Attached scsi generic sg4 type 13
[    7.993502] sd 6:0:0:0: [sdc] 1953458176 512-byte logical blocks:
(1.00 TB/931 GiB)
[    7.993961] sd 6:0:0:0: [sdc] Write Protect is off
[    7.993966] sd 6:0:0:0: [sdc] Mode Sense: 47 00 10 08
[    7.994264] sd 6:0:0:0: [sdc] No Caching mode page found
[    7.994363] sd 6:0:0:0: [sdc] Assuming drive cache: write through
[    7.995878]  sdc: sdc1
[    7.997058] sd 6:0:0:0: [sdc] Attached SCSI disk
[    8.155611] ses 6:0:0:1: Attached Enclosure device
[   10.153697] EXT4-fs (sda5): mounted filesystem with ordered data
mode. Opts: (null)
[   10.375995] Adding 6143996k swap on /dev/sda6.  Priority:-1 extents:1
across:6143996k SSFS
[   10.969983] EXT4-fs (sda5): re-mounted. Opts: errors=remount-ro
[   11.087476] EXT4-fs (sdc1): mounted filesystem with ordered data
mode. Opts: (null)
[   11.133075] EXT4-fs (sda2): mounted filesystem with ordered data
mode. Opts: (null)
[   11.168412] EXT4-fs (sda7): mounted filesystem with ordered data
mode. Opts: (null)
[   11.202688] EXT4-fs (sda8): mounted filesystem with ordered data
mode. Opts: (null)
[   11.358558] EXT4-fs (sdb8): mounted filesystem with ordered data
mode. Opts: (null)
[   11.574472] ISO 9660 Extensions: Microsoft Joliet Level 3
[   11.579274] ISOFS: changing to secondary root
[   11.596679] udevd[774]: starting version 175
[   11.653519] lp: driver loaded but no devices found
[   11.801250] piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xb00,
revision 0
[   11.801333] piix4_smbus 0000:00:14.0: Auxiliary SMBus Host Controller
at 0xb20
[   11.808282] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
[   11.808407] sp5100_tco: PCI Revision ID: 0x42
[   11.808445] sp5100_tco: Using 0xfed80b00 for watchdog MMIO address
[   11.808456] sp5100_tco: Last reboot was not triggered by watchdog.
[   11.809177] sp5100_tco: initialized (0xffffc90011442b00).
heartbeat=60 sec (nowayout=0)
[   11.844576] MCE: In-kernel MCE decoding enabled.
[   11.850338] EDAC MC: Ver: 3.0.0
[   11.853858] AMD64 EDAC driver v3.4.0
[   11.853896] EDAC amd64: DRAM ECC disabled.
[   11.853902] EDAC amd64: ECC disabled in the BIOS or no ECC
capability, module will not load.
[   11.853902]  Either enable ECC checking or force module loading by
setting 'ecc_enable_override'.
[   11.853902]  (Note that use of the override may cause unknown side
effects.)
[   11.871903] snd_hda_intel 0000:01:00.1: Handle VGA-switcheroo audio
client
[   11.872000] snd_hda_intel 0000:06:00.1: Handle VGA-switcheroo audio
client
[   11.872186] snd_hda_intel 0000:01:00.1: irq 76 for MSI/MSI-X
[   11.873264] snd_hda_intel 0000:06:00.1: irq 77 for MSI/MSI-X
[   11.889598] input: HDA ATI HDMI HDMI/DP,pcm=3 as
/devices/pci0000:00/0000:00:02.0/0000:01:00.1/sound/card1/input8
[   11.901051] sound hdaudioC0D0: autoconfig: line_outs=4
(0x24/0x25/0x26/0x27/0x0) type:line
[   11.901057] sound hdaudioC0D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
[   11.901059] sound hdaudioC0D0:    hp_outs=1 (0x28/0x0/0x0/0x0/0x0)
[   11.901061] sound hdaudioC0D0:    mono: mono_out=0x0
[   11.901062] sound hdaudioC0D0:    dig-out=0x2d/0x2e
[   11.901063] sound hdaudioC0D0:    inputs:
[   11.901065] sound hdaudioC0D0:      Front Mic=0x29
[   11.901067] sound hdaudioC0D0:      Rear Mic=0x2b
[   11.901069] sound hdaudioC0D0:      Line=0x2a
[   11.911223] input: HDA ATI HDMI HDMI/DP,pcm=3 as
/devices/pci0000:00/0000:00:15.0/0000:06:00.1/sound/card2/input17
[   11.912999] input: HDA ATI SB Front Mic as
/devices/pci0000:00/0000:00:14.2/sound/card0/input9
[   11.913070] input: HDA ATI SB Rear Mic as
/devices/pci0000:00/0000:00:14.2/sound/card0/input10
[   11.913132] input: HDA ATI SB Line as
/devices/pci0000:00/0000:00:14.2/sound/card0/input11
[   11.913188] input: HDA ATI SB Line Out Front as
/devices/pci0000:00/0000:00:14.2/sound/card0/input12
[   11.913248] input: HDA ATI SB Line Out Surround as
/devices/pci0000:00/0000:00:14.2/sound/card0/input13
[   11.913318] input: HDA ATI SB Line Out CLFE as
/devices/pci0000:00/0000:00:14.2/sound/card0/input14
[   11.913385] input: HDA ATI SB Line Out Side as
/devices/pci0000:00/0000:00:14.2/sound/card0/input15
[   11.913453] input: HDA ATI SB Front Headphone as
/devices/pci0000:00/0000:00:14.2/sound/card0/input16
[   12.034106] Bluetooth: Core ver 2.19
[   12.034131] NET: Registered protocol family 31
[   12.034131] Bluetooth: HCI device and connection manager initialized
[   12.034139] Bluetooth: HCI socket layer initialized
[   12.034141] Bluetooth: L2CAP socket layer initialized
[   12.034149] Bluetooth: SCO socket layer initialized
[   12.053057] usbcore: registered new interface driver btusb
[   12.058245] audit: type=1400 audit(1401121047.124:2):
apparmor="STATUS" operation="profile_load" name="/sbin/dhclient" pid=859
comm="apparmor_parser"
[   12.058357] audit: type=1400 audit(1401121047.124:3):
apparmor="STATUS" operation="profile_load"
name="/usr/lib/NetworkManager/nm-dhcp-client.action" pid=859
comm="apparmor_parser"
[   12.058457] audit: type=1400 audit(1401121047.124:4):
apparmor="STATUS" operation="profile_load"
name="/usr/lib/connman/scripts/dhclient-script" pid=859
comm="apparmor_parser"
[   12.286662] audit: type=1400 audit(1401121047.352:5):
apparmor="STATUS" operation="profile_load" name="/usr/sbin/ntpd"
pid=1147 comm="apparmor_parser"
[   12.342966] audit: type=1400 audit(1401121047.412:6):
apparmor="STATUS" operation="profile_replace" name="/sbin/dhclient"
pid=1102 comm="apparmor_parser"
[   12.343101] audit: type=1400 audit(1401121047.412:7):
apparmor="STATUS" operation="profile_replace"
name="/usr/lib/NetworkManager/nm-dhcp-client.action" pid=1102
comm="apparmor_parser"
[   12.343195] audit: type=1400 audit(1401121047.412:8):
apparmor="STATUS" operation="profile_replace"
name="/usr/lib/connman/scripts/dhclient-script" pid=1102
comm="apparmor_parser"
[   12.563461] audit: type=1400 audit(1401121047.632:9):
apparmor="STATUS" operation="profile_replace" name="/usr/sbin/ntpd"
pid=1201 comm="apparmor_parser"
[   12.604629] ip_tables: (C) 2000-2006 Netfilter Core Team
[   24.856434] EXT4-fs (sdb9): mounted filesystem with ordered data
mode. Opts: (null)
[   24.912880] init: failsafe main process (1301) killed by TERM signal
[   24.931551] init: Failed to spawn connman main process: unable to
execute: No such file or directory
[   24.946654] ppdev: user-space parallel port driver
[   24.952749] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   24.952754] Bluetooth: BNEP filters: protocol multicast
[   24.952766] Bluetooth: BNEP socket layer initialized
[   24.969447] Bluetooth: RFCOMM TTY layer initialized
[   24.969464] Bluetooth: RFCOMM socket layer initialized
[   24.969474] Bluetooth: RFCOMM ver 1.11
[   25.131371] r8169 0000:03:00.0 eth0: link down
[   25.131395] r8169 0000:03:00.0 eth0: link down
[   25.131521] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   25.531343] audit: type=1400 audit(1401121060.600:10):
apparmor="STATUS" operation="profile_load"
name="/usr/lib/lightdm/lightdm/lightdm-guest-session-wrapper" pid=1425
comm="apparmor_parser"
[   25.531580] audit: type=1400 audit(1401121060.600:11):
apparmor="STATUS" operation="profile_load" name="chromium_browser"
pid=1425 comm="apparmor_parser"
[   25.643282] audit: type=1400 audit(1401121060.712:12):
apparmor="STATUS" operation="profile_load"
name="/usr/lib/cups/backend/cups-pdf" pid=1392 comm="apparmor_parser"
[   25.643558] audit: type=1400 audit(1401121060.712:13):
apparmor="STATUS" operation="profile_load" name="/usr/sbin/cupsd"
pid=1392 comm="apparmor_parser"
[   25.671178] audit: type=1400 audit(1401121060.740:14):
apparmor="STATUS" operation="profile_replace" name="/sbin/dhclient"
pid=1426 comm="apparmor_parser"
[   25.671371] audit: type=1400 audit(1401121060.740:15):
apparmor="STATUS" operation="profile_replace"
name="/usr/lib/NetworkManager/nm-dhcp-client.action" pid=1426
comm="apparmor_parser"
[   25.671486] audit: type=1400 audit(1401121060.740:16):
apparmor="STATUS" operation="profile_replace"
name="/usr/lib/connman/scripts/dhclient-script" pid=1426
comm="apparmor_parser"
[   25.891323] audit: type=1400 audit(1401121060.960:17):
apparmor="STATUS" operation="profile_replace" name="/usr/sbin/ntpd"
pid=1439 comm="apparmor_parser"
[   25.942442] audit: type=1400 audit(1401121061.012:18):
apparmor="STATUS" operation="profile_load"
name="/usr/lib/telepathy/mission-control-5" pid=1429 comm="apparmor_parser"
[   25.942804] audit: type=1400 audit(1401121061.012:19):
apparmor="STATUS" operation="profile_load"
name="/usr/lib/telepathy/telepathy-*" pid=1429 comm="apparmor_parser"
[   27.085117] r8169 0000:03:00.0 eth0: link up
[   27.085129] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   34.038633] audit_printk_skb: 9 callbacks suppressed
[   34.038638] audit: type=1400 audit(1401121069.108:23):
apparmor="STATUS" operation="profile_load" name="/usr/bin/evince"
pid=1427 comm="apparmor_parser"
[   34.039586] audit: type=1400 audit(1401121069.108:24):
apparmor="STATUS" operation="profile_load" name="launchpad_integration"
pid=1427 comm="apparmor_parser"
[   34.039919] audit: type=1400 audit(1401121069.108:25):
apparmor="STATUS" operation="profile_load" name="sanitized_helper"
pid=1427 comm="apparmor_parser"
[   34.041361] audit: type=1400 audit(1401121069.112:26):
apparmor="STATUS" operation="profile_load"
name="/usr/bin/evince-previewer" pid=1427 comm="apparmor_parser"
[   34.042151] audit: type=1400 audit(1401121069.112:27):
apparmor="STATUS" operation="profile_load" name="launchpad_integration"
pid=1427 comm="apparmor_parser"
[   34.042472] audit: type=1400 audit(1401121069.112:28):
apparmor="STATUS" operation="profile_load" name="sanitized_helper"
pid=1427 comm="apparmor_parser"
[   34.043418] audit: type=1400 audit(1401121069.112:29):
apparmor="STATUS" operation="profile_load"
name="/usr/bin/evince-thumbnailer" pid=1427 comm="apparmor_parser"
[   34.043937] audit: type=1400 audit(1401121069.112:30):
apparmor="STATUS" operation="profile_load" name="sanitized_helper"
pid=1427 comm="apparmor_parser"
[   34.134295] init: alsa-restore main process (1747) terminated with
status 99
[   34.246901] vgaarb: this pci device is not a vga device
[   34.246914] vgaarb: this pci device is not a vga device
[   34.246923] vgaarb: this pci device is not a vga device
[   34.246931] vgaarb: this pci device is not a vga device
[   34.246940] vgaarb: this pci device is not a vga device
[   34.246948] vgaarb: this pci device is not a vga device
[   34.246956] vgaarb: this pci device is not a vga device
[   34.246965] vgaarb: this pci device is not a vga device
[   34.246974] vgaarb: this pci device is not a vga device
[   34.246984] vgaarb: this pci device is not a vga device
[   34.246993] vgaarb: this pci device is not a vga device
[   34.247002] vgaarb: this pci device is not a vga device
[   34.247011] vgaarb: this pci device is not a vga device
[   34.247021] vgaarb: this pci device is not a vga device
[   34.247031] vgaarb: this pci device is not a vga device
[   34.247041] vgaarb: this pci device is not a vga device
[   34.247051] vgaarb: this pci device is not a vga device
[   34.247061] vgaarb: this pci device is not a vga device
[   34.247071] vgaarb: this pci device is not a vga device
[   34.247081] vgaarb: this pci device is not a vga device
[   34.247091] vgaarb: this pci device is not a vga device
[   34.247102] vgaarb: this pci device is not a vga device
[   34.247112] vgaarb: this pci device is not a vga device
[   34.247123] vgaarb: this pci device is not a vga device
[   34.247146] vgaarb: this pci device is not a vga device
[   34.247160] vgaarb: this pci device is not a vga device
[   34.247174] vgaarb: this pci device is not a vga device
[   34.247188] vgaarb: this pci device is not a vga device
[   34.247203] vgaarb: this pci device is not a vga device
[   34.247227] vgaarb: device changed decodes:
PCI:0000:06:00.0,olddecodes=io+mem,decodes=none:owns=none
[   34.247251] vgaarb: this pci device is not a vga device
[   36.269913] Guest personality initialized and is inactive
[   36.270303] VMCI host device registered (name=vmci, major=10, minor=57)
[   36.270305] Initialized host personality
[   36.299683] NET: Registered protocol family 40
[   37.363193] init: plymouth-stop pre-start process (2717) terminated
with status 1

# EOF


On 05/26/2014 03:14 AM, Michal Hocko wrote:
> Hi,
>
> On Sun 25-05-14 17:42:37, Doug Morse wrote:
> [...]
>>     root@s3:~# dmesg | grep -n Memory:
>>
>>     203:[    0.000000] Memory: 8133320K/8364800K available (7665K kernel code, 1147K rwdata, 3624K rodata, 1356K init, 1432K bss, 231480K reserved)
> Could you post the full dmesg output, please?
> [...]


-- 

doug morse | dougmorse.org | +1 615 340 3400

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
