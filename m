Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 775D86B00B8
	for <linux-mm@kvack.org>; Wed,  5 Mar 2014 08:38:33 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id kl14so1101554pab.32
        for <linux-mm@kvack.org>; Wed, 05 Mar 2014 05:38:33 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id ub8si2440278pac.213.2014.03.05.05.38.30
        for <linux-mm@kvack.org>;
        Wed, 05 Mar 2014 05:38:32 -0800 (PST)
Date: Wed, 5 Mar 2014 21:38:21 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [gbefb] WARNING: CPU: 1 PID: 1 at lib/dma-debug.c:1041 check_unmap()
Message-ID: <20140305133821.GA11657@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="3V7upXqbjpZ4EhLz"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Russell King <rmk@dyn-67.arm.linux.org.uk>


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got the below dmesg and the first bad commit is

commit c060f943d0929f3e429c5d9522290584f6281d6e
Author:     Laura Abbott <lauraa@codeaurora.org>
AuthorDate: Fri Jan 11 14:31:51 2013 -0800
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Fri Jan 11 14:54:55 2013 -0800

    mm: use aligned zone start for pfn_to_bitidx calculation
    

[    7.951495] gbefb: couldn't allocate framebuffer memory
[    7.952974] ------------[ cut here ]------------
[    7.952974] ------------[ cut here ]------------
[    7.954307] WARNING: CPU: 1 PID: 1 at lib/dma-debug.c:1041 check_unmap+0x126/0x702()

git bisect start v3.8 v3.7 --
git bisect good 8d91a42e54eebc43f4d8f6064751ccba73528275  # 12:16     30+     10  Merge tag 'omap-late-cleanups' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
git bisect  bad 910ffdb18a6408e14febbb6e4b6840fd2c928c82  # 12:21      0-     11  ptrace: introduce signal_wake_up_state() and ptrace_signal_wake_up()
git bisect good bfbbd96c51b441b7a9a08762aa9ab832f6655b2c  # 12:29     30+     12  audit: fix auditfilter.c kernel-doc warnings
git bisect  bad a6d3bd274b85218bf7dda925d14db81e1a8268b3  # 12:35      0-     22  Merge tag 'arm64-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/cmarinas/linux-aarch64
git bisect  bad 3441f0d26d02ec8073ea9ac7d1a4da8a9818ad59  # 12:41      0-      2  Merge tag 'driver-core-3.8-rc3' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core
git bisect  bad c727b4c63c9bf33c65351bbcc738161edb444b24  # 12:45      0-      4  Merge branch 'akpm' (incoming fixes from Andrew)
git bisect good 47ecfcb7d01418fcbfbc75183ba5e28e98b667b2  # 12:54     30+     12  mm: compaction: Partially revert capture of suitable high-order page
git bisect good 52b820d917c7c8c1b2ddec2f0ac165b67267feec  # 12:58     30+      9  Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/linux
git bisect good 93ccb3910ae3dbff6d224aecd22d8eece3d70ce9  # 13:01     30+     16  Merge tag 'nfs-for-3.8-3' of git://git.linux-nfs.org/projects/trondmy/linux-nfs
git bisect  bad 1b963c81b14509e330e0fe3218b645ece2738dc5  # 13:08      0-      5  lockdep, rwsem: provide down_write_nest_lock()
git bisect good c0232ae861df679092c15960b6cd9f589d9b7177  # 13:23     30+      9  mm: memblock: fix wrong memmove size in memblock_merge_regions()
git bisect  bad c060f943d0929f3e429c5d9522290584f6281d6e  # 13:26      0-     10  mm: use aligned zone start for pfn_to_bitidx calculation
git bisect good 6d92d4f6a74766cc885b18218268e0c47fbca399  # 13:31     30+      8  fs/exec.c: work around icc miscompilation
# first bad commit: [c060f943d0929f3e429c5d9522290584f6281d6e] mm: use aligned zone start for pfn_to_bitidx calculation
git bisect good 6d92d4f6a74766cc885b18218268e0c47fbca399  # 13:36     90+     52  fs/exec.c: work around icc miscompilation
git bisect  bad 0964c4d936f53872725d96bb04d490a70aa1165a  # 13:37      0-     17  0day head guard for 'devel-hourly-2014022108'
git bisect  bad dbf1b162bc9a01d93fa2d2ab3e8e064528575516  # 13:41     76-     14  Revert "mm: use aligned zone start for pfn_to_bitidx calculation"
git bisect  bad d158fc7f36a25e19791d25a55da5623399a2644f  # 13:45      2-      7  Merge tag 'pci-v3.14-fixes-1' of git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci
git bisect  bad 12f1d94f0c8b256c04cb9b6b5dd989c32e44f11b  # 13:46      0-      8  Add linux-next specific files for 20140220

Thanks,
Fengguang

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-stoakley-5:20140221091816:i386-randconfig-st0-02210812:3.14.0-rc3-wl-01929-g0964c4d:4"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc3-wl-01929-g0964c4d (kbuild@stoakley)=
 (gcc version 4.8.1 (Debian 4.8.1-8) ) #4 SMP Fri Feb 21 09:14:47 CST 2014
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013ffdfff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013ffe000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x1000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdac0-0x000fdacf] mapped at =
[c00fdac0]
[    0.000000]   mpc: fdad0-fdbec
[    0.000000] initial memory mapped: [mem 0x00000000-0x025fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12400000-0x125fffff]
[    0.000000]  [mem 0x12400000-0x125fffff] page 4k
[    0.000000] BRK [0x0206b000, 0x0206bfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x10000000-0x123fffff]
[    0.000000]  [mem 0x10000000-0x123fffff] page 4k
[    0.000000] BRK [0x0206c000, 0x0206cfff] PGTABLE
[    0.000000] BRK [0x0206d000, 0x0206dfff] PGTABLE
[    0.000000] BRK [0x0206e000, 0x0206efff] PGTABLE
[    0.000000] BRK [0x0206f000, 0x0206ffff] PGTABLE
[    0.000000] BRK [0x02070000, 0x02070fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x0fffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12600000-0x13ffdfff]
[    0.000000]  [mem 0x12600000-0x13ffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x127ab000-0x13feffff]
[    0.000000] ACPI: RSDP 0x000FD930 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x13FFE450 000034 (v01 BOCHS  BXPCRSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACP 0x13FFFF80 000074 (v01 BOCHS  BXPCFACP 00000001 B=
XPC 00000001)
[    0.000000] ACPI: DSDT 0x13FFE490 0011A9 (v01 BXPC   BXDSDT   00000001 I=
NTL 20100528)
[    0.000000] ACPI: FACS 0x13FFFF40 000040
[    0.000000] ACPI: SSDT 0x13FFF7A0 000796 (v01 BOCHS  BXPCSSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: APIC 0x13FFF680 000080 (v01 BOCHS  BXPCAPIC 00000001 B=
XPC 00000001)
[    0.000000] ACPI: HPET 0x13FFF640 000038 (v01 BOCHS  BXPCHPET 00000001 B=
XPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x0000000013ffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x13ffdfff]
[    0.000000]   NODE_DATA [mem 0x13ffc000-0x13ffdfff]
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 319MB LOWMEM available.
[    0.000000] max_low_pfn =3D 13ffe, highstart_pfn =3D 13ffe
[    0.000000] Low memory ends at vaddr d3ffe000
[    0.000000] High memory starts at vaddr d3ffe000
[    0.000000]   mapped low ram: 0 - 13ffe000
[    0.000000]   low ram: 0 - 13ffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13ffb001, boot clock
[    0.000000] Node: 0, start_pfn: 1, end_pfn: 9f
[    0.000000]   Setting physnode_map array to node 0 for pfns:
[    0.000000]   0=20
[    0.000000] Node: 0, start_pfn: 100, end_pfn: 13ffe
[    0.000000]   Setting physnode_map array to node 0 for pfns:
[    0.000000]   0 4000 8000 c000 10000=20
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x13ffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000] free_area_init_node: node 0, pgdat d3ffc000, node_mem_map d2=
259028
[    0.000000]   DMA zone: 40 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 760 pages used for memmap
[    0.000000]   Normal zone: 77822 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_no=
de_ids:1
[    0.000000] PERCPU: Embedded 10 pages/cpu @d2797000 s27776 r0 d13184 u40=
960
[    0.000000] pcpu-alloc: s27776 r0 d13184 u40960 alloc=3D10*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:13ffb001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 127997c0
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 81020
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/k=
vm/i386-randconfig-st0-02210812/linux-devel:devel-hourly-2014022108/.vmlinu=
z-0964c4d936f53872725d96bb04d490a70aa1165a-20140221091456-9-stoakley branch=
=3Dlinux-devel/devel-hourly-2014022108 BOOT_IMAGE=3D/kernel/i386-randconfig=
-st0-02210812/0964c4d936f53872725d96bb04d490a70aa1165a/vmlinuz-3.14.0-rc3-w=
l-01929-g0964c4d
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 281264K/327280K available (6250K kernel code, 795K r=
wdata, 3332K rodata, 380K init, 5960K bss, 46016K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffe6a000 - 0xfffff000   (1620 kB)
[    0.000000]     pkmap   : 0xffa00000 - 0xffc00000   (2048 kB)
[    0.000000]     vmalloc : 0xd47fe000 - 0xff9fe000   ( 690 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xd3ffe000   ( 319 MB)
[    0.000000]       .init : 0xc1a24000 - 0xc1a83000   ( 380 kB)
[    0.000000]       .data : 0xc161acdd - 0xc1a23c40   (4131 kB)
[    0.000000]       .text : 0xc1000000 - 0xc161acdd   (6251 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D2
[    0.000000] NR_IRQS:2304 nr_irqs:512 16
[    0.000000] CPU 0 irqstacks, hard=3Dd1c1a000 soft=3Dd1c1c000
[    0.000000] ACPI: Core revision 20140114
[    0.000000] ACPI: All ACPI Tables successfully acquired
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc3-wl-01929-g0964c4d (kbuild@stoakley)=
 (gcc version 4.8.1 (Debian 4.8.1-8) ) #4 SMP Fri Feb 21 09:14:47 CST 2014
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013ffdfff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013ffe000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x1000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdac0-0x000fdacf] mapped at =
[c00fdac0]
[    0.000000]   mpc: fdad0-fdbec
[    0.000000] initial memory mapped: [mem 0x00000000-0x025fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12400000-0x125fffff]
[    0.000000]  [mem 0x12400000-0x125fffff] page 4k
[    0.000000] BRK [0x0206b000, 0x0206bfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x10000000-0x123fffff]
[    0.000000]  [mem 0x10000000-0x123fffff] page 4k
[    0.000000] BRK [0x0206c000, 0x0206cfff] PGTABLE
[    0.000000] BRK [0x0206d000, 0x0206dfff] PGTABLE
[    0.000000] BRK [0x0206e000, 0x0206efff] PGTABLE
[    0.000000] BRK [0x0206f000, 0x0206ffff] PGTABLE
[    0.000000] BRK [0x02070000, 0x02070fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x0fffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12600000-0x13ffdfff]
[    0.000000]  [mem 0x12600000-0x13ffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x127ab000-0x13feffff]
[    0.000000] ACPI: RSDP 0x000FD930 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x13FFE450 000034 (v01 BOCHS  BXPCRSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACP 0x13FFFF80 000074 (v01 BOCHS  BXPCFACP 00000001 B=
XPC 00000001)
[    0.000000] ACPI: DSDT 0x13FFE490 0011A9 (v01 BXPC   BXDSDT   00000001 I=
NTL 20100528)
[    0.000000] ACPI: FACS 0x13FFFF40 000040
[    0.000000] ACPI: SSDT 0x13FFF7A0 000796 (v01 BOCHS  BXPCSSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: APIC 0x13FFF680 000080 (v01 BOCHS  BXPCAPIC 00000001 B=
XPC 00000001)
[    0.000000] ACPI: HPET 0x13FFF640 000038 (v01 BOCHS  BXPCHPET 00000001 B=
XPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x0000000013ffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x13ffdfff]
[    0.000000]   NODE_DATA [mem 0x13ffc000-0x13ffdfff]
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 319MB LOWMEM available.
[    0.000000] max_low_pfn =3D 13ffe, highstart_pfn =3D 13ffe
[    0.000000] Low memory ends at vaddr d3ffe000
[    0.000000] High memory starts at vaddr d3ffe000
[    0.000000]   mapped low ram: 0 - 13ffe000
[    0.000000]   low ram: 0 - 13ffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13ffb001, boot clock
[    0.000000] Node: 0, start_pfn: 1, end_pfn: 9f
[    0.000000]   Setting physnode_map array to node 0 for pfns:
[    0.000000]   0=20
[    0.000000] Node: 0, start_pfn: 100, end_pfn: 13ffe
[    0.000000]   Setting physnode_map array to node 0 for pfns:
[    0.000000]   0 4000 8000 c000 10000=20
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x13ffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000] free_area_init_node: node 0, pgdat d3ffc000, node_mem_map d2=
259028
[    0.000000]   DMA zone: 40 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 760 pages used for memmap
[    0.000000]   Normal zone: 77822 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_no=
de_ids:1
[    0.000000] PERCPU: Embedded 10 pages/cpu @d2797000 s27776 r0 d13184 u40=
960
[    0.000000] pcpu-alloc: s27776 r0 d13184 u40960 alloc=3D10*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:13ffb001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 127997c0
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 81020
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/k=
vm/i386-randconfig-st0-02210812/linux-devel:devel-hourly-2014022108/.vmlinu=
z-0964c4d936f53872725d96bb04d490a70aa1165a-20140221091456-9-stoakley branch=
=3Dlinux-devel/devel-hourly-2014022108 BOOT_IMAGE=3D/kernel/i386-randconfig=
-st0-02210812/0964c4d936f53872725d96bb04d490a70aa1165a/vmlinuz-3.14.0-rc3-w=
l-01929-g0964c4d
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 281264K/327280K available (6250K kernel code, 795K r=
wdata, 3332K rodata, 380K init, 5960K bss, 46016K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffe6a000 - 0xfffff000   (1620 kB)
[    0.000000]     pkmap   : 0xffa00000 - 0xffc00000   (2048 kB)
[    0.000000]     vmalloc : 0xd47fe000 - 0xff9fe000   ( 690 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xd3ffe000   ( 319 MB)
[    0.000000]       .init : 0xc1a24000 - 0xc1a83000   ( 380 kB)
[    0.000000]       .data : 0xc161acdd - 0xc1a23c40   (4131 kB)
[    0.000000]       .text : 0xc1000000 - 0xc161acdd   (6251 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D2
[    0.000000] NR_IRQS:2304 nr_irqs:512 16
[    0.000000] CPU 0 irqstacks, hard=3Dd1c1a000 soft=3Dd1c1c000
[    0.000000] ACPI: Core revision 20140114
[    0.000000] ACPI: All ACPI Tables successfully acquired
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
[    0.000000]  memory used by lock dependency info: 3567 kB
[    0.000000]  memory used by lock dependency info: 3567 kB
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000] ODEBUG: 15 of 15 active objects replaced
[    0.000000] ODEBUG: 15 of 15 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2833.124 MHz processor
[    0.000000] tsc: Detected 2833.124 MHz processor
[    0.003000] Calibrating delay loop (skipped) preset value..=20
[    0.003000] Calibrating delay loop (skipped) preset value.. 5666.24 Bogo=
MIPS (lpj=3D2833124)
5666.24 BogoMIPS (lpj=3D2833124)
[    0.004007] pid_max: default: 32768 minimum: 301
[    0.004007] pid_max: default: 32768 minimum: 301
[    0.007939] Security Framework initialized
[    0.007939] Security Framework initialized
[    0.009246] Mount-cache hash table entries: 512
[    0.009246] Mount-cache hash table entries: 512
[    0.018000] Initializing cgroup subsys debug
[    0.018000] Initializing cgroup subsys debug
[    0.018017] Initializing cgroup subsys perf_event
[    0.018017] Initializing cgroup subsys perf_event
[    0.019451] mce: CPU supports 10 MCE banks
[    0.019451] mce: CPU supports 10 MCE banks
[    0.021157] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.021157] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.021157] tlb_flushall_shift: 6
[    0.021157] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.021157] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.021157] tlb_flushall_shift: 6
[    0.023364] debug: unmapping init [mem 0xc1a83000-0xc1a85fff]
[    0.023364] debug: unmapping init [mem 0xc1a83000-0xc1a85fff]
[    0.027731] Getting VERSION: 50014
[    0.027731] Getting VERSION: 50014
[    0.029010] Getting VERSION: 50014
[    0.029010] Getting VERSION: 50014
[    0.030000] Getting ID: 0
[    0.030000] Getting ID: 0
[    0.030021] Getting ID: f000000
[    0.030021] Getting ID: f000000
[    0.031017] Getting LVT0: 8700
[    0.031017] Getting LVT0: 8700
[    0.032011] Getting LVT1: 8400
[    0.032011] Getting LVT1: 8400
[    0.033007] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.033007] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.034100] enabled ExtINT on CPU#0
[    0.034100] enabled ExtINT on CPU#0
[    0.036707] ENABLING IO-APIC IRQs
[    0.036707] ENABLING IO-APIC IRQs
[    0.037011] init IO_APIC IRQs
[    0.037011] init IO_APIC IRQs
[    0.038006]  apic 0 pin 0 not connected
[    0.038006]  apic 0 pin 0 not connected
[    0.039028] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.039028] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.040031] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.040031] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.041033] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.041033] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.042034] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.042034] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.043033] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.043033] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.044026] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.044026] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.045028] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.045028] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.046026] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.046026] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.047027] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.047027] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.048027] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.048027] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.049026] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.049026] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.050028] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.050028] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.051067] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.051067] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.053007] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.053007] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.054027] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.054027] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.055023]  apic 0 pin 16 not connected
[    0.055023]  apic 0 pin 16 not connected
[    0.056003]  apic 0 pin 17 not connected
[    0.056003]  apic 0 pin 17 not connected
[    0.057004]  apic 0 pin 18 not connected
[    0.057004]  apic 0 pin 18 not connected
[    0.058003]  apic 0 pin 19 not connected
[    0.058003]  apic 0 pin 19 not connected
[    0.059003]  apic 0 pin 20 not connected
[    0.059003]  apic 0 pin 20 not connected
[    0.060003]  apic 0 pin 21 not connected
[    0.060003]  apic 0 pin 21 not connected
[    0.061003]  apic 0 pin 22 not connected
[    0.061003]  apic 0 pin 22 not connected
[    0.062003]  apic 0 pin 23 not connected
[    0.062003]  apic 0 pin 23 not connected
[    0.063159] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.063159] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.064004] smpboot: CPU0:=20
[    0.064004] smpboot: CPU0: Intel Intel Common KVM processorCommon KVM pr=
ocessor (fam: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.067004] Using local APIC timer interrupts.
[    0.067004] calibrating APIC timer ...
[    0.067004] Using local APIC timer interrupts.
[    0.067004] calibrating APIC timer ...
[    0.069000] ... lapic delta =3D 6312530
[    0.069000] ... lapic delta =3D 6312530
[    0.069000] ... PM-Timer delta =3D 361565
[    0.069000] ... PM-Timer delta =3D 361565
[    0.069000] APIC calibration not consistent with PM-Timer: 101ms instead=
 of 100ms
[    0.069000] APIC calibration not consistent with PM-Timer: 101ms instead=
 of 100ms
[    0.069000] APIC delta adjusted to PM-Timer: 6249485 (6312530)
[    0.069000] APIC delta adjusted to PM-Timer: 6249485 (6312530)
[    0.069000] TSC delta adjusted to PM-Timer: 283332018 (286190240)
[    0.069000] TSC delta adjusted to PM-Timer: 283332018 (286190240)
[    0.069000] ..... delta 6249485
[    0.069000] ..... delta 6249485
[    0.069000] ..... mult: 268413336
[    0.069000] ..... mult: 268413336
[    0.069000] ..... calibration result: 999917
[    0.069000] ..... calibration result: 999917
[    0.069000] ..... CPU clock speed is 2833.0320 MHz.
[    0.069000] ..... CPU clock speed is 2833.0320 MHz.
[    0.069000] ..... host bus clock speed is 999.0917 MHz.
[    0.069000] ..... host bus clock speed is 999.0917 MHz.
[    0.069164] Performance Events:=20
[    0.069164] Performance Events: unsupported Netburst CPU model 6 unsuppo=
rted Netburst CPU model 6 no PMU driver, software events only.
no PMU driver, software events only.
[    0.092911] CPU 1 irqstacks, hard=3Dd1d8e000 soft=3Dd1d90000
[    0.092911] CPU 1 irqstacks, hard=3Dd1d8e000 soft=3Dd1d90000
[    0.093004] x86: Booting SMP configuration:
[    0.093004] x86: Booting SMP configuration:
[    0.094011] .... node  #0, CPUs: =20
[    0.094011] .... node  #0, CPUs:         #1 #1
[    0.002000] Initializing CPU#1
[    0.003000] kvm-clock: cpu 1, msr 0:13ffb041, secondary cpu clock
[    0.003000] masked ExtINT on CPU#1
[    0.109191] KVM setup async PF for cpu 1
[    0.109191] KVM setup async PF for cpu 1
[    0.109287] x86: Booted up 1 node, 2 CPUs
[    0.109287] x86: Booted up 1 node, 2 CPUs
[    0.109294] ----------------
[    0.109294] ----------------
[    0.109294] | NMI testsuite:
[    0.109294] | NMI testsuite:
[    0.109295] --------------------
[    0.109295] --------------------
[    0.109191]   remote IPI:
[    0.109191]   remote IPI:
[    0.109191] kvm-stealtime: cpu 1, msr 127a37c0
[    0.109191] kvm-stealtime: cpu 1, msr 127a37c0
[    0.118027]   ok  |
[    0.118027]   ok  |

[    0.118697]    local IPI:
[    0.118697]    local IPI:  ok  |  ok  |

[    0.125010] --------------------
[    0.125010] --------------------
[    0.125950] Good, all   2 testcases passed! |
[    0.125950] Good, all   2 testcases passed! |
[    0.126003] ---------------------------------
[    0.126003] ---------------------------------
[    0.127006] smpboot: Total of 2 processors activated (11332.49 BogoMIPS)
[    0.127006] smpboot: Total of 2 processors activated (11332.49 BogoMIPS)
[    0.133851] devtmpfs: initialized
[    0.133851] devtmpfs: initialized
[    0.158145] atomic64 test passed for i586+ platform with CX8 and with SSE
[    0.158145] atomic64 test passed for i586+ platform with CX8 and with SSE
[    0.163203] NET: Registered protocol family 16
[    0.163203] NET: Registered protocol family 16
[    0.177067] EISA bus registered
[    0.177067] EISA bus registered
[    0.178016] cpuidle: using governor ladder
[    0.178016] cpuidle: using governor ladder
[    0.179005] cpuidle: using governor menu
[    0.179005] cpuidle: using governor menu
[    0.181911] ACPI: bus type PCI registered
[    0.181911] ACPI: bus type PCI registered
[    0.182074] PCI: Using configuration type 1 for base access
[    0.182074] PCI: Using configuration type 1 for base access
[    0.459320] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.459320] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.460041] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.460041] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.468731] ACPI: Added _OSI(Module Device)
[    0.468731] ACPI: Added _OSI(Module Device)
[    0.469005] ACPI: Added _OSI(Processor Device)
[    0.469005] ACPI: Added _OSI(Processor Device)
[    0.470004] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.470004] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.471004] ACPI: Added _OSI(Processor Aggregator Device)
[    0.471004] ACPI: Added _OSI(Processor Aggregator Device)
[    0.489096] ACPI: Interpreter enabled
[    0.489096] ACPI: Interpreter enabled
[    0.490008] ACPI Exception: AE_NOT_FOUND,=20
[    0.490008] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_]While evaluating Sleep State [\_S1_] (20140114/hwxface-580)
 (20140114/hwxface-580)
[    0.492656] ACPI Exception: AE_NOT_FOUND,=20
[    0.492656] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_]While evaluating Sleep State [\_S2_] (20140114/hwxface-580)
 (20140114/hwxface-580)
[    0.494050] ACPI: (supports S0 S3 S5)
[    0.494050] ACPI: (supports S0 S3 S5)
[    0.495004] ACPI: Using IOAPIC for interrupt routing
[    0.495004] ACPI: Using IOAPIC for interrupt routing
[    0.497171] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.497171] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.606300] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.606300] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.607015] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MS=
I]
[    0.607015] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MS=
I]
[    0.608065] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.608065] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.613445] PCI host bridge to bus 0000:00
[    0.613445] PCI host bridge to bus 0000:00
[    0.614011] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.614011] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.615007] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.615007] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.616006] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.616006] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.617005] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.617005] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.618006] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.618006] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.619189] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.619189] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.625203] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.625203] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.630749] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.630749] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.634553] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    0.634553] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    0.640221] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.640221] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.642440] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.642440] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.643017] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.643017] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.649023] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.649023] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.651726] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.651726] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.654051] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.654051] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.662057] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.662057] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.666541] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.666541] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.668005] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.668005] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.670012] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.670012] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.676542] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.676542] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.680650] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.680650] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.682529] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.682529] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.684004] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.684004] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.693322] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.693322] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.695006] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.695006] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.697507] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    0.697507] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    0.706812] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.706812] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.708517] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.708517] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.710005] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    0.710005] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    0.719135] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.719135] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.721518] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    0.721518] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    0.723485] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.723485] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.732030] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.732030] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.734500] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    0.734500] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    0.736497] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.736497] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.745057] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.745057] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.747505] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.747505] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.749005] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.749005] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.757848] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    0.757848] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    0.759004] pci 0000:00:0a.0: reg 0x10: [mem 0xfebf7000-0xfebf700f]
[    0.759004] pci 0000:00:0a.0: reg 0x10: [mem 0xfebf7000-0xfebf700f]
[    0.768633] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    0.768633] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    0.769958] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    0.769958] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    0.771162] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    0.771162] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    0.773343] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    0.773343] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    0.775284] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    0.775284] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    0.780399] ACPI:=20
[    0.780399] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    0.785284] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.785284] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.787009] vgaarb: loaded
[    0.787009] vgaarb: loaded
[    0.788003] vgaarb: bridge control possible 0000:00:02.0
[    0.788003] vgaarb: bridge control possible 0000:00:02.0
[    0.803398] ACPI: bus type USB registered
[    0.803398] ACPI: bus type USB registered
[    0.806145] usbcore: registered new interface driver usbfs
[    0.806145] usbcore: registered new interface driver usbfs
[    0.808378] usbcore: registered new interface driver hub
[    0.808378] usbcore: registered new interface driver hub
[    0.810925] usbcore: registered new device driver usb
[    0.810925] usbcore: registered new device driver usb
[    0.816755] pps_core: LinuxPPS API ver. 1 registered
[    0.816755] pps_core: LinuxPPS API ver. 1 registered
[    0.818004] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.818004] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.824602] wmi: Mapper loaded
[    0.824602] wmi: Mapper loaded
[    0.828242] PCI: Using ACPI for IRQ routing
[    0.828242] PCI: Using ACPI for IRQ routing
[    0.829006] PCI: pci_cache_line_size set to 64 bytes
[    0.829006] PCI: pci_cache_line_size set to 64 bytes
[    0.831131] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.831131] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.833019] e820: reserve RAM buffer [mem 0x13ffe000-0x13ffffff]
[    0.833019] e820: reserve RAM buffer [mem 0x13ffe000-0x13ffffff]
[    0.844045] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.844045] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.848062] Switched to clocksource kvm-clock
[    0.848062] Switched to clocksource kvm-clock
[    0.854386] FS-Cache: Loaded
[    0.854386] FS-Cache: Loaded
[    0.856086] pnp: PnP ACPI init
[    0.856086] pnp: PnP ACPI init
[    0.857614] ACPI: bus type PNP registered
[    0.857614] ACPI: bus type PNP registered
[    0.858947] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.858947] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.862735] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.862735] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.864857] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.864857] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.868443] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.868443] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.870526] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.870526] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.874109] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.874109] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.876299] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    0.876299] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    0.878543] pnp 00:03: [dma 2]
[    0.878543] pnp 00:03: [dma 2]
[    0.880916] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.880916] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.883149] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    0.883149] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    0.886767] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.886767] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.888842] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    0.888842] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    0.892316] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.892316] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.896266] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.896266] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.899478] pnp: PnP ACPI: found 7 devices
[    0.899478] pnp: PnP ACPI: found 7 devices
[    0.900647] ACPI: bus type PNP unregistered
[    0.900647] ACPI: bus type PNP unregistered
[    0.955137] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.955137] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.956770] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.956770] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.958355] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.958355] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.960132] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    0.960132] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    0.962887] NET: Registered protocol family 1
[    0.962887] NET: Registered protocol family 1
[    0.964439] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.964439] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.966388] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.966388] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.968129] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.968129] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.969920] pci 0000:00:02.0: Boot video device
[    0.969920] pci 0000:00:02.0: Boot video device
[    0.971307] PCI: CLS 0 bytes, default 64
[    0.971307] PCI: CLS 0 bytes, default 64
[    0.975790] Unpacking initramfs...
[    0.975790] Unpacking initramfs...
[    6.963238] debug: unmapping init [mem 0xd27ab000-0xd3feffff]
[    6.963238] debug: unmapping init [mem 0xd27ab000-0xd3feffff]
[    7.098065] DMA-API: preallocated 65536 debug entries
[    7.098065] DMA-API: preallocated 65536 debug entries
[    7.099511] DMA-API: debugging enabled by kernel config
[    7.099511] DMA-API: debugging enabled by kernel config
[    7.113232] apm: BIOS not found.
[    7.113232] apm: BIOS not found.
[    7.116976] cryptomgr_test (23) used greatest stack depth: 7036 bytes le=
ft
[    7.116976] cryptomgr_test (23) used greatest stack depth: 7036 bytes le=
ft
[    7.119717] cryptomgr_test (24) used greatest stack depth: 6984 bytes le=
ft
[    7.119717] cryptomgr_test (24) used greatest stack depth: 6984 bytes le=
ft
[    7.123331] The force parameter has not been set to 1. The Iris poweroff=
 handler will not be installed.
[    7.123331] The force parameter has not been set to 1. The Iris poweroff=
 handler will not be installed.
[    7.125928] NatSemi SCx200 Driver
[    7.125928] NatSemi SCx200 Driver
[    7.128710] spin_lock-torture:--- Start of test: nwriters_stress=3D4 sta=
t_interval=3D60 verbose=3D1 shuffle_interval=3D3 stutter=3D5 shutdown_secs=
=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    7.128710] spin_lock-torture:--- Start of test: nwriters_stress=3D4 sta=
t_interval=3D60 verbose=3D1 shuffle_interval=3D3 stutter=3D5 shutdown_secs=
=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    7.132916] spin_lock-torture: Creating torture_shuffle task
[    7.132916] spin_lock-torture: Creating torture_shuffle task
[    7.134765] spin_lock-torture: Creating torture_stutter task
[    7.134765] spin_lock-torture: Creating torture_stutter task
[    7.136378] spin_lock-torture: torture_shuffle task started
[    7.136378] spin_lock-torture: torture_shuffle task started
[    7.138084] spin_lock-torture: Creating lock_torture_writer task
[    7.138084] spin_lock-torture: Creating lock_torture_writer task
[    7.138089] spin_lock-torture: torture_stutter task started
[    7.138089] spin_lock-torture: torture_stutter task started
[    7.141455] spin_lock-torture: Creating lock_torture_writer task
[    7.141455] spin_lock-torture: Creating lock_torture_writer task
[    7.143156] spin_lock-torture: lock_torture_writer task started
[    7.143156] spin_lock-torture: lock_torture_writer task started
[    7.144846] spin_lock-torture: Creating lock_torture_writer task
[    7.144846] spin_lock-torture: Creating lock_torture_writer task
[    7.144855] spin_lock-torture: lock_torture_writer task started
[    7.144855] spin_lock-torture: lock_torture_writer task started
[    7.148451] spin_lock-torture: Creating lock_torture_writer task
[    7.148451] spin_lock-torture: Creating lock_torture_writer task
[    7.150147] spin_lock-torture: lock_torture_writer task started
[    7.150147] spin_lock-torture: lock_torture_writer task started
[    7.151835] spin_lock-torture: Creating lock_torture_stats task
[    7.151835] spin_lock-torture: Creating lock_torture_stats task
[    7.151844] spin_lock-torture: lock_torture_writer task started
[    7.151844] spin_lock-torture: lock_torture_writer task started
[    7.156046] spin_lock-torture: lock_torture_stats task started
[    7.156046] spin_lock-torture: lock_torture_stats task started
[    7.167498] futex hash table entries: 512 (order: 3, 32768 bytes)
[    7.167498] futex hash table entries: 512 (order: 3, 32768 bytes)
[    7.175251] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    7.175251] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    7.186874] fuse init (API version 7.22)
[    7.186874] fuse init (API version 7.22)
[    7.197780] cryptomgr_test (40) used greatest stack depth: 6424 bytes le=
ft
[    7.197780] cryptomgr_test (40) used greatest stack depth: 6424 bytes le=
ft
[    7.211933] cryptomgr_test (45) used greatest stack depth: 6228 bytes le=
ft
[    7.211933] cryptomgr_test (45) used greatest stack depth: 6228 bytes le=
ft
[    7.217504] cryptomgr_test (47) used greatest stack depth: 6180 bytes le=
ft
[    7.217504] cryptomgr_test (47) used greatest stack depth: 6180 bytes le=
ft
[    7.265345] cryptomgr_test (67) used greatest stack depth: 6152 bytes le=
ft
[    7.265345] cryptomgr_test (67) used greatest stack depth: 6152 bytes le=
ft
[    7.272167] alg: No test for lz4hc (lz4hc-generic)
[    7.272167] alg: No test for lz4hc (lz4hc-generic)
[    7.273876] alg: No test for stdrng (krng)
[    7.273876] alg: No test for stdrng (krng)
[    7.275276] list_sort_test: start testing list_sort()
[    7.275276] list_sort_test: start testing list_sort()
[    7.277457] test_string_helpers: Running tests...
[    7.277457] test_string_helpers: Running tests...
[    7.280562] crc32: CRC_LE_BITS =3D 8, CRC_BE BITS =3D 8
[    7.280562] crc32: CRC_LE_BITS =3D 8, CRC_BE BITS =3D 8
[    7.281916] crc32: self tests passed, processed 225944 bytes in 617379 n=
sec
[    7.281916] crc32: self tests passed, processed 225944 bytes in 617379 n=
sec
[    7.284399] crc32c: CRC_LE_BITS =3D 8
[    7.284399] crc32c: CRC_LE_BITS =3D 8
[    7.285378] crc32c: self tests passed, processed 225944 bytes in 268282 =
nsec
[    7.285378] crc32c: self tests passed, processed 225944 bytes in 268282 =
nsec
[    7.570942] crc32_combine: 8373 self tests passed
[    7.570942] crc32_combine: 8373 self tests passed
[    7.859771] crc32c_combine: 8373 self tests passed
[    7.859771] crc32c_combine: 8373 self tests passed
[    7.867057] xz_dec_test: module loaded
[    7.867057] xz_dec_test: module loaded
[    7.868131] xz_dec_test: Create a device node with 'mknod xz_dec_test c =
251 0' and write .xz files to it.
[    7.868131] xz_dec_test: Create a device node with 'mknod xz_dec_test c =
251 0' and write .xz files to it.
[    7.888810] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    7.888810] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    7.891747] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    7.891747] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    7.894364] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    7.894364] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    7.905535] cr_bllcd: INTEL CARILLO RANCH LPC not found.
[    7.905535] cr_bllcd: INTEL CARILLO RANCH LPC not found.
[    7.907110] cr_bllcd: Carillo Ranch Backlight Driver Initialized.
[    7.907110] cr_bllcd: Carillo Ranch Backlight Driver Initialized.
[    7.915208] rivafb_setup START
[    7.915208] rivafb_setup START
[    7.918931] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    7.918931] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    7.927739] vmlfb: initializing
[    7.927739] vmlfb: initializing
[    7.929458] Could not find Carillo Ranch MCH device.
[    7.929458] Could not find Carillo Ranch MCH device.
[    7.935839] sgivwfb: CRT monitor selected
[    7.935839] sgivwfb: CRT monitor selected
[    7.937011] sgivwfb: couldn't ioremap screen_base
[    7.937011] sgivwfb: couldn't ioremap screen_base
[    7.940556] hgafb: HGA card not detected.
[    7.940556] hgafb: HGA card not detected.
[    7.941717] hgafb: probe of hgafb.0 failed with error -22
[    7.941717] hgafb: probe of hgafb.0 failed with error -22
[    7.951495] gbefb: couldn't allocate framebuffer memory
[    7.951495] gbefb: couldn't allocate framebuffer memory
[    7.952974] ------------[ cut here ]------------
[    7.952974] ------------[ cut here ]------------
[    7.954307] WARNING: CPU: 1 PID: 1 at lib/dma-debug.c:1041 check_unmap+0=
x126/0x702()
[    7.954307] WARNING: CPU: 1 PID: 1 at lib/dma-debug.c:1041 check_unmap+0=
x126/0x702()
[    7.957071] NULL NULL: DMA-API: device driver tries to free DMA memory i=
t has not allocated [device address=3D0x000000000001a000] [size=3D256 bytes]
[    7.957071] NULL NULL: DMA-API: device driver tries to free DMA memory i=
t has not allocated [device address=3D0x000000000001a000] [size=3D256 bytes]
[    7.960675] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.14.0-rc3-wl-0192=
9-g0964c4d #4
[    7.960675] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.14.0-rc3-wl-0192=
9-g0964c4d #4
[    7.963014]  00000000
[    7.963014]  00000000 00000000 00000000 d1cebd04 d1cebd04 c1612d01 c1612=
d01 d1cebd2c d1cebd2c d1cebd1c d1cebd1c c10340fe c10340fe c115c326 c115c326

[    7.965395]  c18c1229
[    7.965395]  c18c1229 0001a000 0001a000 00000000 00000000 d1cebd34 d1ceb=
d34 c1034154 c1034154 00000009 00000009 d1cebd2c d1cebd2c c18b78f8 c18b78f8

[    7.967719]  d1cebd48
[    7.967719]  d1cebd48 d1cebd98 d1cebd98 c115c326 c115c326 c18b724f c18b7=
24f 00000411 00000411 c18b78f8 c18b78f8 c18c1229 c18c1229 c18c1229 c18c1229

[    7.970048] Call Trace:
[    7.970048] Call Trace:
[    7.970752]  [<c1612d01>] dump_stack+0x48/0x60
[    7.970752]  [<c1612d01>] dump_stack+0x48/0x60
[    7.971999]  [<c10340fe>] warn_slowpath_common+0x57/0x6e
[    7.971999]  [<c10340fe>] warn_slowpath_common+0x57/0x6e
[    7.973492]  [<c115c326>] ? check_unmap+0x126/0x702
[    7.973492]  [<c115c326>] ? check_unmap+0x126/0x702
[    7.974856]  [<c1034154>] warn_slowpath_fmt+0x26/0x2a
[    7.974856]  [<c1034154>] warn_slowpath_fmt+0x26/0x2a
[    7.976314]  [<c115c326>] check_unmap+0x126/0x702
[    7.976314]  [<c115c326>] check_unmap+0x126/0x702
[    7.977658]  [<c1062c0a>] ? mark_held_locks+0x40/0x72
[    7.977658]  [<c1062c0a>] ? mark_held_locks+0x40/0x72
[    7.979058]  [<c161976d>] ? restore_all+0xf/0xf
[    7.979058]  [<c161976d>] ? restore_all+0xf/0xf
[    7.980472]  [<c115cce0>] debug_dma_free_coherent+0xa8/0xb0
[    7.980472]  [<c115cce0>] debug_dma_free_coherent+0xa8/0xb0
[    7.982078]  [<c11e2082>] dma_free_attrs.constprop.3+0x56/0x7a
[    7.982078]  [<c11e2082>] dma_free_attrs.constprop.3+0x56/0x7a
[    7.983739]  [<c11e266f>] gbefb_probe+0x49b/0x4dc
[    7.983739]  [<c11e266f>] gbefb_probe+0x49b/0x4dc
[    7.985086]  [<c13e893e>] platform_drv_probe+0x32/0x7d
[    7.985086]  [<c13e893e>] platform_drv_probe+0x32/0x7d
[    7.986555]  [<c13e7a92>] driver_probe_device+0x7f/0x177
[    7.986555]  [<c13e7a92>] driver_probe_device+0x7f/0x177
[    7.988046]  [<c13e7ba6>] __device_attach+0x1c/0x2c
[    7.988046]  [<c13e7ba6>] __device_attach+0x1c/0x2c
[    7.989405]  [<c13e6ba6>] bus_for_each_drv+0x35/0x68
[    7.989405]  [<c13e6ba6>] bus_for_each_drv+0x35/0x68
[    7.990783]  [<c13e79a0>] device_attach+0x5d/0x7d
[    7.990783]  [<c13e79a0>] device_attach+0x5d/0x7d
[    7.992086]  [<c13e7b8a>] ? driver_probe_device+0x177/0x177
[    7.992086]  [<c13e7b8a>] ? driver_probe_device+0x177/0x177
[    7.993636]  [<c13e6d1d>] bus_probe_device+0x22/0x77
[    7.993636]  [<c13e6d1d>] bus_probe_device+0x22/0x77
[    7.995012]  [<c13e566d>] device_add+0x30c/0x486
[    7.995012]  [<c13e566d>] device_add+0x30c/0x486
[    7.996304]  [<c13e52d7>] ? dev_set_name+0x14/0x16
[    7.996304]  [<c13e52d7>] ? dev_set_name+0x14/0x16
[    7.997639]  [<c13e8dc5>] platform_device_add+0x10c/0x170
[    7.997639]  [<c13e8dc5>] platform_device_add+0x10c/0x170
[    7.999151]  [<c1a46e8a>] gbefb_init+0x30/0x56
[    7.999151]  [<c1a46e8a>] gbefb_init+0x30/0x56
[    8.000389]  [<c1a46e5a>] ? hgafb_init+0x75/0x75
[    8.000389]  [<c1a46e5a>] ? hgafb_init+0x75/0x75
[    8.001676]  [<c1a24a77>] do_one_initcall+0x79/0x108
[    8.001676]  [<c1a24a77>] do_one_initcall+0x79/0x108
[    8.003055]  [<c1a2445c>] ? repair_env_string+0x12/0x51
[    8.003055]  [<c1a2445c>] ? repair_env_string+0x12/0x51
[    8.004507]  [<c1048c4a>] ? parse_args+0x16a/0x20b
[    8.004507]  [<c1048c4a>] ? parse_args+0x16a/0x20b
[    8.005833]  [<c1a24c80>] kernel_init_freeable+0x17a/0x1ff
[    8.005833]  [<c1a24c80>] kernel_init_freeable+0x17a/0x1ff
[    8.007396]  [<c160d88d>] kernel_init+0x8/0xbd
[    8.007396]  [<c160d88d>] kernel_init+0x8/0xbd
[    8.008629]  [<c1619eb7>] ret_from_kernel_thread+0x1b/0x28
[    8.008629]  [<c1619eb7>] ret_from_kernel_thread+0x1b/0x28
[    8.010147]  [<c160d885>] ? rest_init+0x116/0x116
[    8.010147]  [<c160d885>] ? rest_init+0x116/0x116
[    8.011464] ---[ end trace c1622b028dcb1e0c ]---
[    8.011464] ---[ end trace c1622b028dcb1e0c ]---
[    8.012888] gbefb: probe of gbefb.0 failed with error -12
[    8.012888] gbefb: probe of gbefb.0 failed with error -12
[    8.016715] usbcore: registered new interface driver udlfb
[    8.016715] usbcore: registered new interface driver udlfb
[    8.020535] ipmi message handler version 39.2
[    8.020535] ipmi message handler version 39.2
[    8.021869] ipmi device interface
[    8.021869] ipmi device interface
[    8.023652] IPMI System Interface driver.
[    8.023652] IPMI System Interface driver.
[    8.026096] ipmi_si: Adding default-specified kcs state machine
[    8.026096] ipmi_si: Adding default-specified kcs state machine

[    8.027769] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[    8.027769] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[    8.030569] ipmi_si: Interface detection failed
[    8.030569] ipmi_si: Interface detection failed
[    8.035089] ipmi_si: Adding default-specified smic state machine
[    8.035089] ipmi_si: Adding default-specified smic state machine

[    8.036781] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[    8.036781] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[    8.039586] ipmi_si: Interface detection failed
[    8.039586] ipmi_si: Interface detection failed
[    8.044096] ipmi_si: Adding default-specified bt state machine
[    8.044096] ipmi_si: Adding default-specified bt state machine

[    8.045738] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[    8.045738] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[    8.048474] ipmi_si: Interface detection failed
[    8.048474] ipmi_si: Interface detection failed
[    8.053468] ipmi_si: Unable to find any System Interface(s)
[    8.053468] ipmi_si: Unable to find any System Interface(s)
[    8.055017] IPMI Watchdog: driver initialized
[    8.055017] IPMI Watchdog: driver initialized
[    8.056234] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[    8.056234] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[    8.062876] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    8.062876] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    8.064953] ACPI: Power Button [PWRF]
[    8.064953] ACPI: Power Button [PWRF]
[    8.104110] tsc: Refined TSC clocksource calibration: 2833.278 MHz
[    8.104110] tsc: Refined TSC clocksource calibration: 2833.278 MHz
[    8.999771] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    8.999771] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    9.024745] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    9.024745] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    9.049143] DoubleTalk PC - not found
[    9.049143] DoubleTalk PC - not found
[    9.050190] sonypi: Sony Programmable I/O Controller Driver v1.26.
[    9.050190] sonypi: Sony Programmable I/O Controller Driver v1.26.
[    9.053966] Non-volatile memory driver v1.3
[    9.053966] Non-volatile memory driver v1.3
[    9.056290] scx200_gpio: no SCx200 gpio present
[    9.056290] scx200_gpio: no SCx200 gpio present
[    9.059036] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initial=
izing
[    9.059036] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initial=
izing
[    9.061037] platform pc8736x_gpio.0: no device found
[    9.061037] platform pc8736x_gpio.0: no device found
[    9.062742] nsc_gpio initializing
[    9.062742] nsc_gpio initializing
[    9.063684] Linux agpgart interface v0.103
[    9.063684] Linux agpgart interface v0.103
[    9.072923] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    9.072923] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    9.075408] Hangcheck: Using getrawmonotonic().
[    9.075408] Hangcheck: Using getrawmonotonic().
[    9.077451] [drm] Initialized drm 1.1.0 20060810
[    9.077451] [drm] Initialized drm 1.1.0 20060810
[    9.080212] [drm] radeon kernel modesetting enabled.
[    9.080212] [drm] radeon kernel modesetting enabled.
[    9.092640] [TTM] Zone  kernel: Available graphics memory: 140632 kiB
[    9.092640] [TTM] Zone  kernel: Available graphics memory: 140632 kiB
[    9.094461] [TTM] Initializing pool allocator
[    9.094461] [TTM] Initializing pool allocator
[    9.110335] [drm] fb mappable at 0xFC000000
[    9.110335] [drm] fb mappable at 0xFC000000
[    9.111509] [drm] vram aper at 0xFC000000
[    9.111509] [drm] vram aper at 0xFC000000
[    9.112626] [drm] size 4194304
[    9.112626] [drm] size 4194304
[    9.113490] [drm] fb depth is 24
[    9.113490] [drm] fb depth is 24
[    9.114400] [drm]    pitch is 3072
[    9.114400] [drm]    pitch is 3072
[    9.118251] cirrus 0000:00:02.0: fb0: cirrusdrmfb frame buffer device
[    9.118251] cirrus 0000:00:02.0: fb0: cirrusdrmfb frame buffer device
[    9.120044] cirrus 0000:00:02.0: registered panic notifier
[    9.120044] cirrus 0000:00:02.0: registered panic notifier
[    9.121582] [drm] Initialized cirrus 1.0.0 20110418 for 0000:00:02.0 on =
minor 0
[    9.121582] [drm] Initialized cirrus 1.0.0 20110418 for 0000:00:02.0 on =
minor 0
[    9.125623] usbcore: registered new interface driver udl
[    9.125623] usbcore: registered new interface driver udl
[    9.133679] Phantom Linux Driver, version n0.9.8, init OK
[    9.133679] Phantom Linux Driver, version n0.9.8, init OK
[    9.140860] Guest personality initialized and is inactive
[    9.140860] Guest personality initialized and is inactive
[    9.143786] VMCI host device registered (name=3Dvmci, major=3D10, minor=
=3D62)
[    9.143786] VMCI host device registered (name=3Dvmci, major=3D10, minor=
=3D62)
[    9.145637] Initialized host personality
[    9.145637] Initialized host personality
[    9.154038] usbcore: registered new interface driver viperboard
[    9.154038] usbcore: registered new interface driver viperboard
[    9.164211] Databook TCIC-2 PCMCIA probe:=20
[    9.164211] Databook TCIC-2 PCMCIA probe: not found.
not found.
[    9.167997] usbcore: registered new interface driver hwa-rc
[    9.167997] usbcore: registered new interface driver hwa-rc
[    9.173570] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    9.173570] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    9.175434] ehci-pci: EHCI PCI platform driver
[    9.175434] ehci-pci: EHCI PCI platform driver
[    9.177194] ehci-platform: EHCI generic platform driver
[    9.177194] ehci-platform: EHCI generic platform driver
[    9.180039] uhci_hcd: USB Universal Host Controller Interface driver
[    9.180039] uhci_hcd: USB Universal Host Controller Interface driver
[    9.185587] fotg210_hcd: FOTG210 Host Controller (EHCI) Driver
[    9.185587] fotg210_hcd: FOTG210 Host Controller (EHCI) Driver
[    9.187234]=20
[    9.187234]=20
[    9.191253] usbcore: registered new interface driver wusb-cbaf
[    9.191253] usbcore: registered new interface driver wusb-cbaf
[    9.193432] usbcore: registered new interface driver usblp
[    9.193432] usbcore: registered new interface driver usblp
[    9.195484] usbcore: registered new interface driver cdc_wdm
[    9.195484] usbcore: registered new interface driver cdc_wdm
[    9.197545] usbcore: registered new interface driver usbtmc
[    9.197545] usbcore: registered new interface driver usbtmc
[    9.199919] usbcore: registered new interface driver appledisplay
[    9.199919] usbcore: registered new interface driver appledisplay
[    9.202135] usbcore: registered new interface driver cypress_cy7c63
[    9.202135] usbcore: registered new interface driver cypress_cy7c63
[    9.204415] usbcore: registered new interface driver emi26 - firmware lo=
ader
[    9.204415] usbcore: registered new interface driver emi26 - firmware lo=
ader
[    9.206832] usbcore: registered new interface driver emi62 - firmware lo=
ader
[    9.206832] usbcore: registered new interface driver emi62 - firmware lo=
ader
[    9.209339] usbcore: registered new interface driver idmouse
[    9.209339] usbcore: registered new interface driver idmouse
[    9.211410] usbcore: registered new interface driver iowarrior
[    9.211410] usbcore: registered new interface driver iowarrior
[    9.213520] usbcore: registered new interface driver usbled
[    9.213520] usbcore: registered new interface driver usbled
[    9.215544] usbcore: registered new interface driver legousbtower
[    9.215544] usbcore: registered new interface driver legousbtower
[    9.217746] usbcore: registered new interface driver usbtest
[    9.217746] usbcore: registered new interface driver usbtest
[    9.219812] usbcore: registered new interface driver trancevibrator
[    9.219812] usbcore: registered new interface driver trancevibrator
[    9.222105] usbcore: registered new interface driver usbsevseg
[    9.222105] usbcore: registered new interface driver usbsevseg
[    9.224235] usbcore: registered new interface driver sisusb
[    9.224235] usbcore: registered new interface driver sisusb
[    9.229799] dummy_hcd dummy_hcd.0: USB Host+Gadget Emulator, driver 02 M=
ay 2005
[    9.229799] dummy_hcd dummy_hcd.0: USB Host+Gadget Emulator, driver 02 M=
ay 2005
[    9.231928] dummy_hcd dummy_hcd.0: Dummy host controller
[    9.231928] dummy_hcd dummy_hcd.0: Dummy host controller
[    9.235981] dummy_hcd dummy_hcd.0: new USB bus registered, assigned bus =
number 1
[    9.235981] dummy_hcd dummy_hcd.0: new USB bus registered, assigned bus =
number 1
[    9.246883] hub 1-0:1.0: USB hub found
[    9.246883] hub 1-0:1.0: USB hub found
[    9.248206] hub 1-0:1.0: 1 port detected
[    9.248206] hub 1-0:1.0: 1 port detected
[    9.261508] gadgetfs: USB Gadget filesystem, version 24 Aug 2004
[    9.261508] gadgetfs: USB Gadget filesystem, version 24 Aug 2004
[    9.264248] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    9.264248] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    9.269254] serio: i8042 KBD port at 0x60,0x64 irq 1
[    9.269254] serio: i8042 KBD port at 0x60,0x64 irq 1
[    9.270715] serio: i8042 AUX port at 0x60,0x64 irq 12
[    9.270715] serio: i8042 AUX port at 0x60,0x64 irq 12
[    9.352679] usb usb1: dummy_bus_suspend
[    9.352679] usb usb1: dummy_bus_suspend
[    9.358120] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    9.358120] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    9.362803] usbcore: registered new interface driver xpad
[    9.362803] usbcore: registered new interface driver xpad
[    9.365064] I2O subsystem v1.325
[    9.365064] I2O subsystem v1.325
[    9.365962] i2o: max drivers =3D 8
[    9.365962] i2o: max drivers =3D 8
[    9.368225] I2O Configuration OSM v1.323
[    9.368225] I2O Configuration OSM v1.323
[    9.370506] I2O ProcFS OSM v1.316
[    9.370506] I2O ProcFS OSM v1.316
[    9.372754] rtc_cmos 00:00: RTC can wake from S4
[    9.372754] rtc_cmos 00:00: RTC can wake from S4
[    9.376239] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    9.376239] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    9.378163] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[    9.378163] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[    9.393366] rtc-test rtc-test.0: rtc core: registered test as rtc1
[    9.393366] rtc-test rtc-test.0: rtc core: registered test as rtc1
[    9.396923] rtc-test rtc-test.1: rtc core: registered test as rtc2
[    9.396923] rtc-test rtc-test.1: rtc core: registered test as rtc2
[    9.400408] i2c /dev entries driver
[    9.400408] i2c /dev entries driver
[    9.403612] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, r=
evision 0
[    9.403612] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, r=
evision 0
[    9.413841] usbcore: registered new interface driver i2c-tiny-usb
[    9.413841] usbcore: registered new interface driver i2c-tiny-usb
[    9.415839] scx200_i2c: no SCx200 gpio pins available
[    9.415839] scx200_i2c: no SCx200 gpio pins available
[    9.417569] Driver for 1-wire Dallas network protocol.
[    9.417569] Driver for 1-wire Dallas network protocol.
[    9.420429] usbcore: registered new interface driver DS9490R
[    9.420429] usbcore: registered new interface driver DS9490R
[    9.422328] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    9.422328] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    9.424625] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 20=
04-2005, Szabolcs Gyurko
[    9.424625] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 20=
04-2005, Szabolcs Gyurko
[    9.752067] i2c i2c-0: detect fail: address match, 0x2c
[    9.752067] i2c i2c-0: detect fail: address match, 0x2c
[    9.757095] i2c i2c-0: detect fail: address match, 0x2d
[    9.757095] i2c i2c-0: detect fail: address match, 0x2d
[    9.762062] i2c i2c-0: detect fail: address match, 0x2e
[    9.762062] i2c i2c-0: detect fail: address match, 0x2e
[    9.767064] i2c i2c-0: detect fail: address match, 0x2f
[    9.767064] i2c i2c-0: detect fail: address match, 0x2f
[    9.819088] applesmc: supported laptop not found!
[    9.819088] applesmc: supported laptop not found!
[    9.820447] applesmc: driver init failed (ret=3D-19)!
[    9.820447] applesmc: driver init failed (ret=3D-19)!
[   10.580178] platform eisa.0: Probing EISA bus 0
[   10.580178] platform eisa.0: Probing EISA bus 0
[   10.581499] platform eisa.0: EISA: Cannot allocate resource for mainboard
[   10.581499] platform eisa.0: EISA: Cannot allocate resource for mainboard
[   10.583749] sdhci: Secure Digital Host Controller Interface driver
[   10.583749] sdhci: Secure Digital Host Controller Interface driver
[   10.585469] sdhci: Copyright(c) Pierre Ossman
[   10.585469] sdhci: Copyright(c) Pierre Ossman
[   10.587069] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   10.587069] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   10.588709] wbsd: Copyright(c) Pierre Ossman
[   10.588709] wbsd: Copyright(c) Pierre Ossman
[   10.590955] VUB300 Driver rom wait states =3D 1C irqpoll timeout =3D 0400
[   10.590955] VUB300 Driver rom wait states =3D 1C irqpoll timeout =3D 0400

[   10.594153] usbcore: registered new interface driver vub300
[   10.594153] usbcore: registered new interface driver vub300
[   10.596137] usbcore: registered new interface driver ushc
[   10.596137] usbcore: registered new interface driver ushc
[   10.597641] sdhci-pltfm: SDHCI platform and OF driver helper
[   10.597641] sdhci-pltfm: SDHCI platform and OF driver helper
[   10.606163] ledtrig-cpu: registered to indicate activity on CPUs
[   10.606163] ledtrig-cpu: registered to indicate activity on CPUs
[   10.610504] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[   10.610504] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[   10.612830] cs5535-clockevt: Could not allocate MFGPT timer
[   10.612830] cs5535-clockevt: Could not allocate MFGPT timer
[   10.615184] hidraw: raw HID events driver (C) Jiri Kosina
[   10.615184] hidraw: raw HID events driver (C) Jiri Kosina
[   10.633892] usbcore: registered new interface driver usbhid
[   10.633892] usbcore: registered new interface driver usbhid
[   10.635501] usbhid: USB HID core driver
[   10.635501] usbhid: USB HID core driver
[   10.636929] vme_user: VME User Space Access Driver
[   10.636929] vme_user: VME User Space Access Driver
[   10.638318] vme_user: No cards, skipping registration
[   10.638318] vme_user: No cards, skipping registration
[   10.639743] vme_pio2: No cards, skipping registration
[   10.639743] vme_pio2: No cards, skipping registration
[   10.651879] usbcore: registered new interface driver cedusb
[   10.651879] usbcore: registered new interface driver cedusb
[   10.653452] hdaps: supported laptop not found!
[   10.653452] hdaps: supported laptop not found!
[   10.654697] hdaps: driver init failed (ret=3D-19)!
[   10.654697] hdaps: driver init failed (ret=3D-19)!
[   10.656224] goldfish_pdev_bus goldfish_pdev_bus: unable to reserve Goldf=
ish MMIO.
[   10.656224] goldfish_pdev_bus goldfish_pdev_bus: unable to reserve Goldf=
ish MMIO.
[   10.658332] goldfish_pdev_bus: probe of goldfish_pdev_bus failed with er=
ror -16
[   10.658332] goldfish_pdev_bus: probe of goldfish_pdev_bus failed with er=
ror -16
[   10.680769] oprofile: using NMI interrupt.
[   10.680769] oprofile: using NMI interrupt.
[   10.689500]=20
[   10.689500] printing PIC contents
[   10.689500]=20
[   10.689500] printing PIC contents
[   10.690878] ... PIC  IMR: ffff
[   10.690878] ... PIC  IMR: ffff
[   10.691738] ... PIC  IRR: 1113
[   10.691738] ... PIC  IRR: 1113
[   10.692618] ... PIC  ISR: 0000
[   10.692618] ... PIC  ISR: 0000
[   10.693496] ... PIC ELCR: 0c00
[   10.693496] ... PIC ELCR: 0c00
[   10.694406] printing local APIC contents on CPU#0/0:
[   10.694406] printing local APIC contents on CPU#0/0:
[   10.695015] ... APIC ID:      00000000 (0)
[   10.695015] ... APIC ID:      00000000 (0)
[   10.695015] ... APIC VERSION: 00050014
[   10.695015] ... APIC VERSION: 00050014
[   10.695015] ... APIC TASKPRI: 00000000 (00)
[   10.695015] ... APIC TASKPRI: 00000000 (00)
[   10.695015] ... APIC PROCPRI: 00000000
[   10.695015] ... APIC PROCPRI: 00000000
[   10.695015] ... APIC LDR: 01000000
[   10.695015] ... APIC LDR: 01000000
[   10.695015] ... APIC DFR: ffffffff
[   10.695015] ... APIC DFR: ffffffff
[   10.695015] ... APIC SPIV: 000001ff
[   10.695015] ... APIC SPIV: 000001ff
[   10.695015] ... APIC ISR field:
[   10.695015] ... APIC ISR field:
[   10.695015] 00000000
[   10.695015] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[   10.695015] ... APIC TMR field:
[   10.695015] ... APIC TMR field:
[   10.695015] 00000000
[   10.695015] 000000000200000002000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[   10.695015] ... APIC IRR field:
[   10.695015] ... APIC IRR field:
[   10.695015] 00000000
[   10.695015] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000800000008000

[   10.695015] ... APIC ESR: 00000000
[   10.695015] ... APIC ESR: 00000000
[   10.695015] ... APIC ICR: 000008fd
[   10.695015] ... APIC ICR: 000008fd
[   10.695015] ... APIC ICR2: 02000000
[   10.695015] ... APIC ICR2: 02000000
[   10.695015] ... APIC LVTT: 000000ef
[   10.695015] ... APIC LVTT: 000000ef
[   10.695015] ... APIC LVTPC: 00010000
[   10.695015] ... APIC LVTPC: 00010000
[   10.695015] ... APIC LVT0: 00010700
[   10.695015] ... APIC LVT0: 00010700
[   10.695015] ... APIC LVT1: 00000400
[   10.695015] ... APIC LVT1: 00000400
[   10.695015] ... APIC LVTERR: 000000fe
[   10.695015] ... APIC LVTERR: 000000fe
[   10.695015] ... APIC TMICT: 0000efdb
[   10.695015] ... APIC TMICT: 0000efdb
[   10.695015] ... APIC TMCCT: 00000000
[   10.695015] ... APIC TMCCT: 00000000
[   10.695015] ... APIC TDCR: 00000003
[   10.695015] ... APIC TDCR: 00000003
[   10.695015]=20
[   10.695015]=20
[   10.723281] number of MP IRQ sources: 15.
[   10.723281] number of MP IRQ sources: 15.
[   10.724472] number of IO-APIC #0 registers: 24.
[   10.724472] number of IO-APIC #0 registers: 24.
[   10.725744] testing the IO APIC.......................
[   10.725744] testing the IO APIC.......................
[   10.727204] IO APIC #0......
[   10.727204] IO APIC #0......
[   10.728002] .... register #00: 00000000
[   10.728002] .... register #00: 00000000
[   10.729080] .......    : physical APIC id: 00
[   10.729080] .......    : physical APIC id: 00
[   10.730296] .......    : Delivery Type: 0
[   10.730296] .......    : Delivery Type: 0
[   10.731417] .......    : LTS          : 0
[   10.731417] .......    : LTS          : 0
[   10.732541] .... register #01: 00170011
[   10.732541] .... register #01: 00170011
[   10.733617] .......     : max redirection entries: 17
[   10.733617] .......     : max redirection entries: 17
[   10.735023] .......     : PRQ implemented: 0
[   10.735023] .......     : PRQ implemented: 0
[   10.736210] .......     : IO APIC version: 11
[   10.736210] .......     : IO APIC version: 11
[   10.737427] .... register #02: 00000000
[   10.737427] .... register #02: 00000000
[   10.738500] .......     : arbitration: 00
[   10.738500] .......     : arbitration: 00
[   10.739624] .... IRQ redirection table:
[   10.739624] .... IRQ redirection table:
[   10.740715] 1    0    0   0   0    0    0    00
[   10.740715] 1    0    0   0   0    0    0    00
[   10.741997] 0    0    0   0   0    1    1    31
[   10.741997] 0    0    0   0   0    1    1    31
[   10.743289] 0    0    0   0   0    1    1    30
[   10.743289] 0    0    0   0   0    1    1    30
[   10.744565] 0    0    0   0   0    1    1    33
[   10.744565] 0    0    0   0   0    1    1    33
[   10.745845] 1    0    0   0   0    1    1    34
[   10.745845] 1    0    0   0   0    1    1    34
[   10.747125] 1    1    0   0   0    1    1    35
[   10.747125] 1    1    0   0   0    1    1    35
[   10.748406] 0    0    0   0   0    1    1    36
[   10.748406] 0    0    0   0   0    1    1    36
[   10.749683] 0    0    0   0   0    1    1    37
[   10.749683] 0    0    0   0   0    1    1    37
[   10.750960] 0    0    0   0   0    1    1    38
[   10.750960] 0    0    0   0   0    1    1    38
[   10.752242] 0    1    0   0   0    1    1    39
[   10.752242] 0    1    0   0   0    1    1    39
[   10.753525] 1    1    0   0   0    1    1    3A
[   10.753525] 1    1    0   0   0    1    1    3A
[   10.754810] 1    1    0   0   0    1    1    3B
[   10.754810] 1    1    0   0   0    1    1    3B
[   10.756085] 0    0    0   0   0    1    1    3C
[   10.756085] 0    0    0   0   0    1    1    3C
[   10.757358] 0    0    0   0   0    1    1    3D
[   10.757358] 0    0    0   0   0    1    1    3D
[   10.758630] 0    0    0   0   0    1    1    3E
[   10.758630] 0    0    0   0   0    1    1    3E
[   10.759908] 0    0    0   0   0    1    1    3F
[   10.759908] 0    0    0   0   0    1    1    3F
[   10.761188] 1    0    0   0   0    0    0    00
[   10.761188] 1    0    0   0   0    0    0    00
[   10.762472] 1    0    0   0   0    0    0    00
[   10.762472] 1    0    0   0   0    0    0    00
[   10.763745] 1    0    0   0   0    0    0    00
[   10.763745] 1    0    0   0   0    0    0    00
[   10.765024] 1    0    0   0   0    0    0    00
[   10.765024] 1    0    0   0   0    0    0    00
[   10.766301] 1    0    0   0   0    0    0    00
[   10.766301] 1    0    0   0   0    0    0    00
[   10.767571] 1    0    0   0   0    0    0    00
[   10.767571] 1    0    0   0   0    0    0    00
[   10.768849] 1    0    0   0   0    0    0    00
[   10.768849] 1    0    0   0   0    0    0    00
[   10.770139] 1    0    0   0   0    0    0    00
[   10.770139] 1    0    0   0   0    0    0    00
[   10.771412] IRQ to pin mappings:
[   10.771412] IRQ to pin mappings:
[   10.772320] IRQ0=20
[   10.772320] IRQ0 -> 0:2-> 0:2

[   10.773055] IRQ1=20
[   10.773055] IRQ1 -> 0:1-> 0:1

[   10.773773] IRQ3=20
[   10.773773] IRQ3 -> 0:3-> 0:3

[   10.774510] IRQ4=20
[   10.774510] IRQ4 -> 0:4-> 0:4

[   10.775241] IRQ5=20
[   10.775241] IRQ5 -> 0:5-> 0:5

[   10.775956] IRQ6=20
[   10.775956] IRQ6 -> 0:6-> 0:6

[   10.776697] IRQ7=20
[   10.776697] IRQ7 -> 0:7-> 0:7

[   10.777437] IRQ8=20
[   10.777437] IRQ8 -> 0:8-> 0:8

[   10.778165] IRQ9=20
[   10.778165] IRQ9 -> 0:9-> 0:9

[   10.778881] IRQ10=20
[   10.778881] IRQ10 -> 0:10-> 0:10

[   10.779665] IRQ11=20
[   10.779665] IRQ11 -> 0:11-> 0:11

[   10.780449] IRQ12=20
[   10.780449] IRQ12 -> 0:12-> 0:12

[   10.781233] IRQ13=20
[   10.781233] IRQ13 -> 0:13-> 0:13

[   10.781994] IRQ14=20
[   10.781994] IRQ14 -> 0:14-> 0:14

[   10.782780] IRQ15=20
[   10.782780] IRQ15 -> 0:15-> 0:15

[   10.783568] .................................... done.
[   10.783568] .................................... done.
[   10.784987] Using IPI No-Shortcut mode
[   10.784987] Using IPI No-Shortcut mode
[   10.790078] bootconsole [earlyser0] disabled
[   10.790078] bootconsole [earlyser0] disabled
[   10.798871] debug: unmapping init [mem 0xc1a24000-0xc1a82fff]
[   10.801540] Write protecting the kernel text: 6252k
[   10.803034] Write protecting the kernel read-only data: 3336k
[   10.803848] NX-protecting the kernel data: 6036k
[   10.857268] random: init urandom read with 4 bits of entropy available
[   11.455915] init: Failed to create pty - disabling logging for job
[   11.457333] init: Temporary process spawn error: No space left on device
[   11.887646] initctl (137) used greatest stack depth: 6096 bytes left
[   12.158754] init: plymouth-log main process (150) terminated with status=
 1
udevd[159]: error creating signalfd

udevd[166]: error creating signalfd

udevd[168]: error creating signalfd

udevd[170]: error creating signalfd

udevd[172]: error creating signalfd

udevd[174]: error creating signalfd

udevd[176]: error creating signalfd

udevd[178]: error creating signalfd

udevd[180]: error creating signalfd

udevd[182]: error creating signalfd

udevd[184]: error creating signalfd

Kernel tests: Boot OK!
Kernel tests: Boot OK!
Trinity v1.4pre  Dave Jones <davej@redhat.com>
[init] Marking syscall get_robust_list (312) as to be disabled.
Done parsing arguments.
Marking all syscalls as enabled.
[init] Disabling syscalls marked as disabled by command line options
[init] Marked syscall get_robust_list (312) as deactivated.
[init] Enabled 350 syscalls. Disabled 1 syscalls.
DANGER: RUNNING AS ROOT.
Unless you are running in a virtual machine, this could cause serious probl=
ems such as overwriting CMOS
or similar which could potentially make this machine unbootable without a f=
irmware reset.

ctrl-c now unless you really know what you are doing.
Continuing in 10 seconds.
[init] Kernel was tainted on startup. Will ignore flags that are already se=
t.
[init] Started watchdog process, PID is 257
[main] Main thread is alive.
[main] Setsockopt(1 2c 80d3000 85) on fd 7 [1:5:1]
[main] Setsockopt(1 10 80d3000 4) on fd 9 [1:1:1]
[main] Setsockopt(1 a 80d3000 4) on fd 11 [1:2:1]
[main] Setsockopt(1 29 80d3000 4) on fd 12 [1:1:1]
[main] Setsockopt(1 12 80d3000 46) on fd 15 [16:2:16]
[main] Setsockopt(1 20 80d3000 4) on fd 17 [1:5:1]
[main] Setsockopt(1 10 80d3000 c0) on fd 20 [16:3:15]
[main] Setsockopt(1 1 80d3000 4) on fd 21 [1:5:1]
[main] Setsockopt(1 24 80d3000 da) on fd 22 [16:3:4]
[main] Setsockopt(1 9 80d3000 4) on fd 23 [1:1:1]
[main] Setsockopt(1 e 80d3000 ca) on fd 24 [16:3:16]
[main] Setsockopt(1 b 80d3000 3f) on fd 25 [1:5:1]
[main] Setsockopt(1 f 80d3000 e8) on fd 26 [1:1:1]
[main] Setsockopt(1 e 80d3000 4) on fd 27 [1:5:1]
[main] Setsockopt(1 f 80d3000 4e) on fd 29 [1:1:1]
[main] Setsockopt(1 d 80d3000 8) on fd 30 [1:5:1]
[main] Setsockopt(1 b 80d3000 6b) on fd 31 [1:2:1]
[main] Setsockopt(1 28 80d3000 4) on fd 32 [16:3:15]
[main] Setsockopt(1 2e 80d3000 4) on fd 35 [1:5:1]
[main] Setsockopt(1 2 80d3000 46) on fd 36 [1:5:1]
[main] Setsockopt(10e 4 80d3000 e7) on fd 37 [16:3:15]
[main] Setsockopt(1 1 80d3000 a7) on fd 38 [1:2:1]
[main] Setsockopt(1 d 80d3000 8) on fd 40 [1:1:1]
[main] Setsockopt(10e 5 80d3000 4) on fd 41 [16:3:2]
[main] Setsockopt(1 20 80d3000 88) on fd 44 [1:2:1]
[main] Setsockopt(1 6 80d3000 4) on fd 45 [16:2:0]
[main] Setsockopt(1 a 80d3000 4) on fd 46 [1:2:1]
[main] Setsockopt(1 10 80d3000 eb) on fd 47 [1:1:1]
[main] Setsockopt(1 2 80d3000 4) on fd 48 [1:2:1]
[main] Setsockopt(1 21 80d3000 4) on fd 49 [1:2:1]
[main] Setsockopt(1 2 80d3000 bc) on fd 50 [1:1:1]
[main] Setsockopt(1 10 80d3000 17) on fd 52 [16:3:16]
[main] Setsockopt(1 6 80d3000 4) on fd 54 [1:1:1]
[main] Setsockopt(1 7 80d3000 4) on fd 55 [16:3:4]
[main] Setsockopt(1 2e 80d3000 4) on fd 56 [1:5:1]
[main] Setsockopt(1 6 80d3000 2c) on fd 57 [1:2:1]
[main] Setsockopt(1 1 80d3000 4) on fd 59 [1:2:1]
[main] Setsockopt(1 7 80d3000 4) on fd 60 [1:1:1]
[main] Setsockopt(10e 3 80d3000 4) on fd 61 [16:3:0]
[main] Setsockopt(1 e 80d3000 4) on fd 62 [1:5:1]
[main] Setsockopt(10e 4 80d3000 6f) on fd 63 [16:3:4]
[main] Setsockopt(1 2f 80d3000 4) on fd 64 [1:2:1]
[main] Setsockopt(1 24 80d3000 4) on fd 66 [1:2:1]
[main] Setsockopt(1 2b 80d3000 c) on fd 67 [1:1:1]
[main] Setsockopt(1 2f 80d3000 4) on fd 68 [1:1:1]
[main] Setsockopt(1 9 80d3000 4) on fd 69 [1:1:1]
[main] Setsockopt(1 8 80d3000 e) on fd 70 [1:5:1]
[main] Setsockopt(10e 5 80d3000 4) on fd 71 [16:3:16]
[main] Setsockopt(1 f 80d3000 52) on fd 76 [1:1:1]
[main] Setsockopt(1 1d 80d3000 3a) on fd 77 [1:1:1]
[main] Setsockopt(1 2c 80d3000 c1) on fd 80 [1:2:1]
[main] Setsockopt(1 21 80d3000 b6) on fd 83 [16:2:15]
[main] Setsockopt(1 b 80d3000 c6) on fd 84 [1:2:1]
[main] Setsockopt(1 5 80d3000 5e) on fd 85 [16:3:4]
[main] Setsockopt(1 1d 80d3000 2f) on fd 87 [1:1:1]
[main] Setsockopt(1 9 80d3000 4f) on fd 88 [1:5:1]
[main] Setsockopt(1 b 80d3000 4) on fd 89 [1:5:1]
[main] Setsockopt(1 6 80d3000 4) on fd 91 [1:5:1]
[main] Setsockopt(1 6 80d3000 4) on fd 93 [1:5:1]
[main] Setsockopt(1 2b 80d3000 4) on fd 94 [1:2:1]
[main] Setsockopt(1 2a 80d3000 75) on fd 95 [1:1:1]
[main] Setsockopt(1 6 80d3000 4) on fd 96 [1:2:1]
[main] Setsockopt(1 7 80d3000 f5) on fd 97 [1:1:1]
[main] Setsockopt(1 2 80d3000 4) on fd 105 [1:5:1]
[main] Setsockopt(1 23 80d3000 cb) on fd 106 [1:1:1]
[main] Setsockopt(1 15 80d3000 8) on fd 107 [1:5:1]
[main] Setsockopt(1 10 80d3000 4) on fd 108 [1:2:1]
[main] Setsockopt(10e 4 80d3000 4) on fd 109 [16:3:16]
[main] Setsockopt(1 2e 80d3000 fe) on fd 110 [1:5:1]
[main] Setsockopt(10e 4 80d3000 cb) on fd 112 [16:2:15]
[main] Setsockopt(1 2d 80d3000 80) on fd 114 [1:5:1]
[main] Setsockopt(1 15 80d3000 8) on fd 116 [1:2:1]
[main] Setsockopt(1 2c 80d3000 12) on fd 117 [1:1:1]
[main] Setsockopt(1 5 80d3000 a7) on fd 118 [1:5:1]
[main] Setsockopt(1 2d 80d3000 4) on fd 119 [1:1:1]
[main] Setsockopt(1 2b 80d3000 4) on fd 121 [1:2:1]
[main] Setsockopt(1 6 80d3000 4) on fd 122 [16:3:16]
[main] Setsockopt(10e 1 80d3000 4) on fd 124 [16:3:4]
[main] Setsockopt(1 2b 80d3000 af) on fd 127 [16:3:2]
[main] Setsockopt(1 b 80d3000 7) on fd 128 [1:1:1]
[main] Setsockopt(1 c 80d3000 74) on fd 130 [1:5:1]
[main] Setsockopt(1 1 80d3000 e8) on fd 131 [16:3:0]
[main] Setsockopt(1 5 80d3000 ca) on fd 132 [1:5:1]
[main] Setsockopt(1 2a 80d3000 59) on fd 134 [1:1:1]
[main] Setsockopt(1 e 80d3000 4) on fd 135 [1:1:1]
[main] Setsockopt(1 7 80d3000 e2) on fd 136 [1:2:1]
[main] Setsockopt(1 2b 80d3000 ce) on fd 142 [1:1:1]
[main] Setsockopt(1 d 80d3000 8) on fd 143 [1:1:1]
[main] Setsockopt(1 20 80d3000 4) on fd 145 [1:2:1]
[main] Setsockopt(1 10 80d3000 52) on fd 148 [1:1:1]
[main] Setsockopt(10e 4 80d3000 8d) on fd 149 [16:2:0]
[main] Setsockopt(1 f 80d3000 fb) on fd 151 [1:5:1]
[main] Setsockopt(1 7 80d3000 36) on fd 152 [1:2:1]
[main] Setsockopt(1 28 80d3000 1c) on fd 153 [1:5:1]
[main] Setsockopt(1 2 80d3000 4) on fd 154 [1:5:1]
[main] Setsockopt(1 21 80d3000 29) on fd 155 [1:2:1]
[main] Setsockopt(1 2c 80d3000 4) on fd 156 [1:2:1]
[main] Setsockopt(10e 3 80d3000 90) on fd 159 [16:2:15]
[main] Setsockopt(1 10 80d3000 4) on fd 161 [1:5:1]
[main] Setsockopt(1 2d 80d3000 f7) on fd 163 [1:5:1]
[main] Setsockopt(1 28 80d3000 2a) on fd 164 [1:2:1]
[main] Setsockopt(1 f 80d3000 4) on fd 165 [1:1:1]
[main] Setsockopt(1 2e 80d3000 d3) on fd 166 [1:1:1]
[main] Setsockopt(10e 3 80d3000 4) on fd 169 [16:2:16]
[main] Setsockopt(1 5 80d3000 1e) on fd 170 [1:2:1]
[main] Setsockopt(1 7 80d3000 ac) on fd 172 [1:1:1]
[main] Setsockopt(1 22 80d3000 4) on fd 175 [1:1:1]
[main] Setsockopt(1 7 80d3000 4) on fd 179 [1:5:1]
[main] Setsockopt(10e 5 80d3000 ad) on fd 182 [16:3:0]
[main] Setsockopt(1 2d 80d3000 4) on fd 184 [1:2:1]
[main] Setsockopt(1 21 80d3000 a5) on fd 188 [1:1:1]
[main] Setsockopt(10e 4 80d3000 4) on fd 189 [16:2:16]
[main] Setsockopt(1 2c 80d3000 4) on fd 190 [1:2:1]
[main] Setsockopt(1 10 80d3000 d4) on fd 191 [16:2:16]
[main] Setsockopt(1 5 80d3000 4) on fd 193 [1:5:1]
[main] Setsockopt(1 2f 80d3000 38) on fd 194 [1:5:1]
[main] Setsockopt(1 2a 80d3000 42) on fd 196 [1:2:1]
[main] Setsockopt(1 12 80d3000 4) on fd 198 [16:2:0]
[main] Setsockopt(1 1 80d3000 ff) on fd 199 [1:1:1]
[main] Setsockopt(1 20 80d3000 1a) on fd 200 [1:5:1]
[main] Setsockopt(10e 2 80d3000 4) on fd 202 [16:3:15]
[main] Setsockopt(1 24 80d3000 f1) on fd 204 [1:5:1]
[main] Setsockopt(1 2d 80d3000 93) on fd 205 [1:1:1]
[main] Setsockopt(1 6 80d3000 4) on fd 207 [1:5:1]
[main] Setsockopt(1 2f 80d3000 11) on fd 208 [1:1:1]
[main] Setsockopt(1 2e 80d3000 b4) on fd 213 [1:2:1]
[main] Setsockopt(1 8 80d3000 4) on fd 214 [1:2:1]
[main] Setsockopt(1 1 80d3000 82) on fd 215 [1:2:1]
[main] Setsockopt(1 21 80d3000 6) on fd 216 [1:2:1]
[main] Setsockopt(10e 2 80d3000 4) on fd 217 [16:2:2]
[main] Setsockopt(1 8 80d3000 4) on fd 220 [1:5:1]
[main] Setsockopt(10e 1 80d3000 4) on fd 221 [16:3:16]
[main] Setsockopt(1 b 80d3000 4) on fd 222 [1:5:1]
[main] Setsockopt(1 2f 80d3000 d4) on fd 223 [1:1:1]
[main] Setsockopt(1 6 80d3000 4) on fd 224 [1:2:1]
[main] Setsockopt(1 29 80d3000 4) on fd 225 [1:5:1]
[main] Setsockopt(1 9 80d3000 4) on fd 227 [1:5:1]
[main] Setsockopt(1 2b 80d3000 4) on fd 228 [1:2:1]
[main] Setsockopt(1 2 80d3000 4) on fd 230 [16:2:2]
[main] Setsockopt(1 12 80d3000 4) on fd 231 [1:1:1]
[main] Setsockopt(1 12 80d3000 4) on fd 232 [16:3:16]
[main] Setsockopt(1 21 80d3000 7e) on fd 234 [16:2:15]
[main] Setsockopt(1 e 80d3000 e4) on fd 236 [1:5:1]
[main] Setsockopt(1 a 80d3000 4) on fd 238 [1:2:1]
[main] Setsockopt(1 9 80d3000 4) on fd 239 [1:2:1]
[main] Setsockopt(1 2a 80d3000 4) on fd 240 [1:2:1]
[main] Setsockopt(1 c 80d3000 ed) on fd 243 [16:3:2]
[main] Setsockopt(1 2d 80d3000 4) on fd 244 [1:1:1]
[main] Setsockopt(1 b 80d3000 4) on fd 248 [16:2:16]
[main] Setsockopt(1 f 80d3000 4) on fd 250 [1:5:1]
[main] Setsockopt(10e 5 80d3000 10) on fd 255 [16:3:2]
[main] Setsockopt(1 2b 80d3000 4) on fd 256 [1:5:1]
[main] Setsockopt(10e 5 80d3000 4) on fd 257 [16:3:4]
[main] Setsockopt(10e 5 80d3000 4) on fd 259 [16:2:16]
[main] Setsockopt(1 c 80d3000 5c) on fd 261 [1:1:1]
[main] Setsockopt(10e 3 80d3000 4) on fd 262 [16:3:2]
[main] Setsockopt(1 1d 80d3000 7c) on fd 264 [1:5:1]
[main] Setsockopt(1 20 80d3000 3a) on fd 265 [1:2:1]
[main] Setsockopt(1 d 80d3000 8) on fd 266 [1:5:1]
[main] Setsockopt(1 12 80d3000 4) on fd 267 [1:5:1]
[main] Setsockopt(1 f 80d3000 4) on fd 268 [1:1:1]
[main] Setsockopt(1 f 80d3000 4) on fd 269 [1:1:1]
[main] Setsockopt(1 2b 80d3000 4) on fd 270 [1:1:1]
[main] Setsockopt(1 5 80d3000 4) on fd 273 [1:5:1]
[main] Setsockopt(1 9 80d3000 16) on fd 274 [1:2:1]
[main] Setsockopt(10e 3 80d3000 4) on fd 276 [16:3:0]
[main] Setsockopt(1 2b 80d3000 68) on fd 277 [1:2:1]
[main] Setsockopt(1 24 80d3000 3d) on fd 278 [1:5:1]
[main] Setsockopt(1 9 80d3000 4) on fd 281 [1:1:1]
[main] Setsockopt(1 5 80d3000 9d) on fd 282 [1:2:1]
[main] Setsockopt(1 10 80d3000 a1) on fd 283 [1:2:1]
[main] Setsockopt(10e 5 80d3000 bc) on fd 285 [16:2:4]
[main] Setsockopt(1 2a 80d3000 4d) on fd 286 [1:1:1]
[main] Setsockopt(1 23 80d3000 5a) on fd 287 [16:2:4]
[main] Setsockopt(1 9 80d3000 87) on fd 290 [1:1:1]
[main] Setsockopt(1 b 80d3000 4) on fd 295 [1:5:1]
[main] Setsockopt(1 28 80d3000 57) on fd 296 [1:1:1]
[main] Setsockopt(1 7 80d3000 4) on fd 297 [1:2:1]
[main] Setsockopt(1 10 80d3000 4) on fd 298 [16:2:2]
[main] Setsockopt(1 5 80d3000 4) on fd 299 [1:5:1]
[main] Setsockopt(1 29 80d3000 fc) on fd 300 [1:5:1]
[main] Setsockopt(1 2 80d3000 20) on fd 301 [1:5:1]
[main] Setsockopt(1 14 80d3000 8) on fd 302 [1:2:1]
[main] Setsockopt(1 22 80d3000 4) on fd 303 [1:2:1]
[main] Setsockopt(1 e 80d3000 19) on fd 304 [1:2:1]
[main] Setsockopt(1 2b 80d3000 d9) on fd 307 [1:5:1]
[main] Setsockopt(1 21 80d3000 4) on fd 309 [1:2:1]
[main] Setsockopt(1 2d 80d3000 de) on fd 310 [1:2:1]
[main] Setsockopt(1 2 80d3000 4e) on fd 311 [1:5:1]
[main] Setsockopt(1 2f 80d3000 ed) on fd 312 [1:1:1]
[main] Setsockopt(1 14 80d3000 8) on fd 315 [1:2:1]
[main] Setsockopt(1 23 80d3000 9d) on fd 316 [1:5:1]
[main] Setsockopt(1 28 80d3000 4) on fd 318 [1:1:1]
[main] Setsockopt(1 a 80d3000 e2) on fd 319 [1:5:1]
[main] Setsockopt(1 9 80d3000 9e) on fd 321 [1:2:1]
[main] Setsockopt(10e 3 80d3000 38) on fd 322 [16:3:15]
[main] Setsockopt(1 2f 80d3000 4) on fd 323 [1:5:1]
[main] Setsockopt(1 23 80d3000 4) on fd 324 [1:5:1]
[main] Setsockopt(1 a 80d3000 ab) on fd 325 [1:1:1]
[main] Setsockopt(1 e 80d3000 4) on fd 327 [1:5:1]
[main] Setsockopt(1 a 80d3000 5e) on fd 328 [1:1:1]
[main] Setsockopt(10e 4 80d3000 4) on fd 329 [16:3:2]
[main] Setsockopt(1 22 80d3000 4) on fd 330 [1:5:1]
[main] Setsockopt(1 8 80d3000 4) on fd 331 [1:2:1]
[main] Setsockopt(1 9 80d3000 4) on fd 333 [1:2:1]
[main] Setsockopt(1 e 80d3000 7) on fd 334 [1:5:1]
[main] Setsockopt(1 f 80d3000 85) on fd 335 [1:5:1]
[main] Setsockopt(1 1 80d3000 4) on fd 339 [1:1:1]
[main] Setsockopt(1 9 80d3000 2b) on fd 340 [1:5:1]
[main] Setsockopt(1 2f 80d3000 d) on fd 343 [1:2:1]
[main] Setsockopt(1 f 80d3000 8c) on fd 344 [1:5:1]
[main] Setsockopt(1 21 80d3000 c7) on fd 345 [1:2:1]
[main] Setsockopt(1 25 80d3000 4) on fd 349 [16:2:4]
[main] Setsockopt(1 10 80d3000 84) on fd 350 [1:2:1]
[main] Setsockopt(1 2c 80d3000 12) on fd 352 [1:2:1]
[main] Setsockopt(1 2a 80d3000 32) on fd 353 [1:2:1]
[main] Setsockopt(1 23 80d3000 4) on fd 354 [1:2:1]
[main] Setsockopt(10e 3 80d3000 4) on fd 355 [16:3:15]
[main] Setsockopt(1 20 80d3000 4) on fd 357 [1:2:1]
[main] Setsockopt(1 6 80d3000 4) on fd 358 [1:1:1]
[main] Setsockopt(10e 1 80d3000 5f) on fd 361 [16:3:15]
[main] Setsockopt(1 2a 80d3000 2d) on fd 362 [1:2:1]
[main] Setsockopt(1 2c 80d3000 4) on fd 364 [1:2:1]
[main] Setsockopt(1 28 80d3000 39) on fd 365 [1:1:1]
[main] Setsockopt(1 29 80d3000 3a) on fd 367 [1:5:1]
[main] Setsockopt(1 28 80d3000 39) on fd 370 [1:1:1]
[main] Setsockopt(1 2c 80d3000 4) on fd 371 [16:2:2]
[main] Setsockopt(1 22 80d3000 4) on fd 372 [1:2:1]
[main] Setsockopt(1 c 80d3000 4) on fd 373 [1:1:1]
[main] Setsockopt(1 1 80d3000 4) on fd 375 [1:2:1]
[main] Setsockopt(10e 3 80d3000 f8) on fd 378 [16:3:2]
[main] Setsockopt(1 e 80d3000 1b) on fd 380 [16:3:0]
[main] Setsockopt(1 5 80d3000 4) on fd 381 [1:1:1]
[main] 375 sockets created based on info from socket cachefile.
[main] Generating file descriptors
[main] Added 302 filenames from /dev
[main] Added 7320 filenames from /proc
[main] Added 10730 filenames from /sys
[child0:266] ipc (117) returned ENOSYS, marking as inactive.
[child1:267] getuid16 (24) returned ENOSYS, marking as inactive.
[child1:267] ioprio_set (289) returned ENOSYS, marking as inactive.
[child1:267] mq_open (277) returned ENOSYS, marking as inactive.
[child1:267] open_by_handle_at (342) returned ENOSYS, marking as inactive.
[child1:267] signalfd4 (327) returned ENOSYS, marking as inactive.
[child1:267] eventfd (323) returned ENOSYS, marking as inactive.
[child1:267] getgroups16 (80) returned ENOSYS, marking as inactive.
[child1:267] getegid16 (50) returned ENOSYS, marking as inactive.
[child1:267] fanotify_init (338) returned ENOSYS, marking as inactive.
[child0:266] process_vm_readv (347) returned ENOSYS, marking as inactive.
[child1:267] setuid16 (23) returned ENOSYS, marking as inactive.
[child1:267] vm86 (166) returned ENOSYS, marking as inactive.
[child1:267] finit_module (350) returned ENOSYS, marking as inactive.
[child1:267] getresuid16 (165) returned ENOSYS, marking as inactive.
[child1:267] nfsservctl (169) returned ENOSYS, marking as inactive.
[child1:267] ioprio_get (290) returned ENOSYS, marking as inactive.
[child1:267] lchown16 (16) returned ENOSYS, marking as inactive.
[child1:267] vm86old (113) returned ENOSYS, marking as inactive.
[watchdog] Watchdog is alive. (pid:257)
*** glibc detected *** /trinity: double free or corruption (out): 0x0867300=
0 ***
=3D=3D=3D=3D=3D=3D=3D Backtrace: =3D=3D=3D=3D=3D=3D=3D=3D=3D
/lib/i386-linux-gnu/libc.so.6(+0x73e42)[0xb7699e42]
/trinity[0x8058af6]
/trinity[0x8051888]
/trinity[0x8054894]
/trinity[0x804a9f5]
/trinity[0x804e3be]
/trinity[0x804a085]
/lib/i386-linux-gnu/libc.so.6(__libc_start_main+0xf3)[0xb763f4d3]
/trinity[0x804a594]
=3D=3D=3D=3D=3D=3D=3D Memory map: =3D=3D=3D=3D=3D=3D=3D=3D
08048000-0806d000 r-xp 00000000 00:00 6339       /trinity
0806d000-080ca000 rw-p 00025000 00:00 6339       /trinity
080ca000-084ea000 rw-p 00000000 00:00 0          [heap]
084ea000-087b2000 rw-p 00000000 00:00 0          [heap]
087b2000-08899000 rw-p 00000000 00:00 0          [heap]
b425d000-b4279000 r-xp 00000000 00:00 1794       /lib/i386-linux-gnu/libgcc=
_s.so.1
b4279000-b427a000 r--p 0001b000 00:00 1794       /lib/i386-linux-gnu/libgcc=
_s.so.1
b427a000-b427b000 rw-p 0001c000 00:00 1794       /lib/i386-linux-gnu/libgcc=
_s.so.1
b427d000-b427e000 rw-p 00000000 00:00 0=20
b427e000-b4c7e000 -w-s 00000000 00:02 7429       /dev/zero (deleted)
b4c7e000-b567e000 r--s 00000000 00:02 7428       /dev/zero (deleted)
b567e000-b607e000 rw-s 00000000 00:02 7427       /dev/zero (deleted)
b607e000-b647e000 -w-s 00000000 00:02 7426       /dev/zero (deleted)
b647e000-b687e000 r--s 00000000 00:02 7425       /dev/zero (deleted)
b687e000-b6c7e000 rw-s 00000000 00:02 7424       /dev/zero (deleted)
b6c7e000-b6e7e000 -w-s 00000000 00:02 7423       /dev/zero (deleted)
b6e7e000-b707e000 r--s 00000000 00:02 7422       /dev/zero (deleted)
b707e000-b727e000 rw-s 00000000 00:02 7421       /dev/zero (deleted)
b727e000-b737e000 -w-s 00000000 00:02 7420       /dev/zero (deleted)
b737e000-b747e000 r--s 00000000 00:02 7419       /dev/zero (deleted)
b747e000-b757e000 rw-s 00000000 00:02 7418       /dev/zero (deleted)
b757e000-b7580000 -w-s 00000000 00:02 7417       /dev/zero (deleted)
b7580000-b7582000 r--s 00000000 00:02 7416       /dev/zero (deleted)
b7582000-b7584000 rw-s 00000000 00:02 7415       /dev/zero (deleted)
b7584000-b7586000 rw-p 00000000 00:00 0=20
b7586000-b75a4000 ---s 00000000 00:02 7313       /dev/zero (deleted)
b75a4000-b75b0000 rw-s 0001e000 00:02 7313       /dev/zero (deleted)
b75b0000-b75ce000 ---s 0002a000 00:02 7313       /dev/zero (deleted)
b75ce000-b7625000 rw-s 00000000 00:02 7312       /dev/zero (deleted)
b7625000-b7626000 rw-p 00000000 00:00 0=20
b7626000-b77c5000 r-xp 00000000 00:00 1780       /lib/i386-linux-gnu/libc-2=
=2E15.so
b77c5000-b77c7000 r--p 0019f000 00:00 1780       /lib/i386-linux-gnu/libc-2=
=2E15.so
b77c7000-b77c8000 rw-p 001a1000 00:00 1780       /lib/i386-linux-gnu/libc-2=
=2E15.so
b77c8000-b77cc000 rw-p 00000000 00:00 0=20
b77cc000-b77cf000 rw-p 00000000 00:00 0=20
b77cf000-b77ef000 r-xp 00000000 00:00 1881       /lib/i386-linux-gnu/ld-2.1=
5.so
b77ef000-b77f0000 r--p 0001f000 00:00 1881       /lib/i386-linux-gnu/ld-2.1=
5.so
b77f0000-b77f1000 rw-p 00020000 00:00 1881       /lib/i386-linux-gnu/ld-2.1=
5.so
bfc41000-bfc62000 rw-p 00000000 00:00 0          [stack]
ffffe000-fffff000 r-xp 00000000 00:00 0          [vdso]
[main] Random reseed: 3219938512
[child0:268] setregid16 (71) returned ENOSYS, marking as inactive.
[child0:268] name_to_handle_at (341) returned ENOSYS, marking as inactive.
[child0:268] quotactl (131) returned ENOSYS, marking as inactive.
[child1:267] bdflush (134) returned ENOSYS, marking as inactive.
[child0:268] swapoff (115) returned ENOSYS, marking as inactive.
[child0:268] uid changed! Was: 0, now -16777216
[child1:267] child exiting.
Bailing main loop. Exit reason: UID changed.
[watchdog] [257] Watchdog exiting
[init]=20
Ran 167 syscalls. Successes: 44  Failures: 121
[   67.157146] spin_lock-torture: Writes:  Total: 4  Max/Min: 0/0   Fail: 0=
=20
error: 'rc.local' exited outside the expected code flow.
 * Asking all remaining processes to terminate...      =20
 * All processes ended within 1 seconds....      =20
 * Deactivating swap...      =20
umount: /run/lock: not mounted
 * Will now restart
[   72.870296] spin_lock-torture: Unscheduled system shutdown detected
[   72.873276] reboot: Restarting system
Elapsed time: 80
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig-s=
t0-02210812/0964c4d936f53872725d96bb04d490a70aa1165a/vmlinuz-3.14.0-rc3-wl-=
01929-g0964c4d -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debu=
g apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=3D1 nmi_wat=
chdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=
=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/kvm/i386-rand=
config-st0-02210812/linux-devel:devel-hourly-2014022108/.vmlinuz-0964c4d936=
f53872725d96bb04d490a70aa1165a-20140221091456-9-stoakley branch=3Dlinux-dev=
el/devel-hourly-2014022108 BOOT_IMAGE=3D/kernel/i386-randconfig-st0-0221081=
2/0964c4d936f53872725d96bb04d490a70aa1165a/vmlinuz-3.14.0-rc3-wl-01929-g096=
4c4d'  -initrd /kernel-tests/initrd/quantal-core-i386.cgz -m 320 -smp 2 -ne=
t nic,vlan=3D1,model=3De1000 -net user,vlan=3D1,hostfwd=3Dtcp::20365-:22 -b=
oot order=3Dnc -no-reboot -watchdog i6300esb -rtc base=3Dlocaltime -drive f=
ile=3D/fs/LABEL=3DKVM/disk0-quantal-stoakley-5,media=3Ddisk,if=3Dvirtio -dr=
ive file=3D/fs/LABEL=3DKVM/disk1-quantal-stoakley-5,media=3Ddisk,if=3Dvirti=
o -drive file=3D/fs/LABEL=3DKVM/disk2-quantal-stoakley-5,media=3Ddisk,if=3D=
virtio -drive file=3D/fs/LABEL=3DKVM/disk3-quantal-stoakley-5,media=3Ddisk,=
if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk4-quantal-stoakley-5,media=3D=
disk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk5-quantal-stoakley-5,med=
ia=3Ddisk,if=3Dvirtio -pidfile /dev/shm/kboot/pid-quantal-stoakley-5 -seria=
l file:/dev/shm/kboot/serial-quantal-stoakley-5 -daemonize -display none -m=
onitor null=20

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.14.0-rc3-wl-01929-g0964c4d"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.14.0-rc3 Kernel Configuration
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
CONFIG_X86_32_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
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
CONFIG_KERNEL_BZIP2=y
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_FHANDLE is not set
# CONFIG_AUDIT is not set

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
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
CONFIG_TICK_ONESHOT=y
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

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
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
CONFIG_RCU_FANOUT_EXACT=y
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_NOCB_CPU is not set
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_ARCH_USES_NUMA_PROT_NONE=y
CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
CONFIG_NUMA_BALANCING=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_DEVICE is not set
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_RESOURCE_COUNTERS is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
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
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
# CONFIG_SIGNALFD is not set
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_COMPAT_BRK=y
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
CONFIG_PROFILING=y
CONFIG_OPROFILE=y
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
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
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
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
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
# CONFIG_BLOCK is not set
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
# CONFIG_X86_BIGSMP is not set
CONFIG_GOLDFISH=y
CONFIG_X86_EXTENDED_PLATFORM=y
CONFIG_X86_GOLDFISH=y
CONFIG_X86_INTEL_CE=y
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_RDC321X is not set
CONFIG_X86_32_NON_STANDARD=y
CONFIG_X86_NUMAQ=y
CONFIG_X86_VISWS=y
# CONFIG_STA2X11 is not set
# CONFIG_X86_SUMMIT is not set
CONFIG_X86_32_IRIS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
CONFIG_X86_SUMMIT_NUMA=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
CONFIG_MCRUSOE=y
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
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=5
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
CONFIG_NR_CPUS=8
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_VISWS_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=y
# CONFIG_X86_ANCIENT_MCE is not set
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
# CONFIG_VM86 is not set
# CONFIG_TOSHIBA is not set
# CONFIG_I8K is not set
CONFIG_X86_REBOOTFIXUPS=y
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
CONFIG_HIGHMEM64G=y
CONFIG_VMSPLIT_3G=y
# CONFIG_VMSPLIT_2G is not set
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0xC0000000
CONFIG_HIGHMEM=y
CONFIG_X86_PAE=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_NUMA=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=4
CONFIG_ARCH_HAVE_MEMORY_PRESENT=y
CONFIG_NEED_NODE_MEMMAP_SIZE=y
CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_DISCONTIGMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_DISCONTIGMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_CLEANCACHE=y
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
# CONFIG_HIGHPTE is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
# CONFIG_MTRR is not set
CONFIG_ARCH_RANDOM=y
# CONFIG_X86_SMAP is not set
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
CONFIG_DEBUG_HOTPLUG_CPU0=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
CONFIG_PM_WAKELOCKS_GC=y
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_NUMA is not set
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_APEI is not set
# CONFIG_ACPI_EXTLOG is not set
# CONFIG_SFI is not set
CONFIG_X86_APM_BOOT=y
CONFIG_APM=y
# CONFIG_APM_IGNORE_USER_SUSPEND is not set
# CONFIG_APM_DO_ENABLE is not set
# CONFIG_APM_CPU_IDLE is not set
CONFIG_APM_DISPLAY_BLANK=y
# CONFIG_APM_ALLOW_INTS is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

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
CONFIG_PCI_GODIRECT=y
# CONFIG_PCI_GOANY is not set
CONFIG_PCI_DIRECT=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
CONFIG_PCIEASPM=y
CONFIG_PCIEASPM_DEBUG=y
# CONFIG_PCIEASPM_DEFAULT is not set
# CONFIG_PCIEASPM_POWERSAVE is not set
CONFIG_PCIEASPM_PERFORMANCE=y
CONFIG_PCIE_PME=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
# CONFIG_HT_IRQ is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
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
# CONFIG_EISA_PCI_EISA is not set
CONFIG_EISA_VIRTUAL_ROOT=y
# CONFIG_EISA_NAMES is not set
CONFIG_SCx200=y
CONFIG_SCx200HR_TIMER=y
CONFIG_ALIX=y
# CONFIG_NET5501 is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
CONFIG_PD6729=y
CONFIG_I82092=y
# CONFIG_I82365 is not set
CONFIG_TCIC=y
CONFIG_PCMCIA_PROBE=y
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_ACPI is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=y
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
# CONFIG_BINFMT_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_NET_MPLS_GSO is not set
# CONFIG_HSR is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set

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
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
CONFIG_DTC=y
CONFIG_OF=y

#
# Device Tree and Open Firmware support
#
# CONFIG_PROC_DEVICETREE is not set
# CONFIG_OF_SELFTEST is not set
CONFIG_OF_FLATTREE=y
CONFIG_OF_EARLY_FLATTREE=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
# CONFIG_PARPORT is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
# CONFIG_ISAPNP is not set
# CONFIG_PNPBIOS is not set
CONFIG_PNPACPI=y

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
CONFIG_PHANTOM=y
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ATMEL_SSC=y
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_CS5535_MFGPT=y
CONFIG_CS5535_MFGPT_DEFAULT_IRQ=7
CONFIG_CS5535_CLOCK_EVENT_SRC=y
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
# CONFIG_ISL29003 is not set
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
CONFIG_TI_DAC7512=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
# CONFIG_BMP085_SPI is not set
CONFIG_PCH_PHUB=y
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_LATTICE_ECP3_CONFIG=y
CONFIG_SRAM=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_EEPROM_93XX46 is not set
CONFIG_CB710_CORE=y
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_VMWARE_VMCI=y

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
CONFIG_FIREWIRE_NOSY=y
CONFIG_I2O=y
CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=y
# CONFIG_I2O_EXT_ADAPTEC is not set
CONFIG_I2O_CONFIG=y
CONFIG_I2O_CONFIG_OLD_IOCTL=y
# CONFIG_I2O_BUS is not set
CONFIG_I2O_PROC=y
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
# CONFIG_NETDEVICES is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_GOLDFISH_EVENTS is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_STMPE is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_INPUT_MOUSE is not set
CONFIG_INPUT_JOYSTICK=y
# CONFIG_JOYSTICK_ANALOG is not set
CONFIG_JOYSTICK_A3D=y
CONFIG_JOYSTICK_ADI=y
CONFIG_JOYSTICK_COBRA=y
CONFIG_JOYSTICK_GF2K=y
CONFIG_JOYSTICK_GRIP=y
# CONFIG_JOYSTICK_GRIP_MP is not set
# CONFIG_JOYSTICK_GUILLEMOT is not set
# CONFIG_JOYSTICK_INTERACT is not set
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
CONFIG_JOYSTICK_IFORCE=y
# CONFIG_JOYSTICK_IFORCE_USB is not set
# CONFIG_JOYSTICK_IFORCE_232 is not set
# CONFIG_JOYSTICK_WARRIOR is not set
CONFIG_JOYSTICK_MAGELLAN=y
# CONFIG_JOYSTICK_SPACEORB is not set
CONFIG_JOYSTICK_SPACEBALL=y
CONFIG_JOYSTICK_STINGER=y
CONFIG_JOYSTICK_TWIDJOY=y
CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_JOYSTICK_AS5011=y
# CONFIG_JOYSTICK_JOYDUMP is not set
CONFIG_JOYSTICK_XPAD=y
# CONFIG_JOYSTICK_XPAD_FF is not set
CONFIG_JOYSTICK_XPAD_LEDS=y
# CONFIG_INPUT_TABLET is not set
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
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
# CONFIG_SERIO_APBPS2 is not set
CONFIG_SERIO_OLPC_APSP=y
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
CONFIG_GAMEPORT_EMU10K1=y
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
# CONFIG_GOLDFISH_TTY is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_MRST_MAX3110 is not set
# CONFIG_SERIAL_MFD_HSU is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_OF_PLATFORM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_TTY_PRINTK is not set
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
# CONFIG_HW_RANDOM_INTEL is not set
CONFIG_HW_RANDOM_AMD=y
# CONFIG_HW_RANDOM_GEODE is not set
# CONFIG_HW_RANDOM_VIA is not set
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
CONFIG_DTLK=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
CONFIG_SONYPI=y

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
# CONFIG_MWAVE is not set
CONFIG_SCx200_GPIO=y
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
# CONFIG_I2C_MUX is not set
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
# CONFIG_I2C_AMD756_S4882 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_NFORCE2_S4985=y
CONFIG_I2C_SIS5595=y
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_EG20T=y
CONFIG_I2C_GPIO=y
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=y
CONFIG_I2C_PXA=y
CONFIG_I2C_PXA_PCI=y
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y
# CONFIG_I2C_VIPERBOARD is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_PCA_ISA is not set
CONFIG_SCx200_I2C=y
CONFIG_SCx200_I2C_SCL=12
CONFIG_SCx200_I2C_SDA=13
CONFIG_SCx200_ACB=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
CONFIG_SPI_DEBUG=y
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_GPIO=y
# CONFIG_SPI_FSL_SPI is not set
CONFIG_SPI_OC_TINY=y
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_SC18IS602 is not set
CONFIG_SPI_TOPCLIFF_PCH=y
CONFIG_SPI_XCOMM=y
# CONFIG_SPI_XILINX is not set
CONFIG_SPI_DESIGNWARE=y
CONFIG_SPI_DW_PCI=y
# CONFIG_SPI_DW_MMIO is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_DEBUG_GPIO=y
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_DA9052=y
# CONFIG_GPIO_DA9055 is not set
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_IT8761E is not set
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_SCH311X=y
CONFIG_GPIO_TS5500=y
# CONFIG_GPIO_SCH is not set
CONFIG_GPIO_ICH=y
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_GRGPIO=y

#
# I2C GPIO expanders:
#
CONFIG_GPIO_ARIZONA=y
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
# CONFIG_GPIO_PCA953X is not set
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_RC5T583=y
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_STMPE is not set
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_WM831X=y
CONFIG_GPIO_ADP5520=y
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
# CONFIG_GPIO_ADNP is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_CS5535 is not set
# CONFIG_GPIO_BT8XX is not set
CONFIG_GPIO_AMD8111=y
CONFIG_GPIO_INTEL_MID=y
# CONFIG_GPIO_PCH is not set
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_SODAVILLE=y
# CONFIG_GPIO_TIMBERDALE is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MCP23S08 is not set
CONFIG_GPIO_MC33880=y
CONFIG_GPIO_74X164=y

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
CONFIG_GPIO_JANZ_TTL=y
CONFIG_GPIO_PALMAS=y
CONFIG_GPIO_TPS6586X=y
# CONFIG_GPIO_TPS65910 is not set
CONFIG_GPIO_BCM_KONA=y

#
# USB GPIO expanders:
#
CONFIG_GPIO_VIPERBOARD=y
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
# CONFIG_W1_SLAVE_SMEM is not set
# CONFIG_W1_SLAVE_DS2408 is not set
CONFIG_W1_SLAVE_DS2413=y
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=y
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
# CONFIG_W1_SLAVE_BQ27000 is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
# CONFIG_GENERIC_ADC_BATTERY is not set
# CONFIG_MAX8925_POWER is not set
CONFIG_WM831X_BACKUP=y
# CONFIG_WM831X_POWER is not set
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_DS2760=y
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=y
# CONFIG_BATTERY_DS2782 is not set
CONFIG_BATTERY_SBS=y
# CONFIG_BATTERY_BQ27x00 is not set
CONFIG_BATTERY_DA9030=y
# CONFIG_BATTERY_DA9052 is not set
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
# CONFIG_CHARGER_LP8727 is not set
CONFIG_CHARGER_LP8788=y
CONFIG_CHARGER_GPIO=y
CONFIG_CHARGER_MAX14577=y
# CONFIG_CHARGER_BQ2415X is not set
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24735=y
# CONFIG_CHARGER_SMB347 is not set
CONFIG_BATTERY_GOLDFISH=y
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_DA9055=y
CONFIG_SENSORS_I5K_AMB=y
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
# CONFIG_SENSORS_GL518SM is not set
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_HTU21=y
CONFIG_SENSORS_CORETEMP=y
# CONFIG_SENSORS_IBMAEM is not set
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IIO_HWMON=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LM63=y
# CONFIG_SENSORS_LM70 is not set
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=y
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
# CONFIG_SENSORS_MAX6650 is not set
CONFIG_SENSORS_MAX6697=y
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_NTC_THERMISTOR=y
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_PCF8591 is not set
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
# CONFIG_SENSORS_LM25066 is not set
CONFIG_SENSORS_LTC2978=y
CONFIG_SENSORS_MAX16064=y
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
CONFIG_SENSORS_UCD9000=y
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
# CONFIG_SENSORS_TMP401 is not set
CONFIG_SENSORS_TMP421=y
# CONFIG_SENSORS_VIA_CPUTEMP is not set
CONFIG_SENSORS_VIA686A=y
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=y
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
CONFIG_SENSORS_WM831X=y
CONFIG_SENSORS_APPLESMC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_OF=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_ACPI_INT3403_THERMAL is not set

#
# Texas Instruments thermal drivers
#
# CONFIG_WATCHDOG is not set
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
# CONFIG_SSB_PCMCIAHOST is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
CONFIG_SSB_SILENT=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
CONFIG_MFD_AS3711=y
CONFIG_MFD_AS3722=y
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
# CONFIG_MFD_CROS_EC_SPI is not set
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
# CONFIG_MFD_DA9052_I2C is not set
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9063=y
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_MFD_JANZ_CMODIO=y
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77686=y
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
CONFIG_EZX_PCAP=y
CONFIG_MFD_VIPERBOARD=y
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
CONFIG_MFD_RTSX_PCI=y
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_STMPE=y

#
# STMicroelectronics STMPE Interface Drivers
#
# CONFIG_STMPE_I2C is not set
# CONFIG_STMPE_SPI is not set
# CONFIG_MFD_SYSCON is not set
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP3943 is not set
CONFIG_MFD_LP8788=y
CONFIG_MFD_PALMAS=y
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS65912_SPI is not set
CONFIG_MFD_TPS80031=y
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=y
CONFIG_MFD_TIMBERDALE=y
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
# CONFIG_MFD_WM5102 is not set
# CONFIG_MFD_WM5110 is not set
CONFIG_MFD_WM8997=y
# CONFIG_MFD_WM8400 is not set
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM831X_SPI=y
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=y
# CONFIG_AGP_ALI is not set
CONFIG_AGP_ATI=y
CONFIG_AGP_AMD=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
# CONFIG_AGP_NVIDIA is not set
CONFIG_AGP_SIS=y
# CONFIG_AGP_SWORKS is not set
CONFIG_AGP_VIA=y
CONFIG_AGP_EFFICEON=y
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_USB=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=y

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
CONFIG_DRM_I2C_SIL164=y
CONFIG_DRM_I2C_NXP_TDA998X=y
CONFIG_DRM_TDFX=y
CONFIG_DRM_R128=y
CONFIG_DRM_RADEON=y
# CONFIG_DRM_RADEON_UMS is not set
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
CONFIG_DRM_NOUVEAU_BACKLIGHT=y
# CONFIG_DRM_I810 is not set
CONFIG_DRM_I915=y
CONFIG_DRM_I915_KMS=y
# CONFIG_DRM_I915_FBDEV is not set
# CONFIG_DRM_I915_PRELIMINARY_HW_SUPPORT is not set
CONFIG_DRM_I915_UMS=y
CONFIG_DRM_MGA=y
CONFIG_DRM_SIS=y
CONFIG_DRM_VIA=y
CONFIG_DRM_SAVAGE=y
CONFIG_DRM_VMWGFX=y
# CONFIG_DRM_VMWGFX_FBCON is not set
# CONFIG_DRM_GMA500 is not set
CONFIG_DRM_UDL=y
CONFIG_DRM_AST=y
# CONFIG_DRM_MGAG200 is not set
CONFIG_DRM_CIRRUS_QEMU=y
# CONFIG_DRM_QXL is not set
CONFIG_DRM_BOCHS=y
CONFIG_VGASTATE=y
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_HDMI=y
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
CONFIG_FB_IMSTT=y
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
# CONFIG_FB_N411 is not set
CONFIG_FB_HGA=y
CONFIG_FB_SGIVW=y
CONFIG_FB_GBE=y
CONFIG_FB_GBE_MEM=4
CONFIG_FB_OPENCORES=y
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
CONFIG_FB_RIVA=y
# CONFIG_FB_RIVA_I2C is not set
CONFIG_FB_RIVA_DEBUG=y
CONFIG_FB_RIVA_BACKLIGHT=y
CONFIG_FB_I740=y
# CONFIG_FB_I810 is not set
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
CONFIG_FB_MATROX=y
# CONFIG_FB_MATROX_MILLENIUM is not set
CONFIG_FB_MATROX_MYSTIQUE=y
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=y
CONFIG_FB_MATROX_MAVEN=y
# CONFIG_FB_RADEON is not set
CONFIG_FB_ATY128=y
CONFIG_FB_ATY128_BACKLIGHT=y
CONFIG_FB_ATY=y
# CONFIG_FB_ATY_CT is not set
# CONFIG_FB_ATY_GX is not set
CONFIG_FB_ATY_BACKLIGHT=y
CONFIG_FB_S3=y
CONFIG_FB_S3_DDC=y
CONFIG_FB_SAVAGE=y
# CONFIG_FB_SAVAGE_I2C is not set
CONFIG_FB_SAVAGE_ACCEL=y
CONFIG_FB_SIS=y
# CONFIG_FB_SIS_300 is not set
CONFIG_FB_SIS_315=y
CONFIG_FB_VIA=y
CONFIG_FB_VIA_DIRECT_PROCFS=y
CONFIG_FB_VIA_X_COMPATIBILITY=y
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
# CONFIG_FB_3DFX_ACCEL is not set
# CONFIG_FB_3DFX_I2C is not set
CONFIG_FB_VOODOO1=y
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
CONFIG_FB_ARK=y
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
CONFIG_FB_GEODE=y
CONFIG_FB_GEODE_LX=y
CONFIG_FB_GEODE_GX=y
# CONFIG_FB_GEODE_GX1 is not set
# CONFIG_FB_TMIO is not set
# CONFIG_FB_SMSCUFX is not set
CONFIG_FB_UDL=y
# CONFIG_FB_GOLDFISH is not set
CONFIG_FB_VIRTUAL=y
# CONFIG_FB_METRONOME is not set
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
# CONFIG_FB_MB862XX_I2C is not set
CONFIG_FB_BROADSHEET=y
CONFIG_FB_AUO_K190X=y
CONFIG_FB_AUO_K1900=y
CONFIG_FB_AUO_K1901=y
CONFIG_FB_SIMPLE=y
CONFIG_EXYNOS_VIDEO=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_L4F00242T03 is not set
CONFIG_LCD_LMS283GF05=y
CONFIG_LCD_LTV350QV=y
CONFIG_LCD_ILI922X=y
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
CONFIG_LCD_S6E63M0=y
CONFIG_LCD_LD9040=y
CONFIG_LCD_AMS369FG06=y
# CONFIG_LCD_LMS501KF03 is not set
CONFIG_LCD_HX8357=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_LM3533 is not set
CONFIG_BACKLIGHT_CARILLO_RANCH=y
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_DA903X=y
CONFIG_BACKLIGHT_DA9052=y
CONFIG_BACKLIGHT_MAX8925=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=y
# CONFIG_BACKLIGHT_WM831X is not set
# CONFIG_BACKLIGHT_ADP5520 is not set
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
# CONFIG_BACKLIGHT_LM3630A is not set
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_LP8788=y
CONFIG_BACKLIGHT_AS3711=y
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_LOGO is not set
# CONFIG_FB_SSD1307 is not set
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
CONFIG_HID_ACRUX=y
CONFIG_HID_ACRUX_FF=y
# CONFIG_HID_APPLE is not set
CONFIG_HID_APPLEIR=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CYPRESS is not set
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
CONFIG_HID_ELO=y
CONFIG_HID_EZKEY=y
CONFIG_HID_HOLTEK=y
# CONFIG_HOLTEK_FF is not set
# CONFIG_HID_HUION is not set
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
CONFIG_HID_UCLOGIC=y
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LENOVO_TPKBD=y
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=y
CONFIG_LOGITECH_FF=y
CONFIG_LOGIRUMBLEPAD2_FF=y
CONFIG_LOGIG940_FF=y
CONFIG_LOGIWHEELS_FF=y
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MICROSOFT is not set
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTRIG is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PRIMAX is not set
CONFIG_HID_ROCCAT=y
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
# CONFIG_HID_SONY is not set
# CONFIG_HID_SPEEDLINK is not set
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THINGM=y
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
# CONFIG_HID_ZEROPLUS is not set
CONFIG_HID_ZYDACRON=y
CONFIG_HID_SENSOR_HUB=y

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG=y
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB=y
CONFIG_USB_WUSB_CBAF=y
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_EHCI_HCD=y
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1362_HCD=y
# CONFIG_USB_FUSBH200_HCD is not set
CONFIG_USB_FOTG210_HCD=y
# CONFIG_USB_OHCI_HCD is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_SL811_HCD is not set
CONFIG_USB_R8A66597_HCD=y
# CONFIG_USB_RENESAS_USBHS_HCD is not set
CONFIG_USB_WHCI_HCD=y
# CONFIG_USB_HWA_HCD is not set
CONFIG_USB_HCD_SSB=y
CONFIG_USB_HCD_TEST_MODE=y
CONFIG_USB_RENESAS_USBHS=y

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
CONFIG_USB_MUSB_HDRC=y
# CONFIG_USB_MUSB_HOST is not set
CONFIG_USB_MUSB_GADGET=y
# CONFIG_USB_MUSB_DUAL_ROLE is not set
CONFIG_USB_MUSB_TUSB6010=y
# CONFIG_USB_MUSB_DSPS is not set
# CONFIG_USB_MUSB_UX500 is not set
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_HOST=y
# CONFIG_USB_DWC3_GADGET is not set
# CONFIG_USB_DWC3_DUAL_ROLE is not set

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_EXYNOS=y
CONFIG_USB_DWC3_PCI=y
# CONFIG_USB_DWC3_KEYSTONE is not set

#
# Debugging features
#
CONFIG_USB_DWC3_DEBUG=y
CONFIG_USB_DWC3_VERBOSE=y
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
# CONFIG_USB_ADUTUX is not set
CONFIG_USB_SEVSEG=y
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=y
# CONFIG_USB_LCD is not set
CONFIG_USB_LED=y
CONFIG_USB_CYPRESS_CY7C63=y
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_IDMOUSE=y
# CONFIG_USB_FTDI_ELAN is not set
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
# CONFIG_USB_LD is not set
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HSIC_USB3503 is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
# CONFIG_USB_OTG_FSM is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_SAMSUNG_USB2PHY is not set
# CONFIG_SAMSUNG_USB3PHY is not set
CONFIG_USB_GPIO_VBUS=y
CONFIG_USB_ISP1301=y
CONFIG_USB_RCAR_PHY=y
CONFIG_USB_GADGET=y
CONFIG_USB_GADGET_DEBUG=y
# CONFIG_USB_GADGET_VERBOSE is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_FOTG210_UDC=y
# CONFIG_USB_GR_UDC is not set
CONFIG_USB_R8A66597=y
CONFIG_USB_RENESAS_USBHS_UDC=y
CONFIG_USB_PXA27X=y
CONFIG_USB_MV_UDC=y
CONFIG_USB_MV_U3D=y
# CONFIG_USB_M66592 is not set
CONFIG_USB_AMD5536UDC=y
CONFIG_USB_NET2272=y
CONFIG_USB_NET2272_DMA=y
CONFIG_USB_NET2280=y
CONFIG_USB_GOKU=y
CONFIG_USB_EG20T=y
CONFIG_USB_DUMMY_HCD=y
# CONFIG_USB_CONFIGFS is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
CONFIG_USB_GADGETFS=y
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
CONFIG_UWB=y
CONFIG_UWB_HWA=y
CONFIG_UWB_WHCI=y
# CONFIG_UWB_I1480U is not set
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
# CONFIG_MMC_UNSAFE_RESUME is not set
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_PCI=y
CONFIG_MMC_RICOH_MMC=y
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
# CONFIG_MMC_SDHCI_OF_ARASAN is not set
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_GOLDFISH=y
CONFIG_MMC_SDRICOH_CS=y
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_VUB300=y
CONFIG_MMC_USHC=y
# CONFIG_MMC_REALTEK_PCI is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
CONFIG_MEMSTICK_JMICRON_38X=y
CONFIG_MEMSTICK_R592=y
# CONFIG_MEMSTICK_REALTEK_PCI is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_LM3530=y
# CONFIG_LEDS_LM3533 is not set
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_NET48XX=y
CONFIG_LEDS_WRAP=y
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_PCA9532_GPIO=y
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
# CONFIG_LEDS_LP8788 is not set
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
# CONFIG_LEDS_PCA9685 is not set
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_DA903X=y
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_PWM=y
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_ADP5520=y
# CONFIG_LEDS_DELL_NETBOOKS is not set
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_MAX8997 is not set
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_LEDS_TRIGGER_CAMERA=y
CONFIG_ACCESSIBILITY=y
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
# CONFIG_EDAC_DEBUG is not set
# CONFIG_EDAC_DECODE_MCE is not set
# CONFIG_EDAC_MM_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_AS3722=y
CONFIG_RTC_DRV_DS1307=y
# CONFIG_RTC_DRV_DS1374 is not set
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_DS3232=y
CONFIG_RTC_DRV_HYM8563=y
CONFIG_RTC_DRV_LP8788=y
# CONFIG_RTC_DRV_MAX6900 is not set
CONFIG_RTC_DRV_MAX8925=y
CONFIG_RTC_DRV_MAX8998=y
# CONFIG_RTC_DRV_MAX8997 is not set
CONFIG_RTC_DRV_MAX77686=y
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=y
CONFIG_RTC_DRV_ISL12057=y
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PALMAS=y
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_PCF8523=y
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
CONFIG_RTC_DRV_M41T80_WDT=y
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_TPS6586X=y
CONFIG_RTC_DRV_TPS65910=y
# CONFIG_RTC_DRV_TPS80031 is not set
CONFIG_RTC_DRV_RC5T583=y
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
# CONFIG_RTC_DRV_RX8025 is not set
# CONFIG_RTC_DRV_EM3027 is not set
CONFIG_RTC_DRV_RV3029C2=y

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=y
# CONFIG_RTC_DRV_M41T94 is not set
CONFIG_RTC_DRV_DS1305=y
# CONFIG_RTC_DRV_DS1390 is not set
CONFIG_RTC_DRV_MAX6902=y
# CONFIG_RTC_DRV_R9701 is not set
# CONFIG_RTC_DRV_RS5C348 is not set
CONFIG_RTC_DRV_DS3234=y
CONFIG_RTC_DRV_PCF2123=y
# CONFIG_RTC_DRV_RX4581 is not set

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
# CONFIG_RTC_DRV_DS1742 is not set
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_DA9055=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
# CONFIG_RTC_DRV_RP5C01 is not set
CONFIG_RTC_DRV_V3020=y
# CONFIG_RTC_DRV_DS2404 is not set
# CONFIG_RTC_DRV_WM831X is not set

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_PCAP=y
CONFIG_RTC_DRV_SNVS=y
CONFIG_RTC_DRV_MOXART=y

#
# HID Sensor RTC drivers
#
CONFIG_RTC_DRV_HID_SENSOR_TIME=y
# CONFIG_DMADEVICES is not set
CONFIG_AUXDISPLAY=y
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
CONFIG_UIO_AEC=y
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=y
# CONFIG_UIO_NETX is not set
CONFIG_UIO_MF624=y
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set
# CONFIG_USBIP_CORE is not set
# CONFIG_ECHO is not set
# CONFIG_TRANZPORT is not set
# CONFIG_DX_SEP is not set

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16201=y
CONFIG_ADIS16203=y
CONFIG_ADIS16204=y
# CONFIG_ADIS16209 is not set
CONFIG_ADIS16220=y
CONFIG_ADIS16240=y
# CONFIG_LIS3L02DQ is not set
# CONFIG_SCA3000 is not set

#
# Analog to digital converters
#
# CONFIG_AD7291 is not set
# CONFIG_AD7606 is not set
# CONFIG_AD799X is not set
# CONFIG_AD7780 is not set
CONFIG_AD7816=y
# CONFIG_AD7192 is not set
# CONFIG_AD7280 is not set

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
CONFIG_ADT7316_SPI=y
CONFIG_ADT7316_I2C=y

#
# Capacitance to digital converters
#
# CONFIG_AD7150 is not set
CONFIG_AD7152=y
CONFIG_AD7746=y

#
# Direct Digital Synthesis
#
# CONFIG_AD5930 is not set
# CONFIG_AD9832 is not set
CONFIG_AD9834=y
# CONFIG_AD9850 is not set
CONFIG_AD9852=y
# CONFIG_AD9910 is not set
# CONFIG_AD9951 is not set

#
# Digital gyroscope sensors
#
CONFIG_ADIS16060=y

#
# Network Analyzer, Impedance Converters
#
# CONFIG_AD5933 is not set

#
# Light sensors
#
CONFIG_SENSORS_ISL29018=y
# CONFIG_SENSORS_ISL29028 is not set
# CONFIG_TSL2583 is not set
# CONFIG_TSL2x7x is not set

#
# Magnetometer sensors
#
CONFIG_SENSORS_HMC5843=y

#
# Active energy metering IC
#
# CONFIG_ADE7753 is not set
CONFIG_ADE7754=y
CONFIG_ADE7758=y
# CONFIG_ADE7759 is not set
# CONFIG_ADE7854 is not set

#
# Resolver to digital converters
#
CONFIG_AD2S90=y
# CONFIG_AD2S1200 is not set
CONFIG_AD2S1210=y

#
# Triggers - standalone
#
CONFIG_IIO_PERIODIC_RTC_TRIGGER=y
CONFIG_IIO_DUMMY_EVGEN=y
CONFIG_IIO_SIMPLE_DUMMY=y
CONFIG_IIO_SIMPLE_DUMMY_EVENTS=y
# CONFIG_IIO_SIMPLE_DUMMY_BUFFER is not set
CONFIG_FB_SM7XX=y
# CONFIG_CRYSTALHD is not set
CONFIG_FB_XGI=y
# CONFIG_ACPI_QUICKSTART is not set
# CONFIG_BCM_WIMAX is not set
CONFIG_FT1000=y
# CONFIG_FT1000_USB is not set
# CONFIG_FT1000_PCMCIA is not set

#
# Speakup console speech
#
CONFIG_TOUCHSCREEN_CLEARPAD_TM1217=y
CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4=y
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_USB_WPAN_HCD is not set
# CONFIG_WIMAX_GDM72XX is not set
CONFIG_CED1401=y
# CONFIG_DGRP is not set
# CONFIG_GOLDFISH_AUDIO is not set
# CONFIG_XILLYBUS is not set
# CONFIG_DGNC is not set
# CONFIG_DGAP is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WMI is not set
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_DELL_LAPTOP is not set
# CONFIG_DELL_WMI is not set
# CONFIG_DELL_WMI_AIO is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_TC1100_WMI is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_HP_WMI is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ASUS_WMI is not set
CONFIG_ACPI_WMI=y
# CONFIG_MSI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_ACPI_TOSHIBA is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
CONFIG_IBM_RTL=y
# CONFIG_XO15_EBOOK is not set
CONFIG_SAMSUNG_LAPTOP=y
CONFIG_MXM_WMI=y
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
CONFIG_GOLDFISH_PIPE=y
# CONFIG_CHROME_PLATFORMS is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
# CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND is not set
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
CONFIG_DEVFREQ_GOV_POWERSAVE=y
# CONFIG_DEVFREQ_GOV_USERSPACE is not set

#
# DEVFREQ Drivers
#
# CONFIG_EXTCON is not set
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
CONFIG_BMA180=y
CONFIG_HID_SENSOR_ACCEL_3D=y
CONFIG_IIO_ST_ACCEL_3AXIS=y
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=y
CONFIG_IIO_ST_ACCEL_SPI_3AXIS=y
CONFIG_KXSD9=y

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
CONFIG_AD7298=y
CONFIG_AD7476=y
CONFIG_AD7791=y
CONFIG_AD7793=y
CONFIG_AD7887=y
# CONFIG_AD7923 is not set
CONFIG_EXYNOS_ADC=y
CONFIG_LP8788_ADC=y
# CONFIG_MAX1363 is not set
CONFIG_MCP320X=y
CONFIG_MCP3422=y
CONFIG_NAU7802=y
CONFIG_TI_ADC081C=y
CONFIG_TI_AM335X_ADC=y
# CONFIG_VIPERBOARD_ADC is not set

#
# Amplifiers
#
# CONFIG_AD8366 is not set

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_IIO_TRIGGER=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5360=y
CONFIG_AD5380=y
# CONFIG_AD5421 is not set
# CONFIG_AD5446 is not set
# CONFIG_AD5449 is not set
CONFIG_AD5504=y
# CONFIG_AD5624R_SPI is not set
CONFIG_AD5686=y
# CONFIG_AD5755 is not set
CONFIG_AD5764=y
CONFIG_AD5791=y
# CONFIG_AD7303 is not set
CONFIG_MAX517=y
# CONFIG_MCP4725 is not set

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
CONFIG_AD9523=y

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=y

#
# Digital gyroscope sensors
#
CONFIG_ADIS16080=y
CONFIG_ADIS16130=y
CONFIG_ADIS16136=y
# CONFIG_ADIS16260 is not set
# CONFIG_ADXRS450 is not set
CONFIG_HID_SENSOR_GYRO_3D=y
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
CONFIG_IIO_ST_GYRO_SPI_3AXIS=y
CONFIG_ITG3200=y

#
# Humidity sensors
#
CONFIG_DHT11=y

#
# Inertial measurement units
#
CONFIG_ADIS16400=y
CONFIG_ADIS16480=y
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y
CONFIG_INV_MPU6050_IIO=y

#
# Light sensors
#
CONFIG_ADJD_S311=y
CONFIG_APDS9300=y
CONFIG_CM32181=y
CONFIG_CM36651=y
# CONFIG_GP2AP020A00F is not set
CONFIG_HID_SENSOR_ALS=y
CONFIG_SENSORS_LM3533=y
CONFIG_TCS3472=y
CONFIG_SENSORS_TSL2563=y
CONFIG_TSL4531=y
# CONFIG_VCNL4000 is not set

#
# Magnetometer sensors
#
CONFIG_AK8975=y
CONFIG_MAG3110=y
CONFIG_HID_SENSOR_MAGNETOMETER_3D=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_IIO_ST_MAGN_SPI_3AXIS=y

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=y

#
# Triggers - standalone
#
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Pressure sensors
#
CONFIG_MPL3115=y
# CONFIG_IIO_ST_PRESS is not set

#
# Temperature sensors
#
CONFIG_TMP006=y
CONFIG_NTB=y
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
CONFIG_VME_TSI148=y

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=y

#
# VME Device Drivers
#
CONFIG_VME_USER=y
CONFIG_VME_PIO2=y
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_PCA9685 is not set
CONFIG_IRQCHIP=y
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_PHY_EXYNOS_MIPI_VIDEO is not set
CONFIG_PHY_EXYNOS_DP_VIDEO=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_POWERCAP=y
# CONFIG_INTEL_RAPL is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
# CONFIG_PROC_PAGE_MONITOR is not set
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
# CONFIG_NLS_UTF8 is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
# CONFIG_MAGIC_SYSRQ is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
CONFIG_DEBUG_OBJECTS_TIMERS=y
CONFIG_DEBUG_OBJECTS_WORK=y
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_DEBUG_SLAB=y
# CONFIG_DEBUG_SLAB_LEAK is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_RB is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
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
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHEDSTATS is not set
CONFIG_TIMER_STATS=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_WRITECOUNT=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_PROVE_RCU_REPEATEDLY=y
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_CPU_STALL_INFO=y
# CONFIG_RCU_TRACE is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_CPU_NOTIFIER_ERROR_INJECT=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_BUILD_DOCSRC is not set
CONFIG_DMA_API_DEBUG=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=2
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
# CONFIG_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
# CONFIG_SECURITYFS is not set
# CONFIG_SECURITY_NETWORK is not set
CONFIG_SECURITY_PATH=y
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
# CONFIG_IMA is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
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
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
# CONFIG_CRYPTO_ECB is not set
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
# CONFIG_CRYPTO_CRC32C_INTEL is not set
# CONFIG_CRYPTO_CRC32 is not set
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
# CONFIG_CRYPTO_CRCT10DIF is not set
# CONFIG_CRYPTO_GHASH is not set
# CONFIG_CRYPTO_MD4 is not set
# CONFIG_CRYPTO_MD5 is not set
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
# CONFIG_CRYPTO_SHA512 is not set
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=y
# CONFIG_CRYPTO_CAST5 is not set
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=y
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_SALSA20_586=y
CONFIG_CRYPTO_SEED=y
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
# CONFIG_CRYPTO_LZ4 is not set
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_CRYPTO_DEV_GEODE is not set
# CONFIG_CRYPTO_DEV_CCP is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_KVM is not set
# CONFIG_BINARY_PRINTF is not set

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
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
# CONFIG_CRC_T10DIF is not set
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
CONFIG_CRC32_SARWATE=y
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
# CONFIG_XZ_DEC_POWERPC is not set
# CONFIG_XZ_DEC_IA64 is not set
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CORDIC=y
# CONFIG_DDR is not set

--3V7upXqbjpZ4EhLz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
