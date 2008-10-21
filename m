Message-ID: <48FD82E3.9050502@cn.fujitsu.com>
Date: Tue, 21 Oct 2008 15:21:07 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>	<48FD6901.6050301@linux.vnet.ibm.com>	<20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com>	<48FD74AB.9010307@cn.fujitsu.com>	<20081021155454.db6888e4.kamezawa.hiroyu@jp.fujitsu.com>	<48FD7EEF.3070803@cn.fujitsu.com> <20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: multipart/mixed;
 boundary="------------050709080807010109000902"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050709080807010109000902
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

> Yes. thank you. This is helpful. From this, page_cgroup->page pointer is NULL.
> And page_zid() or some kicks it..
> 
> Then, it seems problem is in page_cgroup.c::page_cgroup_init() or
> page_cgroup()->page is cleared..Hmm..
> 
> could you show /var/log/dmesg ?
> It may includes following kinds of line
> 
> = (this is x86-64)
> sizeof(struct page) = 96
> Zone PFN ranges:
>   DMA      0x00000000 -> 0x00001000
>   DMA32    0x00001000 -> 0x00100000
>   Normal   0x00100000 -> 0x00a40000
> Movable zone start PFN for each node
> early_node_map[4] active PFN ranges
>     0: 0x00000000 -> 0x0000009e
>     0: 0x00000100 -> 0x000bfee0
>     0: 0x000bff00 -> 0x000bff80
>     0: 0x00100000 -> 0x00a40000
> On node 0 totalpages: 10485502
>   DMA zone: 96 pages used for memmap
>   DMA zone: 102 pages reserved
>   DMA zone: 3800 pages, LIFO batch:0
>   DMA32 zone: 24480 pages used for memmap
>   DMA32 zone: 757696 pages, LIFO batch:31
>   Normal zone: 227328 pages used for memmap
>   Normal zone: 9472000 pages, LIFO batch:31
>   Movable zone: 0 pages used for memmap
> .....
> 

dmesg is attached.

--------------050709080807010109000902
Content-Type: text/plain;
 name="dmesg.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dmesg.txt"

BIOS EBDA/lowmem at: 0009f400/0009f400
Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.27 (root@localhost.localdomain) (gcc version 4.1.2 20070925 (Red Hat 4.1.2-33)) #296 SMP Tue Oct 21 15:07:29 CST 2008
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  NSC Geode by NSC
  Cyrix CyrixInstead
  Centaur CentaurHauls
  Transmeta GenuineTMx86
  Transmeta TransmetaCPU
  UMC UMC UMC UMC
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
 BIOS-e820: 000000000009f400 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000003bff0000 (usable)
 BIOS-e820: 000000003bff0000 - 000000003bff3000 (ACPI NVS)
 BIOS-e820: 000000003bff3000 - 000000003c000000 (ACPI data)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
DMI 2.3 present.
Phoenix BIOS detected: BIOS may corrupt low RAM, working it around.
last_pfn = 0x3bff0 max_arch_pfn = 0x100000
kernel direct mapping tables up to 373fe000 @ 10000-16000
RAMDISK: 37d11000 - 37fef3e6
Allocated new RAMDISK: 00100000 - 003de3e6
Move RAMDISK from 0000000037d11000 - 0000000037fef3e5 to 00100000 - 003de3e5
ACPI: RSDP 000F7560, 0014 (r0 AWARD )
ACPI: RSDT 3BFF3040, 002C (r1 AWARD  AWRDACPI 42302E31 AWRD        0)
ACPI: FACP 3BFF30C0, 0074 (r1 AWARD  AWRDACPI 42302E31 AWRD        0)
ACPI: DSDT 3BFF3180, 3ABC (r1 AWARD  AWRDACPI     1000 MSFT  100000E)
ACPI: FACS 3BFF0000, 0040
ACPI: APIC 3BFF6C80, 0084 (r1 AWARD  AWRDACPI 42302E31 AWRD        0)
ACPI: DMI detected: Acer
ACPI: Local APIC address 0xfee00000
75MB HIGHMEM available.
883MB LOWMEM available.
  mapped low ram: 0 - 373fe000
  low ram: 00000000 - 373fe000
  bootmap 00012000 - 00018e80
(9 early reservations) ==> bootmem [0000000000 - 00373fe000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000001000 - 0000002000]    EX TRAMPOLINE ==> [0000001000 - 0000002000]
  #2 [0000006000 - 0000007000]       TRAMPOLINE ==> [0000006000 - 0000007000]
  #3 [0000400000 - 0000bce334]    TEXT DATA BSS ==> [0000400000 - 0000bce334]
  #4 [0000bcf000 - 0000bd3000]    INIT_PG_TABLE ==> [0000bcf000 - 0000bd3000]
  #5 [000009f400 - 0000100000]    BIOS reserved ==> [000009f400 - 0000100000]
  #6 [0000010000 - 0000012000]          PGTABLE ==> [0000010000 - 0000012000]
  #7 [0000100000 - 00003de3e6]      NEW RAMDISK ==> [0000100000 - 00003de3e6]
  #8 [0000012000 - 0000019000]          BOOTMAP ==> [0000012000 - 0000019000]
found SMP MP-table at [c00f5ad0] 000f5ad0
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  Normal   0x00001000 -> 0x000373fe
  HighMem  0x000373fe -> 0x0003bff0
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000010 -> 0x0000009f
    0: 0x00000100 -> 0x0003bff0
On node 0 totalpages: 245631
free_area_init_node: node 0, pgdat c0731a00, node_mem_map c1000340
  DMA zone: 52 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 3931 pages, LIFO batch:0
  Normal zone: 2821 pages used for memmap
  Normal zone: 219385 pages, LIFO batch:31
  HighMem zone: 247 pages used for memmap
  HighMem zone: 19195 pages, LIFO batch:3
  Movable zone: 0 pages used for memmap
Using APIC driver default
ACPI: PM-Timer IO Port: 0x1008
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 4, version 17, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 dfl dfl)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
Using ACPI (MADT) for SMP configuration information
SMP: Allowing 4 CPUs, 2 hotplug CPUs
mapped APIC to ffffb000 (fee00000)
mapped IOAPIC to ffffa000 (fec00000)
PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
Allocating PCI resources starting at 40000000 (gap: 3c000000:c2c00000)
PERCPU: Allocating 32796 bytes of per cpu data
NR_CPUS: 32, nr_cpu_ids: 4, nr_node_ids 1
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 242511
Kernel command line: ro root=LABEL=/ rhgb quiet cgroup_disable=memory
Disabling memory control group subsystem
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
CPU 0 irqstacks, hard=c07c2000 soft=c07a2000
PID hash table entries: 4096 (order: 12, 16384 bytes)
Fast TSC calibration using PIT
Detected 2800.135 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:    8
... MAX_LOCK_DEPTH:          48
... MAX_LOCKDEP_KEYS:        8191
... CLASSHASH_SIZE:           4096
... MAX_LOCKDEP_ENTRIES:     8192
... MAX_LOCKDEP_CHAINS:      16384
... CHAINHASH_SIZE:          8192
 memory used by lock dependency info: 2335 kB
 per task-struct memory footprint: 1152 bytes
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 957788k/982976k available (2113k kernel code, 24500k reserved, 1262k data, 312k init, 77768k highmem)
virtual kernel memory layout:
    fixmap  : 0xffc58000 - 0xfffff000   (3740 kB)
    pkmap   : 0xff400000 - 0xff800000   (4096 kB)
    vmalloc : 0xf7bfe000 - 0xff3fe000   ( 120 MB)
    lowmem  : 0xc0000000 - 0xf73fe000   ( 883 MB)
      .init : 0xc0751000 - 0xc079f000   ( 312 kB)
      .data : 0xc0610798 - 0xc074c218   (1262 kB)
      .text : 0xc0400000 - 0xc0610798   (2113 kB)
Checking if this processor honours the WP bit even in supervisor mode...Ok.
SLUB: Genslabs=12, HWalign=128, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
Calibrating delay loop (skipped), value calculated using timer frequency.. 5600.27 BogoMIPS (lpj=2800135)
Mount-cache hash table entries: 512
Initializing cgroup subsys debug
Initializing cgroup subsys ns
Initializing cgroup subsys cpuacct
Initializing cgroup subsys memory
allocated 4914560 bytes of page_cgroup
please try cgroup_disable=memory option if you don't want
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 1024K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU0: Intel P4/Xeon Extended MCE MSRs (24) available
CPU0: Thermal monitoring enabled
using mwait in idle threads.
Checking 'hlt' instruction... OK.
ACPI: Core revision 20080609
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: Intel(R) Pentium(R) D CPU 2.80GHz stepping 04
lockdep: fixing up alternatives.
CPU 1 irqstacks, hard=c07c3000 soft=c07a3000
Booting processor 1/1 ip 6000
Initializing CPU#1
Calibrating delay using timer specific routine.. 5599.27 BogoMIPS (lpj=2799635)
CPU: Trace cache: 12K uops, L1 D cache: 16K
CPU: L2 cache: 1024K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#1.
CPU1: Intel P4/Xeon Extended MCE MSRs (24) available
CPU1: Thermal monitoring enabled
CPU1: Intel(R) Pentium(R) D CPU 2.80GHz stepping 04
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Brought up 2 CPUs
Total of 2 processors activated (11199.54 BogoMIPS).
CPU0 attaching sched-domain:
 domain 0: span 0-1 level CPU
  groups: 0 1
CPU1 attaching sched-domain:
 domain 0: span 0-1 level CPU
  groups: 1 0
net_namespace: 384 bytes
NET: Registered protocol family 16
No dock devices found.
ACPI: bus type pci registered
PCI: PCI BIOS revision 2.10 entry at 0xfbda0, last bus=1
PCI: Using configuration type 1 for base access
mtrr: your CPUs had inconsistent fixed MTRR settings
mtrr: probably your BIOS does not setup all CPUs.
mtrr: corrected configuration.
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S3 S4 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: 0000:00:00.0 reg 10 32bit mmio: [0xd0000000-0xd7ffffff]
PCI: 0000:00:02.5 reg 10 io port: [0x1f0-0x1f7]
PCI: 0000:00:02.5 reg 14 io port: [0x3f4-0x3f7]
PCI: 0000:00:02.5 reg 18 io port: [0x170-0x177]
PCI: 0000:00:02.5 reg 1c io port: [0x374-0x377]
PCI: 0000:00:02.5 reg 20 io port: [0x4000-0x400f]
pci 0000:00:02.5: PME# supported from D3cold
pci 0000:00:02.5: PME# disabled
PCI: 0000:00:02.7 reg 10 io port: [0xd000-0xd0ff]
PCI: 0000:00:02.7 reg 14 io port: [0xd400-0xd47f]
pci 0000:00:02.7: supports D1
pci 0000:00:02.7: supports D2
pci 0000:00:02.7: PME# supported from D3hot D3cold
pci 0000:00:02.7: PME# disabled
PCI: 0000:00:03.0 reg 10 32bit mmio: [0xe1104000-0xe1104fff]
PCI: 0000:00:03.1 reg 10 32bit mmio: [0xe1100000-0xe1100fff]
PCI: 0000:00:03.2 reg 10 32bit mmio: [0xe1101000-0xe1101fff]
PCI: 0000:00:03.3 reg 10 32bit mmio: [0xe1102000-0xe1102fff]
pci 0000:00:03.3: PME# supported from D0 D3hot D3cold
pci 0000:00:03.3: PME# disabled
PCI: 0000:00:05.0 reg 10 io port: [0xd800-0xd807]
PCI: 0000:00:05.0 reg 14 io port: [0xdc00-0xdc03]
PCI: 0000:00:05.0 reg 18 io port: [0xe000-0xe007]
PCI: 0000:00:05.0 reg 1c io port: [0xe400-0xe403]
PCI: 0000:00:05.0 reg 20 io port: [0xe800-0xe80f]
pci 0000:00:05.0: PME# supported from D3cold
pci 0000:00:05.0: PME# disabled
PCI: 0000:00:0e.0 reg 10 io port: [0xec00-0xecff]
PCI: 0000:00:0e.0 reg 14 32bit mmio: [0xe1103000-0xe11030ff]
PCI: 0000:00:0e.0 reg 30 32bit mmio: [0x000000-0x01ffff]
pci 0000:00:0e.0: supports D1
pci 0000:00:0e.0: supports D2
pci 0000:00:0e.0: PME# supported from D1 D2 D3hot D3cold
pci 0000:00:0e.0: PME# disabled
PCI: 0000:01:00.0 reg 10 32bit mmio: [0xd8000000-0xdfffffff]
PCI: 0000:01:00.0 reg 14 32bit mmio: [0xe1000000-0xe101ffff]
PCI: 0000:01:00.0 reg 18 io port: [0xc000-0xc07f]
pci 0000:01:00.0: supports D1
pci 0000:01:00.0: supports D2
PCI: bridge 0000:00:01.0 io port: [0xc000-0xcfff]
PCI: bridge 0000:00:01.0 32bit mmio: [0xe1000000-0xe10fffff]
PCI: bridge 0000:00:01.0 32bit mmio pref: [0xd8000000-0xdfffffff]
bus 00 -> node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 *11 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 *10 11 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 *11 14 15)
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 *6 7 9 10 11 14 15)
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 *9 10 11 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 *5 6 7 9 10 11 14 15)
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 12 devices
ACPI: ACPI bus type pnp unregistered
system 00:00: iomem range 0xc8000-0xcbfff has been reserved
system 00:00: iomem range 0xf0000-0xf7fff could not be reserved
system 00:00: iomem range 0xf8000-0xfbfff could not be reserved
system 00:00: iomem range 0xfc000-0xfffff could not be reserved
system 00:00: iomem range 0x3bff0000-0x3bffffff could not be reserved
system 00:00: iomem range 0xffff0000-0xffffffff could not be reserved
system 00:00: iomem range 0x0-0x9ffff could not be reserved
system 00:00: iomem range 0x100000-0x3bfeffff could not be reserved
system 00:00: iomem range 0xffee0000-0xffefffff could not be reserved
system 00:00: iomem range 0xfffe0000-0xfffeffff could not be reserved
system 00:00: iomem range 0xfec00000-0xfecfffff could not be reserved
system 00:00: iomem range 0xfee00000-0xfeefffff could not be reserved
system 00:02: ioport range 0x4d0-0x4d1 has been reserved
system 00:02: ioport range 0x800-0x805 has been reserved
system 00:02: ioport range 0x290-0x297 has been reserved
system 00:02: ioport range 0x880-0x88f has been reserved
pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
pci 0000:00:01.0:   IO window: 0xc000-0xcfff
pci 0000:00:01.0:   MEM window: 0xe1000000-0xe10fffff
pci 0000:00:01.0:   PREFETCH window: 0x000000d8000000-0x000000dfffffff
bus: 00 index 0 io port: [0x00-0xffff]
bus: 00 index 1 mmio: [0x000000-0xffffffff]
bus: 01 index 0 io port: [0xc000-0xcfff]
bus: 01 index 1 mmio: [0xe1000000-0xe10fffff]
bus: 01 index 2 mmio: [0xd8000000-0xdfffffff]
bus: 01 index 3 mmio: [0x0-0x0]
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 9, 2097152 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
NET: Registered protocol family 1
checking if image is initramfs... it is
Freeing initrd memory: 2936k freed
apm: BIOS version 1.2 Flags 0x07 (Driver version 1.16ac)
apm: disabled - APM is not SMP safe.
audit: initializing netlink socket (disabled)
type=2000 audit(1224601943.564:1): initialized
highmem bounce pool size: 64 pages
HugeTLB registered 4 MB page size, pre-allocated 0 pages
msgmni has been set to 1724
alg: No test for stdrng (krng)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
io scheduler noop registered
io scheduler cfq registered (default)
pci 0000:01:00.0: Boot video device
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
fan PNP0C0B:00: registered as cooling_device0
ACPI: Fan [FAN] (on)
processor ACPI0007:00: registered as cooling_device1
processor ACPI0007:01: registered as cooling_device2
thermal LNXTHERM:01: registered as thermal_zone0
ACPI: Thermal Zone [THRM] (56 C)
isapnp: Scanning for PnP cards...
Switched to high resolution mode on CPU 1
Switched to high resolution mode on CPU 0
isapnp: No Plug & Play device found
Real Time Clock Driver v1.12ac
Non-volatile memory driver v1.2
Linux agpgart interface v0.103
agpgart-sis 0000:00:00.0: SiS chipset [1039/0661]
agpgart-sis 0000:00:00.0: AGP aperture is 128M @ 0xd0000000
Serial: 8250/16550 driver4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
00:07: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:08: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
brd: module loaded
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
cpuidle: using governor ladder
cpuidle: using governor menu
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
TCP cubic registered
NET: Registered protocol family 17
Using IPI No-Shortcut mode
registered taskstats version 1
Freeing unused kernel memory: 312k freed
Write protecting the kernel text: 2116k
Write protecting the kernel read-only data: 996k
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:03.3: PCI INT D -> GSI 23 (level, low) -> IRQ 23
ehci_hcd 0000:00:03.3: EHCI Host Controller
ehci_hcd 0000:00:03.3: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:03.3: cache line size of 128 is not supported
ehci_hcd 0000:00:03.3: irq 23, io mem 0xe1102000
ehci_hcd 0000:00:03.3: USB 2.0 started, EHCI 1.00
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 8 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd 0000:00:03.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
ohci_hcd 0000:00:03.0: OHCI Host Controller
ohci_hcd 0000:00:03.0: new USB bus registered, assigned bus number 2
ohci_hcd 0000:00:03.0: irq 20, io mem 0xe1104000
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 3 ports detected
ohci_hcd 0000:00:03.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
ohci_hcd 0000:00:03.1: OHCI Host Controller
ohci_hcd 0000:00:03.1: new USB bus registered, assigned bus number 3
ohci_hcd 0000:00:03.1: irq 21, io mem 0xe1100000
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 3 ports detected
ohci_hcd 0000:00:03.2: PCI INT C -> GSI 22 (level, low) -> IRQ 22
ohci_hcd 0000:00:03.2: OHCI Host Controller
ohci_hcd 0000:00:03.2: new USB bus registered, assigned bus number 4
ohci_hcd 0000:00:03.2: irq 22, io mem 0xe1101000
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
uhci_hcd: USB Universal Host Controller Interface driver
SCSI subsystem initialized
Driver 'sd' needs updating - please use bus_type methods
libata version 3.00 loaded.
pata_sis 0000:00:02.5: version 0.5.2
pata_sis 0000:00:02.5: PCI INT A -> GSI 16 (level, low) -> IRQ 16
scsi0 : pata_sis
scsi1 : pata_sis
ata1: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0x4000 irq 14
ata2: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0x4008 irq 15
input: ImPS/2 Logitech Wheel Mouse as /class/input/input0
input: AT Translated Set 2 keyboard as /class/input/input1
sata_sis 0000:00:05.0: version 1.0
sata_sis 0000:00:05.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
sata_sis 0000:00:05.0: Detected SiS 180/181/964 chipset in SATA mode
scsi2 : sata_sis
scsi3 : sata_sis
ata3: SATA max UDMA/133 cmd 0xd800 ctl 0xdc00 bmdma 0xe800 irq 17
ata4: SATA max UDMA/133 cmd 0xe000 ctl 0xe400 bmdma 0xe808 irq 17
ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata3.00: ATA-7: ST3808110AS, 3.AAE, max UDMA/133
ata3.00: 156301488 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata3.00: configured for UDMA/133
ata4: SATA link down (SStatus 0 SControl 300)
scsi 2:0:0:0: Direct-Access     ATA      ST3808110AS      3.AA PQ: 0 ANSI: 5
sd 2:0:0:0: [sda] 156301488 512-byte hardware sectors: (80.0GB/74.5GiB)
sd 2:0:0:0: [sda] Write Protect is off
sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 2:0:0:0: [sda] 156301488 512-byte hardware sectors: (80.0GB/74.5GiB)
sd 2:0:0:0: [sda] Write Protect is off
sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 < sda5 sda6 sda7 sda8 sda9 >
sd 2:0:0:0: [sda] Attached SCSI disk
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
input: Power Button (FF) as /class/input/input2
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input3
ACPI: Power Button (CM) [PWRB]
input: Sleep Button (CM) as /class/input/input4
ACPI: Sleep Button (CM) [FUTS]
sd 2:0:0:0: Attached scsi generic sg0 type 0
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:00:0e.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
r8169 0000:00:0e.0: no PCI Express capability
eth0: RTL8110s at 0xf7fd8000, 00:16:ec:2e:b7:e0, XID 04000000 IRQ 18
parport_pc 00:09: reported by Plug and Play ACPI
parport0: PC-style at 0x378 (0x778), irq 7 [PCSPP,TRISTATE]
device-mapper: ioctl: 4.14.0-ioctl (2008-04-23) initialised: dm-devel@redhat.com
EXT3 FS on sda9, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda8, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
Adding 1052216k swap on /dev/sda7.  Priority:-1 extents:1 across:1052216k
warning: process `kudzu' used the deprecated sysctl system call with 1.23.
r8169: eth0: link up
r8169: eth0: link up
warning: `dbus-daemon' uses 32-bit capabilities (legacy support in use)
virbr0: Dropping NETIF_F_UFO since no NETIF_F_HW_CSUM feature.
CPU0 attaching NULL sched-domain.
CPU1 attaching NULL sched-domain.
CPU0 attaching sched-domain:
 domain 0: span 0-1 level CPU
  groups: 0 1
CPU1 attaching sched-domain:
 domain 0: span 0-1 level CPU
  groups: 1 0

--------------050709080807010109000902--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
