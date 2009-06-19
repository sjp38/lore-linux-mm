Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4E0036B005A
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 01:26:41 -0400 (EDT)
Date: Fri, 19 Jun 2009 13:27:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class
	citizen
Message-ID: <20090619052725.GD5603@localhost>
References: <32411.1245336412@redhat.com> <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2015.1245341938@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "Wang, Roger" <roger.wang@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 19, 2009 at 12:18:58AM +0800, David Howells wrote:
> 
> Okay, after dropping all my devel patches, I got the OOM to happen again;
> fresh trace attached.  I was running LTP and an NFSD, and I was spamming the
> NFSD continuously from another machine (mount;tar;umount;repeat).

It's not likely Rik or mine patches can create OOM situations.

But the problem is true - Roger also reports OOM on 2.6.30.
He's running a 2GB desktop that suspend/resumes a lot.

Thanks,
Fengguang

> 
> David
> ---
> Initializing cgroup subsys cpuset
> Linux version 2.6.30-cachefs (dhowells@warthog.procyon.org.uk) (gcc version 4.4.0 20090506 (Red Hat 4.4.0-4) (GCC) ) #107 SMP Thu Jun 18 15:36:16 BST 2009
> Command line: initrd=andromeda-initrd console=tty0 console=ttyS0,115200 ro root=/dev/sda2 enforcing=1 debug BOOT_IMAGE=andromeda-vmlinuz
> KERNEL supported cpus:
>   Intel GenuineIntel
>   AMD AuthenticAMD
>   Centaur CentaurHauls
> BIOS-provided physical RAM map:
>  BIOS-e820: 0000000000000000 - 000000000009ec00 (usable)
>  BIOS-e820: 000000000009ec00 - 00000000000a0000 (reserved)
>  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
>  BIOS-e820: 0000000000100000 - 000000003e59a000 (usable)
>  BIOS-e820: 000000003e59a000 - 000000003e5a6000 (reserved)
>  BIOS-e820: 000000003e5a6000 - 000000003e644000 (usable)
>  BIOS-e820: 000000003e644000 - 000000003e6a9000 (ACPI NVS)
>  BIOS-e820: 000000003e6a9000 - 000000003e6ac000 (ACPI data)
>  BIOS-e820: 000000003e6ac000 - 000000003e6f2000 (ACPI NVS)
>  BIOS-e820: 000000003e6f2000 - 000000003e6ff000 (ACPI data)
>  BIOS-e820: 000000003e6ff000 - 000000003e700000 (usable)
>  BIOS-e820: 000000003e700000 - 000000003f000000 (reserved)
>  BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
> DMI 2.4 present.
> last_pfn = 0x3e700 max_arch_pfn = 0x400000000
> MTRR default type: uncachable
> MTRR fixed ranges enabled:
>   00000-9FFFF write-back
>   A0000-FFFFF uncachable
> MTRR variable ranges enabled:
>   0 base 000000000 mask FC0000000 write-back
>   1 base 03F000000 mask FFF000000 uncachable
>   2 base 03E800000 mask FFF800000 uncachable
>   3 base 03E700000 mask FFFF00000 uncachable
>   4 disabled
>   5 disabled
>   6 disabled
>   7 disabled
> x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
> initial memory mapped : 0 - 20000000
> init_memory_mapping: 0000000000000000-000000003e700000
>  0000000000 - 003e600000 page 2M
>  003e600000 - 003e700000 page 4k
> kernel direct mapping tables up to 3e700000 @ 8000-b000
> RAMDISK: 3e2ee000 - 3e57991c
> ACPI: RSDP 00000000000fe020 00014 (v00 INTEL )
> ACPI: RSDT 000000003e6fd038 0004C (v01 INTEL  DG965RY  00000330      01000013)
> ACPI: FACP 000000003e6fc000 00074 (v01 INTEL  DG965RY  00000330 MSFT 01000013)
> ACPI: DSDT 000000003e6f8000 03EDA (v01 INTEL  DG965RY  00000330 MSFT 01000013)
> ACPI: FACS 000000003e6ac000 00040
> ACPI: APIC 000000003e6f7000 00078 (v01 INTEL  DG965RY  00000330 MSFT 01000013)
> ACPI: WDDT 000000003e6f6000 00040 (v01 INTEL  DG965RY  00000330 MSFT 01000013)
> ACPI: MCFG 000000003e6f5000 0003C (v01 INTEL  DG965RY  00000330 MSFT 01000013)
> ACPI: ASF! 000000003e6f4000 000A6 (v32 INTEL  DG965RY  00000330 MSFT 01000013)
> ACPI: SSDT 000000003e6f3000 001BC (v01 INTEL     CpuPm 00000330 MSFT 01000013)
> ACPI: SSDT 000000003e6f2000 00175 (v01 INTEL   Cpu0Ist 00000330 MSFT 01000013)
> ACPI: SSDT 000000003e6ab000 00175 (v01 INTEL   Cpu1Ist 00000330 MSFT 01000013)
> ACPI: SSDT 000000003e6aa000 00175 (v01 INTEL   Cpu2Ist 00000330 MSFT 01000013)
> ACPI: SSDT 000000003e6a9000 00175 (v01 INTEL   Cpu3Ist 00000330 MSFT 01000013)
> ACPI: Local APIC address 0xfee00000
> (7 early reservations) ==> bootmem [0000000000 - 003e700000]
>   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
>   #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
>   #2 [0001000000 - 0001535d90]    TEXT DATA BSS ==> [0001000000 - 0001535d90]
>   #3 [003e2ee000 - 003e57991c]          RAMDISK ==> [003e2ee000 - 003e57991c]
>   #4 [000009e800 - 0000100000]    BIOS reserved ==> [000009e800 - 0000100000]
>   #5 [0001536000 - 0001536199]              BRK ==> [0001536000 - 0001536199]
>   #6 [0000008000 - 0000009000]          PGTABLE ==> [0000008000 - 0000009000]
> found SMP MP-table at [ffff8800000fe200] fe200
>  [ffffea0000000000-ffffea0000dfffff] PMD -> [ffff880001a00000-ffff8800027fffff] on node 0
> Zone PFN ranges:
>   DMA      0x00000000 -> 0x00001000
>   DMA32    0x00001000 -> 0x00100000
>   Normal   0x00100000 -> 0x00100000
> Movable zone start PFN for each node
> early_node_map[4] active PFN ranges
>     0: 0x00000000 -> 0x0000009e
>     0: 0x00000100 -> 0x0003e59a
>     0: 0x0003e5a6 -> 0x0003e644
>     0: 0x0003e6ff -> 0x0003e700
> On node 0 totalpages: 255447
>   DMA zone: 56 pages used for memmap
>   DMA zone: 101 pages reserved
>   DMA zone: 3841 pages, LIFO batch:0
>   DMA32 zone: 3441 pages used for memmap
>   DMA32 zone: 248008 pages, LIFO batch:31
> ACPI: PM-Timer IO Port: 0x408
> ACPI: Local APIC address 0xfee00000
> ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
> ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
> ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
> ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
> ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
> ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
> ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
> IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
> ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> ACPI: IRQ0 used by override.
> ACPI: IRQ2 used by override.
> ACPI: IRQ9 used by override.
> Using ACPI (MADT) for SMP configuration information
> 4 Processors exceeds NR_CPUS limit of 2
> SMP: Allowing 2 CPUs, 0 hotplug CPUs
> nr_irqs_gsi: 24
> PM: Registered nosave memory: 000000000009e000 - 000000000009f000
> PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
> PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
> PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
> PM: Registered nosave memory: 000000003e59a000 - 000000003e5a6000
> PM: Registered nosave memory: 000000003e644000 - 000000003e6a9000
> PM: Registered nosave memory: 000000003e6a9000 - 000000003e6ac000
> PM: Registered nosave memory: 000000003e6ac000 - 000000003e6f2000
> PM: Registered nosave memory: 000000003e6f2000 - 000000003e6ff000
> Allocating PCI resources starting at 3f000000 (gap: 3f000000:c0f00000)
> NR_CPUS:2 nr_cpumask_bits:2 nr_cpu_ids:2 nr_node_ids:1
> PERCPU: Embedded 24 pages at ffff880001541000, static data 67296 bytes
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 251849
> Kernel command line: initrd=andromeda-initrd console=tty0 console=ttyS0,115200 ro root=/dev/sda2 enforcing=1 debug BOOT_IMAGE=andromeda-vmlinuz
> PID hash table entries: 4096 (order: 12, 32768 bytes)
> Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
> Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
> Initializing CPU#0
> Checking aperture...
> No AGP bridge found
> Memory: 996952k/1022976k available (2949k kernel code, 1188k absent, 24132k reserved, 1679k data, 360k init)
> NR_IRQS:320
> Fast TSC calibration using PIT
> Detected 1865.185 MHz processor.
> Console: colour VGA+ 80x25
> console [tty0] enabled
> console [ttyS0] enabled
> Calibrating delay loop (skipped), value calculated using timer frequency.. 3730.37 BogoMIPS (lpj=7460740)
> Security Framework initialized
> SELinux:  Initializing.
> SELinux:  Starting in enforcing mode
> Mount-cache hash table entries: 256
> Initializing cgroup subsys debug
> Initializing cgroup subsys ns
> Initializing cgroup subsys devices
> CPU: L1 I cache: 32K, L1 D cache: 32K
> CPU: L2 cache: 2048K
> CPU: Physical Processor ID: 0
> CPU: Processor Core ID: 0
> mce: CPU supports 6 MCE banks
> CPU0: Thermal monitoring enabled (TM2)
> using mwait in idle threads.
> ACPI: Core revision 20090521
> Setting APIC routing to flat
> ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> CPU0: Intel(R) Core(TM)2 CPU          6300  @ 1.86GHz stepping 06
> Booting processor 1 APIC 0x1 ip 0x6000
> Initializing CPU#1
> Calibrating delay using timer specific routine.. 3729.90 BogoMIPS (lpj=7459814)
> CPU: L1 I cache: 32K, L1 D cache: 32K
> CPU: L2 cache: 2048K
> CPU: Physical Processor ID: 0
> CPU: Processor Core ID: 1
> mce: CPU supports 6 MCE banks
> CPU1: Thermal monitoring enabled (TM2)
> x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
> CPU1: Intel(R) Core(TM)2 CPU          6300  @ 1.86GHz stepping 06
> checking TSC synchronization [CPU#0 -> CPU#1]: passed.
> Brought up 2 CPUs
> Total of 2 processors activated (7460.27 BogoMIPS).
> NET: Registered protocol family 16
> ACPI: bus type pci registered
> PCI: MCFG configuration 0: base f0000000 segment 0 buses 0 - 127
> PCI: Not using MMCONFIG.
> PCI: Using configuration type 1 for base access
> bio: create slab <bio-0> at 0
> ACPI: EC: Look up EC in DSDT
> ACPI: Interpreter enabled
> ACPI: (supports S0 S3 S4 S5)
> ACPI: Using IOAPIC for interrupt routing
> PCI: MCFG configuration 0: base f0000000 segment 0 buses 0 - 127
> PCI: MCFG area at f0000000 reserved in ACPI motherboard resources
> PCI: Using MMCONFIG at f0000000 - f7ffffff
> ACPI: No dock devices found.
> ACPI: PCI Root Bridge [PCI0] (0000:00)
> pci 0000:00:02.0: reg 10 32bit mmio: [0x50200000-0x502fffff]
> pci 0000:00:02.0: reg 18 64bit mmio: [0x40000000-0x4fffffff]
> pci 0000:00:02.0: reg 20 io port: [0x2110-0x2117]
> pci 0000:00:03.0: reg 10 64bit mmio: [0x50326100-0x5032610f]
> pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
> pci 0000:00:03.0: PME# disabled
> pci 0000:00:19.0: reg 10 32bit mmio: [0x50300000-0x5031ffff]
> pci 0000:00:19.0: reg 14 32bit mmio: [0x50324000-0x50324fff]
> pci 0000:00:19.0: reg 18 io port: [0x20e0-0x20ff]
> pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
> pci 0000:00:19.0: PME# disabled
> pci 0000:00:1a.0: reg 20 io port: [0x20c0-0x20df]
> pci 0000:00:1a.1: reg 20 io port: [0x20a0-0x20bf]
> pci 0000:00:1a.7: reg 10 32bit mmio: [0x50325c00-0x50325fff]
> pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
> pci 0000:00:1a.7: PME# disabled
> pci 0000:00:1b.0: reg 10 64bit mmio: [0x50320000-0x50323fff]
> pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
> pci 0000:00:1b.0: PME# disabled
> pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
> pci 0000:00:1c.0: PME# disabled
> pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
> pci 0000:00:1c.1: PME# disabled
> pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
> pci 0000:00:1c.2: PME# disabled
> pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
> pci 0000:00:1c.3: PME# disabled
> pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
> pci 0000:00:1c.4: PME# disabled
> pci 0000:00:1d.0: reg 20 io port: [0x2080-0x209f]
> pci 0000:00:1d.1: reg 20 io port: [0x2060-0x207f]
> pci 0000:00:1d.2: reg 20 io port: [0x2040-0x205f]
> pci 0000:00:1d.7: reg 10 32bit mmio: [0x50325800-0x50325bff]
> pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
> pci 0000:00:1d.7: PME# disabled
> pci 0000:00:1f.0: quirk: region 0400-047f claimed by ICH6 ACPI/GPIO/TCO
> pci 0000:00:1f.0: quirk: region 0500-053f claimed by ICH6 GPIO
> pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0680 (mask 007f)
> pci 0000:00:1f.2: reg 10 io port: [0x2108-0x210f]
> pci 0000:00:1f.2: reg 14 io port: [0x211c-0x211f]
> pci 0000:00:1f.2: reg 18 io port: [0x2100-0x2107]
> pci 0000:00:1f.2: reg 1c io port: [0x2118-0x211b]
> pci 0000:00:1f.2: reg 20 io port: [0x2020-0x203f]
> pci 0000:00:1f.2: reg 24 32bit mmio: [0x50325000-0x503257ff]
> pci 0000:00:1f.2: PME# supported from D3hot
> pci 0000:00:1f.2: PME# disabled
> pci 0000:00:1f.3: reg 10 32bit mmio: [0x50326000-0x503260ff]
> pci 0000:00:1f.3: reg 20 io port: [0x2000-0x201f]
> pci 0000:00:1c.0: bridge 32bit mmio: [0x50400000-0x504fffff]
> pci 0000:02:00.0: reg 10 io port: [0x1018-0x101f]
> pci 0000:02:00.0: reg 14 io port: [0x1024-0x1027]
> pci 0000:02:00.0: reg 18 io port: [0x1010-0x1017]
> pci 0000:02:00.0: reg 1c io port: [0x1020-0x1023]
> pci 0000:02:00.0: reg 20 io port: [0x1000-0x100f]
> pci 0000:02:00.0: reg 24 32bit mmio: [0x50100000-0x501001ff]
> pci 0000:02:00.0: supports D1
> pci 0000:02:00.0: PME# supported from D0 D1 D3hot
> pci 0000:02:00.0: PME# disabled
> pci 0000:00:1c.1: bridge io port: [0x1000-0x1fff]
> pci 0000:00:1c.1: bridge 32bit mmio: [0x50100000-0x501fffff]
> pci 0000:00:1c.2: bridge 32bit mmio: [0x50500000-0x505fffff]
> pci 0000:00:1c.3: bridge 32bit mmio: [0x50600000-0x506fffff]
> pci 0000:00:1c.4: bridge 32bit mmio: [0x50700000-0x507fffff]
> pci 0000:06:03.0: reg 10 32bit mmio: [0x50004000-0x500047ff]
> pci 0000:06:03.0: reg 14 32bit mmio: [0x50000000-0x50003fff]
> pci 0000:06:03.0: supports D1 D2
> pci 0000:06:03.0: PME# supported from D0 D1 D2 D3hot
> pci 0000:06:03.0: PME# disabled
> pci 0000:00:1e.0: transparent bridge
> pci 0000:00:1e.0: bridge 32bit mmio: [0x50000000-0x500fffff]
> pci_bus 0000:00: on NUMA node 0
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P32_._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX1._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
> ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 9 10 *11 12)
> ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 9 *10 11 12)
> ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 9 10 *11 12)
> ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 9 10 *11 12)
> ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 *9 10 11 12)
> ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 9 *10 11 12)
> ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 7 *9 10 11 12)
> ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 7 9 10 *11 12)
> SCSI subsystem initialized
> libata version 3.00 loaded.
> PCI: Using ACPI for IRQ routing
> NetLabel: Initializing
> NetLabel:  domain hash size = 128
> NetLabel:  protocols = UNLABELED CIPSOv4
> NetLabel:  unlabeled traffic allowed by default
> pnp: PnP ACPI init
> ACPI: bus type pnp registered
> pnp: PnP ACPI: found 12 devices
> ACPI: ACPI bus type pnp unregistered
> system 00:01: iomem range 0xf0000000-0xf7ffffff has been reserved
> system 00:01: iomem range 0xfed13000-0xfed13fff has been reserved
> system 00:01: iomem range 0xfed14000-0xfed17fff has been reserved
> system 00:01: iomem range 0xfed18000-0xfed18fff has been reserved
> system 00:01: iomem range 0xfed19000-0xfed19fff has been reserved
> system 00:01: iomem range 0xfed1c000-0xfed1ffff has been reserved
> system 00:01: iomem range 0xfed20000-0xfed3ffff has been reserved
> system 00:01: iomem range 0xfed45000-0xfed99fff has been reserved
> system 00:01: iomem range 0xc0000-0xdffff has been reserved
> system 00:01: iomem range 0xe0000-0xfffff could not be reserved
> system 00:06: ioport range 0x500-0x53f has been reserved
> system 00:06: ioport range 0x400-0x47f has been reserved
> system 00:06: ioport range 0x680-0x6ff has been reserved
> pci 0000:00:1c.0: PCI bridge, secondary bus 0000:01
> pci 0000:00:1c.0:   IO window: disabled
> pci 0000:00:1c.0:   MEM window: 0x50400000-0x504fffff
> pci 0000:00:1c.0:   PREFETCH window: disabled
> pci 0000:00:1c.1: PCI bridge, secondary bus 0000:02
> pci 0000:00:1c.1:   IO window: 0x1000-0x1fff
> pci 0000:00:1c.1:   MEM window: 0x50100000-0x501fffff
> pci 0000:00:1c.1:   PREFETCH window: disabled
> pci 0000:00:1c.2: PCI bridge, secondary bus 0000:03
> pci 0000:00:1c.2:   IO window: disabled
> pci 0000:00:1c.2:   MEM window: 0x50500000-0x505fffff
> pci 0000:00:1c.2:   PREFETCH window: disabled
> pci 0000:00:1c.3: PCI bridge, secondary bus 0000:04
> pci 0000:00:1c.3:   IO window: disabled
> pci 0000:00:1c.3:   MEM window: 0x50600000-0x506fffff
> pci 0000:00:1c.3:   PREFETCH window: disabled
> pci 0000:00:1c.4: PCI bridge, secondary bus 0000:05
> pci 0000:00:1c.4:   IO window: disabled
> pci 0000:00:1c.4:   MEM window: 0x50700000-0x507fffff
> pci 0000:00:1c.4:   PREFETCH window: disabled
> pci 0000:00:1e.0: PCI bridge, secondary bus 0000:06
> pci 0000:00:1e.0:   IO window: disabled
> pci 0000:00:1e.0:   MEM window: 0x50000000-0x500fffff
> pci 0000:00:1e.0:   PREFETCH window: disabled
> pci 0000:00:1c.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
> pci 0000:00:1c.0: setting latency timer to 64
> pci 0000:00:1c.1: PCI INT B -> GSI 16 (level, low) -> IRQ 16
> pci 0000:00:1c.1: setting latency timer to 64
> pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
> pci 0000:00:1c.2: setting latency timer to 64
> pci 0000:00:1c.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
> pci 0000:00:1c.3: setting latency timer to 64
> pci 0000:00:1c.4: PCI INT A -> GSI 17 (level, low) -> IRQ 17
> pci 0000:00:1c.4: setting latency timer to 64
> pci 0000:00:1e.0: setting latency timer to 64
> pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
> pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
> pci_bus 0000:01: resource 1 mem: [0x50400000-0x504fffff]
> pci_bus 0000:02: resource 0 io:  [0x1000-0x1fff]
> pci_bus 0000:02: resource 1 mem: [0x50100000-0x501fffff]
> pci_bus 0000:03: resource 1 mem: [0x50500000-0x505fffff]
> pci_bus 0000:04: resource 1 mem: [0x50600000-0x506fffff]
> pci_bus 0000:05: resource 1 mem: [0x50700000-0x507fffff]
> pci_bus 0000:06: resource 1 mem: [0x50000000-0x500fffff]
> pci_bus 0000:06: resource 3 io:  [0x00-0xffff]
> pci_bus 0000:06: resource 4 mem: [0x000000-0xffffffffffffffff]
> NET: Registered protocol family 2
> IP route cache hash table entries: 32768 (order: 6, 262144 bytes)
> TCP established hash table entries: 131072 (order: 9, 2097152 bytes)
> TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
> TCP: Hash tables configured (established 131072 bind 65536)
> TCP reno registered
> NET: Registered protocol family 1
> Unpacking initramfs...
> Freeing initrd memory: 2606k freed
> audit: initializing netlink socket (disabled)
> type=2000 audit(1245336472.149:1): initialized
> VFS: Disk quotas dquot_6.5.2
> Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
> SGI XFS with ACLs, security attributes, large block/inode numbers, no debug enabled
> msgmni has been set to 1953
> SELinux:  Registering netfilter hooks
> alg: No test for fcrypt (fcrypt-generic)
> alg: No test for stdrng (krng)
> Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
> io scheduler noop registered
> io scheduler anticipatory registered (default)
> io scheduler deadline registered
> io scheduler cfq registered
> pci 0000:00:02.0: Boot video device
> pcieport-driver 0000:00:1c.0: irq 24 for MSI/MSI-X
> pcieport-driver 0000:00:1c.0: setting latency timer to 64
> pcieport-driver 0000:00:1c.1: irq 25 for MSI/MSI-X
> pcieport-driver 0000:00:1c.1: setting latency timer to 64
> pcieport-driver 0000:00:1c.2: irq 26 for MSI/MSI-X
> pcieport-driver 0000:00:1c.2: setting latency timer to 64
> pcieport-driver 0000:00:1c.3: irq 27 for MSI/MSI-X
> pcieport-driver 0000:00:1c.3: setting latency timer to 64
> pcieport-driver 0000:00:1c.4: irq 28 for MSI/MSI-X
> pcieport-driver 0000:00:1c.4: setting latency timer to 64
> input: Power Button as /class/input/input0
> ACPI: Power Button [PWRF]
> input: Sleep Button as /class/input/input1
> ACPI: Sleep Button [SLPB]
> processor ACPI_CPU:00: registered as cooling_device0
> ACPI: Processor [CPU0] (supports 8 throttling states)
> processor ACPI_CPU:01: registered as cooling_device1
> ACPI: Processor [CPU1] (supports 8 throttling states)
> Linux agpgart interface v0.103
> agpgart-intel 0000:00:00.0: Intel 965G Chipset
> agpgart-intel 0000:00:00.0: detected 7676K stolen memory
> agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0x40000000
> intelfb: Framebuffer driver for Intel(R) 830M/845G/852GM/855GM/865G/915G/915GM/945G/945GM/945GME/965G/965GM chipsets
> intelfb: Version 0.9.6
> intelfb 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> intelfb: 00:02.0: Intel(R) 965G, aperture size 256MB, stolen memory 7932kB
> intelfb: Initial video mode is 1024x768-32@70.
> Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> Platform driver 'serial8250' needs updating - please use dev_pm_ops
> 00:0a: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> loop: module loaded
> Driver 'sd' needs updating - please use bus_type methods
> ahci 0000:00:1f.2: version 3.0
> ahci 0000:00:1f.2: PCI INT A -> GSI 19 (level, low) -> IRQ 19
> ahci 0000:00:1f.2: irq 29 for MSI/MSI-X
> ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0x33 impl SATA mode
> ahci 0000:00:1f.2: flags: 64bit ncq sntf led clo pio slum part ems
> ahci 0000:00:1f.2: setting latency timer to 64
> scsi0 : ahci
> scsi1 : ahci
> scsi2 : ahci
> scsi3 : ahci
> scsi4 : ahci
> scsi5 : ahci
> ata1: SATA max UDMA/133 abar m2048@0x50325000 port 0x50325100 irq 29
> ata2: SATA max UDMA/133 abar m2048@0x50325000 port 0x50325180 irq 29
> ata3: DUMMY
> ata4: DUMMY
> ata5: SATA max UDMA/133 abar m2048@0x50325000 port 0x50325300 irq 29
> ata6: SATA max UDMA/133 abar m2048@0x50325000 port 0x50325380 irq 29
> e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
> e1000e: Copyright (c) 1999-2008 Intel Corporation.
> e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
> e1000e 0000:00:19.0: setting latency timer to 64
> e1000e 0000:00:19.0: irq 30 for MSI/MSI-X
> 0000:00:19.0: eth0: (PCI Express:2.5GB/s:Width x1) 00:16:76:ce:3a:3c
> 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
> 0000:00:19.0: eth0: MAC: 6, PHY: 6, PBA No: ffffff-0ff
> PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
> Platform driver 'i8042' needs updating - please use dev_pm_ops
> serio: i8042 KBD port at 0x60,0x64 irq 1
> serio: i8042 AUX port at 0x60,0x64 irq 12
> mice: PS/2 mouse device common for all mice
> rtc_cmos 00:03: RTC can wake from S4
> rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
> rtc0: alarms up to one month, 114 bytes nvram
> i2c /dev entries driver
> i801_smbus 0000:00:1f.3: PCI INT B -> GSI 21 (level, low) -> IRQ 21
> coretemp coretemp.0: Using relative temperature scale!
> coretemp coretemp.1: Using relative temperature scale!
> cpuidle: using governor ladder
> ip_tables: (C) 2000-2006 Netfilter Core Team
> TCP cubic registered
> input: AT Translated Set 2 keyboard as /class/input/input2
> NET: Registered protocol family 17
> registered taskstats version 1
> ata6: SATA link down (SStatus 0 SControl 300)
> rtc_cmos 00:03: setting system clock to 2009-06-18 14:47:54 UTC (1245336474)
> ata5: SATA link down (SStatus 0 SControl 300)
> ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> ata2: SATA link down (SStatus 0 SControl 300)
> ata1.00: ATA-7: ST380211AS, 3.AAE, max UDMA/133
> ata1.00: 156301488 sectors, multi 0: LBA48 NCQ (depth 31/32)
> ata1.00: configured for UDMA/133
> scsi 0:0:0:0: Direct-Access     ATA      ST380211AS       3.AA PQ: 0 ANSI: 5
> sd 0:0:0:0: [sda] 156301488 512-byte hardware sectors: (80.0 GB/74.5 GiB)
> sd 0:0:0:0: [sda] Write Protect is off
> sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
>  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 sda8 >
> sd 0:0:0:0: [sda] Attached SCSI disk
> Freeing unused kernel memory: 360k freed
> Write protecting the kernel read-only data: 4320k
> Red Hat nash version 6.0.52 starting
> Mounting proc filesystem
> Mounting sysfs filesystem
> Creating /dev
> Creating initial device nodes
> Setting up hotplug.
> input: ImPS/2 Generic Wheel Mouse as /class/input/input3
> Creating block device nodes.
> mount: could not find filesystem '/proc/bus/usb'
> Waiting for driver initialization.
> Waiting for driver initialization.
> Creating root device.
> Mounting root filesystem.
> kjournald starting.  Commit interval 5 seconds
> Setting up otherEXT3-fs: mounted filesystem with writeback data mode.
>  filesystems.
> Setting up new root fs
> no fstab.sys, mounting internal defaults
> SELinux: 8192 avtab hash slots, 177803 rules.
> SELinux: 8192 avtab hash slots, 177803 rules.
> SELinux:  6 users, 12 roles, 2431 types, 118 bools, 1 sens, 1024 cats
> SELinux:  73 classes, 177803 rules
> SELinux:  class kernel_service not defined in policy
> SELinux:  permission open in class sock_file not defined in policy
> SELinux:  permission nlmsg_tty_audit in class netlink_audit_socket not defined in policy
> SELinux: the above unknown classes and permissions will be allowed
> SELinux:  Completing initialization.
> SELinux:  Setting up existing superblocks.
> SELinux: initialized (dev sda2, type ext3), uses xattr
> SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
> SELinux: initialized (dev selinuxfs, type selinuxfs), uses genfs_contexts
> SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
> SELinux: initialized (dev devpts, type devpts), uses transition SIDs
> SELinux: initialized (dev inotifyfs, type inotifyfs), uses genfs_contexts
> SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
> SELinux: initialized (dev anon_inodefs, type anon_inodefs), uses genfs_contexts
> SELinux: initialized (dev pipefs, type pipefs), uses task SIDs
> SELinux: initialized (dev debugfs, type debugfs), uses genfs_contexts
> SELinux: initialized (dev sockfs, type sockfs), uses task SIDs
> SELinux: initialized (dev proc, type proc), uses genfs_contexts
> SELinux: initialized (dev bdev, type bdev), uses genfs_contexts
> SELinux: initialized (dev rootfs, type rootfs), uses genfs_contexts
> SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
> type=1403 audit(1245336481.989:2): policy loaded auid=4294967295 ses=4294967295
> Switching to new root and running init.
> unmounting old /dev
> unmounting old /proc
> unmounting old /sys
>                 Welcome to Fedora
>                 Press 'I' to enter interactive startup.
> Starting udev: [  OK  ]
> Setting hostname andromeda.procyon.org.uk:  [  OK  ]
> Checking filesystems
> Checking all file systems.
> [/sbin/fsck.ext3 (1) -- /] fsck.ext3 -a /dev/sda2
> /1: clean, 330519/2621440 files, 1528859/2620603 blocks
> [/sbin/fsck.ext3 (1) -- /boot] fsck.ext3 -a /dev/sda1
> /boot1: clean, 79/50200 files, 72187/200780 blocks
> [  OK  ]
> Remounting root filesystem in read-write mode:  [  OK  ]
> Mounting local filesystems:  [  OK  ]
> Enabling local filesystem quotas:  [  OK  ]
> Enabling /etc/fstab swaps:  [  OK  ]
> Entering non-interactive startup
> Starting background readahead (early, fast mode): [  OK  ]
> FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> Bringing up loopback interface:  [  OK  ]
> Bringing up interface eth0:
> Determining IP information for eth0... done.
> [  OK  ]
> FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> Starting restorecond: [  OK  ]
> Starting auditd: [  OK  ]
> Starting irqbalance: [  OK  ]
> Starting mcstransd: [  OK  ]
> Starting rpcbind: modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> rpcbind: cannot create socket for udp6
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> rpcbind: cannot create socket for tcp6
> [  OK  ]
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> Starting NFS statd: [  OK  ]
> Starting system message bus: [  OK  ]
> Starting lm_sensors: not configured, run sensors-detect[WARNING]
> Starting sshd: modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> [  OK  ]
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> Starting ntpd: [  OK  ]
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> SysRq : Changing Loglevel
> Loglevel set to 8
> Now booted
> Starting smartd: modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> [  OK  ]
> 
> Fedora release 9 (Sulphur)
> Kernel 2.6.30-cachefs on an x86_64 (/dev/ttyS0)
> 
> andromeda.procyon.org.uk login: modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> warning: `capget01' uses 32-bit capabilities (legacy support in use)
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> Adding 65528k swap on ./swapfile01.  Priority:-1 extents:141 across:498688k
> Adding 65528k swap on ./swapfile01.  Priority:-1 extents:203 across:829292k
> Adding 65528k swap on ./swapfile01.  Priority:-1 extents:151 across:811620k
> Unable to find swap-space signature
> Adding 32k swap on alreadyused.  Priority:-1 extents:4 across:18988k
> Adding 32k swap on swapfile02.  Priority:-1 extents:4 across:1064k
> Adding 32k swap on swapfile03.  Priority:-2 extents:1 across:32k
> Adding 32k swap on swapfile04.  Priority:-3 extents:4 across:18976k
> Adding 32k swap on swapfile05.  Priority:-4 extents:2 across:44k
> Adding 32k swap on swapfile06.  Priority:-5 extents:1 across:32k
> Adding 32k swap on swapfile07.  Priority:-6 extents:2 across:60k
> Adding 32k swap on swapfile08.  Priority:-7 extents:2 across:32k
> Adding 32k swap on swapfile09.  Priority:-8 extents:1 across:32k
> Adding 32k swap on swapfile10.  Priority:-9 extents:2 across:36k
> Adding 32k swap on swapfile11.  Priority:-10 extents:1 across:32k
> Adding 32k swap on swapfile12.  Priority:-11 extents:2 across:32k
> Adding 32k swap on swapfile13.  Priority:-12 extents:1 across:32k
> Adding 32k swap on swapfile14.  Priority:-13 extents:1 across:32k
> Adding 32k swap on swapfile15.  Priority:-14 extents:1 across:32k
> Adding 32k swap on swapfile16.  Priority:-15 extents:2 across:32k
> Adding 32k swap on swapfile17.  Priority:-16 extents:1 across:32k
> Adding 32k swap on swapfile18.  Priority:-17 extents:2 across:44k
> Adding 32k swap on swapfile19.  Priority:-18 extents:2 across:1316k
> Adding 32k swap on swapfile20.  Priority:-19 extents:2 across:32k
> Adding 32k swap on swapfile21.  Priority:-20 extents:2 across:72k
> Adding 32k swap on swapfile22.  Priority:-21 extents:1 across:32k
> Adding 32k swap on swapfile23.  Priority:-22 extents:1 across:32k
> Adding 32k swap on swapfile24.  Priority:-23 extents:3 across:44k
> Adding 32k swap on swapfile25.  Priority:-24 extents:1 across:32k
> Adding 32k swap on swapfile26.  Priority:-25 extents:1 across:32k
> Adding 32k swap on swapfile27.  Priority:-26 extents:1 across:32k
> Adding 32k swap on swapfile28.  Priority:-27 extents:2 across:32k
> Adding 32k swap on swapfile29.  Priority:-28 extents:1 across:32k
> Adding 32k swap on swapfile30.  Priority:-29 extents:1 across:32k
> Adding 32k swap on swapfile31.  Priority:-30 extents:1 across:32k
> Adding 32k swap on firstswapfile.  Priority:-31 extents:2 across:32k
> Adding 32k swap on secondswapfile.  Priority:-32 extents:2 across:44k
> warning: process `sysctl01' used the deprecated sysctl system call with 1.1.
> warning: process `sysctl01' used the deprecated sysctl system call with 1.2.
> warning: process `sysctl03' used the deprecated sysctl system call with 1.1.
> warning: process `sysctl03' used the deprecated sysctl system call with 1.1.
> warning: process `sysctl04' used the deprecated sysctl system call with
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> NFSD: starting 90-second grace period
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> modprobe: FATAL: Could not load /lib/modules/2.6.30-cachefs/modules.dep: No such file or directory
> 
> msgctl11 invoked oom-killer: gfp_mask=0xd0, order=1, oom_adj=0
> msgctl11 cpuset=/ mems_allowed=0
> Pid: 12411, comm: msgctl11 Not tainted 2.6.30-cachefs #107
> Call Trace:
>  [<ffffffff81071612>] ? oom_kill_process.clone.0+0xa9/0x245
>  [<ffffffff810736e7>] ? drain_local_pages+0x0/0x13
>  [<ffffffff810718d9>] ? __out_of_memory+0x12b/0x142
>  [<ffffffff8107195a>] ? out_of_memory+0x6a/0x94
>  [<ffffffff81074002>] ? __alloc_pages_nodemask+0x422/0x50b
>  [<ffffffff81031112>] ? copy_process+0x95/0x1158
>  [<ffffffff81074155>] ? __get_free_pages+0x12/0x50
>  [<ffffffff81031135>] ? copy_process+0xb8/0x1158
>  [<ffffffff81081346>] ? handle_mm_fault+0x2d5/0x645
>  [<ffffffff81032314>] ? do_fork+0x13f/0x2ba
>  [<ffffffff81022a0b>] ? do_page_fault+0x1f1/0x206
>  [<ffffffff8100b0d3>] ? stub_clone+0x13/0x20
>  [<ffffffff8100ad6b>] ? system_call_fastpath+0x16/0x1b
> Mem-Info:
> DMA per-cpu:
> CPU    0: hi:    0, btch:   1 usd:   0
> CPU    1: hi:    0, btch:   1 usd:   0
> DMA32 per-cpu:
> CPU    0: hi:  186, btch:  31 usd:  57
> CPU    1: hi:  186, btch:  31 usd:   0
> Active_anon:70104 active_file:1 inactive_anon:6557
>  inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
>  free:4062 slab:41969 mapped:541 pagetables:59663 bounce:0
> DMA free:3920kB min:60kB low:72kB high:88kB active_anon:2268kB inactive_anon:428kB active_file:0kB inactive_file:0kB unevictable:0kB present:15364kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 968 968 968
> DMA32 free:12328kB min:3948kB low:4932kB high:5920kB active_anon:278148kB inactive_anon:25800kB active_file:4kB inactive_file:0kB unevictable:0kB present:992032kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> DMA: 8*4kB 0*8kB 1*16kB 1*32kB 2*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3920kB
> DMA32: 2474*4kB 56*8kB 8*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 12328kB
> 1660 total pagecache pages
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  = 0kB
> Total swap = 0kB
> 255744 pages RAM
> 5588 pages reserved
> 255749 pages shared
> 215785 pages non-shared
> Out of memory: kill process 6838 (msgctl11) score 152029 or a child
> Killed process 8850 (msgctl11)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
