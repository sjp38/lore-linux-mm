Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0B76B0031
	for <linux-mm@kvack.org>; Sun,  9 Mar 2014 22:44:05 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so6424092pdi.7
        for <linux-mm@kvack.org>; Sun, 09 Mar 2014 19:44:04 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yo5si15219901pab.237.2014.03.09.19.44.02
        for <linux-mm@kvack.org>;
        Sun, 09 Mar 2014 19:44:03 -0700 (PDT)
Date: Mon, 10 Mar 2014 10:43:56 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [vma caching] BUG: unable to handle kernel paging request at
 ffff880008142f40
Message-ID: <20140310024356.GB9322@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Davidlohr,

I got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
commit 0d9ad4220e6d73f63a9eeeaac031b92838f75bb3
Author:     Davidlohr Bueso <davidlohr@hp.com>
AuthorDate: Thu Mar 6 11:01:48 2014 +1100
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Thu Mar 6 11:01:48 2014 +1100

    mm: per-thread vma caching
    
hwclock: can't open '/dev/misc/rtc': No such file or directory
Running postinst /etc/rpm-postinsts/100...
[    3.658976] BUG: unable to handle kernel paging request at ffff880008142f40
[    3.661422] IP: [<ffffffff8111a1d8>] vmacache_find+0x78/0x90
[    3.662223] PGD 2542067 PUD 2543067 PMD fba5067 PTE 8000000008142060
[    3.662223] Oops: 0000 [#1] DEBUG_PAGEALLOC
[    3.662223] Modules linked in:
[    3.662223] CPU: 0 PID: 326 Comm: 90-trinity Not tainted 3.14.0-rc5-next-20140307 #1
[    3.662223] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.662223] task: ffff8800083020d0 ti: ffff8800082a0000 task.ti: ffff8800082a0000
[    3.662223] RIP: 0010:[<ffffffff8111a1d8>]  [<ffffffff8111a1d8>] vmacache_find+0x78/0x90
[    3.662223] RSP: 0000:ffff8800082a1e00  EFLAGS: 00010282
[    3.662223] RAX: ffff880008142f40 RBX: 00000000000000a9 RCX: ffff8800083020d0
[    3.662223] RDX: 0000000000000002 RSI: 00007fff8a141698 RDI: ffff880008124bc0
[    3.662223] RBP: ffff8800082a1e00 R08: 0000000000000000 R09: 0000000000000001
[    3.662223] R10: ffff8800083020d0 R11: 0000000000000000 R12: 00007fff8a141698
[    3.662223] R13: ffff880008124bc0 R14: ffff8800082a1f58 R15: ffff8800083020d0
[    3.662223] FS:  00007fe3ca364700(0000) GS:ffffffff81a06000(0000) knlGS:0000000000000000
[    3.662223] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    3.662223] CR2: ffff880008142f40 CR3: 000000000824c000 CR4: 00000000000006b0
[    3.662223] Stack:
[    3.662223]  ffff8800082a1e28 ffffffff81125219 00000000000000a9 00007fff8a141698
[    3.662223]  ffff880008124bc0 ffff8800082a1f28 ffffffff816d71fe 0000000000000246
[    3.662223]  0000000000000002 ffff880008124c58 0000000000000006 0000000000000010
[    3.662223] Call Trace:
[    3.662223]  [<ffffffff81125219>] find_vma+0x19/0x70
[    3.662223]  [<ffffffff816d71fe>] __do_page_fault+0x29e/0x560
[    3.662223]  [<ffffffff8116cc6f>] ? mntput_no_expire+0x6f/0x1a0
[    3.662223]  [<ffffffff8116cc11>] ? mntput_no_expire+0x11/0x1a0
[    3.662223]  [<ffffffff8116cdd5>] ? mntput+0x35/0x40
[    3.662223]  [<ffffffff8114f51f>] ? __fput+0x24f/0x290
[    3.662223]  [<ffffffff812794ca>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[    3.662223]  [<ffffffff816d74ce>] do_page_fault+0xe/0x10
[    3.662223]  [<ffffffff816d6ad5>] do_async_page_fault+0x35/0x90
[    3.662223]  [<ffffffff816d3b05>] async_page_fault+0x25/0x30
[    3.662223] Code: c7 81 b0 02 00 00 00 00 00 00 eb 32 0f 1f 80 00 00 00 00 31 d2 66 0f 1f 44 00 00 48 63 c2 48 8b 84 c1 98 02 00 00 48 85 c0 74 0b <48> 39 30 77 06 48 3b 70 08 72 0a 83 c2 01 83 fa 04 75 dd 31 c0 
[    3.662223] RIP  [<ffffffff8111a1d8>] vmacache_find+0x78/0x90
[    3.662223]  RSP <ffff8800082a1e00>
[    3.662223] CR2: ffff880008142f40
[    3.662223] ---[ end trace dead6556b35f2f50 ]---
[    3.662223] Kernel panic - not syncing: Fatal exception

git bisect start 1b0a7e3263168a06d3858798e48c5a21d1c78d3c 56032fc504c9ce9dd6fd697e4687441a7d0ea4a2 --
git bisect  bad 8e6a5f1094819a747c13d6ffef5c44607fb757f8  # 19:31      0-      2  Merge branch 'akpm-current/current'
git bisect  bad e37f7e706daab128221f1fe72967ea4f9ac0c1da  # 19:53      0-      2  zram: move zram size warning to documentation
git bisect good 7f0885cfba68ed357474a55eaa13a5757371f4bd  # 20:13     22+      0  mm-keep-page-cache-radix-tree-nodes-in-check-fix
git bisect good 0caff8dc0cabb8015faa1425c0e61eab4f9c9d2b  # 20:43     22+      3  mm,numa: reorganize change_pmd_range()
git bisect good d6e9552645e4fc33985e6b642ffd2841915eacaa  # 21:05     22+      6  tools/vm/page-types.c: page-cache sniffing feature
git bisect  bad 1d69676e3d045a51ecf3f8f3b6239c46e934f323  # 21:17      0-      1  mm: use macros from compiler.h instead of __attribute__((...))
git bisect good 70051b9078a325e95a0944c688723512ae14459e  # 21:32     22+      5  mm: cleanup size checks in filemap_fault() and filemap_map_pages()
git bisect  bad 0d9ad4220e6d73f63a9eeeaac031b92838f75bb3  # 21:45     14-     19  mm: per-thread vma caching
git bisect good 2c42ccb3347d6e08b3fae34f709a25edbc7b9ad4  # 22:06     48+      3  mm-add-debugfs-tunable-for-fault_around_order-checkpatch-fixes
# first bad commit: [0d9ad4220e6d73f63a9eeeaac031b92838f75bb3] mm: per-thread vma caching
git bisect good 2c42ccb3347d6e08b3fae34f709a25edbc7b9ad4  # 22:13    144+     18  mm-add-debugfs-tunable-for-fault_around_order-checkpatch-fixes
git bisect  bad 1b0a7e3263168a06d3858798e48c5a21d1c78d3c  # 22:13      0-     15  Add linux-next specific files for 20140307
git bisect good ca62eec4e524591b82d9edf7a18e3ae6b691517d  # 22:53    144+     19  Merge branch 'for-3.14-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup
git bisect  bad 1b0a7e3263168a06d3858798e48c5a21d1c78d3c  # 22:53      0-     15  Add linux-next specific files for 20140307

Thanks,
Fengguang

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-yocto-snb-26:20140309185003:x86_64-randconfig-i1-03091831::"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Linux version 3.14.0-rc5-next-20140307 (kbuild@inn) (gcc ver=
sion 4.8.2 (Debian 4.8.2-16) ) #1 Sun Mar 9 18:46:43 CST 2014
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D1=
00 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0=
 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw li=
nk=3D/kernel-tests/run-queue/kvm/x86_64-randconfig-i1-03091831/next:master/=
=2Evmlinuz-1b0a7e3263168a06d3858798e48c5a21d1c78d3c-20140309184826-9-snb br=
anch=3Dnext/master BOOT_IMAGE=3D/kernel/x86_64-randconfig-i1-03091831/1b0a7=
e3263168a06d3858798e48c5a21d1c78d3c/vmlinuz-3.14.0-rc5-next-20140307
[    0.000000] KERNEL supported cpus:
[    0.000000]   Centaur CentaurHauls
[    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
[    0.000000] CPU: Your system may be unstable.
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
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x400000000
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
[    0.000000] found SMP MP-table at [mem 0x000fdac0-0x000fdacf] mapped at =
[ffff8800000fdac0]
[    0.000000]   mpc: fdad0-fdbec
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x02542000, 0x02542fff] PGTABLE
[    0.000000] BRK [0x02543000, 0x02543fff] PGTABLE
[    0.000000] BRK [0x02544000, 0x02544fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0fa00000-0x0fbfffff]
[    0.000000]  [mem 0x0fa00000-0x0fbfffff] page 4k
[    0.000000] BRK [0x02545000, 0x02545fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0c000000-0x0f9fffff]
[    0.000000]  [mem 0x0c000000-0x0f9fffff] page 4k
[    0.000000] BRK [0x02546000, 0x02546fff] PGTABLE
[    0.000000] BRK [0x02547000, 0x02547fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0bffffff]
[    0.000000]  [mem 0x00100000-0x0bffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0fffdfff]
[    0.000000]  [mem 0x0fc00000-0x0fffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x0fce6000-0x0ffeffff]
[    0.000000] ACPI: RSDP 0x00000000000FD930 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000000FFFE450 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000000FFFFF80 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000000FFFE490 0011A9 (v01 BXPC   BXDSDT   00=
000001 INTL 20100528)
[    0.000000] ACPI: FACS 0x000000000FFFFF40 000040
[    0.000000] ACPI: SSDT 0x000000000FFFF7A0 000796 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000000FFFF680 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000000FFFF640 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 960 pages used for memmap
[    0.000000]   DMA32 zone: 61438 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
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
[    0.000000] mapped IOAPIC to ffffffffff5f9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1a0c640
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64391
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramd=
isk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram=
0 rw link=3D/kernel-tests/run-queue/kvm/x86_64-randconfig-i1-03091831/next:=
master/.vmlinuz-1b0a7e3263168a06d3858798e48c5a21d1c78d3c-20140309184826-9-s=
nb branch=3Dnext/master BOOT_IMAGE=3D/kernel/x86_64-randconfig-i1-03091831/=
1b0a7e3263168a06d3858798e48c5a21d1c78d3c/vmlinuz-3.14.0-rc5-next-20140307
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 5, 131072 byte=
s)
[    0.000000] Memory: 231140K/261744K available (7024K kernel code, 818K r=
wdata, 3092K rodata, 1004K init, 9812K bss, 30604K reserved)
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
[    0.000000] ACPI: Core revision 20140214
[    0.000000] ACPI: All ACPI Tables successfully acquired
[    0.000000] Linux version 3.14.0-rc5-next-20140307 (kbuild@inn) (gcc ver=
sion 4.8.2 (Debian 4.8.2-16) ) #1 Sun Mar 9 18:46:43 CST 2014
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D1=
00 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0=
 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw li=
nk=3D/kernel-tests/run-queue/kvm/x86_64-randconfig-i1-03091831/next:master/=
=2Evmlinuz-1b0a7e3263168a06d3858798e48c5a21d1c78d3c-20140309184826-9-snb br=
anch=3Dnext/master BOOT_IMAGE=3D/kernel/x86_64-randconfig-i1-03091831/1b0a7=
e3263168a06d3858798e48c5a21d1c78d3c/vmlinuz-3.14.0-rc5-next-20140307
[    0.000000] KERNEL supported cpus:
[    0.000000]   Centaur CentaurHauls
[    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
[    0.000000] CPU: Your system may be unstable.
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
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x400000000
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
[    0.000000] found SMP MP-table at [mem 0x000fdac0-0x000fdacf] mapped at =
[ffff8800000fdac0]
[    0.000000]   mpc: fdad0-fdbec
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x02542000, 0x02542fff] PGTABLE
[    0.000000] BRK [0x02543000, 0x02543fff] PGTABLE
[    0.000000] BRK [0x02544000, 0x02544fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0fa00000-0x0fbfffff]
[    0.000000]  [mem 0x0fa00000-0x0fbfffff] page 4k
[    0.000000] BRK [0x02545000, 0x02545fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0c000000-0x0f9fffff]
[    0.000000]  [mem 0x0c000000-0x0f9fffff] page 4k
[    0.000000] BRK [0x02546000, 0x02546fff] PGTABLE
[    0.000000] BRK [0x02547000, 0x02547fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0bffffff]
[    0.000000]  [mem 0x00100000-0x0bffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0fffdfff]
[    0.000000]  [mem 0x0fc00000-0x0fffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x0fce6000-0x0ffeffff]
[    0.000000] ACPI: RSDP 0x00000000000FD930 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000000FFFE450 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000000FFFFF80 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000000FFFE490 0011A9 (v01 BXPC   BXDSDT   00=
000001 INTL 20100528)
[    0.000000] ACPI: FACS 0x000000000FFFFF40 000040
[    0.000000] ACPI: SSDT 0x000000000FFFF7A0 000796 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000000FFFF680 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000000FFFF640 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 960 pages used for memmap
[    0.000000]   DMA32 zone: 61438 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
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
[    0.000000] mapped IOAPIC to ffffffffff5f9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1a0c640
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64391
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramd=
isk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram=
0 rw link=3D/kernel-tests/run-queue/kvm/x86_64-randconfig-i1-03091831/next:=
master/.vmlinuz-1b0a7e3263168a06d3858798e48c5a21d1c78d3c-20140309184826-9-s=
nb branch=3Dnext/master BOOT_IMAGE=3D/kernel/x86_64-randconfig-i1-03091831/=
1b0a7e3263168a06d3858798e48c5a21d1c78d3c/vmlinuz-3.14.0-rc5-next-20140307
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 5, 131072 byte=
s)
[    0.000000] Memory: 231140K/261744K available (7024K kernel code, 818K r=
wdata, 3092K rodata, 1004K init, 9812K bss, 30604K reserved)
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
[    0.000000] ACPI: Core revision 20140214
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
[    0.000000]  memory used by lock dependency info: 5855 kB
[    0.000000]  memory used by lock dependency info: 5855 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] ------------------------
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] | Locking API testsuite:
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]                      A-A deadlock:
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                  A-B-B-A deadlock:
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]              A-B-B-C-C-A deadlock:
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]              A-B-C-A-B-C deadlock:
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]          A-B-B-C-C-D-D-A deadlock:
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]          A-B-C-D-B-D-D-A deadlock:
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]          A-B-C-D-B-C-D-A deadlock:
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                     double unlock:
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                   initialize held:
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                  bad unlock order:
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]               recursive read-lock:
[    0.000000]               recursive read-lock:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]            recursive read-lock #2:
[    0.000000]            recursive read-lock #2:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]             mixed read-write-lock:
[    0.000000]             mixed read-write-lock:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]             mixed write-read-lock:
[    0.000000]             mixed write-read-lock:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/12:
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]      hard-irqs-on + irq-safe-A/21:
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/21:
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/12:
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/21:
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/12:
[    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/12:
[    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/21:
[    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/21:
[    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/123:
[    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/123:
[    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/132:
[    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/132:
[    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/213:
[    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/213:
[    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/231:
[    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/231:
[    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/312:
[    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/312:
[    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/321:
[    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/321:
[    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/123:
[    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/123:
[    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/132:
[    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/132:
[    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/213:
[    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/213:
[    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/231:
[    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/231:
[    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/312:
[    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/312:
[    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/321:
[    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/321:
[    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/123:
[    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/123:
[    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/132:
[    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/132:
[    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/213:
[    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/213:
[    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/231:
[    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/231:
[    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/312:
[    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/312:
[    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/321:
[    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/321:
[    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/123:
[    0.000000]       hard-irq read-recursion/123:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/123:
[    0.000000]       soft-irq read-recursion/123:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/132:
[    0.000000]       hard-irq read-recursion/132:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/132:
[    0.000000]       soft-irq read-recursion/132:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/213:
[    0.000000]       hard-irq read-recursion/213:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/213:
[    0.000000]       soft-irq read-recursion/213:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/231:
[    0.000000]       hard-irq read-recursion/231:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/231:
[    0.000000]       soft-irq read-recursion/231:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/312:
[    0.000000]       hard-irq read-recursion/312:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/312:
[    0.000000]       soft-irq read-recursion/312:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/321:
[    0.000000]       hard-irq read-recursion/321:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/321:
[    0.000000]       soft-irq read-recursion/321:  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   | Wound/wait tests |
[    0.000000]   | Wound/wait tests |
[    0.000000]   ---------------------
[    0.000000]   ---------------------
[    0.000000]                   ww api failures:
[    0.000000]                   ww api failures:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                ww contexts mixing:
[    0.000000]                ww contexts mixing:  ok  |  ok  |  ok  |  ok =
 |

[    0.000000]              finishing ww context:
[    0.000000]              finishing ww context:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                locking mismatches:
[    0.000000]                locking mismatches:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                  EDEADLK handling:
[    0.000000]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]            spinlock nest unlocked:
[    0.000000]            spinlock nest unlocked:  ok  |  ok  |

[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                                  |block | try  |context|
[    0.000000]                                  |block | try  |context|
[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                           context:
[    0.000000]                           context:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                               try:
[    0.000000]                               try:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                             block:
[    0.000000]                             block:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                          spinlock:
[    0.000000]                          spinlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000] -------------------------------------------------------
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 253 testcases passed! |
[    0.000000] Good, all 253 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] ---------------------------------
[    0.000000] ODEBUG: 9 of 9 active objects replaced
[    0.000000] ODEBUG: 9 of 9 active objects replaced
[    0.000000] ODEBUG: selftest passed
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2300.158 MHz processor
[    0.000000] tsc: Detected 2300.158 MHz processor
[    0.008000] Calibrating delay loop (skipped) preset value..=20
[    0.008000] Calibrating delay loop (skipped) preset value.. 4600.31 Bogo=
MIPS (lpj=3D9200632)
4600.31 BogoMIPS (lpj=3D9200632)
[    0.009087] pid_max: default: 4096 minimum: 301
[    0.009087] pid_max: default: 4096 minimum: 301
[    0.012552] Security Framework initialized
[    0.012552] Security Framework initialized
[    0.014290] Mount-cache hash table entries: 256
[    0.014290] Mount-cache hash table entries: 256
[    0.018288] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.018288] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.018288] tlb_flushall_shift: -1
[    0.018288] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.018288] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.018288] tlb_flushall_shift: -1
[    0.020015] CPU:=20
[    0.020015] CPU: GenuineIntel GenuineIntel Common KVM processorCommon KV=
M processor (fam: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.029152] ftrace: allocating 23604 entries in 93 pages
[    0.029152] ftrace: allocating 23604 entries in 93 pages
[    0.040739] Performance Events:=20
[    0.040739] Performance Events: no PMU driver, software events only.
no PMU driver, software events only.
[    0.046949] Getting VERSION: 50014
[    0.046949] Getting VERSION: 50014
[    0.048022] Getting VERSION: 50014
[    0.048022] Getting VERSION: 50014
[    0.049264] Getting ID: 0
[    0.049264] Getting ID: 0
[    0.050275] Getting ID: ff000000
[    0.050275] Getting ID: ff000000
[    0.052028] Getting LVT0: 8700
[    0.052028] Getting LVT0: 8700
[    0.053180] Getting LVT1: 8400
[    0.053180] Getting LVT1: 8400
[    0.054389] enabled ExtINT on CPU#0
[    0.054389] enabled ExtINT on CPU#0
[    0.057608] ENABLING IO-APIC IRQs
[    0.057608] ENABLING IO-APIC IRQs
[    0.058882] init IO_APIC IRQs
[    0.058882] init IO_APIC IRQs
[    0.060015]  apic 0 pin 0 not connected
[    0.060015]  apic 0 pin 0 not connected
[    0.061467] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.061467] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.064051] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.064051] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.068053] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.068053] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.071022] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.071022] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.072050] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.072050] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.076045] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.076045] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.080046] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.080046] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.084144] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.084144] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.087088] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.087088] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.088049] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.088049] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.092053] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.092053] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.096052] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.096052] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.099058] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.099058] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.100084] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.100084] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.104051] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.104051] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.108040]  apic 0 pin 16 not connected
[    0.108040]  apic 0 pin 16 not connected
[    0.109542]  apic 0 pin 17 not connected
[    0.109542]  apic 0 pin 17 not connected
[    0.112008]  apic 0 pin 18 not connected
[    0.112008]  apic 0 pin 18 not connected
[    0.113554]  apic 0 pin 19 not connected
[    0.113554]  apic 0 pin 19 not connected
[    0.115049]  apic 0 pin 20 not connected
[    0.115049]  apic 0 pin 20 not connected
[    0.116012]  apic 0 pin 21 not connected
[    0.116012]  apic 0 pin 21 not connected
[    0.117527]  apic 0 pin 22 not connected
[    0.117527]  apic 0 pin 22 not connected
[    0.120010]  apic 0 pin 23 not connected
[    0.120010]  apic 0 pin 23 not connected
[    0.121736] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.121736] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.124013] Using local APIC timer interrupts.
[    0.124013] calibrating APIC timer ...
[    0.124013] Using local APIC timer interrupts.
[    0.124013] calibrating APIC timer ...
[    0.132000] ... lapic delta =3D 6249996
[    0.132000] ... lapic delta =3D 6249996
[    0.132000] ... PM-Timer delta =3D 357938
[    0.132000] ... PM-Timer delta =3D 357938
[    0.132000] ... PM-Timer result ok
[    0.132000] ... PM-Timer result ok
[    0.132000] ..... delta 6249996
[    0.132000] ..... delta 6249996
[    0.132000] ..... mult: 268435284
[    0.132000] ..... mult: 268435284
[    0.132000] ..... calibration result: 3999997
[    0.132000] ..... calibration result: 3999997
[    0.132000] ..... CPU clock speed is 2299.3528 MHz.
[    0.132000] ..... CPU clock speed is 2299.3528 MHz.
[    0.132000] ..... host bus clock speed is 999.3997 MHz.
[    0.132000] ..... host bus clock speed is 999.3997 MHz.
[    0.133882] devtmpfs: initialized
[    0.133882] devtmpfs: initialized
[    0.155657] atomic64 test passed for x86-64 platform with CX8 and with S=
SE
[    0.155657] atomic64 test passed for x86-64 platform with CX8 and with S=
SE
[    0.162464] regulator-dummy: no parameters
[    0.162464] regulator-dummy: no parameters
[    0.165471] NET: Registered protocol family 16
[    0.165471] NET: Registered protocol family 16
[    0.172818] cpuidle: using governor ladder
[    0.172818] cpuidle: using governor ladder
[    0.175334] cpuidle: using governor menu
[    0.175334] cpuidle: using governor menu
[    0.176640] ACPI: bus type PCI registered
[    0.176640] ACPI: bus type PCI registered
[    0.181029] PCI: Using configuration type 1 for base access
[    0.181029] PCI: Using configuration type 1 for base access
[    0.219640] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.219640] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.220094] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.220094] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.228048] ACPI: Added _OSI(Module Device)
[    0.228048] ACPI: Added _OSI(Module Device)
[    0.230769] ACPI: Added _OSI(Processor Device)
[    0.230769] ACPI: Added _OSI(Processor Device)
[    0.232011] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.232011] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.236012] ACPI: Added _OSI(Processor Aggregator Device)
[    0.236012] ACPI: Added _OSI(Processor Aggregator Device)
[    0.281251] ACPI: Interpreter enabled
[    0.281251] ACPI: Interpreter enabled
[    0.283540] ACPI Exception: AE_NOT_FOUND,=20
[    0.283540] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_]While evaluating Sleep State [\_S1_] (20140214/hwxface-580)
 (20140214/hwxface-580)
[    0.289499] ACPI Exception: AE_NOT_FOUND,=20
[    0.289499] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_]While evaluating Sleep State [\_S2_] (20140214/hwxface-580)
 (20140214/hwxface-580)
[    0.293421] ACPI: (supports S0 S3 S4)
[    0.293421] ACPI: (supports S0 S3 S4)
[    0.296011] ACPI: Using IOAPIC for interrupt routing
[    0.296011] ACPI: Using IOAPIC for interrupt routing
[    0.300296] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.300296] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.356990] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.356990] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.360028] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.360028] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.363267] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.363267] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.371257] PCI host bridge to bus 0000:00
[    0.371257] PCI host bridge to bus 0000:00
[    0.372045] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.372045] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.376015] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.376015] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.380016] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.380016] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.384013] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.384013] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.388017] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.388017] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.392166] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.392166] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.398198] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.398198] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.404807] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.404807] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.413643] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    0.413643] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    0.420918] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.420918] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.424706] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.424706] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.428040] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.428040] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.433864] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.433864] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.441291] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.441291] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.448096] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.448096] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.466533] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.466533] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.473895] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.473895] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.478017] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.478017] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.485011] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.485011] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.497905] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.497905] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.504817] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.504817] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.510156] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.510156] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.516013] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.516013] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.531007] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.531007] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.537000] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.537000] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.542038] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    0.542038] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    0.559040] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.559040] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.564014] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.564014] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.570054] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    0.570054] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    0.585805] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.585805] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.590072] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    0.590072] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    0.597069] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.597069] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.612804] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.612804] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.618228] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    0.618228] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    0.624012] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.624012] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.638973] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.638973] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.645024] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.645024] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.649997] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.649997] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.667109] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    0.667109] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    0.672010] pci 0000:00:0a.0: reg 0x10: [mem 0xfebf7000-0xfebf700f]
[    0.672010] pci 0000:00:0a.0: reg 0x10: [mem 0xfebf7000-0xfebf700f]
[    0.684092] pci_bus 0000:00: on NUMA node 0
[    0.684092] pci_bus 0000:00: on NUMA node 0
[    0.690640] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    0.690640] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    0.693806] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    0.693806] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    0.697811] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    0.697811] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    0.704513] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    0.704513] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    0.708561] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    0.708561] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    0.715703] ACPI:=20
[    0.715703] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    0.727812] pps_core: LinuxPPS API ver. 1 registered
[    0.727812] pps_core: LinuxPPS API ver. 1 registered
[    0.728008] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.728008] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.732181] PTP clock support registered
[    0.732181] PTP clock support registered
[    0.734982] PCI: Using ACPI for IRQ routing
[    0.734982] PCI: Using ACPI for IRQ routing
[    0.736018] PCI: pci_cache_line_size set to 64 bytes
[    0.736018] PCI: pci_cache_line_size set to 64 bytes
[    0.740413] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.740413] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.744044] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.744044] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.752497] NET: Registered protocol family 8
[    0.752497] NET: Registered protocol family 8
[    0.755085] NET: Registered protocol family 20
[    0.755085] NET: Registered protocol family 20
[    0.761534] Switched to clocksource kvm-clock
[    0.761534] Switched to clocksource kvm-clock
[    0.764021] Could not create debugfs 'set_ftrace_filter' entry
[    0.764021] Could not create debugfs 'set_ftrace_filter' entry
[    0.767577] Could not create debugfs 'set_ftrace_notrace' entry
[    0.767577] Could not create debugfs 'set_ftrace_notrace' entry
[    0.915749] FS-Cache: Loaded
[    0.915749] FS-Cache: Loaded
[    0.917792] pnp: PnP ACPI init
[    0.917792] pnp: PnP ACPI init
[    0.920128] ACPI: bus type PNP registered
[    0.920128] ACPI: bus type PNP registered
[    0.922760] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.922760] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.928386] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.928386] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.932497] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.932497] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.937996] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.937996] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.942099] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.942099] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.947769] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.947769] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.952119] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.952119] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.956856] pnp 00:03: [dma 2]
[    0.956856] pnp 00:03: [dma 2]
[    0.959474] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.959474] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.963797] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.963797] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.969254] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.969254] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.973491] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.973491] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.979057] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.979057] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.984699] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.984699] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.989792] pnp: PnP ACPI: found 7 devices
[    0.989792] pnp: PnP ACPI: found 7 devices
[    0.992257] ACPI: bus type PNP unregistered
[    0.992257] ACPI: bus type PNP unregistered
[    0.995837] cfg80211: Calling CRDA to update world regulatory domain
[    0.995837] cfg80211: Calling CRDA to update world regulatory domain
[    1.011656] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.011656] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.015100] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.015100] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.018299] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.018299] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.022150] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.022150] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.025939] NET: Registered protocol family 1
[    1.025939] NET: Registered protocol family 1
[    1.028132] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.028132] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.031053] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.031053] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.033871] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.033871] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.036741] pci 0000:00:02.0: Boot video device
[    1.036741] pci 0000:00:02.0: Boot video device
[    1.039217] PCI: CLS 0 bytes, default 64
[    1.039217] PCI: CLS 0 bytes, default 64
[    1.042429] Unpacking initramfs...
[    1.042429] Unpacking initramfs...
[    1.251351] debug: unmapping init [mem 0xffff88000fce6000-0xffff88000ffe=
ffff]
[    1.251351] debug: unmapping init [mem 0xffff88000fce6000-0xffff88000ffe=
ffff]
[    1.257624] cryptomgr_test (17) used greatest stack depth: 6592 bytes le=
ft
[    1.257624] cryptomgr_test (17) used greatest stack depth: 6592 bytes le=
ft
[    1.264637] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.264637] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.267632] PCLMULQDQ-NI instructions are not detected.
[    1.267632] PCLMULQDQ-NI instructions are not detected.
[    1.270268] sha256_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.270268] sha256_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.273439] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.273439] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.276667] AVX or AES-NI instructions are not detected.
[    1.276667] AVX or AES-NI instructions are not detected.
[    1.279374] AVX instructions are not detected.
[    1.279374] AVX instructions are not detected.
[    1.281677] AVX2 or AES-NI instructions are not detected.
[    1.281677] AVX2 or AES-NI instructions are not detected.
[    1.284704] spin_lock-torture:--- Start of test: nwriters_stress=3D2 sta=
t_interval=3D60 verbose=3D1 shuffle_interval=3D3 stutter=3D5 shutdown_secs=
=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    1.284704] spin_lock-torture:--- Start of test: nwriters_stress=3D2 sta=
t_interval=3D60 verbose=3D1 shuffle_interval=3D3 stutter=3D5 shutdown_secs=
=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    1.292217] spin_lock-torture: Creating torture_shuffle task
[    1.292217] spin_lock-torture: Creating torture_shuffle task
[    1.295350] spin_lock-torture: Creating torture_stutter task
[    1.295350] spin_lock-torture: Creating torture_stutter task
[    1.298247] spin_lock-torture: torture_shuffle task started
[    1.298247] spin_lock-torture: torture_shuffle task started
[    1.301395] spin_lock-torture: Creating lock_torture_writer task
[    1.301395] spin_lock-torture: Creating lock_torture_writer task
[    1.304577] spin_lock-torture: torture_stutter task started
[    1.304577] spin_lock-torture: torture_stutter task started
[    1.307258] spin_lock-torture: Creating lock_torture_writer task
[    1.307258] spin_lock-torture: Creating lock_torture_writer task
[    1.310327] spin_lock-torture: lock_torture_writer task started
[    1.310327] spin_lock-torture: lock_torture_writer task started
[    1.313245] spin_lock-torture: Creating lock_torture_stats task
[    1.313245] spin_lock-torture: Creating lock_torture_stats task
[    1.316338] spin_lock-torture: lock_torture_writer task started
[    1.316338] spin_lock-torture: lock_torture_writer task started
[    1.319858] spin_lock-torture: lock_torture_stats task started
[    1.319858] spin_lock-torture: lock_torture_stats task started
[    1.326539] futex hash table entries: 16 (order: -2, 1152 bytes)
[    1.326539] futex hash table entries: 16 (order: -2, 1152 bytes)
[    1.329213] Initialise system trusted keyring
[    1.329213] Initialise system trusted keyring
[    1.362100] bounce pool size: 64 pages
[    1.362100] bounce pool size: 64 pages
[    1.364056] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.364056] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.368269] VFS: Disk quotas dquot_6.5.2
[    1.368269] VFS: Disk quotas dquot_6.5.2
[    1.370378] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.370378] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.374206] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    1.374206] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    1.378263] NILFS version 2 loaded
[    1.378263] NILFS version 2 loaded
[    1.385836] Key type asymmetric registered
[    1.385836] Key type asymmetric registered
[    1.387978] Asymmetric key parser 'x509' registered
[    1.387978] Asymmetric key parser 'x509' registered
[    1.390608] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 251)
[    1.390608] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 251)
[    1.394407] io scheduler noop registered
[    1.394407] io scheduler noop registered
[    1.396589] io scheduler cfq registered (default)
[    1.396589] io scheduler cfq registered (default)
[    1.399039] list_sort_test: start testing list_sort()
[    1.399039] list_sort_test: start testing list_sort()
[    1.407234] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    1.407234] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    1.413362] cirrusfb 0000:00:02.0: Cirrus Logic chipset on PCI bus, RAM =
(4096 kB) at 0xfc000000
[    1.413362] cirrusfb 0000:00:02.0: Cirrus Logic chipset on PCI bus, RAM =
(4096 kB) at 0xfc000000
[    1.422015] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    1.422015] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    1.425640] ACPI: Power Button [PWRF]
[    1.425640] ACPI: Power Button [PWRF]
[    1.706193] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.706193] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.734598] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    1.734598] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    1.747621] mtip32xx Version 1.3.0
[    1.747621] mtip32xx Version 1.3.0
[    1.750710] blk-mq: CPU -> queue map
[    1.750710] blk-mq: CPU -> queue map
[    1.752336]   CPU 0 -> Queue 0
[    1.752336]   CPU 0 -> Queue 0
[    1.756802]  nullb0: unknown partition table
[    1.756802]  nullb0: unknown partition table
[    1.760338] blk-mq: CPU -> queue map
[    1.760338] blk-mq: CPU -> queue map
[    1.762101]   CPU 0 -> Queue 0
[    1.762101]   CPU 0 -> Queue 0
[    1.765884]  nullb1: unknown partition table
[    1.765884]  nullb1: unknown partition table
[    1.769109] null: module loaded
[    1.769109] null: module loaded
[    1.770922] dummy-irq: no IRQ given.  Use irq=3DN
[    1.770922] dummy-irq: no IRQ given.  Use irq=3DN
[    1.773649] Phantom Linux Driver, version n0.9.8, init OK
[    1.773649] Phantom Linux Driver, version n0.9.8, init OK
[    1.777158] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    1.777158] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    1.781516] Guest personality initialized and is inactive
[    1.781516] Guest personality initialized and is inactive
[    1.784789] VMCI host device registered (name=3Dvmci, major=3D10, minor=
=3D61)
[    1.784789] VMCI host device registered (name=3Dvmci, major=3D10, minor=
=3D61)
[    1.788071] Initialized host personality
[    1.788071] Initialized host personality
[    1.790425] mic_init not running on X100 ret -19
[    1.790425] mic_init not running on X100 ret -19
[    1.805603] vcan: Virtual CAN interface driver
[    1.805603] vcan: Virtual CAN interface driver
[    1.808482] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.19 (Decemb=
er 19, 2013)
[    1.808482] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.19 (Decemb=
er 19, 2013)
[    1.812309] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ether=
net Driver bnx2x 1.78.19-0 (2014/02/10)
[    1.812309] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ether=
net Driver bnx2x 1.78.19-0 (2014/02/10)
[    1.817535] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.50
[    1.817535] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.50
[    1.821388] sky2: driver version 1.30
[    1.821388] sky2: driver version 1.30
[    1.824645] Solarflare NET driver v4.0
[    1.824645] Solarflare NET driver v4.0
[    1.826806] ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-1.2.2
[    1.826806] ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-1.2.2
[    1.830096] ipw2100: Copyright(c) 2003-2006 Intel Corporation
[    1.830096] ipw2100: Copyright(c) 2003-2006 Intel Corporation
[    1.833304] libipw: 802.11 data/management/control stack, git-1.1.13
[    1.833304] libipw: 802.11 data/management/control stack, git-1.1.13
[    1.836320] libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@=
linux.intel.com>
[    1.836320] libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@=
linux.intel.com>
[    1.840708] Loaded prism54 driver, version 1.2
[    1.840708] Loaded prism54 driver, version 1.2
[    1.844578] I2O subsystem v1.325
[    1.844578] I2O subsystem v1.325
[    1.846233] i2o: max drivers =3D 8
[    1.846233] i2o: max drivers =3D 8
[    1.849011] I2O Configuration OSM v1.323
[    1.849011] I2O Configuration OSM v1.323
[    1.853855] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    1.853855] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    1.860488] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.860488] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.863223] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.863223] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.866969] rtc_cmos 00:00: RTC can wake from S4
[    1.866969] rtc_cmos 00:00: RTC can wake from S4
[    1.870430] rtc (null): alarm rollover: day
[    1.870430] rtc (null): alarm rollover: day
[    1.873330] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    1.873330] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    1.877047] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[    1.877047] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[    1.887801] i2c-parport-light: adapter type unspecified
[    1.887801] i2c-parport-light: adapter type unspecified
[    1.891268] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[    1.891268] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[    1.900548] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    1.900548] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    1.907661] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)
[    1.907661] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)
[    1.911239] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
[    1.911239] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
[    1.915609] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[    1.915609] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[    1.919146] i6300esb: cannot register miscdev on minor=3D130 (err=3D-16)
[    1.919146] i6300esb: cannot register miscdev on minor=3D130 (err=3D-16)
[    1.923029] i6300ESB timer: probe of 0000:00:0a.0 failed with error -16
[    1.923029] i6300ESB timer: probe of 0000:00:0a.0 failed with error -16
[    1.927197] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[    1.927197] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[    1.930043] w83697hf_wdt: watchdog not found at address 0x2e
[    1.930043] w83697hf_wdt: watchdog not found at address 0x2e
[    1.932819] w83697hf_wdt: No W83697HF/HG could be found
[    1.932819] w83697hf_wdt: No W83697HF/HG could be found
[    1.935443] w83877f_wdt: I/O address 0x0443 already in use
[    1.935443] w83877f_wdt: I/O address 0x0443 already in use
[    1.939159] ledtrig-cpu: registered to indicate activity on CPUs
[    1.939159] ledtrig-cpu: registered to indicate activity on CPUs
[    1.943282] NET: Registered protocol family 5
[    1.943282] NET: Registered protocol family 5
[    1.945724] can: controller area network core (rev 20120528 abi 9)
[    1.945724] can: controller area network core (rev 20120528 abi 9)
[    1.949227] NET: Registered protocol family 29
[    1.949227] NET: Registered protocol family 29
[    1.951475] can: raw protocol (rev 20120528)
[    1.951475] can: raw protocol (rev 20120528)
[    1.953531] can: broadcast manager protocol (rev 20120528 t)
[    1.953531] can: broadcast manager protocol (rev 20120528 t)
[    1.956291] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet=
 Project Team
[    1.956291] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet=
 Project Team
[    1.961057] DECnet: Routing cache hash table of 256 buckets, 16Kbytes
[    1.961057] DECnet: Routing cache hash table of 256 buckets, 16Kbytes
[    1.964331] NET: Registered protocol family 12
[    1.964331] NET: Registered protocol family 12
[    1.967012] NET: Registered protocol family 35
[    1.967012] NET: Registered protocol family 35
[    1.969619] lib80211: common routines for IEEE802.11 drivers
[    1.969619] lib80211: common routines for IEEE802.11 drivers
[    1.972619] lib80211_crypt: registered algorithm 'NULL'
[    1.972619] lib80211_crypt: registered algorithm 'NULL'
[    1.975076] lib80211_crypt: registered algorithm 'WEP'
[    1.975076] lib80211_crypt: registered algorithm 'WEP'
[    1.977642] lib80211_crypt: registered algorithm 'CCMP'
[    1.977642] lib80211_crypt: registered algorithm 'CCMP'
[    1.980136] lib80211_crypt: registered algorithm 'TKIP'
[    1.980136] lib80211_crypt: registered algorithm 'TKIP'
[    1.983067] 9pnet: Installing 9P2000 support
[    1.983067] 9pnet: Installing 9P2000 support
[    1.985427] NET: Registered protocol family 36
[    1.985427] NET: Registered protocol family 36
[    1.987936] Key type dns_resolver registered
[    1.987936] Key type dns_resolver registered
[    1.990422]=20
[    1.990422] printing PIC contents
[    1.990422]=20
[    1.990422] printing PIC contents
[    1.992712] ... PIC  IMR: ffff
[    1.992712] ... PIC  IMR: ffff
[    1.994247] ... PIC  IRR: 1113
[    1.994247] ... PIC  IRR: 1113
[    1.995849] ... PIC  ISR: 0000
[    1.995849] ... PIC  ISR: 0000
[    1.997417] ... PIC ELCR: 0c00
[    1.997417] ... PIC ELCR: 0c00
[    1.998974] printing local APIC contents on CPU#0/0:
[    1.998974] printing local APIC contents on CPU#0/0:
[    2.001478] ... APIC ID:      00000000 (0)
[    2.001478] ... APIC ID:      00000000 (0)
[    2.002951] ... APIC VERSION: 00050014
[    2.002951] ... APIC VERSION: 00050014
[    2.002951] ... APIC TASKPRI: 00000000 (00)
[    2.002951] ... APIC TASKPRI: 00000000 (00)
[    2.002951] ... APIC PROCPRI: 00000000
[    2.002951] ... APIC PROCPRI: 00000000
[    2.002951] ... APIC LDR: 01000000
[    2.002951] ... APIC LDR: 01000000
[    2.002951] ... APIC DFR: ffffffff
[    2.002951] ... APIC DFR: ffffffff
[    2.002951] ... APIC SPIV: 000001ff
[    2.002951] ... APIC SPIV: 000001ff
[    2.002951] ... APIC ISR field:
[    2.002951] ... APIC ISR field:
[    2.002951] 00000000
[    2.002951] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    2.002951] ... APIC TMR field:
[    2.002951] ... APIC TMR field:
[    2.002951] 00000000
[    2.002951] 000000000200000002000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    2.002951] ... APIC IRR field:
[    2.002951] ... APIC IRR field:
[    2.002951] 00000000
[    2.002951] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000800000008000

[    2.002951] ... APIC ESR: 00000000
[    2.002951] ... APIC ESR: 00000000
[    2.002951] ... APIC ICR: 00000831
[    2.002951] ... APIC ICR: 00000831
[    2.002951] ... APIC ICR2: 01000000
[    2.002951] ... APIC ICR2: 01000000
[    2.002951] ... APIC LVTT: 000200ef
[    2.002951] ... APIC LVTT: 000200ef
[    2.002951] ... APIC LVTPC: 00010000
[    2.002951] ... APIC LVTPC: 00010000
[    2.002951] ... APIC LVT0: 00010700
[    2.002951] ... APIC LVT0: 00010700
[    2.002951] ... APIC LVT1: 00000400
[    2.002951] ... APIC LVT1: 00000400
[    2.002951] ... APIC LVTERR: 000000fe
[    2.002951] ... APIC LVTERR: 000000fe
[    2.002951] ... APIC TMICT: 0003d08f
[    2.002951] ... APIC TMICT: 0003d08f
[    2.002951] ... APIC TMCCT: 000125e0
[    2.002951] ... APIC TMCCT: 000125e0
[    2.002951] ... APIC TDCR: 00000003
[    2.002951] ... APIC TDCR: 00000003
[    2.002951]=20
[    2.002951]=20
[    2.049474] number of MP IRQ sources: 15.
[    2.049474] number of MP IRQ sources: 15.
[    2.051205] number of IO-APIC #0 registers: 24.
[    2.051205] number of IO-APIC #0 registers: 24.
[    2.053128] testing the IO APIC.......................
[    2.053128] testing the IO APIC.......................
[    2.055377] IO APIC #0......
[    2.055377] IO APIC #0......
[    2.056168] .... register #00: 00000000
[    2.056168] .... register #00: 00000000
[    2.057224] .......    : physical APIC id: 00
[    2.057224] .......    : physical APIC id: 00
[    2.058450] .......    : Delivery Type: 0
[    2.058450] .......    : Delivery Type: 0
[    2.059655] .......    : LTS          : 0
[    2.059655] .......    : LTS          : 0
[    2.060770] .... register #01: 00170011
[    2.060770] .... register #01: 00170011
[    2.061810] .......     : max redirection entries: 17
[    2.061810] .......     : max redirection entries: 17
[    2.063233] .......     : PRQ implemented: 0
[    2.063233] .......     : PRQ implemented: 0
[    2.064732] .......     : IO APIC version: 11
[    2.064732] .......     : IO APIC version: 11
[    2.065883] .... register #02: 00000000
[    2.065883] .... register #02: 00000000
[    2.067006] .......     : arbitration: 00
[    2.067006] .......     : arbitration: 00
[    2.068122] .... IRQ redirection table:
[    2.068122] .... IRQ redirection table:
[    2.069194] 1    0    0   0   0    0    0    00
[    2.069194] 1    0    0   0   0    0    0    00
[    2.070491] 0    0    0   0   0    1    1    31
[    2.070491] 0    0    0   0   0    1    1    31
[    2.071801] 0    0    0   0   0    1    1    30
[    2.071801] 0    0    0   0   0    1    1    30
[    2.073038] 0    0    0   0   0    1    1    33
[    2.073038] 0    0    0   0   0    1    1    33
[    2.074300] 1    0    0   0   0    1    1    34
[    2.074300] 1    0    0   0   0    1    1    34
[    2.075647] 1    1    0   0   0    1    1    35
[    2.075647] 1    1    0   0   0    1    1    35
[    2.076888] 0    0    0   0   0    1    1    36
[    2.076888] 0    0    0   0   0    1    1    36
[    2.078139] 0    0    0   0   0    1    1    37
[    2.078139] 0    0    0   0   0    1    1    37
[    2.079455] 0    0    0   0   0    1    1    38
[    2.079455] 0    0    0   0   0    1    1    38
[    2.080753] 0    1    0   0   0    1    1    39
[    2.080753] 0    1    0   0   0    1    1    39
[    2.081999] 1    1    0   0   0    1    1    3A
[    2.081999] 1    1    0   0   0    1    1    3A
[    2.083317] 1    1    0   0   0    1    1    3B
[    2.083317] 1    1    0   0   0    1    1    3B
[    2.084622] 0    0    0   0   0    1    1    3C
[    2.084622] 0    0    0   0   0    1    1    3C
[    2.085902] 0    0    0   0   0    1    1    3D
[    2.085902] 0    0    0   0   0    1    1    3D
[    2.087435] 0    0    0   0   0    1    1    3E
[    2.087435] 0    0    0   0   0    1    1    3E
[    2.089689] 0    0    0   0   0    1    1    3F
[    2.089689] 0    0    0   0   0    1    1    3F
[    2.092030] 1    0    0   0   0    0    0    00
[    2.092030] 1    0    0   0   0    0    0    00
[    2.094055] 1    0    0   0   0    0    0    00
[    2.094055] 1    0    0   0   0    0    0    00
[    2.096191] 1    0    0   0   0    0    0    00
[    2.096191] 1    0    0   0   0    0    0    00
[    2.098604] 1    0    0   0   0    0    0    00
[    2.098604] 1    0    0   0   0    0    0    00
[    2.100990] 1    0    0   0   0    0    0    00
[    2.100990] 1    0    0   0   0    0    0    00
[    2.103205] 1    0    0   0   0    0    0    00
[    2.103205] 1    0    0   0   0    0    0    00
[    2.105516] 1    0    0   0   0    0    0    00
[    2.105516] 1    0    0   0   0    0    0    00
[    2.107515] 1    0    0   0   0    0    0    00
[    2.107515] 1    0    0   0   0    0    0    00
[    2.109563] IRQ to pin mappings:
[    2.109563] IRQ to pin mappings:
[    2.111375] IRQ0=20
[    2.111375] IRQ0 -> 0:2-> 0:2

[    2.112799] IRQ1=20
[    2.112799] IRQ1 -> 0:1-> 0:1

[    2.113971] IRQ3=20
[    2.113971] IRQ3 -> 0:3-> 0:3

[    2.115322] IRQ4=20
[    2.115322] IRQ4 -> 0:4-> 0:4

[    2.116645] IRQ5=20
[    2.116645] IRQ5 -> 0:5-> 0:5

[    2.117991] IRQ6=20
[    2.117991] IRQ6 -> 0:6-> 0:6

[    2.119375] IRQ7=20
[    2.119375] IRQ7 -> 0:7-> 0:7

[    2.120680] IRQ8=20
[    2.120680] IRQ8 -> 0:8-> 0:8

[    2.121958] IRQ9=20
[    2.121958] IRQ9 -> 0:9-> 0:9

[    2.123214] IRQ10=20
[    2.123214] IRQ10 -> 0:10-> 0:10

[    2.124681] IRQ11=20
[    2.124681] IRQ11 -> 0:11-> 0:11

[    2.126127] IRQ12=20
[    2.126127] IRQ12 -> 0:12-> 0:12

[    2.127574] IRQ13=20
[    2.127574] IRQ13 -> 0:13-> 0:13

[    2.128898] IRQ14=20
[    2.128898] IRQ14 -> 0:14-> 0:14

[    2.130234] IRQ15=20
[    2.130234] IRQ15 -> 0:15-> 0:15

[    2.131577] .................................... done.
[    2.131577] .................................... done.
[    2.136005] bootconsole [earlyser0] disabled
[    2.136005] bootconsole [earlyser0] disabled
[    2.138307] Loading compiled-in X.509 certificates
[    2.141355] Loaded X.509 cert 'Magrathea: Glacier signing key: d8a38edb2=
0cbcfd5c610cb514df4d8d692b241c3'
[    2.151226] debug: unmapping init [mem 0xffffffff81ab0000-0xffffffff81ba=
afff]
[    2.157005] kworker/u2:1 (87) used greatest stack depth: 6176 bytes left
[    2.177634] mount (90) used greatest stack depth: 5864 bytes left
/etc/rcS.d/S00fbsetup: line 3: /sbin/modprobe: not found
[    2.190888] S00fbsetup (93) used greatest stack depth: 5840 bytes left
[    2.193080] S00fbsetup (92) used greatest stack depth: 5640 bytes left

Please wait: booting...
[    2.209712] rc (100) used greatest stack depth: 5152 bytes left
Starting udev
error initializing inotify
error sending message: Connection refused
[    2.326574] tsc: Refined TSC clocksource calibration: 2299.967 MHz
error sending message: Connection refused
Starting Bootlog daemon: bootlogd: cannot find console device 4:64 under /d=
ev
bootlogd.
Configuring network interfaces... ifconfig: socket: Address family not supp=
orted by protocol
done.
hwclock: can't open '/dev/misc/rtc': No such file or directory
Running postinst /etc/rpm-postinsts/100...
[    3.658976] BUG: unable to handle kernel paging request at ffff880008142=
f40
[    3.661422] IP: [<ffffffff8111a1d8>] vmacache_find+0x78/0x90
[    3.662223] PGD 2542067 PUD 2543067 PMD fba5067 PTE 8000000008142060
[    3.662223] Oops: 0000 [#1] DEBUG_PAGEALLOC
[    3.662223] Modules linked in:
[    3.662223] CPU: 0 PID: 326 Comm: 90-trinity Not tainted 3.14.0-rc5-next=
-20140307 #1
[    3.662223] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.662223] task: ffff8800083020d0 ti: ffff8800082a0000 task.ti: ffff880=
0082a0000
[    3.662223] RIP: 0010:[<ffffffff8111a1d8>]  [<ffffffff8111a1d8>] vmacach=
e_find+0x78/0x90
[    3.662223] RSP: 0000:ffff8800082a1e00  EFLAGS: 00010282
[    3.662223] RAX: ffff880008142f40 RBX: 00000000000000a9 RCX: ffff8800083=
020d0
[    3.662223] RDX: 0000000000000002 RSI: 00007fff8a141698 RDI: ffff8800081=
24bc0
[    3.662223] RBP: ffff8800082a1e00 R08: 0000000000000000 R09: 00000000000=
00001
[    3.662223] R10: ffff8800083020d0 R11: 0000000000000000 R12: 00007fff8a1=
41698
[    3.662223] R13: ffff880008124bc0 R14: ffff8800082a1f58 R15: ffff8800083=
020d0
[    3.662223] FS:  00007fe3ca364700(0000) GS:ffffffff81a06000(0000) knlGS:=
0000000000000000
[    3.662223] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    3.662223] CR2: ffff880008142f40 CR3: 000000000824c000 CR4: 00000000000=
006b0
[    3.662223] Stack:
[    3.662223]  ffff8800082a1e28 ffffffff81125219 00000000000000a9 00007fff=
8a141698
[    3.662223]  ffff880008124bc0 ffff8800082a1f28 ffffffff816d71fe 00000000=
00000246
[    3.662223]  0000000000000002 ffff880008124c58 0000000000000006 00000000=
00000010
[    3.662223] Call Trace:
[    3.662223]  [<ffffffff81125219>] find_vma+0x19/0x70
[    3.662223]  [<ffffffff816d71fe>] __do_page_fault+0x29e/0x560
[    3.662223]  [<ffffffff8116cc6f>] ? mntput_no_expire+0x6f/0x1a0
[    3.662223]  [<ffffffff8116cc11>] ? mntput_no_expire+0x11/0x1a0
[    3.662223]  [<ffffffff8116cdd5>] ? mntput+0x35/0x40
[    3.662223]  [<ffffffff8114f51f>] ? __fput+0x24f/0x290
[    3.662223]  [<ffffffff812794ca>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[    3.662223]  [<ffffffff816d74ce>] do_page_fault+0xe/0x10
[    3.662223]  [<ffffffff816d6ad5>] do_async_page_fault+0x35/0x90
[    3.662223]  [<ffffffff816d3b05>] async_page_fault+0x25/0x30
[    3.662223] Code: c7 81 b0 02 00 00 00 00 00 00 eb 32 0f 1f 80 00 00 00 =
00 31 d2 66 0f 1f 44 00 00 48 63 c2 48 8b 84 c1 98 02 00 00 48 85 c0 74 0b =
<48> 39 30 77 06 48 3b 70 08 72 0a 83 c2 01 83 fa 04 75 dd 31 c0=20
[    3.662223] RIP  [<ffffffff8111a1d8>] vmacache_find+0x78/0x90
[    3.662223]  RSP <ffff8800082a1e00>
[    3.662223] CR2: ffff880008142f40
[    3.662223] ---[ end trace dead6556b35f2f50 ]---
[    3.662223] Kernel panic - not syncing: Fatal exception
[    3.662223] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range=
: 0xffffffff80000000-0xffffffff9fffffff)
[    3.662223] Rebooting in 10 seconds..
Elapsed time: 10
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/x86_64-randconfig=
-i1-03091831/1b0a7e3263168a06d3858798e48c5a21d1c78d3c/vmlinuz-3.14.0-rc5-ne=
xt-20140307 -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug a=
pic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=
=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 console=
=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/ke=
rnel-tests/run-queue/kvm/x86_64-randconfig-i1-03091831/next:master/.vmlinuz=
-1b0a7e3263168a06d3858798e48c5a21d1c78d3c-20140309184826-9-snb branch=3Dnex=
t/master BOOT_IMAGE=3D/kernel/x86_64-randconfig-i1-03091831/1b0a7e3263168a0=
6d3858798e48c5a21d1c78d3c/vmlinuz-3.14.0-rc5-next-20140307'  -initrd /kerne=
l-tests/initrd/yocto-minimal-x86_64.cgz -m 256 -smp 2 -net nic,vlan=3D1,mod=
el=3De1000 -net user,vlan=3D1,hostfwd=3Dtcp::28916-:22 -boot order=3Dnc -no=
-reboot -watchdog i6300esb -rtc base=3Dlocaltime -drive file=3D/fs/LABEL=3D=
KVM/disk0-yocto-snb-26,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DK=
VM/disk1-yocto-snb-26,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKV=
M/disk2-yocto-snb-26,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM=
/disk3-yocto-snb-26,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/=
disk4-yocto-snb-26,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/d=
isk5-yocto-snb-26,media=3Ddisk,if=3Dvirtio -pidfile /dev/shm/kboot/pid-yoct=
o-snb-26 -serial file:/dev/shm/kboot/serial-yocto-snb-26 -daemonize -displa=
y none -monitor null=20

--J2SCkAp4GZ/dPZZf
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="x86_64-randconfig-i1-03091831-1b0a7e3263168a06d3858798e48c5a21d1c78d3c-BUG:-unable-to-handle-kernel-paging-request-at-78607.log"
Content-Transfer-Encoding: base64

Z2l0IGNoZWNrb3V0IDU2MDMyZmM1MDRjOWNlOWRkNmZkNjk3ZTQ2ODc0NDFhN2QwZWE0YTIK
bHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWkx
LTAzMDkxODMxL25leHQ6bWFzdGVyOjU2MDMyZmM1MDRjOWNlOWRkNmZkNjk3ZTQ2ODc0NDFh
N2QwZWE0YTI6YmlzZWN0LW5ldAoKMjAxNC0wMy0wOS0xOTowMTowNSA1NjAzMmZjNTA0Yzlj
ZTlkZDZmZDY5N2U0Njg3NDQxYTdkMGVhNGEyIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFz
ayB0byAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAz
MDkxODMxLTU2MDMyZmM1MDRjOWNlOWRkNmZkNjk3ZTQ2ODc0NDFhN2QwZWE0YTIKQ2hlY2sg
Zm9yIGtlcm5lbCBpbiAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLzU2
MDMyZmM1MDRjOWNlOWRkNmZkNjk3ZTQ2ODc0NDFhN2QwZWE0YTIKd2FpdGluZyBmb3IgY29t
cGxldGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5kY29uZmln
LWkxLTAzMDkxODMxLTU2MDMyZmM1MDRjOWNlOWRkNmZkNjk3ZTQ2ODc0NDFhN2QwZWE0YTIK
d2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlLy54
ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS01NjAzMmZjNTA0YzljZTlkZDZmZDY5N2U0
Njg3NDQxYTdkMGVhNGEyCmtlcm5lbDogL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1pMS0w
MzA5MTgzMS81NjAzMmZjNTA0YzljZTlkZDZmZDY5N2U0Njg3NDQxYTdkMGVhNGEyL3ZtbGlu
dXotMy4xNC4wLXJjNS0wNjcyMS1nNTYwMzJmYwoKMjAxNC0wMy0wOS0xOToxMDowNSBkZXRl
Y3RpbmcgYm9vdCBzdGF0ZSAuCTEJMgk2CTE1CTE4CTIyIFNVQ0NFU1MKCmJpc2VjdDogZ29v
ZCBjb21taXQgNTYwMzJmYzUwNGM5Y2U5ZGQ2ZmQ2OTdlNDY4NzQ0MWE3ZDBlYTRhMgpnaXQg
YmlzZWN0IHN0YXJ0IDFiMGE3ZTMyNjMxNjhhMDZkMzg1ODc5OGU0OGM1YTIxZDFjNzhkM2Mg
NTYwMzJmYzUwNGM5Y2U5ZGQ2ZmQ2OTdlNDY4NzQ0MWE3ZDBlYTRhMiAtLQovYy9rZXJuZWwt
dGVzdHMvbGluZWFyLWJpc2VjdDogWyItYiIsICIxYjBhN2UzMjYzMTY4YTA2ZDM4NTg3OThl
NDhjNWEyMWQxYzc4ZDNjIiwgIi1nIiwgIjU2MDMyZmM1MDRjOWNlOWRkNmZkNjk3ZTQ2ODc0
NDFhN2QwZWE0YTIiLCAiL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVy
ZS5zaCIsICIvaG9tZS93ZmcvbmV0L29iai1iaXNlY3QiXQpCaXNlY3Rpbmc6IDQwOCByZXZp
c2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgOSBzdGVwcykKWzhlNmE1
ZjEwOTQ4MTlhNzQ3YzEzZDZmZmVmNWM0NDYwN2ZiNzU3ZjhdIE1lcmdlIGJyYW5jaCAnYWtw
bS1jdXJyZW50L2N1cnJlbnQnCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0
LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEgL2tlcm5l
bC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxL25l
eHQ6bWFzdGVyOjhlNmE1ZjEwOTQ4MTlhNzQ3YzEzZDZmZmVmNWM0NDYwN2ZiNzU3Zjg6Ymlz
ZWN0LW5ldAoKMjAxNC0wMy0wOS0xOToxMzozNyA4ZTZhNWYxMDk0ODE5YTc0N2MxM2Q2ZmZl
ZjVjNDQ2MDdmYjc1N2Y4IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2VybmVs
LXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLThlNmE1
ZjEwOTQ4MTlhNzQ3YzEzZDZmZmVmNWM0NDYwN2ZiNzU3ZjgKQ2hlY2sgZm9yIGtlcm5lbCBp
biAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLzhlNmE1ZjEwOTQ4MTlh
NzQ3YzEzZDZmZmVmNWM0NDYwN2ZiNzU3ZjgKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAv
a2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMx
LThlNmE1ZjEwOTQ4MTlhNzQ3YzEzZDZmZmVmNWM0NDYwN2ZiNzU3ZjgKd2FpdGluZyBmb3Ig
Y29tcGxldGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlLy54ODZfNjQtcmFuZGNv
bmZpZy1pMS0wMzA5MTgzMS04ZTZhNWYxMDk0ODE5YTc0N2MxM2Q2ZmZlZjVjNDQ2MDdmYjc1
N2Y4Cmtlcm5lbDogL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS84ZTZh
NWYxMDk0ODE5YTc0N2MxM2Q2ZmZlZjVjNDQ2MDdmYjc1N2Y4L3ZtbGludXotMy4xNC4wLXJj
NS0wNzEyMC1nOGU2YTVmMQoKMjAxNC0wMy0wOS0xOTozMDozNyBkZXRlY3RpbmcgYm9vdCBz
dGF0ZSAuIFRFU1QgRkFJTFVSRQpod2Nsb2NrOiBjYW4ndCBvcGVuICcvZGV2L21pc2MvcnRj
JzogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9yeQpSdW5uaW5nIHBvc3RpbnN0IC9ldGMvcnBt
LXBvc3RpbnN0cy8xMDAuLi4KWyAgICAxLjY0NjA2M10gdHNjOiBSZWZpbmVkIFRTQyBjbG9j
a3NvdXJjZSBjYWxpYnJhdGlvbjogMjQ5My45NjQgTUh6ClsgICAgMi4yMTkyMzZdIEJVRzog
dW5hYmxlIHRvIGhhbmRsZSBrZXJuZWwgcGFnaW5nIHJlcXVlc3QgYXQgZmZmZjg4MDAwYmY3
NmY0MApbICAgIDIuMjIwNjA0XSBJUDogWzxmZmZmZmZmZjgxMTFhMTA4Pl0gdm1hY2FjaGVf
ZmluZCsweDc4LzB4OTAKWyAgICAyLjIyMTcxMl0gUEdEIDI1NDIwNjcgUFVEIDI1NDMwNjcg
UE1EIDEzYjg2MDY3IFBURSA4MDAwMDAwMDBiZjc2MDYwClsgICAgMi4yMjE5NThdIE9vcHM6
IDAwMDAgWyMxXSBERUJVR19QQUdFQUxMT0MKWyAgICAyLjIyMTk1OF0gTW9kdWxlcyBsaW5r
ZWQgaW46ClsgICAgMi4yMjE5NThdIENQVTogMCBQSUQ6IDMyNSBDb21tOiA5MC10cmluaXR5
IE5vdCB0YWludGVkIDMuMTQuMC1yYzUtMDcxMjAtZzhlNmE1ZjEgIzEKWyAgICAyLjIyMTk1
OF0gSGFyZHdhcmUgbmFtZTogQm9jaHMgQm9jaHMsIEJJT1MgQm9jaHMgMDEvMDEvMjAxMQpb
ICAgIDIuMjIxOTU4XSB0YXNrOiBmZmZmODgwMDBiZGY0MDUwIHRpOiBmZmZmODgwMDBiYzVl
MDAwIHRhc2sudGk6IGZmZmY4ODAwMGJjNWUwMDAKWyAgICAyLjIyMTk1OF0gUklQOiAwMDEw
Ols8ZmZmZmZmZmY4MTExYTEwOD5dICBbPGZmZmZmZmZmODExMWExMDg+XSB2bWFjYWNoZV9m
aW5kKzB4NzgvMHg5MApbICAgIDIuMjIxOTU4XSBSU1A6IDAwMDA6ZmZmZjg4MDAwYmM1ZmUw
MCAgRUZMQUdTOiAwMDAxMDI4MgpbICAgIDIuMjIxOTU4XSBSQVg6IGZmZmY4ODAwMGJmNzZm
NDAgUkJYOiAwMDAwMDAwMDAwMDAwMGE5IFJDWDogZmZmZjg4MDAwYmRmNDA1MApbICAgIDIu
MjIxOTU4XSBSRFg6IDAwMDAwMDAwMDAwMDAwMDIgUlNJOiAwMDAwN2ZmZjRmNDBmMWU4IFJE
STogZmZmZjg4MDAwYmYzNmJjMApbICAgIDIuMjIxOTU4XSBSQlA6IGZmZmY4ODAwMGJjNWZl
MDAgUjA4OiAwMDAwMDAwMDAwMDAwMDAwIFIwOTogMDAwMDAwMDAwMDAwMDAwMQpbICAgIDIu
MjIxOTU4XSBSMTA6IGZmZmY4ODAwMGJkZjQwNTAgUjExOiAwMDAwMDAwMDAwMDAwMDAwIFIx
MjogMDAwMDdmZmY0ZjQwZjFlOApbICAgIDIuMjIxOTU4XSBSMTM6IGZmZmY4ODAwMGJmMzZi
YzAgUjE0OiBmZmZmODgwMDBiYzVmZjU4IFIxNTogZmZmZjg4MDAwYmRmNDA1MApbICAgIDIu
MjIxOTU4XSBGUzogIDAwMDA3ZmYyODFkMGU3MDAoMDAwMCkgR1M6ZmZmZmZmZmY4MWEwNjAw
MCgwMDAwKSBrbmxHUzowMDAwMDAwMDAwMDAwMDAwClsgICAgMi4yMjE5NThdIENTOiAgMDAx
MCBEUzogMDAwMCBFUzogMDAwMCBDUjA6IDAwMDAwMDAwODAwNTAwMzMKWyAgICAyLjIyMTk1
OF0gQ1IyOiBmZmZmODgwMDBiZjc2ZjQwIENSMzogMDAwMDAwMDAwZDI5MzAwMCBDUjQ6IDAw
MDAwMDAwMDAwMDA2YjAKWyAgICAyLjIyMTk1OF0gU3RhY2s6ClsgICAgMi4yMjE5NThdICBm
ZmZmODgwMDBiYzVmZTI4IGZmZmZmZmZmODExMjUxNDkgMDAwMDAwMDAwMDAwMDBhOSAwMDAw
N2ZmZjRmNDBmMWU4ClsgICAgMi4yMjE5NThdICBmZmZmODgwMDBiZjM2YmMwIGZmZmY4ODAw
MGJjNWZmMjggZmZmZmZmZmY4MTZkNzEzZSAwMDAwMDAwMDAwMDAwMjQ2ClsgICAgMi4yMjE5
NThdICAwMDAwMDAwMDAwMDAwMDAyIGZmZmY4ODAwMGJmMzZjNTggMDAwMDAwMDAwMDAwMDAw
NiAwMDAwMDAwMDAwMDAwMDEwClsgICAgMi4yMjE5NThdIENhbGwgVHJhY2U6ClsgICAgMi4y
MjE5NThdICBbPGZmZmZmZmZmODExMjUxNDk+XSBmaW5kX3ZtYSsweDE5LzB4NzAKWyAgICAy
LjIyMTk1OF0gIFs8ZmZmZmZmZmY4MTZkNzEzZT5dIF9fZG9fcGFnZV9mYXVsdCsweDI5ZS8w
eDU2MApbICAgIDIuMjIxOTU4XSAgWzxmZmZmZmZmZjgxMTZjYjlmPl0gPyBtbnRwdXRfbm9f
ZXhwaXJlKzB4NmYvMHgxYTAKWyAgICAyLjIyMTk1OF0gIFs8ZmZmZmZmZmY4MTE2Y2I0MT5d
ID8gbW50cHV0X25vX2V4cGlyZSsweDExLzB4MWEwClsgICAgMi4yMjE5NThdICBbPGZmZmZm
ZmZmODExNmNkMDU+XSA/IG1udHB1dCsweDM1LzB4NDAKWyAgICAyLjIyMTk1OF0gIFs8ZmZm
ZmZmZmY4MTE0ZjQ0Zj5dID8gX19mcHV0KzB4MjRmLzB4MjkwClsgICAgMi4yMjE5NThdICBb
PGZmZmZmZmZmODEyNzkzZmE+XSA/IHRyYWNlX2hhcmRpcnFzX29mZl90aHVuaysweDNhLzB4
M2MKWyAgICAyLjIyMTk1OF0gIFs8ZmZmZmZmZmY4MTZkNzQwZT5dIGRvX3BhZ2VfZmF1bHQr
MHhlLzB4MTAKWyAgICAyLjIyMTk1OF0gIFs8ZmZmZmZmZmY4MTZkNmExNT5dIGRvX2FzeW5j
X3BhZ2VfZmF1bHQrMHgzNS8weDkwClsgICAgMi4yMjE5NThdICBbPGZmZmZmZmZmODE2ZDNh
NDU+XSBhc3luY19wYWdlX2ZhdWx0KzB4MjUvMHgzMApbICAgIDIuMjIxOTU4XSBDb2RlOiBj
NyA4MSBiMCAwMiAwMCAwMCAwMCAwMCAwMCAwMCBlYiAzMiAwZiAxZiA4MCAwMCAwMCAwMCAw
MCAzMSBkMiA2NiAwZiAxZiA0NCAwMCAwMCA0OCA2MyBjMiA0OCA4YiA4NCBjMSA5OCAwMiAw
MCAwMCA0OCA4NSBjMCA3NCAwYiA8NDg+IDM5IDMwIDc3IDA2IDQ4IDNiIDcwIDA4IDcyIDBh
IDgzIGMyIDAxIDgzIGZhIDA0IDc1IGRkIDMxIGMwIApbICAgIDIuMjIxOTU4XSBSSVAgIFs8
ZmZmZmZmZmY4MTExYTEwOD5dIHZtYWNhY2hlX2ZpbmQrMHg3OC8weDkwClsgICAgMi4yMjE5
NThdICBSU1AgPGZmZmY4ODAwMGJjNWZlMDA+ClsgICAgMi4yMjE5NThdIENSMjogZmZmZjg4
MDAwYmY3NmY0MApbICAgIDIuMjIxOTU4XSAtLS1bIGVuZCB0cmFjZSBlNzM1NmE3YTJiMGFm
NWE5IF0tLS0KWyAgICAyLjIyMTk1OF0gS2VybmVsIHBhbmljIC0gbm90IHN5bmNpbmc6IEZh
dGFsIGV4Y2VwdGlvbgova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLzhl
NmE1ZjEwOTQ4MTlhNzQ3YzEzZDZmZmVmNWM0NDYwN2ZiNzU3ZjgvZG1lc2cteW9jdG8taXZ5
dG93bjItMjQ6MjAxNDAzMDkxOTMwNDg6eDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4MzE6
My4xNC4wLXJjNS0wNzEyMC1nOGU2YTVmMToxCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWct
aTEtMDMwOTE4MzEvOGU2YTVmMTA5NDgxOWE3NDdjMTNkNmZmZWY1YzQ0NjA3ZmI3NTdmOC9k
bWVzZy15b2N0by1pdnl0b3duMi0yNDoyMDE0MDMwOTE5MzEwMzp4ODZfNjQtcmFuZGNvbmZp
Zy1pMS0wMzA5MTgzMTozLjE0LjAtcmM1LTA3MTIwLWc4ZTZhNWYxOjEKMDoyOjIgYWxsX2dv
b2Q6YmFkOmFsbF9iYWQgYm9vdHMKCmxpbmVhci1iaXNlY3Q6IGJhZCBicmFuY2ggbWF5IGJl
IGJyYW5jaCAnYWtwbS1jdXJyZW50L2N1cnJlbnQnCmxpbmVhci1iaXNlY3Q6IGhhbmRsZSBv
dmVyIHRvIGdpdCBiaXNlY3QKbGluZWFyLWJpc2VjdDogZ2l0IGJpc2VjdCBzdGFydCA4ZTZh
NWYxMDk0ODE5YTc0N2MxM2Q2ZmZlZjVjNDQ2MDdmYjc1N2Y4IDU2MDMyZmM1MDRjOWNlOWRk
NmZkNjk3ZTQ2ODc0NDFhN2QwZWE0YTIgLS0KUHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMg
OGU2YTVmMS4uLiBNZXJnZSBicmFuY2ggJ2FrcG0tY3VycmVudC9jdXJyZW50JwpTd2l0Y2hl
ZCB0byBicmFuY2ggJ21hc3RlcicKWW91ciBicmFuY2ggaXMgYmVoaW5kICdvcmlnaW4vbWFz
dGVyJyBieSA0MTIxMyBjb21taXRzLCBhbmQgY2FuIGJlIGZhc3QtZm9yd2FyZGVkLgogICh1
c2UgImdpdCBwdWxsIiB0byB1cGRhdGUgeW91ciBsb2NhbCBicmFuY2gpCkJpc2VjdGluZzog
MTk5IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA4IHN0ZXBz
KQpbZTM3ZjdlNzA2ZGFhYjEyODIyMWYxZmU3Mjk2N2VhNGY5YWMwYzFkYV0genJhbTogbW92
ZSB6cmFtIHNpemUgd2FybmluZyB0byBkb2N1bWVudGF0aW9uCmxpbmVhci1iaXNlY3Q6IGdp
dCBiaXNlY3QgcnVuIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUu
c2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jp
c2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbmV0L29iai1iaXNlY3QKbHMg
LWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAz
MDkxODMxL25leHQ6bWFzdGVyOmUzN2Y3ZTcwNmRhYWIxMjgyMjFmMWZlNzI5NjdlYTRmOWFj
MGMxZGE6YmlzZWN0LW5ldAoKMjAxNC0wMy0wOS0xOTozMTozMiBlMzdmN2U3MDZkYWFiMTI4
MjIxZjFmZTcyOTY3ZWE0ZjlhYzBjMWRhIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0
byAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkx
ODMxLWUzN2Y3ZTcwNmRhYWIxMjgyMjFmMWZlNzI5NjdlYTRmOWFjMGMxZGEKQ2hlY2sgZm9y
IGtlcm5lbCBpbiAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxL2UzN2Y3
ZTcwNmRhYWIxMjgyMjFmMWZlNzI5NjdlYTRmOWFjMGMxZGEKd2FpdGluZyBmb3IgY29tcGxl
dGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5kY29uZmlnLWkx
LTAzMDkxODMxLWUzN2Y3ZTcwNmRhYWIxMjgyMjFmMWZlNzI5NjdlYTRmOWFjMGMxZGEKd2Fp
dGluZyBmb3IgY29tcGxldGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlLy54ODZf
NjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS1lMzdmN2U3MDZkYWFiMTI4MjIxZjFmZTcyOTY3
ZWE0ZjlhYzBjMWRhCmtlcm5lbDogL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5
MTgzMS9lMzdmN2U3MDZkYWFiMTI4MjIxZjFmZTcyOTY3ZWE0ZjlhYzBjMWRhL3ZtbGludXot
My4xNC4wLXJjNS0wMDI0Mi1nZTM3ZjdlNwoKMjAxNC0wMy0wOS0xOTo1MjozMiBkZXRlY3Rp
bmcgYm9vdCBzdGF0ZSAuIFRFU1QgRkFJTFVSRQpkb25lLgpod2Nsb2NrOiBjYW4ndCBvcGVu
ICcvZGV2L21pc2MvcnRjJzogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9yeQpSdW5uaW5nIHBv
c3RpbnN0IC9ldGMvcnBtLXBvc3RpbnN0cy8xMDAuLi4KWyAgICAyLjQwMTQxN10gQlVHOiB1
bmFibGUgdG8gaGFuZGxlIGtlcm5lbCBwYWdpbmcgcmVxdWVzdCBhdCBmZmZmODgwMDBjMTkz
ZjQwClsgICAgMi40MDI3MDVdIElQOiBbPGZmZmZmZmZmODExMThjZTg+XSB2bWFjYWNoZV9m
aW5kKzB4NzgvMHg5MApbICAgIDIuNDAzNjY4XSBQR0QgMjUzNDA2NyBQVUQgMjUzNTA2NyBQ
TUQgMTNiODUwNjcgUFRFIDgwMDAwMDAwMGMxOTMwNjAKWyAgICAyLjQwNDEzMV0gT29wczog
MDAwMCBbIzFdIERFQlVHX1BBR0VBTExPQwpbICAgIDIuNDA0MTMxXSBNb2R1bGVzIGxpbmtl
ZCBpbjoKWyAgICAyLjQwNDEzMV0gQ1BVOiAwIFBJRDogMzE5IENvbW06IDkwLXRyaW5pdHkg
Tm90IHRhaW50ZWQgMy4xNC4wLXJjNS0wMDI0Mi1nZTM3ZjdlNyAjMgpbICAgIDIuNDA0MTMx
XSBIYXJkd2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklPUyBCb2NocyAwMS8wMS8yMDExClsg
ICAgMi40MDQxMzFdIHRhc2s6IGZmZmY4ODAwMGMwOTAwOTAgdGk6IGZmZmY4ODAwMGMxMDAw
MDAgdGFzay50aTogZmZmZjg4MDAwYzEwMDAwMApbICAgIDIuNDA0MTMxXSBSSVA6IDAwMTA6
WzxmZmZmZmZmZjgxMTE4Y2U4Pl0gIFs8ZmZmZmZmZmY4MTExOGNlOD5dIHZtYWNhY2hlX2Zp
bmQrMHg3OC8weDkwClsgICAgMi40MDQxMzFdIFJTUDogMDAwMDpmZmZmODgwMDBjMTAxZTAw
ICBFRkxBR1M6IDAwMDEwMjgyClsgICAgMi40MDQxMzFdIFJBWDogZmZmZjg4MDAwYzE5M2Y0
MCBSQlg6IDAwMDAwMDAwMDAwMDAwYTkgUkNYOiBmZmZmODgwMDBjMDkwMDkwClsgICAgMi40
MDQxMzFdIFJEWDogMDAwMDAwMDAwMDAwMDAwMiBSU0k6IDAwMDA3ZmZmNDhmYzc2ZTggUkRJ
OiBmZmZmODgwMDBhYzViYmMwClsgICAgMi40MDQxMzFdIFJCUDogZmZmZjg4MDAwYzEwMWUw
MCBSMDg6IDAwMDAwMDAwMDAwMDAwMDAgUjA5OiAwMDAwMDAwMDAwMDAwMDAxClsgICAgMi40
MDQxMzFdIFIxMDogMDAwMDAwMDAwMDAwMDAwMCBSMTE6IDAwMDAwMDAwMDAwMDAwMDEgUjEy
OiAwMDAwN2ZmZjQ4ZmM3NmU4ClsgICAgMi40MDQxMzFdIFIxMzogZmZmZjg4MDAwYWM1YmJj
MCBSMTQ6IGZmZmY4ODAwMGMxMDFmNTggUjE1OiBmZmZmODgwMDBjMDkwMDkwClsgICAgMi40
MDQxMzFdIEZTOiAgMDAwMDdmYjBiZjY5YzcwMCgwMDAwKSBHUzpmZmZmZmZmZjgxOWZhMDAw
KDAwMDApIGtubEdTOjAwMDAwMDAwMDAwMDAwMDAKWyAgICAyLjQwNDEzMV0gQ1M6ICAwMDEw
IERTOiAwMDAwIEVTOiAwMDAwIENSMDogMDAwMDAwMDA4MDA1MDAzMwpbICAgIDIuNDA0MTMx
XSBDUjI6IGZmZmY4ODAwMGMxOTNmNDAgQ1IzOiAwMDAwMDAwMDBjN2Y1MDAwIENSNDogMDAw
MDAwMDAwMDAwMDZiMApbICAgIDIuNDA0MTMxXSBTdGFjazoKWyAgICAyLjQwNDEzMV0gIGZm
ZmY4ODAwMGMxMDFlMjggZmZmZmZmZmY4MTEyM2NlOSAwMDAwMDAwMDAwMDAwMGE5IDAwMDA3
ZmZmNDhmYzc2ZTgKWyAgICAyLjQwNDEzMV0gIGZmZmY4ODAwMGFjNWJiYzAgZmZmZjg4MDAw
YzEwMWYyOCBmZmZmZmZmZjgxNmNmMDJlIDAwMDAwMDAwMDAwMDAyNDYKWyAgICAyLjQwNDEz
MV0gIDAwMDAwMDAwMDAwMDAwMDIgZmZmZjg4MDAwYWM1YmM1OCAwMDAwMDAwMDAwMDAwMDA2
IDAwMDAwMDAwMDAwMDAwMTAKWyAgICAyLjQwNDEzMV0gQ2FsbCBUcmFjZToKWyAgICAyLjQw
NDEzMV0gIFs8ZmZmZmZmZmY4MTEyM2NlOT5dIGZpbmRfdm1hKzB4MTkvMHg3MApbICAgIDIu
NDA0MTMxXSAgWzxmZmZmZmZmZjgxNmNmMDJlPl0gX19kb19wYWdlX2ZhdWx0KzB4MjllLzB4
NTYwClsgICAgMi40MDQxMzFdICBbPGZmZmZmZmZmODExNmJhYzI+XSA/IG1udHB1dF9ub19l
eHBpcmUrMHg3Mi8weDFiMApbICAgIDIuNDA0MTMxXSAgWzxmZmZmZmZmZjgxMTZiYTYxPl0g
PyBtbnRwdXRfbm9fZXhwaXJlKzB4MTEvMHgxYjAKWyAgICAyLjQwNDEzMV0gIFs8ZmZmZmZm
ZmY4MTE2YmMzNT5dID8gbW50cHV0KzB4MzUvMHg0MApbICAgIDIuNDA0MTMxXSAgWzxmZmZm
ZmZmZjgxMTRkZmVmPl0gPyBfX2ZwdXQrMHgyNGYvMHgyOTAKWyAgICAyLjQwNDEzMV0gIFs8
ZmZmZmZmZmY4MTI3NmY0YT5dID8gdHJhY2VfaGFyZGlycXNfb2ZmX3RodW5rKzB4M2EvMHgz
YwpbICAgIDIuNDA0MTMxXSAgWzxmZmZmZmZmZjgxNmNmMmZlPl0gZG9fcGFnZV9mYXVsdCsw
eGUvMHgxMApbICAgIDIuNDA0MTMxXSAgWzxmZmZmZmZmZjgxNmNlOTA1Pl0gZG9fYXN5bmNf
cGFnZV9mYXVsdCsweDM1LzB4OTAKWyAgICAyLjQwNDEzMV0gIFs8ZmZmZmZmZmY4MTZjYjhj
NT5dIGFzeW5jX3BhZ2VfZmF1bHQrMHgyNS8weDMwClsgICAgMi40MDQxMzFdIENvZGU6IGM3
IDgxIGIwIDAyIDAwIDAwIDAwIDAwIDAwIDAwIGViIDMyIDBmIDFmIDgwIDAwIDAwIDAwIDAw
IDMxIGQyIDY2IDBmIDFmIDQ0IDAwIDAwIDQ4IDYzIGMyIDQ4IDhiIDg0IGMxIDk4IDAyIDAw
IDAwIDQ4IDg1IGMwIDc0IDBiIDw0OD4gMzkgMzAgNzcgMDYgNDggM2IgNzAgMDggNzIgMGEg
ODMgYzIgMDEgODMgZmEgMDQgNzUgZGQgMzEgYzAgClsgICAgMi40MDQxMzFdIFJJUCAgWzxm
ZmZmZmZmZjgxMTE4Y2U4Pl0gdm1hY2FjaGVfZmluZCsweDc4LzB4OTAKWyAgICAyLjQwNDEz
MV0gIFJTUCA8ZmZmZjg4MDAwYzEwMWUwMD4KWyAgICAyLjQwNDEzMV0gQ1IyOiBmZmZmODgw
MDBjMTkzZjQwClsgICAgMi40MDQxMzFdIC0tLVsgZW5kIHRyYWNlIDgwNWI0YTczZTU2ODUy
ODggXS0tLQpbICAgIDIuNDA0MTMxXSBLZXJuZWwgcGFuaWMgLSBub3Qgc3luY2luZzogRmF0
YWwgZXhjZXB0aW9uCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4MzEvZTM3
ZjdlNzA2ZGFhYjEyODIyMWYxZmU3Mjk2N2VhNGY5YWMwYzFkYS9kbWVzZy15b2N0by1pdnl0
b3duMi0xMDoyMDE0MDMwOTE5NTIyNzp4ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMToz
LjE0LjAtcmM1LTAwMjQyLWdlMzdmN2U3OjIKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1p
MS0wMzA5MTgzMS9lMzdmN2U3MDZkYWFiMTI4MjIxZjFmZTcyOTY3ZWE0ZjlhYzBjMWRhL2Rt
ZXNnLXlvY3RvLWl2eXRvd24yLTY6MjAxNDAzMDkxOTUyNDU6eDg2XzY0LXJhbmRjb25maWct
aTEtMDMwOTE4MzE6My4xNC4wLXJjNS0wMDI0Mi1nZTM3ZjdlNzoyCi9rZXJuZWwveDg2XzY0
LXJhbmRjb25maWctaTEtMDMwOTE4MzEvZTM3ZjdlNzA2ZGFhYjEyODIyMWYxZmU3Mjk2N2Vh
NGY5YWMwYzFkYS9kbWVzZy15b2N0by1pdnl0b3duMi0yNDoyMDE0MDMwOTE5NTI1NTp4ODZf
NjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMTozLjE0LjAtcmM1LTAwMjQyLWdlMzdmN2U3OjIK
MDozOjIgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKCkJpc2VjdGluZzogOTkgcmV2aXNp
b25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDcgc3RlcHMpCls3ZjA4ODVj
ZmJhNjhlZDM1NzQ3NGE1NWVhYTEzYTU3NTczNzFmNGJkXSBtbS1rZWVwLXBhZ2UtY2FjaGUt
cmFkaXgtdHJlZS1ub2Rlcy1pbi1jaGVjay1maXgKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMv
YmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdAps
cyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctaTEt
MDMwOTE4MzEvbmV4dDptYXN0ZXI6N2YwODg1Y2ZiYTY4ZWQzNTc0NzRhNTVlYWExM2E1NzU3
MzcxZjRiZDpiaXNlY3QtbmV0CgoyMDE0LTAzLTA5LTE5OjUzOjA1IDdmMDg4NWNmYmE2OGVk
MzU3NDc0YTU1ZWFhMTNhNTc1NzM3MWY0YmQgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNr
IHRvIC9rZXJuZWwtdGVzdHMvYnVpbGQtcXVldWUveDg2XzY0LXJhbmRjb25maWctaTEtMDMw
OTE4MzEtN2YwODg1Y2ZiYTY4ZWQzNTc0NzRhNTVlYWExM2E1NzU3MzcxZjRiZApDaGVjayBm
b3Iga2VybmVsIGluIC9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4MzEvN2Yw
ODg1Y2ZiYTY4ZWQzNTc0NzRhNTVlYWExM2E1NzU3MzcxZjRiZAp3YWl0aW5nIGZvciBjb21w
bGV0aW9uIG9mIC9rZXJuZWwtdGVzdHMvYnVpbGQtcXVldWUveDg2XzY0LXJhbmRjb25maWct
aTEtMDMwOTE4MzEtN2YwODg1Y2ZiYTY4ZWQzNTc0NzRhNTVlYWExM2E1NzU3MzcxZjRiZAp3
YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rZXJuZWwtdGVzdHMvYnVpbGQtcXVldWUvLng4
Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLTdmMDg4NWNmYmE2OGVkMzU3NDc0YTU1ZWFh
MTNhNTc1NzM3MWY0YmQKa2VybmVsOiAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAz
MDkxODMxLzdmMDg4NWNmYmE2OGVkMzU3NDc0YTU1ZWFhMTNhNTc1NzM3MWY0YmQvdm1saW51
ei0zLjE0LjAtcmM1LTAwMTQyLWc3ZjA4ODVjCgoyMDE0LTAzLTA5LTIwOjEwOjA1IGRldGVj
dGluZyBib290IHN0YXRlIC4JNAkxMgkxNgkyMS4JMjIgU1VDQ0VTUwoKQmlzZWN0aW5nOiA0
OSByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNiBzdGVwcykK
WzBjYWZmOGRjMGNhYmI4MDE1ZmFhMTQyNWMwZTYxZWFiNGY5YzlkMmJdIG1tLG51bWE6IHJl
b3JnYW5pemUgY2hhbmdlX3BtZF9yYW5nZSgpCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jp
c2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbmV0L29iai1iaXNlY3QKbHMg
LWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAz
MDkxODMxL25leHQ6bWFzdGVyOjBjYWZmOGRjMGNhYmI4MDE1ZmFhMTQyNWMwZTYxZWFiNGY5
YzlkMmI6YmlzZWN0LW5ldAoKMjAxNC0wMy0wOS0yMDoxMzozNyAwY2FmZjhkYzBjYWJiODAx
NWZhYTE0MjVjMGU2MWVhYjRmOWM5ZDJiIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0
byAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkx
ODMxLTBjYWZmOGRjMGNhYmI4MDE1ZmFhMTQyNWMwZTYxZWFiNGY5YzlkMmIKQ2hlY2sgZm9y
IGtlcm5lbCBpbiAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLzBjYWZm
OGRjMGNhYmI4MDE1ZmFhMTQyNWMwZTYxZWFiNGY5YzlkMmIKd2FpdGluZyBmb3IgY29tcGxl
dGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5kY29uZmlnLWkx
LTAzMDkxODMxLTBjYWZmOGRjMGNhYmI4MDE1ZmFhMTQyNWMwZTYxZWFiNGY5YzlkMmIKd2Fp
dGluZyBmb3IgY29tcGxldGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlLy54ODZf
NjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS0wY2FmZjhkYzBjYWJiODAxNWZhYTE0MjVjMGU2
MWVhYjRmOWM5ZDJiCmtlcm5lbDogL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5
MTgzMS8wY2FmZjhkYzBjYWJiODAxNWZhYTE0MjVjMGU2MWVhYjRmOWM5ZDJiL3ZtbGludXot
My4xNC4wLXJjNS0wMDE5Mi1nMGNhZmY4ZAoKMjAxNC0wMy0wOS0yMDozMjozNyBkZXRlY3Rp
bmcgYm9vdCBzdGF0ZSAuLi4uLi4uCTEuLgk0CTUJNwk4CTkuCTExCTEyCTE0CTE5CTIxCTIy
IFNVQ0NFU1MKCkJpc2VjdGluZzogMjQgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0
aGlzIChyb3VnaGx5IDUgc3RlcHMpCltkNmU5NTUyNjQ1ZTRmYzMzOTg1ZTZiNjQyZmZkMjg0
MTkxNWVhY2FhXSB0b29scy92bS9wYWdlLXR5cGVzLmM6IHBhZ2UtY2FjaGUgc25pZmZpbmcg
ZmVhdHVyZQpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1
cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVu
LXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS9uZXh0Om1hc3Rlcjpk
NmU5NTUyNjQ1ZTRmYzMzOTg1ZTZiNjQyZmZkMjg0MTkxNWVhY2FhOmJpc2VjdC1uZXQKCjIw
MTQtMDMtMDktMjA6NDM6MzggZDZlOTU1MjY0NWU0ZmMzMzk4NWU2YjY0MmZmZDI4NDE5MTVl
YWNhYSBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tlcm5lbC10ZXN0cy9idWls
ZC1xdWV1ZS94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS1kNmU5NTUyNjQ1ZTRmYzMz
OTg1ZTZiNjQyZmZkMjg0MTkxNWVhY2FhCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC94
ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS9kNmU5NTUyNjQ1ZTRmYzMzOTg1ZTZiNjQy
ZmZkMjg0MTkxNWVhY2FhCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tlcm5lbC10ZXN0
cy9idWlsZC1xdWV1ZS94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS1kNmU5NTUyNjQ1
ZTRmYzMzOTg1ZTZiNjQyZmZkMjg0MTkxNWVhY2FhCndhaXRpbmcgZm9yIGNvbXBsZXRpb24g
b2YgL2tlcm5lbC10ZXN0cy9idWlsZC1xdWV1ZS8ueDg2XzY0LXJhbmRjb25maWctaTEtMDMw
OTE4MzEtZDZlOTU1MjY0NWU0ZmMzMzk4NWU2YjY0MmZmZDI4NDE5MTVlYWNhYQprZXJuZWw6
IC9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4MzEvZDZlOTU1MjY0NWU0ZmMz
Mzk4NWU2YjY0MmZmZDI4NDE5MTVlYWNhYS92bWxpbnV6LTMuMTQuMC1yYzUtMDAyMTctZ2Q2
ZTk1NTIKCjIwMTQtMDMtMDktMjE6MDE6MzggZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLgkyCTYJ
OQkxMAkxNwkxOQkyMiBTVUNDRVNTCgpCaXNlY3Rpbmc6IDEyIHJldmlzaW9ucyBsZWZ0IHRv
IHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA0IHN0ZXBzKQpbMWQ2OTY3NmUzZDA0NWE1MWVj
ZjNmOGYzYjYyMzljNDZlOTM0ZjMyM10gbW06IHVzZSBtYWNyb3MgZnJvbSBjb21waWxlci5o
IGluc3RlYWQgb2YgX19hdHRyaWJ1dGVfXygoLi4uKSkKcnVubmluZyAvYy9rZXJuZWwtdGVz
dHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2Vj
dApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWct
aTEtMDMwOTE4MzEvbmV4dDptYXN0ZXI6MWQ2OTY3NmUzZDA0NWE1MWVjZjNmOGYzYjYyMzlj
NDZlOTM0ZjMyMzpiaXNlY3QtbmV0CgoyMDE0LTAzLTA5LTIxOjA1OjM5IDFkNjk2NzZlM2Qw
NDVhNTFlY2YzZjhmM2I2MjM5YzQ2ZTkzNGYzMjMgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0
YXNrIHRvIC9rZXJuZWwtdGVzdHMvYnVpbGQtcXVldWUveDg2XzY0LXJhbmRjb25maWctaTEt
MDMwOTE4MzEtMWQ2OTY3NmUzZDA0NWE1MWVjZjNmOGYzYjYyMzljNDZlOTM0ZjMyMwpDaGVj
ayBmb3Iga2VybmVsIGluIC9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4MzEv
MWQ2OTY3NmUzZDA0NWE1MWVjZjNmOGYzYjYyMzljNDZlOTM0ZjMyMwp3YWl0aW5nIGZvciBj
b21wbGV0aW9uIG9mIC9rZXJuZWwtdGVzdHMvYnVpbGQtcXVldWUveDg2XzY0LXJhbmRjb25m
aWctaTEtMDMwOTE4MzEtMWQ2OTY3NmUzZDA0NWE1MWVjZjNmOGYzYjYyMzljNDZlOTM0ZjMy
Mwp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rZXJuZWwtdGVzdHMvYnVpbGQtcXVldWUv
Lng4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLTFkNjk2NzZlM2QwNDVhNTFlY2YzZjhm
M2I2MjM5YzQ2ZTkzNGYzMjMKa2VybmVsOiAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkx
LTAzMDkxODMxLzFkNjk2NzZlM2QwNDVhNTFlY2YzZjhmM2I2MjM5YzQ2ZTkzNGYzMjMvdm1s
aW51ei0zLjE0LjAtcmM1LTAwMjI5LWcxZDY5Njc2CgoyMDE0LTAzLTA5LTIxOjE2OjM5IGRl
dGVjdGluZyBib290IHN0YXRlIC4uIFRFU1QgRkFJTFVSRQpod2Nsb2NrOiBjYW4ndCBvcGVu
ICcvZGV2L21pc2MvcnRjJzogTm8gc3VjaCBmaWxlIG9yIGRpcmVjdG9yeQpSdW5uaW5nIHBv
c3RpbnN0IC9ldGMvcnBtLXBvc3RpbnN0cy8xMDAuLi4KWyAgICAxLjU3MTc4Nl0gdHNjOiBS
ZWZpbmVkIFRTQyBjbG9ja3NvdXJjZSBjYWxpYnJhdGlvbjogMjQ5My45NjQgTUh6ClsgICAg
Mi4wNzYzNDRdIEJVRzogdW5hYmxlIHRvIGhhbmRsZSBrZXJuZWwgcGFnaW5nIHJlcXVlc3Qg
YXQgZmZmZjg4MDAwYzE3YWY0MApbICAgIDIuMDc3MjM1XSBJUDogWzxmZmZmZmZmZjgxMTE4
Y2U4Pl0gdm1hY2FjaGVfZmluZCsweDc4LzB4OTAKWyAgICAyLjA3Nzk5Ml0gUEdEIDI1MzQw
NjcgUFVEIDI1MzUwNjcgUE1EIDEzYjg1MDY3IFBURSA4MDAwMDAwMDBjMTdhMDYwClsgICAg
Mi4wNzg5MTJdIE9vcHM6IDAwMDAgWyMxXSBERUJVR19QQUdFQUxMT0MKWyAgICAyLjA3OTQ2
OV0gTW9kdWxlcyBsaW5rZWQgaW46ClsgICAgMi4wNzk2ODZdIENQVTogMCBQSUQ6IDMxOSBD
b21tOiA5MC10cmluaXR5IE5vdCB0YWludGVkIDMuMTQuMC1yYzUtMDAyMjktZzFkNjk2NzYg
IzIKWyAgICAyLjA3OTY4Nl0gSGFyZHdhcmUgbmFtZTogQm9jaHMgQm9jaHMsIEJJT1MgQm9j
aHMgMDEvMDEvMjAxMQpbICAgIDIuMDc5Njg2XSB0YXNrOiBmZmZmODgwMDBjMzZlMGQwIHRp
OiBmZmZmODgwMDBjMTVhMDAwIHRhc2sudGk6IGZmZmY4ODAwMGMxNWEwMDAKWyAgICAyLjA3
OTY4Nl0gUklQOiAwMDEwOls8ZmZmZmZmZmY4MTExOGNlOD5dICBbPGZmZmZmZmZmODExMThj
ZTg+XSB2bWFjYWNoZV9maW5kKzB4NzgvMHg5MApbICAgIDIuMDc5Njg2XSBSU1A6IDAwMDA6
ZmZmZjg4MDAwYzE1YmUwMCAgRUZMQUdTOiAwMDAxMDI4MgpbICAgIDIuMDc5Njg2XSBSQVg6
IGZmZmY4ODAwMGMxN2FmNDAgUkJYOiAwMDAwMDAwMDAwMDAwMGE5IFJDWDogZmZmZjg4MDAw
YzM2ZTBkMApbICAgIDIuMDc5Njg2XSBSRFg6IDAwMDAwMDAwMDAwMDAwMDIgUlNJOiAwMDAw
N2ZmZjliMTExZmEwIFJESTogZmZmZjg4MDAwYzAwY2JjMApbICAgIDIuMDc5Njg2XSBSQlA6
IGZmZmY4ODAwMGMxNWJlMDAgUjA4OiAwMDAwMDAwMDAwMDAwMDAwIFIwOTogMDAwMDAwMDAw
MDAwMDAwMQpbICAgIDIuMDc5Njg2XSBSMTA6IDAwMDAwMDAwMDAwMDAwMDAgUjExOiAwMDAw
MDAwMDAwMDAwMDAxIFIxMjogMDAwMDdmZmY5YjExMWZhMApbICAgIDIuMDc5Njg2XSBSMTM6
IGZmZmY4ODAwMGMwMGNiYzAgUjE0OiBmZmZmODgwMDBjMTViZjU4IFIxNTogZmZmZjg4MDAw
YzM2ZTBkMApbICAgIDIuMDc5Njg2XSBGUzogIDAwMDA3ZjUyMmQ5MWU3MDAoMDAwMCkgR1M6
ZmZmZmZmZmY4MTlmYTAwMCgwMDAwKSBrbmxHUzowMDAwMDAwMDAwMDAwMDAwClsgICAgMi4w
Nzk2ODZdIENTOiAgMDAxMCBEUzogMDAwMCBFUzogMDAwMCBDUjA6IDAwMDAwMDAwODAwNTAw
MzMKWyAgICAyLjA3OTY4Nl0gQ1IyOiBmZmZmODgwMDBjMTdhZjQwIENSMzogMDAwMDAwMDAw
YzM1MDAwMCBDUjQ6IDAwMDAwMDAwMDAwMDA2YjAKWyAgICAyLjA3OTY4Nl0gU3RhY2s6Clsg
ICAgMi4wNzk2ODZdICBmZmZmODgwMDBjMTViZTI4IGZmZmZmZmZmODExMjNjZTkgMDAwMDAw
MDAwMDAwMDBhOSAwMDAwN2ZmZjliMTExZmEwClsgICAgMi4wNzk2ODZdICBmZmZmODgwMDBj
MDBjYmMwIGZmZmY4ODAwMGMxNWJmMjggZmZmZmZmZmY4MTZjZjAyZSAwMDAwMDAwMDAwMDAw
MjQ2ClsgICAgMi4wNzk2ODZdICAwMDAwMDAwMDAwMDAwMDAyIGZmZmY4ODAwMGMwMGNjNTgg
MDAwMDAwMDAwMDAwMDAwNiAwMDAwMDAwMDAwMDAwMDEwClsgICAgMi4wNzk2ODZdIENhbGwg
VHJhY2U6ClsgICAgMi4wNzk2ODZdICBbPGZmZmZmZmZmODExMjNjZTk+XSBmaW5kX3ZtYSsw
eDE5LzB4NzAKWyAgICAyLjA3OTY4Nl0gIFs8ZmZmZmZmZmY4MTZjZjAyZT5dIF9fZG9fcGFn
ZV9mYXVsdCsweDI5ZS8weDU2MApbICAgIDIuMDc5Njg2XSAgWzxmZmZmZmZmZjgxMTZiYWMy
Pl0gPyBtbnRwdXRfbm9fZXhwaXJlKzB4NzIvMHgxYjAKWyAgICAyLjA3OTY4Nl0gIFs8ZmZm
ZmZmZmY4MTE2YmE2MT5dID8gbW50cHV0X25vX2V4cGlyZSsweDExLzB4MWIwClsgICAgMi4w
Nzk2ODZdICBbPGZmZmZmZmZmODExNmJjMzU+XSA/IG1udHB1dCsweDM1LzB4NDAKWyAgICAy
LjA3OTY4Nl0gIFs8ZmZmZmZmZmY4MTE0ZGZlZj5dID8gX19mcHV0KzB4MjRmLzB4MjkwClsg
ICAgMi4wNzk2ODZdICBbPGZmZmZmZmZmODEyNzZmNGE+XSA/IHRyYWNlX2hhcmRpcnFzX29m
Zl90aHVuaysweDNhLzB4M2MKWyAgICAyLjA3OTY4Nl0gIFs8ZmZmZmZmZmY4MTZjZjJmZT5d
IGRvX3BhZ2VfZmF1bHQrMHhlLzB4MTAKWyAgICAyLjA3OTY4Nl0gIFs8ZmZmZmZmZmY4MTZj
ZTkwNT5dIGRvX2FzeW5jX3BhZ2VfZmF1bHQrMHgzNS8weDkwClsgICAgMi4wNzk2ODZdICBb
PGZmZmZmZmZmODE2Y2I4YzU+XSBhc3luY19wYWdlX2ZhdWx0KzB4MjUvMHgzMApbICAgIDIu
MDc5Njg2XSBDb2RlOiBjNyA4MSBiMCAwMiAwMCAwMCAwMCAwMCAwMCAwMCBlYiAzMiAwZiAx
ZiA4MCAwMCAwMCAwMCAwMCAzMSBkMiA2NiAwZiAxZiA0NCAwMCAwMCA0OCA2MyBjMiA0OCA4
YiA4NCBjMSA5OCAwMiAwMCAwMCA0OCA4NSBjMCA3NCAwYiA8NDg+IDM5IDMwIDc3IDA2IDQ4
IDNiIDcwIDA4IDcyIDBhIDgzIGMyIDAxIDgzIGZhIDA0IDc1IGRkIDMxIGMwIApbICAgIDIu
MDc5Njg2XSBSSVAgIFs8ZmZmZmZmZmY4MTExOGNlOD5dIHZtYWNhY2hlX2ZpbmQrMHg3OC8w
eDkwClsgICAgMi4wNzk2ODZdICBSU1AgPGZmZmY4ODAwMGMxNWJlMDA+ClsgICAgMi4wNzk2
ODZdIENSMjogZmZmZjg4MDAwYzE3YWY0MApbICAgIDIuMDc5Njg2XSAtLS1bIGVuZCB0cmFj
ZSBhNTE3ZThkNjAxYWYyOTgzIF0tLS0KWyAgICAyLjA3OTY4Nl0gS2VybmVsIHBhbmljIC0g
bm90IHN5bmNpbmc6IEZhdGFsIGV4Y2VwdGlvbgova2VybmVsL3g4Nl82NC1yYW5kY29uZmln
LWkxLTAzMDkxODMxLzFkNjk2NzZlM2QwNDVhNTFlY2YzZjhmM2I2MjM5YzQ2ZTkzNGYzMjMv
ZG1lc2cteW9jdG8taXZ5dG93bjItNToyMDE0MDMwOTIxMTczMjp4ODZfNjQtcmFuZGNvbmZp
Zy1pMS0wMzA5MTgzMTozLjE0LjAtcmM1LTAwMjI5LWcxZDY5Njc2OjIKMDoxOjEgYWxsX2dv
b2Q6YmFkOmFsbF9iYWQgYm9vdHMKCkJpc2VjdGluZzogNSByZXZpc2lvbnMgbGVmdCB0byB0
ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMyBzdGVwcykKWzcwMDUxYjkwNzhhMzI1ZTk1YTA5
NDRjNjg4NzIzNTEyYWUxNDQ1OWVdIG1tOiBjbGVhbnVwIHNpemUgY2hlY2tzIGluIGZpbGVt
YXBfZmF1bHQoKSBhbmQgZmlsZW1hcF9tYXBfcGFnZXMoKQpydW5uaW5nIC9jL2tlcm5lbC10
ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlz
ZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZp
Zy1pMS0wMzA5MTgzMS9uZXh0Om1hc3Rlcjo3MDA1MWI5MDc4YTMyNWU5NWEwOTQ0YzY4ODcy
MzUxMmFlMTQ0NTllOmJpc2VjdC1uZXQKCjIwMTQtMDMtMDktMjE6MTc6NDIgNzAwNTFiOTA3
OGEzMjVlOTVhMDk0NGM2ODg3MjM1MTJhZTE0NDU5ZSBjb21waWxpbmcKUXVldWVkIGJ1aWxk
IHRhc2sgdG8gL2tlcm5lbC10ZXN0cy9idWlsZC1xdWV1ZS94ODZfNjQtcmFuZGNvbmZpZy1p
MS0wMzA5MTgzMS03MDA1MWI5MDc4YTMyNWU5NWEwOTQ0YzY4ODcyMzUxMmFlMTQ0NTllCkNo
ZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgz
MS83MDA1MWI5MDc4YTMyNWU5NWEwOTQ0YzY4ODcyMzUxMmFlMTQ0NTllCndhaXRpbmcgZm9y
IGNvbXBsZXRpb24gb2YgL2tlcm5lbC10ZXN0cy9idWlsZC1xdWV1ZS94ODZfNjQtcmFuZGNv
bmZpZy1pMS0wMzA5MTgzMS03MDA1MWI5MDc4YTMyNWU5NWEwOTQ0YzY4ODcyMzUxMmFlMTQ0
NTllCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tlcm5lbC10ZXN0cy9idWlsZC1xdWV1
ZS8ueDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4MzEtNzAwNTFiOTA3OGEzMjVlOTVhMDk0
NGM2ODg3MjM1MTJhZTE0NDU5ZQprZXJuZWw6IC9rZXJuZWwveDg2XzY0LXJhbmRjb25maWct
aTEtMDMwOTE4MzEvNzAwNTFiOTA3OGEzMjVlOTVhMDk0NGM2ODg3MjM1MTJhZTE0NDU5ZS92
bWxpbnV6LTMuMTQuMC1yYzUtMDAyMjMtZzcwMDUxYjkKCjIwMTQtMDMtMDktMjE6MzA6NDMg
ZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgCTQJNwkxOQkyMiBTVUNDRVNTCgpCaXNlY3Rpbmc6IDIg
cmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDIgc3RlcHMpClsw
ZDlhZDQyMjBlNmQ3M2Y2M2E5ZWVlYWFjMDMxYjkyODM4Zjc1YmIzXSBtbTogcGVyLXRocmVh
ZCB2bWEgY2FjaGluZwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290
LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVz
dHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS9uZXh0Om1h
c3RlcjowZDlhZDQyMjBlNmQ3M2Y2M2E5ZWVlYWFjMDMxYjkyODM4Zjc1YmIzOmJpc2VjdC1u
ZXQKCjIwMTQtMDMtMDktMjE6MzI6NDQgMGQ5YWQ0MjIwZTZkNzNmNjNhOWVlZWFhYzAzMWI5
MjgzOGY3NWJiMyBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tlcm5lbC10ZXN0
cy9idWlsZC1xdWV1ZS94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS0wZDlhZDQyMjBl
NmQ3M2Y2M2E5ZWVlYWFjMDMxYjkyODM4Zjc1YmIzCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tl
cm5lbC94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS8wZDlhZDQyMjBlNmQ3M2Y2M2E5
ZWVlYWFjMDMxYjkyODM4Zjc1YmIzCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tlcm5l
bC10ZXN0cy9idWlsZC1xdWV1ZS94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS0wZDlh
ZDQyMjBlNmQ3M2Y2M2E5ZWVlYWFjMDMxYjkyODM4Zjc1YmIzCndhaXRpbmcgZm9yIGNvbXBs
ZXRpb24gb2YgL2tlcm5lbC10ZXN0cy9idWlsZC1xdWV1ZS8ueDg2XzY0LXJhbmRjb25maWct
aTEtMDMwOTE4MzEtMGQ5YWQ0MjIwZTZkNzNmNjNhOWVlZWFhYzAzMWI5MjgzOGY3NWJiMwpr
ZXJuZWw6IC9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4MzEvMGQ5YWQ0MjIw
ZTZkNzNmNjNhOWVlZWFhYzAzMWI5MjgzOGY3NWJiMy92bWxpbnV6LTMuMTQuMC1yYzUtMDAy
MjYtZzBkOWFkNDIyCgoyMDE0LTAzLTA5LTIxOjQ0OjQ1IGRldGVjdGluZyBib290IHN0YXRl
IAkxCTE0IFRFU1QgRkFJTFVSRQpbICAgIDIuNTM4MjMwXSBpbnB1dDogUG93ZXIgQnV0dG9u
IGFzIC9kZXZpY2VzL0xOWFNZU1RNOjAwL0xOWFBXUkJOOjAwL2lucHV0L2lucHV0MApbICAg
IDIuNTQxNzU4XSBBQ1BJOiBQb3dlciBCdXR0b24gW1BXUkZdClsgICAgMi41NDE3NThdIEFD
UEk6IFBvd2VyIEJ1dHRvbiBbUFdSRl0KWyAgICAyLjcxNjA1NV0gc3dhcHBlciBpbnZva2Vk
IG9vbS1raWxsZXI6IGdmcF9tYXNrPTB4MjA0MGQwLCBvcmRlcj0wLCBvb21fc2NvcmVfYWRq
PTAKWyAgICAyLjcxNjA1NV0gc3dhcHBlciBpbnZva2VkIG9vbS1raWxsZXI6IGdmcF9tYXNr
PTB4MjA0MGQwLCBvcmRlcj0wLCBvb21fc2NvcmVfYWRqPTAKWyAgICAyLjcxNzk5OF0gQ1BV
OiAwIFBJRDogMSBDb21tOiBzd2FwcGVyIE5vdCB0YWludGVkIDMuMTQuMC1yYzUtMDAyMjYt
ZzBkOWFkNDIyICMxClsgICAgMi43MTc5OThdIENQVTogMCBQSUQ6IDEgQ29tbTogc3dhcHBl
ciBOb3QgdGFpbnRlZCAzLjE0LjAtcmM1LTAwMjI2LWcwZDlhZDQyMiAjMQpbICAgIDIuNzE5
ODYxXSBIYXJkd2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklPUyBCb2NocyAwMS8wMS8yMDEx
ClsgICAgMi43MTk4NjFdIEhhcmR3YXJlIG5hbWU6IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hz
IDAxLzAxLzIwMTEKWyAgICAyLjcyMTI3NV0gIGZmZmY4ODAwMGUzNmM2MTgKWyAgICAyLjcy
MTI3NV0gIGZmZmY4ODAwMGUzNmM2MTggZmZmZjg4MDAwZTM2ZjkwMCBmZmZmODgwMDBlMzZm
OTAwIGZmZmZmZmZmODE2YmY4MTQgZmZmZmZmZmY4MTZiZjgxNCBmZmZmODgwMDBlMzZmOTgw
IGZmZmY4ODAwMGUzNmY5ODAKCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4
MzEvMGQ5YWQ0MjIwZTZkNzNmNjNhOWVlZWFhYzAzMWI5MjgzOGY3NWJiMy9kbWVzZy15b2N0
by1pdnl0b3duMi0yOjIwMTQwMzA5MjE0NDUzOng4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkx
ODMxOjMuMTQuMC1yYzUtMDAyMjYtZzBkOWFkNDIyOjEKL2tlcm5lbC94ODZfNjQtcmFuZGNv
bmZpZy1pMS0wMzA5MTgzMS8wZDlhZDQyMjBlNmQ3M2Y2M2E5ZWVlYWFjMDMxYjkyODM4Zjc1
YmIzL2RtZXNnLXlvY3RvLWl2eXRvd24yLTI6MjAxNDAzMDkyMTQ1MDI6eDg2XzY0LXJhbmRj
b25maWctaTEtMDMwOTE4MzE6My4xNC4wLXJjNS0wMDIyNi1nMGQ5YWQ0MjI6MQova2VybmVs
L3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLzBkOWFkNDIyMGU2ZDczZjYzYTllZWVh
YWMwMzFiOTI4MzhmNzViYjMvZG1lc2cteW9jdG8tamFrZXRvd24tNDoyMDE0MDMwOTIxNDUx
Mjp4ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMTo6Ci9rZXJuZWwveDg2XzY0LXJhbmRj
b25maWctaTEtMDMwOTE4MzEvMGQ5YWQ0MjIwZTZkNzNmNjNhOWVlZWFhYzAzMWI5MjgzOGY3
NWJiMy9kbWVzZy15b2N0by1pdnl0b3duMi0yNzoyMDE0MDMwOTIxNDUyNzp4ODZfNjQtcmFu
ZGNvbmZpZy1pMS0wMzA5MTgzMTozLjE0LjAtcmM1LTAwMjI2LWcwZDlhZDQyMjoxCi9rZXJu
ZWwveDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4MzEvMGQ5YWQ0MjIwZTZkNzNmNjNhOWVl
ZWFhYzAzMWI5MjgzOGY3NWJiMy9kbWVzZy15b2N0by1qYWtldG93bi00OjIwMTQwMzA5MjE0
NTM1Ong4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxOjoKMDo1OjE5IGFsbF9nb29kOmJh
ZDphbGxfYmFkIGJvb3RzChtbMTszNW0yMDE0LTAzLTA5IDIxOjQ1OjQ1IFJFUEVBVCBDT1VO
VDogNDggICMgL2NjL3dmZy9uZXQtYmlzZWN0Ly5yZXBlYXQbWzBtCgpCaXNlY3Rpbmc6IDAg
cmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEgc3RlcCkKWzJj
NDJjY2IzMzQ3ZDZlMDhiM2ZhZTM0ZjcwOWEyNWVkYmM3YjlhZDRdIG1tLWFkZC1kZWJ1Z2Zz
LXR1bmFibGUtZm9yLWZhdWx0X2Fyb3VuZF9vcmRlci1jaGVja3BhdGNoLWZpeGVzCnJ1bm5p
bmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93
ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4
Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxL25leHQ6bWFzdGVyOjJjNDJjY2IzMzQ3ZDZl
MDhiM2ZhZTM0ZjcwOWEyNWVkYmM3YjlhZDQ6YmlzZWN0LW5ldAoKMjAxNC0wMy0wOS0yMTo0
NTo0NiAyYzQyY2NiMzM0N2Q2ZTA4YjNmYWUzNGY3MDlhMjVlZGJjN2I5YWQ0IGNvbXBpbGlu
ZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82
NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLTJjNDJjY2IzMzQ3ZDZlMDhiM2ZhZTM0ZjcwOWEy
NWVkYmM3YjlhZDQKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL3g4Nl82NC1yYW5kY29u
ZmlnLWkxLTAzMDkxODMxLzJjNDJjY2IzMzQ3ZDZlMDhiM2ZhZTM0ZjcwOWEyNWVkYmM3Yjlh
ZDQKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVl
L3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLTJjNDJjY2IzMzQ3ZDZlMDhiM2ZhZTM0
ZjcwOWEyNWVkYmM3YjlhZDQKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2VybmVsLXRl
c3RzL2J1aWxkLXF1ZXVlLy54ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS0yYzQyY2Ni
MzM0N2Q2ZTA4YjNmYWUzNGY3MDlhMjVlZGJjN2I5YWQ0Cmtlcm5lbDogL2tlcm5lbC94ODZf
NjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS8yYzQyY2NiMzM0N2Q2ZTA4YjNmYWUzNGY3MDlh
MjVlZGJjN2I5YWQ0L3ZtbGludXotMy4xNC4wLXJjNS0wMDIyNS1nMmM0MmNjYgoKMjAxNC0w
My0wOS0yMTo1ODo0NiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAJMS4JMgk1CTEwCTIxCTM1CTM2
CTM5CTQwCTQxCTQyCTQ2CTQ3CTQ4IFNVQ0NFU1MKCjBkOWFkNDIyMGU2ZDczZjYzYTllZWVh
YWMwMzFiOTI4MzhmNzViYjMgaXMgdGhlIGZpcnN0IGJhZCBjb21taXQKY29tbWl0IDBkOWFk
NDIyMGU2ZDczZjYzYTllZWVhYWMwMzFiOTI4MzhmNzViYjMKQXV0aG9yOiBEYXZpZGxvaHIg
QnVlc28gPGRhdmlkbG9ockBocC5jb20+CkRhdGU6ICAgVGh1IE1hciA2IDExOjAxOjQ4IDIw
MTQgKzExMDAKCiAgICBtbTogcGVyLXRocmVhZCB2bWEgY2FjaGluZwogICAgCiAgICBUaGlz
IHBhdGNoIGlzIGEgY29udGludWF0aW9uIG9mIGVmZm9ydHMgdHJ5aW5nIHRvIG9wdGltaXpl
IGZpbmRfdm1hKCksCiAgICBhdm9pZGluZyBwb3RlbnRpYWxseSBleHBlbnNpdmUgcmJ0cmVl
IHdhbGtzIHRvIGxvY2F0ZSBhIHZtYSB1cG9uIGZhdWx0cy4KICAgIFRoZSBvcmlnaW5hbCBh
cHByb2FjaCAoaHR0cHM6Ly9sa21sLm9yZy9sa21sLzIwMTMvMTEvMS80MTApLCB3aGVyZSB0
aGUKICAgIGxhcmdlc3Qgdm1hIHdhcyBhbHNvIGNhY2hlZCwgZW5kZWQgdXAgYmVpbmcgdG9v
IHNwZWNpZmljIGFuZCByYW5kb20sIHRodXMKICAgIGZ1cnRoZXIgY29tcGFyaXNvbiB3aXRo
IG90aGVyIGFwcHJvYWNoZXMgd2VyZSBuZWVkZWQuICBUaGVyZSBhcmUgdHdvCiAgICB0aGlu
Z3MgdG8gY29uc2lkZXIgd2hlbiBkZWFsaW5nIHdpdGggdGhpcywgdGhlIGNhY2hlIGhpdCBy
YXRlIGFuZCB0aGUKICAgIGxhdGVuY3kgb2YgZmluZF92bWEoKS4gIEltcHJvdmluZyB0aGUg
aGl0LXJhdGUgZG9lcyBub3QgbmVjZXNzYXJpbHkKICAgIHRyYW5zbGF0ZSBpbiBmaW5kaW5n
IHRoZSB2bWEgYW55IGZhc3RlciwgYXMgdGhlIG92ZXJoZWFkIG9mIGFueSBmYW5jeQogICAg
Y2FjaGluZyBzY2hlbWVzIGNhbiBiZSB0b28gaGlnaCB0byBjb25zaWRlci4KICAgIAogICAg
V2UgY3VycmVudGx5IGNhY2hlIHRoZSBsYXN0IHVzZWQgdm1hIGZvciB0aGUgd2hvbGUgYWRk
cmVzcyBzcGFjZSwgd2hpY2gKICAgIHByb3ZpZGVzIGEgbmljZSBvcHRpbWl6YXRpb24sIHJl
ZHVjaW5nIHRoZSB0b3RhbCBjeWNsZXMgaW4gZmluZF92bWEoKSBieQogICAgdXAgdG8gMjUw
JSwgZm9yIHdvcmtsb2FkcyB3aXRoIGdvb2QgbG9jYWxpdHkuICBPbiB0aGUgb3RoZXIgaGFu
ZCwgdGhpcwogICAgc2ltcGxlIHNjaGVtZSBpcyBwcmV0dHkgbXVjaCB1c2VsZXNzIGZvciB3
b3JrbG9hZHMgd2l0aCBwb29yIGxvY2FsaXR5LgogICAgQW5hbHl6aW5nIGViaXp6eSBydW5z
IHNob3dzIHRoYXQsIG5vIG1hdHRlciBob3cgbWFueSB0aHJlYWRzIGFyZSBydW5uaW5nLAog
ICAgdGhlIG1tYXBfY2FjaGUgaGl0IHJhdGUgaXMgbGVzcyB0aGFuIDIlLCBhbmQgaW4gbWFu
eSBzaXR1YXRpb25zIGJlbG93IDElLgogICAgCiAgICBUaGUgcHJvcG9zZWQgYXBwcm9hY2gg
aXMgdG8gcmVwbGFjZSB0aGlzIHNjaGVtZSB3aXRoIGEgc21hbGwgcGVyLXRocmVhZAogICAg
Y2FjaGUsIG1heGltaXppbmcgaGl0IHJhdGVzIGF0IGEgdmVyeSBsb3cgbWFpbnRlbmFuY2Ug
Y29zdC4gIEludmFsaWRhdGlvbnMKICAgIGFyZSBwZXJmb3JtZWQgYnkgc2ltcGx5IGJ1bXBp
bmcgdXAgYSAzMi1iaXQgc2VxdWVuY2UgbnVtYmVyLiAgVGhlIG9ubHkKICAgIGV4cGVuc2l2
ZSBvcGVyYXRpb24gaXMgaW4gdGhlIHJhcmUgY2FzZSBvZiBhIHNlcSBudW1iZXIgb3ZlcmZs
b3csIHdoZXJlCiAgICBhbGwgY2FjaGVzIHRoYXQgc2hhcmUgdGhlIHNhbWUgYWRkcmVzcyBz
cGFjZSBhcmUgZmx1c2hlZC4gIFVwb24gYSBtaXNzLAogICAgdGhlIHByb3Bvc2VkIHJlcGxh
Y2VtZW50IHBvbGljeSBpcyBiYXNlZCBvbiB0aGUgcGFnZSBudW1iZXIgdGhhdCBjb250YWlu
cwogICAgdGhlIHZpcnR1YWwgYWRkcmVzcyBpbiBxdWVzdGlvbi4gIENvbmNyZXRlbHksIHRo
ZSBmb2xsb3dpbmcgcmVzdWx0cyBhcmUKICAgIHNlZW4gb24gYW4gODAgY29yZSwgOCBzb2Nr
ZXQgeDg2LTY0IGJveDoKICAgIAogICAgMSkgU3lzdGVtIGJvb3R1cDogTW9zdCBwcm9ncmFt
cyBhcmUgc2luZ2xlIHRocmVhZGVkLCBzbyB0aGUgcGVyLXRocmVhZAogICAgICAgc2NoZW1l
IGRvZXMgaW1wcm92ZSB+NTAlIGhpdCByYXRlIGJ5IGp1c3QgYWRkaW5nIGEgZmV3IG1vcmUg
c2xvdHMgdG8KICAgICAgIHRoZSBjYWNoZS4KICAgIAogICAgKy0tLS0tLS0tLS0tLS0tLS0r
LS0tLS0tLS0tLSstLS0tLS0tLS0tLS0tLS0tLS0rCiAgICB8IGNhY2hpbmcgc2NoZW1lIHwg
aGl0LXJhdGUgfCBjeWNsZXMgKGJpbGxpb24pIHwKICAgICstLS0tLS0tLS0tLS0tLS0tKy0t
LS0tLS0tLS0rLS0tLS0tLS0tLS0tLS0tLS0tKwogICAgfCBiYXNlbGluZSAgICAgICB8IDUw
LjYxJSAgIHwgMTkuOTAgICAgICAgICAgICB8CiAgICB8IHBhdGNoZWQgICAgICAgIHwgNzMu
NDUlICAgfCAxMy41OCAgICAgICAgICAgIHwKICAgICstLS0tLS0tLS0tLS0tLS0tKy0tLS0t
LS0tLS0rLS0tLS0tLS0tLS0tLS0tLS0tKwogICAgCiAgICAyKSBLZXJuZWwgYnVpbGQ6IFRo
aXMgb25lIGlzIGFscmVhZHkgcHJldHR5IGdvb2Qgd2l0aCB0aGUgY3VycmVudAogICAgICAg
YXBwcm9hY2ggYXMgd2UncmUgZGVhbGluZyB3aXRoIGdvb2QgbG9jYWxpdHkuCiAgICAKICAg
ICstLS0tLS0tLS0tLS0tLS0tKy0tLS0tLS0tLS0rLS0tLS0tLS0tLS0tLS0tLS0tKwogICAg
fCBjYWNoaW5nIHNjaGVtZSB8IGhpdC1yYXRlIHwgY3ljbGVzIChiaWxsaW9uKSB8CiAgICAr
LS0tLS0tLS0tLS0tLS0tLSstLS0tLS0tLS0tKy0tLS0tLS0tLS0tLS0tLS0tLSsKICAgIHwg
YmFzZWxpbmUgICAgICAgfCA3NS4yOCUgICB8IDExLjAzICAgICAgICAgICAgfAogICAgfCBw
YXRjaGVkICAgICAgICB8IDg4LjA5JSAgIHwgOS4zMSAgICAgICAgICAgICB8CiAgICArLS0t
LS0tLS0tLS0tLS0tLSstLS0tLS0tLS0tKy0tLS0tLS0tLS0tLS0tLS0tLSsKICAgIAogICAg
MykgT3JhY2xlIDExZyBEYXRhIE1pbmluZyAoNGsgcGFnZXMpOiBTaW1pbGFyIHRvIHRoZSBr
ZXJuZWwgYnVpbGQgd29ya2xvYWQuCiAgICAKICAgICstLS0tLS0tLS0tLS0tLS0tKy0tLS0t
LS0tLS0rLS0tLS0tLS0tLS0tLS0tLS0tKwogICAgfCBjYWNoaW5nIHNjaGVtZSB8IGhpdC1y
YXRlIHwgY3ljbGVzIChiaWxsaW9uKSB8CiAgICArLS0tLS0tLS0tLS0tLS0tLSstLS0tLS0t
LS0tKy0tLS0tLS0tLS0tLS0tLS0tLSsKICAgIHwgYmFzZWxpbmUgICAgICAgfCA3MC42NiUg
ICB8IDE3LjE0ICAgICAgICAgICAgfAogICAgfCBwYXRjaGVkICAgICAgICB8IDkxLjE1JSAg
IHwgMTIuNTcgICAgICAgICAgICB8CiAgICArLS0tLS0tLS0tLS0tLS0tLSstLS0tLS0tLS0t
Ky0tLS0tLS0tLS0tLS0tLS0tLSsKICAgIAogICAgNCkgRWJpenp5OiBUaGVyZSdzIGEgZmFp
ciBhbW91bnQgb2YgdmFyaWF0aW9uIGZyb20gcnVuIHRvIHJ1biwgYnV0IHRoaXMKICAgICAg
IGFwcHJvYWNoIGFsd2F5cyBzaG93cyBuZWFybHkgcGVyZmVjdCBoaXQgcmF0ZXMsIHdoaWxl
IGJhc2VsaW5lIGlzIGp1c3QKICAgICAgIGFib3V0IG5vbi1leGlzdGVudC4gIFRoZSBhbW91
bnRzIG9mIGN5Y2xlcyBjYW4gZmx1Y3R1YXRlIGJldHdlZW4KICAgICAgIGFueXdoZXJlIGZy
b20gfjYwIHRvIH4xMTYgZm9yIHRoZSBiYXNlbGluZSBzY2hlbWUsIGJ1dCB0aGlzIGFwcHJv
YWNoCiAgICAgICByZWR1Y2VzIGl0IGNvbnNpZGVyYWJseS4gIEZvciBpbnN0YW5jZSwgd2l0
aCA4MCB0aHJlYWRzOgogICAgCiAgICArLS0tLS0tLS0tLS0tLS0tLSstLS0tLS0tLS0tKy0t
LS0tLS0tLS0tLS0tLS0tLSsKICAgIHwgY2FjaGluZyBzY2hlbWUgfCBoaXQtcmF0ZSB8IGN5
Y2xlcyAoYmlsbGlvbikgfAogICAgKy0tLS0tLS0tLS0tLS0tLS0rLS0tLS0tLS0tLSstLS0t
LS0tLS0tLS0tLS0tLS0rCiAgICB8IGJhc2VsaW5lICAgICAgIHwgMS4wNiUgICAgfCA5MS41
NCAgICAgICAgICAgIHwKICAgIHwgcGF0Y2hlZCAgICAgICAgfCA5OS45NyUgICB8IDE0LjE4
ICAgICAgICAgICAgfAogICAgKy0tLS0tLS0tLS0tLS0tLS0rLS0tLS0tLS0tLSstLS0tLS0t
LS0tLS0tLS0tLS0rCiAgICAKICAgIFNpZ25lZC1vZmYtYnk6IERhdmlkbG9ociBCdWVzbyA8
ZGF2aWRsb2hyQGhwLmNvbT4KICAgIFJldmlld2VkLWJ5OiBSaWsgdmFuIFJpZWwgPHJpZWxA
cmVkaGF0LmNvbT4KICAgIEFja2VkLWJ5OiBMaW51cyBUb3J2YWxkcyA8dG9ydmFsZHNAbGlu
dXgtZm91bmRhdGlvbi5vcmc+CiAgICBSZXZpZXdlZC1ieTogTWljaGVsIExlc3BpbmFzc2Ug
PHdhbGtlbkBnb29nbGUuY29tPgogICAgU2lnbmVkLW9mZi1ieTogQW5kcmV3IE1vcnRvbiA8
YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz4KCjowNDAwMDAgMDQwMDAwIDRlZWNiOGY3MmZj
Yzk2NGVmNTRkODA2YmY1ZDBjZTkwMDY3NDNjNjIgYmE3NjhkYzdiNGE1N2JmYjAwY2M0NzFj
NWMzYzkyYjE0NWEzMmY3YiBNCWFyY2gKOjA0MDAwMCAwNDAwMDAgOWE5OTdlOWU1NjVkZGQ2
YTg3YzAzN2U3M2ZkYTQ5YWQ0NzVjOTdmNCAxMzA3ZTMxYzE4NDZkM2NjZTU3Mzk4YzJmYzBi
ZTg4NmZkMjMzYTUyIE0JZnMKOjA0MDAwMCAwNDAwMDAgMDU3ZTZlMmNkMDAzNDExYTVhOWRi
YmFlMDliYzAxYWZiZjk2YmFmMyBmMmM2ZDA5ZjU3MmUzODVhMDlkNTNiN2EwNGI3MDU0Y2U1
M2U0MGY5IE0JaW5jbHVkZQo6MDQwMDAwIDA0MDAwMCBhMzU0ZjIyODIyYjhmNzUzZTI5NWE2
OTE5YzczZmUzYjRlN2M4OGEwIDk4YTRiNTViNWZkZTBiY2FlOGVhMDI5ZGQyZWE3NzA0Yjc4
ZDkxY2MgTQlrZXJuZWwKOjA0MDAwMCAwNDAwMDAgZDYxYTBiYWM4NmU0NjEzNDRkNmI1MWVh
NzlhNWIzYTg0MDI2OTQ5MSA5ZGY1ZjY3NDBmMzdiN2U5OThiMjA3ZDIwOWMxM2FmZjNiNGI3
OGM2IE0JbW0KYmlzZWN0IHJ1biBzdWNjZXNzCmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1
ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS9uZXh0Om1hc3RlcjoyYzQy
Y2NiMzM0N2Q2ZTA4YjNmYWUzNGY3MDlhMjVlZGJjN2I5YWQ0OmJpc2VjdC1uZXQKCjIwMTQt
MDMtMDktMjI6MDY6MTggMmM0MmNjYjMzNDdkNmUwOGIzZmFlMzRmNzA5YTI1ZWRiYzdiOWFk
NCByZXVzZSAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLzJjNDJjY2Iz
MzQ3ZDZlMDhiM2ZhZTM0ZjcwOWEyNWVkYmM3YjlhZDQvdm1saW51ei0zLjE0LjAtcmM1LTAw
MjI1LWcyYzQyY2NiCgoyMDE0LTAzLTA5LTIyOjA2OjE5IGRldGVjdGluZyBib290IHN0YXRl
IC4JMgk0CTEzCTM2CTM5CTQ2CTUzCTYyCTc4CTg1CTExNAkxMzYJMTQ0IFNVQ0NFU1MKCmxz
IC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1pMS0w
MzA5MTgzMS9uZXh0Om1hc3RlcjoxYjBhN2UzMjYzMTY4YTA2ZDM4NTg3OThlNDhjNWEyMWQx
Yzc4ZDNjOmJpc2VjdC1uZXQKIFRFU1QgRkFJTFVSRQpbICAgIDIuNTQ3MjQzXSBpbnB1dDog
UG93ZXIgQnV0dG9uIGFzIC9kZXZpY2VzL0xOWFNZU1RNOjAwL0xOWFBXUkJOOjAwL2lucHV0
L2lucHV0MApbICAgIDIuNTUwNzcwXSBBQ1BJOiBQb3dlciBCdXR0b24gW1BXUkZdClsgICAg
Mi41NTA3NzBdIEFDUEk6IFBvd2VyIEJ1dHRvbiBbUFdSRl0KWyAgICAyLjc3NzY2OV0gc3dh
cHBlciBpbnZva2VkIG9vbS1raWxsZXI6IGdmcF9tYXNrPTB4MjA0MGQwLCBvcmRlcj0wLCBv
b21fc2NvcmVfYWRqPTAKWyAgICAyLjc3NzY2OV0gc3dhcHBlciBpbnZva2VkIG9vbS1raWxs
ZXI6IGdmcF9tYXNrPTB4MjA0MGQwLCBvcmRlcj0wLCBvb21fc2NvcmVfYWRqPTAKWyAgICAy
Ljc4MTE0OV0gQ1BVOiAwIFBJRDogMSBDb21tOiBzd2FwcGVyIE5vdCB0YWludGVkIDMuMTQu
MC1yYzUtbmV4dC0yMDE0MDMwNyAjMQpbICAgIDIuNzgxMTQ5XSBDUFU6IDAgUElEOiAxIENv
bW06IHN3YXBwZXIgTm90IHRhaW50ZWQgMy4xNC4wLXJjNS1uZXh0LTIwMTQwMzA3ICMxClsg
ICAgMi43ODQ0MjJdIEhhcmR3YXJlIG5hbWU6IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAx
LzAxLzIwMTEKWyAgICAyLjc4NDQyMl0gSGFyZHdhcmUgbmFtZTogQm9jaHMgQm9jaHMsIEJJ
T1MgQm9jaHMgMDEvMDEvMjAxMQpbICAgIDIuNzg2OTE2XSAgZmZmZjg4MDAwZTM2YzYxOApb
ICAgIDIuNzg2OTE2XSAgZmZmZjg4MDAwZTM2YzYxOCBmZmZmODgwMDBlMzZmOTA4IGZmZmY4
ODAwMGUzNmY5MDggZmZmZmZmZmY4MTZjNzhlNSBmZmZmZmZmZjgxNmM3OGU1IGZmZmY4ODAw
MGUzNmY5ODggZmZmZjg4MDAwZTM2Zjk4OAoKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1p
MS0wMzA5MTgzMS8xYjBhN2UzMjYzMTY4YTA2ZDM4NTg3OThlNDhjNWEyMWQxYzc4ZDNjL2Rt
ZXNnLXlvY3RvLXNuYi0yNjoyMDE0MDMwOTE4NTAwMzp4ODZfNjQtcmFuZGNvbmZpZy1pMS0w
MzA5MTgzMTo6Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4MzEvMWIwYTdl
MzI2MzE2OGEwNmQzODU4Nzk4ZTQ4YzVhMjFkMWM3OGQzYy9kbWVzZy15b2N0by1pdnl0b3du
Mi0yMjoyMDE0MDMwOTE5MDAzMzp4ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMTozLjE0
LjAtcmM1LW5leHQtMjAxNDAzMDc6MQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAz
MDkxODMxLzFiMGE3ZTMyNjMxNjhhMDZkMzg1ODc5OGU0OGM1YTIxZDFjNzhkM2MvZG1lc2ct
eW9jdG8taXZ5dG93bjItMjA6MjAxNDAzMDkxOTAwMjU6eDg2XzY0LXJhbmRjb25maWctaTEt
MDMwOTE4MzE6My4xNC4wLXJjNS1uZXh0LTIwMTQwMzA3OjEKL2tlcm5lbC94ODZfNjQtcmFu
ZGNvbmZpZy1pMS0wMzA5MTgzMS8xYjBhN2UzMjYzMTY4YTA2ZDM4NTg3OThlNDhjNWEyMWQx
Yzc4ZDNjL2RtZXNnLXlvY3RvLXNuYi0zOjIwMTQwMzA5MTg0ODU5Ong4Nl82NC1yYW5kY29u
ZmlnLWkxLTAzMDkxODMxOjoKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgz
MS8xYjBhN2UzMjYzMTY4YTA2ZDM4NTg3OThlNDhjNWEyMWQxYzc4ZDNjL2RtZXNnLXlvY3Rv
LWl2eXRvd24yLTE6MjAxNDAzMDkxODQ5MTM6eDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4
MzE6My4xNC4wLXJjNS1uZXh0LTIwMTQwMzA3OjEKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZp
Zy1pMS0wMzA5MTgzMS8xYjBhN2UzMjYzMTY4YTA2ZDM4NTg3OThlNDhjNWEyMWQxYzc4ZDNj
L2RtZXNnLXlvY3RvLWl2eXRvd24yLTEzOjIwMTQwMzA5MTkwMDE0Ong4Nl82NC1yYW5kY29u
ZmlnLWkxLTAzMDkxODMxOjMuMTQuMC1yYzUtbmV4dC0yMDE0MDMwNzoxCi9rZXJuZWwveDg2
XzY0LXJhbmRjb25maWctaTEtMDMwOTE4MzEvMWIwYTdlMzI2MzE2OGEwNmQzODU4Nzk4ZTQ4
YzVhMjFkMWM3OGQzYy9kbWVzZy15b2N0by14Z3dvLTI6MjAxNDAzMDkxOTA0Mzg6eDg2XzY0
LXJhbmRjb25maWctaTEtMDMwOTE4MzE6My4xNC4wLXJjNS1uZXh0LTIwMTQwMzA3OjEKL2tl
cm5lbC94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS8xYjBhN2UzMjYzMTY4YTA2ZDM4
NTg3OThlNDhjNWEyMWQxYzc4ZDNjL2RtZXNnLXlvY3RvLXNuYi0xNToyMDE0MDMwOTE4NTAw
Mzp4ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMTo6Ci9rZXJuZWwveDg2XzY0LXJhbmRj
b25maWctaTEtMDMwOTE4MzEvMWIwYTdlMzI2MzE2OGEwNmQzODU4Nzk4ZTQ4YzVhMjFkMWM3
OGQzYy9kbWVzZy15b2N0by1zbmItMjQ6MjAxNDAzMDkxODQ5NTg6eDg2XzY0LXJhbmRjb25m
aWctaTEtMDMwOTE4MzE6Ogova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMx
LzFiMGE3ZTMyNjMxNjhhMDZkMzg1ODc5OGU0OGM1YTIxZDFjNzhkM2MvZG1lc2cteW9jdG8t
YXRoZW5zLTIyOjIwMTQwMzA5MTg0OTI0Ong4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMx
OjMuMTQuMC1yYzUtbmV4dC0yMDE0MDMwNzoxCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWct
aTEtMDMwOTE4MzEvMWIwYTdlMzI2MzE2OGEwNmQzODU4Nzk4ZTQ4YzVhMjFkMWM3OGQzYy9k
bWVzZy15b2N0by1pdnl0b3duMi0yOToyMDE0MDMwOTE5MDAyNDp4ODZfNjQtcmFuZGNvbmZp
Zy1pMS0wMzA5MTgzMTozLjE0LjAtcmM1LW5leHQtMjAxNDAzMDc6MQova2VybmVsL3g4Nl82
NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLzFiMGE3ZTMyNjMxNjhhMDZkMzg1ODc5OGU0OGM1
YTIxZDFjNzhkM2MvZG1lc2cteW9jdG8teGlhbi0xNDoyMDE0MDMwOTE4NDg1Njp4ODZfNjQt
cmFuZGNvbmZpZy1pMS0wMzA5MTgzMTozLjE0LjAtcmM1LW5leHQtMjAxNDAzMDc6MQo0OjEy
OjE1IGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzCgpIRUFEIGlzIG5vdyBhdCAxYjBhN2Uz
IEFkZCBsaW51eC1uZXh0IHNwZWNpZmljIGZpbGVzIGZvciAyMDE0MDMwNwoKPT09PT09PT09
IHVwc3RyZWFtID09PT09PT09PQpQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdhcyAxYjBhN2Uz
Li4uIEFkZCBsaW51eC1uZXh0IHNwZWNpZmljIGZpbGVzIGZvciAyMDE0MDMwNwpIRUFEIGlz
IG5vdyBhdCBjYTYyZWVjLi4uIE1lcmdlIGJyYW5jaCAnZm9yLTMuMTQtZml4ZXMnIG9mIGdp
dDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC90ai9jZ3JvdXAK
bHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWkx
LTAzMDkxODMxL25leHQ6bWFzdGVyOmNhNjJlZWM0ZTUyNDU5MWI4MmQ5ZWRmN2ExOGUzYWU2
YjY5MTUxN2Q6YmlzZWN0LW5ldAoKMjAxNC0wMy0wOS0yMjoxMzoyOSBjYTYyZWVjNGU1MjQ1
OTFiODJkOWVkZjdhMThlM2FlNmI2OTE1MTdkIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFz
ayB0byAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAz
MDkxODMxLWNhNjJlZWM0ZTUyNDU5MWI4MmQ5ZWRmN2ExOGUzYWU2YjY5MTUxN2QKQ2hlY2sg
Zm9yIGtlcm5lbCBpbiAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxL2Nh
NjJlZWM0ZTUyNDU5MWI4MmQ5ZWRmN2ExOGUzYWU2YjY5MTUxN2QKd2FpdGluZyBmb3IgY29t
cGxldGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlL3g4Nl82NC1yYW5kY29uZmln
LWkxLTAzMDkxODMxLWNhNjJlZWM0ZTUyNDU5MWI4MmQ5ZWRmN2ExOGUzYWU2YjY5MTUxN2QK
d2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2VybmVsLXRlc3RzL2J1aWxkLXF1ZXVlLy54
ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS1jYTYyZWVjNGU1MjQ1OTFiODJkOWVkZjdh
MThlM2FlNmI2OTE1MTdkCmtlcm5lbDogL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1pMS0w
MzA5MTgzMS9jYTYyZWVjNGU1MjQ1OTFiODJkOWVkZjdhMThlM2FlNmI2OTE1MTdkL3ZtbGlu
dXotMy4xNC4wLXJjNS0wMDI4Ny1nY2E2MmVlYwoKMjAxNC0wMy0wOS0yMjoyMjozMCBkZXRl
Y3RpbmcgYm9vdCBzdGF0ZSAJMS4JNAk1CTYJMTEJMTMJMTcuLgkxOQkyMAkyMwkyNAkyNwky
OC4uCTMyLgkzNAkzNgkzOAk0Mwk0NAk0Nwk1MQk1Mwk1OQk2NAk2Ngk2Nwk3MC4uCTcxCTcy
CTc0CTc2CTc3CTc5CTgxCTgyCTgzCTg0CTg4CTg5CTkzCTk2CTEwMwkxMTAJMTE0CTEyMAkx
MjYJMTMwLgkxMzEJMTMyCTEzOQkxNDIJMTQ0IFNVQ0NFU1MKCgo9PT09PT09PT0gbGludXgt
bmV4dCA9PT09PT09PT0KUHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgY2E2MmVlYy4uLiBN
ZXJnZSBicmFuY2ggJ2Zvci0zLjE0LWZpeGVzJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9w
dWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvdGovY2dyb3VwCkhFQUQgaXMgbm93IGF0IDFiMGE3
ZTMuLi4gQWRkIGxpbnV4LW5leHQgc3BlY2lmaWMgZmlsZXMgZm9yIDIwMTQwMzA3CmxzIC1h
IC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5
MTgzMS9uZXh0Om1hc3RlcjoxYjBhN2UzMjYzMTY4YTA2ZDM4NTg3OThlNDhjNWEyMWQxYzc4
ZDNjOmJpc2VjdC1uZXQKIFRFU1QgRkFJTFVSRQpbICAgIDIuNTQ3MjQzXSBpbnB1dDogUG93
ZXIgQnV0dG9uIGFzIC9kZXZpY2VzL0xOWFNZU1RNOjAwL0xOWFBXUkJOOjAwL2lucHV0L2lu
cHV0MApbICAgIDIuNTUwNzcwXSBBQ1BJOiBQb3dlciBCdXR0b24gW1BXUkZdClsgICAgMi41
NTA3NzBdIEFDUEk6IFBvd2VyIEJ1dHRvbiBbUFdSRl0KWyAgICAyLjc3NzY2OV0gc3dhcHBl
ciBpbnZva2VkIG9vbS1raWxsZXI6IGdmcF9tYXNrPTB4MjA0MGQwLCBvcmRlcj0wLCBvb21f
c2NvcmVfYWRqPTAKWyAgICAyLjc3NzY2OV0gc3dhcHBlciBpbnZva2VkIG9vbS1raWxsZXI6
IGdmcF9tYXNrPTB4MjA0MGQwLCBvcmRlcj0wLCBvb21fc2NvcmVfYWRqPTAKWyAgICAyLjc4
MTE0OV0gQ1BVOiAwIFBJRDogMSBDb21tOiBzd2FwcGVyIE5vdCB0YWludGVkIDMuMTQuMC1y
YzUtbmV4dC0yMDE0MDMwNyAjMQpbICAgIDIuNzgxMTQ5XSBDUFU6IDAgUElEOiAxIENvbW06
IHN3YXBwZXIgTm90IHRhaW50ZWQgMy4xNC4wLXJjNS1uZXh0LTIwMTQwMzA3ICMxClsgICAg
Mi43ODQ0MjJdIEhhcmR3YXJlIG5hbWU6IEJvY2hzIEJvY2hzLCBCSU9TIEJvY2hzIDAxLzAx
LzIwMTEKWyAgICAyLjc4NDQyMl0gSGFyZHdhcmUgbmFtZTogQm9jaHMgQm9jaHMsIEJJT1Mg
Qm9jaHMgMDEvMDEvMjAxMQpbICAgIDIuNzg2OTE2XSAgZmZmZjg4MDAwZTM2YzYxOApbICAg
IDIuNzg2OTE2XSAgZmZmZjg4MDAwZTM2YzYxOCBmZmZmODgwMDBlMzZmOTA4IGZmZmY4ODAw
MGUzNmY5MDggZmZmZmZmZmY4MTZjNzhlNSBmZmZmZmZmZjgxNmM3OGU1IGZmZmY4ODAwMGUz
NmY5ODggZmZmZjg4MDAwZTM2Zjk4OAoKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1pMS0w
MzA5MTgzMS8xYjBhN2UzMjYzMTY4YTA2ZDM4NTg3OThlNDhjNWEyMWQxYzc4ZDNjL2RtZXNn
LXlvY3RvLXNuYi0yNjoyMDE0MDMwOTE4NTAwMzp4ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5
MTgzMTo6Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4MzEvMWIwYTdlMzI2
MzE2OGEwNmQzODU4Nzk4ZTQ4YzVhMjFkMWM3OGQzYy9kbWVzZy15b2N0by1pdnl0b3duMi0y
MjoyMDE0MDMwOTE5MDAzMzp4ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMTozLjE0LjAt
cmM1LW5leHQtMjAxNDAzMDc6MQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkx
ODMxLzFiMGE3ZTMyNjMxNjhhMDZkMzg1ODc5OGU0OGM1YTIxZDFjNzhkM2MvZG1lc2cteW9j
dG8taXZ5dG93bjItMjA6MjAxNDAzMDkxOTAwMjU6eDg2XzY0LXJhbmRjb25maWctaTEtMDMw
OTE4MzE6My4xNC4wLXJjNS1uZXh0LTIwMTQwMzA3OjEKL2tlcm5lbC94ODZfNjQtcmFuZGNv
bmZpZy1pMS0wMzA5MTgzMS8xYjBhN2UzMjYzMTY4YTA2ZDM4NTg3OThlNDhjNWEyMWQxYzc4
ZDNjL2RtZXNnLXlvY3RvLXNuYi0zOjIwMTQwMzA5MTg0ODU5Ong4Nl82NC1yYW5kY29uZmln
LWkxLTAzMDkxODMxOjoKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS8x
YjBhN2UzMjYzMTY4YTA2ZDM4NTg3OThlNDhjNWEyMWQxYzc4ZDNjL2RtZXNnLXlvY3RvLWl2
eXRvd24yLTE6MjAxNDAzMDkxODQ5MTM6eDg2XzY0LXJhbmRjb25maWctaTEtMDMwOTE4MzE6
My4xNC4wLXJjNS1uZXh0LTIwMTQwMzA3OjEKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1p
MS0wMzA5MTgzMS8xYjBhN2UzMjYzMTY4YTA2ZDM4NTg3OThlNDhjNWEyMWQxYzc4ZDNjL2Rt
ZXNnLXlvY3RvLWl2eXRvd24yLTEzOjIwMTQwMzA5MTkwMDE0Ong4Nl82NC1yYW5kY29uZmln
LWkxLTAzMDkxODMxOjMuMTQuMC1yYzUtbmV4dC0yMDE0MDMwNzoxCi9rZXJuZWwveDg2XzY0
LXJhbmRjb25maWctaTEtMDMwOTE4MzEvMWIwYTdlMzI2MzE2OGEwNmQzODU4Nzk4ZTQ4YzVh
MjFkMWM3OGQzYy9kbWVzZy15b2N0by14Z3dvLTI6MjAxNDAzMDkxOTA0Mzg6eDg2XzY0LXJh
bmRjb25maWctaTEtMDMwOTE4MzE6My4xNC4wLXJjNS1uZXh0LTIwMTQwMzA3OjEKL2tlcm5l
bC94ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMS8xYjBhN2UzMjYzMTY4YTA2ZDM4NTg3
OThlNDhjNWEyMWQxYzc4ZDNjL2RtZXNnLXlvY3RvLXNuYi0xNToyMDE0MDMwOTE4NTAwMzp4
ODZfNjQtcmFuZGNvbmZpZy1pMS0wMzA5MTgzMTo6Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25m
aWctaTEtMDMwOTE4MzEvMWIwYTdlMzI2MzE2OGEwNmQzODU4Nzk4ZTQ4YzVhMjFkMWM3OGQz
Yy9kbWVzZy15b2N0by1zbmItMjQ6MjAxNDAzMDkxODQ5NTg6eDg2XzY0LXJhbmRjb25maWct
aTEtMDMwOTE4MzE6Ogova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxLzFi
MGE3ZTMyNjMxNjhhMDZkMzg1ODc5OGU0OGM1YTIxZDFjNzhkM2MvZG1lc2cteW9jdG8tYXRo
ZW5zLTIyOjIwMTQwMzA5MTg0OTI0Ong4Nl82NC1yYW5kY29uZmlnLWkxLTAzMDkxODMxOjMu
MTQuMC1yYzUtbmV4dC0yMDE0MDMwNzoxCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctaTEt
MDMwOTE4MzEvMWIwYTdlMzI2MzE2OGEwNmQzODU4Nzk4ZTQ4YzVhMjFkMWM3OGQzYy9kbWVz
Zy15b2N0by1pdnl0b3duMi0yOToyMDE0MDMwOTE5MDAyNDp4ODZfNjQtcmFuZGNvbmZpZy1p
MS0wMzA5MTgzMTozLjE0LjAtcmM1LW5leHQtMjAxNDAzMDc6MQova2VybmVsL3g4Nl82NC1y
YW5kY29uZmlnLWkxLTAzMDkxODMxLzFiMGE3ZTMyNjMxNjhhMDZkMzg1ODc5OGU0OGM1YTIx
ZDFjNzhkM2MvZG1lc2cteW9jdG8teGlhbi0xNDoyMDE0MDMwOTE4NDg1Njp4ODZfNjQtcmFu
ZGNvbmZpZy1pMS0wMzA5MTgzMTozLjE0LjAtcmM1LW5leHQtMjAxNDAzMDc6MQo0OjEyOjE1
IGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzCgo=

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.14.0-rc5-next-20140307"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.14.0-rc5 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
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
CONFIG_COMPILE_TEST=y
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
CONFIG_KERNEL_LZMA=y
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_FHANDLE is not set
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
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
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
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
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
# CONFIG_CGROUPS is not set
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_NAMESPACES is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
# CONFIG_RD_LZO is not set
# CONFIG_RD_LZ4 is not set
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
# CONFIG_SYSFS_SYSCALL is not set
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
CONFIG_PCSPKR_PLATFORM=y
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_EPOLL=y
# CONFIG_SIGNALFD is not set
# CONFIG_TIMERFD is not set
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_COMPAT_BRK is not set
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
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
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
# CONFIG_MODULE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
CONFIG_MODULE_SRCVERSION_ALL=y
CONFIG_MODULE_SIG=y
# CONFIG_MODULE_SIG_FORCE is not set
# CONFIG_MODULE_SIG_ALL is not set
CONFIG_MODULE_SIG_SHA1=y
# CONFIG_MODULE_SIG_SHA224 is not set
# CONFIG_MODULE_SIG_SHA256 is not set
# CONFIG_MODULE_SIG_SHA384 is not set
# CONFIG_MODULE_SIG_SHA512 is not set
CONFIG_MODULE_SIG_HASH="sha1"
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_CMDLINE_PARSER=y

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_AMIGA_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_IOSCHED_CFQ=y
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_ASN1=y
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
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
# CONFIG_CPU_SUP_AMD is not set
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_CALGARY_IOMMU=y
# CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set
CONFIG_I8K=m
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=m
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
# CONFIG_DIRECT_GBPAGES is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
# CONFIG_BALLOON_COMPACTION is not set
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_NEED_BOUNCE_POOL=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_NEED_PER_CPU_KM=y
CONFIG_CLEANCACHE=y
# CONFIG_FRONTSWAP is not set
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
# CONFIG_ZSMALLOC is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
# CONFIG_X86_PAT is not set
# CONFIG_ARCH_RANDOM is not set
# CONFIG_X86_SMAP is not set
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_KEXEC_JUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
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
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_APEI is not set
# CONFIG_SFI is not set

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

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=m

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
# CONFIG_PCIEAER_INJECT is not set
# CONFIG_PCIEASPM is not set
CONFIG_PCIE_PME=y
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
CONFIG_PCI_STUB=m
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
# CONFIG_PCI_PRI is not set
CONFIG_PCI_PASID=y
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
# CONFIG_ISA_DMA_API is not set
CONFIG_PCCARD=m
CONFIG_PCMCIA=m
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=m
# CONFIG_YENTA_O2 is not set
# CONFIG_YENTA_RICOH is not set
# CONFIG_YENTA_TI is not set
CONFIG_YENTA_TOSHIBA=y
CONFIG_PD6729=m
# CONFIG_I82092 is not set
CONFIG_PCCARD_NONSTATIC=y
# CONFIG_HOTPLUG_PCI is not set
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_TSI721=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
# CONFIG_RAPIDIO_DMA_ENGINE is not set
# CONFIG_RAPIDIO_DEBUG is not set
# CONFIG_RAPIDIO_ENUM_BASIC is not set

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=m
CONFIG_RAPIDIO_CPS_XX=m
# CONFIG_RAPIDIO_TSI568 is not set
CONFIG_RAPIDIO_CPS_GEN2=y
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_DEV_DMA_OPS=y
# CONFIG_IOSF_MBI is not set
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
CONFIG_NETFILTER_DEBUG=y
CONFIG_NETFILTER_ADVANCED=y

#
# DECnet: Netfilter Configuration
#
# CONFIG_DECNET_NF_GRABULATOR is not set
# CONFIG_BRIDGE_NF_EBTABLES is not set
CONFIG_ATM=y
CONFIG_ATM_LANE=m
CONFIG_STP=m
CONFIG_BRIDGE=m
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_TAG_DSA=y
CONFIG_NET_DSA_TAG_EDSA=y
# CONFIG_VLAN_8021Q is not set
CONFIG_DECNET=y
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_IPDDP=m
CONFIG_IPDDP_ENCAP=y
CONFIG_X25=m
CONFIG_LAPB=y
CONFIG_PHONET=y
CONFIG_IEEE802154=y
CONFIG_6LOWPAN_IPHC=m
# CONFIG_MAC802154 is not set
# CONFIG_NET_SCHED is not set
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
CONFIG_NETLINK_DIAG=m
# CONFIG_NET_MPLS_GSO is not set
CONFIG_HSR=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_BPF_JIT=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
CONFIG_CAN=y
CONFIG_CAN_RAW=y
CONFIG_CAN_BCM=y
CONFIG_CAN_GW=m

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=m
# CONFIG_CAN_CALC_BITTIMING is not set
# CONFIG_CAN_LEDS is not set
CONFIG_CAN_MCP251X=m
CONFIG_CAN_JANZ_ICAN3=m
CONFIG_PCH_CAN=m
CONFIG_CAN_SJA1000=m
CONFIG_CAN_SJA1000_ISA=m
# CONFIG_CAN_SJA1000_PLATFORM is not set
# CONFIG_CAN_EMS_PCMCIA is not set
CONFIG_CAN_EMS_PCI=m
CONFIG_CAN_PEAK_PCMCIA=m
# CONFIG_CAN_PEAK_PCI is not set
CONFIG_CAN_KVASER_PCI=m
CONFIG_CAN_PLX_PCI=m
CONFIG_CAN_C_CAN=m
CONFIG_CAN_C_CAN_PLATFORM=m
CONFIG_CAN_C_CAN_PCI=m
CONFIG_CAN_CC770=m
CONFIG_CAN_CC770_ISA=m
# CONFIG_CAN_CC770_PLATFORM is not set

#
# CAN USB interfaces
#
# CONFIG_CAN_EMS_USB is not set
# CONFIG_CAN_ESD_USB2 is not set
# CONFIG_CAN_KVASER_USB is not set
CONFIG_CAN_PEAK_USB=m
CONFIG_CAN_8DEV_USB=m
# CONFIG_CAN_SOFTING is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=m

#
# IrDA protocols
#
CONFIG_IRLAN=m
# CONFIG_IRNET is not set
# CONFIG_IRCOMM is not set
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
# CONFIG_IRDA_CACHE_LAST_LSAP is not set
# CONFIG_IRDA_FAST_RR is not set
CONFIG_IRDA_DEBUG=y

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
# CONFIG_IRTTY_SIR is not set

#
# Dongle support
#
CONFIG_KINGSUN_DONGLE=m
# CONFIG_KSDAZZLE_DONGLE is not set
# CONFIG_KS959_DONGLE is not set

#
# FIR device drivers
#
# CONFIG_USB_IRDA is not set
# CONFIG_SIGMATEL_FIR is not set
# CONFIG_VLSI_FIR is not set
CONFIG_MCS_FIR=m
CONFIG_BT=m
CONFIG_BT_RFCOMM=m
# CONFIG_BT_RFCOMM_TTY is not set
# CONFIG_BT_BNEP is not set
CONFIG_BT_CMTP=m
CONFIG_BT_HIDP=m

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTUSB=m
# CONFIG_BT_HCIBTSDIO is not set
# CONFIG_BT_HCIUART is not set
CONFIG_BT_HCIBCM203X=m
CONFIG_BT_HCIBPA10X=m
CONFIG_BT_HCIBFUSB=m
CONFIG_BT_HCIDTL1=m
# CONFIG_BT_HCIBT3C is not set
CONFIG_BT_HCIBLUECARD=m
CONFIG_BT_HCIBTUART=m
# CONFIG_BT_HCIVHCI is not set
CONFIG_BT_MRVL=m
CONFIG_BT_MRVL_SDIO=m
CONFIG_BT_ATH3K=m
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=y
CONFIG_NL80211_TESTMODE=y
CONFIG_CFG80211_DEVELOPER_WARNINGS=y
# CONFIG_CFG80211_REG_DEBUG is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_DEFAULT_PS=y
CONFIG_CFG80211_DEBUGFS=y
# CONFIG_CFG80211_INTERNAL_REGDB is not set
# CONFIG_CFG80211_WEXT is not set
CONFIG_LIB80211=y
CONFIG_LIB80211_CRYPT_WEP=y
CONFIG_LIB80211_CRYPT_CCMP=y
CONFIG_LIB80211_CRYPT_TKIP=y
CONFIG_LIB80211_DEBUG=y
CONFIG_MAC80211=m
# CONFIG_MAC80211_RC_PID is not set
# CONFIG_MAC80211_RC_MINSTREL is not set
CONFIG_MAC80211_RC_DEFAULT=""

#
# Some wireless drivers require a rate control algorithm
#
# CONFIG_MAC80211_MESH is not set
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
CONFIG_MAC80211_MESSAGE_TRACING=y
CONFIG_MAC80211_DEBUG_MENU=y
# CONFIG_MAC80211_NOINLINE is not set
# CONFIG_MAC80211_VERBOSE_DEBUG is not set
# CONFIG_MAC80211_MLME_DEBUG is not set
CONFIG_MAC80211_STA_DEBUG=y
CONFIG_MAC80211_HT_DEBUG=y
CONFIG_MAC80211_IBSS_DEBUG=y
CONFIG_MAC80211_PS_DEBUG=y
# CONFIG_MAC80211_TDLS_DEBUG is not set
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
# CONFIG_RFKILL_INPUT is not set
CONFIG_RFKILL_REGULATOR=m
CONFIG_RFKILL_GPIO=y
CONFIG_NET_9P=y
# CONFIG_NET_9P_VIRTIO is not set
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_FW_LOADER_USER_HELPER is not set
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
CONFIG_CONNECTOR=m
# CONFIG_MTD is not set
CONFIG_PARPORT=m
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=m
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=y
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
# CONFIG_BLK_CPQ_CISS_DA is not set
CONFIG_BLK_DEV_DAC960=m
CONFIG_BLK_DEV_UMEM=m
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=m

#
# DRBD disabled because PROC_FS or INET not selected
#
CONFIG_BLK_DEV_NBD=m
# CONFIG_BLK_DEV_NVME is not set
CONFIG_BLK_DEV_SKD=m
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
CONFIG_CDROM_PKTCDVD_WCACHE=y
# CONFIG_ATA_OVER_ETH is not set
CONFIG_VIRTIO_BLK=m
# CONFIG_BLK_DEV_HD is not set
CONFIG_BLK_DEV_RSXX=y

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=m
# CONFIG_AD525X_DPOT is not set
CONFIG_DUMMY_IRQ=y
CONFIG_IBM_ASM=m
CONFIG_PHANTOM=y
# CONFIG_INTEL_MID_PTI is not set
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
# CONFIG_ICS932S401 is not set
CONFIG_ATMEL_SSC=y
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_CS5535_MFGPT=m
CONFIG_CS5535_MFGPT_DEFAULT_IRQ=7
CONFIG_CS5535_CLOCK_EVENT_SRC=m
CONFIG_HP_ILO=m
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
CONFIG_SENSORS_BH1770=m
CONFIG_SENSORS_APDS990X=m
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
CONFIG_TI_DAC7512=m
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
# CONFIG_BMP085_I2C is not set
CONFIG_BMP085_SPI=y
CONFIG_PCH_PHUB=y
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_LATTICE_ECP3_CONFIG=m
CONFIG_SRAM=y
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=m

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
# CONFIG_EEPROM_AT25 is not set
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_93XX46=m
CONFIG_CB710_CORE=m
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=m

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=m
CONFIG_INTEL_MEI_ME=m
CONFIG_INTEL_MEI_TXE=m
CONFIG_VMWARE_VMCI=y

#
# Intel MIC Host Driver
#
CONFIG_INTEL_MIC_HOST=y

#
# Intel MIC Card Driver
#
CONFIG_INTEL_MIC_CARD=y
CONFIG_GENWQE=y
CONFIG_ECHO=m
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=m
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=m
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
# CONFIG_BLK_DEV_SD is not set
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=m
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=m
# CONFIG_SCSI_MULTI_LUN is not set
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=m
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=m
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_BOOT_SYSFS=m
CONFIG_SCSI_BNX2_ISCSI=m
# CONFIG_SCSI_BNX2X_FCOE is not set
CONFIG_BE2ISCSI=m
CONFIG_BLK_DEV_3W_XXXX_RAID=m
CONFIG_SCSI_HPSA=m
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
CONFIG_SCSI_ACARD=m
CONFIG_SCSI_AACRAID=m
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC79XX is not set
CONFIG_SCSI_AIC94XX=m
CONFIG_AIC94XX_DEBUG=y
CONFIG_SCSI_MVSAS=m
# CONFIG_SCSI_MVSAS_DEBUG is not set
# CONFIG_SCSI_MVSAS_TASKLET is not set
CONFIG_SCSI_MVUMI=m
CONFIG_SCSI_DPT_I2O=m
# CONFIG_SCSI_ADVANSYS is not set
CONFIG_SCSI_ARCMSR=m
# CONFIG_SCSI_ESAS2R is not set
CONFIG_MEGARAID_NEWGEN=y
# CONFIG_MEGARAID_MM is not set
CONFIG_MEGARAID_LEGACY=m
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_MPT2SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=m
# CONFIG_VMWARE_PVSCSI is not set
CONFIG_LIBFC=m
CONFIG_LIBFCOE=m
CONFIG_FCOE=m
# CONFIG_FCOE_FNIC is not set
CONFIG_SCSI_DMX3191D=m
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_ISCI is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
CONFIG_SCSI_INIA100=m
CONFIG_SCSI_STEX=m
CONFIG_SCSI_SYM53C8XX_2=m
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
# CONFIG_SCSI_SYM53C8XX_MMIO is not set
CONFIG_SCSI_QLOGIC_1280=m
CONFIG_SCSI_QLA_FC=m
CONFIG_SCSI_QLA_ISCSI=m
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_DC395x=m
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
CONFIG_SCSI_PMCRAID=m
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_BFA_FC is not set
# CONFIG_SCSI_VIRTIO is not set
# CONFIG_SCSI_CHELSIO_FCOE is not set
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
CONFIG_PCMCIA_AHA152X=m
CONFIG_PCMCIA_FDOMAIN=m
# CONFIG_PCMCIA_QLOGIC is not set
# CONFIG_PCMCIA_SYM53C500 is not set
CONFIG_SCSI_DH=m
CONFIG_SCSI_DH_RDAC=m
# CONFIG_SCSI_DH_HP_SW is not set
CONFIG_SCSI_DH_EMC=m
CONFIG_SCSI_DH_ALUA=m
# CONFIG_SCSI_OSD_INITIATOR is not set
# CONFIG_ATA is not set
# CONFIG_MD is not set
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
# CONFIG_FUSION_SPI is not set
CONFIG_FUSION_FC=m
CONFIG_FUSION_SAS=m
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=m
CONFIG_FUSION_LAN=m
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
CONFIG_FIREWIRE_NOSY=y
CONFIG_I2O=y
CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=y
# CONFIG_I2O_EXT_ADAPTEC is not set
CONFIG_I2O_CONFIG=y
# CONFIG_I2O_CONFIG_OLD_IOCTL is not set
# CONFIG_I2O_BUS is not set
# CONFIG_I2O_BLOCK is not set
CONFIG_I2O_SCSI=m
CONFIG_I2O_PROC=m
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
CONFIG_DUMMY=y
CONFIG_EQUALIZER=m
CONFIG_NET_FC=y
CONFIG_NET_TEAM=y
CONFIG_NET_TEAM_MODE_BROADCAST=m
CONFIG_NET_TEAM_MODE_ROUNDROBIN=y
CONFIG_NET_TEAM_MODE_RANDOM=m
# CONFIG_NET_TEAM_MODE_ACTIVEBACKUP is not set
CONFIG_NET_TEAM_MODE_LOADBALANCE=y
CONFIG_MACVLAN=m
CONFIG_MACVTAP=m
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
CONFIG_NTB_NETDEV=m
# CONFIG_RIONET is not set
# CONFIG_TUN is not set
CONFIG_VETH=m
# CONFIG_VIRTIO_NET is not set
# CONFIG_NLMON is not set
CONFIG_ARCNET=m
# CONFIG_ARCNET_1201 is not set
# CONFIG_ARCNET_1051 is not set
CONFIG_ARCNET_RAW=m
CONFIG_ARCNET_CAP=m
# CONFIG_ARCNET_COM90xx is not set
# CONFIG_ARCNET_COM90xxIO is not set
CONFIG_ARCNET_RIM_I=m
CONFIG_ARCNET_COM20020=m
CONFIG_ARCNET_COM20020_PCI=m
CONFIG_ARCNET_COM20020_CS=m
CONFIG_ATM_DRIVERS=y
# CONFIG_ATM_DUMMY is not set
# CONFIG_ATM_LANAI is not set
CONFIG_ATM_ENI=m
CONFIG_ATM_ENI_DEBUG=y
CONFIG_ATM_ENI_TUNE_BURST=y
# CONFIG_ATM_ENI_BURST_TX_16W is not set
CONFIG_ATM_ENI_BURST_TX_8W=y
CONFIG_ATM_ENI_BURST_TX_4W=y
# CONFIG_ATM_ENI_BURST_TX_2W is not set
# CONFIG_ATM_ENI_BURST_RX_16W is not set
# CONFIG_ATM_ENI_BURST_RX_8W is not set
CONFIG_ATM_ENI_BURST_RX_4W=y
# CONFIG_ATM_ENI_BURST_RX_2W is not set
# CONFIG_ATM_FIRESTREAM is not set
CONFIG_ATM_ZATM=m
# CONFIG_ATM_ZATM_DEBUG is not set
# CONFIG_ATM_NICSTAR is not set
CONFIG_ATM_IDT77252=m
CONFIG_ATM_IDT77252_DEBUG=y
CONFIG_ATM_IDT77252_RCV_ALL=y
CONFIG_ATM_IDT77252_USE_SUNI=y
# CONFIG_ATM_AMBASSADOR is not set
CONFIG_ATM_HORIZON=m
CONFIG_ATM_HORIZON_DEBUG=y
CONFIG_ATM_IA=y
# CONFIG_ATM_IA_DEBUG is not set
# CONFIG_ATM_FORE200E is not set
CONFIG_ATM_HE=y
CONFIG_ATM_HE_USE_SUNI=y
# CONFIG_ATM_SOLOS is not set

#
# CAIF transport drivers
#
CONFIG_VHOST_NET=m
CONFIG_VHOST_RING=y
CONFIG_VHOST=m

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6XXX=y
# CONFIG_NET_DSA_MV88E6060 is not set
CONFIG_NET_DSA_MV88E6XXX_NEED_PPU=y
CONFIG_NET_DSA_MV88E6131=m
CONFIG_NET_DSA_MV88E6123_61_65=y
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
CONFIG_NET_VENDOR_ADAPTEC=y
CONFIG_ADAPTEC_STARFIRE=m
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
CONFIG_ACENIC_OMIT_TIGON_I=y
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=m
CONFIG_PCNET32=m
CONFIG_PCMCIA_NMCLAN=m
# CONFIG_NET_VENDOR_ARC is not set
# CONFIG_NET_VENDOR_ATHEROS is not set
# CONFIG_NET_CADENCE is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
CONFIG_BNX2=y
CONFIG_CNIC=y
# CONFIG_TIGON3 is not set
CONFIG_BNX2X=y
CONFIG_BNX2X_SRIOV=y
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
CONFIG_CHELSIO_T1=y
# CONFIG_CHELSIO_T1_1G is not set
CONFIG_CHELSIO_T4=m
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=y
# CONFIG_DNET is not set
# CONFIG_NET_VENDOR_DEC is not set
CONFIG_NET_VENDOR_DLINK=y
CONFIG_DL2K=y
# CONFIG_SUNDANCE is not set
# CONFIG_NET_VENDOR_EMULEX is not set
CONFIG_NET_VENDOR_EXAR=y
CONFIG_S2IO=y
CONFIG_VXGE=m
CONFIG_VXGE_DEBUG_TRACE_ALL=y
# CONFIG_NET_VENDOR_FUJITSU is not set
CONFIG_NET_VENDOR_HP=y
CONFIG_HP100=y
# CONFIG_NET_VENDOR_INTEL is not set
# CONFIG_IP1000 is not set
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_SKGE is not set
CONFIG_SKY2=y
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=y
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=y
CONFIG_MLX4_DEBUG=y
# CONFIG_MLX5_CORE is not set
CONFIG_NET_VENDOR_MICREL=y
CONFIG_KS8851=y
CONFIG_KS8851_MLL=m
CONFIG_KSZ884X_PCI=y
CONFIG_NET_VENDOR_MICROCHIP=y
CONFIG_ENC28J60=m
# CONFIG_ENC28J60_WRITEVERIFY is not set
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
# CONFIG_NET_VENDOR_NVIDIA is not set
CONFIG_NET_VENDOR_OKI=y
CONFIG_PCH_GBE=m
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
CONFIG_YELLOWFIN=m
# CONFIG_NET_VENDOR_QLOGIC is not set
# CONFIG_NET_VENDOR_REALTEK is not set
CONFIG_SH_ETH=m
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_SEEQ=y
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
CONFIG_SFC=y
# CONFIG_SFC_SRIOV is not set
# CONFIG_NET_VENDOR_SMSC is not set
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
# CONFIG_NET_VENDOR_VIA is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
CONFIG_PCMCIA_XIRC2PS=m
CONFIG_FDDI=m
# CONFIG_DEFXX is not set
CONFIG_SKFP=m
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
CONFIG_AMD_PHY=y
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=m
CONFIG_QSEMI_PHY=y
# CONFIG_LXT_PHY is not set
CONFIG_CICADA_PHY=m
# CONFIG_VITESSE_PHY is not set
CONFIG_SMSC_PHY=y
CONFIG_BROADCOM_PHY=m
# CONFIG_BCM7XXX_PHY is not set
# CONFIG_BCM87XX_PHY is not set
CONFIG_ICPLUS_PHY=m
CONFIG_REALTEK_PHY=y
# CONFIG_NATIONAL_PHY is not set
CONFIG_STE10XP=y
CONFIG_LSI_ET1011C_PHY=m
CONFIG_MICREL_PHY=y
# CONFIG_FIXED_PHY is not set
CONFIG_MDIO_BITBANG=y
CONFIG_MDIO_GPIO=y
CONFIG_MICREL_KS8995MA=m
CONFIG_PLIP=m
CONFIG_PPP=m
CONFIG_PPP_BSDCOMP=m
# CONFIG_PPP_DEFLATE is not set
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=m
# CONFIG_PPP_MULTILINK is not set
CONFIG_PPPOATM=m
# CONFIG_PPPOE is not set
# CONFIG_PPP_ASYNC is not set
# CONFIG_PPP_SYNC_TTY is not set
# CONFIG_SLIP is not set
CONFIG_SLHC=m

#
# USB Network Adapters
#
CONFIG_USB_CATC=m
# CONFIG_USB_KAWETH is not set
CONFIG_USB_PEGASUS=m
CONFIG_USB_RTL8150=m
CONFIG_USB_RTL8152=m
CONFIG_USB_USBNET=m
CONFIG_USB_NET_AX8817X=m
CONFIG_USB_NET_AX88179_178A=m
CONFIG_USB_NET_CDCETHER=m
# CONFIG_USB_NET_CDC_EEM is not set
CONFIG_USB_NET_CDC_NCM=m
# CONFIG_USB_NET_HUAWEI_CDC_NCM is not set
CONFIG_USB_NET_CDC_MBIM=m
CONFIG_USB_NET_DM9601=m
CONFIG_USB_NET_SR9700=m
CONFIG_USB_NET_SR9800=m
# CONFIG_USB_NET_SMSC75XX is not set
CONFIG_USB_NET_SMSC95XX=m
CONFIG_USB_NET_GL620A=m
CONFIG_USB_NET_NET1080=m
# CONFIG_USB_NET_PLUSB is not set
# CONFIG_USB_NET_MCS7830 is not set
# CONFIG_USB_NET_RNDIS_HOST is not set
CONFIG_USB_NET_CDC_SUBSET=m
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
# CONFIG_USB_BELKIN is not set
# CONFIG_USB_ARMLINUX is not set
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=m
CONFIG_USB_NET_CX82310_ETH=m
CONFIG_USB_NET_KALMIA=m
# CONFIG_USB_NET_QMI_WWAN is not set
# CONFIG_USB_HSO is not set
# CONFIG_USB_NET_INT51X1 is not set
CONFIG_USB_CDC_PHONET=m
CONFIG_USB_IPHETH=m
CONFIG_USB_SIERRA_NET=m
# CONFIG_USB_VL600 is not set
CONFIG_WLAN=y
CONFIG_PCMCIA_RAYCS=m
CONFIG_LIBERTAS_THINFIRM=m
# CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
CONFIG_LIBERTAS_THINFIRM_USB=m
CONFIG_ATMEL=y
CONFIG_PCI_ATMEL=m
CONFIG_PCMCIA_ATMEL=m
# CONFIG_AT76C50X_USB is not set
# CONFIG_AIRO_CS is not set
CONFIG_PCMCIA_WL3501=m
CONFIG_PRISM54=y
# CONFIG_USB_ZD1201 is not set
# CONFIG_USB_NET_RNDIS_WLAN is not set
CONFIG_RTL8180=m
# CONFIG_RTL8187 is not set
# CONFIG_ADM8211 is not set
# CONFIG_MAC80211_HWSIM is not set
CONFIG_MWL8K=m
CONFIG_ATH_COMMON=m
CONFIG_ATH_CARDS=m
# CONFIG_ATH_DEBUG is not set
CONFIG_ATH5K=m
# CONFIG_ATH5K_DEBUG is not set
# CONFIG_ATH5K_TRACER is not set
CONFIG_ATH5K_PCI=y
# CONFIG_ATH9K is not set
# CONFIG_ATH9K_HTC is not set
CONFIG_CARL9170=m
# CONFIG_CARL9170_LEDS is not set
CONFIG_CARL9170_WPC=y
# CONFIG_CARL9170_HWRNG is not set
# CONFIG_ATH6KL is not set
CONFIG_AR5523=m
CONFIG_WIL6210=m
# CONFIG_WIL6210_ISR_COR is not set
# CONFIG_WIL6210_TRACING is not set
CONFIG_ATH10K=m
CONFIG_ATH10K_PCI=m
CONFIG_ATH10K_DEBUG=y
CONFIG_ATH10K_DEBUGFS=y
# CONFIG_ATH10K_TRACING is not set
CONFIG_WCN36XX=m
# CONFIG_WCN36XX_DEBUGFS is not set
# CONFIG_B43 is not set
CONFIG_B43LEGACY=m
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_LEDS=y
CONFIG_B43LEGACY_HWRNG=y
CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_DMA=y
# CONFIG_B43LEGACY_DMA_AND_PIO_MODE is not set
CONFIG_B43LEGACY_DMA_MODE=y
# CONFIG_B43LEGACY_PIO_MODE is not set
CONFIG_BRCMUTIL=y
# CONFIG_BRCMSMAC is not set
CONFIG_BRCMFMAC=y
CONFIG_BRCM_TRACING=y
CONFIG_BRCMDBG=y
CONFIG_HOSTAP=y
CONFIG_HOSTAP_FIRMWARE=y
# CONFIG_HOSTAP_FIRMWARE_NVRAM is not set
CONFIG_HOSTAP_PLX=m
CONFIG_HOSTAP_PCI=y
CONFIG_HOSTAP_CS=m
CONFIG_IPW2100=y
# CONFIG_IPW2100_MONITOR is not set
# CONFIG_IPW2100_DEBUG is not set
CONFIG_LIBIPW=y
CONFIG_LIBIPW_DEBUG=y
CONFIG_IWLWIFI=m
CONFIG_IWLDVM=m
# CONFIG_IWLMVM is not set
CONFIG_IWLWIFI_OPMODE_MODULAR=y

#
# Debugging Options
#
# CONFIG_IWLWIFI_DEBUG is not set
CONFIG_IWLWIFI_DEVICE_TRACING=y
CONFIG_IWLEGACY=m
CONFIG_IWL4965=m
# CONFIG_IWL3945 is not set

#
# iwl3945 / iwl4965 Debugging Options
#
CONFIG_IWLEGACY_DEBUG=y
# CONFIG_LIBERTAS is not set
# CONFIG_P54_COMMON is not set
CONFIG_RT2X00=m
CONFIG_RT2400PCI=m
# CONFIG_RT2500PCI is not set
# CONFIG_RT61PCI is not set
# CONFIG_RT2800PCI is not set
# CONFIG_RT2500USB is not set
CONFIG_RT73USB=m
# CONFIG_RT2800USB is not set
CONFIG_RT2X00_LIB_MMIO=m
CONFIG_RT2X00_LIB_PCI=m
CONFIG_RT2X00_LIB_USB=m
CONFIG_RT2X00_LIB=m
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_CRYPTO=y
CONFIG_RT2X00_LIB_LEDS=y
CONFIG_RT2X00_DEBUG=y
CONFIG_RTL_CARDS=m
CONFIG_RTL8192CE=m
CONFIG_RTL8192SE=m
# CONFIG_RTL8192DE is not set
# CONFIG_RTL8723AE is not set
# CONFIG_RTL8723BE is not set
CONFIG_RTL8188EE=m
CONFIG_RTL8192CU=m
CONFIG_RTLWIFI=m
CONFIG_RTLWIFI_PCI=m
CONFIG_RTLWIFI_USB=m
# CONFIG_RTLWIFI_DEBUG is not set
CONFIG_RTL8192C_COMMON=m
CONFIG_WL_TI=y
# CONFIG_WL1251 is not set
CONFIG_WL12XX=m
CONFIG_WL18XX=m
CONFIG_WLCORE=m
CONFIG_WLCORE_SPI=m
CONFIG_WLCORE_SDIO=m
# CONFIG_WILINK_PLATFORM_DATA is not set
# CONFIG_ZD1211RW is not set
CONFIG_MWIFIEX=m
CONFIG_MWIFIEX_SDIO=m
CONFIG_MWIFIEX_PCIE=m
CONFIG_MWIFIEX_USB=m
CONFIG_CW1200=m
CONFIG_CW1200_WLAN_SDIO=m
CONFIG_CW1200_WLAN_SPI=m

#
# WiMAX Wireless Broadband devices
#
# CONFIG_WIMAX_I2400M_USB is not set
# CONFIG_WAN is not set
CONFIG_IEEE802154_DRIVERS=y
CONFIG_IEEE802154_FAKEHARD=m
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
CONFIG_ISDN_CAPI=y
CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON=y
CONFIG_CAPI_TRACE=y
# CONFIG_ISDN_CAPI_MIDDLEWARE is not set
# CONFIG_ISDN_CAPI_CAPI20 is not set

#
# CAPI hardware drivers
#
# CONFIG_CAPI_AVM is not set
# CONFIG_CAPI_EICON is not set
# CONFIG_ISDN_DRV_GIGASET is not set
CONFIG_HYSDN=m
# CONFIG_HYSDN_CAPI is not set
CONFIG_MISDN=m
CONFIG_MISDN_DSP=m
# CONFIG_MISDN_L1OIP is not set

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=m
CONFIG_MISDN_HFCMULTI=m
CONFIG_MISDN_HFCUSB=m
# CONFIG_MISDN_AVMFRITZ is not set
CONFIG_MISDN_SPEEDFAX=m
CONFIG_MISDN_INFINEON=m
CONFIG_MISDN_W6692=m
# CONFIG_MISDN_NETJET is not set
CONFIG_MISDN_IPAC=m
CONFIG_MISDN_ISAR=m

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=m
CONFIG_INPUT_POLLDEV=m
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
CONFIG_INPUT_JOYDEV=m
# CONFIG_INPUT_EVDEV is not set
CONFIG_INPUT_EVBUG=m

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
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
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_SH_KEYSC is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=m
CONFIG_MOUSE_PS2_ALPS=y
# CONFIG_MOUSE_PS2_LOGIPS2PP is not set
# CONFIG_MOUSE_PS2_SYNAPTICS is not set
# CONFIG_MOUSE_PS2_CYPRESS is not set
CONFIG_MOUSE_PS2_LIFEBOOK=y
# CONFIG_MOUSE_PS2_TRACKPOINT is not set
# CONFIG_MOUSE_PS2_ELANTECH is not set
CONFIG_MOUSE_PS2_SENTELIC=y
CONFIG_MOUSE_PS2_TOUCHKIT=y
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
CONFIG_MOUSE_CYAPA=m
# CONFIG_MOUSE_VSXXXAA is not set
CONFIG_MOUSE_GPIO=m
CONFIG_MOUSE_SYNAPTICS_I2C=m
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=m
# CONFIG_JOYSTICK_A3D is not set
CONFIG_JOYSTICK_ADI=m
# CONFIG_JOYSTICK_COBRA is not set
CONFIG_JOYSTICK_GF2K=m
CONFIG_JOYSTICK_GRIP=m
# CONFIG_JOYSTICK_GRIP_MP is not set
# CONFIG_JOYSTICK_GUILLEMOT is not set
# CONFIG_JOYSTICK_INTERACT is not set
# CONFIG_JOYSTICK_SIDEWINDER is not set
# CONFIG_JOYSTICK_TMDC is not set
CONFIG_JOYSTICK_IFORCE=m
# CONFIG_JOYSTICK_IFORCE_USB is not set
# CONFIG_JOYSTICK_IFORCE_232 is not set
CONFIG_JOYSTICK_WARRIOR=m
CONFIG_JOYSTICK_MAGELLAN=m
# CONFIG_JOYSTICK_SPACEORB is not set
CONFIG_JOYSTICK_SPACEBALL=m
CONFIG_JOYSTICK_STINGER=m
CONFIG_JOYSTICK_TWIDJOY=m
# CONFIG_JOYSTICK_ZHENHUA is not set
CONFIG_JOYSTICK_DB9=m
CONFIG_JOYSTICK_GAMECON=m
CONFIG_JOYSTICK_TURBOGRAFX=m
CONFIG_JOYSTICK_AS5011=m
CONFIG_JOYSTICK_JOYDUMP=m
CONFIG_JOYSTICK_XPAD=m
# CONFIG_JOYSTICK_XPAD_FF is not set
CONFIG_JOYSTICK_XPAD_LEDS=y
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
# CONFIG_TOUCHSCREEN_ADS7846 is not set
CONFIG_TOUCHSCREEN_AD7877=m
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
CONFIG_TOUCHSCREEN_AUO_PIXCIR=m
CONFIG_TOUCHSCREEN_BU21013=m
CONFIG_TOUCHSCREEN_CY8CTMG110=m
CONFIG_TOUCHSCREEN_CYTTSP_CORE=m
CONFIG_TOUCHSCREEN_CYTTSP_I2C=m
# CONFIG_TOUCHSCREEN_CYTTSP_SPI is not set
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=m
CONFIG_TOUCHSCREEN_CYTTSP4_I2C=m
CONFIG_TOUCHSCREEN_CYTTSP4_SPI=m
# CONFIG_TOUCHSCREEN_DA9034 is not set
CONFIG_TOUCHSCREEN_DA9052=m
CONFIG_TOUCHSCREEN_DYNAPRO=m
CONFIG_TOUCHSCREEN_HAMPSHIRE=m
CONFIG_TOUCHSCREEN_EETI=m
CONFIG_TOUCHSCREEN_FUJITSU=m
CONFIG_TOUCHSCREEN_ILI210X=m
CONFIG_TOUCHSCREEN_GUNZE=m
CONFIG_TOUCHSCREEN_ELO=m
CONFIG_TOUCHSCREEN_WACOM_W8001=m
# CONFIG_TOUCHSCREEN_WACOM_I2C is not set
CONFIG_TOUCHSCREEN_MAX11801=m
# CONFIG_TOUCHSCREEN_MCS5000 is not set
CONFIG_TOUCHSCREEN_MMS114=m
# CONFIG_TOUCHSCREEN_MTOUCH is not set
CONFIG_TOUCHSCREEN_INEXIO=m
# CONFIG_TOUCHSCREEN_MK712 is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
CONFIG_TOUCHSCREEN_TOUCHRIGHT=m
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
CONFIG_TOUCHSCREEN_PIXCIR=m
CONFIG_TOUCHSCREEN_WM831X=m
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_MC13783=m
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
CONFIG_TOUCHSCREEN_TSC_SERIO=m
CONFIG_TOUCHSCREEN_TSC2005=m
# CONFIG_TOUCHSCREEN_TSC2007 is not set
CONFIG_TOUCHSCREEN_PCAP=m
CONFIG_TOUCHSCREEN_ST1232=m
CONFIG_TOUCHSCREEN_SUR40=m
# CONFIG_TOUCHSCREEN_TPS6507X is not set
CONFIG_TOUCHSCREEN_ZFORCE=m
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=m
# CONFIG_SERIO_PARKBD is not set
CONFIG_SERIO_PCIPS2=m
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_GAMEPORT=m
CONFIG_GAMEPORT_NS558=m
CONFIG_GAMEPORT_L4=m
CONFIG_GAMEPORT_EMU10K1=m
# CONFIG_GAMEPORT_FM801 is not set

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
# CONFIG_SERIAL_CLPS711X is not set
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_MRST_MAX3110 is not set
# CONFIG_SERIAL_MFD_HSU is not set
# CONFIG_SERIAL_UARTLITE is not set
# CONFIG_SERIAL_SH_SCI is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_ST_ASC is not set
# CONFIG_TTY_PRINTK is not set
# CONFIG_PRINTER is not set
CONFIG_PPDEV=m
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=m
# CONFIG_HW_RANDOM_VIA is not set
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=m
CONFIG_NVRAM=m
# CONFIG_R3964 is not set
CONFIG_APPLICOM=m

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=m
CONFIG_CARDMAN_4040=m
# CONFIG_IPWIRELESS is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=m
CONFIG_TCG_TIS=m
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=m
# CONFIG_TCG_ATMEL is not set
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_ST33_I2C=m
CONFIG_TELCLOCK=m
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=m
CONFIG_I2C_MUX_PCA9541=m
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=m
# CONFIG_I2C_ALI15X3 is not set
CONFIG_I2C_AMD756=y
# CONFIG_I2C_AMD756_S4882 is not set
CONFIG_I2C_AMD8111=y
# CONFIG_I2C_I801 is not set
CONFIG_I2C_ISCH=y
# CONFIG_I2C_ISMT is not set
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=y
# CONFIG_I2C_NFORCE2_S4985 is not set
# CONFIG_I2C_SIS5595 is not set
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=m
CONFIG_I2C_DESIGNWARE_PLATFORM=m
CONFIG_I2C_DESIGNWARE_PCI=m
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_GPIO=m
CONFIG_I2C_KEMPLD=m
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_RIIC=y
CONFIG_I2C_SH_MOBILE=y
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set
CONFIG_I2C_RCAR=m

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=m
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=m
CONFIG_I2C_VIPERBOARD=m

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_STUB=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
# CONFIG_SPI_ATMEL is not set
# CONFIG_SPI_BCM2835 is not set
CONFIG_SPI_BCM63XX_HSSPI=y
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=m
CONFIG_SPI_EP93XX=m
# CONFIG_SPI_GPIO is not set
# CONFIG_SPI_IMX is not set
# CONFIG_SPI_LM70_LLP is not set
CONFIG_SPI_FSL_DSPI=y
# CONFIG_SPI_OC_TINY is not set
CONFIG_SPI_TI_QSPI=m
CONFIG_SPI_OMAP_100K=y
# CONFIG_SPI_ORION is not set
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
CONFIG_SPI_SC18IS602=m
CONFIG_SPI_SH=m
CONFIG_SPI_SH_HSPI=m
CONFIG_SPI_SUN4I=m
# CONFIG_SPI_SUN6I is not set
CONFIG_SPI_TEGRA114=m
CONFIG_SPI_TEGRA20_SFLASH=y
CONFIG_SPI_TEGRA20_SLINK=m
# CONFIG_SPI_TOPCLIFF_PCH is not set
CONFIG_SPI_TXX9=m
CONFIG_SPI_XCOMM=m
CONFIG_SPI_XILINX=m
CONFIG_SPI_DESIGNWARE=y
CONFIG_SPI_DW_PCI=m
CONFIG_SPI_DW_MMIO=m

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
# CONFIG_SPI_TLE62X0 is not set
# CONFIG_SPMI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI clients
#
CONFIG_HSI_CHAR=m

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
CONFIG_NTP_PPS=y

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=m
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=m
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
CONFIG_PTP_1588_CLOCK_PCH=m
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
CONFIG_DEBUG_GPIO=y
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=m
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_CLPS711X=m
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_IT8761E is not set
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_SCH311X=m
CONFIG_GPIO_TS5500=y
CONFIG_GPIO_SCH=y
CONFIG_GPIO_ICH=y
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
CONFIG_GPIO_ARIZONA=m
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=m
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_TPS65912 is not set
CONFIG_GPIO_TWL4030=m
# CONFIG_GPIO_TWL6040 is not set
# CONFIG_GPIO_WM831X is not set
CONFIG_GPIO_WM8994=y
# CONFIG_GPIO_ADP5588 is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_CS5535 is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_INTEL_MID is not set
CONFIG_GPIO_PCH=y
CONFIG_GPIO_ML_IOH=m
# CONFIG_GPIO_TIMBERDALE is not set
CONFIG_GPIO_RDC321X=m

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MC33880=m

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#
CONFIG_GPIO_KEMPLD=m

#
# MODULbus GPIO expanders:
#
# CONFIG_GPIO_JANZ_TTL is not set
# CONFIG_GPIO_PALMAS is not set
CONFIG_GPIO_TPS65910=y

#
# USB GPIO expanders:
#
CONFIG_GPIO_VIPERBOARD=m
CONFIG_W1=m
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=m
CONFIG_W1_MASTER_DS2490=m
CONFIG_W1_MASTER_DS2482=m
CONFIG_W1_MASTER_MXC=m
CONFIG_W1_MASTER_DS1WM=m
CONFIG_W1_MASTER_GPIO=m

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=m
CONFIG_W1_SLAVE_SMEM=m
CONFIG_W1_SLAVE_DS2408=m
CONFIG_W1_SLAVE_DS2408_READBACK=y
CONFIG_W1_SLAVE_DS2413=m
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=m
CONFIG_W1_SLAVE_DS2433=m
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2760=m
CONFIG_W1_SLAVE_DS2780=m
CONFIG_W1_SLAVE_DS2781=m
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=m
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_MAX8925_POWER is not set
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_DA9030 is not set
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_PCF50633 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_TWL4030 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_MAX14577 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_CHARGER_TPS65090 is not set
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=m
CONFIG_HWMON_VID=m
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=m
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7X10=m
CONFIG_SENSORS_ADT7310=m
CONFIG_SENSORS_ADT7410=m
CONFIG_SENSORS_ADT7411=m
CONFIG_SENSORS_ADT7462=m
CONFIG_SENSORS_ADT7470=m
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_K8TEMP=m
# CONFIG_SENSORS_K10TEMP is not set
CONFIG_SENSORS_FAM15H_POWER=m
CONFIG_SENSORS_APPLESMC=m
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=m
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_DA9052_ADC=m
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=m
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_MC13783_ADC=m
CONFIG_SENSORS_FSCHMD=m
CONFIG_SENSORS_GL518SM=m
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_G760A=m
CONFIG_SENSORS_G762=m
CONFIG_SENSORS_GPIO_FAN=m
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_CORETEMP=m
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=m
CONFIG_SENSORS_LINEAGE=m
# CONFIG_SENSORS_LTC2945 is not set
CONFIG_SENSORS_LTC4151=m
CONFIG_SENSORS_LTC4215=m
CONFIG_SENSORS_LTC4222=m
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=m
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_MAX1111=m
# CONFIG_SENSORS_MAX16065 is not set
# CONFIG_SENSORS_MAX1619 is not set
CONFIG_SENSORS_MAX1668=m
CONFIG_SENSORS_MAX197=m
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_HTU21 is not set
CONFIG_SENSORS_MCP3021=m
CONFIG_SENSORS_ADCXX=m
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM70 is not set
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=m
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_NTC_THERMISTOR=m
CONFIG_SENSORS_NCT6775=m
CONFIG_SENSORS_PCF8591=m
CONFIG_PMBUS=m
# CONFIG_SENSORS_PMBUS is not set
CONFIG_SENSORS_ADM1275=m
CONFIG_SENSORS_LM25066=m
CONFIG_SENSORS_LTC2978=m
# CONFIG_SENSORS_MAX16064 is not set
CONFIG_SENSORS_MAX34440=m
CONFIG_SENSORS_MAX8688=m
# CONFIG_SENSORS_UCD9000 is not set
CONFIG_SENSORS_UCD9200=m
# CONFIG_SENSORS_ZL6100 is not set
CONFIG_SENSORS_SHT15=m
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=m
CONFIG_SENSORS_EMC1403=m
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=m
CONFIG_SENSORS_SCH5627=m
# CONFIG_SENSORS_SCH5636 is not set
CONFIG_SENSORS_SMM665=m
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=m
CONFIG_SENSORS_ADS7828=m
# CONFIG_SENSORS_ADS7871 is not set
CONFIG_SENSORS_AMC6821=m
CONFIG_SENSORS_INA209=m
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=m
CONFIG_SENSORS_TMP102=m
# CONFIG_SENSORS_TMP401 is not set
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_VIA_CPUTEMP=m
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
CONFIG_SENSORS_VT8231=m
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=m
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=m
# CONFIG_SENSORS_W83795 is not set
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_WM831X is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_RCAR_THERMAL is not set
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
# CONFIG_SOFT_WATCHDOG is not set
CONFIG_DA9052_WATCHDOG=y
CONFIG_WM831X_WATCHDOG=m
CONFIG_XILINX_WATCHDOG=m
CONFIG_DW_WATCHDOG=y
# CONFIG_TWL4030_WATCHDOG is not set
# CONFIG_TEGRA_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
CONFIG_F71808E_WDT=y
CONFIG_SP5100_TCO=y
CONFIG_GEODE_WDT=m
# CONFIG_SC520_WDT is not set
CONFIG_SBC_FITPC2_WATCHDOG=m
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=m
CONFIG_I6300ESB_WDT=y
CONFIG_IE6XX_WDT=y
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=m
CONFIG_IT87_WDT=m
CONFIG_HP_WATCHDOG=y
CONFIG_KEMPLD_WDT=m
# CONFIG_HPWDT_NMI_DECODING is not set
CONFIG_SC1200_WDT=m
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
CONFIG_SBC8360_WDT=m
CONFIG_CPU5_WDT=m
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=m
CONFIG_VIA_WDT=m
CONFIG_W83627HF_WDT=y
CONFIG_W83697HF_WDT=y
CONFIG_W83697UG_WDT=m
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=m
CONFIG_MACHZ_WDT=m
CONFIG_SBC_EPX_C3_WATCHDOG=m
CONFIG_MEN_A21_WDT=y

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=m
CONFIG_WDTPCI=m

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_B43_PCI_BRIDGE=y
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=m
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
CONFIG_BCMA_DRIVER_GPIO=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9063=y
CONFIG_MFD_MC13XXX=m
CONFIG_MFD_MC13XXX_SPI=m
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_MFD_JANZ_CMODIO=y
CONFIG_MFD_KEMPLD=m
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=m
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
CONFIG_EZX_PCAP=y
CONFIG_MFD_VIPERBOARD=m
# CONFIG_MFD_RETU is not set
CONFIG_MFD_PCF50633=m
CONFIG_PCF50633_ADC=m
# CONFIG_PCF50633_GPIO is not set
CONFIG_MFD_RDC321X=m
CONFIG_MFD_RTSX_PCI=m
# CONFIG_MFD_RTSX_USB is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SMSC=y
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
# CONFIG_AB3100_OTP is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_PALMAS=y
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=m
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=m
CONFIG_MFD_TPS65218=m
# CONFIG_MFD_TPS6586X is not set
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS65912_SPI is not set
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
# CONFIG_TWL4030_MADC is not set
# CONFIG_MFD_TWL4030_AUDIO is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=m
# CONFIG_MFD_LM3533 is not set
CONFIG_MFD_TIMBERDALE=m
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=m
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=m
CONFIG_MFD_ARIZONA_SPI=y
CONFIG_MFD_WM5102=y
# CONFIG_MFD_WM5110 is not set
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=m
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
# CONFIG_REGULATOR_AB3100 is not set
# CONFIG_REGULATOR_DA903X is not set
# CONFIG_REGULATOR_DA9052 is not set
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_FAN53555=m
CONFIG_REGULATOR_GPIO=m
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=m
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP8755=m
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=m
CONFIG_REGULATOR_MAX8649=m
# CONFIG_REGULATOR_MAX8660 is not set
# CONFIG_REGULATOR_MAX8907 is not set
# CONFIG_REGULATOR_MAX8925 is not set
# CONFIG_REGULATOR_MAX8952 is not set
CONFIG_REGULATOR_MAX8973=y
# CONFIG_REGULATOR_MAX8997 is not set
# CONFIG_REGULATOR_MAX8998 is not set
CONFIG_REGULATOR_MC13XXX_CORE=m
CONFIG_REGULATOR_MC13783=m
# CONFIG_REGULATOR_MC13892 is not set
CONFIG_REGULATOR_PALMAS=y
# CONFIG_REGULATOR_PBIAS is not set
CONFIG_REGULATOR_PCAP=m
CONFIG_REGULATOR_PCF50633=m
# CONFIG_REGULATOR_PFUZE100 is not set
# CONFIG_REGULATOR_TPS51632 is not set
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS65090 is not set
# CONFIG_REGULATOR_TPS65217 is not set
CONFIG_REGULATOR_TPS6524X=m
CONFIG_REGULATOR_TPS65910=y
CONFIG_REGULATOR_TPS65912=m
CONFIG_REGULATOR_TPS80031=m
# CONFIG_REGULATOR_TWL4030 is not set
CONFIG_REGULATOR_WM831X=y
CONFIG_REGULATOR_WM8400=m
# CONFIG_REGULATOR_WM8994 is not set
CONFIG_MEDIA_SUPPORT=m

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
# CONFIG_MEDIA_RADIO_SUPPORT is not set
CONFIG_MEDIA_RC_SUPPORT=y
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_V4L2=m
# CONFIG_VIDEO_ADV_DEBUG is not set
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_VIDEO_TUNER=m
CONFIG_V4L2_MEM2MEM_DEV=m
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_DMA_SG=m
CONFIG_VIDEOBUF_VMALLOC=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_DMA_CONTIG=m
CONFIG_VIDEOBUF2_VMALLOC=m
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
CONFIG_RC_CORE=m
# CONFIG_RC_MAP is not set
# CONFIG_RC_DECODERS is not set
# CONFIG_RC_DEVICES is not set
CONFIG_MEDIA_USB_SUPPORT=y

#
# Webcam devices
#
CONFIG_USB_VIDEO_CLASS=m
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=m
# CONFIG_USB_M5602 is not set
CONFIG_USB_STV06XX=m
CONFIG_USB_GL860=m
CONFIG_USB_GSPCA_BENQ=m
CONFIG_USB_GSPCA_CONEX=m
# CONFIG_USB_GSPCA_CPIA1 is not set
CONFIG_USB_GSPCA_ETOMS=m
CONFIG_USB_GSPCA_FINEPIX=m
CONFIG_USB_GSPCA_JEILINJ=m
# CONFIG_USB_GSPCA_JL2005BCD is not set
# CONFIG_USB_GSPCA_KINECT is not set
CONFIG_USB_GSPCA_KONICA=m
# CONFIG_USB_GSPCA_MARS is not set
CONFIG_USB_GSPCA_MR97310A=m
CONFIG_USB_GSPCA_NW80X=m
# CONFIG_USB_GSPCA_OV519 is not set
CONFIG_USB_GSPCA_OV534=m
CONFIG_USB_GSPCA_OV534_9=m
# CONFIG_USB_GSPCA_PAC207 is not set
CONFIG_USB_GSPCA_PAC7302=m
# CONFIG_USB_GSPCA_PAC7311 is not set
CONFIG_USB_GSPCA_SE401=m
# CONFIG_USB_GSPCA_SN9C2028 is not set
# CONFIG_USB_GSPCA_SN9C20X is not set
CONFIG_USB_GSPCA_SONIXB=m
CONFIG_USB_GSPCA_SONIXJ=m
CONFIG_USB_GSPCA_SPCA500=m
CONFIG_USB_GSPCA_SPCA501=m
CONFIG_USB_GSPCA_SPCA505=m
# CONFIG_USB_GSPCA_SPCA506 is not set
# CONFIG_USB_GSPCA_SPCA508 is not set
# CONFIG_USB_GSPCA_SPCA561 is not set
# CONFIG_USB_GSPCA_SPCA1528 is not set
CONFIG_USB_GSPCA_SQ905=m
# CONFIG_USB_GSPCA_SQ905C is not set
CONFIG_USB_GSPCA_SQ930X=m
CONFIG_USB_GSPCA_STK014=m
CONFIG_USB_GSPCA_STK1135=m
# CONFIG_USB_GSPCA_STV0680 is not set
CONFIG_USB_GSPCA_SUNPLUS=m
CONFIG_USB_GSPCA_T613=m
CONFIG_USB_GSPCA_TOPRO=m
CONFIG_USB_GSPCA_TV8532=m
CONFIG_USB_GSPCA_VC032X=m
# CONFIG_USB_GSPCA_VICAM is not set
CONFIG_USB_GSPCA_XIRLINK_CIT=m
CONFIG_USB_GSPCA_ZC3XX=m
CONFIG_USB_PWC=m
CONFIG_USB_PWC_DEBUG=y
CONFIG_USB_PWC_INPUT_EVDEV=y
CONFIG_VIDEO_CPIA2=m
CONFIG_USB_ZR364XX=m
CONFIG_USB_STKWEBCAM=m
CONFIG_USB_S2255=m
# CONFIG_VIDEO_USBTV is not set

#
# Analog TV USB devices
#
CONFIG_VIDEO_PVRUSB2=m
# CONFIG_VIDEO_PVRUSB2_SYSFS is not set
CONFIG_VIDEO_HDPVR=m
CONFIG_VIDEO_USBVISION=m
CONFIG_VIDEO_STK1160_COMMON=m
CONFIG_VIDEO_STK1160=m

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_CX231XX=m
CONFIG_VIDEO_CX231XX_RC=y
CONFIG_VIDEO_TM6000=m

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=m
# CONFIG_VIDEO_EM28XX_V4L2 is not set
CONFIG_VIDEO_EM28XX_RC=m
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture support
#

#
# Media capture/analog TV support
#
# CONFIG_VIDEO_IVTV is not set
# CONFIG_VIDEO_ZORAN is not set
# CONFIG_VIDEO_HEXIUM_GEMINI is not set
CONFIG_VIDEO_HEXIUM_ORION=m
# CONFIG_VIDEO_MXB is not set

#
# Media capture/analog/hybrid TV support
#
# CONFIG_VIDEO_CX25821 is not set
CONFIG_VIDEO_CX88=m
# CONFIG_VIDEO_CX88_BLACKBIRD is not set
CONFIG_VIDEO_BT848=m
# CONFIG_VIDEO_SAA7134 is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
CONFIG_V4L_MEM2MEM_DRIVERS=y
CONFIG_VIDEO_SH_VEU=m
CONFIG_V4L_TEST_DRIVERS=y
CONFIG_VIDEO_VIVI=m
CONFIG_VIDEO_MEM2MEM_TESTDEV=m

#
# Supported MMC/SDIO adapters
#
CONFIG_MEDIA_PARPORT_SUPPORT=y
# CONFIG_VIDEO_BWQCAM is not set
CONFIG_VIDEO_CQCAM=m
CONFIG_VIDEO_CX2341X=m
CONFIG_VIDEO_BTCX=m
CONFIG_VIDEO_TVEEPROM=m
# CONFIG_CYPRESS_FIRMWARE is not set
CONFIG_VIDEO_SAA7146=m
CONFIG_VIDEO_SAA7146_VV=m

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set
CONFIG_MEDIA_ATTACH=y
CONFIG_VIDEO_IR_I2C=m

#
# Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=m
# CONFIG_VIDEO_TDA7432 is not set
CONFIG_VIDEO_TDA9840=m
# CONFIG_VIDEO_TEA6415C is not set
CONFIG_VIDEO_TEA6420=m
CONFIG_VIDEO_MSP3400=m
CONFIG_VIDEO_CS5345=m
CONFIG_VIDEO_CS53L32A=m
CONFIG_VIDEO_TLV320AIC23B=m
CONFIG_VIDEO_UDA1342=m
CONFIG_VIDEO_WM8775=m
CONFIG_VIDEO_WM8739=m
# CONFIG_VIDEO_VP27SMPX is not set
CONFIG_VIDEO_SONY_BTF_MPX=m

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

#
# Video decoders
#
CONFIG_VIDEO_ADV7180=m
CONFIG_VIDEO_ADV7183=m
CONFIG_VIDEO_BT819=m
CONFIG_VIDEO_BT856=m
CONFIG_VIDEO_BT866=m
# CONFIG_VIDEO_KS0127 is not set
CONFIG_VIDEO_ML86V7667=m
CONFIG_VIDEO_SAA7110=m
CONFIG_VIDEO_SAA711X=m
CONFIG_VIDEO_SAA7191=m
CONFIG_VIDEO_TVP514X=m
# CONFIG_VIDEO_TVP5150 is not set
# CONFIG_VIDEO_TVP7002 is not set
# CONFIG_VIDEO_TW2804 is not set
# CONFIG_VIDEO_TW9903 is not set
CONFIG_VIDEO_TW9906=m
CONFIG_VIDEO_VPX3220=m

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=m
CONFIG_VIDEO_CX25840=m

#
# Video encoders
#
# CONFIG_VIDEO_SAA7127 is not set
CONFIG_VIDEO_SAA7185=m
# CONFIG_VIDEO_ADV7170 is not set
CONFIG_VIDEO_ADV7175=m
CONFIG_VIDEO_ADV7343=m
CONFIG_VIDEO_ADV7393=m
# CONFIG_VIDEO_AK881X is not set
CONFIG_VIDEO_THS8200=m

#
# Camera sensor devices
#
CONFIG_VIDEO_OV7640=m
# CONFIG_VIDEO_OV7670 is not set
CONFIG_VIDEO_VS6624=m
CONFIG_VIDEO_MT9V011=m
CONFIG_VIDEO_SR030PC30=m

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=m
CONFIG_VIDEO_UPD64083=m

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=m

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=m
CONFIG_VIDEO_M52790=m

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=m

#
# Customize TV tuners
#
# CONFIG_MEDIA_TUNER_SIMPLE is not set
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA827X=m
CONFIG_MEDIA_TUNER_TDA18271=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=m
CONFIG_MEDIA_TUNER_TEA5767=m
# CONFIG_MEDIA_TUNER_MT20XX is not set
# CONFIG_MEDIA_TUNER_MT2060 is not set
CONFIG_MEDIA_TUNER_MT2063=m
# CONFIG_MEDIA_TUNER_MT2266 is not set
CONFIG_MEDIA_TUNER_MT2131=m
# CONFIG_MEDIA_TUNER_QT1010 is not set
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
# CONFIG_MEDIA_TUNER_XC4000 is not set
CONFIG_MEDIA_TUNER_MXL5005S=m
CONFIG_MEDIA_TUNER_MXL5007T=m
# CONFIG_MEDIA_TUNER_MC44S803 is not set
CONFIG_MEDIA_TUNER_MAX2165=m
# CONFIG_MEDIA_TUNER_TDA18218 is not set
CONFIG_MEDIA_TUNER_FC0011=m
CONFIG_MEDIA_TUNER_FC0012=m
CONFIG_MEDIA_TUNER_FC0013=m
CONFIG_MEDIA_TUNER_TDA18212=m
# CONFIG_MEDIA_TUNER_E4000 is not set
CONFIG_MEDIA_TUNER_FC2580=m
CONFIG_MEDIA_TUNER_M88TS2022=m
# CONFIG_MEDIA_TUNER_TUA9001 is not set
# CONFIG_MEDIA_TUNER_IT913X is not set
CONFIG_MEDIA_TUNER_R820T=m

#
# Customise DVB Frontends
#
# CONFIG_DVB_AU8522_V4L is not set
# CONFIG_DVB_TUNER_DIB0070 is not set
CONFIG_DVB_TUNER_DIB0090=m

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
# CONFIG_VGA_ARB is not set
# CONFIG_VGA_SWITCHEROO is not set

#
# Direct Rendering Manager
#
# CONFIG_DRM is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=m
CONFIG_FB_SVGALIB=m
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=y
CONFIG_FB_PM2=m
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
CONFIG_FB_CYBER2000=m
# CONFIG_FB_CYBER2000_DDC is not set
CONFIG_FB_ARC=m
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=m
CONFIG_FB_VESA=y
CONFIG_FB_N411=m
CONFIG_FB_HGA=m
CONFIG_FB_OPENCORES=m
# CONFIG_FB_S1D13XXX is not set
CONFIG_FB_NVIDIA=m
# CONFIG_FB_NVIDIA_I2C is not set
CONFIG_FB_NVIDIA_DEBUG=y
# CONFIG_FB_NVIDIA_BACKLIGHT is not set
CONFIG_FB_RIVA=y
# CONFIG_FB_RIVA_I2C is not set
# CONFIG_FB_RIVA_DEBUG is not set
CONFIG_FB_RIVA_BACKLIGHT=y
# CONFIG_FB_I740 is not set
CONFIG_FB_LE80578=m
# CONFIG_FB_CARILLO_RANCH is not set
CONFIG_FB_MATROX=y
CONFIG_FB_MATROX_MILLENIUM=y
CONFIG_FB_MATROX_MYSTIQUE=y
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=m
CONFIG_FB_MATROX_MAVEN=m
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=y
CONFIG_FB_ATY128_BACKLIGHT=y
# CONFIG_FB_ATY is not set
CONFIG_FB_S3=m
CONFIG_FB_S3_DDC=y
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=y
# CONFIG_FB_SIS_300 is not set
CONFIG_FB_SIS_315=y
CONFIG_FB_VIA=y
CONFIG_FB_VIA_DIRECT_PROCFS=y
CONFIG_FB_VIA_X_COMPATIBILITY=y
CONFIG_FB_NEOMAGIC=m
CONFIG_FB_KYRO=y
# CONFIG_FB_3DFX is not set
CONFIG_FB_VOODOO1=y
# CONFIG_FB_VT8623 is not set
CONFIG_FB_TRIDENT=m
# CONFIG_FB_ARK is not set
CONFIG_FB_PM3=m
CONFIG_FB_CARMINE=y
CONFIG_FB_CARMINE_DRAM_EVAL=y
# CONFIG_CARMINE_DRAM_CUSTOM is not set
CONFIG_FB_GEODE=y
CONFIG_FB_GEODE_LX=y
CONFIG_FB_GEODE_GX=m
CONFIG_FB_GEODE_GX1=y
CONFIG_FB_TMIO=y
CONFIG_FB_TMIO_ACCELL=y
CONFIG_FB_SMSCUFX=m
CONFIG_FB_UDL=m
CONFIG_FB_GOLDFISH=y
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=m
# CONFIG_FB_AUO_K190X is not set
# CONFIG_FB_SIMPLE is not set
CONFIG_EXYNOS_VIDEO=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_PWM=m
# CONFIG_BACKLIGHT_DA903X is not set
# CONFIG_BACKLIGHT_DA9052 is not set
# CONFIG_BACKLIGHT_MAX8925 is not set
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=m
# CONFIG_BACKLIGHT_WM831X is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=m
CONFIG_BACKLIGHT_PCF50633=m
# CONFIG_BACKLIGHT_LM3630A is not set
CONFIG_BACKLIGHT_LM3639=m
# CONFIG_BACKLIGHT_LP855X is not set
# CONFIG_BACKLIGHT_PANDORA is not set
# CONFIG_BACKLIGHT_TPS65217 is not set
CONFIG_BACKLIGHT_GPIO=y
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
CONFIG_VGASTATE=y
CONFIG_VIDEO_OUTPUT_CONTROL=y
# CONFIG_LOGO is not set
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
# CONFIG_SND is not set
CONFIG_SOUND_PRIME=m

#
# HID support
#
CONFIG_HID=m
CONFIG_HIDRAW=y
CONFIG_UHID=m
CONFIG_HID_GENERIC=m

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
CONFIG_HID_ACRUX=m
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=m
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
CONFIG_HID_CHICONY=m
# CONFIG_HID_CYPRESS is not set
CONFIG_HID_DRAGONRISE=m
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=m
# CONFIG_HID_ELECOM is not set
CONFIG_HID_EZKEY=m
CONFIG_HID_KEYTOUCH=m
CONFIG_HID_KYE=m
CONFIG_HID_UCLOGIC=m
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=m
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=m
CONFIG_HID_LCPOWER=m
CONFIG_HID_LENOVO_TPKBD=m
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=m
CONFIG_HID_MICROSOFT=m
# CONFIG_HID_MONTEREY is not set
CONFIG_HID_MULTITOUCH=m
CONFIG_HID_ORTEK=m
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=m
CONFIG_HID_PICOLCD=m
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LEDS=y
# CONFIG_HID_PICOLCD_CIR is not set
# CONFIG_HID_PRIMAX is not set
CONFIG_HID_SAITEK=m
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SPEEDLINK=m
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=m
# CONFIG_HID_GREENASIA is not set
CONFIG_HID_SMARTJOYPLUS=m
CONFIG_SMARTJOYPLUS_FF=y
CONFIG_HID_TIVO=m
# CONFIG_HID_TOPSEED is not set
CONFIG_HID_THINGM=m
CONFIG_HID_THRUSTMASTER=m
CONFIG_THRUSTMASTER_FF=y
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
CONFIG_HID_XINMO=m
CONFIG_HID_ZEROPLUS=m
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=m
CONFIG_HID_SENSOR_HUB=m

#
# USB HID support
#
# CONFIG_USB_HID is not set
# CONFIG_HID_PID is not set

#
# USB HID Boot Protocol drivers
#
# CONFIG_USB_KBD is not set
CONFIG_USB_MOUSE=m

#
# I2C HID support
#
CONFIG_I2C_HID=m
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=m
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=m
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG=y
CONFIG_USB_OTG_WHITELIST=y
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
CONFIG_USB_MON=m
CONFIG_USB_WUSB=m
CONFIG_USB_WUSB_CBAF=m
CONFIG_USB_WUSB_CBAF_DEBUG=y

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_XHCI_HCD=m
CONFIG_USB_XHCI_PLATFORM=m
CONFIG_USB_EHCI_HCD=m
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=m
CONFIG_USB_EHCI_HCD_PLATFORM=m
CONFIG_USB_OXU210HP_HCD=m
# CONFIG_USB_ISP116X_HCD is not set
CONFIG_USB_ISP1760_HCD=m
CONFIG_USB_ISP1362_HCD=m
# CONFIG_USB_FUSBH200_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_OHCI_HCD=m
# CONFIG_USB_OHCI_HCD_PCI is not set
# CONFIG_USB_OHCI_HCD_SSB is not set
CONFIG_USB_OHCI_HCD_PLATFORM=m
CONFIG_USB_UHCI_HCD=m
CONFIG_USB_SL811_HCD=m
CONFIG_USB_SL811_HCD_ISO=y
CONFIG_USB_SL811_CS=m
CONFIG_USB_R8A66597_HCD=m
# CONFIG_USB_WHCI_HCD is not set
# CONFIG_USB_HWA_HCD is not set
CONFIG_USB_HCD_BCMA=m
CONFIG_USB_HCD_SSB=m
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=m
CONFIG_USB_WDM=m
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
# CONFIG_USB_STORAGE is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
# CONFIG_USB_MUSB_HDRC is not set
CONFIG_USB_DWC3=m
CONFIG_USB_DWC3_HOST=y

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_OMAP=m
CONFIG_USB_DWC3_EXYNOS=m
CONFIG_USB_DWC3_PCI=m
CONFIG_USB_DWC3_KEYSTONE=m

#
# Debugging features
#
# CONFIG_USB_DWC3_DEBUG is not set
CONFIG_USB_DWC2=m
# CONFIG_USB_DWC2_DEBUG is not set
CONFIG_USB_DWC2_TRACK_MISSED_SOFS=y
# CONFIG_USB_CHIPIDEA is not set

#
# USB port drivers
#
CONFIG_USB_USS720=m
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
CONFIG_USB_RIO500=m
CONFIG_USB_LEGOTOWER=m
# CONFIG_USB_LCD is not set
CONFIG_USB_LED=m
CONFIG_USB_CYPRESS_CY7C63=m
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_IDMOUSE=m
# CONFIG_USB_FTDI_ELAN is not set
CONFIG_USB_APPLEDISPLAY=m
CONFIG_USB_SISUSBVGA=m
CONFIG_USB_LD=m
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
CONFIG_USB_EHSET_TEST_FIXTURE=m
CONFIG_USB_ISIGHTFW=m
CONFIG_USB_YUREX=m
CONFIG_USB_EZUSB_FX2=m
# CONFIG_USB_HSIC_USB3503 is not set
CONFIG_USB_ATM=m
CONFIG_USB_SPEEDTOUCH=m
CONFIG_USB_CXACRU=m
# CONFIG_USB_UEAGLEATM is not set
CONFIG_USB_XUSBATM=m

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_USB_OTG_FSM=m
CONFIG_KEYSTONE_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_OMAP_CONTROL_USB=y
# CONFIG_OMAP_USB3 is not set
# CONFIG_AM335X_PHY_USB is not set
CONFIG_SAMSUNG_USBPHY=m
CONFIG_SAMSUNG_USB2PHY=m
CONFIG_SAMSUNG_USB3PHY=m
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_RCAR_PHY=m
CONFIG_USB_RCAR_GEN2_PHY=m
# CONFIG_USB_GADGET is not set
CONFIG_UWB=y
CONFIG_UWB_HWA=m
# CONFIG_UWB_WHCI is not set
CONFIG_UWB_I1480U=m
CONFIG_MMC=m
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_MMC_BLOCK_BOUNCE=y
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=m

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=m
CONFIG_MMC_SDHCI_PCI=m
CONFIG_MMC_RICOH_MMC=y
# CONFIG_MMC_SDHCI_ACPI is not set
# CONFIG_MMC_SDHCI_PLTFM is not set
# CONFIG_MMC_OMAP_HS is not set
CONFIG_MMC_TIFM_SD=m
# CONFIG_MMC_SPI is not set
CONFIG_MMC_SDRICOH_CS=m
CONFIG_MMC_CB710=m
CONFIG_MMC_VIA_SDMMC=m
CONFIG_MMC_SH_MMCIF=m
CONFIG_MMC_VUB300=m
CONFIG_MMC_USHC=m
CONFIG_MMC_REALTEK_PCI=m
CONFIG_MEMSTICK=m
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
# CONFIG_MSPRO_BLOCK is not set
CONFIG_MS_BLOCK=m

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
CONFIG_MEMSTICK_JMICRON_38X=m
# CONFIG_MEMSTICK_R592 is not set
CONFIG_MEMSTICK_REALTEK_PCI=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=m

#
# LED drivers
#
CONFIG_LEDS_LM3530=m
CONFIG_LEDS_LM3642=m
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=m
CONFIG_LEDS_LP55XX_COMMON=m
CONFIG_LEDS_LP5521=m
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_LP5562 is not set
CONFIG_LEDS_LP8501=m
CONFIG_LEDS_CLEVO_MAIL=m
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
CONFIG_LEDS_PCA9685=m
CONFIG_LEDS_WM831X_STATUS=m
# CONFIG_LEDS_DA903X is not set
# CONFIG_LEDS_DA9052 is not set
CONFIG_LEDS_DAC124S085=m
CONFIG_LEDS_PWM=m
CONFIG_LEDS_REGULATOR=m
CONFIG_LEDS_BD2802=m
CONFIG_LEDS_INTEL_SS4200=m
CONFIG_LEDS_LT3593=m
CONFIG_LEDS_MC13783=m
CONFIG_LEDS_TCA6507=m
CONFIG_LEDS_MAX8997=m
# CONFIG_LEDS_LM355x is not set
# CONFIG_LEDS_OT200 is not set
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
CONFIG_LEDS_TRIGGER_CPU=y
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=m
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_ACCESSIBILITY is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
# CONFIG_RTC_SYSTOHC is not set
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
# CONFIG_RTC_INTF_PROC is not set
# CONFIG_RTC_INTF_DEV is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_DS1307=m
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_DS3232=y
# CONFIG_RTC_DRV_MAX6900 is not set
CONFIG_RTC_DRV_MAX8907=y
# CONFIG_RTC_DRV_MAX8925 is not set
CONFIG_RTC_DRV_MAX8998=y
CONFIG_RTC_DRV_MAX8997=y
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=m
# CONFIG_RTC_DRV_ISL12022 is not set
# CONFIG_RTC_DRV_ISL12057 is not set
# CONFIG_RTC_DRV_X1205 is not set
CONFIG_RTC_DRV_PALMAS=y
CONFIG_RTC_DRV_PCF2127=y
# CONFIG_RTC_DRV_PCF8523 is not set
CONFIG_RTC_DRV_PCF8563=y
# CONFIG_RTC_DRV_PCF8583 is not set
CONFIG_RTC_DRV_M41T80=y
CONFIG_RTC_DRV_M41T80_WDT=y
# CONFIG_RTC_DRV_BQ32K is not set
CONFIG_RTC_DRV_TWL4030=y
# CONFIG_RTC_DRV_TPS65910 is not set
# CONFIG_RTC_DRV_TPS80031 is not set
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=m
CONFIG_RTC_DRV_RX8025=m
# CONFIG_RTC_DRV_EM3027 is not set
CONFIG_RTC_DRV_RV3029C2=m

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=y
# CONFIG_RTC_DRV_M41T94 is not set
# CONFIG_RTC_DRV_DS1305 is not set
# CONFIG_RTC_DRV_DS1390 is not set
# CONFIG_RTC_DRV_MAX6902 is not set
CONFIG_RTC_DRV_R9701=m
CONFIG_RTC_DRV_RS5C348=y
CONFIG_RTC_DRV_DS3234=m
# CONFIG_RTC_DRV_PCF2123 is not set
CONFIG_RTC_DRV_RX4581=m

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
CONFIG_RTC_DRV_DS1511=y
# CONFIG_RTC_DRV_DS1553 is not set
CONFIG_RTC_DRV_DS1742=m
CONFIG_RTC_DRV_DA9052=m
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=y
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
CONFIG_RTC_DRV_BQ4802=m
CONFIG_RTC_DRV_RP5C01=m
CONFIG_RTC_DRV_V3020=y
CONFIG_RTC_DRV_DS2404=y
# CONFIG_RTC_DRV_WM831X is not set
CONFIG_RTC_DRV_PCF50633=m
# CONFIG_RTC_DRV_AB3100 is not set

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_PCAP is not set
CONFIG_RTC_DRV_MC13XXX=m
CONFIG_RTC_DRV_MOXART=y

#
# HID Sensor RTC drivers
#
# CONFIG_DMADEVICES is not set
CONFIG_AUXDISPLAY=y
CONFIG_UIO=y
CONFIG_UIO_CIF=y
# CONFIG_UIO_PDRV_GENIRQ is not set
CONFIG_UIO_DMEM_GENIRQ=m
CONFIG_UIO_AEC=y
# CONFIG_UIO_SERCOS3 is not set
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
# CONFIG_UIO_MF624 is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=m
CONFIG_VIRTIO_MMIO=m
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
# CONFIG_CHROME_PLATFORMS is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y
# CONFIG_AMD_IOMMU is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=m

#
# Extcon Device Drivers
#
CONFIG_EXTCON_GPIO=m
# CONFIG_EXTCON_MAX14577 is not set
# CONFIG_EXTCON_MAX8997 is not set
# CONFIG_EXTCON_PALMAS is not set
CONFIG_MEMORY=y
# CONFIG_IIO is not set
CONFIG_NTB=m
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
# CONFIG_VME_TSI148 is not set

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=m

#
# VME Device Drivers
#
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_RENESAS_TPU is not set
# CONFIG_PWM_TWL is not set
# CONFIG_PWM_TWL_LED is not set
CONFIG_IPACK_BUS=m
CONFIG_BOARD_TPCI200=m
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
CONFIG_FMC=y
# CONFIG_FMC_FAKEDEV is not set
CONFIG_FMC_TRIVIAL=m
CONFIG_FMC_WRITE_EEPROM=y
# CONFIG_FMC_CHARDEV is not set

#
# PHY Subsystem
#
# CONFIG_GENERIC_PHY is not set
CONFIG_PHY_EXYNOS_MIPI_VIDEO=m
# CONFIG_POWERCAP is not set
CONFIG_MCB=m

#
# Firmware Drivers
#
CONFIG_EDD=m
CONFIG_EDD_OFF=y
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
CONFIG_DCDBAS=m
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
# CONFIG_GOOGLE_MEMCONSOLE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=m
CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
# CONFIG_EXT3_FS_XATTR is not set
# CONFIG_EXT4_FS is not set
CONFIG_JBD=m
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=m
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=m
CONFIG_REISERFS_CHECK=y
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
CONFIG_OCFS2_FS=m
CONFIG_OCFS2_FS_O2CB=m
# CONFIG_OCFS2_FS_STATS is not set
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
# CONFIG_BTRFS_FS is not set
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
# CONFIG_FILE_LOCKING is not set
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
# CONFIG_INOTIFY_USER is not set
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=m
CONFIG_QFMT_V1=m
CONFIG_QFMT_V2=m
CONFIG_QUOTACTL=y
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
CONFIG_FSCACHE_OBJECT_LIST=y
# CONFIG_CACHEFILES is not set

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
# CONFIG_MSDOS_FS is not set
# CONFIG_VFAT_FS is not set
CONFIG_NTFS_FS=m
CONFIG_NTFS_DEBUG=y
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
# CONFIG_PROC_PAGE_MONITOR is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=m
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
CONFIG_AFFS_FS=y
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
CONFIG_HFSPLUS_FS=y
# CONFIG_HFSPLUS_FS_POSIX_ACL is not set
CONFIG_BEFS_FS=m
# CONFIG_BEFS_DEBUG is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_LOGFS is not set
# CONFIG_CRAMFS is not set
CONFIG_SQUASHFS=y
# CONFIG_SQUASHFS_FILE_CACHE is not set
CONFIG_SQUASHFS_FILE_DIRECT=y
CONFIG_SQUASHFS_DECOMP_SINGLE=y
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
# CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set
# CONFIG_SQUASHFS_XATTR is not set
CONFIG_SQUASHFS_ZLIB=y
# CONFIG_SQUASHFS_LZO is not set
CONFIG_SQUASHFS_XZ=y
CONFIG_SQUASHFS_4K_DEVBLK_SIZE=y
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
# CONFIG_MINIX_FS is not set
CONFIG_OMFS_FS=y
CONFIG_HPFS_FS=m
# CONFIG_QNX4FS_FS is not set
CONFIG_QNX6FS_FS=m
CONFIG_QNX6FS_DEBUG=y
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_FTRACE is not set
CONFIG_PSTORE_RAM=m
CONFIG_SYSV_FS=m
# CONFIG_UFS_FS is not set
CONFIG_F2FS_FS=y
CONFIG_F2FS_STAT_FS=y
# CONFIG_F2FS_FS_XATTR is not set
# CONFIG_F2FS_CHECK_FS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=m
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=y
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=m
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_MAC_ROMAN=y
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=m
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=m
CONFIG_NLS_MAC_ROMANIAN=m
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y

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
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
CONFIG_DEBUG_OBJECTS_FREE=y
CONFIG_DEBUG_OBJECTS_TIMERS=y
CONFIG_DEBUG_OBJECTS_WORK=y
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_DEBUG_SLAB=y
# CONFIG_DEBUG_SLAB_LEAK is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_RB=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=m
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_DEBUG_SHIRQ=y

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
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
# CONFIG_PM_NOTIFIER_ERROR_INJECT is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_MAKE_REQUEST is not set
CONFIG_FAIL_IO_TIMEOUT=y
# CONFIG_FAIL_MMC_REQUEST is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
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
CONFIG_HAVE_FENTRY=y
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
# CONFIG_FUNCTION_GRAPH_TRACER is not set
# CONFIG_IRQSOFF_TRACER is not set
# CONFIG_SCHED_TRACER is not set
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_TRACER_SNAPSHOT=y
# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_STACK_TRACER=y
# CONFIG_BLK_DEV_IO_TRACE is not set
# CONFIG_KPROBE_EVENT is not set
# CONFIG_UPROBE_EVENT is not set
# CONFIG_PROBE_EVENTS is not set
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_RING_BUFFER_BENCHMARK=m
# CONFIG_RING_BUFFER_STARTUP_TEST is not set

#
# Runtime Testing
#
CONFIG_LKDTM=m
CONFIG_TEST_LIST_SORT=y
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
CONFIG_INTERVAL_TREE_TEST=m
CONFIG_PERCPU_TEST=m
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=m
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_BUILD_DOCSRC is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_TEST_MODULE is not set
CONFIG_TEST_USER_COPY=m
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA is not set
CONFIG_DEBUG_SET_MODULE_RONX=y
CONFIG_DEBUG_NX_TEST=m
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
CONFIG_IO_DELAY_NONE=y
CONFIG_DEFAULT_IO_DELAY_TYPE=3
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_NMI_SELFTEST is not set
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
# CONFIG_BIG_KEYS is not set
CONFIG_TRUSTED_KEYS=m
CONFIG_ENCRYPTED_KEYS=m
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
# CONFIG_SECURITY_NETWORK is not set
CONFIG_SECURITY_PATH=y
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
CONFIG_SECURITY_YAMA=y
# CONFIG_SECURITY_YAMA_STACKED is not set
# CONFIG_IMA is not set
# CONFIG_DEFAULT_SECURITY_YAMA is not set
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
CONFIG_CRYPTO_PCOMP=m
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
# CONFIG_CRYPTO_AUTHENC is not set
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
# CONFIG_CRYPTO_CMAC is not set
CONFIG_CRYPTO_HMAC=m
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
# CONFIG_CRYPTO_CRC32 is not set
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=m
CONFIG_CRYPTO_GHASH=m
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=m
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=m
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=m
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=m
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=m
CONFIG_CRYPTO_LZO=m
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=m
CONFIG_CRYPTO_USER_API=m
CONFIG_CRYPTO_USER_API_HASH=m
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=m
CONFIG_CRYPTO_DEV_PADLOCK_AES=m
CONFIG_CRYPTO_DEV_PADLOCK_SHA=m
# CONFIG_CRYPTO_DEV_CCP is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
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
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=m
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_CRC64_ECMA=y
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
# CONFIG_XZ_DEC_POWERPC is not set
CONFIG_XZ_DEC_IA64=y
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_FONT_SUPPORT=m
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--J2SCkAp4GZ/dPZZf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
