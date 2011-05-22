Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D7912900123
	for <linux-mm@kvack.org>; Sat, 21 May 2011 23:37:42 -0400 (EDT)
Received: from mail05.corp.redhat.com (zmail05.collab.prod.int.phx2.redhat.com [10.5.5.46])
	by mx3-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p4M3bewt017379
	for <linux-mm@kvack.org>; Sat, 21 May 2011 23:37:41 -0400
Date: Sat, 21 May 2011 23:37:40 -0400 (EDT)
From: Qiannan Cui <qcui@redhat.com>
Message-ID: <1439534018.155162.1306035460906.JavaMail.root@zmail05.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1158989060.155090.1306033067946.JavaMail.root@zmail05.collab.prod.int.phx2.redhat.com>
Subject: Kernel panic - not syncing: Attempted to kill the idle task!
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_155161_1683497149.1306035460905"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

------=_Part_155161_1683497149.1306035460905
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hi,
When I updated the kernel from 2.6.32 to 2.6.39+, the server can not boot the 2.6.39+ kernel successfully. The console ouput showed 'Kernel panic - not syncing: Attempted to kill the idle task!' I have tried to set the kernel parameter idle=poll in the grub file. But it failed to boot again due to the same error. Could anyone help me to solve the problem? The full console output is attached. Thanks.

Best Regards,
Cui

------=_Part_155161_1683497149.1306035460905
Content-Type: application/octet-stream; name=kernel_panic_console_output
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=kernel_panic_console_output

Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.39+ (gcc version 4.4.5 20110214) #1 SMP Fri May 20 03:50:15 EDT 2011
Command line:ro root=/dev/mapper/vg_amddrachma01-lv_root rd_LVM_LV=vg_amddrachma01/lv_root rd_LVM_LV=vg_amddrachma01/lv_swap rd_NO_LUKS rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrheb-sun16 KEYBOARDTYPE=pc KEYTABLE=us console=ttyS0,115200 crashkernel=auto
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009c400 (usable)
 BIOS-e820: 000000000009c400 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000d2000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000c7e70000 (usable)
 BIOS-e820: 00000000c7e70000 - 00000000c7e8b000 (ACPI data)
 BIOS-e820: 00000000c7e8b000 - 00000000c7e8d000 (ACPI NVS)
 BIOS-e820: 00000000c7e8d000 - 00000000c8000000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000001038000000 (usable)
NX (Execute Disable) protection: active
DMI present.
No AGP bridge found
last_pfn = 0x1038000 max_arch_pfn = 0x400000000
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
last_pfn = 0xc7e70 max_arch_pfn = 0x400000000
found SMP MP-table at [ffff8800000f7250] f7250
Using GB pages for direct mapping
init_memory_mapping: 0000000000000000-00000000c7e70000
init_memory_mapping: 0000000100000000-0000001038000000
RAMDISK: 36993000 - 37ff0000
crashkernel: memory value expected
ACPI: RSDP 00000000000f71d0 00024 (v02 PTLTD )
ACPI: XSDT 00000000c7e77c7e 0006C (v01 PTLTD  ? XSDT   06040000  LTP 00000000)
ACPI: FACP 00000000c7e82cae 000F4 (v03 AMD    CHIPOTLE 06040000 AMD  000F4240)
ACPI: DSDT 00000000c7e77cea 0AFC4 (v02    AMD    SB700 06040000 MSFT 03000000)
ACPI: FACS 00000000c7e8cfc0 00040
ACPI: TCPA 00000000c7e82e16 00032 (v02 AMD             06040000 PTEC 00000000)
ACPI: SLIT 00000000c7e82e48 0006C (v01 AMD    F10      06040000 AMD  00000001)
ACPI: SRAT 00000000c7e82eb4 00420 (v02 AMD    F10      06040000 AMD  00000001)
ACPI: SSDT 00000000c7e832d4 078B4 (v01 AMD    POWERNOW 06040000 AMD  00000001)
ACPI: SSDT 00000000c7e8ab88 0010A (v01 AMD-K8 AMD-ACPI 06040000  AMD 00000001)
ACPI: APIC 00000000c7e8ac92 002FA (v01 PTLTD  ? APIC   06040000  LTP 00000000)
ACPI: MCFG 00000000c7e8af8c 0003C (v01 PTLTD    MCFG   06040000  LTP 00000000)
ACPI: HPET 00000000c7e8afc8 00038 (v01 PTLTD  HPETTBL  06040000  LTP 00000001)
SRAT: PXM 0 -> APIC 0x10 -> Node 0
SRAT: PXM 0 -> APIC 0x11 -> Node 0
SRAT: PXM 0 -> APIC 0x12 -> Node 0
SRAT: PXM 0 -> APIC 0x13 -> Node 0
SRAT: PXM 0 -> APIC 0x14 -> Node 0
SRAT: PXM 0 -> APIC 0x15 -> Node 0
SRAT: PXM 1 -> APIC 0x16 -> Node 1
SRAT: PXM 1 -> APIC 0x17 -> Node 1
SRAT: PXM 1 -> APIC 0x18 -> Node 1
SRAT: PXM 1 -> APIC 0x19 -> Node 1
SRAT: PXM 1 -> APIC 0x1a -> Node 1
SRAT: PXM 1 -> APIC 0x1b -> Node 1
SRAT: PXM 2 -> APIC 0x20 -> Node 2
SRAT: PXM 2 -> APIC 0x21 -> Node 2
SRAT: PXM 2 -> APIC 0x22 -> Node 2
SRAT: PXM 2 -> APIC 0x23 -> Node 2
SRAT: PXM 2 -> APIC 0x24 -> Node 2
SRAT: PXM 2 -> APIC 0x25 -> Node 2
SRAT: PXM 3 -> APIC 0x26 -> Node 3
SRAT: PXM 3 -> APIC 0x27 -> Node 3
SRAT: PXM 3 -> APIC 0x28 -> Node 3
SRAT: PXM 3 -> APIC 0x29 -> Node 3
SRAT: PXM 3 -> APIC 0x2a -> Node 3
SRAT: PXM 3 -> APIC 0x2b -> Node 3
SRAT: PXM 4 -> APIC 0x30 -> Node 4
SRAT: PXM 4 -> APIC 0x31 -> Node 4
SRAT: PXM 4 -> APIC 0x32 -> Node 4
SRAT: PXM 4 -> APIC 0x33 -> Node 4
SRAT: PXM 4 -> APIC 0x34 -> Node 4
SRAT: PXM 4 -> APIC 0x35 -> Node 4
SRAT: PXM 5 -> APIC 0x36 -> Node 5
SRAT: PXM 5 -> APIC 0x37 -> Node 5
SRAT: PXM 5 -> APIC 0x38 -> Node 5
SRAT: PXM 5 -> APIC 0x39 -> Node 5
SRAT: PXM 5 -> APIC 0x3a -> Node 5
SRAT: PXM 5 -> APIC 0x3b -> Node 5
SRAT: PXM 6 -> APIC 0x40 -> Node 6
SRAT: PXM 6 -> APIC 0x41 -> Node 6
SRAT: PXM 6 -> APIC 0x42 -> Node 6
SRAT: PXM 6 -> APIC 0x43 -> Node 6
SRAT: PXM 6 -> APIC 0x44 -> Node 6
SRAT: PXM 6 -> APIC 0x45 -> Node 6
SRAT: PXM 7 -> APIC 0x46 -> Node 7
SRAT: PXM 7 -> APIC 0x47 -> Node 7
SRAT: PXM 7 -> APIC 0x48 -> Node 7
SRAT: PXM 7 -> APIC 0x49 -> Node 7
SRAT: PXM 7 -> APIC 0x4a -> Node 7
SRAT: PXM 7 -> APIC 0x4b -> Node 7
SRAT: Node 1 PXM 1 0-a0000
SRAT: Node 1 PXM 1 100000-c8000000
SRAT: Node 1 PXM 1 100000000-438000000
SRAT: Node 3 PXM 3 438000000-838000000
SRAT: Node 5 PXM 5 838000000-c38000000
SRAT: Node 7 PXM 7 c38000000-1038000000
NUMA: Node 1 [0,a0000) + [100000,c8000000) -> [0,c8000000)
NUMA: Node 1 [0,c8000000) + [100000000,438000000) -> [0,438000000)
Initmem setup node 1 0000000000000000-0000000438000000
  NODE_DATA [0000000437fd9000 - 0000000437ffffff]
Initmem setup node 3 0000000438000000-0000000838000000
  NODE_DATA [0000000837fd9000 - 0000000837ffffff]
Initmem setup node 5 0000000838000000-0000000c38000000
  NODE_DATA [0000000c37fd9000 - 0000000c37ffffff]
Initmem setup node 7 0000000c38000000-0000001038000000
  NODE_DATA [0000001037fd7000 - 0000001037ffdfff]
[ffffea000ec40000-ffffea000edfffff] potential offnode page_structs
[ffffea001cc40000-ffffea001cdfffff] potential offnode page_structs
[ffffea002ac40000-ffffea002adfffff] potential offnode page_structs
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x01038000
Movable zone start PFN for each node
early_node_map[6] active PFN ranges
    1: 0x00000010 -> 0x0000009c
    1: 0x00000100 -> 0x000c7e70
    1: 0x00100000 -> 0x00438000
    3: 0x00438000 -> 0x00838000
    5: 0x00838000 -> 0x00c38000
    7: 0x00c38000 -> 0x01038000
ACPI: PM-Timer IO Port: 0x2008
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x10] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x11] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x12] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x13] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x14] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x15] enabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x16] enabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x17] enabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x18] enabled)
ACPI: LAPIC (acpi_id[0x09] lapic_id[0x19] enabled)
ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x1a] enabled)
ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x1b] enabled)
ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x20] enabled)
ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x21] enabled)
ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x22] enabled)
ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x23] enabled)
ACPI: LAPIC (acpi_id[0x10] lapic_id[0x24] enabled)
ACPI: LAPIC (acpi_id[0x11] lapic_id[0x25] enabled)
ACPI: LAPIC (acpi_id[0x12] lapic_id[0x26] enabled)
ACPI: LAPIC (acpi_id[0x13] lapic_id[0x27] enabled)
ACPI: LAPIC (acpi_id[0x14] lapic_id[0x28] enabled)
ACPI: LAPIC (acpi_id[0x15] lapic_id[0x29] enabled)
ACPI: LAPIC (acpi_id[0x16] lapic_id[0x2a] enabled)
ACPI: LAPIC (acpi_id[0x17] lapic_id[0x2b] enabled)
ACPI: LAPIC (acpi_id[0x18] lapic_id[0x30] enabled)
ACPI: LAPIC (acpi_id[0x19] lapic_id[0x31] enabled)
ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x32] enabled)
ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x33] enabled)
ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x34] enabled)
ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x35] enabled)
ACPI: LAPIC (acpi_id[0x1e] lapic_id[0x36] enabled)
ACPI: LAPIC (acpi_id[0x1f] lapic_id[0x37] enabled)
ACPI: LAPIC (acpi_id[0x20] lapic_id[0x38] enabled)
ACPI: LAPIC (acpi_id[0x21] lapic_id[0x39] enabled)
ACPI: LAPIC (acpi_id[0x22] lapic_id[0x3a] enabled)
ACPI: LAPIC (acpi_id[0x23] lapic_id[0x3b] enabled)
ACPI: LAPIC (acpi_id[0x24] lapic_id[0x40] enabled)
ACPI: LAPIC (acpi_id[0x25] lapic_id[0x41] enabled)
ACPI: LAPIC (acpi_id[0x26] lapic_id[0x42] enabled)
ACPI: LAPIC (acpi_id[0x27] lapic_id[0x43] enabled)
ACPI: LAPIC (acpi_id[0x28] lapic_id[0x44] enabled)
ACPI: LAPIC (acpi_id[0x29] lapic_id[0x45] enabled)
ACPI: LAPIC (acpi_id[0x2a] lapic_id[0x46] enabled)
ACPI: LAPIC (acpi_id[0x2b] lapic_id[0x47] enabled)
ACPI: LAPIC (acpi_id[0x2c] lapic_id[0x48] enabled)
ACPI: LAPIC (acpi_id[0x2d] lapic_id[0x49] enabled)
ACPI: LAPIC (acpi_id[0x2e] lapic_id[0x4a] enabled)
ACPI: LAPIC (acpi_id[0x2f] lapic_id[0x4b] enabled)
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x05] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x07] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x08] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x09] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x0a] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x0b] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x0c] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x0d] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x0e] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x0f] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x10] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x11] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x12] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x13] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x14] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x15] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x16] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x17] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x18] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x19] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x1a] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x1b] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x1c] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x1d] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x1e] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x1f] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x20] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x21] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x22] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x23] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x24] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x25] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x26] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x27] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x28] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x29] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x2a] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x2b] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x2c] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x2d] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x2e] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x2f] high edge lint[0x1])
ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 0, version 33, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x01] address[0xc8000000] gsi_base[24])
IOAPIC[1]: apic_id 1, version 33, address 0xc8000000, GSI 24-55
ACPI: IOAPIC (id[0x02] address[0xd8000000] gsi_base[56])
IOAPIC[2]: apic_id 2, version 33, address 0xd8000000, GSI 56-87
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 low level)
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x43538301 base: 0xfed00000
SMP: Allowing 48 CPUs, 0 hotplug CPUs
PM: Registered nosave memory: 000000000009c000 - 000000000009d000
PM: Registered nosave memory: 000000000009d000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000d2000
PM: Registered nosave memory: 00000000000d2000 - 0000000000100000
PM: Registered nosave memory: 00000000c7e70000 - 00000000c7e8b000
PM: Registered nosave memory: 00000000c7e8b000 - 00000000c7e8d000
PM: Registered nosave memory: 00000000c7e8d000 - 00000000c8000000
PM: Registered nosave memory: 00000000c8000000 - 00000000e0000000
PM: Registered nosave memory: 00000000e0000000 - 00000000f0000000
PM: Registered nosave memory: 00000000f0000000 - 00000000fec00000
PM: Registered nosave memory: 00000000fec00000 - 00000000fec10000
PM: Registered nosave memory: 00000000fec10000 - 00000000fee00000
PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
PM: Registered nosave memory: 00000000fee01000 - 00000000fff00000
PM: Registered nosave memory: 00000000fff00000 - 0000000100000000
Allocating PCI resources starting at c8000000 (gap: c8000000:18000000)
Booting paravirtualized kernel on bare hardware
setup_percpu: NR_CPUS:4096 nr_cpumask_bits:48 nr_cpu_ids:48 nr_node_ids:8
PERCPU: Embedded 29 pages/cpu @ffff880437800000 s89536 r8192 d21056 u262144
Built 4 zonelists in Zone order, mobility grouping on.  Total pages: 16544183
Policy zone: Normal
Kernel command line: ro root=/dev/mapper/vg_amddrachma01-lv_root rd_LVM_LV=vg_amddrachma01/lv_root rd_LVM_LV=vg_amddrachma01/lv_swap rd_NO_LUKS rd_NO_MD rd_NO_DM LANG=en_US.UTF-8 SYSFONT=latarcyrheb-sun16 KEYBOARDTYPE=pc KEYTABLE=us console=ttyS0,115200 crashkernel=auto
PID hash table entries: 4096 (order: 3, 32768 bytes)
Checking aperture...
No AGP bridge found
Node 0: aperture @ c014000000 size 32 MB
Aperture beyond 4GB. Ignoring.
Your BIOS doesn't leave a aperture memory hole
Please enable the IOMMU option in the BIOS setup
This costs you 64 MB of RAM
Mapping aperture over 65536 KB of RAM @ a0000000
PM: Registered nosave memory: 00000000a0000000 - 00000000a4000000
Memory: 66010044k/68026368k available (4953k kernel code, 919568k absent, 1096756k reserved, 7378k data, 1500k init)
Hierarchical RCU implementation.
	RCU-based detection of stalled CPUs is disabled.
NR_IRQS:262400 nr_irqs:2152 16
Console: colour VGA+ 80x25
console [ttyS0] enabled
BUG: unable to handle kernel paging request at 0000000000001c08
IP: [<ffffffff811076cc>] __alloc_pages_nodemask+0x7c/0x1f0
PGD 0 
Oops: 0000 [#1] SMP 
last sysfs file: 
CPU 0 
Modules linked in:

Pid: 0, comm: swapper Not tainted 2.6.39+ #1 AMD DRACHMA/DRACHMA
RIP: 0010:[<ffffffff811076cc>]  [<ffffffff811076cc>] __alloc_pages_nodemask+0x7c/0x1f0
RSP: 0000:ffffffff81a01e48  EFLAGS: 00010246
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000008 RDI: 00000000000002d0
RBP: ffffffff81a01ea8 R08: ffffffff81c03680 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000001 R12: 00000000000002d0
R13: 0000000000001c00 R14: ffffffff81a01fa8 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff880437800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000001c08 CR3: 0000000001a03000 CR4: 00000000000006b0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a0b020)
Stack:
 0000000000000000 0000000000000000 ffffffff81a01eb8 000002d000000008
 ffffffff00000020 ffffffff81a01ec8 ffffffff81a01e88 0000000000000008
 0000000000100000 0000000000000000 ffffffff81a01fa8 0000000000093cf0
Call Trace:
 [<ffffffff81107d7f>] alloc_pages_exact_nid+0x5f/0xc0
 [<ffffffff814b2dea>] alloc_page_cgroup+0x2a/0x80
 [<ffffffff814b2ece>] init_section_page_cgroup+0x8e/0x110
 [<ffffffff81c4a2f1>] page_cgroup_init+0x6e/0xa7
 [<ffffffff81c22de4>] start_kernel+0x2ae/0x366
 [<ffffffff81c22346>] x86_64_start_reservations+0x131/0x135
 [<ffffffff81c2244d>] x86_64_start_kernel+0x103/0x112
Code: e0 08 83 f8 01 44 89 e0 19 db c1 e8 13 f7 d3 83 e0 01 83 e3 02 09 c3 8b 05 22 e5 af 00 44 21 e0 a8 10 89 45 bc 0f 85 c4 00 00 00 
 83 7d 08 00 0f 84 dd 00 00 00 65 4c 8b 34 25 c0 cc 00 00 41 
RIP  [<ffffffff811076cc>] __alloc_pages_nodemask+0x7c/0x1f0
 RSP <ffffffff81a01e48>
CR2: 0000000000001c08
---[ end trace a7919e7f17c0a725 ]---
Kernel panic - not syncing: Attempted to kill the idle task!
Pid: 0, comm: swapper Tainted: G      D     2.6.39+ #1
Call Trace:
 [<ffffffff814c77fb>] panic+0x91/0x1a8
 [<ffffffff81067709>] do_exit+0x3f9/0x430
 [<ffffffff814cb88b>] oops_end+0xab/0xf0
 [<ffffffff8103d6fc>] no_context+0xfc/0x190
 [<ffffffff8103d8b5>] __bad_area_nosemaphore+0x125/0x1e0


------=_Part_155161_1683497149.1306035460905--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
