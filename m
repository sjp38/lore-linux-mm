Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 729E26B0253
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:54:03 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id x125so24992796pfb.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 06:54:03 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ml7si17361144pab.58.2016.01.28.06.54.02
        for <linux-mm@kvack.org>;
        Thu, 28 Jan 2016 06:54:02 -0800 (PST)
Date: Thu, 28 Jan 2016 22:52:55 +0800
From: kernel test robot <fengguang.wu@intel.com>
Subject: [slab] a1fd55538c:  WARNING: CPU: 0 PID: 0 at
 kernel/locking/lockdep.c:2601 trace_hardirqs_on_caller()
Message-ID: <56aa2b47.MwdlkrzZ08oDKqh8%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_56aa2b47.57OidNqdxSWkF/GvABHXiVf1CFwf9jl2hhnx+8amWQJ6JN4W"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.orgLinux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com

This is a multi-part message in MIME format.

--=_56aa2b47.57OidNqdxSWkF/GvABHXiVf1CFwf9jl2hhnx+8amWQJ6JN4W
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit a1fd55538cae9f411059c9b067a3d48c41aa876b
Author:     Jesper Dangaard Brouer <brouer@redhat.com>
AuthorDate: Thu Jan 28 09:47:16 2016 +1100
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Thu Jan 28 09:47:16 2016 +1100

    slab: use slab_pre_alloc_hook in SLAB allocator shared with SLUB
    
    Deduplicate code in SLAB allocator functions slab_alloc() and
    slab_alloc_node() by using the slab_pre_alloc_hook() call, which is now
    shared between SLUB and SLAB.
    
    Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
    Cc: Christoph Lameter <cl@linux.com>
    Cc: Pekka Enberg <penberg@kernel.org>
    Cc: David Rientjes <rientjes@google.com>
    Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
    Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

+-----------------------------------------------------------------+------------+------------+---------------+
|                                                                 | 074b6f53c3 | a1fd55538c | next-20160128 |
+-----------------------------------------------------------------+------------+------------+---------------+
| boot_successes                                                  | 40         | 0          | 0             |
| boot_failures                                                   | 52         | 26         | 19            |
| Kernel_panic-not_syncing:Attempted_to_kill_init!exitcode=       | 52         | 26         | 14            |
| WARNING:at_kernel/locking/lockdep.c:#trace_hardirqs_on_caller() | 0          | 26         | 19            |
| backtrace:pcpu_mem_zalloc                                       | 0          | 26         | 19            |
| backtrace:percpu_init_late                                      | 0          | 26         | 19            |
| IP-Config:Auto-configuration_of_network_failed                  | 0          | 0          | 2             |
+-----------------------------------------------------------------+------------+------------+---------------+

[    0.000000] Inode-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.000000] Memory: 194224K/261624K available (10816K kernel code, 5060K rwdata, 6628K rodata, 988K init, 33076K bss, 67400K reserved, 0K cma-reserved)
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: CPU: 0 PID: 0 at kernel/locking/lockdep.c:2601 trace_hardirqs_on_caller+0x341/0x380()
[    0.000000] DEBUG_LOCKS_WARN_ON(unlikely(early_boot_irqs_disabled))
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.5.0-rc1-00069-ga1fd555 #1
[    0.000000]  ffffffff82403dd8 ffffffff82403d90 ffffffff813b937d ffffffff82403dc8
[    0.000000]  ffffffff810eb4d3 ffffffff812617cc 0000000000000001 ffff88000fcc50a8
[    0.000000]  ffff8800000984c0 00000000024000c0 ffffffff82403e28 ffffffff810eb5c7
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff813b937d>] dump_stack+0x27/0x3a
[    0.000000]  [<ffffffff810eb4d3>] warn_slowpath_common+0xa3/0x100
[    0.000000]  [<ffffffff812617cc>] ? cache_alloc_refill+0x7ac/0x910
[    0.000000]  [<ffffffff810eb5c7>] warn_slowpath_fmt+0x57/0x70
[    0.000000]  [<ffffffff81143e61>] trace_hardirqs_on_caller+0x341/0x380
[    0.000000]  [<ffffffff81143ebd>] trace_hardirqs_on+0x1d/0x30
[    0.000000]  [<ffffffff812617cc>] cache_alloc_refill+0x7ac/0x910
[    0.000000]  [<ffffffff8121df6a>] ? pcpu_mem_zalloc+0x5a/0xc0
[    0.000000]  [<ffffffff81261fce>] __kmalloc+0x24e/0x440
[    0.000000]  [<ffffffff8121df6a>] pcpu_mem_zalloc+0x5a/0xc0
[    0.000000]  [<ffffffff829213aa>] percpu_init_late+0x4d/0xbb
[    0.000000]  [<ffffffff828f41c9>] start_kernel+0x30b/0x6e1
[    0.000000]  [<ffffffff828f3120>] ? early_idt_handler_array+0x120/0x120
[    0.000000]  [<ffffffff828f332f>] x86_64_start_reservations+0x46/0x4f
[    0.000000]  [<ffffffff828f34d4>] x86_64_start_kernel+0x19c/0x1b2
[    0.000000] ---[ end trace cb88537fdc8fa200 ]---
[    0.000000] Running RCU self tests

git bisect start 888c8375131656144c1605071eab2eb6ac49abc3 92e963f50fc74041b5e9e744c330dca48e04f08d --
git bisect good f664e02a71d85691fc33f116bae3eb7f0debd194  # 17:19     17+     13  Merge remote-tracking branch 'kbuild/for-next'
git bisect good c7173552fb5efc15dd092d3a90b5d6ad0f3d9421  # 17:35     17+      2  Merge remote-tracking branch 'audit/next'
git bisect good bd605d2e3cc724606fa7c0fd3d5d90276f07e979  # 17:47     17+      2  Merge remote-tracking branch 'extcon/extcon-next'
git bisect good 108776431802ced1ca8ba38a9765ef81c48513de  # 18:06     17+      5  Merge remote-tracking branch 'llvmlinux/for-next'
git bisect good 56f1389517d2470a8abdb661c97d6ef640ca8cf3  # 18:30     17+      3  Merge remote-tracking branch 'coresight/next'
git bisect  bad 3cb196d8ee7f94b78c3d609bb91f5b175b3841d8  # 19:17      0-      8  Merge branch 'akpm-current/current'
git bisect good 49d5623e2407b26b532ca24f49d778b5b6fedb22  # 19:48     22+      0  Merge remote-tracking branch 'rtc/rtc-next'
git bisect  bad 8ccfb34d7450299714a9a590a764934397a818c6  # 20:06      0-     22  mm: filemap: avoid unnecessary calls to lock_page when waiting for IO to complete during a read
git bisect good d9dc8f2de4f863bef9a303b2cbae0bbd1c9dfceb  # 20:32     22+     22  ocfs2: add feature document for online file check
git bisect  bad ebea6ceb9754b02bcab987af96c64782c665aa91  # 20:56      0-     18  mm/slab: remove object status buffer for DEBUG_SLAB_LEAK
git bisect  bad 24d88722c03b13ef63b3b631f81454a63ac26cc4  # 21:06      0-     22  mm: kmemcheck skip object if slab allocation failed
git bisect good 1fc2d06fe0cfca10e571e2e444a4a37693495502  # 21:26     22+     22  ocfs2/dlm: move lock to the tail of grant queue while doing in-place convert
git bisect good 3355ee84b3d96c7c30923d0bba228b0b7aa380d2  # 21:33     21+      8  slub: cleanup code for kmem cgroup support to kmem_cache_free_bulk
git bisect good 074b6f53c320a81e975c0b5dd79daa5e78a711ba  # 21:39     22+     24  mm: fault-inject take over bootstrap kmem_cache check
git bisect  bad a1fd55538cae9f411059c9b067a3d48c41aa876b  # 21:49      0-     26  slab: use slab_pre_alloc_hook in SLAB allocator shared with SLUB
# first bad commit: [a1fd55538cae9f411059c9b067a3d48c41aa876b] slab: use slab_pre_alloc_hook in SLAB allocator shared with SLUB
git bisect good 074b6f53c320a81e975c0b5dd79daa5e78a711ba  # 21:53     66+     52  mm: fault-inject take over bootstrap kmem_cache check
# extra tests with DEBUG_INFO
git bisect  bad a1fd55538cae9f411059c9b067a3d48c41aa876b  # 22:00      0-     36  slab: use slab_pre_alloc_hook in SLAB allocator shared with SLUB
# extra tests on HEAD of linux-next/master
git bisect  bad 888c8375131656144c1605071eab2eb6ac49abc3  # 22:00      0-     19  Add linux-next specific files for 20160128
# extra tests on tree/branch linux-next/master
git bisect  bad 888c8375131656144c1605071eab2eb6ac49abc3  # 22:00      0-     19  Add linux-next specific files for 20160128
# extra tests with first bad commit reverted
git bisect good fea4cd9180f321dd12ec9a7932a9bfb32bfaf4c4  # 22:32     66+     30  Revert "slab: use slab_pre_alloc_hook in SLAB allocator shared with SLUB"
# extra tests on tree/branch linus/master
git bisect good 03c21cb775a313f1ff19be59c5d02df3e3526471  # 22:52     65+     67  Merge tag 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost
# extra tests on tree/branch linux-next/master
git bisect  bad 888c8375131656144c1605071eab2eb6ac49abc3  # 22:52      0-     19  Add linux-next specific files for 20160128


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1
initrd=yocto-minimal-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-initrd $initrd
	-m 256
	-smp 1
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null 
)

append=(
	hung_task_panic=1
	earlyprintk=ttyS0,115200
	systemd.log_level=err
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
	drbd.minor_count=8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_56aa2b47.57OidNqdxSWkF/GvABHXiVf1CFwf9jl2hhnx+8amWQJ6JN4W
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="dmesg-yocto-kbuild-31:20160128214601:x86_64-randconfig-s2-01281631:4.5.0-rc1-00069-ga1fd555:1"

early console in setup code
Probing EDD (edd=3Doff to disable)... ok
[    0.000000] Linux version 4.5.0-rc1-00069-ga1fd555 (kbuild@lkp-ib03)=
 (gcc version 5.2.1 20150911 (Debian 5.2.1-17) ) #1 Thu Jan 28 21:47:49=
 CST 2016
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,11=
5200 systemd.log_level=3Derr debug apic=3Ddebug sysrq_always_enabled rc=
update.rcu_cpu_stall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_=
watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 conso=
le=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=
=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-s2-01281631/linux-next=
:master:a1fd55538cae9f411059c9b067a3d48c41aa876b:bisect-linux-9/.vmlinu=
z-a1fd55538cae9f411059c9b067a3d48c41aa876b-20160128214805-9-kbuild bran=
ch=3Dlinux-next/master BOOT_IMAGE=3D/pkg/linux/x86_64-randconfig-s2-012=
81631/gcc-5/a1fd55538cae9f411059c9b067a3d48c41aa876b/vmlinuz-4.5.0-rc1-=
00069-ga1fd555 drbd.minor_count=3D8
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
[    0.000000] x86/fpu: Supporting XSAVE feature 0x01: 'x87 floating po=
int registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x02: 'SSE registers'
[    0.000000] x86/fpu: Supporting XSAVE feature 0x04: 'AVX registers'
[    0.000000] x86/fpu: Enabled xstate features 0x7, context size is 83=
2 bytes, using 'standard' format.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] u=
sable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000ffdffff] u=
sable
[    0.000000] BIOS-e820: [mem 0x000000000ffe0000-0x000000000fffffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] r=
eserved
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> =
reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xffe0 max_arch_pfn =3D 0x400000000
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
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC=
- WT =20
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f6600-0x000f660f] mapped=
 at [ffff8800000f6600]
[    0.000000]   mpc: f6610-f6718
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size =
24576
[    0.000000] BRK [0x04a37000, 0x04a37fff] PGTABLE
[    0.000000] BRK [0x04a38000, 0x04a38fff] PGTABLE
[    0.000000] BRK [0x04a39000, 0x04a39fff] PGTABLE
[    0.000000] BRK [0x04a3a000, 0x04a3afff] PGTABLE
[    0.000000] RAMDISK: [mem 0x0fcd6000-0x0ffdffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F6430 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000000FFE16EE 000034 (v01 BOCHS  BXPCRSD=
T 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000000FFE0C14 000074 (v01 BOCHS  BXPCFAC=
P 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000000FFE0040 000BD4 (v01 BOCHS  BXPCDSD=
T 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000000FFE0000 000040
[    0.000000] ACPI: SSDT 0x000000000FFE0C88 0009B6 (v01 BOCHS  BXPCSSD=
T 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000000FFE163E 000078 (v01 BOCHS  BXPCAPI=
C 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000000FFE16B6 000038 (v01 BOCHS  BXPCHPE=
T 00000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fd000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fcd5001, primary cpu clock
[    0.000000] kvm-clock: using sched offset of 3315029903 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cyc=
les: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x0000000000001000-0x000000000ffdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000000ffdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000000=
ffdffff]
[    0.000000] On node 0 totalpages: 65406
[    0.000000]   DMA32 zone: 896 pages used for memmap
[    0.000000]   DMA32 zone: 21 pages reserved
[    0.000000]   DMA32 zone: 65406 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fd000 (        fee00000)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GS=
I 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, A=
PIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high lev=
el)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, A=
PIC INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, A=
PIC INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high l=
evel)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, A=
PIC INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high l=
evel)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, A=
PIC INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, A=
PIC INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, A=
PIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, A=
PIC INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, A=
PIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, A=
PIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, A=
PIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, A=
PIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, A=
PIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, A=
PIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, A=
PIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] mapped IOAPIC to ffffffffff5fc000 (fec00000)
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 2462c80
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devi=
ces
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycle=
s: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  =
Total pages: 64489
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3Dt=
tyS0,115200 systemd.log_level=3Derr debug apic=3Ddebug sysrq_always_ena=
bled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D-1 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 prompt_ramdisk=
=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ra=
m0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-s2-01281631/=
linux-next:master:a1fd55538cae9f411059c9b067a3d48c41aa876b:bisect-linux=
-9/.vmlinuz-a1fd55538cae9f411059c9b067a3d48c41aa876b-20160128214805-9-k=
build branch=3Dlinux-next/master BOOT_IMAGE=3D/pkg/linux/x86_64-randcon=
fig-s2-01281631/gcc-5/a1fd55538cae9f411059c9b067a3d48c41aa876b/vmlinuz-=
4.5.0-rc1-00069-ga1fd555 drbd.minor_count=3D8
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 6, 262144=
 bytes)
[    0.000000] Inode-cache hash table entries: 16384 (order: 5, 131072 =
bytes)
[    0.000000] Memory: 194224K/261624K available (10816K kernel code, 5=
060K rwdata, 6628K rodata, 988K init, 33076K bss, 67400K reserved, 0K c=
ma-reserved)
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: CPU: 0 PID: 0 at kernel/locking/lockdep.c:2601 =
trace_hardirqs_on_caller+0x341/0x380()
[    0.000000] DEBUG_LOCKS_WARN_ON(unlikely(early_boot_irqs_disabled))
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.5.0-rc1-00069-=
ga1fd555 #1
[    0.000000]  ffffffff82403dd8 ffffffff82403d90 ffffffff813b937d ffff=
ffff82403dc8
[    0.000000]  ffffffff810eb4d3 ffffffff812617cc 0000000000000001 ffff=
88000fcc50a8
[    0.000000]  ffff8800000984c0 00000000024000c0 ffffffff82403e28 ffff=
ffff810eb5c7
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff813b937d>] dump_stack+0x27/0x3a
[    0.000000]  [<ffffffff810eb4d3>] warn_slowpath_common+0xa3/0x100
[    0.000000]  [<ffffffff812617cc>] ? cache_alloc_refill+0x7ac/0x910
[    0.000000]  [<ffffffff810eb5c7>] warn_slowpath_fmt+0x57/0x70
[    0.000000]  [<ffffffff81143e61>] trace_hardirqs_on_caller+0x341/0x3=
80
[    0.000000]  [<ffffffff81143ebd>] trace_hardirqs_on+0x1d/0x30
[    0.000000]  [<ffffffff812617cc>] cache_alloc_refill+0x7ac/0x910
[    0.000000]  [<ffffffff8121df6a>] ? pcpu_mem_zalloc+0x5a/0xc0
[    0.000000]  [<ffffffff81261fce>] __kmalloc+0x24e/0x440
[    0.000000]  [<ffffffff8121df6a>] pcpu_mem_zalloc+0x5a/0xc0
[    0.000000]  [<ffffffff829213aa>] percpu_init_late+0x4d/0xbb
[    0.000000]  [<ffffffff828f41c9>] start_kernel+0x30b/0x6e1
[    0.000000]  [<ffffffff828f3120>] ? early_idt_handler_array+0x120/0x=
120
[    0.000000]  [<ffffffff828f332f>] x86_64_start_reservations+0x46/0x4=
f
[    0.000000]  [<ffffffff828f34d4>] x86_64_start_kernel+0x19c/0x1b2
[    0.000000] ---[ end trace cb88537fdc8fa200 ]---
[    0.000000] Running RCU self tests
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, I=
nc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8159 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffff=
ff, max_idle_ns: 19112604467 ns
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.508 MHz processor
[    0.162184] Calibrating delay loop (skipped) preset value.. 5387.01 =
BogoMIPS (lpj=3D2693508)
[    0.163576] pid_max: default: 32768 minimum: 301
[    0.164409] ACPI: Core revision 20160108
[    0.167988] ACPI: 2 ACPI AML tables successfully acquired and loaded
[    0.169118]=20
[    0.169416] Security Framework initialized
[    0.170149] Mount-cache hash table entries: 512 (order: 0, 4096 byte=
s)
[    0.171073] Mountpoint-cache hash table entries: 512 (order: 0, 4096=
 bytes)
[    0.172132] mce: CPU supports 10 MCE banks
[    0.172577] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.173132] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.173697] CPU: Intel Core Processor (Haswell) (family: 0x6, model:=
 0x3c, stepping: 0x1)
[    0.177983] Performance Events: unsupported p6 CPU model 60 no PMU d=
river, software events only.
[    0.179261] enabled ExtINT on CPU#0
[    0.180237] ENABLING IO-APIC IRQs
[    0.180566] init IO_APIC IRQs
[    0.180860]  apic 0 pin 0 not connected
[    0.181271] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:=
0 Active:0 Dest:1)
[    0.182043] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:=
0 Active:0 Dest:1)
[    0.182817] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:=
0 Active:0 Dest:1)
[    0.183602] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:=
0 Active:0 Dest:1)
[    0.184386] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:=
1 Active:0 Dest:1)
[    0.185174] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:=
0 Active:0 Dest:1)
[    0.185931] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:=
0 Active:0 Dest:1)
[    0.186710] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:=
0 Active:0 Dest:1)
[    0.187495] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:=
1 Active:0 Dest:1)
[    0.188281] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mod=
e:1 Active:0 Dest:1)
[    0.189081] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mod=
e:1 Active:0 Dest:1)
[    0.189853] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mod=
e:0 Active:0 Dest:1)
[    0.190644] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mod=
e:0 Active:0 Dest:1)
[    0.191451] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mod=
e:0 Active:0 Dest:1)
[    0.192256] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mod=
e:0 Active:0 Dest:1)
[    0.193025]  apic 0 pin 16 not connected
[    0.193427]  apic 0 pin 17 not connected
[    0.193809]  apic 0 pin 18 not connected
[    0.194211]  apic 0 pin 19 not connected
[    0.194586]  apic 0 pin 20 not connected
[    0.194966]  apic 0 pin 21 not connected
[    0.195366]  apic 0 pin 22 not connected
[    0.195748]  apic 0 pin 23 not connected
[    0.196287] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin=
2=3D-1
[    0.196886] TSC deadline timer enabled
[    0.197443] devtmpfs: initialized
[    0.197937] gcov: version magic: 0x3530322a
[    0.199499] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xfff=
fffff, max_idle_ns: 1911260446275000 ns
[    0.200648] regulator-dummy: no parameters
[    0.201255] NET: Registered protocol family 16
[    0.202149] cpuidle: using governor ladder
[    0.203168] ACPI: bus type PCI registered
[    0.203796] PCI: Using configuration type 1 for base access
[    0.208162] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.208954] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.209498] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.210215] ACPI: Added _OSI(Module Device)
[    0.210619] ACPI: Added _OSI(Processor Device)
[    0.211036] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.211469] ACPI: Added _OSI(Processor Aggregator Device)
[    0.213575] ACPI: Interpreter enabled
[    0.213941] ACPI: (supports S0 S5)
[    0.214272] ACPI: Using IOAPIC for interrupt routing
[    0.214757] PCI: Using host bridge windows from ACPI; if necessary, =
use "pci=3Dnocrs" and report a bug
[    0.220261] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.220903] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.221643] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling A=
SPM
[    0.222664] PCI host bridge to bus 0000:00
[    0.223232] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 wi=
ndow]
[    0.224174] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff wi=
ndow]
[    0.225092] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000=
bffff window]
[    0.226120] pci_bus 0000:00: root bus resource [mem 0x10000000-0xfeb=
fffff window]
[    0.227140] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.227935] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.229462] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.231092] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.251157] pci 0000:00:01.1: reg 0x20: [io  0xc200-0xc20f]
[    0.259484] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f=
0-0x01f7]
[    0.260483] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f=
6]
[    0.261377] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x017=
0-0x0177]
[    0.262361] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x037=
6]
[    0.263660] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.265029] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by =
PIIX4 ACPI
[    0.266041] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by =
PIIX4 SMB
[    0.267459] pci 0000:00:02.0: [1234:1111] type 00 class 0x030000
[    0.274456] pci 0000:00:02.0: reg 0x10: [mem 0xfd000000-0xfdffffff p=
ref]
[    0.288785] pci 0000:00:02.0: reg 0x18: [mem 0xfebf0000-0xfebf0fff]
[    0.312646] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff p=
ref]
[    0.314102] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.320380] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.327926] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.357537] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff p=
ref]
[    0.360386] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.366237] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.373510] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.403856] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.412048] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.417497] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    0.449193] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.455663] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.462862] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    0.486239] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.489889] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    0.493751] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.515977] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.520623] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    0.526047] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.555983] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.564409] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.570288] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.600091] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.607497] pci 0000:00:0a.0: reg 0x10: [io  0xc1c0-0xc1ff]
[    0.613730] pci 0000:00:0a.0: reg 0x14: [mem 0xfebf7000-0xfebf7fff]
[    0.644737] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.647965] pci 0000:00:0b.0: reg 0x10: [mem 0xfebf8000-0xfebf800f]
[    0.667176] pci_bus 0000:00: on NUMA node 0
[    0.668666] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.669812] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.670867] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.671910] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.672873] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.674157] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.675775] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.676521] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,=
owns=3Dio+mem,locks=3Dnone
[    0.677576] vgaarb: loaded
[    0.677944] vgaarb: bridge control possible 0000:00:02.0
[    0.678995] ACPI: bus type USB registered
[    0.679562] usbcore: registered new interface driver usbfs
[    0.680313] usbcore: registered new interface driver hub
[    0.681043] usbcore: registered new device driver usb
[    0.681882] media: Linux media interface: v0.10
[    0.682496] Linux video capture interface: v2.00
[    0.683193] EDAC MC: Ver: 3.0.0
[    0.684001] EDAC DEBUG: edac_mc_sysfs_init: device mc created
[    0.685067] Advanced Linux Sound Architecture Driver Initialized.
[    0.685947] PCI: Using ACPI for IRQ routing
[    0.686490] PCI: pci_cache_line_size set to 64 bytes
[    0.687462] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.688270] e820: reserve RAM buffer [mem 0x0ffe0000-0x0fffffff]
[    0.689769] clocksource: Switched to clocksource kvm-clock
[    0.716940] VFS: Disk quotas dquot_6.6.0
[    0.717528] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 =
bytes)
[    0.718546] FS-Cache: Loaded
[    0.719047] pnp: PnP ACPI init
[    0.719610] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (activ=
e)
[    0.720637] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (activ=
e)
[    0.721656] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (activ=
e)
[    0.722632] pnp 00:03: [dma 2]
[    0.723132] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (activ=
e)
[    0.724163] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (activ=
e)
[    0.725194] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (activ=
e)
[    0.726599] pnp: PnP ACPI: found 6 devices
[    0.732499] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xfffff=
f, max_idle_ns: 2085701024 ns
[    0.733855] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.734715] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    0.735589] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff w=
indow]
[    0.736521] pci_bus 0000:00: resource 7 [mem 0x10000000-0xfebfffff w=
indow]
[    0.737518] NET: Registered protocol family 1
[    0.738155] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.738975] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.739762] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.740657] pci 0000:00:02.0: Video device with shadowed ROM
[    0.741575] PCI: CLS 0 bytes, default 64
[    0.742263] Unpacking initramfs...
[    0.815811] Freeing initrd memory: 3112K (ffff88000fcd6000 - ffff880=
00ffe0000)
[    0.817162] Machine check injector initialized
[    0.818216] cryptomgr_test (16) used greatest stack depth: 15248 byt=
es left
[    0.822104] AVX2 instructions are not detected.
[    0.822835] spin_lock-torture:--- Start of test [debug]: nwriters_st=
ress=3D2 nreaders_stress=3D0 stat_interval=3D60 verbose=3D1 shuffle_int=
erval=3D3 stutter=3D5 shutdown_secs=3D0 onoff_interval=3D0 onoff_holdof=
f=3D0
[    0.825145] spin_lock-torture: Creating torture_shuffle task
[    0.825941] spin_lock-torture: Creating torture_stutter task
[    0.826719] spin_lock-torture: torture_shuffle task started
[    0.827510] spin_lock-torture: Creating lock_torture_writer task
[    0.828337] spin_lock-torture: torture_stutter task started
[    0.829092] spin_lock-torture: Creating lock_torture_writer task
[    0.829908] spin_lock-torture: lock_torture_writer task started
[    0.830685] spin_lock-torture: Creating lock_torture_stats task
[    0.831485] spin_lock-torture: lock_torture_writer task started
[    0.832683] futex hash table entries: 256 (order: 2, 20480 bytes)
[    0.835798] spin_lock-torture: lock_torture_stats task started
[    1.200381] Initialise system trusted keyring
[    1.201404] fuse init (API version 7.24)
[    1.205530] test_firmware: interface ready
[    1.206128] Running rhashtable test nelem=3D8, max_size=3D0, shrinki=
ng=3D0
[    1.206975] Test 00:
[    1.209540]   Adding 50000 keys
[    1.260760]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    1.293954]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    1.295076]   Deleting 50000 keys
[    1.324186]   Duration of test: 114173094 ns
[    1.324897] Test 01:
[    1.327282]   Adding 50000 keys
[    1.381307]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    1.414456]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    1.415651]   Deleting 50000 keys
[    1.445882]   Duration of test: 118076548 ns
[    1.446552] Test 02:
[    1.448982]   Adding 50000 keys
[    1.505284]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    1.538810]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    1.539957]   Deleting 50000 keys
[    1.566134]   Duration of test: 116685599 ns
[    1.566793] Test 03:
[    1.569300]   Adding 50000 keys
[    1.626599]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    1.660044]   Traversal complete: counted=3D50000, nelems=3D50000, e=
ntries=3D50000, table-jumps=3D0
[    1.661195]   Deleting 50000 keys
[    1.682813]   Duration of test: 113059942 ns
[    1.683555] Average test time: 115498795
[    1.684140] Testing concurrent rhashtable access from 10 threads
[    1.818580]   thread[0]: rhashtable_insert_fast failed
[    1.819135] rhashtable_thra (168) used greatest stack depth: 14672 b=
ytes left
[    1.819816] Test failed: thread 0 returned: -12
[    1.820254]   thread[5]: rhashtable_insert_fast failed
[    1.820735]   thread[4]: rhashtable_insert_fast failed
[    1.821232]   thread[9]: rhashtable_insert_fast failed
[    1.821717]   thread[2]: rhashtable_insert_fast failed
[    1.822212]   thread[1]: rhashtable_insert_fast failed
[    1.822706] Test failed: thread 1 returned: -12
[    1.823147]   thread[8]: rhashtable_insert_fast failed
[    1.823628]   thread[7]: rhashtable_insert_fast failed
[    1.824292]   thread[3]: rhashtable_insert_fast failed
[    1.825024] Test failed: thread 2 returned: -12
[    1.825651]   thread[6]: rhashtable_insert_fast failed
[    1.826822] Test failed: thread 3 returned: -12
[    1.827471] Test failed: thread 4 returned: -12
[    1.828133] Test failed: thread 5 returned: -12
[    1.829804] Test failed: thread 6 returned: -12
[    1.830449] Test failed: thread 7 returned: -12
[    1.831112] Test failed: thread 8 returned: -12
[    1.831755] Test failed: thread 9 returned: -12
[    1.832383] Started 10 threads, 10 failed
[    1.849042] test_printf: all 224 tests passed
[    1.869587] crc32: CRC_LE_BITS =3D 1, CRC_BE BITS =3D 1
[    1.870144] crc32: self tests passed, processed 225944 bytes in 9558=
229 nsec
[    1.878494] crc32c: CRC_LE_BITS =3D 1
[    1.878848] crc32c: self tests passed, processed 225944 bytes in 398=
5328 nsec
[    1.879638] tsc: Refined TSC clocksource calibration: 2693.503 MHz
[    1.880229] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0=
x26d3451f606, max_idle_ns: 440795333933 ns
[    2.212762] crc32_combine: 8373 self tests passed
[    2.526186] crc32c_combine: 8373 self tests passed
[    2.526759] xz_dec_test: module loaded
[    2.527129] xz_dec_test: Create a device node with 'mknod xz_dec_tes=
t c 249 0' and write .xz files to it.
[    2.528066] rbtree testing -> 11120 cycles
[    2.974673] augmented rbtree testing -> 14086 cycles
[    3.540159] 104-idio-16 104-idio-16: Unable to lock 104-idio-16 port=
 addresses (0x0-0x8)
[    3.540931] 104-idio-16: probe of 104-idio-16 failed with error -16
[    3.541647] gpio_it87: no device
[    3.542070] no IO addresses supplied
[    3.542501] hgafb: HGA card not detected.
[    3.542892] hgafb: probe of hgafb.0 failed with error -22
[    3.543554] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/=
input/input0
[    3.544253] ACPI: Power Button [PWRF]
[    3.544661] Warning: Processor Platform Limit event detected, but no=
t handled.
[    3.545336] Consider compiling CPUfreq support into your kernel.
[    3.569611] r3964: Philips r3964 Driver $Revision: 1.10 $
[    3.570168] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    3.593842] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 1152=
00) is a 16550A
[    3.595301] smapi::smapi_init, ERROR invalid usSmapiID
[    3.595792] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAP=
I is not available on this machine
[    3.596647] mwave: mwavedd::mwave_init: Error: Failed to initialize =
board data
[    3.597318] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    3.597910] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 s=
econds, margin is 60 seconds).
[    3.598855] Failed to find cpu0 device node
[    3.599248] Unable to detect cache hierarchy from DT for CPU 0
[    3.599808] dummy-irq: no IRQ given.  Use irq=3DN
[    3.600295] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolf=
o Giometti
[    3.601235] usbcore: registered new interface driver viperboard
[    3.601904] HSI/SSI char device loaded
[    3.602467] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driv=
er
[    3.603086] ehci-pci: EHCI PCI platform driver
[    3.603567] fotg210_hcd: FOTG210 Host Controller (EHCI) Driver
[    3.604158] usbcore: registered new interface driver cdc_wdm
[    3.604695] usbcore: registered new interface driver usbtmc
[    3.605246] usbcore: registered new interface driver mdc800
[    3.605775] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800=
 Digital Camera
[    3.606489] usbcore: registered new interface driver cypress_cy7c63
[    3.607096] usbcore: registered new interface driver cytherm
[    3.607634] usbcore: registered new interface driver emi26 - firmwar=
e loader
[    3.608305] usbcore: registered new interface driver emi62 - firmwar=
e loader
[    3.608966] ftdi_elan: driver ftdi-elan
[    3.609407] usbcore: registered new interface driver ftdi-elan
[    3.609977] usbcore: registered new interface driver idmouse
[    3.610513] usbcore: registered new interface driver isight_firmware
[    3.611132] usbcore: registered new interface driver usblcd
[    3.611656] usbcore: registered new interface driver usbled
[    3.612199] usbcore: registered new interface driver legousbtower
[    3.612786] usbcore: registered new interface driver rio500
[    3.613319] usbcore: registered new interface driver usb_ehset_test
[    3.613923] usbcore: registered new interface driver trancevibrator
[    3.614511] usbcore: registered new interface driver usbsevseg
[    3.615076] usbcore: registered new interface driver yurex
[    3.615621] usbcore: registered new interface driver lvs
[    3.616458] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at=
 0x60,0x64 irq 1,12
[    3.617853] serio: i8042 KBD port at 0x60,0x64 irq 1
[    3.618317] serio: i8042 AUX port at 0x60,0x64 irq 12
[    3.664361] mousedev: PS/2 mouse device common for all mice
[    3.664957] evbug: Connected device: input0 (Power Button at LNXPWRB=
N/button/input0)
[    3.665972] mk712: device not present
[    3.666334] usbcore: registered new interface driver usbtouchscreen
[    3.667138] cm109: Keymap for Komunikate KIP1000 phone loaded
[    3.667692] usbcore: registered new interface driver cm109
[    3.668213] cm109: CM109 phone driver: 20080805 (C) Alfred E. Hegges=
tad
[    3.668935] usbcore: registered new interface driver ims_pcu
[    3.669481] usbcore: registered new interface driver keyspan_remote
[    3.670227] input: PC Speaker as /devices/platform/pcspkr/input/inpu=
t1
[    3.671139] input: AT Translated Set 2 keyboard as /devices/platform=
/i8042/serio0/input/input2
[    3.671972] evbug: Connected device: input1 (PC Speaker at isa0061/i=
nput0)
[    3.672631] usbcore: registered new interface driver powermate
[    3.673277] usbcore: registered new interface driver yealink
[    3.674333] rtc rtc0: invalid alarm value: 1900-1-29 2022213768:1073=
741856:0
[    3.675069] evbug: Connected device: input2 (AT Translated Set 2 key=
board at isa0060/serio0/input0)
[    3.676071] rtc-test rtc-test.0: rtc core: registered test as rtc0
[    3.676696] rtc rtc1: invalid alarm value: 1900-1-29 2022213768:1073=
741856:0
[    3.677413] rtc-test rtc-test.1: rtc core: registered test as rtc1
[    3.678121] usbcore: registered new interface driver i2c-diolan-u2c
[    3.678699] i2c-parport-light: adapter type unspecified
[    3.679209] usbcore: registered new interface driver RobotFuzz Open =
Source InterFace, OSIF
[    3.680243] lirc_dev: IR Remote Control driver registered, major 241=
=20
[    3.680852] IR NEC protocol handler initialized
[    3.681271] IR RC5(x/sz) protocol handler initialized
[    3.681742] IR JVC protocol handler initialized
[    3.682174] IR Sony protocol handler initialized
[    3.682603] IR SANYO protocol handler initialized
[    3.683050] IR Sharp protocol handler initialized
[    3.683490] IR LIRC bridge handler initialized
[    3.683932] usbcore: registered new interface driver ati_remote
[    3.684508] usbcore: registered new interface driver mceusb
[    3.685052] usbcore: registered new interface driver redrat3
[    3.685591] usbcore: registered new interface driver streamzap
[    3.686144] Registered IR keymap rc-empty
[    3.686607] input: rc-core loopback device as /devices/virtual/rc/rc=
0/input4
[    3.687324] evbug: Connected device: input4 (rc-core loopback device=
 at rc-core/virtual)
[    3.688084] rc rc0: rc-core loopback device as /devices/virtual/rc/r=
c0
[    3.688777] rc rc0: lirc_dev: driver ir-lirc-codec (rc-loopback) reg=
istered at minor =3D 0
[    3.689533] usbcore: registered new interface driver igorplugusb
[    3.690115] Driver for 1-wire Dallas network protocol.
[    3.690637] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    3.691238] 1-Wire driver for the DS2760 battery monitor chip - (c) =
2004-2005, Szabolcs Gyurko
[    3.692084] __power_supply_register: Expected proper parent device f=
or 'test_ac'
[    3.692804] __power_supply_register: Expected proper parent device f=
or 'test_battery'
[    3.693621] __power_supply_register: Expected proper parent device f=
or 'test_usb'
[    3.694875] f71882fg: Not a Fintek device
[    3.695271] f71882fg: Not a Fintek device
[    3.696069] sch56xx_common: Unsupported device id: 0xff
[    3.696566] sch56xx_common: Unsupported device id: 0xff
[    3.697422] usbcore: registered new interface driver pcwd_usb
[    3.698033] advantechwdt: WDT driver for Advantech single board comp=
uter initialising
[    3.698867] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D=
1)
[    3.699448] ib700wdt: WDT driver for IB700 single board computer ini=
tialising
[    3.700186] ib700wdt: START method I/O 443 is not available
[    3.700709] ib700wdt: probe of ib700wdt failed with error -5
[    3.701274] wafer5823wdt: WDT driver for Wafer 5823 single board com=
puter initialising
[    3.702020] wafer5823wdt: I/O address 0x0443 already in use
[    3.702593] it87_wdt: no device
[    3.702927] pc87413_wdt: Version 1.1 at io 0x2E
[    3.703355] pc87413_wdt: cannot register miscdev on minor=3D130 (err=
=3D-16)
[    3.703978] sbc60xxwdt: I/O address 0x0443 already in use
[    3.704475] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.=
1 initialising...
[    3.706260] smsc37b787_wdt: Unable to register miscdev on minor 130
[    3.706894] w83877f_wdt: I/O address 0x0443 already in use
[    3.707402] w83977f_wdt: driver v1.00
[    3.707747] w83977f_wdt: cannot register miscdev on minor=3D130 (err=
=3D-16)
[    3.708359] machzwd: MachZ ZF-Logic Watchdog driver initializing
[    3.708931] machzwd: no ZF-Logic found
[    3.709350] watchdog: Software Watchdog: cannot register miscdev on =
minor=3D130 (err=3D-16).
[    3.710102] watchdog: Software Watchdog: a legacy watchdog module is=
 probably present.
[    3.710938] softdog: Software Watchdog Timer: 0.08 initialized. soft=
_noboot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D1)
[    3.712885] usbcore: registered new interface driver usbhid
[    3.713399] usbhid: USB HID core driver
[    3.713815] cros_ec_lpc: unsupported system.
[    3.715163]  fake-fmc-carrier: mezzanine 0
[    3.715548]       Manufacturer: fake-vendor
[    3.715951]       Product name: fake-design-for-testing
[    3.716468] fmc fake-design-for-testing-f001: Driver has no ID: matc=
hes all
[    3.717129] fmc_write_eeprom fake-design-for-testing-f001: fmc_write=
_eeprom: no busid passed, refusing all cards
[    3.718084] fmc fake-design-for-testing-f001: Driver has no ID: matc=
hes all
[    3.718791] fmc_chardev fake-design-for-testing-f001: Created misc d=
evice "fake-design-for-testing-f001"
[    3.719726] intel_rapl: no valid rapl domains found in package 0
[    3.720662] Audio Excel DSP 16 init driver Copyright (C) Riccardo Fa=
cchetti 1995-98
[    3.721382] aedsp16: I/O, IRQ and DMA are mandatory
[    3.721863] pss: mss_io, mss_dma, mss_irq and pss_io must be set.
[    3.722424] ad1848/cs4248 codec driver Copyright (C) by Hannu Savola=
inen 1993-1996
[    3.723126] ad1848: No ISAPnP cards found, trying standard ones...
[    3.723699] uart6850: irq and io must be set.
[    3.724117] MIDI Loopback device driver
[    3.725113] snd_dummy snd_dummy.0: unable to register OSS PCM device=
 0:0
[    3.728212] microcode: CPU0 sig=3D0x306c1, pf=3D0x1, revision=3D0x1
[    3.728815] microcode: Microcode Update Driver: v2.01 <tigran@aivazi=
an.fsnet.co.uk>, Peter Oruba
[    3.729653] ... APIC ID:      00000000 (0)
[    3.730043] ... APIC VERSION: 01050014
[    3.730401] 00000000000000000000000000000000000000000000000000000000=
00000000
[    3.731175] 00000000000000000000000000000000000000000000000000000000=
00000000
[    3.731950] 00000000000000000000000000000000000000000000000000000000=
00008000
[    3.732736]=20
[    3.732899] number of MP IRQ sources: 15.
[    3.733269] number of IO-APIC #0 registers: 24.
[    3.733687] testing the IO APIC.......................
[    3.734179] IO APIC #0......
[    3.734451] .... register #00: 00000000
[    3.734816] .......    : physical APIC id: 00
[    3.735219] .......    : Delivery Type: 0
[    3.735587] .......    : LTS          : 0
[    3.735969] .... register #01: 00170011
[    3.736325] .......     : max redirection entries: 17
[    3.736795] .......     : PRQ implemented: 0
[    3.737187] .......     : IO APIC version: 11
[    3.737585] .... register #02: 00000000
[    3.737950] .......     : arbitration: 00
[    3.738323] .... IRQ redirection table:
[    3.738677] IOAPIC 0:
[    3.738913]  pin00, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.739631]  pin01, enabled , edge , high, V(31), IRR(0), S(0), logi=
cal , D(01), M(1)
[    3.740358]  pin02, enabled , edge , high, V(30), IRR(0), S(0), logi=
cal , D(01), M(1)
[    3.741086]  pin03, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.741808]  pin04, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.742526]  pin05, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.743248]  pin06, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.743975]  pin07, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.744690]  pin08, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.745435]  pin09, enabled , level, high, V(39), IRR(0), S(0), logi=
cal , D(01), M(1)
[    3.746163]  pin0a, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.746893]  pin0b, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.747609]  pin0c, enabled , edge , high, V(3C), IRR(0), S(0), logi=
cal , D(01), M(1)
[    3.748339]  pin0d, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.749079]  pin0e, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.749811]  pin0f, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.750557]  pin10, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.751382]  pin11, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.752213]  pin12, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.753004]  pin13, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.753849]  pin14, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.754666]  pin15, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.755494]  pin16, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.756324]  pin17, disabled, edge , high, V(00), IRR(0), S(0), phys=
ical, D(00), M(0)
[    3.757179] IRQ to pin mappings:
[    3.757506] IRQ0 -> 0:2
[    3.757764] IRQ1 -> 0:1
[    3.758052] IRQ3 -> 0:3
[    3.758305] IRQ4 -> 0:4
[    3.758643] IRQ5 -> 0:5
[    3.758949] IRQ6 -> 0:6
[    3.759208] IRQ7 -> 0:7
[    3.759464] IRQ8 -> 0:8
[    3.759726] IRQ9 -> 0:9
[    3.760000] IRQ10 -> 0:10
[    3.760274] IRQ11 -> 0:11
[    3.760547] IRQ12 -> 0:12
[    3.760836] IRQ13 -> 0:13
[    3.761109] IRQ14 -> 0:14
[    3.761384] IRQ15 -> 0:15
[    3.761663] .................................... done.
[    3.762173] AVX version of gcm_enc/dec engaged.
[    3.762598] AES CTR mode by8 optimization enabled
[    3.763957] Loading compiled-in X.509 certificates
[    3.764506] cryptomgr_probe (201) used greatest stack depth: 14560 b=
ytes left
[    3.765198] Key type trusted registered
[    3.765686] Key type encrypted registered
[    3.766786] BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
[    3.767496] ALSA device list:
[    3.767792]   #0: Dummy 1
[    3.768041]   #1: Loopback 1
[    3.770299] Freeing unused kernel memory: 988K (ffffffff828f3000 - f=
fffffff829ea000)
[    3.771044] Write protecting the kernel read-only data: 20480k
[    3.772370] Freeing unused kernel memory: 1392K (ffff880001aa4000 - =
ffff880001c00000)
[    3.777620] Freeing unused kernel memory: 1564K (ffff880002279000 - =
ffff880002400000)
[    3.778469] x86/mm: Checked W+X mappings: passed, no W+X pages found=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
--=_56aa2b47.57OidNqdxSWkF/GvABHXiVf1CFwf9jl2hhnx+8amWQJ6JN4W--
