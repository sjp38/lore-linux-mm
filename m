Received: by qb-out-0506.google.com with SMTP id e21so168219qba.0
        for <linux-mm@kvack.org>; Sat, 26 Jan 2008 06:10:18 -0800 (PST)
Message-ID: <2f11576a0801260610m29f4e7ecle9828d8bbaa462cd@mail.gmail.com>
Date: Sat, 26 Jan 2008 23:10:17 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
In-Reply-To: <20080123102332.GB21455@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie>
	 <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080123105810.F295.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080123102332.GB21455@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org, kosaki.motohiro@gmail.com
List-ID: <linux-mm.kvack.org>

Hi Mel


>To rule it out, can you also try with the patch below applied please? It
>should only make a difference on sparsemem so if discontigmem is still
>crashing, there is likely another problem. Assuming it crashes, please
>post the full dmesg output with loglevel=8 on the command line. Thanks

I buy reverse serial cable today.
and I test again.

my patch stack is
  2.6.24-rc7 +
  http://lkml.org/lkml/2007/8/24/220 +
  Relax restrictions on setting CONFIG_NUMA patch +
  your previous mail patch

1. if sparce_mem on, build failture

  CC      arch/x86/mm/discontig_32.o
  CC      init/do_mounts_initrd.o
  CC      arch/x86/kernel/time_32.o
  CC      init/initramfs.o
arch/x86/mm/discontig_32.c: In function 'setup_memory':
arch/x86/mm/discontig_32.c:341: error: too many arguments to function
'calculate_numa_remap_pages'
arch/x86/mm/discontig_32.c:380: error: 'node_remap_offset' undeclared
(first use in this function)
arch/x86/mm/discontig_32.c:380: error: (Each undeclared identifier is
reported only once
arch/x86/mm/discontig_32.c:380: error: for each function it appears in.)
arch/x86/mm/discontig_32.c:383: error: 'node_remap_end_vaddr'
undeclared (first use in this function)
arch/x86/mm/discontig_32.c:385: error: 'node_remap_alloc_vaddr'
undeclared (first use in this function)
arch/x86/mm/discontig_32.c:404: error: 'node_remap_start_pfn'
undeclared (first use in this function)

2. if discontig_mem on, I can't boot.

root (hd0,0)
 Filesystem type is ext2fs, partition type 0x83
kernel /vmlinuz-kosatest ro root=/dev/VolGroup00/LogVol00 rhgb quiet console=tt
y0 console=ttyS0,9600n8r loglevel=8
   [Linux-bzImage, setup=0x2800, size=0x278918]
initrd /initrd-kosatest.img
   [Linux-initrd @ 0x1f3bc000, 0x2c0208 bytes]

Linux version 2.6.24-rc7-numa (kosaki@sc420) (gcc version 4.1.2
20070626 (Red Hat 4.1.2-14)) #13 SMP Sat Jan 26 22:57:40 JST 2008
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 00000000000a0000 (usable)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000001f68cc00 (usable)
 BIOS-e820: 000000001f68cc00 - 000000001f68ec00 (ACPI NVS)
 BIOS-e820: 000000001f68ec00 - 000000001f690c00 (ACPI data)
 BIOS-e820: 000000001f690c00 - 0000000020000000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fed00400 (reserved)
 BIOS-e820: 00000000fed20000 - 00000000feda0000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fef00000 (reserved)
 BIOS-e820: 00000000ffb00000 - 0000000100000000 (reserved)
Node: 0, start_pfn: 0, end_pfn: 160
  Setting physnode_map array to node 0 for pfns:
  0
Node: 0, start_pfn: 256, end_pfn: 128652
  Setting physnode_map array to node 0 for pfns:
  256 65792
get_memcfg_from_srat: assigning address to rsdp
RSD PTR  v0 [DELL  ]
Begin SRAT table scan....
failed to get NUMA memory information from SRAT table
NUMA - single node, flat memory mode
Node: 0, start_pfn: 0, end_pfn: 160
  Setting physnode_map array to node 0 for pfns:
  0
Node: 0, start_pfn: 256, end_pfn: 128652
  Setting physnode_map array to node 0 for pfns:
  256 65792
Node: 0, start_pfn: 0, end_pfn: 128652
  Setting physnode_map array to node 0 for pfns:
  0 65536
Reserving 1024 pages of KVA for lmem_map of node 0
Shrinking node 0 from 128652 pages to 127628 pages
Shrinking node 0 further by 652 pages for proper alignment
Reserving total of 1024 pages for numa KVA remap
kva_start_pfn ~ 125952 find_max_low_pfn() ~ 128652
max_pfn = 128652
0MB HIGHMEM available.
502MB LOWMEM available.
min_low_pfn = 1665, max_low_pfn = 128652, highstart_pfn = 128652
Low memory ends at vaddr df68c000
node 0 will remap to vaddr dec00000 - dfa8c000
High memory starts at vaddr df68c000
found SMP MP-table at 000fe710
Entering add_active_range(0, 0, 126976) 0 entries of 256 used
Zone PFN ranges:
  DMA             0 ->     4096
  Normal       4096 ->   128652
  HighMem    128652 ->   128652
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    0:        0 ->   126976
On node 0 totalpages: 126976
  DMA zone: 32 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 4064 pages, LIFO batch:0
  Normal zone: 960 pages used for memmap
  Normal zone: 121920 pages, LIFO batch:31
  HighMem zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
DMI 2.3 present.
Using APIC driver default
ACPI: RSDP 000FEC00, 0014 (r0 DELL  )
ACPI: RSDT 000FCC8F, 003C (r1 DELL    PESC420        7 ASL        61)
ACPI: FACP 000FCCCB, 0074 (r1 DELL    PESC420        7 ASL        61)
ACPI: DSDT FFFCE00E, 2DA9 (r1   DELL    dt_ex     1000 MSFT  100000D)
ACPI: FACS 1F68CC00, 0040
ACPI: SSDT FFFD0FAE, 0096 (r1   DELL    st_ex     1000 MSFT  100000D)
ACPI: APIC 000FCD3F, 0072 (r1 DELL    PESC420        7 ASL        61)
ACPI: BOOT 000FCDB1, 0028 (r1 DELL    PESC420        7 ASL        61)
ACPI: MCFG 000FCDD9, 003E (r1 DELL    PESC420        7 ASL        61)
ACPI: HPET 000FCE17, 0038 (r1 DELL    PESC420        7 ASL        61)
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
Processor #0 15:4 APIC version 20
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
Processor #1 15:4 APIC version 20
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] disabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x07] disabled)
ACPI: LAPIC_NMI (acpi_id[0xff] high level lint[0x1])
ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
ACPI: HPET id: 0x8086a201 base: 0xfed00000
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at 30000000 (gap: 20000000:c0000000)
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 125984
Policy zone: Normal
Kernel command line: ro root=/dev/VolGroup00/LogVol00 rhgb quiet
console=tty0 console=ttyS0,9600n8r loglevel=8
mapped APIC to ffffb000 (fee00000)
mapped IOAPIC to ffffa000 (fec00000)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
PID hash table entries: 2048 (order: 11, 8192 bytes)
Detected 2793.181 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
console [ttyS0] enabled
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Bad page state in process 'swapper'
page:defe2000 flags:0x763aaa3a mapping:3dda44a6 mapcount:-479800631 count:0
Trying to fix it up, but a reboot is needed
Backtrace:
Pid: 0, comm: swapper Not tainted 2.6.24-rc7-numa #13
 [<c014da0b>] bad_page+0x64/0x8e
 [<c014e6af>] __free_pages_ok+0x5d/0x2ad
 [<c05af4f2>] free_all_bootmem_core+0xd5/0x1b1
 [<c05ac932>] mem_init+0x7f/0x351
 [<c05b0a25>] alloc_large_system_hash+0x21a/0x245
 [<c05b1947>] inode_init_early+0x49/0x72
 [<c059f5ca>] start_kernel+0x281/0x30c
 [<c059f0e0>] unknown_bootoption+0x0/0x195
 =======================
BUG: unable to handle kernel paging request at virtual address 2b021d5a
printing eip: c014e694 *pde = 00000000
Oops: 0000 [#1] SMP
Modules linked in:

Pid: 0, comm: swapper Tainted: G    B   (2.6.24-rc7-numa #13)
EIP: 0060:[<c014e694>] EFLAGS: 00010246 CPU: 0
EIP is at __free_pages_ok+0x42/0x2ad
EAX: 00000000 EBX: defe2020 ECX: 2b021d56 EDX: 4e20ad11
ESI: 4e20ad0f EDI: 00000000 EBP: defe2000 ESP: c0599f0c
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c0598000 task=c053f3a0 task.ti=c0598000)
Stack: 00000005 00000287 00000001 00000002 00000200 00000009 0000000a dec233e0
       ffffffff 0001f000 00000000 c05af4f2 c0683000 c05f6520 0001f000 0001e599
       0001f68c 00000001 00000000 00000000 00000000 00000020 c05ac932 c04d1437
Call Trace:
 [<c05af4f2>] free_all_bootmem_core+0xd5/0x1b1
 [<c05ac932>] mem_init+0x7f/0x351
 [<c05b0a25>] alloc_large_system_hash+0x21a/0x245
 [<c05b1947>] inode_init_early+0x49/0x72
 [<c059f5ca>] start_kernel+0x281/0x30c
 [<c059f0e0>] unknown_bootoption+0x0/0x195
 =======================
Code: 00 eb 5e 8b 03 89 d9 8b 73 08 8b 53 10 25 00 40 02 00 3d 00 40
02 00 75 03 8b 4b 0c 85 d2 0f 95 c2 8d 46 01 0f b6 d2 09 c2 31 c0 <83>
79 04 00 0f 95 c0 09 c2 8b 03 25 e1 9c 08 00 09 c2 74 07 89
EIP: [<c014e694>] __free_pages_ok+0x42/0x2ad SS:ESP 0068:c0599f0c
---[ end trace ca143223eefdc828 ]---
Kernel panic - not syncing: Attempted to kill the idle task!


panic point is below line (I invested by compare EIP and disassenble list.)

static void __free_pages_ok(struct page *page, unsigned int order)
{
        unsigned long flags;
        int i;
        int reserved = 0;

        for (i = 0 ; i < (1 << order) ; ++i)
                reserved += free_pages_check(page + i);    // here!
        if (reserved)
                return;


thanks!

--
kosaki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
