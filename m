Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m03Fq00G032757
	for <linux-mm@kvack.org>; Fri, 4 Jan 2008 02:52:00 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m03FsuFS020110
	for <linux-mm@kvack.org>; Fri, 4 Jan 2008 02:54:57 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m03Fp3ox024033
	for <linux-mm@kvack.org>; Fri, 4 Jan 2008 02:51:04 +1100
Date: Thu, 3 Jan 2008 21:20:46 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [BUG]  at mm/slab.c:3320
Message-ID: <20080103155046.GA7092@skywalker>
References: <20071220100541.GA6953@skywalker> <20071225140519.ef8457ff.akpm@linux-foundation.org> <20071227153235.GA6443@skywalker> <Pine.LNX.4.64.0712271130200.30555@schroedinger.engr.sgi.com> <20071228051959.GA6385@skywalker> <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, nacc@us.ibm.com, lee.schermerhorn@hp.com, bob.picco@hp.com, kamezawa.hiroyu@jp.fujitsu.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Wed, Jan 02, 2008 at 12:32:42PM -0800, Christoph Lameter wrote:
> 
> This occurred on a 32 bit NUMA platform? Guess NUMAQ? 
> 
> The dmesg that I saw was partial. Could you repost a full problem 
> description to linux-mm@kvack.org and cc the authors of memoryless node 
> support?
> 
> Nishanth Aravamudan <nacc@us.ibm.com>
> Lee Schermerhorn <lee.schermerhorn@hp.com>
> Bob Picco <bob.picco@hp.com>
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Mel Gorman <mel@skynet.ie>
> Christoph Lameter <clameter@sgi.com>
> 
Full dmesg:
----------
Booting 'autobench'

root (hd0,0)
 Filesystem type is ext2fs, partition type 0x83
kernel /boot/vmlinuz-autobench ro console=tty0 console=ttyS0,115200 autobench_a
rgs: root=/dev/sda3 ABAT:1198144312
   [Linux-bzImage, setup=0x2800, size=0x1a08e8]
initrd /boot/initrd-autobench.img
   [Linux-initrd @ 0x37ed8000, 0x117985 bytes]

Linux version 2.6.24-rc5-autokern1 (root@elm3a23) (gcc version 3.4.6 20060404 (Red Hat 3.4.6-9)) #1 SMP PREEMPT Thu Dec 20 04:16:18 EST 2007
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009c400 (usable)
 BIOS-e820: 000000000009c400 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000dff91900 (usable)
 BIOS-e820: 00000000dff91900 - 00000000dff9c340 (ACPI data)
 BIOS-e820: 00000000dff9c340 - 00000000e0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 00000002a0000000 (usable)
Node: 0, start_pfn: 0, end_pfn: 156
Node: 0, start_pfn: 256, end_pfn: 917393
Node: 0, start_pfn: 1048576, end_pfn: 2752512
get_memcfg_from_srat: assigning address to rsdp
RSD PTR  v0 [IBM   ]
Begin SRAT table scan....
CPU 0x00 in proximity domain 0x00
CPU 0x02 in proximity domain 0x00
CPU 0x10 in proximity domain 0x00
CPU 0x12 in proximity domain 0x00
Memory range 0x0 to 0xE0000 (type 0x0) in proximity domain 0x00 enabled
Memory range 0x100000 to 0x120000 (type 0x0) in proximity domain 0x00 enabled
CPU 0x20 in proximity domain 0x01
CPU 0x22 in proximity domain 0x01
CPU 0x30 in proximity domain 0x01
CPU 0x32 in proximity domain 0x01
Memory range 0x120000 to 0x2A0000 (type 0x0) in proximity domain 0x01 enabled
acpi20_parse_srat: Entry length value is zero; can't parse any further!
pxm bitmap: 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
Number of logical nodes in system = 2
Number of memory chunks in system = 3
chunk 0 nid 0 start_pfn 00000000 end_pfn 000e0000
chunk 1 nid 0 start_pfn 00100000 end_pfn 00120000
chunk 2 nid 1 start_pfn 00120000 end_pfn 002a0000
Node: 0, start_pfn: 0, end_pfn: 1179648
Node: 1, start_pfn: 1179648, end_pfn: 2752512
Reserving 16384 pages of KVA for lmem_map of node 0
Shrinking node 0 from 1179648 pages to 1163264 pages
Reserving 22016 pages of KVA for lmem_map of node 1
Shrinking node 1 from 2752512 pages to 2730496 pages
Reserving total of 38400 pages for numa KVA remap
kva_start_pfn ~ 190464 find_max_low_pfn() ~ 229376
max_pfn = 2752512
9856MB HIGHMEM available.
896MB LOWMEM available.
min_low_pfn = 1945, max_low_pfn = 229376, highstart_pfn = 229376
Low memory ends at vaddr f8000000
node 0 will remap to vaddr ee800000 - fc000000
node 1 will remap to vaddr f2800000 - 01600000
High memory starts at vaddr f8000000
found SMP MP-table at 0009c540
Zone PFN ranges:
  DMA             0 ->     4096
  Normal       4096 ->   229376
  HighMem    229376 ->  2752512
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0:        0 ->   917504
    0:  1048576 ->  1163264
    1:  1179648 ->  2730496
DMI 2.3 present.
Using APIC driver default
ACPI: RSDP 000FDFC0, 0014 (r0 IBM   )
ACPI: RSDT DFF9C2C0, 0034 (r1 IBM    SERVIGIL     1000 IBM  45444F43)
ACPI: FACP DFF9C240, 0074 (r1 IBM    SERVIGIL     1000 IBM  45444F43)
ACPI Warning (tbfadt-0442): Optional field "Gpe1Block" has zero address or length: 0000000000000000/4 [20070126]
ACPI: DSDT DFF91900, 4AE5 (r1 IBM    SERVIGIL     1000 INTL  2002025)
ACPI: FACS DFF9BFC0, 0040
ACPI: APIC DFF9C140, 00D2 (r1 IBM    SERVIGIL     1000 IBM  45444F43)
ACPI: SRAT DFF9C000, 0128 (r1 IBM    SERVIGIL     1000 IBM  45444F43)
ACPI: SSDT DFF96400, 5AE6 (r1 IBM    VIGSSDT0     1000 INTL  2002025)
ACPI: PM-Timer IO Port: 0x508
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
ACPI: LAPIC_NMI (acpi_id[0x00] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x04] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x05] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x08] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x09] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x0c] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x0d] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x0e] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 14, version 17, address 0xfec00000, GSI 0-43
ACPI: IOAPIC (id[0x0d] address[0xfec01000] gsi_base[44])
IOAPIC[1]: apic_id 13, version 17, address 0xfec01000, GSI 44-87
ACPI: INT_SRC_OVR (bus 0 bus_irq 8 global_irq 8 low edge)
ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 low level)
Enabling APIC mode:  Summit.  Using 2 I/O APICs
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at e2000000 (gap: e0000000:1ec00000)
Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 2545933
Policy zone: HighMem
Kernel command line: ro console=tty0 console=ttyS0,115200 autobench_args: root=/dev/sda3 ABAT:1198144312
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
CPU 0 irqstacks, hard=c04c9000 soft=c0449000
PID hash table entries: 4096 (order: 12, 16384 bytes)
Detected 1996.171 MHz processor.
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
Initializing HighMem for node 0 (00038000:0011c000)
Initializing HighMem for node 1 (00120000:0029aa00)
Memory: 10168328k/11010048k available (2043k kernel code, 162988k reserved, 1058k data, 232k init, 9414212k highmem)
virtual kernel memory layout:
    fixmap  : 0xff234000 - 0xfffff000   (14124 kB)
    pkmap   : 0xff000000 - 0xff200000   (2048 kB)
    vmalloc : 0xf8800000 - 0xfeffe000   ( 103 MB)
    lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
      .init : 0xc040c000 - 0xc0446000   ( 232 kB)
      .data : 0xc02fedc1 - 0xc040765c   (1058 kB)
      .text : 0xc0100000 - 0xc02fedc1   (2043 kB)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay using timer specific routine.. 4002.61 BogoMIPS (lpj=8005239)
------------[ cut here ]------------
kernel BUG at mm/slab.c:3320!
invalid opcode: 0000 [#1] PREEMPT SMP 
Modules linked in:

Pid: 0, comm: swapper Not tainted (2.6.24-rc5-autokern1 #1)
EIP: 0060:[<c0181707>] EFLAGS: 00010046 CPU: 0
EIP is at ____cache_alloc_node+0x1c/0x130
EAX: ee4005c0 EBX: 00000000 ECX: 00000001 EDX: 000000d0
ESI: 00000000 EDI: ee4005c0 EBP: c0408f74 ESP: c0408f54
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c0408000 task=c03d5d80 task.ti=c0408000)
Stack: c03d5d80 c0408f6c c017ac36 00000001 000000d0 00000000 000000d0 ee4005c0 
       c0408f88 c0181577 0001080c 00000246 ee4005c0 c0408fa8 c0181a97 c0408fb0 
       c01395b9 000000d0 0001080c 00099800 c03dccec c0408fd0 c01395b9 c0408fd0 
Call Trace:
 [<c0105e23>] show_trace_log_lvl+0x19/0x2e
 [<c0105ee5>] show_stack_log_lvl+0x99/0xa1
 [<c010603f>] show_registers+0xb3/0x1e9
 [<c0106301>] die+0x11b/0x1fe
 [<c02fb654>] do_trap+0x8e/0xa8
 [<c01065cd>] do_invalid_op+0x88/0x92
 [<c02fb422>] error_code+0x72/0x78
 [<c0181577>] alternate_node_alloc+0x5b/0x60
 [<c0181a97>] kmem_cache_alloc+0x50/0x120
 [<c01395b9>] create_pid_cachep+0x4c/0xec
 [<c041ae65>] pidmap_init+0x2f/0x6e
 [<c040c715>] start_kernel+0x1ca/0x23e
 [<00000000>] 0x0
 =======================
Code: ff eb 02 31 ff 89 f8 83 c4 10 5b 5e 5f 5d c3 55 89 e5 57 89 c7 56 53 83 ec 14 89 55 f0 89 4d ec 8b b4 88 88 02 00 00 85 f6 75 04 <0f> 0b eb fe e8 f3 ee ff ff 8d 46 24 89 45 e4 e8 23 97 17 00 8b 
EIP: [<c0181707>] ____cache_alloc_node+0x1c/0x130 SS:ESP 0068:c0408f54
Kernel panic - not syncing: Attempted to kill the idle task!
-- 0:conmux-control -- time-stamp -- Dec/20/07  2:00:36 --
(bot:conmon-payload) disconnected


dmidecode output for machine details
----------------------------------

# dmidecode 2.2
SMBIOS 2.3 present.
112 structures occupying 6118 bytes.
Table at 0xDFF9C340.
Handle 0x0000
	DMI type 0, 19 bytes.
	BIOS Information
		Vendor: IBM
		Version: -[REE149AUS-1.13]-
		Release Date: 06/08/2005
		Address: 0xF12B0
		Runtime Size: 60752 bytes
		ROM Size: 8192 kB
		Characteristics:
			PCI is supported
			BIOS is upgradeable
			BIOS shadowing is allowed
			Boot from CD is supported
			Selectable boot is supported
			Japanese floppy for NEC 9800 1.2 MB is supported (int 13h)
			Japanese floppy for Toshiba 1.2 MB is supported (int 13h)
			5.25"/360 KB floppy services are supported (int 13h)
			5.25"/1.2 MB floppy services are supported (int 13h)
			3.5"/720 KB floppy services are supported (int 13h)
			3.5"/2.88 MB floppy services are supported (int 13h)
			Print screen service is supported (int 5h)
			8042 keyboard services are supported (int 9h)
			Serial services are supported (int 14h)
			Printer services are supported (int 17h)
			CGA/mono video services are supported (int 10h)
			ACPI is supported
			USB legacy is supported
			I2O boot is supported
			LS-120 boot is supported
Handle 0x0001
	DMI type 1, 25 bytes.
	System Information
		Manufacturer: IBM
		Product Name: eserver xSeries 445 -[887011X]-
		Version: Not Specified
		Serial Number: KPLWN39
		UUID: 3AC361EB-101E-B211-80DA-50D400000000
		Wake-up Type: Power Switch
Handle 0x0002
	DMI type 2, 55 bytes.
	Base Board Information
		Manufacturer: IBM
		Product Name: Node 1 SMP Module 1
		Version: Not Specified
		Serial Number: Not Specified
		Asset Tag: Not Specified
		Features:
		Board is a hosting board
		Board is removable
		Board is replaceable
		Location In Chassis: Node 1, Lower right
		Chassis Handle: 0x0012
		Type: Processor+Memory Module
Handle 0x0003
	DMI type 2, 55 bytes.
	Base Board Information
		Manufacturer: IBM
		Product Name: Node 1 SMP Module 2
		Version: Not Specified
		Serial Number: Not Specified
		Asset Tag: Not Specified
		Features:
		Board is a hosting board
		Board is removable
		Board is replaceable
		Location In Chassis: Node 1, Upper right
		Chassis Handle: 0x0012
		Type: Processor+Memory Module
Handle 0x0004
	DMI type 2, 35 bytes.
	Base Board Information
		Manufacturer: IBM
		Product Name: Node 1 Centerplane
		Version: Not Specified
		Serial Number: Not Specified
		Asset Tag: Not Specified
		Features:
		Board is removable
		Board is replaceable
		Location In Chassis: Node 1, Center vertical
		Chassis Handle: 0x0012
		Type: Interconnect Board
		Contained Object Handlers: 3
			0x005D
			0x005E
			0x005F
Handle 0x0005
	DMI type 2, 35 bytes.
	Base Board Information
		Manufacturer: IBM
		Product Name: Node 1 Native I/O Planar
		Version: Not Specified
		Serial Number: Not Specified
		Asset Tag: Not Specified
		Features:
		Board is removable
		Board is replaceable
		Location In Chassis: Node 1, Lower left
		Chassis Handle: 0x0012
		Type: I/O Module
Handle 0x0006
	DMI type 2, 35 bytes.
	Base Board Information
		Manufacturer: IBM
		Product Name: Node 1 PCI I/O Planar
		Version: Not Specified
		Serial Number: Not Specified
		Asset Tag: Not Specified
		Features:
		Board is removable
		Board is replaceable
		Location In Chassis: Node 1, Upper left
		Chassis Handle: 0x0012
		Type: I/O Module
		Contained Object Handlers: 6
			0x0082
			0x0083
			0x0084
			0x0085
			0x0086
			0x0087
Handle 0x0007
	DMI type 2, 35 bytes.
	Base Board Information
		Manufacturer: IBM
		Product Name: Node 1 Remote Supervisor Adapter
		Version: Not Specified
		Serial Number: Not Specified
		Asset Tag: Not Specified
		Features:
		Board is removable
		Board is replaceable
		Location In Chassis: Node 1, Between Native I/O and PCI I/O planars
		Chassis Handle: 0x0012
		Type: System Management Module
		Contained Object Handlers: 3
			0x006B
			0x006C
			0x006D
Handle 0x0012
	DMI type 3, 13 bytes.
	Chassis Information
		Manufacturer: IBM
		Type: Main Server Chassis
		Lock: Not Present
		Version: Not Specified
		Serial Number: Not Specified
		Asset Tag:                                 
		Boot-up State: Safe
		Power Supply State: Unknown
		Thermal State: Unknown
		Security Status: Unknown
Handle 0x0016
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L1 Cache
		Configuration: Enabled, Socketed, Level 1
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 8 KB
		Maximum Size: 16 KB
		Supported SRAM Types:
			Synchronous
		Installed SRAM Type: Synchronous
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 4-way Set-associative
Handle 0x0017
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L2 Cache
		Configuration: Enabled, Socketed, Level 2
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 512 KB
		Maximum Size: 512 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x0018
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L3 Cache
		Configuration: Enabled, Socketed, Level 3
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 1024 KB
		Maximum Size: 32768 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x0019
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L1 Cache
		Configuration: Enabled, Socketed, Level 1
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 8 KB
		Maximum Size: 16 KB
		Supported SRAM Types:
			Synchronous
		Installed SRAM Type: Synchronous
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 4-way Set-associative
Handle 0x001A
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L2 Cache
		Configuration: Enabled, Socketed, Level 2
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 512 KB
		Maximum Size: 512 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x001B
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L3 Cache
		Configuration: Enabled, Socketed, Level 3
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 1024 KB
		Maximum Size: 32768 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x001C
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L1 Cache
		Configuration: Enabled, Socketed, Level 1
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 8 KB
		Maximum Size: 16 KB
		Supported SRAM Types:
			Synchronous
		Installed SRAM Type: Synchronous
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 4-way Set-associative
Handle 0x001D
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L2 Cache
		Configuration: Enabled, Socketed, Level 2
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 512 KB
		Maximum Size: 512 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x001E
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L3 Cache
		Configuration: Enabled, Socketed, Level 3
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 2048 KB
		Maximum Size: 32768 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x001F
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L1 Cache
		Configuration: Enabled, Socketed, Level 1
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 8 KB
		Maximum Size: 16 KB
		Supported SRAM Types:
			Synchronous
		Installed SRAM Type: Synchronous
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 4-way Set-associative
Handle 0x0020
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L2 Cache
		Configuration: Enabled, Socketed, Level 2
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 512 KB
		Maximum Size: 512 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x0021
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L3 Cache
		Configuration: Enabled, Socketed, Level 3
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 2048 KB
		Maximum Size: 32768 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x0022
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L1 Cache
		Configuration: Enabled, Socketed, Level 1
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 8 KB
		Maximum Size: 16 KB
		Supported SRAM Types:
			Synchronous
		Installed SRAM Type: Synchronous
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 4-way Set-associative
Handle 0x0023
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L2 Cache
		Configuration: Enabled, Socketed, Level 2
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 512 KB
		Maximum Size: 512 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x0024
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L3 Cache
		Configuration: Enabled, Socketed, Level 3
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 2048 KB
		Maximum Size: 32768 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x0025
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L1 Cache
		Configuration: Enabled, Socketed, Level 1
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 8 KB
		Maximum Size: 16 KB
		Supported SRAM Types:
			Synchronous
		Installed SRAM Type: Synchronous
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 4-way Set-associative
Handle 0x0026
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L2 Cache
		Configuration: Enabled, Socketed, Level 2
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 512 KB
		Maximum Size: 512 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x0027
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L3 Cache
		Configuration: Enabled, Socketed, Level 3
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 2048 KB
		Maximum Size: 32768 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x0028
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L1 Cache
		Configuration: Enabled, Socketed, Level 1
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 8 KB
		Maximum Size: 16 KB
		Supported SRAM Types:
			Synchronous
		Installed SRAM Type: Synchronous
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 4-way Set-associative
Handle 0x0029
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L2 Cache
		Configuration: Enabled, Socketed, Level 2
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 512 KB
		Maximum Size: 512 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x002A
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L3 Cache
		Configuration: Enabled, Socketed, Level 3
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 2048 KB
		Maximum Size: 32768 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x002B
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L1 Cache
		Configuration: Enabled, Socketed, Level 1
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 8 KB
		Maximum Size: 16 KB
		Supported SRAM Types:
			Synchronous
		Installed SRAM Type: Synchronous
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 4-way Set-associative
Handle 0x002C
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L2 Cache
		Configuration: Enabled, Socketed, Level 2
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 512 KB
		Maximum Size: 512 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x002D
	DMI type 7, 19 bytes.
	Cache Information
		Socket Designation: Internal L3 Cache
		Configuration: Enabled, Socketed, Level 3
		Operational Mode: Write Back
		Location: Internal
		Installed Size: 2048 KB
		Maximum Size: 32768 KB
		Supported SRAM Types:
			Burst
		Installed SRAM Type: Burst
		Speed: Unknown
		Error Correction Type: Single-bit ECC
		System Type: Unified
		Associativity: 8-way Set-associative
Handle 0x0046
	DMI type 4, 32 bytes.
	Processor Information
		Socket Designation: Node 1 CPU 1
		Type: Central Processor
		Family: Xeon
		Manufacturer: GenuineIntel
		ID: 25 0F 00 00 00 00 00 00
		Signature: Type 0, Family F, Model 2, Stepping 5
		Flags: None
		Version: Intel Xeon MP       
		Voltage: 1.5 V
		External Clock: 100 MHz
		Max Speed: 3000 MHz
		Current Speed: 2000 MHz
		Status: Populated, Enabled
		Upgrade: ZIF Socket
		L1 Cache Handle: 0x0016
		L2 Cache Handle: 0x0017
		L3 Cache Handle: 0x0018
Handle 0x0047
	DMI type 4, 32 bytes.
	Processor Information
		Socket Designation: Node 1 CPU 2
		Type: Central Processor
		Family: Xeon
		Manufacturer: GenuineIntel
		ID: 25 0F 00 00 00 00 00 00
		Signature: Type 0, Family F, Model 2, Stepping 5
		Flags: None
		Version: Intel Xeon MP       
		Voltage: 1.5 V
		External Clock: 100 MHz
		Max Speed: 3000 MHz
		Current Speed: 2000 MHz
		Status: Populated, Enabled
		Upgrade: ZIF Socket
		L1 Cache Handle: 0x0019
		L2 Cache Handle: 0x001A
		L3 Cache Handle: 0x001B
Handle 0x0048
	DMI type 4, 32 bytes.
	Processor Information
		Socket Designation: Node 1 CPU 3
		Type: Central Processor
		Family: Xeon
		Manufacturer: GenuineIntel
		ID: 22 0F 00 00 00 00 00 00
		Signature: Type 0, Family F, Model 2, Stepping 2
		Flags: None
		Version: Intel Xeon MP       
		Voltage: 1.5 V
		External Clock: 100 MHz
		Max Speed: 3000 MHz
		Current Speed: 2000 MHz
		Status: Populated, Enabled
		Upgrade: ZIF Socket
		L1 Cache Handle: 0x001C
		L2 Cache Handle: 0x001D
		L3 Cache Handle: 0x001E
Handle 0x0049
	DMI type 4, 32 bytes.
	Processor Information
		Socket Designation: Node 1 CPU 4
		Type: Central Processor
		Family: Xeon
		Manufacturer: GenuineIntel
		ID: 22 0F 00 00 00 00 00 00
		Signature: Type 0, Family F, Model 2, Stepping 2
		Flags: None
		Version: Intel Xeon MP       
		Voltage: 1.5 V
		External Clock: 100 MHz
		Max Speed: 3000 MHz
		Current Speed: 2000 MHz
		Status: Populated, Enabled
		Upgrade: ZIF Socket
		L1 Cache Handle: 0x001F
		L2 Cache Handle: 0x0020
		L3 Cache Handle: 0x0021
Handle 0x004A
	DMI type 4, 32 bytes.
	Processor Information
		Socket Designation: Node 1 CPU 5
		Type: Central Processor
		Family: Xeon
		Manufacturer: GenuineIntel
		ID: 22 0F 00 00 00 00 00 00
		Signature: Type 0, Family F, Model 2, Stepping 2
		Flags: None
		Version: Intel Xeon MP       
		Voltage: 1.5 V
		External Clock: 100 MHz
		Max Speed: 3000 MHz
		Current Speed: 2000 MHz
		Status: Populated, Enabled
		Upgrade: ZIF Socket
		L1 Cache Handle: 0x0022
		L2 Cache Handle: 0x0023
		L3 Cache Handle: 0x0024
Handle 0x004B
	DMI type 4, 32 bytes.
	Processor Information
		Socket Designation: Node 1 CPU 6
		Type: Central Processor
		Family: Xeon
		Manufacturer: GenuineIntel
		ID: 22 0F 00 00 00 00 00 00
		Signature: Type 0, Family F, Model 2, Stepping 2
		Flags: None
		Version: Intel Xeon MP       
		Voltage: 1.5 V
		External Clock: 100 MHz
		Max Speed: 3000 MHz
		Current Speed: 2000 MHz
		Status: Populated, Enabled
		Upgrade: ZIF Socket
		L1 Cache Handle: 0x0025
		L2 Cache Handle: 0x0026
		L3 Cache Handle: 0x0027
Handle 0x004C
	DMI type 4, 32 bytes.
	Processor Information
		Socket Designation: Node 1 CPU 7
		Type: Central Processor
		Family: Xeon
		Manufacturer: GenuineIntel
		ID: 22 0F 00 00 00 00 00 00
		Signature: Type 0, Family F, Model 2, Stepping 2
		Flags: None
		Version: Intel Xeon MP       
		Voltage: 1.5 V
		External Clock: 100 MHz
		Max Speed: 3000 MHz
		Current Speed: 2000 MHz
		Status: Populated, Enabled
		Upgrade: ZIF Socket
		L1 Cache Handle: 0x0028
		L2 Cache Handle: 0x0029
		L3 Cache Handle: 0x002A
Handle 0x004D
	DMI type 4, 32 bytes.
	Processor Information
		Socket Designation: Node 1 CPU 8
		Type: Central Processor
		Family: Xeon
		Manufacturer: GenuineIntel
		ID: 22 0F 00 00 00 00 00 00
		Signature: Type 0, Family F, Model 2, Stepping 2
		Flags: None
		Version: Intel Xeon MP       
		Voltage: 1.5 V
		External Clock: 100 MHz
		Max Speed: 3000 MHz
		Current Speed: 2000 MHz
		Status: Populated, Enabled
		Upgrade: ZIF Socket
		L1 Cache Handle: 0x002B
		L2 Cache Handle: 0x002C
		L3 Cache Handle: 0x002D
Handle 0x0056
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Lower Scalability 1
		External Connector Type: Proprietary
		Port Type: Other
Handle 0x0057
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Lower Scalability 2
		External Connector Type: Proprietary
		Port Type: Other
Handle 0x0058
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Lower Scalability 3
		External Connector Type: Proprietary
		Port Type: Other
Handle 0x0059
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Upper Scalability 1
		External Connector Type: Proprietary
		Port Type: Other
Handle 0x005A
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Upper Scalability 2
		External Connector Type: Proprietary
		Port Type: Other
Handle 0x005B
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Upper Scalability 3
		External Connector Type: Proprietary
		Port Type: Other
Handle 0x005C
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: RXE B
		External Connector Type: Proprietary
		Port Type: Other
Handle 0x005D
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Mouse
		External Connector Type: Mini DIN
		Port Type: Mouse Port
Handle 0x005E
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Keyboard
		External Connector Type: Mini DIN
		Port Type: Keyboard Port
Handle 0x005F
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: RS-485
		External Connector Type: RJ-45
		Port Type: Other
Handle 0x0060
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: USB 1
		External Connector Type: Access Bus (USB)
		Port Type: USB
Handle 0x0061
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: USB 2
		External Connector Type: Access Bus (USB)
		Port Type: USB
Handle 0x0062
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: USB 3
		External Connector Type: Access Bus (USB)
		Port Type: USB
Handle 0x0063
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: Video
		External Connector Type: DB-15 female
		Port Type: Video Port
Handle 0x0064
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: RXE A
		External Connector Type: Proprietary
		Port Type: Other
Handle 0x0065
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Diskette/CDROM
		Internal Connector Type: Other
		External Reference Designator: Not Specified
		External Connector Type: None
		Port Type: Other
Handle 0x0066
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: External SCSI (channel A)
		External Connector Type: 68 Pin Dual Inline
		Port Type: SCSI Wide
Handle 0x0067
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Internal SCSI (channel B)
		Internal Connector Type: 68 Pin Dual Inline
		External Reference Designator: Not Specified
		External Connector Type: None
		Port Type: SCSI Wide
Handle 0x0068
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: 10/100/1000 Ethernet (port A)
		External Connector Type: RJ-45
		Port Type: Network Port
Handle 0x0069
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: 10/100/1000 Ethernet (port B)
		External Connector Type: RJ-45
		Port Type: Network Port
Handle 0x006A
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: RSA Serial
		External Connector Type: DB-9 male
		Port Type: Serial Port 16550A Compatible
Handle 0x006B
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: RSA Ethernet
		External Connector Type: RJ-45
		Port Type: Network Port
Handle 0x006C
	DMI type 8, 9 bytes.
	Port Connector Information
		Internal Reference Designator: Not Specified
		Internal Connector Type: None
		External Reference Designator: RSA RS-485
		External Connector Type: RJ-45
		Port Type: Other
Handle 0x0081
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: Node 1 133MHz PCI-X ActivePCI Card Slot 6
		Type: 64-bit PCI-X
		Current Usage: Available
		Length: Long
		ID: 6
		Characteristics:
			3.3 V is provided
			PME signal is supported
			Hot-plug devices are supported
Handle 0x0082
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: Node 1 133MHz PCI-X ActivePCI Card Slot 5
		Type: 64-bit PCI-X
		Current Usage: Available
		Length: Long
		ID: 5
		Characteristics:
			3.3 V is provided
			PME signal is supported
			Hot-plug devices are supported
Handle 0x0083
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: Node 1 100MHz PCI-X ActivePCI Card Slot 4
		Type: 64-bit PCI-X
		Current Usage: Available
		Length: Long
		ID: 4
		Characteristics:
			3.3 V is provided
			PME signal is supported
			Hot-plug devices are supported
Handle 0x0084
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: Node 1 100MHz PCI-X ActivePCI Card Slot 3
		Type: 64-bit PCI-X
		Current Usage: Available
		Length: Long
		ID: 3
		Characteristics:
			3.3 V is provided
			PME signal is supported
			Hot-plug devices are supported
Handle 0x0085
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: Node 1 66MHz PCI-X ActivePCI Card Slot 2
		Type: 64-bit PCI-X
		Current Usage: Available
		Length: Long
		ID: 2
		Characteristics:
			3.3 V is provided
			PME signal is supported
			Hot-plug devices are supported
Handle 0x0086
	DMI type 9, 13 bytes.
	System Slot Information
		Designation: Node 1 66MHz PCI-X ActivePCI Card Slot 1
		Type: 64-bit PCI-X
		Current Usage: Available
		Length: Long
		ID: 1
		Characteristics:
			3.3 V is provided
			PME signal is supported
			Hot-plug devices are supported
Handle 0x00A5
	DMI type 10, 10 bytes.
	On Board Device Information
		Type: Video
		Status: Enabled
		Description: ATI Rage XL Video Controller, 8M Memory
	On Board Device Information
		Type: SCSI Controller
		Status: Enabled
		Description: LSI Logic 1030 Dual Ultra320 SCSI Controller
	On Board Device Information
		Type: Ethernet
		Status: Enabled
		Description: Broadcom 5704 10/100/1000 Dual Ethernet Controller
Handle 0x00A7
	DMI type 11, 5 bytes.
	OEM Strings
		String 1: IBM Diagnostics 1.05 -[REYT23AUS-1.05]-
		String 2: IBM Remote Supervisor Adapter -[REE825CUS]-
Handle 0x00A8
	DMI type 12, 5 bytes.
	System Configuration Options
		Option 1: J20-Power on Password Override jumper
		Option 2: Changing the position of this jumper bypasses the
		Option 3: power-on password checking on the next power-on. 
		Option 4: You do not need to move the jumper back to the 
		Option 5: default position after the password is overridden. 
		Option 6: Changing the position of this jumper does not affect 
		Option 7: the administrator password check if an administrator 
		Option 8: password is set.
Handle 0x00A9
	DMI type 12, 5 bytes.
	System Configuration Options
		Option 1: J28-Flash ROM page swap jumper
		Option 2: Primary-on pins 1-2, Backup-on pins 2-3
		Option 3: The Primary(default) position is a jumper installed 
		Option 4: on pins marked by a white block under the pins.
		Option 5: Changing the position of this jumper will change 
		Option 6: which of the two pages of flash ROM is used when 
		Option 7: the system is started.
Handle 0x00AA
	DMI type 13, 22 bytes.
	BIOS Language Information
		Installable Languages: 1
			en|US|iso8859-1
		Currently Installed Language: en|US|iso8859-1
Handle 0x00AB
	DMI type 16, 15 bytes.
	Physical Memory Array
		Location: System Board Or Motherboard
		Use: System Memory
		Error Correction Type: Multi-bit ECC
		Maximum Capacity: 64 GB
		Error Information Handle: Not Provided
		Number Of Devices: 64
Handle 0x00AC
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 1
		Locator: J1
		Bank Locator: BANK 1/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00AD
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 1
		Locator: J3
		Bank Locator: BANK 1/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00AE
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: 512 MB
		Form Factor: DIMM
		Set: 2
		Locator: J2
		Bank Locator: BANK 3/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00AF
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: 512 MB
		Form Factor: DIMM
		Set: 2
		Locator: J4
		Bank Locator: BANK 3/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00B0
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 3
		Locator: J5
		Bank Locator: BANK 5/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00B1
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 3
		Locator: J7
		Bank Locator: BANK 5/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00B2
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: 512 MB
		Form Factor: DIMM
		Set: 4
		Locator: J6
		Bank Locator: BANK 7/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00B3
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: 512 MB
		Form Factor: DIMM
		Set: 4
		Locator: J8
		Bank Locator: BANK 7/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00B4
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 5
		Locator: J9
		Bank Locator: BANK 2/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00B5
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 5
		Locator: J11
		Bank Locator: BANK 2/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00B6
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: 1024 MB
		Form Factor: DIMM
		Set: 6
		Locator: J10
		Bank Locator: BANK 4/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00B7
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: 1024 MB
		Form Factor: DIMM
		Set: 6
		Locator: J12
		Bank Locator: BANK 4/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00B8
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 7
		Locator: J13
		Bank Locator: BANK 6/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00B9
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 7
		Locator: J15
		Bank Locator: BANK 6/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00BA
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 8
		Locator: J14
		Bank Locator: BANK 8/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00BB
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 8
		Locator: J16
		Bank Locator: BANK 8/SMP Module 1/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00BC
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: 2048 MB
		Form Factor: DIMM
		Set: 9
		Locator: J1
		Bank Locator: BANK 1/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00BD
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: 2048 MB
		Form Factor: DIMM
		Set: 9
		Locator: J3
		Bank Locator: BANK 1/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00BE
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 10
		Locator: J2
		Bank Locator: BANK 3/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00BF
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 10
		Locator: J4
		Bank Locator: BANK 3/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00C0
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 11
		Locator: J5
		Bank Locator: BANK 5/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00C1
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 11
		Locator: J7
		Bank Locator: BANK 5/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00C2
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 12
		Locator: J6
		Bank Locator: BANK 7/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00C3
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 12
		Locator: J8
		Bank Locator: BANK 7/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00C4
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: 1024 MB
		Form Factor: DIMM
		Set: 13
		Locator: J9
		Bank Locator: BANK 2/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00C5
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: 1024 MB
		Form Factor: DIMM
		Set: 13
		Locator: J11
		Bank Locator: BANK 2/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00C6
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 14
		Locator: J10
		Bank Locator: BANK 4/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00C7
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 14
		Locator: J12
		Bank Locator: BANK 4/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00C8
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 15
		Locator: J13
		Bank Locator: BANK 6/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00C9
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 15
		Locator: J15
		Bank Locator: BANK 6/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00CA
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 16
		Locator: J14
		Bank Locator: BANK 8/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00CB
	DMI type 17, 21 bytes.
	Memory Device
		Array Handle: 0x00AB
		Error Information Handle: Not Provided
		Total Width: 72 bits
		Data Width: 64 bits
		Size: No Module Installed
		Form Factor: DIMM
		Set: 16
		Locator: J16
		Bank Locator: BANK 8/SMP Module 2/NODE 1
		Type: DDR
		Type Detail: Synchronous
Handle 0x00EC
	DMI type 19, 15 bytes.
	Memory Array Mapped Address
		Starting Address: 0x00000000000
		Ending Address: 0x0027FFFFFFF
		Range Size: 10 GB
		Physical Array Handle: 0x00AB
		Partition Width: 0
Handle 0x010D
	DMI type 32, 11 bytes.
	System Boot Information
		Status: No errors detected
Handle 0x010E
	DMI type 221, 31 bytes.
	OEM-specific Type
		Header And Data:
			DD 1F 0E 01 4E 4F 44 45 49 4E 46 4F 01 3A C3 61
			EB 10 1E B2 11 80 DA 50 D4 00 00 00 00 01 02
		Strings:
			IBM Diagnostics 1.05 -[REYT23AUS-1.05]-
			IBM Remote Supervisor Adapter -[REE825CUS]-
Handle 0x0110
	DMI type 127, 4 bytes.
	End Of Table

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
