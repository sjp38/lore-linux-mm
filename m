Date: Tue, 25 Dec 2007 14:05:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG]  at mm/slab.c:3320
Message-Id: <20071225140519.ef8457ff.akpm@linux-foundation.org>
In-Reply-To: <20071220100541.GA6953@skywalker>
References: <20071220100541.GA6953@skywalker>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Dec 2007 15:35:41 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> 
> Linux version 2.6.24-rc5-autokern1 (root@elm3a23) (gcc version 3.4.6 20060404
> (Red Hat 3.4.6-9)) #1 SMP PREEMPT Thu Dec 20 04:16:18 EST 2007
> BIOS-provided physical RAM map:
>  BIOS-e820: 0000000000000000 - 000000000009c400 (usable)
>  BIOS-e820: 000000000009c400 - 00000000000a0000 (reserved)
>  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
>  BIOS-e820: 0000000000100000 - 00000000dff91900 (usable)
>  BIOS-e820: 00000000dff91900 - 00000000dff9c340 (ACPI data)
>  BIOS-e820: 00000000dff9c340 - 00000000e0000000 (reserved)
>  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
>  BIOS-e820: 0000000100000000 - 00000002a0000000 (usable)
> Node: 0, start_pfn: 0, end_pfn: 156
> Node: 0, start_pfn: 256, end_pfn: 917393
> Node: 0, start_pfn: 1048576, end_pfn: 2752512
> get_memcfg_from_srat: assigning address to rsdp
> RSD PTR  v0 [IBM   ]
> Begin SRAT table scan....
> CPU 0x00 in proximity domain 0x00
> CPU 0x02 in proximity domain 0x00
> CPU 0x10 in proximity domain 0x00
> CPU 0x12 in proximity domain 0x00
> Memory range 0x0 to 0xE0000 (type 0x0) in proximity domain 0x00 enabled
> Memory range 0x100000 to 0x120000 (type 0x0) in proximity domain 0x00 enabled
> CPU 0x20 in proximity domain 0x01
> CPU 0x22 in proximity domain 0x01
> CPU 0x30 in proximity domain 0x01
> CPU 0x32 in proximity domain 0x01
> Memory range 0x120000 to 0x2A0000 (type 0x0) in proximity domain 0x01 enabled
> acpi20_parse_srat: Entry length value is zero; can't parse any further!
> pxm bitmap: 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 00 00 00 00 00 00 00 00 00 00
> Number of logical nodes in system = 2
> Number of memory chunks in system = 3
> chunk 0 nid 0 start_pfn 00000000 end_pfn 000e0000
> chunk 1 nid 0 start_pfn 00100000 end_pfn 00120000
> chunk 2 nid 1 start_pfn 00120000 end_pfn 002a0000
> Node: 0, start_pfn: 0, end_pfn: 1179648
> Node: 1, start_pfn: 1179648, end_pfn: 2752512
> Reserving 16384 pages of KVA for lmem_map of node 0
> Shrinking node 0 from 1179648 pages to 1163264 pages
> Reserving 22016 pages of KVA for lmem_map of node 1
> Shrinking node 1 from 2752512 pages to 2730496 pages
> Reserving total of 38400 pages for numa KVA remap
> kva_start_pfn ~ 190464 find_max_low_pfn() ~ 229376
> max_pfn = 2752512
> 9856MB HIGHMEM available.
> 896MB LOWMEM available.
> min_low_pfn = 1945, max_low_pfn = 229376, highstart_pfn = 229376
> Low memory ends at vaddr f8000000
> node 0 will remap to vaddr ee800000 - fc000000
> node 1 will remap to vaddr f2800000 - 01600000
> High memory starts at vaddr f8000000
> found SMP MP-table at 0009c540
> Zone PFN ranges:
>   DMA             0 ->     4096
>   Normal       4096 ->   229376
>   HighMem    229376 ->  2752512
> Movable zone start PFN for each node
> early_node_map[3] active PFN ranges
>     0:        0 ->   917504
>     0:  1048576 ->  1163264
>     1:  1179648 ->  2730496
> DMI 2.3 present.
> Using APIC driver default
> ACPI: RSDP 000FDFC0, 0014 (r0 IBM   )
> ACPI: RSDT DFF9C2C0, 0034 (r1 IBM    SERVIGIL     1000 IBM  45444F43)
> ACPI: FACP DFF9C240, 0074 (r1 IBM    SERVIGIL     1000 IBM  45444F43)
> ACPI Warning (tbfadt-0442): Optional field "Gpe1Block" has zero address or
> length: 0000000000000000/4 [20070126]
> ACPI: DSDT DFF91900, 4AE5 (r1 IBM    SERVIGIL     1000 INTL  2002025)
> ACPI: FACS DFF9BFC0, 0040
> ACPI: APIC DFF9C140, 00D2 (r1 IBM    SERVIGIL     1000 IBM  45444F43)
> ACPI: SRAT DFF9C000, 0128 (r1 IBM    SERVIGIL     1000 IBM  45444F43)
> ACPI: SSDT DFF96400, 5AE6 (r1 IBM    VIGSSDT0     1000 INTL  2002025)
> ACPI: PM-Timer IO Port: 0x508
> Marking TSC unstable due to: Summit based system.
> Switched to APIC driver `summit'.
> ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
> Processor #0 15:2 APIC version 20
> ACPI: LAPIC (acpi_id[0x01] lapic_id[0x02] enabled)
> Processor #2 15:2 APIC version 20
> ACPI: LAPIC (acpi_id[0x04] lapic_id[0x10] enabled)
> Processor #16 15:2 APIC version 20
> ACPI: LAPIC (acpi_id[0x05] lapic_id[0x12] enabled)
> Processor #18 15:2 APIC version 20
> ACPI: LAPIC (acpi_id[0x08] lapic_id[0x20] enabled)
> Processor #32 15:2 APIC version 20
> ACPI: LAPIC (acpi_id[0x09] lapic_id[0x22] enabled)
> Processor #34 15:2 APIC version 20
> ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x30] enabled)
> Processor #48 15:2 APIC version 20
> ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x32] enabled)
> Processor #50 15:2 APIC version 20
> ACPI: LAPIC_NMI (acpi_id[0x00] dfl dfl lint[0x1])
> ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
> ACPI: LAPIC_NMI (acpi_id[0x04] dfl dfl lint[0x1])
> ACPI: LAPIC_NMI (acpi_id[0x05] dfl dfl lint[0x1])
> ACPI: LAPIC_NMI (acpi_id[0x08] dfl dfl lint[0x1])
> ACPI: LAPIC_NMI (acpi_id[0x09] dfl dfl lint[0x1])
> ACPI: LAPIC_NMI (acpi_id[0x0c] dfl dfl lint[0x1])
> ACPI: LAPIC_NMI (acpi_id[0x0d] dfl dfl lint[0x1])
> ACPI: IOAPIC (id[0x0e] address[0xfec00000] gsi_base[0])
> IOAPIC[0]: apic_id 14, version 17, address 0xfec00000, GSI 0-43
> ACPI: IOAPIC (id[0x0d] address[0xfec01000] gsi_base[44])
> IOAPIC[1]: apic_id 13, version 17, address 0xfec01000, GSI 44-87
> ACPI: INT_SRC_OVR (bus 0 bus_irq 8 global_irq 8 low edge)
> ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high dfl)
> ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 low level)
> Enabling APIC mode:  Summit.  Using 2 I/O APICs
> Using ACPI (MADT) for SMP configuration information
> Allocating PCI resources starting at e2000000 (gap: e0000000:1ec00000)
> Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 2545933
> Policy zone: HighMem
> Kernel command line: ro console=tty0 console=ttyS0,115200 autobench_args:
> root=/dev/sda3 ABAT:1198144312
> Enabling fast FPU save and restore... done.
> Enabling unmasked SIMD FPU exception support... done.
> Initializing CPU#0
> CPU 0 irqstacks, hard=c04c9000 soft=c0449000
> PID hash table entries: 4096 (order: 12, 16384 bytes)
> Detected 1996.171 MHz processor.
> Console: colour VGA+ 80x25
> console [tty0] enabled
> console [ttyS0] enabled
> Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
> ... MAX_LOCKDEP_SUBCLASSES:    8
> ... MAX_LOCK_DEPTH:          30
> ... MAX_LOCKDEP_KEYS:        2048
> ... CLASSHASH_SIZE:           1024
> ... MAX_LOCKDEP_ENTRIES:     8192
> ... MAX_LOCKDEP_CHAINS:      16384
> ... CHAINHASH_SIZE:          8192
>  memory used by lock dependency info: 992 kB
>  per task-struct memory footprint: 1200 bytes
> Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
> Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
> Initializing HighMem for node 0 (00038000:0011c000)
> Initializing HighMem for node 1 (00120000:0029aa00)
> Memory: 10168328k/11010048k available (2043k kernel code, 162988k reserved,
> 1058k data, 232k init, 9414212k highmem)
> virtual kernel memory layout:
>     fixmap  : 0xff234000 - 0xfffff000   (14124 kB)
>     pkmap   : 0xff000000 - 0xff200000   (2048 kB)
>     vmalloc : 0xf8800000 - 0xfeffe000   ( 103 MB)
>     lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
>       .init : 0xc040c000 - 0xc0446000   ( 232 kB)
>       .data : 0xc02fedc1 - 0xc040765c   (1058 kB)
>       .text : 0xc0100000 - 0xc02fedc1   (2043 kB)
> Checking if this processor honours the WP bit even in supervisor mode... Ok.
> Calibrating delay using timer specific routine.. 4002.61 BogoMIPS
> (lpj=8005239)
> ------------[ cut here ]------------
> kernel BUG at mm/slab.c:3320!
> invalid opcode: 0000 [#1] PREEMPT SMP
> Modules linked in:
> 
> Pid: 0, comm: swapper Not tainted (2.6.24-rc5-autokern1 #1)
> EIP: 0060:[<c0181707>] EFLAGS: 00010046 CPU: 0
> EIP is at ____cache_alloc_node+0x1c/0x130
> EAX: ee4005c0 EBX: 00000000 ECX: 00000001 EDX: 000000d0
> ESI: 00000000 EDI: ee4005c0 EBP: c0408f74 ESP: c0408f54
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process swapper (pid: 0, ti=c0408000 task=c03d5d80 task.ti=c0408000)
> Stack: c03d5d80 c0408f6c c017ac36 00000001 000000d0 00000000 000000d0 ee4005c0
>        c0408f88 c0181577 0001080c 00000246 ee4005c0 c0408fa8 c0181a97 c0408fb0
>        c01395b9 000000d0 0001080c 00099800 c03dccec c0408fd0 c01395b9 c0408fd0
> Call Trace:
>  [<c0105e23>] show_trace_log_lvl+0x19/0x2e
>  [<c0105ee5>] show_stack_log_lvl+0x99/0xa1
>  [<c010603f>] show_registers+0xb3/0x1e9
>  [<c0106301>] die+0x11b/0x1fe
>  [<c02fb654>] do_trap+0x8e/0xa8
>  [<c01065cd>] do_invalid_op+0x88/0x92
>  [<c02fb422>] error_code+0x72/0x78
>  [<c0181577>] alternate_node_alloc+0x5b/0x60
>  [<c0181a97>] kmem_cache_alloc+0x50/0x120
>  [<c01395b9>] create_pid_cachep+0x4c/0xec
>  [<c041ae65>] pidmap_init+0x2f/0x6e
>  [<c040c715>] start_kernel+0x1ca/0x23e
>  [<00000000>] 0x0
>  =======================
> Code: ff eb 02 31 ff 89 f8 83 c4 10 5b 5e 5f 5d c3 55 89 e5 57 89 c7 56 53 83
> ec 14 89 55 f0 89 4d ec 8b b4 88 88 02 00 00 85 f6 75 04 <0f> 0b eb fe e8 f3
> ee ff ff 8d 46 24 89 45 e4 e8 23 97 17 00 8b
> EIP: [<c0181707>] ____cache_alloc_node+0x1c/0x130 SS:ESP 0068:c0408f54
> Kernel panic - not syncing: Attempted to kill the idle task!

ow.

static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
				int nodeid)
{
	struct list_head *entry;
	struct slab *slabp;
	struct kmem_list3 *l3;
	void *obj;
	int x;

	l3 = cachep->nodelists[nodeid];
	BUG_ON(!l3);

Maybe something got mucked up in our initial preparation of the zonelists.

I assume this is a recent regression.  Is there any chance you can bisect
it down to the offending commit?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
