Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B85B36B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 19:29:30 -0500 (EST)
Date: Tue, 12 Jan 2010 17:29:23 -0700
From: Alex Chiang <achiang@hp.com>
Subject: SLUB ia64 linux-next crash bisected to 756dee75
Message-ID: <20100113002923.GF2985@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="/04w6evG8XlLl3ft"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org, penberg@cs.helsinki.fi
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello Christoph,

My HP rx8640 (ia64, 16 CPUs) is experiencing a bad paging request
during boot.

I've bisected it down to this commit:

756dee75872a2a764b478e18076360b8a4ec9045 is the first bad commit
commit 756dee75872a2a764b478e18076360b8a4ec9045
Author: Christoph Lameter <cl@linux-foundation.org>
Date:   Fri Dec 18 16:26:21 2009 -0600

    SLUB: Get rid of dynamic DMA kmalloc cache allocation
    
    Dynamic DMA kmalloc cache allocation is troublesome since the
    new percpu allocator does not support allocations in atomic contexts.
    Reserve some statically allocated kmalloc_cpu structures instead.
    
    Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
    Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>

Below is the crash log. Will attach my .config.

Thanks,
/ac

Initializing cgroup subsys cpuset
Linux version 2.6.33-rc1-00002-g756dee7 (root@coffee0) (gcc version 4.3.2 [gcc-4_3-branch revision 141291] (SUSE Linux) ) #12 SMP Tue Jan 12 16:35:35 MST 2010
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
Initial ramdisk at: 0xe0000787fa9c7000 (6055123 bytes)
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
Kernel command line: BOOT_IMAGE=scsi1:\efi\SuSE\vmlinuz-2.6.33-rc1-00002-g756dee7 root=/dev/disk/by-id/scsi-35001d38000048bd8-part2  debug
PID hash table entries: 4096 (order: -1, 32768 bytes)
Memory: 66832128k/66893888k available (7953k code, 127936k reserved, 10820k data, 1984k init)
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
CPU 2: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 146 cycles)
CPU 2: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 3: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 146 cycles)
CPU 3: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 4: synchronized ITC with CPU 0 (last diff 2 cycles, maxerr 336 cycles)
CPU 4: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 5: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 337 cycles)
CPU 5: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 6: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 337 cycles)
CPU 6: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 7: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 337 cycles)
CPU 7: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 8: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 648 cycles)
CPU 8: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 9: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 649 cycles)
CPU 9: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 10: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 656 cycles)
CPU 10: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 11: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 652 cycles)
CPU 11: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 12: synchronized ITC with CPU 0 (last diff -1 cycles, maxerr 655 cycles)
CPU 12: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 13: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 655 cycles)
CPU 13: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 14: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 657 cycles)
CPU 14: base freq=266.666MHz, ITC ratio=6/4, ITC freq=400.000MHz+/-75ppm
CPU 15: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 657 cycles)
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
GSI 26 (level, low) -> CPU 7 (0x0d00) vector 95
mptspi 0000:00:02.1: PCI INT B -> GSI 26 (level, low) -> IRQ 95
mptbase: ioc1: Initiating bringup
ioc1: LSI53C1030 C0: Capabilities={Initiator,Target}
scsi1 : ioc1: LSI53C1030 C0, FwRev=01032346h, Ports=1, MaxQ=255, IRQ=95
 sda: sda1 sda2 sda3
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
GSI 28 (level, low) -> CPU 1 (0x0100) vector 97
mptspi 0000:00:03.1: PCI INT B -> GSI 28 (level, low) -> IRQ 97
mptbase: ioc3: Initiating bringup
ioc3: LSI53C1030 C0: Capabilities={Initiator,Target}
scsi3 : ioc3: LSI53C1030 C0, FwRev=01032346h, Ports=1, MaxQ=255, IRQ=97
 sdb: sdb1 sdb2
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
GSI 134 (level, low) -> CPU 11 (0x0501) vector 99
mptspi 0001:00:02.1: PCI INT B -> GSI 134 (level, low) -> IRQ 99
 sdc:
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
GSI 136 (level, low) -> CPU 13 (0x0901) vector 101
mptspi 0001:00:03.1: PCI INT B -> GSI 136 (level, low) -> IRQ 101
 sdd:
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
udev: renamed network interface eth18 to eth20
udev: renamed network interface eth19 to eth21
udev: renamed network interface eth12 to eth13
udev: renamed network interface eth17 to eth19
udev: renamed network interface eth11 to eth12
udev: renamed network interface eth16 to eth18
udev: renamed network interface eth14 to eth16
udev: renamed network interface eth25 to eth27
udev: renamed network interface eth22 to eth24
udev: renamed network interface eth34 to eth0
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
GSI 80 (level, low) -> CPU 6 (0x0c00) vector 102
ehci_hcd 0000:8d:02.2: PCI INT C -> GSI 80 (level, low) -> IRQ 102
ehci_hcd 0000:8d:02.2: EHCI Host Controller
ehci_hcd 0000:8d:02.2: new USB bus registered, assigned bus number 1
ehci_hcd 0000:8d:02.2: irq 102, io mem 0xf4004135000
udev: renamed network interface eth6 to eth7
ehci_hcd 0000:8d:02.2: USB 2.0 started, EHCI 1.00
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 3 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
GSI 82 (level, low) -> CPU 7 (0x0d00) vector 103
ohci_hcd 0000:8d:02.0: PCI INT A -> GSI 82 (level, low) -> IRQ 103
ohci_hcd 0000:8d:02.0: OHCI Host Controller
ohci_hcd 0000:8d:02.0: new USB bus registered, assigned bus number 2
ohci_hcd 0000:8d:02.0: irq 103, io mem 0xf4004130000
udev: renamed network interface eth35 to eth15
udev: renamed network interface eth28 to eth30
udev: renamed network interface eth32 to eth34
udev: renamed network interface eth5 to eth6
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
GSI 83 (level, low) -> CPU 0 (0x0000) vector 104
ohci_hcd 0000:8d:02.1: PCI INT B -> GSI 83 (level, low) -> IRQ 104
ohci_hcd 0000:8d:02.1: OHCI Host Controller
ohci_hcd 0000:8d:02.1: new USB bus registered, assigned bus number 3
ohci_hcd 0000:8d:02.1: irq 104, io mem 0xf4004131000
udev: renamed network interface eth9 to eth10
udev: renamed network interface eth1_rename to eth2
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 1 port detected
udev: renamed network interface eth23_rename to eth25
udev: renamed network interface eth10_rename to eth11
udev: renamed network interface eth13_rename to eth14
udev: renamed network interface eth20_rename to eth22
udev: renamed network interface eth0_rename to eth1
udev: renamed network interface eth21_rename to eth23
udev: renamed network interface eth15_rename to eth17
udev: renamed network interface eth27_rename to eth29
udev: renamed network interface eth8_rename to eth9
udev: renamed network interface eth24_rename to eth26
udev: renamed network interface eth30_rename to eth32
udev: renamed network interface eth4_rename to eth5
udev: renamed network interface eth26_rename to eth28
udev: renamed network interface eth33_rename to eth35
udev: renamed network interface eth7_rename to eth8
udev: renamed network interface eth3_rename to eth4
udev: renamed network interface eth2_rename to eth3
udev: renamed network interface eth29_rename to eth31
udev: renamed network interface eth31_rename to eth33
usb 2-1: new full speed USB device using ohci_hcd and address 2
preping 05-blogd.sh
running 05-blogd.sh
Boot logging started on /dev/ttyS0(/dev/console) at Tue Jan 12 23:45:20 2010
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
input: HP Virtual Management Device as /class/input/input0
generic-usb 0003:03F0:1126.0001: input: USB HID v1.11 Keyboard [HP Virtual Management Device] on usb-0000:8d:02.0-1/input0
input: HP Virtual Management Device as /class/input/input1
generic-usb 0003:03F0:1126.0002: input: USB HID v1.01 Mouse [HP Virtual Management Device] on usb-0000:8d:02.0-1/input1
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
/dev/disk/by-id/scsi-35001d38000048bd8-part2: clean, 206457/4448256 files, 3090212/17789968 blocks
kjournald starting.  Commit interval 5 seconds
fsck succeeded. Mounting root device read-write.
Mounting root /dev/disk/by-id/scsi-35001d38000048bd8-part2
mount -o rw,acl,user_xattr -t ext3 /dev/disk/by-id/scsi-35001d38000048bd8-part2 /root
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
Unable to handle kernel paging request at virtual address a07ffffe5a783870
modprobe[6776]: Oops 8813272891392 [1]
Modules linked in: sr_mod(+) sg button container usbhid ohci_hcd ehci_hcd usbcore fan thermal processor thermal_sys

Pid: 6776, CPU 5, comm:             modprobe
psr : 0000101008026018 ifs : 8000000000000b1d ip  : [<a0000001001a7c60>]    Not tainted (2.6.33-rc1-00002-g756dee7)
ip is at kmem_cache_open+0x420/0xca0
unat: 0000000000000000 pfs : 0000000000000b1d rsc : 0000000000000003
rnat: a000000101255d28 bsps: a000000207dd6768 pr  : aa99aaa6aa566659
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001a7980 b6  : a0000001003571c0 b7  : a000000100088f60
f6  : 0fff5fffffffff0000000 f7  : 0ffeb8000000000000000
f8  : 1000f8000000000000000 f9  : 100088000000000000000
f10 : 10005fffffffff0000000 f11 : 1003e0000000000000080
r1  : a0000001014385f0 r2  : 0000000000010007 r3  : 0000000000080800
r8  : 0000000000000001 r9  : a0000001010275f8 r10 : 0000000000000000
r11 : a000000101256178 r12 : e00007860955fdf0 r13 : e000078609550000
r14 : 0000000000000009 r15 : a000000101027668 r16 : 0000000040004000
r17 : 0000000000000009 r18 : 0000000000000fff r19 : 0000000000000000
r20 : a000000101027658 r21 : 00000000000003ff r22 : 0000000000003fff
r23 : 0000000000003fff r24 : 00000000000017ff r25 : 0000000000002fff
r26 : a000000101027604 r27 : a000000101027600 r28 : a0000001010296e8
r29 : a000000101027610 r30 : 0000000000000080 r31 : 0000000000000080

Call Trace:
 [<a000000100016970>] show_stack+0x50/0xa0
                                sp=e00007860955f9c0 bsp=e0000786095514b8
 [<a0000001000171e0>] show_regs+0x820/0x860
                                sp=e00007860955fb90 bsp=e000078609551460
 [<a00000010003bc60>] die+0x1a0/0x300
                                sp=e00007860955fb90 bsp=e000078609551420
 [<a000000100068b40>] ia64_do_page_fault+0x8c0/0x9e0
                                sp=e00007860955fb90 bsp=e0000786095513c8
 [<a00000010000c8a0>] ia64_native_leave_kernel+0x0/0x270
                                sp=e00007860955fc20 bsp=e0000786095513c8
 [<a0000001001a7c60>] kmem_cache_open+0x420/0xca0
                                sp=e00007860955fdf0 bsp=e0000786095512e0
 [<a0000001001a8cf0>] dma_kmalloc_cache+0x2d0/0x440
                                sp=e00007860955fdf0 bsp=e000078609551290
 [<a0000001001a8f70>] get_slab+0x110/0x1a0
                                sp=e00007860955fdf0 bsp=e000078609551268
 [<a0000001001a96e0>] __kmalloc+0xa0/0x240
                                sp=e00007860955fdf0 bsp=e000078609551230
 [<a000000207dd16d0>] sr_probe+0x3b0/0xf20 [sr_mod]
                                sp=e00007860955fdf0 bsp=e0000786095511c8
 [<a000000100479240>] driver_probe_device+0x180/0x300
                                sp=e00007860955fe20 bsp=e000078609551190
 [<a0000001004794a0>] __driver_attach+0xe0/0x140
                                sp=e00007860955fe20 bsp=e000078609551160
 [<a000000100477ea0>] bus_for_each_dev+0xa0/0x140
                                sp=e00007860955fe20 bsp=e000078609551128
 [<a000000100478e60>] driver_attach+0x40/0x60
                                sp=e00007860955fe30 bsp=e000078609551108
 [<a000000100476cc0>] bus_add_driver+0x180/0x520
                                sp=e00007860955fe30 bsp=e0000786095510c0
 [<a000000100479c60>] driver_register+0x260/0x400
                                sp=e00007860955fe30 bsp=e000078609551078
 [<a0000001004cdd00>] scsi_register_driver+0x40/0x60
                                sp=e00007860955fe30 bsp=e000078609551058
 [<a000000207e00070>] init_sr+0x70/0x140 [sr_mod]
                                sp=e00007860955fe30 bsp=e000078609551038
 [<a00000010000a960>] do_one_initcall+0xe0/0x360
                                sp=e00007860955fe30 bsp=e000078609550ff0
 [<a000000100104080>] sys_init_module+0x1e0/0x4c0
                                sp=e00007860955fe30 bsp=e000078609550f78
 [<a00000010000c700>] ia64_ret_from_syscall+0x0/0x20
                                sp=e00007860955fe30 bsp=e000078609550f78
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=e000078609560000 bsp=e000078609550f78
Disabling lock debugging due to kernel taint
udevd-event[6618]: '/sbin/modprobe' abnormal exit


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=config-ia64

#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.33-rc1
# Tue Jan 12 15:47:09 2010
#
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set
# CONFIG_AUDIT is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_TREE_PREEMPT_RCU is not set
# CONFIG_TINY_RCU is not set
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_FANOUT=64
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
# CONFIG_GROUP_SCHED is not set
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_CGROUP_NS is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_DEVICE is not set
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_RESOURCE_COUNTERS is not set
CONFIG_SYSFS_DEPRECATED=y
CONFIG_SYSFS_DEPRECATED_V2=y
# CONFIG_RELAY is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
# CONFIG_IPC_NS is not set
# CONFIG_USER_NS is not set
# CONFIG_PID_NS is not set
# CONFIG_NET_NS is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EMBEDDED is not set
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_EXTRA_PASS is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y

#
# Kernel Performance Events And Counters
#
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
# CONFIG_KPROBES is not set
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_HAVE_DMA_API_DEBUG=y

#
# GCOV-based kernel profiling
#
CONFIG_SLOW_WORK=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
CONFIG_MODVERSIONS=y
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
# CONFIG_BLK_DEV_BSG is not set
# CONFIG_BLK_DEV_INTEGRITY is not set
# CONFIG_BLK_CGROUP is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_CFQ_GROUP_IOSCHED is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
# CONFIG_INLINE_SPIN_TRYLOCK is not set
# CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK is not set
# CONFIG_INLINE_SPIN_LOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK_IRQ is not set
# CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
CONFIG_INLINE_SPIN_UNLOCK=y
# CONFIG_INLINE_SPIN_UNLOCK_BH is not set
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
# CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_READ_TRYLOCK is not set
# CONFIG_INLINE_READ_LOCK is not set
# CONFIG_INLINE_READ_LOCK_BH is not set
# CONFIG_INLINE_READ_LOCK_IRQ is not set
# CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
CONFIG_INLINE_READ_UNLOCK=y
# CONFIG_INLINE_READ_UNLOCK_BH is not set
CONFIG_INLINE_READ_UNLOCK_IRQ=y
# CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_WRITE_TRYLOCK is not set
# CONFIG_INLINE_WRITE_LOCK is not set
# CONFIG_INLINE_WRITE_LOCK_BH is not set
# CONFIG_INLINE_WRITE_LOCK_IRQ is not set
# CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
CONFIG_INLINE_WRITE_UNLOCK=y
# CONFIG_INLINE_WRITE_UNLOCK_BH is not set
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
# CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
# CONFIG_MUTEX_SPIN_ON_OWNER is not set
# CONFIG_FREEZER is not set

#
# Processor type and features
#
CONFIG_IA64=y
CONFIG_64BIT=y
CONFIG_ZONE_DMA=y
CONFIG_QUICKLIST=y
CONFIG_MMU=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_GENERIC_LOCKBREAK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_HUGETLB_PAGE_SIZE_VARIABLE=y
CONFIG_GENERIC_FIND_NEXT_BIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_DMI=y
CONFIG_EFI=y
CONFIG_GENERIC_IOMAP=y
CONFIG_SCHED_OMIT_FRAME_POINTER=y
CONFIG_IA64_UNCACHED_ALLOCATOR=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_AUDIT_ARCH=y
# CONFIG_PARAVIRT_GUEST is not set
CONFIG_IA64_GENERIC=y
# CONFIG_IA64_DIG is not set
# CONFIG_IA64_DIG_VTD is not set
# CONFIG_IA64_HP_ZX1 is not set
# CONFIG_IA64_HP_ZX1_SWIOTLB is not set
# CONFIG_IA64_SGI_SN2 is not set
# CONFIG_IA64_SGI_UV is not set
# CONFIG_IA64_HP_SIM is not set
# CONFIG_IA64_XEN_GUEST is not set
# CONFIG_ITANIUM is not set
CONFIG_MCKINLEY=y
# CONFIG_IA64_PAGE_SIZE_4KB is not set
# CONFIG_IA64_PAGE_SIZE_8KB is not set
# CONFIG_IA64_PAGE_SIZE_16KB is not set
CONFIG_IA64_PAGE_SIZE_64KB=y
CONFIG_PGTABLE_3=y
# CONFIG_PGTABLE_4 is not set
CONFIG_HZ=250
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
# CONFIG_SCHED_HRTICK is not set
CONFIG_IA64_L1_CACHE_SHIFT=7
CONFIG_IA64_CYCLONE=y
CONFIG_IOSAPIC=y
CONFIG_FORCE_MAX_ZONEORDER=17
# CONFIG_VIRT_CPU_ACCOUNTING is not set
CONFIG_SMP=y
CONFIG_NR_CPUS=4096
CONFIG_HOTPLUG_CPU=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
# CONFIG_SCHED_SMT is not set
# CONFIG_PERMIT_BSP_REMOVE is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
CONFIG_DISCONTIGMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_DISCONTIGMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_NR_QUICK=1
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
CONFIG_NUMA=y
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_VIRTUAL_MEM_MAP=y
CONFIG_HOLES_IN_ZONE=y
# CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID is not set
CONFIG_HAVE_ARCH_NODEDATA_EXTENSION=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_IA32_SUPPORT=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_IA64_MCA_RECOVERY=y
CONFIG_PERFMON=y
CONFIG_IA64_PALINFO=y
# CONFIG_IA64_MC_ERR_INJECT is not set
CONFIG_SGI_SN=y
# CONFIG_IA64_ESI is not set
# CONFIG_IA64_HP_AML_NFW is not set

#
# SN Devices
#
CONFIG_SGI_IOC3=m
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y

#
# Firmware Drivers
#
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_EFI_VARS=y
CONFIG_EFI_PCDP=y
CONFIG_DMIID=y
CONFIG_BINFMT_ELF=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=m

#
# Power management and ACPI options
#
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_PM_RUNTIME is not set
CONFIG_ACPI=y
CONFIG_ACPI_PROCFS=y
CONFIG_ACPI_PROCFS_POWER=y
# CONFIG_ACPI_POWER_METER is not set
CONFIG_ACPI_SYSFS_POWER=y
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_FAN=m
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_PROCESSOR=m
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_THERMAL=m
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=m
CONFIG_ACPI_CONTAINER=m

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# Bus options (PCI, PCMCIA)
#
CONFIG_PCI=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCI_SYSCALL=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
CONFIG_PCI_LEGACY=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_STUB is not set
# CONFIG_PCI_IOV is not set
CONFIG_PCI_IOAPIC=y
CONFIG_HOTPLUG_PCI=m
# CONFIG_HOTPLUG_PCI_FAKE is not set
CONFIG_HOTPLUG_PCI_ACPI=m
# CONFIG_HOTPLUG_PCI_ACPI_IBM is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set
# CONFIG_HOTPLUG_PCI_SGI is not set
# CONFIG_PCCARD is not set
CONFIG_DMAR=y
CONFIG_DMAR_DEFAULT_ON=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_MMAP is not set
CONFIG_UNIX=y
CONFIG_XFRM=y
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_FIB_HASH=y
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_IP_MROUTE is not set
CONFIG_ARPD=y
CONFIG_SYN_COOKIES=y
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
# CONFIG_INET_TUNNEL is not set
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
# CONFIG_DEVTMPFS is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_CPQ_DA=m
CONFIG_BLK_CPQ_CISS_DA=m
# CONFIG_CISS_SCSI_TAPE is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_CRYPTOLOOP=m
# CONFIG_BLK_DEV_DRBD is not set
CONFIG_BLK_DEV_NBD=m
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
# CONFIG_BLK_DEV_XIP is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_BLK_DEV_HD is not set
CONFIG_MISC_DEVICES=y
# CONFIG_AD525X_DPOT is not set
# CONFIG_PHANTOM is not set
CONFIG_SGI_IOC4=y
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_SGI_XP=m
# CONFIG_HP_ILO is not set
# CONFIG_ISL29003 is not set
# CONFIG_DS1682 is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_CB710_CORE is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
CONFIG_IDE_GD_ATA=y
# CONFIG_IDE_GD_ATAPI is not set
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
# CONFIG_IDE_GENERIC is not set
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=y
# CONFIG_BLK_DEV_OPTI621 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
CONFIG_BLK_DEV_CMD64X=y
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
CONFIG_BLK_DEV_SGIIOC4=y
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=m
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=m
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=m
# CONFIG_CHR_DEV_SCH is not set
# CONFIG_SCSI_MULTI_LUN is not set
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=y
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
CONFIG_SCSI_HPSA=m
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
CONFIG_MEGARAID_NEWGEN=y
# CONFIG_MEGARAID_MM is not set
CONFIG_MEGARAID_LEGACY=m
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_MPT2SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_LIBFC is not set
# CONFIG_LIBFCOE is not set
# CONFIG_FCOE is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_STEX is not set
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
# CONFIG_SCSI_IPR is not set
CONFIG_SCSI_QLOGIC_1280=y
CONFIG_SCSI_QLA_FC=m
CONFIG_SCSI_QLA_ISCSI=m
CONFIG_SCSI_LPFC=m
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_BFA_FC is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
CONFIG_ATA_NONSTANDARD=y
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y
# CONFIG_SATA_AHCI is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y
# CONFIG_SATA_SVW is not set
CONFIG_ATA_PIIX=y
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SX4 is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
CONFIG_SATA_VITESSE=y
# CONFIG_SATA_INIC162X is not set
# CONFIG_PATA_ACPI is not set
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATP867X is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_TOSHIBA is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set
# CONFIG_PATA_SCH is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=m
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
# CONFIG_MULTICORE_RAID456 is not set
CONFIG_MD_RAID6_PQ=m
# CONFIG_ASYNC_RAID6_TEST is not set
CONFIG_MD_MULTIPATH=m
# CONFIG_MD_FAULTY is not set
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_MIRROR=m
# CONFIG_DM_LOG_USERSPACE is not set
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
# CONFIG_DM_MULTIPATH_QL is not set
# CONFIG_DM_MULTIPATH_ST is not set
# CONFIG_DM_DELAY is not set
# CONFIG_DM_UEVENT is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=m
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
# CONFIG_FUSION_CTL is not set
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#

#
# You can enable one or both FireWire driver stacks.
#

#
# See the help texts for more information.
#
# CONFIG_FIREWIRE is not set
# CONFIG_IEEE1394 is not set
# CONFIG_I2O is not set
CONFIG_NETDEVICES=y
CONFIG_DUMMY=m
# CONFIG_BONDING is not set
# CONFIG_MACVLAN is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_VETH is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_MARVELL_PHY is not set
# CONFIG_DAVICOM_PHY is not set
# CONFIG_QSEMI_PHY is not set
# CONFIG_LXT_PHY is not set
# CONFIG_CICADA_PHY is not set
# CONFIG_VITESSE_PHY is not set
# CONFIG_SMSC_PHY is not set
# CONFIG_BROADCOM_PHY is not set
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_FIXED_PHY is not set
# CONFIG_MDIO_BITBANG is not set
CONFIG_NET_ETHERNET=y
CONFIG_MII=m
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_ETHOC is not set
# CONFIG_DNET is not set
CONFIG_NET_TULIP=y
# CONFIG_DE2104X is not set
CONFIG_TULIP=m
# CONFIG_TULIP_MWI is not set
# CONFIG_TULIP_MMIO is not set
# CONFIG_TULIP_NAPI is not set
# CONFIG_DE4X5 is not set
# CONFIG_WINBOND_840 is not set
# CONFIG_DM9102 is not set
# CONFIG_ULI526X is not set
# CONFIG_HP100 is not set
# CONFIG_IBM_NEW_EMAC_ZMII is not set
# CONFIG_IBM_NEW_EMAC_RGMII is not set
# CONFIG_IBM_NEW_EMAC_TAH is not set
# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
# CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL is not set
# CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT is not set
# CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR is not set
CONFIG_NET_PCI=y
# CONFIG_PCNET32 is not set
# CONFIG_AMD8111_ETH is not set
# CONFIG_ADAPTEC_STARFIRE is not set
# CONFIG_B44 is not set
# CONFIG_FORCEDETH is not set
CONFIG_E100=m
# CONFIG_FEALNX is not set
# CONFIG_NATSEMI is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R6040 is not set
# CONFIG_SIS900 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC9420 is not set
# CONFIG_SUNDANCE is not set
# CONFIG_TLAN is not set
# CONFIG_KS8842 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_VIA_RHINE is not set
# CONFIG_SC92031 is not set
# CONFIG_ATL2 is not set
CONFIG_NETDEV_1000=y
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
CONFIG_E1000=y
# CONFIG_E1000E is not set
# CONFIG_IP1000 is not set
CONFIG_IGB=y
# CONFIG_IGBVF is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_TIGON3=y
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_JME is not set
CONFIG_NETDEV_10000=y
# CONFIG_CHELSIO_T1 is not set
CONFIG_CHELSIO_T3_DEPENDS=y
# CONFIG_CHELSIO_T3 is not set
# CONFIG_ENIC is not set
# CONFIG_IXGBE is not set
# CONFIG_IXGB is not set
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
# CONFIG_MYRI10GE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_NIU is not set
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_TEHUTI is not set
# CONFIG_BNX2X is not set
# CONFIG_QLGE is not set
# CONFIG_SFC is not set
# CONFIG_BE2NET is not set
# CONFIG_TR is not set
CONFIG_WLAN=y
# CONFIG_ATMEL is not set
# CONFIG_PRISM54 is not set
# CONFIG_USB_ZD1201 is not set
# CONFIG_HOSTAP is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET is not set
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
CONFIG_NETCONSOLE=y
# CONFIG_NETCONSOLE_DYNAMIC is not set
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_VMXNET3 is not set
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_GAMEPORT=m
# CONFIG_GAMEPORT_NS558 is not set
# CONFIG_GAMEPORT_L4 is not set
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_VT_HW_CONSOLE_BINDING is not set
CONFIG_DEVKMEM=y
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_COMPUTONE is not set
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
# CONFIG_DIGIEPCA is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_ISI is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_N_HDLC is not set
# CONFIG_RISCOM8 is not set
# CONFIG_SPECIALIX is not set
# CONFIG_STALDRV is not set
# CONFIG_NOZOMI is not set
CONFIG_SGI_SNSC=y
CONFIG_SGI_TIOCX=y
CONFIG_SGI_MBCS=m

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=6
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
# CONFIG_SERIAL_8250_RSA is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_SGI_L1_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SGI_IOC4=y
# CONFIG_SERIAL_SGI_IOC3 is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
CONFIG_EFI_RTC=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
CONFIG_RAW_DRIVER=m
CONFIG_MAX_RAW_DEVS=256
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_MMTIMER=y
# CONFIG_TCG_TPM is not set
CONFIG_DEVPORT=y
CONFIG_I2C=m
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_ALGOBIT=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_SIMTEC is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_STUB is not set

#
# Miscellaneous I2C Chip support
#
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I2C_DEBUG_CHIP is not set
# CONFIG_SPI is not set

#
# PPS support
#
# CONFIG_PPS is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_MAX17040 is not set
CONFIG_HWMON=y
# CONFIG_HWMON_VID is not set
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7473 is not set
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_THERMAL=m
# CONFIG_THERMAL_HWMON is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_AB3100_CORE is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=m
CONFIG_AGP_I460=m
CONFIG_AGP_HP_ZX1=m
CONFIG_AGP_SGI_TIOCA=m
CONFIG_VGA_ARB=y
CONFIG_DRM=m
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_TTM=m
CONFIG_DRM_TDFX=m
CONFIG_DRM_R128=m
CONFIG_DRM_RADEON=m
CONFIG_DRM_MGA=m
CONFIG_DRM_SIS=m
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
CONFIG_FB=m
# CONFIG_FIRMWARE_EDID is not set
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=m
CONFIG_FB_CFB_COPYAREA=m
CONFIG_FB_CFB_IMAGEBLIT=m
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
# CONFIG_FB_SYS_FILLRECT is not set
# CONFIG_FB_SYS_COPYAREA is not set
# CONFIG_FB_SYS_IMAGEBLIT is not set
# CONFIG_FB_FOREIGN_ENDIAN is not set
# CONFIG_FB_SYS_FOPS is not set
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
# CONFIG_FB_MODE_HELPERS is not set
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Display device support
#
# CONFIG_DISPLAY_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=m
# CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY is not set
# CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
# CONFIG_LOGO is not set
# CONFIG_SOUND is not set
CONFIG_HID_SUPPORT=y
CONFIG_HID=y
# CONFIG_HIDRAW is not set

#
# USB Input Devices
#
CONFIG_USB_HID=m
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=m
CONFIG_HID_APPLE=m
CONFIG_HID_BELKIN=m
CONFIG_HID_CHERRY=m
CONFIG_HID_CHICONY=m
CONFIG_HID_CYPRESS=m
CONFIG_HID_DRAGONRISE=m
# CONFIG_DRAGONRISE_FF is not set
CONFIG_HID_EZKEY=m
CONFIG_HID_KYE=m
CONFIG_HID_GYRATION=m
CONFIG_HID_TWINHAN=m
CONFIG_HID_KENSINGTON=m
CONFIG_HID_LOGITECH=m
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_HID_MICROSOFT=m
CONFIG_HID_MONTEREY=m
CONFIG_HID_NTRIG=m
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=m
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SONY=m
CONFIG_HID_SUNPLUS=m
CONFIG_HID_GREENASIA=m
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=m
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TOPSEED=m
CONFIG_HID_THRUSTMASTER=m
# CONFIG_THRUSTMASTER_FF is not set
CONFIG_HID_ZEROPLUS=m
# CONFIG_ZEROPLUS_FF is not set
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=m
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
CONFIG_USB_DEVICE_CLASS=y
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_SUSPEND is not set
# CONFIG_USB_OTG is not set
CONFIG_USB_MON=m
# CONFIG_USB_WUSB is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=m
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
CONFIG_USB_OHCI_HCD=m
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=m
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
# CONFIG_USB_HWA_HCD is not set

#
# Enable Host or Gadget support to see Inventra options
#

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_USBAT is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
# CONFIG_USB_STORAGE_SDDR55 is not set
# CONFIG_USB_STORAGE_JUMPSHOT is not set
# CONFIG_USB_STORAGE_ALAUDA is not set
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_BERRY_CHARGE is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_VST is not set
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set

#
# TI VLYNQ
#
# CONFIG_STAGING is not set

#
# HP Simulator drivers
#
# CONFIG_HP_SIMETH is not set
# CONFIG_HP_SIMSERIAL is not set
# CONFIG_HP_SIMSCSI is not set
CONFIG_MSPEC=m

#
# File systems
#
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
# CONFIG_EXT4_FS is not set
CONFIG_JBD=y
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=y
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
# CONFIG_NILFS2_FS is not set
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
# CONFIG_INOTIFY is not set
CONFIG_INOTIFY_USER=y
# CONFIG_QUOTA is not set
CONFIG_AUTOFS_FS=m
CONFIG_AUTOFS4_FS=m
# CONFIG_FUSE_FS is not set

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
# CONFIG_ZISOFS is not set
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_NTFS_FS=m
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
# CONFIG_CONFIGFS_FS is not set
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=y
# CONFIG_NFS_V4_1 is not set
CONFIG_NFSD=m
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
CONFIG_NFSD_V4=y
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m
CONFIG_SUNRPC_GSS=m
CONFIG_RPCSEC_GSS_KRB5=m
# CONFIG_RPCSEC_GSS_SPKM3 is not set
CONFIG_SMB_FS=m
CONFIG_SMB_NLS_DEFAULT=y
CONFIG_SMB_NLS_REMOTE="cp437"
CONFIG_CIFS=m
# CONFIG_CIFS_STATS is not set
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_XATTR is not set
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_EXPERIMENTAL is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
# CONFIG_BSD_DISKLABEL is not set
# CONFIG_MINIX_SUBPARTITION is not set
# CONFIG_SOLARIS_X86_PARTITION is not set
# CONFIG_UNIXWARE_DISKLABEL is not set
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=m
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=m
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_UTF8=m
# CONFIG_DLM is not set

#
# Kernel hacking
#
# CONFIG_PRINTK_TIME is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_DEBUG_FS is not set
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
CONFIG_DETECT_SOFTLOCKUP=y
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
# CONFIG_DEBUG_SPINLOCK is not set
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_SPINLOCK_SLEEP is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_CPU_STALL_DETECTOR is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_SYSCTL_SYSCALL_CHECK=y
# CONFIG_PAGE_POISONING is not set
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_IA64_GRANULE_16MB=y
# CONFIG_IA64_GRANULE_64MB is not set
# CONFIG_IA64_PRINT_HAZARDS is not set
# CONFIG_DISABLE_VHPT is not set
# CONFIG_IA64_DEBUG_CMPXCHG is not set
# CONFIG_IA64_DEBUG_IRQ is not set
CONFIG_SYSVIPC_COMPAT=y

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
# CONFIG_DEFAULT_SECURITY_SELINUX is not set
# CONFIG_DEFAULT_SECURITY_SMACK is not set
# CONFIG_DEFAULT_SECURITY_TOMOYO is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=m
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_MANAGER=m
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_GF128MUL is not set
# CONFIG_CRYPTO_NULL is not set
CONFIG_CRYPTO_WORKQUEUE=y
# CONFIG_CRYPTO_CRYPTD is not set
# CONFIG_CRYPTO_AUTHENC is not set
# CONFIG_CRYPTO_TEST is not set

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_SEQIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
# CONFIG_CRYPTO_CTR is not set
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=m
# CONFIG_CRYPTO_LRW is not set
CONFIG_CRYPTO_PCBC=m
# CONFIG_CRYPTO_XTS is not set

#
# Hash modes
#
# CONFIG_CRYPTO_HMAC is not set
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
# CONFIG_CRYPTO_CRC32C is not set
# CONFIG_CRYPTO_GHASH is not set
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
# CONFIG_CRYPTO_SHA1 is not set
# CONFIG_CRYPTO_SHA256 is not set
# CONFIG_CRYPTO_SHA512 is not set
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set

#
# Ciphers
#
# CONFIG_CRYPTO_AES is not set
# CONFIG_CRYPTO_ANUBIS is not set
# CONFIG_CRYPTO_ARC4 is not set
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST6 is not set
CONFIG_CRYPTO_DES=m
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SEED is not set
# CONFIG_CRYPTO_SERPENT is not set
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
# CONFIG_CRYPTO_ZLIB is not set
# CONFIG_CRYPTO_LZO is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_KVM is not set
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_LAST_BIT=y
# CONFIG_CRC_CCITT is not set
# CONFIG_CRC16 is not set
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
# CONFIG_CRC7 is not set
# CONFIG_LIBCRC32C is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_NLATTR=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_PER_CPU=y
CONFIG_IOMMU_API=y

--/04w6evG8XlLl3ft--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
