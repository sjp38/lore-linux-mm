Date: Thu, 17 Jan 2008 21:40:13 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUG] at mm/slab.c:3320
Message-ID: <20080117214012.GB25975@csn.ul.ie>
References: <20080109214707.GA26941@us.ibm.com> <Pine.LNX.4.64.0801091349430.12505@schroedinger.engr.sgi.com> <20080109221315.GB26941@us.ibm.com> <Pine.LNX.4.64.0801091601080.14723@schroedinger.engr.sgi.com> <84144f020801170431l2d6d0d63i1fb7ebc5145539f4@mail.gmail.com> <Pine.LNX.4.64.0801170631000.19208@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0801171634530.27536@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0801170705210.19928@schroedinger.engr.sgi.com> <20080117152524.GB6667@skywalker> <Pine.LNX.4.64.0801170857520.20366@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801170857520.20366@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka J Enberg <penberg@cs.helsinki.fi>, Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On (17/01/08 08:58), Christoph Lameter didst pronounce:
> On Thu, 17 Jan 2008, Aneesh Kumar K.V wrote:
> 
> > I have already updated the problem still exist
> > 
> > http://marc.info/?l=linux-mm&m=119990525620006&w=2
> 
> Wasnt that an earlier version of the patch?
> 

I am joining this party late in the game so have not read the patches closely
yet to see what might be going wrong. However, I noticed a machine that
showed this problem and tried out the patch. It failed with the console
output below. Reverting the patch did allow the machine to get past the
problem point (it failed later because the default config associated with
the test machine is bad).

root (hd0,0)
 Filesystem type is ext2fs, partition type 0x83
kernel /boot/vmlinuz-autobench ro console=tty0 console=ttyS0,115200  autobench_
args: root=/dev/sda3 ABAT:1200600833 loglevel=8
   [Linux-bzImage, setup=0x2800, size=0x186088]
initrd /boot/initrd-autobench.img
   [Linux-initrd @ 0x37ed4000, 0x11bb9a bytes]

Linux version 2.6.24-rc8-autokern1 (root@elm3a82) (gcc version 3.4.6 20060404 (Red Hat 3.4.6-9)) #1 SMP PREEMPT Thu Jan 17 15:07:28 EST 2008
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009c400 (usable)
 BIOS-e820: 000000000009c400 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000dff91800 (usable)
 BIOS-e820: 00000000dff91800 - 00000000dff9c340 (ACPI data)
 BIOS-e820: 00000000dff9c340 - 00000000e0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 00000005e0000000 (usable)
Node: 0, start_pfn: 0, end_pfn: 156
  Setting physnode_map array to node 0 for pfns:
  0 
Node: 0, start_pfn: 256, end_pfn: 917393
  Setting physnode_map array to node 0 for pfns:
  256 65792 131328 196864 262400 327936 393472 459008 524544 590080 655616 721152 786688 852224 
Node: 0, start_pfn: 1048576, end_pfn: 6160384
  Setting physnode_map array to node 0 for pfns:
  1048576 1114112 1179648 1245184 1310720 1376256 1441792 1507328 1572864 1638400 1703936 1769472 1835008 1900544 1966080 2031616 2097152 2162688 2228224 2293760 2359296 2424832 2490368 2555904 2621440 2686976 2752512 2818048 2883584 2949120 3014656 3080192 3145728 3211264 3276800 3342336 3407872 3473408 3538944 3604480 3670016 3735552 3801088 3866624 3932160 3997696 4063232 4128768 4194304 4259840 4325376 4390912 4456448 4521984 4587520 4653056 4718592 4784128 4849664 4915200 4980736 5046272 5111808 5177344 5242880 5308416 5373952 5439488 5505024 5570560 5636096 5701632 5767168 5832704 5898240 5963776 6029312 6094848 
get_memcfg_from_srat: assigning address to rsdp
RSD PTR  v0 [IBM   ]
Begin SRAT table scan....
CPU 0x00 in proximity domain 0x00
CPU 0x01 in proximity domain 0x00
CPU 0x02 in proximity domain 0x00
CPU 0x03 in proximity domain 0x00
CPU 0x10 in proximity domain 0x00
CPU 0x11 in proximity domain 0x00
CPU 0x12 in proximity domain 0x00
CPU 0x13 in proximity domain 0x00
Memory range 0x0 to 0xE0000 (type 0x0) in proximity domain 0x00 enabled
Memory range 0x100000 to 0x420000 (type 0x0) in proximity domain 0x00 enabled
CPU 0x20 in proximity domain 0x01
CPU 0x21 in proximity domain 0x01
CPU 0x22 in proximity domain 0x01
CPU 0x23 in proximity domain 0x01
CPU 0x30 in proximity domain 0x01
CPU 0x31 in proximity domain 0x01
CPU 0x32 in proximity domain 0x01
CPU 0x33 in proximity domain 0x01
Memory range 0x420000 to 0x5E0000 (type 0x0) in proximity domain 0x01 enabled
acpi20_parse_srat: Entry length value is zero; can't parse any further!
pxm bitmap: 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
Number of logical nodes in system = 2
Number of memory chunks in system = 3
chunk 0 nid 0 start_pfn 00000000 end_pfn 000e0000
Entering add_active_range(0, 0, 917504) 0 entries of 256 used
chunk 1 nid 0 start_pfn 00100000 end_pfn 00420000
Entering add_active_range(0, 1048576, 4325376) 1 entries of 256 used
chunk 2 nid 1 start_pfn 00420000 end_pfn 005e0000
Entering add_active_range(1, 4325376, 6160384) 2 entries of 256 used
Node: 0, start_pfn: 0, end_pfn: 4325376
  Setting physnode_map array to node 0 for pfns:
  0 65536 131072 196608 262144 327680 393216 458752 524288 589824 655360 720896 786432 851968 917504 983040 1048576 1114112 1179648 1245184 1310720 1376256 1441792 1507328 1572864 1638400 1703936 1769472 1835008 1900544 1966080 2031616 2097152 2162688 2228224 2293760 2359296 2424832 2490368 2555904 2621440 2686976 2752512 2818048 2883584 2949120 3014656 3080192 3145728 3211264 3276800 3342336 3407872 3473408 3538944 3604480 3670016 3735552 3801088 3866624 3932160 3997696 4063232 4128768 4194304 4259840 
Node: 1, start_pfn: 4325376, end_pfn: 6160384
  Setting physnode_map array to node 1 for pfns:
  4325376 4390912 4456448 4521984 4587520 4653056 4718592 4784128 4849664 4915200 4980736 5046272 5111808 5177344 5242880 5308416 5373952 5439488 5505024 5570560 5636096 5701632 5767168 5832704 5898240 5963776 6029312 6094848 
Reserving 59392 pages of KVA for lmem_map of node 0
Shrinking node 0 from 4325376 pages to 4265984 pages
Reserving 25600 pages of KVA for lmem_map of node 1
Shrinking node 1 from 6160384 pages to 6134784 pages
Reserving total of 84992 pages for numa KVA remap
kva_start_pfn ~ 143872 find_max_low_pfn() ~ 229376
max_pfn = 6160384
23168MB HIGHMEM available.
896MB LOWMEM available.
min_low_pfn = 1896, max_low_pfn = 229376, highstart_pfn = 229376
Low memory ends at vaddr f8000000
node 0 will remap to vaddr e3200000 - 06800000
node 1 will remap to vaddr f1a00000 - 0cc00000
High memory starts at vaddr f8000000
found SMP MP-table at 0009c540
Zone PFN ranges:
  DMA             0 ->     4096
  Normal       4096 ->   229376
  HighMem    229376 ->  6160384
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0:        0 ->   917504
    0:  1048576 ->  4265984
    1:  4325376 ->  6134784
On node 0 totalpages: 4134912
  DMA zone: 56 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 4040 pages, LIFO batch:0
  Normal zone: 3080 pages used for memmap
  Normal zone: 222200 pages, LIFO batch:31
  HighMem zone: 55188 pages used for memmap
  HighMem zone: 3850348 pages, LIFO batch:31
  Movable zone: 0 pages used for memmap
On node 1 totalpages: 1809408
  DMA zone: 0 pages used for memmap
  Normal zone: 0 pages used for memmap
  HighMem zone: 24738 pages used for memmap
  HighMem zone: 1784670 pages, LIFO batch:31
  Movable zone: 0 pages used for memmap
DMI 2.3 present.
Using APIC driver default
ACPI: RSDP 000FDFC0, 0014 (r0 IBM   )
ACPI: RSDT DFF9C2C0, 0034 (r1 IBM    SERVIGIL     1000 IBM  45444F43)
ACPI: FACP DFF9C240, 0074 (r1 IBM    SERVIGIL     1000 IBM  45444F43)
ACPI Warning (tbfadt-0442): Optional field "Gpe1Block" has zero address or length: 0000000000000000/4 [20070126]
ACPI: DSDT DFF91800, 4AE5 (r1 IBM    SERVIGIL     1000 INTL  2002025)
ACPI: FACS DFF9BEC0, 0040
ACPI: APIC DFF9C0C0, 0142 (r1 IBM    SERVIGIL     1000 IBM  45444F43)
ACPI: SRAT DFF9BF00, 01A8 (r1 IBM    SERVIGIL     1000 IBM  45444F43)
ACPI: SSDT DFF96300, 5B86 (r1 IBM    VIGSSDT0     1000 INTL  2002025)
ACPI: PM-Timer IO Port: 0x508
ACPI: Local APIC address 0xfee00000
Marking TSC unstable due to: Summit based system.
Switched to APIC driver `summit'.
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
Processor #0 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x02] enabled)
Processor #2 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x10] enabled)
Processor #16 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x12] enabled)
Processor #18 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x20] enabled)
Processor #32 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x09] lapic_id[0x22] enabled)
Processor #34 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x30] enabled)
Processor #48 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x32] enabled)
Processor #50 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x80] lapic_id[0x01] enabled)
Processor #1 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x81] lapic_id[0x03] enabled)
Processor #3 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x84] lapic_id[0x11] enabled)
Processor #17 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x85] lapic_id[0x13] enabled)
Processor #19 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x88] lapic_id[0x21] enabled)
Processor #33 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x89] lapic_id[0x23] enabled)
Processor #35 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x8c] lapic_id[0x31] enabled)
Processor #49 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x8d] lapic_id[0x33] enabled)
Processor #51 15:2 APIC version 20
ACPI: LAPIC_NMI (acpi_id[0x00] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x04] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x05] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x08] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x09] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x0c] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x0d] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x80] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x81] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x84] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x85] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x88] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x89] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x8c] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x8d] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x0e] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 14, version 17, address 0xfec00000, GSI 0-43
ACPI: IOAPIC (id[0x0d] address[0xfec01000] gsi_base[44])
IOAPIC[1]: apic_id 13, version 17, address 0xfec01000, GSI 44-87
ACPI: INT_SRC_OVR (bus 0 bus_irq 8 global_irq 8 low edge)
ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 low level)
ACPI: IRQ8 used by override.
ACPI: IRQ9 used by override.
ACPI: IRQ11 used by override.
ACPI: IRQ14 used by override.
Enabling APIC mode:  Summit.  Using 2 I/O APICs
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at e2000000 (gap: e0000000:1ec00000)
Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 5861258
Policy zone: HighMem
Kernel command line: ro console=tty0 console=ttyS0,115200  autobench_args: root=/dev/sda3 ABAT:1200600833 loglevel=8
mapped APIC to ffffb000 (fee00000)
mapped IOAPIC to ffffa000 (fec00000)
mapped IOAPIC to ffff9000 (fec01000)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
CPU 0 irqstacks, hard=c0498000 soft=c0418000
PID hash table entries: 4096 (order: 12, 16384 bytes)
Detected 2494.905 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
console [ttyS0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:    8
... MAX_LOCK_DEPTH:          30
... MAX_LOCKDEP_KEYS:        2048
... CLASSHASH_SIZE:           1024
... MAX_LOCKDEP_ENTRIES:     8192
... MAX_LOCKDEP_CHAINS:      16384
... CHAINHASH_SIZE:          8192
 memory used by lock dependency info: 992 kB
 per task-struct memory footprint: 1200 bytes
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Initializing HighMem for node 0 (00038000:00411800)
Initializing HighMem for node 1 (00420000:005d9c00)
Memory: 23426968k/24641536k available (1889k kernel code, 349468k reserved, 1016k data, 232k init, 22859332k highmem)
virtual kernel memory layout:
    fixmap  : 0xff234000 - 0xfffff000   (14124 kB)
    pkmap   : 0xff000000 - 0xff200000   (2048 kB)
    vmalloc : 0xf8800000 - 0xfeffe000   ( 103 MB)
    lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
      .init : 0xc03db000 - 0xc0415000   ( 232 kB)
      .data : 0xc02d844d - 0xc03d665c   (1016 kB)
      .text : 0xc0100000 - 0xc02d844d   (1889 kB)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay using timer specific routine.. 5002.07 BogoMIPS (lpj=10004150)
Mount-cache hash table entries: 512
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 0
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU0: Intel P4/Xeon Extended MCE MSRs (12) available
CPU0: Thermal monitoring enabled
Compat vDSO mapped to ffffe000.
Checking 'hlt' instruction... OK.
lockdep: not fixing up alternatives.
ACPI: Core revision 20070126
Parsing all Control Methods:
Table [DSDT](id 0001) - 180 Objects with 22 Devices 80 Methods 4 Regions
Parsing all Control Methods:
Table [SSDT](id 0002) - 746 Objects with 58 Devices 149 Methods 65 Regions
 tbxface-0598 [00] tb_load_namespace     : ACPI Tables successfully acquired
evxfevnt-0091 [00] enable                : Transition to ACPI mode successful
CPU0: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
Leaving ESR disabled.
Mapping cpu 0 to node 0
lockdep: not fixing up alternatives.
Booting processor 1/2 eip 3000
CPU 1 irqstacks, hard=c0499000 soft=c0419000
Initializing CPU#1
Leaving ESR disabled.
Mapping cpu 1 to node 0
Calibrating delay using timer specific routine.. 4990.14 BogoMIPS (lpj=9980292)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 1
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#1.
CPU1: Intel P4/Xeon Extended MCE MSRs (12) available
CPU1: Thermal monitoring enabled
CPU1: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 2/16 eip 3000
CPU 2 irqstacks, hard=c049a000 soft=c041a000
Initializing CPU#2
Leaving ESR disabled.
Mapping cpu 2 to node 0
Calibrating delay using timer specific routine.. 4990.34 BogoMIPS (lpj=9980698)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 8
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#2.
CPU2: Intel P4/Xeon Extended MCE MSRs (12) available
CPU2: Thermal monitoring enabled
CPU2: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 3/18 eip 3000
CPU 3 irqstacks, hard=c049b000 soft=c041b000
Initializing CPU#3
Leaving ESR disabled.
Mapping cpu 3 to node 0
Calibrating delay using timer specific routine.. 4990.24 BogoMIPS (lpj=9980497)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 9
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#3.
CPU3: Intel P4/Xeon Extended MCE MSRs (12) available
CPU3: Thermal monitoring enabled
CPU3: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 4/32 eip 3000
CPU 4 irqstacks, hard=c049c000 soft=c041c000
Initializing CPU#4
Leaving ESR disabled.
Mapping cpu 4 to node 1
Calibrating delay using timer specific routine.. 4990.75 BogoMIPS (lpj=9981511)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 16
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#4.
CPU4: Intel P4/Xeon Extended MCE MSRs (12) available
CPU4: Thermal monitoring enabled
CPU4: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 5/34 eip 3000
CPU 5 irqstacks, hard=c049d000 soft=c041d000
Initializing CPU#5
Leaving ESR disabled.
Mapping cpu 5 to node 1
Calibrating delay using timer specific routine.. 4990.72 BogoMIPS (lpj=9981459)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 17
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#5.
CPU5: Intel P4/Xeon Extended MCE MSRs (12) available
CPU5: Thermal monitoring enabled
CPU5: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 6/48 eip 3000
CPU 6 irqstacks, hard=c049e000 soft=c041e000
Initializing CPU#6
Leaving ESR disabled.
Mapping cpu 6 to node 1
Calibrating delay using timer specific routine.. 4990.67 BogoMIPS (lpj=9981344)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 24
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#6.
CPU6: Intel P4/Xeon Extended MCE MSRs (12) available
CPU6: Thermal monitoring enabled
CPU6: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 7/50 eip 3000
CPU 7 irqstacks, hard=c049f000 soft=c041f000
Initializing CPU#7
Leaving ESR disabled.
Mapping cpu 7 to node 1
Calibrating delay using timer specific routine.. 4990.66 BogoMIPS (lpj=9981333)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 25
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#7.
CPU7: Intel P4/Xeon Extended MCE MSRs (12) available
CPU7: Thermal monitoring enabled
CPU7: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 8/1 eip 3000
CPU 8 irqstacks, hard=c04a0000 soft=c0420000
Initializing CPU#8
Leaving ESR disabled.
Mapping cpu 8 to node 0
Calibrating delay using timer specific routine.. 4990.13 BogoMIPS (lpj=9980278)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 0
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#8.
CPU8: Intel P4/Xeon Extended MCE MSRs (12) available
CPU8: Thermal monitoring enabled
CPU8: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 9/3 eip 3000
CPU 9 irqstacks, hard=c04a1000 soft=c0421000
Initializing CPU#9
Leaving ESR disabled.
Mapping cpu 9 to node 0
Calibrating delay using timer specific routine.. 4990.23 BogoMIPS (lpj=9980478)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 1
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#9.
CPU9: Intel P4/Xeon Extended MCE MSRs (12) available
CPU9: Thermal monitoring enabled
CPU9: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 10/17 eip 3000
CPU 10 irqstacks, hard=c04a2000 soft=c0422000
Initializing CPU#10
Leaving ESR disabled.
Mapping cpu 10 to node 0
Calibrating delay using timer specific routine.. 4990.23 BogoMIPS (lpj=9980472)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 8
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#10.
CPU10: Intel P4/Xeon Extended MCE MSRs (12) available
CPU10: Thermal monitoring enabled
CPU10: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 11/19 eip 3000
CPU 11 irqstacks, hard=c04a3000 soft=c0423000
Initializing CPU#11
Leaving ESR disabled.
Mapping cpu 11 to node 0
Calibrating delay using timer specific routine.. 4990.25 BogoMIPS (lpj=9980500)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 9
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#11.
CPU11: Intel P4/Xeon Extended MCE MSRs (12) available
CPU11: Thermal monitoring enabled
CPU11: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 12/33 eip 3000
CPU 12 irqstacks, hard=c04a4000 soft=c0424000
Initializing CPU#12
Leaving ESR disabled.
Mapping cpu 12 to node 1
Calibrating delay using timer specific routine.. 4990.80 BogoMIPS (lpj=9981614)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 16
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#12.
CPU12: Intel P4/Xeon Extended MCE MSRs (12) available
CPU12: Thermal monitoring enabled
CPU12: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 13/35 eip 3000
CPU 13 irqstacks, hard=c04a5000 soft=c0425000
Initializing CPU#13
Leaving ESR disabled.
Mapping cpu 13 to node 1
Calibrating delay using timer specific routine.. 4990.71 BogoMIPS (lpj=9981436)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 17
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#13.
CPU13: Intel P4/Xeon Extended MCE MSRs (12) available
CPU13: Thermal monitoring enabled
CPU13: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 14/49 eip 3000
CPU 14 irqstacks, hard=c04a6000 soft=c0426000
Initializing CPU#14
Leaving ESR disabled.
Mapping cpu 14 to node 1
Calibrating delay using timer specific routine.. 4990.76 BogoMIPS (lpj=9981528)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 24
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#14.
CPU14: Intel P4/Xeon Extended MCE MSRs (12) available
CPU14: Thermal monitoring enabled
CPU14: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
lockdep: not fixing up alternatives.
Booting processor 15/51 eip 3000
CPU 15 irqstacks, hard=c04a7000 soft=c0427000
Initializing CPU#15
Leaving ESR disabled.
Mapping cpu 15 to node 1
Calibrating delay using timer specific routine.. 4990.77 BogoMIPS (lpj=9981554)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: L3 cache: 1024K
CPU: Physical Processor ID: 25
CPU: After all inits, caps: bfebfbff 00000000 00000000 0000b080 00004400 00000000 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#15.
CPU15: Intel P4/Xeon Extended MCE MSRs (12) available
CPU15: Thermal monitoring enabled
CPU15: Intel(R) Xeon(TM) MP CPU 2.50GHz stepping 05
Total of 16 processors activated (79859.57 BogoMIPS).
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 apic1=0 pin1=0 apic2=-1 pin2=-1
Brought up 16 CPUs
CPU0 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00000101
  groups: 00000000,00000000,00000000,00000001 00000000,00000000,00000000,00000100
  domain 1: span 00000000,00000000,00000000,00000f0f
   groups: 00000000,00000000,00000000,00000101 00000000,00000000,00000000,00000202 00000000,00000000,00000000,00000404 00000000,00000000,00000000,00000808
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,00000f0f 00000000,00000000,00000000,0000f0f0
CPU1 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00000202
  groups: 00000000,00000000,00000000,00000002 00000000,00000000,00000000,00000200
  domain 1: span 00000000,00000000,00000000,00000f0f
   groups: 00000000,00000000,00000000,00000202 00000000,00000000,00000000,00000404 00000000,00000000,00000000,00000808 00000000,00000000,00000000,00000101
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,00000f0f 00000000,00000000,00000000,0000f0f0
CPU2 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00000404
  groups: 00000000,00000000,00000000,00000004 00000000,00000000,00000000,00000400
  domain 1: span 00000000,00000000,00000000,00000f0f
   groups: 00000000,00000000,00000000,00000404 00000000,00000000,00000000,00000808 00000000,00000000,00000000,00000101 00000000,00000000,00000000,00000202
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,00000f0f 00000000,00000000,00000000,0000f0f0
CPU3 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00000808
  groups: 00000000,00000000,00000000,00000008 00000000,00000000,00000000,00000800
  domain 1: span 00000000,00000000,00000000,00000f0f
   groups: 00000000,00000000,00000000,00000808 00000000,00000000,00000000,00000101 00000000,00000000,00000000,00000202 00000000,00000000,00000000,00000404
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,00000f0f 00000000,00000000,00000000,0000f0f0
CPU4 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00001010
  groups: 00000000,00000000,00000000,00000010 00000000,00000000,00000000,00001000
  domain 1: span 00000000,00000000,00000000,0000f0f0
   groups: 00000000,00000000,00000000,00001010 00000000,00000000,00000000,00002020 00000000,00000000,00000000,00004040 00000000,00000000,00000000,00008080
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,0000f0f0 00000000,00000000,00000000,00000f0f
CPU5 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00002020
  groups: 00000000,00000000,00000000,00000020 00000000,00000000,00000000,00002000
  domain 1: span 00000000,00000000,00000000,0000f0f0
   groups: 00000000,00000000,00000000,00002020 00000000,00000000,00000000,00004040 00000000,00000000,00000000,00008080 00000000,00000000,00000000,00001010
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,0000f0f0 00000000,00000000,00000000,00000f0f
CPU6 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00004040
  groups: 00000000,00000000,00000000,00000040 00000000,00000000,00000000,00004000
  domain 1: span 00000000,00000000,00000000,0000f0f0
   groups: 00000000,00000000,00000000,00004040 00000000,00000000,00000000,00008080 00000000,00000000,00000000,00001010 00000000,00000000,00000000,00002020
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,0000f0f0 00000000,00000000,00000000,00000f0f
CPU7 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00008080
  groups: 00000000,00000000,00000000,00000080 00000000,00000000,00000000,00008000
  domain 1: span 00000000,00000000,00000000,0000f0f0
   groups: 00000000,00000000,00000000,00008080 00000000,00000000,00000000,00001010 00000000,00000000,00000000,00002020 00000000,00000000,00000000,00004040
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,0000f0f0 00000000,00000000,00000000,00000f0f
CPU8 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00000101
  groups: 00000000,00000000,00000000,00000100 00000000,00000000,00000000,00000001
  domain 1: span 00000000,00000000,00000000,00000f0f
   groups: 00000000,00000000,00000000,00000101 00000000,00000000,00000000,00000202 00000000,00000000,00000000,00000404 00000000,00000000,00000000,00000808
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,00000f0f 00000000,00000000,00000000,0000f0f0
CPU9 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00000202
  groups: 00000000,00000000,00000000,00000200 00000000,00000000,00000000,00000002
  domain 1: span 00000000,00000000,00000000,00000f0f
   groups: 00000000,00000000,00000000,00000202 00000000,00000000,00000000,00000404 00000000,00000000,00000000,00000808 00000000,00000000,00000000,00000101
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,00000f0f 00000000,00000000,00000000,0000f0f0
CPU10 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00000404
  groups: 00000000,00000000,00000000,00000400 00000000,00000000,00000000,00000004
  domain 1: span 00000000,00000000,00000000,00000f0f
   groups: 00000000,00000000,00000000,00000404 00000000,00000000,00000000,00000808 00000000,00000000,00000000,00000101 00000000,00000000,00000000,00000202
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,00000f0f 00000000,00000000,00000000,0000f0f0
CPU11 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00000808
  groups: 00000000,00000000,00000000,00000800 00000000,00000000,00000000,00000008
  domain 1: span 00000000,00000000,00000000,00000f0f
   groups: 00000000,00000000,00000000,00000808 00000000,00000000,00000000,00000101 00000000,00000000,00000000,00000202 00000000,00000000,00000000,00000404
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,00000f0f 00000000,00000000,00000000,0000f0f0
CPU12 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00001010
  groups: 00000000,00000000,00000000,00001000 00000000,00000000,00000000,00000010
  domain 1: span 00000000,00000000,00000000,0000f0f0
   groups: 00000000,00000000,00000000,00001010 00000000,00000000,00000000,00002020 00000000,00000000,00000000,00004040 00000000,00000000,00000000,00008080
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,0000f0f0 00000000,00000000,00000000,00000f0f
CPU13 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00002020
  groups: 00000000,00000000,00000000,00002000 00000000,00000000,00000000,00000020
  domain 1: span 00000000,00000000,00000000,0000f0f0
   groups: 00000000,00000000,00000000,00002020 00000000,00000000,00000000,00004040 00000000,00000000,00000000,00008080 00000000,00000000,00000000,00001010
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,0000f0f0 00000000,00000000,00000000,00000f0f
CPU14 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00004040
  groups: 00000000,00000000,00000000,00004000 00000000,00000000,00000000,00000040
  domain 1: span 00000000,00000000,00000000,0000f0f0
   groups: 00000000,00000000,00000000,00004040 00000000,00000000,00000000,00008080 00000000,00000000,00000000,00001010 00000000,00000000,00000000,00002020
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,0000f0f0 00000000,00000000,00000000,00000f0f
CPU15 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00008080
  groups: 00000000,00000000,00000000,00008000 00000000,00000000,00000000,00000080
  domain 1: span 00000000,00000000,00000000,0000f0f0
   groups: 00000000,00000000,00000000,00008080 00000000,00000000,00000000,00001010 00000000,00000000,00000000,00002020 00000000,00000000,00000000,00004040
   domain 2: span 00000000,00000000,00000000,0000ffff
    groups: 00000000,00000000,00000000,0000f0f0 00000000,00000000,00000000,00000f0f
khelper used greatest stack depth: 2936 bytes left
net_namespace: 76 bytes
khelper used greatest stack depth: 2600 bytes left
Time: 15:20:19  Date: 01/17/08
NET: Registered protocol family 16
ACPI: bus type pci registered
Summit chipset: Starting Cyclone Counter.
PCI: PCI BIOS revision 2.10 entry at 0xfd47d, last bus=11
PCI: Using configuration type 1
Setting up standard PCI resources
evgpeblk-0956 [00] ev_create_gpe_block   : GPE 00 to 1F [_GPE] 4 regs on int 0x9
evgpeblk-1052 [00] ev_initialize_gpe_bloc: Found 0 Wake, Enabled 2 Runtime GPEs in this block
ACPI: EC: Look up EC in DSDT
Completing Region/Field/Buffer/Package initialization:............................................................................................
Initialized 64/69 Regions 0/0 Fields 9/9 Buffers 19/19 Packages (935 nodes)
Initializing Device/Processor/Thermal objects by executing _INI methods:..
Executed 2 _INI methods requiring 0 _STA executions (examined 98 objects)
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [VP00] (0000:00)
PCI: Scanning bus 0000:00
PCI: Found 0000:00:00.0 [1014/0302] 000600 00
PCI: Found 0000:00:03.0 [1002/4752] 000300 00
PCI: Found 0000:00:04.0 [1014/010f] 000680 00
PCI: Found 0000:00:05.0 [1106/0686] 000601 00
PCI: Calling quirk c01f3e22 for 0000:00:05.0
PCI: Found 0000:00:05.1 [1106/0571] 000101 00
PCI: Found 0000:00:05.2 [1106/3038] 000c03 00
PCI: Found 0000:00:05.3 [1106/3038] 000c03 00
PCI: Found 0000:00:05.4 [1106/3057] 000c05 00
PCI: Calling quirk c01f3b86 for 0000:00:05.4
PCI quirk: region 0440-044f claimed by vt82c686 SMB
PCI: Calling quirk c01f3ddb for 0000:00:05.4
PCI: Fixups for bus 0000:00
PCI: Bus scan for 0000:00 returning with max=00
ACPI: PCI Interrupt Routing Table [\_SB_.VP00._PRT]
ACPI: PCI Root Bridge [VP01] (0000:01)
PCI: Scanning bus 0000:01
PCI: Found 0000:01:00.0 [1014/0302] 000600 00
PCI: Found 0000:01:03.0 [1000/0030] 000100 00
PCI: Found 0000:01:03.1 [1000/0030] 000100 00
PCI: Found 0000:01:04.0 [14e4/1648] 000200 00
PCI: Found 0000:01:04.1 [14e4/1648] 000200 00
PCI: Fixups for bus 0000:01
PCI: Bus scan for 0000:01 returning with max=01
ACPI: PCI Interrupt Routing Table [\_SB_.VP01._PRT]
ACPI: PCI Root Bridge [VP02] (0000:02)
PCI: Scanning bus 0000:02
PCI: Found 0000:02:00.0 [1014/0302] 000600 00
PCI: Fixups for bus 0000:02
PCI: Bus scan for 0000:02 returning with max=02
ACPI: PCI Interrupt Routing Table [\_SB_.VP02._PRT]
ACPI: PCI Root Bridge [VP03] (0000:05)
PCI: Scanning bus 0000:05
PCI: Found 0000:05:00.0 [1014/0302] 000600 00
PCI: Fixups for bus 0000:05
PCI: Bus scan for 0000:05 returning with max=05
ACPI: PCI Interrupt Routing Table [\_SB_.VP03._PRT]
ACPI: PCI Root Bridge [VP04] (0000:07)
PCI: Scanning bus 0000:07
PCI: Found 0000:07:00.0 [1014/0302] 000600 00
PCI: Fixups for bus 0000:07
PCI: Bus scan for 0000:07 returning with max=07
ACPI: PCI Interrupt Routing Table [\_SB_.VP04._PRT]
ACPI: PCI Root Bridge [VP05] (0000:09)
PCI: Scanning bus 0000:09
PCI: Found 0000:09:00.0 [1014/0302] 000600 00
PCI: Fixups for bus 0000:09
PCI: Bus scan for 0000:09 returning with max=09
ACPI: PCI Interrupt Routing Table [\_SB_.VP05._PRT]
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:02: Plug and Play ACPI device, IDs PNP0303 (active)
pnp 00:03: Plug and Play ACPI device, IDs PNP0f13 (active)
pnp 00:04: Plug and Play ACPI device, IDs PNP0700 (active)
pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
pnp 00:06: Plug and Play ACPI device, IDs PNP0003 (active)
pnp 00:07: Plug and Play ACPI device, IDs PNP0200 (active)
pnp: IRQ 8 override to edge, low
pnp 00:08: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:09: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:0a: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:0c: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp 00:0d: Plug and Play ACPI device, IDs PNP0c80 PNP0c01 (active)
pnp 00:0e: Plug and Play ACPI device, IDs PNP0c80 PNP0c01 (active)
pnp 00:0f: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp 00:10: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp 00:11: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp 00:12: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp 00:13: Plug and Play ACPI device, IDs PNP0a03 (active)
pnp: PnP ACPI: found 20 devices
ACPI: ACPI bus type pnp unregistered
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
Time: cyclone clocksource has been installed.
pnp: the driver 'system' has been registered
system 00:01: ioport range 0x430-0x437 has been reserved
system 00:01: ioport range 0x438-0x439 has been reserved
system 00:01: driver attached
system 00:0b: ioport range 0x440-0x44f has been reserved
system 00:0b: ioport range 0x4c0-0x4c3 has been reserved
system 00:0b: ioport range 0x4d0-0x4d1 has been reserved
system 00:0b: ioport range 0x4e0-0x4ff has been reserved
system 00:0b: ioport range 0x500-0x57f has been reserved
system 00:0b: driver attached
system 00:0c: iomem range 0x400-0x4ff could not be reserved
system 00:0c: driver attached
system 00:0d: driver attached
system 00:0e: driver attached
  got res [e2000000:e21fffff] bus [e2000000:e21fffff] flags 7200 for BAR 6 of 0000:00:04.0
  got res [e2200000:e221ffff] bus [e2200000:e221ffff] flags 7200 for BAR 6 of 0000:00:03.0
  got res [e2300000:e23fffff] bus [e2300000:e23fffff] flags 7200 for BAR 6 of 0000:01:03.0
  got res [e2400000:e24fffff] bus [e2400000:e24fffff] flags 7200 for BAR 6 of 0000:01:03.1
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 9, 2359296 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
Unpacking initramfs... done
Freeing initrd memory: 1134k freed
audit: initializing netlink socket (disabled)
audit(1200583212.896:1): initialized
highmem bounce pool size: 64 pages
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
PCI: Calling quirk c01f3f95 for 0000:00:00.0
PCI: Calling quirk c024ee1f for 0000:00:00.0
PCI: Calling quirk c026b557 for 0000:00:00.0
PCI: Calling quirk c01f3f95 for 0000:01:00.0
PCI: Calling quirk c024ee1f for 0000:01:00.0
PCI: Calling quirk c026b557 for 0000:01:00.0
PCI: Calling quirk c01f3f95 for 0000:02:00.0
PCI: Calling quirk c024ee1f for 0000:02:00.0
PCI: Calling quirk c026b557 for 0000:02:00.0
PCI: Calling quirk c01f3f95 for 0000:05:00.0
PCI: Calling quirk c024ee1f for 0000:05:00.0
PCI: Calling quirk c026b557 for 0000:05:00.0
PCI: Calling quirk c01f3f95 for 0000:07:00.0
PCI: Calling quirk c024ee1f for 0000:07:00.0
PCI: Calling quirk c026b557 for 0000:07:00.0
PCI: Calling quirk c01f3f95 for 0000:09:00.0
PCI: Calling quirk c024ee1f for 0000:09:00.0
PCI: Calling quirk c026b557 for 0000:09:00.0
PCI: Calling quirk c01f3f95 for 0000:00:03.0
PCI: Calling quirk c024ee1f for 0000:00:03.0
PCI: Calling quirk c026b557 for 0000:00:03.0
Boot video device is 0000:00:03.0
PCI: Calling quirk c01f3f95 for 0000:00:04.0
PCI: Calling quirk c024ee1f for 0000:00:04.0
PCI: Calling quirk c026b557 for 0000:00:04.0
PCI: Calling quirk c01098c2 for 0000:00:05.0
PCI: Calling quirk c01f3ca8 for 0000:00:05.0
PCI: Enabling Via external APIC routing
PCI: Calling quirk c01f3f95 for 0000:00:05.0
PCI: Calling quirk c024ee1f for 0000:00:05.0
PCI: Calling quirk c026b557 for 0000:00:05.0
PCI: Calling quirk c01098c2 for 0000:00:05.1
PCI: Calling quirk c01f3f95 for 0000:00:05.1
PCI: Calling quirk c024ee1f for 0000:00:05.1
PCI: Calling quirk c026b557 for 0000:00:05.1
PCI: Calling quirk c01098c2 for 0000:00:05.2
PCI: Calling quirk c01f3f95 for 0000:00:05.2
PCI: Calling quirk c024ee1f for 0000:00:05.2
pci 0000:00:05.2: uhci_check_and_reset_hc: legsup = 0x2000
pci 0000:00:05.2: Performing full reset
PCI: Calling quirk c026b557 for 0000:00:05.2
PCI: Calling quirk c01098c2 for 0000:00:05.3
PCI: Calling quirk c01f3f95 for 0000:00:05.3
PCI: Calling quirk c024ee1f for 0000:00:05.3
pci 0000:00:05.3: uhci_check_and_reset_hc: legsup = 0x2000
pci 0000:00:05.3: Performing full reset
PCI: Calling quirk c026b557 for 0000:00:05.3
PCI: Calling quirk c01098c2 for 0000:00:05.4
PCI: Calling quirk c01f3f95 for 0000:00:05.4
PCI: Calling quirk c024ee1f for 0000:00:05.4
PCI: Calling quirk c026b557 for 0000:00:05.4
PCI: Calling quirk c01f3f95 for 0000:01:03.0
PCI: Calling quirk c024ee1f for 0000:01:03.0
PCI: Calling quirk c026b557 for 0000:01:03.0
PCI: Calling quirk c01f3f95 for 0000:01:03.1
PCI: Calling quirk c024ee1f for 0000:01:03.1
PCI: Calling quirk c026b557 for 0000:01:03.1
PCI: Calling quirk c01f3f95 for 0000:01:04.0
PCI: Calling quirk c024ee1f for 0000:01:04.0
PCI: Calling quirk c026b557 for 0000:01:04.0
PCI: Calling quirk c01f3f95 for 0000:01:04.1
PCI: Calling quirk c024ee1f for 0000:01:04.1
PCI: Calling quirk c026b557 for 0000:01:04.1
Slab corruption: file_lock_cache start=e1c59098, len=128
Redzone: 0xe1c5909400000000/0xc0193a2e00000000.
Last user: [<09f91102>](0x9f91102)
000: 94 90 c5 e1 9c 90 c5 e1 9c 90 c5 e1 00 00 00 00
010: 00 00 00 00 01 00 00 00 5a 5a 5a 5a ad 4e ad de
020: ff ff ff ff ff ff ff ff 94 f0 54 c0 00 00 00 00
030: a5 54 36 c0 cc 90 c5 e1 cc 90 c5 e1 00<4>udev used greatest stack depth: 2544 bytes left
 00 00 00
040: 00 00 5a 5a 00 00 00 00 00 00 00 00 00 00 00 00
050: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 00 00 00 00
Next obj: start=e1c59128, len=128
Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
Last user: [<00000000>](0x0)
000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b<6>Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
 6b 6b 6b
010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
slab error in cache_alloc_debugcheck_after(): cache `file_lock_cache': double free, or memory outside object was overwritten
Pid: 289, comm: udev Not tainted 2.6.24-rc8-autokern1 #1
 [<c0105ebb>] show_trace_log_lvl+0x19/0x2e
 [<c0105ee2>] show_trace+0x12/0x14
 [<c010601e>] dump_stack+0x6c/0x72
 [<c017f540>] __slab_error+0x29/0x2b
 [<c0181954>] cache_alloc_debugcheck_after+0xa4/0x13c
 [<c01821ab>] kmem_cache_alloc+0x252/0x298
 [<c0193a2e>] locks_alloc_lock+0x12/0x14
 [<c0195539>] fcntl_setlk+0x16/0x1d5
 [<c019193c>] do_fcntl+0x103/0x152
 [<c0191a1f>] sys_fcntl64+0x5a/0x6e
 [<c01050ea>] syscall_call+0x7/0xb
 =======================
e1c59090: redzone 1:0xe1c5909400000000, redzone 2:0xc0193a2e00000000
slab error in cache_alloc_debugcheck_after(): cache `file_lock_cache': double free, or memory outside object was overwritten
Pid: 289, comm: udev Not tainted 2.6.24-rc8-autokern1 #1
 [<c0105ebb>] show_trace_log_lvl+0x19/0x2e
 [<c0105ee2>] show_trace+0x12/0x14
 [<c010601e>] dump_stack+0x6c/0x72
 [<c017f540>] __slab_error+0x29/0x2b
 [<c0181954>] cache_alloc_debugcheck_after+0xa4/0x13c
 [<c0182140>] kmem_cache_alloc+0x1e7/0x298
 [<c0193a2e>] locks_alloc_lock+0x12/0x14
 [<c01945b7>] __posix_lock_file+0x63/0x441
 [<c01949a3>] posix_lock_file+0xe/0x10
 [<c019551e>] vfs_lock_file+0x2e/0x33
 [<c0195607>] fcntl_setlk+0xe4/0x1d5
 [<c019193c>] do_fcntl+0x103/0x152
 [<c0191a1f>] sys_fcntl64+0x5a/0x6e
 [<c01050ea>] syscall_call+0x7/0xb
 =======================
e1c59120: redzone 1:0xc0193a2e9d74e35b, redzone 2:0x9f911029d74e35b
Slab corruption: file_lock_cache start=e1c59130, len=128
Redzone: 0xe1c5912c00000000/0xc0193a2e00000000.
Last user: [<09f91102>](0x9f91102)
000: 2c 91 c5 e1 34 91 c5 e1 34 91 c5 e1 00 00 00 00
010: 00 00 00 00 01 00 00 00 5a 5a 5a 5a ad 4e ad de
020: ff ff ff ff ff ff ff ff 94 f0 54 c0 00 00 00 00
030: a5 54 36 c0 64 91 c5 e1 64 91 c5 e1 00 00 00 00
040: 00 00 5a 5a 00 00 00 00 00 00 00 00 00 00 00 00
050: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 00 00 00 00
Prev obj: start=e1c59090, len=128
Redzone: 0xd84156c5635688c0/0xa55a5a5a5a5a5a5a.
Last user: [<d84156c5>](0xd84156c5)
000: c0 88 56 63 c5 56 41 d8 00 00 00 00 9c 90 c5 e1
010: 9c 90 c5 e1 a4 90 c5 e1 a4 90 c5 e1 f8 53 45 e2
Next obj: start=e1c591c0, len=128
Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
Last user: [<00000000>](0x0)
000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
slab errr in cache_alloc_debugcheck_after(): cache `file_lock_cache': double free, or memory outside object was overwritten
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
Pid: 289, comm: udev Not tainted 2.6.24-rc8-autokern1 #1
e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
pnp: the driver 'i8042 kbd' has been registered
i8042 kbd 00:02: driver attached
pnp: the driver 'i8042 aux' has been registered
i8042 aux 00:03: driver attached
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x64,0x60 irq 1,12
PNP: PS/2 controller has invalid data port 0x64; using default 0x60
PNP: PS/2 controller has invalid command port 0x60; using default 0x64
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
BUG: unable to handle kernel NULL pointer dereference at virtual address 00000048
printing eip: c0182a1a *pdpt = 0000000000417001 *pde = 0000000000000000 
Oops: 0000 [#1] PREEMPT SMP 
Modules linked in:

Pid: 229, comm: kseriod Not tainted (2.6.24-rc8-autokern1 #1)
EIP: 0060:[<c0182a1a>] EFLAGS: 00010003 CPU: 4
EIP is at kmem_cache_free+0xc7/0x18c
EAX: 00000000 EBX: e2dda920 ECX: e396c880 EDX: e396c880
ESI: e2dd9a00 EDI: 00000000 EBP: e2426e58 ESP: e2426e38
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process kseriod (pid: 229, ti=e2426000 task=e24072a0 task.ti=e2426000)
Stack: 00000000 e1e70070 e1e70068 00000282 e1e70068 e1e70070 e1e70070 00000000 
       e2426e64 c0271f2f e1e70070 e2426e70 c0272040 e1e70070 e2426e78 c027206c 
       e2426ed0 c028d507 c0182305 e1e70070 c0760720 00000000 e2d11678 e2d11678 
Call Trace:
 [<c0105ebb>] show_trace_log_lvl+0x19/0x2e
 [<c0105f7d>] <6>mice: PS/2 mouse device common for all mice
show_stack_log_lvl+0x99/0xa1
 [<c01060d7>] show_registers+0xb3/0x1e9
 [<c010639d>] die+0x11f/0x202
 [<c02d667c>] do_page_fault+0x6d6/0x7bc
 [<c02d4aaa>] error_code+0x72/0x78
 [<c0271f2f>] kfree_skbmem+0x63/0x66
 [<c0272040>] __kfree_skb+0x12/0x15
 [<c027206c>] kfree_skb+0x29/0x2b
 [<c028d507>] netlink_broadcast+0x254/0x2b8
 [<c01e7d23>] kobject_uevent_env+0x30e/0x395
 [<c01e7db4>] kobject_uevent+0xa/0xc
 [<c0243364>] device_add+0x134/0x2d1
 [<c024f82e>] serio_add_port+0x65/0xc6
 [<c024f274>] serio_handle_event+0x38/0x79
 [<c024f38b>] serio_thread+0x1a/0x133
 [<c013ba66>] kthread+0x37/0x59
 [<c0105d7f>] kernel_thread_helper+0x7/0x10
 =======================
Code: eb fe 8b 41 34 0f b7 78 18 64 a1 04 e0 40 c0 8b 04 85 40 3c 3d c0 39 c7 0f 84 81 00 00 00 ff 86 68 02 00 00 8b 84 86 88 02 00 00 <8b> 40 48 85 c0 74 3b 8b 1c b8 85 db 74 34 8d 43 10 89 45 e4 e8 
EIP: [<c0182a1a>] kmem_cache_free+0xc7/0x18c SS:ESP 0068:e2426e38
---[ end trace a94ddbad7c53b035 ]---
input: PC Speaker as /devices/platform/pcspkr/input/input0
BUG: unable to handle kernel NULL pointer dereference at virtual address 00000048
printing eip: c017f8c4 *pdpt = 0000000000417001 *pde = 0000000000000000 
Oops: 0000 [#2] PREEMPT SMP 
Modules linked in:

Pid: 63, comm: events/12 Tainted: G      D (2.6.24-rc8-autokern1 #1)
EIP: 0060:[<c017f8c4>] EFLAGS: 00010202 CPU: 12
EIP is at reap_alien+0x19/0x61
EAX: c0411574 EBX: 00000000 ECX: 00cbb000 EDX: 00000000
ESI: e27df480 EDI: 00000000 EBP: e2dd1f0c ESP: e2dd1efc
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process events/12 (pid: 63, ti=e2dd1000 task=e2df0be0 task.ti=e2dd1000)
Stack: e27df480 00000000 e27df480 00000001 e2dd1f30 c01832ce 00000002 00000000 
       c10cc540 e2dd1f60 e2dd1f60 c10cc540 e2d98ed0 e2dd1f7c c013844d 00000000 
       00000002 c01383f8 c02d2929 c018326c e2d98ef8 00000286 e2dd1f64 c03a4b20 
Call Trace:
 [<c0105ebb>] show_trace_log_lvl+0x19/0x2e
 [<c0105f7d>] show_stack_log_lvl+0x99/0xa1
 [<c01060d7>] show_registers+0xb3/0x1e9
 [<c010639d>] die+0x11f/0x202
 [<c02d667c>] do_page_fault+0x6d6/0x7bc
 [<c02d4aaa>] error_code+0x72/0x78
 [<c01832ce>] cache_reap+0x62/0x127
 [<c013844d>] run_workqueue+0xde/0x1b0
 [<c01385ee>] worker_thread+0xcf/0xda
 [<c013ba66>] kthread+0x37/0x59
 [<c0105d7f>] kernel_thread_helper+0x7/0x10
 =======================
Code: 00 00 8b 45 ec e8 17 4d 15 00 83 c4 0c 5b 5e 5f 5d c3 55 89 e5 57 56 53 51 89 45 f0 b8 74 15 41 c0 64 8b 0d 28 01 41 c0 8b 3c 08 <8b> 42 48 85 c0 74 3b 8b 1c b8 85 db 74 34 83 3b 00 74 2f fa 8d 
EIP: [<c017f8c4>] reap_alien+0x19/0x61 SS:ESP 0068:e2dd1efc
---[ end trace a94ddbad7c53b035 ]---
 [<c0105ebb>] show_trace_log_lvl+0x19/0x2e
 [<c0105ee2>] show_trace+0x12/0x14
 [<c010601e>] dump_stack+0x6c/0x72
 [<c017f540>] __slab_error+0x29/0x2b
 [<c0181954>] cache_alloc_debugcheck_after+0xa4/0x13c
 [<c01821ab>] kmem_cache_alloc+0x252/0x298
 [<c0193a2e>] locks_alloc_lock+0x12/0x14
 [<c01945b7>] __posix_lock_file+0x63/0x441
 [<c01949a3>] posix_lock_file+0xe/0x10
 [<c019551e>] vfs_lock_file+0x2e/0x33
 [<c0195607>] fcntl_setlk+0xe4/0x1d5
 [<c019193c>] do_fcntl+0x103/0x152
 [<c0191a1f>] sys_fcntl64+0x5a/0x6e
 [<c01050ea>] syscall_call+0x7/0xb
 =======================
e1c59128: redzone 1:0xe1c5912c00000000, redzone 2:0xc0193a2e00000000
slab error in cache_alloc_debugcheck_after(): cache `file_lock_cache': double free, or memory outside object was overwritten
Pid: 289, comm: udev Tainted: G      D 2.6.24-rc8-autokern1 #1
 [<c0105ebb>] show_trace_log_lvl+0x19/0x2e
 [<c0105ee2>] show_trace+0x12/0x14
 [<c010601e>] dump_stack+0x6c/0x72
 [<c017f540>] __slab_error+0x29/0x2b
 [<c0181954>] cache_alloc_debugcheck_after+0xa4/0x13c
 [<c0182140>] kmem_cache_alloc+0x1e7/0x298
 [<c0193a2e>] locks_alloc_lock+0x12/0x14
 [<c01945bf>] __posix_lock_file+0x6b/0x441
 [<c01949a3>] posix_lock_file+0xe/0x10
 [<c019551e>] vfs_lock_file+0x2e/0x33
 [<c0195607>] fcntl_setlk+0xe4/0x1d5
 [<c019193c>] do_fcntl+0x103/0x152
 [<c0191a1f>] sys_fcntl64+0x5a/0x6e
 [<c01050ea>] syscall_call+0x7/0xb
 =======================
e1c591b8: redzone 1:0xc0193a2e9d74e35b, redzone 2:0x9f911029d74e35b
Slab corruption: file_lock_cache start=e1c591c8, len=128
Redzone: 0xe1c591c400000000/0xc0193a2e00000000.
Last user: [<09f91102>](0x9f91102)
000: c4 91 c5 e1 cc 91 c5 e1 cc 91 c5 e1 00 00 00 00
010: 00 00 00 00 01 00 00 00 5a 5a 5a 5a ad 4e ad de
020: ff ff ff ff ff ff ff ff 5a 5a 5a 5a 5a 5a 5a 5a
030: 5a 5a 5a 5a fc 91 c5 e1 fc 91 c5 e1 00 00 00 00
040: 00 00 5a 5a 00 00 00 00 00 00 00 00 00 00 00 00
050: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 00 00 00 00
Prev obj: start=e1c59128, len=128
Redzone: 0xd84156c5635688c0/0xa55a5a5a5a5a5a5a.
Last user: [<d84156c5>](0xd84156c5)
000: c0 88 56 63 c5 56 41 d8 00 00 00 00 34 91 c5 e1
010: 34 91 c5 e1 3c 91 c5 e1 3c 91 c5 e1 00 00 00 00
Next obj: start=e1c59258, len=128
Redzone: 0x9f911029d74e35b/0x9f911029d74e35b.
Last user: [<00000000>](0x0)
000: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
010: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
slab error in cache_alloc_debugcheck_after(): cache `file_lock_cache': double free, or memory outside object was overwritten
Pid: 289, comm: udev Tainted: G      D 2.6.24-rc8-autokern1 #1
 [<c0105ebb>] show_trace_log_lvl+0x19/0x2e
 [<c0105ee2>] show_trace+0x12/0x14
 [<c010601e>] dump_stack+0x6c/0x72
 [<c017f540>] __slab_error+0x29/0x2b
 [<c0181954>] cache_alloc_debugcheck_after+0xa4/0x13c
 [<c01821ab>] kmem_cache_alloc+0x252/0x298
 [<c0193a2e>] locks_alloc_lock+0x12/0x14
 [<c01945bf>] __posix_lock_file+0x6b/0x441
 [<c01949a3>] posix_lock_file+0xe/0x10
 [<c019551e>] vfs_lock_file+0x2e/0x33
 [<c0195607>] fcntl_setlk+0xe4/0x1d5
 [<c019193c>] do_fcntl+0x103/0x152
 [<c0191a1f>] sys_fcntl64+0x5a/0x6e
 [<c01050ea>] syscall_call+0x7/0xb
 =======================
e1c591c0: redzone 1:0xe1c591c400000000, redzone 2:0xc0193a2e00000000
------------[ cut here ]------------
kernel BUG at mm/slab.c:2903!
invalid opcode: 0000 [#3] PREEMPT SMP 
Modules linked in:

Pid: 289, comm: udev Tainted: G      D (2.6.24-rc8-autokern1 #1)
EIP: 0060:[<c01815b9>] EFLAGS: 00010012 CPU: 15
EIP is at cache_free_debugcheck+0x220/0x247
EAX: e1c591b8 EBX: 635688c0 ECX: e1c59088 EDX: 00000002
ESI: d84156c5 EDI: e2dd9cc0 EBP: e2457e60 ESP: e2457e28
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process udev (pid: 289, ti=e2457000 task=e1c72230 task.ti=e2457000)
Stack: e1c59248 e2457e34 c0193b2c e2457e60 c01819e0 c036d9de 635688c0 d84156c5 
       e1c59000 c0193aa8 e1c591c0 e2dda808 e2dd9cc0 00000000 e2457e88 c0182997 
       c0193a2e 00000246 e1c591c8 00000282 00000000 e1c591c8 00000000 00000000 
Call Trace:
 [<c0105ebb>] show_trace_log_lvl+0x19/0x2e
 [<c0105f7d>] show_stack_log_lvl+0x99/0xa1
 [<c01060d7>] show_registers+0xb3/0x1e9
 [<c010639d>] die+0x11f/0x202
 [<c02d4cdc>] do_trap+0x8e/0xa8
 [<c0106669>] do_invalid_op+0x88/0x92
 [<c02d4aaa>] error_code+0x72/0x78
 [<c0182997>] kmem_cache_free+0x44/0x18c
 [<c0193aa8>] locks_free_lock+0x3d/0x40
 [<c019498b>] __posix_lock_file+0x437/0x441
 [<c01949a3>] posix_lock_file+0xe/0x10
 [<c019551e>] vfs_lock_file+0x2e/0x33
 [<c0195607>] fcntl_setlk+0xe4/0x1d5
 [<c019193c>] do_fcntl+0x103/0x152
 [<c0191a1f>] sys_fcntl64+0x5a/0x6e
 [<c01050ea>] syscall_call+0x7/0xb
 =======================
Code: 8b 48 0c 8b 45 f0 29 c8 f7 a7 10 02 00 00 3b 97 18 02 00 00 89 d0 72 04 0f 0b eb fe 0f af 87 0c 02 00 00 8d 04 01 39 45 f0 74 04 <0f> 0b eb fe f6 87 15 02 00 00 08 74 0f 8b 55 f0 b9 6b 00 00 00 
EIP: [<c01815b9>] cache_free_debugcheck+0x220/0x247 SS:ESP 0068:e2457e28
---[ end trace a94ddbad7c53b035 ]---
------------[ cut here ]------------
kernel BUG at mm/slab.c:2903!
invalid opcode: 0000 [#4] PREEMPT SMP 
Modules linked in:

Pid: 289, comm: udev Tainted: G      D (2.6.24-rc8-autokern1 #1)
EIP: 0060:[<c01815b9>] EFLAGS: 00010002 CPU: 15
EIP is at cache_free_debugcheck+0x220/0x247
EAX: e1c59120 EBX: 635688c0 ECX: e1c59088 EDX: 00000001
ESI: d84156c5 EDI: e2dd9cc0 EBP: e2457b34 ESP: e2457afc
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process udev (pid: 289, ti=e2457000 task=e1c72230 task.ti=e2457000)
Stack: c010514b 00000001 e1c72230 00000000 c03b19e0 c0191ce1 635688c0 d84156c5 
       e1c59000 c0193aa8 e1c59128 e2dda808 e2dd9cc0 00000000 e2457b5c c0182997 
       e2457b48 c02d4893 e1c59130 00000296 c0191ce1 e1c59130 00000000 00000000 
Call Trace:
 [<c0105ebb>] show_trace_log_lvl+0x19/0x2e
 [<c0105f7d>] show_stack_log_lvl+0x99/0xa1
 [<c01060d7>] show_registers+0xb3/0x1e9
 [<c010639d>] die+0x11f/0x202
 [<c02d4cdc>] do_trap+0x8e/0xa8
 [<c0106669>] do_invalid_op+0x88/0x92
 [<c02d4aaa>] error_code+0x72/0x78
 [<c0182997>] kmem_cache_free+0x44/0x18c
 [<c0193aa8>] locks_free_lock+0x3d/0x40
 [<c01941c7>] locks_delete_lock+0x76/0x7b
 [<c019480f>] __posix_lock_file+0x2bb/0x441
 [<c01949a3>] posix_lock_file+0xe/0x10
 [<c019551e>] vfs_lock_file+0x2e/0x33
 [<c0195a08>] locks_remove_posix+0x7e/0x9a
 [<c0186b67>] filp_close+0x49/0x58
 [<c012b7ce>] close_files+0x52/0x67
 [<c012b829>] put_files_struct+0x18/0x3f
 [<c012b8c3>] __exit_files+0x37/0x3c
 [<c012c2a7>] do_exit+0x23f/0x31f
 [<c0106478>] die+0x1fa/0x202
 [<c02d4cdc>] do_trap+0x8e/0xa8
 [<c0106669>] do_invalid_op+0x88/0x92
 [<c02d4aaa>] error_code+0x72/0x78
 [<c0182997>] kmem_cache_free+0x44/0x18c
 [<c0193aa8>] locks_free_lock+0x3d/0x40
 [<c019498b>] __posix_lock_file+0x437/0x441
 [<c01949a3>] posix_lock_file+0xe/0x10
 [<c019551e>] vfs_lock_file+0x2e/0x33
 [<c0195607>] fcntl_setlk+0xe4/0x1d5
 [<c019193c>] do_fcntl+0x103/0x152
 [<c0191a1f>] sys_fcntl64+0x5a/0x6e
 [<c01050ea>] syscall_call+0x7/0xb
 =======================
Code: 8b 48 0c 8b 45 f0 29 c8 f7 a7 10 02 00 00 3b 97 18 02 00 00 89 d0 72 04 0f 0b eb fe 0f af 87 0c 02 00 00 8d 04 01 39 45 f0 74 04 <0f> 0b eb fe f6 87 15 02 00 00 08 74 0f 8b 55 f0 b9 6b 00 00 00 
EIP: [<c01815b9>] cache_free_debugcheck+0x220/0x247 SS:ESP 0068:e2457afc
---[ end trace a94ddbad7c53b035 ]---
Fixing recursive fault but reboot is needed!

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
