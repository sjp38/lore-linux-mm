Message-ID: <46D78147.5040507@intel.com>
Date: Fri, 31 Aug 2007 10:47:35 +0800
From: "bibo,mao" <bibo.mao@intel.com>
MIME-Version: 1.0
Subject: Re: [BUG] kernel crash with CONFIG_SPARSEMEM on my ia32 box
References: <46D773C1.4070400@intel.com> <20070830190544.88b07189.akpm@linux-foundation.org>
In-Reply-To: <20070830190544.88b07189.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I tried 2.6.21 version, it also crashed similarly.

thanks
bibo,mao

Andrew Morton wrote:
> On Fri, 31 Aug 2007 09:49:53 +0800 "bibo,mao" <bibo.mao@intel.com> wrote:
> 
>  > Hi,
> 
> Let's cc linux-mm.
> 
>  >    I have one machine with 4G memory and 1G pci memory hole
>  > between 2G and 3G. I compiled kernel with CONFIG_SPARSEMEM
>  > option without PAE enabled, system crashed when booting.
>  >    I check the source code, function sparse_init will only
>  > allocate mem_map space for valid section which is set in
>  > function memory_present(). That means only E820_ram space
>  > has mem_map space allocated.
>  >    so system crashed in function set_highmem_pages_init(),
>  > if pfn points to E820_reserve space, pfn_to_page(pfn) will
>  > point to unallocated page area.
>  >
> 
> Is this a regression?  Did 2.6.21 or 2.6.22 crash similarly?
> 
> Thanks.
> 
>  >
>  >
>  > Here is crashing log.
>  > ============================================================
>  > Linux version 2.6.23-rc4 (root@harwichb) (gcc version 4.1.2 20070626 (Red
>  > Hat 4.1.2-14)) #3 SMP Wed Aug 29 23:05:50 CST 2007
>  > BIOS-provided physical RAM map:
>  >   BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
>  >   BIOS-e820: 000000000009f400 - 0000000000100000 (reserved)
>  >   BIOS-e820: 0000000000100000 - 000000007f89b000 (usable)
>  >   BIOS-e820: 000000007f89b000 - 000000007f912000 (reserved)
>  >   BIOS-e820: 000000007f912000 - 000000007f939000 (usable)
>  >   BIOS-e820: 000000007f939000 - 000000007f93a000 (reserved)
>  >   BIOS-e820: 000000007f93a000 - 000000007f944000 (usable)
>  >   BIOS-e820: 000000007f944000 - 000000007f977000 (reserved)
>  >   BIOS-e820: 000000007f977000 - 000000007f9f8000 (ACPI NVS)
>  >   BIOS-e820: 000000007f9f8000 - 000000007fa12000 (reserved)
>  >   BIOS-e820: 000000007fa12000 - 000000007fa6b000 (usable)
>  >   BIOS-e820: 000000007fa6b000 - 000000007fa92000 (reserved)
>  >   BIOS-e820: 000000007fa92000 - 000000007fb06000 (usable)
>  >   BIOS-e820: 000000007fb06000 - 000000007fb12000 (ACPI NVS)
>  >   BIOS-e820: 000000007fb12000 - 000000007fb18000 (usable)
>  >   BIOS-e820: 000000007fb18000 - 000000007fb32000 (ACPI data)
>  >   BIOS-e820: 000000007fb32000 - 000000007fb33000 (reserved)
>  >   BIOS-e820: 000000007fb33000 - 000000007fb7a000 (usable)
>  >   BIOS-e820: 000000007fb7a000 - 000000007fbfa000 (reserved)
>  >   BIOS-e820: 000000007fbfa000 - 000000007fc00000 (usable)
>  >   BIOS-e820: 0000000080000000 - 0000000090000000 (reserved)
>  >   BIOS-e820: 00000000fec00000 - 00000000fed00000 (reserved)
>  >   BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
>  >   BIOS-e820: 00000000fffa0000 - 00000000fffac000 (reserved)
>  >   BIOS-e820: 0000000100000000 - 0000000180000000 (usable)
>  > Warning only 4GB will be used.
>  > Use a HIGHMEM64G enabled kernel.
>  > 3200MB HIGHMEM available.
>  > 896MB LOWMEM available.
>  > found SMP MP-table at 000fd7c0
>  > Zone PFN ranges:
>  >    DMA             0 ->     4096
>  >    Normal       4096 ->   229376
>  >    HighMem    229376 ->  1048576
>  > Movable zone start PFN for each node
>  > early_node_map[1] active PFN ranges
>  >      0:        0 ->  1048576
>  > DMI 2.3 present.
>  > ACPI: RSDP 000F03D0, 0024 (r2 INTEL )
>  > ACPI: XSDT 7FB31F30, 006C (r1 INTEL  SHW40M          2 MSFT  1000013)
>  > ACPI: FACP 7FB2FD90, 00F4 (r3 INTEL  SHW40M          2             0)
>  > ACPI: DSDT 7FB21010, DCA4 (r1 INTEL  SHW40M          2 INTL 20030918)
>  > ACPI: FACS 7FB11C40, 0040
>  > ACPI: APIC 7FB2FC10, 015C (r1 INTEL  SHW40M          2             0)
>  > ACPI: SRAT 7FB20F90, 0058 (r1 INTEL  SHW40M          2             0)
>  > ACPI: MCFG 7FB20F10, 003C (r1 INTEL  SHW40M          2             0)
>  > ACPI: SPCR 7FB20E90, 0050 (r1 INTEL  SHW40M          2             0)
>  > ACPI: SSDT 7FB1E010, 14B0 (r1 INTEL  SHW40M       4000 INTL 20030918)
>  > ACPI: SSDT 7FB1C010, 14B0 (r1 INTEL  SHW40M       4004 INTL 20030918)
>  > ACPI: SSDT 7FB1A010, 14B0 (r1 INTEL  SHW40M       4008 INTL 20030918)
>  > ACPI: SSDT 7FB18010, 14B0 (r1 INTEL  SHW40M       400C INTL 20030918)
>  > ACPI: PM-Timer IO Port: 0x408
>  > ACPI: LAPIC (acpi_id[0x00] lapic_id[0x08] enabled)
>  > Processor #8 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x04] lapic_id[0x0e] enabled)
>  > Processor #14 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x08] lapic_id[0x00] enabled)
>  > Processor #0 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x06] enabled)
>  > Processor #6 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x02] lapic_id[0x0a] enabled)
>  > Processor #10 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x06] lapic_id[0x0c] enabled)
>  > Processor #12 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x02] enabled)
>  > Processor #2 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x04] enabled)
>  > Processor #4 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x01] lapic_id[0x09] enabled)
>  > Processor #9 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x05] lapic_id[0x0f] enabled)
>  > Processor #15 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x09] lapic_id[0x01] enabled)
>  > Processor #1 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x07] enabled)
>  > Processor #7 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x03] lapic_id[0x0b] enabled)
>  > Processor #11 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x07] lapic_id[0x0d] enabled)
>  > Processor #13 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x03] enabled)
>  > Processor #3 15:6 APIC version 20
>  > ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x05] enabled)
>  > Processor #5 15:6 APIC version 20
>  > ACPI: LAPIC_NMI (acpi_id[0x00] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x01] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x02] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x03] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x04] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x05] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x06] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x07] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x08] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x09] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x0a] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x0b] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x0c] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x0d] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x0e] high level lint[0x1])
>  > ACPI: LAPIC_NMI (acpi_id[0x0f] high level lint[0x1])
>  > ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
>  > IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
>  > ACPI: IOAPIC (id[0x09] address[0xfec85000] gsi_base[24])
>  > IOAPIC[1]: apic_id 9, version 32, address 0xfec85000, GSI 24-47
>  > ACPI: IOAPIC (id[0x0a] address[0xfec85800] gsi_base[48])
>  > IOAPIC[2]: apic_id 10, version 32, address 0xfec85800, GSI 48-71
>  > ACPI: IOAPIC (id[0x0b] address[0xfec86000] gsi_base[72])
>  > IOAPIC[3]: apic_id 11, version 32, address 0xfec86000, GSI 72-95
>  > ACPI: IOAPIC (id[0x0c] address[0xfec86800] gsi_base[96])
>  > IOAPIC[4]: apic_id 12, version 32, address 0xfec86800, GSI 96-119
>  > ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
>  > ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
>  > Enabling APIC mode:  Flat.  Using 5 I/O APICs
>  > More than 8 CPUs detected and CONFIG_X86_PC cannot handle it.
>  > Use CONFIG_X86_GENERICARCH or CONFIG_X86_BIGSMP.
>  > Using ACPI (MADT) for SMP configuration information
>  > Allocating PCI resources starting at 98000000 (gap: 90000000:6ec00000)
>  > swsusp: Registered nosave memory region: 000000000009f000 - 00000000000a0000
>  > swsusp: Registered nosave memory region: 00000000000a0000 - 0000000000100000
>  > Built 1 zonelists in Zone order.  Total pages: 1040384
>  > Kernel command line: ro root=LABEL=/12 console=tty0 console=ttyS0,115200
>  > Enabling fast FPU save and restore... done.
>  > Enabling unmasked SIMD FPU exception support... done.
>  > Initializing CPU#0
>  > PID hash table entries: 4096 (order: 12, 16384 bytes)
>  > Detected 3192.483 MHz processor.
>  > Console: colour VGA+ 80x25
>  > console [tty0] enabled
>  > console [ttyS0] enabled
>  > Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
>  > Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
>  > BUG: unable to handle kernel paging request at virtual address 01000000
>  >   printing eip:
>  > c04f93e3
>  > *pde = 00000000
>  > Oops: 0002 [#1]
>  > SMP
>  > Modules linked in:
>  > CPU:    0
>  > EIP:    0060:[<c04f93e3>]    Not tainted VLI
>  > EFLAGS: 00010292   (2.6.23-rc4 #3)
>  > EIP is at add_one_highpage_init+0x4d/0x59
>  > eax: 00000039   ebx: 01000000   ecx: 00000046   edx: 00000000
>  > esi: 00080000   edi: 00000000   ebp: 00000040   esp: c04e7f44
>  > ds: 007b   es: 007b   fs: 00d8  gs: 0000  ss: 0068
>  > Process swapper (pid: 0, ti=c04e6000 task=c04ac2a0 task.ti=c04e6000)
>  > Stack: c046afbe 01000000 00080000 00000000 00080001 01000020 00000000 c04f9733
>  >         c0224f2a c046fec3 c04e7f7c c04e7f7c c04fd13c c046fec3 c0471ab5
>  > 00010000
>  >         00000006 00040000 03f80000 00000000 0fe00000 c0471ab5 00000010
>  > 00001e83
>  > Call Trace:
>  >   [<c04f9733>] mem_init+0xf4/0x382
>  >   [<c0224f2a>] printk+0x1b/0x1f
>  >   [<c04fd13c>] alloc_large_system_hash+0x205/0x230
>  >   [<c04fde99>] inode_init_early+0x49/0x72
>  >   [<c04ec874>] start_kernel+0x270/0x2f6
>  >   [<c04ec0e0>] unknown_bootoption+0x0/0x195
>  >   =======================
>  > Code: f8 3f 76 0f f0 0f ba 33 0a 83 c4 10 89 d8 5b 5e 5f eb b6 89 7c 24 0c
>  > 89 74 24 08 89 5c 24 04 c7 04 24 be af 46 c0 e8 2c bb d2 ff <f0> 0f ba 2b
>  > 0a 83 c4 10 5b 5e 5f c3 8b 15 ac 1e 4e c0 55 57 56
>  > EIP: [<c04f93e3>] add_one_highpage_init+0x4d/0x59 SS:ESP 0068:c04e7f44
>  > Kernel panic - not syncing: Attempted to kill the idle task!
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
