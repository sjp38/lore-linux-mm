Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 05CDF6B025E
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 00:53:36 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id le9so104980306pab.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 21:53:35 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wi6si1180782pab.81.2016.08.10.21.53.34
        for <linux-mm@kvack.org>;
        Wed, 10 Aug 2016 21:53:34 -0700 (PDT)
Date: Thu, 11 Aug 2016 12:52:27 +0800
From: kernel test robot <fengguang.wu@intel.com>
Subject: [mm, kasan] 80a9201a59:  RIP: 0010:[<ffffffff9890f590>]
  [<ffffffff9890f590>] __kernel_text_address
Message-ID: <57ac048b.Qkbm0ARWLAJq8zX6%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_57ac048b.1M/X76gU08iKtlBZ1ywCY7GkGh/S0xQOFidVjCGQh3XtIpBv"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.comLinux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com

This is a multi-part message in MIME format.

--=_57ac048b.1M/X76gU08iKtlBZ1ywCY7GkGh/S0xQOFidVjCGQh3XtIpBv
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit 80a9201a5965f4715d5c09790862e0df84ce0614
Author:     Alexander Potapenko <glider@google.com>
AuthorDate: Thu Jul 28 15:49:07 2016 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Thu Jul 28 16:07:41 2016 -0700

    mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
    
    For KASAN builds:
     - switch SLUB allocator to using stackdepot instead of storing the
       allocation/deallocation stacks in the objects;
     - change the freelist hook so that parts of the freelist can be put
       into the quarantine.
    
    [aryabinin@virtuozzo.com: fixes]
      Link: http://lkml.kernel.org/r/1468601423-28676-1-git-send-email-aryabinin@virtuozzo.com
    Link: http://lkml.kernel.org/r/1468347165-41906-3-git-send-email-glider@google.com
    Signed-off-by: Alexander Potapenko <glider@google.com>
    Cc: Andrey Konovalov <adech.fo@gmail.com>
    Cc: Christoph Lameter <cl@linux.com>
    Cc: Dmitry Vyukov <dvyukov@google.com>
    Cc: Steven Rostedt (Red Hat) <rostedt@goodmis.org>
    Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
    Cc: Kostya Serebryany <kcc@google.com>
    Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
    Cc: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

+------------------------------------------------+------------+------------+------------+
|                                                | c146a2b98e | 80a9201a59 | 4fc0672d18 |
+------------------------------------------------+------------+------------+------------+
| boot_successes                                 | 106        | 0          | 17         |
| boot_failures                                  | 874        | 250        | 30         |
| RIP:T                                          | 201        | 53         | 3          |
| Kernel_panic-not_syncing:softlockup:hung_tasks | 874        | 250        | 30         |
| backtrace:eata2x_detect                        | 490        | 84         | 15         |
| backtrace:init_this_scsi_driver                | 490        | 84         | 15         |
| backtrace:do_basic_setup                       | 506        | 250        | 23         |
| backtrace:kernel_init_freeable                 | 506        | 250        | 23         |
| backtrace:ret_from_fork                        | 874        | 250        | 30         |
| RIP:_raw_spin_unlock_irqrestore                | 244        | 11         | 9          |
| backtrace:pci_enable_device_flags              | 16         | 166        | 8          |
| backtrace:__pci_register_driver                | 16         | 166        | 8          |
| backtrace:virtio_pci_driver_init               | 16         | 166        | 8          |
| RIP:note_page                                  | 248        | 0          | 5          |
| backtrace:mark_rodata_ro                       | 368        | 0          | 7          |
| RIP:walk_pmd_level                             | 120        | 0          | 2          |
| RIP:kmem_cache_free                            | 7          | 2          | 2          |
| RIP:check_bytes_and_report                     | 1          |            |            |
| backtrace:acpi_ut_update_object_reference      | 2          | 1          |            |
| RIP:kasan_kmalloc                              | 2          | 1          |            |
| RIP:acpi_ut_update_object_reference            | 3          | 2          |            |
| RIP:port_detect                                | 19         |            |            |
| RIP:delay_tsc                                  | 3          |            |            |
| RIP:lockdep_trace_alloc                        | 1          |            |            |
| RIP:free_debug_processing                      | 2          |            |            |
| RIP:__slab_free                                | 6          | 0          | 1          |
| RIP:kasan_slab_free                            | 1          | 3          |            |
| RIP:___might_sleep                             | 1          |            |            |
| RIP:__memset                                   | 3          | 2          |            |
| RIP:acpi_ps_push_scope                         | 1          |            |            |
| RIP:debug_lockdep_rcu_enabled                  | 1          |            |            |
| RIP:lock_is_held                               | 2          | 2          |            |
| RIP:memset_erms                                | 1          |            |            |
| RIP:should_failslab                            | 2          |            |            |
| RIP:acpi_ut_update_ref_count                   | 2          |            |            |
| RIP:acpi_ds_result_push                        | 1          |            |            |
| RIP:acpi_ps_get_arg                            | 1          |            |            |
| RIP:memchr_inv                                 | 1          |            |            |
| RIP:print_context_stack                        | 0          | 36         | 3          |
| RIP:qlist_free_all                             | 0          | 65         |            |
| RIP:__kernel_text_address                      | 0          | 37         | 3          |
| RIP:memcmp                                     | 0          | 18         | 1          |
| RIP:depot_save_stack                           | 0          | 5          |            |
| backtrace:apic_timer_interrupt                 | 0          | 17         | 2          |
| RIP:get_page_from_freelist                     | 0          | 1          |            |
| RIP:quarantine_put                             | 0          | 1          |            |
| RIP:save_stack_address                         | 0          | 4          |            |
| RIP:kasan_unpoison_shadow                      | 0          | 1          |            |
| RIP:dump_trace                                 | 0          | 2          |            |
| RIP:acpi_ut_create_generic_state               | 0          | 1          |            |
| RIP:acpi_ds_exec_begin_op                      | 0          | 1          |            |
| RIP:__do_softirq                               | 0          | 1          |            |
| backtrace:new_slab                             | 0          | 1          |            |
| RIP:acpi_ns_search_one_scope                   | 0          | 1          |            |
| RIP:acpi_ut_delete_generic_state               | 0          | 0          | 1          |
+------------------------------------------------+------------+------------+------------+

[   64.298576] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [swapper/0:1]
[   64.300827] irq event stamp: 5606950
[   64.301377] hardirqs last  enabled at (5606949): [<ffffffff98a4ef09>] T.2097+0x9a/0xbe
[   64.302586] hardirqs last disabled at (5606950): [<ffffffff997347a9>] apic_timer_interrupt+0x89/0xa0
[   64.303991] softirqs last  enabled at (5605564): [<ffffffff99735abe>] __do_softirq+0x23e/0x2bb
[   64.305308] softirqs last disabled at (5605557): [<ffffffff988ee34f>] irq_exit+0x73/0x108
[   64.306598] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.7.0-05999-g80a9201 #1
[   64.307678] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[   64.326233] task: ffff88000ea19ec0 task.stack: ffff88000ea20000
[   64.327137] RIP: 0010:[<ffffffff9890f590>]  [<ffffffff9890f590>] __kernel_text_address+0xb/0xa1
[   64.328504] RSP: 0000:ffff88000ea27348  EFLAGS: 00000207
[   64.329320] RAX: 0000000000000001 RBX: ffff88000ea275c0 RCX: 0000000000000001
[   64.330426] RDX: ffff88000ea27ff8 RSI: 024080c099733d8f RDI: 024080c099733d8f
[   64.331496] RBP: ffff88000ea27348 R08: ffff88000ea27678 R09: 0000000000000000
[   64.332567] R10: 0000000000021298 R11: ffffffff990f235c R12: ffff88000ea276c8
[   64.333635] R13: ffffffff99805e20 R14: ffff88000ea19ec0 R15: 0000000000000000
[   64.334706] FS:  0000000000000000(0000) GS:ffff88000ee00000(0000) knlGS:0000000000000000
[   64.335916] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   64.336782] CR2: 0000000000000000 CR3: 000000000aa0a000 CR4: 00000000000406b0
[   64.337846] Stack:
[   64.338206]  ffff88000ea273a8 ffffffff9881f3dd 024080c099733d8f ffffffffffff8000
[   64.339410]  ffff88000ea27678 ffff88000ea276c8 000000020e81a4d8 ffff88000ea273f8
[   64.340602]  ffffffff99805e20 ffff88000ea19ec0 ffff88000ea27438 ffff88000ee07fc0
[   64.348993] Call Trace:
[   64.349380]  [<ffffffff9881f3dd>] print_context_stack+0x68/0x13e
[   64.350295]  [<ffffffff9881e4af>] dump_trace+0x3ab/0x3d6
[   64.351102]  [<ffffffff9882f6e4>] save_stack_trace+0x31/0x5c
[   64.351964]  [<ffffffff98a521db>] kasan_kmalloc+0x126/0x1f6
[   64.365727]  [<ffffffff9882f6e4>] ? save_stack_trace+0x31/0x5c
[   64.366675]  [<ffffffff98a521db>] ? kasan_kmalloc+0x126/0x1f6
[   64.367560]  [<ffffffff9904a8eb>] ? acpi_ut_create_generic_state+0x43/0x5c

git bisect start 29b4817d4018df78086157ea3a55c1d9424a7cfc v4.7 --
git bisect  bad 574c7e233344b58c6b14b305c93de361d3e7d35d  # 23:23      2-      4  Merge branch 'for-4.7-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup
git bisect good 0e06f5c0deeef0332a5da2ecb8f1fcf3e024d958  # 23:53    205+    114  Merge branch 'akpm' (patches from Andrew)
git bisect good 76d5b28bbad1c5502a24f94c2beafc468690b2ba  # 08:23    213+    198  Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs
git bisect  bad c624c86615fb8aa61fa76ed8c935446d06c80e77  # 08:37     27-     32  Merge tag 'trace-v4.8' of git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-trace
git bisect good 6039b80eb50a893476fea7d56e86ed2d19290054  # 09:05    206+    170  Merge tag 'dmaengine-4.8-rc1' of git://git.infradead.org/users/vkoul/slave-dma
git bisect  bad f0c98ebc57c2d5e535bc4f9167f35650d2ba3c90  # 09:24     42-     46  Merge tag 'libnvdimm-for-4.8' of git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm
git bisect  bad 1c88e19b0f6a8471ee50d5062721ba30b8fd4ba9  # 09:47     43-     53  Merge branch 'akpm' (patches from Andrew)
git bisect good bca6759258dbef378bcf5b872177bcd2259ceb68  # 09:58    245+    243  mm, vmstat: remove zone and node double accounting by approximating retries
git bisect good efdc94907977d2db84b4b00cb9bd98ca011f6819  # 10:15    240+    240  mm: fix memcg stack accounting for sub-page stacks
git bisect good fb399b4854d2159a4d23fbfbd7daaed914fd54fa  # 11:48    250+    249  mm/memblock.c: fix index adjustment error in __next_mem_range_rev()
git bisect  bad 31a6c1909f51dbe9bf08eb40dc64e3db90cf6f79  # 11:53     47-     52  mm, page_alloc: set alloc_flags only once in slowpath
git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 12:03    245+    178  mm, kasan: account for object redzone in SLUB's nearest_obj()
git bisect  bad 87cc271d5e4320d705cfdf59f68d4d037b3511b2  # 12:07      3-      6  lib/stackdepot.c: use __GFP_NOWARN for stack allocations
git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 12:14     14-     16  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
# first bad commit: [80a9201a5965f4715d5c09790862e0df84ce0614] mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 12:27    726+    874  mm, kasan: account for object redzone in SLUB's nearest_obj()
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 12:33     14-     17  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
# extra tests on HEAD of linux-devel/devel-spot-201608102121
git bisect  bad 4fc0672d1847abd92df3ce73f61a1f0a1cc83e58  # 12:33      0-     30  0day head guard for 'devel-spot-201608102121'
# extra tests on tree/branch linus/master
git bisect  bad 85e97be32c6242c98dbbc7a241b4a78c1b93327b  # 12:40     33-     37  Merge branch 'akpm' (patches from Andrew)
# extra tests on tree/branch linus/master
git bisect  bad 85e97be32c6242c98dbbc7a241b4a78c1b93327b  # 12:40      0-     37  Merge branch 'akpm' (patches from Andrew)
# extra tests on tree/branch linux-next/master
git bisect  bad c0a5420a2efbfebd3cb90b000aeb953068b4da20  # 12:50     15-     20  Add linux-next specific files for 20160811


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
	-m 300
	-smp 1
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null 
)

append=(
	root=/dev/ram0
	hung_task_panic=1
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
	systemd.log_level=err
	ignore_loglevel
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	console=tty0
	vga=normal
	rw
	drbd.minor_count=8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_57ac048b.1M/X76gU08iKtlBZ1ywCY7GkGh/S0xQOFidVjCGQh3XtIpBv
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-kbuild-19:20160811121451:x86_64-randconfig-s0-08102154:4.7.0-05999-g80a9201:1.gz"

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
Jh/+C96P438CxQAA

--=_57ac048b.1M/X76gU08iKtlBZ1ywCY7GkGh/S0xQOFidVjCGQh3XtIpBv
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-quantal-intel12-13:20160811122033:x86_64-randconfig-s0-08102154:4.7.0-05998-gc146a2b:1.gz"

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
zwAA

--=_57ac048b.1M/X76gU08iKtlBZ1ywCY7GkGh/S0xQOFidVjCGQh3XtIpBv
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-4.7.0-05999-g80a9201"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.7.0 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
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
CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
CONFIG_X86_64_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEBUG_RODATA=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
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
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
CONFIG_KERNEL_LZO=y
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_FHANDLE=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ_FULL is not set
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_CONTEXT_TRACKING=y
CONFIG_CONTEXT_TRACKING_FORCE=y
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FAST_NO_HZ is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_RCU_KTHREAD_PRIO=0
# CONFIG_RCU_NOCB_CPU is not set
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_NMI_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
# CONFIG_MEMCG is not set
# CONFIG_BLK_CGROUP is not set
CONFIG_CGROUP_SCHED=y
# CONFIG_FAIR_GROUP_SCHED is not set
CONFIG_RT_GROUP_SCHED=y
# CONFIG_CGROUP_PIDS is not set
CONFIG_CGROUP_FREEZER=y
# CONFIG_CGROUP_HUGETLB is not set
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_DEBUG=y
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_NAMESPACES is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
# CONFIG_SYSFS_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
# CONFIG_BPF_SYSCALL is not set
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
# CONFIG_USERFAULTFD is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_MEMBARRIER is not set
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLAB_FREELIST_RANDOM=y
# CONFIG_SLUB_CPU_PARTIAL is not set
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
CONFIG_PROFILING=y
CONFIG_OPROFILE=y
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
# CONFIG_HAVE_ARCH_HASH is not set
CONFIG_ISA_BUS_API=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_FORMAT_AUTODETECT is not set
# CONFIG_GCOV_FORMAT_3_4 is not set
CONFIG_GCOV_FORMAT_4_7=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
# CONFIG_BLK_DEV_BSGLIB is not set
# CONFIG_BLK_DEV_INTEGRITY is not set
# CONFIG_BLK_CMDLINE_PARSER is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_AMIGA_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
# CONFIG_IOSCHED_CFQ is not set
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
# CONFIG_X86_X2APIC is not set
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_VSMP is not set
# CONFIG_X86_GOLDFISH is not set
CONFIG_X86_INTEL_LPSS=y
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
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
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_CALGARY_IOMMU=y
# CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS=8192
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
# CONFIG_PERF_EVENTS_INTEL_UNCORE is not set
CONFIG_PERF_EVENTS_INTEL_RAPL=y
# CONFIG_PERF_EVENTS_INTEL_CSTATE is not set
CONFIG_PERF_EVENTS_AMD_POWER=y
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_X86_MSR is not set
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_X86_DIRECT_GBPAGES=y
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CLEANCACHE=y
# CONFIG_FRONTSWAP is not set
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
CONFIG_ZPOOL=y
# CONFIG_ZBUD is not set
CONFIG_Z3FOLD=y
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
# CONFIG_X86_PMEM_LEGACY is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
# CONFIG_X86_SMAP is not set
CONFIG_X86_INTEL_MPX=y
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
# CONFIG_KEXEC_FILE is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_RANDOMIZE_MEMORY=y
CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING=0x0
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
CONFIG_DEBUG_HOTPLUG_CPU0=y
CONFIG_COMPAT_VDSO=y
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
# CONFIG_HIBERNATION is not set
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_AUTOSLEEP=y
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
CONFIG_PM_WAKELOCKS_GC=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
# CONFIG_PM_ADVANCED_DEBUG is not set
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_PM_TRACE_RTC is not set
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
# CONFIG_ACPI_BUTTON is not set
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=y
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_NFIT is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
CONFIG_PMIC_OPREGION=y
CONFIG_XPOWER_PMIC_OPREGION=y
CONFIG_ACPI_CONFIGFS=y
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
# CONFIG_CPU_FREQ_GOV_SCHEDUTIL is not set

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
CONFIG_X86_PCC_CPUFREQ=y
# CONFIG_X86_ACPI_CPUFREQ is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
# CONFIG_PCIEAER is not set
# CONFIG_PCIEASPM is not set
CONFIG_PCIE_PME=y
# CONFIG_PCIE_DPC is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI host controller drivers
#
# CONFIG_PCIE_DW_PLAT is not set
CONFIG_ISA_BUS=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
# CONFIG_CARDBUS is not set

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
# CONFIG_COREDUMP is not set
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
CONFIG_X86_X32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_KEYS_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_PMC_ATOM=y
CONFIG_VMD=y
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
# CONFIG_NET_PTP_CLASSIFY is not set
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
# CONFIG_DNS_RESOLVER is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_HSR is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_SOCK_CGROUP_DATA is not set
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
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
# CONFIG_LWTUNNEL is not set
# CONFIG_DST_CACHE is not set
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_ALLOW_DEV_COREDUMP=y
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
# CONFIG_FENCE_TRACE is not set
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
CONFIG_CMA_SIZE_SEL_MIN=y
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
# CONFIG_FTL is not set
CONFIG_NFTL=y
# CONFIG_NFTL_RW is not set
CONFIG_INFTL=y
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
CONFIG_SM_FTL=y
# CONFIG_MTD_OOPS is not set
CONFIG_MTD_SWAP=y
CONFIG_MTD_PARTITIONED_MASTER=y

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
CONFIG_MTD_CFI_BE_BYTE_SWAP=y
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
# CONFIG_MTD_CFI_GEOMETRY is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
# CONFIG_MTD_OTP is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
# CONFIG_MTD_PHYSMAP_COMPAT is not set
CONFIG_MTD_AMD76XROM=y
CONFIG_MTD_ICHXROM=y
CONFIG_MTD_ESB2ROM=y
# CONFIG_MTD_CK804XROM is not set
CONFIG_MTD_SCB2_FLASH=y
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=y
# CONFIG_MTD_PMC551_BUGFIX is not set
CONFIG_MTD_PMC551_DEBUG=y
CONFIG_MTD_DATAFLASH=y
CONFIG_MTD_DATAFLASH_WRITE_VERIFY=y
CONFIG_MTD_DATAFLASH_OTP=y
# CONFIG_MTD_SST25L is not set
# CONFIG_MTD_SLRAM is not set
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=y
CONFIG_MTD_NAND_ECC_SMC=y
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_ECC_BCH is not set
# CONFIG_MTD_SM_COMMON is not set
# CONFIG_MTD_NAND_DENALI_PCI is not set
CONFIG_MTD_NAND_GPIO=y
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=y
# CONFIG_MTD_NAND_RICOH is not set
# CONFIG_MTD_NAND_DISKONCHIP is not set
CONFIG_MTD_NAND_DOCG4=y
CONFIG_MTD_NAND_CAFE=y
# CONFIG_MTD_NAND_NANDSIM is not set
CONFIG_MTD_NAND_PLATFORM=y
CONFIG_MTD_NAND_HISI504=y
CONFIG_MTD_ONENAND=y
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
CONFIG_MTD_ONENAND_GENERIC=y
# CONFIG_MTD_ONENAND_OTP is not set
CONFIG_MTD_ONENAND_2X_PROGRAM=y

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_SPI_NOR is not set
# CONFIG_MTD_UBI is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SKD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RSXX is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_NVME_TARGET is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
CONFIG_SGI_IOC4=y
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
# CONFIG_BMP085_I2C is not set
CONFIG_BMP085_SPI=y
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_LATTICE_ECP3_CONFIG=y
CONFIG_SRAM=y
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
# CONFIG_PANEL_CHANGE_MESSAGE is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_EEPROM_93XX46 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
CONFIG_INTEL_MEI_TXE=y
CONFIG_VMWARE_VMCI=y

#
# Intel MIC Bus Driver
#
CONFIG_INTEL_MIC_BUS=y

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

#
# VOP Bus Driver
#
CONFIG_VOP_BUS=y

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
CONFIG_VOP=y
CONFIG_GENWQE=y
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=0
CONFIG_ECHO=y
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_KERNEL_API is not set
# CONFIG_CXL_EEH is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_NETLINK is not set
CONFIG_SCSI_MQ_DEFAULT=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_BE2ISCSI is not set
CONFIG_BLK_DEV_3W_XXXX_RAID=y
CONFIG_SCSI_HPSA=y
CONFIG_SCSI_3W_9XXX=y
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
# CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
# CONFIG_AIC79XX_BUILD_FIRMWARE is not set
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC94XX=y
CONFIG_AIC94XX_DEBUG=y
CONFIG_SCSI_MVSAS=y
# CONFIG_SCSI_MVSAS_DEBUG is not set
CONFIG_SCSI_MVSAS_TASKLET=y
CONFIG_SCSI_MVUMI=y
CONFIG_SCSI_DPT_I2O=y
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_ARCMSR=y
CONFIG_SCSI_ESAS2R=y
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
# CONFIG_MEGARAID_MAILBOX is not set
# CONFIG_MEGARAID_LEGACY is not set
CONFIG_MEGARAID_SAS=y
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_MPT2SAS is not set
CONFIG_SCSI_UFSHCD=y
CONFIG_SCSI_UFSHCD_PCI=y
CONFIG_SCSI_UFS_DWC_TC_PCI=y
CONFIG_SCSI_UFSHCD_PLATFORM=y
# CONFIG_SCSI_UFS_DWC_TC_PLATFORM is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
CONFIG_VMWARE_PVSCSI=y
CONFIG_SCSI_SNIC=y
CONFIG_SCSI_SNIC_DEBUG_FS=y
# CONFIG_SCSI_DMX3191D is not set
CONFIG_SCSI_EATA=y
CONFIG_SCSI_EATA_TAGGED_QUEUE=y
CONFIG_SCSI_EATA_LINKED_COMMANDS=y
CONFIG_SCSI_EATA_MAX_TAGS=16
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_ISCI is not set
CONFIG_SCSI_IPS=y
CONFIG_SCSI_INITIO=y
CONFIG_SCSI_INIA100=y
CONFIG_SCSI_STEX=y
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
# CONFIG_SCSI_SYM53C8XX_MMIO is not set
CONFIG_SCSI_QLOGIC_1280=y
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_AM53C974 is not set
# CONFIG_SCSI_WD719X is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
CONFIG_SCSI_PM8001=y
# CONFIG_SCSI_VIRTIO is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
# CONFIG_SCSI_DH_ALUA is not set
CONFIG_SCSI_OSD_INITIATOR=y
# CONFIG_SCSI_OSD_ULD is not set
CONFIG_SCSI_OSD_DPRINT_SENSE=1
CONFIG_SCSI_OSD_DEBUG=y
# CONFIG_ATA is not set
# CONFIG_MD is not set
# CONFIG_TARGET_CORE is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
CONFIG_FIREWIRE_SBP2=y
CONFIG_FIREWIRE_NOSY=y
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set
CONFIG_VHOST_RING=y
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5520=y
CONFIG_KEYBOARD_ADP5588=y
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
# CONFIG_KEYBOARD_QT2160 is not set
CONFIG_KEYBOARD_LKKBD=y
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
CONFIG_KEYBOARD_TCA6416=y
# CONFIG_KEYBOARD_TCA8418 is not set
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
CONFIG_KEYBOARD_SAMSUNG=y
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_TWL4030=y
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
# CONFIG_TABLET_USB_ACECAD is not set
# CONFIG_TABLET_USB_AIPTEK is not set
# CONFIG_TABLET_USB_HANWANG is not set
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_PEGASUS is not set
CONFIG_TABLET_SERIAL_WACOM4=y
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
CONFIG_TOUCHSCREEN_88PM860X=y
CONFIG_TOUCHSCREEN_ADS7846=y
# CONFIG_TOUCHSCREEN_AD7877 is not set
CONFIG_TOUCHSCREEN_AD7879=y
# CONFIG_TOUCHSCREEN_AD7879_I2C is not set
# CONFIG_TOUCHSCREEN_AD7879_SPI is not set
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
CONFIG_TOUCHSCREEN_BU21013=y
CONFIG_TOUCHSCREEN_CY8CTMG110=y
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP_I2C=y
# CONFIG_TOUCHSCREEN_CYTTSP_SPI is not set
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP4_I2C=y
# CONFIG_TOUCHSCREEN_CYTTSP4_SPI is not set
CONFIG_TOUCHSCREEN_DA9034=y
CONFIG_TOUCHSCREEN_DA9052=y
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=y
CONFIG_TOUCHSCREEN_EGALAX_SERIAL=y
CONFIG_TOUCHSCREEN_FT6236=y
CONFIG_TOUCHSCREEN_FUJITSU=y
CONFIG_TOUCHSCREEN_GOODIX=y
CONFIG_TOUCHSCREEN_ILI210X=y
CONFIG_TOUCHSCREEN_GUNZE=y
CONFIG_TOUCHSCREEN_ELAN=y
CONFIG_TOUCHSCREEN_ELO=y
# CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
# CONFIG_TOUCHSCREEN_WACOM_I2C is not set
# CONFIG_TOUCHSCREEN_MAX11801 is not set
# CONFIG_TOUCHSCREEN_MCS5000 is not set
CONFIG_TOUCHSCREEN_MMS114=y
# CONFIG_TOUCHSCREEN_MELFAS_MIP4 is not set
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_INEXIO=y
# CONFIG_TOUCHSCREEN_MK712 is not set
CONFIG_TOUCHSCREEN_PENMOUNT=y
CONFIG_TOUCHSCREEN_EDT_FT5X06=y
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
# CONFIG_TOUCHSCREEN_TI_AM335X_TSC is not set
CONFIG_TOUCHSCREEN_PIXCIR=y
CONFIG_TOUCHSCREEN_WDT87XX_I2C=y
CONFIG_TOUCHSCREEN_WM831X=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_TOUCHIT213=y
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
CONFIG_TOUCHSCREEN_TSC200X_CORE=y
# CONFIG_TOUCHSCREEN_TSC2004 is not set
CONFIG_TOUCHSCREEN_TSC2005=y
CONFIG_TOUCHSCREEN_TSC2007=y
CONFIG_TOUCHSCREEN_PCAP=y
CONFIG_TOUCHSCREEN_RM_TS=y
CONFIG_TOUCHSCREEN_ST1232=y
CONFIG_TOUCHSCREEN_SURFACE3_SPI=y
CONFIG_TOUCHSCREEN_SX8654=y
CONFIG_TOUCHSCREEN_TPS6507X=y
# CONFIG_TOUCHSCREEN_ZFORCE is not set
# CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM860X_ONKEY=y
CONFIG_INPUT_88PM80X_ONKEY=y
# CONFIG_INPUT_AD714X is not set
CONFIG_INPUT_BMA150=y
# CONFIG_INPUT_E3X0_BUTTON is not set
CONFIG_INPUT_MMA8450=y
# CONFIG_INPUT_MPU3050 is not set
CONFIG_INPUT_APANEL=y
CONFIG_INPUT_GP2A=y
CONFIG_INPUT_GPIO_BEEPER=y
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
CONFIG_INPUT_ATLAS_BTNS=y
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=y
# CONFIG_INPUT_KXTJ9_POLLED_MODE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
# CONFIG_INPUT_RETU_PWRBUTTON is not set
CONFIG_INPUT_TPS65218_PWRBUTTON=y
CONFIG_INPUT_AXP20X_PEK=y
CONFIG_INPUT_TWL4030_PWRBUTTON=y
CONFIG_INPUT_TWL4030_VIBRA=y
# CONFIG_INPUT_TWL6040_VIBRA is not set
CONFIG_INPUT_UINPUT=y
# CONFIG_INPUT_PALMAS_PWRBUTTON is not set
CONFIG_INPUT_PCF50633_PMU=y
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_DA9052_ONKEY is not set
CONFIG_INPUT_DA9063_ONKEY=y
CONFIG_INPUT_WM831X_ON=y
# CONFIG_INPUT_PCAP is not set
# CONFIG_INPUT_ADXL34X is not set
CONFIG_INPUT_CMA3000=y
CONFIG_INPUT_CMA3000_I2C=y
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
# CONFIG_INPUT_DRV260X_HAPTICS is not set
CONFIG_INPUT_DRV2665_HAPTICS=y
CONFIG_INPUT_DRV2667_HAPTICS=y
CONFIG_RMI4_CORE=y
CONFIG_RMI4_I2C=y
# CONFIG_RMI4_SPI is not set
CONFIG_RMI4_2D_SENSOR=y
# CONFIG_RMI4_F11 is not set
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y

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
# CONFIG_SERIO_RAW is not set
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_USERIO=y
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
# CONFIG_UNIX98_PTYS is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
CONFIG_MOXA_INTELLIO=y
CONFIG_MOXA_SMARTIO=y
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
CONFIG_SYNCLINK_GT=y
# CONFIG_NOZOMI is not set
CONFIG_ISI=y
CONFIG_N_HDLC=y
# CONFIG_N_GSM is not set
# CONFIG_TRACE_ROUTER is not set
CONFIG_TRACE_SINK=y
CONFIG_DEVMEM=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_FINTEK=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_FSL is not set
# CONFIG_SERIAL_8250_DW is not set
CONFIG_SERIAL_8250_RT288X=y
CONFIG_SERIAL_8250_MID=y
CONFIG_SERIAL_8250_MOXA=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
# CONFIG_SERIAL_MAX310X is not set
CONFIG_SERIAL_UARTLITE=y
# CONFIG_SERIAL_UARTLITE_CONSOLE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS=y
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_ALTERA_UART_CONSOLE=y
CONFIG_SERIAL_IFX6X60=y
# CONFIG_SERIAL_ARC is not set
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
CONFIG_SERIAL_FSL_LPUART=y
# CONFIG_SERIAL_FSL_LPUART_CONSOLE is not set
CONFIG_SERIAL_MCTRL_GPIO=y
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=y
CONFIG_R3964=y
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_XILLYBUS=y
# CONFIG_XILLYBUS_PCIE is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_MUX_PINCTRL=y
CONFIG_I2C_MUX_REG=y
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
# CONFIG_I2C_ALI1563 is not set
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
CONFIG_I2C_AMD756_S4882=y
CONFIG_I2C_AMD8111=y
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
# CONFIG_I2C_NFORCE2 is not set
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
# CONFIG_I2C_SIS96X is not set
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
# CONFIG_I2C_DESIGNWARE_PLATFORM is not set
CONFIG_I2C_DESIGNWARE_PCI=y
CONFIG_I2C_EMEV2=y
CONFIG_I2C_GPIO=y
# CONFIG_I2C_KEMPLD is not set
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_SLAVE=y
# CONFIG_I2C_SLAVE_EEPROM is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
CONFIG_SPI_DEBUG=y
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_AXI_SPI_ENGINE=y
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
# CONFIG_SPI_CADENCE is not set
CONFIG_SPI_DESIGNWARE=y
CONFIG_SPI_DW_PCI=y
# CONFIG_SPI_DW_MMIO is not set
CONFIG_SPI_GPIO=y
CONFIG_SPI_LM70_LLP=y
CONFIG_SPI_OC_TINY=y
CONFIG_SPI_PXA2XX=y
CONFIG_SPI_PXA2XX_PCI=y
# CONFIG_SPI_ROCKCHIP is not set
CONFIG_SPI_SC18IS602=y
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
CONFIG_SPI_TLE62X0=y
# CONFIG_SPMI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
CONFIG_PPS_CLIENT_LDISC=y
CONFIG_PPS_CLIENT_PARPORT=y
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
CONFIG_PINCTRL=y

#
# Pin controllers
#
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
# CONFIG_DEBUG_PINCTRL is not set
CONFIG_PINCTRL_AMD=y
CONFIG_PINCTRL_BAYTRAIL=y
CONFIG_PINCTRL_CHERRYVIEW=y
CONFIG_PINCTRL_INTEL=y
# CONFIG_PINCTRL_BROXTON is not set
CONFIG_PINCTRL_SUNRISEPOINT=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_AMDPT=y
CONFIG_GPIO_DWAPB=y
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_LYNXPOINT=y
CONFIG_GPIO_VX855=y
CONFIG_GPIO_ZX=y

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_104_DIO_48E=y
CONFIG_GPIO_104_IDIO_16=y
# CONFIG_GPIO_104_IDI_48 is not set
# CONFIG_GPIO_F7188X is not set
CONFIG_GPIO_IT87=y
CONFIG_GPIO_SCH=y
CONFIG_GPIO_SCH311X=y
CONFIG_GPIO_WS16C48=y

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#
CONFIG_GPIO_ADP5520=y
CONFIG_GPIO_ARIZONA=y
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_KEMPLD=y
CONFIG_GPIO_PALMAS=y
CONFIG_GPIO_TPS65086=y
# CONFIG_GPIO_TPS65218 is not set
CONFIG_GPIO_TPS6586X=y
# CONFIG_GPIO_TPS65910 is not set
# CONFIG_GPIO_TPS65912 is not set
CONFIG_GPIO_TWL4030=y
CONFIG_GPIO_TWL6040=y
# CONFIG_GPIO_WM831X is not set
CONFIG_GPIO_WM8350=y
CONFIG_GPIO_WM8994=y

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
CONFIG_GPIO_BT8XX=y
# CONFIG_GPIO_ML_IOH is not set
CONFIG_GPIO_RDC321X=y

#
# SPI GPIO expanders
#
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MC33880=y
# CONFIG_GPIO_PISOSR is not set

#
# SPI or I2C GPIO expanders
#
# CONFIG_GPIO_MCP23S08 is not set
CONFIG_W1=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
# CONFIG_W1_SLAVE_SMEM is not set
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
CONFIG_GENERIC_ADC_BATTERY=y
# CONFIG_WM831X_BACKUP is not set
CONFIG_WM831X_POWER=y
CONFIG_WM8350_POWER=y
CONFIG_TEST_POWER=y
# CONFIG_BATTERY_88PM860X is not set
CONFIG_BATTERY_DS2760=y
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
CONFIG_BATTERY_BQ27XXX=y
CONFIG_BATTERY_BQ27XXX_I2C=y
# CONFIG_BATTERY_DA9030 is not set
CONFIG_BATTERY_DA9052=y
CONFIG_AXP288_FUEL_GAUGE=y
CONFIG_BATTERY_MAX17040=y
# CONFIG_BATTERY_MAX17042 is not set
CONFIG_BATTERY_TWL4030_MADC=y
CONFIG_CHARGER_PCF50633=y
CONFIG_BATTERY_RX51=y
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_CHARGER_TWL4030=y
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MAX14577 is not set
CONFIG_CHARGER_MAX77693=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24257=y
CONFIG_CHARGER_BQ24735=y
# CONFIG_CHARGER_BQ25890 is not set
CONFIG_CHARGER_SMB347=y
CONFIG_CHARGER_TPS65217=y
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_BATTERY_RT5033 is not set
CONFIG_CHARGER_RT9455=y
# CONFIG_AXP20X_POWER is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_RESTART is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
# CONFIG_SENSORS_ABITUGURU3 is not set
CONFIG_SENSORS_AD7314=y
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=y
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_FTSTEUTATES=y
# CONFIG_SENSORS_GL518SM is not set
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IIO_HWMON=y
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
# CONFIG_SENSORS_LTC2990 is not set
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4260=y
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_MAX1111=y
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
CONFIG_SENSORS_MAX31722=y
CONFIG_SENSORS_MAX6639=y
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
# CONFIG_SENSORS_MAX31790 is not set
CONFIG_SENSORS_MCP3021=y
# CONFIG_SENSORS_MENF21BMC_HWMON is not set
# CONFIG_SENSORS_ADCXX is not set
CONFIG_SENSORS_LM63=y
# CONFIG_SENSORS_LM70 is not set
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_NCT7802=y
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHT3x=y
CONFIG_SENSORS_SHTC1=y
CONFIG_SENSORS_SIS5595=y
# CONFIG_SENSORS_DME1737 is not set
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
CONFIG_SENSORS_SCH5636=y
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_ADC128D818=y
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
# CONFIG_SENSORS_ADS7871 is not set
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_INA209=y
# CONFIG_SENSORS_INA2XX is not set
# CONFIG_SENSORS_INA3221 is not set
# CONFIG_SENSORS_TC74 is not set
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP103=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
# CONFIG_SENSORS_TWL4030_MADC is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_WM831X is not set
# CONFIG_SENSORS_WM8350 is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE=y
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_EMULATION=y
CONFIG_INTEL_POWERCLAMP=y
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
CONFIG_INTEL_SOC_DTS_THERMAL=y

#
# ACPI INT340X thermal drivers
#
CONFIG_INT340X_THERMAL=y
CONFIG_ACPI_THERMAL_REL=y
# CONFIG_INT3406_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
CONFIG_GENERIC_ADC_THERMAL=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
# CONFIG_WATCHDOG_SYSFS is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
# CONFIG_DA9052_WATCHDOG is not set
CONFIG_DA9063_WATCHDOG=y
CONFIG_DA9062_WATCHDOG=y
CONFIG_MENF21BMC_WATCHDOG=y
CONFIG_WM831X_WATCHDOG=y
CONFIG_WM8350_WATCHDOG=y
CONFIG_XILINX_WATCHDOG=y
# CONFIG_ZIIRAVE_WATCHDOG is not set
CONFIG_CADENCE_WATCHDOG=y
CONFIG_DW_WATCHDOG=y
# CONFIG_TWL4030_WATCHDOG is not set
CONFIG_MAX63XX_WATCHDOG=y
# CONFIG_RETU_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
CONFIG_ALIM7101_WDT=y
# CONFIG_EBC_C384_WDT is not set
CONFIG_F71808E_WDT=y
CONFIG_SP5100_TCO=y
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
# CONFIG_WAFER_WDT is not set
# CONFIG_I6300ESB_WDT is not set
CONFIG_IE6XX_WDT=y
CONFIG_ITCO_WDT=y
# CONFIG_ITCO_VENDOR_SUPPORT is not set
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
CONFIG_HP_WATCHDOG=y
# CONFIG_KEMPLD_WDT is not set
# CONFIG_HPWDT_NMI_DECODING is not set
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
CONFIG_NV_TCO=y
# CONFIG_60XX_WDT is not set
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
# CONFIG_SMSC37B787_WDT is not set
CONFIG_VIA_WDT=y
CONFIG_W83627HF_WDT=y
CONFIG_W83877F_WDT=y
# CONFIG_W83977F_WDT is not set
CONFIG_MACHZ_WDT=y
CONFIG_SBC_EPX_C3_WATCHDOG=y
CONFIG_INTEL_MEI_WDT=y
CONFIG_NI903X_WDT=y
CONFIG_MEN_A21_WDT=y

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
CONFIG_WDTPCI=y
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
# CONFIG_BCMA_HOST_PCI is not set
CONFIG_BCMA_HOST_SOC=y
# CONFIG_BCMA_DRIVER_PCI is not set
# CONFIG_BCMA_SFLASH is not set
CONFIG_BCMA_DRIVER_GMAC_CMN=y
CONFIG_BCMA_DRIVER_GPIO=y
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_AS3711=y
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_AXP20X=y
CONFIG_MFD_AXP20X_I2C=y
# CONFIG_MFD_CROS_EC is not set
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
# CONFIG_MFD_DA9150 is not set
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=y
# CONFIG_LPC_ICH is not set
CONFIG_LPC_SCH=y
# CONFIG_INTEL_SOC_PMIC is not set
CONFIG_MFD_INTEL_LPSS=y
CONFIG_MFD_INTEL_LPSS_ACPI=y
CONFIG_MFD_INTEL_LPSS_PCI=y
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX77843 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MT6397 is not set
CONFIG_MFD_MENF21BMC=y
CONFIG_EZX_PCAP=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
# CONFIG_PCF50633_ADC is not set
CONFIG_PCF50633_GPIO=y
CONFIG_MFD_RDC321X=y
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RT5033=y
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
CONFIG_AB3100_OTP=y
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP3943 is not set
CONFIG_MFD_LP8788=y
CONFIG_MFD_PALMAS=y
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
CONFIG_MFD_TPS65086=y
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS65218=y
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
# CONFIG_MFD_TPS65912_I2C is not set
CONFIG_MFD_TPS65912_SPI=y
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
CONFIG_TWL6040_CORE=y
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_ARIZONA_SPI=y
# CONFIG_MFD_CS47L24 is not set
CONFIG_MFD_WM5102=y
# CONFIG_MFD_WM5110 is not set
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8998=y
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM831X_SPI=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
# CONFIG_REGULATOR is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
# CONFIG_MEDIA_RADIO_SUPPORT is not set
# CONFIG_MEDIA_SDR_SUPPORT is not set
CONFIG_MEDIA_RC_SUPPORT=y
CONFIG_MEDIA_CEC_EDID=y
CONFIG_MEDIA_CONTROLLER=y
CONFIG_MEDIA_CONTROLLER_DVB=y
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2_SUBDEV_API=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
# CONFIG_VIDEO_PCI_SKELETON is not set
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_V4L2_FLASH_LED_CLASS=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_VIDEOBUF2_DMA_SG=y
CONFIG_DVB_CORE=y
# CONFIG_TTPCI_EEPROM is not set
CONFIG_DVB_MAX_ADAPTERS=8
# CONFIG_DVB_DYNAMIC_MINORS is not set

#
# Media drivers
#
CONFIG_RC_CORE=y
# CONFIG_RC_MAP is not set
# CONFIG_RC_DECODERS is not set
# CONFIG_RC_DEVICES is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set
CONFIG_V4L_PLATFORM_DRIVERS=y
CONFIG_VIDEO_CAFE_CCIC=y
CONFIG_SOC_CAMERA=y
CONFIG_SOC_CAMERA_PLATFORM=y
CONFIG_V4L_MEM2MEM_DRIVERS=y
CONFIG_VIDEO_SH_VEU=y
# CONFIG_V4L_TEST_DRIVERS is not set
CONFIG_DVB_PLATFORM_DRIVERS=y

#
# Supported MMC/SDIO adapters
#

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=y
CONFIG_DVB_FIREDTV_INPUT=y

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
CONFIG_VIDEO_OV7670=y

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#

#
# soc_camera sensor drivers
#
# CONFIG_SOC_CAMERA_IMX074 is not set
CONFIG_SOC_CAMERA_MT9M001=y
# CONFIG_SOC_CAMERA_MT9M111 is not set
CONFIG_SOC_CAMERA_MT9T031=y
CONFIG_SOC_CAMERA_MT9T112=y
CONFIG_SOC_CAMERA_MT9V022=y
CONFIG_SOC_CAMERA_OV2640=y
CONFIG_SOC_CAMERA_OV5642=y
CONFIG_SOC_CAMERA_OV6650=y
# CONFIG_SOC_CAMERA_OV772X is not set
CONFIG_SOC_CAMERA_OV9640=y
# CONFIG_SOC_CAMERA_OV9740 is not set
CONFIG_SOC_CAMERA_RJ54N1=y
# CONFIG_SOC_CAMERA_TW9910 is not set
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
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
# CONFIG_DVB_AS102_FE is not set

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
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
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
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
# CONFIG_AGP_INTEL is not set
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_VIA is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y
# CONFIG_DRM is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
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
CONFIG_FB_HECUBA=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_VESA=y
CONFIG_FB_N411=y
# CONFIG_FB_HGA is not set
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
CONFIG_FB_RIVA=y
CONFIG_FB_RIVA_I2C=y
CONFIG_FB_RIVA_DEBUG=y
# CONFIG_FB_RIVA_BACKLIGHT is not set
CONFIG_FB_I740=y
CONFIG_FB_LE80578=y
# CONFIG_FB_CARILLO_RANCH is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
CONFIG_FB_ATY=y
CONFIG_FB_ATY_CT=y
# CONFIG_FB_ATY_GENERIC_LCD is not set
# CONFIG_FB_ATY_GX is not set
CONFIG_FB_ATY_BACKLIGHT=y
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=y
# CONFIG_FB_SIS_300 is not set
CONFIG_FB_SIS_315=y
# CONFIG_FB_VIA is not set
CONFIG_FB_NEOMAGIC=y
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
CONFIG_FB_VOODOO1=y
# CONFIG_FB_VT8623 is not set
CONFIG_FB_TRIDENT=y
# CONFIG_FB_ARK is not set
CONFIG_FB_PM3=y
# CONFIG_FB_CARMINE is not set
CONFIG_FB_SM501=y
CONFIG_FB_IBM_GXT4500=y
CONFIG_FB_VIRTUAL=y
# CONFIG_FB_METRONOME is not set
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
# CONFIG_FB_MB862XX_I2C is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_SIMPLE=y
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_L4F00242T03=y
# CONFIG_LCD_LMS283GF05 is not set
CONFIG_LCD_LTV350QV=y
CONFIG_LCD_ILI922X=y
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
CONFIG_LCD_VGG2432A4=y
# CONFIG_LCD_PLATFORM is not set
# CONFIG_LCD_S6E63M0 is not set
CONFIG_LCD_LD9040=y
CONFIG_LCD_AMS369FG06=y
CONFIG_LCD_LMS501KF03=y
# CONFIG_LCD_HX8357 is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_LM3533=y
# CONFIG_BACKLIGHT_CARILLO_RANCH is not set
# CONFIG_BACKLIGHT_DA903X is not set
CONFIG_BACKLIGHT_DA9052=y
CONFIG_BACKLIGHT_APPLE=y
# CONFIG_BACKLIGHT_PM8941_WLED is not set
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
# CONFIG_BACKLIGHT_ADP5520 is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
# CONFIG_BACKLIGHT_PCF50633 is not set
CONFIG_BACKLIGHT_AAT2870=y
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_TPS65217=y
CONFIG_BACKLIGHT_AS3711=y
CONFIG_BACKLIGHT_GPIO=y
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
CONFIG_VGASTATE=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
# CONFIG_LOGO_LINUX_CLUT224 is not set
CONFIG_SOUND=y
# CONFIG_SOUND_OSS_CORE is not set
# CONFIG_SND is not set
# CONFIG_SOUND_PRIME is not set

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
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_ASUS is not set
CONFIG_HID_AUREAL=y
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
CONFIG_HID_CHICONY=y
CONFIG_HID_CMEDIA=y
CONFIG_HID_CYPRESS=y
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
CONFIG_HID_EZKEY=y
CONFIG_HID_GEMBIRD=y
CONFIG_HID_GFRM=y
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LENOVO=y
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_ORTEK=y
# CONFIG_HID_PANTHERLORD is not set
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
# CONFIG_HID_PICOLCD_CIR is not set
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
CONFIG_HID_RMI=y
# CONFIG_HID_GREENASIA is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=y
# CONFIG_HID_SENSOR_CUSTOM_SENSOR is not set

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
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_TAHVO_USB is not set
# CONFIG_USB_GADGET is not set
CONFIG_UWB=y
CONFIG_UWB_WHCI=y
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_PCA9532=y
# CONFIG_LEDS_PCA9532_GPIO is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP3952=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_LP8788=y
# CONFIG_LEDS_LP8860 is not set
CONFIG_LEDS_CLEVO_MAIL=y
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA963X=y
# CONFIG_LEDS_WM831X_STATUS is not set
# CONFIG_LEDS_WM8350 is not set
CONFIG_LEDS_DA903X=y
# CONFIG_LEDS_DA9052 is not set
# CONFIG_LEDS_DAC124S085 is not set
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
# CONFIG_LEDS_ADP5520 is not set
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_TLC591XX=y
CONFIG_LEDS_LM355x=y
# CONFIG_LEDS_MENF21BMC is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_MTD=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
# CONFIG_LEDS_TRIGGER_CAMERA is not set
CONFIG_LEDS_TRIGGER_PANIC=y
CONFIG_ACCESSIBILITY=y
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_SYSTOHC is not set
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
CONFIG_RTC_INTF_DEV_UIE_EMUL=y
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_88PM860X is not set
CONFIG_RTC_DRV_88PM80X=y
CONFIG_RTC_DRV_ABB5ZES3=y
CONFIG_RTC_DRV_ABX80X=y
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1307_HWMON=y
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1374_WDT=y
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_LP8788=y
CONFIG_RTC_DRV_MAX6900=y
# CONFIG_RTC_DRV_RS5C372 is not set
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=y
CONFIG_RTC_DRV_ISL12057=y
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PCF8523=y
CONFIG_RTC_DRV_PCF85063=y
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_RTC_DRV_PCF8583=y
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_BQ32K is not set
CONFIG_RTC_DRV_TWL4030=y
CONFIG_RTC_DRV_PALMAS=y
# CONFIG_RTC_DRV_TPS6586X is not set
# CONFIG_RTC_DRV_TPS65910 is not set
# CONFIG_RTC_DRV_TPS80031 is not set
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
CONFIG_RTC_DRV_RX8010=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV8803=y
CONFIG_RTC_DRV_S5M=y

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
# CONFIG_RTC_DRV_M41T94 is not set
# CONFIG_RTC_DRV_DS1302 is not set
# CONFIG_RTC_DRV_DS1305 is not set
CONFIG_RTC_DRV_DS1343=y
# CONFIG_RTC_DRV_DS1347 is not set
CONFIG_RTC_DRV_DS1390=y
CONFIG_RTC_DRV_R9701=y
CONFIG_RTC_DRV_RX4581=y
CONFIG_RTC_DRV_RX6110=y
CONFIG_RTC_DRV_RS5C348=y
CONFIG_RTC_DRV_MAX6902=y
CONFIG_RTC_DRV_PCF2123=y
CONFIG_RTC_DRV_MCP795=y
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=y
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_RV3029C2=y
CONFIG_RTC_DRV_RV3029_HWMON=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1685_FAMILY=y
# CONFIG_RTC_DRV_DS1685 is not set
CONFIG_RTC_DRV_DS1689=y
# CONFIG_RTC_DRV_DS17285 is not set
# CONFIG_RTC_DRV_DS17485 is not set
# CONFIG_RTC_DRV_DS17885 is not set
# CONFIG_RTC_DS1685_PROC_REGS is not set
CONFIG_RTC_DS1685_SYSFS_REGS=y
# CONFIG_RTC_DRV_DS1742 is not set
CONFIG_RTC_DRV_DS2404=y
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_DA9063=y
# CONFIG_RTC_DRV_STK17TA8 is not set
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
# CONFIG_RTC_DRV_RP5C01 is not set
# CONFIG_RTC_DRV_V3020 is not set
# CONFIG_RTC_DRV_WM831X is not set
CONFIG_RTC_DRV_WM8350=y
CONFIG_RTC_DRV_PCF50633=y
# CONFIG_RTC_DRV_AB3100 is not set

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_PCAP is not set

#
# HID Sensor RTC drivers
#
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
# CONFIG_UIO_DMEM_GENIRQ is not set
CONFIG_UIO_AEC=y
CONFIG_UIO_SERCOS3=y
# CONFIG_UIO_PCI_GENERIC is not set
CONFIG_UIO_NETX=y
CONFIG_UIO_PRUSS=y
# CONFIG_UIO_MF624 is not set
CONFIG_VFIO_IOMMU_TYPE1=y
CONFIG_VFIO=y
# CONFIG_VFIO_NOIOMMU is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
# CONFIG_VIRTIO_PCI_LEGACY is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_INPUT is not set
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set
CONFIG_RTS5208=y

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16201=y
# CONFIG_ADIS16203 is not set
CONFIG_ADIS16209=y
CONFIG_ADIS16240=y
# CONFIG_SCA3000 is not set

#
# Analog to digital converters
#
# CONFIG_AD7606 is not set
CONFIG_AD7780=y
CONFIG_AD7816=y
CONFIG_AD7192=y
CONFIG_AD7280=y

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
# CONFIG_AD7152 is not set
CONFIG_AD7746=y

#
# Direct Digital Synthesis
#
CONFIG_AD9832=y
CONFIG_AD9834=y

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
# CONFIG_SENSORS_ISL29018 is not set
# CONFIG_SENSORS_ISL29028 is not set
CONFIG_TSL2583=y
CONFIG_TSL2x7x=y

#
# Active energy metering IC
#
# CONFIG_ADE7753 is not set
CONFIG_ADE7754=y
# CONFIG_ADE7758 is not set
CONFIG_ADE7759=y
# CONFIG_ADE7854 is not set

#
# Resolver to digital converters
#
CONFIG_AD2S90=y
CONFIG_AD2S1200=y
CONFIG_AD2S1210=y

#
# Triggers - standalone
#
# CONFIG_FB_SM750 is not set
# CONFIG_FB_XGI is not set

#
# Speakup console speech
#
CONFIG_STAGING_MEDIA=y
CONFIG_MEDIA_CEC=y
CONFIG_MEDIA_CEC_DEBUG=y
CONFIG_DVB_CXD2099=y
CONFIG_VIDEO_TW686X_KH=y

#
# Android
#
# CONFIG_FIREWIRE_SERIAL is not set
CONFIG_MTD_SPINAND_MT29F=y
# CONFIG_MTD_SPINAND_ONDIEECC is not set
CONFIG_DGNC=y
# CONFIG_GS_FPGABOOT is not set
CONFIG_CRYPTO_SKEIN=y
CONFIG_UNISYSSPAR=y
CONFIG_UNISYS_VISORBUS=y
# CONFIG_UNISYS_VISORNIC is not set
# CONFIG_UNISYS_VISORINPUT is not set
CONFIG_UNISYS_VISORHBA=y
# CONFIG_FB_TFT is not set
# CONFIG_MOST is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
# CONFIG_CHROME_PLATFORMS is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
CONFIG_COMMON_CLK_WM831X=y
CONFIG_COMMON_CLK_SI5351=y
CONFIG_COMMON_CLK_CDCE706=y
CONFIG_COMMON_CLK_CS2000_CP=y
CONFIG_COMMON_CLK_S2MPS11=y
CONFIG_CLK_TWL6040=y
# CONFIG_COMMON_CLK_NXP is not set
CONFIG_COMMON_CLK_PALMAS=y
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set
# CONFIG_COMMON_CLK_OXNAS is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
CONFIG_PCC=y
CONFIG_ALTERA_MBOX=y
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
CONFIG_AMD_IOMMU=y
CONFIG_AMD_IOMMU_V2=y
CONFIG_DMAR_TABLE=y
# CONFIG_INTEL_IOMMU is not set
CONFIG_IRQ_REMAP=y

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_SUNXI_SRAM is not set
# CONFIG_SOC_TI is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
CONFIG_DEVFREQ_GOV_USERSPACE=y
# CONFIG_DEVFREQ_GOV_PASSIVE is not set

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
CONFIG_EXTCON_GPIO=y
CONFIG_EXTCON_MAX14577=y
CONFIG_EXTCON_MAX3355=y
CONFIG_EXTCON_MAX77693=y
# CONFIG_EXTCON_PALMAS is not set
CONFIG_EXTCON_RT8973A=y
CONFIG_EXTCON_SM5502=y
CONFIG_EXTCON_USB_GPIO=y
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
# CONFIG_IIO_BUFFER_CB is not set
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
CONFIG_IIO_SW_DEVICE=y
CONFIG_IIO_SW_TRIGGER=y
CONFIG_IIO_TRIGGERED_EVENT=y

#
# Accelerometers
#
# CONFIG_BMA180 is not set
CONFIG_BMA220=y
CONFIG_BMC150_ACCEL=y
CONFIG_BMC150_ACCEL_I2C=y
CONFIG_BMC150_ACCEL_SPI=y
CONFIG_HID_SENSOR_ACCEL_3D=y
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
# CONFIG_KXSD9 is not set
# CONFIG_KXCJK1013 is not set
CONFIG_MMA7455=y
CONFIG_MMA7455_I2C=y
CONFIG_MMA7455_SPI=y
CONFIG_MMA7660=y
# CONFIG_MMA8452 is not set
CONFIG_MMA9551_CORE=y
CONFIG_MMA9551=y
# CONFIG_MMA9553 is not set
CONFIG_MXC4005=y
CONFIG_MXC6255=y
CONFIG_STK8312=y
CONFIG_STK8BA50=y

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
CONFIG_AD7291=y
# CONFIG_AD7298 is not set
CONFIG_AD7476=y
CONFIG_AD7791=y
# CONFIG_AD7793 is not set
CONFIG_AD7887=y
CONFIG_AD7923=y
# CONFIG_AD799X is not set
CONFIG_AXP288_ADC=y
CONFIG_HI8435=y
# CONFIG_INA2XX_ADC is not set
# CONFIG_LP8788_ADC is not set
CONFIG_MAX1027=y
# CONFIG_MAX1363 is not set
CONFIG_MCP320X=y
CONFIG_MCP3422=y
CONFIG_NAU7802=y
CONFIG_PALMAS_GPADC=y
CONFIG_TI_ADC081C=y
CONFIG_TI_ADC0832=y
CONFIG_TI_ADC128S052=y
CONFIG_TI_ADS1015=y
# CONFIG_TI_AM335X_ADC is not set
CONFIG_TWL4030_MADC=y
# CONFIG_TWL6030_GPADC is not set

#
# Amplifiers
#
CONFIG_AD8366=y

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=y
CONFIG_IAQCORE=y
# CONFIG_VZ89X is not set

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_IIO_TRIGGER=y
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
# CONFIG_IIO_SSP_SENSORHUB is not set
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
CONFIG_AD5446=y
# CONFIG_AD5449 is not set
CONFIG_AD5592R_BASE=y
CONFIG_AD5592R=y
CONFIG_AD5593R=y
CONFIG_AD5504=y
# CONFIG_AD5624R_SPI is not set
# CONFIG_AD5686 is not set
CONFIG_AD5755=y
CONFIG_AD5761=y
CONFIG_AD5764=y
CONFIG_AD5791=y
CONFIG_AD7303=y
CONFIG_M62332=y
CONFIG_MAX517=y
# CONFIG_MCP4725 is not set
# CONFIG_MCP4922 is not set
CONFIG_STX104=y

#
# IIO dummy driver
#
CONFIG_IIO_SIMPLE_DUMMY=y
# CONFIG_IIO_SIMPLE_DUMMY_EVENTS is not set
# CONFIG_IIO_SIMPLE_DUMMY_BUFFER is not set

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
# CONFIG_AD9523 is not set

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=y

#
# Digital gyroscope sensors
#
CONFIG_ADIS16080=y
# CONFIG_ADIS16130 is not set
CONFIG_ADIS16136=y
CONFIG_ADIS16260=y
CONFIG_ADXRS450=y
# CONFIG_BMG160 is not set
CONFIG_HID_SENSOR_GYRO_3D=y
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
CONFIG_IIO_ST_GYRO_SPI_3AXIS=y
# CONFIG_ITG3200 is not set

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4403=y
# CONFIG_AFE4404 is not set
# CONFIG_MAX30100 is not set

#
# Humidity sensors
#
CONFIG_AM2315=y
# CONFIG_DHT11 is not set
CONFIG_HDC100X=y
CONFIG_HTU21=y
CONFIG_SI7005=y
# CONFIG_SI7020 is not set

#
# Inertial measurement units
#
CONFIG_ADIS16400=y
CONFIG_ADIS16480=y
CONFIG_BMI160=y
CONFIG_BMI160_I2C=y
CONFIG_BMI160_SPI=y
CONFIG_KMX61=y
# CONFIG_INV_MPU6050_I2C is not set
# CONFIG_INV_MPU6050_SPI is not set
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
CONFIG_ACPI_ALS=y
CONFIG_ADJD_S311=y
CONFIG_AL3320A=y
CONFIG_APDS9300=y
# CONFIG_APDS9960 is not set
CONFIG_BH1750=y
CONFIG_BH1780=y
CONFIG_CM32181=y
CONFIG_CM3232=y
# CONFIG_CM3323 is not set
CONFIG_CM36651=y
# CONFIG_GP2AP020A00F is not set
CONFIG_ISL29125=y
CONFIG_HID_SENSOR_ALS=y
# CONFIG_HID_SENSOR_PROX is not set
CONFIG_JSA1212=y
# CONFIG_RPR0521 is not set
CONFIG_SENSORS_LM3533=y
CONFIG_LTR501=y
CONFIG_MAX44000=y
CONFIG_OPT3001=y
# CONFIG_PA12203001 is not set
# CONFIG_STK3310 is not set
CONFIG_TCS3414=y
CONFIG_TCS3472=y
CONFIG_SENSORS_TSL2563=y
CONFIG_TSL4531=y
CONFIG_US5182D=y
CONFIG_VCNL4000=y
CONFIG_VEML6070=y

#
# Magnetometer sensors
#
CONFIG_AK8975=y
CONFIG_AK09911=y
CONFIG_BMC150_MAGN=y
# CONFIG_BMC150_MAGN_I2C is not set
CONFIG_BMC150_MAGN_SPI=y
CONFIG_MAG3110=y
# CONFIG_HID_SENSOR_MAGNETOMETER_3D is not set
# CONFIG_MMC35240 is not set
# CONFIG_IIO_ST_MAGN_3AXIS is not set
CONFIG_SENSORS_HMC5843=y
CONFIG_SENSORS_HMC5843_I2C=y
# CONFIG_SENSORS_HMC5843_SPI is not set

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=y
CONFIG_HID_SENSOR_DEVICE_ROTATION=y

#
# Triggers - standalone
#
# CONFIG_IIO_HRTIMER_TRIGGER is not set
CONFIG_IIO_INTERRUPT_TRIGGER=y
CONFIG_IIO_TIGHTLOOP_TRIGGER=y
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Digital potentiometers
#
CONFIG_DS1803=y
CONFIG_MAX5487=y
# CONFIG_MCP4131 is not set
# CONFIG_MCP4531 is not set
CONFIG_TPL0102=y

#
# Pressure sensors
#
CONFIG_HID_SENSOR_PRESS=y
CONFIG_HP03=y
CONFIG_MPL115=y
# CONFIG_MPL115_I2C is not set
CONFIG_MPL115_SPI=y
# CONFIG_MPL3115 is not set
CONFIG_MS5611=y
CONFIG_MS5611_I2C=y
CONFIG_MS5611_SPI=y
# CONFIG_MS5637 is not set
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_IIO_ST_PRESS_SPI=y
CONFIG_T5403=y
CONFIG_HP206C=y

#
# Lightning sensors
#
CONFIG_AS3935=y

#
# Proximity sensors
#
CONFIG_LIDAR_LITE_V2=y
CONFIG_SX9500=y

#
# Temperature sensors
#
# CONFIG_MLX90614 is not set
CONFIG_TMP006=y
CONFIG_TSYS01=y
CONFIG_TSYS02D=y
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
CONFIG_SERIAL_IPOCTAL=y
CONFIG_RESET_CONTROLLER=y
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_PHY_PXA_28NM_HSIC is not set
CONFIG_PHY_PXA_28NM_USB2=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=y
# CONFIG_MCB is not set

#
# Performance monitor support
#
# CONFIG_RAS is not set
CONFIG_THUNDERBOLT=y

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_LIBNVDIMM is not set
CONFIG_NVMEM=y
CONFIG_STM=y
CONFIG_STM_DUMMY=y
CONFIG_STM_SOURCE_CONSOLE=y
# CONFIG_STM_SOURCE_HEARTBEAT is not set
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
CONFIG_INTEL_TH_GTH=y
CONFIG_INTEL_TH_STH=y
CONFIG_INTEL_TH_MSU=y
# CONFIG_INTEL_TH_PTI is not set
# CONFIG_INTEL_TH_DEBUG is not set

#
# FPGA Configuration Support
#
CONFIG_FPGA=y
# CONFIG_FPGA_MGR_ZYNQ_FPGA is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
# CONFIG_FIRMWARE_MEMMAP is not set
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
# CONFIG_DMIID is not set
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=y
CONFIG_FW_CFG_SYSFS=y
# CONFIG_FW_CFG_SYSFS_CMDLINE is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
CONFIG_GOOGLE_MEMCONSOLE=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
# CONFIG_EXT2_FS is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
# CONFIG_EXT4_USE_FOR_EXT2 is not set
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_ENCRYPTION=y
CONFIG_EXT4_FS_ENCRYPTION=y
CONFIG_EXT4_DEBUG=y
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
CONFIG_JFS_FS=y
CONFIG_JFS_POSIX_ACL=y
# CONFIG_JFS_SECURITY is not set
# CONFIG_JFS_DEBUG is not set
CONFIG_JFS_STATISTICS=y
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
CONFIG_XFS_DEBUG=y
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
# CONFIG_BTRFS_FS_POSIX_ACL is not set
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
CONFIG_BTRFS_ASSERT=y
CONFIG_NILFS2_FS=y
CONFIG_F2FS_FS=y
# CONFIG_F2FS_STAT_FS is not set
# CONFIG_F2FS_FS_XATTR is not set
CONFIG_F2FS_CHECK_FS=y
# CONFIG_F2FS_FAULT_INJECTION is not set
# CONFIG_FS_DAX is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
# CONFIG_PRINT_QUOTA_WARNING is not set
CONFIG_QUOTA_DEBUG=y
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
# CONFIG_FUSE_FS is not set
CONFIG_OVERLAY_FS=y

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
CONFIG_FSCACHE_OBJECT_LIST=y
# CONFIG_CACHEFILES is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
CONFIG_ZISOFS=y
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_FAT_DEFAULT_UTF8=y
CONFIG_NTFS_FS=y
CONFIG_NTFS_DEBUG=y
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
# CONFIG_PROC_VMCORE is not set
# CONFIG_PROC_SYSCTL is not set
# CONFIG_PROC_PAGE_MONITOR is not set
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
CONFIG_ADFS_FS=y
CONFIG_ADFS_FS_RW=y
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=y
CONFIG_ECRYPT_FS_MESSAGING=y
CONFIG_HFS_FS=y
CONFIG_HFSPLUS_FS=y
CONFIG_HFSPLUS_FS_POSIX_ACL=y
CONFIG_BEFS_FS=y
CONFIG_BEFS_DEBUG=y
CONFIG_BFS_FS=y
CONFIG_EFS_FS=y
# CONFIG_JFFS2_FS is not set
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=y
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_FILE_CACHE=y
# CONFIG_SQUASHFS_FILE_DIRECT is not set
# CONFIG_SQUASHFS_DECOMP_SINGLE is not set
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU=y
CONFIG_SQUASHFS_XATTR=y
# CONFIG_SQUASHFS_ZLIB is not set
# CONFIG_SQUASHFS_LZ4 is not set
# CONFIG_SQUASHFS_LZO is not set
# CONFIG_SQUASHFS_XZ is not set
CONFIG_SQUASHFS_4K_DEVBLK_SIZE=y
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
CONFIG_MINIX_FS=y
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
CONFIG_QNX6FS_FS=y
CONFIG_QNX6FS_DEBUG=y
# CONFIG_ROMFS_FS is not set
# CONFIG_PSTORE is not set
CONFIG_SYSV_FS=y
CONFIG_UFS_FS=y
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
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
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=8192
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_STACK_VALIDATION=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_SLUB_DEBUG_ON=y
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
CONFIG_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_KASAN=y
# CONFIG_KASAN_OUTLINE is not set
CONFIG_KASAN_INLINE=y
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_WQ_WATCHDOG=y
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHED_INFO is not set
# CONFIG_SCHEDSTATS is not set
CONFIG_SCHED_STACK_END_CHECK=y
CONFIG_DEBUG_TIMEKEEPING=y
# CONFIG_TIMER_STATS is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
# CONFIG_PROVE_RCU_REPEATEDLY is not set
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT is not set
CONFIG_RCU_TORTURE_TEST_SLOW_INIT=y
CONFIG_RCU_TORTURE_TEST_SLOW_INIT_DELAY=3
CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP=y
CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP_DELAY=3
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_CPU_NOTIFIER_ERROR_INJECT=y
# CONFIG_PM_NOTIFIER_ERROR_INJECT is not set
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
CONFIG_FAULT_INJECTION=y
CONFIG_FAILSLAB=y
# CONFIG_FAIL_PAGE_ALLOC is not set
# CONFIG_FAIL_MAKE_REQUEST is not set
# CONFIG_FAIL_IO_TIMEOUT is not set
# CONFIG_FAIL_FUTEX is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=y
CONFIG_TEST_PRINTF=y
CONFIG_TEST_BITMAP=y
CONFIG_TEST_UUID=y
# CONFIG_TEST_RHASHTABLE is not set
CONFIG_TEST_HASH=y
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_FIRMWARE=y
CONFIG_TEST_UDELAY=y
CONFIG_MEMTEST=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_WX=y
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
CONFIG_IOMMU_STRESS=y
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
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
CONFIG_PUNIT_ATOM_DEBUG=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
# CONFIG_BIG_KEYS is not set
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEY_DH_OPERATIONS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
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
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

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
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA1_MB=y
# CONFIG_CRYPTO_SHA256_MB is not set
CONFIG_CRYPTO_SHA512_MB=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_SHA3 is not set
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
# CONFIG_CRYPTO_LZ4 is not set
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
# CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
CONFIG_SYSTEM_EXTRA_CERTIFICATE=y
CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE=4096
CONFIG_SECONDARY_TRUSTED_KEYRING=y
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
# CONFIG_CRC_CCITT is not set
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
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
# CONFIG_XZ_DEC is not set
# CONFIG_XZ_DEC_BCJ is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
CONFIG_DDR=y
# CONFIG_IRQ_POLL is not set
CONFIG_MPILIB=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_STACKDEPOT=y

--=_57ac048b.1M/X76gU08iKtlBZ1ywCY7GkGh/S0xQOFidVjCGQh3XtIpBv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
