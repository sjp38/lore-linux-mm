Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id CB4FF6B0253
	for <linux-mm@kvack.org>; Sun, 13 Sep 2015 23:21:10 -0400 (EDT)
Received: by lbpo4 with SMTP id o4so60770355lbp.2
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 20:21:10 -0700 (PDT)
Received: from mail-la0-x233.google.com (mail-la0-x233.google.com. [2a00:1450:4010:c03::233])
        by mx.google.com with ESMTPS id qb2si8321091lbb.85.2015.09.13.20.21.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Sep 2015 20:21:08 -0700 (PDT)
Received: by lamp12 with SMTP id p12so77608940lam.0
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 20:21:07 -0700 (PDT)
MIME-Version: 1.0
From: =?UTF-8?Q?=C3=96zkan_Pakdil?= <ozkan.pakdil@gmail.com>
Date: Mon, 14 Sep 2015 05:20:47 +0200
Message-ID: <CAEqaY8cE7C2UvQP5x6VswOG46Gn+W+NYzWvFyqwXSjLaaTZBJg@mail.gmail.com>
Subject: how can I solve this grep problem
Content-Type: multipart/alternative; boundary=001a11c30fa8609855051fac8e04
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a11c30fa8609855051fac8e04
Content-Type: text/plain; charset=UTF-8

Hello

I was searching some strings in my disk yes I mean whole disk like this

find / -type f -exec grep -sl "access denied" {} \;

then I start seeing this messages

[121338.113923] do_IRQ: 3.228 No irq handler for vector (irq -1)

when I check the dmesg I saw some others and one of them was like this

[ 6181.655960] grep: The scan_unevictable_pages sysctl/node-interface has
been disabled for lack of a legitimate use case.  If you have one, please
send an email to linux-mm@kvack.org.

this is why I am sending this email. how can I solve this message ?

thanks

all dmesg output:

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.16.0-4-amd64 (debian-kernel@lists.debian.org)
(gcc version 4.8.4 (Debian 4.8.4-1) ) #1 SMP Debian 3.16.7-ckt11-1+deb8u3
(2015-08-04)
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.16.0-4-amd64
root=UUID=879fd989-f331-4a17-a930-e3f003666d2e ro nomodeset
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009ebff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009ec00-0x000000000009ffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff]
reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bf77ffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bf780000-0x00000000bf78dfff] ACPI
data
[    0.000000] BIOS-e820: [mem 0x00000000bf78e000-0x00000000bf7cffff] ACPI
NVS
[    0.000000] BIOS-e820: [mem 0x00000000bf7d0000-0x00000000bf7dffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000bf7ec000-0x00000000bfffffff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff]
reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffc00000-0x00000000ffffffff]
reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x0000000c3fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.5 present.
[    0.000000] DMI: MSI MS-7522/MSI X58 Pro (MS-7522)  , BIOS V8.14B8
11/09/2012
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] AGP: No AGP bridge found
[    0.000000] e820: last_pfn = 0xc40000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-CFFFF write-protect
[    0.000000]   D0000-DFFFF uncachable
[    0.000000]   E0000-E3FFF write-protect
[    0.000000]   E4000-E7FFF write-through
[    0.000000]   E8000-EBFFF write-protect
[    0.000000]   EC000-EFFFF write-through
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask 800000000 write-back
[    0.000000]   1 base 800000000 mask C00000000 write-back
[    0.000000]   2 base C00000000 mask FC0000000 write-back
[    0.000000]   3 base 0C0000000 mask FC0000000 uncachable
[    0.000000]   4 base 0BF800000 mask FFF800000 uncachable
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new
0x7010600070106
[    0.000000] e820: update [mem 0xbf800000-0xffffffff] usable ==> reserved
[    0.000000] e820: last_pfn = 0xbf780 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000ff780-0x000ff78f] mapped at
[ffff8800000ff780]
[    0.000000] Base memory trampoline at [ffff880000098000] 98000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01af4000, 0x01af4fff] PGTABLE
[    0.000000] BRK [0x01af5000, 0x01af5fff] PGTABLE
[    0.000000] BRK [0x01af6000, 0x01af6fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0xc3fe00000-0xc3fffffff]
[    0.000000]  [mem 0xc3fe00000-0xc3fffffff] page 2M
[    0.000000] BRK [0x01af7000, 0x01af7fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0xc3c000000-0xc3fdfffff]
[    0.000000]  [mem 0xc3c000000-0xc3fdfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0xc00000000-0xc3bffffff]
[    0.000000]  [mem 0xc00000000-0xc3bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0xbf77ffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0xbf5fffff] page 2M
[    0.000000]  [mem 0xbf600000-0xbf77ffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0xbffffffff]
[    0.000000]  [mem 0x100000000-0xbffffffff] page 2M
[    0.000000] BRK [0x01af8000, 0x01af8fff] PGTABLE
[    0.000000] BRK [0x01af9000, 0x01af9fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x35f1c000-0x36f85fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000FA590 000014 (v00 ACPIAM)
[    0.000000] ACPI: RSDT 0x00000000BF780000 00003C (v01 7522MT A7522800
20120925 MSFT 00000097)
[    0.000000] ACPI: FACP 0x00000000BF780200 000084 (v01 7522MT A7522800
20120925 MSFT 00000097)
[    0.000000] ACPI: DSDT 0x00000000BF780480 006E82 (v01 A7522  A7522800
00000800 INTL 20051117)
[    0.000000] ACPI: FACS 0x00000000BF78E000 000040
[    0.000000] ACPI: APIC 0x00000000BF780390 0000AC (v01 7522MT A7522800
20120925 MSFT 00000097)
[    0.000000] ACPI: MCFG 0x00000000BF780440 00003C (v01 7522MT OEMMCFG
 20120925 MSFT 00000097)
[    0.000000] ACPI: OEMB 0x00000000BF78E040 00007A (v01 7522MT A7522800
20120925 MSFT 00000097)
[    0.000000] ACPI: HPET 0x00000000BF78A480 000038 (v01 7522MT OEMHPET
 20120925 MSFT 00000097)
[    0.000000] ACPI: SSDT 0x00000000BF790560 000363 (v01 DpgPmm CpuPm
 00000012 INTL 20051117)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x0000000c3fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0xc3fffffff]
[    0.000000]   NODE_DATA [mem 0xc3ffce000-0xc3ffd2fff]
[    0.000000]  [ffffea0000000000-ffffea002adfffff] PMD ->
[ffff880c0f600000-ffff880c395fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0xc3fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009dfff]
[    0.000000]   node   0: [mem 0x00100000-0xbf77ffff]
[    0.000000]   node   0: [mem 0x100000000-0xc3fffffff]
[    0.000000] On node 0 totalpages: 12580637
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 10667 pages used for memmap
[    0.000000]   DMA32 zone: 780160 pages, LIFO batch:31
[    0.000000]   Normal zone: 161280 pages used for memmap
[    0.000000]   Normal zone: 11796480 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x06] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x07] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x88] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x89] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x8a] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x8b] disabled)
[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI
0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0xffffffff base: 0xfed00000
[    0.000000] smpboot: Allowing 12 CPUs, 4 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009efff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xbf780000-0xbf78dfff]
[    0.000000] PM: Registered nosave memory: [mem 0xbf78e000-0xbf7cffff]
[    0.000000] PM: Registered nosave memory: [mem 0xbf7d0000-0xbf7dffff]
[    0.000000] PM: Registered nosave memory: [mem 0xbf7e0000-0xbf7ebfff]
[    0.000000] PM: Registered nosave memory: [mem 0xbf7ec000-0xbfffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xc0000000-0xfedfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xfee00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee01000-0xffbfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xffc00000-0xffffffff]
[    0.000000] e820: [mem 0xc0000000-0xfedfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:12
nr_node_ids:1
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff880c3fc00000 s80896 r8192
d21504 u131072
[    0.000000] pcpu-alloc: s80896 r8192 d21504 u131072 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 00 01 02 03 04 05 06 07 08 09 10 11 -- -- --
-- 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
Total pages: 12408613
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.16.0-4-amd64
root=UUID=879fd989-f331-4a17-a930-e3f003666d2e ro nomodeset
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] AGP: Checking aperture...
[    0.000000] AGP: No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 49538472K/50322548K available (5209K kernel code,
946K rwdata, 1832K rodata, 1204K init, 840K bss, 784076K reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=12.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=12
[    0.000000] NR_IRQS:33024 nr_irqs:776 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration failed
[    0.000000] tsc: PIT calibration matches HPET. 1 loops
[    0.000000] tsc: Detected 2806.961 MHz processor
[    0.000031] Calibrating delay loop (skipped), value calculated using
timer frequency.. 5613.92 BogoMIPS (lpj=11227844)
[    0.000147] pid_max: default: 32768 minimum: 301
[    0.000211] ACPI: Core revision 20140424
[    0.005912] ACPI: All ACPI Tables successfully acquired
[    0.029909] Security Framework initialized
[    0.029973] AppArmor: AppArmor disabled by boot time parameter
[    0.030039] Yama: disabled by default; enable with sysctl kernel.yama.*
[    0.034285] Dentry cache hash table entries: 8388608 (order: 14,
67108864 bytes)
[    0.046946] Inode-cache hash table entries: 4194304 (order: 13, 33554432
bytes)
[    0.052343] Mount-cache hash table entries: 131072 (order: 8, 1048576
bytes)
[    0.052475] Mountpoint-cache hash table entries: 131072 (order: 8,
1048576 bytes)
[    0.053070] Initializing cgroup subsys memory
[    0.053131] Initializing cgroup subsys devices
[    0.053194] Initializing cgroup subsys freezer
[    0.053252] Initializing cgroup subsys net_cls
[    0.053312] Initializing cgroup subsys blkio
[    0.053370] Initializing cgroup subsys perf_event
[    0.053428] Initializing cgroup subsys net_prio
[    0.053510] CPU: Physical Processor ID: 0
[    0.053565] CPU: Processor Core ID: 0
[    0.053624] mce: CPU supports 9 MCE banks
[    0.053692] CPU0: Thermal monitoring enabled (TM1)
[    0.053755] process: using mwait in idle threads
[    0.053814] Last level iTLB entries: 4KB 512, 2MB 7, 4MB 7
Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
tlb_flushall_shift: 6
[    0.054001] Freeing SMP alternatives memory: 20K (ffffffff81a1b000 -
ffffffff81a20000)
[    0.055213] ftrace: allocating 21623 entries in 85 pages
[    0.065126] Switched APIC routing to physical flat.
[    0.065564] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.105326] smpboot: CPU0: Intel(R) Core(TM) i7 CPU         930  @
2.80GHz (fam: 06, model: 1a, stepping: 05)
[    0.210111] Performance Events: PEBS fmt1+, 16-deep LBR, Nehalem events,
Intel PMU driver.
[    0.210333] perf_event_intel: CPU erratum AAJ80 worked around
[    0.210392] perf_event_intel: CPUID marked event: 'bus cycles'
unavailable
[    0.210454] ... version:                3
[    0.210509] ... bit width:              48
[    0.210564] ... generic registers:      4
[    0.210619] ... value mask:             0000ffffffffffff
[    0.210676] ... max period:             000000007fffffff
[    0.210734] ... fixed-purpose events:   3
[    0.210789] ... event mask:             000000070000000f
[    0.212392] x86: Booting SMP configuration:
[    0.212449] .... node  #0, CPUs:        #1
[    0.225819] NMI watchdog: enabled on all CPUs, permanently consumes one
hw-PMU counter.
[    0.226067]   #2  #3  #4  #5  #6  #7
[    0.307401] x86: Booted up 1 node, 8 CPUs
[    0.307507] smpboot: Total of 8 processors activated (44911.37 BogoMIPS)
[    0.313395] devtmpfs: initialized
[    0.321002] PM: Registering ACPI NVS region [mem 0xbf78e000-0xbf7cffff]
(270336 bytes)
[    0.321966] pinctrl core: initialized pinctrl subsystem
[    0.322097] NET: Registered protocol family 16
[    0.322260] cpuidle: using governor ladder
[    0.322316] cpuidle: using governor menu
[    0.322404] ACPI: bus type PCI registered
[    0.322460] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.322601] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
0xe0000000-0xefffffff] (base 0xe0000000)
[    0.322681] PCI: not using MMCONFIG
[    0.322735] PCI: Using configuration type 1 for base access
[    0.334566] ACPI: Added _OSI(Module Device)
[    0.334623] ACPI: Added _OSI(Processor Device)
[    0.334679] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.334735] ACPI: Added _OSI(Processor Aggregator Device)
[    0.336166] ACPI: Executed 1 blocks of module-level executable AML code
[    0.338902] ACPI: Dynamic OEM Table Load:
[    0.339031] ACPI: SSDT 0xFFFF880C0E24C000 001E1C (v01 DpgPmm P001Ist
 00000011 INTL 20051117)
[    0.339673] ACPI: Dynamic OEM Table Load:
[    0.339796] ACPI: SSDT 0xFFFF880C0E213800 000678 (v01 PmRef  P001Cst
 00003001 INTL 20051117)
[    0.349953] ACPI: Interpreter enabled
[    0.350014] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State
[\_S2_] (20140424/hwxface-580)
[    0.350160] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State
[\_S3_] (20140424/hwxface-580)
[    0.350314] ACPI: (supports S0 S1 S4 S5)
[    0.350369] ACPI: Using IOAPIC for interrupt routing
[    0.350448] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
0xe0000000-0xefffffff] (base 0xe0000000)
[    0.351026] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in
ACPI motherboard resources
[    0.351573] PCI: Using host bridge windows from ACPI; if necessary, use
"pci=nocrs" and report a bug
[    0.357224] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.357287] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM
ClockPM Segments MSI]
[    0.357520] acpi PNP0A08:00: _OSC: platform does not support
[PCIeCapability]
[    0.357656] acpi PNP0A08:00: _OSC: not requesting control; platform does
not support [PCIeCapability]
[    0.357735] acpi PNP0A08:00: _OSC: OS requested [PCIeHotplug PME AER
PCIeCapability]
[    0.357812] acpi PNP0A08:00: _OSC: platform willing to grant
[PCIeHotplug PME AER]
[    0.357888] acpi PNP0A08:00: _OSC failed (AE_SUPPORT); disabling ASPM
[    0.358228] PCI host bridge to bus 0000:00
[    0.358285] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.358346] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.358405] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.358464] pci_bus 0000:00: root bus resource [mem
0x000a0000-0x000bffff]
[    0.358525] pci_bus 0000:00: root bus resource [mem
0x000d0000-0x000dffff]
[    0.358585] pci_bus 0000:00: root bus resource [mem
0xc0000000-0xdfffffff]
[    0.358645] pci_bus 0000:00: root bus resource [mem
0xf0000000-0xfed8ffff]
[    0.358715] pci 0000:00:00.0: [8086:3405] type 00 class 0x060000
[    0.358770] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
[    0.358847] pci 0000:00:01.0: [8086:3408] type 01 class 0x060400
[    0.358901] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.358944] pci 0000:00:01.0: System wakeup disabled by ACPI
[    0.359040] pci 0000:00:03.0: [8086:340a] type 01 class 0x060400
[    0.359097] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    0.359140] pci 0000:00:03.0: System wakeup disabled by ACPI
[    0.359237] pci 0000:00:07.0: [8086:340e] type 01 class 0x060400
[    0.359290] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
[    0.359331] pci 0000:00:07.0: System wakeup disabled by ACPI
[    0.359432] pci 0000:00:14.0: [8086:342e] type 00 class 0x080000
[    0.359537] pci 0000:00:14.1: [8086:3422] type 00 class 0x080000
[    0.359639] pci 0000:00:14.2: [8086:3423] type 00 class 0x080000
[    0.359740] pci 0000:00:14.3: [8086:3438] type 00 class 0x080000
[    0.359835] pci 0000:00:1a.0: [8086:3a37] type 00 class 0x0c0300
[    0.359874] pci 0000:00:1a.0: reg 0x20: [io  0xbc00-0xbc1f]
[    0.359956] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    0.360052] pci 0000:00:1a.1: [8086:3a38] type 00 class 0x0c0300
[    0.360090] pci 0000:00:1a.1: reg 0x20: [io  0xb880-0xb89f]
[    0.360171] pci 0000:00:1a.1: System wakeup disabled by ACPI
[    0.360266] pci 0000:00:1a.2: [8086:3a39] type 00 class 0x0c0300
[    0.360304] pci 0000:00:1a.2: reg 0x20: [io  0xb800-0xb81f]
[    0.360385] pci 0000:00:1a.2: System wakeup disabled by ACPI
[    0.360488] pci 0000:00:1a.7: [8086:3a3c] type 00 class 0x0c0320
[    0.360507] pci 0000:00:1a.7: reg 0x10: [mem 0xf7ffe000-0xf7ffe3ff]
[    0.360591] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
[    0.360635] pci 0000:00:1a.7: System wakeup disabled by ACPI
[    0.360730] pci 0000:00:1c.0: [8086:3a40] type 01 class 0x060400
[    0.360796] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.360840] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    0.360936] pci 0000:00:1c.4: [8086:3a48] type 01 class 0x060400
[    0.361006] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    0.361050] pci 0000:00:1c.4: System wakeup disabled by ACPI
[    0.361146] pci 0000:00:1d.0: [8086:3a34] type 00 class 0x0c0300
[    0.361185] pci 0000:00:1d.0: reg 0x20: [io  0xb480-0xb49f]
[    0.361265] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    0.361360] pci 0000:00:1d.1: [8086:3a35] type 00 class 0x0c0300
[    0.361400] pci 0000:00:1d.1: reg 0x20: [io  0xb400-0xb41f]
[    0.361480] pci 0000:00:1d.1: System wakeup disabled by ACPI
[    0.361575] pci 0000:00:1d.2: [8086:3a36] type 00 class 0x0c0300
[    0.361613] pci 0000:00:1d.2: reg 0x20: [io  0xb080-0xb09f]
[    0.361694] pci 0000:00:1d.2: System wakeup disabled by ACPI
[    0.361797] pci 0000:00:1d.7: [8086:3a3a] type 00 class 0x0c0320
[    0.361817] pci 0000:00:1d.7: reg 0x10: [mem 0xf7ffc000-0xf7ffc3ff]
[    0.361900] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.361944] pci 0000:00:1d.7: System wakeup disabled by ACPI
[    0.362037] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    0.362111] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    0.362208] pci 0000:00:1f.0: [8086:3a16] type 00 class 0x060100
[    0.362281] pci 0000:00:1f.0: can't claim BAR 13 [io  0x0800-0x087f]:
address conflict with ACPI CPU throttle [io  0x0810-0x0815]
[    0.362370] pci 0000:00:1f.0: quirk: [io  0x0500-0x053f] claimed by ICH6
GPIO
[    0.362432] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0a00
(mask 00ff)
[    0.362510] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0a00
(mask 0017)
[    0.362588] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 4700
(mask 00ff)
[    0.362760] pci 0000:00:1f.2: [8086:3a22] type 00 class 0x010601
[    0.362777] pci 0000:00:1f.2: reg 0x10: [io  0xb000-0xb007]
[    0.362784] pci 0000:00:1f.2: reg 0x14: [io  0xac00-0xac03]
[    0.362791] pci 0000:00:1f.2: reg 0x18: [io  0xa880-0xa887]
[    0.362798] pci 0000:00:1f.2: reg 0x1c: [io  0xa800-0xa803]
[    0.362804] pci 0000:00:1f.2: reg 0x20: [io  0xa480-0xa49f]
[    0.362811] pci 0000:00:1f.2: reg 0x24: [mem 0xf7ffa000-0xf7ffa7ff]
[    0.362853] pci 0000:00:1f.2: PME# supported from D3hot
[    0.362926] pci 0000:00:1f.3: [8086:3a30] type 00 class 0x0c0500
[    0.362940] pci 0000:00:1f.3: reg 0x10: [mem 0xf7ff9c00-0xf7ff9cff 64bit]
[    0.362958] pci 0000:00:1f.3: reg 0x20: [io  0x0400-0x041f]
[    0.363074] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.363185] pci 0000:02:00.0: [10de:06e4] type 00 class 0x030000
[    0.363195] pci 0000:02:00.0: reg 0x10: [mem 0xfa000000-0xfaffffff]
[    0.363203] pci 0000:02:00.0: reg 0x14: [mem 0xd0000000-0xdfffffff 64bit
pref]
[    0.363212] pci 0000:02:00.0: reg 0x1c: [mem 0xf8000000-0xf9ffffff 64bit]
[    0.363218] pci 0000:02:00.0: reg 0x24: [io  0xcc00-0xcc7f]
[    0.363224] pci 0000:02:00.0: reg 0x30: [mem 0xfbce0000-0xfbcfffff pref]
[    0.370309] pci 0000:00:03.0: PCI bridge to [bus 02]
[    0.370373] pci 0000:00:03.0:   bridge window [io  0xc000-0xcfff]
[    0.370379] pci 0000:00:03.0:   bridge window [mem 0xf8000000-0xfbcfffff]
[    0.370384] pci 0000:00:03.0:   bridge window [mem 0xd0000000-0xdfffffff
64bit pref]
[    0.370428] pci 0000:00:07.0: PCI bridge to [bus 03]
[    0.370536] pci 0000:00:1c.0: PCI bridge to [bus 04]
[    0.370662] pci 0000:06:00.0: [10ec:8168] type 00 class 0x020000
[    0.370681] pci 0000:06:00.0: reg 0x10: [io  0xe800-0xe8ff]
[    0.370707] pci 0000:06:00.0: reg 0x18: [mem 0xfbeff000-0xfbefffff 64bit]
[    0.370723] pci 0000:06:00.0: reg 0x20: [mem 0xf6ff0000-0xf6ffffff 64bit
pref]
[    0.370735] pci 0000:06:00.0: reg 0x30: [mem 0x00000000-0x0001ffff pref]
[    0.370812] pci 0000:06:00.0: supports D1 D2
[    0.370813] pci 0000:06:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.378320] pci 0000:00:1c.4: PCI bridge to [bus 06]
[    0.378387] pci 0000:00:1c.4:   bridge window [io  0xe000-0xefff]
[    0.378390] pci 0000:00:1c.4:   bridge window [mem 0xfbe00000-0xfbefffff]
[    0.378395] pci 0000:00:1c.4:   bridge window [mem 0xf6f00000-0xf6ffffff
64bit pref]
[    0.378463] pci 0000:00:1e.0: PCI bridge to [bus 07] (subtractive decode)
[    0.378530] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7]
(subtractive decode)
[    0.378532] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
[    0.378533] pci 0000:00:1e.0:   bridge window [mem
0x000a0000-0x000bffff] (subtractive decode)
[    0.378535] pci 0000:00:1e.0:   bridge window [mem
0x000d0000-0x000dffff] (subtractive decode)
[    0.378536] pci 0000:00:1e.0:   bridge window [mem
0xc0000000-0xdfffffff] (subtractive decode)
[    0.378538] pci 0000:00:1e.0:   bridge window [mem
0xf0000000-0xfed8ffff] (subtractive decode)
[    0.378972] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 6 7 *10 11 12 14
15)
[    0.379431] ACPI: PCI Interrupt Link [LNKB] (IRQs *5)
[    0.379626] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 6 7 10 11 12 *14
15)
[    0.380085] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 6 7 10 *11 12 14
15)
[    0.380541] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 6 7 10 11 12 14
15) *0, disabled.
[    0.381079] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 6 7 10 11 12 14
*15)
[    0.381536] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 6 7 10 11 12 14
15) *0, disabled.
[    0.382075] ACPI: PCI Interrupt Link [LNKH] (IRQs *3 4 6 7 10 11 12 14
15)
[    0.382537] ACPI: Enabled 1 GPEs in block 00 to 3F
[    0.382748] vgaarb: setting as boot device: PCI:0000:02:00.0
[    0.382807] vgaarb: device added:
PCI:0000:02:00.0,decodes=io+mem,owns=io+mem,locks=none
[    0.382884] vgaarb: loaded
[    0.382936] vgaarb: bridge control possible 0000:02:00.0
[    0.383041] PCI: Using ACPI for IRQ routing
[    0.388801] PCI: Discovered peer bus ff
[    0.388856] PCI: root bus ff: using default resources
[    0.388857] PCI: Probing PCI hardware (bus ff)
[    0.388883] PCI host bridge to bus 0000:ff
[    0.388939] pci_bus 0000:ff: root bus resource [io  0x0000-0xffff]
[    0.388998] pci_bus 0000:ff: root bus resource [mem
0x00000000-0xfffffffff]
[    0.389059] pci_bus 0000:ff: No busn resource found for root bus, will
use [bus ff-ff]
[    0.389136] pci_bus 0000:ff: busn_res: can not insert [bus ff] under
domain [bus 00-ff] (conflicts with (null) [bus 00-ff])
[    0.389141] pci 0000:ff:00.0: [8086:2c41] type 00 class 0x060000
[    0.389182] pci 0000:ff:00.1: [8086:2c01] type 00 class 0x060000
[    0.389221] pci 0000:ff:02.0: [8086:2c10] type 00 class 0x060000
[    0.389258] pci 0000:ff:02.1: [8086:2c11] type 00 class 0x060000
[    0.389297] pci 0000:ff:03.0: [8086:2c18] type 00 class 0x060000
[    0.389334] pci 0000:ff:03.1: [8086:2c19] type 00 class 0x060000
[    0.389371] pci 0000:ff:03.4: [8086:2c1c] type 00 class 0x060000
[    0.389409] pci 0000:ff:04.0: [8086:2c20] type 00 class 0x060000
[    0.389446] pci 0000:ff:04.1: [8086:2c21] type 00 class 0x060000
[    0.389483] pci 0000:ff:04.2: [8086:2c22] type 00 class 0x060000
[    0.389520] pci 0000:ff:04.3: [8086:2c23] type 00 class 0x060000
[    0.389558] pci 0000:ff:05.0: [8086:2c28] type 00 class 0x060000
[    0.389596] pci 0000:ff:05.1: [8086:2c29] type 00 class 0x060000
[    0.389633] pci 0000:ff:05.2: [8086:2c2a] type 00 class 0x060000
[    0.389670] pci 0000:ff:05.3: [8086:2c2b] type 00 class 0x060000
[    0.389709] pci 0000:ff:06.0: [8086:2c30] type 00 class 0x060000
[    0.389746] pci 0000:ff:06.1: [8086:2c31] type 00 class 0x060000
[    0.389782] pci 0000:ff:06.2: [8086:2c32] type 00 class 0x060000
[    0.389818] pci 0000:ff:06.3: [8086:2c33] type 00 class 0x060000
[    0.389864] pci_bus 0000:ff: busn_res: [bus ff] end is updated to ff
[    0.389866] pci_bus 0000:ff: busn_res: can not insert [bus ff] under
domain [bus 00-ff] (conflicts with (null) [bus 00-ff])
[    0.389869] PCI: pci_cache_line_size set to 64 bytes
[    0.389928] e820: reserve RAM buffer [mem 0x0009ec00-0x0009ffff]
[    0.389930] e820: reserve RAM buffer [mem 0xbf780000-0xbfffffff]
[    0.390038] HPET: 4 timers in total, 0 timers will be used for per-cpu
timer
[    0.390102] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
[    0.390325] hpet0: 4 comparators, 64-bit 14.318180 MHz counter
[    0.392557] Switched to clocksource hpet
[    0.397105] pnp: PnP ACPI init
[    0.397169] ACPI: bus type PNP registered
[    0.397281] system 00:00: [mem 0xfbf00000-0xfbffffff] has been reserved
[    0.397342] system 00:00: [mem 0xfc000000-0xfcffffff] has been reserved
[    0.397402] system 00:00: [mem 0xfd000000-0xfdffffff] has been reserved
[    0.397463] system 00:00: [mem 0xfe000000-0xfebfffff] has been reserved
[    0.397523] system 00:00: [mem 0xfec8a000-0xfec8afff] has been reserved
[    0.397583] system 00:00: [mem 0xfed10000-0xfed10fff] has been reserved
[    0.397644] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.397700] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.397823] pnp 00:02: Plug and Play ACPI device, IDs PNP0303 PNP030b
(active)
[    0.397934] system 00:03: [io  0x0a00-0x0adf] has been reserved
[    0.397993] system 00:03: [io  0x0ae0-0x0aef] has been reserved
[    0.398053] system 00:03: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.398200] system 00:04: [io  0x04d0-0x04d1] has been reserved
[    0.398260] system 00:04: [io  0x0800-0x087f] could not be reserved
[    0.398320] system 00:04: [io  0x0500-0x057f] could not be reserved
[    0.398379] system 00:04: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.398440] system 00:04: [mem 0xfed10000-0xfed103ff] has been reserved
[    0.398500] system 00:04: [mem 0xfed10400-0xfed107ff] has been reserved
[    0.398560] system 00:04: [mem 0xfed10800-0xfed10bff] has been reserved
[    0.398620] system 00:04: [mem 0xfed10c00-0xfed10fff] has been reserved
[    0.398680] system 00:04: [mem 0xfec8a000-0xfec8a3ff] has been reserved
[    0.398741] system 00:04: [mem 0xfec8a400-0xfec8a7ff] has been reserved
[    0.398801] system 00:04: [mem 0xfec8a800-0xfec8abff] has been reserved
[    0.398861] system 00:04: [mem 0xfec8ac00-0xfec8afff] has been reserved
[    0.398921] system 00:04: [mem 0xfed20000-0xfed3ffff] has been reserved
[    0.398981] system 00:04: [mem 0xfed45000-0xfed89fff] has been reserved
[    0.399041] system 00:04: [mem 0xfed20000-0xfed3ffff] has been reserved
[    0.399101] system 00:04: [mem 0xfed40000-0xfed8ffff] could not be
reserved
[    0.399163] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.399275] system 00:05: [mem 0xfec00000-0xfec00fff] could not be
reserved
[    0.399337] system 00:05: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.399397] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.399463] system 00:06: [mem 0xe0000000-0xefffffff] has been reserved
[    0.399524] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.399696] system 00:07: [mem 0x00000000-0x0009ffff] could not be
reserved
[    0.399758] system 00:07: [mem 0x000c0000-0x000cffff] could not be
reserved
[    0.399819] system 00:07: [mem 0x000e0000-0x000fffff] could not be
reserved
[    0.399880] system 00:07: [mem 0x00100000-0xbfffffff] could not be
reserved
[    0.399941] system 00:07: [mem 0xfed90000-0xffffffff] could not be
reserved
[    0.400002] system 00:07: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.400099] pnp: PnP ACPI: found 8 devices
[    0.400154] ACPI: bus type PNP unregistered
[    0.406391] pci 0000:00:1c.0: bridge window [io  0x1000-0x0fff] to [bus
04] add_size 1000
[    0.406394] pci 0000:00:1c.0: bridge window [mem 0x00100000-0x000fffff
64bit pref] to [bus 04] add_size 200000
[    0.406396] pci 0000:00:1c.0: bridge window [mem 0x00100000-0x000fffff]
to [bus 04] add_size 200000
[    0.406413] pci 0000:00:1f.0: BAR 13: [io  0x0800-0x087f] has bogus
alignment
[    0.406476] pci 0000:00:1c.0: res[14]=[mem 0x00100000-0x000fffff]
get_res_add_size add_size 200000
[    0.406477] pci 0000:00:1c.0: res[15]=[mem 0x00100000-0x000fffff 64bit
pref] get_res_add_size add_size 200000
[    0.406479] pci 0000:00:1c.0: res[13]=[io  0x1000-0x0fff]
get_res_add_size add_size 1000
[    0.406483] pci 0000:00:1c.0: BAR 14: assigned [mem
0xc0000000-0xc01fffff]
[    0.406546] pci 0000:00:1c.0: BAR 15: assigned [mem
0xc0200000-0xc03fffff 64bit pref]
[    0.406624] pci 0000:00:1c.0: BAR 13: assigned [io  0x1000-0x1fff]
[    0.406683] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.406746] pci 0000:00:03.0: PCI bridge to [bus 02]
[    0.406804] pci 0000:00:03.0:   bridge window [io  0xc000-0xcfff]
[    0.406865] pci 0000:00:03.0:   bridge window [mem 0xf8000000-0xfbcfffff]
[    0.406927] pci 0000:00:03.0:   bridge window [mem 0xd0000000-0xdfffffff
64bit pref]
[    0.407005] pci 0000:00:07.0: PCI bridge to [bus 03]
[    0.407068] pci 0000:00:1c.0: PCI bridge to [bus 04]
[    0.407126] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[    0.407187] pci 0000:00:1c.0:   bridge window [mem 0xc0000000-0xc01fffff]
[    0.407248] pci 0000:00:1c.0:   bridge window [mem 0xc0200000-0xc03fffff
64bit pref]
[    0.407329] pci 0000:06:00.0: BAR 6: assigned [mem 0xfbe00000-0xfbe1ffff
pref]
[    0.407404] pci 0000:00:1c.4: PCI bridge to [bus 06]
[    0.407462] pci 0000:00:1c.4:   bridge window [io  0xe000-0xefff]
[    0.407523] pci 0000:00:1c.4:   bridge window [mem 0xfbe00000-0xfbefffff]
[    0.407585] pci 0000:00:1c.4:   bridge window [mem 0xf6f00000-0xf6ffffff
64bit pref]
[    0.407664] pci 0000:00:1e.0: PCI bridge to [bus 07]
[    0.407728] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.407730] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.407731] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.407733] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff]
[    0.407734] pci_bus 0000:00: resource 8 [mem 0xc0000000-0xdfffffff]
[    0.407736] pci_bus 0000:00: resource 9 [mem 0xf0000000-0xfed8ffff]
[    0.407737] pci_bus 0000:02: resource 0 [io  0xc000-0xcfff]
[    0.407739] pci_bus 0000:02: resource 1 [mem 0xf8000000-0xfbcfffff]
[    0.407740] pci_bus 0000:02: resource 2 [mem 0xd0000000-0xdfffffff 64bit
pref]
[    0.407742] pci_bus 0000:04: resource 0 [io  0x1000-0x1fff]
[    0.407743] pci_bus 0000:04: resource 1 [mem 0xc0000000-0xc01fffff]
[    0.407745] pci_bus 0000:04: resource 2 [mem 0xc0200000-0xc03fffff 64bit
pref]
[    0.407746] pci_bus 0000:06: resource 0 [io  0xe000-0xefff]
[    0.407747] pci_bus 0000:06: resource 1 [mem 0xfbe00000-0xfbefffff]
[    0.407749] pci_bus 0000:06: resource 2 [mem 0xf6f00000-0xf6ffffff 64bit
pref]
[    0.407750] pci_bus 0000:07: resource 4 [io  0x0000-0x0cf7]
[    0.407752] pci_bus 0000:07: resource 5 [io  0x0d00-0xffff]
[    0.407753] pci_bus 0000:07: resource 6 [mem 0x000a0000-0x000bffff]
[    0.407755] pci_bus 0000:07: resource 7 [mem 0x000d0000-0x000dffff]
[    0.407756] pci_bus 0000:07: resource 8 [mem 0xc0000000-0xdfffffff]
[    0.407757] pci_bus 0000:07: resource 9 [mem 0xf0000000-0xfed8ffff]
[    0.407760] pci_bus 0000:ff: resource 4 [io  0x0000-0xffff]
[    0.407761] pci_bus 0000:ff: resource 5 [mem 0x00000000-0xfffffffff]
[    0.407843] NET: Registered protocol family 2
[    0.408337] TCP established hash table entries: 524288 (order: 10,
4194304 bytes)
[    0.409261] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.409451] TCP: Hash tables configured (established 524288 bind 65536)
[    0.409528] TCP: reno registered
[    0.409633] UDP hash table entries: 32768 (order: 8, 1048576 bytes)
[    0.409902] UDP-Lite hash table entries: 32768 (order: 8, 1048576 bytes)
[    0.410216] NET: Registered protocol family 1
[    0.411759] pci 0000:02:00.0: Video device with shadowed ROM
[    0.411782] PCI: CLS 256 bytes, default 64
[    0.411826] Unpacking initramfs...
[    0.685150] Freeing initrd memory: 16808K (ffff880035f1c000 -
ffff880036f86000)
[    0.685245] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.685306] software IO TLB [mem 0xbb780000-0xbf780000] (64MB) mapped at
[ffff8800bb780000-ffff8800bf77ffff]
[    0.685726] microcode: CPU0 sig=0x106a5, pf=0x2, revision=0x11
[    0.685789] microcode: CPU1 sig=0x106a5, pf=0x2, revision=0x11
[    0.685853] microcode: CPU2 sig=0x106a5, pf=0x2, revision=0x11
[    0.685917] microcode: CPU3 sig=0x106a5, pf=0x2, revision=0x11
[    0.685981] microcode: CPU4 sig=0x106a5, pf=0x2, revision=0x11
[    0.686045] microcode: CPU5 sig=0x106a5, pf=0x2, revision=0x11
[    0.686107] microcode: CPU6 sig=0x106a5, pf=0x2, revision=0x11
[    0.686170] microcode: CPU7 sig=0x106a5, pf=0x2, revision=0x11
[    0.686274] microcode: Microcode Update Driver: v2.00 <
tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    0.686695] futex hash table entries: 4096 (order: 6, 262144 bytes)
[    0.686814] audit: initializing netlink subsys (disabled)
[    0.686887] audit: type=2000 audit(1442052872.568:1): initialized
[    0.687275] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.687353] zbud: loaded
[    0.688318] VFS: Disk quotas dquot_6.5.2
[    0.688394] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.688509] msgmni has been set to 32768
[    0.688841] alg: No test for stdrng (krng)
[    0.688922] Block layer SCSI generic (bsg) driver version 0.4 loaded
(major 252)
[    0.689048] io scheduler noop registered
[    0.689103] io scheduler deadline registered
[    0.689199] io scheduler cfq registered (default)
[    0.689444] pcieport 0000:00:1c.0: enabling device (0104 -> 0107)
[    0.689637] pcieport 0000:00:1c.0: irq 40 for MSI/MSI-X
[    0.689798] pcieport 0000:00:1c.4: irq 41 for MSI/MSI-X
[    0.689881] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.689952] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    0.690027] intel_idle: MWAIT substates: 0x1120
[    0.690037] intel_idle: v0.4 model 0x1A
[    0.690038] intel_idle: lapic_timer_reliable_states 0x2
[    0.690338] GHES: HEST is not enabled!
[    0.690456] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.690896] Linux agpgart interface v0.103
[    0.691074] i8042: PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
[    0.691135] i8042: PNP: PS/2 appears to have AUX port disabled, if this
is incorrect please boot with i8042.nopnp
[    0.691907] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.692060] mousedev: PS/2 mouse device common for all mice
[    0.692158] rtc_cmos 00:01: RTC can wake from S4
[    0.692328] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    0.692410] rtc_cmos 00:01: alarms up to one month, y3k, 114 bytes
nvram, hpet irqs
[    0.692499] ledtrig-cpu: registered to indicate activity on CPUs
[    0.692784] AMD IOMMUv2 driver by Joerg Roedel <joerg.roedel@amd.com>
[    0.692844] AMD IOMMUv2 functionality not available on this system
[    0.692977] TCP: cubic registered
[    0.693152] NET: Registered protocol family 10
[    0.693442] mip6: Mobile IPv6
[    0.693497] NET: Registered protocol family 17
[    0.693556] mpls_gso: MPLS GSO support
[    0.693942] registered taskstats version 1
[    0.694481] rtc_cmos 00:01: setting system clock to 2015-09-12 10:14:33
UTC (1442052873)
[    0.694603] PM: Hibernation image not present or could not be loaded.
[    0.695367] Freeing unused kernel memory: 1204K (ffffffff818ee000 -
ffffffff81a1b000)
[    0.695444] Write protecting the kernel read-only data: 8192k
[    0.698179] Freeing unused kernel memory: 924K (ffff880001519000 -
ffff880001600000)
[    0.699167] Freeing unused kernel memory: 216K (ffff8800017ca000 -
ffff880001800000)
[    0.709484] systemd-udevd[96]: starting version 215
[    0.709760] random: systemd-udevd urandom read with 1 bits of entropy
available
[    0.724390] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    0.724460] r8169 0000:06:00.0: can't disable ASPM; OS doesn't have ASPM
control
[    0.724757] r8169 0000:06:00.0: irq 42 for MSI/MSI-X
[    0.724782] ACPI: bus type USB registered
[    0.724874] usbcore: registered new interface driver usbfs
[    0.724918] r8169 0000:06:00.0 eth0: RTL8168c/8111c at
0xffffc90000008000, 6c:62:6d:60:73:4d, XID 1c4000c0 IRQ 42
[    0.724919] r8169 0000:06:00.0 eth0: jumbo features [frames: 6128 bytes,
tx checksumming: ko]
[    0.725116] usbcore: registered new interface driver hub
[    0.725328] usbcore: registered new device driver usb
[    0.725592] SCSI subsystem initialized
[    0.725958] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.726383] ehci-pci: EHCI PCI platform driver
[    0.726597] ehci-pci 0000:00:1a.7: EHCI Host Controller
[    0.726626] uhci_hcd: USB Universal Host Controller Interface driver
[    0.726727] ehci-pci 0000:00:1a.7: new USB bus registered, assigned bus
number 1
[    0.726817] ehci-pci 0000:00:1a.7: debug port 1
[    0.727413] libata version 3.00 loaded.
[    0.730767] ehci-pci 0000:00:1a.7: cache line size of 256 is not
supported
[    0.730783] ehci-pci 0000:00:1a.7: irq 18, io mem 0xf7ffe000
[    0.740766] ehci-pci 0000:00:1a.7: USB 2.0 started, EHCI 1.00
[    0.740878] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    0.740943] usb usb1: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.741022] usb usb1: Product: EHCI Host Controller
[    0.741083] usb usb1: Manufacturer: Linux 3.16.0-4-amd64 ehci_hcd
[    0.741144] usb usb1: SerialNumber: 0000:00:1a.7
[    0.741330] hub 1-0:1.0: USB hub found
[    0.741396] hub 1-0:1.0: 6 ports detected
[    0.741755] ehci-pci 0000:00:1d.7: EHCI Host Controller
[    0.741822] ehci-pci 0000:00:1d.7: new USB bus registered, assigned bus
number 2
[    0.741913] ehci-pci 0000:00:1d.7: debug port 1
[    0.745880] ehci-pci 0000:00:1d.7: cache line size of 256 is not
supported
[    0.745895] ehci-pci 0000:00:1d.7: irq 23, io mem 0xf7ffc000
[    0.749975] input: AT Translated Set 2 keyboard as
/devices/platform/i8042/serio0/input/input0
[    0.756763] ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    0.756846] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    0.756906] usb usb2: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.756982] usb usb2: Product: EHCI Host Controller
[    0.757038] usb usb2: Manufacturer: Linux 3.16.0-4-amd64 ehci_hcd
[    0.757097] usb usb2: SerialNumber: 0000:00:1d.7
[    0.757287] hub 2-0:1.0: USB hub found
[    0.757347] hub 2-0:1.0: 6 ports detected
[    0.757738] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[    0.757803] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus
number 3
[    0.757888] uhci_hcd 0000:00:1a.0: detected 2 ports
[    0.757977] uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000bc00
[    0.758101] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    0.758164] usb usb3: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.758240] usb usb3: Product: UHCI Host Controller
[    0.758297] usb usb3: Manufacturer: Linux 3.16.0-4-amd64 uhci_hcd
[    0.758355] usb usb3: SerialNumber: 0000:00:1a.0
[    0.758626] hub 3-0:1.0: USB hub found
[    0.758685] hub 3-0:1.0: 2 ports detected
[    0.758911] uhci_hcd 0000:00:1a.1: UHCI Host Controller
[    0.758972] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus
number 4
[    0.759051] uhci_hcd 0000:00:1a.1: detected 2 ports
[    0.759131] uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000b880
[    0.759224] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    0.759285] usb usb4: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.759360] usb usb4: Product: UHCI Host Controller
[    0.759417] usb usb4: Manufacturer: Linux 3.16.0-4-amd64 uhci_hcd
[    0.759476] usb usb4: SerialNumber: 0000:00:1a.1
[    0.759737] hub 4-0:1.0: USB hub found
[    0.759796] hub 4-0:1.0: 2 ports detected
[    0.760015] uhci_hcd 0000:00:1a.2: UHCI Host Controller
[    0.760076] uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus
number 5
[    0.760156] uhci_hcd 0000:00:1a.2: detected 2 ports
[    0.760236] uhci_hcd 0000:00:1a.2: irq 19, io base 0x0000b800
[    0.760327] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    0.760388] usb usb5: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.760463] usb usb5: Product: UHCI Host Controller
[    0.760519] usb usb5: Manufacturer: Linux 3.16.0-4-amd64 uhci_hcd
[    0.760578] usb usb5: SerialNumber: 0000:00:1a.2
[    0.760787] hub 5-0:1.0: USB hub found
[    0.760846] hub 5-0:1.0: 2 ports detected
[    0.761063] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    0.761124] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus
number 6
[    0.761204] uhci_hcd 0000:00:1d.0: detected 2 ports
[    0.761276] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000b480
[    0.761367] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[    0.761428] usb usb6: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.761503] usb usb6: Product: UHCI Host Controller
[    0.761560] usb usb6: Manufacturer: Linux 3.16.0-4-amd64 uhci_hcd
[    0.761619] usb usb6: SerialNumber: 0000:00:1d.0
[    0.761870] hub 6-0:1.0: USB hub found
[    0.761929] hub 6-0:1.0: 2 ports detected
[    0.762149] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    0.762210] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus
number 7
[    0.762290] uhci_hcd 0000:00:1d.1: detected 2 ports
[    0.762362] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000b400
[    0.762455] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[    0.762516] usb usb7: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.762591] usb usb7: Product: UHCI Host Controller
[    0.762648] usb usb7: Manufacturer: Linux 3.16.0-4-amd64 uhci_hcd
[    0.762707] usb usb7: SerialNumber: 0000:00:1d.1
[    0.762948] hub 7-0:1.0: USB hub found
[    0.763007] hub 7-0:1.0: 2 ports detected
[    0.763227] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    0.763288] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus
number 8
[    0.763368] uhci_hcd 0000:00:1d.2: detected 2 ports
[    0.763440] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000b080
[    0.763533] usb usb8: New USB device found, idVendor=1d6b, idProduct=0001
[    0.763593] usb usb8: New USB device strings: Mfr=3, Product=2,
SerialNumber=1
[    0.763669] usb usb8: Product: UHCI Host Controller
[    0.763726] usb usb8: Manufacturer: Linux 3.16.0-4-amd64 uhci_hcd
[    0.763785] usb usb8: SerialNumber: 0000:00:1d.2
[    0.764030] hub 8-0:1.0: USB hub found
[    0.764090] hub 8-0:1.0: 2 ports detected
[    0.764283] ahci 0000:00:1f.2: version 3.0
[    0.764427] ahci 0000:00:1f.2: irq 43 for MSI/MSI-X
[    0.764452] ahci 0000:00:1f.2: SSS flag set, parallel bus scan disabled
[    0.764550] ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps
0x3f impl SATA mode
[    0.764632] ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pio
slum part ccc ems sxs
[    0.809712] scsi0 : ahci
[    0.810781] scsi1 : ahci
[    0.811193] scsi2 : ahci
[    0.811533] scsi3 : ahci
[    0.811928] scsi4 : ahci
[    0.812344] scsi5 : ahci
[    0.813152] ata1: SATA max UDMA/133 abar m2048@0xf7ffa000 port
0xf7ffa100 irq 43
[    0.813229] ata2: SATA max UDMA/133 abar m2048@0xf7ffa000 port
0xf7ffa180 irq 43
[    0.813306] ata3: SATA max UDMA/133 abar m2048@0xf7ffa000 port
0xf7ffa200 irq 43
[    0.813382] ata4: SATA max UDMA/133 abar m2048@0xf7ffa000 port
0xf7ffa280 irq 43
[    0.813458] ata5: SATA max UDMA/133 abar m2048@0xf7ffa000 port
0xf7ffa300 irq 43
[    0.813533] ata6: SATA max UDMA/133 abar m2048@0xf7ffa000 port
0xf7ffa380 irq 43
[    1.133104] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.134220] ata1.00: ATA-8: WDC WD2000FYYZ-01UL1B1, 01.01K02, max
UDMA/133
[    1.134289] ata1.00: 3907029168 sectors, multi 0: LBA48 NCQ (depth
31/32), AA
[    1.135778] ata1.00: configured for UDMA/133
[    1.136153] scsi 0:0:0:0: Direct-Access     ATA      WDC WD2000FYYZ-0
1K02 PQ: 0 ANSI: 5
[    1.453273] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    1.454361] ata2.00: ATA-8: WDC WD2000FYYZ-01UL1B1, 01.01K02, max
UDMA/133
[    1.454429] ata2.00: 3907029168 sectors, multi 0: LBA48 NCQ (depth
31/32), AA
[    1.455992] ata2.00: configured for UDMA/133
[    1.456328] scsi 1:0:0:0: Direct-Access     ATA      WDC WD2000FYYZ-0
1K02 PQ: 0 ANSI: 5
[    1.685330] tsc: Refined TSC clocksource calibration: 2806.964 MHz
[    1.777441] ata3: SATA link down (SStatus 0 SControl 300)
[    2.097612] ata4: SATA link down (SStatus 0 SControl 300)
[    2.417777] ata5: SATA link down (SStatus 0 SControl 300)
[    2.686208] Switched to clocksource tsc
[    2.737980] ata6: SATA link down (SStatus 0 SControl 300)
[    2.771037] sd 0:0:0:0: [sda] 3907029168 512-byte logical blocks: (2.00
TB/1.81 TiB)
[    2.771051] sd 1:0:0:0: [sdb] 3907029168 512-byte logical blocks: (2.00
TB/1.81 TiB)
[    2.771074] sd 1:0:0:0: [sdb] Write Protect is off
[    2.771075] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    2.771085] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled,
doesn't support DPO or FUA
[    2.771348] sd 0:0:0:0: [sda] Write Protect is off
[    2.771405] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.771416] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,
doesn't support DPO or FUA
[    2.780668]  sda: sda1 sda2 sda3
[    2.780917] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.782276] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    2.782367] sd 1:0:0:0: Attached scsi generic sg1 type 0
[    2.790178]  sdb: sdb1 sdb2 sdb3
[    2.790432] sd 1:0:0:0: [sdb] Attached SCSI disk
[    2.925798] md: bind<sdb2>
[    2.929991] md: bind<sda3>
[    2.930650] md: bind<sda1>
[    2.931388] md: bind<sdb1>
[    2.934077] md: raid1 personality registered for level 1
[    2.935011] md/raid1:md0: active with 2 out of 2 mirrors
[    2.935109] md0: detected capacity change from 0 to 25752895488
[    2.942184] md: bind<sda2>
[    2.943774] md/raid1:md1: active with 2 out of 2 mirrors
[    2.943867] md1: detected capacity change from 0 to 536543232
[    2.944257]  md1: unknown partition table
[    2.945848]  md0: unknown partition table
[    2.990152] md: bind<sdb3>
[    2.993032] md/raid1:md2: not clean -- starting background reconstruction
[    2.993099] md/raid1:md2: active with 2 out of 2 mirrors
[    2.993180] md2: detected capacity change from 0 to 1973953691648
[    3.001503]  md2: unknown partition table
[    3.066972] device-mapper: uevent: version 1.0.3
[    3.067131] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised:
dm-devel@redhat.com
[    3.138013] raid6: sse2x1    6911 MB/s
[    3.206046] raid6: sse2x2    8146 MB/s
[    3.274085] raid6: sse2x4    9066 MB/s
[    3.274189] raid6: using algorithm sse2x4 (9066 MB/s)
[    3.274247] raid6: using ssse3x2 recovery algorithm
[    3.276368] xor: measuring software checksum speed
[    3.314102]    prefetch64-sse: 11488.000 MB/sec
[    3.354123]    generic_sse: 10139.000 MB/sec
[    3.354228] xor: using function: prefetch64-sse (11488.000 MB/sec)
[    3.359057] Btrfs loaded
[    3.528899] PM: Starting manual resume from disk
[    3.528958] PM: Hibernation image partition 9:0 present
[    3.528960] PM: Looking for hibernation image.
[    3.529057] PM: Image not found (code -22)
[    3.529060] PM: Hibernation image not present or could not be loaded.
[    3.637328] md: resync of RAID array md2
[    3.637390] md: minimum _guaranteed_  speed: 1000 KB/sec/disk.
[    3.637452] md: using maximum available idle IO bandwidth (but not more
than 200000 KB/sec) for resync.
[    3.637537] md: using 128k window, over a total of 1927689152k.
[    3.637595] md: resuming resync of md2 from checkpoint.
[    3.676739] random: nonblocking pool is initialized
[    3.741318] EXT4-fs (md2): mounted filesystem with ordered data mode.
Opts: (null)
[    4.184259] systemd[1]: systemd 215 running in system mode. (+PAM +AUDIT
+SELINUX +IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +XZ -SECCOMP -APPARMOR)
[    4.184507] systemd[1]: Detected architecture 'x86-64'.
[    4.308631] systemd[1]: Inserted module 'autofs4'
[    4.316048] systemd[1]: Set hostname to <Debian-81-jessie-64-minimal>.
[    4.324893] systemd[1]: Initializing machine ID from random generator.
[    4.324996] systemd[1]: Installed transient /etc/machine-id file.
[    4.713240] systemd[1]: Cannot add dependency job for unit
display-manager.service, ignoring: Unit display-manager.service failed to
load: No such file or directory.
[    4.713586] systemd[1]: Starting Forward Password Requests to Wall
Directory Watch.
[    4.713707] systemd[1]: Started Forward Password Requests to Wall
Directory Watch.
[    4.713791] systemd[1]: Starting Remote File Systems (Pre).
[    4.714126] systemd[1]: Reached target Remote File Systems (Pre).
[    4.714204] systemd[1]: Starting Arbitrary Executable File Formats File
System Automount Point.
[    4.714594] systemd[1]: Set up automount Arbitrary Executable File
Formats File System Automount Point.
[    4.714685] systemd[1]: Starting Dispatch Password Requests to Console
Directory Watch.
[    4.714784] systemd[1]: Started Dispatch Password Requests to Console
Directory Watch.
[    4.714879] systemd[1]: Starting Paths.
[    4.715186] systemd[1]: Reached target Paths.
[    4.715249] systemd[1]: Expecting device dev-md-0.device...
[    4.715487] systemd[1]: Expecting device dev-md-1.device...
[    4.715725] systemd[1]: Starting Root Slice.
[    4.716042] systemd[1]: Created slice Root Slice.
[    4.716105] systemd[1]: Starting User and Session Slice.
[    4.716477] systemd[1]: Created slice User and Session Slice.
[    4.716543] systemd[1]: Starting /dev/initctl Compatibility Named Pipe.
[    4.716880] systemd[1]: Listening on /dev/initctl Compatibility Named
Pipe.
[    4.716948] systemd[1]: Starting Delayed Shutdown Socket.
[    4.717271] systemd[1]: Listening on Delayed Shutdown Socket.
[    4.717336] systemd[1]: Starting Journal Socket (/dev/log).
[    4.717665] systemd[1]: Listening on Journal Socket (/dev/log).
[    4.717731] systemd[1]: Starting LVM2 metadata daemon socket.
[    4.718058] systemd[1]: Listening on LVM2 metadata daemon socket.
[    4.718124] systemd[1]: Starting Device-mapper event daemon FIFOs.
[    4.743571] systemd[1]: Listening on Device-mapper event daemon FIFOs.
[    4.743642] systemd[1]: Starting udev Control Socket.
[    4.743966] systemd[1]: Listening on udev Control Socket.
[    4.744033] systemd[1]: Starting udev Kernel Socket.
[    4.744350] systemd[1]: Listening on udev Kernel Socket.
[    4.744416] systemd[1]: Starting Journal Socket.
[    4.744741] systemd[1]: Listening on Journal Socket.
[    4.744812] systemd[1]: Starting System Slice.
[    4.745180] systemd[1]: Created slice System Slice.
[    4.745246] systemd[1]: Starting system-getty.slice.
[    4.745622] systemd[1]: Created slice system-getty.slice.
[    4.745698] systemd[1]: Starting Increase datagram queue length...
[    4.746226] systemd[1]: Mounting POSIX Message Queue File System...
[    4.746737] systemd[1]: Starting udev Coldplug all Devices...
[    4.747505] systemd[1]: Started Set Up Additional Binary Formats.
[    4.748318] systemd[1]: Starting Create list of required static device
nodes for the current kernel...
[    4.748920] systemd[1]: Mounting Debug File System...
[    4.749439] systemd[1]: Mounting Huge Pages File System...
[    4.761732] systemd[1]: Starting Load Kernel Modules...
[    4.762282] systemd[1]: Starting Slices.
[    4.762594] systemd[1]: Reached target Slices.
[    4.821476] systemd[1]: Started Increase datagram queue length.
[    4.821809] systemd[1]: Starting Syslog Socket.
[    4.822149] systemd[1]: Listening on Syslog Socket.
[    4.822215] systemd[1]: Starting Journal Service...
[    4.823034] systemd[1]: Started Journal Service.
[    5.141541] systemd-udevd[258]: starting version 215
[    5.460310] wmi: Mapper loaded
[    5.535388] EDAC MC: Ver: 3.0.0
[    5.595519] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    5.607990] EDAC MC0: Giving out device to module i7core_edac.c
controller i7 core #0: DEV 0000:ff:03.0 (POLLED)
[    5.608109] EDAC PCI0: Giving out device to module i7core_edac
controller EDAC PCI controller: DEV 0000:ff:03.0 (POLLED)
[    5.608195] EDAC i7core: Driver loaded, 1 memory controller(s) found.
[    5.617162] i801_smbus 0000:00:1f.3: SMBus using PCI Interrupt
[    5.650060] ACPI Warning: SystemIO range
0x0000000000000828-0x000000000000082f conflicts with OpRegion
0x0000000000000800-0x000000000000084f (\PMRG) (20140424/utaddress-258)
[    5.650235] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
[    5.650333] lpc_ich: Resource conflict(s) found affecting gpio_ich
[    5.739062] input: Power Button as
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input1
[    5.739160] ACPI: Power Button [PWRB]
[    5.739303] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
[    5.739393] ACPI: Power Button [PWRF]
[    5.989189] iTCO_vendor_support: vendor-support=0
[    5.995542] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[    5.995625] iTCO_wdt: Found a ICH10R TCO device (Version=2,
TCOBASE=0x0860)
[    5.995917] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[    6.084667] [drm] Initialized drm 1.1.0 20060810
[    6.131944] kvm: VM_EXIT_LOAD_IA32_PERF_GLOBAL_CTRL does not work
properly. Using workaround
[    6.637843] Adding 25149308k swap on /dev/md0.  Priority:-1 extents:1
across:25149308k FS
[    6.949499] EXT4-fs (md2): re-mounted. Opts: (null)
[    6.996326] EXT4-fs (md1): mounting ext3 file system using the ext4
subsystem
[    7.051510] EXT4-fs (md1): mounted filesystem with ordered data mode.
Opts: (null)
[    7.093399] systemd-journald[242]: Received request to flush runtime
journal from PID 1
[    7.541744] r8169 0000:06:00.0 eth0: link down
[    7.541854] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[    7.542021] r8169 0000:06:00.0 eth0: link down
[   10.577502] r8169 0000:06:00.0 eth0: link up
[   10.577574] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   17.607886] ip_tables: (C) 2000-2006 Netfilter Core Team
[ 1368.818980] perf interrupt took too long (2501 > 2500), lowering
kernel.perf_event_max_sample_rate to 50000
[ 4426.079842] do_IRQ: 3.35 No irq handler for vector (irq -1)
[ 6179.045866] WARNING! power/level is deprecated; use power/control instead
[ 6181.655960] grep: The scan_unevictable_pages sysctl/node-interface has
been disabled for lack of a legitimate use case.  If you have one, please
send an email to linux-mm@kvack.org.
[15302.826147] perf interrupt took too long (5095 > 5000), lowering
kernel.perf_event_max_sample_rate to 25000
[18263.301729] do_IRQ: 2.93 No irq handler for vector (irq -1)
[23255.910251] do_IRQ: 0.80 No irq handler for vector (irq -1)
[25897.434281] do_IRQ: 0.179 No irq handler for vector (irq -1)
[29419.545609] do_IRQ: 0.153 No irq handler for vector (irq -1)
[30850.163556] do_IRQ: 2.227 No irq handler for vector (irq -1)
[34732.279281] do_IRQ: 3.206 No irq handler for vector (irq -1)
[36223.099314] do_IRQ: 0.153 No irq handler for vector (irq -1)
[43576.841059] do_IRQ: 0.45 No irq handler for vector (irq -1)
[44337.434825] do_IRQ: 0.35 No irq handler for vector (irq -1)
[48059.145357] do_IRQ: 0.155 No irq handler for vector (irq -1)
[60625.808903] do_IRQ: 2.70 No irq handler for vector (irq -1)
[63034.351559] md: md2: resync done.
[63034.423123] RAID1 conf printout:
[63034.423127]  --- wd:2 rd:2
[63034.423130]  disk 0, wo:0, o:1, dev:sda3
[63034.423133]  disk 1, wo:0, o:1, dev:sdb3
[63397.309458] do_IRQ: 1.39 No irq handler for vector (irq -1)
[70501.175555] do_IRQ: 2.198 No irq handler for vector (irq -1)
[72172.082120] do_IRQ: 0.236 No irq handler for vector (irq -1)
[72693.132497] do_IRQ: 1.111 No irq handler for vector (irq -1)
[84578.955758] do_IRQ: 1.160 No irq handler for vector (irq -1)
[87440.229370] do_IRQ: 2.62 No irq handler for vector (irq -1)
[96044.812114] do_IRQ: 1.164 No irq handler for vector (irq -1)
[96185.497298] list passed to list_sort() too long for efficiency
[120547.710208] do_IRQ: 1.193 No irq handler for vector (irq -1)
[121338.113923] do_IRQ: 3.228 No irq handler for vector (irq -1)
[129172.282348] do_IRQ: 0.160 No irq handler for vector (irq -1)
[131964.181384] do_IRQ: 2.108 No irq handler for vector (irq -1)
[135575.812350] do_IRQ: 1.92 No irq handler for vector (irq -1)
[143419.884584] do_IRQ: 3.187 No irq handler for vector (irq -1)

--001a11c30fa8609855051fac8e04
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello<div><br></div><div>I was searching some strings in m=
y disk yes I mean whole disk like this</div><div><br></div><div>find / -typ=
e f -exec grep -sl &quot;access denied&quot; {} \;<br></div><div><br></div>=
<div>then I start seeing this messages</div><div><br></div><div><div>[12133=
8.113923] do_IRQ: 3.228 No irq handler for vector (irq -1)</div></div><div>=
<br></div><div>when I check the dmesg I saw some others and one of them was=
 like this=C2=A0</div><div><br></div><div><div>[ 6181.655960] grep: The sca=
n_unevictable_pages sysctl/node-interface has been disabled for lack of a l=
egitimate use case.=C2=A0 If you have one, please send an email to <a href=
=3D"mailto:linux-mm@kvack.org">linux-mm@kvack.org</a>.</div></div><div><br>=
</div><div>this is why I am sending this email. how can I solve this messag=
e ?</div><div><br></div><div>thanks</div><div><br></div><div>all dmesg outp=
ut:</div><div><br></div><div><div>[ =C2=A0 =C2=A00.000000] Initializing cgr=
oup subsys cpuset</div><div>[ =C2=A0 =C2=A00.000000] Initializing cgroup su=
bsys cpu</div><div>[ =C2=A0 =C2=A00.000000] Initializing cgroup subsys cpua=
cct</div><div>[ =C2=A0 =C2=A00.000000] Linux version 3.16.0-4-amd64 (<a hre=
f=3D"mailto:debian-kernel@lists.debian.org">debian-kernel@lists.debian.org<=
/a>) (gcc version 4.8.4 (Debian 4.8.4-1) ) #1 SMP Debian 3.16.7-ckt11-1+deb=
8u3 (2015-08-04)</div><div>[ =C2=A0 =C2=A00.000000] Command line: BOOT_IMAG=
E=3D/vmlinuz-3.16.0-4-amd64 root=3DUUID=3D879fd989-f331-4a17-a930-e3f003666=
d2e ro nomodeset</div><div>[ =C2=A0 =C2=A00.000000] e820: BIOS-provided phy=
sical RAM map:</div><div>[ =C2=A0 =C2=A00.000000] BIOS-e820: [mem 0x0000000=
000000000-0x000000000009ebff] usable</div><div>[ =C2=A0 =C2=A00.000000] BIO=
S-e820: [mem 0x000000000009ec00-0x000000000009ffff] reserved</div><div>[ =
=C2=A0 =C2=A00.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000ffff=
f] reserved</div><div>[ =C2=A0 =C2=A00.000000] BIOS-e820: [mem 0x0000000000=
100000-0x00000000bf77ffff] usable</div><div>[ =C2=A0 =C2=A00.000000] BIOS-e=
820: [mem 0x00000000bf780000-0x00000000bf78dfff] ACPI data</div><div>[ =C2=
=A0 =C2=A00.000000] BIOS-e820: [mem 0x00000000bf78e000-0x00000000bf7cffff] =
ACPI NVS</div><div>[ =C2=A0 =C2=A00.000000] BIOS-e820: [mem 0x00000000bf7d0=
000-0x00000000bf7dffff] reserved</div><div>[ =C2=A0 =C2=A00.000000] BIOS-e8=
20: [mem 0x00000000bf7ec000-0x00000000bfffffff] reserved</div><div>[ =C2=A0=
 =C2=A00.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] res=
erved</div><div>[ =C2=A0 =C2=A00.000000] BIOS-e820: [mem 0x00000000ffc00000=
-0x00000000ffffffff] reserved</div><div>[ =C2=A0 =C2=A00.000000] BIOS-e820:=
 [mem 0x0000000100000000-0x0000000c3fffffff] usable</div><div>[ =C2=A0 =C2=
=A00.000000] NX (Execute Disable) protection: active</div><div>[ =C2=A0 =C2=
=A00.000000] SMBIOS 2.5 present.</div><div>[ =C2=A0 =C2=A00.000000] DMI: MS=
I MS-7522/MSI X58 Pro (MS-7522) =C2=A0, BIOS V8.14B8 11/09/2012</div><div>[=
 =C2=A0 =C2=A00.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=
=3D&gt; reserved</div><div>[ =C2=A0 =C2=A00.000000] e820: remove [mem 0x000=
a0000-0x000fffff] usable</div><div>[ =C2=A0 =C2=A00.000000] AGP: No AGP bri=
dge found</div><div>[ =C2=A0 =C2=A00.000000] e820: last_pfn =3D 0xc40000 ma=
x_arch_pfn =3D 0x400000000</div><div>[ =C2=A0 =C2=A00.000000] MTRR default =
type: uncachable</div><div>[ =C2=A0 =C2=A00.000000] MTRR fixed ranges enabl=
ed:</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 00000-9FFFF write-back</div><=
div>[ =C2=A0 =C2=A00.000000] =C2=A0 A0000-BFFFF uncachable</div><div>[ =C2=
=A0 =C2=A00.000000] =C2=A0 C0000-CFFFF write-protect</div><div>[ =C2=A0 =C2=
=A00.000000] =C2=A0 D0000-DFFFF uncachable</div><div>[ =C2=A0 =C2=A00.00000=
0] =C2=A0 E0000-E3FFF write-protect</div><div>[ =C2=A0 =C2=A00.000000] =C2=
=A0 E4000-E7FFF write-through</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 E80=
00-EBFFF write-protect</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 EC000-EFFF=
F write-through</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 F0000-FFFFF write=
-protect</div><div>[ =C2=A0 =C2=A00.000000] MTRR variable ranges enabled:</=
div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 0 base 000000000 mask 800000000 wr=
ite-back</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 1 base 800000000 mask C0=
0000000 write-back</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 2 base C000000=
00 mask FC0000000 write-back</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 3 ba=
se 0C0000000 mask FC0000000 uncachable</div><div>[ =C2=A0 =C2=A00.000000] =
=C2=A0 4 base 0BF800000 mask FFF800000 uncachable</div><div>[ =C2=A0 =C2=A0=
0.000000] =C2=A0 5 disabled</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 6 dis=
abled</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 7 disabled</div><div>[ =C2=
=A0 =C2=A00.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010=
600070106</div><div>[ =C2=A0 =C2=A00.000000] e820: update [mem 0xbf800000-0=
xffffffff] usable =3D=3D&gt; reserved</div><div>[ =C2=A0 =C2=A00.000000] e8=
20: last_pfn =3D 0xbf780 max_arch_pfn =3D 0x400000000</div><div>[ =C2=A0 =
=C2=A00.000000] found SMP MP-table at [mem 0x000ff780-0x000ff78f] mapped at=
 [ffff8800000ff780]</div><div>[ =C2=A0 =C2=A00.000000] Base memory trampoli=
ne at [ffff880000098000] 98000 size 24576</div><div>[ =C2=A0 =C2=A00.000000=
] init_memory_mapping: [mem 0x00000000-0x000fffff]</div><div>[ =C2=A0 =C2=
=A00.000000] =C2=A0[mem 0x00000000-0x000fffff] page 4k</div><div>[ =C2=A0 =
=C2=A00.000000] BRK [0x01af4000, 0x01af4fff] PGTABLE</div><div>[ =C2=A0 =C2=
=A00.000000] BRK [0x01af5000, 0x01af5fff] PGTABLE</div><div>[ =C2=A0 =C2=A0=
0.000000] BRK [0x01af6000, 0x01af6fff] PGTABLE</div><div>[ =C2=A0 =C2=A00.0=
00000] init_memory_mapping: [mem 0xc3fe00000-0xc3fffffff]</div><div>[ =C2=
=A0 =C2=A00.000000] =C2=A0[mem 0xc3fe00000-0xc3fffffff] page 2M</div><div>[=
 =C2=A0 =C2=A00.000000] BRK [0x01af7000, 0x01af7fff] PGTABLE</div><div>[ =
=C2=A0 =C2=A00.000000] init_memory_mapping: [mem 0xc3c000000-0xc3fdfffff]</=
div><div>[ =C2=A0 =C2=A00.000000] =C2=A0[mem 0xc3c000000-0xc3fdfffff] page =
2M</div><div>[ =C2=A0 =C2=A00.000000] init_memory_mapping: [mem 0xc00000000=
-0xc3bffffff]</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0[mem 0xc00000000-0xc=
3bffffff] page 2M</div><div>[ =C2=A0 =C2=A00.000000] init_memory_mapping: [=
mem 0x00100000-0xbf77ffff]</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0[mem 0x=
00100000-0x001fffff] page 4k</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0[mem =
0x00200000-0xbf5fffff] page 2M</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0[me=
m 0xbf600000-0xbf77ffff] page 4k</div><div>[ =C2=A0 =C2=A00.000000] init_me=
mory_mapping: [mem 0x100000000-0xbffffffff]</div><div>[ =C2=A0 =C2=A00.0000=
00] =C2=A0[mem 0x100000000-0xbffffffff] page 2M</div><div>[ =C2=A0 =C2=A00.=
000000] BRK [0x01af8000, 0x01af8fff] PGTABLE</div><div>[ =C2=A0 =C2=A00.000=
000] BRK [0x01af9000, 0x01af9fff] PGTABLE</div><div>[ =C2=A0 =C2=A00.000000=
] RAMDISK: [mem 0x35f1c000-0x36f85fff]</div><div>[ =C2=A0 =C2=A00.000000] A=
CPI: Early table checksum verification disabled</div><div>[ =C2=A0 =C2=A00.=
000000] ACPI: RSDP 0x00000000000FA590 000014 (v00 ACPIAM)</div><div>[ =C2=
=A0 =C2=A00.000000] ACPI: RSDT 0x00000000BF780000 00003C (v01 7522MT A75228=
00 20120925 MSFT 00000097)</div><div>[ =C2=A0 =C2=A00.000000] ACPI: FACP 0x=
00000000BF780200 000084 (v01 7522MT A7522800 20120925 MSFT 00000097)</div><=
div>[ =C2=A0 =C2=A00.000000] ACPI: DSDT 0x00000000BF780480 006E82 (v01 A752=
2 =C2=A0A7522800 00000800 INTL 20051117)</div><div>[ =C2=A0 =C2=A00.000000]=
 ACPI: FACS 0x00000000BF78E000 000040</div><div>[ =C2=A0 =C2=A00.000000] AC=
PI: APIC 0x00000000BF780390 0000AC (v01 7522MT A7522800 20120925 MSFT 00000=
097)</div><div>[ =C2=A0 =C2=A00.000000] ACPI: MCFG 0x00000000BF780440 00003=
C (v01 7522MT OEMMCFG =C2=A020120925 MSFT 00000097)</div><div>[ =C2=A0 =C2=
=A00.000000] ACPI: OEMB 0x00000000BF78E040 00007A (v01 7522MT A7522800 2012=
0925 MSFT 00000097)</div><div>[ =C2=A0 =C2=A00.000000] ACPI: HPET 0x0000000=
0BF78A480 000038 (v01 7522MT OEMHPET =C2=A020120925 MSFT 00000097)</div><di=
v>[ =C2=A0 =C2=A00.000000] ACPI: SSDT 0x00000000BF790560 000363 (v01 DpgPmm=
 CpuPm =C2=A0 =C2=A000000012 INTL 20051117)</div><div>[ =C2=A0 =C2=A00.0000=
00] ACPI: Local APIC address 0xfee00000</div><div>[ =C2=A0 =C2=A00.000000] =
No NUMA configuration found</div><div>[ =C2=A0 =C2=A00.000000] Faking a nod=
e at [mem 0x0000000000000000-0x0000000c3fffffff]</div><div>[ =C2=A0 =C2=A00=
.000000] Initmem setup node 0 [mem 0x00000000-0xc3fffffff]</div><div>[ =C2=
=A0 =C2=A00.000000] =C2=A0 NODE_DATA [mem 0xc3ffce000-0xc3ffd2fff]</div><di=
v>[ =C2=A0 =C2=A00.000000] =C2=A0[ffffea0000000000-ffffea002adfffff] PMD -&=
gt; [ffff880c0f600000-ffff880c395fffff] on node 0</div><div>[ =C2=A0 =C2=A0=
0.000000] Zone ranges:</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 DMA =C2=A0=
 =C2=A0 =C2=A0[mem 0x00001000-0x00ffffff]</div><div>[ =C2=A0 =C2=A00.000000=
] =C2=A0 DMA32 =C2=A0 =C2=A0[mem 0x01000000-0xffffffff]</div><div>[ =C2=A0 =
=C2=A00.000000] =C2=A0 Normal =C2=A0 [mem 0x100000000-0xc3fffffff]</div><di=
v>[ =C2=A0 =C2=A00.000000] Movable zone start for each node</div><div>[ =C2=
=A0 =C2=A00.000000] Early memory node ranges</div><div>[ =C2=A0 =C2=A00.000=
000] =C2=A0 node =C2=A0 0: [mem 0x00001000-0x0009dfff]</div><div>[ =C2=A0 =
=C2=A00.000000] =C2=A0 node =C2=A0 0: [mem 0x00100000-0xbf77ffff]</div><div=
>[ =C2=A0 =C2=A00.000000] =C2=A0 node =C2=A0 0: [mem 0x100000000-0xc3ffffff=
f]</div><div>[ =C2=A0 =C2=A00.000000] On node 0 totalpages: 12580637</div><=
div>[ =C2=A0 =C2=A00.000000] =C2=A0 DMA zone: 56 pages used for memmap</div=
><div>[ =C2=A0 =C2=A00.000000] =C2=A0 DMA zone: 21 pages reserved</div><div=
>[ =C2=A0 =C2=A00.000000] =C2=A0 DMA zone: 3997 pages, LIFO batch:0</div><d=
iv>[ =C2=A0 =C2=A00.000000] =C2=A0 DMA32 zone: 10667 pages used for memmap<=
/div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 DMA32 zone: 780160 pages, LIFO ba=
tch:31</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 Normal zone: 161280 pages =
used for memmap</div><div>[ =C2=A0 =C2=A00.000000] =C2=A0 Normal zone: 1179=
6480 pages, LIFO batch:31</div><div>[ =C2=A0 =C2=A00.000000] ACPI: PM-Timer=
 IO Port: 0x808</div><div>[ =C2=A0 =C2=A00.000000] ACPI: Local APIC address=
 0xfee00000</div><div>[ =C2=A0 =C2=A00.000000] ACPI: LAPIC (acpi_id[0x01] l=
apic_id[0x00] enabled)</div><div>[ =C2=A0 =C2=A00.000000] ACPI: LAPIC (acpi=
_id[0x02] lapic_id[0x02] enabled)</div><div>[ =C2=A0 =C2=A00.000000] ACPI: =
LAPIC (acpi_id[0x03] lapic_id[0x04] enabled)</div><div>[ =C2=A0 =C2=A00.000=
000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x06] enabled)</div><div>[ =C2=A0 =
=C2=A00.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x01] enabled)</div><di=
v>[ =C2=A0 =C2=A00.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x03] enable=
d)</div><div>[ =C2=A0 =C2=A00.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0=
x05] enabled)</div><div>[ =C2=A0 =C2=A00.000000] ACPI: LAPIC (acpi_id[0x08]=
 lapic_id[0x07] enabled)</div><div>[ =C2=A0 =C2=A00.000000] ACPI: LAPIC (ac=
pi_id[0x09] lapic_id[0x88] disabled)</div><div>[ =C2=A0 =C2=A00.000000] ACP=
I: LAPIC (acpi_id[0x0a] lapic_id[0x89] disabled)</div><div>[ =C2=A0 =C2=A00=
.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x8a] disabled)</div><div>[ =
=C2=A0 =C2=A00.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x8b] disabled)<=
/div><div>[ =C2=A0 =C2=A00.000000] ACPI: IOAPIC (id[0x08] address[0xfec0000=
0] gsi_base[0])</div><div>[ =C2=A0 =C2=A00.000000] IOAPIC[0]: apic_id 8, ve=
rsion 32, address 0xfec00000, GSI 0-23</div><div>[ =C2=A0 =C2=A00.000000] A=
CPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)</div><div>[ =C2=A0 =
=C2=A00.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)=
</div><div>[ =C2=A0 =C2=A00.000000] ACPI: IRQ0 used by override.</div><div>=
[ =C2=A0 =C2=A00.000000] ACPI: IRQ2 used by override.</div><div>[ =C2=A0 =
=C2=A00.000000] ACPI: IRQ9 used by override.</div><div>[ =C2=A0 =C2=A00.000=
000] Using ACPI (MADT) for SMP configuration information</div><div>[ =C2=A0=
 =C2=A00.000000] ACPI: HPET id: 0xffffffff base: 0xfed00000</div><div>[ =C2=
=A0 =C2=A00.000000] smpboot: Allowing 12 CPUs, 4 hotplug CPUs</div><div>[ =
=C2=A0 =C2=A00.000000] nr_irqs_gsi: 40</div><div>[ =C2=A0 =C2=A00.000000] P=
M: Registered nosave memory: [mem 0x0009e000-0x0009efff]</div><div>[ =C2=A0=
 =C2=A00.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]<=
/div><div>[ =C2=A0 =C2=A00.000000] PM: Registered nosave memory: [mem 0x000=
a0000-0x000dffff]</div><div>[ =C2=A0 =C2=A00.000000] PM: Registered nosave =
memory: [mem 0x000e0000-0x000fffff]</div><div>[ =C2=A0 =C2=A00.000000] PM: =
Registered nosave memory: [mem 0xbf780000-0xbf78dfff]</div><div>[ =C2=A0 =
=C2=A00.000000] PM: Registered nosave memory: [mem 0xbf78e000-0xbf7cffff]</=
div><div>[ =C2=A0 =C2=A00.000000] PM: Registered nosave memory: [mem 0xbf7d=
0000-0xbf7dffff]</div><div>[ =C2=A0 =C2=A00.000000] PM: Registered nosave m=
emory: [mem 0xbf7e0000-0xbf7ebfff]</div><div>[ =C2=A0 =C2=A00.000000] PM: R=
egistered nosave memory: [mem 0xbf7ec000-0xbfffffff]</div><div>[ =C2=A0 =C2=
=A00.000000] PM: Registered nosave memory: [mem 0xc0000000-0xfedfffff]</div=
><div>[ =C2=A0 =C2=A00.000000] PM: Registered nosave memory: [mem 0xfee0000=
0-0xfee00fff]</div><div>[ =C2=A0 =C2=A00.000000] PM: Registered nosave memo=
ry: [mem 0xfee01000-0xffbfffff]</div><div>[ =C2=A0 =C2=A00.000000] PM: Regi=
stered nosave memory: [mem 0xffc00000-0xffffffff]</div><div>[ =C2=A0 =C2=A0=
0.000000] e820: [mem 0xc0000000-0xfedfffff] available for PCI devices</div>=
<div>[ =C2=A0 =C2=A00.000000] Booting paravirtualized kernel on bare hardwa=
re</div><div>[ =C2=A0 =C2=A00.000000] setup_percpu: NR_CPUS:512 nr_cpumask_=
bits:512 nr_cpu_ids:12 nr_node_ids:1</div><div>[ =C2=A0 =C2=A00.000000] PER=
CPU: Embedded 27 pages/cpu @ffff880c3fc00000 s80896 r8192 d21504 u131072</d=
iv><div>[ =C2=A0 =C2=A00.000000] pcpu-alloc: s80896 r8192 d21504 u131072 al=
loc=3D1*2097152</div><div>[ =C2=A0 =C2=A00.000000] pcpu-alloc: [0] 00 01 02=
 03 04 05 06 07 08 09 10 11 -- -- -- --=C2=A0</div><div>[ =C2=A0 =C2=A00.00=
0000] Built 1 zonelists in Zone order, mobility grouping on.=C2=A0 Total pa=
ges: 12408613</div><div>[ =C2=A0 =C2=A00.000000] Policy zone: Normal</div><=
div>[ =C2=A0 =C2=A00.000000] Kernel command line: BOOT_IMAGE=3D/vmlinuz-3.1=
6.0-4-amd64 root=3DUUID=3D879fd989-f331-4a17-a930-e3f003666d2e ro nomodeset=
</div><div>[ =C2=A0 =C2=A00.000000] PID hash table entries: 4096 (order: 3,=
 32768 bytes)</div><div>[ =C2=A0 =C2=A00.000000] AGP: Checking aperture...<=
/div><div>[ =C2=A0 =C2=A00.000000] AGP: No AGP bridge found</div><div>[ =C2=
=A0 =C2=A00.000000] Calgary: detecting Calgary via BIOS EBDA area</div><div=
>[ =C2=A0 =C2=A00.000000] Calgary: Unable to locate Rio Grande table in EBD=
A - bailing!</div><div>[ =C2=A0 =C2=A00.000000] Memory: 49538472K/50322548K=
 available (5209K kernel code, 946K rwdata, 1832K rodata, 1204K init, 840K =
bss, 784076K reserved)</div><div>[ =C2=A0 =C2=A00.000000] Hierarchical RCU =
implementation.</div><div>[ =C2=A0 =C2=A00.000000] <span class=3D"" style=
=3D"white-space:pre">	</span>RCU dyntick-idle grace-period acceleration is =
enabled.</div><div>[ =C2=A0 =C2=A00.000000] <span class=3D"" style=3D"white=
-space:pre">	</span>RCU restricting CPUs from NR_CPUS=3D512 to nr_cpu_ids=
=3D12.</div><div>[ =C2=A0 =C2=A00.000000] RCU: Adjusting geometry for rcu_f=
anout_leaf=3D16, nr_cpu_ids=3D12</div><div>[ =C2=A0 =C2=A00.000000] NR_IRQS=
:33024 nr_irqs:776 16</div><div>[ =C2=A0 =C2=A00.000000] Console: colour VG=
A+ 80x25</div><div>[ =C2=A0 =C2=A00.000000] console [tty0] enabled</div><di=
v>[ =C2=A0 =C2=A00.000000] hpet clockevent registered</div><div>[ =C2=A0 =
=C2=A00.000000] tsc: Fast TSC calibration failed</div><div>[ =C2=A0 =C2=A00=
.000000] tsc: PIT calibration matches HPET. 1 loops</div><div>[ =C2=A0 =C2=
=A00.000000] tsc: Detected 2806.961 MHz processor</div><div>[ =C2=A0 =C2=A0=
0.000031] Calibrating delay loop (skipped), value calculated using timer fr=
equency.. 5613.92 BogoMIPS (lpj=3D11227844)</div><div>[ =C2=A0 =C2=A00.0001=
47] pid_max: default: 32768 minimum: 301</div><div>[ =C2=A0 =C2=A00.000211]=
 ACPI: Core revision 20140424</div><div>[ =C2=A0 =C2=A00.005912] ACPI: All =
ACPI Tables successfully acquired</div><div>[ =C2=A0 =C2=A00.029909] Securi=
ty Framework initialized</div><div>[ =C2=A0 =C2=A00.029973] AppArmor: AppAr=
mor disabled by boot time parameter</div><div>[ =C2=A0 =C2=A00.030039] Yama=
: disabled by default; enable with sysctl kernel.yama.*</div><div>[ =C2=A0 =
=C2=A00.034285] Dentry cache hash table entries: 8388608 (order: 14, 671088=
64 bytes)</div><div>[ =C2=A0 =C2=A00.046946] Inode-cache hash table entries=
: 4194304 (order: 13, 33554432 bytes)</div><div>[ =C2=A0 =C2=A00.052343] Mo=
unt-cache hash table entries: 131072 (order: 8, 1048576 bytes)</div><div>[ =
=C2=A0 =C2=A00.052475] Mountpoint-cache hash table entries: 131072 (order: =
8, 1048576 bytes)</div><div>[ =C2=A0 =C2=A00.053070] Initializing cgroup su=
bsys memory</div><div>[ =C2=A0 =C2=A00.053131] Initializing cgroup subsys d=
evices</div><div>[ =C2=A0 =C2=A00.053194] Initializing cgroup subsys freeze=
r</div><div>[ =C2=A0 =C2=A00.053252] Initializing cgroup subsys net_cls</di=
v><div>[ =C2=A0 =C2=A00.053312] Initializing cgroup subsys blkio</div><div>=
[ =C2=A0 =C2=A00.053370] Initializing cgroup subsys perf_event</div><div>[ =
=C2=A0 =C2=A00.053428] Initializing cgroup subsys net_prio</div><div>[ =C2=
=A0 =C2=A00.053510] CPU: Physical Processor ID: 0</div><div>[ =C2=A0 =C2=A0=
0.053565] CPU: Processor Core ID: 0</div><div>[ =C2=A0 =C2=A00.053624] mce:=
 CPU supports 9 MCE banks</div><div>[ =C2=A0 =C2=A00.053692] CPU0: Thermal =
monitoring enabled (TM1)</div><div>[ =C2=A0 =C2=A00.053755] process: using =
mwait in idle threads</div><div>[ =C2=A0 =C2=A00.053814] Last level iTLB en=
tries: 4KB 512, 2MB 7, 4MB 7</div><div>Last level dTLB entries: 4KB 512, 2M=
B 32, 4MB 32, 1GB 0</div><div>tlb_flushall_shift: 6</div><div>[ =C2=A0 =C2=
=A00.054001] Freeing SMP alternatives memory: 20K (ffffffff81a1b000 - fffff=
fff81a20000)</div><div>[ =C2=A0 =C2=A00.055213] ftrace: allocating 21623 en=
tries in 85 pages</div><div>[ =C2=A0 =C2=A00.065126] Switched APIC routing =
to physical flat.</div><div>[ =C2=A0 =C2=A00.065564] ..TIMER: vector=3D0x30=
 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1</div><div>[ =C2=A0 =C2=A00.105326]=
 smpboot: CPU0: Intel(R) Core(TM) i7 CPU =C2=A0 =C2=A0 =C2=A0 =C2=A0 930 =
=C2=A0@ 2.80GHz (fam: 06, model: 1a, stepping: 05)</div><div>[ =C2=A0 =C2=
=A00.210111] Performance Events: PEBS fmt1+, 16-deep LBR, Nehalem events, I=
ntel PMU driver.</div><div>[ =C2=A0 =C2=A00.210333] perf_event_intel: CPU e=
rratum AAJ80 worked around</div><div>[ =C2=A0 =C2=A00.210392] perf_event_in=
tel: CPUID marked event: &#39;bus cycles&#39; unavailable</div><div>[ =C2=
=A0 =C2=A00.210454] ... version: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A03</div><div>[ =C2=A0 =C2=A00.210509] ... bit width: =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A048</div><div>[ =C2=A0 =C2=A00.210564]=
 ... generic registers: =C2=A0 =C2=A0 =C2=A04</div><div>[ =C2=A0 =C2=A00.21=
0619] ... value mask: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0000fffffff=
fffff</div><div>[ =C2=A0 =C2=A00.210676] ... max period: =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 000000007fffffff</div><div>[ =C2=A0 =C2=A00.210734=
] ... fixed-purpose events: =C2=A0 3</div><div>[ =C2=A0 =C2=A00.210789] ...=
 event mask: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 000000070000000f</di=
v><div>[ =C2=A0 =C2=A00.212392] x86: Booting SMP configuration:</div><div>[=
 =C2=A0 =C2=A00.212449] .... node =C2=A0#0, CPUs: =C2=A0 =C2=A0 =C2=A0 =C2=
=A0#1</div><div>[ =C2=A0 =C2=A00.225819] NMI watchdog: enabled on all CPUs,=
 permanently consumes one hw-PMU counter.</div><div>[ =C2=A0 =C2=A00.226067=
] =C2=A0 #2 =C2=A0#3 =C2=A0#4 =C2=A0#5 =C2=A0#6 =C2=A0#7</div><div>[ =C2=A0=
 =C2=A00.307401] x86: Booted up 1 node, 8 CPUs</div><div>[ =C2=A0 =C2=A00.3=
07507] smpboot: Total of 8 processors activated (44911.37 BogoMIPS)</div><d=
iv>[ =C2=A0 =C2=A00.313395] devtmpfs: initialized</div><div>[ =C2=A0 =C2=A0=
0.321002] PM: Registering ACPI NVS region [mem 0xbf78e000-0xbf7cffff] (2703=
36 bytes)</div><div>[ =C2=A0 =C2=A00.321966] pinctrl core: initialized pinc=
trl subsystem</div><div>[ =C2=A0 =C2=A00.322097] NET: Registered protocol f=
amily 16</div><div>[ =C2=A0 =C2=A00.322260] cpuidle: using governor ladder<=
/div><div>[ =C2=A0 =C2=A00.322316] cpuidle: using governor menu</div><div>[=
 =C2=A0 =C2=A00.322404] ACPI: bus type PCI registered</div><div>[ =C2=A0 =
=C2=A00.322460] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5</=
div><div>[ =C2=A0 =C2=A00.322601] PCI: MMCONFIG for domain 0000 [bus 00-ff]=
 at [mem 0xe0000000-0xefffffff] (base 0xe0000000)</div><div>[ =C2=A0 =C2=A0=
0.322681] PCI: not using MMCONFIG</div><div>[ =C2=A0 =C2=A00.322735] PCI: U=
sing configuration type 1 for base access</div><div>[ =C2=A0 =C2=A00.334566=
] ACPI: Added _OSI(Module Device)</div><div>[ =C2=A0 =C2=A00.334623] ACPI: =
Added _OSI(Processor Device)</div><div>[ =C2=A0 =C2=A00.334679] ACPI: Added=
 _OSI(3.0 _SCP Extensions)</div><div>[ =C2=A0 =C2=A00.334735] ACPI: Added _=
OSI(Processor Aggregator Device)</div><div>[ =C2=A0 =C2=A00.336166] ACPI: E=
xecuted 1 blocks of module-level executable AML code</div><div>[ =C2=A0 =C2=
=A00.338902] ACPI: Dynamic OEM Table Load:</div><div>[ =C2=A0 =C2=A00.33903=
1] ACPI: SSDT 0xFFFF880C0E24C000 001E1C (v01 DpgPmm P001Ist =C2=A000000011 =
INTL 20051117)</div><div>[ =C2=A0 =C2=A00.339673] ACPI: Dynamic OEM Table L=
oad:</div><div>[ =C2=A0 =C2=A00.339796] ACPI: SSDT 0xFFFF880C0E213800 00067=
8 (v01 PmRef =C2=A0P001Cst =C2=A000003001 INTL 20051117)</div><div>[ =C2=A0=
 =C2=A00.349953] ACPI: Interpreter enabled</div><div>[ =C2=A0 =C2=A00.35001=
4] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (2014=
0424/hwxface-580)</div><div>[ =C2=A0 =C2=A00.350160] ACPI Exception: AE_NOT=
_FOUND, While evaluating Sleep State [\_S3_] (20140424/hwxface-580)</div><d=
iv>[ =C2=A0 =C2=A00.350314] ACPI: (supports S0 S1 S4 S5)</div><div>[ =C2=A0=
 =C2=A00.350369] ACPI: Using IOAPIC for interrupt routing</div><div>[ =C2=
=A0 =C2=A00.350448] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe00=
00000-0xefffffff] (base 0xe0000000)</div><div>[ =C2=A0 =C2=A00.351026] PCI:=
 MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in ACPI motherboard resou=
rces</div><div>[ =C2=A0 =C2=A00.351573] PCI: Using host bridge windows from=
 ACPI; if necessary, use &quot;pci=3Dnocrs&quot; and report a bug</div><div=
>[ =C2=A0 =C2=A00.357224] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00=
-ff])</div><div>[ =C2=A0 =C2=A00.357287] acpi PNP0A08:00: _OSC: OS supports=
 [ExtendedConfig ASPM ClockPM Segments MSI]</div><div>[ =C2=A0 =C2=A00.3575=
20] acpi PNP0A08:00: _OSC: platform does not support [PCIeCapability]</div>=
<div>[ =C2=A0 =C2=A00.357656] acpi PNP0A08:00: _OSC: not requesting control=
; platform does not support [PCIeCapability]</div><div>[ =C2=A0 =C2=A00.357=
735] acpi PNP0A08:00: _OSC: OS requested [PCIeHotplug PME AER PCIeCapabilit=
y]</div><div>[ =C2=A0 =C2=A00.357812] acpi PNP0A08:00: _OSC: platform willi=
ng to grant [PCIeHotplug PME AER]</div><div>[ =C2=A0 =C2=A00.357888] acpi P=
NP0A08:00: _OSC failed (AE_SUPPORT); disabling ASPM</div><div>[ =C2=A0 =C2=
=A00.358228] PCI host bridge to bus 0000:00</div><div>[ =C2=A0 =C2=A00.3582=
85] pci_bus 0000:00: root bus resource [bus 00-ff]</div><div>[ =C2=A0 =C2=
=A00.358346] pci_bus 0000:00: root bus resource [io =C2=A00x0000-0x0cf7]</d=
iv><div>[ =C2=A0 =C2=A00.358405] pci_bus 0000:00: root bus resource [io =C2=
=A00x0d00-0xffff]</div><div>[ =C2=A0 =C2=A00.358464] pci_bus 0000:00: root =
bus resource [mem 0x000a0000-0x000bffff]</div><div>[ =C2=A0 =C2=A00.358525]=
 pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000dffff]</div><div>[=
 =C2=A0 =C2=A00.358585] pci_bus 0000:00: root bus resource [mem 0xc0000000-=
0xdfffffff]</div><div>[ =C2=A0 =C2=A00.358645] pci_bus 0000:00: root bus re=
source [mem 0xf0000000-0xfed8ffff]</div><div>[ =C2=A0 =C2=A00.358715] pci 0=
000:00:00.0: [8086:3405] type 00 class 0x060000</div><div>[ =C2=A0 =C2=A00.=
358770] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold</div><div>[ =
=C2=A0 =C2=A00.358847] pci 0000:00:01.0: [8086:3408] type 01 class 0x060400=
</div><div>[ =C2=A0 =C2=A00.358901] pci 0000:00:01.0: PME# supported from D=
0 D3hot D3cold</div><div>[ =C2=A0 =C2=A00.358944] pci 0000:00:01.0: System =
wakeup disabled by ACPI</div><div>[ =C2=A0 =C2=A00.359040] pci 0000:00:03.0=
: [8086:340a] type 01 class 0x060400</div><div>[ =C2=A0 =C2=A00.359097] pci=
 0000:00:03.0: PME# supported from D0 D3hot D3cold</div><div>[ =C2=A0 =C2=
=A00.359140] pci 0000:00:03.0: System wakeup disabled by ACPI</div><div>[ =
=C2=A0 =C2=A00.359237] pci 0000:00:07.0: [8086:340e] type 01 class 0x060400=
</div><div>[ =C2=A0 =C2=A00.359290] pci 0000:00:07.0: PME# supported from D=
0 D3hot D3cold</div><div>[ =C2=A0 =C2=A00.359331] pci 0000:00:07.0: System =
wakeup disabled by ACPI</div><div>[ =C2=A0 =C2=A00.359432] pci 0000:00:14.0=
: [8086:342e] type 00 class 0x080000</div><div>[ =C2=A0 =C2=A00.359537] pci=
 0000:00:14.1: [8086:3422] type 00 class 0x080000</div><div>[ =C2=A0 =C2=A0=
0.359639] pci 0000:00:14.2: [8086:3423] type 00 class 0x080000</div><div>[ =
=C2=A0 =C2=A00.359740] pci 0000:00:14.3: [8086:3438] type 00 class 0x080000=
</div><div>[ =C2=A0 =C2=A00.359835] pci 0000:00:1a.0: [8086:3a37] type 00 c=
lass 0x0c0300</div><div>[ =C2=A0 =C2=A00.359874] pci 0000:00:1a.0: reg 0x20=
: [io =C2=A00xbc00-0xbc1f]</div><div>[ =C2=A0 =C2=A00.359956] pci 0000:00:1=
a.0: System wakeup disabled by ACPI</div><div>[ =C2=A0 =C2=A00.360052] pci =
0000:00:1a.1: [8086:3a38] type 00 class 0x0c0300</div><div>[ =C2=A0 =C2=A00=
.360090] pci 0000:00:1a.1: reg 0x20: [io =C2=A00xb880-0xb89f]</div><div>[ =
=C2=A0 =C2=A00.360171] pci 0000:00:1a.1: System wakeup disabled by ACPI</di=
v><div>[ =C2=A0 =C2=A00.360266] pci 0000:00:1a.2: [8086:3a39] type 00 class=
 0x0c0300</div><div>[ =C2=A0 =C2=A00.360304] pci 0000:00:1a.2: reg 0x20: [i=
o =C2=A00xb800-0xb81f]</div><div>[ =C2=A0 =C2=A00.360385] pci 0000:00:1a.2:=
 System wakeup disabled by ACPI</div><div>[ =C2=A0 =C2=A00.360488] pci 0000=
:00:1a.7: [8086:3a3c] type 00 class 0x0c0320</div><div>[ =C2=A0 =C2=A00.360=
507] pci 0000:00:1a.7: reg 0x10: [mem 0xf7ffe000-0xf7ffe3ff]</div><div>[ =
=C2=A0 =C2=A00.360591] pci 0000:00:1a.7: PME# supported from D0 D3hot D3col=
d</div><div>[ =C2=A0 =C2=A00.360635] pci 0000:00:1a.7: System wakeup disabl=
ed by ACPI</div><div>[ =C2=A0 =C2=A00.360730] pci 0000:00:1c.0: [8086:3a40]=
 type 01 class 0x060400</div><div>[ =C2=A0 =C2=A00.360796] pci 0000:00:1c.0=
: PME# supported from D0 D3hot D3cold</div><div>[ =C2=A0 =C2=A00.360840] pc=
i 0000:00:1c.0: System wakeup disabled by ACPI</div><div>[ =C2=A0 =C2=A00.3=
60936] pci 0000:00:1c.4: [8086:3a48] type 01 class 0x060400</div><div>[ =C2=
=A0 =C2=A00.361006] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold</=
div><div>[ =C2=A0 =C2=A00.361050] pci 0000:00:1c.4: System wakeup disabled =
by ACPI</div><div>[ =C2=A0 =C2=A00.361146] pci 0000:00:1d.0: [8086:3a34] ty=
pe 00 class 0x0c0300</div><div>[ =C2=A0 =C2=A00.361185] pci 0000:00:1d.0: r=
eg 0x20: [io =C2=A00xb480-0xb49f]</div><div>[ =C2=A0 =C2=A00.361265] pci 00=
00:00:1d.0: System wakeup disabled by ACPI</div><div>[ =C2=A0 =C2=A00.36136=
0] pci 0000:00:1d.1: [8086:3a35] type 00 class 0x0c0300</div><div>[ =C2=A0 =
=C2=A00.361400] pci 0000:00:1d.1: reg 0x20: [io =C2=A00xb400-0xb41f]</div><=
div>[ =C2=A0 =C2=A00.361480] pci 0000:00:1d.1: System wakeup disabled by AC=
PI</div><div>[ =C2=A0 =C2=A00.361575] pci 0000:00:1d.2: [8086:3a36] type 00=
 class 0x0c0300</div><div>[ =C2=A0 =C2=A00.361613] pci 0000:00:1d.2: reg 0x=
20: [io =C2=A00xb080-0xb09f]</div><div>[ =C2=A0 =C2=A00.361694] pci 0000:00=
:1d.2: System wakeup disabled by ACPI</div><div>[ =C2=A0 =C2=A00.361797] pc=
i 0000:00:1d.7: [8086:3a3a] type 00 class 0x0c0320</div><div>[ =C2=A0 =C2=
=A00.361817] pci 0000:00:1d.7: reg 0x10: [mem 0xf7ffc000-0xf7ffc3ff]</div><=
div>[ =C2=A0 =C2=A00.361900] pci 0000:00:1d.7: PME# supported from D0 D3hot=
 D3cold</div><div>[ =C2=A0 =C2=A00.361944] pci 0000:00:1d.7: System wakeup =
disabled by ACPI</div><div>[ =C2=A0 =C2=A00.362037] pci 0000:00:1e.0: [8086=
:244e] type 01 class 0x060401</div><div>[ =C2=A0 =C2=A00.362111] pci 0000:0=
0:1e.0: System wakeup disabled by ACPI</div><div>[ =C2=A0 =C2=A00.362208] p=
ci 0000:00:1f.0: [8086:3a16] type 00 class 0x060100</div><div>[ =C2=A0 =C2=
=A00.362281] pci 0000:00:1f.0: can&#39;t claim BAR 13 [io =C2=A00x0800-0x08=
7f]: address conflict with ACPI CPU throttle [io =C2=A00x0810-0x0815]</div>=
<div>[ =C2=A0 =C2=A00.362370] pci 0000:00:1f.0: quirk: [io =C2=A00x0500-0x0=
53f] claimed by ICH6 GPIO</div><div>[ =C2=A0 =C2=A00.362432] pci 0000:00:1f=
.0: ICH7 LPC Generic IO decode 1 PIO at 0a00 (mask 00ff)</div><div>[ =C2=A0=
 =C2=A00.362510] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at 0a00=
 (mask 0017)</div><div>[ =C2=A0 =C2=A00.362588] pci 0000:00:1f.0: ICH7 LPC =
Generic IO decode 3 PIO at 4700 (mask 00ff)</div><div>[ =C2=A0 =C2=A00.3627=
60] pci 0000:00:1f.2: [8086:3a22] type 00 class 0x010601</div><div>[ =C2=A0=
 =C2=A00.362777] pci 0000:00:1f.2: reg 0x10: [io =C2=A00xb000-0xb007]</div>=
<div>[ =C2=A0 =C2=A00.362784] pci 0000:00:1f.2: reg 0x14: [io =C2=A00xac00-=
0xac03]</div><div>[ =C2=A0 =C2=A00.362791] pci 0000:00:1f.2: reg 0x18: [io =
=C2=A00xa880-0xa887]</div><div>[ =C2=A0 =C2=A00.362798] pci 0000:00:1f.2: r=
eg 0x1c: [io =C2=A00xa800-0xa803]</div><div>[ =C2=A0 =C2=A00.362804] pci 00=
00:00:1f.2: reg 0x20: [io =C2=A00xa480-0xa49f]</div><div>[ =C2=A0 =C2=A00.3=
62811] pci 0000:00:1f.2: reg 0x24: [mem 0xf7ffa000-0xf7ffa7ff]</div><div>[ =
=C2=A0 =C2=A00.362853] pci 0000:00:1f.2: PME# supported from D3hot</div><di=
v>[ =C2=A0 =C2=A00.362926] pci 0000:00:1f.3: [8086:3a30] type 00 class 0x0c=
0500</div><div>[ =C2=A0 =C2=A00.362940] pci 0000:00:1f.3: reg 0x10: [mem 0x=
f7ff9c00-0xf7ff9cff 64bit]</div><div>[ =C2=A0 =C2=A00.362958] pci 0000:00:1=
f.3: reg 0x20: [io =C2=A00x0400-0x041f]</div><div>[ =C2=A0 =C2=A00.363074] =
pci 0000:00:01.0: PCI bridge to [bus 01]</div><div>[ =C2=A0 =C2=A00.363185]=
 pci 0000:02:00.0: [10de:06e4] type 00 class 0x030000</div><div>[ =C2=A0 =
=C2=A00.363195] pci 0000:02:00.0: reg 0x10: [mem 0xfa000000-0xfaffffff]</di=
v><div>[ =C2=A0 =C2=A00.363203] pci 0000:02:00.0: reg 0x14: [mem 0xd0000000=
-0xdfffffff 64bit pref]</div><div>[ =C2=A0 =C2=A00.363212] pci 0000:02:00.0=
: reg 0x1c: [mem 0xf8000000-0xf9ffffff 64bit]</div><div>[ =C2=A0 =C2=A00.36=
3218] pci 0000:02:00.0: reg 0x24: [io =C2=A00xcc00-0xcc7f]</div><div>[ =C2=
=A0 =C2=A00.363224] pci 0000:02:00.0: reg 0x30: [mem 0xfbce0000-0xfbcfffff =
pref]</div><div>[ =C2=A0 =C2=A00.370309] pci 0000:00:03.0: PCI bridge to [b=
us 02]</div><div>[ =C2=A0 =C2=A00.370373] pci 0000:00:03.0: =C2=A0 bridge w=
indow [io =C2=A00xc000-0xcfff]</div><div>[ =C2=A0 =C2=A00.370379] pci 0000:=
00:03.0: =C2=A0 bridge window [mem 0xf8000000-0xfbcfffff]</div><div>[ =C2=
=A0 =C2=A00.370384] pci 0000:00:03.0: =C2=A0 bridge window [mem 0xd0000000-=
0xdfffffff 64bit pref]</div><div>[ =C2=A0 =C2=A00.370428] pci 0000:00:07.0:=
 PCI bridge to [bus 03]</div><div>[ =C2=A0 =C2=A00.370536] pci 0000:00:1c.0=
: PCI bridge to [bus 04]</div><div>[ =C2=A0 =C2=A00.370662] pci 0000:06:00.=
0: [10ec:8168] type 00 class 0x020000</div><div>[ =C2=A0 =C2=A00.370681] pc=
i 0000:06:00.0: reg 0x10: [io =C2=A00xe800-0xe8ff]</div><div>[ =C2=A0 =C2=
=A00.370707] pci 0000:06:00.0: reg 0x18: [mem 0xfbeff000-0xfbefffff 64bit]<=
/div><div>[ =C2=A0 =C2=A00.370723] pci 0000:06:00.0: reg 0x20: [mem 0xf6ff0=
000-0xf6ffffff 64bit pref]</div><div>[ =C2=A0 =C2=A00.370735] pci 0000:06:0=
0.0: reg 0x30: [mem 0x00000000-0x0001ffff pref]</div><div>[ =C2=A0 =C2=A00.=
370812] pci 0000:06:00.0: supports D1 D2</div><div>[ =C2=A0 =C2=A00.370813]=
 pci 0000:06:00.0: PME# supported from D0 D1 D2 D3hot D3cold</div><div>[ =
=C2=A0 =C2=A00.378320] pci 0000:00:1c.4: PCI bridge to [bus 06]</div><div>[=
 =C2=A0 =C2=A00.378387] pci 0000:00:1c.4: =C2=A0 bridge window [io =C2=A00x=
e000-0xefff]</div><div>[ =C2=A0 =C2=A00.378390] pci 0000:00:1c.4: =C2=A0 br=
idge window [mem 0xfbe00000-0xfbefffff]</div><div>[ =C2=A0 =C2=A00.378395] =
pci 0000:00:1c.4: =C2=A0 bridge window [mem 0xf6f00000-0xf6ffffff 64bit pre=
f]</div><div>[ =C2=A0 =C2=A00.378463] pci 0000:00:1e.0: PCI bridge to [bus =
07] (subtractive decode)</div><div>[ =C2=A0 =C2=A00.378530] pci 0000:00:1e.=
0: =C2=A0 bridge window [io =C2=A00x0000-0x0cf7] (subtractive decode)</div>=
<div>[ =C2=A0 =C2=A00.378532] pci 0000:00:1e.0: =C2=A0 bridge window [io =
=C2=A00x0d00-0xffff] (subtractive decode)</div><div>[ =C2=A0 =C2=A00.378533=
] pci 0000:00:1e.0: =C2=A0 bridge window [mem 0x000a0000-0x000bffff] (subtr=
active decode)</div><div>[ =C2=A0 =C2=A00.378535] pci 0000:00:1e.0: =C2=A0 =
bridge window [mem 0x000d0000-0x000dffff] (subtractive decode)</div><div>[ =
=C2=A0 =C2=A00.378536] pci 0000:00:1e.0: =C2=A0 bridge window [mem 0xc00000=
00-0xdfffffff] (subtractive decode)</div><div>[ =C2=A0 =C2=A00.378538] pci =
0000:00:1e.0: =C2=A0 bridge window [mem 0xf0000000-0xfed8ffff] (subtractive=
 decode)</div><div>[ =C2=A0 =C2=A00.378972] ACPI: PCI Interrupt Link [LNKA]=
 (IRQs 3 4 6 7 *10 11 12 14 15)</div><div>[ =C2=A0 =C2=A00.379431] ACPI: PC=
I Interrupt Link [LNKB] (IRQs *5)</div><div>[ =C2=A0 =C2=A00.379626] ACPI: =
PCI Interrupt Link [LNKC] (IRQs 3 4 6 7 10 11 12 *14 15)</div><div>[ =C2=A0=
 =C2=A00.380085] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 6 7 10 *11 12 14=
 15)</div><div>[ =C2=A0 =C2=A00.380541] ACPI: PCI Interrupt Link [LNKE] (IR=
Qs 3 4 6 7 10 11 12 14 15) *0, disabled.</div><div>[ =C2=A0 =C2=A00.381079]=
 ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 6 7 10 11 12 14 *15)</div><div>[=
 =C2=A0 =C2=A00.381536] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 6 7 10 11=
 12 14 15) *0, disabled.</div><div>[ =C2=A0 =C2=A00.382075] ACPI: PCI Inter=
rupt Link [LNKH] (IRQs *3 4 6 7 10 11 12 14 15)</div><div>[ =C2=A0 =C2=A00.=
382537] ACPI: Enabled 1 GPEs in block 00 to 3F</div><div>[ =C2=A0 =C2=A00.3=
82748] vgaarb: setting as boot device: PCI:0000:02:00.0</div><div>[ =C2=A0 =
=C2=A00.382807] vgaarb: device added: PCI:0000:02:00.0,decodes=3Dio+mem,own=
s=3Dio+mem,locks=3Dnone</div><div>[ =C2=A0 =C2=A00.382884] vgaarb: loaded</=
div><div>[ =C2=A0 =C2=A00.382936] vgaarb: bridge control possible 0000:02:0=
0.0</div><div>[ =C2=A0 =C2=A00.383041] PCI: Using ACPI for IRQ routing</div=
><div>[ =C2=A0 =C2=A00.388801] PCI: Discovered peer bus ff</div><div>[ =C2=
=A0 =C2=A00.388856] PCI: root bus ff: using default resources</div><div>[ =
=C2=A0 =C2=A00.388857] PCI: Probing PCI hardware (bus ff)</div><div>[ =C2=
=A0 =C2=A00.388883] PCI host bridge to bus 0000:ff</div><div>[ =C2=A0 =C2=
=A00.388939] pci_bus 0000:ff: root bus resource [io =C2=A00x0000-0xffff]</d=
iv><div>[ =C2=A0 =C2=A00.388998] pci_bus 0000:ff: root bus resource [mem 0x=
00000000-0xfffffffff]</div><div>[ =C2=A0 =C2=A00.389059] pci_bus 0000:ff: N=
o busn resource found for root bus, will use [bus ff-ff]</div><div>[ =C2=A0=
 =C2=A00.389136] pci_bus 0000:ff: busn_res: can not insert [bus ff] under d=
omain [bus 00-ff] (conflicts with (null) [bus 00-ff])</div><div>[ =C2=A0 =
=C2=A00.389141] pci 0000:ff:00.0: [8086:2c41] type 00 class 0x060000</div><=
div>[ =C2=A0 =C2=A00.389182] pci 0000:ff:00.1: [8086:2c01] type 00 class 0x=
060000</div><div>[ =C2=A0 =C2=A00.389221] pci 0000:ff:02.0: [8086:2c10] typ=
e 00 class 0x060000</div><div>[ =C2=A0 =C2=A00.389258] pci 0000:ff:02.1: [8=
086:2c11] type 00 class 0x060000</div><div>[ =C2=A0 =C2=A00.389297] pci 000=
0:ff:03.0: [8086:2c18] type 00 class 0x060000</div><div>[ =C2=A0 =C2=A00.38=
9334] pci 0000:ff:03.1: [8086:2c19] type 00 class 0x060000</div><div>[ =C2=
=A0 =C2=A00.389371] pci 0000:ff:03.4: [8086:2c1c] type 00 class 0x060000</d=
iv><div>[ =C2=A0 =C2=A00.389409] pci 0000:ff:04.0: [8086:2c20] type 00 clas=
s 0x060000</div><div>[ =C2=A0 =C2=A00.389446] pci 0000:ff:04.1: [8086:2c21]=
 type 00 class 0x060000</div><div>[ =C2=A0 =C2=A00.389483] pci 0000:ff:04.2=
: [8086:2c22] type 00 class 0x060000</div><div>[ =C2=A0 =C2=A00.389520] pci=
 0000:ff:04.3: [8086:2c23] type 00 class 0x060000</div><div>[ =C2=A0 =C2=A0=
0.389558] pci 0000:ff:05.0: [8086:2c28] type 00 class 0x060000</div><div>[ =
=C2=A0 =C2=A00.389596] pci 0000:ff:05.1: [8086:2c29] type 00 class 0x060000=
</div><div>[ =C2=A0 =C2=A00.389633] pci 0000:ff:05.2: [8086:2c2a] type 00 c=
lass 0x060000</div><div>[ =C2=A0 =C2=A00.389670] pci 0000:ff:05.3: [8086:2c=
2b] type 00 class 0x060000</div><div>[ =C2=A0 =C2=A00.389709] pci 0000:ff:0=
6.0: [8086:2c30] type 00 class 0x060000</div><div>[ =C2=A0 =C2=A00.389746] =
pci 0000:ff:06.1: [8086:2c31] type 00 class 0x060000</div><div>[ =C2=A0 =C2=
=A00.389782] pci 0000:ff:06.2: [8086:2c32] type 00 class 0x060000</div><div=
>[ =C2=A0 =C2=A00.389818] pci 0000:ff:06.3: [8086:2c33] type 00 class 0x060=
000</div><div>[ =C2=A0 =C2=A00.389864] pci_bus 0000:ff: busn_res: [bus ff] =
end is updated to ff</div><div>[ =C2=A0 =C2=A00.389866] pci_bus 0000:ff: bu=
sn_res: can not insert [bus ff] under domain [bus 00-ff] (conflicts with (n=
ull) [bus 00-ff])</div><div>[ =C2=A0 =C2=A00.389869] PCI: pci_cache_line_si=
ze set to 64 bytes</div><div>[ =C2=A0 =C2=A00.389928] e820: reserve RAM buf=
fer [mem 0x0009ec00-0x0009ffff]</div><div>[ =C2=A0 =C2=A00.389930] e820: re=
serve RAM buffer [mem 0xbf780000-0xbfffffff]</div><div>[ =C2=A0 =C2=A00.390=
038] HPET: 4 timers in total, 0 timers will be used for per-cpu timer</div>=
<div>[ =C2=A0 =C2=A00.390102] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0</d=
iv><div>[ =C2=A0 =C2=A00.390325] hpet0: 4 comparators, 64-bit 14.318180 MHz=
 counter</div><div>[ =C2=A0 =C2=A00.392557] Switched to clocksource hpet</d=
iv><div>[ =C2=A0 =C2=A00.397105] pnp: PnP ACPI init</div><div>[ =C2=A0 =C2=
=A00.397169] ACPI: bus type PNP registered</div><div>[ =C2=A0 =C2=A00.39728=
1] system 00:00: [mem 0xfbf00000-0xfbffffff] has been reserved</div><div>[ =
=C2=A0 =C2=A00.397342] system 00:00: [mem 0xfc000000-0xfcffffff] has been r=
eserved</div><div>[ =C2=A0 =C2=A00.397402] system 00:00: [mem 0xfd000000-0x=
fdffffff] has been reserved</div><div>[ =C2=A0 =C2=A00.397463] system 00:00=
: [mem 0xfe000000-0xfebfffff] has been reserved</div><div>[ =C2=A0 =C2=A00.=
397523] system 00:00: [mem 0xfec8a000-0xfec8afff] has been reserved</div><d=
iv>[ =C2=A0 =C2=A00.397583] system 00:00: [mem 0xfed10000-0xfed10fff] has b=
een reserved</div><div>[ =C2=A0 =C2=A00.397644] system 00:00: Plug and Play=
 ACPI device, IDs PNP0c01 (active)</div><div>[ =C2=A0 =C2=A00.397700] pnp 0=
0:01: Plug and Play ACPI device, IDs PNP0b00 (active)</div><div>[ =C2=A0 =
=C2=A00.397823] pnp 00:02: Plug and Play ACPI device, IDs PNP0303 PNP030b (=
active)</div><div>[ =C2=A0 =C2=A00.397934] system 00:03: [io =C2=A00x0a00-0=
x0adf] has been reserved</div><div>[ =C2=A0 =C2=A00.397993] system 00:03: [=
io =C2=A00x0ae0-0x0aef] has been reserved</div><div>[ =C2=A0 =C2=A00.398053=
] system 00:03: Plug and Play ACPI device, IDs PNP0c02 (active)</div><div>[=
 =C2=A0 =C2=A00.398200] system 00:04: [io =C2=A00x04d0-0x04d1] has been res=
erved</div><div>[ =C2=A0 =C2=A00.398260] system 00:04: [io =C2=A00x0800-0x0=
87f] could not be reserved</div><div>[ =C2=A0 =C2=A00.398320] system 00:04:=
 [io =C2=A00x0500-0x057f] could not be reserved</div><div>[ =C2=A0 =C2=A00.=
398379] system 00:04: [mem 0xfed1c000-0xfed1ffff] has been reserved</div><d=
iv>[ =C2=A0 =C2=A00.398440] system 00:04: [mem 0xfed10000-0xfed103ff] has b=
een reserved</div><div>[ =C2=A0 =C2=A00.398500] system 00:04: [mem 0xfed104=
00-0xfed107ff] has been reserved</div><div>[ =C2=A0 =C2=A00.398560] system =
00:04: [mem 0xfed10800-0xfed10bff] has been reserved</div><div>[ =C2=A0 =C2=
=A00.398620] system 00:04: [mem 0xfed10c00-0xfed10fff] has been reserved</d=
iv><div>[ =C2=A0 =C2=A00.398680] system 00:04: [mem 0xfec8a000-0xfec8a3ff] =
has been reserved</div><div>[ =C2=A0 =C2=A00.398741] system 00:04: [mem 0xf=
ec8a400-0xfec8a7ff] has been reserved</div><div>[ =C2=A0 =C2=A00.398801] sy=
stem 00:04: [mem 0xfec8a800-0xfec8abff] has been reserved</div><div>[ =C2=
=A0 =C2=A00.398861] system 00:04: [mem 0xfec8ac00-0xfec8afff] has been rese=
rved</div><div>[ =C2=A0 =C2=A00.398921] system 00:04: [mem 0xfed20000-0xfed=
3ffff] has been reserved</div><div>[ =C2=A0 =C2=A00.398981] system 00:04: [=
mem 0xfed45000-0xfed89fff] has been reserved</div><div>[ =C2=A0 =C2=A00.399=
041] system 00:04: [mem 0xfed20000-0xfed3ffff] has been reserved</div><div>=
[ =C2=A0 =C2=A00.399101] system 00:04: [mem 0xfed40000-0xfed8ffff] could no=
t be reserved</div><div>[ =C2=A0 =C2=A00.399163] system 00:04: Plug and Pla=
y ACPI device, IDs PNP0c02 (active)</div><div>[ =C2=A0 =C2=A00.399275] syst=
em 00:05: [mem 0xfec00000-0xfec00fff] could not be reserved</div><div>[ =C2=
=A0 =C2=A00.399337] system 00:05: [mem 0xfee00000-0xfee00fff] has been rese=
rved</div><div>[ =C2=A0 =C2=A00.399397] system 00:05: Plug and Play ACPI de=
vice, IDs PNP0c02 (active)</div><div>[ =C2=A0 =C2=A00.399463] system 00:06:=
 [mem 0xe0000000-0xefffffff] has been reserved</div><div>[ =C2=A0 =C2=A00.3=
99524] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)</div><=
div>[ =C2=A0 =C2=A00.399696] system 00:07: [mem 0x00000000-0x0009ffff] coul=
d not be reserved</div><div>[ =C2=A0 =C2=A00.399758] system 00:07: [mem 0x0=
00c0000-0x000cffff] could not be reserved</div><div>[ =C2=A0 =C2=A00.399819=
] system 00:07: [mem 0x000e0000-0x000fffff] could not be reserved</div><div=
>[ =C2=A0 =C2=A00.399880] system 00:07: [mem 0x00100000-0xbfffffff] could n=
ot be reserved</div><div>[ =C2=A0 =C2=A00.399941] system 00:07: [mem 0xfed9=
0000-0xffffffff] could not be reserved</div><div>[ =C2=A0 =C2=A00.400002] s=
ystem 00:07: Plug and Play ACPI device, IDs PNP0c01 (active)</div><div>[ =
=C2=A0 =C2=A00.400099] pnp: PnP ACPI: found 8 devices</div><div>[ =C2=A0 =
=C2=A00.400154] ACPI: bus type PNP unregistered</div><div>[ =C2=A0 =C2=A00.=
406391] pci 0000:00:1c.0: bridge window [io =C2=A00x1000-0x0fff] to [bus 04=
] add_size 1000</div><div>[ =C2=A0 =C2=A00.406394] pci 0000:00:1c.0: bridge=
 window [mem 0x00100000-0x000fffff 64bit pref] to [bus 04] add_size 200000<=
/div><div>[ =C2=A0 =C2=A00.406396] pci 0000:00:1c.0: bridge window [mem 0x0=
0100000-0x000fffff] to [bus 04] add_size 200000</div><div>[ =C2=A0 =C2=A00.=
406413] pci 0000:00:1f.0: BAR 13: [io =C2=A00x0800-0x087f] has bogus alignm=
ent</div><div>[ =C2=A0 =C2=A00.406476] pci 0000:00:1c.0: res[14]=3D[mem 0x0=
0100000-0x000fffff] get_res_add_size add_size 200000</div><div>[ =C2=A0 =C2=
=A00.406477] pci 0000:00:1c.0: res[15]=3D[mem 0x00100000-0x000fffff 64bit p=
ref] get_res_add_size add_size 200000</div><div>[ =C2=A0 =C2=A00.406479] pc=
i 0000:00:1c.0: res[13]=3D[io =C2=A00x1000-0x0fff] get_res_add_size add_siz=
e 1000</div><div>[ =C2=A0 =C2=A00.406483] pci 0000:00:1c.0: BAR 14: assigne=
d [mem 0xc0000000-0xc01fffff]</div><div>[ =C2=A0 =C2=A00.406546] pci 0000:0=
0:1c.0: BAR 15: assigned [mem 0xc0200000-0xc03fffff 64bit pref]</div><div>[=
 =C2=A0 =C2=A00.406624] pci 0000:00:1c.0: BAR 13: assigned [io =C2=A00x1000=
-0x1fff]</div><div>[ =C2=A0 =C2=A00.406683] pci 0000:00:01.0: PCI bridge to=
 [bus 01]</div><div>[ =C2=A0 =C2=A00.406746] pci 0000:00:03.0: PCI bridge t=
o [bus 02]</div><div>[ =C2=A0 =C2=A00.406804] pci 0000:00:03.0: =C2=A0 brid=
ge window [io =C2=A00xc000-0xcfff]</div><div>[ =C2=A0 =C2=A00.406865] pci 0=
000:00:03.0: =C2=A0 bridge window [mem 0xf8000000-0xfbcfffff]</div><div>[ =
=C2=A0 =C2=A00.406927] pci 0000:00:03.0: =C2=A0 bridge window [mem 0xd00000=
00-0xdfffffff 64bit pref]</div><div>[ =C2=A0 =C2=A00.407005] pci 0000:00:07=
.0: PCI bridge to [bus 03]</div><div>[ =C2=A0 =C2=A00.407068] pci 0000:00:1=
c.0: PCI bridge to [bus 04]</div><div>[ =C2=A0 =C2=A00.407126] pci 0000:00:=
1c.0: =C2=A0 bridge window [io =C2=A00x1000-0x1fff]</div><div>[ =C2=A0 =C2=
=A00.407187] pci 0000:00:1c.0: =C2=A0 bridge window [mem 0xc0000000-0xc01ff=
fff]</div><div>[ =C2=A0 =C2=A00.407248] pci 0000:00:1c.0: =C2=A0 bridge win=
dow [mem 0xc0200000-0xc03fffff 64bit pref]</div><div>[ =C2=A0 =C2=A00.40732=
9] pci 0000:06:00.0: BAR 6: assigned [mem 0xfbe00000-0xfbe1ffff pref]</div>=
<div>[ =C2=A0 =C2=A00.407404] pci 0000:00:1c.4: PCI bridge to [bus 06]</div=
><div>[ =C2=A0 =C2=A00.407462] pci 0000:00:1c.4: =C2=A0 bridge window [io =
=C2=A00xe000-0xefff]</div><div>[ =C2=A0 =C2=A00.407523] pci 0000:00:1c.4: =
=C2=A0 bridge window [mem 0xfbe00000-0xfbefffff]</div><div>[ =C2=A0 =C2=A00=
.407585] pci 0000:00:1c.4: =C2=A0 bridge window [mem 0xf6f00000-0xf6ffffff =
64bit pref]</div><div>[ =C2=A0 =C2=A00.407664] pci 0000:00:1e.0: PCI bridge=
 to [bus 07]</div><div>[ =C2=A0 =C2=A00.407728] pci_bus 0000:00: resource 4=
 [io =C2=A00x0000-0x0cf7]</div><div>[ =C2=A0 =C2=A00.407730] pci_bus 0000:0=
0: resource 5 [io =C2=A00x0d00-0xffff]</div><div>[ =C2=A0 =C2=A00.407731] p=
ci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]</div><div>[ =C2=A0 =
=C2=A00.407733] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff]</di=
v><div>[ =C2=A0 =C2=A00.407734] pci_bus 0000:00: resource 8 [mem 0xc0000000=
-0xdfffffff]</div><div>[ =C2=A0 =C2=A00.407736] pci_bus 0000:00: resource 9=
 [mem 0xf0000000-0xfed8ffff]</div><div>[ =C2=A0 =C2=A00.407737] pci_bus 000=
0:02: resource 0 [io =C2=A00xc000-0xcfff]</div><div>[ =C2=A0 =C2=A00.407739=
] pci_bus 0000:02: resource 1 [mem 0xf8000000-0xfbcfffff]</div><div>[ =C2=
=A0 =C2=A00.407740] pci_bus 0000:02: resource 2 [mem 0xd0000000-0xdfffffff =
64bit pref]</div><div>[ =C2=A0 =C2=A00.407742] pci_bus 0000:04: resource 0 =
[io =C2=A00x1000-0x1fff]</div><div>[ =C2=A0 =C2=A00.407743] pci_bus 0000:04=
: resource 1 [mem 0xc0000000-0xc01fffff]</div><div>[ =C2=A0 =C2=A00.407745]=
 pci_bus 0000:04: resource 2 [mem 0xc0200000-0xc03fffff 64bit pref]</div><d=
iv>[ =C2=A0 =C2=A00.407746] pci_bus 0000:06: resource 0 [io =C2=A00xe000-0x=
efff]</div><div>[ =C2=A0 =C2=A00.407747] pci_bus 0000:06: resource 1 [mem 0=
xfbe00000-0xfbefffff]</div><div>[ =C2=A0 =C2=A00.407749] pci_bus 0000:06: r=
esource 2 [mem 0xf6f00000-0xf6ffffff 64bit pref]</div><div>[ =C2=A0 =C2=A00=
.407750] pci_bus 0000:07: resource 4 [io =C2=A00x0000-0x0cf7]</div><div>[ =
=C2=A0 =C2=A00.407752] pci_bus 0000:07: resource 5 [io =C2=A00x0d00-0xffff]=
</div><div>[ =C2=A0 =C2=A00.407753] pci_bus 0000:07: resource 6 [mem 0x000a=
0000-0x000bffff]</div><div>[ =C2=A0 =C2=A00.407755] pci_bus 0000:07: resour=
ce 7 [mem 0x000d0000-0x000dffff]</div><div>[ =C2=A0 =C2=A00.407756] pci_bus=
 0000:07: resource 8 [mem 0xc0000000-0xdfffffff]</div><div>[ =C2=A0 =C2=A00=
.407757] pci_bus 0000:07: resource 9 [mem 0xf0000000-0xfed8ffff]</div><div>=
[ =C2=A0 =C2=A00.407760] pci_bus 0000:ff: resource 4 [io =C2=A00x0000-0xfff=
f]</div><div>[ =C2=A0 =C2=A00.407761] pci_bus 0000:ff: resource 5 [mem 0x00=
000000-0xfffffffff]</div><div>[ =C2=A0 =C2=A00.407843] NET: Registered prot=
ocol family 2</div><div>[ =C2=A0 =C2=A00.408337] TCP established hash table=
 entries: 524288 (order: 10, 4194304 bytes)</div><div>[ =C2=A0 =C2=A00.4092=
61] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)</div><div>=
[ =C2=A0 =C2=A00.409451] TCP: Hash tables configured (established 524288 bi=
nd 65536)</div><div>[ =C2=A0 =C2=A00.409528] TCP: reno registered</div><div=
>[ =C2=A0 =C2=A00.409633] UDP hash table entries: 32768 (order: 8, 1048576 =
bytes)</div><div>[ =C2=A0 =C2=A00.409902] UDP-Lite hash table entries: 3276=
8 (order: 8, 1048576 bytes)</div><div>[ =C2=A0 =C2=A00.410216] NET: Registe=
red protocol family 1</div><div>[ =C2=A0 =C2=A00.411759] pci 0000:02:00.0: =
Video device with shadowed ROM</div><div>[ =C2=A0 =C2=A00.411782] PCI: CLS =
256 bytes, default 64</div><div>[ =C2=A0 =C2=A00.411826] Unpacking initramf=
s...</div><div>[ =C2=A0 =C2=A00.685150] Freeing initrd memory: 16808K (ffff=
880035f1c000 - ffff880036f86000)</div><div>[ =C2=A0 =C2=A00.685245] PCI-DMA=
: Using software bounce buffering for IO (SWIOTLB)</div><div>[ =C2=A0 =C2=
=A00.685306] software IO TLB [mem 0xbb780000-0xbf780000] (64MB) mapped at [=
ffff8800bb780000-ffff8800bf77ffff]</div><div>[ =C2=A0 =C2=A00.685726] micro=
code: CPU0 sig=3D0x106a5, pf=3D0x2, revision=3D0x11</div><div>[ =C2=A0 =C2=
=A00.685789] microcode: CPU1 sig=3D0x106a5, pf=3D0x2, revision=3D0x11</div>=
<div>[ =C2=A0 =C2=A00.685853] microcode: CPU2 sig=3D0x106a5, pf=3D0x2, revi=
sion=3D0x11</div><div>[ =C2=A0 =C2=A00.685917] microcode: CPU3 sig=3D0x106a=
5, pf=3D0x2, revision=3D0x11</div><div>[ =C2=A0 =C2=A00.685981] microcode: =
CPU4 sig=3D0x106a5, pf=3D0x2, revision=3D0x11</div><div>[ =C2=A0 =C2=A00.68=
6045] microcode: CPU5 sig=3D0x106a5, pf=3D0x2, revision=3D0x11</div><div>[ =
=C2=A0 =C2=A00.686107] microcode: CPU6 sig=3D0x106a5, pf=3D0x2, revision=3D=
0x11</div><div>[ =C2=A0 =C2=A00.686170] microcode: CPU7 sig=3D0x106a5, pf=
=3D0x2, revision=3D0x11</div><div>[ =C2=A0 =C2=A00.686274] microcode: Micro=
code Update Driver: v2.00 &lt;<a href=3D"mailto:tigran@aivazian.fsnet.co.uk=
">tigran@aivazian.fsnet.co.uk</a>&gt;, Peter Oruba</div><div>[ =C2=A0 =C2=
=A00.686695] futex hash table entries: 4096 (order: 6, 262144 bytes)</div><=
div>[ =C2=A0 =C2=A00.686814] audit: initializing netlink subsys (disabled)<=
/div><div>[ =C2=A0 =C2=A00.686887] audit: type=3D2000 audit(1442052872.568:=
1): initialized</div><div>[ =C2=A0 =C2=A00.687275] HugeTLB registered 2 MB =
page size, pre-allocated 0 pages</div><div>[ =C2=A0 =C2=A00.687353] zbud: l=
oaded</div><div>[ =C2=A0 =C2=A00.688318] VFS: Disk quotas dquot_6.5.2</div>=
<div>[ =C2=A0 =C2=A00.688394] Dquot-cache hash table entries: 512 (order 0,=
 4096 bytes)</div><div>[ =C2=A0 =C2=A00.688509] msgmni has been set to 3276=
8</div><div>[ =C2=A0 =C2=A00.688841] alg: No test for stdrng (krng)</div><d=
iv>[ =C2=A0 =C2=A00.688922] Block layer SCSI generic (bsg) driver version 0=
.4 loaded (major 252)</div><div>[ =C2=A0 =C2=A00.689048] io scheduler noop =
registered</div><div>[ =C2=A0 =C2=A00.689103] io scheduler deadline registe=
red</div><div>[ =C2=A0 =C2=A00.689199] io scheduler cfq registered (default=
)</div><div>[ =C2=A0 =C2=A00.689444] pcieport 0000:00:1c.0: enabling device=
 (0104 -&gt; 0107)</div><div>[ =C2=A0 =C2=A00.689637] pcieport 0000:00:1c.0=
: irq 40 for MSI/MSI-X</div><div>[ =C2=A0 =C2=A00.689798] pcieport 0000:00:=
1c.4: irq 41 for MSI/MSI-X</div><div>[ =C2=A0 =C2=A00.689881] pci_hotplug: =
PCI Hot Plug PCI Core version: 0.5</div><div>[ =C2=A0 =C2=A00.689952] pcieh=
p: PCI Express Hot Plug Controller Driver version: 0.4</div><div>[ =C2=A0 =
=C2=A00.690027] intel_idle: MWAIT substates: 0x1120</div><div>[ =C2=A0 =C2=
=A00.690037] intel_idle: v0.4 model 0x1A</div><div>[ =C2=A0 =C2=A00.690038]=
 intel_idle: lapic_timer_reliable_states 0x2</div><div>[ =C2=A0 =C2=A00.690=
338] GHES: HEST is not enabled!</div><div>[ =C2=A0 =C2=A00.690456] Serial: =
8250/16550 driver, 4 ports, IRQ sharing enabled</div><div>[ =C2=A0 =C2=A00.=
690896] Linux agpgart interface v0.103</div><div>[ =C2=A0 =C2=A00.691074] i=
8042: PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1</div><div>[ =
=C2=A0 =C2=A00.691135] i8042: PNP: PS/2 appears to have AUX port disabled, =
if this is incorrect please boot with i8042.nopnp</div><div>[ =C2=A0 =C2=A0=
0.691907] serio: i8042 KBD port at 0x60,0x64 irq 1</div><div>[ =C2=A0 =C2=
=A00.692060] mousedev: PS/2 mouse device common for all mice</div><div>[ =
=C2=A0 =C2=A00.692158] rtc_cmos 00:01: RTC can wake from S4</div><div>[ =C2=
=A0 =C2=A00.692328] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0</=
div><div>[ =C2=A0 =C2=A00.692410] rtc_cmos 00:01: alarms up to one month, y=
3k, 114 bytes nvram, hpet irqs</div><div>[ =C2=A0 =C2=A00.692499] ledtrig-c=
pu: registered to indicate activity on CPUs</div><div>[ =C2=A0 =C2=A00.6927=
84] AMD IOMMUv2 driver by Joerg Roedel &lt;<a href=3D"mailto:joerg.roedel@a=
md.com">joerg.roedel@amd.com</a>&gt;</div><div>[ =C2=A0 =C2=A00.692844] AMD=
 IOMMUv2 functionality not available on this system</div><div>[ =C2=A0 =C2=
=A00.692977] TCP: cubic registered</div><div>[ =C2=A0 =C2=A00.693152] NET: =
Registered protocol family 10</div><div>[ =C2=A0 =C2=A00.693442] mip6: Mobi=
le IPv6</div><div>[ =C2=A0 =C2=A00.693497] NET: Registered protocol family =
17</div><div>[ =C2=A0 =C2=A00.693556] mpls_gso: MPLS GSO support</div><div>=
[ =C2=A0 =C2=A00.693942] registered taskstats version 1</div><div>[ =C2=A0 =
=C2=A00.694481] rtc_cmos 00:01: setting system clock to 2015-09-12 10:14:33=
 UTC (1442052873)</div><div>[ =C2=A0 =C2=A00.694603] PM: Hibernation image =
not present or could not be loaded.</div><div>[ =C2=A0 =C2=A00.695367] Free=
ing unused kernel memory: 1204K (ffffffff818ee000 - ffffffff81a1b000)</div>=
<div>[ =C2=A0 =C2=A00.695444] Write protecting the kernel read-only data: 8=
192k</div><div>[ =C2=A0 =C2=A00.698179] Freeing unused kernel memory: 924K =
(ffff880001519000 - ffff880001600000)</div><div>[ =C2=A0 =C2=A00.699167] Fr=
eeing unused kernel memory: 216K (ffff8800017ca000 - ffff880001800000)</div=
><div>[ =C2=A0 =C2=A00.709484] systemd-udevd[96]: starting version 215</div=
><div>[ =C2=A0 =C2=A00.709760] random: systemd-udevd urandom read with 1 bi=
ts of entropy available</div><div>[ =C2=A0 =C2=A00.724390] r8169 Gigabit Et=
hernet driver 2.3LK-NAPI loaded</div><div>[ =C2=A0 =C2=A00.724460] r8169 00=
00:06:00.0: can&#39;t disable ASPM; OS doesn&#39;t have ASPM control</div><=
div>[ =C2=A0 =C2=A00.724757] r8169 0000:06:00.0: irq 42 for MSI/MSI-X</div>=
<div>[ =C2=A0 =C2=A00.724782] ACPI: bus type USB registered</div><div>[ =C2=
=A0 =C2=A00.724874] usbcore: registered new interface driver usbfs</div><di=
v>[ =C2=A0 =C2=A00.724918] r8169 0000:06:00.0 eth0: RTL8168c/8111c at 0xfff=
fc90000008000, 6c:62:6d:60:73:4d, XID 1c4000c0 IRQ 42</div><div>[ =C2=A0 =
=C2=A00.724919] r8169 0000:06:00.0 eth0: jumbo features [frames: 6128 bytes=
, tx checksumming: ko]</div><div>[ =C2=A0 =C2=A00.725116] usbcore: register=
ed new interface driver hub</div><div>[ =C2=A0 =C2=A00.725328] usbcore: reg=
istered new device driver usb</div><div>[ =C2=A0 =C2=A00.725592] SCSI subsy=
stem initialized</div><div>[ =C2=A0 =C2=A00.725958] ehci_hcd: USB 2.0 &#39;=
Enhanced&#39; Host Controller (EHCI) Driver</div><div>[ =C2=A0 =C2=A00.7263=
83] ehci-pci: EHCI PCI platform driver</div><div>[ =C2=A0 =C2=A00.726597] e=
hci-pci 0000:00:1a.7: EHCI Host Controller</div><div>[ =C2=A0 =C2=A00.72662=
6] uhci_hcd: USB Universal Host Controller Interface driver</div><div>[ =C2=
=A0 =C2=A00.726727] ehci-pci 0000:00:1a.7: new USB bus registered, assigned=
 bus number 1</div><div>[ =C2=A0 =C2=A00.726817] ehci-pci 0000:00:1a.7: deb=
ug port 1</div><div>[ =C2=A0 =C2=A00.727413] libata version 3.00 loaded.</d=
iv><div>[ =C2=A0 =C2=A00.730767] ehci-pci 0000:00:1a.7: cache line size of =
256 is not supported</div><div>[ =C2=A0 =C2=A00.730783] ehci-pci 0000:00:1a=
.7: irq 18, io mem 0xf7ffe000</div><div>[ =C2=A0 =C2=A00.740766] ehci-pci 0=
000:00:1a.7: USB 2.0 started, EHCI 1.00</div><div>[ =C2=A0 =C2=A00.740878] =
usb usb1: New USB device found, idVendor=3D1d6b, idProduct=3D0002</div><div=
>[ =C2=A0 =C2=A00.740943] usb usb1: New USB device strings: Mfr=3D3, Produc=
t=3D2, SerialNumber=3D1</div><div>[ =C2=A0 =C2=A00.741022] usb usb1: Produc=
t: EHCI Host Controller</div><div>[ =C2=A0 =C2=A00.741083] usb usb1: Manufa=
cturer: Linux 3.16.0-4-amd64 ehci_hcd</div><div>[ =C2=A0 =C2=A00.741144] us=
b usb1: SerialNumber: 0000:00:1a.7</div><div>[ =C2=A0 =C2=A00.741330] hub 1=
-0:1.0: USB hub found</div><div>[ =C2=A0 =C2=A00.741396] hub 1-0:1.0: 6 por=
ts detected</div><div>[ =C2=A0 =C2=A00.741755] ehci-pci 0000:00:1d.7: EHCI =
Host Controller</div><div>[ =C2=A0 =C2=A00.741822] ehci-pci 0000:00:1d.7: n=
ew USB bus registered, assigned bus number 2</div><div>[ =C2=A0 =C2=A00.741=
913] ehci-pci 0000:00:1d.7: debug port 1</div><div>[ =C2=A0 =C2=A00.745880]=
 ehci-pci 0000:00:1d.7: cache line size of 256 is not supported</div><div>[=
 =C2=A0 =C2=A00.745895] ehci-pci 0000:00:1d.7: irq 23, io mem 0xf7ffc000</d=
iv><div>[ =C2=A0 =C2=A00.749975] input: AT Translated Set 2 keyboard as /de=
vices/platform/i8042/serio0/input/input0</div><div>[ =C2=A0 =C2=A00.756763]=
 ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00</div><div>[ =C2=A0 =C2=
=A00.756846] usb usb2: New USB device found, idVendor=3D1d6b, idProduct=3D0=
002</div><div>[ =C2=A0 =C2=A00.756906] usb usb2: New USB device strings: Mf=
r=3D3, Product=3D2, SerialNumber=3D1</div><div>[ =C2=A0 =C2=A00.756982] usb=
 usb2: Product: EHCI Host Controller</div><div>[ =C2=A0 =C2=A00.757038] usb=
 usb2: Manufacturer: Linux 3.16.0-4-amd64 ehci_hcd</div><div>[ =C2=A0 =C2=
=A00.757097] usb usb2: SerialNumber: 0000:00:1d.7</div><div>[ =C2=A0 =C2=A0=
0.757287] hub 2-0:1.0: USB hub found</div><div>[ =C2=A0 =C2=A00.757347] hub=
 2-0:1.0: 6 ports detected</div><div>[ =C2=A0 =C2=A00.757738] uhci_hcd 0000=
:00:1a.0: UHCI Host Controller</div><div>[ =C2=A0 =C2=A00.757803] uhci_hcd =
0000:00:1a.0: new USB bus registered, assigned bus number 3</div><div>[ =C2=
=A0 =C2=A00.757888] uhci_hcd 0000:00:1a.0: detected 2 ports</div><div>[ =C2=
=A0 =C2=A00.757977] uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000bc00</div>=
<div>[ =C2=A0 =C2=A00.758101] usb usb3: New USB device found, idVendor=3D1d=
6b, idProduct=3D0001</div><div>[ =C2=A0 =C2=A00.758164] usb usb3: New USB d=
evice strings: Mfr=3D3, Product=3D2, SerialNumber=3D1</div><div>[ =C2=A0 =
=C2=A00.758240] usb usb3: Product: UHCI Host Controller</div><div>[ =C2=A0 =
=C2=A00.758297] usb usb3: Manufacturer: Linux 3.16.0-4-amd64 uhci_hcd</div>=
<div>[ =C2=A0 =C2=A00.758355] usb usb3: SerialNumber: 0000:00:1a.0</div><di=
v>[ =C2=A0 =C2=A00.758626] hub 3-0:1.0: USB hub found</div><div>[ =C2=A0 =
=C2=A00.758685] hub 3-0:1.0: 2 ports detected</div><div>[ =C2=A0 =C2=A00.75=
8911] uhci_hcd 0000:00:1a.1: UHCI Host Controller</div><div>[ =C2=A0 =C2=A0=
0.758972] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus numbe=
r 4</div><div>[ =C2=A0 =C2=A00.759051] uhci_hcd 0000:00:1a.1: detected 2 po=
rts</div><div>[ =C2=A0 =C2=A00.759131] uhci_hcd 0000:00:1a.1: irq 21, io ba=
se 0x0000b880</div><div>[ =C2=A0 =C2=A00.759224] usb usb4: New USB device f=
ound, idVendor=3D1d6b, idProduct=3D0001</div><div>[ =C2=A0 =C2=A00.759285] =
usb usb4: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1</d=
iv><div>[ =C2=A0 =C2=A00.759360] usb usb4: Product: UHCI Host Controller</d=
iv><div>[ =C2=A0 =C2=A00.759417] usb usb4: Manufacturer: Linux 3.16.0-4-amd=
64 uhci_hcd</div><div>[ =C2=A0 =C2=A00.759476] usb usb4: SerialNumber: 0000=
:00:1a.1</div><div>[ =C2=A0 =C2=A00.759737] hub 4-0:1.0: USB hub found</div=
><div>[ =C2=A0 =C2=A00.759796] hub 4-0:1.0: 2 ports detected</div><div>[ =
=C2=A0 =C2=A00.760015] uhci_hcd 0000:00:1a.2: UHCI Host Controller</div><di=
v>[ =C2=A0 =C2=A00.760076] uhci_hcd 0000:00:1a.2: new USB bus registered, a=
ssigned bus number 5</div><div>[ =C2=A0 =C2=A00.760156] uhci_hcd 0000:00:1a=
.2: detected 2 ports</div><div>[ =C2=A0 =C2=A00.760236] uhci_hcd 0000:00:1a=
.2: irq 19, io base 0x0000b800</div><div>[ =C2=A0 =C2=A00.760327] usb usb5:=
 New USB device found, idVendor=3D1d6b, idProduct=3D0001</div><div>[ =C2=A0=
 =C2=A00.760388] usb usb5: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1</div><div>[ =C2=A0 =C2=A00.760463] usb usb5: Product: UHCI H=
ost Controller</div><div>[ =C2=A0 =C2=A00.760519] usb usb5: Manufacturer: L=
inux 3.16.0-4-amd64 uhci_hcd</div><div>[ =C2=A0 =C2=A00.760578] usb usb5: S=
erialNumber: 0000:00:1a.2</div><div>[ =C2=A0 =C2=A00.760787] hub 5-0:1.0: U=
SB hub found</div><div>[ =C2=A0 =C2=A00.760846] hub 5-0:1.0: 2 ports detect=
ed</div><div>[ =C2=A0 =C2=A00.761063] uhci_hcd 0000:00:1d.0: UHCI Host Cont=
roller</div><div>[ =C2=A0 =C2=A00.761124] uhci_hcd 0000:00:1d.0: new USB bu=
s registered, assigned bus number 6</div><div>[ =C2=A0 =C2=A00.761204] uhci=
_hcd 0000:00:1d.0: detected 2 ports</div><div>[ =C2=A0 =C2=A00.761276] uhci=
_hcd 0000:00:1d.0: irq 23, io base 0x0000b480</div><div>[ =C2=A0 =C2=A00.76=
1367] usb usb6: New USB device found, idVendor=3D1d6b, idProduct=3D0001</di=
v><div>[ =C2=A0 =C2=A00.761428] usb usb6: New USB device strings: Mfr=3D3, =
Product=3D2, SerialNumber=3D1</div><div>[ =C2=A0 =C2=A00.761503] usb usb6: =
Product: UHCI Host Controller</div><div>[ =C2=A0 =C2=A00.761560] usb usb6: =
Manufacturer: Linux 3.16.0-4-amd64 uhci_hcd</div><div>[ =C2=A0 =C2=A00.7616=
19] usb usb6: SerialNumber: 0000:00:1d.0</div><div>[ =C2=A0 =C2=A00.761870]=
 hub 6-0:1.0: USB hub found</div><div>[ =C2=A0 =C2=A00.761929] hub 6-0:1.0:=
 2 ports detected</div><div>[ =C2=A0 =C2=A00.762149] uhci_hcd 0000:00:1d.1:=
 UHCI Host Controller</div><div>[ =C2=A0 =C2=A00.762210] uhci_hcd 0000:00:1=
d.1: new USB bus registered, assigned bus number 7</div><div>[ =C2=A0 =C2=
=A00.762290] uhci_hcd 0000:00:1d.1: detected 2 ports</div><div>[ =C2=A0 =C2=
=A00.762362] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000b400</div><div>[ =
=C2=A0 =C2=A00.762455] usb usb7: New USB device found, idVendor=3D1d6b, idP=
roduct=3D0001</div><div>[ =C2=A0 =C2=A00.762516] usb usb7: New USB device s=
trings: Mfr=3D3, Product=3D2, SerialNumber=3D1</div><div>[ =C2=A0 =C2=A00.7=
62591] usb usb7: Product: UHCI Host Controller</div><div>[ =C2=A0 =C2=A00.7=
62648] usb usb7: Manufacturer: Linux 3.16.0-4-amd64 uhci_hcd</div><div>[ =
=C2=A0 =C2=A00.762707] usb usb7: SerialNumber: 0000:00:1d.1</div><div>[ =C2=
=A0 =C2=A00.762948] hub 7-0:1.0: USB hub found</div><div>[ =C2=A0 =C2=A00.7=
63007] hub 7-0:1.0: 2 ports detected</div><div>[ =C2=A0 =C2=A00.763227] uhc=
i_hcd 0000:00:1d.2: UHCI Host Controller</div><div>[ =C2=A0 =C2=A00.763288]=
 uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8</div>=
<div>[ =C2=A0 =C2=A00.763368] uhci_hcd 0000:00:1d.2: detected 2 ports</div>=
<div>[ =C2=A0 =C2=A00.763440] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000=
b080</div><div>[ =C2=A0 =C2=A00.763533] usb usb8: New USB device found, idV=
endor=3D1d6b, idProduct=3D0001</div><div>[ =C2=A0 =C2=A00.763593] usb usb8:=
 New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1</div><div>[=
 =C2=A0 =C2=A00.763669] usb usb8: Product: UHCI Host Controller</div><div>[=
 =C2=A0 =C2=A00.763726] usb usb8: Manufacturer: Linux 3.16.0-4-amd64 uhci_h=
cd</div><div>[ =C2=A0 =C2=A00.763785] usb usb8: SerialNumber: 0000:00:1d.2<=
/div><div>[ =C2=A0 =C2=A00.764030] hub 8-0:1.0: USB hub found</div><div>[ =
=C2=A0 =C2=A00.764090] hub 8-0:1.0: 2 ports detected</div><div>[ =C2=A0 =C2=
=A00.764283] ahci 0000:00:1f.2: version 3.0</div><div>[ =C2=A0 =C2=A00.7644=
27] ahci 0000:00:1f.2: irq 43 for MSI/MSI-X</div><div>[ =C2=A0 =C2=A00.7644=
52] ahci 0000:00:1f.2: SSS flag set, parallel bus scan disabled</div><div>[=
 =C2=A0 =C2=A00.764550] ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports =
3 Gbps 0x3f impl SATA mode</div><div>[ =C2=A0 =C2=A00.764632] ahci 0000:00:=
1f.2: flags: 64bit ncq sntf stag pm led clo pio slum part ccc ems sxs=C2=A0=
</div><div>[ =C2=A0 =C2=A00.809712] scsi0 : ahci</div><div>[ =C2=A0 =C2=A00=
.810781] scsi1 : ahci</div><div>[ =C2=A0 =C2=A00.811193] scsi2 : ahci</div>=
<div>[ =C2=A0 =C2=A00.811533] scsi3 : ahci</div><div>[ =C2=A0 =C2=A00.81192=
8] scsi4 : ahci</div><div>[ =C2=A0 =C2=A00.812344] scsi5 : ahci</div><div>[=
 =C2=A0 =C2=A00.813152] ata1: SATA max UDMA/133 abar m2048@0xf7ffa000 port =
0xf7ffa100 irq 43</div><div>[ =C2=A0 =C2=A00.813229] ata2: SATA max UDMA/13=
3 abar m2048@0xf7ffa000 port 0xf7ffa180 irq 43</div><div>[ =C2=A0 =C2=A00.8=
13306] ata3: SATA max UDMA/133 abar m2048@0xf7ffa000 port 0xf7ffa200 irq 43=
</div><div>[ =C2=A0 =C2=A00.813382] ata4: SATA max UDMA/133 abar m2048@0xf7=
ffa000 port 0xf7ffa280 irq 43</div><div>[ =C2=A0 =C2=A00.813458] ata5: SATA=
 max UDMA/133 abar m2048@0xf7ffa000 port 0xf7ffa300 irq 43</div><div>[ =C2=
=A0 =C2=A00.813533] ata6: SATA max UDMA/133 abar m2048@0xf7ffa000 port 0xf7=
ffa380 irq 43</div><div>[ =C2=A0 =C2=A01.133104] ata1: SATA link up 3.0 Gbp=
s (SStatus 123 SControl 300)</div><div>[ =C2=A0 =C2=A01.134220] ata1.00: AT=
A-8: WDC WD2000FYYZ-01UL1B1, 01.01K02, max UDMA/133</div><div>[ =C2=A0 =C2=
=A01.134289] ata1.00: 3907029168 sectors, multi 0: LBA48 NCQ (depth 31/32),=
 AA</div><div>[ =C2=A0 =C2=A01.135778] ata1.00: configured for UDMA/133</di=
v><div>[ =C2=A0 =C2=A01.136153] scsi 0:0:0:0: Direct-Access =C2=A0 =C2=A0 A=
TA =C2=A0 =C2=A0 =C2=A0WDC WD2000FYYZ-0 1K02 PQ: 0 ANSI: 5</div><div>[ =C2=
=A0 =C2=A01.453273] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)<=
/div><div>[ =C2=A0 =C2=A01.454361] ata2.00: ATA-8: WDC WD2000FYYZ-01UL1B1, =
01.01K02, max UDMA/133</div><div>[ =C2=A0 =C2=A01.454429] ata2.00: 39070291=
68 sectors, multi 0: LBA48 NCQ (depth 31/32), AA</div><div>[ =C2=A0 =C2=A01=
.455992] ata2.00: configured for UDMA/133</div><div>[ =C2=A0 =C2=A01.456328=
] scsi 1:0:0:0: Direct-Access =C2=A0 =C2=A0 ATA =C2=A0 =C2=A0 =C2=A0WDC WD2=
000FYYZ-0 1K02 PQ: 0 ANSI: 5</div><div>[ =C2=A0 =C2=A01.685330] tsc: Refine=
d TSC clocksource calibration: 2806.964 MHz</div><div>[ =C2=A0 =C2=A01.7774=
41] ata3: SATA link down (SStatus 0 SControl 300)</div><div>[ =C2=A0 =C2=A0=
2.097612] ata4: SATA link down (SStatus 0 SControl 300)</div><div>[ =C2=A0 =
=C2=A02.417777] ata5: SATA link down (SStatus 0 SControl 300)</div><div>[ =
=C2=A0 =C2=A02.686208] Switched to clocksource tsc</div><div>[ =C2=A0 =C2=
=A02.737980] ata6: SATA link down (SStatus 0 SControl 300)</div><div>[ =C2=
=A0 =C2=A02.771037] sd 0:0:0:0: [sda] 3907029168 512-byte logical blocks: (=
2.00 TB/1.81 TiB)</div><div>[ =C2=A0 =C2=A02.771051] sd 1:0:0:0: [sdb] 3907=
029168 512-byte logical blocks: (2.00 TB/1.81 TiB)</div><div>[ =C2=A0 =C2=
=A02.771074] sd 1:0:0:0: [sdb] Write Protect is off</div><div>[ =C2=A0 =C2=
=A02.771075] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00</div><div>[ =C2=A0 =
=C2=A02.771085] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled=
, doesn&#39;t support DPO or FUA</div><div>[ =C2=A0 =C2=A02.771348] sd 0:0:=
0:0: [sda] Write Protect is off</div><div>[ =C2=A0 =C2=A02.771405] sd 0:0:0=
:0: [sda] Mode Sense: 00 3a 00 00</div><div>[ =C2=A0 =C2=A02.771416] sd 0:0=
:0:0: [sda] Write cache: enabled, read cache: enabled, doesn&#39;t support =
DPO or FUA</div><div>[ =C2=A0 =C2=A02.780668] =C2=A0sda: sda1 sda2 sda3</di=
v><div>[ =C2=A0 =C2=A02.780917] sd 0:0:0:0: [sda] Attached SCSI disk</div><=
div>[ =C2=A0 =C2=A02.782276] sd 0:0:0:0: Attached scsi generic sg0 type 0</=
div><div>[ =C2=A0 =C2=A02.782367] sd 1:0:0:0: Attached scsi generic sg1 typ=
e 0</div><div>[ =C2=A0 =C2=A02.790178] =C2=A0sdb: sdb1 sdb2 sdb3</div><div>=
[ =C2=A0 =C2=A02.790432] sd 1:0:0:0: [sdb] Attached SCSI disk</div><div>[ =
=C2=A0 =C2=A02.925798] md: bind&lt;sdb2&gt;</div><div>[ =C2=A0 =C2=A02.9299=
91] md: bind&lt;sda3&gt;</div><div>[ =C2=A0 =C2=A02.930650] md: bind&lt;sda=
1&gt;</div><div>[ =C2=A0 =C2=A02.931388] md: bind&lt;sdb1&gt;</div><div>[ =
=C2=A0 =C2=A02.934077] md: raid1 personality registered for level 1</div><d=
iv>[ =C2=A0 =C2=A02.935011] md/raid1:md0: active with 2 out of 2 mirrors</d=
iv><div>[ =C2=A0 =C2=A02.935109] md0: detected capacity change from 0 to 25=
752895488</div><div>[ =C2=A0 =C2=A02.942184] md: bind&lt;sda2&gt;</div><div=
>[ =C2=A0 =C2=A02.943774] md/raid1:md1: active with 2 out of 2 mirrors</div=
><div>[ =C2=A0 =C2=A02.943867] md1: detected capacity change from 0 to 5365=
43232</div><div>[ =C2=A0 =C2=A02.944257] =C2=A0md1: unknown partition table=
</div><div>[ =C2=A0 =C2=A02.945848] =C2=A0md0: unknown partition table</div=
><div>[ =C2=A0 =C2=A02.990152] md: bind&lt;sdb3&gt;</div><div>[ =C2=A0 =C2=
=A02.993032] md/raid1:md2: not clean -- starting background reconstruction<=
/div><div>[ =C2=A0 =C2=A02.993099] md/raid1:md2: active with 2 out of 2 mir=
rors</div><div>[ =C2=A0 =C2=A02.993180] md2: detected capacity change from =
0 to 1973953691648</div><div>[ =C2=A0 =C2=A03.001503] =C2=A0md2: unknown pa=
rtition table</div><div>[ =C2=A0 =C2=A03.066972] device-mapper: uevent: ver=
sion 1.0.3</div><div>[ =C2=A0 =C2=A03.067131] device-mapper: ioctl: 4.27.0-=
ioctl (2013-10-30) initialised: <a href=3D"mailto:dm-devel@redhat.com">dm-d=
evel@redhat.com</a></div><div>[ =C2=A0 =C2=A03.138013] raid6: sse2x1 =C2=A0=
 =C2=A06911 MB/s</div><div>[ =C2=A0 =C2=A03.206046] raid6: sse2x2 =C2=A0 =
=C2=A08146 MB/s</div><div>[ =C2=A0 =C2=A03.274085] raid6: sse2x4 =C2=A0 =C2=
=A09066 MB/s</div><div>[ =C2=A0 =C2=A03.274189] raid6: using algorithm sse2=
x4 (9066 MB/s)</div><div>[ =C2=A0 =C2=A03.274247] raid6: using ssse3x2 reco=
very algorithm</div><div>[ =C2=A0 =C2=A03.276368] xor: measuring software c=
hecksum speed</div><div>[ =C2=A0 =C2=A03.314102] =C2=A0 =C2=A0prefetch64-ss=
e: 11488.000 MB/sec</div><div>[ =C2=A0 =C2=A03.354123] =C2=A0 =C2=A0generic=
_sse: 10139.000 MB/sec</div><div>[ =C2=A0 =C2=A03.354228] xor: using functi=
on: prefetch64-sse (11488.000 MB/sec)</div><div>[ =C2=A0 =C2=A03.359057] Bt=
rfs loaded</div><div>[ =C2=A0 =C2=A03.528899] PM: Starting manual resume fr=
om disk</div><div>[ =C2=A0 =C2=A03.528958] PM: Hibernation image partition =
9:0 present</div><div>[ =C2=A0 =C2=A03.528960] PM: Looking for hibernation =
image.</div><div>[ =C2=A0 =C2=A03.529057] PM: Image not found (code -22)</d=
iv><div>[ =C2=A0 =C2=A03.529060] PM: Hibernation image not present or could=
 not be loaded.</div><div>[ =C2=A0 =C2=A03.637328] md: resync of RAID array=
 md2</div><div>[ =C2=A0 =C2=A03.637390] md: minimum _guaranteed_ =C2=A0spee=
d: 1000 KB/sec/disk.</div><div>[ =C2=A0 =C2=A03.637452] md: using maximum a=
vailable idle IO bandwidth (but not more than 200000 KB/sec) for resync.</d=
iv><div>[ =C2=A0 =C2=A03.637537] md: using 128k window, over a total of 192=
7689152k.</div><div>[ =C2=A0 =C2=A03.637595] md: resuming resync of md2 fro=
m checkpoint.</div><div>[ =C2=A0 =C2=A03.676739] random: nonblocking pool i=
s initialized</div><div>[ =C2=A0 =C2=A03.741318] EXT4-fs (md2): mounted fil=
esystem with ordered data mode. Opts: (null)</div><div>[ =C2=A0 =C2=A04.184=
259] systemd[1]: systemd 215 running in system mode. (+PAM +AUDIT +SELINUX =
+IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +XZ -SECCOMP -APPARMOR)</div><di=
v>[ =C2=A0 =C2=A04.184507] systemd[1]: Detected architecture &#39;x86-64&#3=
9;.</div><div>[ =C2=A0 =C2=A04.308631] systemd[1]: Inserted module &#39;aut=
ofs4&#39;</div><div>[ =C2=A0 =C2=A04.316048] systemd[1]: Set hostname to &l=
t;Debian-81-jessie-64-minimal&gt;.</div><div>[ =C2=A0 =C2=A04.324893] syste=
md[1]: Initializing machine ID from random generator.</div><div>[ =C2=A0 =
=C2=A04.324996] systemd[1]: Installed transient /etc/machine-id file.</div>=
<div>[ =C2=A0 =C2=A04.713240] systemd[1]: Cannot add dependency job for uni=
t display-manager.service, ignoring: Unit display-manager.service failed to=
 load: No such file or directory.</div><div>[ =C2=A0 =C2=A04.713586] system=
d[1]: Starting Forward Password Requests to Wall Directory Watch.</div><div=
>[ =C2=A0 =C2=A04.713707] systemd[1]: Started Forward Password Requests to =
Wall Directory Watch.</div><div>[ =C2=A0 =C2=A04.713791] systemd[1]: Starti=
ng Remote File Systems (Pre).</div><div>[ =C2=A0 =C2=A04.714126] systemd[1]=
: Reached target Remote File Systems (Pre).</div><div>[ =C2=A0 =C2=A04.7142=
04] systemd[1]: Starting Arbitrary Executable File Formats File System Auto=
mount Point.</div><div>[ =C2=A0 =C2=A04.714594] systemd[1]: Set up automoun=
t Arbitrary Executable File Formats File System Automount Point.</div><div>=
[ =C2=A0 =C2=A04.714685] systemd[1]: Starting Dispatch Password Requests to=
 Console Directory Watch.</div><div>[ =C2=A0 =C2=A04.714784] systemd[1]: St=
arted Dispatch Password Requests to Console Directory Watch.</div><div>[ =
=C2=A0 =C2=A04.714879] systemd[1]: Starting Paths.</div><div>[ =C2=A0 =C2=
=A04.715186] systemd[1]: Reached target Paths.</div><div>[ =C2=A0 =C2=A04.7=
15249] systemd[1]: Expecting device dev-md-0.device...</div><div>[ =C2=A0 =
=C2=A04.715487] systemd[1]: Expecting device dev-md-1.device...</div><div>[=
 =C2=A0 =C2=A04.715725] systemd[1]: Starting Root Slice.</div><div>[ =C2=A0=
 =C2=A04.716042] systemd[1]: Created slice Root Slice.</div><div>[ =C2=A0 =
=C2=A04.716105] systemd[1]: Starting User and Session Slice.</div><div>[ =
=C2=A0 =C2=A04.716477] systemd[1]: Created slice User and Session Slice.</d=
iv><div>[ =C2=A0 =C2=A04.716543] systemd[1]: Starting /dev/initctl Compatib=
ility Named Pipe.</div><div>[ =C2=A0 =C2=A04.716880] systemd[1]: Listening =
on /dev/initctl Compatibility Named Pipe.</div><div>[ =C2=A0 =C2=A04.716948=
] systemd[1]: Starting Delayed Shutdown Socket.</div><div>[ =C2=A0 =C2=A04.=
717271] systemd[1]: Listening on Delayed Shutdown Socket.</div><div>[ =C2=
=A0 =C2=A04.717336] systemd[1]: Starting Journal Socket (/dev/log).</div><d=
iv>[ =C2=A0 =C2=A04.717665] systemd[1]: Listening on Journal Socket (/dev/l=
og).</div><div>[ =C2=A0 =C2=A04.717731] systemd[1]: Starting LVM2 metadata =
daemon socket.</div><div>[ =C2=A0 =C2=A04.718058] systemd[1]: Listening on =
LVM2 metadata daemon socket.</div><div>[ =C2=A0 =C2=A04.718124] systemd[1]:=
 Starting Device-mapper event daemon FIFOs.</div><div>[ =C2=A0 =C2=A04.7435=
71] systemd[1]: Listening on Device-mapper event daemon FIFOs.</div><div>[ =
=C2=A0 =C2=A04.743642] systemd[1]: Starting udev Control Socket.</div><div>=
[ =C2=A0 =C2=A04.743966] systemd[1]: Listening on udev Control Socket.</div=
><div>[ =C2=A0 =C2=A04.744033] systemd[1]: Starting udev Kernel Socket.</di=
v><div>[ =C2=A0 =C2=A04.744350] systemd[1]: Listening on udev Kernel Socket=
.</div><div>[ =C2=A0 =C2=A04.744416] systemd[1]: Starting Journal Socket.</=
div><div>[ =C2=A0 =C2=A04.744741] systemd[1]: Listening on Journal Socket.<=
/div><div>[ =C2=A0 =C2=A04.744812] systemd[1]: Starting System Slice.</div>=
<div>[ =C2=A0 =C2=A04.745180] systemd[1]: Created slice System Slice.</div>=
<div>[ =C2=A0 =C2=A04.745246] systemd[1]: Starting system-getty.slice.</div=
><div>[ =C2=A0 =C2=A04.745622] systemd[1]: Created slice system-getty.slice=
.</div><div>[ =C2=A0 =C2=A04.745698] systemd[1]: Starting Increase datagram=
 queue length...</div><div>[ =C2=A0 =C2=A04.746226] systemd[1]: Mounting PO=
SIX Message Queue File System...</div><div>[ =C2=A0 =C2=A04.746737] systemd=
[1]: Starting udev Coldplug all Devices...</div><div>[ =C2=A0 =C2=A04.74750=
5] systemd[1]: Started Set Up Additional Binary Formats.</div><div>[ =C2=A0=
 =C2=A04.748318] systemd[1]: Starting Create list of required static device=
 nodes for the current kernel...</div><div>[ =C2=A0 =C2=A04.748920] systemd=
[1]: Mounting Debug File System...</div><div>[ =C2=A0 =C2=A04.749439] syste=
md[1]: Mounting Huge Pages File System...</div><div>[ =C2=A0 =C2=A04.761732=
] systemd[1]: Starting Load Kernel Modules...</div><div>[ =C2=A0 =C2=A04.76=
2282] systemd[1]: Starting Slices.</div><div>[ =C2=A0 =C2=A04.762594] syste=
md[1]: Reached target Slices.</div><div>[ =C2=A0 =C2=A04.821476] systemd[1]=
: Started Increase datagram queue length.</div><div>[ =C2=A0 =C2=A04.821809=
] systemd[1]: Starting Syslog Socket.</div><div>[ =C2=A0 =C2=A04.822149] sy=
stemd[1]: Listening on Syslog Socket.</div><div>[ =C2=A0 =C2=A04.822215] sy=
stemd[1]: Starting Journal Service...</div><div>[ =C2=A0 =C2=A04.823034] sy=
stemd[1]: Started Journal Service.</div><div>[ =C2=A0 =C2=A05.141541] syste=
md-udevd[258]: starting version 215</div><div>[ =C2=A0 =C2=A05.460310] wmi:=
 Mapper loaded</div><div>[ =C2=A0 =C2=A05.535388] EDAC MC: Ver: 3.0.0</div>=
<div>[ =C2=A0 =C2=A05.595519] shpchp: Standard Hot Plug PCI Controller Driv=
er version: 0.4</div><div>[ =C2=A0 =C2=A05.607990] EDAC MC0: Giving out dev=
ice to module i7core_edac.c controller i7 core #0: DEV 0000:ff:03.0 (POLLED=
)</div><div>[ =C2=A0 =C2=A05.608109] EDAC PCI0: Giving out device to module=
 i7core_edac controller EDAC PCI controller: DEV 0000:ff:03.0 (POLLED)</div=
><div>[ =C2=A0 =C2=A05.608195] EDAC i7core: Driver loaded, 1 memory control=
ler(s) found.</div><div>[ =C2=A0 =C2=A05.617162] i801_smbus 0000:00:1f.3: S=
MBus using PCI Interrupt</div><div>[ =C2=A0 =C2=A05.650060] ACPI Warning: S=
ystemIO range 0x0000000000000828-0x000000000000082f conflicts with OpRegion=
 0x0000000000000800-0x000000000000084f (\PMRG) (20140424/utaddress-258)</di=
v><div>[ =C2=A0 =C2=A05.650235] ACPI: If an ACPI driver is available for th=
is device, you should use it instead of the native driver</div><div>[ =C2=
=A0 =C2=A05.650333] lpc_ich: Resource conflict(s) found affecting gpio_ich<=
/div><div>[ =C2=A0 =C2=A05.739062] input: Power Button as /devices/LNXSYSTM=
:00/LNXSYBUS:00/PNP0C0C:00/input/input1</div><div>[ =C2=A0 =C2=A05.739160] =
ACPI: Power Button [PWRB]</div><div>[ =C2=A0 =C2=A05.739303] input: Power B=
utton as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2</div><div>[ =C2=A0 =
=C2=A05.739393] ACPI: Power Button [PWRF]</div><div>[ =C2=A0 =C2=A05.989189=
] iTCO_vendor_support: vendor-support=3D0</div><div>[ =C2=A0 =C2=A05.995542=
] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11</div><div>[ =C2=A0 =C2=A0=
5.995625] iTCO_wdt: Found a ICH10R TCO device (Version=3D2, TCOBASE=3D0x086=
0)</div><div>[ =C2=A0 =C2=A05.995917] iTCO_wdt: initialized. heartbeat=3D30=
 sec (nowayout=3D0)</div><div>[ =C2=A0 =C2=A06.084667] [drm] Initialized dr=
m 1.1.0 20060810</div><div>[ =C2=A0 =C2=A06.131944] kvm: VM_EXIT_LOAD_IA32_=
PERF_GLOBAL_CTRL does not work properly. Using workaround</div><div>[ =C2=
=A0 =C2=A06.637843] Adding 25149308k swap on /dev/md0.=C2=A0 Priority:-1 ex=
tents:1 across:25149308k FS</div><div>[ =C2=A0 =C2=A06.949499] EXT4-fs (md2=
): re-mounted. Opts: (null)</div><div>[ =C2=A0 =C2=A06.996326] EXT4-fs (md1=
): mounting ext3 file system using the ext4 subsystem</div><div>[ =C2=A0 =
=C2=A07.051510] EXT4-fs (md1): mounted filesystem with ordered data mode. O=
pts: (null)</div><div>[ =C2=A0 =C2=A07.093399] systemd-journald[242]: Recei=
ved request to flush runtime journal from PID 1</div><div>[ =C2=A0 =C2=A07.=
541744] r8169 0000:06:00.0 eth0: link down</div><div>[ =C2=A0 =C2=A07.54185=
4] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready</div><div>[ =C2=A0 =
=C2=A07.542021] r8169 0000:06:00.0 eth0: link down</div><div>[ =C2=A0 10.57=
7502] r8169 0000:06:00.0 eth0: link up</div><div>[ =C2=A0 10.577574] IPv6: =
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready</div><div>[ =C2=A0 17.607=
886] ip_tables: (C) 2000-2006 Netfilter Core Team</div><div>[ 1368.818980] =
perf interrupt took too long (2501 &gt; 2500), lowering kernel.perf_event_m=
ax_sample_rate to 50000</div><div>[ 4426.079842] do_IRQ: 3.35 No irq handle=
r for vector (irq -1)</div><div>[ 6179.045866] WARNING! power/level is depr=
ecated; use power/control instead</div><div>[ 6181.655960] grep: The scan_u=
nevictable_pages sysctl/node-interface has been disabled for lack of a legi=
timate use case.=C2=A0 If you have one, please send an email to <a href=3D"=
mailto:linux-mm@kvack.org">linux-mm@kvack.org</a>.</div><div>[15302.826147]=
 perf interrupt took too long (5095 &gt; 5000), lowering kernel.perf_event_=
max_sample_rate to 25000</div><div>[18263.301729] do_IRQ: 2.93 No irq handl=
er for vector (irq -1)</div><div>[23255.910251] do_IRQ: 0.80 No irq handler=
 for vector (irq -1)</div><div>[25897.434281] do_IRQ: 0.179 No irq handler =
for vector (irq -1)</div><div>[29419.545609] do_IRQ: 0.153 No irq handler f=
or vector (irq -1)</div><div>[30850.163556] do_IRQ: 2.227 No irq handler fo=
r vector (irq -1)</div><div>[34732.279281] do_IRQ: 3.206 No irq handler for=
 vector (irq -1)</div><div>[36223.099314] do_IRQ: 0.153 No irq handler for =
vector (irq -1)</div><div>[43576.841059] do_IRQ: 0.45 No irq handler for ve=
ctor (irq -1)</div><div>[44337.434825] do_IRQ: 0.35 No irq handler for vect=
or (irq -1)</div><div>[48059.145357] do_IRQ: 0.155 No irq handler for vecto=
r (irq -1)</div><div>[60625.808903] do_IRQ: 2.70 No irq handler for vector =
(irq -1)</div><div>[63034.351559] md: md2: resync done.</div><div>[63034.42=
3123] RAID1 conf printout:</div><div>[63034.423127] =C2=A0--- wd:2 rd:2</di=
v><div>[63034.423130] =C2=A0disk 0, wo:0, o:1, dev:sda3</div><div>[63034.42=
3133] =C2=A0disk 1, wo:0, o:1, dev:sdb3</div><div>[63397.309458] do_IRQ: 1.=
39 No irq handler for vector (irq -1)</div><div>[70501.175555] do_IRQ: 2.19=
8 No irq handler for vector (irq -1)</div><div>[72172.082120] do_IRQ: 0.236=
 No irq handler for vector (irq -1)</div><div>[72693.132497] do_IRQ: 1.111 =
No irq handler for vector (irq -1)</div><div>[84578.955758] do_IRQ: 1.160 N=
o irq handler for vector (irq -1)</div><div>[87440.229370] do_IRQ: 2.62 No =
irq handler for vector (irq -1)</div><div>[96044.812114] do_IRQ: 1.164 No i=
rq handler for vector (irq -1)</div><div>[96185.497298] list passed to list=
_sort() too long for efficiency</div><div>[120547.710208] do_IRQ: 1.193 No =
irq handler for vector (irq -1)</div><div>[121338.113923] do_IRQ: 3.228 No =
irq handler for vector (irq -1)</div><div>[129172.282348] do_IRQ: 0.160 No =
irq handler for vector (irq -1)</div><div>[131964.181384] do_IRQ: 2.108 No =
irq handler for vector (irq -1)</div><div>[135575.812350] do_IRQ: 1.92 No i=
rq handler for vector (irq -1)</div><div>[143419.884584] do_IRQ: 3.187 No i=
rq handler for vector (irq -1)</div></div><div><br></div></div>

--001a11c30fa8609855051fac8e04--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
