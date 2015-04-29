Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8E26B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 09:28:23 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so28413765pdb.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 06:28:23 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ha8si39436213pac.226.2015.04.29.06.28.21
        for <linux-mm@kvack.org>;
        Wed, 29 Apr 2015 06:28:22 -0700 (PDT)
Date: Wed, 29 Apr 2015 21:28:17 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mm/meminit] PANIC: early exception 06 rip 10:ffffffff811bfa9a error
 0 cr2 ffff88000fbff000
Message-ID: <20150429132817.GA10479@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: fengguang.wu@intel.com, LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma mm-defe=
rred-meminit-v6r1

commit 285c36ab5b3e59865a0f4d79f4c1758455e684f7
Author:     Mel Gorman <mgorman@suse.de>
AuthorDate: Mon Sep 29 14:54:01 2014 +0100
Commit:     Mel Gorman <mgorman@suse.de>
CommitDate: Wed Apr 22 19:48:15 2015 +0100

    mm: meminit: Reduce number of times pageblocks are set during struct pa=
ge init
   =20
    During parallel sturct page initialisation, ranges are checked for every
    PFN unnecessarily which increases boot times. This patch alters when the
    ranges are checked.
   =20
    Signed-off-by: Mel Gorman <mgorman@suse.de>

+------------------------------------------------+------------+------------=
+------------+
|                                                | 47391c7fae | 285c36ab5b =
| 87531bc9b8 |
+------------------------------------------------+------------+------------=
+------------+
| boot_successes                                 | 80         | 0          =
| 0          |
| boot_failures                                  | 2          | 20         =
| 12         |
| IP-Config:Auto-configuration_of_network_failed | 2          |            =
|            |
| PANIC:early_exception                          | 0          | 20         =
| 12         |
| BUG:kernel_boot_hang                           | 0          | 20         =
| 12         |
| backtrace:set_pageblock_migratetype            | 0          | 20         =
| 12         |
| backtrace:memmap_init_zone                     | 0          | 20         =
| 12         |
| backtrace:free_area_init_node                  | 0          | 20         =
| 12         |
| backtrace:free_area_init_nodes                 | 0          | 20         =
| 12         |
| backtrace:zone_sizes_init                      | 0          | 20         =
| 12         |
| backtrace:paging_init                          | 0          | 20         =
| 12         |
+------------------------------------------------+------------+------------=
+------------+

[    0.000000] page:ffffea0000040000 count:0 mapcount:1 mapping:          (=
null) index:0x0
[    0.000000] flags: 0x0()
[    0.000000] page dumped because: VM_BUG_ON_PAGE(!zone_spans_pfn(zone, pf=
n))
PANIC: early exception 06 rip 10:ffffffff811bfa9a error 0 cr2 ffff88000fbff=
000
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.0.0-00012-g285c36a=
 #5
[    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.7.5-20140531_083030-gandalf 04/01/2014
[    0.000000]  0000000000000002 ffffffff82003c40 ffffffff81937569 00000000=
000003f8
[    0.000000]  ffffea0000040000 ffffffff82003d08 ffffffff821ca1b0 5f4e4f5f=
4755425f
[    0.000000]  0000000000000001 0000000000000000 0000000000000001 00000000=
00000001
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff81937569>] dump_stack+0x4c/0x65
[    0.000000]  [<ffffffff821ca1b0>] early_idt_handler+0x90/0xb7
[    0.000000]  [<ffffffff811bfa9a>] ? set_pfnblock_flags_mask+0x12a/0x130
[    0.000000]  [<ffffffff811bfa9a>] ? set_pfnblock_flags_mask+0x12a/0x130
[    0.000000]  [<ffffffff811bfb0f>] set_pageblock_migratetype+0x6f/0x80
[    0.000000]  [<ffffffff82222386>] memmap_init_zone+0x97/0x160
[    0.000000]  [<ffffffff82222826>] free_area_init_node+0x3d7/0x3fe
[    0.000000]  [<ffffffff821ecc4f>] free_area_init_nodes+0x586/0x603
[    0.000000]  [<ffffffff821dd96d>] zone_sizes_init+0x50/0x52
[    0.000000]  [<ffffffff821dde05>] paging_init+0x28/0x2a
[    0.000000]  [<ffffffff821ce73c>] setup_arch+0x84b/0x8f8
[    0.000000]  [<ffffffff821ca120>] ? early_idt_handlers+0x120/0x120
[    0.000000]  [<ffffffff821cabb9>] start_kernel+0xa5/0x4c0
[    0.000000]  [<ffffffff821ca120>] ? early_idt_handlers+0x120/0x120
[    0.000000]  [<ffffffff821ca4b3>] x86_64_start_reservations+0x2a/0x2c
[    0.000000]  [<ffffffff821ca602>] x86_64_start_kernel+0x14d/0x15c
[    0.000000] RIP 0x1

BUG: kernel boot hang
Elapsed time: 305
qemu-system-x86_64 -enable-kvm -cpu Haswell,+smep,+smap -kernel /kernel/x86=
_64-randconfig-ib0-04102124/285c36ab5b3e59865a0f4d79f4c1758455e684f7/vmlinu=
z-4.0.0-00012-g285c36a -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115=
200 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log_lev=
el=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall=
_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3D=
panic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3D=
tty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x=
86_64-randconfig-ib0-04102124/linux-devel:devel-lkp-ib04-smoke-201504230337=
:285c36ab5b3e59865a0f4d79f4c1758455e684f7:bisect-linux/.vmlinuz-285c36ab5b3=
e59865a0f4d79f4c1758455e684f7-20150428075714-16-kbuild branch=3Dlinux-devel=
/devel-lkp-ib04-smoke-201504230337 BOOT_IMAGE=3D/kernel/x86_64-randconfig-i=
b0-04102124/285c36ab5b3e59865a0f4d79f4c1758455e684f7/vmlinuz-4.0.0-00012-g2=
85c36a drbd.minor_count=3D8'  -initrd /kernel-tests/initrd/yocto-minimal-x8=
6_64.cgz -m 256 -smp 1 -device e1000,netdev=3Dnet0 -netdev user,id=3Dnet0 -=
boot order=3Dnc -no-reboot -watchdog i6300esb -rtc base=3Dlocaltime -drive =
file=3D/fs/sdd1/disk0-yocto-kbuild-1,media=3Ddisk,if=3Dvirtio -drive file=
=3D/fs/sdd1/disk1-yocto-kbuild-1,media=3Ddisk,if=3Dvirtio -drive file=3D/fs=
/sdd1/disk2-yocto-kbuild-1,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/sdd1/=
disk3-yocto-kbuild-1,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/sdd1/disk4-=
yocto-kbuild-1,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/sdd1/disk5-yocto-=
kbuild-1,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/sdd1/disk6-yocto-kbuild=
-1,media=3Ddisk,if=3Dvirtio -pidfile /dev/shm/kboot/pid-yocto-kbuild-1 -ser=
ial file:/dev/shm/kboot/serial-yocto-kbuild-1 -daemonize -display none -mon=
itor null=20

git bisect start 87531bc9b8e14e27cafc72113e23a3dd8e329599 39a8804455fb23f09=
157341d3ba7db6d7ae6ee76 --
git bisect good ea9ffe871553dced04d763bf2c9495e9ff1aac94  # 03:50     20+  =
    2  Merge 'x86-mpx/mpx-v20' into devel-lkp-ib04-smoke-201504230337
git bisect  bad 89182f2be5924cad5707d8210c574c6857d4140c  # 04:07      0-  =
    3  Merge 'balancenuma/mm-deferred-meminit-v6r1' into devel-lkp-ib04-smo=
ke-201504230337
git bisect good 3a7731f195d77f95fa36918225bcd5823944923a  # 06:58     20+  =
    1  mm: meminit: Only a subset of struct pages if CONFIG_DEFERRED_STRUCT=
_PAGE_INIT is set
git bisect good 13c2e6e0490b55f5e2bda3a0461d112eade2d87a  # 07:51     20+  =
    0  x86: mm: Enable deferred struct page initialisation on x86-64
git bisect  bad 285c36ab5b3e59865a0f4d79f4c1758455e684f7  # 08:03      0-  =
    2  mm: meminit: Reduce number of times pageblocks are set during struct=
 page init
git bisect good 47391c7fae3df9cb332311c9fdd27917784496c5  # 09:05     20+  =
    2  mm: meminit: Free pages in large chunks where possible
# first bad commit: [285c36ab5b3e59865a0f4d79f4c1758455e684f7] mm: meminit:=
 Reduce number of times pageblocks are set during struct page init
git bisect good 47391c7fae3df9cb332311c9fdd27917784496c5  # 12:37     60+  =
    2  mm: meminit: Free pages in large chunks where possible
# extra tests with DEBUG_INFO
# extra tests on HEAD of linux-devel/devel-lkp-ib04-smoke-201504230337
git bisect  bad 87531bc9b8e14e27cafc72113e23a3dd8e329599  # 13:33      0-  =
   12  0day head guard for 'devel-lkp-ib04-smoke-201504230337'
# extra tests on tree/branch balancenuma/mm-deferred-meminit-v6r1
git bisect  bad 00f83fc5a6488216e3eabdb8fb34f72177c89beb  # 15:12      0-  =
    1  mm: meminit: Remove mminit_verify_page_links
# extra tests with first bad commit reverted
# extra tests on tree/branch linus/master
git bisect good 2decb2682f80759f631c8332f9a2a34a02150a03  # 23:44     60+  =
    0  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
# extra tests on tree/branch next/master
git bisect good 63382678150626a85e694031769496d58245d430  # 02:20     60+  =
    0  Add linux-next specific files for 20150428


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=3D$1

kvm=3D(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-m 256
	-smp 1
	-device e1000,netdev=3Dnet0
	-netdev user,id=3Dnet0
	-boot order=3Dnc
	-no-reboot
	-watchdog i6300esb
	-rtc base=3Dlocaltime
	-serial stdio
	-display none
	-monitor null=20
)

append=3D(
	hung_task_panic=3D1
	earlyprintk=3DttyS0,115200
	rd.udev.log-priority=3Derr
	systemd.log_target=3Djournal
	systemd.log_level=3Dwarning
	debug
	apic=3Ddebug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=3D100
	panic=3D-1
	softlockup_panic=3D1
	nmi_watchdog=3Dpanic
	oops=3Dpanic
	load_ramdisk=3D2
	prompt_ramdisk=3D0
	console=3DttyS0,115200
	console=3Dtty0
	vga=3Dnormal
	root=3D/dev/ram0
	rw
	drbd.minor_count=3D8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

Thanks,
Fengguang

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-yocto-kbuild-1:20150428002112:x86_64-randconfig-ib0-04102124:4.0.0-00012-g285c36a:5"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 4.0.0-00012-g285c36a (kbuild@lkp-ib04) (gcc ve=
rsion 4.9.2 (Debian 4.9.2-10) ) #5 SMP Tue Apr 28 07:55:51 CST 2015
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log_level=
=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_t=
imeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpa=
nic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtt=
y0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86=
_64-randconfig-ib0-04102124/linux-devel:devel-lkp-ib04-smoke-201504230337:2=
85c36ab5b3e59865a0f4d79f4c1758455e684f7:bisect-linux/.vmlinuz-285c36ab5b3e5=
9865a0f4d79f4c1758455e684f7-20150428075714-16-kbuild branch=3Dlinux-devel/d=
evel-lkp-ib04-smoke-201504230337 BOOT_IMAGE=3D/kernel/x86_64-randconfig-ib0=
-04102124/285c36ab5b3e59865a0f4d79f4c1758455e684f7/vmlinuz-4.0.0-00012-g285=
c36a drbd.minor_count=3D8
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000ffdffff] usable
[    0.000000] BIOS-e820: [mem 0x000000000ffe0000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-2014=
0531_083030-gandalf 04/01/2014
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] AGP: No AGP bridge found
[    0.000000] e820: last_pfn =3D 0xffe0 max_arch_pfn =3D 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0e90-0x000f0e9f] mapped at =
[ffff8800000f0e90]
[    0.000000]   mpc: f0ea0-f0fa8
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x031ab000, 0x031abfff] PGTABLE
[    0.000000] BRK [0x031ac000, 0x031acfff] PGTABLE
[    0.000000] BRK [0x031ad000, 0x031adfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0fa00000-0x0fbfffff]
[    0.000000]  [mem 0x0fa00000-0x0fbfffff] page 4k
[    0.000000] BRK [0x031ae000, 0x031aefff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0f9fffff]
[    0.000000]  [mem 0x00100000-0x0f9fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0ffdffff]
[    0.000000]  [mem 0x0fc00000-0x0ffdffff] page 4k
[    0.000000] BRK [0x031af000, 0x031affff] PGTABLE
[    0.000000] BRK [0x031b0000, 0x031b0fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x0fcce000-0x0ffd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0CB0 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000000FFE1854 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000000FFE0B37 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000000FFE0040 000AF7 (v01 BOCHS  BXPCDSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000000FFE0000 000040
[    0.000000] ACPI: SSDT 0x000000000FFE0BAB 000BF9 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000000FFE17A4 000078 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000000FFE181C 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000000ffdffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x0ffdb000-0x0ffdffff]
[    0.000000] cma: dma_contiguous_reserve(limit 0ffe0000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:ffda001, primary cpu clock
[    0.000000]  [ffffea0000000000-ffffea00003fffff] PMD -> [ffff88000ee0000=
0-ffff88000f1fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x000000000ffdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000000ffdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000000ffdf=
fff]
[    0.000000] On node 0 totalpages: 65406
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 960 pages used for memmap
[    0.000000]   DMA32 zone: 61408 pages, LIFO batch:15
[    0.000000] page:ffffea0000040000 count:0 mapcount:1 mapping:          (=
null) index:0x0
[    0.000000] flags: 0x0()
[    0.000000] page dumped because: VM_BUG_ON_PAGE(!zone_spans_pfn(zone, pf=
n))
PANIC: early exception 06 rip 10:ffffffff811bfa9a error 0 cr2 ffff88000fbff=
000
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.0.0-00012-g285c36a=
 #5
[    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.7.5-20140531_083030-gandalf 04/01/2014
[    0.000000]  0000000000000002 ffffffff82003c40 ffffffff81937569 00000000=
000003f8
[    0.000000]  ffffea0000040000 ffffffff82003d08 ffffffff821ca1b0 5f4e4f5f=
4755425f
[    0.000000]  0000000000000001 0000000000000000 0000000000000001 00000000=
00000001
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff81937569>] dump_stack+0x4c/0x65
[    0.000000]  [<ffffffff821ca1b0>] early_idt_handler+0x90/0xb7
[    0.000000]  [<ffffffff811bfa9a>] ? set_pfnblock_flags_mask+0x12a/0x130
[    0.000000]  [<ffffffff811bfa9a>] ? set_pfnblock_flags_mask+0x12a/0x130
[    0.000000]  [<ffffffff811bfb0f>] set_pageblock_migratetype+0x6f/0x80
[    0.000000]  [<ffffffff82222386>] memmap_init_zone+0x97/0x160
[    0.000000]  [<ffffffff82222826>] free_area_init_node+0x3d7/0x3fe
[    0.000000]  [<ffffffff821ecc4f>] free_area_init_nodes+0x586/0x603
[    0.000000]  [<ffffffff821dd96d>] zone_sizes_init+0x50/0x52
[    0.000000]  [<ffffffff821dde05>] paging_init+0x28/0x2a
[    0.000000]  [<ffffffff821ce73c>] setup_arch+0x84b/0x8f8
[    0.000000]  [<ffffffff821ca120>] ? early_idt_handlers+0x120/0x120
[    0.000000]  [<ffffffff821cabb9>] start_kernel+0xa5/0x4c0
[    0.000000]  [<ffffffff821ca120>] ? early_idt_handlers+0x120/0x120
[    0.000000]  [<ffffffff821ca4b3>] x86_64_start_reservations+0x2a/0x2c
[    0.000000]  [<ffffffff821ca602>] x86_64_start_kernel+0x14d/0x15c
[    0.000000] RIP 0x1

BUG: kernel boot hang
Elapsed time: 305
qemu-system-x86_64 -enable-kvm -cpu Haswell,+smep,+smap -kernel /kernel/x86=
_64-randconfig-ib0-04102124/285c36ab5b3e59865a0f4d79f4c1758455e684f7/vmlinu=
z-4.0.0-00012-g285c36a -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115=
200 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log_lev=
el=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall=
_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3D=
panic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3D=
tty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x=
86_64-randconfig-ib0-04102124/linux-devel:devel-lkp-ib04-smoke-201504230337=
:285c36ab5b3e59865a0f4d79f4c1758455e684f7:bisect-linux/.vmlinuz-285c36ab5b3=
e59865a0f4d79f4c1758455e684f7-20150428075714-16-kbuild branch=3Dlinux-devel=
/devel-lkp-ib04-smoke-201504230337 BOOT_IMAGE=3D/kernel/x86_64-randconfig-i=
b0-04102124/285c36ab5b3e59865a0f4d79f4c1758455e684f7/vmlinuz-4.0.0-00012-g2=
85c36a drbd.minor_count=3D8'  -initrd /kernel-tests/initrd/yocto-minimal-x8=
6_64.cgz -m 256 -smp 1 -device e1000,netdev=3Dnet0 -netdev user,id=3Dnet0 -=
boot order=3Dnc -no-reboot -watchdog i6300esb -rtc base=3Dlocaltime -drive =
file=3D/fs/sdd1/disk0-yocto-kbuild-1,media=3Ddisk,if=3Dvirtio -drive file=
=3D/fs/sdd1/disk1-yocto-kbuild-1,media=3Ddisk,if=3Dvirtio -drive file=3D/fs=
/sdd1/disk2-yocto-kbuild-1,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/sdd1/=
disk3-yocto-kbuild-1,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/sdd1/disk4-=
yocto-kbuild-1,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/sdd1/disk5-yocto-=
kbuild-1,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/sdd1/disk6-yocto-kbuild=
-1,media=3Ddisk,if=3Dvirtio -pidfile /dev/shm/kboot/pid-yocto-kbuild-1 -ser=
ial file:/dev/shm/kboot/serial-yocto-kbuild-1 -daemonize -display none -mon=
itor null=20

--bg08WKrSYDhXBjb5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
