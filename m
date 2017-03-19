Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B7EEA6B0038
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 18:51:35 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 79so139353867pgf.2
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 15:51:35 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id v1si15431952plk.19.2017.03.19.15.51.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Mar 2017 15:51:34 -0700 (PDT)
Date: Mon, 20 Mar 2017 06:51:24 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [x86/mm/gup] 2947ba054a [   71.329069] kernel BUG at
 include/linux/pagemap.h:151!
Message-ID: <20170319225124.xodpqjldom6ceazz@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="xqkdgemdwi5wxj5z"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, LKP <lkp@01.org>


--xqkdgemdwi5wxj5z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git x86/mm

commit 2947ba054a4dabbd82848728d765346886050029
Author:     Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
AuthorDate: Fri Mar 17 00:39:06 2017 +0300
Commit:     Ingo Molnar <mingo@kernel.org>
CommitDate: Sat Mar 18 09:48:03 2017 +0100

     x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation
     
     This patch provides all required callbacks required by the generic
     get_user_pages_fast() code and switches x86 over - and removes
     the platform specific implementation.
     
     Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
     Cc: Andrew Morton <akpm@linux-foundation.org>
     Cc: Aneesh Kumar K . V <aneesh.kumar@linux.vnet.ibm.com>
     Cc: Borislav Petkov <bp@alien8.de>
     Cc: Catalin Marinas <catalin.marinas@arm.com>
     Cc: Dann Frazier <dann.frazier@canonical.com>
     Cc: Dave Hansen <dave.hansen@intel.com>
     Cc: H. Peter Anvin <hpa@zytor.com>
     Cc: Linus Torvalds <torvalds@linux-foundation.org>
     Cc: Peter Zijlstra <peterz@infradead.org>
     Cc: Rik van Riel <riel@redhat.com>
     Cc: Steve Capper <steve.capper@linaro.org>
     Cc: Thomas Gleixner <tglx@linutronix.de>
     Cc: linux-arch@vger.kernel.org
     Cc: linux-mm@kvack.org
     Link: http://lkml.kernel.org/r/20170316213906.89528-1-kirill.shutemov@linux.intel.com
     [ Minor readability edits. ]
     Signed-off-by: Ingo Molnar <mingo@kernel.org>

73e10a6181  mm/gup: Provide callback to check if __GUP_fast() is allowed for the range
2947ba054a  x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation
5b781c7e31  x86/tls: Forcibly set the accessed bit in TLS segments
d730a1a1d7  Merge branch 'linus'
+------------------------------------------+------------+------------+------------+------------+
|                                          | 73e10a6181 | 2947ba054a | 5b781c7e31 | d730a1a1d7 |
+------------------------------------------+------------+------------+------------+------------+
| boot_successes                           | 198        | 64         | 74         | 13         |
| boot_failures                            | 3          | 6          | 2          | 4          |
| BUG:unable_to_handle_kernel              | 3          | 2          | 0          | 3          |
| Oops:#[##]                               | 3          | 2          | 0          | 3          |
| Kernel_panic-not_syncing:Fatal_exception | 3          | 6          | 2          | 4          |
| kernel_BUG_at_include/linux/pagemap.h    | 0          | 4          | 2          | 1          |
| invalid_opcode:#[##]                     | 0          | 4          | 2          | 1          |
+------------------------------------------+------------+------------+------------+------------+

[   62.968921] init: networking main process (452) terminated with status 1
[   62.968921] init: networking main process (452) terminated with status 1
[   64.749439] Writes:  Total: 2  Max/Min: 0/0   Fail: 0 
[   70.486518] sock: process `trinity-main' is using obsolete setsockopt SO_BSDCOMPAT
[   71.326909] ------------[ cut here ]------------
[   71.329069] kernel BUG at include/linux/pagemap.h:151!
[   71.329069] kernel BUG at include/linux/pagemap.h:151!
[   71.332456] invalid opcode: 0000 [#1]
[   71.332456] invalid opcode: 0000 [#1]
[   71.334359] CPU: 0 PID: 458 Comm: trinity-c0 Not tainted 4.11.0-rc2-00251-g2947ba0 #1
[   71.334359] CPU: 0 PID: 458 Comm: trinity-c0 Not tainted 4.11.0-rc2-00251-g2947ba0 #1
[   71.338444] task: ffff88001f19ab00 task.stack: ffff88001f084000
[   71.338444] task: ffff88001f19ab00 task.stack: ffff88001f084000
[   71.340586] RIP: 0010:gup_pud_range+0x56f/0x63d
[   71.340586] RIP: 0010:gup_pud_range+0x56f/0x63d
[   71.342886] RSP: 0018:ffff88001f087ba8 EFLAGS: 00010046
[   71.342886] RSP: 0018:ffff88001f087ba8 EFLAGS: 00010046
[   71.345607] RAX: 0000000080000000 RBX: 000000000164e000 RCX: ffff88001e0badc0
[   71.345607] RAX: 0000000080000000 RBX: 000000000164e000 RCX: ffff88001e0badc0
[   71.347923] RDX: dead000000000100 RSI: 0000000000000001 RDI: ffff88001e0badc0
[   71.347923] RDX: dead000000000100 RSI: 0000000000000001 RDI: ffff88001e0badc0
[   71.350249] RBP: ffff88001f087c38 R08: ffff88001f087cf8 R09: ffff88001f087c6c
[   71.350249] RBP: ffff88001f087c38 R08: ffff88001f087cf8 R09: ffff88001f087c6c
[   71.352741] R10: 0000000000000000 R11: ffff88001f19b0f0 R12: ffff88001f087c6c
[   71.352741] R10: 0000000000000000 R11: ffff88001f19b0f0 R12: ffff88001f087c6c
[   71.356086] R13: ffff88001e0badc0 R14: 800000001e7b7867 R15: 0000000000000000
[   71.356086] R13: ffff88001e0badc0 R14: 800000001e7b7867 R15: 0000000000000000
[   71.359328] FS:  00007f7ea7b60700(0000) GS:ffffffffae02f000(0000) knlGS:0000000000000000
[   71.359328] FS:  00007f7ea7b60700(0000) GS:ffffffffae02f000(0000) knlGS:0000000000000000
[   71.361945] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   71.361945] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   71.363806] CR2: 00000000013eb130 CR3: 0000000017ddb000 CR4: 00000000000006f0
[   71.363806] CR2: 00000000013eb130 CR3: 0000000017ddb000 CR4: 00000000000006f0
[   71.366122] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   71.366122] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   71.368424] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000d0602
[   71.368424] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000d0602
[   71.370729] Call Trace:
[   71.370729] Call Trace:
[   71.371537]  __get_user_pages_fast+0x107/0x136
[   71.371537]  __get_user_pages_fast+0x107/0x136
[   71.373435]  get_user_pages_fast+0x78/0x89
[   71.373435]  get_user_pages_fast+0x78/0x89
[   71.375447]  get_futex_key+0xfd/0x350
[   71.375447]  get_futex_key+0xfd/0x350
[   71.376999]  ? simple_write_end+0x83/0xbe
[   71.376999]  ? simple_write_end+0x83/0xbe
[   71.378614]  futex_requeue+0x1a3/0x585
[   71.378614]  futex_requeue+0x1a3/0x585
[   71.380244]  do_futex+0x834/0x86f
[   71.380244]  do_futex+0x834/0x86f
[   71.381893]  ? kvm_clock_read+0x16/0x1e
[   71.381893]  ? kvm_clock_read+0x16/0x1e
[   71.383794]  ? paravirt_sched_clock+0x9/0xd
[   71.383794]  ? paravirt_sched_clock+0x9/0xd
[   71.385857]  ? lock_release+0x11e/0x328
[   71.385857]  ? lock_release+0x11e/0x328
[   71.387760]  SyS_futex+0x125/0x135
[   71.387760]  SyS_futex+0x125/0x135
[   71.389446]  ? write_seqcount_end+0x1a/0x1f
[   71.389446]  ? write_seqcount_end+0x1a/0x1f
[   71.391499]  ? vtime_account_user+0x4b/0x50
[   71.391499]  ? vtime_account_user+0x4b/0x50
[   71.393404]  do_syscall_64+0x61/0x74
[   71.393404]  do_syscall_64+0x61/0x74
[   71.394806]  entry_SYSCALL64_slow_path+0x25/0x25
[   71.394806]  entry_SYSCALL64_slow_path+0x25/0x25
[   71.396853] RIP: 0033:0x7f7ea76756d9
[   71.396853] RIP: 0033:0x7f7ea76756d9
[   71.398617] RSP: 002b:00007ffcc92aa7b8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
[   71.398617] RSP: 002b:00007ffcc92aa7b8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
[   71.402322] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f7ea76756d9
[   71.402322] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f7ea76756d9
[   71.405421] RDX: 000000000000be98 RSI: 0000000000000004 RDI: 000000000164e690
[   71.405421] RDX: 000000000000be98 RSI: 0000000000000004 RDI: 000000000164e690
[   71.408674] RBP: 00000000000000ca R08: 00000000013e3110 R09: 950000000000002d
[   71.408674] RBP: 00000000000000ca R08: 00000000013e3110 R09: 950000000000002d
[   71.411757] R10: 0000000000f4e000 R11: 0000000000000246 R12: 0000000000000000
[   71.411757] R10: 0000000000f4e000 R11: 0000000000000246 R12: 0000000000000000
[   71.414998] R13: 00000000000000ca R14: 00000000000000ca R15: 950000000000002d
[   71.414998] R13: 00000000000000ca R14: 00000000000000ca R15: 950000000000002d
[   71.418178] Code: c1 e1 06 49 83 e5 fc 49 01 cd 4c 89 ef e8 20 f7 ff ff 48 89 c1 8b 05 18 83 10 01 a9 00 ff 1f 00 74 02 0f 0b a9 ff ff ff 7f 75 02 <0f> 0b 48 89 cf e8 fd f6 ff ff 8b 40 1c 85 c0 75 11 48 c7 c6 e5 
[   71.418178] Code: c1 e1 06 49 83 e5 fc 49 01 cd 4c 89 ef e8 20 f7 ff ff 48 89 c1 8b 05 18 83 10 01 a9 00 ff 1f 00 74 02 0f 0b a9 ff ff ff 7f 75 02 <0f> 0b 48 89 cf e8 fd f6 ff ff 8b 40 1c 85 c0 75 11 48 c7 c6 e5 
[   71.426515] RIP: gup_pud_range+0x56f/0x63d RSP: ffff88001f087ba8
[   71.426515] RIP: gup_pud_range+0x56f/0x63d RSP: ffff88001f087ba8
[   71.428870] ---[ end trace 86b31f300c9b87a7 ]---
[   71.428870] ---[ end trace 86b31f300c9b87a7 ]---

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start 9872ac2f754f4f5e572dc16bdc879dca0c7cd1bc 4495c08e84729385774601b5146d51d9e5849f81 --
git bisect  bad 092f53447eb7673382c281411fc3d1fb7e10b10d  # 01:26  B      9     1    0   0  Merge 'linux-review/Moritz-Fischer/fpga-altera_freeze_bridge-Constify-ops/20170319-164702' into devel-spot-201703192350
git bisect  bad 78dd5ec52f02b1a3a0755b265afccf0230590bd8  # 01:43  B      6     1    0   0  Merge 'linux-review/David-Rivshin/gpio-omap-return-error-if-requested-debounce-time-is-not-possible/20170319-201713' into devel-spot-201703192350
git bisect good 235b66a6e627c0d011570699e85445456a7c51c9  # 02:04  G     68     0    0   0  Merge 'saeed/net-rc' into devel-spot-201703192350
git bisect  bad 1cb74cc1571bbb6ade2de556ca868e8471065f18  # 02:14  B      3     1    0   0  Merge 'iio/fixes-togreg' into devel-spot-201703192350
git bisect  bad 764d81941ec35d3cb0eac136358f43bfb86c6cd6  # 02:25  B      0     1   11   0  Merge 'tip/x86/mm' into devel-spot-201703192350
git bisect good d11507e197242aaab172d7f1d0fe4771fbffa530  # 02:44  G     68     0    0   0  Merge tag 'xfs-4.11-fixes-2' of git://git.kernel.org/pub/scm/fs/xfs/xfs-linux
git bisect good f06bdd4001c257792c54dce9427399f2896470af  # 03:00  G     68     0    0   0  x86/mm: Adapt MODULES_END based on fixmap section size
git bisect good e7884f8ead4a301b04687a3238527b06feef8ea0  # 03:17  G     63     0    0   2  mm/gup: Move permission checks into helpers
git bisect good b59f65fa076a8eac2ff3a8ab7f8e1705b9fa86cb  # 03:43  G     66     0    0   3  mm/gup: Implement the dev_pagemap() logic in the generic get_user_pages_fast() function
git bisect  bad 2947ba054a4dabbd82848728d765346886050029  # 03:58  B     13     1    0   2  x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation
git bisect good 73e10a61817dfc97fe7418bfad1f608e562d7348  # 04:27  G     64     0    1   3  mm/gup: Provide callback to check if __GUP_fast() is allowed for the range
# first bad commit: [2947ba054a4dabbd82848728d765346886050029] x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation
git bisect good 73e10a61817dfc97fe7418bfad1f608e562d7348  # 04:48  G    191     0    0   3  mm/gup: Provide callback to check if __GUP_fast() is allowed for the range
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad 2947ba054a4dabbd82848728d765346886050029  # 05:04  B      2     1    0   2  x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation
# extra tests on HEAD of linux-devel/devel-spot-201703192350
git bisect  bad 9872ac2f754f4f5e572dc16bdc879dca0c7cd1bc  # 05:04  B     21     4    0   0  0day head guard for 'devel-spot-201703192350'
# extra tests on tree/branch tip/x86/mm
git bisect  bad 5b781c7e317fcf9f74475dc82bfce2e359dfca13  # 05:28  B     43     1    0   0  x86/tls: Forcibly set the accessed bit in TLS segments
# extra tests with first bad commit reverted
git bisect good ebfa79a64457cb162e3ab9fd6d26cfdefd03e604  # 05:59  G    173     0    0   0  Revert "x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation"
# extra tests on tree/branch tip/master
git bisect  bad d730a1a1d7cbf6d447312f1a1a1c79d252fd7aea  # 06:17  B     12     1    0   2  Merge branch 'linus'

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--xqkdgemdwi5wxj5z
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-quantal-ivb41-122:20170320035940:x86_64-randconfig-g0-03200012:4.11.0-rc2-00251-g2947ba0:1.gz"
Content-Transfer-Encoding: base64

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

--xqkdgemdwi5wxj5z
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-quantal-ivb41-109:20170320042221:x86_64-randconfig-g0-03200012:4.11.0-rc2-00250-g73e10a6:2.gz"
Content-Transfer-Encoding: base64

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

--xqkdgemdwi5wxj5z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="reproduce-quantal-ivb41-122:20170320035940:x86_64-randconfig-g0-03200012:4.11.0-rc2-00251-g2947ba0:1"

#!/bin/bash

kernel=$1
initrd=quantal-core-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu kvm64
	-kernel $kernel
	-initrd $initrd
	-m 512
	-smp 2
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

--xqkdgemdwi5wxj5z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.11.0-rc2-00251-g2947ba0"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.11.0-rc2 Kernel Configuration
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
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

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
CONFIG_KERNEL_LZO=y
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
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
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ=y
# CONFIG_HIGH_RES_TIMERS is not set

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
CONFIG_TINY_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
# CONFIG_RCU_STALL_COMMON is not set
CONFIG_CONTEXT_TRACKING=y
CONFIG_CONTEXT_TRACKING_FORCE=y
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
# CONFIG_MEMCG is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_RDMA=y
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_HUGETLB is not set
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_BPF=y
CONFIG_CGROUP_DEBUG=y
CONFIG_SOCK_CGROUP_DATA=y
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_INITRAMFS_COMPRESSION=".gz"
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
# CONFIG_SYSFS_SYSCALL is not set
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
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_ADVISE_SYSCALLS=y
# CONFIG_USERFAULTFD is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_MEMBARRIER is not set
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
# CONFIG_VM_EVENT_COUNTERS is not set
# CONFIG_SLUB_DEBUG is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
CONFIG_PROFILING=y
CONFIG_KEXEC_CORE=y
CONFIG_OPROFILE=y
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
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
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
CONFIG_GCC_PLUGINS=y
CONFIG_GCC_PLUGIN_CYC_COMPLEXITY=y
CONFIG_GCC_PLUGIN_LATENT_ENTROPY=y
# CONFIG_GCC_PLUGIN_STRUCTLEAK is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
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
CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
# CONFIG_HAVE_ARCH_HASH is not set
CONFIG_ISA_BUS_API=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set
CONFIG_HAVE_ARCH_VMAP_STACK=y
# CONFIG_VMAP_STACK is not set
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
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
# CONFIG_BLK_DEV_BSGLIB is not set
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_ZONED is not set
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_CMDLINE_PARSER is not set
# CONFIG_BLK_WBT is not set
# CONFIG_BLK_DEBUG_FS is not set
CONFIG_BLK_SED_OPAL=y

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y
CONFIG_BLOCK_COMPAT=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
# CONFIG_IOSCHED_CFQ is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_NOOP=y
CONFIG_DEFAULT_IOSCHED="noop"
# CONFIG_MQ_IOSCHED_DEADLINE is not set
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_FAST_FEATURE_TESTS is not set
# CONFIG_X86_X2APIC is not set
# CONFIG_X86_MPPARSE is not set
CONFIG_GOLDFISH=y
CONFIG_INTEL_RDT_A=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
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
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
# CONFIG_DMI is not set
CONFIG_GART_IOMMU=y
CONFIG_CALGARY_IOMMU=y
# CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y

#
# Performance monitoring
#
# CONFIG_PERF_EVENTS_INTEL_UNCORE is not set
# CONFIG_PERF_EVENTS_INTEL_RAPL is not set
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=y
# CONFIG_VM86 is not set
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
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
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_HAVE_GENERIC_GUP=y
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
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_MEMORY_FAILURE is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
CONFIG_MEM_SOFT_DIRTY=y
CONFIG_ZPOOL=y
# CONFIG_ZBUD is not set
CONFIG_Z3FOLD=y
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
# CONFIG_X86_PMEM_LEGACY is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
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
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
# CONFIG_KEXEC_FILE is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_RANDOMIZE_MEMORY is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
# CONFIG_MODIFY_LDT_SYSCALL is not set
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
# CONFIG_PM_AUTOSLEEP is not set
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
CONFIG_PM_WAKELOCKS_GC=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_SLEEP_DEBUG=y
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
CONFIG_PM_CLK=y
CONFIG_PM_GENERIC_DOMAINS=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_PM_GENERIC_DOMAINS_SLEEP=y
CONFIG_PM_GENERIC_DOMAINS_OF=y
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
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_NFIT is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_DPTF_POWER is not set
# CONFIG_ACPI_EXTLOG is not set
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
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
# CONFIG_HT_IRQ is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# DesignWare PCI Core Support
#
CONFIG_PCIE_DW=y
CONFIG_PCIE_DW_HOST=y
CONFIG_PCIE_DW_PLAT=y

#
# PCI host controller drivers
#
# CONFIG_VMD is not set
CONFIG_ISA_BUS=y
# CONFIG_ISA_DMA_API is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
# CONFIG_YENTA_O2 is not set
CONFIG_YENTA_RICOH=y
# CONFIG_YENTA_TI is not set
CONFIG_YENTA_TOSHIBA=y
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
CONFIG_RAPIDIO_DMA_ENGINE=y
CONFIG_RAPIDIO_DEBUG=y
CONFIG_RAPIDIO_ENUM_BASIC=y
# CONFIG_RAPIDIO_CHMAN is not set
# CONFIG_RAPIDIO_MPORT_CDEV is not set

#
# RapidIO Switch drivers
#
# CONFIG_RAPIDIO_TSI57X is not set
CONFIG_RAPIDIO_CPS_XX=y
CONFIG_RAPIDIO_TSI568=y
CONFIG_RAPIDIO_CPS_GEN2=y
CONFIG_RAPIDIO_RXS_GEN3=y
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT_32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
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
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_STREAM_PARSER is not set
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
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
# CONFIG_DST_CACHE is not set
# CONFIG_GRO_CELLS is not set
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set
# CONFIG_DMA_CMA is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
CONFIG_MTD_CMDLINE_PARTS=y
# CONFIG_MTD_OF_PARTS is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
# CONFIG_MTD_BLOCK is not set
CONFIG_MTD_BLOCK_RO=y
CONFIG_FTL=y
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
# CONFIG_INFTL is not set
# CONFIG_RFD_FTL is not set
CONFIG_SSFDC=y
CONFIG_SM_FTL=y
# CONFIG_MTD_OOPS is not set
CONFIG_MTD_SWAP=y
CONFIG_MTD_PARTITIONED_MASTER=y

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
CONFIG_MTD_CFI_LE_BYTE_SWAP=y
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
CONFIG_MTD_OTP=y
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
# CONFIG_MTD_RAM is not set
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
CONFIG_MTD_PHYSMAP_OF=y
CONFIG_MTD_PHYSMAP_OF_VERSATILE=y
# CONFIG_MTD_PHYSMAP_OF_GEMINI is not set
CONFIG_MTD_SBC_GXX=y
CONFIG_MTD_AMD76XROM=y
CONFIG_MTD_ICHXROM=y
CONFIG_MTD_ESB2ROM=y
CONFIG_MTD_CK804XROM=y
CONFIG_MTD_SCB2_FLASH=y
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
CONFIG_MTD_PCI=y
CONFIG_MTD_INTEL_VR_NOR=y
# CONFIG_MTD_PLATRAM is not set
# CONFIG_MTD_LATCH_ADDR is not set

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=y
CONFIG_MTD_PMC551_BUGFIX=y
# CONFIG_MTD_PMC551_DEBUG is not set
CONFIG_MTD_DATAFLASH=y
CONFIG_MTD_DATAFLASH_WRITE_VERIFY=y
# CONFIG_MTD_DATAFLASH_OTP is not set
# CONFIG_MTD_SST25L is not set
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=y
CONFIG_MTD_NAND_ECC_SMC=y
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
CONFIG_MTD_UBI_FASTMAP=y
CONFIG_MTD_UBI_GLUEBI=y
# CONFIG_MTD_UBI_BLOCK is not set
CONFIG_DTC=y
CONFIG_OF=y
CONFIG_OF_UNITTEST=y
CONFIG_OF_FLATTREE=y
CONFIG_OF_EARLY_FLATTREE=y
# CONFIG_OF_DYNAMIC is not set
CONFIG_OF_ADDRESS=y
CONFIG_OF_ADDRESS_PCI=y
CONFIG_OF_IRQ=y
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
CONFIG_OF_RESOLVE=y
# CONFIG_OF_OVERLAY is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

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
CONFIG_NVME_FABRICS=y
CONFIG_NVME_FC=y
CONFIG_NVME_TARGET=y
CONFIG_NVME_TARGET_LOOP=y
# CONFIG_NVME_TARGET_FC is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
CONFIG_DUMMY_IRQ=y
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
# CONFIG_ISL29003 is not set
CONFIG_ISL29020=y
# CONFIG_SENSORS_TSL2550 is not set
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_LATTICE_ECP3_CONFIG=y
CONFIG_SRAM=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_AT25=y
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_MAX6875=y
# CONFIG_EEPROM_93CX6 is not set
CONFIG_EEPROM_93XX46=y
CONFIG_EEPROM_IDT_89HPESX=y
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
CONFIG_INTEL_MEI_TXE=y
CONFIG_VMWARE_VMCI=y

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

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
CONFIG_GENWQE=y
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=0
# CONFIG_ECHO is not set
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_AFU_DRIVER_OPS is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
# CONFIG_IDE_GD is not set
# CONFIG_BLK_DEV_DELKIN is not set
CONFIG_BLK_DEV_IDECD=y
# CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS is not set
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y
# CONFIG_IDE_PROC_FS is not set

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_PLATFORM=y
CONFIG_BLK_DEV_CMD640=y
# CONFIG_BLK_DEV_CMD640_ENHANCED is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
CONFIG_BLK_DEV_OFFBOARD=y
CONFIG_BLK_DEV_GENERIC=y
CONFIG_BLK_DEV_OPTI621=y
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
CONFIG_BLK_DEV_ALI15X3=y
CONFIG_BLK_DEV_AMD74XX=y
CONFIG_BLK_DEV_ATIIXP=y
CONFIG_BLK_DEV_CMD64X=y
CONFIG_BLK_DEV_TRIFLEX=y
CONFIG_BLK_DEV_HPT366=y
CONFIG_BLK_DEV_JMICRON=y
# CONFIG_BLK_DEV_PIIX is not set
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
CONFIG_BLK_DEV_NS87415=y
CONFIG_BLK_DEV_PDC202XX_OLD=y
CONFIG_BLK_DEV_PDC202XX_NEW=y
# CONFIG_BLK_DEV_SVWKS is not set
CONFIG_BLK_DEV_SIIMAGE=y
CONFIG_BLK_DEV_SIS5513=y
CONFIG_BLK_DEV_SLC90E66=y
# CONFIG_BLK_DEV_TRM290 is not set
CONFIG_BLK_DEV_VIA82CXXX=y
CONFIG_BLK_DEV_TC86C001=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_NETLINK is not set
# CONFIG_SCSI_MQ_DEFAULT is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set
CONFIG_SCSI_SRP_ATTRS=y
# CONFIG_SCSI_LOWLEVEL is not set
CONFIG_SCSI_DH=y
# CONFIG_SCSI_DH_RDAC is not set
# CONFIG_SCSI_DH_HP_SW is not set
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
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
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_AHCI_CEVA is not set
# CONFIG_AHCI_QORIQ is not set
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
CONFIG_ATA_PIIX=y
CONFIG_SATA_DWC=y
# CONFIG_SATA_DWC_OLD_DMA is not set
# CONFIG_SATA_DWC_DEBUG is not set
CONFIG_SATA_MV=y
CONFIG_SATA_NV=y
CONFIG_SATA_PROMISE=y
CONFIG_SATA_SIL=y
CONFIG_SATA_SIS=y
CONFIG_SATA_SVW=y
CONFIG_SATA_ULI=y
CONFIG_SATA_VIA=y
CONFIG_SATA_VITESSE=y

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
CONFIG_PATA_AMD=y
CONFIG_PATA_ARTOP=y
CONFIG_PATA_ATIIXP=y
CONFIG_PATA_ATP867X=y
CONFIG_PATA_CMD64X=y
CONFIG_PATA_CYPRESS=y
# CONFIG_PATA_EFAR is not set
CONFIG_PATA_HPT366=y
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
CONFIG_PATA_IT8213=y
CONFIG_PATA_IT821X=y
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
CONFIG_PATA_NETCELL=y
CONFIG_PATA_NINJA32=y
CONFIG_PATA_NS87415=y
CONFIG_PATA_OLDPIIX=y
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
CONFIG_PATA_PDC_OLD=y
CONFIG_PATA_RADISYS=y
# CONFIG_PATA_RDC is not set
CONFIG_PATA_SCH=y
CONFIG_PATA_SERVERWORKS=y
# CONFIG_PATA_SIL680 is not set
CONFIG_PATA_SIS=y
# CONFIG_PATA_TOSHIBA is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
CONFIG_PATA_NS87410=y
CONFIG_PATA_OPTI=y
CONFIG_PATA_PLATFORM=y
# CONFIG_PATA_OF_PLATFORM is not set
CONFIG_PATA_RZ1000=y

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
# CONFIG_ATA_GENERIC is not set
CONFIG_PATA_LEGACY=y
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
# CONFIG_MD_LINEAR is not set
# CONFIG_MD_RAID0 is not set
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
# CONFIG_MD_RAID456 is not set
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BCACHE=y
CONFIG_BCACHE_DEBUG=y
CONFIG_BCACHE_CLOSURES_DEBUG=y
# CONFIG_BLK_DEV_DM is not set
CONFIG_TARGET_CORE=y
CONFIG_TCM_IBLOCK=y
# CONFIG_TCM_FILEIO is not set
CONFIG_TCM_PSCSI=y
# CONFIG_TCM_USER2 is not set
CONFIG_LOOPBACK_TARGET=y
# CONFIG_ISCSI_TARGET is not set
CONFIG_SBP_TARGET=y
CONFIG_FUSION=y
# CONFIG_FUSION_SPI is not set
# CONFIG_FUSION_SAS is not set
CONFIG_FUSION_MAX_SGE=128
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
# CONFIG_FIREWIRE_OHCI is not set
CONFIG_FIREWIRE_SBP2=y
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set
CONFIG_NVM=y
CONFIG_NVM_DEBUG=y
# CONFIG_NVM_RRPC is not set

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
# CONFIG_INPUT_MOUSEDEV is not set
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

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
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_GOLDFISH_EVENTS is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_KEYBOARD_CAP11XX is not set
# CONFIG_KEYBOARD_BCM is not set
# CONFIG_INPUT_MOUSE is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
# CONFIG_JOYSTICK_A3D is not set
# CONFIG_JOYSTICK_ADI is not set
CONFIG_JOYSTICK_COBRA=y
CONFIG_JOYSTICK_GF2K=y
CONFIG_JOYSTICK_GRIP=y
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=y
CONFIG_JOYSTICK_SIDEWINDER=y
# CONFIG_JOYSTICK_TMDC is not set
CONFIG_JOYSTICK_IFORCE=y
# CONFIG_JOYSTICK_IFORCE_USB is not set
CONFIG_JOYSTICK_IFORCE_232=y
CONFIG_JOYSTICK_WARRIOR=y
# CONFIG_JOYSTICK_MAGELLAN is not set
# CONFIG_JOYSTICK_SPACEORB is not set
CONFIG_JOYSTICK_SPACEBALL=y
CONFIG_JOYSTICK_STINGER=y
CONFIG_JOYSTICK_TWIDJOY=y
# CONFIG_JOYSTICK_ZHENHUA is not set
CONFIG_JOYSTICK_AS5011=y
CONFIG_JOYSTICK_JOYDUMP=y
CONFIG_JOYSTICK_XPAD=y
# CONFIG_JOYSTICK_XPAD_FF is not set
CONFIG_JOYSTICK_XPAD_LEDS=y
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
# CONFIG_TABLET_USB_AIPTEK is not set
# CONFIG_TABLET_USB_GTCO is not set
# CONFIG_TABLET_USB_HANWANG is not set
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_PEGASUS is not set
# CONFIG_TABLET_SERIAL_WACOM4 is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
CONFIG_TOUCHSCREEN_88PM860X=y
CONFIG_TOUCHSCREEN_ADS7846=y
CONFIG_TOUCHSCREEN_AD7877=y
# CONFIG_TOUCHSCREEN_AD7879 is not set
CONFIG_TOUCHSCREEN_AR1021_I2C=y
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_TOUCHSCREEN_BU21013=y
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP_I2C=y
# CONFIG_TOUCHSCREEN_CYTTSP_SPI is not set
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP4_I2C=y
CONFIG_TOUCHSCREEN_CYTTSP4_SPI=y
CONFIG_TOUCHSCREEN_DA9034=y
CONFIG_TOUCHSCREEN_DYNAPRO=y
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=y
CONFIG_TOUCHSCREEN_EGALAX=y
# CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
# CONFIG_TOUCHSCREEN_FUJITSU is not set
CONFIG_TOUCHSCREEN_ILI210X=y
CONFIG_TOUCHSCREEN_GUNZE=y
CONFIG_TOUCHSCREEN_EKTF2127=y
CONFIG_TOUCHSCREEN_ELAN=y
CONFIG_TOUCHSCREEN_ELO=y
CONFIG_TOUCHSCREEN_WACOM_W8001=y
CONFIG_TOUCHSCREEN_WACOM_I2C=y
CONFIG_TOUCHSCREEN_MAX11801=y
# CONFIG_TOUCHSCREEN_MCS5000 is not set
CONFIG_TOUCHSCREEN_MMS114=y
CONFIG_TOUCHSCREEN_MELFAS_MIP4=y
# CONFIG_TOUCHSCREEN_MTOUCH is not set
CONFIG_TOUCHSCREEN_INEXIO=y
CONFIG_TOUCHSCREEN_MK712=y
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
CONFIG_TOUCHSCREEN_EDT_FT5X06=y
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
# CONFIG_TOUCHSCREEN_PIXCIR is not set
# CONFIG_TOUCHSCREEN_WDT87XX_I2C is not set
CONFIG_TOUCHSCREEN_WM97XX=y
CONFIG_TOUCHSCREEN_WM9705=y
CONFIG_TOUCHSCREEN_WM9712=y
CONFIG_TOUCHSCREEN_WM9713=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_TOUCHIT213=y
CONFIG_TOUCHSCREEN_TSC_SERIO=y
CONFIG_TOUCHSCREEN_TSC200X_CORE=y
CONFIG_TOUCHSCREEN_TSC2004=y
# CONFIG_TOUCHSCREEN_TSC2005 is not set
CONFIG_TOUCHSCREEN_TSC2007=y
# CONFIG_TOUCHSCREEN_SILEAD is not set
CONFIG_TOUCHSCREEN_ST1232=y
# CONFIG_TOUCHSCREEN_SX8654 is not set
CONFIG_TOUCHSCREEN_TPS6507X=y
CONFIG_TOUCHSCREEN_ZET6223=y
# CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_88PM860X_ONKEY is not set
# CONFIG_INPUT_88PM80X_ONKEY is not set
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_ARIZONA_HAPTICS is not set
# CONFIG_INPUT_ATMEL_CAPTOUCH is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_E3X0_BUTTON is not set
CONFIG_INPUT_MAX77693_HAPTIC=y
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_APANEL=y
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
CONFIG_INPUT_KEYSPAN_REMOTE=y
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=y
CONFIG_INPUT_YEALINK=y
CONFIG_INPUT_CM109=y
# CONFIG_INPUT_REGULATOR_HAPTIC is not set
# CONFIG_INPUT_RETU_PWRBUTTON is not set
CONFIG_INPUT_TPS65218_PWRBUTTON=y
CONFIG_INPUT_TWL4030_PWRBUTTON=y
CONFIG_INPUT_TWL4030_VIBRA=y
CONFIG_INPUT_TWL6040_VIBRA=y
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PALMAS_PWRBUTTON=y
CONFIG_INPUT_PCF50633_PMU=y
# CONFIG_INPUT_PCF8574 is not set
CONFIG_INPUT_PWM_BEEPER=y
# CONFIG_INPUT_DA9055_ONKEY is not set
# CONFIG_INPUT_DA9063_ONKEY is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_IMS_PCU is not set
CONFIG_INPUT_CMA3000=y
# CONFIG_INPUT_CMA3000_I2C is not set
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
# CONFIG_INPUT_DRV2665_HAPTICS is not set
# CONFIG_INPUT_DRV2667_HAPTICS is not set
CONFIG_RMI4_CORE=y
CONFIG_RMI4_I2C=y
CONFIG_RMI4_SPI=y
CONFIG_RMI4_SMB=y
# CONFIG_RMI4_F03 is not set
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
# CONFIG_RMI4_F12 is not set
CONFIG_RMI4_F30=y
CONFIG_RMI4_F34=y
CONFIG_RMI4_F55=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_SERIO_APBPS2=y
CONFIG_USERIO=y
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
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
CONFIG_CYCLADES=y
# CONFIG_CYZ_INTR is not set
CONFIG_MOXA_INTELLIO=y
CONFIG_MOXA_SMARTIO=y
CONFIG_SYNCLINKMP=y
CONFIG_SYNCLINK_GT=y
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
# CONFIG_N_GSM is not set
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
CONFIG_GOLDFISH_TTY=y
CONFIG_DEVMEM=y
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_FSL is not set
# CONFIG_SERIAL_8250_DW is not set
CONFIG_SERIAL_8250_RT288X=y
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
CONFIG_SERIAL_8250_MOXA=y
# CONFIG_SERIAL_OF_PLATFORM is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
CONFIG_SERIAL_MAX310X=y
CONFIG_SERIAL_UARTLITE=y
CONFIG_SERIAL_UARTLITE_CONSOLE=y
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_SC16IS7XX_CORE=y
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_SC16IS7XX_I2C=y
# CONFIG_SERIAL_SC16IS7XX_SPI is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_ALTERA_UART_CONSOLE=y
# CONFIG_SERIAL_XILINX_PS_UART is not set
CONFIG_SERIAL_ARC=y
# CONFIG_SERIAL_ARC_CONSOLE is not set
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
CONFIG_SERIAL_FSL_LPUART=y
# CONFIG_SERIAL_FSL_LPUART_CONSOLE is not set
CONFIG_SERIAL_CONEXANT_DIGICOLOR=y
# CONFIG_SERIAL_CONEXANT_DIGICOLOR_CONSOLE is not set
# CONFIG_SERIAL_DEV_BUS is not set
CONFIG_TTY_PRINTK=y
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
# CONFIG_HW_RANDOM_VIA is not set
CONFIG_HW_RANDOM_VIRTIO=y
# CONFIG_HW_RANDOM_TPM is not set
CONFIG_NVRAM=y
CONFIG_R3964=y
# CONFIG_APPLICOM is not set
CONFIG_MWAVE=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_SPI=y
CONFIG_TCG_TIS_I2C_ATMEL=y
CONFIG_TCG_TIS_I2C_INFINEON=y
CONFIG_TCG_TIS_I2C_NUVOTON=y
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
# CONFIG_TCG_VTPM_PROXY is not set
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
# CONFIG_TCG_TIS_ST33ZP24_SPI is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
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
CONFIG_I2C_AMD756_S4882=y
CONFIG_I2C_AMD8111=y
# CONFIG_I2C_I801 is not set
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_DESIGNWARE_CORE=y
# CONFIG_I2C_DESIGNWARE_PLATFORM is not set
CONFIG_I2C_DESIGNWARE_PCI=y
CONFIG_I2C_EMEV2=y
CONFIG_I2C_KEMPLD=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_RK3X is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_ROBOTFUZZ_OSIF=y
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set
# CONFIG_I2C_VIPERBOARD is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_MLXCPLD is not set
# CONFIG_I2C_CROS_EC_TUNNEL is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
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
CONFIG_SPI_AXI_SPI_ENGINE=y
CONFIG_SPI_BITBANG=y
CONFIG_SPI_CADENCE=y
# CONFIG_SPI_DESIGNWARE is not set
CONFIG_SPI_FSL_LIB=y
CONFIG_SPI_FSL_SPI=y
CONFIG_SPI_PXA2XX=y
CONFIG_SPI_PXA2XX_PCI=y
CONFIG_SPI_ROCKCHIP=y
CONFIG_SPI_SC18IS602=y
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
CONFIG_NTP_PPS=y

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=y
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_GPIOLIB is not set
CONFIG_W1=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
# CONFIG_W1_MASTER_DS2490 is not set
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
# CONFIG_W1_SLAVE_SMEM is not set
# CONFIG_W1_SLAVE_DS2405 is not set
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2413 is not set
# CONFIG_W1_SLAVE_DS2406 is not set
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
# CONFIG_W1_SLAVE_DS2781 is not set
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_AVS=y
CONFIG_POWER_RESET=y
CONFIG_POWER_RESET_RESTART=y
# CONFIG_POWER_RESET_SYSCON is not set
CONFIG_POWER_RESET_SYSCON_POWEROFF=y
CONFIG_REBOOT_MODE=y
CONFIG_SYSCON_REBOOT_MODE=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
# CONFIG_PDA_POWER is not set
CONFIG_WM8350_POWER=y
CONFIG_TEST_POWER=y
# CONFIG_BATTERY_88PM860X is not set
CONFIG_BATTERY_ACT8945A=y
CONFIG_BATTERY_DS2760=y
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_WM97XX=y
CONFIG_BATTERY_SBS=y
CONFIG_CHARGER_SBS=y
CONFIG_BATTERY_BQ27XXX=y
# CONFIG_BATTERY_BQ27XXX_I2C is not set
CONFIG_BATTERY_DA9030=y
CONFIG_BATTERY_DA9150=y
CONFIG_BATTERY_MAX17040=y
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_PCF50633 is not set
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_LP8727=y
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_MAX14577 is not set
CONFIG_CHARGER_DETECTOR_MAX14656=y
# CONFIG_CHARGER_MAX77693 is not set
# CONFIG_CHARGER_MAX8998 is not set
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_SMB347=y
# CONFIG_CHARGER_TPS65217 is not set
CONFIG_BATTERY_GAUGE_LTC2941=y
CONFIG_BATTERY_GOLDFISH=y
CONFIG_BATTERY_RT5033=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_AD7314=y
CONFIG_SENSORS_AD7414=y
# CONFIG_SENSORS_AD7418 is not set
CONFIG_SENSORS_ADM1021=y
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
# CONFIG_SENSORS_ASC7621 is not set
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=y
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_GL518SM is not set
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_I5500=y
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC2990=y
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
# CONFIG_SENSORS_LTC4222 is not set
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX1111=y
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX31722=y
CONFIG_SENSORS_MAX6639=y
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
# CONFIG_SENSORS_TC654 is not set
# CONFIG_SENSORS_ADCXX is not set
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM70=y
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_NCT7802=y
# CONFIG_SENSORS_NCT7904 is not set
# CONFIG_SENSORS_PCF8591 is not set
CONFIG_PMBUS=y
# CONFIG_SENSORS_PMBUS is not set
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_LM25066=y
# CONFIG_SENSORS_LTC2978 is not set
CONFIG_SENSORS_LTC3815=y
CONFIG_SENSORS_MAX16064=y
CONFIG_SENSORS_MAX20751=y
# CONFIG_SENSORS_MAX34440 is not set
# CONFIG_SENSORS_MAX8688 is not set
CONFIG_SENSORS_TPS40422=y
CONFIG_SENSORS_UCD9000=y
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
CONFIG_SENSORS_PWM_FAN=y
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SHT3x is not set
CONFIG_SENSORS_SHTC1=y
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=y
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_STTS751=y
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_ADC128D818 is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_INA3221=y
# CONFIG_SENSORS_TC74 is not set
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP103=y
CONFIG_SENSORS_TMP108=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
# CONFIG_SENSORS_W83627EHF is not set
CONFIG_SENSORS_WM8350=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_OF=y
# CONFIG_THERMAL_WRITABLE_TRIPS is not set
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_QORIQ_THERMAL is not set
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
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
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
CONFIG_SSB_SILENT=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
# CONFIG_BCMA_SFLASH is not set
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_ACT8945A=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_MFD_AS3722 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_ATMEL_FLEXCOM is not set
CONFIG_MFD_ATMEL_HLCDC=y
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_AXP20X_I2C is not set
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
CONFIG_MFD_CROS_EC_SPI=y
CONFIG_PMIC_DA903X=y
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
# CONFIG_MFD_DLN2 is not set
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_MFD_HI6421_PMIC is not set
CONFIG_HTC_PASIC3=y
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=y
# CONFIG_LPC_ICH is not set
CONFIG_LPC_SCH=y
CONFIG_MFD_INTEL_LPSS=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
CONFIG_MFD_INTEL_LPSS_PCI=y
CONFIG_MFD_JANZ_CMODIO=y
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77620 is not set
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
# CONFIG_MFD_MT6397 is not set
# CONFIG_MFD_MENF21BMC is not set
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_CPCAP=y
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
# CONFIG_PCF50633_ADC is not set
# CONFIG_PCF50633_GPIO is not set
CONFIG_MFD_RDC321X=y
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RT5033=y
CONFIG_MFD_RTSX_USB=y
CONFIG_MFD_RC5T583=y
CONFIG_MFD_RK808=y
CONFIG_MFD_RN5T618=y
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_PALMAS=y
# CONFIG_TPS6105X is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TI_LP873X=y
CONFIG_MFD_TPS65218=y
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
CONFIG_MFD_CS47L24=y
CONFIG_MFD_WM5102=y
# CONFIG_MFD_WM5110 is not set
CONFIG_MFD_WM8997=y
CONFIG_MFD_WM8998=y
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PM800=y
# CONFIG_REGULATOR_88PM8607 is not set
# CONFIG_REGULATOR_ACT8865 is not set
# CONFIG_REGULATOR_ACT8945A is not set
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_ANATOP is not set
# CONFIG_REGULATOR_ARIZONA is not set
# CONFIG_REGULATOR_CPCAP is not set
CONFIG_REGULATOR_DA903X=y
# CONFIG_REGULATOR_DA9055 is not set
# CONFIG_REGULATOR_DA9062 is not set
# CONFIG_REGULATOR_DA9063 is not set
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_ISL9305=y
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP873X=y
CONFIG_REGULATOR_LP8755=y
# CONFIG_REGULATOR_LTC3589 is not set
# CONFIG_REGULATOR_LTC3676 is not set
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
# CONFIG_REGULATOR_MAX8907 is not set
# CONFIG_REGULATOR_MAX8952 is not set
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX8998=y
# CONFIG_REGULATOR_MAX77693 is not set
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=y
CONFIG_REGULATOR_PWM=y
# CONFIG_REGULATOR_QCOM_SPMI is not set
CONFIG_REGULATOR_RC5T583=y
CONFIG_REGULATOR_RK808=y
CONFIG_REGULATOR_RN5T618=y
CONFIG_REGULATOR_RT5033=y
# CONFIG_REGULATOR_S2MPA01 is not set
CONFIG_REGULATOR_S2MPS11=y
CONFIG_REGULATOR_S5M8767=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65217=y
CONFIG_REGULATOR_TPS65218=y
# CONFIG_REGULATOR_TPS6524X is not set
CONFIG_REGULATOR_TPS6586X=y
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_WM8350=y
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
# CONFIG_VGA_ARB is not set
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_MIPI_DSI=y
CONFIG_DRM_DP_AUX_CHARDEV=y
# CONFIG_DRM_DEBUG_MM is not set
CONFIG_DRM_DEBUG_MM_SELFTEST=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
CONFIG_DRM_I2C_SIL164=y
# CONFIG_DRM_I2C_NXP_TDA998X is not set
# CONFIG_DRM_RADEON is not set
CONFIG_DRM_AMDGPU=y
# CONFIG_DRM_AMDGPU_SI is not set
# CONFIG_DRM_AMDGPU_CIK is not set
# CONFIG_DRM_AMDGPU_USERPTR is not set
CONFIG_DRM_AMDGPU_GART_DEBUGFS=y

#
# ACP (Audio CoProcessor) Configuration
#
CONFIG_DRM_AMD_ACP=y
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_VGEM is not set
CONFIG_DRM_VMWGFX=y
CONFIG_DRM_VMWGFX_FBCON=y
# CONFIG_DRM_GMA500 is not set
CONFIG_DRM_UDL=y
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
CONFIG_DRM_CIRRUS_QEMU=y
# CONFIG_DRM_QXL is not set
CONFIG_DRM_BOCHS=y
# CONFIG_DRM_VIRTIO_GPU is not set
CONFIG_DRM_PANEL=y

#
# Display Panels
#
CONFIG_DRM_PANEL_SIMPLE=y
CONFIG_DRM_PANEL_JDI_LT070ME05000=y
CONFIG_DRM_PANEL_SAMSUNG_LD9040=y
CONFIG_DRM_PANEL_LG_LG4573=y
CONFIG_DRM_PANEL_PANASONIC_VVX10F034N00=y
CONFIG_DRM_PANEL_SAMSUNG_S6E8AA0=y
# CONFIG_DRM_PANEL_SHARP_LQ101R1SX01 is not set
# CONFIG_DRM_PANEL_SHARP_LS043T1LE01 is not set
CONFIG_DRM_BRIDGE=y

#
# Display Interface Bridges
#
CONFIG_DRM_ANALOGIX_ANX78XX=y
CONFIG_DRM_DUMB_VGA_DAC=y
CONFIG_DRM_NXP_PTN3460=y
# CONFIG_DRM_PARADE_PS8622 is not set
CONFIG_DRM_SIL_SII8620=y
CONFIG_DRM_SII902X=y
# CONFIG_DRM_TOSHIBA_TC358767 is not set
CONFIG_DRM_TI_TFP410=y
CONFIG_DRM_I2C_ADV7511=y
CONFIG_DRM_I2C_ADV7511_AUDIO=y
CONFIG_DRM_I2C_ADV7533=y
CONFIG_DRM_ARCPGU=y
CONFIG_DRM_HISI_HIBMC=y
CONFIG_DRM_MXS=y
CONFIG_DRM_MXSFB=y
CONFIG_DRM_TINYDRM=y
CONFIG_TINYDRM_MIPI_DBI=y
CONFIG_TINYDRM_MI0283QT=y
# CONFIG_DRM_LEGACY is not set
CONFIG_DRM_LIB_RANDOM=y

#
# Frame buffer Devices
#
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
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
# CONFIG_FB_PROVIDE_GET_FB_UNMAPPED_AREA is not set
CONFIG_FB_FOREIGN_ENDIAN=y
# CONFIG_FB_BOTH_ENDIAN is not set
CONFIG_FB_BIG_ENDIAN=y
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=y
CONFIG_FB_PM2=y
CONFIG_FB_PM2_FIFO_DISCONNECT=y
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_OPENCORES=y
# CONFIG_FB_S1D13XXX is not set
CONFIG_FB_NVIDIA=y
CONFIG_FB_NVIDIA_I2C=y
# CONFIG_FB_NVIDIA_DEBUG is not set
# CONFIG_FB_NVIDIA_BACKLIGHT is not set
CONFIG_FB_RIVA=y
CONFIG_FB_RIVA_I2C=y
# CONFIG_FB_RIVA_DEBUG is not set
# CONFIG_FB_RIVA_BACKLIGHT is not set
# CONFIG_FB_I740 is not set
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
CONFIG_FB_MATROX=y
# CONFIG_FB_MATROX_MILLENIUM is not set
CONFIG_FB_MATROX_MYSTIQUE=y
# CONFIG_FB_MATROX_G is not set
# CONFIG_FB_MATROX_I2C is not set
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
# CONFIG_FB_ATY128 is not set
CONFIG_FB_ATY=y
# CONFIG_FB_ATY_CT is not set
# CONFIG_FB_ATY_GX is not set
CONFIG_FB_ATY_BACKLIGHT=y
CONFIG_FB_S3=y
# CONFIG_FB_S3_DDC is not set
CONFIG_FB_SAVAGE=y
# CONFIG_FB_SAVAGE_I2C is not set
CONFIG_FB_SAVAGE_ACCEL=y
CONFIG_FB_SIS=y
CONFIG_FB_SIS_300=y
# CONFIG_FB_SIS_315 is not set
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
CONFIG_FB_VT8623=y
CONFIG_FB_TRIDENT=y
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_SM501 is not set
CONFIG_FB_SMSCUFX=y
# CONFIG_FB_UDL is not set
# CONFIG_FB_IBM_GXT4500 is not set
# CONFIG_FB_GOLDFISH is not set
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
# CONFIG_FB_SIMPLE is not set
CONFIG_FB_SM712=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_LTV350QV is not set
CONFIG_LCD_ILI922X=y
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
CONFIG_LCD_S6E63M0=y
# CONFIG_LCD_LD9040 is not set
# CONFIG_LCD_AMS369FG06 is not set
# CONFIG_LCD_LMS501KF03 is not set
CONFIG_LCD_HX8357=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_CARILLO_RANCH=y
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_DA903X=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_LM3630A=y
CONFIG_BACKLIGHT_LM3639=y
# CONFIG_BACKLIGHT_LP855X is not set
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_TPS65217=y
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
CONFIG_VGASTATE=y
CONFIG_VIDEOMODE_HELPERS=y
CONFIG_HDMI=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_PCM_ELD=y
CONFIG_SND_PCM_IEC958=y
CONFIG_SND_DMAENGINE_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
# CONFIG_SND_PCM_OSS is not set
# CONFIG_SND_PCM_TIMER is not set
# CONFIG_SND_SEQUENCER_OSS is not set
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=y
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
CONFIG_SND_MPU401_UART=y
CONFIG_SND_AC97_CODEC=y
CONFIG_SND_DRIVERS=y
CONFIG_SND_DUMMY=y
CONFIG_SND_ALOOP=y
CONFIG_SND_VIRMIDI=y
# CONFIG_SND_MTPAV is not set
CONFIG_SND_SERIAL_U16550=y
CONFIG_SND_MPU401=y
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=0
# CONFIG_SND_PCI is not set

#
# HD-Audio
#
CONFIG_SND_HDA_PREALLOC_SIZE=64
# CONFIG_SND_SPI is not set
# CONFIG_SND_USB is not set
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=y
# CONFIG_SND_DICE is not set
CONFIG_SND_OXFW=y
CONFIG_SND_ISIGHT=y
# CONFIG_SND_FIREWORKS is not set
CONFIG_SND_BEBOB=y
CONFIG_SND_FIREWIRE_DIGI00X=y
CONFIG_SND_FIREWIRE_TASCAM=y
CONFIG_SND_SOC=y
CONFIG_SND_SOC_AC97_BUS=y
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
CONFIG_SND_SOC_AMD_ACP=y
CONFIG_SND_ATMEL_SOC=y
CONFIG_SND_DESIGNWARE_I2S=y
CONFIG_SND_DESIGNWARE_PCM=y

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
# CONFIG_SND_SOC_FSL_ASRC is not set
# CONFIG_SND_SOC_FSL_SAI is not set
CONFIG_SND_SOC_FSL_SSI=y
CONFIG_SND_SOC_FSL_SPDIF=y
CONFIG_SND_SOC_FSL_ESAI=y
# CONFIG_SND_SOC_IMX_AUDMUX is not set
# CONFIG_SND_SOC_IMG is not set
# CONFIG_SND_SOC_INTEL_BXT_DA7219_MAX98357A_MACH is not set
# CONFIG_SND_SOC_INTEL_BXT_RT298_MACH is not set
# CONFIG_SND_SOC_INTEL_BYTCR_RT5640_MACH is not set
# CONFIG_SND_SOC_INTEL_BYTCR_RT5651_MACH is not set
# CONFIG_SND_SOC_INTEL_SKL_RT286_MACH is not set
CONFIG_SND_SOC_XTFPGA_I2S=y
CONFIG_SND_SOC_I2C_AND_SPI=y

#
# CODEC drivers
#
CONFIG_SND_SOC_AC97_CODEC=y
CONFIG_SND_SOC_ADAU1701=y
# CONFIG_SND_SOC_ADAU7002 is not set
CONFIG_SND_SOC_AK4104=y
CONFIG_SND_SOC_AK4554=y
CONFIG_SND_SOC_AK4613=y
CONFIG_SND_SOC_AK4642=y
# CONFIG_SND_SOC_AK5386 is not set
CONFIG_SND_SOC_ALC5623=y
CONFIG_SND_SOC_BT_SCO=y
CONFIG_SND_SOC_CS35L32=y
# CONFIG_SND_SOC_CS35L33 is not set
# CONFIG_SND_SOC_CS35L34 is not set
# CONFIG_SND_SOC_CS42L42 is not set
CONFIG_SND_SOC_CS42L51=y
CONFIG_SND_SOC_CS42L51_I2C=y
CONFIG_SND_SOC_CS42L52=y
CONFIG_SND_SOC_CS42L56=y
CONFIG_SND_SOC_CS42L73=y
# CONFIG_SND_SOC_CS4265 is not set
# CONFIG_SND_SOC_CS4270 is not set
CONFIG_SND_SOC_CS4271=y
CONFIG_SND_SOC_CS4271_I2C=y
# CONFIG_SND_SOC_CS4271_SPI is not set
CONFIG_SND_SOC_CS42XX8=y
CONFIG_SND_SOC_CS42XX8_I2C=y
# CONFIG_SND_SOC_CS4349 is not set
CONFIG_SND_SOC_CS53L30=y
CONFIG_SND_SOC_HDMI_CODEC=y
# CONFIG_SND_SOC_ES8328_I2C is not set
# CONFIG_SND_SOC_ES8328_SPI is not set
# CONFIG_SND_SOC_GTM601 is not set
CONFIG_SND_SOC_INNO_RK3036=y
CONFIG_SND_SOC_MAX98504=y
# CONFIG_SND_SOC_MAX9860 is not set
# CONFIG_SND_SOC_MSM8916_WCD_ANALOG is not set
# CONFIG_SND_SOC_MSM8916_WCD_DIGITAL is not set
# CONFIG_SND_SOC_PCM1681 is not set
CONFIG_SND_SOC_PCM179X=y
CONFIG_SND_SOC_PCM179X_I2C=y
CONFIG_SND_SOC_PCM179X_SPI=y
CONFIG_SND_SOC_PCM3168A=y
# CONFIG_SND_SOC_PCM3168A_I2C is not set
CONFIG_SND_SOC_PCM3168A_SPI=y
CONFIG_SND_SOC_PCM512x=y
CONFIG_SND_SOC_PCM512x_I2C=y
CONFIG_SND_SOC_PCM512x_SPI=y
CONFIG_SND_SOC_RL6231=y
CONFIG_SND_SOC_RT5616=y
CONFIG_SND_SOC_RT5631=y
# CONFIG_SND_SOC_RT5677_SPI is not set
CONFIG_SND_SOC_SGTL5000=y
CONFIG_SND_SOC_SIGMADSP=y
CONFIG_SND_SOC_SIGMADSP_I2C=y
CONFIG_SND_SOC_SIRF_AUDIO_CODEC=y
CONFIG_SND_SOC_SPDIF=y
CONFIG_SND_SOC_SSM2602=y
CONFIG_SND_SOC_SSM2602_SPI=y
CONFIG_SND_SOC_SSM2602_I2C=y
# CONFIG_SND_SOC_SSM4567 is not set
CONFIG_SND_SOC_STA32X=y
CONFIG_SND_SOC_STA350=y
# CONFIG_SND_SOC_STI_SAS is not set
CONFIG_SND_SOC_TAS2552=y
# CONFIG_SND_SOC_TAS5086 is not set
CONFIG_SND_SOC_TAS571X=y
CONFIG_SND_SOC_TAS5720=y
CONFIG_SND_SOC_TFA9879=y
CONFIG_SND_SOC_TLV320AIC23=y
# CONFIG_SND_SOC_TLV320AIC23_I2C is not set
CONFIG_SND_SOC_TLV320AIC23_SPI=y
# CONFIG_SND_SOC_TLV320AIC31XX is not set
CONFIG_SND_SOC_TLV320AIC3X=y
# CONFIG_SND_SOC_TS3A227E is not set
# CONFIG_SND_SOC_WM8510 is not set
# CONFIG_SND_SOC_WM8523 is not set
CONFIG_SND_SOC_WM8580=y
# CONFIG_SND_SOC_WM8711 is not set
CONFIG_SND_SOC_WM8728=y
CONFIG_SND_SOC_WM8731=y
CONFIG_SND_SOC_WM8737=y
CONFIG_SND_SOC_WM8741=y
# CONFIG_SND_SOC_WM8750 is not set
CONFIG_SND_SOC_WM8753=y
CONFIG_SND_SOC_WM8770=y
CONFIG_SND_SOC_WM8776=y
CONFIG_SND_SOC_WM8804=y
CONFIG_SND_SOC_WM8804_I2C=y
CONFIG_SND_SOC_WM8804_SPI=y
CONFIG_SND_SOC_WM8903=y
# CONFIG_SND_SOC_WM8960 is not set
# CONFIG_SND_SOC_WM8962 is not set
CONFIG_SND_SOC_WM8974=y
# CONFIG_SND_SOC_WM8978 is not set
CONFIG_SND_SOC_WM8985=y
CONFIG_SND_SOC_NAU8540=y
CONFIG_SND_SOC_NAU8810=y
CONFIG_SND_SOC_TPA6130A2=y
CONFIG_SND_SIMPLE_CARD_UTILS=y
CONFIG_SND_SIMPLE_CARD=y
CONFIG_SND_SIMPLE_SCU_CARD=y
CONFIG_SND_X86=y
CONFIG_SOUND_PRIME=y
CONFIG_AC97_BUS=y

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CORSAIR=y
CONFIG_HID_PRODIKEYS=y
CONFIG_HID_CMEDIA=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_ELECOM=y
# CONFIG_HID_EZKEY is not set
CONFIG_HID_GEMBIRD=y
CONFIG_HID_GFRM=y
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LED=y
CONFIG_HID_LENOVO=y
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_HIDPP=y
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWHEELS_FF is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MAYFLASH is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PLANTRONICS=y
# CONFIG_HID_PRIMAX is not set
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_RMI is not set
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THINGM=y
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
CONFIG_HID_UDRAW_PS3=y
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=y
CONFIG_HID_SENSOR_HUB=y
CONFIG_HID_SENSOR_CUSTOM_SENSOR=y
# CONFIG_HID_ALPS is not set

#
# USB HID support
#
# CONFIG_USB_HID is not set
# CONFIG_HID_PID is not set

#
# USB HID Boot Protocol drivers
#
CONFIG_USB_KBD=y
CONFIG_USB_MOUSE=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set

#
# Intel ISH HID support
#
CONFIG_INTEL_ISH_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG=y
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_OTG_FSM is not set
# CONFIG_USB_LEDS_TRIGGER_USBPORT is not set
CONFIG_USB_MON=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_MAX3421_HCD=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_SSB is not set
CONFIG_USB_OHCI_HCD_PLATFORM=y
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_U132_HCD is not set
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_HCD_BCMA is not set
# CONFIG_USB_HCD_SSB is not set
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
# CONFIG_USB_WDM is not set
CONFIG_USB_TMC=y

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
CONFIG_USB_MICROTEK=y
# CONFIG_USBIP_CORE is not set
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_HOST=y

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
# CONFIG_MUSB_PIO_ONLY is not set
# CONFIG_USB_DWC3 is not set
# CONFIG_USB_DWC2 is not set
CONFIG_USB_CHIPIDEA=y
CONFIG_USB_CHIPIDEA_OF=y
CONFIG_USB_CHIPIDEA_PCI=y
# CONFIG_USB_CHIPIDEA_HOST is not set
CONFIG_USB_CHIPIDEA_ULPI=y
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1760_HOST_ROLE=y

#
# USB port drivers
#
CONFIG_USB_SERIAL=y
# CONFIG_USB_SERIAL_CONSOLE is not set
# CONFIG_USB_SERIAL_GENERIC is not set
CONFIG_USB_SERIAL_SIMPLE=y
CONFIG_USB_SERIAL_AIRCABLE=y
# CONFIG_USB_SERIAL_ARK3116 is not set
CONFIG_USB_SERIAL_BELKIN=y
# CONFIG_USB_SERIAL_CH341 is not set
CONFIG_USB_SERIAL_WHITEHEAT=y
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
CONFIG_USB_SERIAL_CP210X=y
CONFIG_USB_SERIAL_CYPRESS_M8=y
CONFIG_USB_SERIAL_EMPEG=y
CONFIG_USB_SERIAL_FTDI_SIO=y
CONFIG_USB_SERIAL_VISOR=y
# CONFIG_USB_SERIAL_IPAQ is not set
CONFIG_USB_SERIAL_IR=y
CONFIG_USB_SERIAL_EDGEPORT=y
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
CONFIG_USB_SERIAL_F81232=y
# CONFIG_USB_SERIAL_F8153X is not set
# CONFIG_USB_SERIAL_GARMIN is not set
# CONFIG_USB_SERIAL_IPW is not set
CONFIG_USB_SERIAL_IUU=y
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
CONFIG_USB_SERIAL_KEYSPAN=y
# CONFIG_USB_SERIAL_KLSI is not set
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
CONFIG_USB_SERIAL_MCT_U232=y
CONFIG_USB_SERIAL_METRO=y
CONFIG_USB_SERIAL_MOS7720=y
CONFIG_USB_SERIAL_MOS7840=y
CONFIG_USB_SERIAL_MXUPORT=y
# CONFIG_USB_SERIAL_NAVMAN is not set
# CONFIG_USB_SERIAL_PL2303 is not set
CONFIG_USB_SERIAL_OTI6858=y
CONFIG_USB_SERIAL_QCAUX=y
CONFIG_USB_SERIAL_QUALCOMM=y
CONFIG_USB_SERIAL_SPCP8X5=y
CONFIG_USB_SERIAL_SAFE=y
# CONFIG_USB_SERIAL_SAFE_PADDED is not set
# CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
CONFIG_USB_SERIAL_SYMBOL=y
# CONFIG_USB_SERIAL_TI is not set
CONFIG_USB_SERIAL_CYBERJACK=y
CONFIG_USB_SERIAL_XIRCOM=y
CONFIG_USB_SERIAL_WWAN=y
CONFIG_USB_SERIAL_OPTION=y
CONFIG_USB_SERIAL_OMNINET=y
CONFIG_USB_SERIAL_OPTICON=y
CONFIG_USB_SERIAL_XSENS_MT=y
CONFIG_USB_SERIAL_WISHBONE=y
CONFIG_USB_SERIAL_SSU100=y
CONFIG_USB_SERIAL_QT2=y
CONFIG_USB_SERIAL_UPD78F0730=y
CONFIG_USB_SERIAL_DEBUG=y

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
# CONFIG_USB_ADUTUX is not set
CONFIG_USB_SEVSEG=y
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=y
# CONFIG_USB_APPLEDISPLAY is not set
CONFIG_USB_SISUSBVGA=y
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
# CONFIG_USB_TEST is not set
CONFIG_USB_EHSET_TEST_FIXTURE=y
# CONFIG_USB_ISIGHTFW is not set
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
CONFIG_USB_HUB_USB251XB=y
CONFIG_USB_HSIC_USB3503=y
CONFIG_USB_HSIC_USB4604=y
# CONFIG_USB_LINK_LAYER_TEST is not set
CONFIG_USB_CHAOSKEY=y
# CONFIG_UCSI is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_TAHVO_USB=y
CONFIG_TAHVO_USB_HOST_BY_DEFAULT=y
# CONFIG_USB_ISP1301 is not set
# CONFIG_USB_GADGET is not set
CONFIG_USB_LED_TRIG=y
CONFIG_USB_ULPI_BUS=y
# CONFIG_UWB is not set
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
CONFIG_PWRSEQ_EMMC=y
CONFIG_PWRSEQ_SIMPLE=y
# CONFIG_MMC_BLOCK is not set
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_PCI=y
CONFIG_MMC_RICOH_MMC=y
# CONFIG_MMC_SDHCI_ACPI is not set
# CONFIG_MMC_SDHCI_PLTFM is not set
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_GOLDFISH=y
CONFIG_MMC_SPI=y
CONFIG_MMC_CB710=y
CONFIG_MMC_VIA_SDMMC=y
CONFIG_MMC_VUB300=y
CONFIG_MMC_USHC=y
CONFIG_MMC_USDHI6ROL0=y
# CONFIG_MMC_REALTEK_USB is not set
# CONFIG_MMC_TOSHIBA_PCI is not set
# CONFIG_MMC_MTK is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y
CONFIG_LEDS_BRIGHTNESS_HW_CHANGED=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
CONFIG_LEDS_BCM6328=y
# CONFIG_LEDS_BCM6358 is not set
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_LP8860=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
# CONFIG_LEDS_WM8350 is not set
CONFIG_LEDS_DA903X=y
CONFIG_LEDS_DAC124S085=y
# CONFIG_LEDS_PWM is not set
# CONFIG_LEDS_REGULATOR is not set
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_TLC591XX is not set
# CONFIG_LEDS_MAX77693 is not set
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_IS31FL319X=y
CONFIG_LEDS_IS31FL32XX=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
CONFIG_LEDS_SYSCON=y
CONFIG_LEDS_USER=y
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
CONFIG_LEDS_TRIGGER_DISK=y
# CONFIG_LEDS_TRIGGER_MTD is not set
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
CONFIG_DMADEVICES_VDEBUG=y

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y
CONFIG_FSL_EDMA=y
# CONFIG_INTEL_IDMA64 is not set
# CONFIG_INTEL_IOATDMA is not set
CONFIG_QCOM_HIDMA_MGMT=y
CONFIG_QCOM_HIDMA=y
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
CONFIG_DW_DMAC_PCI=y
CONFIG_HSU_DMA=y

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
CONFIG_DMATEST=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
# CONFIG_SW_SYNC is not set
CONFIG_AUXDISPLAY=y
CONFIG_IMG_ASCII_LCD=y
CONFIG_HT16K33=y
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV_GENIRQ=y
# CONFIG_UIO_DMEM_GENIRQ is not set
CONFIG_UIO_AEC=y
# CONFIG_UIO_SERCOS3 is not set
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
CONFIG_UIO_PRUSS=y
CONFIG_UIO_MF624=y
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_PCI_LEGACY=y
# CONFIG_VIRTIO_BALLOON is not set
CONFIG_VIRTIO_INPUT=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_PMC_ATOM=y
CONFIG_GOLDFISH_BUS=y
CONFIG_GOLDFISH_PIPE=y
CONFIG_CHROME_PLATFORMS=y
# CONFIG_CHROMEOS_PSTORE is not set
CONFIG_CROS_EC_CHARDEV=y
# CONFIG_CROS_EC_LPC is not set
CONFIG_CROS_EC_PROTO=y
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_RK808 is not set
# CONFIG_COMMON_CLK_SI5351 is not set
CONFIG_COMMON_CLK_SI514=y
CONFIG_COMMON_CLK_SI570=y
CONFIG_COMMON_CLK_CDCE706=y
CONFIG_COMMON_CLK_CDCE925=y
CONFIG_COMMON_CLK_CS2000_CP=y
CONFIG_COMMON_CLK_S2MPS11=y
CONFIG_CLK_TWL6040=y
# CONFIG_COMMON_CLK_NXP is not set
# CONFIG_COMMON_CLK_PALMAS is not set
CONFIG_COMMON_CLK_PWM=y
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set
CONFIG_COMMON_CLK_VC5=y

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
CONFIG_PLATFORM_MHU=y
# CONFIG_PCC is not set
CONFIG_ALTERA_MBOX=y
CONFIG_MAILBOX_TEST=y
# CONFIG_IOMMU_SUPPORT is not set

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
# CONFIG_SOC_TI is not set
CONFIG_SOC_ZTE=y
CONFIG_ZX2967_PM_DOMAINS=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y
# CONFIG_DEVFREQ_GOV_PASSIVE is not set

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ARIZONA=y
CONFIG_EXTCON_MAX14577=y
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_PALMAS=y
CONFIG_EXTCON_QCOM_SPMI_MISC=y
CONFIG_EXTCON_RT8973A=y
CONFIG_EXTCON_SM5502=y
CONFIG_MEMORY=y
# CONFIG_IIO is not set
CONFIG_NTB=y
CONFIG_NTB_AMD=y
CONFIG_NTB_INTEL=y
CONFIG_NTB_PINGPONG=y
# CONFIG_NTB_TOOL is not set
CONFIG_NTB_PERF=y
CONFIG_NTB_TRANSPORT=y
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
# CONFIG_VME_TSI148 is not set
CONFIG_VME_FAKE=y

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=y

#
# VME Device Drivers
#
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_ATMEL_HLCDC_PWM=y
CONFIG_PWM_CROS_EC=y
CONFIG_PWM_FSL_FTM=y
CONFIG_PWM_LP3943=y
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
CONFIG_PWM_PCA9685=y
CONFIG_PWM_TWL=y
CONFIG_PWM_TWL_LED=y
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
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
# CONFIG_FMC_TRIVIAL is not set
CONFIG_FMC_WRITE_EEPROM=y
# CONFIG_FMC_CHARDEV is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_PHY_PXA_28NM_HSIC is not set
CONFIG_PHY_PXA_28NM_USB2=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_PHY_QCOM_USB_HS=y
# CONFIG_PHY_QCOM_USB_HSIC is not set
CONFIG_PHY_TUSB1210=y
# CONFIG_POWERCAP is not set
# CONFIG_MCB is not set

#
# Performance monitor support
#
CONFIG_RAS=y
CONFIG_MCE_AMD_INJ=y
CONFIG_THUNDERBOLT=y

#
# Android
#
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_ANDROID_BINDER_DEVICES="binder"
# CONFIG_LIBNVDIMM is not set
CONFIG_DEV_DAX=y
CONFIG_NR_DEV_DAX=32768
CONFIG_NVMEM=y
CONFIG_STM=y
CONFIG_STM_DUMMY=y
CONFIG_STM_SOURCE_CONSOLE=y
# CONFIG_STM_SOURCE_HEARTBEAT is not set
CONFIG_INTEL_TH=y
CONFIG_INTEL_TH_PCI=y
CONFIG_INTEL_TH_GTH=y
CONFIG_INTEL_TH_STH=y
CONFIG_INTEL_TH_MSU=y
CONFIG_INTEL_TH_PTI=y
# CONFIG_INTEL_TH_DEBUG is not set

#
# FPGA Configuration Support
#
# CONFIG_FPGA is not set

#
# FSI support
#
# CONFIG_FSI is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
# CONFIG_FIRMWARE_MEMMAP is not set
# CONFIG_DELL_RBU is not set
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_FW_CFG_SYSFS is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
# CONFIG_EFI_DEV_PATH_PARSER is not set

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
# CONFIG_EXT2_FS_SECURITY is not set
CONFIG_EXT3_FS=y
# CONFIG_EXT3_FS_POSIX_ACL is not set
# CONFIG_EXT3_FS_SECURITY is not set
CONFIG_EXT4_FS=y
# CONFIG_EXT4_FS_POSIX_ACL is not set
# CONFIG_EXT4_FS_SECURITY is not set
# CONFIG_EXT4_ENCRYPTION is not set
CONFIG_EXT4_DEBUG=y
CONFIG_JBD2=y
CONFIG_JBD2_DEBUG=y
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
CONFIG_GFS2_FS=y
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
CONFIG_BTRFS_ASSERT=y
# CONFIG_NILFS2_FS is not set
CONFIG_F2FS_FS=y
CONFIG_F2FS_STAT_FS=y
CONFIG_F2FS_FS_XATTR=y
CONFIG_F2FS_FS_POSIX_ACL=y
# CONFIG_F2FS_FS_SECURITY is not set
CONFIG_F2FS_CHECK_FS=y
# CONFIG_F2FS_FS_ENCRYPTION is not set
CONFIG_F2FS_FAULT_INJECTION=y
# CONFIG_FS_DAX is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_OVERLAY_FS=y
CONFIG_OVERLAY_FS_REDIRECT_DIR=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
# CONFIG_ZISOFS is not set
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
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
# CONFIG_PROC_SYSCTL is not set
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
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
CONFIG_NLS_CODEPAGE_855=y
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
# CONFIG_NLS_CODEPAGE_863 is not set
CONFIG_NLS_CODEPAGE_864=y
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
# CONFIG_NLS_MAC_CYRILLIC is not set
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
# CONFIG_NLS_MAC_ICELAND is not set
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
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_STACK_VALIDATION=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_PAGE_POISONING=y
# CONFIG_PAGE_POISONING_NO_SANITY is not set
CONFIG_PAGE_POISONING_ZERO=y
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
CONFIG_DEBUG_OBJECTS_FREE=y
CONFIG_DEBUG_OBJECTS_TIMERS=y
CONFIG_DEBUG_OBJECTS_WORK=y
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
# CONFIG_DEBUG_VM_RB is not set
CONFIG_DEBUG_VM_PGFLAGS=y
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_WQ_WATCHDOG=y
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHED_INFO is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set

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
CONFIG_LOCK_TORTURE_TEST=y
# CONFIG_WW_MUTEX_SELFTEST is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=y
CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT=y
CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT_DELAY=3
CONFIG_RCU_TORTURE_TEST_SLOW_INIT=y
CONFIG_RCU_TORTURE_TEST_SLOW_INIT_DELAY=3
# CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
# CONFIG_FAIL_MAKE_REQUEST is not set
# CONFIG_FAIL_IO_TIMEOUT is not set
CONFIG_FAIL_FUTEX=y
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
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
CONFIG_LKDTM=y
CONFIG_TEST_LIST_SORT=y
# CONFIG_TEST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_TEST_HEXDUMP=y
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=y
CONFIG_TEST_PRINTF=y
CONFIG_TEST_BITMAP=y
CONFIG_TEST_UUID=y
CONFIG_TEST_RHASHTABLE=y
CONFIG_TEST_HASH=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_TEST_FIRMWARE is not set
# CONFIG_TEST_UDELAY is not set
CONFIG_MEMTEST=y
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_DEBUG=y
# CONFIG_IOMMU_STRESS is not set
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
CONFIG_DEBUG_ENTRY=y
# CONFIG_DEBUG_NMI_SELFTEST is not set
# CONFIG_X86_DEBUG_FPU is not set
CONFIG_PUNIT_ATOM_DEBUG=y

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEY_DH_OPERATIONS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HAVE_ARCH_HARDENED_USERCOPY=y
# CONFIG_HARDENED_USERCOPY is not set
CONFIG_STATIC_USERMODEHELPER=y
CONFIG_STATIC_USERMODEHELPER_PATH="/sbin/usermode-helper"
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
CONFIG_CRYPTO_ACOMP2=y
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
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y
CONFIG_CRYPTO_ENGINE=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_CHACHA20POLY1305=y
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
# CONFIG_CRYPTO_CMAC is not set
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
# CONFIG_CRYPTO_GHASH is not set
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
CONFIG_CRYPTO_SHA256_SSSE3=y
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA1_MB=y
CONFIG_CRYPTO_SHA256_MB=y
CONFIG_CRYPTO_SHA512_MB=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=y
# CONFIG_CRYPTO_AES_X86_64 is not set
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
# CONFIG_CRYPTO_ARC4 is not set
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_DES3_EDE_X86_64=y
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_LZO is not set
# CONFIG_CRYPTO_842 is not set
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
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
# CONFIG_CRYPTO_DEV_FSL_CAAM_CRYPTO_API_DESC is not set
CONFIG_CRYPTO_DEV_CCP=y
# CONFIG_CRYPTO_DEV_CCP_DD is not set
CONFIG_CRYPTO_DEV_QAT=y
CONFIG_CRYPTO_DEV_QAT_DH895xCC=y
CONFIG_CRYPTO_DEV_QAT_C3XXX=y
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
CONFIG_CRYPTO_DEV_QAT_C3XXXVF=y
CONFIG_CRYPTO_DEV_QAT_C62XVF=y
CONFIG_CRYPTO_DEV_VIRTIO=y
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
# CONFIG_X509_CERTIFICATE_PARSER is not set

#
# Certificates for signature checking
#
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set
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
# CONFIG_CRC8 is not set
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
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
CONFIG_INTERVAL_TREE=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
# CONFIG_DMA_NOOP_OPS is not set
# CONFIG_DMA_VIRT_OPS is not set
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_GLOB=y
CONFIG_GLOB_SELFTEST=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_LIBFDT=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_SBITMAP=y
CONFIG_PRIME_NUMBERS=y

--xqkdgemdwi5wxj5z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
