Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7CDA76B0071
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 17:46:51 -0500 (EST)
Date: Wed, 20 Jan 2010 15:46:29 -0700
From: Alex Chiang <achiang@hp.com>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-ID: <20100120224629.GC3881@ldl.fc.hp.com>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001151358110.6590@router.home> <1263587721.20615.255.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.1001151730350.10558@router.home> <alpine.DEB.2.00.1001191252370.25101@router.home> <20100119200228.GE11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191427370.26683@router.home> <20100119212935.GG11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191545170.26683@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001191545170.26683@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux-foundation.org>:
> 
> Could you boot with full debugging?
> 
> Either switch on
> 
> CONFIG_SLUB_DEBUG_ON
> 
> or pass
> 
> 	slub_debug
> 
> on the kernel command line.
> 
 
coffee0:/usr/src/linux-2.6 # grep SLUB .config
CONFIG_SLUB_DEBUG=y
CONFIG_SLUB=y
CONFIG_SLUB_DEBUG_ON=y
# CONFIG_SLUB_STATS is not set

boot log below.

ELILO boot: achiang slub_debug
Uncompressing Linux... done
Loading file initrd-2.6.33-rc3-next-20100111-dirty...done
Initializing cgroup subsys cpuset
Linux version 2.6.33-rc3-next-20100111-dirty (root@coffee0) (gcc version 4.3.2 [gcc-4_3-branch revision 141291] (SUSE Linux) ) #20 SMP Tue Jan 19 12:34:56 MST 2010
EFI v2.00 by HP: SALsystab=0x707fd39c088 ACPI 2.0=0x707fd7d0000 HCDP=0x707fd7f6998 SMBIOS=0x1ffec000
booting generic kernel on platform hpzx1
PCDP: v3 at 0x707fd7f6998
Early serial console at MMIO 0xffc30064000 (options '9600n8')
bootconsole [uart8250] enabled
ACPI: RSDP 00000707fd7d0000 00024 (v02     HP)
ACPI: XSDT 00000707fd7f6a80 0007C (v01     HP   rx8640 00000000   HP 00000000)
ACPI: FACP 00000707fd7f65b0 000F4 (v03     HP   rx8640 00000000   HP 00000000)
ACPI Warning: 32/64X length mismatch in Pm1aEventBlock: 32/16 (20091214/tbfadt-526)
ACPI Warning: 32/64X length mismatch in Gpe0Block: 256/0 (20091214/tbfadt-526)
ACPI Warning: 32/64X length mismatch in Gpe1Block: 256/0 (20091214/tbfadt-526)
ACPI Warning: Invalid length for Pm1aEventBlock: 16, using default 32 (20091214/tbfadt-607)
ACPI: DSDT 00000707fd7d03d0 2618B (v02     HP  CELL000 00000000   HP 00000000)
ACPI: FACS 00000707fd7d0028 00040
ACPI: SPCR 00000707fd7d0068 00050 (v01     HP   rx8640 00000000   HP 00000000)
ACPI: DBGP 00000707fd7d00b8 00034 (v01     HP   rx8640 00000000   HP 00000000)
ACPI: APIC 00000707fd7d01a0 0022C (v01     HP   rx8640 00000000   HP 00000000)
ACPI: SLIT 00000707fd7f66a8 00045 (v01     HP   rx8640 00000000   HP 00000000)
ACPI: CPEP 00000707fd7f66f0 000AC (v01     HP   rx8640 00000000   HP 00000000)
ACPI: SRAT 00000707fd7f67a0 001F8 (v01     HP   rx8640 00000000   HP 00000000)
ACPI: SPMI 00000707fd7f6560 00050 (v04     HP   rx8640 00000000   HP 00000000)
ACPI: OEMD 00000707fd7d0128 00074 (v01     HP   rx8640 00000000   HP 00000000)
ACPI: HPET 00000707fd7d00f0 00038 (v01     HP   rx8640 00000000   HP 00000000)
ACPI: SSDT 00000707fd7f6b78 25088 (v02     HP  CELL001 00000000   HP 00000000)
ACPI: Local APIC address c0000000fee00000
16 CPUs available, 16 CPUs total
ACPI: SLIT table looks invalid. Not used.
Number of logical nodes in system = 3
Number of memory chunks in system = 5
SMP: Allowing 16 CPUs, 0 hotplug CPUs
warning: skipping physical page 0
warning: skipping physical page 0
warning: skipping physical page 0
warning: skipping physical page 0
Initial ramdisk at: 0xe0000787fa9c7000 (6057711 bytes)
SAL 3.20: HP Orca/IPF version 9.48
SAL Platform features: None
SAL: AP wakeup using external interrupt vector 0xff
ACPI: Local APIC address c0000000fee00000
GSI 16 (level, low) -> CPU 0 (0x0000) vector 49
MCA related initialization done
warning: skipping physical page 0
Virtual mem_map starts at 0xa07ffffe5a400000
Zone PFN ranges:
  DMA      0x00000001 -> 0x00010000
  Normal   0x00010000 -> 0x0787fc00
Movable zone start PFN for each node
early_node_map[5] active PFN ranges
    2: 0x00000001 -> 0x00001ffe
    0: 0x07002000 -> 0x07005db7
    0: 0x07005db8 -> 0x0707fb00
    1: 0x07800000 -> 0x0787fbd9
    1: 0x0787fbe8 -> 0x0787fbfd
On node 0 totalpages: 514815
free_area_init_node: node 0, pgdat e000070020080000, node_mem_map a07fffffe2470000
  Normal zone: 440 pages used for memmap
  Normal zone: 514375 pages, LIFO batch:1
On node 1 totalpages: 523246
free_area_init_node: node 1, pgdat e000078000090080, node_mem_map a07ffffffe400000
  Normal zone: 448 pages used for memmap
  Normal zone: 522798 pages, LIFO batch:1
On node 2 totalpages: 8189
free_area_init_node: node 2, pgdat e000000000120100, node_mem_map a07ffffe5a400000
  DMA zone: 7 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 8182 pages, LIFO batch:0
pcpu-alloc: s43032 r8192 d14312 u65536 alloc=1*65536
pcpu-alloc: [0] 00 [0] 01 [0] 02 [0] 03 [0] 04 [0] 05 [0] 06 [0] 07 
pcpu-alloc: [1] 08 [1] 09 [1] 10 [1] 11 [1] 12 [1] 13 [1] 14 [1] 15 
Built 3 zonelists in Zone order, mobility grouping on.  Total pages: 1045355
Policy zone: Normal
Kernel command line: BOOT_IMAGE=scsi1:\efi\SuSE\vmlinuz-2.6.33-rc3-next-20100111-dirty root=/dev/disk/by-id/scsi-35001d38000048bd8-part2  debug slub_debug
PID hash table entries: 4096 (order: -1, 32768 bytes)
Memory: 66849344k/66910528k available (8033k code, 110720k reserved, 10805k data, 1984k init)
SLUB: Unable to allocate memory from node 2
SLUB: Allocating a useless per node structure in order to be able to continue
SLUB: Genslabs=18, HWalign=128, Order=0-3, MinObjects=0, CPUs=16, Nodes=1024
Hierarchical RCU implementation.
NR_IRQS:1024
CPU 0: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
Console: colour dummy device 80x25
Calibrating delay loop... 3194.88 BogoMIPS (lpj=6389760)
Dentry cache hash table entries: 8388608 (order: 10, 67108864 bytes)
Inode-cache hash table entries: 4194304 (order: 9, 33554432 bytes)
Mount-cache hash table entries: 4096
ACPI: Core revision 20091214
Boot processor id 0x0/0x0
Fixed BSP b0 value from CPU 1
CPU 1: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 141 cycles)
CPU 1: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 2: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 146 cycles)
CPU 2: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 3: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 146 cycles)
CPU 3: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 4: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 337 cycles)
CPU 4: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 5: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 337 cycles)
CPU 5: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 6: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 337 cycles)
CPU 6: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 7: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 337 cycles)
CPU 7: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 8: synchronized ITC with CPU 0 (last diff 2 cycles, maxerr 652 cycles)
CPU 8: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 9: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 652 cycles)
CPU 9: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 10: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 652 cycles)
CPU 10: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 11: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 656 cycles)
CPU 11: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 12: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 656 cycles)
CPU 12: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 13: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 652 cycles)
CPU 13: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 14: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 655 cycles)
CPU 14: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 15: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 654 cycles)
CPU 15: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
Brought up 16 CPUs
Total of 16 processors activated (51118.08 BogoMIPS).
DMI 2.5 present.
NET: Registered protocol family 16
ACPI: bus type pci registered
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: BIOS offers _GTS
ACPI: If "acpi.gts=1" improves suspend, please notify linux-acpi@vger.kernel.org
ACPI: Using IOSAPIC for interrupt routing
ACPI: No dock devices found.
ACPI: PCI Root Bridge [L000] (0000:00)
pci_root HWP0002:00: host bridge window [io  0x0000-0x0fff]
pci_root HWP0002:00: host bridge window [mem 0xf0000000000-0xf007edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0000:00:01.0: reg 10: [mem 0x80520000-0x8052ffff 64bit]
pci 0000:00:01.0: reg 30: [mem 0x80400000-0x8041ffff pref]
pci 0000:00:01.0: PME# supported from D3hot
pci 0000:00:01.0: PME# disabled
pci 0000:00:02.0: reg 10: [io  0x0800-0x08ff]
pci 0000:00:02.0: reg 14: [mem 0x80420000-0x8043ffff 64bit]
pci 0000:00:02.0: reg 1c: [mem 0x80440000-0x8045ffff 64bit]
pci 0000:00:02.0: reg 30: [mem 0x80000000-0x800fffff pref]
pci 0000:00:02.0: supports D1 D2
pci 0000:00:02.1: reg 10: [io  0x0900-0x09ff]
pci 0000:00:02.1: reg 14: [mem 0x80460000-0x8047ffff 64bit]
pci 0000:00:02.1: reg 1c: [mem 0x80480000-0x8049ffff 64bit]
pci 0000:00:02.1: reg 30: [mem 0x80100000-0x801fffff pref]
pci 0000:00:02.1: supports D1 D2
pci 0000:00:03.0: reg 10: [io  0x0a00-0x0aff]
pci 0000:00:03.0: reg 14: [mem 0x804a0000-0x804bffff 64bit]
pci 0000:00:03.0: reg 1c: [mem 0x804c0000-0x804dffff 64bit]
pci 0000:00:03.0: reg 30: [mem 0x80200000-0x802fffff pref]
pci 0000:00:03.0: supports D1 D2
pci 0000:00:03.1: reg 10: [io  0x0b00-0x0bff]
pci 0000:00:03.1: reg 14: [mem 0x804e0000-0x804fffff 64bit]
pci 0000:00:03.1: reg 1c: [mem 0x80500000-0x8051ffff 64bit]
pci 0000:00:03.1: reg 30: [mem 0x80300000-0x803fffff pref]
pci 0000:00:03.1: supports D1 D2
ACPI: PCI Interrupt Routing Table [\_SB_.N000.S000.IOC0.L000._PRT]
ACPI: PCI Root Bridge [L001] (0000:1c)
pci_root HWP0002:01: host bridge window [io  0x1000-0x1fff]
pci_root HWP0002:01: host bridge window [mem 0xf0080000000-0xf00fedfffff] (PCI address [0x80000000-0xfedfffff])
pci 0000:1c:01.0: reg 10: [mem 0x80100000-0x8011ffff 64bit]
pci 0000:1c:01.0: reg 18: [mem 0x80080000-0x800bffff 64bit]
pci 0000:1c:01.0: reg 20: [io  0x1000-0x103f]
pci 0000:1c:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0000:1c:01.0: PME# supported from D0 D3hot
pci 0000:1c:01.0: PME# disabled
pci 0000:1c:01.1: reg 10: [mem 0x80120000-0x8013ffff 64bit]
pci 0000:1c:01.1: reg 18: [mem 0x800c0000-0x800fffff 64bit]
pci 0000:1c:01.1: reg 20: [io  0x1040-0x107f]
pci 0000:1c:01.1: reg 30: [mem 0x80040000-0x8007ffff pref]
pci 0000:1c:01.1: PME# supported from D0 D3hot
pci 0000:1c:01.1: PME# disabled
ACPI: PCI Interrupt Routing Table [\_SB_.N000.S000.IOC0.L001._PRT]
ACPI: PCI Root Bridge [L002] (0000:38)
pci_root HWP0002:02: host bridge window [io  0x2000-0x3fff]
pci_root HWP0002:02: host bridge window [mem 0xf1000000000-0xf107edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0000:38:01.0: reg 10: [mem 0x80100000-0x8011ffff 64bit]
pci 0000:38:01.0: reg 18: [mem 0x80080000-0x800bffff 64bit]
pci 0000:38:01.0: reg 20: [io  0x2000-0x203f]
pci 0000:38:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0000:38:01.1: reg 10: [mem 0x80120000-0x8013ffff 64bit]
pci 0000:38:01.1: reg 18: [mem 0x800c0000-0x800fffff 64bit]
pci 0000:38:01.1: reg 20: [io  0x2040-0x207f]
pci 0000:38:01.1: reg 30: [mem 0x80040000-0x8007ffff pref]
ACPI: PCI Interrupt Routing Table [\_SB_.N000.S000.IOC0.L002._PRT]
ACPI: PCI Root Bridge [L004] (0000:54)
pci_root HWP0002:03: host bridge window [io  0x4000-0x5fff]
pci_root HWP0002:03: host bridge window [mem 0xf2000000000-0xf207edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0000:54:01.0: reg 10: [mem 0x80100000-0x8011ffff 64bit]
pci 0000:54:01.0: reg 18: [mem 0x80080000-0x800bffff 64bit]
pci 0000:54:01.0: reg 20: [io  0x4000-0x403f]
pci 0000:54:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0000:54:01.1: reg 10: [mem 0x80120000-0x8013ffff 64bit]
pci 0000:54:01.1: reg 18: [mem 0x800c0000-0x800fffff 64bit]
pci 0000:54:01.1: reg 20: [io  0x4040-0x407f]
pci 0000:54:01.1: reg 30: [mem 0x80040000-0x8007ffff pref]
ACPI: PCI Interrupt Routing Table [\_SB_.N000.S000.IOC0.L004._PRT]
ACPI: PCI Root Bridge [L006] (0000:70)
pci_root HWP0002:04: host bridge window [io  0x6000-0x7fff]
pci_root HWP0002:04: host bridge window [mem 0xf3000000000-0xf307edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0000:70:01.0: reg 10: [mem 0x80100000-0x8011ffff 64bit]
pci 0000:70:01.0: reg 18: [mem 0x80080000-0x800bffff 64bit]
pci 0000:70:01.0: reg 20: [io  0x6000-0x603f]
pci 0000:70:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0000:70:01.1: reg 10: [mem 0x80120000-0x8013ffff 64bit]
pci 0000:70:01.1: reg 18: [mem 0x800c0000-0x800fffff 64bit]
pci 0000:70:01.1: reg 20: [io  0x6040-0x607f]
pci 0000:70:01.1: reg 30: [mem 0x80040000-0x8007ffff pref]
ACPI: PCI Interrupt Routing Table [\_SB_.N000.S000.IOC0.L006._PRT]
ACPI: PCI Root Bridge [L008] (0000:8c)
pci_root HWP0002:05: host bridge window [io  0x8000-0x9fff]
pci_root HWP0002:05: host bridge window [mem 0xf4000000000-0xf407edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0000:8d:01.0: reg 14: [mem 0x84132000-0x84132fff 64bit]
pci 0000:8d:01.0: reg 20: [mem 0x84133000-0x84133fff 64bit]
pci 0000:8d:01.1: reg 14: [mem 0x84134000-0x84134fff 64bit]
pci 0000:8d:01.1: reg 1c: [mem 0x84000000-0x840fffff 64bit pref]
pci 0000:8d:02.0: reg 10: [mem 0x84130000-0x84130fff]
pci 0000:8d:02.0: supports D1 D2
pci 0000:8d:02.0: PME# supported from D0 D1 D2 D3hot
pci 0000:8d:02.0: PME# disabled
pci 0000:8d:02.1: reg 10: [mem 0x84131000-0x84131fff]
pci 0000:8d:02.1: supports D1 D2
pci 0000:8d:02.1: PME# supported from D0 D1 D2 D3hot
pci 0000:8d:02.1: PME# disabled
pci 0000:8d:02.2: reg 10: [mem 0x84135000-0x841350ff]
pci 0000:8d:02.2: supports D1 D2
pci 0000:8d:02.2: PME# supported from D0 D1 D2 D3hot
pci 0000:8d:02.2: PME# disabled
pci 0000:8d:03.0: reg 10: [mem 0x80000000-0x83ffffff pref]
pci 0000:8d:03.0: reg 14: [io  0x8000-0x80ff]
pci 0000:8d:03.0: reg 18: [mem 0x84120000-0x8412ffff]
pci 0000:8d:03.0: reg 30: [mem 0x84100000-0x8411ffff pref]
pci 0000:8d:03.0: supports D1 D2
pci 0000:8c:01.0: PCI bridge to [bus 8d-8d]
pci 0000:8c:01.0:   bridge window [io  0x8000-0x8fff]
pci 0000:8c:01.0:   bridge window [mem 0x80000000-0x841fffff]
ACPI: PCI Interrupt Routing Table [\_SB_.N000.S000.IOC1.L008._PRT]
ACPI: PCI Root Bridge [L010] (0000:a9)
pci_root HWP0002:06: host bridge window [io  0xa000-0xbfff]
pci_root HWP0002:06: host bridge window [mem 0xf5000000000-0xf507edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0000:a9:01.0: reg 10: [mem 0x80100000-0x8011ffff 64bit]
pci 0000:a9:01.0: reg 18: [mem 0x80080000-0x800bffff 64bit]
pci 0000:a9:01.0: reg 20: [io  0xa000-0xa03f]
pci 0000:a9:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0000:a9:01.1: reg 10: [mem 0x80120000-0x8013ffff 64bit]
pci 0000:a9:01.1: reg 18: [mem 0x800c0000-0x800fffff 64bit]
pci 0000:a9:01.1: reg 20: [io  0xa040-0xa07f]
pci 0000:a9:01.1: reg 30: [mem 0x80040000-0x8007ffff pref]
ACPI: PCI Interrupt Routing Table [\_SB_.N000.S000.IOC1.L010._PRT]
ACPI: PCI Root Bridge [L012] (0000:c6)
pci_root HWP0002:07: host bridge window [io  0xc000-0xdfff]
pci_root HWP0002:07: host bridge window [mem 0xf6000000000-0xf607edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0000:c6:01.0: reg 10: [mem 0x80100000-0x8011ffff 64bit]
pci 0000:c6:01.0: reg 18: [mem 0x80080000-0x800bffff 64bit]
pci 0000:c6:01.0: reg 20: [io  0xc000-0xc03f]
pci 0000:c6:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0000:c6:01.1: reg 10: [mem 0x80120000-0x8013ffff 64bit]
pci 0000:c6:01.1: reg 18: [mem 0x800c0000-0x800fffff 64bit]
pci 0000:c6:01.1: reg 20: [io  0xc040-0xc07f]
pci 0000:c6:01.1: reg 30: [mem 0x80040000-0x8007ffff pref]
ACPI: PCI Interrupt Routing Table [\_SB_.N000.S000.IOC1.L012._PRT]
ACPI: PCI Root Bridge [L014] (0000:e3)
pci_root HWP0002:08: host bridge window [io  0xe000-0xffff]
pci_root HWP0002:08: host bridge window [mem 0xf7000000000-0xf707edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0000:e3:01.0: reg 10: [mem 0x80100000-0x8011ffff 64bit]
pci 0000:e3:01.0: reg 18: [mem 0x80080000-0x800bffff 64bit]
pci 0000:e3:01.0: reg 20: [io  0xe000-0xe03f]
pci 0000:e3:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0000:e3:01.1: reg 10: [mem 0x80120000-0x8013ffff 64bit]
pci 0000:e3:01.1: reg 18: [mem 0x800c0000-0x800fffff 64bit]
pci 0000:e3:01.1: reg 20: [io  0xe040-0xe07f]
pci 0000:e3:01.1: reg 30: [mem 0x80040000-0x8007ffff pref]
ACPI: PCI Interrupt Routing Table [\_SB_.N000.S000.IOC1.L014._PRT]
ACPI: PCI Root Bridge [L000] (0001:00)
pci_root HWP0002:09: host bridge window [io  0x1000000-0x1000fff] (PCI address [0x0-0xfff])
pci_root HWP0002:09: host bridge window [mem 0xf0100000000-0xf017edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0001:00:01.0: reg 10: [mem 0x80520000-0x8052ffff 64bit]
pci 0001:00:01.0: reg 30: [mem 0x80400000-0x8041ffff pref]
pci 0001:00:01.0: PME# supported from D3hot
pci 0001:00:01.0: PME# disabled
pci 0001:00:02.0: reg 10: [io  0x0800-0x08ff]
pci 0001:00:02.0: reg 14: [mem 0x80420000-0x8043ffff 64bit]
pci 0001:00:02.0: reg 1c: [mem 0x80440000-0x8045ffff 64bit]
pci 0001:00:02.0: reg 30: [mem 0x80000000-0x800fffff pref]
pci 0001:00:02.0: supports D1 D2
pci 0001:00:02.1: reg 10: [io  0x0900-0x09ff]
pci 0001:00:02.1: reg 14: [mem 0x80460000-0x8047ffff 64bit]
pci 0001:00:02.1: reg 1c: [mem 0x80480000-0x8049ffff 64bit]
pci 0001:00:02.1: reg 30: [mem 0x80100000-0x801fffff pref]
pci 0001:00:02.1: supports D1 D2
pci 0001:00:03.0: reg 10: [io  0x0a00-0x0aff]
pci 0001:00:03.0: reg 14: [mem 0x804a0000-0x804bffff 64bit]
pci 0001:00:03.0: reg 1c: [mem 0x804c0000-0x804dffff 64bit]
pci 0001:00:03.0: reg 30: [mem 0x80200000-0x802fffff pref]
pci 0001:00:03.0: supports D1 D2
pci 0001:00:03.1: reg 10: [io  0x0b00-0x0bff]
pci 0001:00:03.1: reg 14: [mem 0x804e0000-0x804fffff 64bit]
pci 0001:00:03.1: reg 1c: [mem 0x80500000-0x8051ffff 64bit]
pci 0001:00:03.1: reg 30: [mem 0x80300000-0x803fffff pref]
pci 0001:00:03.1: supports D1 D2
ACPI: PCI Interrupt Routing Table [\_SB_.N001.S016.IOC0.L000._PRT]
ACPI: PCI Root Bridge [L001] (0001:1c)
pci_root HWP0002:0a: host bridge window [io  0x1001000-0x1001fff] (PCI address [0x1000-0x1fff])
pci_root HWP0002:0a: host bridge window [mem 0xf0180000000-0xf01fedfffff] (PCI address [0x80000000-0xfedfffff])
pci 0001:1d:04.0: reg 10: [mem 0x80200000-0x8021ffff 64bit]
pci 0001:1d:04.0: reg 18: [mem 0x80100000-0x8013ffff 64bit]
pci 0001:1d:04.0: reg 20: [io  0x1000-0x103f]
pci 0001:1d:04.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0001:1d:04.1: reg 10: [mem 0x80220000-0x8023ffff 64bit]
pci 0001:1d:04.1: reg 18: [mem 0x80140000-0x8017ffff 64bit]
pci 0001:1d:04.1: reg 20: [io  0x1040-0x107f]
pci 0001:1d:04.1: reg 30: [mem 0x80040000-0x8007ffff pref]
pci 0001:1d:06.0: reg 10: [mem 0x80240000-0x8025ffff 64bit]
pci 0001:1d:06.0: reg 18: [mem 0x80180000-0x801bffff 64bit]
pci 0001:1d:06.0: reg 20: [io  0x1080-0x10bf]
pci 0001:1d:06.0: reg 30: [mem 0x80080000-0x800bffff pref]
pci 0001:1d:06.1: reg 10: [mem 0x80260000-0x8027ffff 64bit]
pci 0001:1d:06.1: reg 18: [mem 0x801c0000-0x801fffff 64bit]
pci 0001:1d:06.1: reg 20: [io  0x10c0-0x10ff]
pci 0001:1d:06.1: reg 30: [mem 0x800c0000-0x800fffff pref]
pci 0001:1c:01.0: PCI bridge to [bus 1d-1d]
pci 0001:1c:01.0:   bridge window [io  0x1000-0x1fff]
pci 0001:1c:01.0:   bridge window [mem 0x80000000-0x802fffff]
ACPI: PCI Interrupt Routing Table [\_SB_.N001.S016.IOC0.L001._PRT]
ACPI: PCI Root Bridge [L002] (0001:38)
pci_root HWP0002:0b: host bridge window [io  0x1002000-0x1003fff] (PCI address [0x2000-0x3fff])
pci_root HWP0002:0b: host bridge window [mem 0xf1100000000-0xf117edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0001:39:04.0: reg 10: [mem 0x80200000-0x8021ffff 64bit]
pci 0001:39:04.0: reg 18: [mem 0x80100000-0x8013ffff 64bit]
pci 0001:39:04.0: reg 20: [io  0x2000-0x203f]
pci 0001:39:04.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0001:39:04.1: reg 10: [mem 0x80220000-0x8023ffff 64bit]
pci 0001:39:04.1: reg 18: [mem 0x80140000-0x8017ffff 64bit]
pci 0001:39:04.1: reg 20: [io  0x2040-0x207f]
pci 0001:39:04.1: reg 30: [mem 0x80040000-0x8007ffff pref]
pci 0001:39:06.0: reg 10: [mem 0x80240000-0x8025ffff 64bit]
pci 0001:39:06.0: reg 18: [mem 0x80180000-0x801bffff 64bit]
pci 0001:39:06.0: reg 20: [io  0x2080-0x20bf]
pci 0001:39:06.0: reg 30: [mem 0x80080000-0x800bffff pref]
pci 0001:39:06.1: reg 10: [mem 0x80260000-0x8027ffff 64bit]
pci 0001:39:06.1: reg 18: [mem 0x801c0000-0x801fffff 64bit]
pci 0001:39:06.1: reg 20: [io  0x20c0-0x20ff]
pci 0001:39:06.1: reg 30: [mem 0x800c0000-0x800fffff pref]
pci 0001:38:01.0: PCI bridge to [bus 39-39]
pci 0001:38:01.0:   bridge window [io  0x2000-0x2fff]
pci 0001:38:01.0:   bridge window [mem 0x80000000-0x802fffff]
ACPI: PCI Interrupt Routing Table [\_SB_.N001.S016.IOC0.L002._PRT]
ACPI: PCI Root Bridge [L004] (0001:54)
pci_root HWP0002:0c: host bridge window [io  0x1004000-0x1005fff] (PCI address [0x4000-0x5fff])
pci_root HWP0002:0c: host bridge window [mem 0xf2100000000-0xf217edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0001:54:01.0: reg 10: [mem 0x80100000-0x8011ffff 64bit]
pci 0001:54:01.0: reg 18: [mem 0x80080000-0x800bffff 64bit]
pci 0001:54:01.0: reg 20: [io  0x4000-0x403f]
pci 0001:54:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0001:54:01.1: reg 10: [mem 0x80120000-0x8013ffff 64bit]
pci 0001:54:01.1: reg 18: [mem 0x800c0000-0x800fffff 64bit]
pci 0001:54:01.1: reg 20: [io  0x4040-0x407f]
pci 0001:54:01.1: reg 30: [mem 0x80040000-0x8007ffff pref]
ACPI: PCI Interrupt Routing Table [\_SB_.N001.S016.IOC0.L004._PRT]
ACPI: PCI Root Bridge [L006] (0001:70)
pci_root HWP0002:0d: host bridge window [io  0x1006000-0x1007fff] (PCI address [0x6000-0x7fff])
pci_root HWP0002:0d: host bridge window [mem 0xf3100000000-0xf317edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0001:70:01.0: reg 10: [mem 0x80100000-0x8011ffff 64bit]
pci 0001:70:01.0: reg 18: [mem 0x80080000-0x800bffff 64bit]
pci 0001:70:01.0: reg 20: [io  0x6000-0x603f]
pci 0001:70:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0001:70:01.1: reg 10: [mem 0x80120000-0x8013ffff 64bit]
pci 0001:70:01.1: reg 18: [mem 0x800c0000-0x800fffff 64bit]
pci 0001:70:01.1: reg 20: [io  0x6040-0x607f]
pci 0001:70:01.1: reg 30: [mem 0x80040000-0x8007ffff pref]
ACPI: PCI Interrupt Routing Table [\_SB_.N001.S016.IOC0.L006._PRT]
ACPI: PCI Root Bridge [L008] (0001:8c)
pci_root HWP0002:0e: host bridge window [io  0x1008000-0x1009fff] (PCI address [0x8000-0x9fff])
pci_root HWP0002:0e: host bridge window [mem 0xf4100000000-0xf417edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0001:8c:01.0: reg 10: [mem 0x80080000-0x8009ffff 64bit]
pci 0001:8c:01.0: reg 18: [mem 0x80040000-0x8007ffff 64bit]
pci 0001:8c:01.0: reg 20: [io  0x8000-0x803f]
pci 0001:8c:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0001:8c:01.1: reg 10: [mem 0x800a0000-0x800bffff 64bit]
pci 0001:8c:01.1: reg 20: [io  0x8040-0x807f]
ACPI: PCI Interrupt Routing Table [\_SB_.N001.S016.IOC1.L008._PRT]
ACPI: PCI Root Bridge [L010] (0001:a9)
pci_root HWP0002:0f: host bridge window [io  0x100a000-0x100bfff] (PCI address [0xa000-0xbfff])
pci_root HWP0002:0f: host bridge window [mem 0xf5100000000-0xf517edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0001:a9:01.0: reg 10: [mem 0x80100000-0x8011ffff 64bit]
pci 0001:a9:01.0: reg 18: [mem 0x80080000-0x800bffff 64bit]
pci 0001:a9:01.0: reg 20: [io  0xa000-0xa03f]
pci 0001:a9:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0001:a9:01.1: reg 10: [mem 0x80120000-0x8013ffff 64bit]
pci 0001:a9:01.1: reg 18: [mem 0x800c0000-0x800fffff 64bit]
pci 0001:a9:01.1: reg 20: [io  0xa040-0xa07f]
pci 0001:a9:01.1: reg 30: [mem 0x80040000-0x8007ffff pref]
ACPI: PCI Interrupt Routing Table [\_SB_.N001.S016.IOC1.L010._PRT]
ACPI: PCI Root Bridge [L012] (0001:c6)
pci_root HWP0002:10: host bridge window [io  0x100c000-0x100dfff] (PCI address [0xc000-0xdfff])
pci_root HWP0002:10: host bridge window [mem 0xf6100000000-0xf617edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0001:c6:01.0: reg 10: [mem 0x80100000-0x8011ffff 64bit]
pci 0001:c6:01.0: reg 18: [mem 0x80080000-0x800bffff 64bit]
pci 0001:c6:01.0: reg 20: [io  0xc000-0xc03f]
pci 0001:c6:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0001:c6:01.1: reg 10: [mem 0x80120000-0x8013ffff 64bit]
pci 0001:c6:01.1: reg 18: [mem 0x800c0000-0x800fffff 64bit]
pci 0001:c6:01.1: reg 20: [io  0xc040-0xc07f]
pci 0001:c6:01.1: reg 30: [mem 0x80040000-0x8007ffff pref]
ACPI: PCI Interrupt Routing Table [\_SB_.N001.S016.IOC1.L012._PRT]
ACPI: PCI Root Bridge [L014] (0001:e3)
pci_root HWP0002:11: host bridge window [io  0x100e000-0x100ffff] (PCI address [0xe000-0xffff])
pci_root HWP0002:11: host bridge window [mem 0xf7100000000-0xf717edfffff] (PCI address [0x80000000-0xfedfffff])
pci 0001:e3:01.0: reg 10: [mem 0x80100000-0x8011ffff 64bit]
pci 0001:e3:01.0: reg 18: [mem 0x80080000-0x800bffff 64bit]
pci 0001:e3:01.0: reg 20: [io  0xe000-0xe03f]
pci 0001:e3:01.0: reg 30: [mem 0x80000000-0x8003ffff pref]
pci 0001:e3:01.1: reg 10: [mem 0x80120000-0x8013ffff 64bit]
pci 0001:e3:01.1: reg 18: [mem 0x800c0000-0x800fffff 64bit]
pci 0001:e3:01.1: reg 20: [io  0xe040-0xe07f]
pci 0001:e3:01.1: reg 30: [mem 0x80040000-0x8007ffff pref]
ACPI: PCI Interrupt Routing Table [\_SB_.N001.S016.IOC1.L014._PRT]
vgaarb: device added: PCI:0000:8d:03.0,decodes=io+mem,owns=none,locks=none
vgaarb: loaded
SCSI subsystem initialized
libata version 3.00 loaded.
IOC: sx2000 0.1 HPA 0xf8020002000 IOVA space 1024Mb at 0x40000000
IOC: sx2000 0.1 HPA 0xf8020003000 IOVA space 1024Mb at 0x40000000
IOC: sx2000 0.1 HPA 0xf8120002000 IOVA space 1024Mb at 0x40000000
IOC: sx2000 0.1 HPA 0xf8120003000 IOVA space 1024Mb at 0x40000000
DMA-API: preallocated 65536 debug entries
DMA-API: debugging enabled by kernel config
Switching to clocksource itc
pnp: PnP ACPI init
ACPI: bus type pnp registered
GSI 17 (level, low) -> CPU 2 (0x0400) vector 50
GSI 18 (edge, low) -> CPU 3 (0x0500) vector 51
GSI 19 (edge, low) -> CPU 4 (0x0800) vector 52
GSI 20 (edge, low) -> CPU 5 (0x0900) vector 53
GSI 23 (level, low) -> CPU 6 (0x0c00) vector 54
GSI 126 (edge, low) -> CPU 15 (0x0d01) vector 55
GSI 127 (edge, low) -> CPU 8 (0x0001) vector 56
GSI 128 (edge, low) -> CPU 9 (0x0101) vector 57
pnp: PnP ACPI: found 36 devices
ACPI: ACPI bus type pnp unregistered
NET: Registered protocol family 2
IP route cache hash table entries: 524288 (order: 6, 4194304 bytes)
TCP established hash table entries: 524288 (order: 7, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 4, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
UDP hash table entries: 32768 (order: 4, 1048576 bytes)
UDP-Lite hash table entries: 32768 (order: 4, 1048576 bytes)
NET: Registered protocol family 1
PCI: CLS 128 bytes, default 128
Trying to unpack rootfs image as initramfs...
Freeing initrd memory: 5824kB freed
perfmon: version 2.0 IRQ 238
perfmon: Montecito PMU detected, 27 PMCs, 35 PMDs, 12 counters (47 bits)
PAL Information Facility v0.5
perfmon: added sampling format default_format
perfmon_default_smpl: default_format v2.0 registered
Please use IA-32 EL for executing IA-32 binaries
HugeTLB registered 256 MB page size, pre-allocated 0 pages
msgmni has been set to 32768
alg: No test for stdrng (krng)
io scheduler noop registered
io scheduler deadline registered
io scheduler cfq registered (default)
hpet0: at MMIO 0xffff6030000, IRQs 51, 52, 53
hpet0: 3 comparators, 64-bit 267.000025 MHz counter
hpet1: at MMIO 0xffff60b0000, IRQs 55, 56, 57
hpet1: 3 comparators, 64-bit 267.000025 MHz counter
EFI Time Services Driver v0.4
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
00:03: ttyS0 at MMIO 0xffc30064000 (irq = 54) is a 16550A
console [ttyS0] enabled, bootconsole disabled
console [ttyS0] enabled, bootconsole disabled
brd: module loaded
Uniform Multi-Platform E-IDE driver
ide-gd driver 1.18
ide-cd driver 5.00
Intel(R) PRO/1000 Network Driver - version 7.3.21-k5-NAPI
Copyright (c) 1999-2006 Intel Corporation.
GSI 36 (level, low) -> CPU 2 (0x0400) vector 58
e1000 0000:1c:01.0: PCI INT A -> GSI 36 (level, low) -> IRQ 58
e1000: 0000:1c:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:15:60:04:12:76
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 37 (level, low) -> CPU 3 (0x0500) vector 59
e1000 0000:1c:01.1: PCI INT B -> GSI 37 (level, low) -> IRQ 59
e1000: 0000:1c:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:15:60:04:12:77
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 47 (level, low) -> CPU 4 (0x0800) vector 60
e1000 0000:38:01.0: PCI INT A -> GSI 47 (level, low) -> IRQ 60
e1000: 0000:38:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:12:79:9e:b8:28
e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 48 (level, low) -> CPU 5 (0x0900) vector 61
e1000 0000:38:01.1: PCI INT B -> GSI 48 (level, low) -> IRQ 61
e1000: 0000:38:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:12:79:9e:b8:29
e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 58 (level, low) -> CPU 6 (0x0c00) vector 62
e1000 0000:54:01.0: PCI INT A -> GSI 58 (level, low) -> IRQ 62
e1000: 0000:54:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:12:79:9e:b8:44
e1000: eth4: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 59 (level, low) -> CPU 7 (0x0d00) vector 63
e1000 0000:54:01.1: PCI INT B -> GSI 59 (level, low) -> IRQ 63
e1000: 0000:54:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:12:79:9e:b8:45
e1000: eth5: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 69 (level, low) -> CPU 0 (0x0000) vector 64
e1000 0000:70:01.0: PCI INT A -> GSI 69 (level, low) -> IRQ 64
e1000: 0000:70:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:30:6e:5d:2f:1a
e1000: eth6: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 70 (level, low) -> CPU 1 (0x0100) vector 65
e1000 0000:70:01.1: PCI INT B -> GSI 70 (level, low) -> IRQ 65
e1000: 0000:70:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:30:6e:5d:2f:1b
e1000: eth7: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 91 (level, low) -> CPU 2 (0x0400) vector 66
e1000 0000:a9:01.0: PCI INT A -> GSI 91 (level, low) -> IRQ 66
e1000: 0000:a9:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:30:6e:5d:2b:d6
e1000: eth8: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 92 (level, low) -> CPU 3 (0x0500) vector 67
e1000 0000:a9:01.1: PCI INT B -> GSI 92 (level, low) -> IRQ 67
e1000: 0000:a9:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:30:6e:5d:2b:d7
e1000: eth9: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 102 (level, low) -> CPU 4 (0x0800) vector 68
e1000 0000:c6:01.0: PCI INT A -> GSI 102 (level, low) -> IRQ 68
e1000: 0000:c6:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:30:6e:5d:30:c2
e1000: eth10: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 103 (level, low) -> CPU 5 (0x0900) vector 69
e1000 0000:c6:01.1: PCI INT B -> GSI 103 (level, low) -> IRQ 69
e1000: 0000:c6:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:30:6e:5d:30:c3
e1000: eth11: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 113 (level, low) -> CPU 6 (0x0c00) vector 70
e1000 0000:e3:01.0: PCI INT A -> GSI 113 (level, low) -> IRQ 70
e1000: 0000:e3:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:30:6e:5d:30:c6
e1000: eth12: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 114 (level, low) -> CPU 7 (0x0d00) vector 71
e1000 0000:e3:01.1: PCI INT B -> GSI 114 (level, low) -> IRQ 71
e1000: 0000:e3:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:30:6e:5d:30:c7
e1000: eth13: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 144 (level, low) -> CPU 8 (0x0001) vector 72
e1000 0001:1d:04.0: PCI INT A -> GSI 144 (level, low) -> IRQ 72
e1000: 0001:1d:04.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:42:fe:90
e1000: eth14: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 145 (level, low) -> CPU 9 (0x0101) vector 73
e1000 0001:1d:04.1: PCI INT B -> GSI 145 (level, low) -> IRQ 73
e1000: 0001:1d:04.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:42:fe:91
e1000: eth15: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 146 (level, low) -> CPU 10 (0x0401) vector 74
e1000 0001:1d:06.0: PCI INT A -> GSI 146 (level, low) -> IRQ 74
e1000: 0001:1d:06.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:42:fe:92
e1000: eth16: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 147 (level, low) -> CPU 11 (0x0501) vector 75
e1000 0001:1d:06.1: PCI INT B -> GSI 147 (level, low) -> IRQ 75
e1000: 0001:1d:06.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:42:fe:93
e1000: eth17: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 155 (level, low) -> CPU 12 (0x0801) vector 76
e1000 0001:39:04.0: PCI INT A -> GSI 155 (level, low) -> IRQ 76
e1000: 0001:39:04.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:43:ab:00
e1000: eth18: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 156 (level, low) -> CPU 13 (0x0901) vector 77
e1000 0001:39:04.1: PCI INT B -> GSI 156 (level, low) -> IRQ 77
e1000: 0001:39:04.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:43:ab:01
e1000: eth19: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 157 (level, low) -> CPU 14 (0x0c01) vector 78
e1000 0001:39:06.0: PCI INT A -> GSI 157 (level, low) -> IRQ 78
e1000: 0001:39:06.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:43:ab:02
e1000: eth20: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 158 (level, low) -> CPU 15 (0x0d01) vector 79
e1000 0001:39:06.1: PCI INT B -> GSI 158 (level, low) -> IRQ 79
e1000: 0001:39:06.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:43:ab:03
e1000: eth21: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 166 (level, low) -> CPU 8 (0x0001) vector 80
e1000 0001:54:01.0: PCI INT A -> GSI 166 (level, low) -> IRQ 80
e1000: 0001:54:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:30:6e:5d:32:30
e1000: eth22: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 167 (level, low) -> CPU 9 (0x0101) vector 81
e1000 0001:54:01.1: PCI INT B -> GSI 167 (level, low) -> IRQ 81
e1000: 0001:54:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:30:6e:5d:32:31
e1000: eth23: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 177 (level, low) -> CPU 10 (0x0401) vector 82
e1000 0001:70:01.0: PCI INT A -> GSI 177 (level, low) -> IRQ 82
e1000: 0001:70:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:12:79:9e:59:2c
e1000: eth24: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 178 (level, low) -> CPU 11 (0x0501) vector 83
e1000 0001:70:01.1: PCI INT B -> GSI 178 (level, low) -> IRQ 83
e1000: 0001:70:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:12:79:9e:59:2d
e1000: eth25: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 188 (level, low) -> CPU 12 (0x0801) vector 84
e1000 0001:8c:01.0: PCI INT A -> GSI 188 (level, low) -> IRQ 84
e1000: 0001:8c:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:30:6e:10:01:7e
e1000: eth26: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 189 (level, low) -> CPU 13 (0x0901) vector 85
e1000 0001:8c:01.1: PCI INT B -> GSI 189 (level, low) -> IRQ 85
e1000: 0001:8c:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:30:6e:10:01:7f
e1000: eth27: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 199 (level, low) -> CPU 14 (0x0c01) vector 86
e1000 0001:a9:01.0: PCI INT A -> GSI 199 (level, low) -> IRQ 86
e1000: 0001:a9:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:12:79:9e:69:58
e1000: eth28: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 200 (level, low) -> CPU 15 (0x0d01) vector 87
e1000 0001:a9:01.1: PCI INT B -> GSI 200 (level, low) -> IRQ 87
e1000: 0001:a9:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:12:79:9e:69:59
e1000: eth29: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 210 (level, low) -> CPU 8 (0x0001) vector 88
e1000 0001:c6:01.0: PCI INT A -> GSI 210 (level, low) -> IRQ 88
e1000: 0001:c6:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:12:79:9e:56:78
e1000: eth30: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 211 (level, low) -> CPU 9 (0x0101) vector 89
e1000 0001:c6:01.1: PCI INT B -> GSI 211 (level, low) -> IRQ 89
e1000: 0001:c6:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:12:79:9e:56:79
e1000: eth31: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 221 (level, low) -> CPU 10 (0x0401) vector 90
e1000 0001:e3:01.0: PCI INT A -> GSI 221 (level, low) -> IRQ 90
e1000: 0001:e3:01.0: e1000_check_options: Warning: no configuration for board #32
e1000: 0001:e3:01.0: e1000_check_options: Using defaults for all values
e1000: 0001:e3:01.0: e1000_probe: (PCI-X:133MHz:64-bit) 00:12:79:9e:b8:00
e1000: eth32: e1000_probe: Intel(R) PRO/1000 Network Connection
GSI 222 (level, low) -> CPU 11 (0x0501) vector 91
e1000 0001:e3:01.1: PCI INT B -> GSI 222 (level, low) -> IRQ 91
e1000: 0001:e3:01.1: e1000_check_options: Warning: no configuration for board #33
e1000: 0001:e3:01.1: e1000_check_options: Using defaults for all values
e1000: 0001:e3:01.1: e1000_probe: (PCI-X:133MHz:64-bit) 00:12:79:9e:b8:01
e1000: eth33: e1000_probe: Intel(R) PRO/1000 Network Connection
Intel(R) Gigabit Ethernet Network Driver - version 2.1.0-k2
Copyright (c) 2007-2009 Intel Corporation.
tg3.c:v3.105 (December 2, 2009)
GSI 29 (level, low) -> CPU 4 (0x0800) vector 92
tg3 0000:00:01.0: PCI INT A -> GSI 29 (level, low) -> IRQ 92
eth34: Tigon3 [partno(BCM95700A6) rev 1100] (PCIX:66MHz:64-bit) MAC address 00:1b:78:d2:b6:7b
eth34: attached PHY is 5703 (10/100/1000Base-T Ethernet) (WireSpeed[1])
eth34: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
eth34: dma_rwctrl[769c0000] dma_mask[64-bit]
GSI 137 (level, low) -> CPU 13 (0x0901) vector 93
tg3 0001:00:01.0: PCI INT A -> GSI 137 (level, low) -> IRQ 93
eth35: Tigon3 [partno(BCM95700A6) rev 1100] (PCIX:66MHz:64-bit) MAC address 00:1b:78:d2:36:5f
eth35: attached PHY is 5703 (10/100/1000Base-T Ethernet) (WireSpeed[1])
eth35: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
eth35: dma_rwctrl[769c0000] dma_mask[64-bit]
console [netcon0] enabled
netconsole: network logging started
Fusion MPT base driver 3.04.13
Copyright (c) 1999-2008 LSI Corporation
Fusion MPT SPI Host driver 3.04.13
GSI 25 (level, low) -> CPU 6 (0x0c00) vector 94
mptspi 0000:00:02.0: PCI INT A -> GSI 25 (level, low) -> IRQ 94
mptbase: ioc0: Initiating bringup
ioc0: LSI53C1030 C0: Capabilities={Initiator,Target}
scsi0 : ioc0: LSI53C1030 C0, FwRev=01032346h, Ports=1, MaxQ=255, IRQ=94
scsi 0:0:6:0: Direct-Access     HP 73.4G ST373455LC       HPC8 PQ: 0 ANSI: 3
 target0:0:6: Beginning Domain Validation
 target0:0:6: Ending Domain Validation
 target0:0:6: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI WRFLOW PCOMP (6.25 ns, offset 127)
sd 0:0:6:0: [sda] 143374738 512-byte logical blocks: (73.4 GB/68.3 GiB)
sd 0:0:6:0: [sda] Write Protect is off
sd 0:0:6:0: [sda] Mode Sense: d3 00 10 08
sd 0:0:6:0: [sda] Write cache: disabled, read cache: enabled, supports DPO and FUA
 sda:
GSI 26 (level, low) -> CPU 7 (0x0d00) vector 95
mptspi 0000:00:02.1: PCI INT B -> GSI 26 (level, low) -> IRQ 95
mptbase: ioc1: Initiating bringup
ioc1: LSI53C1030 C0: Capabilities={Initiator,Target}
scsi1 : ioc1: LSI53C1030 C0, FwRev=01032346h, Ports=1, MaxQ=255, IRQ=95
 sda1 sda2 sda3
sd 0:0:6:0: [sda] Attached SCSI disk
scsi 1:0:2:0: CD-ROM            Optiarc  DVD RW AD-5170A  1.32 PQ: 0 ANSI: 2
 target1:0:2: Beginning Domain Validation
 target1:0:2: Domain Validation skipping write tests
 target1:0:2: Ending Domain Validation
 target1:0:2: FAST-20 WIDE SCSI 40.0 MB/s ST (50 ns, offset 14)
GSI 27 (level, low) -> CPU 0 (0x0000) vector 96
mptspi 0000:00:03.0: PCI INT A -> GSI 27 (level, low) -> IRQ 96
mptbase: ioc2: Initiating bringup
ioc2: LSI53C1030 C0: Capabilities={Initiator,Target}
scsi2 : ioc2: LSI53C1030 C0, FwRev=01032346h, Ports=1, MaxQ=255, IRQ=96
scsi 2:0:6:0: Direct-Access     HP 73.4G ST373455LC       HPC8 PQ: 0 ANSI: 3
 target2:0:6: Beginning Domain Validation
 target2:0:6: Ending Domain Validation
 target2:0:6: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI WRFLOW PCOMP (6.25 ns, offset 127)
sd 2:0:6:0: [sdb] 143374738 512-byte logical blocks: (73.4 GB/68.3 GiB)
sd 2:0:6:0: [sdb] Write Protect is off
sd 2:0:6:0: [sdb] Mode Sense: d3 00 10 08
sd 2:0:6:0: [sdb] Write cache: disabled, read cache: enabled, supports DPO and FUA
 sdb:
GSI 28 (level, low) -> CPU 1 (0x0100) vector 97
mptspi 0000:00:03.1: PCI INT B -> GSI 28 (level, low) -> IRQ 97
mptbase: ioc3: Initiating bringup
ioc3: LSI53C1030 C0: Capabilities={Initiator,Target}
scsi3 : ioc3: LSI53C1030 C0, FwRev=01032346h, Ports=1, MaxQ=255, IRQ=97
 sdb1 sdb2
sd 2:0:6:0: [sdb] Attached SCSI disk
GSI 133 (level, low) -> CPU 10 (0x0401) vector 98
mptspi 0001:00:02.0: PCI INT A -> GSI 133 (level, low) -> IRQ 98
mptbase: ioc4: Initiating bringup
ioc4: LSI53C1030 C0: Capabilities={Initiator,Target}
scsi4 : ioc4: LSI53C1030 C0, FwRev=01032346h, Ports=1, MaxQ=255, IRQ=98
scsi 4:0:6:0: Direct-Access     HP 73.4G ST373454LC       HPC2 PQ: 0 ANSI: 3
 target4:0:6: Beginning Domain Validation
 target4:0:6: Ending Domain Validation
 target4:0:6: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
sd 4:0:6:0: [sdc] 143374738 512-byte logical blocks: (73.4 GB/68.3 GiB)
sd 4:0:6:0: [sdc] Write Protect is off
sd 4:0:6:0: [sdc] Mode Sense: d3 00 10 08
sd 4:0:6:0: [sdc] Write cache: disabled, read cache: enabled, supports DPO and FUA
 sdc:
GSI 134 (level, low) -> CPU 11 (0x0501) vector 99
mptspi 0001:00:02.1: PCI INT B -> GSI 134 (level, low) -> IRQ 99
mptbase: ioc5: Initiating bringup
ioc5: LSI53C1030 C0: Capabilities={Initiator,Target}
 sdc1 sdc2
scsi5 : ioc5: LSI53C1030 C0, FwRev=01032346h, Ports=1, MaxQ=255, IRQ=99
sd 4:0:6:0: [sdc] Attached SCSI disk
scsi 5:0:2:0: CD-ROM            _NEC     DVD+RW ND-2100AD 1.28 PQ: 0 ANSI: 2
 target5:0:2: Beginning Domain Validation
 target5:0:2: Domain Validation skipping write tests
 target5:0:2: Ending Domain Validation
 target5:0:2: FAST-20 WIDE SCSI 40.0 MB/s ST (50 ns, offset 14)
GSI 135 (level, low) -> CPU 12 (0x0801) vector 100
mptspi 0001:00:03.0: PCI INT A -> GSI 135 (level, low) -> IRQ 100
mptbase: ioc6: Initiating bringup
ioc6: LSI53C1030 C0: Capabilities={Initiator,Target}
scsi6 : ioc6: LSI53C1030 C0, FwRev=01032346h, Ports=1, MaxQ=255, IRQ=100
scsi 6:0:6:0: Direct-Access     HP 73.4G ST373454LC       HPC3 PQ: 0 ANSI: 3
 target6:0:6: Beginning Domain Validation
 target6:0:6: Ending Domain Validation
 target6:0:6: FAST-160 WIDE SCSI 320.0 MB/s DT IU QAS RTI WRFLOW PCOMP (6.25 ns, offset 63)
sd 6:0:6:0: [sdd] 143374738 512-byte logical blocks: (73.4 GB/68.3 GiB)
sd 6:0:6:0: [sdd] Write Protect is off
sd 6:0:6:0: [sdd] Mode Sense: d3 00 10 08
sd 6:0:6:0: [sdd] Write cache: disabled, read cache: enabled, supports DPO and FUA
 sdd:
GSI 136 (level, low) -> CPU 13 (0x0901) vector 101
mptspi 0001:00:03.1: PCI INT B -> GSI 136 (level, low) -> IRQ 101
mptbase: ioc7: Initiating bringup
ioc7: LSI53C1030 C0: Capabilities={Initiator,Target}
 sdd1 sdd2
scsi7 : ioc7: LSI53C1030 C0, FwRev=01032346h, Ports=1, MaxQ=255, IRQ=101
sd 6:0:6:0: [sdd] Attached SCSI disk
Fusion MPT SAS Host driver 3.04.13
mice: PS/2 mouse device common for all mice
EFI Variables Facility v0.08 2004-May-17
TCP cubic registered
NET: Registered protocol family 17
Freeing unused kernel memory: 1984kB freed
doing fast boot
FATAL: Module mptspi not found.
FATAL: Module jbd not found.
FATAL: Module ext3 not found.
preping 03-storage.sh
running 03-storage.sh
preping 04-udev.sh
running 04-udev.sh
Creating device nodes with udev
udevd version 128 started
udev: renamed network interface eth10 to eth11
udev: renamed network interface eth20 to eth22
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
GSI 80 (level, low) -> CPU 6 (0x0c00) vector 102
ehci_hcd 0000:8d:02.2: PCI INT C -> GSI 80 (level, low) -> IRQ 102
ehci_hcd 0000:8d:02.2: EHCI Host Controller
ehci_hcd 0000:8d:02.2: new USB bus registered, assigned bus number 1
ehci_hcd 0000:8d:02.2: irq 102, io mem 0xf4004135000
ehci_hcd 0000:8d:02.2: USB 2.0 started, EHCI 1.00
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 3 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
GSI 82 (level, low) -> CPU 7 (0x0d00) vector 103
ohci_hcd 0000:8d:02.0: PCI INT A -> GSI 82 (level, low) -> IRQ 103
ohci_hcd 0000:8d:02.0: OHCI Host Controller
ohci_hcd 0000:8d:02.0: new USB bus registered, assigned bus number 2
ohci_hcd 0000:8d:02.0: irq 103, io mem 0xf4004130000
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
GSI 83 (level, low) -> CPU 0 (0x0000) vector 104
ohci_hcd 0000:8d:02.1: PCI INT B -> GSI 83 (level, low) -> IRQ 104
ohci_hcd 0000:8d:02.1: OHCI Host Controller
ohci_hcd 0000:8d:02.1: new USB bus registered, assigned bus number 3
ohci_hcd 0000:8d:02.1: irq 104, io mem 0xf4004131000
udev: renamed network interface eth30 to eth32
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 1 port detected
udev: renamed network interface eth34 to eth0
udev: renamed network interface eth31 to eth33
udev: renamed network interface eth35 to eth15
udev: renamed network interface eth4 to eth5
udev: renamed network interface eth9 to eth10
udev: renamed network interface eth1_rename to eth2
udev: renamed network interface eth0_rename to eth1
udev: renamed network interface eth11_rename to eth12
udev: renamed network interface eth12_rename to eth13
udev: renamed network interface eth13_rename to eth14
udev: renamed network interface eth14_rename to eth16
udev: renamed network interface eth17_rename to eth19
udev: renamed network interface eth18_rename to eth20
udev: renamed network interface eth15_rename to eth17
udev: renamed network interface eth16_rename to eth18
udev: renamed network interface eth19_rename to eth21
usb 2-1: new full speed USB device using ohci_hcd and address 2
udev: renamed network interface eth2_rename to eth3
udev: renamed network interface eth21_rename to eth23
udev: renamed network interface eth22_rename to eth24
udev: renamed network interface eth23_rename to eth25
udev: renamed network interface eth24_rename to eth26
udev: renamed network interface eth28_rename to eth30
udev: renamed network interface eth25_rename to eth27
udev: renamed network interface eth26_rename to eth28
udev: renamed network interface eth27_rename to eth29
udev: renamed network interface eth29_rename to eth31
udev: renamed network interface eth3_rename to eth4
input: HP Virtual Management Device as /class/input/input0
generic-usb 0003:03F0:1126.0001: input: USB HID v1.11 Keyboard [HP Virtual Management Device] on usb-0000:8d:02.0-1/input0
input: HP Virtual Management Device as /class/input/input1
generic-usb 0003:03F0:1126.0002: input: USB HID v1.01 Mouse [HP Virtual Management Device] on usb-0000:8d:02.0-1/input1
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
udev: renamed network interface eth32_rename to eth34
udev: renamed network interface eth33_rename to eth35
udev: renamed network interface eth8_rename to eth9
udev: renamed network interface eth5_rename to eth6
udev: renamed network interface eth6_rename to eth7
udev: renamed network interface eth7_rename to eth8
preping 05-blogd.sh
running 05-blogd.sh
Boot logging started on /dev/ttyS0(/dev/console) at Tue Jan 19 22:22:27 2010
preping 11-block.sh
running 11-block.sh
preping 11-usb.sh
running 11-usb.sh
preping 21-devinit_done.sh
running 21-devinit_done.sh
preping 81-mount.sh
running 81-mount.sh
Waiting for device /dev/disk/by-id/scsi-35001d38000048bd8-part2 to appear:  ok
showconsole: Warning: the ioctl TIOCGDEV is not known by the kernel
fsck 1.41.1 (01-Sep-2008)
[/sbin/fsck.ext3 (1) -- /] fsck.ext3 -a /dev/disk/by-id/scsi-35001d38000048bd8-part2 
/dev/disk/by-id/scsi-35001d38000048bd8-part2: clean, 208025/4448256 files, 3299103/17789968 blocks
fsck succeeded. Mounting root device read-write.
Mounting root /dev/disk/by-id/scsi-35001d38000048bd8-part2
mount -o rw,acl,user_xattr -t ext3 /dev/disk/by-id/scsi-35001d38000048bd8-part2 /root
kjournald starting.  Commit interval 5 seconds
EXT3-fs (sdb2): using internal journal
EXT3-fs (sdb2): mounted filesystem with writeback data mode
preping 82-remount.sh
running 82-remount.sh
preping 91-createfb.sh
running 91-createfb.sh
preping 91-killblogd.sh
running 91-killblogd.sh
preping 91-killudev.sh
running 91-killudev.sh
preping 91-shell.sh
running 91-shell.sh
preping 92-killblogd2.sh
running 92-killblogd2.sh
preping 93-boot.sh
running 93-boot.sh
mount: can't find /root/proc in /etc/fstab or /etc/mtab
INIT: version 2.86 booting
System Boot Control: Running /etc/init.d/boot
Mounting procfs at /proc                                             done
Mounting sysfs at /sys                                               done
Remounting tmpfs at /dev                                             done
Initializing /dev                                                    done
Mounting devpts at /dev/pts                                          done
Starting udevd: udevd version 128 started
                                                                     done
Loading drivers, configuring devices: input: Power Button as /class/input/input2
ACPI: Power Button [PWRB]
input: Sleep Button as /class/input/input3
ACPI: Sleep Button [SLPF]
sd 0:0:6:0: Attached scsi generic sg0 type 0
scsi 1:0:2:0: Attached scsi generic sg1 type 5
sd 2:0:6:0: Attached scsi generic sg2 type 0
sd 4:0:6:0: Attached scsi generic sg3 type 0
scsi 5:0:2:0: Attached scsi generic sg4 type 5
sd 6:0:6:0: Attached scsi generic sg5 type 0
sr0: scsi3-mmc drive: 48x/48x writer cd/rw xa/form2 cdda tray
kernel BUG at mm/slub.c:2839!
modprobe[6155]: bugcheck! 0 [1]
Modules linked in: sr_mod(+) sg button container(+) usbhid ohci_hcd ehci_hcd usbcore fan thermal processor thermal_sys

Pid: 6155, CPU 9, comm:             modprobe
psr : 0000101008526010 ifs : 8000000000000289 ip  : [<a0000001001ae800>]    Not tainted (2.6.33-rc3-next-20100111-dirty)
ip is at kfree+0xe0/0x260
unat: 0000000000000000 pfs : 0000000000000289 rsc : 0000000000000003
rnat: e000070607721720 bsps: aa99aaa6aa595999 pr  : aa99aaa6aa565959
ldrs: 0000000000000000 ccv : 00000000000000c2 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001ae800 b6  : a0000001005e4360 b7  : a00000010046de40
f6  : 1003e0000000cb700a034 f7  : 1003e0000000000000190
f8  : 1003e0000000cb7009ea4 f9  : 1003e0000000000000001
f10 : 0fffefffffffffa0a1f00 f11 : 1003e0000000000000000
r1  : a0000001014480f0 r2  : 0000000000001816 r3  : 000000000000fffe
r8  : 0000000000000021 r9  : 000000000000ffff r10 : ffffffffffff40a1
r11 : 0000000000000000 r12 : e00007060772fdf0 r13 : e000070607720000
r14 : 0000000000001816 r15 : 0000000000004000 r16 : a00000010119c62c
r17 : a000000101265d70 r18 : 0000000000000009 r19 : a0000001005e4360
r20 : a0000001018edb38 r21 : 000000000000bf41 r22 : 00000000000fffff
r23 : 0000000000100000 r24 : a000000102a3ddc8 r25 : a000000100a0dca8
r26 : a00000010046de40 r27 : a000000102a3ddc8 r28 : a000000102a3dec0
r29 : a000000100a0dc98 r30 : a00000010046dd80 r31 : a000000102a3ddc0

Call Trace:
 [<a000000100016950>] show_stack+0x50/0xa0
                                sp=e00007060772f9c0 bsp=e000070607721368
 [<a0000001000171c0>] show_regs+0x820/0x860
                                sp=e00007060772fb90 bsp=e000070607721310
 [<a00000010003bc40>] die+0x1a0/0x300
                                sp=e00007060772fb90 bsp=e0000706077212d0
 [<a00000010003bdf0>] die_if_kernel+0x50/0x80
                                sp=e00007060772fb90 bsp=e0000706077212a0
 [<a00000010003d460>] ia64_bad_break+0x220/0x440
                                sp=e00007060772fb90 bsp=e000070607721278
 [<a00000010000c8a0>] ia64_native_leave_kernel+0x0/0x270
                                sp=e00007060772fc20 bsp=e000070607721278
 [<a0000001001ae800>] kfree+0xe0/0x260
                                sp=e00007060772fdf0 bsp=e000070607721230
 [<a000000207dd1df0>] sr_probe+0xad0/0xf20 [sr_mod]
                                sp=e00007060772fdf0 bsp=e0000706077211c8
 [<a00000010048ab40>] driver_probe_device+0x180/0x300
                                sp=e00007060772fe20 bsp=e000070607721190
 [<a00000010048ada0>] __driver_attach+0xe0/0x140
                                sp=e00007060772fe20 bsp=e000070607721160
 [<a0000001004897a0>] bus_for_each_dev+0xa0/0x140
                                sp=e00007060772fe20 bsp=e000070607721128
 [<a00000010048a760>] driver_attach+0x40/0x60
                                sp=e00007060772fe30 bsp=e000070607721108
 [<a0000001004885c0>] bus_add_driver+0x180/0x520
                                sp=e00007060772fe30 bsp=e0000706077210c0
 [<a00000010048b560>] driver_register+0x260/0x400
                                sp=e00007060772fe30 bsp=e000070607721078
 [<a0000001004df540>] scsi_register_driver+0x40/0x60
                                sp=e00007060772fe30 bsp=e000070607721058
 [<a000000207e00070>] init_sr+0x70/0x140 [sr_mod]
                                sp=e00007060772fe30 bsp=e000070607721038
 [<a00000010000a960>] do_one_initcall+0xe0/0x360
                                sp=e00007060772fe30 bsp=e000070607720ff0
 [<a000000100106040>] sys_init_module+0x1e0/0x4c0
                                sp=e00007060772fe30 bsp=e000070607720f78
 [<a00000010000c700>] ia64_ret_from_syscall+0x0/0x20
                                sp=e00007060772fe30 bsp=e000070607720f78
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=e000070607730000 bsp=e000070607720f78
Disabling lock debugging due to kernel taint
udevd-event[6154]: '/sbin/modprobe' abnormal exit

                                                                     done
Loading required kernel modules                                      done
Activating swap-devices in /etc/fstab...
Adding 2104384k swap on /dev/sda2.  Priority:-1 extents:1 across:2104done 
Setting up the hardware clock                                        done
Activating device mapper...
device-mapper: ioctl: 4.16.0-ioctl (2009-11-05) initialised: dm-devel@redhat.com
                                                                     done
Checking file systems...
fsck 1.41.1 (01-Sep-2008)
Checking all file systems.                                           done
                                                                     done
Mounting local file systems...
/proc on /proc type proc (rw)
sysfs on /sys type sysfs (rw)
udev on /dev type tmpfs (rw)
loop: module loaded
devpts on /dev/pts type devpts (rw,mode=0620,gid=5)
/dev/sdb1 on /boot/efi type vfat (rw)                                done
Activating remaining swap-devices in /etc/fstab...                   done
Loading fuse module                                                  done
Retry device configuration:                                          done
Setting current sysctl status from /etc/sysctl.conf                  done
Starting ia32el                                                      done
Enabling syn flood protection                                        done
Disabling IP forwarding                                              done
                                                                     done
Turning quota on
quotaoff: Warning: No quota format detected in the kernel.
Checking quotas. This may take some time.
quotaon: Warning: No quota format detected in the kernel.
                                                                     done
Creating /var/log/boot.msg                                           done
showconsole: Warning: the ioctl TIOCGDEV is not known by the kernel
Setting up hostname 'linux-4zax'                                     done
Setting up loopback interface     lo        
    lo        IP address: 127.0.0.1/8   
              IP address: 127.0.0.2/8   
                                                                     done
Loading kdump
Invalid kernel image: /boot/vmlinuz-2.6.33-rc3-next-20100111-dirty
                                                                     skipped
System Boot Control: The system has been                             set up
Skipped features:                                  boot.cycle boot.kdump
System Boot Control: Running /etc/init.d/boot.local                  done
INIT: Entering runlevel: 3
Boot logging started on /dev/ttyS0(/dev/console) at Tue Jan 19 15:25:36 2010
Master Resource Control: previous runlevel: N, switching to runlevel:3
acpid: starting up

Initializing random number generator                                 done
acpid: 2 rules loaded

Starting acpid                                                       done
Starting salinfo daemon                                              done
Starting D-Bus daemon                                                done
Starting syslog services                                             done
tg3 0000:00:01.0: firmware: using built-in firmware tigon/tg3_tso.bin
Loading CPUFreq modules (CPUFreq not supported)
Starting HAL daemon                                                  done
Setting up (localfs) network interfaces:
    lo        
    lo        IP address: 127.0.0.1/8   
              IP address: 127.0.0.2/8                                done
    eth0      device: Broadcom Corporation NetXtreme BCM5703 Gigabit Ethernet (rev 10)
    eth0      Starting DHCP4 client. . .  
    eth0      IP address: 10.206.5.23/16                             done
    eth1      device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth1                        unused
    eth10     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth10                       unused
    eth11     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth11                       unused
    eth12     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth12                       unused
    eth13     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth13                       unused
    eth14     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth14                       unused
    eth15     device: Broadcom Corporation NetXtreme BCM5703 Gigabit Ethernet (rev 10)
              No configuration found for eth15                       unused
    eth16     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth16                       unused
    eth17     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth17                       unused
    eth18     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth18                       unused
    eth19     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth19                       unused
    eth2      device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth2                        unused
    eth20     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth20                       unused
    eth21     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth21                       unused
    eth22     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth22                       unused
    eth23     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth23                       unused
    eth24     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth24                       unused
    eth25     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth25                       unused
    eth26     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth26                       unused
    eth27     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth27                       unused
    eth28     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth28                       unused
    eth29     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth29                       unused
    eth3      device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth3                        unused
    eth30     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth30                       unused
    eth31     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth31                       unused
    eth32     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth32                       unused
    eth33     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth33                       unused
    eth34     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth34                       unused
    eth35     device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth35                       unused
    eth4      device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth4                        unused
    eth5      device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth5                        unused
    eth6      device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth6                        unused
    eth7      device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth7                        unused
    eth8      device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth8                        unused
    eth9      device: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
              No configuration found for eth9                        unused
Setting up service (localfs) network  .  .  .  .  .  .  .  .  .  .   done
Starting rpcbind                                                     done
Not starting NFS client services - no NFS found in /etc/fstab:       unused
Mount CIFS File Systems                                              unused
Loading console font lat9w-16.psfu  -m trivial G0:loadable           done
Loading keymap assuming iso-8859-15 euro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
