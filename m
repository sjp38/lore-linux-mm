Message-ID: <46F14B67.5010807@andrew.cmu.edu>
Date: Wed, 19 Sep 2007 12:16:39 -0400
From: Low Yucheng <ylow@andrew.cmu.edu>
MIME-Version: 1.0
Subject: Re: PROBLEM: System Freeze on Particular workload with kernel 2.6.22.6
References: <46F0E19D.8000400@andrew.cmu.edu> <E1IY1mO-00067S-7v@flower>
In-Reply-To: <E1IY1mO-00067S-7v@flower>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Verych <olecom@flower.upol.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

There are no additional console messages.
Not sure what this is: * no relevant Cc (memory management added)

But output of dmesg as requested:

[    0.000000] Linux version 2.6.22.6intelcore2 (root@mossnew) (gcc version 4.1.2 (Ubuntu 4.1.2-0ubuntu4)) #1 SMP Sat Sep 15 00:29:00 EDT 2007
[    0.000000] Command line: root=UUID=07b82da5-efcc-4d75-a31b-c01ccc3b2c14 ro quiet splash
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007ff80000 (usable)
[    0.000000]  BIOS-e820: 000000007ff80000 - 000000007ff8e000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007ff8e000 - 000000007ffe0000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007ffe0000 - 0000000080000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
[    0.000000] Entering add_active_range(0, 0, 159) 0 entries of 3200 used
[    0.000000] Entering add_active_range(0, 256, 524160) 1 entries of 3200 used
[    0.000000] end_pfn_map = 1048576
[    0.000000] DMI 2.4 present.
[    0.000000] ACPI: RSDP 000FBCD0, 0014 (r0 ACPIAM)
[    0.000000] ACPI: RSDT 7FF80000, 003C (r1 A_M_I_ OEMRSDT   7000703 MSFT       97)
[    0.000000] ACPI: FACP 7FF80200, 0084 (r2 A_M_I_ OEMFACP   7000703 MSFT       97)
[    0.000000] ACPI: DSDT 7FF805C0, 8C00 (r1  A0751 A0751055       55 INTL 20060113)
[    0.000000] ACPI: FACS 7FF8E000, 0040
[    0.000000] ACPI: APIC 7FF80390, 006C (r1 A_M_I_ OEMAPIC   7000703 MSFT       97)
[    0.000000] ACPI: MCFG 7FF80400, 003C (r1 A_M_I_ OEMMCFG   7000703 MSFT       97)
[    0.000000] ACPI: OEMB 7FF8E040, 0081 (r1 A_M_I_ AMI_OEM   7000703 MSFT       97)
[    0.000000] ACPI: HPET 7FF891C0, 0038 (r1 A_M_I_ OEMHPET   7000703 MSFT       97)
[    0.000000] ACPI: OSFR 7FF89200, 00B0 (r1 A_M_I_ OEMOSFR   7000703 MSFT       97)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-000000007ff80000
[    0.000000] Entering add_active_range(0, 0, 159) 0 entries of 3200 used
[    0.000000] Entering add_active_range(0, 256, 524160) 1 entries of 3200 used
[    0.000000] Bootmem setup node 0 0000000000000000-000000007ff80000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   DMA32        4096 ->  1048576
[    0.000000]   Normal    1048576 ->  1048576
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0:        0 ->      159
[    0.000000]     0:      256 ->   524160
[    0.000000] On node 0 totalpages: 524063
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 1101 pages reserved
[    0.000000]   DMA zone: 2842 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 7110 pages used for memmap
[    0.000000]   DMA32 zone: 512954 pages, LIFO batch:31
[    0.000000]   Normal zone: 0 pages used for memmap
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] Processor #0 (Bootup-CPU)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] Processor #1
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Setting APIC routing to flat
[    0.000000] ACPI: HPET id: 0xffffffff base: 0xfed00000
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] Allocating PCI resources starting at 88000000 (gap: 80000000:7ee00000)
[    0.000000] PERCPU: Allocating 34056 bytes of per cpu data
[    0.000000] Built 1 zonelists.  Total pages: 515796
[    0.000000] Kernel command line: root=UUID=07b82da5-efcc-4d75-a31b-c01ccc3b2c14 ro quiet splash
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[   22.596350] time.c: Detected 2671.602 MHz processor.
[   22.597239] Console: colour VGA+ 80x25
[   22.597251] Checking aperture...
[   22.597258] Calgary: detecting Calgary via BIOS EBDA area
[   22.597259] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[   22.612686] Memory: 2026004k/2096640k available (2266k kernel code, 70248k reserved, 1174k data, 320k init)
[   22.612719] SLUB: Genslabs=23, HWalign=64, Order=0-1, MinObjects=4, CPUs=2, Nodes=1
[   22.690848] Calibrating delay using timer specific routine.. 5346.72 BogoMIPS (lpj=10693452)
[   22.690872] Security Framework v1.0.0 initialized
[   22.690877] SELinux:  Disabled at boot.
[   22.691015] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
[   22.691970] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
[   22.692413] Mount-cache hash table entries: 256
[   22.692509] CPU: L1 I cache: 32K, L1 D cache: 32K
[   22.692511] CPU: L2 cache: 4096K
[   22.692513] CPU 0/0 -> Node 0
[   22.692515] using mwait in idle threads.
[   22.692516] CPU: Physical Processor ID: 0
[   22.692517] CPU: Processor Core ID: 0
[   22.692522] CPU0: Thermal monitoring enabled (TM2)
[   22.692529] Freeing SMP alternatives: 23k freed
[   22.693208] ACPI: Core revision 20070126
[   22.773878] Using local APIC timer interrupts.
[   22.815659] result 20871890
[   22.815660] Detected 20.871 MHz APIC timer.
[   22.818802] Booting processor 1/2 APIC 0x1
[   22.829113] Initializing CPU#1
[   22.906682] Calibrating delay using timer specific routine.. 5343.20 BogoMIPS (lpj=10686416)
[   22.906687] CPU: L1 I cache: 32K, L1 D cache: 32K
[   22.906688] CPU: L2 cache: 4096K
[   22.906690] CPU 1/1 -> Node 0
[   22.906691] CPU: Physical Processor ID: 0
[   22.906692] CPU: Processor Core ID: 1
[   22.906696] CPU1: Thermal monitoring enabled (TM2)
[   22.907072] Intel(R) Core(TM)2 Duo CPU     E6750  @ 2.66GHz stepping 0b
[   22.907137] checking TSC synchronization [CPU#0 -> CPU#1]: passed.
[   22.930672] Brought up 2 CPUs
[   22.976106] migration_cost=9
[   22.976161] PM: Adding info for No Bus:platform
[   22.976230] NET: Registered protocol family 16
[   22.976252] PM: Adding info for No Bus:vtcon0
[   22.976285] ACPI: bus type pci registered
[   22.976293] PCI: BIOS Bug: MCFG area at e0000000 is not E820-reserved
[   22.976323] PCI: Not using MMCONFIG.
[   22.976350] PCI: Using configuration type 1
[   22.981704] ACPI: Interpreter enabled
[   22.981705] ACPI: Using IOAPIC for interrupt routing
[   22.981756] PM: Adding info for acpi:acpi_system:00
[   22.981783] PM: Adding info for acpi:button_power:00
[   22.981812] PM: Adding info for acpi:ACPI0007:00
[   22.981836] PM: Adding info for acpi:ACPI0007:01
[   22.981859] PM: Adding info for acpi:ACPI0007:02
[   22.981882] PM: Adding info for acpi:ACPI0007:03
[   22.981915] PM: Adding info for acpi:device:00
[   22.982204] PM: Adding info for acpi:PNP0A08:00
[   22.982234] PM: Adding info for acpi:PNP0C01:00
[   22.982350] PM: Adding info for acpi:device:01
[   22.982462] PM: Adding info for acpi:device:02
[   22.982494] PM: Adding info for acpi:device:03
[   22.982792] PM: Adding info for acpi:PNP0000:00
[   22.982826] PM: Adding info for acpi:PNP0200:00
[   22.982853] PM: Adding info for acpi:PNP0100:00
[   22.982880] PM: Adding info for acpi:PNP0B00:00
[   22.982909] PM: Adding info for acpi:PNP0800:00
[   22.982939] PM: Adding info for acpi:PNP0C04:00
[   22.983308] PM: Adding info for acpi:PNP0700:00
[   22.983366] PM: Adding info for acpi:PNP0C02:00
[   22.983406] PM: Adding info for acpi:PNP0C02:01
[   22.983482] PM: Adding info for acpi:ATK0110:00
[   22.983632] PM: Adding info for acpi:PNP0103:00
[   22.984080] PM: Adding info for acpi:PNP0501:00
[   22.984111] PM: Adding info for acpi:PNP0C02:02
[   22.984285] PM: Adding info for acpi:PNP0303:00
[   22.984319] PM: Adding info for acpi:PNP0C02:03
[   22.984351] PM: Adding info for acpi:device:04
[   22.984381] PM: Adding info for acpi:device:05
[   22.984409] PM: Adding info for acpi:device:06
[   22.984438] PM: Adding info for acpi:device:07
[   22.984467] PM: Adding info for acpi:device:08
[   22.984497] PM: Adding info for acpi:device:09
[   22.984525] PM: Adding info for acpi:device:0a
[   22.984560] PM: Adding info for acpi:device:0b
[   22.984591] PM: Adding info for acpi:device:0c
[   22.984618] PM: Adding info for acpi:device:0d
[   22.984648] PM: Adding info for acpi:device:0e
[   22.984677] PM: Adding info for acpi:device:0f
[   22.984704] PM: Adding info for acpi:device:10
[   22.984731] PM: Adding info for acpi:device:11
[   22.984848] PM: Adding info for acpi:device:12
[   22.984963] PM: Adding info for acpi:device:13
[   22.985077] PM: Adding info for acpi:device:14
[   22.985190] PM: Adding info for acpi:device:15
[   22.985307] PM: Adding info for acpi:device:16
[   22.985420] PM: Adding info for acpi:device:17
[   22.985451] PM: Adding info for acpi:device:18
[   22.985482] PM: Adding info for acpi:device:19
[   22.985511] PM: Adding info for acpi:device:1a
[   22.985539] PM: Adding info for acpi:device:1b
[   22.985570] PM: Adding info for acpi:device:1c
[   22.985598] PM: Adding info for acpi:device:1d
[   22.985626] PM: Adding info for acpi:device:1e
[   22.985656] PM: Adding info for acpi:device:1f
[   22.985687] PM: Adding info for acpi:device:20
[   22.985714] PM: Adding info for acpi:device:21
[   22.985745] PM: Adding info for acpi:device:22
[   22.985775] PM: Adding info for acpi:device:23
[   22.985802] PM: Adding info for acpi:device:24
[   22.985830] PM: Adding info for acpi:device:25
[   22.985943] PM: Adding info for acpi:device:26
[   22.985976] PM: Adding info for acpi:device:27
[   22.986168] PM: Adding info for acpi:device:28
[   22.986362] PM: Adding info for acpi:device:29
[   22.986558] PM: Adding info for acpi:device:2a
[   22.986754] PM: Adding info for acpi:device:2b
[   22.986948] PM: Adding info for acpi:device:2c
[   22.987140] PM: Adding info for acpi:device:2d
[   22.987335] PM: Adding info for acpi:device:2e
[   22.987450] PM: Adding info for acpi:device:2f
[   22.987480] PM: Adding info for acpi:PNP0C01:01
[   22.987514] PM: Adding info for acpi:PNP0C0C:00
[   22.987650] PM: Adding info for acpi:PNP0C0F:00
[   22.987739] PM: Adding info for acpi:PNP0C0F:01
[   22.987827] PM: Adding info for acpi:PNP0C0F:02
[   22.987919] PM: Adding info for acpi:PNP0C0F:03
[   22.988009] PM: Adding info for acpi:PNP0C0F:04
[   22.988100] PM: Adding info for acpi:PNP0C0F:05
[   22.988190] PM: Adding info for acpi:PNP0C0F:06
[   22.988277] PM: Adding info for acpi:PNP0C0F:07
[   22.988310] PM: Adding info for acpi:thermal:00
[   22.988434] ACPI: PCI Root Bridge [PCI0] (0000:00)
[   22.988444] PCI: Probing PCI hardware (bus 00)
[   22.988449] PM: Adding info for No Bus:pci0000:00
[   22.989373] PCI: Transparent bridge - 0000:00:1e.0
[   22.989413] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[   22.989524] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
[   22.989588] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
[   22.989686] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P9._PRT]
[   22.989761] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
[   22.990446] PM: Adding info for pci:0000:00:00.0
[   22.991113] PM: Adding info for pci:0000:00:01.0
[   22.991758] PM: Adding info for pci:0000:00:1a.0
[   22.992404] PM: Adding info for pci:0000:00:1a.1
[   22.993047] PM: Adding info for pci:0000:00:1a.2
[   22.993692] PM: Adding info for pci:0000:00:1a.7
[   22.994333] PM: Adding info for pci:0000:00:1b.0
[   22.994983] PM: Adding info for pci:0000:00:1c.0
[   22.995627] PM: Adding info for pci:0000:00:1c.5
[   22.996272] PM: Adding info for pci:0000:00:1d.0
[   22.996916] PM: Adding info for pci:0000:00:1d.1
[   22.997559] PM: Adding info for pci:0000:00:1d.2
[   22.998204] PM: Adding info for pci:0000:00:1d.7
[   22.998869] PM: Adding info for pci:0000:00:1e.0
[   22.999514] PM: Adding info for pci:0000:00:1f.0
[   23.000156] PM: Adding info for pci:0000:00:1f.2
[   23.000801] PM: Adding info for pci:0000:00:1f.3
[   23.001446] PM: Adding info for pci:0000:00:1f.5
[   23.001472] PM: Adding info for pci:0000:01:00.0
[   23.001496] PM: Adding info for pci:0000:02:00.0
[   23.001522] PM: Adding info for pci:0000:04:03.0
[   23.001645] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[   23.001733] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[   23.001819] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 10 11 12 14 15)
[   23.001906] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 11 12 *14 15)
[   23.001992] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[   23.002078] ACPI: PCI Interrupt Link [LNKF] (IRQs *3 4 5 6 7 10 11 12 14 15)
[   23.002164] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 *15)
[   23.002251] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *7 10 11 12 14 15)
[   23.002322] Linux Plug and Play Support v0.97 (c) Adam Belay
[   23.002328] pnp: PnP ACPI init
[   23.002331] PM: Adding info for No Bus:pnp0
[   23.002336] ACPI: bus type pnp registered
[   23.002420] PM: Adding info for pnp:00:00
[   23.002448] PM: Adding info for pnp:00:01
[   23.002509] PM: Adding info for pnp:00:02
[   23.002545] PM: Adding info for pnp:00:03
[   23.002571] PM: Adding info for pnp:00:04
[   23.002601] PM: Adding info for pnp:00:05
[   23.003047] PM: Adding info for pnp:00:06
[   23.003116] PM: Adding info for pnp:00:07
[   23.003238] PM: Adding info for pnp:00:08
[   23.003378] PM: Adding info for pnp:00:09
[   23.003797] PM: Adding info for pnp:00:0a
[   23.003873] PM: Adding info for pnp:00:0b
[   23.003939] PM: Adding info for pnp:00:0c
[   23.004011] PM: Adding info for pnp:00:0d
[   23.004194] PM: Adding info for pnp:00:0e
[   23.004446] pnp: PnP ACPI: found 15 devices
[   23.004447] ACPI: ACPI bus type pnp unregistered
[   23.004511] PCI: Using ACPI for IRQ routing
[   23.004512] PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
[   23.004570] NET: Registered protocol family 8
[   23.004571] NET: Registered protocol family 20
[   23.004582] PCI-GART: No AMD northbridge found.
[   23.004585] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
[   23.004588] hpet0: 4 64-bit timers, 14318180 Hz
[   23.005618] pnp: 00:01: iomem range 0xfed14000-0xfed19fff has been reserved
[   23.005623] pnp: 00:07: ioport range 0x290-0x297 has been reserved
[   23.005626] pnp: 00:08: iomem range 0xfed1c000-0xfed1ffff has been reserved
[   23.005628] pnp: 00:08: iomem range 0xfed20000-0xfed3ffff has been reserved
[   23.005630] pnp: 00:08: iomem range 0xfed50000-0xfed8ffff has been reserved
[   23.005632] pnp: 00:08: iomem range 0xffa00000-0xffafffff has been reserved
[   23.005635] pnp: 00:0b: iomem range 0xfec00000-0xfec00fff has been reserved
[   23.005637] pnp: 00:0b: iomem range 0xfee00000-0xfee00fff could not be reserved
[   23.005641] pnp: 00:0d: iomem range 0xe0000000-0xefffffff has been reserved
[   23.005644] pnp: 00:0e: iomem range 0x0-0x9ffff could not be reserved
[   23.005645] pnp: 00:0e: iomem range 0xc0000-0xcffff has been reserved
[   23.005647] pnp: 00:0e: iomem range 0xe0000-0xfffff could not be reserved
[   23.005649] pnp: 00:0e: iomem range 0x100000-0x7fffffff could not be reserved
[   23.005658] PM: Adding info for No Bus:mem
[   23.005675] PM: Adding info for No Bus:kmem
[   23.005694] PM: Adding info for No Bus:null
[   23.005711] PM: Adding info for No Bus:port
[   23.005726] PM: Adding info for No Bus:zero
[   23.005742] PM: Adding info for No Bus:full
[   23.005758] PM: Adding info for No Bus:random
[   23.005776] PM: Adding info for No Bus:urandom
[   23.005793] PM: Adding info for No Bus:kmsg
[   23.005810] PM: Adding info for No Bus:oldmem
[   23.005843] PCI: Bridge: 0000:00:01.0
[   23.005845]   IO window: d000-dfff
[   23.005847]   MEM window: fc000000-fe9fffff
[   23.005849]   PREFETCH window: d0000000-dfffffff
[   23.005851] PCI: Bridge: 0000:00:1c.0
[   23.005852]   IO window: disabled.
[   23.005855]   MEM window: disabled.
[   23.005858]   PREFETCH window: faf00000-faffffff
[   23.005861] PCI: Bridge: 0000:00:1c.5
[   23.005862]   IO window: disabled.
[   23.005865]   MEM window: fea00000-feafffff
[   23.005868]   PREFETCH window: disabled.
[   23.005871] PCI: Bridge: 0000:00:1e.0
[   23.005872]   IO window: e000-efff
[   23.005876]   MEM window: feb00000-febfffff
[   23.005878]   PREFETCH window: disabled.
[   23.005888] ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 16 (level, low) -> IRQ 16
[   23.005891] PCI: Setting latency timer of device 0000:00:01.0 to 64
[   23.005902] ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 17 (level, low) -> IRQ 17
[   23.005906] PCI: Setting latency timer of device 0000:00:1c.0 to 64
[   23.005917] ACPI: PCI Interrupt 0000:00:1c.5[B] -> GSI 16 (level, low) -> IRQ 16
[   23.005920] PCI: Setting latency timer of device 0000:00:1c.5 to 64
[   23.005928] PCI: Setting latency timer of device 0000:00:1e.0 to 64
[   23.005935] NET: Registered protocol family 2
[   23.006607] Time: tsc clocksource has been installed.
[   23.046739] IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
[   23.047188] TCP established hash table entries: 262144 (order: 10, 6291456 bytes)
[   23.049200] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[   23.049604] TCP: Hash tables configured (established 262144 bind 65536)
[   23.049606] TCP reno registered
[   23.062844] checking if image is initramfs... it is
[   25.843466] Freeing initrd memory: 36987k freed
[   25.854935] PM: Adding info for No Bus:mcelog
[   25.855140] PM: Adding info for platform:pcspkr
[   25.855222] audit: initializing netlink socket (disabled)
[   25.855235] audit(1190175461.176:1): initialized
[   25.856573] VFS: Disk quotas dquot_6.5.1
[   25.856612] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[   25.856667] io scheduler noop registered
[   25.856668] io scheduler anticipatory registered
[   25.856670] io scheduler deadline registered
[   25.856729] io scheduler cfq registered (default)
[   25.859553] Boot video device is 0000:01:00.0
[   25.859645] PCI: Setting latency timer of device 0000:00:01.0 to 64
[   25.859666] assign_interrupt_mode Found MSI capability
[   25.859684] Allocate Port Service[0000:00:01.0:pcie00]
[   25.859689] PM: Adding info for pci_express:0000:00:01.0:pcie00
[   25.859733] PCI: Setting latency timer of device 0000:00:1c.0 to 64
[   25.859762] assign_interrupt_mode Found MSI capability
[   25.859785] Allocate Port Service[0000:00:1c.0:pcie00]
[   25.859790] PM: Adding info for pci_express:0000:00:1c.0:pcie00
[   25.859807] Allocate Port Service[0000:00:1c.0:pcie02]
[   25.859810] PM: Adding info for pci_express:0000:00:1c.0:pcie02
[   25.859859] PCI: Setting latency timer of device 0000:00:1c.5 to 64
[   25.859888] assign_interrupt_mode Found MSI capability
[   25.859911] Allocate Port Service[0000:00:1c.5:pcie00]
[   25.859914] PM: Adding info for pci_express:0000:00:1c.5:pcie00
[   25.859930] Allocate Port Service[0000:00:1c.5:pcie02]
[   25.859934] PM: Adding info for pci_express:0000:00:1c.5:pcie02
[   25.860018] PM: Adding info for platform:vesafb.0
[   25.860055] PM: Adding info for No Bus:tty
[   25.860074] PM: Adding info for No Bus:console
[   25.860090] PM: Adding info for No Bus:ptmx
[   25.860110] PM: Adding info for No Bus:tty0
[   25.860133] PM: Adding info for No Bus:vcs
[   25.860149] PM: Adding info for No Bus:vcsa
[   25.860167] PM: Adding info for No Bus:tty1
[   25.860186] PM: Adding info for No Bus:tty2
[   25.860203] PM: Adding info for No Bus:tty3
[   25.860219] PM: Adding info for No Bus:tty4
[   25.860240] PM: Adding info for No Bus:tty5
[   25.860256] PM: Adding info for No Bus:tty6
[   25.860273] PM: Adding info for No Bus:tty7
[   25.860288] PM: Adding info for No Bus:tty8
[   25.860305] PM: Adding info for No Bus:tty9
[   25.860321] PM: Adding info for No Bus:tty10
[   25.860340] PM: Adding info for No Bus:tty11
[   25.860358] PM: Adding info for No Bus:tty12
[   25.860374] PM: Adding info for No Bus:tty13
[   25.860390] PM: Adding info for No Bus:tty14
[   25.860408] PM: Adding info for No Bus:tty15
[   25.860427] PM: Adding info for No Bus:tty16
[   25.860443] PM: Adding info for No Bus:tty17
[   25.860464] PM: Adding info for No Bus:tty18
[   25.860483] PM: Adding info for No Bus:tty19
[   25.860499] PM: Adding info for No Bus:tty20
[   25.860515] PM: Adding info for No Bus:tty21
[   25.860531] PM: Adding info for No Bus:tty22
[   25.860551] PM: Adding info for No Bus:tty23
[   25.860569] PM: Adding info for No Bus:tty24
[   25.860589] PM: Adding info for No Bus:tty25
[   25.860607] PM: Adding info for No Bus:tty26
[   25.860626] PM: Adding info for No Bus:tty27
[   25.860642] PM: Adding info for No Bus:tty28
[   25.860658] PM: Adding info for No Bus:tty29
[   25.860679] PM: Adding info for No Bus:tty30
[   25.860698] PM: Adding info for No Bus:tty31
[   25.860715] PM: Adding info for No Bus:tty32
[   25.860732] PM: Adding info for No Bus:tty33
[   25.860749] PM: Adding info for No Bus:tty34
[   25.860768] PM: Adding info for No Bus:tty35
[   25.860785] PM: Adding info for No Bus:tty36
[   25.860805] PM: Adding info for No Bus:tty37
[   25.860822] PM: Adding info for No Bus:tty38
[   25.860840] PM: Adding info for No Bus:tty39
[   25.860858] PM: Adding info for No Bus:tty40
[   25.860874] PM: Adding info for No Bus:tty41
[   25.860892] PM: Adding info for No Bus:tty42
[   25.860909] PM: Adding info for No Bus:tty43
[   25.860929] PM: Adding info for No Bus:tty44
[   25.860946] PM: Adding info for No Bus:tty45
[   25.860964] PM: Adding info for No Bus:tty46
[   25.860984] PM: Adding info for No Bus:tty47
[   25.861000] PM: Adding info for No Bus:tty48
[   25.861018] PM: Adding info for No Bus:tty49
[   25.861034] PM: Adding info for No Bus:tty50
[   25.861055] PM: Adding info for No Bus:tty51
[   25.861072] PM: Adding info for No Bus:tty52
[   25.861089] PM: Adding info for No Bus:tty53
[   25.861108] PM: Adding info for No Bus:tty54
[   25.861126] PM: Adding info for No Bus:tty55
[   25.861143] PM: Adding info for No Bus:tty56
[   25.861161] PM: Adding info for No Bus:tty57
[   25.861179] PM: Adding info for No Bus:tty58
[   25.861197] PM: Adding info for No Bus:tty59
[   25.861216] PM: Adding info for No Bus:tty60
[   25.861236] PM: Adding info for No Bus:tty61
[   25.861254] PM: Adding info for No Bus:tty62
[   25.861272] PM: Adding info for No Bus:tty63
[   25.861312] PM: Adding info for No Bus:ptyp0
[   25.861330] PM: Adding info for No Bus:ptyp1
[   25.861347] PM: Adding info for No Bus:ptyp2
[   25.861364] PM: Adding info for No Bus:ptyp3
[   25.861383] PM: Adding info for No Bus:ptyp4
[   25.861399] PM: Adding info for No Bus:ptyp5
[   25.861417] PM: Adding info for No Bus:ptyp6
[   25.861436] PM: Adding info for No Bus:ptyp7
[   25.861454] PM: Adding info for No Bus:ptyp8
[   25.861472] PM: Adding info for No Bus:ptyp9
[   25.861488] PM: Adding info for No Bus:ptypa
[   25.861508] PM: Adding info for No Bus:ptypb
[   25.861524] PM: Adding info for No Bus:ptypc
[   25.861543] PM: Adding info for No Bus:ptypd
[   25.861560] PM: Adding info for No Bus:ptype
[   25.861580] PM: Adding info for No Bus:ptypf
[   25.861598] PM: Adding info for No Bus:ptyq0
[   25.861614] PM: Adding info for No Bus:ptyq1
[   25.861634] PM: Adding info for No Bus:ptyq2
[   25.861654] PM: Adding info for No Bus:ptyq3
[   25.861671] PM: Adding info for No Bus:ptyq4
[   25.861688] PM: Adding info for No Bus:ptyq5
[   25.861707] PM: Adding info for No Bus:ptyq6
[   25.861725] PM: Adding info for No Bus:ptyq7
[   25.861743] PM: Adding info for No Bus:ptyq8
[   25.861761] PM: Adding info for No Bus:ptyq9
[   25.861780] PM: Adding info for No Bus:ptyqa
[   25.861798] PM: Adding info for No Bus:ptyqb
[   25.861817] PM: Adding info for No Bus:ptyqc
[   25.861836] PM: Adding info for No Bus:ptyqd
[   25.861854] PM: Adding info for No Bus:ptyqe
[   25.861873] PM: Adding info for No Bus:ptyqf
[   25.861893] PM: Adding info for No Bus:ptyr0
[   25.861912] PM: Adding info for No Bus:ptyr1
[   25.861929] PM: Adding info for No Bus:ptyr2
[   25.861949] PM: Adding info for No Bus:ptyr3
[   25.861969] PM: Adding info for No Bus:ptyr4
[   25.861986] PM: Adding info for No Bus:ptyr5
[   25.862006] PM: Adding info for No Bus:ptyr6
[   25.862027] PM: Adding info for No Bus:ptyr7
[   25.862046] PM: Adding info for No Bus:ptyr8
[   25.862063] PM: Adding info for No Bus:ptyr9
[   25.862081] PM: Adding info for No Bus:ptyra
[   25.862101] PM: Adding info for No Bus:ptyrb
[   25.862119] PM: Adding info for No Bus:ptyrc
[   25.862136] PM: Adding info for No Bus:ptyrd
[   25.862158] PM: Adding info for No Bus:ptyre
[   25.862178] PM: Adding info for No Bus:ptyrf
[   25.862196] PM: Adding info for No Bus:ptys0
[   25.862213] PM: Adding info for No Bus:ptys1
[   25.862233] PM: Adding info for No Bus:ptys2
[   25.862253] PM: Adding info for No Bus:ptys3
[   25.862272] PM: Adding info for No Bus:ptys4
[   25.862291] PM: Adding info for No Bus:ptys5
[   25.862310] PM: Adding info for No Bus:ptys6
[   25.862330] PM: Adding info for No Bus:ptys7
[   25.862348] PM: Adding info for No Bus:ptys8
[   25.862369] PM: Adding info for No Bus:ptys9
[   25.862387] PM: Adding info for No Bus:ptysa
[   25.862408] PM: Adding info for No Bus:ptysb
[   25.862428] PM: Adding info for No Bus:ptysc
[   25.862446] PM: Adding info for No Bus:ptysd
[   25.862466] PM: Adding info for No Bus:ptyse
[   25.862485] PM: Adding info for No Bus:ptysf
[   25.862505] PM: Adding info for No Bus:ptyt0
[   25.862524] PM: Adding info for No Bus:ptyt1
[   25.862543] PM: Adding info for No Bus:ptyt2
[   25.862564] PM: Adding info for No Bus:ptyt3
[   25.862583] PM: Adding info for No Bus:ptyt4
[   25.862601] PM: Adding info for No Bus:ptyt5
[   25.862619] PM: Adding info for No Bus:ptyt6
[   25.862641] PM: Adding info for No Bus:ptyt7
[   25.862661] PM: Adding info for No Bus:ptyt8
[   25.862681] PM: Adding info for No Bus:ptyt9
[   25.862701] PM: Adding info for No Bus:ptyta
[   25.862721] PM: Adding info for No Bus:ptytb
[   25.862740] PM: Adding info for No Bus:ptytc
[   25.862759] PM: Adding info for No Bus:ptytd
[   25.862780] PM: Adding info for No Bus:ptyte
[   25.862801] PM: Adding info for No Bus:ptytf
[   25.862819] PM: Adding info for No Bus:ptyu0
[   25.862839] PM: Adding info for No Bus:ptyu1
[   25.862857] PM: Adding info for No Bus:ptyu2
[   25.862877] PM: Adding info for No Bus:ptyu3
[   25.862897] PM: Adding info for No Bus:ptyu4
[   25.862920] PM: Adding info for No Bus:ptyu5
[   25.862938] PM: Adding info for No Bus:ptyu6
[   25.862958] PM: Adding info for No Bus:ptyu7
[   25.862978] PM: Adding info for No Bus:ptyu8
[   25.862997] PM: Adding info for No Bus:ptyu9
[   25.863016] PM: Adding info for No Bus:ptyua
[   25.863036] PM: Adding info for No Bus:ptyub
[   25.863059] PM: Adding info for No Bus:ptyuc
[   25.863078] PM: Adding info for No Bus:ptyud
[   25.863100] PM: Adding info for No Bus:ptyue
[   25.863123] PM: Adding info for No Bus:ptyuf
[   25.863142] PM: Adding info for No Bus:ptyv0
[   25.863161] PM: Adding info for No Bus:ptyv1
[   25.863181] PM: Adding info for No Bus:ptyv2
[   25.863203] PM: Adding info for No Bus:ptyv3
[   25.863223] PM: Adding info for No Bus:ptyv4
[   25.863242] PM: Adding info for No Bus:ptyv5
[   25.863262] PM: Adding info for No Bus:ptyv6
[   25.863283] PM: Adding info for No Bus:ptyv7
[   25.863303] PM: Adding info for No Bus:ptyv8
[   25.863324] PM: Adding info for No Bus:ptyv9
[   25.863345] PM: Adding info for No Bus:ptyva
[   25.863367] PM: Adding info for No Bus:ptyvb
[   25.863386] PM: Adding info for No Bus:ptyvc
[   25.863406] PM: Adding info for No Bus:ptyvd
[   25.863427] PM: Adding info for No Bus:ptyve
[   25.863450] PM: Adding info for No Bus:ptyvf
[   25.863469] PM: Adding info for No Bus:ptyw0
[   25.863490] PM: Adding info for No Bus:ptyw1
[   25.863510] PM: Adding info for No Bus:ptyw2
[   25.863530] PM: Adding info for No Bus:ptyw3
[   25.863551] PM: Adding info for No Bus:ptyw4
[   25.863571] PM: Adding info for No Bus:ptyw5
[   25.863592] PM: Adding info for No Bus:ptyw6
[   25.863613] PM: Adding info for No Bus:ptyw7
[   25.863633] PM: Adding info for No Bus:ptyw8
[   25.863653] PM: Adding info for No Bus:ptyw9
[   25.863673] PM: Adding info for No Bus:ptywa
[   25.863697] PM: Adding info for No Bus:ptywb
[   25.863717] PM: Adding info for No Bus:ptywc
[   25.863738] PM: Adding info for No Bus:ptywd
[   25.863758] PM: Adding info for No Bus:ptywe
[   25.863780] PM: Adding info for No Bus:ptywf
[   25.863801] PM: Adding info for No Bus:ptyx0
[   25.863821] PM: Adding info for No Bus:ptyx1
[   25.863843] PM: Adding info for No Bus:ptyx2
[   25.863865] PM: Adding info for No Bus:ptyx3
[   25.863885] PM: Adding info for No Bus:ptyx4
[   25.863906] PM: Adding info for No Bus:ptyx5
[   25.863928] PM: Adding info for No Bus:ptyx6
[   25.863949] PM: Adding info for No Bus:ptyx7
[   25.863968] PM: Adding info for No Bus:ptyx8
[   25.863990] PM: Adding info for No Bus:ptyx9
[   25.864011] PM: Adding info for No Bus:ptyxa
[   25.864033] PM: Adding info for No Bus:ptyxb
[   25.864052] PM: Adding info for No Bus:ptyxc
[   25.864074] PM: Adding info for No Bus:ptyxd
[   25.864096] PM: Adding info for No Bus:ptyxe
[   25.864117] PM: Adding info for No Bus:ptyxf
[   25.864141] PM: Adding info for No Bus:ptyy0
[   25.864161] PM: Adding info for No Bus:ptyy1
[   25.864182] PM: Adding info for No Bus:ptyy2
[   25.864203] PM: Adding info for No Bus:ptyy3
[   25.864224] PM: Adding info for No Bus:ptyy4
[   25.864246] PM: Adding info for No Bus:ptyy5
[   25.864266] PM: Adding info for No Bus:ptyy6
[   25.864291] PM: Adding info for No Bus:ptyy7
[   25.864312] PM: Adding info for No Bus:ptyy8
[   25.864332] PM: Adding info for No Bus:ptyy9
[   25.864353] PM: Adding info for No Bus:ptyya
[   25.864376] PM: Adding info for No Bus:ptyyb
[   25.864396] PM: Adding info for No Bus:ptyyc
[   25.864418] PM: Adding info for No Bus:ptyyd
[   25.864441] PM: Adding info for No Bus:ptyye
[   25.864465] PM: Adding info for No Bus:ptyyf
[   25.864486] PM: Adding info for No Bus:ptyz0
[   25.864508] PM: Adding info for No Bus:ptyz1
[   25.864530] PM: Adding info for No Bus:ptyz2
[   25.864552] PM: Adding info for No Bus:ptyz3
[   25.864576] PM: Adding info for No Bus:ptyz4
[   25.864600] PM: Adding info for No Bus:ptyz5
[   25.864622] PM: Adding info for No Bus:ptyz6
[   25.864643] PM: Adding info for No Bus:ptyz7
[   25.864665] PM: Adding info for No Bus:ptyz8
[   25.864688] PM: Adding info for No Bus:ptyz9
[   25.864709] PM: Adding info for No Bus:ptyza
[   25.864733] PM: Adding info for No Bus:ptyzb
[   25.864757] PM: Adding info for No Bus:ptyzc
[   25.864778] PM: Adding info for No Bus:ptyzd
[   25.864799] PM: Adding info for No Bus:ptyze
[   25.864822] PM: Adding info for No Bus:ptyzf
[   25.864844] PM: Adding info for No Bus:ptya0
[   25.864866] PM: Adding info for No Bus:ptya1
[   25.864888] PM: Adding info for No Bus:ptya2
[   25.864911] PM: Adding info for No Bus:ptya3
[   25.864933] PM: Adding info for No Bus:ptya4
[   25.864955] PM: Adding info for No Bus:ptya5
[   25.864975] PM: Adding info for No Bus:ptya6
[   25.865000] PM: Adding info for No Bus:ptya7
[   25.865024] PM: Adding info for No Bus:ptya8
[   25.865045] PM: Adding info for No Bus:ptya9
[   25.865067] PM: Adding info for No Bus:ptyaa
[   25.865092] PM: Adding info for No Bus:ptyab
[   25.865114] PM: Adding info for No Bus:ptyac
[   25.865135] PM: Adding info for No Bus:ptyad
[   25.865161] PM: Adding info for No Bus:ptyae
[   25.865184] PM: Adding info for No Bus:ptyaf
[   25.865205] PM: Adding info for No Bus:ptyb0
[   25.865228] PM: Adding info for No Bus:ptyb1
[   25.865251] PM: Adding info for No Bus:ptyb2
[   25.865274] PM: Adding info for No Bus:ptyb3
[   25.865295] PM: Adding info for No Bus:ptyb4
[   25.865319] PM: Adding info for No Bus:ptyb5
[   25.865341] PM: Adding info for No Bus:ptyb6
[   25.865364] PM: Adding info for No Bus:ptyb7
[   25.865387] PM: Adding info for No Bus:ptyb8
[   25.865409] PM: Adding info for No Bus:ptyb9
[   25.865430] PM: Adding info for No Bus:ptyba
[   25.865454] PM: Adding info for No Bus:ptybb
[   25.865477] PM: Adding info for No Bus:ptybc
[   25.865499] PM: Adding info for No Bus:ptybd
[   25.865523] PM: Adding info for No Bus:ptybe
[   25.865548] PM: Adding info for No Bus:ptybf
[   25.865569] PM: Adding info for No Bus:ptyc0
[   25.865592] PM: Adding info for No Bus:ptyc1
[   25.865615] PM: Adding info for No Bus:ptyc2
[   25.865640] PM: Adding info for No Bus:ptyc3
[   25.865661] PM: Adding info for No Bus:ptyc4
[   25.865683] PM: Adding info for No Bus:ptyc5
[   25.865706] PM: Adding info for No Bus:ptyc6
[   25.865729] PM: Adding info for No Bus:ptyc7
[   25.865752] PM: Adding info for No Bus:ptyc8
[   25.865775] PM: Adding info for No Bus:ptyc9
[   25.865799] PM: Adding info for No Bus:ptyca
[   25.865822] PM: Adding info for No Bus:ptycb
[   25.865844] PM: Adding info for No Bus:ptycc
[   25.865868] PM: Adding info for No Bus:ptycd
[   25.865894] PM: Adding info for No Bus:ptyce
[   25.865920] PM: Adding info for No Bus:ptycf
[   25.865942] PM: Adding info for No Bus:ptyd0
[   25.865967] PM: Adding info for No Bus:ptyd1
[   25.865989] PM: Adding info for No Bus:ptyd2
[   25.866013] PM: Adding info for No Bus:ptyd3
[   25.866039] PM: Adding info for No Bus:ptyd4
[   25.866061] PM: Adding info for No Bus:ptyd5
[   25.866085] PM: Adding info for No Bus:ptyd6
[   25.866108] PM: Adding info for No Bus:ptyd7
[   25.866132] PM: Adding info for No Bus:ptyd8
[   25.866154] PM: Adding info for No Bus:ptyd9
[   25.866176] PM: Adding info for No Bus:ptyda
[   25.866201] PM: Adding info for No Bus:ptydb
[   25.866226] PM: Adding info for No Bus:ptydc
[   25.866249] PM: Adding info for No Bus:ptydd
[   25.866273] PM: Adding info for No Bus:ptyde
[   25.866298] PM: Adding info for No Bus:ptydf
[   25.866320] PM: Adding info for No Bus:ptye0
[   25.866343] PM: Adding info for No Bus:ptye1
[   25.866367] PM: Adding info for No Bus:ptye2
[   25.866391] PM: Adding info for No Bus:ptye3
[   25.866415] PM: Adding info for No Bus:ptye4
[   25.866438] PM: Adding info for No Bus:ptye5
[   25.866462] PM: Adding info for No Bus:ptye6
[   25.866486] PM: Adding info for No Bus:ptye7
[   25.866509] PM: Adding info for No Bus:ptye8
[   25.866535] PM: Adding info for No Bus:ptye9
[   25.866558] PM: Adding info for No Bus:ptyea
[   25.866583] PM: Adding info for No Bus:ptyeb
[   25.866606] PM: Adding info for No Bus:ptyec
[   25.866630] PM: Adding info for No Bus:ptyed
[   25.866654] PM: Adding info for No Bus:ptyee
[   25.866678] PM: Adding info for No Bus:ptyef
[   25.866706] PM: Adding info for No Bus:ttyp0
[   25.866728] PM: Adding info for No Bus:ttyp1
[   25.866749] PM: Adding info for No Bus:ttyp2
[   25.866773] PM: Adding info for No Bus:ttyp3
[   25.866796] PM: Adding info for No Bus:ttyp4
[   25.866817] PM: Adding info for No Bus:ttyp5
[   25.866839] PM: Adding info for No Bus:ttyp6
[   25.866866] PM: Adding info for No Bus:ttyp7
[   25.866887] PM: Adding info for No Bus:ttyp8
[   25.866909] PM: Adding info for No Bus:ttyp9
[   25.866932] PM: Adding info for No Bus:ttypa
[   25.866956] PM: Adding info for No Bus:ttypb
[   25.866978] PM: Adding info for No Bus:ttypc
[   25.867001] PM: Adding info for No Bus:ttypd
[   25.867026] PM: Adding info for No Bus:ttype
[   25.867050] PM: Adding info for No Bus:ttypf
[   25.867071] PM: Adding info for No Bus:ttyq0
[   25.867093] PM: Adding info for No Bus:ttyq1
[   25.867116] PM: Adding info for No Bus:ttyq2
[   25.867140] PM: Adding info for No Bus:ttyq3
[   25.867163] PM: Adding info for No Bus:ttyq4
[   25.867186] PM: Adding info for No Bus:ttyq5
[   25.867208] PM: Adding info for No Bus:ttyq6
[   25.867232] PM: Adding info for No Bus:ttyq7
[   25.867254] PM: Adding info for No Bus:ttyq8
[   25.867277] PM: Adding info for No Bus:ttyq9
[   25.867303] PM: Adding info for No Bus:ttyqa
[   25.867326] PM: Adding info for No Bus:ttyqb
[   25.867350] PM: Adding info for No Bus:ttyqc
[   25.867373] PM: Adding info for No Bus:ttyqd
[   25.867396] PM: Adding info for No Bus:ttyqe
[   25.867419] PM: Adding info for No Bus:ttyqf
[   25.867443] PM: Adding info for No Bus:ttyr0
[   25.867466] PM: Adding info for No Bus:ttyr1
[   25.867489] PM: Adding info for No Bus:ttyr2
[   25.867513] PM: Adding info for No Bus:ttyr3
[   25.867537] PM: Adding info for No Bus:ttyr4
[   25.867560] PM: Adding info for No Bus:ttyr5
[   25.867584] PM: Adding info for No Bus:ttyr6
[   25.867610] PM: Adding info for No Bus:ttyr7
[   25.867632] PM: Adding info for No Bus:ttyr8
[   25.867654] PM: Adding info for No Bus:ttyr9
[   25.867680] PM: Adding info for No Bus:ttyra
[   25.867704] PM: Adding info for No Bus:ttyrb
[   25.867726] PM: Adding info for No Bus:ttyrc
[   25.867750] PM: Adding info for No Bus:ttyrd
[   25.867777] PM: Adding info for No Bus:ttyre
[   25.867800] PM: Adding info for No Bus:ttyrf
[   25.867824] PM: Adding info for No Bus:ttys0
[   25.867848] PM: Adding info for No Bus:ttys1
[   25.867871] PM: Adding info for No Bus:ttys2
[   25.867895] PM: Adding info for No Bus:ttys3
[   25.867918] PM: Adding info for No Bus:ttys4
[   25.867943] PM: Adding info for No Bus:ttys5
[   25.867966] PM: Adding info for No Bus:ttys6
[   25.867989] PM: Adding info for No Bus:ttys7
[   25.868014] PM: Adding info for No Bus:ttys8
[   25.868038] PM: Adding info for No Bus:ttys9
[   25.868062] PM: Adding info for No Bus:ttysa
[   25.868088] PM: Adding info for No Bus:ttysb
[   25.868113] PM: Adding info for No Bus:ttysc
[   25.868135] PM: Adding info for No Bus:ttysd
[   25.868159] PM: Adding info for No Bus:ttyse
[   25.868185] PM: Adding info for No Bus:ttysf
[   25.868209] PM: Adding info for No Bus:ttyt0
[   25.868232] PM: Adding info for No Bus:ttyt1
[   25.868256] PM: Adding info for No Bus:ttyt2
[   25.868283] PM: Adding info for No Bus:ttyt3
[   25.868306] PM: Adding info for No Bus:ttyt4
[   25.868329] PM: Adding info for No Bus:ttyt5
[   25.868354] PM: Adding info for No Bus:ttyt6
[   25.868378] PM: Adding info for No Bus:ttyt7
[   25.868403] PM: Adding info for No Bus:ttyt8
[   25.868426] PM: Adding info for No Bus:ttyt9
[   25.868450] PM: Adding info for No Bus:ttyta
[   25.868477] PM: Adding info for No Bus:ttytb
[   25.868501] PM: Adding info for No Bus:ttytc
[   25.868526] PM: Adding info for No Bus:ttytd
[   25.868550] PM: Adding info for No Bus:ttyte
[   25.868577] PM: Adding info for No Bus:ttytf
[   25.868603] PM: Adding info for No Bus:ttyu0
[   25.868629] PM: Adding info for No Bus:ttyu1
[   25.868652] PM: Adding info for No Bus:ttyu2
[   25.868678] PM: Adding info for No Bus:ttyu3
[   25.868703] PM: Adding info for No Bus:ttyu4
[   25.868728] PM: Adding info for No Bus:ttyu5
[   25.868752] PM: Adding info for No Bus:ttyu6
[   25.868777] PM: Adding info for No Bus:ttyu7
[   25.868802] PM: Adding info for No Bus:ttyu8
[   25.868825] PM: Adding info for No Bus:ttyu9
[   25.868849] PM: Adding info for No Bus:ttyua
[   25.868875] PM: Adding info for No Bus:ttyub
[   25.868901] PM: Adding info for No Bus:ttyuc
[   25.868925] PM: Adding info for No Bus:ttyud
[   25.868951] PM: Adding info for No Bus:ttyue
[   25.868978] PM: Adding info for No Bus:ttyuf
[   25.869002] PM: Adding info for No Bus:ttyv0
[   25.869026] PM: Adding info for No Bus:ttyv1
[   25.869051] PM: Adding info for No Bus:ttyv2
[   25.869077] PM: Adding info for No Bus:ttyv3
[   25.869103] PM: Adding info for No Bus:ttyv4
[   25.869126] PM: Adding info for No Bus:ttyv5
[   25.869153] PM: Adding info for No Bus:ttyv6
[   25.869178] PM: Adding info for No Bus:ttyv7
[   25.869202] PM: Adding info for No Bus:ttyv8
[   25.869230] PM: Adding info for No Bus:ttyv9
[   25.869254] PM: Adding info for No Bus:ttyva
[   25.869279] PM: Adding info for No Bus:ttyvb
[   25.869303] PM: Adding info for No Bus:ttyvc
[   25.869329] PM: Adding info for No Bus:ttyvd
[   25.869354] PM: Adding info for No Bus:ttyve
[   25.869378] PM: Adding info for No Bus:ttyvf
[   25.869405] PM: Adding info for No Bus:ttyw0
[   25.869429] PM: Adding info for No Bus:ttyw1
[   25.869455] PM: Adding info for No Bus:ttyw2
[   25.869480] PM: Adding info for No Bus:ttyw3
[   25.869506] PM: Adding info for No Bus:ttyw4
[   25.869530] PM: Adding info for No Bus:ttyw5
[   25.869558] PM: Adding info for No Bus:ttyw6
[   25.869585] PM: Adding info for No Bus:ttyw7
[   25.869609] PM: Adding info for No Bus:ttyw8
[   25.869634] PM: Adding info for No Bus:ttyw9
[   25.869660] PM: Adding info for No Bus:ttywa
[   25.869687] PM: Adding info for No Bus:ttywb
[   25.869712] PM: Adding info for No Bus:ttywc
[   25.869739] PM: Adding info for No Bus:ttywd
[   25.869766] PM: Adding info for No Bus:ttywe
[   25.869791] PM: Adding info for No Bus:ttywf
[   25.869816] PM: Adding info for No Bus:ttyx0
[   25.869840] PM: Adding info for No Bus:ttyx1
[   25.869867] PM: Adding info for No Bus:ttyx2
[   25.869894] PM: Adding info for No Bus:ttyx3
[   25.869919] PM: Adding info for No Bus:ttyx4
[   25.869946] PM: Adding info for No Bus:ttyx5
[   25.869970] PM: Adding info for No Bus:ttyx6
[   25.869996] PM: Adding info for No Bus:ttyx7
[   25.870021] PM: Adding info for No Bus:ttyx8
[   25.870047] PM: Adding info for No Bus:ttyx9
[   25.870073] PM: Adding info for No Bus:ttyxa
[   25.870099] PM: Adding info for No Bus:ttyxb
[   25.870126] PM: Adding info for No Bus:ttyxc
[   25.870151] PM: Adding info for No Bus:ttyxd
[   25.870177] PM: Adding info for No Bus:ttyxe
[   25.870204] PM: Adding info for No Bus:ttyxf
[   25.870231] PM: Adding info for No Bus:ttyy0
[   25.870257] PM: Adding info for No Bus:ttyy1
[   25.870282] PM: Adding info for No Bus:ttyy2
[   25.870311] PM: Adding info for No Bus:ttyy3
[   25.870335] PM: Adding info for No Bus:ttyy4
[   25.870360] PM: Adding info for No Bus:ttyy5
[   25.870385] PM: Adding info for No Bus:ttyy6
[   25.870414] PM: Adding info for No Bus:ttyy7
[   25.870440] PM: Adding info for No Bus:ttyy8
[   25.870465] PM: Adding info for No Bus:ttyy9
[   25.870492] PM: Adding info for No Bus:ttyya
[   25.870519] PM: Adding info for No Bus:ttyyb
[   25.870544] PM: Adding info for No Bus:ttyyc
[   25.870570] PM: Adding info for No Bus:ttyyd
[   25.870600] PM: Adding info for No Bus:ttyye
[   25.870627] PM: Adding info for No Bus:ttyyf
[   25.870652] PM: Adding info for No Bus:ttyz0
[   25.870679] PM: Adding info for No Bus:ttyz1
[   25.870705] PM: Adding info for No Bus:ttyz2
[   25.870731] PM: Adding info for No Bus:ttyz3
[   25.870760] PM: Adding info for No Bus:ttyz4
[   25.870787] PM: Adding info for No Bus:ttyz5
[   25.870812] PM: Adding info for No Bus:ttyz6
[   25.870838] PM: Adding info for No Bus:ttyz7
[   25.870865] PM: Adding info for No Bus:ttyz8
[   25.870891] PM: Adding info for No Bus:ttyz9
[   25.870917] PM: Adding info for No Bus:ttyza
[   25.870945] PM: Adding info for No Bus:ttyzb
[   25.870973] PM: Adding info for No Bus:ttyzc
[   25.870998] PM: Adding info for No Bus:ttyzd
[   25.871025] PM: Adding info for No Bus:ttyze
[   25.871053] PM: Adding info for No Bus:ttyzf
[   25.871078] PM: Adding info for No Bus:ttya0
[   25.871105] PM: Adding info for No Bus:ttya1
[   25.871131] PM: Adding info for No Bus:ttya2
[   25.871160] PM: Adding info for No Bus:ttya3
[   25.871186] PM: Adding info for No Bus:ttya4
[   25.871213] PM: Adding info for No Bus:ttya5
[   25.871239] PM: Adding info for No Bus:ttya6
[   25.871267] PM: Adding info for No Bus:ttya7
[   25.871293] PM: Adding info for No Bus:ttya8
[   25.871319] PM: Adding info for No Bus:ttya9
[   25.871348] PM: Adding info for No Bus:ttyaa
[   25.871375] PM: Adding info for No Bus:ttyab
[   25.871401] PM: Adding info for No Bus:ttyac
[   25.871428] PM: Adding info for No Bus:ttyad
[   25.871456] PM: Adding info for No Bus:ttyae
[   25.871486] PM: Adding info for No Bus:ttyaf
[   25.871511] PM: Adding info for No Bus:ttyb0
[   25.871540] PM: Adding info for No Bus:ttyb1
[   25.871566] PM: Adding info for No Bus:ttyb2
[   25.871593] PM: Adding info for No Bus:ttyb3
[   25.871620] PM: Adding info for No Bus:ttyb4
[   25.871649] PM: Adding info for No Bus:ttyb5
[   25.871675] PM: Adding info for No Bus:ttyb6
[   25.871702] PM: Adding info for No Bus:ttyb7
[   25.871730] PM: Adding info for No Bus:ttyb8
[   25.871757] PM: Adding info for No Bus:ttyb9
[   25.871784] PM: Adding info for No Bus:ttyba
[   25.871812] PM: Adding info for No Bus:ttybb
[   25.871840] PM: Adding info for No Bus:ttybc
[   25.871866] PM: Adding info for No Bus:ttybd
[   25.871893] PM: Adding info for No Bus:ttybe
[   25.871921] PM: Adding info for No Bus:ttybf
[   25.871947] PM: Adding info for No Bus:ttyc0
[   25.871975] PM: Adding info for No Bus:ttyc1
[   25.872004] PM: Adding info for No Bus:ttyc2
[   25.872031] PM: Adding info for No Bus:ttyc3
[   25.872057] PM: Adding info for No Bus:ttyc4
[   25.872084] PM: Adding info for No Bus:ttyc5
[   25.872113] PM: Adding info for No Bus:ttyc6
[   25.872140] PM: Adding info for No Bus:ttyc7
[   25.872167] PM: Adding info for No Bus:ttyc8
[   25.872197] PM: Adding info for No Bus:ttyc9
[   25.872224] PM: Adding info for No Bus:ttyca
[   25.872252] PM: Adding info for No Bus:ttycb
[   25.872279] PM: Adding info for No Bus:ttycc
[   25.872307] PM: Adding info for No Bus:ttycd
[   25.872336] PM: Adding info for No Bus:ttyce
[   25.872366] PM: Adding info for No Bus:ttycf
[   25.872395] PM: Adding info for No Bus:ttyd0
[   25.872422] PM: Adding info for No Bus:ttyd1
[   25.872449] PM: Adding info for No Bus:ttyd2
[   25.872477] PM: Adding info for No Bus:ttyd3
[   25.872507] PM: Adding info for No Bus:ttyd4
[   25.872534] PM: Adding info for No Bus:ttyd5
[   25.872563] PM: Adding info for No Bus:ttyd6
[   25.872619] PM: Adding info for No Bus:ttyd7
[   25.872873] PM: Adding info for No Bus:ttyd8
[   25.872900] PM: Adding info for No Bus:ttyd9
[   25.872926] PM: Adding info for No Bus:ttyda
[   25.872955] PM: Adding info for No Bus:ttydb
[   25.872982] PM: Adding info for No Bus:ttydc
[   25.873010] PM: Adding info for No Bus:ttydd
[   25.873039] PM: Adding info for No Bus:ttyde
[   25.873067] PM: Adding info for No Bus:ttydf
[   25.873093] PM: Adding info for No Bus:ttye0
[   25.873120] PM: Adding info for No Bus:ttye1
[   25.873148] PM: Adding info for No Bus:ttye2
[   25.873178] PM: Adding info for No Bus:ttye3
[   25.873205] PM: Adding info for No Bus:ttye4
[   25.873234] PM: Adding info for No Bus:ttye5
[   25.873261] PM: Adding info for No Bus:ttye6
[   25.873288] PM: Adding info for No Bus:ttye7
[   25.873316] PM: Adding info for No Bus:ttye8
[   25.873345] PM: Adding info for No Bus:ttye9
[   25.873374] PM: Adding info for No Bus:ttyea
[   25.873403] PM: Adding info for No Bus:ttyeb
[   25.873431] PM: Adding info for No Bus:ttyec
[   25.873458] PM: Adding info for No Bus:ttyed
[   25.873486] PM: Adding info for No Bus:ttyee
[   25.873514] PM: Adding info for No Bus:ttyef
[   25.873546] PM: Adding info for No Bus:rtc
[   25.873571] Real Time Clock Driver v1.12ac
[   25.873574] PM: Adding info for No Bus:hpet
[   25.873688] hpet_resources: 0xfed00000 is busy
[   25.873716] Linux agpgart interface v0.102 (c) Dave Jones
[   25.873721] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
[   25.873733] PM: Adding info for platform:serial8250
[   25.873803] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   25.873822] PM: Adding info for No Bus:ttyS0
[   25.873859] PM: Adding info for No Bus:ttyS1
[   25.873896] PM: Adding info for No Bus:ttyS2
[   25.873934] PM: Adding info for No Bus:ttyS3
[   25.874090] PM: Removing info for No Bus:ttyS0
[   25.874172] 00:0a: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   25.874189] PM: Adding info for No Bus:ttyS0
[   25.874563] RAMDISK driver initialized: 16 RAM disks of 65536K size 1024 blocksize
[   25.874587] PM: Adding info for No Bus:lo
[   25.874616] Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
[   25.874619] ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
[   25.874713] Probing IDE interface ide0...
[   26.438773] Probing IDE interface ide1...
[   27.000541] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
[   27.000543] PNP: PS/2 controller doesn't have AUX irq; using default 12
[   27.000571] PM: Adding info for platform:i8042
[   27.002741] serio: i8042 KBD port at 0x60,0x64 irq 1
[   27.002744] serio: i8042 AUX port at 0x60,0x64 irq 12
[   27.002760] PM: Adding info for serio:serio0
[   27.002791] PM: Adding info for serio:serio1
[   27.002807] PM: Adding info for No Bus:psaux
[   27.002829] mice: PS/2 mouse device common for all mice
[   27.002902] TCP cubic registered
[   27.002941] NET: Registered protocol family 1
[   27.003050] drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
[   27.003054] Freeing unused kernel memory: 320k freed
[   27.003882] PM: Adding info for No Bus:vcs1
[   27.003926] PM: Adding info for No Bus:vcsa1
[   27.024508] input: AT Translated Set 2 keyboard as /class/input/input0
[   27.056029] PM: Adding info for No Bus:vcs2
[   27.056059] PM: Adding info for No Bus:vcsa2
[   27.056251] PM: Removing info for No Bus:vcs2
[   27.056270] PM: Removing info for No Bus:vcsa2
[   27.057030] PM: Adding info for No Bus:vcs2
[   27.057061] PM: Adding info for No Bus:vcsa2
[   27.059105] PM: Removing info for No Bus:vcs2
[   27.059127] PM: Removing info for No Bus:vcsa2
[   27.059682] PM: Adding info for No Bus:vcs2
[   27.059703] PM: Adding info for No Bus:vcsa2
[   27.060110] PM: Removing info for No Bus:vcs2
[   27.060131] PM: Removing info for No Bus:vcsa2
[   27.060499] PM: Adding info for No Bus:vcs3
[   27.060529] PM: Adding info for No Bus:vcsa3
[   27.060736] PM: Removing info for No Bus:vcs3
[   27.060754] PM: Removing info for No Bus:vcsa3
[   27.061508] PM: Adding info for No Bus:vcs3
[   27.061527] PM: Adding info for No Bus:vcsa3
[   27.063603] PM: Removing info for No Bus:vcs3
[   27.063622] PM: Removing info for No Bus:vcsa3
[   27.064177] PM: Adding info for No Bus:vcs3
[   27.064196] PM: Adding info for No Bus:vcsa3
[   27.064605] PM: Removing info for No Bus:vcs3
[   27.064625] PM: Removing info for No Bus:vcsa3
[   27.064983] PM: Adding info for No Bus:vcs4
[   27.065004] PM: Adding info for No Bus:vcsa4
[   27.065191] PM: Removing info for No Bus:vcs4
[   27.065210] PM: Removing info for No Bus:vcsa4
[   27.065957] PM: Adding info for No Bus:vcs4
[   27.065986] PM: Adding info for No Bus:vcsa4
[   27.068026] PM: Removing info for No Bus:vcs4
[   27.068047] PM: Removing info for No Bus:vcsa4
[   27.068607] PM: Adding info for No Bus:vcs4
[   27.068627] PM: Adding info for No Bus:vcsa4
[   27.069036] PM: Removing info for No Bus:vcs4
[   27.069054] PM: Removing info for No Bus:vcsa4
[   27.069413] PM: Adding info for No Bus:vcs5
[   27.069432] PM: Adding info for No Bus:vcsa5
[   27.069620] PM: Removing info for No Bus:vcs5
[   27.069637] PM: Removing info for No Bus:vcsa5
[   27.070387] PM: Adding info for No Bus:vcs5
[   27.070408] PM: Adding info for No Bus:vcsa5
[   27.072458] PM: Removing info for No Bus:vcs5
[   27.072486] PM: Removing info for No Bus:vcsa5
[   27.073034] PM: Adding info for No Bus:vcs5
[   27.073054] PM: Adding info for No Bus:vcsa5
[   27.073464] PM: Removing info for No Bus:vcs5
[   27.073484] PM: Removing info for No Bus:vcsa5
[   27.073842] PM: Adding info for No Bus:vcs6
[   27.073863] PM: Adding info for No Bus:vcsa6
[   27.074053] PM: Removing info for No Bus:vcs6
[   27.074072] PM: Removing info for No Bus:vcsa6
[   27.074816] PM: Adding info for No Bus:vcs6
[   27.074845] PM: Adding info for No Bus:vcsa6
[   27.076895] PM: Removing info for No Bus:vcs6
[   27.076917] PM: Removing info for No Bus:vcsa6
[   27.077469] PM: Adding info for No Bus:vcs6
[   27.077490] PM: Adding info for No Bus:vcsa6
[   27.077901] PM: Removing info for No Bus:vcs6
[   27.077919] PM: Removing info for No Bus:vcsa6
[   27.106607] PM: Adding info for No Bus:vcs8
[   27.106702] PM: Adding info for No Bus:vcsa8
[   28.351945] usbcore: registered new interface driver usbfs
[   28.351960] usbcore: registered new interface driver hub
[   28.351974] usbcore: registered new device driver usb
[   28.352636] USB Universal Host Controller Interface driver v3.0
[   28.352695] ACPI: PCI Interrupt 0000:00:1a.0[A] -> GSI 16 (level, low) -> IRQ 16
[   28.352703] PCI: Setting latency timer of device 0000:00:1a.0 to 64
[   28.352706] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[   28.352795] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 1
[   28.352817] uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000c800
[   28.352845] PM: Adding info for usb:usb1
[   28.352877] PM: Adding info for No Bus:usbdev1.1_ep00
[   28.352888] usb usb1: configuration #1 chosen from 1 choice
[   28.352894] PM: Adding info for usb:1-0:1.0
[   28.352904] hub 1-0:1.0: USB hub found
[   28.352907] hub 1-0:1.0: 2 ports detected
[   28.382757] SCSI subsystem initialized
[   28.392659] libata version 2.21 loaded.
[   28.418148] Floppy drive(s): fd0 is 1.44M
[   28.438218] FDC 0 is a post-1991 82077
[   28.439081] PM: Adding info for platform:floppy.0
[   28.454655] PM: Adding info for No Bus:usbdev1.1_ep81
[   28.454757] PM: Adding info for No Bus:usbdev1.1
[   28.454867] ACPI: PCI Interrupt 0000:00:1a.7[C] -> GSI 18 (level, low) -> IRQ 18
[   28.455564] PCI: Setting latency timer of device 0000:00:1a.7 to 64
[   28.455569] ehci_hcd 0000:00:1a.7: EHCI Host Controller
[   28.455607] ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 2
[   28.455636] ehci_hcd 0000:00:1a.7: debug port 1
[   28.455640] PCI: cache line size of 32 is not supported by device 0000:00:1a.7
[   28.455649] ehci_hcd 0000:00:1a.7: irq 18, io mem 0xfbfffc00
[   28.459534] ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
[   28.459551] PM: Adding info for usb:usb2
[   28.459584] PM: Adding info for No Bus:usbdev2.1_ep00
[   28.459594] usb usb2: configuration #1 chosen from 1 choice
[   28.459600] PM: Adding info for usb:2-0:1.0
[   28.459612] hub 2-0:1.0: USB hub found
[   28.459616] hub 2-0:1.0: 6 ports detected
[   28.562901] PM: Adding info for No Bus:usbdev2.1_ep81
[   28.562925] PM: Adding info for No Bus:usbdev2.1
[   28.562965] ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 23 (level, low) -> IRQ 23
[   28.563687] PCI: Setting latency timer of device 0000:00:1d.7 to 64
[   28.563691] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[   28.563726] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 3
[   28.563753] ehci_hcd 0000:00:1d.7: debug port 1
[   28.563757] PCI: cache line size of 32 is not supported by device 0000:00:1d.7
[   28.563765] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfbfff800
[   28.567634] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
[   28.567651] PM: Adding info for usb:usb3
[   28.567683] PM: Adding info for No Bus:usbdev3.1_ep00
[   28.567696] usb usb3: configuration #1 chosen from 1 choice
[   28.567702] PM: Adding info for usb:3-0:1.0
[   28.567716] hub 3-0:1.0: USB hub found
[   28.567720] hub 3-0:1.0: 6 ports detected
[   28.671351] PM: Adding info for No Bus:usbdev3.1_ep81
[   28.671372] PM: Adding info for No Bus:usbdev3.1
[   28.671929] ACPI: PCI Interrupt 0000:00:1a.1[B] -> GSI 21 (level, low) -> IRQ 21
[   28.671937] PCI: Setting latency timer of device 0000:00:1a.1 to 64
[   28.671940] uhci_hcd 0000:00:1a.1: UHCI Host Controller
[   28.671956] uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
[   28.671978] uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000c880
[   28.672006] PM: Adding info for usb:usb4
[   28.672035] PM: Adding info for No Bus:usbdev4.1_ep00
[   28.672045] usb usb4: configuration #1 chosen from 1 choice
[   28.672050] PM: Adding info for usb:4-0:1.0
[   28.672062] hub 4-0:1.0: USB hub found
[   28.672066] hub 4-0:1.0: 2 ports detected
[   28.775766] PM: Adding info for No Bus:usbdev4.1_ep81
[   28.775792] PM: Adding info for No Bus:usbdev4.1
[   28.775828] ACPI: PCI Interrupt 0000:00:1a.2[C] -> GSI 18 (level, low) -> IRQ 18
[   28.775836] PCI: Setting latency timer of device 0000:00:1a.2 to 64
[   28.775839] uhci_hcd 0000:00:1a.2: UHCI Host Controller
[   28.775856] uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
[   28.775876] uhci_hcd 0000:00:1a.2: irq 18, io base 0x0000cc00
[   28.775908] PM: Adding info for usb:usb5
[   28.775942] PM: Adding info for No Bus:usbdev5.1_ep00
[   28.775951] usb usb5: configuration #1 chosen from 1 choice
[   28.775957] PM: Adding info for usb:5-0:1.0
[   28.775969] hub 5-0:1.0: USB hub found
[   28.775972] hub 5-0:1.0: 2 ports detected
[   28.880213] PM: Adding info for No Bus:usbdev5.1_ep81
[   28.880233] PM: Adding info for No Bus:usbdev5.1
[   28.880262] ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 23 (level, low) -> IRQ 23
[   28.880268] PCI: Setting latency timer of device 0000:00:1d.0 to 64
[   28.880270] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[   28.880287] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
[   28.880306] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000c080
[   28.880336] PM: Adding info for usb:usb6
[   28.880367] PM: Adding info for No Bus:usbdev6.1_ep00
[   28.880386] usb usb6: configuration #1 chosen from 1 choice
[   28.880391] PM: Adding info for usb:6-0:1.0
[   28.880403] hub 6-0:1.0: USB hub found
[   28.880406] hub 6-0:1.0: 2 ports detected
[   28.984665] PM: Adding info for No Bus:usbdev6.1_ep81
[   28.984689] PM: Adding info for No Bus:usbdev6.1
[   28.984720] ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 19
[   28.984726] PCI: Setting latency timer of device 0000:00:1d.1 to 64
[   28.984729] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[   28.984745] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
[   28.984768] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000c400
[   28.984798] PM: Adding info for usb:usb7
[   28.984835] PM: Adding info for No Bus:usbdev7.1_ep00
[   28.984845] usb usb7: configuration #1 chosen from 1 choice
[   28.984850] PM: Adding info for usb:7-0:1.0
[   28.984862] hub 7-0:1.0: USB hub found
[   28.984865] hub 7-0:1.0: 2 ports detected
[   28.988675] usb 2-5: new high speed USB device using ehci_hcd and address 3
[   29.089131] PM: Adding info for No Bus:usbdev7.1_ep81
[   29.089151] PM: Adding info for No Bus:usbdev7.1
[   29.089179] ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 18
[   29.089185] PCI: Setting latency timer of device 0000:00:1d.2 to 64
[   29.089187] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[   29.089203] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
[   29.089222] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000c480
[   29.089254] PM: Adding info for usb:usb8
[   29.089285] PM: Adding info for No Bus:usbdev8.1_ep00
[   29.089302] usb usb8: configuration #1 chosen from 1 choice
[   29.089307] PM: Adding info for usb:8-0:1.0
[   29.089318] hub 8-0:1.0: USB hub found
[   29.089321] hub 8-0:1.0: 2 ports detected
[   29.123817] PM: Adding info for usb:2-5
[   29.123852] PM: Adding info for No Bus:usbdev2.3_ep00
[   29.123866] usb 2-5: configuration #1 chosen from 1 choice
[   29.123937] PM: Adding info for usb:2-5:1.0
[   29.123964] PM: Adding info for No Bus:usbdev2.3_ep02
[   29.123981] PM: Adding info for No Bus:usbdev2.3_ep86
[   29.124001] PM: Adding info for No Bus:usbdev2.3_ep81
[   29.124017] PM: Adding info for No Bus:usbdev2.3
[   29.193600] PM: Adding info for No Bus:usbdev8.1_ep81
[   29.193625] PM: Adding info for No Bus:usbdev8.1
[   29.193750] ACPI: PCI Interrupt 0000:04:03.0[A] -> GSI 16 (level, low) -> IRQ 16
[   29.193768] PM: Adding info for ieee1394:fw-host0
[   29.246865] ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[16]  MMIO=[febff800-febfffff]  Max Packet=[2048]  IR/IT contexts=[4/8]
[   29.253008] ata_piix 0000:00:1f.2: version 2.11
[   29.253012] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[   29.253032] ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 22 (level, low) -> IRQ 22
[   29.253051] PCI: Setting latency timer of device 0000:00:1f.2 to 64
[   29.253092] scsi0 : ata_piix
[   29.253099] PM: Adding info for No Bus:host0
[   29.253120] scsi1 : ata_piix
[   29.253124] PM: Adding info for No Bus:host1
[   29.253136] ata1: SATA max UDMA/133 cmd 0x000000000001b000 ctl 0x000000000001ac02 bmdma 0x000000000001a480 irq 22
[   29.253138] ata2: SATA max UDMA/133 cmd 0x000000000001a880 ctl 0x000000000001a802 bmdma 0x000000000001a488 irq 22
[   29.414148] ata1.00: ATA-7: HDT722525DLA380, V44OA96A, max UDMA/133
[   29.414151] ata1.00: 488397168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[   29.430182] ata1.00: configured for UDMA/133
[   29.546133] usb 4-2: new low speed USB device using uhci_hcd and address 2
[   29.594678] ata2.00: ATA-7: HDT722525DLA380, V44OA96A, max UDMA/133
[   29.594680] ata2.00: 488397168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[   29.610760] ata2.00: configured for UDMA/133
[   29.610771] PM: Adding info for No Bus:target0:0:0
[   29.610833] scsi 0:0:0:0: Direct-Access     ATA      HDT722525DLA380  V44O PQ: 0 ANSI: 5
[   29.610838] PM: Adding info for scsi:0:0:0:0
[   29.610874] PM: Adding info for No Bus:target1:0:0
[   29.611079] scsi 1:0:0:0: Direct-Access     ATA      HDT722525DLA380  V44O PQ: 0 ANSI: 5
[   29.611083] PM: Adding info for scsi:1:0:0:0
[   29.611114] ata_piix 0000:00:1f.5: MAP [ P0 P2 P1 P3 ]
[   29.611127] ACPI: PCI Interrupt 0000:00:1f.5[B] -> GSI 22 (level, low) -> IRQ 22
[   29.611142] PCI: Setting latency timer of device 0000:00:1f.5 to 64
[   29.611158] scsi2 : ata_piix
[   29.611163] PM: Adding info for No Bus:host2
[   29.611180] scsi3 : ata_piix
[   29.611184] PM: Adding info for No Bus:host3
[   29.611198] ata3: SATA max UDMA/133 cmd 0x000000000001c000 ctl 0x000000000001bc02 bmdma 0x000000000001b480 irq 22
[   29.611200] ata4: SATA max UDMA/133 cmd 0x000000000001b880 ctl 0x000000000001b802 bmdma 0x000000000001b488 irq 22
[   29.723210] PM: Adding info for usb:4-2
[   29.723255] PM: Adding info for No Bus:usbdev4.2_ep00
[   29.723266] usb 4-2: configuration #1 chosen from 1 choice
[   29.726208] PM: Adding info for usb:4-2:1.0
[   29.726236] PM: Adding info for No Bus:usbdev4.2_ep81
[   29.726259] PM: Adding info for No Bus:usbdev4.2
[   29.775531] ata3.00: ATA-7: WDC WD2500KS-00MJB0, 02.01C03, max UDMA/133
[   29.775534] ata3.00: 488397168 sectors, multi 16: LBA48
[   29.783565] ata3.00: configured for UDMA/133
[   29.969166] ata4.00: ATA-7: WDC WD5000ABYS-01TNA0, 12.01C01, max UDMA/133
[   29.969169] ata4.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[   29.985197] ata4.00: configured for UDMA/133
[   29.985210] PM: Adding info for No Bus:target2:0:0
[   29.985268] scsi 2:0:0:0: Direct-Access     ATA      WDC WD2500KS-00M 02.0 PQ: 0 ANSI: 5
[   29.985275] PM: Adding info for scsi:2:0:0:0
[   29.985313] PM: Adding info for No Bus:target3:0:0
[   29.985504] scsi 3:0:0:0: Direct-Access     ATA      WDC WD5000ABYS-0 12.0 PQ: 0 ANSI: 5
[   29.985509] PM: Adding info for scsi:3:0:0:0
[   29.989584] sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors (250059 MB)
[   29.989592] sd 0:0:0:0: [sda] Write Protect is off
[   29.989593] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   29.989602] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   29.989630] sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors (250059 MB)
[   29.992822] sd 0:0:0:0: [sda] Write Protect is off
[   29.992824] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[   29.992839] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   29.992842]  sda: sda1 sda2 < sda5 sda6 >
[   30.034228] sd 0:0:0:0: [sda] Attached SCSI disk
[   30.034325] sd 1:0:0:0: [sdb] 488397168 512-byte hardware sectors (250059 MB)
[   30.034331] sd 1:0:0:0: [sdb] Write Protect is off
[   30.034332] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[   30.034341] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   30.034362] sd 1:0:0:0: [sdb] 488397168 512-byte hardware sectors (250059 MB)
[   30.034367] sd 1:0:0:0: [sdb] Write Protect is off
[   30.034368] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[   30.034376] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   30.034378]  sdb: sdb1
[   30.050795] sd 1:0:0:0: [sdb] Attached SCSI disk
[   30.050828] sd 2:0:0:0: [sdc] 488397168 512-byte hardware sectors (250059 MB)
[   30.050836] sd 2:0:0:0: [sdc] Write Protect is off
[   30.050838] sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[   30.050850] sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   30.050879] sd 2:0:0:0: [sdc] 488397168 512-byte hardware sectors (250059 MB)
[   30.050886] sd 2:0:0:0: [sdc] Write Protect is off
[   30.050888] sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[   30.050899] sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   30.050903]  sdc: sdc1
[   30.062020] sd 2:0:0:0: [sdc] Attached SCSI disk
[   30.062051] sd 3:0:0:0: [sdd] 976773168 512-byte hardware sectors (500108 MB)
[   30.062058] sd 3:0:0:0: [sdd] Write Protect is off
[   30.062060] sd 3:0:0:0: [sdd] Mode Sense: 00 3a 00 00
[   30.062071] sd 3:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   30.062096] sd 3:0:0:0: [sdd] 976773168 512-byte hardware sectors (500108 MB)
[   30.062104] sd 3:0:0:0: [sdd] Write Protect is off
[   30.062105] sd 3:0:0:0: [sdd] Mode Sense: 00 3a 00 00
[   30.062117] sd 3:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[   30.062119]  sdd: sdd1
[   30.064332] sd 3:0:0:0: [sdd] Attached SCSI disk
[   30.067590] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   30.067603] sd 1:0:0:0: Attached scsi generic sg1 type 0
[   30.067614] sd 2:0:0:0: Attached scsi generic sg2 type 0
[   30.067625] sd 3:0:0:0: Attached scsi generic sg3 type 0
[   30.096546] usb 5-2: new low speed USB device using uhci_hcd and address 2
[   30.295763] PM: Adding info for usb:5-2
[   30.295815] PM: Adding info for No Bus:usbdev5.2_ep00
[   30.295831] usb 5-2: configuration #1 chosen from 1 choice
[   30.298756] PM: Adding info for usb:5-2:1.0
[   30.298784] PM: Adding info for No Bus:usbdev5.2_ep81
[   30.298807] PM: Adding info for No Bus:usbdev5.2
[   30.298879] usbcore: registered new interface driver hiddev
[   30.298896] usbcore: registered new interface driver libusual
[   30.302718] Initializing USB Mass Storage driver...
[   30.302760] scsi4 : SCSI emulation for USB Mass Storage devices
[   30.302767] PM: Adding info for No Bus:host4
[   30.302792] usb-storage: device found at 3
[   30.302793] usb-storage: waiting for device to settle before scanning
[   30.312894] input: Logitech USB-PS/2 Optical Mouse as /class/input/input1
[   30.312907] input: USB HID v1.10 Mouse [Logitech USB-PS/2 Optical Mouse] on usb-0000:00:1a.1-2
[   30.325177] EXT3-fs: INFO: recovery required on readonly filesystem.
[   30.325180] EXT3-fs: write access will be enabled during recovery.
[   30.523365] PM: Adding info for ieee1394:0011d800015cb048
[   30.523396] ieee1394: Host added: ID:BUS[0-00:1023]  GUID[0011d800015cb048]
[   30.763414] PM: Adding info for No Bus:hiddev0
[   30.763426] hiddev96: USB HID v1.10 Device [APC Back-UPS ES 650 FW:825.B1.D USB FW:B1] on usb-0000:00:1a.2-2
[   30.763439] usbcore: registered new interface driver usbhid
[   30.763442] drivers/hid/usbhid/hid-core.c: v2.6:USB HID core driver
[   30.763444] usbcore: registered new interface driver usb-storage
[   30.763448] USB Mass Storage support registered.
[   34.248055] kjournald starting.  Commit interval 5 seconds
[   34.248065] EXT3-fs: sda5: orphan cleanup on readonly fs
[   34.248070] ext3_orphan_cleanup: deleting unreferenced inode 737286
[   34.248097] EXT3-fs: sda5: 1 orphan inode deleted
[   34.248098] EXT3-fs: recovery complete.
[   34.260487] EXT3-fs: mounted filesystem with ordered data mode.
[   35.299018] usb-storage: device scan complete
[   35.299044] PM: Adding info for No Bus:target4:0:0
[   35.300147] scsi 4:0:0:0: CD-ROM            LITE-ON  DVDRW SHW-1635S  YS0R PQ: 0 ANSI: 0
[   35.300285] PM: Adding info for No Bus:target4:0:1
[   35.300301] PM: Removing info for No Bus:target4:0:1
[   35.300309] PM: Adding info for No Bus:target4:0:2
[   35.300322] PM: Removing info for No Bus:target4:0:2
[   35.300328] PM: Adding info for No Bus:target4:0:3
[   35.300341] PM: Removing info for No Bus:target4:0:3
[   35.300347] PM: Adding info for No Bus:target4:0:4
[   35.300360] PM: Removing info for No Bus:target4:0:4
[   35.300366] PM: Adding info for No Bus:target4:0:5
[   35.300378] PM: Removing info for No Bus:target4:0:5
[   35.300384] PM: Adding info for No Bus:target4:0:6
[   35.300397] PM: Removing info for No Bus:target4:0:6
[   35.300402] PM: Adding info for No Bus:target4:0:7
[   35.300415] PM: Removing info for No Bus:target4:0:7
[   35.300421] PM: Adding info for scsi:4:0:0:0
[   35.300457] scsi 4:0:0:0: Attached scsi generic sg4 type 5
[   39.619652] PM: Adding info for No Bus:vcs2
[   39.619666] PM: Adding info for No Bus:vcsa2
[   39.620102] PM: Removing info for No Bus:vcs2
[   39.620112] PM: Removing info for No Bus:vcsa2
[   39.620160] PM: Adding info for No Bus:vcs3
[   39.620168] PM: Adding info for No Bus:vcsa3
[   39.620597] PM: Removing info for No Bus:vcs3
[   39.620607] PM: Removing info for No Bus:vcsa3
[   39.620657] PM: Adding info for No Bus:vcs4
[   39.620666] PM: Adding info for No Bus:vcsa4
[   39.621107] PM: Removing info for No Bus:vcs4
[   39.621116] PM: Removing info for No Bus:vcsa4
[   39.621164] PM: Adding info for No Bus:vcs5
[   39.621172] PM: Adding info for No Bus:vcsa5
[   39.621601] PM: Removing info for No Bus:vcs5
[   39.621609] PM: Removing info for No Bus:vcsa5
[   39.621655] PM: Adding info for No Bus:vcs6
[   39.621663] PM: Adding info for No Bus:vcsa6
[   39.622090] PM: Removing info for No Bus:vcs6
[   39.622100] PM: Removing info for No Bus:vcsa6
[   41.299202] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   41.321357] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   41.400471] input: PC Speaker as /class/input/input2
[   41.698408] sr0: scsi3-mmc drive: 48x/48x writer cd/rw xa/form2 cdda tray
[   41.698412] Uniform CD-ROM driver Revision: 3.20
[   41.698534] sr 4:0:0:0: Attached scsi CD-ROM sr0
[   41.721179] PM: Adding info for No Bus:timer
[   41.746627] ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 17 (level, low) -> IRQ 17
[   41.746636] PCI: Setting latency timer of device 0000:02:00.0 to 64
[   41.747313] atl1 0000:02:00.0: version 2.0.7
[   41.763156] PM: Adding info for No Bus:eth0
[   41.782462] PM: Adding info for No Bus:seq
[   41.836169] PM: Adding info for No Bus:sequencer
[   41.836374] PM: Adding info for No Bus:sequencer2
[   42.013340] ACPI: PCI Interrupt 0000:00:1b.0[A] -> GSI 22 (level, low) -> IRQ 22
[   42.014023] PCI: Setting latency timer of device 0000:00:1b.0 to 64
[   42.221575] hda_codec: Unknown model for ALC883, trying auto-probe from BIOS...
[   42.326075] PM: Adding info for No Bus:pcmC0D2c
[   42.326107] PM: Adding info for No Bus:pcmC0D1p
[   42.326128] PM: Adding info for No Bus:adsp
[   42.326143] PM: Adding info for No Bus:pcmC0D0p
[   42.326162] PM: Adding info for No Bus:pcmC0D0c
[   42.326182] PM: Adding info for No Bus:dsp
[   42.326198] PM: Adding info for No Bus:audio
[   42.326220] PM: Adding info for No Bus:controlC0
[   42.326236] PM: Adding info for No Bus:mixer
[   42.451348] fuse init (API version 7.8)
[   42.451418] PM: Adding info for No Bus:fuse
[   42.519504] PM: Adding info for platform:parport_pc.956
[   42.519532] PM: Removing info for platform:parport_pc.956
[   42.519539] PM: Adding info for platform:parport_pc.888
[   42.519575] PM: Removing info for platform:parport_pc.888
[   42.519581] PM: Adding info for platform:parport_pc.632
[   42.519604] PM: Removing info for platform:parport_pc.632
[   42.519684] lp: driver loaded but no devices found
[   42.587032] PM: Adding info for platform:coretemp.0
[   42.587045] coretemp coretemp.0: Using undocumented features, absolute temperature might be wrong!
[   42.587206] PM: Adding info for platform:coretemp.1
[   42.587215] coretemp coretemp.1: Using undocumented features, absolute temperature might be wrong!
[   42.635462] PM: Adding info for No Bus:i2c-9191
[   42.641612] PM: Adding info for i2c:9191-0290
[   42.673638] Adding 489940k swap on /dev/disk/by-uuid/fb919ccd-d028-4fb3-8b77-3161a5a384bd.  Priority:-1 extents:1 across:489940k
[   43.015960] EXT3 FS on sda5, internal journal
[   51.422522] NTFS driver 2.1.28 [Flags: R/O MODULE].
[   51.490346] NTFS volume version 3.1.
[   51.662739] kjournald starting.  Commit interval 5 seconds
[   51.672446] EXT3 FS on sdd1, internal journal
[   51.672450] EXT3-fs: mounted filesystem with ordered data mode.
[   52.878108] NET: Registered protocol family 17
[   55.663359] PM: Adding info for No Bus:vcs4
[   55.663376] PM: Adding info for No Bus:vcsa4
[   55.663669] PM: Adding info for No Bus:vcs5
[   55.663680] PM: Adding info for No Bus:vcsa5
[   55.665481] PM: Adding info for No Bus:vcs2
[   55.665494] PM: Adding info for No Bus:vcsa2
[   55.665788] PM: Adding info for No Bus:vcs3
[   55.665800] PM: Adding info for No Bus:vcsa3
[   55.666379] PM: Adding info for No Bus:vcs6
[   55.666390] PM: Adding info for No Bus:vcsa6
[   55.714242] input: Power Button (FF) as /class/input/input3
[   55.714336] ACPI: Power Button (FF) [PWRF]
[   55.714866] input: Power Button (CM) as /class/input/input4
[   55.714960] ACPI: Power Button (CM) [PWRB]
[   55.722247] No dock devices found.
[   55.801387] toshiba_acpi: Unknown parameter `hotkeys_over_acpi'
[   60.832574] atl1 0000:02:00.0: eth0 link is up 100 Mbps full duplex
[   62.057394] PM: Adding info for No Bus:vcs7
[   62.057607] PM: Adding info for No Bus:vcsa7
[   62.115354] PM: Removing info for No Bus:vcs7
[   62.115562] PM: Removing info for No Bus:vcsa7
[   62.141617] PM: Adding info for No Bus:vcs7
[   62.141810] PM: Adding info for No Bus:vcsa7
[   63.110644] ppdev: user-space parallel port driver
[   65.355203] NET: Registered protocol family 10
[   65.355259] lo: Disabled Privacy Extensions
[   73.217269] ISO 9660 Extensions: Microsoft Joliet Level 3
[   73.229636] ISOFS: changing to secondary root
[   76.279844] eth0: no IPv6 routers present
[  137.911259] PM: Removing info for No Bus:vcs7
[  137.911284] PM: Removing info for No Bus:vcsa7
[  141.002395] PM: Removing info for No Bus:vcs2
[  141.002417] PM: Removing info for No Bus:vcsa2
[  141.003353] PM: Adding info for No Bus:vcs2
[  141.003369] PM: Adding info for No Bus:vcsa2
[  301.883919] VM: killing process convert
[  301.884382] swap_free: Unused swap offset entry 0000ff00
[  301.884421] swap_free: Unused swap offset entry 00000300
[  301.884456] swap_free: Unused swap offset entry 00000200
[  301.884491] swap_free: Unused swap offset entry 0000ff00
[  301.884527] swap_free: Unused swap offset entry 0000ff00
[  301.884562] swap_free: Unused swap offset entry 00000100
[  327.221932] PM: Removing info for No Bus:vcs2
[  327.221952] PM: Removing info for No Bus:vcsa2
[  327.223254] PM: Adding info for No Bus:vcs2
[  327.223516] PM: Adding info for No Bus:vcsa2
[  345.349002] PM: Adding info for No Bus:vcs7
[  345.350146] PM: Adding info for No Bus:vcsa7
[  345.353575] PM: Removing info for No Bus:vcs7
[  345.354441] PM: Removing info for No Bus:vcsa7
[  345.355363] PM: Adding info for No Bus:vcs7
[  345.355471] PM: Adding info for No Bus:vcsa7
[  354.867793] ISO 9660 Extensions: Microsoft Joliet Level 3
[  354.897019] ISOFS: changing to secondary root


Oleg Verych wrote:
> * Wed, 19 Sep 2007 04:45:17 -0400
>> [1.] Summary
>> System Freeze on Particular workload with kernel 2.6.22.6
>>
>> [2.] Description
>> System freezes on repeated application of the following command
>> for f in *png ; do convert -quality 100 $f `basename $f png`jpg; done
>>
>> Problem is consistent and repeatable.
>> Problem persists when running on a different drive, and also in pure console (no X).
>>
>> One time, the following error logged in syslog:
>> Sep 19 04:22:11 mossnew kernel: [  301.883919] VM: killing process convert
>> Sep 19 04:22:11 mossnew kernel: [  301.884382] swap_free: Unused swap offset entry 0000ff00
>> Sep 19 04:22:11 mossnew kernel: [  301.884421] swap_free: Unused swap offset entry 00000300
>> Sep 19 04:22:11 mossnew kernel: [  301.884456] swap_free: Unused swap offset entry 00000200
>> Sep 19 04:22:11 mossnew kernel: [  301.884491] swap_free: Unused swap offset entry 0000ff00
>> Sep 19 04:22:11 mossnew kernel: [  301.884527] swap_free: Unused swap offset entry 0000ff00
>> Sep 19 04:22:11 mossnew kernel: [  301.884562] swap_free: Unused swap offset entry 00000100
>>
>> Should not be a RAM problem. RAM has survived 12 hrs of Memtest with no errors.
>> Should not be a CPU problem either. I have been running CPU intensive tasks for days.
>>
>> [3.] Keywords
>> freeze, swap_free,VM
> 
> Nice bug report, seems like from linux-source/REPORTING-BUGS.
> But still:
> 
> * no relevant Cc (memory management added)
> + no output of `mount` (because if swap is on some file system, that
>   *can* be another problem)
> + no information about amount of memory and its BIOS configuration
> 
> FYI, latter two (and much more) is one `dmesg` output. This output,
> together with any other kernel information can be gathered by serial or
> net consoles:
> 
> linux-source/Documentation/serial-console.txt
> linux-source/Documentation/networking/netconsole.txt 
> 
> If console messages after freeze can be seen in text mode VGA/CRT
> also, photos of it somewhere on ftp will be OK.
> 
>> [4.] /proc/version
>> Linux version 2.6.22.6intelcore2 (root@mossnew) (gcc version 4.1.2 (Ubuntu 4.1.2-0ubuntu4)) #1 SMP Sat Sep 15 00:29:00 EDT 2007
>>
>> [5.] No Oops
>>
>> [6.] Trigger
>> - Create a large number of png images. (a few hundred)
>>
>> - repeatedly run
>> for f in *png ; do convert -quality 100 $f `basename $f png`jpg; done
>>
>> - This might be subjective, but the freeze seems to show up sooner if there is a CPU heavy
>> process running in the background.
>>
>> [7] Environment
>> [7.1] Software /script/ver_linux
>>
>> Linux mossnew 2.6.22.6intelcore2 #1 SMP Sat Sep 15 00:29:00 EDT 2007 x86_64 GNU/Linux
>>
> []
> ____
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
