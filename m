Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7666B0069
	for <linux-mm@kvack.org>; Sun,  9 Oct 2016 00:32:38 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ry6so66911734pac.1
        for <linux-mm@kvack.org>; Sat, 08 Oct 2016 21:32:38 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i7si24864899pae.320.2016.10.08.21.32.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Oct 2016 21:32:37 -0700 (PDT)
Date: Sun, 09 Oct 2016 12:31:42 +0800
From: kernel test robot <fengguang.wu@intel.com>
Subject: [mm, kasan] 80a9201a59:  INFO: rcu_sched stall on CPU (84741
 ticks this GP) idle=140000000000000 (t=100000 jiffies q=1)
Message-ID: <57f9c82e.wswaLjJd7sV05RiZ%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_57f9c82e.mU3ivv+KD5t+0FDAsYsOxh+p+AcGJ4qzf1FPOeQscGek4iug"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.comLinux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com

This is a multi-part message in MIME format.

--=_57f9c82e.mU3ivv+KD5t+0FDAsYsOxh+p+AcGJ4qzf1FPOeQscGek4iug
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

+----------------------------------------------------------------------------+------------+------------+------------+
|                                                                            | c146a2b98e | 80a9201a59 | a61bc9c9af |
+----------------------------------------------------------------------------+------------+------------+------------+
| boot_successes                                                             | 655        | 86         | 9          |
| boot_failures                                                              | 0          | 139        | 16         |
| INFO:rcu_sched_stall_on_CPU(#ticks_this_GP)idle=#(t=#jiffies_q=#)          | 0          | 139        | 10         |
| calltrace:mark_rodata_ro                                                   | 0          | 139        | 14         |
| Kernel_panic-not_syncing:VFS:Unable_to_mount_root_fs_on_unknown-block(#,#) | 0          | 0          | 2          |
| calltrace:prepare_namespace                                                | 0          | 0          | 2          |
| WARNING:at_arch/x86/mm/dump_pagetables.c:#note_page                        | 0          | 0          | 6          |
+----------------------------------------------------------------------------+------------+------------+------------+

[   14.024541] Write protecting the kernel read-only data: 18432k
[   14.030857] Freeing unused kernel memory: 1936K (ffff88000e81c000 - ffff88000ea00000)
[   14.043192] Freeing unused kernel memory: 248K (ffff88000efc2000 - ffff88000f000000)
[  114.005845] INFO: rcu_sched stall on CPU (84741 ticks this GP) idle=140000000000000 (t=100000 jiffies q=1)
[  114.009928] CPU: 0 PID: 1 Comm: swapper Not tainted 4.7.0-05999-g80a9201 #1
[  114.011362] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[  114.013154]  0000000000000000 ffffffffacc40db8 ffffffffabfc7274 ffffffffacc40df8
[  114.014763]  ffffffffabae00ec 0000000000000001 0000000000000000 0000000000000000
[  114.016378]  00000019dcf1a68b ffffffffacc40f18 fffffffface7e488 ffffffffacc40e18
[  114.017988] Call Trace:
[  114.018504]  <IRQ>  [<ffffffffabfc7274>] dump_stack+0x19/0x1b
[  114.019739]  [<ffffffffabae00ec>] check_cpu_stall+0xc0/0x124
[  114.021041]  [<ffffffffabae0283>] rcu_check_callbacks+0x50/0xa0
[  114.022263]  [<ffffffffabae62fe>] update_process_times+0x2e/0x52
[  114.023503]  [<ffffffffabaf8f5f>] tick_sched_handle+0x66/0x6d
[  114.024813]  [<ffffffffabaf8fa3>] tick_sched_timer+0x3d/0x78
[  114.025977]  [<ffffffffabae733d>] __hrtimer_run_queues+0x252/0x45b
[  114.027461]  [<ffffffffabaf8f66>] ? tick_sched_handle+0x6d/0x6d
[  114.028793]  [<ffffffffabae70eb>] ? hrtimer_start_range_ns+0x315/0x315
[  114.030130]  [<ffffffffaba29b24>] ? kvm_clock_get_cycles+0x9/0xb
[  114.031367]  [<ffffffffabaf1120>] ? ktime_get_update_offsets_now+0xf1/0x184
[  114.032784]  [<ffffffffabae76d4>] hrtimer_interrupt+0x8c/0x189
[  114.033983]  [<ffffffffaba1f190>] local_apic_timer_interrupt+0x42/0x44
[  114.035337]  [<ffffffffac417ba8>] smp_apic_timer_interrupt+0x55/0x66
[  114.036636]  [<ffffffffac416b6d>] apic_timer_interrupt+0x7d/0x90
[  114.037864]  <EOI>  [<ffffffffaba37538>] ? note_page+0x2b/0x7af
[  114.039125]  [<ffffffffaba375db>] ? note_page+0xce/0x7af
[  114.040219]  [<ffffffffaba37fff>] ptdump_walk_pgd_level_core+0x343/0x483
[  114.041583]  [<ffffffffaba37cbc>] ? note_page+0x7af/0x7af
[  114.042577]  [<ffffffffaba38168>] ptdump_walk_pgd_level_checkwx+0x17/0x2f
[  114.043639]  [<ffffffffaba2dc93>] mark_rodata_ro+0x14b/0x152
[  114.044545]  [<ffffffffac40ce10>] kernel_init+0x29/0x100
[  114.045393]  [<ffffffffac4162df>] ret_from_fork+0x1f/0x40
[  114.046252]  [<ffffffffac40cde7>] ? rest_init+0xce/0xce
[  118.107577] x86/mm: Checked W+X mappings: passed, no W+X pages found.
[  118.113902] rcu-torture: rtc: ffffffffaddea720 ver: 1 tfle: 0 rta: 1 rtaf: 0 rtf: 0 rtmbe: 0 rtbke: 0 rtbre: 0 rtbf: 0 rtb: 0 nt: 1 barrier: 0/0:0 cbflood: 1

git bisect start v4.8 v4.7 --
git bisect  bad e6e7214fbbdab1f90254af68e0927bdb24708d22  # 07:46      9-      9  Merge branch 'sched-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect  bad ba929b6646c5b87c7bb15cd8d3e51617725c983b  # 08:00     14-      7  Merge branch 'for-linus-4.8' of git://git.kernel.org/pub/scm/linux/kernel/git/mason/linux-btrfs
git bisect good 468fc7ed5537615efe671d94248446ac24679773  # 08:21    219+      2  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
git bisect  bad e55884d2c6ac3ae50e49a1f6fe38601a91181719  # 08:34     17-      7  Merge tag 'vfio-v4.8-rc1' of git://github.com/awilliam/linux-vfio
git bisect good 554828ee0db41618d101d9549db8808af9fd9d65  # 08:47    220+      0  Merge branch 'salted-string-hash'
git bisect good ce8c891c3496d3ea4a72ec40beac9a7b7f6649bf  # 09:07    225+      0  Merge tag 'rproc-v4.8' of git://github.com/andersson/remoteproc
git bisect  bad 1c88e19b0f6a8471ee50d5062721ba30b8fd4ba9  # 09:20      2-      3  Merge branch 'akpm' (patches from Andrew)
git bisect good c9b011a87dd49bac1632311811c974bb7cd33c25  # 09:39    225+      1  Merge tag 'hwlock-v4.8' of git://github.com/andersson/remoteproc
git bisect good 6039b80eb50a893476fea7d56e86ed2d19290054  # 10:02    216+      1  Merge tag 'dmaengine-4.8-rc1' of git://git.infradead.org/users/vkoul/slave-dma
git bisect good bca6759258dbef378bcf5b872177bcd2259ceb68  # 10:20    224+      0  mm, vmstat: remove zone and node double accounting by approximating retries
git bisect good efdc94907977d2db84b4b00cb9bd98ca011f6819  # 10:33    225+      0  mm: fix memcg stack accounting for sub-page stacks
git bisect good fb399b4854d2159a4d23fbfbd7daaed914fd54fa  # 10:46    225+      1  mm/memblock.c: fix index adjustment error in __next_mem_range_rev()
git bisect  bad 31a6c1909f51dbe9bf08eb40dc64e3db90cf6f79  # 11:00      6-      6  mm, page_alloc: set alloc_flags only once in slowpath
git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 11:14    215+      0  mm, kasan: account for object redzone in SLUB's nearest_obj()
git bisect  bad 87cc271d5e4320d705cfdf59f68d4d037b3511b2  # 11:24     14-      5  lib/stackdepot.c: use __GFP_NOWARN for stack allocations
git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 11:36      1-      1  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
# first bad commit: [80a9201a5965f4715d5c09790862e0df84ce0614] mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 11:52    655+      0  mm, kasan: account for object redzone in SLUB's nearest_obj()
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 12:11      8-      5  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
# extra tests on HEAD of linux-devel/devel-spot-201610090613
git bisect  bad a61bc9c9af01517642ddecff8d6f2425baf33e61  # 12:12      0-     16  0day head guard for 'devel-spot-201610090613'
# extra tests on tree/branch linus/master
git bisect  bad b66484cd74706fa8681d051840fe4b18a3da40ff  # 12:29      6-      2  Merge branch 'akpm' (patches from Andrew)
# extra tests on tree/branch linus/master
git bisect  bad b66484cd74706fa8681d051840fe4b18a3da40ff  # 12:30      0-      2  Merge branch 'akpm' (patches from Andrew)
# extra tests on tree/branch linux-next/master
git bisect  bad c802e87fbe2d4dd58982d01b3c39bc5a781223aa  # 12:31      0-      1  Add linux-next specific files for 20161006


---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_57f9c82e.mU3ivv+KD5t+0FDAsYsOxh+p+AcGJ4qzf1FPOeQscGek4iug
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-quantal-kbuild-8:20161009034259:x86_64-randconfig-u0-10090618:4.7.0-05999-g80a9201:1.gz"

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
bfaf1zbrDVvfQyCRM5TeDXMr5nSJH5+qPFwDO6LbS0zeS5JhkmzElPuvNsEWnWm1CTBfzz1N
wDdsAi62bwJ0qG5U1w7698Z1mS3rwhhWnsjNKtu2H5WZYzeqbNs5CSs7SU43qkxs2z0eVdm2
M1JoRrNZZbvoIBtXtsXs9/hm3E1v3FAy/d+UbBddf1PJZLJlZbgTBJOy2Ky2befGx7SjkTuo
TG44X5ldjGqd8M0q28VA27iyXUwhsI5vVtkuRvWLTSvbxahWm1a2i1F9yjfrjXaLcVYpYZi3
uFC4OL9DCZOP0EPtFqvsGuU4SV7dwZR4DFNbzH8Y5t1aYJIcvVFVW0wR8aGAsKX8/0/btTW3
bSzpd/0KnKcjp0B57hfVZrOSZafOnkp8KnYqteVSaUEAlLiiSC1Jyfb++u0GiRlIwMyQIaOk
IIpGfz3T093Tc+1eo6AfhvrTfep/gA30G4XJi8tAo5hVaXYu1AEu56+T1KGuaa+eUh9jGHV0
ERxjeHvsQpmj+LpjF+oYI4pdB2bmAB/210nggOhrc95x/Z3QxyUwhCLU33bkeoCP3ZwOHKME
oPr0wyOKoEZ5jGqSU5bfL4uH2YrmLJ983clcDhDBX9cuhzj87QnJ8/bDaIIZlzaXnO7E/ADH
7puHohTopnkuLgVtmicXOaU5Ffm9prlmuea5FrmWuVa51rm2ub7I9WWu3+X6Ktfvc/0hNyQ3
73LzPjcfcnuZ23e5vcrt+9x+yC94fiHyC5lfqPziXX5xlV/q/NLklza/svl7lkPFRT5Dxixf
7aYP5gD3WT4+neOuzfNvRuXP9ZyQDx8mxQPI4AO8B7/U+fZyufMc1QIfFB8MHxwfAh8SHwof
Gh8GHxYfl/h4h48rfLzHx4cc1Q4fCEURhSIZRTKKZPQCHgxpOcJzpNX4SSMjjX8aBDD4yeJ3
9sNJVFY4w80IHiakShw0T96gqCZp4BHm7gHNcOiWzaFlMlw0l6YfqUyKaHrYKmKDwqQ+Xpmg
fuqwtSNAsTBoNMdZRUQ0bphf40aDHE22uxZHt8vi8W5arl6t3TFLw2t3TDtkoc2Bq3eIIik3
x1mfRDRthD3YeqxRQh9nDZ5hZm3L+IHWgwm0paBH0gpMcUmba9Gnj9kppzS+hUXz3r0RDQaY
oHDrg/N6vb2z7JU2cWITK8GAxTE9mqsddhWrYlL3kKCg99PmRsfx9+zz+99+2dzpMGthpFbs
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

--=_57f9c82e.mU3ivv+KD5t+0FDAsYsOxh+p+AcGJ4qzf1FPOeQscGek4iug
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
CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
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
CONFIG_SWAP=y
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
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
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
CONFIG_IRQ_TIME_ACCOUNTING=y
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_NMI_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
# CONFIG_MEMCG_SWAP is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CGROUP_WRITEBACK=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CPUSETS=y
# CONFIG_PROC_PID_CPUSET is not set
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_DEBUG=y
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_MULTIUSER=y
# CONFIG_SGETMASK_SYSCALL is not set
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_ABSOLUTE_PERCPU is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_ADVISE_SYSCALLS=y
# CONFIG_USERFAULTFD is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_MEMBARRIER is not set
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
# CONFIG_VM_EVENT_COUNTERS is not set
# CONFIG_SLUB_DEBUG is not set
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLAB_FREELIST_RANDOM=y
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
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
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
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
# CONFIG_ISA_BUS_API is not set
# CONFIG_CPU_NO_EFFICIENT_FFS is not set

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
CONFIG_MODULE_SRCVERSION_ALL=y
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_THROTTLING is not set
# CONFIG_BLK_CMDLINE_PARSER is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
CONFIG_AIX_PARTITION=y
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
# CONFIG_MSDOS_PARTITION is not set
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
# CONFIG_EFI_PARTITION is not set
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_DEADLINE is not set
# CONFIG_IOSCHED_CFQ is not set
CONFIG_DEFAULT_NOOP=y
CONFIG_DEFAULT_IOSCHED="noop"
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
# CONFIG_X86_X2APIC is not set
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_IOSF_MBI=y
CONFIG_IOSF_MBI_DEBUG=y
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
# CONFIG_CPU_SUP_CENTAUR is not set
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_CALGARY_IOMMU=y
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=m
CONFIG_X86_MSR=m
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_X86_DIRECT_GBPAGES=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
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
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
# CONFIG_COMPACTION is not set
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_CMA is not set
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_ZPOOL=y
CONFIG_ZBUD=m
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=m
CONFIG_PGTABLE_MAPPING=y
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_FRAME_VECTOR=y
# CONFIG_X86_PMEM_LEGACY is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
# CONFIG_X86_SMAP is not set
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
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
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_REV_OVERRIDE_POSSIBLE is not set
CONFIG_ACPI_EC_DEBUGFS=y
# CONFIG_ACPI_AC is not set
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=m
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=m
CONFIG_ACPI_IPMI=m
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
# CONFIG_ACPI_THERMAL is not set
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_DEBUG=y
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_NFIT is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_EINJ=y
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set

#
# Memory power savings
#
# CONFIG_I7300_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
CONFIG_PCI_CNB20LE_QUIRK=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=m
# CONFIG_HT_IRQ is not set
CONFIG_PCI_ATS=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
CONFIG_PCI_HYPERV=m
# CONFIG_HOTPLUG_PCI is not set

#
# PCI host controller drivers
#
# CONFIG_PCIE_DW_PLAT is not set
# CONFIG_ISA_BUS is not set
# CONFIG_ISA_DMA_API is not set
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
# CONFIG_CARDBUS is not set

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
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
# CONFIG_SOCK_CGROUP_DATA is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set

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
# CONFIG_RFKILL_REGULATOR is not set
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
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_FENCE_TRACE=y

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
# CONFIG_MTD_TESTS is not set
CONFIG_MTD_REDBOOT_PARTS=m
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
CONFIG_MTD_CMDLINE_PARTS=m
# CONFIG_MTD_OF_PARTS is not set
CONFIG_MTD_AR7_PARTS=m

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=m
CONFIG_MTD_BLOCK_RO=m
CONFIG_FTL=m
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
# CONFIG_INFTL is not set
CONFIG_RFD_FTL=m
CONFIG_SSFDC=y
CONFIG_SM_FTL=y
CONFIG_MTD_OOPS=m
CONFIG_MTD_SWAP=m
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=m
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
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
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=m
CONFIG_MTD_ROM=m
CONFIG_MTD_ABSENT=m

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
CONFIG_MTD_PHYSMAP_OF=m
CONFIG_MTD_PHYSMAP_OF_VERSATILE=y
CONFIG_MTD_AMD76XROM=y
CONFIG_MTD_ICHXROM=m
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
CONFIG_MTD_SCB2_FLASH=y
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=m
CONFIG_MTD_INTEL_VR_NOR=y
CONFIG_MTD_PLATRAM=m

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=m
CONFIG_MTD_PMC551_BUGFIX=y
# CONFIG_MTD_PMC551_DEBUG is not set
CONFIG_MTD_SLRAM=m
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
# CONFIG_MTD_NAND is not set
# CONFIG_MTD_ONENAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=m
CONFIG_MTD_QINFO_PROBE=m
# CONFIG_MTD_SPI_NOR is not set
# CONFIG_MTD_UBI is not set
CONFIG_OF=y
# CONFIG_OF_UNITTEST is not set
CONFIG_OF_DYNAMIC=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_ADDRESS_PCI=y
CONFIG_OF_IRQ=y
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
CONFIG_OF_MTD=y
CONFIG_OF_RESOLVE=y
CONFIG_OF_OVERLAY=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=m
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=m
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
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
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
CONFIG_BLK_DEV_NVME_SCSI=y
CONFIG_NVME_TARGET=m
# CONFIG_NVME_TARGET_LOOP is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=m
CONFIG_DUMMY_IRQ=m
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
CONFIG_SGI_IOC4=y
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=m
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
CONFIG_SENSORS_BH1770=m
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=m
CONFIG_DS1682=y
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
CONFIG_USB_SWITCH_FSA9480=m
CONFIG_SRAM=y
CONFIG_PANEL=m
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
# CONFIG_PANEL_CHANGE_MESSAGE is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=m
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
CONFIG_ALTERA_STAPL=m
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=m
CONFIG_INTEL_MEI_TXE=y
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#
CONFIG_INTEL_MIC_BUS=m

#
# SCIF Bus Driver
#
CONFIG_SCIF_BUS=m

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

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
# CONFIG_GENWQE is not set
CONFIG_ECHO=m
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_KERNEL_API is not set
# CONFIG_CXL_EEH is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_NETLINK is not set
# CONFIG_SCSI_MQ_DEFAULT is not set
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
# CONFIG_BLK_DEV_SR is not set
# CONFIG_CHR_DEV_SG is not set
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=m
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=m
# CONFIG_SCSI_LOWLEVEL is not set
# CONFIG_SCSI_DH is not set
CONFIG_SCSI_OSD_INITIATOR=m
# CONFIG_SCSI_OSD_ULD is not set
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
# CONFIG_ATA_VERBOSE_ERROR is not set
# CONFIG_ATA_ACPI is not set
# CONFIG_SATA_PMP is not set

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
CONFIG_SATA_AHCI_PLATFORM=m
CONFIG_AHCI_CEVA=y
# CONFIG_AHCI_QORIQ is not set
CONFIG_SATA_INIC162X=m
CONFIG_SATA_ACARD_AHCI=m
CONFIG_SATA_SIL24=y
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
CONFIG_SATA_QSTOR=y
# CONFIG_SATA_SX4 is not set
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
CONFIG_SATA_MV=m
CONFIG_SATA_NV=y
# CONFIG_SATA_PROMISE is not set
CONFIG_SATA_SIL=y
CONFIG_SATA_SIS=y
# CONFIG_SATA_SVW is not set
CONFIG_SATA_ULI=m
# CONFIG_SATA_VIA is not set
CONFIG_SATA_VITESSE=y

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=m
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
CONFIG_PATA_ATIIXP=y
CONFIG_PATA_ATP867X=y
# CONFIG_PATA_CMD64X is not set
CONFIG_PATA_CYPRESS=y
# CONFIG_PATA_EFAR is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
CONFIG_PATA_HPT3X2N=y
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_IT821X is not set
CONFIG_PATA_JMICRON=y
CONFIG_PATA_MARVELL=m
CONFIG_PATA_NETCELL=y
CONFIG_PATA_NINJA32=y
CONFIG_PATA_NS87415=m
CONFIG_PATA_OLDPIIX=m
CONFIG_PATA_OPTIDMA=y
# CONFIG_PATA_PDC2027X is not set
CONFIG_PATA_PDC_OLD=y
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_SCH is not set
# CONFIG_PATA_SERVERWORKS is not set
CONFIG_PATA_SIL680=m
CONFIG_PATA_SIS=y
CONFIG_PATA_TOSHIBA=y
CONFIG_PATA_TRIFLEX=y
CONFIG_PATA_VIA=m
CONFIG_PATA_WINBOND=y

#
# PIO-only SFF controllers
#
CONFIG_PATA_CMD640_PCI=y
CONFIG_PATA_MPIIX=y
CONFIG_PATA_NS87410=y
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_PLATFORM is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_ATA_GENERIC is not set
CONFIG_PATA_LEGACY=y
CONFIG_MD=y
CONFIG_BLK_DEV_MD=m
# CONFIG_MD_LINEAR is not set
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
# CONFIG_MD_MULTIPATH is not set
# CONFIG_MD_FAULTY is not set
CONFIG_BCACHE=y
CONFIG_BCACHE_DEBUG=y
# CONFIG_BCACHE_CLOSURES_DEBUG is not set
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_MQ_DEFAULT is not set
CONFIG_DM_DEBUG=y
CONFIG_DM_BUFIO=m
# CONFIG_DM_DEBUG_BLOCK_STACK_TRACING is not set
CONFIG_DM_BIO_PRISON=m
CONFIG_DM_PERSISTENT_DATA=m
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
# CONFIG_DM_THIN_PROVISIONING is not set
CONFIG_DM_CACHE=m
# CONFIG_DM_CACHE_SMQ is not set
CONFIG_DM_CACHE_CLEANER=m
# CONFIG_DM_ERA is not set
# CONFIG_DM_MIRROR is not set
CONFIG_DM_RAID=m
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
CONFIG_DM_MULTIPATH_QL=m
CONFIG_DM_MULTIPATH_ST=m
CONFIG_DM_DELAY=m
# CONFIG_DM_UEVENT is not set
CONFIG_DM_FLAKEY=m
CONFIG_DM_VERITY=m
CONFIG_DM_VERITY_FEC=y
CONFIG_DM_SWITCH=m
CONFIG_DM_LOG_WRITES=m
CONFIG_TARGET_CORE=m
CONFIG_TCM_IBLOCK=m
CONFIG_TCM_FILEIO=m
# CONFIG_TCM_PSCSI is not set
CONFIG_LOOPBACK_TARGET=m
# CONFIG_ISCSI_TARGET is not set
CONFIG_SBP_TARGET=m
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
CONFIG_FIREWIRE_SBP2=m
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
# CONFIG_NETDEVICES is not set
# CONFIG_VHOST_NET is not set
# CONFIG_VHOST_SCSI is not set
CONFIG_VHOST_CROSS_ENDIAN_LEGACY=y
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=m
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
CONFIG_INPUT_EVDEV=m
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
CONFIG_KEYBOARD_ADP5588=m
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=m
CONFIG_KEYBOARD_LKKBD=m
CONFIG_KEYBOARD_GPIO=y
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_MATRIX=y
# CONFIG_KEYBOARD_LM8323 is not set
CONFIG_KEYBOARD_LM8333=m
CONFIG_KEYBOARD_MAX7359=y
CONFIG_KEYBOARD_MCS=m
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=m
CONFIG_KEYBOARD_OPENCORES=m
CONFIG_KEYBOARD_SAMSUNG=m
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_STMPE=m
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CAP11XX is not set
# CONFIG_KEYBOARD_BCM is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
CONFIG_TOUCHSCREEN_AD7879=m
CONFIG_TOUCHSCREEN_AD7879_I2C=m
CONFIG_TOUCHSCREEN_AR1021_I2C=m
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_TOUCHSCREEN_AUO_PIXCIR=y
CONFIG_TOUCHSCREEN_BU21013=m
# CONFIG_TOUCHSCREEN_CHIPONE_ICN8318 is not set
CONFIG_TOUCHSCREEN_CY8CTMG110=y
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
CONFIG_TOUCHSCREEN_DA9052=m
CONFIG_TOUCHSCREEN_DYNAPRO=y
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=y
CONFIG_TOUCHSCREEN_EGALAX=m
CONFIG_TOUCHSCREEN_EGALAX_SERIAL=y
CONFIG_TOUCHSCREEN_FT6236=y
# CONFIG_TOUCHSCREEN_FUJITSU is not set
CONFIG_TOUCHSCREEN_GOODIX=m
# CONFIG_TOUCHSCREEN_ILI210X is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
CONFIG_TOUCHSCREEN_ELAN=m
CONFIG_TOUCHSCREEN_ELO=m
# CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
CONFIG_TOUCHSCREEN_WACOM_I2C=m
# CONFIG_TOUCHSCREEN_MAX11801 is not set
# CONFIG_TOUCHSCREEN_MCS5000 is not set
CONFIG_TOUCHSCREEN_MMS114=m
# CONFIG_TOUCHSCREEN_MELFAS_MIP4 is not set
CONFIG_TOUCHSCREEN_MTOUCH=m
CONFIG_TOUCHSCREEN_IMX6UL_TSC=m
CONFIG_TOUCHSCREEN_INEXIO=y
# CONFIG_TOUCHSCREEN_MK712 is not set
CONFIG_TOUCHSCREEN_PENMOUNT=y
CONFIG_TOUCHSCREEN_EDT_FT5X06=y
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
CONFIG_TOUCHSCREEN_TOUCHWIN=y
CONFIG_TOUCHSCREEN_PIXCIR=m
CONFIG_TOUCHSCREEN_WDT87XX_I2C=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
# CONFIG_TOUCHSCREEN_MC13783 is not set
CONFIG_TOUCHSCREEN_TOUCHIT213=y
CONFIG_TOUCHSCREEN_TSC_SERIO=y
# CONFIG_TOUCHSCREEN_TSC2004 is not set
CONFIG_TOUCHSCREEN_TSC2007=m
CONFIG_TOUCHSCREEN_RM_TS=y
# CONFIG_TOUCHSCREEN_ST1232 is not set
CONFIG_TOUCHSCREEN_STMPE=m
CONFIG_TOUCHSCREEN_SX8654=m
# CONFIG_TOUCHSCREEN_TPS6507X is not set
CONFIG_TOUCHSCREEN_ZFORCE=y
# CONFIG_TOUCHSCREEN_COLIBRI_VF50 is not set
# CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM80X_ONKEY=m
CONFIG_INPUT_AD714X=y
# CONFIG_INPUT_AD714X_I2C is not set
# CONFIG_INPUT_ATMEL_CAPTOUCH is not set
CONFIG_INPUT_BMA150=y
CONFIG_INPUT_E3X0_BUTTON=m
CONFIG_INPUT_PCSPKR=y
# CONFIG_INPUT_MAX77693_HAPTIC is not set
# CONFIG_INPUT_MC13783_PWRBUTTON is not set
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_MPU3050=m
CONFIG_INPUT_APANEL=y
CONFIG_INPUT_GP2A=y
CONFIG_INPUT_GPIO_BEEPER=m
CONFIG_INPUT_GPIO_TILT_POLLED=y
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=m
CONFIG_INPUT_KXTJ9_POLLED_MODE=y
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
# CONFIG_INPUT_REGULATOR_HAPTIC is not set
CONFIG_INPUT_RETU_PWRBUTTON=m
CONFIG_INPUT_TPS65218_PWRBUTTON=m
CONFIG_INPUT_TWL4030_PWRBUTTON=m
CONFIG_INPUT_TWL4030_VIBRA=m
# CONFIG_INPUT_TWL6040_VIBRA is not set
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PCF8574=m
CONFIG_INPUT_PWM_BEEPER=m
CONFIG_INPUT_GPIO_ROTARY_ENCODER=y
CONFIG_INPUT_DA9052_ONKEY=m
CONFIG_INPUT_DA9063_ONKEY=y
CONFIG_INPUT_ADXL34X=y
CONFIG_INPUT_ADXL34X_I2C=y
CONFIG_INPUT_CMA3000=y
CONFIG_INPUT_CMA3000_I2C=m
CONFIG_INPUT_IDEAPAD_SLIDEBAR=m
# CONFIG_INPUT_SOC_BUTTON_ARRAY is not set
CONFIG_INPUT_DRV260X_HAPTICS=m
CONFIG_INPUT_DRV2665_HAPTICS=y
# CONFIG_INPUT_DRV2667_HAPTICS is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=m
CONFIG_SERIO_PCIPS2=m
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
CONFIG_SERIO_ALTERA_PS2=m
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_SERIO_APBPS2=m
CONFIG_HYPERV_KEYBOARD=m
CONFIG_USERIO=m
CONFIG_GAMEPORT=m
CONFIG_GAMEPORT_NS558=m
CONFIG_GAMEPORT_L4=m
CONFIG_GAMEPORT_EMU10K1=m
CONFIG_GAMEPORT_FM801=m

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=y
# CONFIG_N_GSM is not set
CONFIG_TRACE_ROUTER=m
CONFIG_TRACE_SINK=y
# CONFIG_DEVMEM is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
# CONFIG_SERIAL_8250_PNP is not set
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
# CONFIG_SERIAL_8250_PCI is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
# CONFIG_SERIAL_8250_SHARE_IRQ is not set
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
# CONFIG_SERIAL_8250_RSA is not set
# CONFIG_SERIAL_8250_FSL is not set
CONFIG_SERIAL_8250_DW=y
CONFIG_SERIAL_8250_RT288X=y
CONFIG_SERIAL_8250_MID=y
CONFIG_SERIAL_8250_MOXA=y
CONFIG_SERIAL_OF_PLATFORM=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_UARTLITE=y
CONFIG_SERIAL_UARTLITE_CONSOLE=y
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_SC16IS7XX_CORE=y
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_SC16IS7XX_I2C=y
CONFIG_SERIAL_ALTERA_JTAGUART=m
# CONFIG_SERIAL_ALTERA_UART is not set
CONFIG_SERIAL_XILINX_PS_UART=m
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_SERIAL_RP2=m
CONFIG_SERIAL_RP2_NR_UARTS=32
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_CONEXANT_DIGICOLOR is not set
CONFIG_SERIAL_MEN_Z135=m
CONFIG_SERIAL_MCTRL_GPIO=y
CONFIG_TTY_PRINTK=m
CONFIG_PRINTER=m
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=m
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=m
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
# CONFIG_IPMI_DEVICE_INTERFACE is not set
CONFIG_IPMI_SI=m
CONFIG_IPMI_SSIF=m
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
CONFIG_APPLICOM=m
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=m
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_ATMEL=m
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_CRB=m
CONFIG_TCG_TIS_ST33ZP24=m
CONFIG_TCG_TIS_ST33ZP24_I2C=m
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_XILLYBUS=m
CONFIG_XILLYBUS_PCIE=m
# CONFIG_XILLYBUS_OF is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=m

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_ARB_GPIO_CHALLENGE is not set
CONFIG_I2C_MUX_GPIO=m
CONFIG_I2C_MUX_PCA9541=m
CONFIG_I2C_MUX_PCA954x=m
# CONFIG_I2C_MUX_PINCTRL is not set
CONFIG_I2C_MUX_REG=m
CONFIG_I2C_DEMUX_PINCTRL=m
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=m
CONFIG_I2C_ALGOBIT=m
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=m
CONFIG_I2C_ALI15X3=y
# CONFIG_I2C_AMD756 is not set
CONFIG_I2C_AMD8111=y
CONFIG_I2C_I801=m
CONFIG_I2C_ISCH=y
# CONFIG_I2C_ISMT is not set
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=m
CONFIG_I2C_NFORCE2_S4985=m
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=m
CONFIG_I2C_DESIGNWARE_PLATFORM=m
CONFIG_I2C_DESIGNWARE_PCI=m
CONFIG_I2C_DESIGNWARE_BAYTRAIL=y
# CONFIG_I2C_EMEV2 is not set
CONFIG_I2C_GPIO=m
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=m
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_RK3X=y
# CONFIG_I2C_SIMTEC is not set
CONFIG_I2C_XILINX=m

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=m
# CONFIG_I2C_PARPORT_LIGHT is not set
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_STUB=m
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
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
CONFIG_PPS=m
# CONFIG_PPS_DEBUG is not set
CONFIG_NTP_PPS=y

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=m
CONFIG_PPS_CLIENT_LDISC=m
CONFIG_PPS_CLIENT_PARPORT=m
# CONFIG_PPS_CLIENT_GPIO is not set

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
# CONFIG_PINCTRL_SINGLE is not set
# CONFIG_PINCTRL_BAYTRAIL is not set
CONFIG_PINCTRL_CHERRYVIEW=m
CONFIG_PINCTRL_INTEL=y
CONFIG_PINCTRL_BROXTON=y
CONFIG_PINCTRL_SUNRISEPOINT=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_74XX_MMIO=m
CONFIG_GPIO_ALTERA=m
CONFIG_GPIO_AMDPT=m
CONFIG_GPIO_DWAPB=m
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_GRGPIO is not set
CONFIG_GPIO_ICH=m
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_MENZ127=y
CONFIG_GPIO_SYSCON=m
CONFIG_GPIO_VX855=y
# CONFIG_GPIO_XILINX is not set
# CONFIG_GPIO_ZX is not set

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_F7188X is not set
CONFIG_GPIO_IT87=m
CONFIG_GPIO_SCH=y
CONFIG_GPIO_SCH311X=y

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
CONFIG_GPIO_ADP5588_IRQ=y
CONFIG_GPIO_ADNP=m
# CONFIG_GPIO_MAX7300 is not set
CONFIG_GPIO_MAX732X=m
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
CONFIG_GPIO_PCF857X=m
CONFIG_GPIO_SX150X=y
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_ADP5520=y
# CONFIG_GPIO_ARIZONA is not set
CONFIG_GPIO_CRYSTAL_COVE=y
CONFIG_GPIO_DA9052=y
# CONFIG_GPIO_JANZ_TTL is not set
CONFIG_GPIO_RC5T583=y
CONFIG_GPIO_STMPE=y
CONFIG_GPIO_TPS65086=m
CONFIG_GPIO_TPS65218=m
CONFIG_GPIO_TPS65912=m
CONFIG_GPIO_TWL4030=m
CONFIG_GPIO_TWL6040=m
CONFIG_GPIO_WM8350=y

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=y
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_ML_IOH=m
CONFIG_GPIO_RDC321X=m
# CONFIG_GPIO_SODAVILLE is not set

#
# SPI or I2C GPIO expanders
#
CONFIG_GPIO_MCP23S08=m
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=m
CONFIG_GENERIC_ADC_BATTERY=m
# CONFIG_WM8350_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
# CONFIG_BATTERY_BQ27XXX is not set
CONFIG_BATTERY_DA9052=m
CONFIG_CHARGER_DA9150=m
# CONFIG_BATTERY_DA9150 is not set
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_TWL4030_MADC=m
# CONFIG_BATTERY_RX51 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_TWL4030 is not set
CONFIG_CHARGER_LP8727=y
# CONFIG_CHARGER_LP8788 is not set
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_MAX14577 is not set
CONFIG_CHARGER_MAX8998=m
CONFIG_CHARGER_BQ2415X=m
# CONFIG_CHARGER_BQ24190 is not set
CONFIG_CHARGER_BQ24257=y
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_BQ25890=m
CONFIG_CHARGER_SMB347=m
CONFIG_CHARGER_TPS65090=y
CONFIG_CHARGER_TPS65217=m
CONFIG_BATTERY_GAUGE_LTC2941=m
CONFIG_BATTERY_RT5033=m
CONFIG_CHARGER_RT9455=m
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_GPIO is not set
# CONFIG_POWER_RESET_GPIO_RESTART is not set
# CONFIG_POWER_RESET_LTC2952 is not set
# CONFIG_POWER_RESET_RESTART is not set
CONFIG_POWER_RESET_SYSCON=y
CONFIG_POWER_RESET_SYSCON_POWEROFF=y
CONFIG_REBOOT_MODE=y
CONFIG_SYSCON_REBOOT_MODE=y
CONFIG_POWER_AVS=y
CONFIG_HWMON=m
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
CONFIG_SENSORS_ABITUGURU3=m
CONFIG_SENSORS_AD7414=m
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7X10=m
CONFIG_SENSORS_ADT7410=m
CONFIG_SENSORS_ADT7411=m
CONFIG_SENSORS_ADT7462=m
CONFIG_SENSORS_ADT7470=m
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_K8TEMP=m
CONFIG_SENSORS_K10TEMP=m
CONFIG_SENSORS_APPLESMC=m
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS620=m
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DELL_SMM=m
CONFIG_SENSORS_DA9052_ADC=m
CONFIG_SENSORS_I5K_AMB=m
CONFIG_SENSORS_F71805F=m
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_MC13783_ADC is not set
CONFIG_SENSORS_FSCHMD=m
CONFIG_SENSORS_GL518SM=m
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_G760A is not set
CONFIG_SENSORS_G762=m
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_IBMAEM=m
CONFIG_SENSORS_IBMPEX=m
CONFIG_SENSORS_IIO_HWMON=m
CONFIG_SENSORS_I5500=m
# CONFIG_SENSORS_CORETEMP is not set
CONFIG_SENSORS_IT87=m
CONFIG_SENSORS_JC42=m
CONFIG_SENSORS_POWR1220=m
CONFIG_SENSORS_LINEAGE=m
CONFIG_SENSORS_LTC2945=m
# CONFIG_SENSORS_LTC2990 is not set
CONFIG_SENSORS_LTC4151=m
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4222 is not set
CONFIG_SENSORS_LTC4245=m
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=m
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=m
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX197 is not set
CONFIG_SENSORS_MAX6639=m
CONFIG_SENSORS_MAX6642=m
CONFIG_SENSORS_MAX6650=m
CONFIG_SENSORS_MAX6697=m
# CONFIG_SENSORS_MAX31790 is not set
CONFIG_SENSORS_MCP3021=m
CONFIG_SENSORS_MENF21BMC_HWMON=m
CONFIG_SENSORS_LM63=m
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
# CONFIG_SENSORS_LM95234 is not set
CONFIG_SENSORS_LM95241=m
CONFIG_SENSORS_LM95245=m
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_NTC_THERMISTOR=m
# CONFIG_SENSORS_NCT6683 is not set
CONFIG_SENSORS_NCT6775=m
# CONFIG_SENSORS_NCT7802 is not set
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_PCF8591=m
# CONFIG_PMBUS is not set
CONFIG_SENSORS_PWM_FAN=m
CONFIG_SENSORS_SHT15=m
CONFIG_SENSORS_SHT21=m
CONFIG_SENSORS_SHT3x=m
# CONFIG_SENSORS_SHTC1 is not set
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=m
CONFIG_SENSORS_EMC1403=m
CONFIG_SENSORS_EMC2103=m
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=m
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=m
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_ADC128D818=m
CONFIG_SENSORS_ADS1015=m
CONFIG_SENSORS_ADS7828=m
CONFIG_SENSORS_AMC6821=m
CONFIG_SENSORS_INA209=m
CONFIG_SENSORS_INA2XX=m
CONFIG_SENSORS_INA3221=m
# CONFIG_SENSORS_TC74 is not set
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=m
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_TWL4030_MADC=m
CONFIG_SENSORS_VIA_CPUTEMP=m
CONFIG_SENSORS_VIA686A=m
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83795=m
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=m
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
CONFIG_SENSORS_WM8350=m

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_OF=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR=y
CONFIG_THERMAL_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_GOV_STEP_WISE is not set
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
CONFIG_THERMAL_EMULATION=y
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=y
CONFIG_GENERIC_ADC_THERMAL=m
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
# CONFIG_SSB_PCIHOST is not set
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=m
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
# CONFIG_BCMA_HOST_PCI is not set
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
# CONFIG_BCMA_SFLASH is not set
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DRIVER_GPIO is not set
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_ACT8945A is not set
# CONFIG_MFD_AS3711 is not set
# CONFIG_MFD_AS3722 is not set
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_ATMEL_FLEXCOM=m
CONFIG_MFD_ATMEL_HLCDC=y
CONFIG_MFD_BCM590XX=y
# CONFIG_MFD_AXP20X_I2C is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=m
CONFIG_MFD_MC13XXX=m
CONFIG_MFD_MC13XXX_I2C=m
CONFIG_MFD_HI6421_PMIC=y
# CONFIG_HTC_PASIC3 is not set
CONFIG_HTC_I2CPLD=y
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=m
CONFIG_LPC_ICH=m
CONFIG_LPC_SCH=y
CONFIG_INTEL_SOC_PMIC=y
CONFIG_MFD_INTEL_LPSS=y
CONFIG_MFD_INTEL_LPSS_ACPI=y
# CONFIG_MFD_INTEL_LPSS_PCI is not set
CONFIG_MFD_JANZ_CMODIO=y
# CONFIG_MFD_KEMPLD is not set
CONFIG_MFD_88PM800=m
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77620 is not set
CONFIG_MFD_MAX77686=y
# CONFIG_MFD_MAX77693 is not set
CONFIG_MFD_MAX77843=y
CONFIG_MFD_MAX8907=m
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=m
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
CONFIG_MFD_RDC321X=m
CONFIG_MFD_RTSX_PCI=m
CONFIG_MFD_RT5033=y
CONFIG_MFD_RC5T583=y
CONFIG_MFD_RK808=y
CONFIG_MFD_RN5T618=y
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=m
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SKY81452=y
CONFIG_MFD_SMSC=y
CONFIG_ABX500_CORE=y
# CONFIG_AB3100_CORE is not set
CONFIG_MFD_STMPE=y

#
# STMicroelectronics STMPE Interface Drivers
#
# CONFIG_STMPE_I2C is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP3943 is not set
CONFIG_MFD_LP8788=y
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=m
CONFIG_MFD_TPS65086=m
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS65218=m
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
CONFIG_TWL6040_CORE=y
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_CS47L24=y
# CONFIG_MFD_WM5102 is not set
# CONFIG_MFD_WM5110 is not set
CONFIG_MFD_WM8997=y
# CONFIG_MFD_WM8998 is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PM800=m
CONFIG_REGULATOR_ACT8865=m
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_BCM590XX=m
CONFIG_REGULATOR_DA9052=y
CONFIG_REGULATOR_DA9062=y
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=m
# CONFIG_REGULATOR_DA9211 is not set
CONFIG_REGULATOR_FAN53555=m
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_HI6421=m
CONFIG_REGULATOR_ISL9305=m
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=m
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LP8788=m
CONFIG_REGULATOR_LTC3589=m
CONFIG_REGULATOR_MAX14577=m
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
# CONFIG_REGULATOR_MAX8907 is not set
# CONFIG_REGULATOR_MAX8952 is not set
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX8998=m
CONFIG_REGULATOR_MAX77686=y
CONFIG_REGULATOR_MAX77693=y
# CONFIG_REGULATOR_MAX77802 is not set
CONFIG_REGULATOR_MC13XXX_CORE=m
CONFIG_REGULATOR_MC13783=m
CONFIG_REGULATOR_MC13892=m
# CONFIG_REGULATOR_MT6311 is not set
CONFIG_REGULATOR_MT6323=y
CONFIG_REGULATOR_MT6397=m
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=m
# CONFIG_REGULATOR_PV88090 is not set
CONFIG_REGULATOR_PWM=m
CONFIG_REGULATOR_RC5T583=y
CONFIG_REGULATOR_RK808=m
CONFIG_REGULATOR_RN5T618=y
# CONFIG_REGULATOR_RT5033 is not set
# CONFIG_REGULATOR_S2MPA01 is not set
# CONFIG_REGULATOR_S2MPS11 is not set
CONFIG_REGULATOR_S5M8767=y
# CONFIG_REGULATOR_SKY81452 is not set
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=m
CONFIG_REGULATOR_TPS65023=m
# CONFIG_REGULATOR_TPS6507X is not set
CONFIG_REGULATOR_TPS65086=m
CONFIG_REGULATOR_TPS65090=m
CONFIG_REGULATOR_TPS65217=m
CONFIG_REGULATOR_TPS65218=m
CONFIG_REGULATOR_TPS65912=m
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_WM8350=y
CONFIG_MEDIA_SUPPORT=m

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
# CONFIG_MEDIA_RADIO_SUPPORT is not set
CONFIG_MEDIA_SDR_SUPPORT=y
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_MEDIA_CEC_EDID=y
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_V4L2=m
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
# CONFIG_VIDEO_PCI_SKELETON is not set
CONFIG_VIDEO_TUNER=m
CONFIG_V4L2_MEM2MEM_DEV=m
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_DMA_SG=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_DMA_CONTIG=m
CONFIG_VIDEOBUF2_VMALLOC=m
CONFIG_VIDEOBUF2_DMA_SG=m
CONFIG_VIDEOBUF2_DVB=m
CONFIG_DVB_CORE=m
CONFIG_TTPCI_EEPROM=m
CONFIG_DVB_MAX_ADAPTERS=8
# CONFIG_DVB_DYNAMIC_MINORS is not set

#
# Media drivers
#
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture support
#
# CONFIG_VIDEO_SOLO6X10 is not set
CONFIG_VIDEO_TW68=m
CONFIG_VIDEO_TW686X=m
CONFIG_VIDEO_ZORAN=m
# CONFIG_VIDEO_ZORAN_DC30 is not set
# CONFIG_VIDEO_ZORAN_ZR36060 is not set

#
# Media capture/analog/hybrid TV support
#
CONFIG_VIDEO_CX25821=m
# CONFIG_VIDEO_CX25821_ALSA is not set
CONFIG_VIDEO_SAA7134=m
CONFIG_VIDEO_SAA7134_ALSA=m
CONFIG_VIDEO_SAA7134_DVB=m
CONFIG_VIDEO_SAA7164=m

#
# Media digital TV PCI Adapters
#
CONFIG_DVB_AV7110_IR=y
CONFIG_DVB_AV7110=m
# CONFIG_DVB_AV7110_OSD is not set
# CONFIG_DVB_BUDGET_CORE is not set
CONFIG_DVB_B2C2_FLEXCOP_PCI=m
# CONFIG_DVB_B2C2_FLEXCOP_PCI_DEBUG is not set
CONFIG_DVB_PLUTO2=m
# CONFIG_DVB_PT1 is not set
CONFIG_DVB_PT3=m
CONFIG_DVB_NGENE=m
# CONFIG_DVB_DDBRIDGE is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
CONFIG_V4L_TEST_DRIVERS=y
CONFIG_VIDEO_VIVID=m
CONFIG_VIDEO_VIVID_MAX_DEVS=64
CONFIG_VIDEO_VIM2M=m
# CONFIG_DVB_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=m
CONFIG_DVB_FIREDTV_INPUT=y
CONFIG_VIDEO_TVEEPROM=m
CONFIG_DVB_B2C2_FLEXCOP=m
CONFIG_VIDEO_SAA7146=m
CONFIG_VIDEO_SAA7146_VV=m
CONFIG_VIDEO_V4L2_TPG=m

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

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
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=m

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=m
CONFIG_MEDIA_TUNER_SIMPLE=m
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA827X=m
CONFIG_MEDIA_TUNER_TDA18271=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_MT2131=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
CONFIG_MEDIA_TUNER_XC4000=m
CONFIG_MEDIA_TUNER_MC44S803=m
CONFIG_MEDIA_TUNER_MXL301RF=m
CONFIG_MEDIA_TUNER_QM1D1C0042=m

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STV090x=m
CONFIG_DVB_STV6110x=m

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=m
CONFIG_DVB_TDA18271C2DD=m

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24123=m
CONFIG_DVB_MT312=m
CONFIG_DVB_ZL10036=m
CONFIG_DVB_ZL10039=m
CONFIG_DVB_S5H1420=m
CONFIG_DVB_STV0299=m
CONFIG_DVB_TDA8083=m
CONFIG_DVB_TDA10086=m
CONFIG_DVB_VES1X93=m
CONFIG_DVB_TUNER_ITD1000=m
CONFIG_DVB_TUNER_CX24113=m
CONFIG_DVB_TDA826X=m
CONFIG_DVB_CX24120=m

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=m
CONFIG_DVB_L64781=m
CONFIG_DVB_TDA1004X=m
CONFIG_DVB_MT352=m
CONFIG_DVB_ZL10353=m
CONFIG_DVB_TDA10048=m
# CONFIG_DVB_AS102_FE is not set

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=m
CONFIG_DVB_STV0297=m

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=m
CONFIG_DVB_BCM3510=m
CONFIG_DVB_LGDT330X=m
CONFIG_DVB_LGDT3305=m
CONFIG_DVB_S5H1411=m

#
# ISDB-T (terrestrial) frontends
#

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=m

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=m

#
# SEC control devices for DVB-S
#
CONFIG_DVB_LNBP21=m
CONFIG_DVB_ISL6405=m
CONFIG_DVB_ISL6421=m

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
CONFIG_DRM=m
CONFIG_DRM_MIPI_DSI=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_FBDEV_EMULATION is not set
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=m
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_ADV7511=m
CONFIG_DRM_I2C_CH7006=m
CONFIG_DRM_I2C_SIL164=m
CONFIG_DRM_I2C_NXP_TDA998X=m
CONFIG_DRM_TDFX=m
CONFIG_DRM_R128=m
CONFIG_DRM_RADEON=m
CONFIG_DRM_RADEON_USERPTR=y
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#
CONFIG_DRM_NOUVEAU=m
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
# CONFIG_DRM_NOUVEAU_BACKLIGHT is not set
# CONFIG_DRM_I915 is not set
CONFIG_DRM_MGA=m
# CONFIG_DRM_VIA is not set
CONFIG_DRM_SAVAGE=m
CONFIG_DRM_VGEM=m
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
CONFIG_DRM_MGAG200=m
CONFIG_DRM_CIRRUS_QEMU=m
CONFIG_DRM_QXL=m
# CONFIG_DRM_BOCHS is not set
# CONFIG_DRM_VIRTIO_GPU is not set
CONFIG_DRM_PANEL=y

#
# Display Panels
#
CONFIG_DRM_PANEL_SIMPLE=m
CONFIG_DRM_PANEL_PANASONIC_VVX10F034N00=m
CONFIG_DRM_PANEL_SAMSUNG_S6E8AA0=m
CONFIG_DRM_PANEL_SHARP_LQ101R1SX01=m
CONFIG_DRM_PANEL_SHARP_LS043T1LE01=m
CONFIG_DRM_BRIDGE=y

#
# Display Interface Bridges
#
CONFIG_DRM_ANALOGIX_ANX78XX=m
CONFIG_DRM_NXP_PTN3460=m
CONFIG_DRM_PARADE_PS8622=m
CONFIG_DRM_ARCPGU=m

#
# Frame buffer Devices
#
CONFIG_FB=m
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_DDC=m
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=m
CONFIG_FB_CFB_COPYAREA=m
CONFIG_FB_CFB_IMAGEBLIT=m
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_SVGALIB=m
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=m
CONFIG_FB_PM2=m
CONFIG_FB_PM2_FIFO_DISCONNECT=y
CONFIG_FB_CYBER2000=m
# CONFIG_FB_CYBER2000_DDC is not set
CONFIG_FB_ARC=m
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
CONFIG_FB_OPENCORES=m
CONFIG_FB_S1D13XXX=m
CONFIG_FB_NVIDIA=m
# CONFIG_FB_NVIDIA_I2C is not set
CONFIG_FB_NVIDIA_DEBUG=y
# CONFIG_FB_NVIDIA_BACKLIGHT is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
CONFIG_FB_MATROX=m
CONFIG_FB_MATROX_MILLENIUM=y
# CONFIG_FB_MATROX_MYSTIQUE is not set
# CONFIG_FB_MATROX_G is not set
CONFIG_FB_MATROX_I2C=m
CONFIG_FB_RADEON=m
# CONFIG_FB_RADEON_I2C is not set
CONFIG_FB_RADEON_BACKLIGHT=y
CONFIG_FB_RADEON_DEBUG=y
CONFIG_FB_ATY128=m
# CONFIG_FB_ATY128_BACKLIGHT is not set
CONFIG_FB_ATY=m
# CONFIG_FB_ATY_CT is not set
CONFIG_FB_ATY_GX=y
# CONFIG_FB_ATY_BACKLIGHT is not set
# CONFIG_FB_S3 is not set
CONFIG_FB_SAVAGE=m
CONFIG_FB_SAVAGE_I2C=y
# CONFIG_FB_SAVAGE_ACCEL is not set
CONFIG_FB_SIS=m
# CONFIG_FB_SIS_300 is not set
CONFIG_FB_SIS_315=y
CONFIG_FB_VIA=m
CONFIG_FB_VIA_DIRECT_PROCFS=y
CONFIG_FB_VIA_X_COMPATIBILITY=y
CONFIG_FB_NEOMAGIC=m
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
CONFIG_FB_VOODOO1=m
# CONFIG_FB_VT8623 is not set
CONFIG_FB_TRIDENT=m
CONFIG_FB_ARK=m
CONFIG_FB_PM3=m
CONFIG_FB_CARMINE=m
CONFIG_FB_CARMINE_DRAM_EVAL=y
# CONFIG_CARMINE_DRAM_CUSTOM is not set
# CONFIG_FB_IBM_GXT4500 is not set
CONFIG_FB_VIRTUAL=m
CONFIG_FB_METRONOME=m
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_FB_AUO_K190X=m
CONFIG_FB_AUO_K1900=m
# CONFIG_FB_AUO_K1901 is not set
# CONFIG_FB_HYPERV is not set
# CONFIG_FB_SSD1307 is not set
CONFIG_FB_SM712=m
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_PWM=y
CONFIG_BACKLIGHT_DA9052=y
CONFIG_BACKLIGHT_APPLE=y
CONFIG_BACKLIGHT_PM8941_WLED=m
CONFIG_BACKLIGHT_SAHARA=y
# CONFIG_BACKLIGHT_ADP5520 is not set
CONFIG_BACKLIGHT_ADP8860=m
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_LM3630A is not set
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_LP8788=y
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_SKY81452=y
CONFIG_BACKLIGHT_TPS65217=y
CONFIG_BACKLIGHT_GPIO=y
# CONFIG_BACKLIGHT_LV5207LP is not set
# CONFIG_BACKLIGHT_BD6107 is not set
CONFIG_VGASTATE=m
CONFIG_VIDEOMODE_HELPERS=y
CONFIG_HDMI=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
# CONFIG_LOGO_LINUX_CLUT224 is not set
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_RAWMIDI=m
# CONFIG_SND_SEQUENCER is not set
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
CONFIG_SND_PCM_OSS=m
CONFIG_SND_PCM_OSS_PLUGINS=y
CONFIG_SND_PCM_TIMER=y
CONFIG_SND_HRTIMER=m
# CONFIG_SND_DYNAMIC_MINORS is not set
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
CONFIG_SND_VERBOSE_PRINTK=y
CONFIG_SND_DEBUG=y
CONFIG_SND_DEBUG_VERBOSE=y
CONFIG_SND_PCM_XRUN_DEBUG=y
CONFIG_SND_DMA_SGBUF=y
# CONFIG_SND_RAWMIDI_SEQ is not set
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
CONFIG_SND_MPU401_UART=m
CONFIG_SND_DRIVERS=y
# CONFIG_SND_PCSP is not set
# CONFIG_SND_DUMMY is not set
CONFIG_SND_ALOOP=m
CONFIG_SND_MTPAV=m
# CONFIG_SND_MTS64 is not set
CONFIG_SND_SERIAL_U16550=m
CONFIG_SND_MPU401=m
# CONFIG_SND_PORTMAN2X4 is not set
# CONFIG_SND_PCI is not set

#
# HD-Audio
#
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=m
# CONFIG_SND_DICE is not set
CONFIG_SND_OXFW=m
CONFIG_SND_ISIGHT=m
CONFIG_SND_FIREWORKS=m
CONFIG_SND_BEBOB=m
CONFIG_SND_FIREWIRE_DIGI00X=m
CONFIG_SND_FIREWIRE_TASCAM=m
# CONFIG_SND_SOC is not set
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
CONFIG_UHID=m
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
CONFIG_HID_ACRUX=y
CONFIG_HID_ACRUX_FF=y
CONFIG_HID_APPLE=y
# CONFIG_HID_ASUS is not set
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
# CONFIG_HID_CHERRY is not set
CONFIG_HID_CHICONY=m
CONFIG_HID_PRODIKEYS=m
CONFIG_HID_CMEDIA=y
CONFIG_HID_CYPRESS=m
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=m
CONFIG_HID_EZKEY=y
CONFIG_HID_GEMBIRD=m
CONFIG_HID_GFRM=m
CONFIG_HID_KEYTOUCH=m
CONFIG_HID_KYE=m
CONFIG_HID_WALTOP=m
CONFIG_HID_GYRATION=m
# CONFIG_HID_ICADE is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
# CONFIG_HID_LENOVO is not set
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=m
# CONFIG_HID_MICROSOFT is not set
CONFIG_HID_MONTEREY=m
CONFIG_HID_MULTITOUCH=m
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PLANTRONICS=m
CONFIG_HID_PRIMAX=m
CONFIG_HID_SAITEK=m
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=m
CONFIG_HID_SUNPLUS=y
# CONFIG_HID_RMI is not set
CONFIG_HID_GREENASIA=m
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_HYPERV_MOUSE=m
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=m
CONFIG_HID_THINGM=m
CONFIG_HID_THRUSTMASTER=m
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_HID_WACOM is not set
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
# CONFIG_HID_ZEROPLUS is not set
CONFIG_HID_ZYDACRON=m
CONFIG_HID_SENSOR_HUB=y
# CONFIG_HID_SENSOR_CUSTOM_SENSOR is not set

#
# I2C HID support
#
CONFIG_I2C_HID=m
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
CONFIG_LEDS_CLASS_FLASH=m

#
# LED drivers
#
CONFIG_LEDS_AAT1290=m
CONFIG_LEDS_BCM6328=y
# CONFIG_LEDS_BCM6358 is not set
CONFIG_LEDS_LM3530=m
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_PCA9532=m
# CONFIG_LEDS_PCA9532_GPIO is not set
# CONFIG_LEDS_GPIO is not set
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP3952=m
CONFIG_LEDS_LP55XX_COMMON=m
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=m
# CONFIG_LEDS_LP5562 is not set
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_LP8860=m
CONFIG_LEDS_CLEVO_MAIL=m
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=m
# CONFIG_LEDS_WM8350 is not set
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_PWM=m
CONFIG_LEDS_REGULATOR=m
CONFIG_LEDS_BD2802=m
CONFIG_LEDS_INTEL_SS4200=m
CONFIG_LEDS_LT3593=y
# CONFIG_LEDS_ADP5520 is not set
# CONFIG_LEDS_MC13783 is not set
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_TLC591XX is not set
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_MENF21BMC=m
CONFIG_LEDS_KTD2692=m
CONFIG_LEDS_IS31FL32XX=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
CONFIG_LEDS_SYSCON=y

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
# CONFIG_SYNC_FILE is not set
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=m
# CONFIG_VIRTIO_PCI_LEGACY is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_INPUT is not set
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=m
# CONFIG_HYPERV_BALLOON is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=m
CONFIG_ACERHDF=m
CONFIG_ALIENWARE_WMI=m
CONFIG_ASUS_LAPTOP=y
CONFIG_DELL_WMI_AIO=m
CONFIG_DELL_SMO8800=y
CONFIG_FUJITSU_LAPTOP=m
# CONFIG_FUJITSU_LAPTOP_DEBUG is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
CONFIG_HP_WMI=m
# CONFIG_PANASONIC_LAPTOP is not set
CONFIG_THINKPAD_ACPI=m
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
CONFIG_THINKPAD_ACPI_DEBUGFACILITIES=y
CONFIG_THINKPAD_ACPI_DEBUG=y
CONFIG_THINKPAD_ACPI_UNSAFE_LEDS=y
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
# CONFIG_SENSORS_HDAPS is not set
CONFIG_ASUS_WIRELESS=m
CONFIG_ACPI_WMI=y
# CONFIG_MSI_WMI is not set
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_ACPI_TOSHIBA=m
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_TOSHIBA_HAPS is not set
CONFIG_TOSHIBA_WMI=y
CONFIG_ACPI_CMPC=y
# CONFIG_INTEL_HID_EVENT is not set
# CONFIG_INTEL_VBTN is not set
# CONFIG_INTEL_IPS is not set
CONFIG_INTEL_PMC_CORE=y
CONFIG_IBM_RTL=m
CONFIG_SAMSUNG_LAPTOP=y
CONFIG_MXM_WMI=m
CONFIG_SAMSUNG_Q10=m
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
CONFIG_INTEL_PMC_IPC=y
CONFIG_SURFACE_PRO3_BUTTON=m
CONFIG_INTEL_PUNIT_IPC=y
# CONFIG_INTEL_TELEMETRY is not set
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=y
CONFIG_CHROMEOS_PSTORE=m
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_MAX77686 is not set
# CONFIG_COMMON_CLK_MAX77802 is not set
CONFIG_COMMON_CLK_RK808=m
CONFIG_COMMON_CLK_SI5351=y
# CONFIG_COMMON_CLK_SI514 is not set
# CONFIG_COMMON_CLK_SI570 is not set
CONFIG_COMMON_CLK_CDCE706=m
CONFIG_COMMON_CLK_CDCE925=m
CONFIG_COMMON_CLK_CS2000_CP=m
# CONFIG_COMMON_CLK_S2MPS11 is not set
CONFIG_CLK_TWL6040=m
# CONFIG_COMMON_CLK_NXP is not set
# CONFIG_COMMON_CLK_PWM is not set
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
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=m
CONFIG_STE_MODEM_RPROC=m

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
# CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND is not set
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=m
CONFIG_DEVFREQ_GOV_PASSIVE=y

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_ADC_JACK is not set
# CONFIG_EXTCON_GPIO is not set
# CONFIG_EXTCON_MAX14577 is not set
CONFIG_EXTCON_MAX3355=m
# CONFIG_EXTCON_MAX77843 is not set
# CONFIG_EXTCON_RT8973A is not set
CONFIG_EXTCON_SM5502=y
CONFIG_EXTCON_USB_GPIO=y
# CONFIG_MEMORY is not set
CONFIG_IIO=m
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=m
CONFIG_IIO_KFIFO_BUF=m
CONFIG_IIO_TRIGGERED_BUFFER=m
CONFIG_IIO_CONFIGFS=m
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
# CONFIG_IIO_SW_DEVICE is not set
# CONFIG_IIO_SW_TRIGGER is not set

#
# Accelerometers
#
# CONFIG_BMA180 is not set
CONFIG_BMC150_ACCEL=m
CONFIG_BMC150_ACCEL_I2C=m
# CONFIG_HID_SENSOR_ACCEL_3D is not set
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
CONFIG_KXCJK1013=m
CONFIG_MMA7455=m
CONFIG_MMA7455_I2C=m
# CONFIG_MMA7660 is not set
# CONFIG_MMA8452 is not set
CONFIG_MMA9551_CORE=m
# CONFIG_MMA9551 is not set
CONFIG_MMA9553=m
CONFIG_MXC4005=m
# CONFIG_MXC6255 is not set
CONFIG_STK8312=m
CONFIG_STK8BA50=m

#
# Analog to digital converters
#
CONFIG_AD7291=m
# CONFIG_AD799X is not set
CONFIG_CC10001_ADC=m
CONFIG_DA9150_GPADC=m
CONFIG_INA2XX_ADC=m
CONFIG_LP8788_ADC=m
CONFIG_MAX1363=m
CONFIG_MCP3422=m
# CONFIG_MEN_Z188_ADC is not set
CONFIG_NAU7802=m
# CONFIG_TI_ADC081C is not set
CONFIG_TI_ADS1015=m
CONFIG_TWL4030_MADC=m
CONFIG_TWL6030_GPADC=m
CONFIG_VF610_ADC=m

#
# Amplifiers
#

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=m
# CONFIG_IAQCORE is not set
CONFIG_VZ89X=m

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=m
CONFIG_HID_SENSOR_IIO_TRIGGER=m
CONFIG_IIO_MS_SENSORS_I2C=m

#
# SSP Sensor Common
#
CONFIG_IIO_ST_SENSORS_I2C=m
CONFIG_IIO_ST_SENSORS_CORE=m

#
# Digital to analog converters
#
CONFIG_AD5064=m
# CONFIG_AD5380 is not set
# CONFIG_AD5446 is not set
CONFIG_AD5592R_BASE=m
CONFIG_AD5593R=m
CONFIG_M62332=m
# CONFIG_MAX517 is not set
CONFIG_MAX5821=m
# CONFIG_MCP4725 is not set
# CONFIG_VF610_DAC is not set

#
# IIO dummy driver
#

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#

#
# Phase-Locked Loop (PLL) frequency synthesizers
#

#
# Digital gyroscope sensors
#
# CONFIG_BMG160 is not set
CONFIG_HID_SENSOR_GYRO_3D=m
CONFIG_IIO_ST_GYRO_3AXIS=m
CONFIG_IIO_ST_GYRO_I2C_3AXIS=m
CONFIG_ITG3200=m

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4404=m
# CONFIG_MAX30100 is not set

#
# Humidity sensors
#
# CONFIG_AM2315 is not set
CONFIG_DHT11=m
CONFIG_HDC100X=m
# CONFIG_HTU21 is not set
CONFIG_SI7005=m
CONFIG_SI7020=m

#
# Inertial measurement units
#
# CONFIG_BMI160_I2C is not set
CONFIG_KMX61=m
CONFIG_INV_MPU6050_IIO=m
CONFIG_INV_MPU6050_I2C=m

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
CONFIG_ADJD_S311=m
CONFIG_AL3320A=m
CONFIG_APDS9300=m
# CONFIG_APDS9960 is not set
# CONFIG_BH1750 is not set
# CONFIG_BH1780 is not set
CONFIG_CM32181=m
CONFIG_CM3232=m
CONFIG_CM3323=m
CONFIG_CM36651=m
# CONFIG_GP2AP020A00F is not set
# CONFIG_ISL29125 is not set
# CONFIG_HID_SENSOR_ALS is not set
CONFIG_HID_SENSOR_PROX=m
CONFIG_JSA1212=m
CONFIG_RPR0521=m
# CONFIG_LTR501 is not set
CONFIG_MAX44000=m
CONFIG_OPT3001=m
# CONFIG_PA12203001 is not set
# CONFIG_STK3310 is not set
CONFIG_TCS3414=m
CONFIG_TCS3472=m
CONFIG_SENSORS_TSL2563=m
CONFIG_TSL4531=m
CONFIG_US5182D=m
CONFIG_VCNL4000=m
CONFIG_VEML6070=m

#
# Magnetometer sensors
#
CONFIG_AK8975=m
# CONFIG_AK09911 is not set
# CONFIG_BMC150_MAGN_I2C is not set
# CONFIG_MAG3110 is not set
# CONFIG_HID_SENSOR_MAGNETOMETER_3D is not set
CONFIG_MMC35240=m
# CONFIG_IIO_ST_MAGN_3AXIS is not set
CONFIG_SENSORS_HMC5843=m
CONFIG_SENSORS_HMC5843_I2C=m

#
# Inclinometer sensors
#
# CONFIG_HID_SENSOR_INCLINOMETER_3D is not set
CONFIG_HID_SENSOR_DEVICE_ROTATION=m

#
# Triggers - standalone
#
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Digital potentiometers
#
CONFIG_DS1803=m
CONFIG_MCP4531=m
CONFIG_TPL0102=m

#
# Pressure sensors
#
CONFIG_HID_SENSOR_PRESS=m
# CONFIG_HP03 is not set
CONFIG_MPL115=m
CONFIG_MPL115_I2C=m
CONFIG_MPL3115=m
# CONFIG_MS5611 is not set
CONFIG_MS5637=m
CONFIG_IIO_ST_PRESS=m
CONFIG_IIO_ST_PRESS_I2C=m
CONFIG_T5403=m
CONFIG_HP206C=m

#
# Lightning sensors
#

#
# Proximity sensors
#
CONFIG_LIDAR_LITE_V2=m
CONFIG_SX9500=m

#
# Temperature sensors
#
CONFIG_MLX90614=m
# CONFIG_TMP006 is not set
# CONFIG_TSYS01 is not set
CONFIG_TSYS02D=m
CONFIG_NTB=m
CONFIG_NTB_AMD=m
# CONFIG_NTB_INTEL is not set
CONFIG_NTB_PINGPONG=m
CONFIG_NTB_TOOL=m
# CONFIG_NTB_PERF is not set
# CONFIG_NTB_TRANSPORT is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_ATMEL_HLCDC_PWM is not set
CONFIG_PWM_CRC=y
# CONFIG_PWM_FSL_FTM is not set
CONFIG_PWM_LPSS=m
# CONFIG_PWM_LPSS_PCI is not set
CONFIG_PWM_LPSS_PLATFORM=m
CONFIG_PWM_PCA9685=m
# CONFIG_PWM_TWL is not set
# CONFIG_PWM_TWL_LED is not set
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=m
# CONFIG_BOARD_TPCI200 is not set
CONFIG_SERIAL_IPOCTAL=m
CONFIG_RESET_CONTROLLER=y
CONFIG_FMC=m
CONFIG_FMC_FAKEDEV=m
# CONFIG_FMC_TRIVIAL is not set
CONFIG_FMC_WRITE_EEPROM=m
CONFIG_FMC_CHARDEV=m

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_PHY_PXA_28NM_HSIC is not set
CONFIG_PHY_PXA_28NM_USB2=m
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_POWERCAP=y
# CONFIG_INTEL_RAPL is not set
CONFIG_MCB=y
CONFIG_MCB_PCI=m

#
# Performance monitor support
#
# CONFIG_RAS is not set
CONFIG_THUNDERBOLT=y

#
# Android
#
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y
# CONFIG_LIBNVDIMM is not set
CONFIG_NVMEM=y
# CONFIG_STM is not set
# CONFIG_INTEL_TH is not set

#
# FPGA Configuration Support
#
# CONFIG_FPGA is not set

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=m
# CONFIG_DCDBAS is not set
# CONFIG_DMIID is not set
# CONFIG_DMI_SYSFS is not set
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
CONFIG_ISCSI_IBFT_FIND=y
# CONFIG_FW_CFG_SYSFS is not set
# CONFIG_GOOGLE_FIRMWARE is not set
CONFIG_UEFI_CPER=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
# CONFIG_EXT2_FS_SECURITY is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_ENCRYPTION is not set
CONFIG_EXT4_DEBUG=y
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
# CONFIG_REISERFS_FS_SECURITY is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
CONFIG_XFS_WARN=y
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=m
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=m
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
CONFIG_BTRFS_DEBUG=y
# CONFIG_BTRFS_ASSERT is not set
CONFIG_NILFS2_FS=y
CONFIG_F2FS_FS=m
CONFIG_F2FS_STAT_FS=y
CONFIG_F2FS_FS_XATTR=y
# CONFIG_F2FS_FS_POSIX_ACL is not set
CONFIG_F2FS_FS_SECURITY=y
CONFIG_F2FS_CHECK_FS=y
# CONFIG_F2FS_FS_ENCRYPTION is not set
# CONFIG_F2FS_IO_TRACE is not set
CONFIG_F2FS_FAULT_INJECTION=y
# CONFIG_FS_DAX is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
# CONFIG_MANDATORY_FILE_LOCKING is not set
CONFIG_FS_ENCRYPTION=m
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
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
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
CONFIG_FSCACHE_DEBUG=y
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=y
CONFIG_CACHEFILES_DEBUG=y
CONFIG_CACHEFILES_HISTOGRAM=y

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_FAT_DEFAULT_UTF8=y
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
# CONFIG_PROC_VMCORE is not set
CONFIG_PROC_SYSCTL=y
# CONFIG_PROC_PAGE_MONITOR is not set
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=m
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
CONFIG_ADFS_FS=m
# CONFIG_ADFS_FS_RW is not set
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=y
# CONFIG_ECRYPT_FS_MESSAGING is not set
# CONFIG_HFS_FS is not set
CONFIG_HFSPLUS_FS=m
CONFIG_HFSPLUS_FS_POSIX_ACL=y
# CONFIG_BEFS_FS is not set
CONFIG_BFS_FS=m
CONFIG_EFS_FS=m
# CONFIG_JFFS2_FS is not set
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=y
CONFIG_SQUASHFS=m
# CONFIG_SQUASHFS_FILE_CACHE is not set
CONFIG_SQUASHFS_FILE_DIRECT=y
# CONFIG_SQUASHFS_DECOMP_SINGLE is not set
CONFIG_SQUASHFS_DECOMP_MULTI=y
# CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set
# CONFIG_SQUASHFS_XATTR is not set
# CONFIG_SQUASHFS_ZLIB is not set
# CONFIG_SQUASHFS_LZ4 is not set
# CONFIG_SQUASHFS_LZO is not set
# CONFIG_SQUASHFS_XZ is not set
CONFIG_SQUASHFS_4K_DEVBLK_SIZE=y
CONFIG_SQUASHFS_EMBEDDED=y
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
CONFIG_MINIX_FS=m
CONFIG_OMFS_FS=y
CONFIG_HPFS_FS=y
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
CONFIG_PSTORE_ZLIB_COMPRESS=y
# CONFIG_PSTORE_LZO_COMPRESS is not set
# CONFIG_PSTORE_LZ4_COMPRESS is not set
CONFIG_PSTORE_CONSOLE=y
# CONFIG_PSTORE_PMSG is not set
CONFIG_PSTORE_FTRACE=y
CONFIG_PSTORE_RAM=y
CONFIG_SYSV_FS=m
CONFIG_UFS_FS=m
CONFIG_UFS_FS_WRITE=y
# CONFIG_UFS_DEBUG is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=m
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=m
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=m
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=m
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=m
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=m
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=m
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=m
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=m

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
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=8192
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_STACK_VALIDATION is not set
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
CONFIG_DEBUG_PAGE_REF=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_VMACACHE=y
CONFIG_DEBUG_VM_RB=y
# CONFIG_DEBUG_VM_PGFLAGS is not set
CONFIG_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_KASAN=y
CONFIG_KASAN_OUTLINE=y
# CONFIG_KASAN_INLINE is not set
CONFIG_TEST_KASAN=m
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHED_INFO is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set
CONFIG_TIMER_STATS=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
CONFIG_RCU_PERF_TEST=m
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT is not set
CONFIG_RCU_TORTURE_TEST_SLOW_INIT=y
CONFIG_RCU_TORTURE_TEST_SLOW_INIT_DELAY=3
CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP=y
CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP_DELAY=3
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
CONFIG_RCU_EQS_DEBUG=y
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
CONFIG_FAILSLAB=y
# CONFIG_FAIL_PAGE_ALLOC is not set
CONFIG_FAIL_MAKE_REQUEST=y
CONFIG_FAIL_IO_TIMEOUT=y
# CONFIG_FAIL_FUTEX is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
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
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
# CONFIG_FUNCTION_GRAPH_TRACER is not set
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_STACK_TRACER=y
CONFIG_BLK_DEV_IO_TRACE=y
# CONFIG_KPROBE_EVENT is not set
# CONFIG_UPROBE_EVENT is not set
# CONFIG_PROBE_EVENTS is not set
# CONFIG_DYNAMIC_FTRACE is not set
CONFIG_FUNCTION_PROFILER=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_HIST_TRIGGERS is not set
CONFIG_TRACEPOINT_BENCHMARK=y
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
CONFIG_TRACE_ENUM_MAP_FILE=y
CONFIG_TRACING_EVENTS_GPIO=y

#
# Runtime Testing
#
CONFIG_LKDTM=m
CONFIG_TEST_LIST_SORT=y
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=m
# CONFIG_INTERVAL_TREE_TEST is not set
CONFIG_PERCPU_TEST=m
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_ASYNC_RAID6_TEST=m
CONFIG_TEST_HEXDUMP=m
CONFIG_TEST_STRING_HELPERS=m
CONFIG_TEST_KSTRTOX=m
CONFIG_TEST_PRINTF=y
CONFIG_TEST_BITMAP=m
CONFIG_TEST_UUID=m
# CONFIG_TEST_RHASHTABLE is not set
CONFIG_TEST_HASH=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_LKM=m
# CONFIG_TEST_USER_COPY is not set
# CONFIG_TEST_BPF is not set
CONFIG_TEST_FIRMWARE=m
CONFIG_TEST_UDELAY=y
CONFIG_MEMTEST=y
CONFIG_TEST_STATIC_KEYS=m
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
# CONFIG_UBSAN_ALIGNMENT is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP_CORE=y
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_WX=y
# CONFIG_DEBUG_SET_MODULE_RONX is not set
# CONFIG_DEBUG_NX_TEST is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
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
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_ENTRY=y
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
# CONFIG_BIG_KEYS is not set
CONFIG_TRUSTED_KEYS=m
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEY_DH_OPERATIONS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
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
CONFIG_CRYPTO_RNG_DEFAULT=m
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_RSA=y
# CONFIG_CRYPTO_DH is not set
# CONFIG_CRYPTO_ECDH is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=m
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=m
# CONFIG_CRYPTO_ECHAINIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=m
CONFIG_CRYPTO_CTS=m
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=m

#
# Hash modes
#
# CONFIG_CRYPTO_CMAC is not set
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=m
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=m
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=m
CONFIG_CRYPTO_POLY1305=y
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=m
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
CONFIG_CRYPTO_SHA512_SSSE3=m
CONFIG_CRYPTO_SHA1_MB=m
CONFIG_CRYPTO_SHA256_MB=m
# CONFIG_CRYPTO_SHA512_MB is not set
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
CONFIG_CRYPTO_AES_X86_64=m
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
# CONFIG_CRYPTO_ARC4 is not set
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAMELLIA_X86_64=m
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_DES3_EDE_X86_64=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=m
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=m
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=m

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
CONFIG_CRYPTO_LZO=m
CONFIG_CRYPTO_842=y
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=m
CONFIG_CRYPTO_DRBG_MENU=m
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=m
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
# CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_KVM is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=m
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
CONFIG_CRC_CCITT=m
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=m
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
# CONFIG_XZ_DEC_POWERPC is not set
CONFIG_XZ_DEC_IA64=y
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=m
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_FONT_SUPPORT=m
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_STACKDEPOT=y

--=_57f9c82e.mU3ivv+KD5t+0FDAsYsOxh+p+AcGJ4qzf1FPOeQscGek4iug--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
