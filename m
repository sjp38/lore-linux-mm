Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBAC96B0338
	for <linux-mm@kvack.org>; Sun,  7 May 2017 05:07:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d3so40516430pfj.5
        for <linux-mm@kvack.org>; Sun, 07 May 2017 02:07:49 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l8si9860179pln.114.2017.05.07.02.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 02:07:48 -0700 (PDT)
Date: Sun, 07 May 2017 17:06:53 +0800
From: kernel test robot <fengguang.wu@intel.com>
Subject: [mm/usercopy] 517e1fbeb6:  kernel BUG at
 arch/x86/mm/physaddr.c:78!
Message-ID: <590ee3ad.UQCaUFBHvkklRvGC%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_590ee3ad.MMDO8bLFgbUFGqMpxjTVyTOkfh0+P6mfL9xyPGfvVsiVBJjg"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, wfg@linux.intel.com

This is a multi-part message in MIME format.

--=_590ee3ad.MMDO8bLFgbUFGqMpxjTVyTOkfh0+P6mfL9xyPGfvVsiVBJjg
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit 517e1fbeb65f5eade8d14f46ac365db6c75aea9b
Author:     Laura Abbott <labbott@redhat.com>
AuthorDate: Tue Apr 4 14:09:00 2017 -0700
Commit:     Kees Cook <keescook@chromium.org>
CommitDate: Wed Apr 5 12:30:18 2017 -0700

    mm/usercopy: Drop extra is_vmalloc_or_module() check
    
    Previously virt_addr_valid() was insufficient to validate if virt_to_page()
    could be called on an address on arm64. This has since been fixed up so
    there is no need for the extra check. Drop it.
    
    Signed-off-by: Laura Abbott <labbott@redhat.com>
    Acked-by: Mark Rutland <mark.rutland@arm.com>
    Signed-off-by: Kees Cook <keescook@chromium.org>

96dc4f9fb6  usercopy: Move enum for arch_within_stack_frames()
517e1fbeb6  mm/usercopy: Drop extra is_vmalloc_or_module() check
13e0988140  docs: complete bumping minimal GNU Make version to 3.81
9e597e815f  Add linux-next specific files for 20170505
+------------------------------------------------------+------------+------------+------------+---------------+
|                                                      | 96dc4f9fb6 | 517e1fbeb6 | 13e0988140 | next-20170505 |
+------------------------------------------------------+------------+------------+------------+---------------+
| boot_successes                                       | 35         | 3          | 6          | 0             |
| boot_failures                                        | 0          | 12         | 13         | 18            |
| kernel_BUG_at_arch/x86/mm/physaddr.c                 | 0          | 12         | 13         | 13            |
| invalid_opcode:#[##]                                 | 0          | 12         | 13         | 13            |
| EIP:__phys_addr                                      | 0          | 12         | 13         | 13            |
| Kernel_panic-not_syncing:Fatal_exception             | 0          | 12         | 13         | 13            |
| WARNING:at_kernel/cpu.c:#lockdep_assert_hotplug_held | 0          | 0          | 0          | 18            |
| EIP:lockdep_assert_hotplug_held                      | 0          | 0          | 0          | 18            |
+------------------------------------------------------+------------+------------+------------+---------------+

[main] Setsockopt(1 22 80d3000 4) on fd 47 [1:5:1]
[   18.665929] sock: process `trinity-main' is using obsolete setsockopt SO_BSDCOMPAT
[main] Setsockopt(1 e 80d3000 90) on fd 49 [1:2:1]
[main] Setsockopt(10e 5 80d3000 4) on fd 52 [16:3:16]
[   18.668412] ------------[ cut here ]------------
[   18.668824] kernel BUG at arch/x86/mm/physaddr.c:78!
[   18.669424] invalid opcode: 0000 [#1] SMP
[   18.669776] CPU: 0 PID: 754 Comm: trinity-main Not tainted 4.11.0-rc2-00002-g517e1fb #1
[   18.670469] task: 4ca52e80 task.stack: 4c572000
[   18.670860] EIP: __phys_addr+0x120/0x130
[   18.671189] EFLAGS: 00010202 CPU: 0
[   18.671482] EAX: 0000ff01 EBX: 50851020 ECX: 00000000 EDX: 00000001
[   18.672025] ESI: 0000ff01 EDI: 10851020 EBP: 4c573e70 ESP: 4c573e60
[   18.672557]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[   18.673025] CR0: 80050033 CR2: 084da000 CR3: 0c65c4a0 CR4: 001406f0
[   18.673560] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[   18.674100] DR6: fffe0ff0 DR7: 00000400
[   18.674420] Call Trace:
[   18.674632]  __check_object_size+0xff/0x42f
[   18.674988]  ? __might_sleep+0x8e/0x130
[   18.675310]  __get_filter+0xaa/0x130
[   18.675612]  sk_attach_filter+0x15/0x90
[   18.675937]  sock_setsockopt+0x6b3/0x960
[   18.676263]  SyS_socketcall+0x773/0x810
[   18.676585]  ? __do_page_fault+0x36c/0x730
[   18.676932]  do_int80_syscall_32+0x8a/0x230
[   18.677307]  ? prepare_exit_to_usermode+0x38/0x60
[   18.677712]  entry_INT80_32+0x2f/0x2f
[   18.678034] EIP: 0x37688a42
[   18.678278] EFLAGS: 00000202 CPU: 0
[   18.678580] EAX: ffffffda EBX: 0000000e ECX: 3fc2da40 EDX: 3fc2dac0
[   18.679099] ESI: 00000004 EDI: 00000035 EBP: 3753f1ac ESP: 3fc2da3c
[   18.679618]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   18.680069] Code: 00 00 e0 ff 2d 00 20 00 00 39 c3 0f 83 47 ff ff ff c7 04 24 00 00 00 00 31 c9 ba 01 00 00 00 b8 98 e7 1a 42 e8 22 3e 0d 00 0f 0b <0f> 0b 8d b4 26 00 00 00 00 8d bc 27 00 00 00 00 55 89 e5 53 3e
[   18.681652] EIP: __phys_addr+0x120/0x130 SS:ESP: 0068:4c573e60
[   18.682174] ---[ end trace bbf34582d6d63d7a ]---
[   18.682636] Kernel panic - not syncing: Fatal exception

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start 773f7f5cf2d18eb40343d1e4e9a49062739e0425 a351e9b9fc24e982ec2f0e76379a49826036da12 --
git bisect  bad 39af3d3d90897d17d79bc655068cf09a717a0e68  # 12:26  B      0     4   15   0  Merge 'mellanox/queue-next' into devel-spot-201705070851
git bisect  bad 32f465722603afc8d3d90ad9fb999095afe11205  # 12:42  B      0    11   22   0  Merge 'linux-review/David-Ahern/net-reducing-memory-footprint-of-network-devices/20170507-031536' into devel-spot-201705070851
git bisect  bad 1cbccce1b4565d60c4d9a5bc3aaf8d63b5b9224f  # 12:53  B      0    11   22   0  Merge 'linux-review/Geliang-Tang/yam-use-memdup_user/20170507-045454' into devel-spot-201705070851
git bisect  bad 408133c058c5492c03ff9f3827ccdb65b42cb842  # 13:06  B      0    11   22   0  Merge 'linux-review/Christophe-JAILLET/firmware-Google-VPD-Fix-memory-allocation-error-handling/20170507-064549' into devel-spot-201705070851
git bisect  bad d5f6ce59cba315fc39f8bdd594d9a6ec7633be45  # 13:14  B      0     1   12   0  Merge 'linux-review/Geert-Uytterhoeven/signal-Export-signal_wake_up_state-to-modules/20170507-082935' into devel-spot-201705070851
git bisect good 163f34fcdf2791ac0e609d59440a9ef90d2bf3d2  # 13:34  G     11     0    0   0  0day base guard for 'devel-spot-201705070851'
git bisect good ddd92361062a7eb9708eb6c633346c35d0d67d2f  # 13:45  G     11     0    0   0  Merge 'linux-review/Geliang-Tang/platform-x86-toshiba_acpi-use-memdup_user_nul/20170507-083752' into devel-spot-201705070851
git bisect  bad a3719f34fdb664ffcfaec2160ef20fca7becf2ee  # 13:57  B      0    11   22   0  Merge branch 'generic' of git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs
git bisect good 5d15af6778b8e4ed1fd41b040283af278e7a9a72  # 14:11  G     11     0    0   0  Merge branch 'tipc-refactor-socket-receive-functions'
git bisect good 7c8c03bfc7b9f5211d8a69eab7fee99c9fb4f449  # 14:21  G     11     0    0   0  Merge branch 'perf-core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect  bad 8d65b08debc7e62b2c6032d7fe7389d895b92cbc  # 14:30  B      0    11   22   0  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
git bisect good b68e7e952f24527de62f4768b1cead91f92f5f6e  # 14:40  G     11     0    0   0  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/s390/linux
git bisect  bad 5b13475a5e12c49c24422ba1bd9998521dec1d4e  # 14:51  B      0    11   22   0  Merge branch 'work.iov_iter' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs
git bisect good 0cb300623e3bb460fd9853bbde2fd1973e3bbcd8  # 15:01  G     11     0    0   0  usb: gadget.h: be consistent at kernel doc macros
git bisect good 3a7d2fd16c57a1ef47dc2891171514231c9c7c6e  # 15:21  G     11     0    0   0  pstore: Solve lockdep warning by moving inode locks
git bisect good c58d4055c054fc6dc72f1be8bc71bd6fff209e48  # 15:35  G     11     0    0   0  Merge tag 'docs-4.12' of git://git.lwn.net/linux
git bisect  bad 6fd4e7f7744bd7859ca3cae19c4613252ebb6bff  # 15:43  B      0    11   22   0  Merge branch 'for-next' of git://git.samba.org/sfrench/cifs-2.6
git bisect  bad 5958cc49ed2961a059d92ae55afeeaba64a783a0  # 15:51  B      0     1   12   0  Merge tag 'usercopy-v4.12-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/kees/linux
git bisect  bad 517e1fbeb65f5eade8d14f46ac365db6c75aea9b  # 16:05  B      0    11   22   0  mm/usercopy: Drop extra is_vmalloc_or_module() check
git bisect good 96dc4f9fb64690fc34410415fd1fc609cf803f61  # 16:14  G     11     0    0   0  usercopy: Move enum for arch_within_stack_frames()
# first bad commit: [517e1fbeb65f5eade8d14f46ac365db6c75aea9b] mm/usercopy: Drop extra is_vmalloc_or_module() check
git bisect good 96dc4f9fb64690fc34410415fd1fc609cf803f61  # 16:17  G     31     0    0   0  usercopy: Move enum for arch_within_stack_frames()
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad 517e1fbeb65f5eade8d14f46ac365db6c75aea9b  # 16:31  B      0    11   22   0  mm/usercopy: Drop extra is_vmalloc_or_module() check
# extra tests on HEAD of linux-devel/devel-spot-201705070851
git bisect  bad 773f7f5cf2d18eb40343d1e4e9a49062739e0425  # 16:32  B      0    22   37   0  0day head guard for 'devel-spot-201705070851'
# extra tests on tree/branch linus/master
git bisect  bad 13e0988140374123bead1dd27c287354cb95108e  # 16:43  B      0    11   22   0  docs: complete bumping minimal GNU Make version to 3.81
# extra tests with first bad commit reverted
git bisect good 688e95d3e3571e6b1c08da62fc402f1c1c3d5542  # 16:53  G     10     0    0   0  Revert "mm/usercopy: Drop extra is_vmalloc_or_module() check"
# extra tests on tree/branch linux-next/master
git bisect  bad 9e597e815f68867c70d1b70cb2b037b92a8ec12b  # 17:06  B      0     9   27   7  Add linux-next specific files for 20170505

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_590ee3ad.MMDO8bLFgbUFGqMpxjTVyTOkfh0+P6mfL9xyPGfvVsiVBJjg
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-lkp-hsw01-17:20170507160406:i386-randconfig-c0-05071103:4.11.0-rc2-00002-g517e1fb:1.gz"

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

--=_590ee3ad.MMDO8bLFgbUFGqMpxjTVyTOkfh0+P6mfL9xyPGfvVsiVBJjg
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="reproduce-yocto-lkp-hsw01-17:20170507160406:i386-randconfig-c0-05071103:4.11.0-rc2-00002-g517e1fb:1"

#!/bin/bash

kernel=$1
initrd=yocto-trinity-i386.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep
	-kernel $kernel
	-initrd $initrd
	-m 256
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
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	console=tty0
	vga=normal
	rw
	drbd.minor_count=8
)

"${kvm[@]}" -append "${append[*]}"

--=_590ee3ad.MMDO8bLFgbUFGqMpxjTVyTOkfh0+P6mfL9xyPGfvVsiVBJjg
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-4.11.0-rc2-00002-g517e1fb"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 4.11.0-rc2 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_BITS_MAX=16
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
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
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_SMP=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=3
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

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
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_IRQ_DOMAIN_DEBUG=y
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
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
CONFIG_IRQ_TIME_ACCOUNTING=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_RCU_KTHREAD_PRIO=0
# CONFIG_RCU_NOCB_CPU is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_MEMCG_SWAP_ENABLED=y
# CONFIG_BLK_CGROUP is not set
# CONFIG_CGROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_RDMA is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_BPF is not set
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_SOCK_CGROUP_DATA is not set
CONFIG_CHECKPOINT_RESTORE=y
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
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_INITRAMFS_COMPRESSION=".gz"
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_MULTIUSER=y
# CONFIG_SGETMASK_SYSCALL is not set
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
# CONFIG_POSIX_TIMERS is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_ABSOLUTE_PERCPU is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
# CONFIG_PCSPKR_PLATFORM is not set
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
# CONFIG_AIO is not set
# CONFIG_ADVISE_SYSCALLS is not set
CONFIG_USERFAULTFD=y
CONFIG_PCI_QUIRKS=y
# CONFIG_MEMBARRIER is not set
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# CONFIG_VM_EVENT_COUNTERS is not set
# CONFIG_SLUB_DEBUG is not set
# CONFIG_SLUB_MEMCG_SYSFS_ON is not set
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_SLAB_FREELIST_RANDOM is not set
CONFIG_SLUB_CPU_PARTIAL=y
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
CONFIG_STATIC_KEYS_SELFTEST=y
CONFIG_UPROBES=y
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
CONFIG_ARCH_HAS_SET_MEMORY=y
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
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
# CONFIG_HAVE_ARCH_HASH is not set
# CONFIG_ISA_BUS_API is not set
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set
# CONFIG_HAVE_ARCH_VMAP_STACK is not set
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX is not set
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX_DEFAULT is not set
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_LBDAF=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
# CONFIG_BLK_DEV_BSGLIB is not set
# CONFIG_BLK_DEV_INTEGRITY is not set
# CONFIG_BLK_DEV_ZONED is not set
# CONFIG_BLK_CMDLINE_PARSER is not set
# CONFIG_BLK_WBT is not set
CONFIG_BLK_DEBUG_FS=y
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_MQ_IOSCHED_DEADLINE=y
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
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
# CONFIG_ZONE_DMA is not set
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_BIGSMP=y
# CONFIG_GOLDFISH is not set
CONFIG_INTEL_RDT_A=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
# CONFIG_X86_INTEL_QUARK is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
CONFIG_X86_RDC321X=y
# CONFIG_X86_32_NON_STANDARD is not set
# CONFIG_X86_32_IRIS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
CONFIG_MPENTIUMII=y
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
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
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
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
# CONFIG_DMI is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=32
# CONFIG_SCHED_SMT is not set
# CONFIG_SCHED_MC is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_ANCIENT_MCE=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=y
# CONFIG_X86_LEGACY_VM86 is not set
# CONFIG_VM86 is not set
# CONFIG_X86_16BIT is not set
CONFIG_TOSHIBA=y
CONFIG_I8K=y
CONFIG_X86_REBOOTFIXUPS=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_NOHIGHMEM is not set
# CONFIG_HIGHMEM4G is not set
CONFIG_HIGHMEM64G=y
# CONFIG_VMSPLIT_3G is not set
# CONFIG_VMSPLIT_2G is not set
CONFIG_VMSPLIT_1G=y
CONFIG_PAGE_OFFSET=0x40000000
CONFIG_HIGHMEM=y
CONFIG_X86_PAE=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_NUMA=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=3
CONFIG_NEED_NODE_MEMMAP_SIZE=y
CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
CONFIG_ARCH_DISCONTIGMEM_DEFAULT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_DISCONTIGMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MOVABLE_NODE is not set
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is not set
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_MEMORY_BALLOON=y
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_CLEANCACHE=y
# CONFIG_FRONTSWAP is not set
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_FRAME_VECTOR=y
CONFIG_X86_PMEM_LEGACY_DEVICE=y
CONFIG_X86_PMEM_LEGACY=y
CONFIG_HIGHPTE=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
# CONFIG_X86_PAT is not set
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_X86_INTEL_MPX is not set
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
CONFIG_DEBUG_HOTPLUG_CPU0=y
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_SUSPEND_SKIP_SYNC=y
# CONFIG_HIBERNATION is not set
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
# CONFIG_PM_WAKELOCKS_GC is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_DPM_WATCHDOG is not set
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_NUMA is not set
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_NFIT=y
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_ACPI_EXTLOG is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
# CONFIG_SFI is not set
# CONFIG_APM is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
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
CONFIG_PCI_BUS_ADDR_T_64BIT=y
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# DesignWare PCI Core Support
#

#
# PCI host controller drivers
#
# CONFIG_ISA_BUS is not set
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
# CONFIG_SCx200 is not set
CONFIG_ALIX=y
# CONFIG_NET5501 is not set
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
# CONFIG_BINFMT_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
CONFIG_COMPAT_32=y
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
# CONFIG_STREAM_PARSER is not set
CONFIG_WIRELESS=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
# CONFIG_LIB80211 is not set
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
# CONFIG_MAC80211_RC_MINSTREL_VHT is not set
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
# CONFIG_DST_CACHE is not set
# CONFIG_GRO_CELLS is not set
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
CONFIG_DEBUG_TEST_DRIVER_REMOVE=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_SPMI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_FENCE_TRACE=y
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
CONFIG_CMA_SIZE_SEL_PERCENTAGE=y
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=y
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
CONFIG_MTD_CMDLINE_PARTS=y
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
# CONFIG_MTD_BLOCK is not set
# CONFIG_MTD_BLOCK_RO is not set
# CONFIG_FTL is not set
# CONFIG_NFTL is not set
# CONFIG_INFTL is not set
# CONFIG_RFD_FTL is not set
# CONFIG_SSFDC is not set
# CONFIG_SM_FTL is not set
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_SWAP is not set
CONFIG_MTD_PARTITIONED_MASTER=y

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
CONFIG_MTD_CFI_NOSWAP=y
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
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
# CONFIG_MTD_CFI_INTELEXT is not set
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
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
CONFIG_MTD_AMD76XROM=y
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_DATAFLASH=y
# CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
# CONFIG_MTD_DATAFLASH_OTP is not set
# CONFIG_MTD_SST25L is not set
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
# CONFIG_MTD_NAND is not set
# CONFIG_MTD_ONENAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_MTD_UBI_BLOCK is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
# CONFIG_PARPORT_PC_FIFO is not set
CONFIG_PARPORT_PC_SUPERIO=y
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
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
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
# CONFIG_BLK_DEV_RAM_DAX is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RSXX is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_NVME_FC is not set
# CONFIG_NVME_TARGET is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
# CONFIG_TI_DAC7512 is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_LATTICE_ECP3_CONFIG is not set
# CONFIG_SRAM is not set
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
# CONFIG_PANEL_CHANGE_MESSAGE is not set
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_AT25=y
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_93XX46=y
CONFIG_EEPROM_IDT_89HPESX=y
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
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#

#
# SCIF Bus Driver
#

#
# VOP Bus Driver
#

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
# CONFIG_ECHO is not set
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_AFU_DRIVER_OPS is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_NETLINK is not set
# CONFIG_SCSI_MQ_DEFAULT is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
# CONFIG_CHR_DEV_SG is not set
# CONFIG_CHR_DEV_SCH is not set
# CONFIG_SCSI_ENCLOSURE is not set
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_BOOT_SYSFS is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_MPT2SAS is not set
# CONFIG_SCSI_SMARTPQI is not set
# CONFIG_SCSI_UFSHCD is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
# CONFIG_SCSI_SNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_ISCI is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_PPA is not set
# CONFIG_SCSI_IMM is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_AM53C974 is not set
# CONFIG_SCSI_NSP32 is not set
# CONFIG_SCSI_WD719X is not set
CONFIG_SCSI_DEBUG=y
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_VIRTIO is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
CONFIG_SATA_AHCI_PLATFORM=y
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_SX4 is not set
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
# CONFIG_ATA_PIIX is not set
# CONFIG_SATA_DWC is not set
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_SVW is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_ATP867X is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5535 is not set
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SCH is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_TOSHIBA is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_PLATFORM is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MD_MULTIPATH=y
# CONFIG_MD_FAULTY is not set
# CONFIG_BCACHE is not set
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_MQ_DEFAULT is not set
# CONFIG_DM_DEBUG is not set
# CONFIG_DM_CRYPT is not set
# CONFIG_DM_SNAPSHOT is not set
# CONFIG_DM_THIN_PROVISIONING is not set
# CONFIG_DM_CACHE is not set
# CONFIG_DM_ERA is not set
# CONFIG_DM_MIRROR is not set
# CONFIG_DM_RAID is not set
# CONFIG_DM_ZERO is not set
# CONFIG_DM_MULTIPATH is not set
# CONFIG_DM_DELAY is not set
# CONFIG_DM_UEVENT is not set
# CONFIG_DM_FLAKEY is not set
# CONFIG_DM_VERITY is not set
# CONFIG_DM_SWITCH is not set
# CONFIG_DM_LOG_WRITES is not set
# CONFIG_TARGET_CORE is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_LEDS is not set
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADC is not set
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
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
# CONFIG_MOUSE_PS2 is not set
# CONFIG_MOUSE_SERIAL is not set
CONFIG_MOUSE_APPLETOUCH=y
CONFIG_MOUSE_BCM5974=y
# CONFIG_MOUSE_CYAPA is not set
CONFIG_MOUSE_ELAN_I2C=y
CONFIG_MOUSE_ELAN_I2C_I2C=y
# CONFIG_MOUSE_ELAN_I2C_SMBUS is not set
# CONFIG_MOUSE_VSXXXAA is not set
CONFIG_MOUSE_GPIO=y
CONFIG_MOUSE_SYNAPTICS_I2C=y
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
# CONFIG_TOUCHSCREEN_88PM860X is not set
CONFIG_TOUCHSCREEN_ADS7846=y
CONFIG_TOUCHSCREEN_AD7877=y
# CONFIG_TOUCHSCREEN_AD7879 is not set
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_TOUCHSCREEN_AUO_PIXCIR=y
CONFIG_TOUCHSCREEN_BU21013=y
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
# CONFIG_TOUCHSCREEN_DA9034 is not set
CONFIG_TOUCHSCREEN_DA9052=y
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=y
# CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
CONFIG_TOUCHSCREEN_FUJITSU=y
CONFIG_TOUCHSCREEN_GOODIX=y
CONFIG_TOUCHSCREEN_ILI210X=y
CONFIG_TOUCHSCREEN_GUNZE=y
CONFIG_TOUCHSCREEN_EKTF2127=y
# CONFIG_TOUCHSCREEN_ELAN is not set
# CONFIG_TOUCHSCREEN_ELO is not set
CONFIG_TOUCHSCREEN_WACOM_W8001=y
CONFIG_TOUCHSCREEN_WACOM_I2C=y
CONFIG_TOUCHSCREEN_MAX11801=y
# CONFIG_TOUCHSCREEN_MCS5000 is not set
# CONFIG_TOUCHSCREEN_MMS114 is not set
CONFIG_TOUCHSCREEN_MELFAS_MIP4=y
# CONFIG_TOUCHSCREEN_MTOUCH is not set
CONFIG_TOUCHSCREEN_INEXIO=y
# CONFIG_TOUCHSCREEN_MK712 is not set
CONFIG_TOUCHSCREEN_PENMOUNT=y
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
CONFIG_TOUCHSCREEN_TOUCHWIN=y
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_WDT87XX_I2C=y
CONFIG_TOUCHSCREEN_WM831X=y
CONFIG_TOUCHSCREEN_USB_COMPOSITE=y
# CONFIG_TOUCHSCREEN_MC13783 is not set
# CONFIG_TOUCHSCREEN_USB_EGALAX is not set
CONFIG_TOUCHSCREEN_USB_PANJIT=y
# CONFIG_TOUCHSCREEN_USB_3M is not set
CONFIG_TOUCHSCREEN_USB_ITM=y
# CONFIG_TOUCHSCREEN_USB_ETURBO is not set
# CONFIG_TOUCHSCREEN_USB_GUNZE is not set
CONFIG_TOUCHSCREEN_USB_DMC_TSC10=y
# CONFIG_TOUCHSCREEN_USB_IRTOUCH is not set
CONFIG_TOUCHSCREEN_USB_IDEALTEK=y
CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=y
CONFIG_TOUCHSCREEN_USB_GOTOP=y
# CONFIG_TOUCHSCREEN_USB_JASTEC is not set
# CONFIG_TOUCHSCREEN_USB_ELO is not set
CONFIG_TOUCHSCREEN_USB_E2I=y
CONFIG_TOUCHSCREEN_USB_ZYTRONIC=y
CONFIG_TOUCHSCREEN_USB_ETT_TC45USB=y
# CONFIG_TOUCHSCREEN_USB_NEXIO is not set
# CONFIG_TOUCHSCREEN_USB_EASYTOUCH is not set
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
CONFIG_TOUCHSCREEN_TSC_SERIO=y
CONFIG_TOUCHSCREEN_TSC200X_CORE=y
# CONFIG_TOUCHSCREEN_TSC2004 is not set
CONFIG_TOUCHSCREEN_TSC2005=y
CONFIG_TOUCHSCREEN_TSC2007=y
# CONFIG_TOUCHSCREEN_RM_TS is not set
CONFIG_TOUCHSCREEN_SILEAD=y
# CONFIG_TOUCHSCREEN_SIS_I2C is not set
# CONFIG_TOUCHSCREEN_ST1232 is not set
CONFIG_TOUCHSCREEN_SURFACE3_SPI=y
# CONFIG_TOUCHSCREEN_SX8654 is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
CONFIG_TOUCHSCREEN_ZET6223=y
# CONFIG_TOUCHSCREEN_ZFORCE is not set
CONFIG_TOUCHSCREEN_ROHM_BU21023=y
# CONFIG_INPUT_MISC is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_USERIO is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
# CONFIG_N_GSM is not set
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
# CONFIG_DEVMEM is not set
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_FINTEK=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_FSL is not set
CONFIG_SERIAL_8250_DW=y
CONFIG_SERIAL_8250_RT288X=y
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
CONFIG_SERIAL_MAX310X=y
CONFIG_SERIAL_UARTLITE=y
# CONFIG_SERIAL_UARTLITE_CONSOLE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_SC16IS7XX_CORE=y
CONFIG_SERIAL_SC16IS7XX=y
# CONFIG_SERIAL_SC16IS7XX_I2C is not set
CONFIG_SERIAL_SC16IS7XX_SPI=y
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=y
CONFIG_SERIAL_FSL_LPUART_CONSOLE=y
CONFIG_SERIAL_MEN_Z135=y
# CONFIG_SERIAL_DEV_BUS is not set
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
# CONFIG_IPMI_SSIF is not set
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=y
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set
CONFIG_MWAVE=y
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_SPI=y
CONFIG_TCG_TIS_I2C_ATMEL=y
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=y
# CONFIG_TCG_NSC is not set
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
CONFIG_TCG_VTPM_PROXY=y
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
CONFIG_TCG_TIS_ST33ZP24_SPI=y
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

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
CONFIG_I2C_MUX_REG=y
CONFIG_I2C_MUX_MLXCPLD=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y

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
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_DESIGNWARE_BAYTRAIL is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_EMEV2 is not set
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
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT=y
# CONFIG_I2C_PARPORT_LIGHT is not set
CONFIG_I2C_ROBOTFUZZ_OSIF=y
CONFIG_I2C_TAOS_EVM=y
# CONFIG_I2C_TINY_USB is not set
CONFIG_I2C_VIPERBOARD=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_SCx200_ACB is not set
# CONFIG_I2C_SLAVE is not set
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
# CONFIG_SPI_AXI_SPI_ENGINE is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
CONFIG_SPI_CADENCE=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set
# CONFIG_SPI_DW_MMIO is not set
CONFIG_SPI_GPIO=y
CONFIG_SPI_LM70_LLP=y
CONFIG_SPI_OC_TINY=y
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_ROCKCHIP is not set
CONFIG_SPI_SC18IS602=y
# CONFIG_SPI_TOPCLIFF_PCH is not set
CONFIG_SPI_XCOMM=y
# CONFIG_SPI_XILINX is not set
CONFIG_SPI_ZYNQMP_GQSPI=y

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
CONFIG_SPI_TLE62X0=y
CONFIG_SPMI=y
# CONFIG_HSI is not set

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
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_EXAR is not set
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_LYNXPOINT=y
CONFIG_GPIO_MENZ127=y
CONFIG_GPIO_MOCKUP=y
# CONFIG_GPIO_VX855 is not set

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_IT87=y
# CONFIG_GPIO_SCH is not set
CONFIG_GPIO_SCH311X=y

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
CONFIG_GPIO_MAX7300=y
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#
CONFIG_GPIO_ADP5520=y
# CONFIG_GPIO_ARIZONA is not set
CONFIG_GPIO_CRYSTAL_COVE=y
CONFIG_GPIO_DA9052=y
# CONFIG_GPIO_DA9055 is not set
# CONFIG_GPIO_KEMPLD is not set
# CONFIG_GPIO_LP3943 is not set
# CONFIG_GPIO_TPS65086 is not set
CONFIG_GPIO_TPS6586X=y
# CONFIG_GPIO_TPS65910 is not set
CONFIG_GPIO_TPS65912=y
# CONFIG_GPIO_TWL4030 is not set
# CONFIG_GPIO_TWL6040 is not set
CONFIG_GPIO_WHISKEY_COVE=y
CONFIG_GPIO_WM831X=y
CONFIG_GPIO_WM8350=y

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_PCI_IDIO_16 is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
CONFIG_GPIO_MAX7301=y
# CONFIG_GPIO_MC33880 is not set
CONFIG_GPIO_PISOSR=y

#
# SPI or I2C GPIO expanders
#

#
# USB GPIO expanders
#
CONFIG_GPIO_VIPERBOARD=y
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
# CONFIG_W1_MASTER_DS2482 is not set
# CONFIG_W1_MASTER_DS1WM is not set
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
# CONFIG_W1_SLAVE_DS2405 is not set
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
# CONFIG_W1_SLAVE_DS2433 is not set
# CONFIG_W1_SLAVE_DS2760 is not set
# CONFIG_W1_SLAVE_DS2780 is not set
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
# CONFIG_POWER_AVS is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
CONFIG_GENERIC_ADC_BATTERY=y
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
CONFIG_WM8350_POWER=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_88PM860X=y
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
# CONFIG_CHARGER_SBS is not set
CONFIG_BATTERY_BQ27XXX=y
CONFIG_BATTERY_BQ27XXX_I2C=y
CONFIG_BATTERY_DA9030=y
CONFIG_BATTERY_DA9052=y
# CONFIG_BATTERY_DA9150 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
CONFIG_BATTERY_TWL4030_MADC=y
CONFIG_CHARGER_88PM860X=y
CONFIG_BATTERY_RX51=y
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
# CONFIG_CHARGER_TWL4030 is not set
CONFIG_CHARGER_LP8727=y
# CONFIG_CHARGER_GPIO is not set
CONFIG_CHARGER_MANAGER=y
# CONFIG_CHARGER_MAX14577 is not set
CONFIG_CHARGER_MAX77693=y
# CONFIG_CHARGER_MAX8997 is not set
# CONFIG_CHARGER_BQ2415X is not set
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24257=y
CONFIG_CHARGER_BQ24735=y
CONFIG_CHARGER_BQ25890=y
CONFIG_CHARGER_SMB347=y
# CONFIG_CHARGER_TPS65090 is not set
CONFIG_CHARGER_TPS65217=y
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
CONFIG_BATTERY_RT5033=y
# CONFIG_CHARGER_RT9455 is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_AD7314=y
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_F75375S=y
# CONFIG_SENSORS_MC13783_ADC is not set
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_FTSTEUTATES=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_G762 is not set
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IBMAEM=y
# CONFIG_SENSORS_IBMPEX is not set
# CONFIG_SENSORS_IIO_HWMON is not set
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_POWR1220 is not set
CONFIG_SENSORS_LINEAGE=y
# CONFIG_SENSORS_LTC2945 is not set
# CONFIG_SENSORS_LTC2990 is not set
CONFIG_SENSORS_LTC4151=y
# CONFIG_SENSORS_LTC4215 is not set
CONFIG_SENSORS_LTC4222=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX197 is not set
CONFIG_SENSORS_MAX31722=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MAX31790 is not set
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_TC654=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_LM95245 is not set
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_NCT7802=y
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_LM25066=y
CONFIG_SENSORS_LTC2978=y
CONFIG_SENSORS_LTC2978_REGULATOR=y
# CONFIG_SENSORS_LTC3815 is not set
CONFIG_SENSORS_MAX16064=y
# CONFIG_SENSORS_MAX20751 is not set
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
# CONFIG_SENSORS_TPS40422 is not set
# CONFIG_SENSORS_UCD9000 is not set
CONFIG_SENSORS_UCD9200=y
# CONFIG_SENSORS_ZL6100 is not set
# CONFIG_SENSORS_SHT15 is not set
# CONFIG_SENSORS_SHT21 is not set
CONFIG_SENSORS_SHT3x=y
# CONFIG_SENSORS_SHTC1 is not set
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
# CONFIG_SENSORS_SCH5636 is not set
CONFIG_SENSORS_STTS751=y
CONFIG_SENSORS_SMM665=y
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_INA3221=y
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=y
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP108=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_TWL4030_MADC=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=y
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=y
# CONFIG_SENSORS_WM831X is not set
CONFIG_SENSORS_WM8350=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_GOV_STEP_WISE is not set
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=y
CONFIG_X86_PKG_TEMP_THERMAL=y
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
CONFIG_INTEL_SOC_DTS_THERMAL=y

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
CONFIG_INTEL_BXT_PMIC_THERMAL=y
CONFIG_INTEL_PCH_THERMAL=y
# CONFIG_GENERIC_ADC_THERMAL is not set
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
CONFIG_WATCHDOG_NOWAYOUT=y
CONFIG_WATCHDOG_SYSFS=y

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
# CONFIG_SOFT_WATCHDOG_PRETIMEOUT is not set
CONFIG_DA9052_WATCHDOG=y
# CONFIG_DA9055_WATCHDOG is not set
CONFIG_DA9063_WATCHDOG=y
CONFIG_DA9062_WATCHDOG=y
# CONFIG_WDAT_WDT is not set
# CONFIG_WM831X_WATCHDOG is not set
CONFIG_WM8350_WATCHDOG=y
# CONFIG_XILINX_WATCHDOG is not set
CONFIG_ZIIRAVE_WATCHDOG=y
# CONFIG_CADENCE_WATCHDOG is not set
# CONFIG_DW_WATCHDOG is not set
CONFIG_TWL4030_WATCHDOG=y
CONFIG_MAX63XX_WATCHDOG=y
# CONFIG_RETU_WATCHDOG is not set
CONFIG_ACQUIRE_WDT=y
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
# CONFIG_WAFER_WDT is not set
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
# CONFIG_IT8712F_WDT is not set
CONFIG_IT87_WDT=y
# CONFIG_HP_WATCHDOG is not set
CONFIG_KEMPLD_WDT=y
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
# CONFIG_RDC321X_WDT is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
CONFIG_SBC7240_WDT=y
CONFIG_CPU5_WDT=y
# CONFIG_SMSC_SCH311X_WDT is not set
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
# CONFIG_W83877F_WDT is not set
CONFIG_W83977F_WDT=y
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
# CONFIG_NI903X_WDT is not set
# CONFIG_NIC7018_WDT is not set
# CONFIG_MEN_A21_WDT is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=y

#
# Watchdog Pretimeout Governors
#
CONFIG_WATCHDOG_PRETIMEOUT_GOV=y
CONFIG_WATCHDOG_PRETIMEOUT_DEFAULT_GOV_NOOP=y
# CONFIG_WATCHDOG_PRETIMEOUT_DEFAULT_GOV_PANIC is not set
CONFIG_WATCHDOG_PRETIMEOUT_GOV_NOOP=y
# CONFIG_WATCHDOG_PRETIMEOUT_GOV_PANIC is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
CONFIG_SSB_SILENT=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_SFLASH=y
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DRIVER_GPIO is not set
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_AAT2870_CORE=y
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_AXP20X_I2C is not set
# CONFIG_MFD_CROS_EC is not set
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
# CONFIG_MFD_DLN2 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
CONFIG_INTEL_SOC_PMIC=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX77843=y
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_MT6397=y
# CONFIG_MFD_MENF21BMC is not set
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RT5033=y
CONFIG_MFD_RTSX_USB=y
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
CONFIG_AB3100_OTP=y
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65086=y
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TI_LP873X is not set
# CONFIG_MFD_TPS65218 is not set
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS65912_SPI is not set
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
# CONFIG_MFD_TWL4030_AUDIO is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TIMBERDALE is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
# CONFIG_MFD_CS47L24 is not set
# CONFIG_MFD_WM5102 is not set
CONFIG_MFD_WM5110=y
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8998=y
# CONFIG_MFD_WM8400 is not set
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM831X_SPI=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PM8607=y
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AAT2870=y
CONFIG_REGULATOR_AB3100=y
CONFIG_REGULATOR_DA903X=y
# CONFIG_REGULATOR_DA9052 is not set
# CONFIG_REGULATOR_DA9055 is not set
CONFIG_REGULATOR_DA9062=y
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_GPIO is not set
CONFIG_REGULATOR_ISL9305=y
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LTC3589=y
CONFIG_REGULATOR_LTC3676=y
# CONFIG_REGULATOR_MAX14577 is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8997=y
# CONFIG_REGULATOR_MAX77693 is not set
CONFIG_REGULATOR_MC13XXX_CORE=y
# CONFIG_REGULATOR_MC13783 is not set
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_MT6323=y
CONFIG_REGULATOR_MT6397=y
# CONFIG_REGULATOR_PFUZE100 is not set
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=y
CONFIG_REGULATOR_PWM=y
# CONFIG_REGULATOR_QCOM_SPMI is not set
CONFIG_REGULATOR_RT5033=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS65086 is not set
# CONFIG_REGULATOR_TPS65090 is not set
# CONFIG_REGULATOR_TPS65217 is not set
CONFIG_REGULATOR_TPS6524X=y
CONFIG_REGULATOR_TPS6586X=y
CONFIG_REGULATOR_TPS65910=y
CONFIG_REGULATOR_TPS65912=y
# CONFIG_REGULATOR_TPS80031 is not set
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_WM831X=y
CONFIG_REGULATOR_WM8350=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
# CONFIG_MEDIA_RADIO_SUPPORT is not set
# CONFIG_MEDIA_SDR_SUPPORT is not set
CONFIG_MEDIA_RC_SUPPORT=y
# CONFIG_MEDIA_CEC_SUPPORT is not set
CONFIG_MEDIA_CONTROLLER=y
# CONFIG_MEDIA_CONTROLLER_DVB is not set
# CONFIG_VIDEO_ADV_DEBUG is not set
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_DVB_CORE=y
# CONFIG_TTPCI_EEPROM is not set
CONFIG_DVB_MAX_ADAPTERS=16
CONFIG_DVB_DYNAMIC_MINORS=y
# CONFIG_DVB_DEMUX_SECTION_LOSS_LOG is not set

#
# Media drivers
#
CONFIG_RC_CORE=y
# CONFIG_RC_MAP is not set
CONFIG_RC_DECODERS=y
# CONFIG_LIRC is not set
CONFIG_IR_NEC_DECODER=y
CONFIG_IR_RC5_DECODER=y
# CONFIG_IR_RC6_DECODER is not set
# CONFIG_IR_JVC_DECODER is not set
CONFIG_IR_SONY_DECODER=y
# CONFIG_IR_SANYO_DECODER is not set
CONFIG_IR_SHARP_DECODER=y
# CONFIG_IR_MCE_KBD_DECODER is not set
# CONFIG_IR_XMP_DECODER is not set
CONFIG_RC_DEVICES=y
CONFIG_RC_ATI_REMOTE=y
# CONFIG_IR_ENE is not set
CONFIG_IR_HIX5HD2=y
CONFIG_IR_IMON=y
CONFIG_IR_MCEUSB=y
# CONFIG_IR_ITE_CIR is not set
# CONFIG_IR_FINTEK is not set
# CONFIG_IR_NUVOTON is not set
# CONFIG_IR_REDRAT3 is not set
CONFIG_IR_STREAMZAP=y
# CONFIG_IR_WINBOND_CIR is not set
CONFIG_IR_IGORPLUGUSB=y
CONFIG_IR_IGUANA=y
# CONFIG_IR_TTUSBIR is not set
CONFIG_RC_LOOPBACK=y
CONFIG_IR_GPIO_CIR=y
# CONFIG_IR_SERIAL is not set
CONFIG_MEDIA_USB_SUPPORT=y

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_AU0828=y
CONFIG_VIDEO_AU0828_RC=y

#
# Digital TV USB devices
#
CONFIG_DVB_USB=y
# CONFIG_DVB_USB_DEBUG is not set
CONFIG_DVB_USB_DIB3000MC=y
# CONFIG_DVB_USB_A800 is not set
CONFIG_DVB_USB_DIBUSB_MB=y
CONFIG_DVB_USB_DIBUSB_MB_FAULTY=y
# CONFIG_DVB_USB_DIBUSB_MC is not set
CONFIG_DVB_USB_DIB0700=y
CONFIG_DVB_USB_UMT_010=y
CONFIG_DVB_USB_CXUSB=y
CONFIG_DVB_USB_M920X=y
CONFIG_DVB_USB_DIGITV=y
CONFIG_DVB_USB_VP7045=y
CONFIG_DVB_USB_VP702X=y
# CONFIG_DVB_USB_GP8PSK is not set
CONFIG_DVB_USB_NOVA_T_USB2=y
CONFIG_DVB_USB_TTUSB2=y
CONFIG_DVB_USB_DTT200U=y
CONFIG_DVB_USB_OPERA1=y
CONFIG_DVB_USB_AF9005=y
CONFIG_DVB_USB_AF9005_REMOTE=y
# CONFIG_DVB_USB_PCTV452E is not set
# CONFIG_DVB_USB_DW2102 is not set
CONFIG_DVB_USB_CINERGY_T2=y
# CONFIG_DVB_USB_DTV5100 is not set
# CONFIG_DVB_USB_FRIIO is not set
# CONFIG_DVB_USB_AZ6027 is not set
# CONFIG_DVB_USB_TECHNISAT_USB2 is not set
CONFIG_DVB_USB_V2=y
CONFIG_DVB_USB_AF9015=y
# CONFIG_DVB_USB_AF9035 is not set
CONFIG_DVB_USB_ANYSEE=y
CONFIG_DVB_USB_AU6610=y
CONFIG_DVB_USB_AZ6007=y
# CONFIG_DVB_USB_CE6230 is not set
# CONFIG_DVB_USB_EC168 is not set
# CONFIG_DVB_USB_GL861 is not set
CONFIG_DVB_USB_LME2510=y
CONFIG_DVB_USB_MXL111SF=y
# CONFIG_DVB_USB_RTL28XXU is not set
# CONFIG_DVB_USB_DVBSKY is not set
# CONFIG_DVB_USB_ZD1301 is not set
# CONFIG_DVB_TTUSB_BUDGET is not set
# CONFIG_DVB_TTUSB_DEC is not set
CONFIG_SMS_USB_DRV=y
# CONFIG_DVB_B2C2_FLEXCOP_USB is not set
CONFIG_DVB_AS102=y

#
# Webcam, TV (analog/digital) USB devices
#
# CONFIG_MEDIA_PCI_SUPPORT is not set
CONFIG_DVB_PLATFORM_DRIVERS=y

#
# Supported MMC/SDIO adapters
#
# CONFIG_SMS_SDIO_DRV is not set
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_TVEEPROM=y
CONFIG_CYPRESS_FIRMWARE=y
CONFIG_SMS_SIANO_MDTV=y
CONFIG_SMS_SIANO_RC=y

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
# CONFIG_MEDIA_TUNER_SIMPLE is not set
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
# CONFIG_MEDIA_TUNER_TEA5761 is not set
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_MT2060=y
CONFIG_MEDIA_TUNER_MT2063=y
CONFIG_MEDIA_TUNER_MT2266=y
# CONFIG_MEDIA_TUNER_MT2131 is not set
CONFIG_MEDIA_TUNER_QT1010=y
CONFIG_MEDIA_TUNER_XC2028=y
# CONFIG_MEDIA_TUNER_XC5000 is not set
# CONFIG_MEDIA_TUNER_XC4000 is not set
# CONFIG_MEDIA_TUNER_MXL5005S is not set
CONFIG_MEDIA_TUNER_MXL5007T=y
CONFIG_MEDIA_TUNER_MC44S803=y
CONFIG_MEDIA_TUNER_MAX2165=y
CONFIG_MEDIA_TUNER_TDA18218=y
CONFIG_MEDIA_TUNER_FC0011=y
CONFIG_MEDIA_TUNER_FC0012=y
# CONFIG_MEDIA_TUNER_FC0013 is not set
CONFIG_MEDIA_TUNER_TDA18212=y
CONFIG_MEDIA_TUNER_E4000=y
# CONFIG_MEDIA_TUNER_FC2580 is not set
CONFIG_MEDIA_TUNER_M88RS6000T=y
CONFIG_MEDIA_TUNER_TUA9001=y
CONFIG_MEDIA_TUNER_SI2157=y
CONFIG_MEDIA_TUNER_IT913X=y
# CONFIG_MEDIA_TUNER_R820T is not set
# CONFIG_MEDIA_TUNER_MXL301RF is not set
# CONFIG_MEDIA_TUNER_QM1D1C0042 is not set

#
# Customise DVB Frontends
#

#
# Multistandard (satellite) frontends
#
# CONFIG_DVB_STB0899 is not set
CONFIG_DVB_STB6100=y
# CONFIG_DVB_STV090x is not set
CONFIG_DVB_STV6110x=y
CONFIG_DVB_M88DS3103=y

#
# Multistandard (cable + terrestrial) frontends
#
# CONFIG_DVB_DRXK is not set
# CONFIG_DVB_TDA18271C2DD is not set
CONFIG_DVB_SI2165=y
CONFIG_DVB_MN88472=y
# CONFIG_DVB_MN88473 is not set

#
# DVB-S (satellite) frontends
#
# CONFIG_DVB_CX24110 is not set
CONFIG_DVB_CX24123=y
CONFIG_DVB_MT312=y
# CONFIG_DVB_ZL10036 is not set
CONFIG_DVB_ZL10039=y
CONFIG_DVB_S5H1420=y
CONFIG_DVB_STV0288=y
CONFIG_DVB_STB6000=y
CONFIG_DVB_STV0299=y
CONFIG_DVB_STV6110=y
# CONFIG_DVB_STV0900 is not set
CONFIG_DVB_TDA8083=y
CONFIG_DVB_TDA10086=y
# CONFIG_DVB_TDA8261 is not set
CONFIG_DVB_VES1X93=y
CONFIG_DVB_TUNER_ITD1000=y
# CONFIG_DVB_TUNER_CX24113 is not set
CONFIG_DVB_TDA826X=y
# CONFIG_DVB_TUA6100 is not set
# CONFIG_DVB_CX24116 is not set
# CONFIG_DVB_CX24117 is not set
CONFIG_DVB_CX24120=y
# CONFIG_DVB_SI21XX is not set
CONFIG_DVB_TS2020=y
CONFIG_DVB_DS3000=y
# CONFIG_DVB_MB86A16 is not set
# CONFIG_DVB_TDA10071 is not set

#
# DVB-T (terrestrial) frontends
#
# CONFIG_DVB_SP8870 is not set
# CONFIG_DVB_SP887X is not set
CONFIG_DVB_CX22700=y
CONFIG_DVB_CX22702=y
CONFIG_DVB_S5H1432=y
CONFIG_DVB_DRXD=y
CONFIG_DVB_L64781=y
# CONFIG_DVB_TDA1004X is not set
# CONFIG_DVB_NXT6000 is not set
CONFIG_DVB_MT352=y
# CONFIG_DVB_ZL10353 is not set
CONFIG_DVB_DIB3000MB=y
CONFIG_DVB_DIB3000MC=y
# CONFIG_DVB_DIB7000M is not set
CONFIG_DVB_DIB7000P=y
# CONFIG_DVB_DIB9000 is not set
CONFIG_DVB_TDA10048=y
CONFIG_DVB_AF9013=y
CONFIG_DVB_EC100=y
CONFIG_DVB_STV0367=y
CONFIG_DVB_CXD2820R=y
CONFIG_DVB_CXD2841ER=y
CONFIG_DVB_RTL2830=y
# CONFIG_DVB_RTL2832 is not set
CONFIG_DVB_SI2168=y
CONFIG_DVB_AS102_FE=y
CONFIG_DVB_ZD1301_DEMOD=y
# CONFIG_DVB_GP8PSK_FE is not set

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
CONFIG_DVB_TDA10021=y
# CONFIG_DVB_TDA10023 is not set
# CONFIG_DVB_STV0297 is not set

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
CONFIG_DVB_OR51211=y
# CONFIG_DVB_OR51132 is not set
CONFIG_DVB_BCM3510=y
CONFIG_DVB_LGDT330X=y
CONFIG_DVB_LGDT3305=y
# CONFIG_DVB_LGDT3306A is not set
CONFIG_DVB_LG2160=y
CONFIG_DVB_S5H1409=y
# CONFIG_DVB_AU8522_DTV is not set
# CONFIG_DVB_S5H1411 is not set

#
# ISDB-T (terrestrial) frontends
#
# CONFIG_DVB_S921 is not set
# CONFIG_DVB_DIB8000 is not set
CONFIG_DVB_MB86A20S=y

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=y

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y
CONFIG_DVB_TUNER_DIB0070=y
CONFIG_DVB_TUNER_DIB0090=y

#
# SEC control devices for DVB-S
#
CONFIG_DVB_DRX39XYJ=y
# CONFIG_DVB_LNBH25 is not set
CONFIG_DVB_LNBP21=y
CONFIG_DVB_LNBP22=y
CONFIG_DVB_ISL6405=y
# CONFIG_DVB_ISL6421 is not set
CONFIG_DVB_ISL6423=y
# CONFIG_DVB_A8293 is not set
CONFIG_DVB_SP2=y
CONFIG_DVB_LGS8GL5=y
CONFIG_DVB_LGS8GXX=y
CONFIG_DVB_ATBM8830=y
# CONFIG_DVB_TDA665x is not set
CONFIG_DVB_IX2505V=y
CONFIG_DVB_M88RS2000=y
# CONFIG_DVB_AF9033 is not set
# CONFIG_DVB_HORUS3A is not set
CONFIG_DVB_ASCOT2E=y
CONFIG_DVB_HELENE=y

#
# Tools to develop new frontends
#
CONFIG_DVB_DUMMY_FE=y

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set

#
# ACP (Audio CoProcessor) Configuration
#
# CONFIG_DRM_LIB_RANDOM is not set

#
# Frame buffer Devices
#
# CONFIG_FB is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
# CONFIG_BACKLIGHT_LM3533 is not set
CONFIG_BACKLIGHT_PWM=y
CONFIG_BACKLIGHT_DA903X=y
CONFIG_BACKLIGHT_DA9052=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP5520=y
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_88PM860X is not set
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3630A=y
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_TPS65217=y
# CONFIG_BACKLIGHT_GPIO is not set
CONFIG_BACKLIGHT_LV5207LP=y
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_VGASTATE is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
# CONFIG_SND is not set
CONFIG_SOUND_PRIME=y
CONFIG_SOUND_OSS=y
# CONFIG_SOUND_TRACEINIT is not set
CONFIG_SOUND_DMAP=y
# CONFIG_SOUND_VMIDI is not set
CONFIG_SOUND_TRIX=y
# CONFIG_TRIX_HAVE_BOOT is not set
# CONFIG_SOUND_MSS is not set
CONFIG_SOUND_MPU401=y
CONFIG_SOUND_PAS=y
CONFIG_PAS_JOYSTICK=y
# CONFIG_SOUND_PSS is not set
# CONFIG_SOUND_SB is not set
# CONFIG_SOUND_YM3812 is not set
CONFIG_SOUND_UART6850=y
CONFIG_SOUND_AEDSP16=y
CONFIG_SC6600=y
CONFIG_SC6600_JOY=y
CONFIG_SC6600_CDROM=4
CONFIG_SC6600_CDROMBASE=0

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
CONFIG_HID_ACRUX_FF=y
# CONFIG_HID_APPLE is not set
# CONFIG_HID_APPLEIR is not set
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
CONFIG_HID_BETOP_FF=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_CORSAIR is not set
CONFIG_HID_CMEDIA=y
# CONFIG_HID_CP2112 is not set
CONFIG_HID_CYPRESS=y
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
CONFIG_HID_ELO=y
CONFIG_HID_EZKEY=y
CONFIG_HID_GEMBIRD=y
CONFIG_HID_GFRM=y
CONFIG_HID_HOLTEK=y
CONFIG_HOLTEK_FF=y
# CONFIG_HID_GT683R is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
CONFIG_HID_UCLOGIC=y
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
CONFIG_HID_LED=y
# CONFIG_HID_LENOVO is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=y
CONFIG_HID_LOGITECH_HIDPP=y
# CONFIG_LOGITECH_FF is not set
CONFIG_LOGIRUMBLEPAD2_FF=y
CONFIG_LOGIG940_FF=y
CONFIG_LOGIWHEELS_FF=y
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MAYFLASH is not set
CONFIG_HID_MICROSOFT=y
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTRIG is not set
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
# CONFIG_HID_PENMOUNT is not set
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
# CONFIG_HID_PICOLCD_BACKLIGHT is not set
# CONFIG_HID_PICOLCD_LEDS is not set
CONFIG_HID_PICOLCD_CIR=y
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
CONFIG_HID_ROCCAT=y
CONFIG_HID_SAITEK=y
# CONFIG_HID_SAMSUNG is not set
CONFIG_HID_SONY=y
CONFIG_SONY_FF=y
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
# CONFIG_HID_RMI is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
CONFIG_HID_UDRAW_PS3=y
CONFIG_HID_WACOM=y
# CONFIG_HID_WIIMOTE is not set
CONFIG_HID_XINMO=y
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=y
CONFIG_HID_SENSOR_CUSTOM_SENSOR=y
# CONFIG_HID_ALPS is not set

#
# USB HID support
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG=y
# CONFIG_USB_OTG_WHITELIST is not set
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_OTG_FSM=y
CONFIG_USB_LEDS_TRIGGER_USBPORT=y
CONFIG_USB_MON=y
CONFIG_USB_WUSB=y
CONFIG_USB_WUSB_CBAF=y
CONFIG_USB_WUSB_CBAF_DEBUG=y

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
# CONFIG_USB_EHCI_HCD is not set
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_ISP1362_HCD=y
# CONFIG_USB_FOTG210_HCD is not set
# CONFIG_USB_MAX3421_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_SSB is not set
CONFIG_USB_OHCI_HCD_PLATFORM=y
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_R8A66597_HCD=y
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=y
CONFIG_USB_HCD_BCMA=y
CONFIG_USB_HCD_SSB=y
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
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
CONFIG_USB_MDC800=y
# CONFIG_USB_MICROTEK is not set
# CONFIG_USBIP_CORE is not set
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_HOST=y

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_HOST=y

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
# CONFIG_USB_DWC2 is not set
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1760_HOST_ROLE=y

#
# USB port drivers
#
# CONFIG_USB_USS720 is not set
CONFIG_USB_SERIAL=y
# CONFIG_USB_SERIAL_CONSOLE is not set
# CONFIG_USB_SERIAL_GENERIC is not set
# CONFIG_USB_SERIAL_SIMPLE is not set
CONFIG_USB_SERIAL_AIRCABLE=y
# CONFIG_USB_SERIAL_ARK3116 is not set
CONFIG_USB_SERIAL_BELKIN=y
# CONFIG_USB_SERIAL_CH341 is not set
CONFIG_USB_SERIAL_WHITEHEAT=y
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=y
# CONFIG_USB_SERIAL_CP210X is not set
CONFIG_USB_SERIAL_CYPRESS_M8=y
CONFIG_USB_SERIAL_EMPEG=y
CONFIG_USB_SERIAL_FTDI_SIO=y
CONFIG_USB_SERIAL_VISOR=y
CONFIG_USB_SERIAL_IPAQ=y
CONFIG_USB_SERIAL_IR=y
CONFIG_USB_SERIAL_EDGEPORT=y
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
# CONFIG_USB_SERIAL_F81232 is not set
CONFIG_USB_SERIAL_F8153X=y
# CONFIG_USB_SERIAL_GARMIN is not set
# CONFIG_USB_SERIAL_IPW is not set
CONFIG_USB_SERIAL_IUU=y
CONFIG_USB_SERIAL_KEYSPAN_PDA=y
CONFIG_USB_SERIAL_KEYSPAN=y
# CONFIG_USB_SERIAL_KLSI is not set
CONFIG_USB_SERIAL_KOBIL_SCT=y
CONFIG_USB_SERIAL_MCT_U232=y
# CONFIG_USB_SERIAL_METRO is not set
CONFIG_USB_SERIAL_MOS7720=y
CONFIG_USB_SERIAL_MOS7715_PARPORT=y
CONFIG_USB_SERIAL_MOS7840=y
# CONFIG_USB_SERIAL_MXUPORT is not set
CONFIG_USB_SERIAL_NAVMAN=y
# CONFIG_USB_SERIAL_PL2303 is not set
CONFIG_USB_SERIAL_OTI6858=y
# CONFIG_USB_SERIAL_QCAUX is not set
# CONFIG_USB_SERIAL_QUALCOMM is not set
CONFIG_USB_SERIAL_SPCP8X5=y
# CONFIG_USB_SERIAL_SAFE is not set
CONFIG_USB_SERIAL_SIERRAWIRELESS=y
CONFIG_USB_SERIAL_SYMBOL=y
# CONFIG_USB_SERIAL_TI is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
CONFIG_USB_SERIAL_XIRCOM=y
CONFIG_USB_SERIAL_WWAN=y
CONFIG_USB_SERIAL_OPTION=y
CONFIG_USB_SERIAL_OMNINET=y
# CONFIG_USB_SERIAL_OPTICON is not set
CONFIG_USB_SERIAL_XSENS_MT=y
CONFIG_USB_SERIAL_WISHBONE=y
CONFIG_USB_SERIAL_SSU100=y
# CONFIG_USB_SERIAL_QT2 is not set
# CONFIG_USB_SERIAL_UPD78F0730 is not set
CONFIG_USB_SERIAL_DEBUG=y

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=y
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
# CONFIG_USB_CYPRESS_CY7C63 is not set
CONFIG_USB_CYTHERM=y
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HUB_USB251XB is not set
CONFIG_USB_HSIC_USB3503=y
CONFIG_USB_HSIC_USB4604=y
CONFIG_USB_LINK_LAYER_TEST=y
# CONFIG_USB_CHAOSKEY is not set
# CONFIG_UCSI is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_TAHVO_USB=y
CONFIG_TAHVO_USB_HOST_BY_DEFAULT=y
# CONFIG_USB_ISP1301 is not set
# CONFIG_USB_GADGET is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=y
CONFIG_UWB_HWA=y
# CONFIG_UWB_WHCI is not set
CONFIG_UWB_I1480U=y
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_MMC_BLOCK_BOUNCE=y
CONFIG_SDIO_UART=y
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
# CONFIG_MMC_VUB300 is not set
CONFIG_MMC_USHC=y
CONFIG_MMC_USDHI6ROL0=y
CONFIG_MMC_REALTEK_USB=y
# CONFIG_MMC_TOSHIBA_PCI is not set
CONFIG_MMC_MTK=y
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y
# CONFIG_MSPRO_BLOCK is not set
# CONFIG_MS_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_MEMSTICK_REALTEK_USB=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
# CONFIG_LEDS_88PM860X is not set
CONFIG_LEDS_LM3530=y
# CONFIG_LEDS_LM3533 is not set
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
# CONFIG_LEDS_LP8860 is not set
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM831X_STATUS=y
# CONFIG_LEDS_WM8350 is not set
CONFIG_LEDS_DA903X=y
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_DAC124S085=y
# CONFIG_LEDS_PWM is not set
# CONFIG_LEDS_REGULATOR is not set
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_ADP5520=y
CONFIG_LEDS_MC13783=y
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_TLC591XX is not set
CONFIG_LEDS_MAX8997=y
CONFIG_LEDS_LM355x=y
# CONFIG_LEDS_OT200 is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
# CONFIG_LEDS_BLINKM is not set
# CONFIG_LEDS_USER is not set
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
# CONFIG_LEDS_TRIGGER_DISK is not set
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
CONFIG_LEDS_TRIGGER_CAMERA=y
CONFIG_LEDS_TRIGGER_PANIC=y
CONFIG_ACCESSIBILITY=y
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
# CONFIG_DMADEVICES_VDEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_INTEL_IDMA64=y
# CONFIG_PCH_DMA is not set
CONFIG_QCOM_HIDMA_MGMT=y
CONFIG_QCOM_HIDMA=y
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
CONFIG_DW_DMAC_PCI=y
CONFIG_HSU_DMA=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_PRUSS is not set
# CONFIG_UIO_MF624 is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_INPUT is not set
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_RTS5208 is not set

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16201=y
CONFIG_ADIS16203=y
CONFIG_ADIS16209=y
# CONFIG_ADIS16240 is not set

#
# Analog to digital converters
#
# CONFIG_AD7606 is not set
CONFIG_AD7780=y
# CONFIG_AD7816 is not set
# CONFIG_AD7192 is not set
# CONFIG_AD7280 is not set

#
# Analog digital bi-direction converters
#
# CONFIG_ADT7316 is not set

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
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
# CONFIG_ADIS16060 is not set

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=y

#
# Light sensors
#
CONFIG_SENSORS_ISL29028=y
# CONFIG_TSL2x7x is not set

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

#
# Speakup console speech
#
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
CONFIG_ASHMEM=y
# CONFIG_ANDROID_LOW_MEMORY_KILLER is not set
# CONFIG_ION is not set
# CONFIG_DGNC is not set
# CONFIG_GS_FPGABOOT is not set
# CONFIG_MOST is not set
# CONFIG_KS7010 is not set
CONFIG_GREYBUS=y
CONFIG_GREYBUS_ES2=y
CONFIG_GREYBUS_AUDIO=y
# CONFIG_GREYBUS_BOOTROM is not set
# CONFIG_GREYBUS_FIRMWARE is not set
CONFIG_GREYBUS_HID=y
# CONFIG_GREYBUS_LIGHT is not set
CONFIG_GREYBUS_LOG=y
# CONFIG_GREYBUS_LOOPBACK is not set
# CONFIG_GREYBUS_POWER is not set
# CONFIG_GREYBUS_RAW is not set
# CONFIG_GREYBUS_VIBRATOR is not set
CONFIG_GREYBUS_BRIDGED_PHY=y
# CONFIG_GREYBUS_GPIO is not set
# CONFIG_GREYBUS_I2C is not set
CONFIG_GREYBUS_PWM=y
CONFIG_GREYBUS_SDIO=y
# CONFIG_GREYBUS_SPI is not set
CONFIG_GREYBUS_UART=y
CONFIG_GREYBUS_USB=y
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_DELL_SMO8800 is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ASUS_WIRELESS is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_HID_EVENT is not set
# CONFIG_INTEL_VBTN is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_INTEL_PMC_CORE is not set
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=y
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_INTEL_PMC_IPC is not set
# CONFIG_SURFACE_PRO3_BUTTON is not set
# CONFIG_INTEL_PUNIT_IPC is not set
CONFIG_MLX_CPLD_PLATFORM=y
CONFIG_PMC_ATOM=y
# CONFIG_CHROME_PLATFORMS is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_WM831X is not set
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
# CONFIG_CLK_TWL6040 is not set
# CONFIG_COMMON_CLK_NXP is not set
# CONFIG_COMMON_CLK_PWM is not set
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
# CONFIG_PCC is not set
CONFIG_ALTERA_MBOX=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#

#
# Broadcom SoC drivers
#
# CONFIG_SUNXI_SRAM is not set
CONFIG_SOC_TI=y
CONFIG_SOC_ZTE=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
# CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND is not set
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
# CONFIG_DEVFREQ_GOV_USERSPACE is not set
CONFIG_DEVFREQ_GOV_PASSIVE=y

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
# CONFIG_EXTCON_INTEL_INT3496 is not set
# CONFIG_EXTCON_MAX14577 is not set
CONFIG_EXTCON_MAX3355=y
CONFIG_EXTCON_MAX77693=y
# CONFIG_EXTCON_MAX77843 is not set
CONFIG_EXTCON_MAX8997=y
CONFIG_EXTCON_QCOM_SPMI_MISC=y
CONFIG_EXTCON_RT8973A=y
# CONFIG_EXTCON_SM5502 is not set
# CONFIG_EXTCON_USB_GPIO is not set
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
CONFIG_IIO_SW_DEVICE=y
# CONFIG_IIO_SW_TRIGGER is not set

#
# Accelerometers
#
# CONFIG_BMA180 is not set
CONFIG_BMA220=y
CONFIG_BMC150_ACCEL=y
CONFIG_BMC150_ACCEL_I2C=y
CONFIG_BMC150_ACCEL_SPI=y
CONFIG_DA280=y
CONFIG_DA311=y
# CONFIG_DMARD09 is not set
# CONFIG_DMARD10 is not set
CONFIG_HID_SENSOR_ACCEL_3D=y
# CONFIG_KXSD9 is not set
CONFIG_KXCJK1013=y
CONFIG_MC3230=y
CONFIG_MMA7455=y
CONFIG_MMA7455_I2C=y
# CONFIG_MMA7455_SPI is not set
CONFIG_MMA7660=y
CONFIG_MMA8452=y
CONFIG_MMA9551_CORE=y
CONFIG_MMA9551=y
CONFIG_MMA9553=y
# CONFIG_MXC4005 is not set
CONFIG_MXC6255=y
# CONFIG_SCA3000 is not set
CONFIG_STK8312=y
# CONFIG_STK8BA50 is not set

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
CONFIG_AD7266=y
CONFIG_AD7291=y
CONFIG_AD7298=y
# CONFIG_AD7476 is not set
CONFIG_AD7766=y
# CONFIG_AD7791 is not set
CONFIG_AD7793=y
CONFIG_AD7887=y
CONFIG_AD7923=y
# CONFIG_AD799X is not set
# CONFIG_CC10001_ADC is not set
# CONFIG_DA9150_GPADC is not set
# CONFIG_HI8435 is not set
CONFIG_HX711=y
# CONFIG_LTC2485 is not set
CONFIG_MAX1027=y
# CONFIG_MAX11100 is not set
# CONFIG_MAX1363 is not set
CONFIG_MCP320X=y
CONFIG_MCP3422=y
CONFIG_MEN_Z188_ADC=y
CONFIG_NAU7802=y
# CONFIG_QCOM_SPMI_IADC is not set
CONFIG_QCOM_SPMI_VADC=y
# CONFIG_TI_ADC081C is not set
CONFIG_TI_ADC0832=y
# CONFIG_TI_ADC12138 is not set
CONFIG_TI_ADC128S052=y
CONFIG_TI_ADC161S626=y
CONFIG_TI_ADS7950=y
CONFIG_TI_AM335X_ADC=y
# CONFIG_TI_TLC4541 is not set
CONFIG_TWL4030_MADC=y
CONFIG_TWL6030_GPADC=y
CONFIG_VIPERBOARD_ADC=y

#
# Amplifiers
#
# CONFIG_AD8366 is not set

#
# Chemical Sensors
#
# CONFIG_ATLAS_PH_SENSOR is not set
CONFIG_IAQCORE=y
CONFIG_VZ89X=y

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_IIO_TRIGGER=y
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
CONFIG_IIO_SSP_SENSORS_COMMONS=y
CONFIG_IIO_SSP_SENSORHUB=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Counters
#

#
# Digital to analog converters
#
CONFIG_AD5064=y
# CONFIG_AD5360 is not set
CONFIG_AD5380=y
# CONFIG_AD5421 is not set
CONFIG_AD5446=y
CONFIG_AD5449=y
CONFIG_AD5592R_BASE=y
CONFIG_AD5592R=y
# CONFIG_AD5593R is not set
CONFIG_AD5504=y
CONFIG_AD5624R_SPI=y
CONFIG_AD5686=y
CONFIG_AD5755=y
# CONFIG_AD5761 is not set
CONFIG_AD5764=y
# CONFIG_AD5791 is not set
# CONFIG_AD7303 is not set
# CONFIG_AD8801 is not set
# CONFIG_M62332 is not set
CONFIG_MAX517=y
CONFIG_MCP4725=y
# CONFIG_MCP4922 is not set

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
CONFIG_AD9523=y

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=y

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16080 is not set
CONFIG_ADIS16130=y
CONFIG_ADIS16136=y
# CONFIG_ADIS16260 is not set
CONFIG_ADXRS450=y
CONFIG_BMG160=y
CONFIG_BMG160_I2C=y
CONFIG_BMG160_SPI=y
# CONFIG_HID_SENSOR_GYRO_3D is not set
CONFIG_MPU3050=y
CONFIG_MPU3050_I2C=y
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
CONFIG_AFE4404=y
CONFIG_MAX30100=y

#
# Humidity sensors
#
# CONFIG_AM2315 is not set
CONFIG_DHT11=y
CONFIG_HDC100X=y
CONFIG_HTS221=y
CONFIG_HTS221_I2C=y
CONFIG_HTS221_SPI=y
# CONFIG_HTU21 is not set
CONFIG_SI7005=y
CONFIG_SI7020=y

#
# Inertial measurement units
#
CONFIG_ADIS16400=y
# CONFIG_ADIS16480 is not set
CONFIG_BMI160=y
CONFIG_BMI160_I2C=y
CONFIG_BMI160_SPI=y
# CONFIG_KMX61 is not set
CONFIG_INV_MPU6050_IIO=y
CONFIG_INV_MPU6050_I2C=y
# CONFIG_INV_MPU6050_SPI is not set
# CONFIG_IIO_ST_LSM6DSX is not set
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
# CONFIG_ADJD_S311 is not set
# CONFIG_AL3320A is not set
CONFIG_APDS9300=y
CONFIG_APDS9960=y
CONFIG_BH1750=y
CONFIG_BH1780=y
# CONFIG_CM32181 is not set
CONFIG_CM3232=y
CONFIG_CM3323=y
CONFIG_CM36651=y
CONFIG_GP2AP020A00F=y
CONFIG_SENSORS_ISL29018=y
CONFIG_ISL29125=y
# CONFIG_HID_SENSOR_ALS is not set
CONFIG_HID_SENSOR_PROX=y
CONFIG_JSA1212=y
CONFIG_RPR0521=y
CONFIG_SENSORS_LM3533=y
CONFIG_LTR501=y
# CONFIG_MAX44000 is not set
CONFIG_OPT3001=y
CONFIG_PA12203001=y
CONFIG_SI1145=y
CONFIG_STK3310=y
# CONFIG_TCS3414 is not set
CONFIG_TCS3472=y
CONFIG_SENSORS_TSL2563=y
CONFIG_TSL2583=y
CONFIG_TSL4531=y
CONFIG_US5182D=y
CONFIG_VCNL4000=y
# CONFIG_VEML6070 is not set

#
# Magnetometer sensors
#
CONFIG_AK8975=y
# CONFIG_AK09911 is not set
CONFIG_BMC150_MAGN=y
# CONFIG_BMC150_MAGN_I2C is not set
CONFIG_BMC150_MAGN_SPI=y
# CONFIG_MAG3110 is not set
CONFIG_HID_SENSOR_MAGNETOMETER_3D=y
CONFIG_MMC35240=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
CONFIG_IIO_ST_MAGN_SPI_3AXIS=y
CONFIG_SENSORS_HMC5843=y
CONFIG_SENSORS_HMC5843_I2C=y
# CONFIG_SENSORS_HMC5843_SPI is not set

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=y
# CONFIG_HID_SENSOR_DEVICE_ROTATION is not set

#
# Triggers - standalone
#
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Digital potentiometers
#
CONFIG_DS1803=y
# CONFIG_MAX5481 is not set
CONFIG_MAX5487=y
# CONFIG_MCP4131 is not set
# CONFIG_MCP4531 is not set
CONFIG_TPL0102=y

#
# Digital potentiostats
#
# CONFIG_LMP91000 is not set

#
# Pressure sensors
#
CONFIG_ABP060MG=y
CONFIG_BMP280=y
CONFIG_BMP280_I2C=y
CONFIG_BMP280_SPI=y
CONFIG_HID_SENSOR_PRESS=y
# CONFIG_HP03 is not set
CONFIG_MPL115=y
CONFIG_MPL115_I2C=y
CONFIG_MPL115_SPI=y
# CONFIG_MPL3115 is not set
# CONFIG_MS5611 is not set
CONFIG_MS5637=y
# CONFIG_IIO_ST_PRESS is not set
CONFIG_T5403=y
# CONFIG_HP206C is not set
CONFIG_ZPA2326=y
CONFIG_ZPA2326_I2C=y
CONFIG_ZPA2326_SPI=y

#
# Lightning sensors
#
CONFIG_AS3935=y

#
# Proximity and distance sensors
#
CONFIG_LIDAR_LITE_V2=y
CONFIG_SX9500=y
CONFIG_SRF08=y

#
# Temperature sensors
#
CONFIG_MAXIM_THERMOCOUPLE=y
# CONFIG_MLX90614 is not set
# CONFIG_TMP006 is not set
CONFIG_TMP007=y
# CONFIG_TSYS01 is not set
# CONFIG_TSYS02D is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_CRC=y
CONFIG_PWM_LP3943=y
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
# CONFIG_PWM_PCA9685 is not set
CONFIG_PWM_TWL=y
# CONFIG_PWM_TWL_LED is not set
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_RESET_ATH79 is not set
# CONFIG_RESET_BERLIN is not set
# CONFIG_RESET_LPC18XX is not set
# CONFIG_RESET_MESON is not set
# CONFIG_RESET_PISTACHIO is not set
# CONFIG_RESET_SOCFPGA is not set
# CONFIG_RESET_STM32 is not set
# CONFIG_RESET_SUNXI is not set
CONFIG_TI_SYSCON_RESET=y
# CONFIG_RESET_ZYNQ is not set
# CONFIG_RESET_TEGRA_BPMP is not set
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
CONFIG_FMC_TRIVIAL=y
CONFIG_FMC_WRITE_EEPROM=y
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_PHY_PXA_28NM_HSIC is not set
# CONFIG_PHY_PXA_28NM_USB2 is not set
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=y
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set
CONFIG_MCB_LPC=y

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_MCE_AMD_INJ is not set
# CONFIG_THUNDERBOLT is not set

#
# Android
#
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_ANDROID_BINDER_DEVICES="binder"
CONFIG_ANDROID_BINDER_IPC_32BIT=y
CONFIG_LIBNVDIMM=y
CONFIG_BLK_DEV_PMEM=y
CONFIG_ND_BLK=y
CONFIG_ND_CLAIM=y
CONFIG_ND_BTT=y
CONFIG_BTT=y
CONFIG_DEV_DAX=y
CONFIG_NR_DEV_DAX=32768
CONFIG_NVMEM=y
CONFIG_STM=y
CONFIG_STM_DUMMY=y
CONFIG_STM_SOURCE_CONSOLE=y
CONFIG_STM_SOURCE_HEARTBEAT=y
# CONFIG_STM_SOURCE_FTRACE is not set
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
CONFIG_INTEL_TH_GTH=y
CONFIG_INTEL_TH_STH=y
# CONFIG_INTEL_TH_MSU is not set
CONFIG_INTEL_TH_PTI=y
CONFIG_INTEL_TH_DEBUG=y

#
# FPGA Configuration Support
#
CONFIG_FPGA=y

#
# FSI support
#
# CONFIG_FSI is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=y
CONFIG_FW_CFG_SYSFS_CMDLINE=y
# CONFIG_GOOGLE_FIRMWARE is not set
# CONFIG_EFI_DEV_PATH_PARSER is not set

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
# CONFIG_EXT4_FS is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
CONFIG_OCFS2_FS=y
CONFIG_OCFS2_FS_O2CB=y
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
# CONFIG_BTRFS_FS is not set
# CONFIG_NILFS2_FS is not set
# CONFIG_F2FS_FS is not set
CONFIG_FS_DAX=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
# CONFIG_MANDATORY_FILE_LOCKING is not set
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
# CONFIG_QFMT_V2 is not set
CONFIG_QUOTACTL=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
# CONFIG_MSDOS_FS is not set
# CONFIG_VFAT_FS is not set
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
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
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_JFFS2_FS is not set
# CONFIG_UBIFS_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_SQUASHFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
CONFIG_PSTORE_ZLIB_COMPRESS=y
# CONFIG_PSTORE_LZO_COMPRESS is not set
# CONFIG_PSTORE_LZ4_COMPRESS is not set
CONFIG_PSTORE_CONSOLE=y
CONFIG_PSTORE_PMSG=y
# CONFIG_PSTORE_FTRACE is not set
CONFIG_PSTORE_RAM=y
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
# CONFIG_NLS_MAC_CENTEURO is not set
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
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
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
# CONFIG_MAGIC_SYSRQ_SERIAL is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_PAGE_POISONING=y
# CONFIG_PAGE_POISONING_NO_SANITY is not set
# CONFIG_PAGE_POISONING_ZERO is not set
CONFIG_DEBUG_PAGE_REF=y
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=y
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
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_WQ_WATCHDOG=y
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
# CONFIG_SCHED_STACK_END_CHECK is not set
CONFIG_DEBUG_TIMEKEEPING=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_LOCK_TORTURE_TEST=y
# CONFIG_WW_MUTEX_SELFTEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_TORTURE_TEST=y
CONFIG_RCU_PERF_TEST=y
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT is not set
# CONFIG_RCU_TORTURE_TEST_SLOW_INIT is not set
# CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_MAKE_REQUEST is not set
# CONFIG_FAIL_IO_TIMEOUT is not set
# CONFIG_FAIL_FUTEX is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_LATENCYTOP=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
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
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_HWLAT_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
CONFIG_PROFILE_ANNOTATED_BRANCHES=y
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_BRANCH_TRACER is not set
# CONFIG_STACK_TRACER is not set
# CONFIG_BLK_DEV_IO_TRACE is not set
CONFIG_UPROBE_EVENTS=y
CONFIG_BPF_EVENTS=y
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
# CONFIG_FUNCTION_PROFILER is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
CONFIG_TRACEPOINT_BENCHMARK=y
CONFIG_RING_BUFFER_BENCHMARK=y
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
CONFIG_TRACE_ENUM_MAP_FILE=y
# CONFIG_TRACING_EVENTS_GPIO is not set

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
CONFIG_TEST_LIST_SORT=y
# CONFIG_TEST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_ASYNC_RAID6_TEST is not set
CONFIG_TEST_HEXDUMP=y
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
CONFIG_TEST_PRINTF=y
CONFIG_TEST_BITMAP=y
# CONFIG_TEST_UUID is not set
CONFIG_TEST_RHASHTABLE=y
# CONFIG_TEST_HASH is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_FIRMWARE=y
# CONFIG_TEST_UDELAY is not set
# CONFIG_MEMTEST is not set
CONFIG_BUG_ON_DATA_CORRUPTION=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
# CONFIG_X86_PTDUMP_CORE is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_WX is not set
# CONFIG_DOUBLEFAULT is not set
CONFIG_DEBUG_TLBFLUSH=y
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
# CONFIG_X86_DEBUG_FPU is not set
# CONFIG_PUNIT_ATOM_DEBUG is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HAVE_ARCH_HARDENED_USERCOPY=y
CONFIG_HARDENED_USERCOPY=y
CONFIG_HARDENED_USERCOPY_PAGESPAN=y
# CONFIG_STATIC_USERMODEHELPER is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
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
CONFIG_CRYPTO_ACOMP2=y
# CONFIG_CRYPTO_RSA is not set
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
# CONFIG_CRYPTO_MCRYPTD is not set
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y
CONFIG_CRYPTO_ENGINE=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=y
# CONFIG_CRYPTO_ECHAINIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
# CONFIG_CRYPTO_CRC32 is not set
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST6 is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
# CONFIG_CRYPTO_SALSA20_586 is not set
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
# CONFIG_CRYPTO_TWOFISH_586 is not set

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
# CONFIG_CRYPTO_LZ4 is not set
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_CRYPTO_DEV_GEODE is not set
# CONFIG_CRYPTO_DEV_FSL_CAAM_CRYPTO_API_DESC is not set
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
CONFIG_CRYPTO_DEV_VIRTIO=y
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y

#
# Certificates for signature checking
#
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_KVM is not set
# CONFIG_VHOST_NET is not set
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set
# CONFIG_LGUEST is not set
CONFIG_BINARY_PRINTF=y

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
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
CONFIG_XZ_DEC_POWERPC=y
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
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
# CONFIG_DMA_NOOP_OPS is not set
# CONFIG_DMA_VIRT_OPS is not set
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
CONFIG_GLOB_SELFTEST=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
# CONFIG_IRQ_POLL is not set
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_SBITMAP=y

--=_590ee3ad.MMDO8bLFgbUFGqMpxjTVyTOkfh0+P6mfL9xyPGfvVsiVBJjg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
