Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B3B8A6B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 03:23:27 -0500 (EST)
Message-ID: <4ECB5C80.8080609@redhat.com>
Date: Tue, 22 Nov 2011 16:25:36 +0800
From: Dave Young <dyoung@redhat.com>
MIME-Version: 1.0
Subject: BUG:  zonelist->_zonerefs == 0x1c08
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kexec@lists.infradead.org



[    0.000000] Linux version 3.2.0-rc2+ (dave@darkstar) (gcc version
4.5.2 (GCC) ) #256 SMP
[    0.000000] Command line: ro root=/dev/mapper/vg_dellper71001-lv_root
rd_LVM_LV=vg_dellp
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000100 - 00000000000a0000 (usable)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000cf379000 (usable)
[    0.000000]  BIOS-e820: 00000000cf379000 - 00000000cf38f000 (reserved)
[    0.000000]  BIOS-e820: 00000000cf38f000 - 00000000cf3ce000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000cf3ce000 - 00000000d0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fe000000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 0000000630000000 (usable)
[    0.000000] last_pfn = 0x630000 max_arch_pfn = 0x400000000
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] user-defined physical RAM map:
[    0.000000]  user: 0000000000000000 - 0000000000010000 (reserved)
[    0.000000]  user: 0000000000010000 - 00000000000a0000 (usable)
[    0.000000]  user: 0000000003090000 - 000000000affb000 (usable)
[    0.000000]  user: 00000000cf379000 - 00000000cf38f000 (reserved)
[    0.000000]  user: 00000000cf38f000 - 00000000cf3ce000 (ACPI data)
[    0.000000]  user: 00000000cf3ce000 - 00000000d0000000 (reserved)
[    0.000000]  user: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  user: 00000000fe000000 - 0000000100000000 (reserved)
[    0.000000] DMI 2.6 present.
[    0.000000] No AGP bridge found
[    0.000000] last_pfn = 0xaffb max_arch_pfn = 0x400000000
[    0.000000] x86 PAT enabled: cpu 0, old 0x7010600070106, new
0x7010600070106
[    0.000000] found SMP MP-table at [ffff8800000fe710] fe710
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: 0000000000000000-000000000affb000
[    0.000000] RAMDISK: 0ac79000 - 0afef000
[    0.000000] ACPI: RSDP 00000000000f1240 00024 (v02 DELL  )
[    0.000000] ACPI: XSDT 00000000000f1344 0009C (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: FACP 00000000cf3b3f9c 000F4 (v03 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: DSDT 00000000cf38f000 03D72 (v01 DELL   PE_SC3
00000001 INTL 2005062
[    0.000000] ACPI: FACS 00000000cf3b6000 00040
[    0.000000] ACPI: APIC 00000000cf3b3478 0015E (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: SPCR 00000000cf3b35d8 00050 (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: HPET 00000000cf3b362c 00038 (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: DMAR 00000000cf3b3668 001C0 (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: MCFG 00000000cf3b38c4 0003C (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: WD__ 00000000cf3b3904 00134 (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: SLIC 00000000cf3b3a3c 00176 (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: ERST 00000000cf392ef4 00270 (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: HEST 00000000cf393164 003A8 (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: BERT 00000000cf392d74 00030 (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: EINJ 00000000cf392da4 00150 (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: SRAT 00000000cf3b3bc0 00370 (v01 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: TCPA 00000000cf3b3f34 00064 (v02 DELL   PE_SC3
00000001 DELL 0000000
[    0.000000] ACPI: SSDT 00000000cf3b7000 02A4C (v01  INTEL PPM RCM
80000001 INTL 2006110
[    0.000000] SRAT: PXM 1 -> APIC 0x20 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x00 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x34 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x14 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x21 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x01 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x35 -> Node 0
[    0.000000] SRAT: PXM 2 -> APIC 0x15 -> Node 1
[    0.000000] SRAT: Node 1 PXM 2 0-d0000000
[    0.000000] SRAT: Node 1 PXM 2 100000000-330000000
[    0.000000] SRAT: Node 0 PXM 1 330000000-630000000
[    0.000000] Initmem setup node 1 0000000000000000-000000000affb000
[    0.000000]   NODE_DATA [000000000aff6000 - 000000000affafff]
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   empty
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     1: 0x00000010 -> 0x000000a0
[    0.000000]     1: 0x00003090 -> 0x0000affb
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x20] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 almost reached.
Keeping one slot for
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x00] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 almost reached.
Keeping one slot for
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x34] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 almost reached.
Keeping one slot for
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x14] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x21] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.
Processor 4/0x21 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.
Processor 5/0x1 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x35] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.
Processor 6/0x35 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x15] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.
Processor 7/0x15 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x09] lapic_id[0x28] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x29] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x2a] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x2b] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x2c] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x2d] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x2e] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x10] lapic_id[0x2f] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x11] lapic_id[0x30] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x12] lapic_id[0x31] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x13] lapic_id[0x32] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x14] lapic_id[0x33] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x15] lapic_id[0x34] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x16] lapic_id[0x35] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x17] lapic_id[0x36] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x18] lapic_id[0x37] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x19] lapic_id[0x38] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x39] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x3a] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x3b] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x3c] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1e] lapic_id[0x3d] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x1f] lapic_id[0x3e] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x20] lapic_id[0x3f] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI
0-23
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec80000] gsi_base[32])
[    0.000000] IOAPIC[1]: apic_id 1, version 32, address 0xfec80000, GSI
32-55
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
[    0.000000] 32 Processors exceeds NR_CPUS limit of 1
[    0.000000] SMP: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: 00000000000a0000 -
0000000003090000
[    0.000000] Allocating PCI resources starting at affb000 (gap:
affb000:c437e000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:256 nr_cpumask_bits:256
nr_cpu_ids:1 nr_node_ids:2
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88000aa00000 s82752
r8192 d23744 u2097152
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.
Total pages: 32052
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: ro
root=/dev/mapper/vg_dellper71001-lv_root rd_LVM_LV=v
[    0.000000] Misrouted IRQ fixup and polling support enabled
[    0.000000] This may significantly impact system performance
[    0.000000] Disabling memory control group subsystem
[    0.000000] PID hash table entries: 512 (order: 0, 4096 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 109492k/180204k available (6124k kernel code,
49152k absent, 21560k
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0,
CPUs=1, Nodes=2
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] NR_IRQS:16640 nr_irqs:256 16
[    0.000000] Extended CMOS year: 2000
[    0.000000] Spurious LAPIC timer interrupt on cpu 0
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [ttyS0] enabled
[    0.004000] Fast TSC calibration using PIT
[    0.008000] Detected 4389.258 MHz processor.
[    0.000002] Calibrating delay loop (skipped), value calculated using
timer frequency.. 8
[    0.010695] pid_max: default: 32768 minimum: 301
[    0.015330] Security Framework initialized
[    0.019429] AppArmor: AppArmor initialized
[    0.023561] Dentry cache hash table entries: 16384 (order: 5, 131072
bytes)
[    0.030533] Inode-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.037245] Mount-cache hash table entries: 256
[    0.041941] Initializing cgroup subsys cpuacct
[    0.046388] Initializing cgroup subsys memory
[    0.050737] Initializing cgroup subsys devices
[    0.055169] Initializing cgroup subsys freezer
[    0.059601] Initializing cgroup subsys net_cls
[    0.064038] Initializing cgroup subsys blkio
[    0.068310] Initializing cgroup subsys perf_event
[    0.073053] CPU: Physical Processor ID: 0
[    0.077060] CPU: Processor Core ID: 10
[    0.080803] mce: CPU supports 9 MCE banks
[    0.084815] using mwait in idle threads.
[    0.088768] SMP alternatives: switching to UP code
[    0.104786] debug: unmapping init memory
ffffffff81bb5000..ffffffff81bbb000
[    0.111742] ACPI: Core revision 20110623
[    0.116575] ftrace: allocating 23044 entries in 91 pages
[    0.133878] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.179497] CPU0: Intel(R) Xeon(R) CPU           X5698  @ 4.40GHz
stepping 02
[    0.292266] Performance Events: PEBS fmt1+, Westmere events, Intel
PMU driver.
[    0.299495] ... version:                3
[    0.303488] ... bit width:              48
[    0.307569] ... generic registers:      4
[    0.311561] ... value mask:             0000ffffffffffff
[    0.316851] ... max period:             000000007fffffff
[    0.322141] ... fixed-purpose events:   3
[    0.326133] ... event mask:             000000070000000f
[    0.331568] Brought up 1 CPUs
[    0.334527] Total of 1 processors activated (8778.51 BogoMIPS).
[    0.341693] devtmpfs: initialized
[    0.345695] print_constraints: dummy:
[    0.349459] RTC time:  2:55:50, date: 11/22/11
[    0.353912] NET: Registered protocol family 16
[    0.358526] ACPI FADT declares the system doesn't support PCIe ASPM,
so disable it
[    0.366074] ACPI: bus type pci registered
[    0.370178] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
0xe0000000-0xefffffff] (ba
[    0.379454] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
[    0.403926] PCI: Using configuration type 1 for base access
[    0.410366] bio: create slab <bio-0> at 0
[    0.414491] ACPI: Added _OSI(Module Device)
[    0.418662] ACPI: Added _OSI(Processor Device)
[    0.423091] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.427779] ACPI: Added _OSI(Processor Aggregator Device)
[    0.433990] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.440154] ACPI: Interpreter enabled
[    0.443803] ACPI: (supports S0 S4 S5)
[    0.447493] ACPI: Using IOAPIC for interrupt routing
[    0.457268] ACPI: No dock devices found.
[    0.461176] HEST: Table parsing has been initialized.
[    0.466208] PCI: Using host bridge windows from ACPI; if necessary,
use "pci=nocrs" and
[    0.475595] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.482023] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.488614] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.495203] pci_root PNP0A08:00: host bridge window [mem
0x000a0000-0x000bffff]
[    0.502484] pci_root PNP0A08:00: host bridge window [mem
0xd0000000-0xfdffffff]
[    0.509767] pci_root PNP0A08:00: host bridge window [mem
0xfed40000-0xfed44fff]
[    0.518176] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at
0c00 (mask 007f)
[    0.525718] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 2 PIO at
0ca0 (mask 000f)
[    0.533262] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at
00e0 (mask 000f)
[    0.541241] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    0.546662] pci 0000:00:03.0: PCI bridge to [bus 02-02]
[    0.551980] pci 0000:00:04.0: PCI bridge to [bus 03-03]
[    0.557212] pci 0000:00:05.0: PCI bridge to [bus 04-04]
[    0.562459] pci 0000:00:06.0: PCI bridge to [bus 05-05]
[    0.567707] pci 0000:00:07.0: PCI bridge to [bus 06-06]
[    0.572952] pci 0000:00:09.0: PCI bridge to [bus 07-07]
[    0.578288] pci 0000:00:1e.0: PCI bridge to [bus 08-08] (subtractive
decode)
[    0.585850]  pci0000:00: Requesting ACPI _OSC control (0x15)
[    0.591776]  pci0000:00: ACPI _OSC control (0x15) granted
[    0.601447] ACPI: PCI Interrupt Link [LK00] (IRQs 3 4 5 6 7 10 11 14
15) *0, disabled.
[    0.609476] ACPI: PCI Interrupt Link [LK01] (IRQs 3 4 5 6 7 10 11 14
15) *0, disabled.
[    0.617500] ACPI: PCI Interrupt Link [LK02] (IRQs 3 4 5 6 7 10 11 14
15) *0, disabled.
[    0.625568] ACPI: PCI Interrupt Link [LK03] (IRQs 3 4 5 6 7 10 11 14
15) *0, disabled.
[    0.633633] ACPI: PCI Interrupt Link [LK04] (IRQs 3 4 5 6 7 10 11 14
15) *0, disabled.
[    0.641657] ACPI: PCI Interrupt Link [LK05] (IRQs 3 4 5 6 7 10 11 14
15) *0, disabled.
[    0.649724] ACPI: PCI Interrupt Link [LK06] (IRQs 3 4 5 6 7 10 11 14
15) *0, disabled.
[    0.657793] ACPI: PCI Interrupt Link [LK07] (IRQs 3 4 5 6 7 10 11 14
15) *0, disabled.
[    0.665867] vgaarb: device added:
PCI:0000:08:03.0,decodes=io+mem,owns=io+mem,locks=none
[    0.673927] vgaarb: loaded
[    0.676620] vgaarb: bridge control possible 0000:08:03.0
[    0.682133] SCSI subsystem initialized
[    0.685981] usbcore: registered new interface driver usbfs
[    0.691465] usbcore: registered new interface driver hub
[    0.696777] usbcore: registered new device driver usb
[    0.701850] PCI: Using ACPI for IRQ routing
[    0.712452] PCI: Discovered peer bus fe
[    0.717876] PCI: Discovered peer bus ff
[    0.722476] NetLabel: Initializing
[    0.725863] NetLabel:  domain hash size = 128
[    0.730199] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.735159] NetLabel:  unlabeled traffic allowed by default
[    0.740732] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
[    0.745894] hpet0: 4 comparators, 64-bit 14.318180 MHz counter
[    0.753722] Switching to clocksource hpet
[    0.762268] AppArmor: AppArmor Filesystem Enabled
[    0.766978] pnp: PnP ACPI init
[    0.770039] ACPI: bus type pnp registered
[    0.776255] system 00:07: [io  0x0800-0x087f] has been reserved
[    0.782156] system 00:07: [io  0x0880-0x08ff] has been reserved
[    0.788054] system 00:07: [io  0x0900-0x091f] has been reserved
[    0.793956] system 00:07: [io  0x0920-0x0923] has been reserved
[    0.799858] system 00:07: [io  0x0924] has been reserved
[    0.805153] system 00:07: [io  0x0c00-0x0c7f] has been reserved
[    0.811053] system 00:07: [io  0x0ca0-0x0ca7] has been reserved
[    0.816950] system 00:07: [io  0x0ca9-0x0cab] has been reserved
[    0.822852] system 00:07: [io  0x0cad-0x0caf] has been reserved
[    0.828914] system 00:08: [io  0x0ca8] has been reserved
[    0.834213] system 00:08: [io  0x0cac] has been reserved
[    0.840016] system 00:09: [mem 0xe0000000-0xefffffff] has been reserved
[    0.846702] system 00:0b: [mem 0xfed90000-0xfed91fff] has been reserved
[    0.853520] pnp: PnP ACPI: found 12 devices
[    0.857690] ACPI: ACPI bus type pnp unregistered
[    0.869316] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    0.874524] pci 0000:00:01.0:   bridge window [mem 0xd6000000-0xd9ffffff]
[    0.881293] pci 0000:00:03.0: PCI bridge to [bus 02-02]
[    0.886504] pci 0000:00:03.0:   bridge window [mem 0xda000000-0xddffffff]
[    0.893275] pci 0000:00:04.0: PCI bridge to [bus 03-03]
[    0.898482] pci 0000:00:04.0:   bridge window [io  0xf000-0xffff]
[    0.904554] pci 0000:00:04.0:   bridge window [mem 0xdf100000-0xdf1fffff]
[    0.911324] pci 0000:00:05.0: PCI bridge to [bus 04-04]
[    0.916540] pci 0000:00:06.0: PCI bridge to [bus 05-05]
[    0.921755] pci 0000:00:07.0: PCI bridge to [bus 06-06]
[    0.926967] pci 0000:00:09.0: PCI bridge to [bus 07-07]
[    0.932180] pci 0000:08:03.0: BAR 6: assigned [mem
0xde000000-0xde00ffff pref]
[    0.939378] pci 0000:00:1e.0: PCI bridge to [bus 08-08]
[    0.944589] pci 0000:00:1e.0:   bridge window [mem 0xde000000-0xdeffffff]
[    0.951357] pci 0000:00:1e.0:   bridge window [mem
0xd5800000-0xd5ffffff 64bit pref]
[    0.959092] pci 0000:00:01.0: PCI INT A -> GSI 53 (level, low) -> IRQ 53
[    0.965775] pci 0000:00:03.0: PCI INT A -> GSI 53 (level, low) -> IRQ 53
[    0.972463] pci 0000:00:04.0: PCI INT A -> GSI 53 (level, low) -> IRQ 53
[    0.979153] pci 0000:00:05.0: PCI INT A -> GSI 53 (level, low) -> IRQ 53
[    0.985835] pci 0000:00:06.0: PCI INT A -> GSI 53 (level, low) -> IRQ 53
[    0.992516] pci 0000:00:07.0: PCI INT A -> GSI 53 (level, low) -> IRQ 53
[    0.999203] pci 0000:00:09.0: PCI INT A -> GSI 53 (level, low) -> IRQ 53
[    1.005997] NET: Registered protocol family 2
[    1.010418] IP route cache hash table entries: 1024 (order: 1, 8192
bytes)
[    1.017387] TCP established hash table entries: 4096 (order: 4, 65536
bytes)
[    1.024436] TCP bind hash table entries: 4096 (order: 4, 65536 bytes)
[    1.030873] TCP: Hash tables configured (established 4096 bind 4096)
[    1.037207] TCP reno registered
[    1.040341] UDP hash table entries: 128 (order: 0, 4096 bytes)
[    1.046158] UDP-Lite hash table entries: 128 (order: 0, 4096 bytes)
[    1.052432] NET: Registered protocol family 1
[    1.057058] Trying to unpack rootfs image as initramfs...
[    1.119484] debug: unmapping init memory
ffff88000ac79000..ffff88000afef000
[    1.127100] audit: initializing netlink socket (disabled)
[    1.132545] type=2000 audit(1321930549.916:1): initialized
[    1.156444] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.163877] VFS: Disk quotas dquot_6.5.2
[    1.167821] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.174389] Kdump: vmcore initialized
[    1.178780] fuse init (API version 7.17)
[    1.182829] msgmni has been set to 213
[    1.186939] Block layer SCSI generic (bsg) driver version 0.4 loaded
(major 253)
[    1.194328] io scheduler noop registered
[    1.198242] io scheduler deadline registered
[    1.202518] io scheduler cfq registered (default)
[    1.208266] pcieport 0000:00:01.0: Signaling PME through PCIe PME
interrupt
[    1.215212] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
[    1.221718] pci 0000:01:00.1: Signaling PME through PCIe PME interrupt
[    1.228238] pcieport 0000:00:03.0: Signaling PME through PCIe PME
interrupt
[    1.235177] pci 0000:02:00.0: Signaling PME through PCIe PME interrupt
[    1.241687] pci 0000:02:00.1: Signaling PME through PCIe PME interrupt
[    1.248203] pcieport 0000:00:04.0: Signaling PME through PCIe PME
interrupt
[    1.255139] pci 0000:03:00.0: Signaling PME through PCIe PME interrupt
[    1.261673] pcieport 0000:00:05.0: Signaling PME through PCIe PME
interrupt
[    1.268640] pcieport 0000:00:06.0: Signaling PME through PCIe PME
interrupt
[    1.275603] pcieport 0000:00:07.0: Signaling PME through PCIe PME
interrupt
[    1.282551] pcieport 0000:00:09.0: Signaling PME through PCIe PME
interrupt
[    1.289503] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.295090] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    1.301911] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    1.309287] ACPI: Power Button [PWRF]
[    1.313025] BIOS reported wrong ACPI id for the processor
[    1.319757] ERST: Error Record Serialization Table (ERST) support is
initialized.
[    1.327318] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
[    1.354043] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    1.380428] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    1.408245] 00:05: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    1.434232] 00:06: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
[    1.440179] Linux agpgart interface v0.103
[    1.448140] BUG: unable to handle kernel paging request at
0000000000001c08
[    1.455092] IP: [<ffffffff8111c355>] __alloc_pages_nodemask+0xb5/0x870
[    1.461605] PGD 0
[    1.463614] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[    1.468153] CPU 0
[    1.469979] Modules linked in:
[    1.473237]
[    1.474720] Pid: 1, comm: swapper Not tainted 3.2.0-rc2+ #256 Dell
Inc. PowerEdge R710/0
[    1.483238] RIP: 0010:[<ffffffff8111c355>]  [<ffffffff8111c355>]
__alloc_pages_nodemask+
[    1.492170] RSP: 0018:ffff88000a4cfb60  EFLAGS: 00010282
[    1.497459] RAX: 000000000000002d RBX: 0000000000000000 RCX:
0000000000000000
[    1.504568] RDX: 0000000000000000 RSI: 0000000000000082 RDI:
0000000000000246
[    1.511676] RBP: ffff88000a4cfc80 R08: 0000000000000000 R09:
0000000000000000
[    1.518782] R10: 0000000000000000 R11: 0000000000000003 R12:
0000000000000000
[    1.525890] R13: 0000000000000000 R14: 00000000000012d0 R15:
0000000000001c00
[    1.532998] FS:  0000000000000000(0000) GS:ffff88000aa00000(0000)
knlGS:0000000000000000
[    1.541058] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    1.546780] CR2: 0000000000001c08 CR3: 0000000004a05000 CR4:
00000000000006f0
[    1.553887] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[    1.560994] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[    1.568105] Process swapper (pid: 1, threadinfo ffff88000a4ce000,
task ffff88000a4d0000)
[    1.576165] Stack:
[    1.578165]  ffff88000a4cfb90 ffffea000024a380 00000000000012d0
00000000000012d0
[    1.585568]  0000000000000000 ffff88000a40c018 ffff88000a4cfbc0
ffffffff81154d93
[    1.592972]  ffff88000a406f00 ffff88000a401a80 000000100a406f00
0000000000000046
[    1.600376] Call Trace:
[    1.602812]  [<ffffffff81154d93>] ? alloc_pages_current+0x123/0x140
[    1.609055]  [<ffffffff8115ecdf>] new_slab+0xaf/0x300
[    1.614087]  [<ffffffff811604d7>] __slab_alloc+0x2c7/0x510
[    1.619553]  [<ffffffff81309e94>] ? blk_throtl_init+0x34/0x110
[    1.625366]  [<ffffffff8113578a>] ? pcpu_alloc+0x39a/0x9e0
[    1.630830]  [<ffffffff81160973>] kmem_cache_alloc_node_trace+0x73/0x160
[    1.637505]  [<ffffffff815ec76e>] ? mutex_lock+0x1e/0x50
[    1.642796]  [<ffffffff81309e94>] ? blk_throtl_init+0x34/0x110
[    1.648610]  [<ffffffff8132cb13>] ? __percpu_counter_init+0x73/0x80
[    1.654855]  [<ffffffff81309e94>] blk_throtl_init+0x34/0x110
[    1.660492]  [<ffffffff812f6c57>] blk_alloc_queue_node+0x77/0x1d0
[    1.666561]  [<ffffffff812f6dc3>] blk_alloc_queue+0x13/0x20
[    1.672113]  [<ffffffff814072da>] brd_alloc+0x6a/0x1a0
[    1.677234]  [<ffffffff81b1145e>] brd_init+0xcd/0x1d4
[    1.682266]  [<ffffffff81b11391>] ? ramdisk_size+0x1a/0x1a
[    1.687730]  [<ffffffff81002164>] do_one_initcall+0x44/0x190
[    1.693366]  [<ffffffff81adbce9>] kernel_init+0xcd/0x152
[    1.698656]  [<ffffffff815f83b4>] kernel_thread_helper+0x4/0x10
[    1.704554]  [<ffffffff81adbc1c>] ? start_kernel+0x3c8/0x3c8
[    1.710193]  [<ffffffff815f83b0>] ? gs_change+0x13/0x13
[    1.715397] Code: 89 45 84 0f 85 4d 01 00 00 49 81 ff 08 1c 00 00 0f
84 87 01 00 00 49 8
[    1.728749]  83 7f 08 00 0f 84 4c 01 00 00 65 4c 8b 14 25 80 c4 00 00 41
[    1.735861] RIP  [<ffffffff8111c355>] __alloc_pages_nodemask+0xb5/0x870
[    1.742461]  RSP <ffff88000a4cfb60>
[    1.745933] CR2: 0000000000001c08
[    1.749246] ---[ end trace cb2538e743a4de7c ]---

-- 
Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
