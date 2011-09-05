Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 22BD1900146
	for <linux-mm@kvack.org>; Sun,  4 Sep 2011 20:33:33 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3C7C03EE0B6
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:33:28 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 139D645DE54
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:33:28 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F0A3045DE53
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:33:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DCFB31DB8044
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:33:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8595C1DB804F
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:33:27 +0900 (JST)
Date: Mon, 5 Sep 2011 09:26:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: oops 3.0.3, mem related?
Message-Id: <20110905092600.444e96ff.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4E63CA0A.2080000@fastmail.fm>
References: <4E63CA0A.2080000@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anders Eriksson <aeriksson@fastmail.fm>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Sun, 04 Sep 2011 20:57:14 +0200
Anders Eriksson <aeriksson@fastmail.fm> wrote:

> I found the following oops in the logs produced by kdump.
> 
> Memory related?
> 

Thank you for reporting. 

> <6>[27002.832843] usb 4-2: USB disconnect, device number 2
> <1>[28054.549637] BUG: unable to handle kernel NULL pointer dereference
> at 000000000000000c
> <4>[28054.550429] Pid: 29246, comm: python2.6 Not tainted 3.0.3-dirty
> #37 System manufacturer System Product Name/M2A-VM HDMI
> <4>[28054.550429] RIP: 0010:[<ffffffff810a5e1f>]  [<ffffffff810a5e1f>]
> valid_swaphandles+0x68/0xf3

Hmm...swapinfo was NULL ? (0ffset 0xc is accessing si->max ?)


Thanks,
-Kame

> -Anders
> 
> 
> <6>[    0.000000] Initializing cgroup subsys cpuset
> <6>[    0.000000] Initializing cgroup subsys cpu
> <5>[    0.000000] Linux version 3.0.3-dirty (root@tv) (gcc version 4.4.5
> (Gentoo 4.4.5 p1.2, pie-0.4.5) ) #37 SMP PREEMPT Mon Aug 22 08:54:35
> CEST 2011
> <6>[    0.000000] Command line: root=/dev/sda3 hpet=disable crashkernel=128M
> <6>[    0.000000] KERNEL supported cpus:
> <6>[    0.000000]   AMD AuthenticAMD
> <6>[    0.000000] BIOS-provided physical RAM map:
> <6>[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f000 (usable)
> <6>[    0.000000]  BIOS-e820: 000000000009f000 - 00000000000a0000 (reserved)
> <6>[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
> <6>[    0.000000]  BIOS-e820: 0000000000100000 - 0000000077ee0000 (usable)
> <6>[    0.000000]  BIOS-e820: 0000000077ee0000 - 0000000077ee3000 (ACPI NVS)
> <6>[    0.000000]  BIOS-e820: 0000000077ee3000 - 0000000077ef0000 (ACPI
> data)
> <6>[    0.000000]  BIOS-e820: 0000000077ef0000 - 0000000077f00000 (reserved)
> <6>[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
> <6>[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
> <6>[    0.000000] NX (Execute Disable) protection: active
> <6>[    0.000000] DMI 2.4 present.
> <7>[    0.000000] DMI: System manufacturer System Product Name/M2A-VM
> HDMI, BIOS ASUS M2A-VM HDMI ACPI BIOS Revision 2201 10/22/2008
> <7>[    0.000000] e820 update range: 0000000000000000 - 0000000000010000
> (usable) ==> (reserved)
> <7>[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000
> (usable)
> <6>[    0.000000] No AGP bridge found
> <6>[    0.000000] last_pfn = 0x77ee0 max_arch_pfn = 0x400000000
> <7>[    0.000000] MTRR default type: uncachable
> <7>[    0.000000] MTRR fixed ranges enabled:
> <7>[    0.000000]   00000-9FFFF write-back
> <7>[    0.000000]   A0000-BFFFF uncachable
> <7>[    0.000000]   C0000-C7FFF write-protect
> <7>[    0.000000]   C8000-FFFFF uncachable
> <7>[    0.000000] MTRR variable ranges enabled:
> <7>[    0.000000]   0 base 0000000000 mask FFC0000000 write-back
> <7>[    0.000000]   1 base 0040000000 mask FFE0000000 write-back
> <7>[    0.000000]   2 base 0060000000 mask FFF0000000 write-back
> <7>[    0.000000]   3 base 0070000000 mask FFF8000000 write-back
> <7>[    0.000000]   4 base 0077F00000 mask FFFFF00000 uncachable
> <7>[    0.000000]   5 disabled
> <7>[    0.000000]   6 disabled
> <7>[    0.000000]   7 disabled
> <6>[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new
> 0x7010600070106
> <6>[    0.000000] found SMP MP-table at [ffff8800000f6560] f6560
> <7>[    0.000000] initial memory mapped : 0 - 20000000
> <7>[    0.000000] Base memory trampoline at [ffff88000009a000] 9a000
> size 20480
> <6>[    0.000000] init_memory_mapping: 0000000000000000-0000000077ee0000
> <7>[    0.000000]  0000000000 - 0077e00000 page 2M
> <7>[    0.000000]  0077e00000 - 0077ee0000 page 4k
> <7>[    0.000000] kernel direct mapping tables up to 77ee0000 @
> 77edc000-77ee0000
> <6>[    0.000000] Reserving 128MB of memory at 768MB for crashkernel
> (System RAM: 1918MB)
> <4>[    0.000000] ACPI: RSDP 00000000000f8210 00024 (v02 ATI   )
> <4>[    0.000000] ACPI: XSDT 0000000077ee3100 00044 (v01 ATI    ASUSACPI
> 42302E31 AWRD 00000000)
> <4>[    0.000000] ACPI: FACP 0000000077ee8500 000F4 (v03 ATI    ASUSACPI
> 42302E31 AWRD 00000000)
> <4>[    0.000000] ACPI: DSDT 0000000077ee3280 05210 (v01 ATI    ASUSACPI
> 00001000 MSFT 03000000)
> <4>[    0.000000] ACPI: FACS 0000000077ee0000 00040
> <4>[    0.000000] ACPI: SSDT 0000000077ee8740 002CC (v01 PTLTD  POWERNOW
> 00000001  LTP 00000001)
> <4>[    0.000000] ACPI: MCFG 0000000077ee8b00 0003C (v01 ATI    ASUSACPI
> 42302E31 AWRD 00000000)
> <4>[    0.000000] ACPI: APIC 0000000077ee8640 00084 (v01 ATI    ASUSACPI
> 42302E31 AWRD 00000000)
> <7>[    0.000000] ACPI: Local APIC address 0xfee00000
> <7>[    0.000000]  [ffffea0000000000-ffffea0001bfffff] PMD ->
> [ffff880075800000-ffff8800773fffff] on node 0
> <4>[    0.000000] Zone PFN ranges:
> <4>[    0.000000]   DMA      0x00000010 -> 0x00001000
> <4>[    0.000000]   DMA32    0x00001000 -> 0x00100000
> <4>[    0.000000]   Normal   empty
> <4>[    0.000000] Movable zone start PFN for each node
> <4>[    0.000000] early_node_map[2] active PFN ranges
> <4>[    0.000000]     0: 0x00000010 -> 0x0000009f
> <4>[    0.000000]     0: 0x00000100 -> 0x00077ee0
> <7>[    0.000000] On node 0 totalpages: 491119
> <7>[    0.000000]   DMA zone: 56 pages used for memmap
> <7>[    0.000000]   DMA zone: 5 pages reserved
> <7>[    0.000000]   DMA zone: 3922 pages, LIFO batch:0
> <7>[    0.000000]   DMA32 zone: 6661 pages used for memmap
> <7>[    0.000000]   DMA32 zone: 480475 pages, LIFO batch:31
> <6>[    0.000000] Detected use of extended apic ids on hypertransport bus
> <6>[    0.000000] ACPI: PM-Timer IO Port: 0x4008
> <7>[    0.000000] ACPI: Local APIC address 0xfee00000
> <6>[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> <6>[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
> <6>[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
> <6>[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
> <6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
> <6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
> <6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
> <6>[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
> <6>[    0.000000] ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
> <6>[    0.000000] IOAPIC[0]: apic_id 4, version 33, address 0xfec00000,
> GSI 0-23
> <6>[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> <6>[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
> <7>[    0.000000] ACPI: IRQ0 used by override.
> <7>[    0.000000] ACPI: IRQ2 used by override.
> <7>[    0.000000] ACPI: IRQ9 used by override.
> <6>[    0.000000] Using ACPI (MADT) for SMP configuration information
> <6>[    0.000000] SMP: Allowing 4 CPUs, 2 hotplug CPUs
> <7>[    0.000000] nr_irqs_gsi: 40
> <6>[    0.000000] PM: Registered nosave memory: 000000000009f000 -
> 00000000000a0000
> <6>[    0.000000] PM: Registered nosave memory: 00000000000a0000 -
> 00000000000f0000
> <6>[    0.000000] PM: Registered nosave memory: 00000000000f0000 -
> 0000000000100000
> <6>[    0.000000] Allocating PCI resources starting at 77f00000 (gap:
> 77f00000:68100000)
> <6>[    0.000000] setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4
> nr_node_ids:1
> <6>[    0.000000] PERCPU: Embedded 24 pages/cpu @ffff880077c00000 s68800
> r8192 d21312 u524288
> <7>[    0.000000] pcpu-alloc: s68800 r8192 d21312 u524288 alloc=1*2097152
> <7>[    0.000000] pcpu-alloc: [0] 0 1 2 3
> <4>[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
>  Total pages: 484397
> <5>[    0.000000] Kernel command line: root=/dev/sda3 hpet=disable
> crashkernel=128M
> <6>[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
> <6>[    0.000000] Dentry cache hash table entries: 262144 (order: 9,
> 2097152 bytes)
> <6>[    0.000000] Inode-cache hash table entries: 131072 (order: 8,
> 1048576 bytes)
> <6>[    0.000000] Checking aperture...
> <6>[    0.000000] No AGP bridge found
> <6>[    0.000000] Node 0: aperture @ 1066000000 size 32 MB
> <6>[    0.000000] Aperture beyond 4GB. Ignoring.
> <6>[    0.000000] Memory: 1792880k/1964928k available (4899k kernel
> code, 452k absent, 171596k reserved, 2346k data, 464k init)
> <6>[    0.000000] Preemptible hierarchical RCU implementation.
> <6>[    0.000000]       CONFIG_RCU_FANOUT set to non-default value of 32
> <6>[    0.000000] NR_IRQS:384
> <6>[    0.000000] Console: colour VGA+ 80x25
> <6>[    0.000000] console [tty0] enabled
> <6>[    0.000000] allocated 15728640 bytes of page_cgroup
> <6>[    0.000000] please try 'cgroup_disable=memory' option if you don't
> want memory cgroups
> <4>[    0.000000] Fast TSC calibration using PIT
> <4>[    0.000000] Detected 2800.219 MHz processor.
> <6>[    0.000000] Marking TSC unstable due to TSCs unsynchronized
> <6>[    0.002039] Calibrating delay loop (skipped), value calculated
> using timer frequency.. 5600.43 BogoMIPS (lpj=2800219)
> <6>[    0.002109] pid_max: default: 32768 minimum: 301
> <6>[    0.002204] Mount-cache hash table entries: 256
> <6>[    0.003023] Initializing cgroup subsys cpuacct
> <6>[    0.003065] Initializing cgroup subsys memory
> <6>[    0.003111] Initializing cgroup subsys devices
> <6>[    0.003146] Initializing cgroup subsys freezer
> <6>[    0.003180] Initializing cgroup subsys blkio
> <7>[    0.003237] tseg: 0077f00000
> <6>[    0.003239] CPU: Physical Processor ID: 0
> <6>[    0.003273] CPU: Processor Core ID: 0
> <6>[    0.003306] mce: CPU supports 5 MCE banks
> <6>[    0.003348] using AMD E400 aware idle routine
> <6>[    0.003414] ACPI: Core revision 20110413
> <6>[    0.005567] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> <6>[    0.015683] CPU0: AMD Athlon(tm) 64 X2 Dual Core Processor 5600+
> stepping 03
> <6>[    0.015998] Performance Events: AMD PMU driver.
> <6>[    0.015998] ... version:                0
> <6>[    0.015998] ... bit width:              48
> <6>[    0.015998] ... generic registers:      4
> <6>[    0.015998] ... value mask:             0000ffffffffffff
> <6>[    0.015998] ... max period:             00007fffffffffff
> <6>[    0.015998] ... fixed-purpose events:   0
> <6>[    0.015998] ... event mask:             000000000000000f
> <6>[    0.027010] Booting Node   0, Processors  #1
> <7>[    0.027071] smpboot cpu 1: start_ip = 9a000
> <6>[    0.098048] Brought up 2 CPUs
> <6>[    0.098082] Total of 2 processors activated (11199.24 BogoMIPS).
> <6>[    0.098475] PM: Registering ACPI NVS region at 77ee0000 (12288 bytes)
> <6>[    0.098475] NET: Registered protocol family 16
> <7>[    0.099025] node 0 link 0: io port [c000, ffff]
> <6>[    0.099025] TOM: 0000000080000000 aka 2048M
> <7>[    0.099050] node 0 link 0: mmio [a0000, bffff]
> <7>[    0.099052] node 0 link 0: mmio [f0000000, f7ffffff]
> <7>[    0.099055] node 0 link 0: mmio [80000000, dfffffff]
> <7>[    0.099057] node 0 link 0: mmio [f0000000, fe02ffff]
> <7>[    0.099060] node 0 link 0: mmio [e0000000, e03fffff]
> <7>[    0.099062] bus: [00, 03] on node 0 link 0
> <7>[    0.099065] bus: 00 index 0 [io  0x0000-0xffff]
> <7>[    0.099067] bus: 00 index 1 [mem 0x000a0000-0x000bffff]
> <7>[    0.099069] bus: 00 index 2 [mem 0xe0400000-0xfcffffffff]
> <7>[    0.099071] bus: 00 index 3 [mem 0x80000000-0xe03fffff]
> <6>[    0.099080] ACPI: bus type pci registered
> <6>[    0.099124] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
> 0xe0000000-0xefffffff] (base 0xe0000000)
> <6>[    0.099124] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved
> in E820
> <6>[    0.115195] PCI: Using configuration type 1 for base access
> <6>[    0.121035] bio: create slab <bio-0> at 0
> <7>[    0.121551] ACPI: EC: Look up EC in DSDT
> <6>[    0.125210] ACPI: Interpreter enabled
> <6>[    0.125249] ACPI: (supports S0 S1 S3 S4 S5)
> <6>[    0.125442] ACPI: Using IOAPIC for interrupt routing
> <6>[    0.130069] ACPI: No dock devices found.
> <6>[    0.130106] HEST: Table not found.
> <6>[    0.130141] PCI: Using host bridge windows from ACPI; if
> necessary, use "pci=nocrs" and report a bug
> <6>[    0.130232] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
> <6>[    0.130302] pci_root PNP0A03:00: host bridge window [io
> 0x0000-0x0cf7]
> <6>[    0.130302] pci_root PNP0A03:00: host bridge window [io
> 0x0d00-0xffff]
> <6>[    0.130302] pci_root PNP0A03:00: host bridge window [mem
> 0x000a0000-0x000bffff]
> <6>[    0.130302] pci_root PNP0A03:00: host bridge window [mem
> 0x000c0000-0x000dffff]
> <6>[    0.130302] pci_root PNP0A03:00: host bridge window [mem
> 0x80000000-0xfebfffff]
> <7>[    0.130302] pci 0000:00:00.0: [1002:7910] type 0 class 0x000600
> <7>[    0.130302] pci 0000:00:01.0: [1002:7912] type 1 class 0x000604
> <7>[    0.130326] pci 0000:00:07.0: [1002:7917] type 1 class 0x000604
> <7>[    0.130347] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
> <7>[    0.130350] pci 0000:00:07.0: PME# disabled
> <7>[    0.130378] pci 0000:00:12.0: [1002:4380] type 0 class 0x000101
> <7>[    0.130396] pci 0000:00:12.0: reg 10: [io  0xff00-0xff07]
> <7>[    0.130406] pci 0000:00:12.0: reg 14: [io  0xfe00-0xfe03]
> <7>[    0.130416] pci 0000:00:12.0: reg 18: [io  0xfd00-0xfd07]
> <7>[    0.130426] pci 0000:00:12.0: reg 1c: [io  0xfc00-0xfc03]
> <7>[    0.130436] pci 0000:00:12.0: reg 20: [io  0xfb00-0xfb0f]
> <7>[    0.130446] pci 0000:00:12.0: reg 24: [mem 0xfe02f000-0xfe02f3ff]
> <6>[    0.130467] pci 0000:00:12.0: set SATA to AHCI mode
> <7>[    0.130529] pci 0000:00:13.0: [1002:4387] type 0 class 0x000c03
> <7>[    0.130543] pci 0000:00:13.0: reg 10: [mem 0xfe02e000-0xfe02efff]
> <7>[    0.130608] pci 0000:00:13.1: [1002:4388] type 0 class 0x000c03
> <7>[    0.130622] pci 0000:00:13.1: reg 10: [mem 0xfe02d000-0xfe02dfff]
> <7>[    0.131030] pci 0000:00:13.2: [1002:4389] type 0 class 0x000c03
> <7>[    0.131043] pci 0000:00:13.2: reg 10: [mem 0xfe02c000-0xfe02cfff]
> <7>[    0.131108] pci 0000:00:13.3: [1002:438a] type 0 class 0x000c03
> <7>[    0.131122] pci 0000:00:13.3: reg 10: [mem 0xfe02b000-0xfe02bfff]
> <7>[    0.131187] pci 0000:00:13.4: [1002:438b] type 0 class 0x000c03
> <7>[    0.131200] pci 0000:00:13.4: reg 10: [mem 0xfe02a000-0xfe02afff]
> <7>[    0.131271] pci 0000:00:13.5: [1002:4386] type 0 class 0x000c03
> <7>[    0.131291] pci 0000:00:13.5: reg 10: [mem 0xfe029000-0xfe0290ff]
> <7>[    0.131362] pci 0000:00:13.5: supports D1 D2
> <7>[    0.131364] pci 0000:00:13.5: PME# supported from D0 D1 D2 D3hot
> <7>[    0.131368] pci 0000:00:13.5: PME# disabled
> <7>[    0.131391] pci 0000:00:14.0: [1002:4385] type 0 class 0x000c05
> <7>[    0.131413] pci 0000:00:14.0: reg 10: [io  0x0b00-0x0b0f]
> <7>[    0.131490] pci 0000:00:14.1: [1002:438c] type 0 class 0x000101
> <7>[    0.131504] pci 0000:00:14.1: reg 10: [io  0x0000-0x0007]
> <7>[    0.131514] pci 0000:00:14.1: reg 14: [io  0x0000-0x0003]
> <7>[    0.131523] pci 0000:00:14.1: reg 18: [io  0x0000-0x0007]
> <7>[    0.131533] pci 0000:00:14.1: reg 1c: [io  0x0000-0x0003]
> <7>[    0.131543] pci 0000:00:14.1: reg 20: [io  0xf900-0xf90f]
> <7>[    0.131581] pci 0000:00:14.2: [1002:4383] type 0 class 0x000403
> <7>[    0.131603] pci 0000:00:14.2: reg 10: [mem 0xfe020000-0xfe023fff
> 64bit]
> <7>[    0.131662] pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
> <7>[    0.131667] pci 0000:00:14.2: PME# disabled
> <7>[    0.131681] pci 0000:00:14.3: [1002:438d] type 0 class 0x000601
> <7>[    0.131755] pci 0000:00:14.4: [1002:4384] type 1 class 0x000604
> <7>[    0.131800] pci 0000:00:18.0: [1022:1100] type 0 class 0x000600
> <7>[    0.131815] pci 0000:00:18.1: [1022:1101] type 0 class 0x000600
> <7>[    0.131828] pci 0000:00:18.2: [1022:1102] type 0 class 0x000600
> <7>[    0.131841] pci 0000:00:18.3: [1022:1103] type 0 class 0x000600
> <7>[    0.131880] pci 0000:01:05.0: [1002:791e] type 0 class 0x000300
> <7>[    0.131888] pci 0000:01:05.0: reg 10: [mem 0xf0000000-0xf7ffffff
> 64bit pref]
> <7>[    0.131894] pci 0000:01:05.0: reg 18: [mem 0xfdbe0000-0xfdbeffff
> 64bit]
> <7>[    0.131898] pci 0000:01:05.0: reg 20: [io  0xde00-0xdeff]
> <7>[    0.131902] pci 0000:01:05.0: reg 24: [mem 0xfda00000-0xfdafffff]
> <7>[    0.131912] pci 0000:01:05.0: supports D1 D2
> <7>[    0.131922] pci 0000:01:05.2: [1002:7919] type 0 class 0x000403
> <7>[    0.131930] pci 0000:01:05.2: reg 10: [mem 0xfdbfc000-0xfdbfffff
> 64bit]
> <6>[    0.131989] pci 0000:00:01.0: PCI bridge to [bus 01-01]
> <7>[    0.132005] pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
> <7>[    0.132008] pci 0000:00:01.0:   bridge window [mem
> 0xfda00000-0xfdbfffff]
> <7>[    0.132011] pci 0000:00:01.0:   bridge window [mem
> 0xf0000000-0xf7ffffff 64bit pref]
> <7>[    0.132049] pci 0000:02:00.0: [10ec:8168] type 0 class 0x000200
> <7>[    0.132064] pci 0000:02:00.0: reg 10: [io  0xee00-0xeeff]
> <7>[    0.132088] pci 0000:02:00.0: reg 18: [mem 0xfdfff000-0xfdffffff
> 64bit]
> <7>[    0.132114] pci 0000:02:00.0: reg 30: [mem 0x00000000-0x0001ffff pref]
> <7>[    0.132149] pci 0000:02:00.0: supports D1 D2
> <7>[    0.132151] pci 0000:02:00.0: PME# supported from D1 D2 D3hot D3cold
> <7>[    0.132156] pci 0000:02:00.0: PME# disabled
> <6>[    0.132170] pci 0000:02:00.0: disabling ASPM on pre-1.1 PCIe
> device.  You can enable it with 'pcie_aspm=force'
> <6>[    0.132217] pci 0000:00:07.0: PCI bridge to [bus 02-02]
> <7>[    0.132254] pci 0000:00:07.0:   bridge window [io  0xe000-0xefff]
> <7>[    0.132257] pci 0000:00:07.0:   bridge window [mem
> 0xfdf00000-0xfdffffff]
> <7>[    0.132260] pci 0000:00:07.0:   bridge window [mem
> 0xfdc00000-0xfdcfffff 64bit pref]
> <7>[    0.132297] pci 0000:03:06.0: [1131:7133] type 0 class 0x000480
> <7>[    0.132320] pci 0000:03:06.0: reg 10: [mem 0xfdeff000-0xfdeff7ff]
> <7>[    0.132407] pci 0000:03:06.0: supports D1 D2
> <7>[    0.132430] pci 0000:03:07.0: [1106:3044] type 0 class 0x000c00
> <7>[    0.132454] pci 0000:03:07.0: reg 10: [mem 0xfdefe000-0xfdefe7ff]
> <7>[    0.132467] pci 0000:03:07.0: reg 14: [io  0xcf00-0xcf7f]
> <7>[    0.132548] pci 0000:03:07.0: supports D2
> <7>[    0.132550] pci 0000:03:07.0: PME# supported from D2 D3hot D3cold
> <7>[    0.132556] pci 0000:03:07.0: PME# disabled
> <6>[    0.132601] pci 0000:00:14.4: PCI bridge to [bus 03-03]
> (subtractive decode)
> <7>[    0.132640] pci 0000:00:14.4:   bridge window [io  0xc000-0xcfff]
> <7>[    0.132645] pci 0000:00:14.4:   bridge window [mem
> 0xfde00000-0xfdefffff]
> <7>[    0.132649] pci 0000:00:14.4:   bridge window [mem
> 0xfdd00000-0xfddfffff pref]
> <7>[    0.132652] pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7]
> (subtractive decode)
> <7>[    0.132655] pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff]
> (subtractive decode)
> <7>[    0.132657] pci 0000:00:14.4:   bridge window [mem
> 0x000a0000-0x000bffff] (subtractive decode)
> <7>[    0.132660] pci 0000:00:14.4:   bridge window [mem
> 0x000c0000-0x000dffff] (subtractive decode)
> <7>[    0.132662] pci 0000:00:14.4:   bridge window [mem
> 0x80000000-0xfebfffff] (subtractive decode)
> <7>[    0.132673] pci_bus 0000:00: on NUMA node 0
> <7>[    0.132676] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> <7>[    0.132830] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P2P_._PRT]
> <7>[    0.132897] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE7._PRT]
> <7>[    0.132923] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
> <6>[    0.132952]  pci0000:00: Requesting ACPI _OSC control (0x1d)
> <6>[    0.132991]  pci0000:00: ACPI _OSC request failed (AE_NOT_FOUND),
> returned control mask: 0x1d
> <6>[    0.133030] ACPI _OSC control for PCIe not granted, disabling ASPM
> <6>[    0.146006] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 11)
> *0, disabled.
> <6>[    0.146395] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 11)
> *0, disabled.
> <6>[    0.146781] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 11)
> *0, disabled.
> <6>[    0.147172] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 11)
> *0, disabled.
> <6>[    0.147557] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11)
> *0, disabled.
> <6>[    0.147942] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11)
> *0, disabled.
> <6>[    0.148323] ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 6 7 10 *11)
> <6>[    0.148646] ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 6 7 10 11)
> *0, disabled.
> <6>[    0.149040] vgaarb: device added:
> PCI:0000:01:05.0,decodes=io+mem,owns=io+mem,locks=none
> <6>[    0.149050] vgaarb: loaded
> <6>[    0.149084] vgaarb: bridge control possible 0000:01:05.0
> <5>[    0.149210] SCSI subsystem initialized
> <7>[    0.149210] libata version 3.00 loaded.
> <6>[    0.149210] usbcore: registered new interface driver usbfs
> <6>[    0.149210] usbcore: registered new interface driver hub
> <6>[    0.149210] usbcore: registered new device driver usb
> <6>[    0.150016] Advanced Linux Sound Architecture Driver Version 1.0.24.
> <6>[    0.150049] PCI: Using ACPI for IRQ routing
> <7>[    0.159209] PCI: pci_cache_line_size set to 64 bytes
> <7>[    0.159289] reserve RAM buffer: 000000000009f000 - 000000000009ffff
> <7>[    0.159293] reserve RAM buffer: 0000000077ee0000 - 0000000077ffffff
> <6>[    0.159310] Bluetooth: Core ver 2.16
> <6>[    0.159310] NET: Registered protocol family 31
> <6>[    0.159310] Bluetooth: HCI device and connection manager initialized
> <6>[    0.159310] Bluetooth: HCI socket layer initialized
> <6>[    0.159310] Bluetooth: L2CAP socket layer initialized
> <6>[    0.159310] Bluetooth: SCO socket layer initialized
> <6>[    0.159310] pnp: PnP ACPI init
> <6>[    0.159993] ACPI: bus type pnp registered
> <7>[    0.160134] pnp 00:00: [bus 00-ff]
> <7>[    0.160137] pnp 00:00: [io  0x0cf8-0x0cff]
> <7>[    0.160139] pnp 00:00: [io  0x0000-0x0cf7 window]
> <7>[    0.160141] pnp 00:00: [io  0x0d00-0xffff window]
> <7>[    0.160143] pnp 00:00: [mem 0x000a0000-0x000bffff window]
> <7>[    0.160145] pnp 00:00: [mem 0x000c0000-0x000dffff window]
> <7>[    0.160148] pnp 00:00: [mem 0x80000000-0xfebfffff window]
> <7>[    0.160203] pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
> <7>[    0.160203] pnp 00:01: [io  0x4100-0x411f]
> <7>[    0.160203] pnp 00:01: [io  0x0228-0x022f]
> <7>[    0.160203] pnp 00:01: [io  0x040b]
> <7>[    0.160203] pnp 00:01: [io  0x04d6]
> <7>[    0.160203] pnp 00:01: [io  0x0c00-0x0c01]
> <7>[    0.160203] pnp 00:01: [io  0x0c14]
> <7>[    0.160203] pnp 00:01: [io  0x0c50-0x0c52]
> <7>[    0.160203] pnp 00:01: [io  0x0c6c-0x0c6d]
> <7>[    0.160203] pnp 00:01: [io  0x0c6f]
> <7>[    0.160203] pnp 00:01: [io  0x0cd0-0x0cd1]
> <7>[    0.160203] pnp 00:01: [io  0x0cd2-0x0cd3]
> <7>[    0.160203] pnp 00:01: [io  0x0cd4-0x0cdf]
> <7>[    0.160203] pnp 00:01: [io  0x4000-0x40fe]
> <7>[    0.160203] pnp 00:01: [io  0x4210-0x4217]
> <7>[    0.160203] pnp 00:01: [io  0x0b10-0x0b1f]
> <7>[    0.160203] pnp 00:01: [mem 0x00000000-0x00000fff window]
> <7>[    0.160203] pnp 00:01: [mem 0xfee00400-0xfee00fff window]
> <4>[    0.160203] pnp 00:01: disabling [mem 0x00000000-0x00000fff
> window] because it overlaps 0000:02:00.0 BAR 6 [mem
> 0x00000000-0x0001ffff pref]
> <6>[    0.160203] system 00:01: [io  0x4100-0x411f] has been reserved
> <6>[    0.160203] system 00:01: [io  0x0228-0x022f] has been reserved
> <6>[    0.160203] system 00:01: [io  0x040b] has been reserved
> <6>[    0.160203] system 00:01: [io  0x04d6] has been reserved
> <6>[    0.160990] system 00:01: [io  0x0c00-0x0c01] has been reserved
> <6>[    0.161027] system 00:01: [io  0x0c14] has been reserved
> <6>[    0.161062] system 00:01: [io  0x0c50-0x0c52] has been reserved
> <6>[    0.161097] system 00:01: [io  0x0c6c-0x0c6d] has been reserved
> <6>[    0.161133] system 00:01: [io  0x0c6f] has been reserved
> <6>[    0.161168] system 00:01: [io  0x0cd0-0x0cd1] has been reserved
> <6>[    0.161204] system 00:01: [io  0x0cd2-0x0cd3] has been reserved
> <6>[    0.161240] system 00:01: [io  0x0cd4-0x0cdf] has been reserved
> <6>[    0.161276] system 00:01: [io  0x4000-0x40fe] has been reserved
> <6>[    0.161312] system 00:01: [io  0x4210-0x4217] has been reserved
> <6>[    0.161347] system 00:01: [io  0x0b10-0x0b1f] has been reserved
> <6>[    0.161383] system 00:01: [mem 0xfee00400-0xfee00fff window] has
> been reserved
> <7>[    0.161424] system 00:01: Plug and Play ACPI device, IDs PNP0c02
> (active)
> <7>[    0.161516] pnp 00:02: [dma 4]
> <7>[    0.161518] pnp 00:02: [io  0x0000-0x000f]
> <7>[    0.161520] pnp 00:02: [io  0x0080-0x0090]
> <7>[    0.161522] pnp 00:02: [io  0x0094-0x009f]
> <7>[    0.161524] pnp 00:02: [io  0x00c0-0x00df]
> <7>[    0.161549] pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
> <7>[    0.161994] pnp 00:03: [io  0x0070-0x0073]
> <7>[    0.162007] pnp 00:03: [irq 8]
> <7>[    0.162034] pnp 00:03: Plug and Play ACPI device, IDs PNP0b00 (active)
> <7>[    0.162034] pnp 00:04: [io  0x0061]
> <7>[    0.162034] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
> <7>[    0.162034] pnp 00:05: [io  0x00f0-0x00ff]
> <7>[    0.162034] pnp 00:05: [irq 13]
> <7>[    0.162041] pnp 00:05: Plug and Play ACPI device, IDs PNP0c04 (active)
> <7>[    0.162041] pnp 00:06: [io  0x0010-0x001f]
> <7>[    0.162041] pnp 00:06: [io  0x0022-0x003f]
> <7>[    0.162041] pnp 00:06: [io  0x0044-0x005f]
> <7>[    0.162041] pnp 00:06: [io  0x0062-0x0063]
> <7>[    0.162041] pnp 00:06: [io  0x0065-0x006f]
> <7>[    0.162041] pnp 00:06: [io  0x0074-0x007f]
> <7>[    0.162041] pnp 00:06: [io  0x0091-0x0093]
> <7>[    0.162041] pnp 00:06: [io  0x00a2-0x00bf]
> <7>[    0.162043] pnp 00:06: [io  0x00e0-0x00ef]
> <7>[    0.162045] pnp 00:06: [io  0x04d0-0x04d1]
> <7>[    0.162047] pnp 00:06: [io  0x0220-0x0225]
> <6>[    0.162094] system 00:06: [io  0x04d0-0x04d1] has been reserved
> <6>[    0.162094] system 00:06: [io  0x0220-0x0225] has been reserved
> <7>[    0.162094] system 00:06: Plug and Play ACPI device, IDs PNP0c02
> (active)
> <7>[    0.162193] pnp 00:07: [io  0x03f0-0x03f5]
> <7>[    0.162195] pnp 00:07: [io  0x03f7]
> <7>[    0.162203] pnp 00:07: [irq 6]
> <7>[    0.162205] pnp 00:07: [dma 2]
> <7>[    0.162248] pnp 00:07: Plug and Play ACPI device, IDs PNP0700 (active)
> <7>[    0.162248] pnp 00:08: [io  0x03f8-0x03ff]
> <7>[    0.162248] pnp 00:08: [irq 4]
> <7>[    0.162248] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
> <7>[    0.163053] pnp 00:09: [io  0x0378-0x037f]
> <7>[    0.163062] pnp 00:09: [irq 7]
> <7>[    0.163108] pnp 00:09: Plug and Play ACPI device, IDs PNP0400 (active)
> <7>[    0.163108] pnp 00:0a: [mem 0xe0000000-0xefffffff]
> <6>[    0.163149] system 00:0a: [mem 0xe0000000-0xefffffff] has been
> reserved
> <7>[    0.163149] system 00:0a: Plug and Play ACPI device, IDs PNP0c02
> (active)
> <7>[    0.163157] pnp 00:0b: [mem 0x000cd600-0x000cffff]
> <7>[    0.163159] pnp 00:0b: [mem 0x000f0000-0x000f7fff]
> <7>[    0.163161] pnp 00:0b: [mem 0x000f8000-0x000fbfff]
> <7>[    0.163163] pnp 00:0b: [mem 0x000fc000-0x000fffff]
> <7>[    0.163165] pnp 00:0b: [mem 0x77ef0000-0x77feffff]
> <7>[    0.163168] pnp 00:0b: [mem 0xfed00000-0xfed000ff]
> <7>[    0.163170] pnp 00:0b: [mem 0x77ee0000-0x77efffff]
> <7>[    0.163172] pnp 00:0b: [mem 0xffff0000-0xffffffff]
> <7>[    0.163174] pnp 00:0b: [mem 0x00000000-0x0009ffff]
> <7>[    0.163176] pnp 00:0b: [mem 0x00100000-0x77edffff]
> <7>[    0.163178] pnp 00:0b: [mem 0x77ff0000-0x7ffeffff]
> <7>[    0.163181] pnp 00:0b: [mem 0xfec00000-0xfec00fff]
> <7>[    0.163183] pnp 00:0b: [mem 0xfee00000-0xfee00fff]
> <7>[    0.163188] pnp 00:0b: [mem 0xfff80000-0xfffeffff]
> <6>[    0.163240] system 00:0b: [mem 0x000cd600-0x000cffff] has been
> reserved
> <6>[    0.163240] system 00:0b: [mem 0x000f0000-0x000f7fff] could not be
> reserved
> <6>[    0.163240] system 00:0b: [mem 0x000f8000-0x000fbfff] could not be
> reserved
> <6>[    0.163240] system 00:0b: [mem 0x000fc000-0x000fffff] could not be
> reserved
> <6>[    0.163240] system 00:0b: [mem 0x77ef0000-0x77feffff] could not be
> reserved
> <6>[    0.163240] system 00:0b: [mem 0xfed00000-0xfed000ff] has been
> reserved
> <6>[    0.163240] system 00:0b: [mem 0x77ee0000-0x77efffff] could not be
> reserved
> <6>[    0.163256] system 00:0b: [mem 0xffff0000-0xffffffff] has been
> reserved
> <6>[    0.163293] system 00:0b: [mem 0x00000000-0x0009ffff] could not be
> reserved
> <6>[    0.163329] system 00:0b: [mem 0x00100000-0x77edffff] could not be
> reserved
> <6>[    0.163365] system 00:0b: [mem 0x77ff0000-0x7ffeffff] could not be
> reserved
> <6>[    0.163402] system 00:0b: [mem 0xfec00000-0xfec00fff] could not be
> reserved
> <6>[    0.163989] system 00:0b: [mem 0xfee00000-0xfee00fff] could not be
> reserved
> <6>[    0.164026] system 00:0b: [mem 0xfff80000-0xfffeffff] has been
> reserved
> <7>[    0.164062] system 00:0b: Plug and Play ACPI device, IDs PNP0c01
> (active)
> <6>[    0.164069] pnp: PnP ACPI: found 12 devices
> <6>[    0.164104] ACPI: ACPI bus type pnp unregistered
> <6>[    0.172004] Switching to clocksource acpi_pm
> <7>[    0.172067] PCI: max bus depth: 1 pci_try_num: 2
> <6>[    0.172085] pci 0000:00:01.0: PCI bridge to [bus 01-01]
> <6>[    0.172121] pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
> <6>[    0.172158] pci 0000:00:01.0:   bridge window [mem
> 0xfda00000-0xfdbfffff]
> <6>[    0.172194] pci 0000:00:01.0:   bridge window [mem
> 0xf0000000-0xf7ffffff 64bit pref]
> <6>[    0.172237] pci 0000:02:00.0: BAR 6: assigned [mem
> 0xfdc00000-0xfdc1ffff pref]
> <6>[    0.172276] pci 0000:00:07.0: PCI bridge to [bus 02-02]
> <6>[    0.172312] pci 0000:00:07.0:   bridge window [io  0xe000-0xefff]
> <6>[    0.172348] pci 0000:00:07.0:   bridge window [mem
> 0xfdf00000-0xfdffffff]
> <6>[    0.172385] pci 0000:00:07.0:   bridge window [mem
> 0xfdc00000-0xfdcfffff 64bit pref]
> <6>[    0.172425] pci 0000:00:14.4: PCI bridge to [bus 03-03]
> <6>[    0.172462] pci 0000:00:14.4:   bridge window [io  0xc000-0xcfff]
> <6>[    0.172500] pci 0000:00:14.4:   bridge window [mem
> 0xfde00000-0xfdefffff]
> <6>[    0.172539] pci 0000:00:14.4:   bridge window [mem
> 0xfdd00000-0xfddfffff pref]
> <7>[    0.172588] pci 0000:00:07.0: setting latency timer to 64
> <7>[    0.172596] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
> <7>[    0.172598] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
> <7>[    0.172600] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
> <7>[    0.172602] pci_bus 0000:00: resource 7 [mem 0x000c0000-0x000dffff]
> <7>[    0.172605] pci_bus 0000:00: resource 8 [mem 0x80000000-0xfebfffff]
> <7>[    0.172607] pci_bus 0000:01: resource 0 [io  0xd000-0xdfff]
> <7>[    0.172610] pci_bus 0000:01: resource 1 [mem 0xfda00000-0xfdbfffff]
> <7>[    0.172612] pci_bus 0000:01: resource 2 [mem 0xf0000000-0xf7ffffff
> 64bit pref]
> <7>[    0.172615] pci_bus 0000:02: resource 0 [io  0xe000-0xefff]
> <7>[    0.172617] pci_bus 0000:02: resource 1 [mem 0xfdf00000-0xfdffffff]
> <7>[    0.172619] pci_bus 0000:02: resource 2 [mem 0xfdc00000-0xfdcfffff
> 64bit pref]
> <7>[    0.172622] pci_bus 0000:03: resource 0 [io  0xc000-0xcfff]
> <7>[    0.172624] pci_bus 0000:03: resource 1 [mem 0xfde00000-0xfdefffff]
> <7>[    0.172626] pci_bus 0000:03: resource 2 [mem 0xfdd00000-0xfddfffff
> pref]
> <7>[    0.172629] pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7]
> <7>[    0.172631] pci_bus 0000:03: resource 5 [io  0x0d00-0xffff]
> <7>[    0.172633] pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000bffff]
> <7>[    0.172635] pci_bus 0000:03: resource 7 [mem 0x000c0000-0x000dffff]
> <7>[    0.172638] pci_bus 0000:03: resource 8 [mem 0x80000000-0xfebfffff]
> <6>[    0.172703] NET: Registered protocol family 2
> <6>[    0.172789] IP route cache hash table entries: 65536 (order: 7,
> 524288 bytes)
> <6>[    0.172933] Switched to NOHz mode on CPU #0
> <6>[    0.172979] Switched to NOHz mode on CPU #1
> <6>[    0.173265] TCP established hash table entries: 262144 (order: 10,
> 4194304 bytes)
> <6>[    0.175105] TCP bind hash table entries: 65536 (order: 8, 1048576
> bytes)
> <6>[    0.175651] TCP: Hash tables configured (established 262144 bind
> 65536)
> <6>[    0.175687] TCP reno registered
> <6>[    0.175723] UDP hash table entries: 1024 (order: 3, 32768 bytes)
> <6>[    0.175778] UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes)
> <6>[    0.175968] NET: Registered protocol family 1
> <6>[    0.176135] RPC: Registered named UNIX socket transport module.
> <6>[    0.176179] RPC: Registered udp transport module.
> <6>[    0.176215] RPC: Registered tcp transport module.
> <6>[    0.176249] RPC: Registered tcp NFSv4.1 backchannel transport module.
> <7>[    0.402045] pci 0000:01:05.0: Boot video device
> <7>[    0.402056] PCI: CLS 32 bytes, default 64
> <6>[    0.403154] audit: initializing netlink socket (disabled)
> <5>[    0.403196] type=2000 audit(1314542588.403:1): initialized
> <6>[    0.409968] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> <6>[    0.410287] msgmni has been set to 3501
> <6>[    0.410705] Block layer SCSI generic (bsg) driver version 0.4
> loaded (major 253)
> <6>[    0.410748] io scheduler noop registered
> <6>[    0.410798] io scheduler cfq registered (default)
> <7>[    0.410956] pcieport 0000:00:07.0: setting latency timer to 64
> <7>[    0.410978] pcieport 0000:00:07.0: irq 40 for MSI/MSI-X
> <6>[    0.411613] input: Power Button as
> /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
> <6>[    0.411655] ACPI: Power Button [PWRB]
> <6>[    0.411783] input: Power Button as
> /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
> <6>[    0.411823] ACPI: Power Button [PWRF]
> <6>[    0.411981] ACPI: Fan [FAN] (on)
> <7>[    0.412176] ACPI: acpi_idle registered with cpuidle
> <4>[    0.413662] ACPI Warning: For \_TZ_.THRM._PSL: Return Package has
> no elements (empty) (20110413/nspredef-456)
> <3>[    0.413766] ACPI: [Package] has zero elements (ffff88007438ed00)
> <4>[    0.413801] ACPI: Invalid passive threshold
> <6>[    0.414018] thermal LNXTHERM:00: registered as thermal_zone0
> <6>[    0.414056] ACPI: Thermal Zone [THRM] (40 C)
> <6>[    0.414143] ERST: Table is not found!
> <6>[    0.414273] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> <6>[    0.434992] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> <6>[    0.507807] 00:08: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> <6>[    0.519342] [drm] Initialized drm 1.1.0 20060810
> <6>[    0.519429] [drm] radeon defaulting to kernel modesetting.
> <6>[    0.519465] [drm] radeon kernel modesetting enabled.
> <6>[    0.519555] radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low)
> -> IRQ 18
> <6>[    0.519771] [drm] initializing kernel modesetting (RS690
> 0x1002:0x791E 0x1043:0x826D).
> <6>[    0.519825] [drm] register mmio base: 0xFDBE0000
> <6>[    0.519860] [drm] register mmio size: 65536
> <6>[    0.521406] ATOM BIOS: ATI
> <6>[    0.521457] radeon 0000:01:05.0: VRAM: 128M 0x0000000078000000 -
> 0x000000007FFFFFFF (128M used)
> <6>[    0.521497] radeon 0000:01:05.0: GTT: 512M 0x0000000080000000 -
> 0x000000009FFFFFFF
> <6>[    0.521537] [drm] Supports vblank timestamp caching Rev 1
> (10.10.2010).
> <6>[    0.521572] [drm] Driver supports precise vblank timestamp query.
> <6>[    0.521631] [drm] radeon: irq initialized.
> <6>[    0.522044] [drm] Detected VRAM RAM=128M, BAR=128M
> <6>[    0.522084] [drm] RAM width 128bits DDR
> <6>[    0.522195] [TTM] Zone  kernel: Available graphics memory: 896440 kiB.
> <6>[    0.522234] [TTM] Initializing pool allocator.
> <6>[    0.522291] [drm] radeon: 128M of VRAM memory ready
> <6>[    0.522326] [drm] radeon: 512M of GTT memory ready.
> <6>[    0.522363] [drm] GART: num cpu pages 131072, num gpu pages 131072
> <6>[    0.526197] [drm] radeon: 1 quad pipes, 1 z pipes initialized.
> <6>[    0.532075] radeon 0000:01:05.0: WB enabled
> <6>[    0.532212] [drm] Loading RS690/RS740 Microcode
> <6>[    0.532397] [drm] radeon: ring at 0x0000000080001000
> <6>[    0.532448] [drm] ring test succeeded in 1 usecs
> <6>[    0.532570] [drm] radeon: ib pool ready.
> <6>[    0.532614] [drm] ib test succeeded in 0 usecs
> <7>[    0.532652] failed to evaluate ATIF got AE_BAD_PARAMETER
> <6>[    0.533339] [drm] Radeon Display Connectors
> <6>[    0.533374] [drm] Connector 0:
> <6>[    0.533407] [drm]   VGA
> <6>[    0.533441] [drm]   DDC: 0x7e50 0x7e40 0x7e54 0x7e44 0x7e58 0x7e48
> 0x7e5c 0x7e4c
> <6>[    0.533479] [drm]   Encoders:
> <6>[    0.533512] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
> <6>[    0.533546] [drm] Connector 1:
> <6>[    0.533579] [drm]   S-video
> <6>[    0.533612] [drm]   Encoders:
> <6>[    0.533645] [drm]     TV1: INTERNAL_KLDSCP_DAC1
> <6>[    0.533679] [drm] Connector 2:
> <6>[    0.533712] [drm]   HDMI-A
> <6>[    0.533745] [drm]   HPD2
> <6>[    0.533778] [drm]   DDC: 0x7e40 0x7e60 0x7e44 0x7e64 0x7e48 0x7e68
> 0x7e4c 0x7e6c
> <6>[    0.533816] [drm]   Encoders:
> <6>[    0.533849] [drm]     DFP2: INTERNAL_DDI
> <6>[    0.533883] [drm] Connector 3:
> <6>[    0.533916] [drm]   DVI-D
> <6>[    0.533950] [drm]   DDC: 0x7e40 0x7e50 0x7e44 0x7e54 0x7e48 0x7e58
> 0x7e4c 0x7e5c
> <6>[    0.533987] [drm]   Encoders:
> <6>[    0.534034] [drm]     DFP3: INTERNAL_LVTM1
> <6>[    0.585392] [drm] Radeon display connector VGA-1: Found valid EDID
> <6>[    0.686370] [drm] Radeon display connector HDMI-A-1: Found valid EDID
> <6>[    0.695990] [drm] Radeon display connector DVI-D-1: No monitor
> connected or invalid EDID
> <6>[    0.951545] [drm] fb mappable at 0xF0040000
> <6>[    0.951610] [drm] vram apper at 0xF0000000
> <6>[    0.951644] [drm] size 8294400
> <6>[    0.951677] [drm] fb depth is 24
> <6>[    0.951710] [drm]    pitch is 7680
> <6>[    0.951829] fbcon: radeondrmfb (fb0) is primary device
> <6>[    0.997938] Console: switching to colour frame buffer device 240x67
> <6>[    1.015586] fb0: radeondrmfb frame buffer device
> <6>[    1.015653] drm: registered panic notifier
> <6>[    1.015715] [drm] Initialized radeon 2.10.0 20080528 for
> 0000:01:05.0 on minor 0
> <6>[    1.018284] brd: module loaded
> <6>[    1.019515] loop: module loaded
> <6>[    1.019615] Uniform Multi-Platform E-IDE driver
> <6>[    1.019822] ide-gd driver 1.18
> <7>[    1.020144] ahci 0000:00:12.0: version 3.0
> <6>[    1.020168] ahci 0000:00:12.0: PCI INT A -> GSI 22 (level, low) ->
> IRQ 22
> <4>[    1.020283] ahci 0000:00:12.0: ASUS M2A-VM: enabling 64bit DMA
> <6>[    1.020477] ahci 0000:00:12.0: AHCI 0001.0100 32 slots 4 ports 3
> Gbps 0xf impl SATA mode
> <6>[    1.020593] ahci 0000:00:12.0: flags: 64bit ncq sntf ilck pm led
> clo pmp pio slum part ccc
> <6>[    1.022098] scsi0 : ahci
> <6>[    1.022386] scsi1 : ahci
> <6>[    1.022598] scsi2 : ahci
> <6>[    1.022815] scsi3 : ahci
> <6>[    1.023045] ata1: SATA max UDMA/133 abar m1024@0xfe02f000 port
> 0xfe02f100 irq 22
> <6>[    1.023140] ata2: SATA max UDMA/133 abar m1024@0xfe02f000 port
> 0xfe02f180 irq 22
> <6>[    1.023232] ata3: SATA max UDMA/133 abar m1024@0xfe02f000 port
> 0xfe02f200 irq 22
> <6>[    1.023335] ata4: SATA max UDMA/133 abar m1024@0xfe02f000 port
> 0xfe02f280 irq 22
> <6>[    1.023670] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> <6>[    1.023783] r8169 0000:02:00.0: PCI INT A -> GSI 19 (level, low)
> -> IRQ 19
> <7>[    1.023915] r8169 0000:02:00.0: setting latency timer to 64
> <7>[    1.023966] r8169 0000:02:00.0: irq 41 for MSI/MSI-X
> <6>[    1.024218] r8169 0000:02:00.0: eth0: RTL8168b/8111b at
> 0xffffc9000000c000, 00:1b:fc:89:fa:a2, XID 18000000 IRQ 41
> <6>[    1.024432] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> <6>[    1.024540] ehci_hcd 0000:00:13.5: PCI INT D -> GSI 19 (level,
> low) -> IRQ 19
> <6>[    1.024652] ehci_hcd 0000:00:13.5: EHCI Host Controller
> <6>[    1.024734] ehci_hcd 0000:00:13.5: new USB bus registered,
> assigned bus number 1
> <6>[    1.024866] ehci_hcd 0000:00:13.5: applying AMD SB600/SB700 USB
> freeze workaround
> <6>[    1.024984] ehci_hcd 0000:00:13.5: debug port 1
> <6>[    1.025133] ehci_hcd 0000:00:13.5: irq 19, io mem 0xfe029000
> <6>[    1.031016] ehci_hcd 0000:00:13.5: USB 2.0 started, EHCI 1.00
> <6>[    1.031320] hub 1-0:1.0: USB hub found
> <6>[    1.031382] hub 1-0:1.0: 10 ports detected
> <6>[    1.031570] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> <6>[    1.031676] ohci_hcd 0000:00:13.0: PCI INT A -> GSI 16 (level,
> low) -> IRQ 16
> <6>[    1.031784] ohci_hcd 0000:00:13.0: OHCI Host Controller
> <6>[    1.031861] ohci_hcd 0000:00:13.0: new USB bus registered,
> assigned bus number 2
> <6>[    1.031998] ohci_hcd 0000:00:13.0: irq 16, io mem 0xfe02e000
> <6>[    1.087210] hub 2-0:1.0: USB hub found
> <6>[    1.087273] hub 2-0:1.0: 2 ports detected
> <6>[    1.087383] ohci_hcd 0000:00:13.1: PCI INT B -> GSI 17 (level,
> low) -> IRQ 17
> <6>[    1.087491] ohci_hcd 0000:00:13.1: OHCI Host Controller
> <6>[    1.087568] ohci_hcd 0000:00:13.1: new USB bus registered,
> assigned bus number 3
> <6>[    1.091311] ohci_hcd 0000:00:13.1: irq 17, io mem 0xfe02d000
> <6>[    1.149205] hub 3-0:1.0: USB hub found
> <6>[    1.153000] hub 3-0:1.0: 2 ports detected
> <6>[    1.156772] ohci_hcd 0000:00:13.2: PCI INT C -> GSI 18 (level,
> low) -> IRQ 18
> <6>[    1.160562] ohci_hcd 0000:00:13.2: OHCI Host Controller
> <6>[    1.164382] ohci_hcd 0000:00:13.2: new USB bus registered,
> assigned bus number 4
> <6>[    1.168223] ohci_hcd 0000:00:13.2: irq 18, io mem 0xfe02c000
> <6>[    1.227200] hub 4-0:1.0: USB hub found
> <6>[    1.231033] hub 4-0:1.0: 2 ports detected
> <6>[    1.234933] ohci_hcd 0000:00:13.3: PCI INT B -> GSI 17 (level,
> low) -> IRQ 17
> <6>[    1.238842] ohci_hcd 0000:00:13.3: OHCI Host Controller
> <6>[    1.242681] ohci_hcd 0000:00:13.3: new USB bus registered,
> assigned bus number 5
> <6>[    1.246479] ohci_hcd 0000:00:13.3: irq 17, io mem 0xfe02b000
> <6>[    1.305213] hub 5-0:1.0: USB hub found
> <6>[    1.308955] hub 5-0:1.0: 2 ports detected
> <6>[    1.312685] ohci_hcd 0000:00:13.4: PCI INT C -> GSI 18 (level,
> low) -> IRQ 18
> <6>[    1.316546] ohci_hcd 0000:00:13.4: OHCI Host Controller
> <6>[    1.320414] ohci_hcd 0000:00:13.4: new USB bus registered,
> assigned bus number 6
> <6>[    1.324322] ohci_hcd 0000:00:13.4: irq 18, io mem 0xfe02a000
> <6>[    1.383199] hub 6-0:1.0: USB hub found
> <6>[    1.386963] hub 6-0:1.0: 2 ports detected
> <6>[    1.390919] i8042: PNP: No PS/2 controller found. Probing ports
> directly.
> <6>[    1.395041] serio: i8042 KBD port at 0x60,0x64 irq 1
> <6>[    1.398776] serio: i8042 AUX port at 0x60,0x64 irq 12
> <6>[    1.402722] mousedev: PS/2 mouse device common for all mice
> <4>[    1.406734] k8temp 0000:00:18.3: Temperature readouts might be
> wrong - check erratum #141
> <6>[    1.410564] md: linear personality registered for level -1
> <6>[    1.414467] device-mapper: uevent: version 1.0.3
> <6>[    1.418353] device-mapper: ioctl: 4.20.0-ioctl (2011-02-02)
> initialised: dm-devel@redhat.com
> <6>[    1.422227] Bluetooth: Generic Bluetooth USB driver ver 0.6
> <6>[    1.426078] usbcore: registered new interface driver btusb
> <6>[    1.429817] cpuidle: using governor ladder
> <6>[    1.433651] cpuidle: using governor menu
> <6>[    1.437958] ALSA device list:
> <6>[    1.441821]   No soundcards found.
> <6>[    1.445603] TCP cubic registered
> <6>[    1.449478] NET: Registered protocol family 17
> <6>[    1.453450] Bluetooth: RFCOMM TTY layer initialized
> <6>[    1.457444] Bluetooth: RFCOMM socket layer initialized
> <6>[    1.461277] Bluetooth: RFCOMM ver 1.11
> <6>[    1.465147] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
> <6>[    1.469069] Bluetooth: BNEP filters: protocol multicast
> <6>[    1.472805] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
> <3>[    1.485024] ata3: softreset failed (device not ready)
> <4>[    1.488759] ata3: applying SB600 PMP SRST workaround and retrying
> <3>[    1.492492] ata4: softreset failed (device not ready)
> <4>[    1.496196] ata4: applying SB600 PMP SRST workaround and retrying
> <3>[    1.499986] ata1: softreset failed (device not ready)
> <4>[    1.503793] ata1: applying SB600 PMP SRST workaround and retrying
> <3>[    1.507574] ata2: softreset failed (device not ready)
> <4>[    1.511337] ata2: applying SB600 PMP SRST workaround and retrying
> <6>[    1.622017] usb 3-2: new full speed USB device number 2 using ohci_hcd
> <6>[    1.668031] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> <6>[    1.671934] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> <6>[    1.675739] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> <6>[    1.679444] ata4.00: ATAPI: TSSTcorp CDDVDW SH-S203P, SB00, max
> UDMA/100
> <6>[    1.683287] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[    1.687113] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> <6>[    1.691537] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[    1.695323] ata4.00: configured for UDMA/100
> <6>[    1.700031] ata1.00: ATA-8: SAMSUNG HD501LJ, CR100-11, max UDMA7
> <6>[    1.703902] ata1.00: 976773168 sectors, multi 1: LBA48 NCQ (depth
> 31/32), AA
> <6>[    1.707754] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[    1.711623] ata2.00: ATA-8: WDC WD15EADS-00P8B0, 01.00A01, max
> UDMA/133
> <6>[    1.715580] ata2.00: 2930277168 sectors, multi 1: LBA48 NCQ (depth
> 31/32), AA
> <6>[    1.719509] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[    1.723448] ata3.00: ATA-8: WDC WD3200BEVT-00ZCT0, 11.01A11, max
> UDMA/133
> <6>[    1.727246] ata3.00: 625142448 sectors, multi 1: LBA48 NCQ (depth
> 31/32), AA
> <6>[    1.731213] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[    1.735231] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[    1.739203] ata1.00: configured for UDMA/133
> <6>[    1.743246] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[    1.747072] ata2.00: configured for UDMA/133
> <6>[    1.751221] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[    1.755133] ata3.00: configured for UDMA/133
> <5>[    1.755260] scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG
> HD501LJ  CR10 PQ: 0 ANSI: 5
> <5>[    1.755439] sd 0:0:0:0: [sda] 976773168 512-byte logical blocks:
> (500 GB/465 GiB)
> <5>[    1.755470] sd 0:0:0:0: [sda] Write Protect is off
> <7>[    1.755473] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> <5>[    1.755486] sd 0:0:0:0: [sda] Write cache: enabled, read cache:
> enabled, doesn't support DPO or FUA
> <5>[    1.775104] scsi 1:0:0:0: Direct-Access     ATA      WDC
> WD15EADS-00P 01.0 PQ: 0 ANSI: 5
> <5>[    1.779395] sd 1:0:0:0: [sdb] 2930277168 512-byte logical blocks:
> (1.50 TB/1.36 TiB)
> <5>[    1.783594] sd 1:0:0:0: [sdb] Write Protect is off
> <6>[    1.784992]  sda: sda1 sda2 sda3 sda4
> <5>[    1.791774] scsi 2:0:0:0: Direct-Access     ATA      WDC
> WD3200BEVT-0 11.0 PQ: 0 ANSI: 5
> <5>[    1.791922] sd 0:0:0:0: [sda] Attached SCSI disk
> <7>[    1.800097] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
> <5>[    1.800114] sd 1:0:0:0: [sdb] Write cache: enabled, read cache:
> enabled, doesn't support DPO or FUA
> <5>[    1.802222] sd 2:0:0:0: [sdc] 625142448 512-byte logical blocks:
> (320 GB/298 GiB)
> <5>[    1.802250] sd 2:0:0:0: [sdc] Write Protect is off
> <7>[    1.802252] sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
> <5>[    1.802265] sd 2:0:0:0: [sdc] Write cache: enabled, read cache:
> enabled, doesn't support DPO or FUA
> <5>[    1.803110] scsi 3:0:0:0: CD-ROM            TSSTcorp CDDVDW
> SH-S203P  SB00 PQ: 0 ANSI: 5
> <4>[    1.805473] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw
> xa/form2 cdda tray
> <6>[    1.805476] cdrom: Uniform CD-ROM driver Revision: 3.20
> <7>[    1.805578] sr 3:0:0:0: Attached scsi CD-ROM sr0
> <6>[    1.840855]  sdb: sdb1 sdb2 sdb3 sdb4
> <5>[    1.845456] sd 1:0:0:0: [sdb] Attached SCSI disk
> <6>[    1.869474]  sdc: sdc1 sdc2 sdc3 sdc4 < sdc5 sdc6 sdc7 sdc8 >
> <5>[    1.874567] sd 2:0:0:0: [sdc] Attached SCSI disk
> <3>[    1.880107] drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
> <6>[    1.884470] powernow-k8: Found 1 AMD Athlon(tm) 64 X2 Dual Core
> Processor 5600+ (2 cpu cores) (version 2.20.00)
> <6>[    1.888971] powernow-k8: fid 0x14 (2800 MHz), vid 0x8
> <6>[    1.893330] powernow-k8: fid 0x12 (2600 MHz), vid 0xa
> <6>[    1.897685] powernow-k8: fid 0x10 (2400 MHz), vid 0xc
> <6>[    1.902065] powernow-k8: fid 0xe (2200 MHz), vid 0xe
> <6>[    1.906447] powernow-k8: fid 0xc (2000 MHz), vid 0x10
> <6>[    1.910640] powernow-k8: fid 0xa (1800 MHz), vid 0x10
> <6>[    1.914932] powernow-k8: fid 0x2 (1000 MHz), vid 0x12
> <6>[    1.919340] md: Skipping autodetection of RAID arrays.
> (raid=autodetect will force)
> <6>[    1.942021] usb 5-1: new low speed USB device number 2 using ohci_hcd
> <6>[    1.946734] EXT3-fs (sda3): recovery required on readonly filesystem
> <6>[    1.951191] EXT3-fs (sda3): write access will be enabled during
> recovery
> <6>[    1.960877] EXT3-fs: barriers not enabled
> <6>[    4.943453] kjournald starting.  Commit interval 5 seconds
> <6>[    4.943542] EXT3-fs (sda3): recovery complete
> <6>[    4.952803] EXT3-fs (sda3): mounted filesystem with writeback data
> mode
> <6>[    4.952840] VFS: Mounted root (ext3 filesystem) readonly on device
> 8:3.
> <6>[    4.970346] Freeing unused kernel memory: 464k freed
> <6>[   10.173643] udev[1060]: starting version 164
> <6>[   10.422157] piix4_smbus 0000:00:14.0: SMBus Host Controller at
> 0xb00, revision 0
> <6>[   10.459852] input: PC Speaker as /devices/platform/pcspkr/input/input2
> <6>[   10.781082] atiixp 0000:00:14.1: IDE controller (0x1002:0x438c rev
> 0x00)
> <6>[   10.781119] ATIIXP_IDE 0000:00:14.1: PCI INT A -> GSI 16 (level,
> low) -> IRQ 16
> <6>[   10.781161] atiixp 0000:00:14.1: not 100% native mode: will probe
> irqs later
> <6>[   10.781174]     ide0: BM-DMA at 0xf900-0xf907
> <7>[   10.781195] Probing IDE interface ide0...
> <6>[   10.784479] rtc_cmos 00:03: RTC can wake from S4
> <6>[   10.784723] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
> <6>[   10.784773] rtc0: alarms up to one month, 242 bytes nvram
> <6>[   10.798403] IT8716 SuperIO detected.
> <6>[   10.798851] parport_pc 00:09: reported by Plug and Play ACPI
> <6>[   10.798891] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE,EPP]
> <6>[   10.822534] input: iMON Panel, Knob and Mouse(15c2:ffdc) as
> /devices/pci0000:00/0000:00:13.3/usb5/5-1/5-1:1.0/input/input3
> <6>[   10.838543] IR NEC protocol handler initialized
> <6>[   10.843050] imon 5-1:1.0: 0xffdc iMON VFD, MCE IR (id 0x9e)
> <6>[   10.863737] IR RC5(x) protocol handler initialized
> <6>[   10.874936] IR RC6 protocol handler initialized
> <6>[   10.878390] Linux video capture interface: v2.00
> <6>[   10.882403] Registered IR keymap rc-imon-mce
> <6>[   10.882636] input: iMON Remote (15c2:ffdc) as
> /devices/pci0000:00/0000:00:13.3/usb5/5-1/5-1:1.0/rc/rc0/input4
> <6>[   10.882733] rc0: iMON Remote (15c2:ffdc) as
> /devices/pci0000:00/0000:00:13.3/usb5/5-1/5-1:1.0/rc/rc0
> <6>[   10.883595] IR JVC protocol handler initialized
> <6>[   10.891254] usbcore: registered new interface driver imon
> <6>[   10.959690] IR Sony protocol handler initialized
> <5>[   10.961908] sd 0:0:0:0: Attached scsi generic sg0 type 0
> <5>[   10.964687] sd 1:0:0:0: Attached scsi generic sg1 type 0
> <5>[   10.964861] sd 2:0:0:0: Attached scsi generic sg2 type 0
> <5>[   10.965072] sr 3:0:0:0: Attached scsi generic sg3 type 5
> <6>[   11.051295] lirc_dev: IR Remote Control driver registered, major 252
> <6>[   11.059645] IR LIRC bridge handler initialized
> <6>[   11.078276] saa7130/34: v4l2 driver version 0.2.16 loaded
> <6>[   11.078413] saa7134 0000:03:06.0: PCI INT A -> GSI 21 (level, low)
> -> IRQ 21
> <6>[   11.078428] saa7133[0]: found at 0000:03:06.0, rev: 209, irq: 21,
> latency: 64, mmio: 0xfdeff000
> <6>[   11.078442] saa7133[0]: subsystem: 11bd:002f, board: Pinnacle PCTV
> 310i [card=101,autodetected]
> <6>[   11.078485] saa7133[0]: board init: gpio is 600e000
> <4>[   11.181175] saa7133[0]: i2c eeprom read error (err=-5)
> <6>[   11.297213] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
> <6>[   11.297438] HDA Intel 0000:00:14.2: PCI INT A -> GSI 16 (level,
> low) -> IRQ 16
> <4>[   11.370229] i2c-core: driver [tuner] using legacy suspend method
> <4>[   11.370237] i2c-core: driver [tuner] using legacy resume method
> <6>[   11.420119] HDA Intel 0000:01:05.2: PCI INT B -> GSI 19 (level,
> low) -> IRQ 19
> <7>[   11.420203] HDA Intel 0000:01:05.2: irq 42 for MSI/MSI-X
> <6>[   11.653024] tuner 5-004b: Tuner -1 found with type(s) Radio TV.
> <6>[   11.688021] tda829x 5-004b: setting tuner address to 61
> <6>[   11.726241] tda829x 5-004b: ANDERS: setting switch_addr. was 0x00,
> new 0x4b
> <6>[   11.726245] tda829x 5-004b: ANDERS: new 0x61
> <6>[   11.732019] tda829x 5-004b: type set to tda8290+75a
> <4>[   14.427011] hda-intel: azx_get_response timeout, switching to
> polling mode: last cmd=0x000f0000
> <6>[   14.723096] saa7133[0]: registered device video0 [v4l2]
> <6>[   14.723138] saa7133[0]: registered device vbi0
> <6>[   14.723175] saa7133[0]: registered device radio0
> <6>[   14.743776] dvb_init() allocating 1 frontend
> <6>[   14.768849] DVB: registering new adapter (saa7133[0])
> <4>[   14.768855] DVB: registering adapter 0 frontend 0 (Philips
> TDA10046H DVB-T)...
> <6>[   14.897019] tda1004x: setting up plls for 48MHz sampling clock
> <4>[   15.428014] hda-intel: No response from codec, disabling MSI: last
> cmd=0x000f0000
> <6>[   15.855029] tda1004x: found firmware revision 0 -- invalid
> <6>[   15.855032] tda1004x: trying to boot from eeprom
> <6>[   16.340019] tda1004x: found firmware revision 0 -- invalid
> <6>[   16.340021] tda1004x: waiting for firmware upload...
> <3>[   16.371086] tda1004x: no firmware upload (timeout or file not found?)
> <4>[   16.371089] tda1004x: firmware upload failed
> <4>[   16.429010] hda-intel: Codec #0 probe error; disabling it...
> <6>[   16.485184] saa7134 ALSA driver for DMA sound loaded
> <6>[   16.485206] saa7133[0]/alsa: saa7133[0] at 0xfdeff000 irq 21
> registered as card -1
> <3>[   18.540010] hda_intel: azx_get_response timeout, switching to
> single_cmd mode: last cmd=0x00070503
> <3>[   18.541755] hda-codec: No codec parser is available
> <6>[   61.254539] EXT3-fs (sda3): using internal journal
> <6>[   61.418982] EXT3-fs: barriers not enabled
> <6>[   61.421281] kjournald starting.  Commit interval 5 seconds
> <6>[   61.421643] EXT3-fs (sda1): using internal journal
> <6>[   61.421653] EXT3-fs (sda1): mounted filesystem with writeback data
> mode
> <6>[   61.443600] EXT3-fs: barriers not enabled
> <6>[   61.456383] kjournald starting.  Commit interval 5 seconds
> <6>[   61.456633] EXT3-fs (dm-1): using internal journal
> <6>[   61.456641] EXT3-fs (dm-1): mounted filesystem with writeback data
> mode
> <6>[   61.544696] EXT3-fs: barriers not enabled
> <6>[   61.553285] kjournald starting.  Commit interval 5 seconds
> <6>[   61.553598] EXT3-fs (dm-2): using internal journal
> <6>[   61.553606] EXT3-fs (dm-2): mounted filesystem with writeback data
> mode
> <6>[   61.572435] EXT3-fs: barriers not enabled
> <6>[   61.585392] kjournald starting.  Commit interval 5 seconds
> <6>[   61.585753] EXT3-fs (dm-3): using internal journal
> <6>[   61.585761] EXT3-fs (dm-3): mounted filesystem with writeback data
> mode
> <6>[   61.622480] EXT4-fs (dm-4): mounted filesystem with ordered data
> mode. Opts: (null)
> <6>[   61.772903] EXT4-fs (dm-7): mounted filesystem with ordered data
> mode. Opts: (null)
> <6>[   61.812758] EXT3-fs: barriers not enabled
> <6>[   61.816780] kjournald starting.  Commit interval 5 seconds
> <6>[   61.816917] EXT3-fs (dm-5): using internal journal
> <6>[   61.816921] EXT3-fs (dm-5): mounted filesystem with writeback data
> mode
> <6>[   61.877352] EXT4-fs (dm-6): mounted filesystem with ordered data
> mode. Opts: (null)
> <6>[   61.926082] EXT4-fs (dm-0): mounted filesystem without journal.
> Opts: (null)
> <6>[   64.437185] Adding 10490440k swap on /dev/sda2.  Priority:-1
> extents:1 across:10490440k
> <6>[   64.945247] r8169 0000:02:00.0: eth0: link down
> <6>[   64.945261] r8169 0000:02:00.0: eth0: link down
> <6>[   66.674646] r8169 0000:02:00.0: eth0: link up
> <3>[ 8144.296653] [drm:drm_edid_block_valid] *ERROR* EDID checksum is
> invalid, remainder is 160
> <3>[ 8144.296657] Raw EDID:
> <7>[ 8144.296669] <3>1f ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[ 8144.296672] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[ 8144.296674] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[ 8144.296676] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[ 8144.296678] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[ 8144.296680] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[ 8144.296682] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[ 8144.296684] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <3>[ 8144.296686]
> <3>[12483.585101] [drm:drm_edid_block_valid] *ERROR* EDID checksum is
> invalid, remainder is 146
> <3>[12483.585109] Raw EDID:
> <7>[12483.585115] <3>9e 8c 0a d0 8a 20 e0 2d 10 10 3e 96 00 a0 5a 00
> ..... .-..>...Z.
> <7>[12483.585122] <3>00 00 18 00 00 00 00 00 00 00 00 00 00 00 00 00
> ................
> <7>[12483.585128] <3>00 00 00 dc 00 ff ff ff ff ff ff 00 4c 2d 9f 02
> ............L-..
> <7>[12483.585134] <3>00 00 00 00 2d 10 01 03 80 10 09 78 0a ae a5 a6
> ....-......x....
> <7>[12483.585140] <3>54 4c 99 26 14 50 54 a1 08 00 81 80 01 01 01 01
> TL.&.PT.........
> <7>[12483.585145] <3>01 01 01 01 01 01 01 01 01 01 02 3a 80 18 71 38
> ...........:..q8
> <7>[12483.585151] <3>2d 40 58 2c 45 00 a0 5a 00 00 00 1e 01 1d 00 72
> -@X,E..Z.......r
> <7>[12483.585157] <3>51 d0 1e 20 6e 28 55 00 a0 5a 00 00 00 1e 00 00
> Q.. n(U..Z......
> <3>[12483.585161]
> <3>[13071.640801] [drm:drm_edid_block_valid] *ERROR* EDID checksum is
> invalid, remainder is 136
> <3>[13071.640804] Raw EDID:
> <7>[13071.640807] <3>07 ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[13071.640809] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[13071.640811] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[13071.640813] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[13071.640815] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[13071.640817] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[13071.640819] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[13071.640821] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <3>[13071.640823]
> <3>[13983.945180] [drm:drm_edid_block_valid] *ERROR* EDID checksum is
> invalid, remainder is 57
> <3>[13983.945188] Raw EDID:
> <7>[13983.945194] <3>b8 2d 01 1d 00 bc 52 d0 1e 20 b8 28 55 40 a0 5a
> .-....R.. .(U@.Z
> <7>[13983.945201] <3>00 00 00 1e 01 1d 80 18 71 1c 16 20 58 2c 25 00
> ........q.. X,%.
> <7>[13983.945207] <3>a0 5a 00 00 00 9e 01 1d 80 d0 72 1c 16 20 10 2c
> .Z........r.. .,
> <7>[13983.945212] <3>25 80 a0 5a 00 00 00 9e 8c 0a d0 8a 20 e0 2d 10
> %..Z........ .-.
> <7>[13983.945218] <3>10 3e 96 00 a0 5a 00 00 00 18 00 00 00 00 00 00
> .>...Z..........
> <7>[13983.945224] <3>00 00 00 00 00 00 00 00 00 00 dc 00 ff ff ff ff
> ................
> <7>[13983.945229] <3>ff ff 00 4c 2d 9f 02 00 00 00 00 2d 10 01 03 80
> ...L-......-....
> <7>[13983.945235] <3>10 09 78 0a ae a5 a6 54 4c 99 26 14 50 54 a1 08
> ..x....TL.&.PT..
> <3>[13983.945240]
> <6>[19564.918465] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19564.920526] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19564.920537] ata1.00: configured for UDMA/133
> <6>[19564.920544] ata1: EH complete
> <6>[19565.647364] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19565.651362] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19565.651370] ata2.00: configured for UDMA/133
> <6>[19565.651379] ata2: EH complete
> <6>[19567.832804] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19567.834789] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19567.834798] ata3.00: configured for UDMA/133
> <6>[19567.834807] ata3: EH complete
> <6>[19568.031266] EXT4-fs (dm-4): re-mounted. Opts: commit=0
> <6>[19568.039121] EXT4-fs (dm-7): re-mounted. Opts: commit=0
> <6>[19568.053889] EXT4-fs (dm-6): re-mounted. Opts: commit=0
> <6>[19568.061766] EXT4-fs (dm-0): re-mounted. Opts: commit=0
> <6>[19568.657334] PM: Syncing filesystems ... done.
> <4>[19568.822346] Freezing user space processes ...
> <3>[19568.827021] imon:send_packet: task interrupted
> <4>[19568.833028] (elapsed 0.01 seconds) done.
> <4>[19568.833031] Freezing remaining freezable tasks ... (elapsed 0.01
> seconds) done.
> <4>[19568.844033] Suspending console(s) (use no_console_suspend to debug)
> <5>[19568.844516] sd 2:0:0:0: [sdc] Synchronizing SCSI cache
> <5>[19568.844574] sd 1:0:0:0: [sdb] Synchronizing SCSI cache
> <5>[19568.844636] sd 0:0:0:0: [sda] Synchronizing SCSI cache
> <5>[19568.844701] sd 2:0:0:0: [sdc] Stopping disk
> <5>[19568.844704] sd 1:0:0:0: [sdb] Stopping disk
> <6>[19568.844811] parport_pc 00:09: disabled
> <6>[19568.844874] serial 00:08: disabled
> <6>[19568.844895] serial 00:08: wake-up capability disabled by ACPI
> <7>[19568.845014] ACPI handle has no context!
> <6>[19568.845458] r8169 0000:02:00.0: eth0: link down
> <6>[19568.847470] ATIIXP_IDE 0000:00:14.1: PCI INT A disabled
> <6>[19568.847503] ehci_hcd 0000:00:13.5: PCI INT D disabled
> <6>[19568.847513] ohci_hcd 0000:00:13.4: PCI INT C disabled
> <6>[19568.847548] ohci_hcd 0000:00:13.2: PCI INT C disabled
> <6>[19568.847583] ohci_hcd 0000:00:13.0: PCI INT A disabled
> <6>[19568.855038] ohci_hcd 0000:00:13.3: PCI INT B disabled
> <6>[19568.857035] ohci_hcd 0000:00:13.1: PCI INT B disabled
> <5>[19568.869576] sd 0:0:0:0: [sda] Stopping disk
> <6>[19568.878604] radeon 0000:01:05.0: PCI INT A disabled
> <6>[19568.946025] HDA Intel 0000:01:05.2: PCI INT B disabled
> <7>[19568.946034] ACPI handle has no context!
> <6>[19568.948104] HDA Intel 0000:00:14.2: PCI INT A disabled
> <6>[19569.553243] ahci 0000:00:12.0: PCI INT A disabled
> <6>[19569.553270] PM: suspend of devices complete after 708.961 msecs
> <7>[19569.553498] r8169 0000:02:00.0: PME# enabled
> <6>[19569.553507] pcieport 0000:00:07.0: wake-up capability enabled by ACPI
> <6>[19569.575150] PM: late suspend of devices complete after 21.876 msecs
> <6>[19569.575352] ACPI: Preparing to enter system sleep state S3
> <6>[19569.575432] PM: Saving platform NVS memory
> <4>[19569.575463] Disabling non-boot CPUs ...
> <6>[19569.576856] CPU 1 is now offline
> <6>[19569.577338] ACPI: Low-level resume complete
> <6>[19569.577338] PM: Restoring platform NVS memory
> <6>[19569.577338] Enabling non-boot CPUs ...
> <6>[19569.579574] Booting Node 0 Processor 1 APIC 0x1
> <7>[19569.579575] smpboot cpu 1: start_ip = 9a000
> <6>[19569.650306] CPU1 is up
> <6>[19569.650531] ACPI: Waking up from system sleep state S3
> <7>[19569.650654] pci 0000:00:00.0: restoring config space at offset 0x3
> (was 0x0, writing 0x4000)
> <7>[19569.650678] pcieport 0000:00:07.0: restoring config space at
> offset 0x1 (was 0x100007, writing 0x100407)
> <7>[19569.650712] ahci 0000:00:12.0: restoring config space at offset
> 0x2 (was 0x1018f00, writing 0x1060100)
> <6>[19569.650730] ahci 0000:00:12.0: set SATA to AHCI mode
> <7>[19569.650751] ohci_hcd 0000:00:13.0: restoring config space at
> offset 0x1 (was 0x2a00007, writing 0x2a00003)
> <7>[19569.650777] ohci_hcd 0000:00:13.1: restoring config space at
> offset 0x1 (was 0x2a00007, writing 0x2a00003)
> <7>[19569.650803] ohci_hcd 0000:00:13.2: restoring config space at
> offset 0x1 (was 0x2a00007, writing 0x2a00003)
> <7>[19569.650828] ohci_hcd 0000:00:13.3: restoring config space at
> offset 0x1 (was 0x2a00007, writing 0x2a00003)
> <7>[19569.650854] ohci_hcd 0000:00:13.4: restoring config space at
> offset 0x1 (was 0x2a00007, writing 0x2a00003)
> <7>[19569.650886] ehci_hcd 0000:00:13.5: restoring config space at
> offset 0x1 (was 0x2b00000, writing 0x2b00013)
> <7>[19569.650971] HDA Intel 0000:00:14.2: restoring config space at
> offset 0x1 (was 0x4100006, writing 0x4100002)
> <6>[19569.651024] Switched to NOHz mode on CPU #1
> <7>[19569.651071] radeon 0000:01:05.0: restoring config space at offset
> 0x1 (was 0x100007, writing 0x20100007)
> <7>[19569.651079] HDA Intel 0000:01:05.2: restoring config space at
> offset 0xf (was 0x200, writing 0x20a)
> <7>[19569.651084] HDA Intel 0000:01:05.2: restoring config space at
> offset 0x4 (was 0x4, writing 0xfdbfc004)
> <7>[19569.651087] HDA Intel 0000:01:05.2: restoring config space at
> offset 0x3 (was 0x0, writing 0x4008)
> <7>[19569.651090] HDA Intel 0000:01:05.2: restoring config space at
> offset 0x1 (was 0x100000, writing 0x100002)
> <7>[19569.651113] r8169 0000:02:00.0: restoring config space at offset
> 0xf (was 0x100, writing 0x10a)
> <7>[19569.651127] r8169 0000:02:00.0: restoring config space at offset
> 0x6 (was 0x4, writing 0xfdfff004)
> <7>[19569.651133] r8169 0000:02:00.0: restoring config space at offset
> 0x4 (was 0x1, writing 0xee01)
> <7>[19569.651138] r8169 0000:02:00.0: restoring config space at offset
> 0x3 (was 0x0, writing 0x8)
> <7>[19569.651144] r8169 0000:02:00.0: restoring config space at offset
> 0x1 (was 0x100000, writing 0x100407)
> <7>[19569.651186] saa7134 0000:03:06.0: restoring config space at offset
> 0xf (was 0x2054015f, writing 0x205401ff)
> <7>[19569.651206] saa7134 0000:03:06.0: restoring config space at offset
> 0x4 (was 0x502800, writing 0xfdeff000)
> <7>[19569.651212] saa7134 0000:03:06.0: restoring config space at offset
> 0x3 (was 0xff00, writing 0x4000)
> <7>[19569.651218] saa7134 0000:03:06.0: restoring config space at offset
> 0x1 (was 0x2900100, writing 0x2900006)
> <7>[19569.651240] pci 0000:03:07.0: restoring config space at offset 0xf
> (was 0x200001ff, writing 0x2000010b)
> <7>[19569.651260] pci 0000:03:07.0: restoring config space at offset 0x5
> (was 0x1, writing 0xcf01)
> <7>[19569.651266] pci 0000:03:07.0: restoring config space at offset 0x4
> (was 0xfdeff000, writing 0xfdefe000)
> <7>[19569.651271] pci 0000:03:07.0: restoring config space at offset 0x3
> (was 0x4000, writing 0x4008)
> <7>[19569.651278] pci 0000:03:07.0: restoring config space at offset 0x1
> (was 0x2100006, writing 0x2100007)
> <6>[19569.651418] PM: early resume of devices complete after 0.789 msecs
> <6>[19569.651535] ahci 0000:00:12.0: PCI INT A -> GSI 22 (level, low) ->
> IRQ 22
> <6>[19569.651540] ohci_hcd 0000:00:13.0: PCI INT A -> GSI 16 (level,
> low) -> IRQ 16
> <6>[19569.651563] ohci_hcd 0000:00:13.1: PCI INT B -> GSI 17 (level,
> low) -> IRQ 17
> <6>[19569.651584] ohci_hcd 0000:00:13.2: PCI INT C -> GSI 18 (level,
> low) -> IRQ 18
> <6>[19569.651606] ohci_hcd 0000:00:13.3: PCI INT B -> GSI 17 (level,
> low) -> IRQ 17
> <6>[19569.651610] ohci_hcd 0000:00:13.4: PCI INT C -> GSI 18 (level,
> low) -> IRQ 18
> <6>[19569.651657] ehci_hcd 0000:00:13.5: PCI INT D -> GSI 19 (level,
> low) -> IRQ 19
> <6>[19569.651699] ATIIXP_IDE 0000:00:14.1: PCI INT A -> GSI 16 (level,
> low) -> IRQ 16
> <6>[19569.651712] HDA Intel 0000:00:14.2: PCI INT A -> GSI 16 (level,
> low) -> IRQ 16
> <6>[19569.651760] radeon 0000:01:05.0: PCI INT A -> GSI 18 (level, low)
> -> IRQ 18
> <6>[19569.651804] HDA Intel 0000:01:05.2: PCI INT B -> GSI 19 (level,
> low) -> IRQ 19
> <6>[19569.651810] pcieport 0000:00:07.0: wake-up capability disabled by ACPI
> <7>[19569.651815] r8169 0000:02:00.0: PME# disabled
> <6>[19569.651818] saa7133[0]: board init: gpio is 600c000
> <5>[19569.652038] sd 0:0:0:0: [sda] Starting disk
> <5>[19569.652082] sd 1:0:0:0: [sdb] Starting disk
> <5>[19569.652113] sd 2:0:0:0: [sdc] Starting disk
> <6>[19569.653460] serial 00:08: activated
> <6>[19569.653767] parport_pc 00:09: activated
> <6>[19569.657040] r8169 0000:02:00.0: eth0: link down
> <6>[19569.739029] [drm] radeon: 1 quad pipes, 1 z pipes initialized.
> <6>[19569.745171] radeon 0000:01:05.0: WB enabled
> <6>[19569.745202] [drm] radeon: ring at 0x0000000080001000
> <6>[19569.745220] [drm] ring test succeeded in 1 usecs
> <6>[19569.745229] [drm] ib test succeeded in 0 usecs
> <3>[19570.111015] ata4: softreset failed (device not ready)
> <4>[19570.111018] ata4: applying SB600 PMP SRST workaround and retrying
> <6>[19570.266026] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> <6>[19570.267170] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19570.309719] ata4.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19570.309722] ata4.00: configured for UDMA/100
> <6>[19571.383160] r8169 0000:02:00.0: eth0: link up
> <3>[19572.814024] ata3: softreset failed (device not ready)
> <4>[19572.814027] ata3: applying SB600 PMP SRST workaround and retrying
> <6>[19572.969037] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> <6>[19572.999062] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19573.000028] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19573.000030] ata3.00: configured for UDMA/133
> <3>[19577.353025] ata1: softreset failed (device not ready)
> <4>[19577.353028] ata1: applying SB600 PMP SRST workaround and retrying
> <6>[19577.508038] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> <6>[19577.528631] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19577.530662] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19577.530664] ata1.00: configured for UDMA/133
> <3>[19578.220015] ata2: softreset failed (device not ready)
> <4>[19578.220018] ata2: applying SB600 PMP SRST workaround and retrying
> <6>[19578.375024] ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
> <6>[19580.082542] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19580.085911] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19580.085913] ata2.00: configured for UDMA/133
> <6>[19580.672045] PM: resume of devices complete after 11020.548 msecs
> <4>[19580.672196] Restarting tasks ... done.
> <3>[19581.050987] [drm:drm_edid_block_valid] *ERROR* EDID checksum is
> invalid, remainder is 35
> <3>[19581.050989] Raw EDID:
> <7>[19581.050992] <3>99 26 0f 50 54 af cf 00 a9 40 81 80 61 40 01 01
> .&.PT....@..a@..
> <7>[19581.050994] <3>01 01 01 01 01 01 01 01 1a 36 80 a0 70 38 1f 40
> .........6..p8.@
> <7>[19581.050997] <3>30 20 35 00 fa 3d 32 00 00 1a 30 2a 00 98 51 00  0
> 5..=2...0*..Q.
> <7>[19581.051358] <3>2a 40 30 70 13 00 fa 3d 32 00 00 1e 00 00 00 fc
> *@0p...=2.......
> <7>[19581.051361] <3>00 53 41 4d 53 55 4e 47 0a 20 20 20 20 20 00 00
> .SAMSUNG.     ..
> <7>[19581.051363] <3>00 fd 00 38 4b 1e 50 0e 00 0a 20 20 20 20 20 20
> ...8K.P...
> <7>[19581.051365] <3>00 cc ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <7>[19581.051367] <3>ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> ................
> <3>[19581.051368]
> <6>[19581.063089] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19581.065102] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19581.065106] ata1.00: configured for UDMA/133
> <6>[19581.065108] ata1: EH complete
> <6>[19581.380667] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19581.384027] ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19581.384029] ata2.00: configured for UDMA/133
> <6>[19581.384032] ata2: EH complete
> <6>[19582.019137] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19582.020161] ata3.00: SB600 AHCI: limiting to 255 sectors per cmd
> <6>[19582.020165] ata3.00: configured for UDMA/133
> <6>[19582.020172] ata3: EH complete
> <6>[19582.108757] EXT4-fs (dm-4): re-mounted. Opts: commit=0
> <6>[19582.116213] EXT4-fs (dm-7): re-mounted. Opts: commit=0
> <6>[19582.129690] EXT4-fs (dm-6): re-mounted. Opts: commit=0
> <6>[19582.136600] EXT4-fs (dm-0): re-mounted. Opts: commit=0
> <6>[19682.474035] usb 4-2: new low speed USB device number 2 using ohci_hcd
> <6>[19682.715376] usbcore: registered new interface driver usbhid
> <6>[19682.715383] usbhid: USB HID core driver
> <6>[19682.738047] input: MLK TB-104 as
> /devices/pci0000:00/0000:00:13.2/usb4/4-2/4-2:1.0/input/input5
> <6>[19682.738263] sunplus 0003:04FC:05D8.0001: input: USB HID v1.00
> Keyboard [MLK TB-104] on usb-0000:00:13.2-2/input0
> <6>[19682.743827] sunplus 0003:04FC:05D8.0002: fixing up Sunplus
> Wireless Desktop report descriptor
> <6>[19682.749336] input: MLK TB-104 as
> /devices/pci0000:00/0000:00:13.2/usb4/4-2/4-2:1.1/input/input6
> <6>[19682.751668] sunplus 0003:04FC:05D8.0002: input,hiddev0: USB HID
> v1.00 Mouse [MLK TB-104] on usb-0000:00:13.2-2/input1
> <6>[27002.832843] usb 4-2: USB disconnect, device number 2
> <1>[28054.549637] BUG: unable to handle kernel NULL pointer dereference
> at 000000000000000c
> <1>[28054.549872] IP: [<ffffffff810a5e1f>] valid_swaphandles+0x68/0xf3
> <4>[28054.550047] PGD 6f556067 PUD 6884a067 PMD 0
> <0>[28054.550174] Oops: 0000 [#1] PREEMPT SMP
> <4>[28054.550288] CPU 1
> <4>[28054.550343] Modules linked in: hid_sunplus usbhid saa7134_alsa
> tda1004x saa7134_dvb videobuf_dvb dvb_core ir_kbd_i2c tda827x tda8290
> snd_hda_codec_realtek tuner saa7134 videobuf_dma_sg ir_lirc_codec
> lirc_dev videobuf_core sg ir_sony_decoder v4l2_common ir_jvc_decoder
> videodev ir_rc6_decoder ir_rc5_decoder rc_imon_mce v4l2_compat_ioctl32
> snd_hda_intel tveeprom ir_nec_decoder imon rc_core parport_pc rtc_cmos
> atiixp snd_hda_codec parport pcspkr snd_hwdep i2c_piix4 asus_atk0110
> <4>[28054.550429]
> <4>[28054.550429] Pid: 29246, comm: python2.6 Not tainted 3.0.3-dirty
> #37 System manufacturer System Product Name/M2A-VM HDMI
> <4>[28054.550429] RIP: 0010:[<ffffffff810a5e1f>]  [<ffffffff810a5e1f>]
> valid_swaphandles+0x68/0xf3
> <4>[28054.550429] RSP: 0000:ffff88006a78fd18  EFLAGS: 00210246
> <4>[28054.550429] RAX: 0000000000001717 RBX: 0040cfc05040d140 RCX:
> 0000000000000003
> <4>[28054.550429] RDX: ffff88006b7a4a68 RSI: ffff88006a78fd70 RDI:
> ffffffff817ea0b4
> <4>[28054.550429] RBP: 0040cfc05040d140 R08: 0000000000000001 R09:
> ffff88006b7a4a68
> <4>[28054.550429] R10: 0000000000000000 R11: ffffffff00000001 R12:
> 0040cfc05040d140
> <4>[28054.550429] R13: 0000000000000000 R14: ffff88006a78fd70 R15:
> 0000000000000000
> <4>[28054.550429] FS:  00007f3ad67d6700(0000) GS:ffff880077c80000(0000)
> knlGS:0000000000000000
> <4>[28054.550429] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> <4>[28054.550429] CR2: 000000000000000c CR3: 0000000068ea2000 CR4:
> 00000000000006e0
> <4>[28054.550429] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> <4>[28054.550429] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> <4>[28054.550429] Process python2.6 (pid: 29246, threadinfo
> ffff88006a78e000, task ffff88004c77b990)
> <0>[28054.550429] Stack:
> <4>[28054.550429]  0000000000000040 ffff880000000003 ffff88006a78fd48
> 8040cfc05040d140
> <4>[28054.550429]  8000000000000000 ffff88006f4b8180 ffff88006b7a4a68
> 00007f3ad07da650
> <4>[28054.550429]  00000000000200da ffffffff810a51a7 0000000000000008
> ffff88006a78fcd8
> <0>[28054.550429] Call Trace:
> <4>[28054.550429]  [<ffffffff810a51a7>] ? swapin_readahead+0x2f/0x98
> <4>[28054.550429]  [<ffffffff81098041>] ? handle_pte_fault+0x34d/0x70a
> <4>[28054.550429]  [<ffffffff810ab79f>] ?
> mem_cgroup_count_vm_event+0x15/0x67
> <4>[28054.550429]  [<ffffffff810987e5>] ? handle_mm_fault+0x3b/0x1e8
> <4>[28054.550429]  [<ffffffff8101bdb0>] ? do_page_fault+0x31a/0x33f
> <4>[28054.550429]  [<ffffffff810b207b>] ? do_readv_writev+0x15f/0x174
> <4>[28054.550429]  [<ffffffff8104bb23>] ? ktime_get_ts+0x65/0xa6
> <4>[28054.550429]  [<ffffffff810bfd2c>] ?
> poll_select_copy_remaining+0xce/0xed
> <4>[28054.550429]  [<ffffffff8104bc6e>] ? getnstimeofday+0x54/0xa5
> <4>[28054.550429]  [<ffffffff814c4b4f>] ? page_fault+0x1f/0x30
> <0>[28054.550429] Code: c7 c7 b4 a0 7e 81 48 89 eb 4c 8b 2c c5 c0 a0 7e
> 81 89 4c 24 08 48 d3 eb 48 d3 e3 48 85 db 4c 0f 45 e3 e8 65 e4 41 00 8b
> 4c 24 08
> <41>[28054.550429]  8b 55 0c b8 01 00 00 00 d3 e0 48 98 48 01 c3 48 39
> d3 48 0f
> <1>[28054.550429] RIP  [<ffffffff810a5e1f>] valid_swaphandles+0x68/0xf3
> <4>[28054.550429]  RSP <ffff88006a78fd18>
> <0>[28054.550429] CR2: 000000000000000c
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
