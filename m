Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 099766B0035
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 21:26:20 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so19473469pbc.1
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 18:26:20 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id l8si56776075pao.7.2014.01.06.18.26.18
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 18:26:19 -0800 (PST)
Date: Tue, 7 Jan 2014 10:25:59 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [setup_bios_corruption_check] WARNING: CPU: 0 PID: 0 at
 mm/memblock.c:789 __next_free_mem_range+0x82/0x261()
Message-ID: <20140107022559.GE14055@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
Content-Disposition: inline
In-Reply-To: <20140106133600.GA18624@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>, Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all,

Here is another call trace triggered by debug patch 68abcdf547
("mm/memblock: use WARN_ONCE when MAX_NUMNODES passed as input
parameter"):

[    0.000000] found SMP MP-table at [mem 0x000fdab0-0x000fdabf] mapped at [c00fdab0]
[    0.000000]   mpc: fdac0-fdbe4
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: CPU: 0 PID: 0 at mm/memblock.c:789 __next_free_mem_range+0x82/0x261()
[    0.000000] Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.13.0-rc7-next-20140106-07462-gb4a839b #4
[    0.000000] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000]  c1b8fea0 c1b8fea0 c1b8fe60 c180425f c1b8fe90 c103af65 c1ab8db8 c1b8febc
[    0.000000]  00000000 c1ab8d54 00000315 c1e51e3d c1e51e3d 00000000 00000001 00000001
[    0.000000]  c1b8fea8 c103afd3 00000009 c1b8fea0 c1ab8db8 c1b8febc c1b8ff08 c1e51e3d
[    0.000000] Call Trace:
[    0.000000]  [<c180425f>] dump_stack+0x16/0x18
[    0.000000]  [<c103af65>] warn_slowpath_common+0x75/0x90
[    0.000000]  [<c1e51e3d>] ? __next_free_mem_range+0x82/0x261
[    0.000000]  [<c1e51e3d>] ? __next_free_mem_range+0x82/0x261
[    0.000000]  [<c103afd3>] warn_slowpath_fmt+0x33/0x40
[    0.000000]  [<c1e51e3d>] __next_free_mem_range+0x82/0x261
[    0.000000]  [<c1e023f5>] setup_bios_corruption_check+0x78/0x1ee
[    0.000000]  [<c1df7bad>] ? memblock_x86_fill+0x5f/0x74
[    0.000000]  [<c1df5792>] setup_arch+0x703/0xbef
[    0.000000]  [<c1df2771>] start_kernel+0x75/0x447
[    0.000000]  [<c1df23be>] ? reserve_ebda_region+0x63/0x68
[    0.000000]  [<c1df2358>] i386_start_kernel+0x12e/0x131
[    0.000000] ---[ end trace ee1eeac2e47ba743 ]---
[    0.000000] Scanning 1 areas for low memory corruption

Full dmesg and kconfig attached.

Thanks,
Fengguang

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-yocto-waimea-8:20140107090354:i386-randconfig-nh1-01070835:3.13.0-rc7-next-20140106-07462-gb4a839b:4"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... No relocation needed... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.13.0-rc7-next-20140106-07462-gb4a839b (kbuil=
d@nhm4) (gcc version 4.8.1 (Debian 4.8.1-8) ) #4 Tue Jan 7 08:58:11 CST 2014
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   UMC UMC UMC UMC
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x1000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdab0-0x000fdabf] mapped at =
[c00fdab0]
[    0.000000]   mpc: fdac0-fdbe4
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: CPU: 0 PID: 0 at mm/memblock.c:789 __next_free_mem_=
range+0x82/0x261()
[    0.000000] Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.13.0-rc7-next-2014=
0106-07462-gb4a839b #4
[    0.000000] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000]  c1b8fea0 c1b8fea0 c1b8fe60 c180425f c1b8fe90 c103af65 c1ab8=
db8 c1b8febc
[    0.000000]  00000000 c1ab8d54 00000315 c1e51e3d c1e51e3d 00000000 00000=
001 00000001
[    0.000000]  c1b8fea8 c103afd3 00000009 c1b8fea0 c1ab8db8 c1b8febc c1b8f=
f08 c1e51e3d
[    0.000000] Call Trace:
[    0.000000]  [<c180425f>] dump_stack+0x16/0x18
[    0.000000]  [<c103af65>] warn_slowpath_common+0x75/0x90
[    0.000000]  [<c1e51e3d>] ? __next_free_mem_range+0x82/0x261
[    0.000000]  [<c1e51e3d>] ? __next_free_mem_range+0x82/0x261
[    0.000000]  [<c103afd3>] warn_slowpath_fmt+0x33/0x40
[    0.000000]  [<c1e51e3d>] __next_free_mem_range+0x82/0x261
[    0.000000]  [<c1e023f5>] setup_bios_corruption_check+0x78/0x1ee
[    0.000000]  [<c1df7bad>] ? memblock_x86_fill+0x5f/0x74
[    0.000000]  [<c1df5792>] setup_arch+0x703/0xbef
[    0.000000]  [<c1df2771>] start_kernel+0x75/0x447
[    0.000000]  [<c1df23be>] ? reserve_ebda_region+0x63/0x68
[    0.000000]  [<c1df2358>] i386_start_kernel+0x12e/0x131
[    0.000000] ---[ end trace ee1eeac2e47ba743 ]---
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x027fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0fa00000-0x0fbfffff]
[    0.000000]  [mem 0x0fa00000-0x0fbfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0c000000-0x0f9fffff]
[    0.000000]  [mem 0x0c000000-0x0f9fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0bffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x0bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0fffdfff]
[    0.000000]  [mem 0x0fc00000-0x0fdfffff] page 2M
[    0.000000]  [mem 0x0fe00000-0x0fffdfff] page 4k
[    0.000000] BRK [0x023a8000, 0x023a8fff] PGTABLE
[    0.000000] cma: dma_contiguous_reserve(limit 00000000)
[    0.000000] cma: dma_contiguous_reserve: reserving 25 MiB for global area
[    0.000000] cma: dma_contiguous_reserve_area(size 198f000, base 00000000=
, limit 00000000)
[    0.000000] cma: CMA: reserved 28 MiB at 0e000000
[    0.000000] RAMDISK: [mem 0x0fce4000-0x0ffeffff]
[    0.000000] ACPI: RSDP 000fd920 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0fffe450 000034 (v01 BOCHS  BXPCRSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: FACP 0fffff80 000074 (v01 BOCHS  BXPCFACP 00000001 BXP=
C 00000001)
[    0.000000] ACPI: DSDT 0fffe490 0011A9 (v01   BXPC   BXDSDT 00000001 INT=
L 20100528)
[    0.000000] ACPI: FACS 0fffff40 000040
[    0.000000] ACPI: SSDT 0ffff7a0 000796 (v01 BOCHS  BXPCSSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: APIC 0ffff680 000080 (v01 BOCHS  BXPCAPIC 00000001 BXP=
C 00000001)
[    0.000000] ACPI: HPET 0ffff640 000038 (v01 BOCHS  BXPCHPET 00000001 BXP=
C 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, boot clock
[    0.000000] BRK [0x023a9000, 0x023a9fff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x0fffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000] free_area_init_node: node 0, pgdat c1dab9a0, node_mem_map cd=
e00020
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 480 pages used for memmap
[    0.000000]   Normal zone: 61438 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] Using ACPI for processor (LAPIC) configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] Intel MultiProcessor Specification v1.4
[    0.000000]     Virtual Wire compatibility mode.
[    0.000000]   mpc: fdac0-fdbe4
[    0.000000] MPTABLE: OEM ID: BOCHSCPU
[    0.000000] MPTABLE: Product ID: 0.1        =20
[    0.000000] MPTABLE: APIC at: 0xFEE00000
[    0.000000] Lint: type 3, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC=
 LINT 00
[    0.000000] Lint: type 1, pol 0, trig 0, bus 01, IRQ 00, APIC ID ff, API=
C LINT 01
[    0.000000] Processors: 1
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1ba32c0
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64924
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10  prompt_ramdisk=
=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 r=
w link=3D/kernel-tests/run-queue/kvm/i386-randconfig-nh1-01070835/next:mast=
er/.vmlinuz-b4a839be48406e0e8bdec0bbc86db6f67df3d406-20140107090038-7-waime=
a branch=3Dnext/master BOOT_IMAGE=3D/kernel/i386-randconfig-nh1-01070835/b4=
a839be48406e0e8bdec0bbc86db6f67df3d406/vmlinuz-3.13.0-rc7-next-20140106-074=
62-gb4a839b
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] allocated 524264 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=3Dmemory' option if you don't wan=
t memory cgroups
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 206912K/261744K available (8254K kernel code, 2450K =
rwdata, 3568K rodata, 752K init, 5012K bss, 54832K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffcc000 - 0xfffff000   ( 204 kB)
[    0.000000]     pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
[    0.000000]     vmalloc : 0xd07fe000 - 0xffbfe000   ( 756 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xcfffe000   ( 255 MB)
[    0.000000]       .init : 0xc1df2000 - 0xc1eae000   ( 752 kB)
[    0.000000]       .data : 0xc180fc2c - 0xc1df1880   (6023 kB)
[    0.000000]       .text : 0xc1000000 - 0xc180fc2c   (8255 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] CPU 0 irqstacks, hard=3Dcd802000 soft=3Dcd804000
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.13.0-rc7-next-20140106-07462-gb4a839b (kbuil=
d@nhm4) (gcc version 4.8.1 (Debian 4.8.1-8) ) #4 Tue Jan 7 08:58:11 CST 2014
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   UMC UMC UMC UMC
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x1000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdab0-0x000fdabf] mapped at =
[c00fdab0]
[    0.000000]   mpc: fdac0-fdbe4
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: CPU: 0 PID: 0 at mm/memblock.c:789 __next_free_mem_=
range+0x82/0x261()
[    0.000000] Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.13.0-rc7-next-2014=
0106-07462-gb4a839b #4
[    0.000000] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000]  c1b8fea0 c1b8fea0 c1b8fe60 c180425f c1b8fe90 c103af65 c1ab8=
db8 c1b8febc
[    0.000000]  00000000 c1ab8d54 00000315 c1e51e3d c1e51e3d 00000000 00000=
001 00000001
[    0.000000]  c1b8fea8 c103afd3 00000009 c1b8fea0 c1ab8db8 c1b8febc c1b8f=
f08 c1e51e3d
[    0.000000] Call Trace:
[    0.000000]  [<c180425f>] dump_stack+0x16/0x18
[    0.000000]  [<c103af65>] warn_slowpath_common+0x75/0x90
[    0.000000]  [<c1e51e3d>] ? __next_free_mem_range+0x82/0x261
[    0.000000]  [<c1e51e3d>] ? __next_free_mem_range+0x82/0x261
[    0.000000]  [<c103afd3>] warn_slowpath_fmt+0x33/0x40
[    0.000000]  [<c1e51e3d>] __next_free_mem_range+0x82/0x261
[    0.000000]  [<c1e023f5>] setup_bios_corruption_check+0x78/0x1ee
[    0.000000]  [<c1df7bad>] ? memblock_x86_fill+0x5f/0x74
[    0.000000]  [<c1df5792>] setup_arch+0x703/0xbef
[    0.000000]  [<c1df2771>] start_kernel+0x75/0x447
[    0.000000]  [<c1df23be>] ? reserve_ebda_region+0x63/0x68
[    0.000000]  [<c1df2358>] i386_start_kernel+0x12e/0x131
[    0.000000] ---[ end trace ee1eeac2e47ba743 ]---
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x027fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0fa00000-0x0fbfffff]
[    0.000000]  [mem 0x0fa00000-0x0fbfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0c000000-0x0f9fffff]
[    0.000000]  [mem 0x0c000000-0x0f9fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0bffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x0bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0fffdfff]
[    0.000000]  [mem 0x0fc00000-0x0fdfffff] page 2M
[    0.000000]  [mem 0x0fe00000-0x0fffdfff] page 4k
[    0.000000] BRK [0x023a8000, 0x023a8fff] PGTABLE
[    0.000000] cma: dma_contiguous_reserve(limit 00000000)
[    0.000000] cma: dma_contiguous_reserve: reserving 25 MiB for global area
[    0.000000] cma: dma_contiguous_reserve_area(size 198f000, base 00000000=
, limit 00000000)
[    0.000000] cma: CMA: reserved 28 MiB at 0e000000
[    0.000000] RAMDISK: [mem 0x0fce4000-0x0ffeffff]
[    0.000000] ACPI: RSDP 000fd920 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0fffe450 000034 (v01 BOCHS  BXPCRSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: FACP 0fffff80 000074 (v01 BOCHS  BXPCFACP 00000001 BXP=
C 00000001)
[    0.000000] ACPI: DSDT 0fffe490 0011A9 (v01   BXPC   BXDSDT 00000001 INT=
L 20100528)
[    0.000000] ACPI: FACS 0fffff40 000040
[    0.000000] ACPI: SSDT 0ffff7a0 000796 (v01 BOCHS  BXPCSSDT 00000001 BXP=
C 00000001)
[    0.000000] ACPI: APIC 0ffff680 000080 (v01 BOCHS  BXPCAPIC 00000001 BXP=
C 00000001)
[    0.000000] ACPI: HPET 0ffff640 000038 (v01 BOCHS  BXPCHPET 00000001 BXP=
C 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, boot clock
[    0.000000] BRK [0x023a9000, 0x023a9fff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x0fffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000] free_area_init_node: node 0, pgdat c1dab9a0, node_mem_map cd=
e00020
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 480 pages used for memmap
[    0.000000]   Normal zone: 61438 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] Using ACPI for processor (LAPIC) configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] Intel MultiProcessor Specification v1.4
[    0.000000]     Virtual Wire compatibility mode.
[    0.000000]   mpc: fdac0-fdbe4
[    0.000000] MPTABLE: OEM ID: BOCHSCPU
[    0.000000] MPTABLE: Product ID: 0.1        =20
[    0.000000] MPTABLE: APIC at: 0xFEE00000
[    0.000000] Lint: type 3, pol 0, trig 0, bus 01, IRQ 00, APIC ID 0, APIC=
 LINT 00
[    0.000000] Lint: type 1, pol 0, trig 0, bus 01, IRQ 00, APIC ID ff, API=
C LINT 01
[    0.000000] Processors: 1
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1ba32c0
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64924
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10  prompt_ramdisk=
=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 r=
w link=3D/kernel-tests/run-queue/kvm/i386-randconfig-nh1-01070835/next:mast=
er/.vmlinuz-b4a839be48406e0e8bdec0bbc86db6f67df3d406-20140107090038-7-waime=
a branch=3Dnext/master BOOT_IMAGE=3D/kernel/i386-randconfig-nh1-01070835/b4=
a839be48406e0e8bdec0bbc86db6f67df3d406/vmlinuz-3.13.0-rc7-next-20140106-074=
62-gb4a839b
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] allocated 524264 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=3Dmemory' option if you don't wan=
t memory cgroups
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 206912K/261744K available (8254K kernel code, 2450K =
rwdata, 3568K rodata, 752K init, 5012K bss, 54832K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffcc000 - 0xfffff000   ( 204 kB)
[    0.000000]     pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
[    0.000000]     vmalloc : 0xd07fe000 - 0xffbfe000   ( 756 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xcfffe000   ( 255 MB)
[    0.000000]       .init : 0xc1df2000 - 0xc1eae000   ( 752 kB)
[    0.000000]       .data : 0xc180fc2c - 0xc1df1880   (6023 kB)
[    0.000000]       .text : 0xc1000000 - 0xc180fc2c   (8255 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] CPU 0 irqstacks, hard=3Dcd802000 soft=3Dcd804000
[    0.000000] console [ttyS0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3807 kB
[    0.000000]  memory used by lock dependency info: 3807 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 3300.264 MHz processor
[    0.000000] tsc: Detected 3300.264 MHz processor
[    0.006666] Calibrating delay loop (skipped) preset value..=20
[    0.006666] Calibrating delay loop (skipped) preset value.. 6603.55 Bogo=
MIPS (lpj=3D11000880)
6603.55 BogoMIPS (lpj=3D11000880)
[    0.006666] pid_max: default: 32768 minimum: 301
[    0.006666] pid_max: default: 32768 minimum: 301
[    0.006821] Security Framework initialized
[    0.006821] Security Framework initialized
[    0.010055] AppArmor: AppArmor disabled by boot time parameter
[    0.010055] AppArmor: AppArmor disabled by boot time parameter
[    0.011791] Yama: becoming mindful.
[    0.011791] Yama: becoming mindful.
[    0.013399] Mount-cache hash table entries: 512
[    0.013399] Mount-cache hash table entries: 512
[    0.015245] Initializing cgroup subsys debug
[    0.015245] Initializing cgroup subsys debug
[    0.016732] Initializing cgroup subsys memory
[    0.016732] Initializing cgroup subsys memory
[    0.020021] Initializing cgroup subsys devices
[    0.020021] Initializing cgroup subsys devices
[    0.021517] Initializing cgroup subsys freezer
[    0.021517] Initializing cgroup subsys freezer
[    0.023412] Initializing cgroup subsys perf_event
[    0.023412] Initializing cgroup subsys perf_event
[    0.024797] Initializing cgroup subsys net_prio
[    0.024797] Initializing cgroup subsys net_prio
[    0.026687] Initializing cgroup subsys hugetlb
[    0.026687] Initializing cgroup subsys hugetlb
[    0.028160] mce: CPU supports 10 MCE banks
[    0.028160] mce: CPU supports 10 MCE banks
[    0.030147] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.030147] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.030147] tlb_flushall_shift: 6
[    0.030147] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.030147] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.030147] tlb_flushall_shift: 6
[    0.033354] CPU:=20
[    0.033354] CPU: Intel Intel Common KVM processorCommon KVM processor (f=
am: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.046052] ACPI: Core revision 20131115
[    0.046052] ACPI: Core revision 20131115
[    0.058496] ACPI:=20
[    0.058496] ACPI: All ACPI Tables successfully acquiredAll ACPI Tables s=
uccessfully acquired

[    0.061078] ACPI: setting ELCR to 0200 (from 0c00)
[    0.061078] ACPI: setting ELCR to 0200 (from 0c00)
[    0.063731] Performance Events:=20
[    0.063731] Performance Events: unsupported Netburst CPU model 6 unsuppo=
rted Netburst CPU model 6 no PMU driver, software events only.
no PMU driver, software events only.
[    0.067233] ftrace: Allocated trace_printk buffers
[    0.067233] ftrace: Allocated trace_printk buffers
[    0.081418] Getting VERSION: 50014
[    0.081418] Getting VERSION: 50014
[    0.082435] Getting VERSION: 50014
[    0.082435] Getting VERSION: 50014
[    0.083354] Getting ID: 0
[    0.083354] Getting ID: 0
[    0.084130] Getting ID: f000000
[    0.084130] Getting ID: f000000
[    0.085024] Getting LVT0: 8700
[    0.085024] Getting LVT0: 8700
[    0.085963] Getting LVT1: 8400
[    0.085963] Getting LVT1: 8400
[    0.086786] enabled ExtINT on CPU#0
[    0.086786] enabled ExtINT on CPU#0
[    0.087873] Using local APIC timer interrupts.
[    0.087873] calibrating APIC timer ...
[    0.087873] Using local APIC timer interrupts.
[    0.087873] calibrating APIC timer ...
[    0.096666] ... lapic delta =3D 8179149
[    0.096666] ... lapic delta =3D 8179149
[    0.096666] ... PM-Timer delta =3D 468593
[    0.096666] ... PM-Timer delta =3D 468593
[    0.096666] APIC calibration not consistent with PM-Timer: 130ms instead=
 of 100ms
[    0.096666] APIC calibration not consistent with PM-Timer: 130ms instead=
 of 100ms
[    0.096666] APIC delta adjusted to PM-Timer: 6247978 (8179149)
[    0.096666] APIC delta adjusted to PM-Timer: 6247978 (8179149)
[    0.096666] TSC delta adjusted to PM-Timer: 348988165 (456855941)
[    0.096666] TSC delta adjusted to PM-Timer: 348988165 (456855941)
[    0.096666] ..... delta 6247978
[    0.096666] ..... delta 6247978
[    0.096666] ..... mult: 268348638
[    0.096666] ..... mult: 268348638
[    0.096666] ..... calibration result: 3332254
[    0.096666] ..... calibration result: 3332254
[    0.096666] ..... CPU clock speed is 3490.0768 MHz.
[    0.096666] ..... CPU clock speed is 3490.0768 MHz.
[    0.096666] ..... host bus clock speed is 999.2587 MHz.
[    0.096666] ..... host bus clock speed is 999.2587 MHz.
[    0.097982] devtmpfs: initialized
[    0.097982] devtmpfs: initialized
[    0.101561] EVM: security.ima
[    0.101561] EVM: security.ima
[    0.102551] EVM: security.capability
[    0.102551] EVM: security.capability
[    0.113614] prandom: seed boundary self test passed
[    0.113614] prandom: seed boundary self test passed
[    0.115752] prandom: 100 self tests passed
[    0.115752] prandom: 100 self tests passed
[    0.117348] regulator-dummy: no parameters
[    0.117348] regulator-dummy: no parameters
[    0.120039] NET: Registered protocol family 16
[    0.120039] NET: Registered protocol family 16
[    0.123663] EISA bus registered
[    0.123663] EISA bus registered
[    0.124783] cpuidle: using governor ladder
[    0.124783] cpuidle: using governor ladder
[    0.126684] cpuidle: using governor menu
[    0.126684] cpuidle: using governor menu
[    0.130729] ACPI: bus type PCI registered
[    0.130729] ACPI: bus type PCI registered
[    0.133373] PCI : PCI BIOS area is rw and x. Use pci=3Dnobios if you wan=
t it NX.
[    0.133373] PCI : PCI BIOS area is rw and x. Use pci=3Dnobios if you wan=
t it NX.
[    0.136686] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.136686] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.140022] PCI: Using configuration type 1 for base access
[    0.140022] PCI: Using configuration type 1 for base access
[    0.192793] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.192793] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.193520] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.193520] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.200802] ACPI: Added _OSI(Module Device)
[    0.200802] ACPI: Added _OSI(Module Device)
[    0.202033] ACPI: Added _OSI(Processor Device)
[    0.202033] ACPI: Added _OSI(Processor Device)
[    0.203360] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.203360] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.206674] ACPI: Added _OSI(Processor Aggregator Device)
[    0.206674] ACPI: Added _OSI(Processor Aggregator Device)
[    0.237327] ACPI: Interpreter enabled
[    0.237327] ACPI: Interpreter enabled
[    0.238474] ACPI Exception: AE_NOT_FOUND,=20
[    0.238474] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_]While evaluating Sleep State [\_S1_] (20131115/hwxface-580)
 (20131115/hwxface-580)
[    0.246711] ACPI Exception: AE_NOT_FOUND,=20
[    0.246711] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_]While evaluating Sleep State [\_S2_] (20131115/hwxface-580)
 (20131115/hwxface-580)
[    0.251820] ACPI: (supports S0 S3 S5)
[    0.251820] ACPI: (supports S0 S3 S5)
[    0.253360] ACPI: Using PIC for interrupt routing
[    0.253360] ACPI: Using PIC for interrupt routing
[    0.256784] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.256784] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.314758] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.314758] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.316700] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.316700] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.320013] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.320013] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.324020] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    0.324020] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    0.326998] PCI host bridge to bus 0000:00
[    0.326998] PCI host bridge to bus 0000:00
[    0.330075] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.330075] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.331819] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.331819] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.333359] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.333359] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.336693] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.336693] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.338771] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.338771] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.340185] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.340185] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.345000] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.345000] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.354340] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.354340] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.359840] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    0.359840] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    0.370264] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.370264] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.372676] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.372676] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.373412] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.373412] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.384373] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.384373] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.387669] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.387669] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.394319] pci 0000:00:02.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.394319] pci 0000:00:02.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.410174] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.410174] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.417002] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.417002] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.423354] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.423354] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.427998] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.427998] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.441137] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.441137] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.447673] pci 0000:00:04.0: [8086:2668] type 00 class 0x040300
[    0.447673] pci 0000:00:04.0: [8086:2668] type 00 class 0x040300
[    0.450534] pci 0000:00:04.0: reg 0x10: [mem 0xfebf0000-0xfebf3fff]
[    0.450534] pci 0000:00:04.0: reg 0x10: [mem 0xfebf0000-0xfebf3fff]
[    0.466704] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.466704] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.470021] pci 0000:00:05.0: reg 0x10: [io  0xc040-0xc07f]
[    0.470021] pci 0000:00:05.0: reg 0x10: [io  0xc040-0xc07f]
[    0.473956] pci 0000:00:05.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.473956] pci 0000:00:05.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.493414] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.493414] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.498082] pci 0000:00:06.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.498082] pci 0000:00:06.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.501388] pci 0000:00:06.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.501388] pci 0000:00:06.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.520126] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.520126] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.524693] pci 0000:00:07.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.524693] pci 0000:00:07.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.530877] pci 0000:00:07.0: reg 0x14: [mem 0xfebf7000-0xfebf7fff]
[    0.530877] pci 0000:00:07.0: reg 0x14: [mem 0xfebf7000-0xfebf7fff]
[    0.548294] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.548294] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.553892] pci 0000:00:08.0: reg 0x10: [io  0xc100-0xc13f]
[    0.553892] pci 0000:00:08.0: reg 0x10: [io  0xc100-0xc13f]
[    0.558140] pci 0000:00:08.0: reg 0x14: [mem 0xfebf8000-0xfebf8fff]
[    0.558140] pci 0000:00:08.0: reg 0x14: [mem 0xfebf8000-0xfebf8fff]
[    0.574044] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.574044] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.580069] pci 0000:00:09.0: reg 0x10: [io  0xc140-0xc17f]
[    0.580069] pci 0000:00:09.0: reg 0x10: [io  0xc140-0xc17f]
[    0.586695] pci 0000:00:09.0: reg 0x14: [mem 0xfebf9000-0xfebf9fff]
[    0.586695] pci 0000:00:09.0: reg 0x14: [mem 0xfebf9000-0xfebf9fff]
[    0.603631] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.603631] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.610024] pci 0000:00:0a.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.610024] pci 0000:00:0a.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.614763] pci 0000:00:0a.0: reg 0x14: [mem 0xfebfa000-0xfebfafff]
[    0.614763] pci 0000:00:0a.0: reg 0x14: [mem 0xfebfa000-0xfebfafff]
[    0.627209] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.627209] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.630838] pci 0000:00:0b.0: reg 0x10: [mem 0xfebfb000-0xfebfb00f]
[    0.630838] pci 0000:00:0b.0: reg 0x10: [mem 0xfebfb000-0xfebfb00f]
[    0.638484] pci_bus 0000:00: on NUMA node 0
[    0.638484] pci_bus 0000:00: on NUMA node 0
[    0.641814] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    0.641814] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    0.644544] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    0.644544] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    0.647608] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    0.647608] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    0.650441] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    0.650441] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    0.654135] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    0.654135] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    0.664436] ACPI:=20
[    0.664436] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    0.668527] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.668527] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.670032] vgaarb: loaded
[    0.670032] vgaarb: loaded
[    0.673338] vgaarb: bridge control possible 0000:00:02.0
[    0.673338] vgaarb: bridge control possible 0000:00:02.0
[    0.677057] Linux video capture interface: v2.00
[    0.677057] Linux video capture interface: v2.00
[    0.680183] pps_core: LinuxPPS API ver. 1 registered
[    0.680183] pps_core: LinuxPPS API ver. 1 registered
[    0.683339] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.683339] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.686836] PTP clock support registered
[    0.686836] PTP clock support registered
[    0.688133] EDAC MC: Ver: 3.0.0
[    0.688133] EDAC MC: Ver: 3.0.0
[    0.691097] EDAC DEBUG: edac_mc_sysfs_init: device mc created
[    0.691097] EDAC DEBUG: edac_mc_sysfs_init: device mc created
[    0.700639] PCI: Using ACPI for IRQ routing
[    0.700639] PCI: Using ACPI for IRQ routing
[    0.703384] PCI: pci_cache_line_size set to 64 bytes
[    0.703384] PCI: pci_cache_line_size set to 64 bytes
[    0.707060] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.707060] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.708853] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.708853] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.711046] irda_init()
[    0.711046] irda_init()
[    0.713529] NET: Registered protocol family 23
[    0.713529] NET: Registered protocol family 23
[    0.715826] nfc: nfc_init: NFC Core ver 0.1
[    0.715826] nfc: nfc_init: NFC Core ver 0.1
[    0.726685] cfg80211: Calling CRDA to update world regulatory domain
[    0.726685] cfg80211: Calling CRDA to update world regulatory domain
[    0.730153] NET: Registered protocol family 39
[    0.730153] NET: Registered protocol family 39
[    0.732221] Switched to clocksource kvm-clock
[    0.732221] Switched to clocksource kvm-clock
[    0.733333] Warning: could not register annotated branches stats
[    0.733333] Warning: could not register annotated branches stats
[    1.116850] FS-Cache: Loaded
[    1.116850] FS-Cache: Loaded
[    1.124831] pnp: PnP ACPI init
[    1.124831] pnp: PnP ACPI init
[    1.128309] ACPI: bus type PNP registered
[    1.128309] ACPI: bus type PNP registered
[    1.134080] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.134080] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.142100] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.142100] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.152847] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.152847] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.160646] pnp 00:03: [dma 2]
[    1.160646] pnp 00:03: [dma 2]
[    1.172160] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.172160] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.182117] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.182117] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.194072] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.194072] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.216219] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.216219] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.226124] pnp: PnP ACPI: found 7 devices
[    1.226124] pnp: PnP ACPI: found 7 devices
[    1.230467] ACPI: bus type PNP unregistered
[    1.230467] ACPI: bus type PNP unregistered
[    1.235768] PnPBIOS: Disabled
[    1.235768] PnPBIOS: Disabled
[    1.288619] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.288619] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.293384] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.293384] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.295095] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.295095] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.311480] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.311480] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.313426] NET: Registered protocol family 2
[    1.313426] NET: Registered protocol family 2
[    1.325114] TCP established hash table entries: 2048 (order: 1, 8192 byt=
es)
[    1.325114] TCP established hash table entries: 2048 (order: 1, 8192 byt=
es)
[    1.327255] TCP bind hash table entries: 2048 (order: 4, 90112 bytes)
[    1.327255] TCP bind hash table entries: 2048 (order: 4, 90112 bytes)
[    1.337582] TCP: Hash tables configured (established 2048 bind 2048)
[    1.337582] TCP: Hash tables configured (established 2048 bind 2048)
[    1.351519] TCP: reno registered
[    1.351519] TCP: reno registered
[    1.352481] UDP hash table entries: 256 (order: 2, 24576 bytes)
[    1.352481] UDP hash table entries: 256 (order: 2, 24576 bytes)
[    1.354270] UDP-Lite hash table entries: 256 (order: 2, 24576 bytes)
[    1.354270] UDP-Lite hash table entries: 256 (order: 2, 24576 bytes)
[    1.366482] NET: Registered protocol family 1
[    1.366482] NET: Registered protocol family 1
[    1.378288] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.378288] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.380015] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.380015] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.390230] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.390230] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.397075] pci 0000:00:02.0: Boot video device
[    1.397075] pci 0000:00:02.0: Boot video device
[    1.398637] PCI: CLS 0 bytes, default 64
[    1.398637] PCI: CLS 0 bytes, default 64
[    1.410121] Unpacking initramfs...
[    1.410121] Unpacking initramfs...
[    2.072117] Freeing initrd memory: 3120K (cfce4000 - cfff0000)
[    2.072117] Freeing initrd memory: 3120K (cfce4000 - cfff0000)
[   11.019784] DMA-API: preallocated 65536 debug entries
[   11.019784] DMA-API: preallocated 65536 debug entries
[   11.021396] DMA-API: debugging enabled by kernel config
[   11.021396] DMA-API: debugging enabled by kernel config
[   11.034926] Machine check injector initialized
[   11.034926] Machine check injector initialized
[   11.067259] apm: BIOS not found.
[   11.067259] apm: BIOS not found.
[   11.096918] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[   11.096918] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[   11.133593] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[   11.133593] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[   11.136167] Scanning for low memory corruption every 60 seconds
[   11.136167] Scanning for low memory corruption every 60 seconds
[   11.156245] cryptomgr_test (13) used greatest stack depth: 7028 bytes le=
ft
[   11.156245] cryptomgr_test (13) used greatest stack depth: 7028 bytes le=
ft
[   11.158641] PCLMULQDQ-NI instructions are not detected.
[   11.158641] PCLMULQDQ-NI instructions are not detected.
[   11.174019] The force parameter has not been set to 1. The Iris poweroff=
 handler will not be installed.
[   11.174019] The force parameter has not been set to 1. The Iris poweroff=
 handler will not be installed.
[   11.211128] audit: initializing netlink socket (disabled)
[   11.211128] audit: initializing netlink socket (disabled)
[   11.221055] type=3D2000 audit(1389056517.586:1): initialized
[   11.221055] type=3D2000 audit(1389056517.586:1): initialized
[   11.370105] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[   11.370105] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[   11.398742] VFS: Disk quotas dquot_6.5.2
[   11.398742] VFS: Disk quotas dquot_6.5.2
[   11.411074] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[   11.411074] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[   11.520173] DLM installed
[   11.520173] DLM installed
[   11.521178] fuse init (API version 7.22)
[   11.521178] fuse init (API version 7.22)
[   11.551211] msgmni has been set to 466
[   11.551211] msgmni has been set to 466
[   11.553307] cryptomgr_test (25) used greatest stack depth: 6636 bytes le=
ft
[   11.553307] cryptomgr_test (25) used greatest stack depth: 6636 bytes le=
ft
[   11.569370] cryptomgr_test (31) used greatest stack depth: 6388 bytes le=
ft
[   11.569370] cryptomgr_test (31) used greatest stack depth: 6388 bytes le=
ft
[   11.581635] cryptomgr_test (32) used greatest stack depth: 6316 bytes le=
ft
[   11.581635] cryptomgr_test (32) used greatest stack depth: 6316 bytes le=
ft
[   11.619786] alg: No test for crc32 (crc32-table)
[   11.619786] alg: No test for crc32 (crc32-table)
[   11.632656] alg: No test for lz4 (lz4-generic)
[   11.632656] alg: No test for lz4 (lz4-generic)
[   11.634369] alg: No test for stdrng (krng)
[   11.634369] alg: No test for stdrng (krng)
[   11.646379] NET: Registered protocol family 38
[   11.646379] NET: Registered protocol family 38
[   11.647884] Key type asymmetric registered
[   11.647884] Key type asymmetric registered
[   11.681733] list_sort_test: start testing list_sort()
[   11.681733] list_sort_test: start testing list_sort()
[   11.697769] test_string_helpers: Running tests...
[   11.697769] test_string_helpers: Running tests...
[   11.746936] crc32: CRC_LE_BITS =3D 1, CRC_BE BITS =3D 1
[   11.746936] crc32: CRC_LE_BITS =3D 1, CRC_BE BITS =3D 1
[   11.748494] crc32: self tests passed, processed 225944 bytes in 16371663=
 nsec
[   11.748494] crc32: self tests passed, processed 225944 bytes in 16371663=
 nsec
[   11.764934] crc32c: CRC_LE_BITS =3D 1
[   11.764934] crc32c: CRC_LE_BITS =3D 1
[   11.779304] crc32c: self tests passed, processed 225944 bytes in 1194910=
 nsec
[   11.779304] crc32c: self tests passed, processed 225944 bytes in 1194910=
 nsec
[   12.891161] tsc: Refined TSC clocksource calibration: 3300.265 MHz
[   12.891161] tsc: Refined TSC clocksource calibration: 3300.265 MHz
[   13.083776] crc32_combine: 8373 self tests passed
[   13.083776] crc32_combine: 8373 self tests passed
[   14.277275] crc32c_combine: 8373 self tests passed
[   14.277275] crc32c_combine: 8373 self tests passed
[   14.278902] rbtree testing
[   14.278902] rbtree testing -> 53808 cycles
 -> 53808 cycles
[   16.084162] augmented rbtree testing
[   16.084162] augmented rbtree testing -> 70342 cycles
 -> 70342 cycles
[   18.782005] ipmi message handler version 39.2
[   18.782005] ipmi message handler version 39.2
[   18.793198] ipmi device interface
[   18.793198] ipmi device interface
[   18.825554] IPMI System Interface driver.
[   18.825554] IPMI System Interface driver.
[   18.840626] ipmi_si: Adding default-specified kcs state machine
[   18.840626] ipmi_si: Adding default-specified kcs state machine

[   18.842443] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[   18.842443] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[   18.854448] ipmi_si: Interface detection failed
[   18.854448] ipmi_si: Interface detection failed
[   18.879285] ipmi_si: Adding default-specified smic state machine
[   18.879285] ipmi_si: Adding default-specified smic state machine

[   18.882147] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[   18.882147] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[   18.902178] ipmi_si: Interface detection failed
[   18.902178] ipmi_si: Interface detection failed
[   18.912310] ipmi_si: Adding default-specified bt state machine
[   18.912310] ipmi_si: Adding default-specified bt state machine

[   18.925150] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[   18.925150] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[   18.937738] ipmi_si: Interface detection failed
[   18.937738] ipmi_si: Interface detection failed
[   18.950176] ipmi_si: Unable to find any System Interface(s)
[   18.950176] ipmi_si: Unable to find any System Interface(s)
[   18.967787] IPMI Watchdog: driver initialized
[   18.967787] IPMI Watchdog: driver initialized
[   18.969083] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[   18.969083] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[   18.985264] IPMI poweroff: Unable to register powercycle sysctl
[   18.985264] IPMI poweroff: Unable to register powercycle sysctl
[   19.028267] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[   19.028267] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[   19.050795] ACPI: Power Button [PWRF]
[   19.050795] ACPI: Power Button [PWRF]
[   19.098977] isapnp: Scanning for PnP cards...
[   19.098977] isapnp: Scanning for PnP cards...
[   20.932205] isapnp: No Plug & Play device found
[   20.932205] isapnp: No Plug & Play device found
[   20.969527] HDLC line discipline maxframe=3D4096
[   20.969527] HDLC line discipline maxframe=3D4096
[   20.980249] N_HDLC line discipline registered.
[   20.980249] N_HDLC line discipline registered.
[   20.981680] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[   20.981680] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled

[   21.371261] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115=
200) is a 16550A
[   21.510046] serial: Freescale lpuart driver
[   21.510046] serial: Freescale lpuart driver
[   21.536531] Cyclades driver 2.6
[   21.536531] Cyclades driver 2.6
[   21.660928] MOXA Intellio family driver version 6.0k
[   21.660928] MOXA Intellio family driver version 6.0k
[   21.669450] MOXA Smartio/Industio family driver version 2.0.5
[   21.669450] MOXA Smartio/Industio family driver version 2.0.5
[   21.673957] RocketPort device driver module, version 2.09, 12-June-2003
[   21.673957] RocketPort device driver module, version 2.09, 12-June-2003
[   21.681307] No rocketport ports found; unloading driver
[   21.681307] No rocketport ports found; unloading driver
[   21.699441] DoubleTalk PC - not found
[   21.699441] DoubleTalk PC - not found
[   21.710109] Non-volatile memory driver v1.3
[   21.710109] Non-volatile memory driver v1.3
[   21.722313] ppdev: user-space parallel port driver
[   21.722313] ppdev: user-space parallel port driver
[   21.731296] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initial=
izing
[   21.731296] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initial=
izing
[   21.733497] platform pc8736x_gpio.0: no device found
[   21.733497] platform pc8736x_gpio.0: no device found
[   21.735502] nsc_gpio initializing
[   21.735502] nsc_gpio initializing
[   21.736561] smapi::smapi_init, ERROR invalid usSmapiID
[   21.736561] smapi::smapi_init, ERROR invalid usSmapiID
[   21.744141] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[   21.744141] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[   21.751118] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[   21.751118] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[   21.753481] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   21.753481] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   21.758866] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[   21.758866] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[   21.761580] Hangcheck: Using getrawmonotonic().
[   21.761580] Hangcheck: Using getrawmonotonic().
[   21.793934] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[   21.793934] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[   21.800478] c2port c2port0: C2 port uc added
[   21.800478] c2port c2port0: C2 port uc added
[   21.801761] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[   21.801761] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[   21.860965] HSI/SSI char device loaded
[   21.860965] HSI/SSI char device loaded
[   21.867961] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, =
2011)
[   21.867961] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, =
2011)
[   22.038600] w83977af_init()
[   22.038600] w83977af_init()
[   22.042474] w83977af_open()
[   22.042474] w83977af_open()
[   22.043350] w83977af_probe()
[   22.043350] w83977af_probe()
[   22.044397] w83977af_probe(), Wrong chip version
[   22.044397] w83977af_probe(), Wrong chip version

[   22.045823] w83977af_probe()
[   22.045823] w83977af_probe()
[   22.049699] w83977af_probe(), Wrong chip version
[   22.049699] w83977af_probe(), Wrong chip version

[   22.054554] irda_register_dongle : registering dongle "JetEye PC ESI-968=
0 PC" (1).
[   22.054554] irda_register_dongle : registering dongle "JetEye PC ESI-968=
0 PC" (1).
[   22.056998] irda_register_dongle : registering dongle "Actisys ACT-220L"=
 (2).
[   22.056998] irda_register_dongle : registering dongle "Actisys ACT-220L"=
 (2).
[   22.064598] irda_register_dongle : registering dongle "Actisys ACT-220L+=
" (3).
[   22.064598] irda_register_dongle : registering dongle "Actisys ACT-220L+=
" (3).
[   22.069568] irda_register_dongle : registering dongle "Parallax LiteLink=
" (5).
[   22.069568] irda_register_dongle : registering dongle "Parallax LiteLink=
" (5).
[   22.074456] irda_register_dongle : registering dongle "Greenwich GIrBIL"=
 (4).
[   22.074456] irda_register_dongle : registering dongle "Greenwich GIrBIL"=
 (4).
[   22.076786] irda_register_dongle : registering dongle "Microchip MCP2120=
" (9).
[   22.076786] irda_register_dongle : registering dongle "Microchip MCP2120=
" (9).
[   22.084730] irda_register_dongle : registering dongle "MA600" (11).
[   22.084730] irda_register_dongle : registering dongle "MA600" (11).
[   22.090846] irda_register_dongle : registering dongle "Vishay TOIM3232" =
(12).
[   22.090846] irda_register_dongle : registering dongle "Vishay TOIM3232" =
(12).
[   22.093044] PPP generic driver version 2.4.2
[   22.093044] PPP generic driver version 2.4.2
[   22.109605] PPP Deflate Compression module registered
[   22.109605] PPP Deflate Compression module registered
[   22.111305] NET: Registered protocol family 24
[   22.111305] NET: Registered protocol family 24
[   22.112709] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=
=3D256) (6 bit encapsulation enabled).
[   22.112709] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=
=3D256) (6 bit encapsulation enabled).
[   22.121322] SLIP linefill/keepalive option.
[   22.121322] SLIP linefill/keepalive option.
[   22.139182] Databook TCIC-2 PCMCIA probe:=20
[   22.139182] Databook TCIC-2 PCMCIA probe: not found.
not found.
[   22.148108] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[   22.148108] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[   22.157233] serio: i8042 KBD port at 0x60,0x64 irq 1
[   22.157233] serio: i8042 KBD port at 0x60,0x64 irq 1
[   22.165099] serio: i8042 AUX port at 0x60,0x64 irq 12
[   22.165099] serio: i8042 AUX port at 0x60,0x64 irq 12
[   22.195631] evbug: Connected device: input0 (Power Button at LNXPWRBN/bu=
tton/input0)
[   22.195631] evbug: Connected device: input0 (Power Button at LNXPWRBN/bu=
tton/input0)
[   22.288561] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[   22.288561] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[   22.309143] inport.c: Didn't find InPort mouse at 0x23c
[   22.309143] inport.c: Didn't find InPort mouse at 0x23c
[   22.324850] rtc_cmos 00:00: RTC can wake from S4
[   22.324850] rtc_cmos 00:00: RTC can wake from S4
[   22.393714] rtc (null): alarm rollover: day
[   22.393714] rtc (null): alarm rollover: day
[   22.401817] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[   22.401817] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[   22.404863] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[   22.404863] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[   22.420029] hpet1: lost 1 rtc interrupts
[   22.420029] hpet1: lost 1 rtc interrupts
[   22.471727] evbug: Connected device: input1 (AT Translated Set 2 keyboar=
d at isa0060/serio0/input0)
[   22.471727] evbug: Connected device: input1 (AT Translated Set 2 keyboar=
d at isa0060/serio0/input0)
[   22.665259] rtc-test rtc-test.0: rtc core: registered test as rtc1
[   22.665259] rtc-test rtc-test.0: rtc core: registered test as rtc1
[   22.689138] rtc-test rtc-test.1: rtc core: registered test as rtc2
[   22.689138] rtc-test rtc-test.1: rtc core: registered test as rtc2
[   22.700198] i2c /dev entries driver
[   22.700198] i2c /dev entries driver
[   22.760492] isa i2c-pca-isa.0: Please specify I/O base
[   22.760492] isa i2c-pca-isa.0: Please specify I/O base
[   22.795669] Registered IR keymap rc-empty
[   22.795669] Registered IR keymap rc-empty
[   22.821013] input: rc-core loopback device as /devices/virtual/rc/rc0/in=
put4
[   22.821013] input: rc-core loopback device as /devices/virtual/rc/rc0/in=
put4
[   22.839383] evbug: Connected device: input4 (rc-core loopback device at =
rc-core/virtual)
[   22.839383] evbug: Connected device: input4 (rc-core loopback device at =
rc-core/virtual)
[   22.853112] rc0: rc-core loopback device as /devices/virtual/rc/rc0
[   22.853112] rc0: rc-core loopback device as /devices/virtual/rc/rc0
[   22.864165] smssdio: Siano SMS1xxx SDIO driver
[   22.864165] smssdio: Siano SMS1xxx SDIO driver
[   22.865556] smssdio: Copyright Pierre Ossman
[   22.865556] smssdio: Copyright Pierre Ossman
[   22.900048] Colour QuickCam for Video4Linux v0.06
[   22.900048] Colour QuickCam for Video4Linux v0.06
[   22.901668] PMS: not enabled, use pms.enable=3D1 to probe
[   22.901668] PMS: not enabled, use pms.enable=3D1 to probe
[   22.911944] radio-rtrack2.0: you must set an I/O address with io=3D0x20f
[   22.911944] radio-rtrack2.0: you must set an I/O address with io=3D0x20f=
/0x30f/0x30f.
=2E
[   22.925650] radio-rtrack2: probe of radio-rtrack2.0 failed with error -22
[   22.925650] radio-rtrack2: probe of radio-rtrack2.0 failed with error -22
[   22.996523] radio-sf16fmi: no cards found
[   22.996523] radio-sf16fmi: no cards found
[   23.031229] radio-sf16fmr2: Unable to detect TEA575x tuner
[   23.031229] radio-sf16fmr2: Unable to detect TEA575x tuner
[   23.582136] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input3
[   23.582136] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input3
[   23.601048] evbug: Connected device: input3 (ImExPS/2 Generic Explorer M=
ouse at isa0060/serio1/input0)
[   23.601048] evbug: Connected device: input3 (ImExPS/2 Generic Explorer M=
ouse at isa0060/serio1/input0)
[   26.533675] radio-typhoon.0: Initialized radio card Typhoon Radio on por=
t 0x316
[   26.533675] radio-typhoon.0: Initialized radio card Typhoon Radio on por=
t 0x316
[   26.547971] radio-terratec.0: Initialized radio card TerraTec ActiveRadi=
o on port 0x590
[   26.547971] radio-terratec.0: Initialized radio card TerraTec ActiveRadi=
o on port 0x590
[   29.642467] radio-aimslab.0: Initialized radio card AIMSlab RadioTrack/R=
adioReveal on port 0x30f
[   29.642467] radio-aimslab.0: Initialized radio card AIMSlab RadioTrack/R=
adioReveal on port 0x30f
[   29.735894] radio-zoltrix.0: Initialized radio card Zoltrix Radio Plus o=
n port 0x20c
[   29.735894] radio-zoltrix.0: Initialized radio card Zoltrix Radio Plus o=
n port 0x20c
[   29.825372] radio-gemtek.0: Initialized radio card GemTek Radio on port =
0x34c
[   29.825372] radio-gemtek.0: Initialized radio card GemTek Radio on port =
0x34c
[   29.958241] radio-trust.0: Initialized radio card Trust FM Radio on port=
 0x350
[   29.958241] radio-trust.0: Initialized radio card Trust FM Radio on port=
 0x350
[   30.009639] pps pps0: new PPS source ktimer
[   30.009639] pps pps0: new PPS source ktimer
[   30.010998] pps pps0: ktimer PPS source registered
[   30.010998] pps pps0: ktimer PPS source registered
[   30.025334] pps_parport: parallel port PPS client
[   30.025334] pps_parport: parallel port PPS client
[   30.026868] Driver for 1-wire Dallas network protocol.
[   30.026868] Driver for 1-wire Dallas network protocol.
[   30.074961] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[   30.074961] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[   30.086187] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 20=
04-2005, Szabolcs Gyurko
[   30.086187] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 20=
04-2005, Szabolcs Gyurko
[   30.133921] power_supply test_ac: uevent
[   30.133921] power_supply test_ac: uevent
[   30.135228] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[   30.135228] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[   30.164630] power_supply test_ac: prop ONLINE=3D1
[   30.164630] power_supply test_ac: prop ONLINE=3D1
[   30.166082] power_supply test_ac: power_supply_changed
[   30.166082] power_supply test_ac: power_supply_changed
[   30.183950] power_supply test_ac: power_supply_changed_work
[   30.183950] power_supply test_ac: power_supply_changed_work
[   30.191765] power_supply test_ac: power_supply_update_gen_leds 1
[   30.191765] power_supply test_ac: power_supply_update_gen_leds 1
[   30.216666] power_supply test_ac: uevent
[   30.216666] power_supply test_ac: uevent
[   30.217898] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[   30.217898] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[   30.249063] power_supply test_battery: uevent
[   30.249063] power_supply test_battery: uevent
[   30.271475] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[   30.271475] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[   30.291702] power_supply test_ac: prop ONLINE=3D1
[   30.291702] power_supply test_ac: prop ONLINE=3D1
[   30.293288] power_supply test_battery: prop STATUS=3DDischarging
[   30.293288] power_supply test_battery: prop STATUS=3DDischarging
[   30.295258] power_supply test_battery: prop CHARGE_TYPE=3DFast
[   30.295258] power_supply test_battery: prop CHARGE_TYPE=3DFast
[   30.317322] power_supply test_battery: prop HEALTH=3DGood
[   30.317322] power_supply test_battery: prop HEALTH=3DGood
[   30.319041] power_supply test_battery: prop PRESENT=3D1
[   30.319041] power_supply test_battery: prop PRESENT=3D1
[   30.339640] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[   30.339640] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[   30.341338] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[   30.341338] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[   30.362279] power_supply test_battery: prop CHARGE_FULL=3D100
[   30.362279] power_supply test_battery: prop CHARGE_FULL=3D100
[   30.364028] power_supply test_battery: prop CHARGE_NOW=3D50
[   30.364028] power_supply test_battery: prop CHARGE_NOW=3D50
[   30.385872] power_supply test_battery: prop CAPACITY=3D50
[   30.385872] power_supply test_battery: prop CAPACITY=3D50
[   30.387571] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[   30.387571] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[   30.413130] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[   30.413130] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[   30.415041] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[   30.415041] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[   30.426065] power_supply test_battery: prop MODEL_NAME=3DTest battery
[   30.426065] power_supply test_battery: prop MODEL_NAME=3DTest battery
[   30.427957] power_supply test_battery: prop MANUFACTURER=3DLinux
[   30.427957] power_supply test_battery: prop MANUFACTURER=3DLinux
[   30.448574] power_supply test_battery: prop SERIAL_NUMBER=3D3.13.0-rc7-n=
ext-20140106-07462-gb4a839b
[   30.448574] power_supply test_battery: prop SERIAL_NUMBER=3D3.13.0-rc7-n=
ext-20140106-07462-gb4a839b
[   30.468351] power_supply test_battery: prop TEMP=3D26
[   30.468351] power_supply test_battery: prop TEMP=3D26
[   30.469784] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[   30.469784] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[   30.513191] power_supply test_battery: power_supply_changed
[   30.513191] power_supply test_battery: power_supply_changed
[   30.532672] power_supply test_battery: power_supply_changed_work
[   30.532672] power_supply test_battery: power_supply_changed_work
[   30.553947] power_supply test_battery: power_supply_update_bat_leds 2
[   30.553947] power_supply test_battery: power_supply_update_bat_leds 2
[   30.556006] power_supply test_battery: uevent
[   30.556006] power_supply test_battery: uevent
[   30.557350] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[   30.557350] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[   30.585301] power_supply test_usb: uevent
[   30.585301] power_supply test_usb: uevent
[   30.607940] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[   30.607940] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[   30.609836] power_supply test_battery: prop STATUS=3DDischarging
[   30.609836] power_supply test_battery: prop STATUS=3DDischarging
[   30.636154] power_supply test_battery: prop CHARGE_TYPE=3DFast
[   30.636154] power_supply test_battery: prop CHARGE_TYPE=3DFast
[   30.637935] power_supply test_battery: prop HEALTH=3DGood
[   30.637935] power_supply test_battery: prop HEALTH=3DGood
[   30.661632] power_supply test_battery: prop PRESENT=3D1
[   30.661632] power_supply test_battery: prop PRESENT=3D1
[   30.663094] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[   30.663094] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[   30.664846] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[   30.664846] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[   30.687837] power_supply test_battery: prop CHARGE_FULL=3D100
[   30.687837] power_supply test_battery: prop CHARGE_FULL=3D100
[   30.689498] power_supply test_battery: prop CHARGE_NOW=3D50
[   30.689498] power_supply test_battery: prop CHARGE_NOW=3D50
[   30.716388] power_supply test_battery: prop CAPACITY=3D50
[   30.716388] power_supply test_battery: prop CAPACITY=3D50
[   30.718004] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[   30.718004] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[   30.742958] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[   30.742958] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[   30.744981] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[   30.744981] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[   30.765577] power_supply test_battery: prop MODEL_NAME=3DTest battery
[   30.765577] power_supply test_battery: prop MODEL_NAME=3DTest battery
[   30.789550] power_supply test_battery: prop MANUFACTURER=3DLinux
[   30.789550] power_supply test_battery: prop MANUFACTURER=3DLinux
[   30.791314] power_supply test_battery: prop SERIAL_NUMBER=3D3.13.0-rc7-n=
ext-20140106-07462-gb4a839b
[   30.791314] power_supply test_battery: prop SERIAL_NUMBER=3D3.13.0-rc7-n=
ext-20140106-07462-gb4a839b
[   30.817328] power_supply test_battery: prop TEMP=3D26
[   30.817328] power_supply test_battery: prop TEMP=3D26
[   30.818858] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[   30.818858] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[   30.841694] power_supply test_usb: prop ONLINE=3D1
[   30.841694] power_supply test_usb: prop ONLINE=3D1
[   30.843112] power_supply test_usb: power_supply_changed
[   30.843112] power_supply test_usb: power_supply_changed
[   30.945772] w83781d: Detection failed at step 2
[   30.945772] w83781d: Detection failed at step 2
[   31.024234] applesmc: supported laptop not found!
[   31.024234] applesmc: supported laptop not found!
[   31.047859] applesmc: driver init failed (ret=3D-19)!
[   31.047859] applesmc: driver init failed (ret=3D-19)!
[   31.077554] f71882fg: Not a Fintek device
[   31.077554] f71882fg: Not a Fintek device
[   31.109033] f71882fg: Not a Fintek device
[   31.109033] f71882fg: Not a Fintek device
[   31.110706] power_supply test_usb: power_supply_changed_work
[   31.110706] power_supply test_usb: power_supply_changed_work
[   31.133667] power_supply test_usb: power_supply_update_gen_leds 1
[   31.133667] power_supply test_usb: power_supply_update_gen_leds 1
[   31.135573] power_supply test_usb: uevent
[   31.135573] power_supply test_usb: uevent
[   31.152775] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[   31.152775] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[   31.241858] power_supply test_usb: prop ONLINE=3D1
[   31.241858] power_supply test_usb: prop ONLINE=3D1
[   31.271055] pc87360: PC8736x not detected, module not inserted
[   31.271055] pc87360: PC8736x not detected, module not inserted
[   31.295659] sch56xx_common: Unsupported device id: 0xff
[   31.295659] sch56xx_common: Unsupported device id: 0xff
[   31.297258] sch56xx_common: Unsupported device id: 0xff
[   31.297258] sch56xx_common: Unsupported device id: 0xff
[   31.386856] mixcomwd: No card detected, or port not available
[   31.386856] mixcomwd: No card detected, or port not available
[   31.405924] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[   31.405924] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[   31.445928] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)
[   31.445928] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)
[   31.464997] sc520_wdt: cannot register miscdev on minor=3D130 (err=3D-16)
[   31.464997] sc520_wdt: cannot register miscdev on minor=3D130 (err=3D-16)
[   31.467193] ib700wdt: WDT driver for IB700 single board computer initial=
ising
[   31.467193] ib700wdt: WDT driver for IB700 single board computer initial=
ising
[   31.482260] ib700wdt: START method I/O 443 is not available
[   31.482260] ib700wdt: START method I/O 443 is not available
[   31.498056] ib700wdt: probe of ib700wdt failed with error -5
[   31.498056] ib700wdt: probe of ib700wdt failed with error -5
[   31.510232] wafer5823wdt: WDT driver for Wafer 5823 single board compute=
r initialising
[   31.510232] wafer5823wdt: WDT driver for Wafer 5823 single board compute=
r initialising
[   31.518621] wafer5823wdt: I/O address 0x0443 already in use
[   31.518621] wafer5823wdt: I/O address 0x0443 already in use
[   31.536628] it87_wdt: no device
[   31.536628] it87_wdt: no device
[   31.537883] sc1200wdt: build 20020303
[   31.537883] sc1200wdt: build 20020303
[   31.575711] sc1200wdt: io parameter must be specified
[   31.575711] sc1200wdt: io parameter must be specified
[   31.579703] pc87413_wdt: Version 1.1 at io 0x2E
[   31.579703] pc87413_wdt: Version 1.1 at io 0x2E
[   31.597318] pc87413_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[   31.597318] pc87413_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[   31.606308] sbc60xxwdt: I/O address 0x0443 already in use
[   31.606308] sbc60xxwdt: I/O address 0x0443 already in use
[   31.611708] sbc8360: failed to register misc device
[   31.611708] sbc8360: failed to register misc device
[   31.622341] sbc7240_wdt: I/O address 0x0443 already in use
[   31.622341] sbc7240_wdt: I/O address 0x0443 already in use
[   31.637386] cpu5wdt: misc_register failed
[   31.637386] cpu5wdt: misc_register failed
[   31.645315] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[   31.645315] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[   31.669824] smsc37b787_wdt: Unable to register miscdev on minor 130
[   31.669824] smsc37b787_wdt: Unable to register miscdev on minor 130
[   31.671729] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG=
/DHG Super I/O chip initialising
[   31.671729] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG=
/DHG Super I/O chip initialising
[   31.698637] w83627hf_wdt: Watchdog already running. Resetting timeout to=
 60 sec
[   31.698637] w83627hf_wdt: Watchdog already running. Resetting timeout to=
 60 sec
[   31.714706] watchdog: W83627HF Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[   31.714706] watchdog: W83627HF Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[   31.729379] watchdog: W83627HF Watchdog: a legacy watchdog module is pro=
bably present.
[   31.729379] watchdog: W83627HF Watchdog: a legacy watchdog module is pro=
bably present.
[   31.770293] w83627hf_wdt: initialized. timeout=3D60 sec (nowayout=3D0)
[   31.770293] w83627hf_wdt: initialized. timeout=3D60 sec (nowayout=3D0)
[   31.778945] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[   31.778945] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[   31.788930] w83697hf_wdt: watchdog not found at address 0x2e
[   31.788930] w83697hf_wdt: watchdog not found at address 0x2e
[   31.803237] w83697hf_wdt: No W83697HF/HG could be found
[   31.803237] w83697hf_wdt: No W83697HF/HG could be found
[   31.809994] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Sup=
er I/O chip initialising
[   31.809994] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Sup=
er I/O chip initialising
[   31.828436] w83697ug_wdt: No W83697UG/UF could be found
[   31.828436] w83697ug_wdt: No W83697UG/UF could be found
[   31.830020] w83877f_wdt: I/O address 0x0443 already in use
[   31.830020] w83877f_wdt: I/O address 0x0443 already in use
[   31.841628] machzwd: MachZ ZF-Logic Watchdog driver initializing
[   31.841628] machzwd: MachZ ZF-Logic Watchdog driver initializing
[   31.855600] machzwd: no ZF-Logic found
[   31.855600] machzwd: no ZF-Logic found
[   31.862794] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[   31.862794] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[   31.878572] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[   31.878572] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[   31.899635] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[   31.899635] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[   31.930645] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[   31.930645] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[   31.955675] Modular ISDN core version 1.1.29
[   31.955675] Modular ISDN core version 1.1.29
[   31.962848] NET: Registered protocol family 34
[   31.962848] NET: Registered protocol family 34
[   31.964396] DSP module 2.0
[   31.964396] DSP module 2.0
[   31.987348] mISDN_dsp: DSP clocks every 80 samples. This equals 3 jiffie=
s.
[   31.987348] mISDN_dsp: DSP clocks every 80 samples. This equals 3 jiffie=
s.
[   32.026124] mISDN: Layer-1-over-IP driver Rev. 2.00
[   32.026124] mISDN: Layer-1-over-IP driver Rev. 2.00
[   32.047261] 0 virtual devices registered
[   32.047261] 0 virtual devices registered
[   32.048495] gigaset: Driver for Gigaset 307x (debug build)
[   32.048495] gigaset: Driver for Gigaset 307x (debug build)
[   32.050283] gigaset: no ISDN subsystem interface
[   32.050283] gigaset: no ISDN subsystem interface
[   32.070755] platform eisa.0: Probing EISA bus 0
[   32.070755] platform eisa.0: Probing EISA bus 0
[   32.088365] lguest: mapped switcher at fffc8000
[   32.088365] lguest: mapped switcher at fffc8000
[   32.090122] cpufreq-nforce2: No nForce2 chipset.
[   32.090122] cpufreq-nforce2: No nForce2 chipset.
[   32.111193] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   32.111193] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   32.112981] wbsd: Copyright(c) Pierre Ossman
[   32.112981] wbsd: Copyright(c) Pierre Ossman
[   32.218602] ledtrig-cpu: registered to indicate activity on CPUs
[   32.218602] ledtrig-cpu: registered to indicate activity on CPUs
[   32.289073] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[   32.289073] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[   32.308889] hidraw: raw HID events driver (C) Jiri Kosina
[   32.308889] hidraw: raw HID events driver (C) Jiri Kosina
[   32.503018] hdaps: supported laptop not found!
[   32.503018] hdaps: supported laptop not found!
[   32.514495] hdaps: driver init failed (ret=3D-19)!
[   32.514495] hdaps: driver init failed (ret=3D-19)!
[   32.516137] drop_monitor: Initializing network drop monitor service
[   32.516137] drop_monitor: Initializing network drop monitor service
[   32.533183] NET: Registered protocol family 26
[   32.533183] NET: Registered protocol family 26
[   32.534544] Mirror/redirect action on
[   32.534544] Mirror/redirect action on
[   32.601122] u32 classifier
[   32.601122] u32 classifier
[   32.602034]     Actions configured
[   32.602034]     Actions configured
[   32.603251] Netfilter messages via NETLINK v0.30.
[   32.603251] Netfilter messages via NETLINK v0.30.
[   32.626577] nfnl_acct: registering with nfnetlink.
[   32.626577] nfnl_acct: registering with nfnetlink.
[   32.628199] nf_tables: (c) 2007-2009 Patrick McHardy <kaber@trash.net>
[   32.628199] nf_tables: (c) 2007-2009 Patrick McHardy <kaber@trash.net>
[   32.680704] ip_set: protocol 6
[   32.680704] ip_set: protocol 6
[   32.681665] IPVS: Registered protocols (TCP, UDP, ESP)
[   32.681665] IPVS: Registered protocols (TCP, UDP, ESP)
[   32.683275] IPVS: Connection hash table configured (size=3D4096, memory=
=3D32Kbytes)
[   32.683275] IPVS: Connection hash table configured (size=3D4096, memory=
=3D32Kbytes)
[   32.702661] IPVS: Each connection entry needs 256 bytes at least
[   32.702661] IPVS: Each connection entry needs 256 bytes at least
[   32.732253] IPVS: Creating netns size=3D1228 id=3D0
[   32.732253] IPVS: Creating netns size=3D1228 id=3D0
[   32.733949] IPVS: ipvs loaded.
[   32.733949] IPVS: ipvs loaded.
[   32.734940] IPVS: [rr] scheduler registered.
[   32.734940] IPVS: [rr] scheduler registered.
[   32.749354] IPVS: [lblc] scheduler registered.
[   32.749354] IPVS: [lblc] scheduler registered.
[   32.750902] IPVS: [lblcr] scheduler registered.
[   32.750902] IPVS: [lblcr] scheduler registered.
[   32.770918] IPVS: [dh] scheduler registered.
[   32.770918] IPVS: [dh] scheduler registered.
[   32.772249] IPVS: [sh] scheduler registered.
[   32.772249] IPVS: [sh] scheduler registered.
[   32.789907] IPVS: [nq] scheduler registered.
[   32.789907] IPVS: [nq] scheduler registered.
[   32.791221] ipip: IPv4 over IPv4 tunneling driver
[   32.791221] ipip: IPv4 over IPv4 tunneling driver
[   32.853233] gre: GRE over IPv4 demultiplexor driver
[   32.853233] gre: GRE over IPv4 demultiplexor driver
[   32.875501] ip_gre: GRE over IPv4 tunneling driver
[   32.875501] ip_gre: GRE over IPv4 tunneling driver
[   32.975564] arp_tables: (C) 2002 David S. Miller
[   32.975564] arp_tables: (C) 2002 David S. Miller
[   32.987603] TCP: cubic registered
[   32.987603] TCP: cubic registered
[   32.998751] Initializing XFRM netlink socket
[   32.998751] Initializing XFRM netlink socket
[   33.000143] NET: Registered protocol family 17
[   33.000143] NET: Registered protocol family 17
[   33.023787] NET: Registered protocol family 4
[   33.023787] NET: Registered protocol family 4
[   33.041674] NET: Registered protocol family 9
[   33.041674] NET: Registered protocol family 9
[   33.042959] X25: Linux Version 0.2
[   33.042959] X25: Linux Version 0.2
[   33.044018] can: controller area network core (rev 20120528 abi 9)
[   33.044018] can: controller area network core (rev 20120528 abi 9)
[   33.062467] NET: Registered protocol family 29
[   33.062467] NET: Registered protocol family 29
[   33.063814] can: netlink gateway (rev 20130117) max_hops=3D1
[   33.063814] can: netlink gateway (rev 20130117) max_hops=3D1
[   33.135733] NET: Registered protocol family 33
[   33.135733] NET: Registered protocol family 33
[   33.154557] Key type rxrpc registered
[   33.154557] Key type rxrpc registered
[   33.155684] Key type rxrpc_s registered
[   33.155684] Key type rxrpc_s registered
[   33.180812] RxRPC: Registered security type 2 'rxkad'
[   33.180812] RxRPC: Registered security type 2 'rxkad'
[   33.182610] l2tp_core: L2TP core driver, V2.0
[   33.182610] l2tp_core: L2TP core driver, V2.0
[   33.184083] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   33.184083] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   33.197802] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   33.197802] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   33.199486] l2tp_netlink: L2TP netlink interface
[   33.199486] l2tp_netlink: L2TP netlink interface
[   33.221996] l2tp_eth: L2TP ethernet pseudowire support (L2TPv3)
[   33.221996] l2tp_eth: L2TP ethernet pseudowire support (L2TPv3)
[   33.223759] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet=
 Project Team
[   33.223759] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet=
 Project Team
[   33.250931] DECnet: Routing cache hash table of 256 buckets, 11Kbytes
[   33.250931] DECnet: Routing cache hash table of 256 buckets, 11Kbytes
[   33.292500] NET: Registered protocol family 12
[   33.292500] NET: Registered protocol family 12
[   33.294256] 8021q: 802.1Q VLAN Support v1.8
[   33.294256] 8021q: 802.1Q VLAN Support v1.8
[   33.312619] DCCP: Activated CCID 2 (TCP-like)
[   33.312619] DCCP: Activated CCID 2 (TCP-like)
[   33.313908] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   33.313908] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   33.334966] sctp: Hash tables configured (established 1638 bind 1489)
[   33.334966] sctp: Hash tables configured (established 1638 bind 1489)
[   33.350120] rds_page_remainder_cpu_notify(): cpu 0 action 0x7
[   33.350120] rds_page_remainder_cpu_notify(): cpu 0 action 0x7
[   33.351938] Registered RDS/tcp transport
[   33.351938] Registered RDS/tcp transport
[   33.375217] lib80211: common routines for IEEE802.11 drivers
[   33.375217] lib80211: common routines for IEEE802.11 drivers
[   33.377105] lib80211_crypt: registered algorithm 'NULL'
[   33.377105] lib80211_crypt: registered algorithm 'NULL'
[   33.396031] lib80211_crypt: registered algorithm 'WEP'
[   33.396031] lib80211_crypt: registered algorithm 'WEP'
[   33.397611] lib80211_crypt: registered algorithm 'CCMP'
[   33.397611] lib80211_crypt: registered algorithm 'CCMP'
[   33.420284] lib80211_crypt: registered algorithm 'TKIP'
[   33.420284] lib80211_crypt: registered algorithm 'TKIP'
[   33.421800] tipc: Activated (version 2.0.0)
[   33.421800] tipc: Activated (version 2.0.0)
[   33.441798] NET: Registered protocol family 30
[   33.441798] NET: Registered protocol family 30
[   33.474145] tipc: Started in single node mode
[   33.474145] tipc: Started in single node mode
[   33.491659] 9pnet: Installing 9P2000 support
[   33.491659] 9pnet: Installing 9P2000 support
[   33.505201] NET: Registered protocol family 37
[   33.505201] NET: Registered protocol family 37
[   33.506762] NET: Registered protocol family 36
[   33.506762] NET: Registered protocol family 36
[   33.526595] Key type dns_resolver registered
[   33.526595] Key type dns_resolver registered
[   33.553538] batman_adv: B.A.T.M.A.N. advanced 2013.5.0 (compatibility ve=
rsion 15) loaded
[   33.553538] batman_adv: B.A.T.M.A.N. advanced 2013.5.0 (compatibility ve=
rsion 15) loaded
[   33.574382] openvswitch: Open vSwitch switching datapath
[   33.574382] openvswitch: Open vSwitch switching datapath
[   33.651022] Using IPI Shortcut mode
[   33.651022] Using IPI Shortcut mode
[   33.671908] bootconsole [earlyser0] disabled
[   33.671908] bootconsole [earlyser0] disabled
[   33.694170] Key type trusted registered
[   33.712241] Key type encrypted registered
[   33.756448] IMA: No TPM chip found, activating TPM-bypass!
[   33.897910] console [netcon0] enabled
[   33.898550] netconsole: network logging started
[   33.922520] rtc_cmos 00:00: setting system clock to 2014-01-07 09:02:21 =
UTC (1389085341)
[   33.923760] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   33.947453] EDD information not available.
[   33.961039] Freeing unused kernel memory: 752K (c1df2000 - c1eae000)

/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: No such file or directory

Please wait: booting...
Starting udev
/etc/rcS.d/S03udev: line 72: /proc/sys/kernel/hotplug: No such file or dire=
ctory
[   38.317637] power_supply test_ac: uevent
[   38.318303] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[   38.333856] power_supply test_ac: prop ONLINE=3D1
[   38.334717] power_supply test_battery: uevent
[   38.335341] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[   38.336354] power_supply test_battery: prop STATUS=3DDischarging
[   38.350084] power_supply test_battery: prop CHARGE_TYPE=3DFast
[   38.351002] power_supply test_battery: prop HEALTH=3DGood
[   38.351858] power_supply test_battery: prop PRESENT=3D1
[   38.367839] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[   38.368736] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[   38.369734] power_supply test_battery: prop CHARGE_FULL=3D100
[   38.370726] power_supply test_battery: prop CHARGE_NOW=3D50
[   38.384764] power_supply test_battery: prop CAPACITY=3D50
[   38.385571] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[   38.386445] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[   38.387337] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[   38.401114] power_supply test_battery: prop MODEL_NAME=3DTest battery
[   38.402059] power_supply test_battery: prop MANUFACTURER=3DLinux
[   38.402969] power_supply test_battery: prop SERIAL_NUMBER=3D3.13.0-rc7-n=
ext-20140106-07462-gb4a839b
[   38.418745] power_supply test_battery: prop TEMP=3D26
[   38.419568] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[   38.492968] power_supply test_usb: uevent
[   38.493641] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[   38.504270] power_supply test_usb: prop ONLINE=3D1
[   44.066779] power_supply test_ac: uevent
[   44.067471] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[   44.068378] power_supply test_ac: prop ONLINE=3D1
[   44.223848] power_supply test_battery: uevent
[   44.224622] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[   44.242683] power_supply test_battery: prop STATUS=3DDischarging
[   44.243728] power_supply test_battery: prop CHARGE_TYPE=3DFast
[   44.244566] power_supply test_battery: prop HEALTH=3DGood
[   44.251844] power_supply test_battery: prop PRESENT=3D1
[   44.252741] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[   44.263304] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[   44.274386] power_supply test_battery: prop CHARGE_FULL=3D100
[   44.275263] power_supply test_battery: prop CHARGE_NOW=3D50
[   44.276187] power_supply test_battery: prop CAPACITY=3D50
[   44.284614] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[   44.297451] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[   44.299742] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[   44.300651] power_supply test_battery: prop MODEL_NAME=3DTest battery
[   44.306860] power_supply test_battery: prop MANUFACTURER=3DLinux
[   44.307880] power_supply test_battery: prop SERIAL_NUMBER=3D3.13.0-rc7-n=
ext-20140106-07462-gb4a839b
[   44.320641] power_supply test_battery: prop TEMP=3D26
[   44.327629] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[   44.386685] power_supply test_ac: uevent
[   44.387469] power_supply test_ac: POWER_SUPPLY_NAME=3Dtest_ac
[   44.388323] power_supply test_ac: prop ONLINE=3D1
[   44.575444] power_supply test_battery: uevent
[   44.576174] power_supply test_battery: POWER_SUPPLY_NAME=3Dtest_battery
[   44.590169] power_supply test_battery: prop STATUS=3DDischarging
[   44.591033] power_supply test_battery: prop CHARGE_TYPE=3DFast
[   44.591880] power_supply test_battery: prop HEALTH=3DGood
[   44.592724] power_supply test_battery: prop PRESENT=3D1
[   44.607478] power_supply test_battery: prop TECHNOLOGY=3DLi-ion
[   44.608368] power_supply test_battery: prop CHARGE_FULL_DESIGN=3D100
[   44.618745] power_supply test_battery: prop CHARGE_FULL=3D100
[   44.619618] power_supply test_battery: prop CHARGE_NOW=3D50
[   44.620486] power_supply test_battery: prop CAPACITY=3D50
[   44.631720] power_supply test_battery: prop CAPACITY_LEVEL=3DNormal
[   44.632717] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3D3600
[   44.643531] power_supply test_battery: prop TIME_TO_FULL_NOW=3D3600
[   44.644518] power_supply test_battery: prop MODEL_NAME=3DTest battery
[   44.655250] power_supply test_battery: prop MANUFACTURER=3DLinux
[   44.656191] power_supply test_battery: prop SERIAL_NUMBER=3D3.13.0-rc7-n=
ext-20140106-07462-gb4a839b
[   44.670944] power_supply test_battery: prop TEMP=3D26
[   44.671744] power_supply test_battery: prop VOLTAGE_NOW=3D3300
[   44.844124] power_supply test_usb: uevent
[   44.850227] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[   44.967805] power_supply test_usb: prop ONLINE=3D1
[   45.331662] power_supply test_usb: uevent
[   45.332325] power_supply test_usb: POWER_SUPPLY_NAME=3Dtest_usb
[   45.446629] power_supply test_usb: prop ONLINE=3D1
Starting Bootlog daemon: bootlogd: cannot allocate pseudo tty: No such file=
 or directory
bootlogd.
[   50.987642] udevd (99) used greatest stack depth: 6196 bytes left
Configuring network interfaces... done.
hwclock: can't open '/dev/misc/rtc': No such file or directory
Running postinst /etc/rpm-postinsts/100...

wfg: skip syslogd
Kernel tests: Boot OK!
Kernel tests: Boot OK!
sed: /lib/modules/3.13.0-rc7-next-20140106-07462-gb4a839b/modules.dep: No s=
uch file or directory
xargs: modprobe: No such file or directory
run-parts: /etc/kernel-tests/01-modprobe exited with code 127
Trinity v1.0  Dave Jones <davej@redhat.com> 2012
Trinity v1.0  Dave Jones <davej@redhat.com> 2012
Trinity v1.0  Dave Jones <davej@redhat.com> 2012
No idea what syscall (get_robust_list) is.
Trinity v1.0  Dave Jones <davej@redhat.com> 2012
Don't run as root (or pass --dangerous if you know what you are doing).
No idea what syscall (get_robust_list) is.
Couldn't find socket cachefile. Regenerating.
fcntl F_WRLCK F_SETLKW: Permission denied
lsmod: can't open '/proc/modules': No such file or directory
BusyBox v1.19.4 (2012-04-22 09:22:10 PDT) multi-call binary.

Usage: rmmod [-wfa] [MODULE]...

lsmod: can't open '/proc/modules': No such file or directory
BusyBox v1.19.4 (2012-04-22 09:22:10 PDT) multi-call binary.

Usage: rmmod [-wfa] [MODULE]...

lsmod: can't open '/proc/modules': No such file or directory
BusyBox v1.19.4 (2012-04-22 09:22:10 PDT) multi-call binary.

Usage: rmmod [-wfa] [MODULE]...

run-parts: /etc/kernel-tests/99-rmmod exited with code 123


wfg: skip syslogd
Deconfiguring network interfaces... done.
Sending all processes the TERM signal...
Sending all processes the KILL signal...
Unmounting remote filesystems...
Deactivating swap...
Unmounting local filesystems...
Rebooting...=20
[  122.457724] Unregister pv shared memory for cpu 0
[  122.460529] reboot: Restarting system
[  122.461181] reboot: machine restart
Elapsed time: 135
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig-n=
h1-01070835/b4a839be48406e0e8bdec0bbc86db6f67df3d406/vmlinuz-3.13.0-rc7-nex=
t-20140106-07462-gb4a839b -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,=
115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10  prompt_ramdisk=
=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 r=
w link=3D/kernel-tests/run-queue/kvm/i386-randconfig-nh1-01070835/next:mast=
er/.vmlinuz-b4a839be48406e0e8bdec0bbc86db6f67df3d406-20140107090038-7-waime=
a branch=3Dnext/master BOOT_IMAGE=3D/kernel/i386-randconfig-nh1-01070835/b4=
a839be48406e0e8bdec0bbc86db6f67df3d406/vmlinuz-3.13.0-rc7-next-20140106-074=
62-gb4a839b'  -initrd /kernel-tests/initrd/yocto-minimal-i386.cgz -m 256M -=
smp 2 -net nic,vlan=3D1,model=3De1000 -net user,vlan=3D1,hostfwd=3Dtcp::122=
83-:22 -boot order=3Dnc -no-reboot -watchdog i6300esb -rtc base=3Dlocaltime=
 -soundhw hda -drive file=3D/fs/LABEL=3DKVM/disk0-yocto-waimea-8,media=3Ddi=
sk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk1-yocto-waimea-8,media=3Dd=
isk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk2-yocto-waimea-8,media=3D=
disk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk3-yocto-waimea-8,media=
=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk4-yocto-waimea-8,medi=
a=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk5-yocto-waimea-8,med=
ia=3Ddisk,if=3Dvirtio -pidfile /dev/shm/kboot/pid-yocto-waimea-8 -serial fi=
le:/dev/shm/kboot/serial-yocto-waimea-8 -daemonize -display none -monitor n=
ull=20

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.13.0-rc7-next-20140106-07462-gb4a839b"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.13.0-rc7 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
# CONFIG_ZONE_DMA32 is not set
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_KERNEL_LZ4=y
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SYSVIPC=y
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_FHANDLE is not set
CONFIG_AUDIT=y
# CONFIG_AUDITSYSCALL is not set

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_KTIME_SCALAR=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ=y
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_RCU_STALL_COMMON is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
CONFIG_MEMCG=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_NAMESPACES is not set
# CONFIG_UIDGID_STRICT_TYPE_CHECKS is not set
CONFIG_SCHED_AUTOGROUP=y
CONFIG_MM_OWNER=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
# CONFIG_RD_LZ4 is not set
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
# CONFIG_EPOLL is not set
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
# CONFIG_SHMEM is not set
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
CONFIG_UPROBES=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
# CONFIG_MODULES is not set
# CONFIG_BLOCK is not set
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_X86_32_IRIS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
CONFIG_LGUEST_GUEST=y
CONFIG_PARAVIRT_TIME_ACCOUNTING=y
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
CONFIG_MPENTIUM4=y
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_X86_GENERIC=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=7
CONFIG_X86_L1_CACHE_SHIFT=7
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=5
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
CONFIG_CPU_SUP_INTEL=y
# CONFIG_CPU_SUP_CYRIX_32 is not set
# CONFIG_CPU_SUP_AMD is not set
# CONFIG_CPU_SUP_CENTAUR is not set
# CONFIG_CPU_SUP_TRANSMETA_32 is not set
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_UP_APIC=y
# CONFIG_X86_UP_IOAPIC is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
# CONFIG_X86_ANCIENT_MCE is not set
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_VM86=y
# CONFIG_TOSHIBA is not set
# CONFIG_I8K is not set
CONFIG_X86_REBOOTFIXUPS=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_INTEL_LIB=y
CONFIG_MICROCODE_INTEL_EARLY=y
CONFIG_MICROCODE_AMD_EARLY=y
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_NOHIGHMEM is not set
# CONFIG_HIGHMEM4G is not set
CONFIG_HIGHMEM64G=y
CONFIG_VMSPLIT_3G=y
# CONFIG_VMSPLIT_2G is not set
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0xC0000000
CONFIG_HIGHMEM=y
CONFIG_X86_PAE=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
# CONFIG_TRANSPARENT_HUGEPAGE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
# CONFIG_ZBUD is not set
# CONFIG_ZSMALLOC is not set
CONFIG_HIGHPTE=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
# CONFIG_X86_PAT is not set
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
# CONFIG_SCHED_HRTICK is not set
# CONFIG_KEXEC is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_APEI is not set
# CONFIG_ACPI_EXTLOG is not set
CONFIG_SFI=y
CONFIG_X86_APM_BOOT=y
CONFIG_APM=y
CONFIG_APM_IGNORE_USER_SUSPEND=y
# CONFIG_APM_DO_ENABLE is not set
# CONFIG_APM_CPU_IDLE is not set
CONFIG_APM_DISPLAY_BLANK=y
# CONFIG_APM_ALLOW_INTS is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set

#
# x86 CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
CONFIG_X86_POWERNOW_K6=y
CONFIG_X86_POWERNOW_K7=y
CONFIG_X86_POWERNOW_K7_ACPI=y
# CONFIG_X86_GX_SUSPMOD is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_SPEEDSTEP_CENTRINO_TABLE=y
CONFIG_X86_SPEEDSTEP_ICH=y
# CONFIG_X86_SPEEDSTEP_SMI is not set
CONFIG_X86_P4_CLOCKMOD=y
CONFIG_X86_CPUFREQ_NFORCE2=y
# CONFIG_X86_LONGRUN is not set
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
# CONFIG_X86_SPEEDSTEP_RELAXED_CAP_CHECK is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
CONFIG_EISA=y
# CONFIG_EISA_VLB_PRIMING is not set
CONFIG_EISA_PCI_EISA=y
CONFIG_EISA_VIRTUAL_ROOT=y
CONFIG_EISA_NAMES=y
# CONFIG_SCx200 is not set
CONFIG_ALIX=y
# CONFIG_NET5501 is not set
CONFIG_GEOS=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_I82365 is not set
CONFIG_TCIC=y
CONFIG_PCMCIA_PROBE=y
CONFIG_PCCARD_NONSTATIC=y
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
# CONFIG_IP_ROUTE_VERBOSE is not set
CONFIG_IP_ROUTE_CLASSID=y
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=y
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IP_TUNNEL=y
CONFIG_NET_IPGRE=y
CONFIG_SYN_COOKIES=y
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
# CONFIG_INET_LRO is not set
# CONFIG_INET_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
# CONFIG_IPV6 is not set
# CONFIG_NETLABEL is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_ACCT=y
CONFIG_NETFILTER_NETLINK_QUEUE=y
# CONFIG_NETFILTER_NETLINK_LOG is not set
# CONFIG_NF_CONNTRACK is not set
CONFIG_NF_TABLES=y
# CONFIG_NFT_EXTHDR is not set
# CONFIG_NFT_META is not set
CONFIG_NFT_RBTREE=y
CONFIG_NFT_HASH=y
# CONFIG_NFT_COUNTER is not set
CONFIG_NFT_LOG=y
CONFIG_NFT_LIMIT=y
# CONFIG_NFT_COMPAT is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_SET=y

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=y
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
# CONFIG_NETFILTER_XT_TARGET_HMARK is not set
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
CONFIG_NETFILTER_XT_TARGET_LED=y
CONFIG_NETFILTER_XT_TARGET_LOG=y
CONFIG_NETFILTER_XT_TARGET_MARK=y
# CONFIG_NETFILTER_XT_TARGET_NFLOG is not set
# CONFIG_NETFILTER_XT_TARGET_NFQUEUE is not set
# CONFIG_NETFILTER_XT_TARGET_RATEEST is not set
CONFIG_NETFILTER_XT_TARGET_TEE=y
# CONFIG_NETFILTER_XT_TARGET_TCPMSS is not set

#
# Xtables matches
#
# CONFIG_NETFILTER_XT_MATCH_ADDRTYPE is not set
CONFIG_NETFILTER_XT_MATCH_BPF=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
# CONFIG_NETFILTER_XT_MATCH_CPU is not set
CONFIG_NETFILTER_XT_MATCH_DCCP=y
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=y
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ECN=y
# CONFIG_NETFILTER_XT_MATCH_ESP is not set
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
# CONFIG_NETFILTER_XT_MATCH_MAC is not set
# CONFIG_NETFILTER_XT_MATCH_MARK is not set
# CONFIG_NETFILTER_XT_MATCH_MULTIPORT is not set
CONFIG_NETFILTER_XT_MATCH_NFACCT=y
CONFIG_NETFILTER_XT_MATCH_OSF=y
# CONFIG_NETFILTER_XT_MATCH_OWNER is not set
CONFIG_NETFILTER_XT_MATCH_POLICY=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
# CONFIG_NETFILTER_XT_MATCH_RATEEST is not set
# CONFIG_NETFILTER_XT_MATCH_REALM is not set
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
CONFIG_NETFILTER_XT_MATCH_SOCKET=y
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
# CONFIG_NETFILTER_XT_MATCH_TIME is not set
CONFIG_NETFILTER_XT_MATCH_U32=y
CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
# CONFIG_IP_SET_BITMAP_IP is not set
CONFIG_IP_SET_BITMAP_IPMAC=y
CONFIG_IP_SET_BITMAP_PORT=y
# CONFIG_IP_SET_HASH_IP is not set
# CONFIG_IP_SET_HASH_IPPORT is not set
# CONFIG_IP_SET_HASH_IPPORTIP is not set
CONFIG_IP_SET_HASH_IPPORTNET=y
# CONFIG_IP_SET_HASH_NETPORTNET is not set
CONFIG_IP_SET_HASH_NET=y
CONFIG_IP_SET_HASH_NETNET=y
CONFIG_IP_SET_HASH_NETPORT=y
# CONFIG_IP_SET_HASH_NETIFACE is not set
CONFIG_IP_SET_LIST_SET=y
CONFIG_IP_VS=y
CONFIG_IP_VS_DEBUG=y
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
# CONFIG_IP_VS_PROTO_AH is not set
# CONFIG_IP_VS_PROTO_SCTP is not set

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=y
# CONFIG_IP_VS_WRR is not set
# CONFIG_IP_VS_LC is not set
# CONFIG_IP_VS_WLC is not set
CONFIG_IP_VS_LBLC=y
CONFIG_IP_VS_LBLCR=y
CONFIG_IP_VS_DH=y
CONFIG_IP_VS_SH=y
# CONFIG_IP_VS_SED is not set
CONFIG_IP_VS_NQ=y

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
# CONFIG_NF_TABLES_IPV4 is not set
CONFIG_NF_TABLES_ARP=y
# CONFIG_IP_NF_IPTABLES is not set
CONFIG_IP_NF_ARPTABLES=y
CONFIG_IP_NF_ARPFILTER=y
CONFIG_IP_NF_ARP_MANGLE=y

#
# DECnet: Netfilter Configuration
#
CONFIG_DECNET_NF_GRABULATOR=y
CONFIG_NF_TABLES_BRIDGE=y
CONFIG_IP_DCCP=y

#
# DCCP CCIDs Configuration
#
CONFIG_IP_DCCP_CCID2_DEBUG=y
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_IP_SCTP=y
# CONFIG_SCTP_DBG_OBJCNT is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
CONFIG_RDS=y
CONFIG_RDS_TCP=y
CONFIG_RDS_DEBUG=y
CONFIG_TIPC=y
CONFIG_TIPC_PORTS=8191
# CONFIG_ATM is not set
CONFIG_L2TP=y
# CONFIG_L2TP_DEBUGFS is not set
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=y
CONFIG_L2TP_ETH=y
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_TAG_DSA=y
CONFIG_NET_DSA_TAG_TRAILER=y
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
# CONFIG_VLAN_8021Q_MVRP is not set
CONFIG_DECNET=y
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_IPX=y
# CONFIG_IPX_INTERN is not set
# CONFIG_ATALK is not set
CONFIG_X25=y
CONFIG_LAPB=y
# CONFIG_PHONET is not set
CONFIG_IEEE802154=y
# CONFIG_MAC802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
# CONFIG_NET_SCH_HFSC is not set
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_MULTIQ=y
CONFIG_NET_SCH_RED=y
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
# CONFIG_NET_SCH_NETEM is not set
# CONFIG_NET_SCH_DRR is not set
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=y
# CONFIG_NET_SCH_QFQ is not set
CONFIG_NET_SCH_CODEL=y
CONFIG_NET_SCH_FQ_CODEL=y
CONFIG_NET_SCH_FQ=y
CONFIG_NET_SCH_HHF=y
CONFIG_NET_SCH_INGRESS=y
# CONFIG_NET_SCH_PLUG is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
# CONFIG_CLS_U32_PERF is not set
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=y
CONFIG_NET_CLS_FLOW=y
# CONFIG_NET_CLS_CGROUP is not set
CONFIG_NET_CLS_BPF=y
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=y
CONFIG_NET_EMATCH_NBYTE=y
# CONFIG_NET_EMATCH_U32 is not set
CONFIG_NET_EMATCH_META=y
CONFIG_NET_EMATCH_TEXT=y
CONFIG_NET_EMATCH_CANID=y
CONFIG_NET_EMATCH_IPSET=y
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
# CONFIG_NET_ACT_GACT is not set
CONFIG_NET_ACT_MIRRED=y
CONFIG_NET_ACT_NAT=y
# CONFIG_NET_ACT_PEDIT is not set
# CONFIG_NET_ACT_SIMP is not set
# CONFIG_NET_ACT_SKBEDIT is not set
CONFIG_NET_ACT_CSUM=y
# CONFIG_NET_CLS_IND is not set
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BLA=y
# CONFIG_BATMAN_ADV_DAT is not set
# CONFIG_BATMAN_ADV_NC is not set
# CONFIG_BATMAN_ADV_DEBUG is not set
CONFIG_OPENVSWITCH=y
CONFIG_OPENVSWITCH_GRE=y
# CONFIG_OPENVSWITCH_VXLAN is not set
CONFIG_VSOCKETS=y
CONFIG_NETLINK_MMAP=y
CONFIG_NETLINK_DIAG=y
# CONFIG_NET_MPLS_GSO is not set
CONFIG_HSR=y
CONFIG_NETPRIO_CGROUP=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
CONFIG_NET_DROP_MONITOR=y
# CONFIG_HAMRADIO is not set
CONFIG_CAN=y
# CONFIG_CAN_RAW is not set
# CONFIG_CAN_BCM is not set
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
# CONFIG_CAN_VCAN is not set
# CONFIG_CAN_SLCAN is not set
# CONFIG_CAN_DEV is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
CONFIG_IRNET=y
# CONFIG_IRCOMM is not set
CONFIG_IRDA_ULTRA=y

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
CONFIG_IRDA_FAST_RR=y
CONFIG_IRDA_DEBUG=y

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=y

#
# Dongle support
#
CONFIG_DONGLE=y
CONFIG_ESI_DONGLE=y
CONFIG_ACTISYS_DONGLE=y
# CONFIG_TEKRAM_DONGLE is not set
CONFIG_TOIM3232_DONGLE=y
CONFIG_LITELINK_DONGLE=y
CONFIG_MA600_DONGLE=y
CONFIG_GIRBIL_DONGLE=y
CONFIG_MCP2120_DONGLE=y
# CONFIG_OLD_BELKIN_DONGLE is not set
# CONFIG_ACT200L_DONGLE is not set

#
# FIR device drivers
#
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=y
# CONFIG_TOSHIBA_FIR is not set
# CONFIG_SMC_IRCC_FIR is not set
CONFIG_ALI_FIR=y
# CONFIG_VLSI_FIR is not set
CONFIG_VIA_FIR=y
# CONFIG_BT is not set
CONFIG_AF_RXRPC=y
CONFIG_AF_RXRPC_DEBUG=y
CONFIG_RXKAD=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_REG_DEBUG is not set
CONFIG_CFG80211_CERTIFICATION_ONUS=y
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
# CONFIG_CFG80211_WEXT is not set
CONFIG_LIB80211=y
CONFIG_LIB80211_CRYPT_WEP=y
CONFIG_LIB80211_CRYPT_CCMP=y
CONFIG_LIB80211_CRYPT_TKIP=y
CONFIG_LIB80211_DEBUG=y
# CONFIG_MAC80211 is not set
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
# CONFIG_RFKILL is not set
CONFIG_RFKILL_REGULATOR=y
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_NET_9P_DEBUG=y
CONFIG_CAIF=y
CONFIG_CAIF_DEBUG=y
CONFIG_CAIF_NETDEV=y
# CONFIG_CAIF_USB is not set
# CONFIG_CEPH_LIB is not set
CONFIG_NFC=y
CONFIG_NFC_DIGITAL=y
CONFIG_NFC_NCI=y
# CONFIG_NFC_NCI_SPI is not set
# CONFIG_NFC_HCI is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_SIM=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_FW_LOADER_USER_HELPER is not set
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
# CONFIG_DMA_SHARED_BUFFER is not set
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=16
CONFIG_CMA_SIZE_PERCENTAGE=10
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
CONFIG_CMA_SIZE_SEL_MAX=y
CONFIG_CMA_ALIGNMENT=8
CONFIG_CMA_AREAS=7

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
CONFIG_PARPORT=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
# CONFIG_PARPORT_1284 is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_ISAPNP=y
CONFIG_PNPBIOS=y
CONFIG_PNPBIOS_PROC_FS=y
CONFIG_PNPACPI=y

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
CONFIG_ATMEL_SSC=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
CONFIG_TI_DAC7512=y
CONFIG_VMWARE_BALLOON=y
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
CONFIG_BMP085_SPI=y
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
CONFIG_SRAM=y
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_AT25 is not set
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
# CONFIG_EEPROM_93CX6 is not set
CONFIG_EEPROM_93XX46=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
CONFIG_BONDING=y
CONFIG_DUMMY=y
# CONFIG_EQUALIZER is not set
CONFIG_IFB=y
# CONFIG_NET_TEAM is not set
CONFIG_MACVLAN=y
CONFIG_MACVTAP=y
CONFIG_VXLAN=y
CONFIG_NETCONSOLE=y
# CONFIG_NETCONSOLE_DYNAMIC is not set
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_TUN is not set
# CONFIG_VETH is not set
CONFIG_VIRTIO_NET=y
CONFIG_NLMON=y
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#
CONFIG_CAIF_TTY=y
CONFIG_CAIF_SPI_SLAVE=y
# CONFIG_CAIF_SPI_SYNC is not set
CONFIG_CAIF_HSI=y
CONFIG_CAIF_VIRTIO=y
# CONFIG_VHOST_NET is not set
CONFIG_VHOST_RING=y

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6XXX=y
CONFIG_NET_DSA_MV88E6060=y
CONFIG_NET_DSA_MV88E6XXX_NEED_PPU=y
CONFIG_NET_DSA_MV88E6131=y
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
# CONFIG_NET_VENDOR_3COM is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_NET_VENDOR_AMD is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
CONFIG_NET_CADENCE=y
# CONFIG_ARM_AT91_ETHER is not set
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=y
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_CALXEDA_XGMAC=y
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
# CONFIG_NET_VENDOR_CIRRUS is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
# CONFIG_DNET is not set
# CONFIG_NET_VENDOR_DEC is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
# CONFIG_NET_VENDOR_FUJITSU is not set
# CONFIG_NET_VENDOR_HP is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
# CONFIG_E1000 is not set
# CONFIG_E1000E is not set
# CONFIG_IGB is not set
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
# CONFIG_IXGBE is not set
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_IP1000 is not set
# CONFIG_JME is not set
# CONFIG_NET_VENDOR_MARVELL is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_MLX5_CORE is not set
CONFIG_NET_VENDOR_MICREL=y
CONFIG_KS8842=y
# CONFIG_KS8851 is not set
CONFIG_KS8851_MLL=y
# CONFIG_KSZ884X_PCI is not set
# CONFIG_NET_VENDOR_MICROCHIP is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_NET_VENDOR_REALTEK is not set
CONFIG_SH_ETH=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
# CONFIG_NET_VENDOR_SEEQ is not set
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
# CONFIG_SFC is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_SMC9194 is not set
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
# CONFIG_NET_VENDOR_STMICRO is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
CONFIG_WIZNET_W5300=y
# CONFIG_WIZNET_BUS_DIRECT is not set
# CONFIG_WIZNET_BUS_INDIRECT is not set
CONFIG_WIZNET_BUS_ANY=y
CONFIG_NET_VENDOR_XIRCOM=y
CONFIG_PCMCIA_XIRC2PS=y
CONFIG_FDDI=y
CONFIG_DEFXX=y
CONFIG_DEFXX_MMIO=y
# CONFIG_SKFP is not set
# CONFIG_HIPPI is not set
CONFIG_NET_SB1000=y
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
# CONFIG_AMD_PHY is not set
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
CONFIG_QSEMI_PHY=y
CONFIG_LXT_PHY=y
CONFIG_CICADA_PHY=y
CONFIG_VITESSE_PHY=y
# CONFIG_SMSC_PHY is not set
CONFIG_BROADCOM_PHY=y
# CONFIG_BCM87XX_PHY is not set
CONFIG_ICPLUS_PHY=y
CONFIG_REALTEK_PHY=y
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
CONFIG_MICREL_PHY=y
# CONFIG_FIXED_PHY is not set
CONFIG_MDIO_BITBANG=y
# CONFIG_MDIO_GPIO is not set
# CONFIG_MICREL_KS8995MA is not set
CONFIG_PLIP=y
CONFIG_PPP=y
# CONFIG_PPP_BSDCOMP is not set
CONFIG_PPP_DEFLATE=y
CONFIG_PPP_FILTER=y
# CONFIG_PPP_MPPE is not set
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOE=y
# CONFIG_PPTP is not set
CONFIG_PPPOL2TP=y
# CONFIG_PPP_ASYNC is not set
# CONFIG_PPP_SYNC_TTY is not set
CONFIG_SLIP=y
CONFIG_SLHC=y
# CONFIG_SLIP_COMPRESSED is not set
CONFIG_SLIP_SMART=y
CONFIG_SLIP_MODE_SLIP6=y
CONFIG_WLAN=y
CONFIG_PCMCIA_RAYCS=y
# CONFIG_AIRO is not set
CONFIG_ATMEL=y
# CONFIG_PCI_ATMEL is not set
CONFIG_PCMCIA_ATMEL=y
# CONFIG_AIRO_CS is not set
CONFIG_PCMCIA_WL3501=y
# CONFIG_PRISM54 is not set
CONFIG_ATH_CARDS=y
CONFIG_ATH_DEBUG=y
# CONFIG_ATH_REG_DYNAMIC_USER_REG_HINTS is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_ATH6KL=y
CONFIG_ATH6KL_SDIO=y
# CONFIG_ATH6KL_DEBUG is not set
CONFIG_ATH6KL_TRACING=y
# CONFIG_ATH6KL_REGDOMAIN is not set
# CONFIG_WIL6210 is not set
CONFIG_BRCMUTIL=y
CONFIG_BRCMFMAC=y
# CONFIG_BRCMFMAC_SDIO is not set
CONFIG_BRCM_TRACING=y
CONFIG_BRCMDBG=y
CONFIG_HOSTAP=y
CONFIG_HOSTAP_FIRMWARE=y
# CONFIG_HOSTAP_FIRMWARE_NVRAM is not set
# CONFIG_HOSTAP_PLX is not set
# CONFIG_HOSTAP_PCI is not set
CONFIG_HOSTAP_CS=y
# CONFIG_IPW2100 is not set
# CONFIG_LIBERTAS is not set
CONFIG_WL_TI=y
CONFIG_MWIFIEX=y
CONFIG_MWIFIEX_SDIO=y
# CONFIG_MWIFIEX_PCIE is not set

#
# WiMAX Wireless Broadband devices
#

#
# Enable USB support to see WiMAX USB drivers
#
# CONFIG_WAN is not set
CONFIG_IEEE802154_DRIVERS=y
# CONFIG_IEEE802154_FAKEHARD is not set
# CONFIG_VMXNET3 is not set
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
# CONFIG_ISDN_CAPI is not set
CONFIG_ISDN_DRV_GIGASET=y
CONFIG_GIGASET_DUMMYLL=y
CONFIG_GIGASET_M101=y
CONFIG_GIGASET_DEBUG=y
CONFIG_MISDN=y
CONFIG_MISDN_DSP=y
CONFIG_MISDN_L1OIP=y

#
# mISDN hardware drivers
#
# CONFIG_MISDN_HFCPCI is not set
# CONFIG_MISDN_HFCMULTI is not set
# CONFIG_MISDN_AVMFRITZ is not set
# CONFIG_MISDN_SPEEDFAX is not set
# CONFIG_MISDN_INFINEON is not set
# CONFIG_MISDN_W6692 is not set
# CONFIG_MISDN_NETJET is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
CONFIG_INPUT_JOYDEV=y
# CONFIG_INPUT_EVDEV is not set
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5520=y
CONFIG_KEYBOARD_ADP5588=y
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
CONFIG_KEYBOARD_GPIO=y
CONFIG_KEYBOARD_GPIO_POLLED=y
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
# CONFIG_KEYBOARD_NEWTON is not set
CONFIG_KEYBOARD_OPENCORES=y
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_KEYBOARD_SUNKBD=y
# CONFIG_KEYBOARD_STMPE is not set
CONFIG_KEYBOARD_TC3589X=y
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
# CONFIG_MOUSE_PS2_SYNAPTICS is not set
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
# CONFIG_MOUSE_PS2_TRACKPOINT is not set
CONFIG_MOUSE_PS2_ELANTECH=y
# CONFIG_MOUSE_PS2_SENTELIC is not set
CONFIG_MOUSE_PS2_TOUCHKIT=y
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
CONFIG_MOUSE_CYAPA=y
CONFIG_MOUSE_INPORT=y
CONFIG_MOUSE_ATIXL=y
# CONFIG_MOUSE_LOGIBM is not set
CONFIG_MOUSE_PC110PAD=y
CONFIG_MOUSE_VSXXXAA=y
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=y
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
# CONFIG_TABLET_USB_ACECAD is not set
# CONFIG_TABLET_USB_AIPTEK is not set
# CONFIG_TABLET_USB_HANWANG is not set
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_WACOM is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
# CONFIG_UNIX98_PTYS is not set
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
CONFIG_CYCLADES=y
# CONFIG_CYZ_INTR is not set
CONFIG_MOXA_INTELLIO=y
CONFIG_MOXA_SMARTIO=y
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
CONFIG_N_GSM=y
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
# CONFIG_SERIAL_8250_PNP is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
# CONFIG_SERIAL_8250_DMA is not set
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
# CONFIG_SERIAL_8250_SHARE_IRQ is not set
CONFIG_SERIAL_8250_DETECT_IRQ=y
# CONFIG_SERIAL_8250_RSA is not set
CONFIG_SERIAL_8250_DW=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=y
CONFIG_SERIAL_FSL_LPUART_CONSOLE=y
CONFIG_TTY_PRINTK=y
# CONFIG_PRINTER is not set
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PANIC_EVENT=y
# CONFIG_IPMI_PANIC_STRING is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
# CONFIG_HW_RANDOM_VIA is not set
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=y
CONFIG_NVRAM=y
CONFIG_DTLK=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
CONFIG_IPWIRELESS=y
CONFIG_MWAVE=y
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_ATMEL=y
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=y
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
CONFIG_TCG_ST33_I2C=y
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
# CONFIG_I2C_MUX_PCA9541 is not set
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

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
# CONFIG_I2C_ISMT is not set
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
CONFIG_I2C_CBUS_GPIO=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_GPIO=y
# CONFIG_I2C_KEMPLD is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_ELEKTOR=y
CONFIG_I2C_PCA_ISA=y
# CONFIG_SCx200_ACB is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
CONFIG_SPI_GPIO=y
CONFIG_SPI_LM70_LLP=y
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_SC18IS602 is not set
# CONFIG_SPI_TOPCLIFF_PCH is not set
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI clients
#
CONFIG_HSI_CHAR=y

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_IT8761E=y
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_SCH311X=y
CONFIG_GPIO_TS5500=y
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_ARIZONA is not set
CONFIG_GPIO_LP3943=y
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_RC5T583=y
CONFIG_GPIO_SX150X=y
CONFIG_GPIO_STMPE=y
# CONFIG_GPIO_TC3589X is not set
CONFIG_GPIO_TPS65912=y
# CONFIG_GPIO_TWL6040 is not set
CONFIG_GPIO_WM831X=y
# CONFIG_GPIO_WM8350 is not set
# CONFIG_GPIO_ADP5520 is not set
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_INTEL_MID is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MCP23S08=y
CONFIG_GPIO_MC33880=y

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#
CONFIG_GPIO_KEMPLD=y

#
# MODULbus GPIO expanders:
#
# CONFIG_GPIO_TPS6586X is not set

#
# USB GPIO expanders:
#
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
CONFIG_W1_SLAVE_DS2413=y
# CONFIG_W1_SLAVE_DS2423 is not set
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
# CONFIG_PDA_POWER is not set
# CONFIG_WM831X_BACKUP is not set
CONFIG_WM831X_POWER=y
CONFIG_WM8350_POWER=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_88PM860X=y
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
CONFIG_BATTERY_BQ27x00=y
CONFIG_BATTERY_BQ27X00_I2C=y
CONFIG_BATTERY_BQ27X00_PLATFORM=y
CONFIG_BATTERY_DA9030=y
# CONFIG_BATTERY_MAX17040 is not set
CONFIG_BATTERY_MAX17042=y
# CONFIG_CHARGER_88PM860X is not set
CONFIG_CHARGER_PCF50633=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_MAX14577=y
# CONFIG_CHARGER_MAX8998 is not set
# CONFIG_CHARGER_BQ2415X is not set
CONFIG_CHARGER_BQ24190=y
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_SMB347=y
CONFIG_POWER_RESET=y
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
CONFIG_SENSORS_ABITUGURU3=y
CONFIG_SENSORS_AD7314=y
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_ADM1021=y
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=y
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_HTU21=y
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_LINEAGE=y
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM70 is not set
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_LM25066=y
CONFIG_SENSORS_LTC2978=y
CONFIG_SENSORS_MAX16064=y
# CONFIG_SENSORS_MAX34440 is not set
CONFIG_SENSORS_MAX8688=y
CONFIG_SENSORS_UCD9000=y
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_DME1737=y
# CONFIG_SENSORS_EMC1403 is not set
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
# CONFIG_SENSORS_SCH5627 is not set
CONFIG_SENSORS_SCH5636=y
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
# CONFIG_SENSORS_INA2XX is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y
CONFIG_SENSORS_WM8350=y
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_MC13783_ADC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
CONFIG_X86_PKG_TEMP_THERMAL=y
# CONFIG_ACPI_INT3403_THERMAL is not set

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_WM831X_WATCHDOG=y
# CONFIG_WM8350_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
CONFIG_SC520_WDT=y
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
# CONFIG_IBMASR is not set
CONFIG_WAFER_WDT=y
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
# CONFIG_HP_WATCHDOG is not set
CONFIG_KEMPLD_WDT=y
CONFIG_SC1200_WDT=y
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
CONFIG_60XX_WDT=y
CONFIG_SBC8360_WDT=y
CONFIG_SBC7240_WDT=y
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
CONFIG_W83697HF_WDT=y
CONFIG_W83697UG_WDT=y
CONFIG_W83877F_WDT=y
# CONFIG_W83977F_WDT is not set
CONFIG_MACHZ_WDT=y
CONFIG_SBC_EPX_C3_WATCHDOG=y
CONFIG_MEN_A21_WDT=y

#
# ISA-based Watchdog Cards
#
# CONFIG_PCWATCHDOG is not set
CONFIG_MIXCOMWD=y
# CONFIG_WDT is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_SILENT is not set
CONFIG_SSB_DEBUG=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
CONFIG_BCMA_DRIVER_GPIO=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
CONFIG_PMIC_DA903X=y
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9063=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
# CONFIG_EZX_PCAP is not set
# CONFIG_MFD_RETU is not set
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SMSC=y
CONFIG_ABX500_CORE=y
# CONFIG_AB3100_CORE is not set
CONFIG_MFD_STMPE=y

#
# STMicroelectronics STMPE Interface Drivers
#
# CONFIG_STMPE_I2C is not set
CONFIG_STMPE_SPI=y
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TIMBERDALE is not set
CONFIG_MFD_TC3589X=y
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
CONFIG_MFD_WM5102=y
CONFIG_MFD_WM5110=y
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM831X_SPI=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PM800=y
# CONFIG_REGULATOR_88PM8607 is not set
# CONFIG_REGULATOR_ACT8865 is not set
# CONFIG_REGULATOR_AD5398 is not set
# CONFIG_REGULATOR_ANATOP is not set
CONFIG_REGULATOR_DA903X=y
# CONFIG_REGULATOR_DA9063 is not set
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=y
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
# CONFIG_REGULATOR_MAX8907 is not set
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8973=y
CONFIG_REGULATOR_MAX8998=y
CONFIG_REGULATOR_MAX77693=y
# CONFIG_REGULATOR_MC13783 is not set
# CONFIG_REGULATOR_MC13892 is not set
CONFIG_REGULATOR_PCF50633=y
# CONFIG_REGULATOR_PFUZE100 is not set
# CONFIG_REGULATOR_RC5T583 is not set
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
# CONFIG_REGULATOR_TPS62360 is not set
# CONFIG_REGULATOR_TPS65023 is not set
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65217=y
# CONFIG_REGULATOR_TPS6524X is not set
# CONFIG_REGULATOR_TPS6586X is not set
CONFIG_REGULATOR_TPS65912=y
# CONFIG_REGULATOR_WM831X is not set
# CONFIG_REGULATOR_WM8350 is not set
CONFIG_REGULATOR_WM8400=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
CONFIG_MEDIA_RC_SUPPORT=y
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_DVB_CORE=y
CONFIG_DVB_NET=y
# CONFIG_TTPCI_EEPROM is not set
CONFIG_DVB_MAX_ADAPTERS=8
# CONFIG_DVB_DYNAMIC_MINORS is not set

#
# Media drivers
#
CONFIG_RC_CORE=y
CONFIG_RC_MAP=y
# CONFIG_RC_DECODERS is not set
CONFIG_RC_DEVICES=y
# CONFIG_RC_ATI_REMOTE is not set
# CONFIG_IR_ENE is not set
# CONFIG_IR_IMON is not set
# CONFIG_IR_MCEUSB is not set
CONFIG_IR_ITE_CIR=y
CONFIG_IR_FINTEK=y
# CONFIG_IR_NUVOTON is not set
# CONFIG_IR_REDRAT3 is not set
# CONFIG_IR_STREAMZAP is not set
CONFIG_IR_WINBOND_CIR=y
# CONFIG_IR_IGUANA is not set
# CONFIG_IR_TTUSBIR is not set
CONFIG_RC_LOOPBACK=y
CONFIG_IR_GPIO_CIR=y
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
# CONFIG_V4L_TEST_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=y
CONFIG_MEDIA_PARPORT_SUPPORT=y
# CONFIG_VIDEO_BWQCAM is not set
CONFIG_VIDEO_CQCAM=y
CONFIG_VIDEO_PMS=y
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=y
CONFIG_RADIO_SI470X=y
# CONFIG_I2C_SI470X is not set
CONFIG_RADIO_SI4713=y
CONFIG_PLATFORM_SI4713=y
CONFIG_I2C_SI4713=y
# CONFIG_RADIO_MAXIRADIO is not set
CONFIG_RADIO_TEA5764=y
# CONFIG_RADIO_TEA5764_XTAL is not set
# CONFIG_RADIO_SAA7706H is not set
# CONFIG_RADIO_TEF6862 is not set
CONFIG_RADIO_WL1273=y

#
# Texas Instruments WL128x FM driver (ST based)
#
CONFIG_V4L_RADIO_ISA_DRIVERS=y
CONFIG_RADIO_ISA=y
CONFIG_RADIO_CADET=y
CONFIG_RADIO_RTRACK=y
CONFIG_RADIO_RTRACK_PORT=30f
CONFIG_RADIO_RTRACK2=y
CONFIG_RADIO_RTRACK2_PORT=30c
# CONFIG_RADIO_AZTECH is not set
CONFIG_RADIO_GEMTEK=y
CONFIG_RADIO_GEMTEK_PORT=34c
# CONFIG_RADIO_GEMTEK_PROBE is not set
CONFIG_RADIO_SF16FMI=y
CONFIG_RADIO_SF16FMR2=y
CONFIG_RADIO_TERRATEC=y
CONFIG_RADIO_TRUST=y
CONFIG_RADIO_TRUST_PORT=350
CONFIG_RADIO_TYPHOON=y
CONFIG_RADIO_TYPHOON_PORT=316
CONFIG_RADIO_TYPHOON_MUTEFREQ=87500
CONFIG_RADIO_ZOLTRIX=y
CONFIG_RADIO_ZOLTRIX_PORT=20c
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_SMS_SIANO_MDTV=y
# CONFIG_SMS_SIANO_RC is not set

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_VIDEO_IR_I2C=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Multistandard (satellite) frontends
#

#
# Multistandard (cable + terrestrial) frontends
#

#
# DVB-S (satellite) frontends
#

#
# DVB-T (terrestrial) frontends
#

#
# DVB-C (cable) frontends
#

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#

#
# ISDB-T (terrestrial) frontends
#

#
# Digital terrestrial only tuners/PLL
#

#
# SEC control devices for DVB-S
#

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
# CONFIG_FB_DDC is not set
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_VESA=y
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
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
# CONFIG_FB_GEODE is not set
# CONFIG_FB_TMIO is not set
CONFIG_FB_GOLDFISH=y
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
CONFIG_FB_AUO_K190X=y
CONFIG_FB_AUO_K1900=y
# CONFIG_FB_AUO_K1901 is not set
# CONFIG_FB_SIMPLE is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_L4F00242T03=y
CONFIG_LCD_LMS283GF05=y
# CONFIG_LCD_LTV350QV is not set
CONFIG_LCD_ILI922X=y
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
CONFIG_LCD_S6E63M0=y
CONFIG_LCD_LD9040=y
CONFIG_LCD_AMS369FG06=y
CONFIG_LCD_LMS501KF03=y
# CONFIG_LCD_HX8357 is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_DA903X=y
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
CONFIG_BACKLIGHT_WM831X=y
# CONFIG_BACKLIGHT_ADP5520 is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=y
# CONFIG_BACKLIGHT_88PM860X is not set
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_LM3630A=y
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
# CONFIG_BACKLIGHT_LP8788 is not set
CONFIG_BACKLIGHT_TPS65217=y
CONFIG_BACKLIGHT_GPIO=y
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
# CONFIG_SND is not set
CONFIG_SOUND_PRIME=y
# CONFIG_SOUND_MSNDCLAS is not set
# CONFIG_SOUND_MSNDPIN is not set
# CONFIG_SOUND_OSS is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
CONFIG_UHID=y
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
CONFIG_HID_ACRUX_FF=y
CONFIG_HID_APPLE=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_CYPRESS is not set
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=y
# CONFIG_HID_ELECOM is not set
CONFIG_HID_EZKEY=y
CONFIG_HID_KEYTOUCH=y
# CONFIG_HID_KYE is not set
CONFIG_HID_UCLOGIC=y
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_TWINHAN=y
# CONFIG_HID_KENSINGTON is not set
CONFIG_HID_LCPOWER=y
# CONFIG_HID_LENOVO_TPKBD is not set
CONFIG_HID_LOGITECH=y
# CONFIG_HID_LOGITECH_DJ is not set
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_LOGIG940_FF=y
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PRIMAX=y
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
# CONFIG_HID_GREENASIA is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THINGM=y
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=y

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_SAMSUNG_USB2PHY is not set
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
CONFIG_MMC_UNSAFE_RESUME=y
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
# CONFIG_SDIO_UART is not set
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_SDRICOH_CS is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_88PM860X is not set
CONFIG_LEDS_LM3530=y
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
# CONFIG_LEDS_LP8788 is not set
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA963X is not set
CONFIG_LEDS_PCA9685=y
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_WM8350=y
# CONFIG_LEDS_DA903X is not set
# CONFIG_LEDS_DAC124S085 is not set
CONFIG_LEDS_REGULATOR=y
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_INTEL_SS4200 is not set
# CONFIG_LEDS_LT3593 is not set
CONFIG_LEDS_ADP5520=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
CONFIG_EDAC_DEBUG=y
CONFIG_EDAC_MM_EDAC=y
# CONFIG_EDAC_AMD76X is not set
# CONFIG_EDAC_E7XXX is not set
# CONFIG_EDAC_E752X is not set
# CONFIG_EDAC_I82875P is not set
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_I3200 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I7CORE is not set
# CONFIG_EDAC_I82860 is not set
# CONFIG_EDAC_R82600 is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
# CONFIG_RTC_SYSTOHC is not set
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
CONFIG_RTC_INTF_PROC=y
# CONFIG_RTC_INTF_DEV is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM860X=y
CONFIG_RTC_DRV_88PM80X=y
CONFIG_RTC_DRV_DS1307=y
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
CONFIG_RTC_DRV_DS3232=y
CONFIG_RTC_DRV_LP8788=y
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8907=y
CONFIG_RTC_DRV_MAX8998=y
# CONFIG_RTC_DRV_RS5C372 is not set
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=y
CONFIG_RTC_DRV_ISL12057=y
# CONFIG_RTC_DRV_X1205 is not set
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_PCF8523=y
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
CONFIG_RTC_DRV_M41T80_WDT=y
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_TPS6586X=y
# CONFIG_RTC_DRV_RC5T583 is not set
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
# CONFIG_RTC_DRV_RX8025 is not set
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV3029C2=y

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=y
# CONFIG_RTC_DRV_M41T94 is not set
# CONFIG_RTC_DRV_DS1305 is not set
CONFIG_RTC_DRV_DS1390=y
CONFIG_RTC_DRV_MAX6902=y
# CONFIG_RTC_DRV_R9701 is not set
CONFIG_RTC_DRV_RS5C348=y
CONFIG_RTC_DRV_DS3234=y
CONFIG_RTC_DRV_PCF2123=y
CONFIG_RTC_DRV_RX4581=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_STK17TA8=y
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=y
# CONFIG_RTC_DRV_M48T59 is not set
CONFIG_RTC_DRV_MSM6242=y
# CONFIG_RTC_DRV_BQ4802 is not set
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
# CONFIG_RTC_DRV_DS2404 is not set
# CONFIG_RTC_DRV_WM831X is not set
# CONFIG_RTC_DRV_WM8350 is not set
# CONFIG_RTC_DRV_PCF50633 is not set

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_MC13XXX=y
CONFIG_RTC_DRV_MOXART=y

#
# HID Sensor RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
# CONFIG_INTEL_IOATDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_MF624 is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_LAPTOP=y
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_CHROME_PLATFORMS is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_GPIO is not set
CONFIG_EXTCON_MAX77693=y
CONFIG_MEMORY=y
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
CONFIG_SERIAL_IPOCTAL=y
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_EXYNOS_MIPI_VIDEO=y
CONFIG_BCM_KONA_USB2_PHY=y
# CONFIG_POWERCAP is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
# CONFIG_FIRMWARE_MEMMAP is not set
# CONFIG_DELL_RBU is not set
CONFIG_DCDBAS=y
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
# CONFIG_GOOGLE_SMI is not set
CONFIG_GOOGLE_MEMCONSOLE=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_FS_POSIX_ACL is not set
# CONFIG_FILE_LOCKING is not set
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
# CONFIG_PRINT_QUOTA_WARNING is not set
# CONFIG_QUOTA_DEBUG is not set
# CONFIG_QFMT_V1 is not set
# CONFIG_QFMT_V2 is not set
CONFIG_QUOTACTL=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
CONFIG_FSCACHE_OBJECT_LIST=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
# CONFIG_PROC_VMCORE is not set
# CONFIG_PROC_SYSCTL is not set
# CONFIG_PROC_PAGE_MONITOR is not set
CONFIG_SYSFS=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=y
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
# CONFIG_NLS_ISO8859_1 is not set
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
# CONFIG_NLS_ISO8859_5 is not set
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
CONFIG_DLM=y
# CONFIG_DLM_DEBUG is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_DEBUG_HIGHMEM=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
# CONFIG_TIMER_STATS is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_WRITECOUNT=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP is not set
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
CONFIG_PROFILE_ANNOTATED_BRANCHES=y
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_TRACING_BRANCHES=y
CONFIG_BRANCH_TRACER=y
# CONFIG_STACK_TRACER is not set
CONFIG_UPROBE_EVENT=y
CONFIG_PROBE_EVENTS=y
# CONFIG_DYNAMIC_FTRACE is not set
CONFIG_FUNCTION_PROFILER=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_RING_BUFFER_BENCHMARK=y
# CONFIG_RING_BUFFER_STARTUP_TEST is not set

#
# Runtime Testing
#
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_TEST_STRING_HELPERS=y
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_DMA_API_DEBUG=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA is not set
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEYS_DEBUG_PROC_KEYS=y
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
CONFIG_SECURITY_PATH=y
# CONFIG_SECURITY_SELINUX is not set
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1
# CONFIG_SECURITY_APPARMOR_HASH is not set
CONFIG_SECURITY_YAMA=y
# CONFIG_SECURITY_YAMA_STACKED is not set
CONFIG_INTEGRITY=y
# CONFIG_INTEGRITY_SIGNATURE is not set
CONFIG_INTEGRITY_AUDIT=y
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
# CONFIG_IMA_TEMPLATE is not set
CONFIG_IMA_NG_TEMPLATE=y
# CONFIG_IMA_SIG_TEMPLATE is not set
CONFIG_IMA_DEFAULT_TEMPLATE="ima-ng"
CONFIG_IMA_DEFAULT_HASH_SHA1=y
# CONFIG_IMA_DEFAULT_HASH_SHA256 is not set
# CONFIG_IMA_DEFAULT_HASH_SHA512 is not set
CONFIG_IMA_DEFAULT_HASH="sha1"
CONFIG_IMA_APPRAISE=y
CONFIG_EVM=y
CONFIG_EVM_HMAC_VERSION=2
# CONFIG_DEFAULT_SECURITY_APPARMOR is not set
CONFIG_DEFAULT_SECURITY_YAMA=y
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="yama"
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_586 is not set
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_SALSA20_586=y
# CONFIG_CRYPTO_SEED is not set
# CONFIG_CRYPTO_SERPENT is not set
# CONFIG_CRYPTO_SERPENT_SSE2_586 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
# CONFIG_CRYPTO_LZO is not set
CONFIG_CRYPTO_LZ4=y
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_CRYPTO_DEV_GEODE is not set
# CONFIG_CRYPTO_DEV_CCP is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
# CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE is not set
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
CONFIG_LGUEST=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_PERCPU_RWSEM=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
# CONFIG_CRC64_ECMA is not set
CONFIG_AUDIT_GENERIC=y
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
# CONFIG_XZ_DEC is not set
# CONFIG_XZ_DEC_BCJ is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
CONFIG_MPILIB=y

--jI8keyz6grp/JLjh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
