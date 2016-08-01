Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9018F6B0267
	for <linux-mm@kvack.org>; Sun, 31 Jul 2016 21:38:39 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so220177368pad.2
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 18:38:39 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id g79si32224918pfb.219.2016.07.31.18.38.38
        for <linux-mm@kvack.org>;
        Sun, 31 Jul 2016 18:38:38 -0700 (PDT)
Date: Mon, 1 Aug 2016 09:38:30 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [   25.666092] WARNING: CPU: 0 PID: 451 at mm/memcontrol.c:998
 mem_cgroup_update_lru_size
Message-ID: <20160801013830.GB27998@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="wac7ysb48OaltWcw"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKP <lkp@01.org>


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git mm-vmscan-node-lru-follow-up-v2r1

commit d5d54a2c5517f0818ad75a2f5b1d26a0dacae46a
Author:     Mel Gorman <mgorman@techsingularity.net>
AuthorDate: Wed Jul 13 09:30:01 2016 +0100
Commit:     Mel Gorman <mgorman@techsingularity.net>
CommitDate: Wed Jul 13 09:30:01 2016 +0100

     mm, memcg: move memcg limit enforcement from zones to nodes
     
     Memcg needs adjustment after moving LRUs to the node. Limits are tracked
     per memcg but the soft-limit excess is tracked per zone. As global page
     reclaim is based on the node, it is easy to imagine a situation where
     a zone soft limit is exceeded even though the memcg limit is fine.
     
     This patch moves the soft limit tree the node.  Technically, all the variable
     names should also change but people are already familiar by the meaning of
     "mz" even if "mn" would be a more appropriate name now.
     
     Link: http://lkml.kernel.org/r/1467970510-21195-15-git-send-email-mgorman@techsingularity.net
     Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
     Acked-by: Michal Hocko <mhocko@suse.com>
     Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
     Acked-by: Johannes Weiner <hannes@cmpxchg.org>
     Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
     Cc: Minchan Kim <minchan@kernel.org>
     Cc: Rik van Riel <riel@surriel.com>
     Cc: Vlastimil Babka <vbabka@suse.cz>
     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

+------------------------------------------------------------------+------------+------------+------------+
|                                                                  | 3eee0b402e | d5d54a2c55 | a3db8049ae |
+------------------------------------------------------------------+------------+------------+------------+
| boot_successes                                                   | 1160       | 287        | 8          |
| boot_failures                                                    | 14         | 27         | 20         |
| invoked_oom-killer:gfp_mask=0x                                   | 11         | 0          | 4          |
| Mem-Info                                                         | 11         | 0          | 4          |
| Out_of_memory:Kill_process                                       | 9          | 0          | 12         |
| backtrace:SyS_clone+0x                                           | 8          | 10         | 8          |
| BUG:kernel_test_crashed                                          | 3          | 2          |            |
| Kernel_panic-not_syncing:Out_of_memory_and_no_killable_processes | 2          | 0          | 4          |
| backtrace:do_mlock+0x                                            | 1          |            |            |
| backtrace:SyS_mlock+0x                                           | 1          |            |            |
| backtrace:_do_fork+0x                                            | 5          |            |            |
| backtrace:SyS_newlstat+0x                                        | 1          |            |            |
| backtrace:lock_torture_stats+0x                                  | 1          |            |            |
| backtrace:getname_flags+0x                                       | 1          | 0          | 1          |
| backtrace:SyS_symlink+0x                                         | 1          | 0          | 1          |
| warn_alloc_failed+0x                                             | 1          |            |            |
| backtrace:__mm_populate+0x                                       | 1          | 2          |            |
| backtrace:SyS_mlockall+0x                                        | 1          | 2          |            |
| WARNING:at_mm/memcontrol.c:#mem_cgroup_update_lru_size           | 0          | 25         | 3          |
| kernel_BUG_at_mm/memcontrol.c                                    | 0          | 25         | 8          |
| invalid_opcode:#[##]PREEMPT_SMP                                  | 0          | 25         | 8          |
| RIP:mem_cgroup_update_lru_size                                   | 0          | 25         |            |
| Kernel_panic-not_syncing:Fatal_exception                         | 0          | 25         | 8          |
| backtrace:SyS_newfstatat+0x                                      | 0          | 6          | 1          |
| backtrace:sock_map_fd+0x                                         | 0          | 1          |            |
| backtrace:SyS_socket+0x                                          | 0          | 1          |            |
| backtrace:do_sys_open+0x                                         | 0          | 1          |            |
| backtrace:SyS_openat+0x                                          | 0          | 1          |            |
| RIP:#:[<#>]RIP:mem_cgroup_update_lru_size                        | 0          | 0          | 8          |
| backtrace:SyS_setsockopt+0x                                      | 0          | 0          | 4          |
| backtrace:sock_setsockopt+0x                                     | 0          | 0          | 2          |
| backtrace:common_nsleep+0x                                       | 0          | 0          | 1          |
| backtrace:SyS_clock_nanosleep+0x                                 | 0          | 0          | 1          |
| backtrace:_do_fork                                               | 0          | 0          | 1          |
| backtrace:SyS_clone                                              | 0          | 0          | 1          |
| backtrace:sock_common_setsockopt                                 | 0          | 0          | 1          |
| backtrace:SyS_setsockopt                                         | 0          | 0          | 1          |
+------------------------------------------------------------------+------------+------------+------------+

[   25.517925] ODEBUG: Out of memory. ODEBUG disabled
[   25.665103] ------------[ cut here ]------------
[   25.665103] ------------[ cut here ]------------
[   25.666092] WARNING: CPU: 0 PID: 451 at mm/memcontrol.c:998 mem_cgroup_update_lru_size+0x111/0x120
[   25.666092] WARNING: CPU: 0 PID: 451 at mm/memcontrol.c:998 mem_cgroup_update_lru_size+0x111/0x120
[   25.668268] mem_cgroup_update_lru_size(ffff880010100008, 3, -4): lru_size 23 but empty
[   25.668268] mem_cgroup_update_lru_size(ffff880010100008, 3, -4): lru_size 23 but empty
[   25.669844] CPU: 0 PID: 451 Comm: trinity-main Not tainted 4.7.0-rc7-mm1-00218-gd5d54a2 #1
[   25.669844] CPU: 0 PID: 451 Comm: trinity-main Not tainted 4.7.0-rc7-mm1-00218-gd5d54a2 #1
[   25.670012]  0000000000000000
[   25.670012]  0000000000000000 ffff880008677408 ffff880008677408 ffffffff8136ea65 ffffffff8136ea65 ffff880008677458 ffff880008677458

[   25.670012]  0000000000000000
[   25.670012]  0000000000000000 ffff880008677448 ffff880008677448 ffffffff810889fc ffffffff810889fc 000003e68100e2d9 000003e68100e2d9

[   25.670012]  0000000000000003
[   25.670012]  0000000000000003 fffffffffffffffc fffffffffffffffc ffffffff82b32cc0 ffffffff82b32cc0 ffff880010100008 ffff880010100008

[   25.670012] Call Trace:
[   25.670012] Call Trace:
[   25.670012]  [<ffffffff8136ea65>] dump_stack+0x86/0xc1
[   25.670012]  [<ffffffff8136ea65>] dump_stack+0x86/0xc1
[   25.670012]  [<ffffffff810889fc>] __warn+0xbc/0xe0
[   25.670012]  [<ffffffff810889fc>] __warn+0xbc/0xe0
[   25.670012]  [<ffffffff81088a6a>] warn_slowpath_fmt+0x4a/0x50
[   25.670012]  [<ffffffff81088a6a>] warn_slowpath_fmt+0x4a/0x50
[   25.670012]  [<ffffffff81190111>] mem_cgroup_update_lru_size+0x111/0x120
[   25.670012]  [<ffffffff81190111>] mem_cgroup_update_lru_size+0x111/0x120
[   25.670012]  [<ffffffff81156f7b>] isolate_lru_pages+0x15b/0x1f0
[   25.670012]  [<ffffffff81156f7b>] isolate_lru_pages+0x15b/0x1f0
[   25.670012]  [<ffffffff811589bf>] shrink_active_list+0xbf/0x2b0
[   25.670012]  [<ffffffff811589bf>] shrink_active_list+0xbf/0x2b0
[   25.670012]  [<ffffffff81158eb1>] shrink_node_memcg+0x301/0x490
[   25.670012]  [<ffffffff81158eb1>] shrink_node_memcg+0x301/0x490
[   25.670012]  [<ffffffff811590ff>] shrink_node+0xbf/0x1d0
[   25.670012]  [<ffffffff811590ff>] shrink_node+0xbf/0x1d0
[   25.670012]  [<ffffffff811592d4>] do_try_to_free_pages+0xc4/0x270
[   25.670012]  [<ffffffff811592d4>] do_try_to_free_pages+0xc4/0x270
[   25.670012]  [<ffffffff8115952e>] try_to_free_pages+0xae/0xc0
[   25.670012]  [<ffffffff8115952e>] try_to_free_pages+0xae/0xc0
[   25.670012]  [<ffffffff8114cde7>] __alloc_pages_slowpath+0x277/0xb90
[   25.670012]  [<ffffffff8114cde7>] __alloc_pages_slowpath+0x277/0xb90
[   25.670012]  [<ffffffff8114da35>] __alloc_pages_nodemask+0x1d5/0x1f0
[   25.670012]  [<ffffffff8114da35>] __alloc_pages_nodemask+0x1d5/0x1f0
[   25.670012]  [<ffffffff81181740>] new_slab+0x2c0/0x610
[   25.670012]  [<ffffffff81181740>] new_slab+0x2c0/0x610
[   25.670012]  [<ffffffff811e74d8>] ? proc_alloc_inode+0x18/0xb0
[   25.670012]  [<ffffffff811e74d8>] ? proc_alloc_inode+0x18/0xb0
[   25.670012]  [<ffffffff81183916>] ___slab_alloc+0x1a6/0x490
[   25.670012]  [<ffffffff81183916>] ___slab_alloc+0x1a6/0x490
[   25.670012]  [<ffffffff811e74d8>] ? proc_alloc_inode+0x18/0xb0
[   25.670012]  [<ffffffff811e74d8>] ? proc_alloc_inode+0x18/0xb0
[   25.670012]  [<ffffffff811e74d8>] ? proc_alloc_inode+0x18/0xb0
[   25.670012]  [<ffffffff811e74d8>] ? proc_alloc_inode+0x18/0xb0
[   25.670012]  [<ffffffff81183c50>] __slab_alloc+0x50/0xa0
[   25.670012]  [<ffffffff81183c50>] __slab_alloc+0x50/0xa0
[   25.670012]  [<ffffffff811e74d8>] ? proc_alloc_inode+0x18/0xb0
[   25.670012]  [<ffffffff811e74d8>] ? proc_alloc_inode+0x18/0xb0
[   25.670012]  [<ffffffff81184365>] kmem_cache_alloc+0x115/0x140
[   25.670012]  [<ffffffff81184365>] kmem_cache_alloc+0x115/0x140
[   25.670012]  [<ffffffff811e74d8>] proc_alloc_inode+0x18/0xb0
[   25.670012]  [<ffffffff811e74d8>] proc_alloc_inode+0x18/0xb0
[   25.670012]  [<ffffffff811b9598>] alloc_inode+0x18/0x80
[   25.670012]  [<ffffffff811b9598>] alloc_inode+0x18/0x80
[   25.670012]  [<ffffffff811ba1ac>] new_inode_pseudo+0xc/0x60
[   25.670012]  [<ffffffff811ba1ac>] new_inode_pseudo+0xc/0x60
[   25.670012]  [<ffffffff811e79ff>] proc_get_inode+0xf/0x130
[   25.670012]  [<ffffffff811e79ff>] proc_get_inode+0xf/0x130
[   25.670012]  [<ffffffff811ecee4>] proc_lookup_de+0x54/0xb0
[   25.670012]  [<ffffffff811ecee4>] proc_lookup_de+0x54/0xb0
[   25.670012]  [<ffffffff811f4363>] proc_tgid_net_lookup+0x33/0x40
[   25.670012]  [<ffffffff811f4363>] proc_tgid_net_lookup+0x33/0x40
[   25.670012]  [<ffffffff811a5dab>] lookup_slow+0x11b/0x1f0
[   25.670012]  [<ffffffff811a5dab>] lookup_slow+0x11b/0x1f0
[   25.670012]  [<ffffffff811a85be>] walk_component+0x1ce/0x520
[   25.670012]  [<ffffffff811a85be>] walk_component+0x1ce/0x520
[   25.670012]  [<ffffffff811a8981>] ? link_path_walk+0x71/0x5d0
[   25.670012]  [<ffffffff811a8981>] ? link_path_walk+0x71/0x5d0
[   25.670012]  [<ffffffff810d03ad>] ? trace_hardirqs_on+0xd/0x10
[   25.670012]  [<ffffffff810d03ad>] ? trace_hardirqs_on+0xd/0x10
[   25.670012]  [<ffffffff811a9242>] path_lookupat+0x62/0x120
[   25.670012]  [<ffffffff811a9242>] path_lookupat+0x62/0x120
[   25.670012]  [<ffffffff811a9399>] filename_lookup+0x99/0x150
[   25.670012]  [<ffffffff811a9399>] filename_lookup+0x99/0x150
[   25.670012]  [<ffffffff810d03ad>] ? trace_hardirqs_on+0xd/0x10
[   25.670012]  [<ffffffff810d03ad>] ? trace_hardirqs_on+0xd/0x10
[   25.670012]  [<ffffffff811a6ada>] ? getname_flags+0x4a/0x1e0
[   25.670012]  [<ffffffff811a6ada>] ? getname_flags+0x4a/0x1e0
[   25.670012]  [<ffffffff81184365>] ? kmem_cache_alloc+0x115/0x140
[   25.670012]  [<ffffffff81184365>] ? kmem_cache_alloc+0x115/0x140
[   25.670012]  [<ffffffff811ab101>] user_path_at_empty+0x31/0x40
[   25.670012]  [<ffffffff811ab101>] user_path_at_empty+0x31/0x40
[   25.670012]  [<ffffffff811a0b2e>] vfs_fstatat+0x4e/0xa0
[   25.670012]  [<ffffffff811a0b2e>] vfs_fstatat+0x4e/0xa0
[   25.670012]  [<ffffffff811a0b95>] SYSC_newfstatat+0x15/0x30
[   25.670012]  [<ffffffff811a0b95>] SYSC_newfstatat+0x15/0x30
[   25.670012]  [<ffffffff810d02e5>] ? trace_hardirqs_on_caller+0xf5/0x1b0

git bisect start a3db8049aec5ca8c90d86d1f09a63ce5ceeb66be 92d21ac74a9e3c09b0b01c764e530657e4c85c49 --
git bisect  bad d52ed4edc9167152aa2976e04926c041f4eff9b8  # 15:02      0-     11  Merge 'yexl/git-format-patch-verify-on-lv-zheng-ACPI' into devel-spot-201607151924
git bisect  bad a0f2d9d9e90d0ff3d6d9fdd92dec785d748122c2  # 15:02      0-    107  Merge 'linux-review/Javier-Martinez-Canillas/vb2-include-length-in-dmabuf-qbuf-debug-message/20160715-152805' into devel-spot-201607151924
git bisect  bad f45065106a42183395249f4a36c87d80c83cb175  # 15:02      0-    176  Merge 'linux-review/Philippe-Reynes/net-ethernet-smsc9420-use-phydev-from-struct-net_device/20160715-172417' into devel-spot-201607151924
git bisect  bad 519b4ca9bc0e8dbc1835988e4339eecda289f579  # 15:03      0-    180  Merge 'jpirko-mlxsw/combined_queue' into devel-spot-201607151924
git bisect  bad 151f330b09503ff463f19f0116c93276fb7d9c1c  # 15:03      0-    161  Merge 'arm-tegra/for-next' into devel-spot-201607151924
git bisect good 2b75d858d5e5005649a6878c95e673f75b54c85f  # 15:06    140+    104  0day base guard for 'devel-spot-201607151924'
git bisect  bad 51ce11d42369204dd8c0fb620cce050b367c6daa  # 15:08      8-      8  Merge 'mel/mm-vmscan-node-lru-follow-up-v2r1' into devel-spot-201607151924
git bisect good 8b6f2fa3d440dfb5e9b246184e8af5a0c5aafdcb  # 15:30    136+      2  thp, mlock: do not mlock PTE-mapped file huge pages
git bisect  bad 2c80750fac5a84b15106733b96702a1819980038  # 16:05      3-      1  mm: vmstat: replace __count_zone_vm_events with a zone id equivalent
git bisect good 67f413fd3aa33595d03a90e448e56f06366a34cf  # 16:21    140+      2  mm: update the comment in __isolate_free_page
git bisect good 3313b5ca3cd67cf1751d70c6d9453072f4f3998a  # 16:37    138+      0  mm, vmscan: remove duplicate logic clearing node congestion and dirty state
git bisect  bad 68b0562046a73eb40b5b17866854a49b7512fc74  # 16:40     17-      1  mm, vmscan: only wakeup kswapd once per node for the requested classzone
git bisect  bad 80022ba40a24cfe6b0aadf720a0c112833477423  # 16:48     67-      3  mm, page_alloc: consider dirtyable memory in terms of nodes
git bisect good 3eee0b402edcc91203b5486d0d269e8473add914  # 17:03    250+      2  mm, vmscan: make shrink_node decisions more node-centric
git bisect  bad b69ad1f6f47bd028fb0573e2c94795ab77363e70  # 17:12     55-      1  mm, workingset: make working set detection node-aware
git bisect  bad d5d54a2c5517f0818ad75a2f5b1d26a0dacae46a  # 17:17      1-      1  mm, memcg: move memcg limit enforcement from zones to nodes
# first bad commit: [d5d54a2c5517f0818ad75a2f5b1d26a0dacae46a] mm, memcg: move memcg limit enforcement from zones to nodes
git bisect good 3eee0b402edcc91203b5486d0d269e8473add914  # 17:30    906+     14  mm, vmscan: make shrink_node decisions more node-centric
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad d5d54a2c5517f0818ad75a2f5b1d26a0dacae46a  # 17:39      7-      6  mm, memcg: move memcg limit enforcement from zones to nodes
# extra tests on HEAD of linux-devel/devel-spot-201607151924
git bisect  bad a3db8049aec5ca8c90d86d1f09a63ce5ceeb66be  # 17:39      0-     20  0day head guard for 'devel-spot-201607151924'
# extra tests on tree/branch mel/mm-vmscan-node-lru-follow-up-v2r1
git bisect good d5502746ab169a810a4adc0ec760117790e477df  # 18:01    906+    112  mm, vmscan: Update all zone LRU sizes before updating memcg
# extra tests on tree/branch linus/master
git bisect good 194dc870a5890e855ecffb30f3b80ba7c88f96d6  # 18:49    910+      9  Add braces to avoid "ambiguous a??elsea??" compiler warnings
# extra tests on tree/branch linux-next/master
git bisect good d4e661a48572b90ab727149e2f2ec087380a573b  # 19:17    910+      8  Add linux-next specific files for 20160728


This script may reproduce the error.

----------------------------------------------------------------------------
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
	-m 300
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

--wac7ysb48OaltWcw
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-quantal-vp-51:20160728171844:x86_64-randconfig-s3-07152033:4.7.0-rc7-mm1-00218-gd5d54a2:1.gz"
Content-Transfer-Encoding: base64

H4sICLzpmVcAA2RtZXNnLXF1YW50YWwtdnAtNTE6MjAxNjA3MjgxNzE4NDQ6eDg2XzY0LXJh
bmRjb25maWctczMtMDcxNTIwMzM6NC43LjAtcmM3LW1tMS0wMDIxOC1nZDVkNTRhMjoxAOxd
W3PiSLJ+71+RsfMweMNgle7iBBtrY9zm2NiMce/MbkcHIaQS1lhIGl3c9vz6k1mSaEDgC7an
e+NA9BgkZX6VVZWVlVmVpeF2EjyAE4VpFHDwQ0h5lsd4w+Uf+Oozfp8ltpONb3kS8uCDH8Z5
NnbtzG6DdC9VH9V0HNnQy8cBD5eeSo6kyqb8IcozfLz0iBVf5aMapywrhmmYH4rSx1mU2cE4
9f/ky6Wr3CWQD8fciWZxwtPUD6dw7of5favVgqGdiBu98xO6dKOQtz4cRVFGN7MbDgV868Nn
wI/UKlC/FABwx5E7CkFtGS2pmThGczZjTZSNmc2pq7maasvQuJ3kfuD+M7iNm+lEUvegMXWc
Oa/eYi0GssR0yZA0aBzziW+Xt5vWHuzBTwxGgyEMr3q9wfAarm9y+N88ANkEZrRlGf9Bd3Qt
IFbF7EazmR26EPghtgskWLHOgcvvDhJ7JsFNHk7HmZ3ejmM79J0OA5dP8inYMV4UP9OHNPlj
bAdf7Yd0zEN7EnAXEiePsZ95C3+MnTgfp9j22AX+jGNndbDjoABsMkgjLwsi5zaP54WEM3/8
1c6cGzeadsRNiKI4LX8Gke2OUTzXT287MsQJdls2vyGRRBmfua0gmqJO3PGgw5ME/GkYJXyM
N8U9EMoaJ36Y3Xay7GEk7TOmyShYqb8bb0pwN7U7CDazA0i+Usvddg6KLmxmPM3SgyQPm3/k
POcHt3ezg3tTH+tqM8FmRhjPnzZTpSkZBKwoBwHpSdMlmdribzONo6xZdDfTmCWr7VJRHE1j
hieZzLRdQ7NlT5swV9ZtybUdm6u63Z74KXeyZoFpHbTuZvTzz+ZzAcpiZZMZOHqUJtOadzFM
UHTnprMg6cEGSeHo8vJ63B8cfux1DuLbaVG7J1oAdb2pHzxXxIOqTo8OKTeZuK2Zj700dqI8
zDrmquKf9a4ueueQ5nEcJRnqLKpp2l6lAujyMLPzpPo+tfMgrQ2i4ac2DtfQxeJ8F37+yMMc
x1M/zHjwM+ThbRh9DfchF4ZkykOeoBr7oZ/VrIZA+neE5RVaDDP7ASYcMXAE4dCqMWDTHnhx
3oZzPrWdB7w24GT4CcdphprA3c0Mn4Q0P3N7ypOfBQ/2TYYmG9KvPo49ntZ4uSlLbTjqX46a
OOrufBebLb55SH0Hh8LV4QCljWtNKMgLzs8zrNGibS8+zaVbljfxvC/YWFTfF4FZnlMH8wgM
rTpP7rj7IjivLpu3PRxbrSqTJ24B99KqIievg20tm8c9arhFOLq1NVyBtgTnPQUn5pJ2YaRJ
LedmGt0LmmlrqjjBiaryND4LW47ApKLFDLRKfvEbNHr33MkzDse+aO89mjlokOAc2wZ0U/y7
Wh+cPsQorp9GyXxAteHsX4P1A6OY81bbo2qHha6GTucfG5uiwEr4LLpbxLK/YXmPqU3BHthp
No69EDrILfQFx+b92E6cm/lttZJwFWJwfXWF9fXQ1GWQYRO04WviZ7w5sZ3btcSef0+zvh1O
eVp1wRpbWrSHdYKfRxABDgXdkaDLQ8d2btbVFG2zoDtZwCu7dK2Qd3bii9Z/Wk6Y2ClHcc2y
hbDx0ls4OZlfPyYVOkmFhtW6FkB+5JnyyDP1kWfaI8/0R54ZG5/RHDE8vG6jd0izdZ7YNEjg
s9Q0vrTh1yOAX7sAn7pN/A+Wrn+9BlhFGznorXo4hMhHxahgw/hQUKefz7pg6wsb/3zWBbvu
rWX10GNwBd9g2BTTLtjZIoCueRUA/sShiPNejAOAqAjRLPRE0NXQAWax0wZP11EKTzeYU7Ot
pHxYWpQ8AAZQszgi73wV3bIEsfgCCmtAVjWj5uAfXZ1hx91LmuoaeGMfyt/ChAw/Xh8enfce
4TEXeMxn8lgLPNYzeewFHvsxHnQzjvujs/m0Qw66W3TofEZd5TnsDvtt6InwtOhPdG+c2zSf
UZDle+i/CAXfNB4K/qvR8XDZQzjRlZ4krBpToXGH/XB02T0dwd5GgOulafyoxwzFEACKAGAl
ABz9NuwW5CWtuDO/2lDACX6tFCB1UTS6MOoFFOQvKeC4XgOMoEUTHB3XCzjepgajWgFS0cZq
baIqeEZrhOqaJvFYJ0ZNqNGLhToc9rur/aYbJ4LNlGoFFOQvKeB02Ksphn5SFKCYtQIK8pcU
cB6Rhy4Es12X1jiwOI8LL7LWqqUxE9RZBN78ownHDhpQfiqAWqHOzG6DO7PHFFHg/BHl6bh0
dxqBP/MzqFzYGisGzE2HlgOqAGWWJimoE01XXawsLVWUFzW5F1gxlgM0J8gLUpsx1UZyto8O
nz+z0ajSY0H5CEQRrKVoKFyIPA/9UPwC1TQtdOU1FMV5cAJeCwUFd4oBnINe0wIcORC07uSt
fIRbVkDRY+a4qsxVNGOTffHIdwM+DvGZaTLNkjSLqaYCYa3c/0Rh5discWiOB4dFl62JwCgw
WYpyvPWzokBR5HUo5ULcuuCmjnJRrJwA8FmcPdQ8tehOGOg/qT4Y8yaZmMQ5elsQ0iLjCn1h
1MvJkgjKRqiXKx7irbVhaK0RJIuvF/8RmM0h3ipMH2N/4i4WTwWk9AyxNuJdhhWIWOWMbVID
MHTdqI2SQhmoedugqyBIUdlRy6mdUQQc/o/xyKzk2RS/LBIrlmUW5Ptw3j+5RL86c27a64VC
3Sq4GFP0Fwg25zNk3ZDXFMe09VZxOGhe+zOeQP8ShlEiFpd1qbZS9F1MaFkoIYwvBn1o2E7s
ozX4TCYE42UvEP+hY5jhLfalBtC/JN7PEjrstFpL61JoEas1ZWbsL1VDROz4/OOoD1JTVtaL
07+4Ho+uuuPLf11BY5KnFCihafeTP/DXNIgmdiAu5Eq+ulQhtjKFlCQM+rX0lSX+lL4FIH73
r34R36L1+scw/3mBs578Ysm0Rck0uPGnNyDWFp4WjpXCKSvCaRuE26BnjwhnLQpnvYlw1gbh
rBcLx5Y6Fa/eQjx7g3j2y8VjS+KxNxFvskG8yQbxrn6RCiM1eYAIR1fiu/VF2mdrPdtQOtsa
UdmAWBvhz0ZUNyCqG1tIe8MW0jeUXot7n41obEA0tkY0NyBumFmQx3q6hea07BkK942YvWHb
OxvqVVvAeDaiuwGx5lQ8G5FvQKw5js9G9DYgequIRbxCTQ+NweHx9d58+clZWkbzQ49cYPr9
SDjou+SOmJKp2zJGG7QgKeIHsVtd9zjSWUxL4hisBkH0lQSRaTMJHSE021EWB/lUXG/wVApv
YdVXmUjkq1TeQc2oLi3/M7mgapKMHu3hoJti39l+IPx5aophtw8uv/OduntebajHdmLf+UmW
24H/J8pVbK4DttqaVfelWCvhnh9yt/m773k+eb+rEddKpFXdXgmzmMWYrEuqqsuGRsWsibWE
1z6OeeLQPtrF1RgbdtQ2mSVDmNB2NxU9nvhZ2q7uYAHlBfnp4qpm0yvA3mzCXdpaUw2j8GYP
KGD9Z7X2x6TCZ4QUS0QPW4ZEAle2TFqXliWL9lVr2IjQtFE1nPZjbCBIOuzvz4BB15KCFvzL
aku+2FllbGOnD6EDwxOhACIsXxdzpxm3A8oOWArdqaKOXtf1o9wPMiyVvP7AT7OU1ndFABwl
Lk+QOZr4gZ89wDSJ8pj0KgpbANcUG0EVHGmqWnOJzgp1c3ZJEbukiP+PSRFCb9vFFxTqW22T
1dyGIU6IN3Z6U66o8xBnTxpYsqSa0BAjES/2gemKqaIDglpQm0GOiesBaC+NrwXTNU3R52jo
qmmyKpvmBrg+GdfmZjRFNvRvsqErKesyUzcJNxCLSlQhydT0swNF0nVTOluY1BpMU2XjrJql
KAluHxRVMs9wDFCe2z7oKpPxKiquZIueUeYH0lmaho8mKc7RTNJMWT2br6ngrH1Gq6jN6kZN
uNH5pyP0FH7FeXIadnR0yi+pVh2piR7/wA8vJ7+j0qcdNKU07XewIy5QvLRTm3au8jAkE3nV
/YQ2O/BADNdabyec1ut8qvaNzxPaSS7SPpDNn8UBn1GCDDk1NU1BEvRL3N/zNCsSYKIZp26n
KYFsoWeHkcjfs70Ow175NmV2ajMQzrbolY3aqAdowIkUg7+0raoS1JPbdjl4u+lmN938uNPN
Lgdvl4O3y8ETldrl4O1y8Jacz10O3i4Hb5eDt8vB2+XgLfLvcvB2OXjzftvl4O1y8HY5eAsQ
0i4Hb5eDt0q8y8Hb5eCtKP4uB2+Xg7fLwdvl4G1Z+i4Hb5eDt8vB2+Xg1WKtXQ7eLgdvl4O3
S4rYJUXscvB2OXi7HDzhIFQJAsJsbUwOeCbZOdpjNPUxD10eOg9wh22P3RoltE8aP6DveJNB
w9kjhdHhCi3+qY393A+dFv2dRjCIgtBO/ipcemXg4PC38fll9+y4NxyPPh11zw9Ho94I57Ta
0N+eeozk16dtmH/UtyQnWc56/x7NGdDPqunwVgyieqeHo9PxqP+f3qJAklVTpa0YFkXqXVxf
9XulVMIQvT1H9/Swf1FVXJjOt+EQVOsqvlGql3FU6/dVqBqsjAiKmNpg6gaD26O3ZUanG8iX
Qxc0yZ2sAvPQ5RN+EJp/vZpv3pR5KXi5iXn2+ojFWBOr/EXFEHJRFvpAYYYT2RQdc57Urejz
KbMUo4zjMu0KW9JSWppkwuD0T3JvMYhMo5rN25pnYCe3NDldj7rzZEtwc04hMd5L6SZGMjdJ
FFJg+qYYcoHRRbs/oTUChHB5YJMqRzE00lufYnTKV+O0DYnzQ85xjL2WX1NMdBYZxt7TaNAf
jqARxL93qM2wyTDaf+r5SvGx745RY9pV5ljlbqHD6c/yGV4uLGO+gqdYI+li3IK6c+eL7Qzh
bquy/BraAbnEjziPTEJXvvId2T6IeH/Fc3wnqDjyf1S8czvNijV38K/Pj75hqGdHFMfLA/Gl
0teb8epLvO5TvOhff3xrCIYO+xc4Qa+Yhhst8tkBWrHQpjTStJwJEAr9+EZlUU2Zi1QlaMLC
LYXSsvb+CmRD1dnCSuHAvqc8W+HFx7ZzW6yLyNvTm4ZlLq5EDvvdhrRHSYR3PCmW96pkcdqo
XgVbbN63g1KwDWpQbD0UWwfF3gVKVgiqWhrq3We0pozWCYO1n6QXk6GlRoXuXRwenfcvPkL/
slmsU1/9kr6QSLVk9YuIUJFgvA2BZkmoNWI1DPsm9kP8G0YZRVmhmJa3IjWYZixtao9wJksw
bKRWL1YRGlKTQfMf6MIo4ptW7xkaPJe3JTgU+d344xij2/ZCntT7IatoZZSnkeUSWaqQpe+J
LGuW/jSyUiIrFbLyPZFV05SeRlZLZLVCVr8nsq7Lz0DWSmStQtYKZPZdkE3JZE8j6yWyXiHr
T7fG+yFbuvQMrTNKZKNCNr4jslZ4R08hmyWyWSGbPz6yVSJbFbL1pNZ9d2QmldD23PRL/xXY
1ZQ1mWOz/wrsatpy5tjyW+nfu2JXU5c7x3567voRsKvpi8+xn56/fgTsagrz5tjaj4C96M4y
fYM/+1pa451ozXeitd6HVt4UL7yWlr0TrfxOtMrb0bZa1/1B74oOtDtZlHREAEH8rCMAWEcW
lzLlKeA1fb8HRpFOFXxLu85ErrYfZjxJ8jhbOJ5ecjgLC6ALHK1WjfI9sWn7IxDt7fIgs6ED
uqyalqm9inCeq17RKpphmuZbkSY8pcO+0e3WVPT/JxPlba7E80hmYh1Y1k3FYqYuv4Jo3mdR
WIreBsuyTGXhlOTrGLr01gSx4ZTGnLvgp7TnILcsxVBo02GdcmzPdhOlmchNXOFFEVsk41uz
zhe6UF6pDU88XnzpxfIFvWOmyOD7tgmz7h40PHvmBw9iF4qyuFBbxJmMjQ/2Ic14TBle4vDU
3ofajRWZhzwRyZehw6FH+09pvV7raMIIR8EncBOc+pN9kZ711U44iD2sFKIweGh9eBZRWRjT
JSYzcdS6Pc9+HK3mira3JmeqIhedX55Y+qnMBGl/O6D9OFX5+Ynhv9WV+5Wjdmz5qJ2K1ylH
ydz1h+1KENqHrC1qzotihsR069FUwi1pmawba9MOy2owJi2lHW7DYaJVWugtrCYKxUQj75eZ
ua8ino+9Iqcx8kD+No7S4m0WNiE1mGQYaktS5tt4e++CZUqWpX6BeOrSHOlnEjRkaa/YlJ8m
3KakIjrPV+zNZzdtjAR0dHnFrhIE3MveEcrld9ks9lCrCc8vcotfSMRMSyvejDCbtcvcMJgU
1lT8fz2ZbA6Otqc3TNlY2a5/x1Tmv7w8S1IYNrKdRTPf0dUxdWIbYjutDvhhSzXpPGJgZ2R9
4auf3UD3N1Mc+RUXo1Hv3eBkWWW0HR06WUKJfAlfUoP5kzSfFJm0b8KqKaQjV9eFN9mmt7Ux
s820faA8YWxq40A2D77ltb2cA02trFDaXO+6DVfzVAvx6pvIiQIoJlZ4FYciSTpKhQaRdKE6
Oj2lAychdkVguy5PtqQ2Jcl4hHqGfsZ2tEzUctjtXsMNt7FIERWJV3+0XkqlqMyqkg3IyRLH
Sui0Qz255YXEqqYhMZ39jG/idnG45BQlGNJ5DmLqRmGWREGAkh0Lv6M64om60NLeAUg3VRON
pWMDZab6TnlKm3JW54dLW0xusVexmLIuU7v3q9cALB+hEW3GxEAXb+qxHZqt3ohdlTUmox5N
Yz9qegYzzfs2XGBb2XBCEeJteYiFXshSnc2W+ffjVt+KG02qacxfeiGOoIwvR/3GIHLzgMOx
4N3bmlw2TGkN+XDu/r8Bh8oMaw2H0pJgPOoOydnkIWlc+lomzaCWfkS2wyk6K1PK462L+Rpm
01QkpWJef1cuxvfh4LzI7Elx8hEq7uUBmm7b+SP3yaaLMy4RmjX3wxYsVdH0uh/Ug03XlCym
m/MzibTEEicc/67mWb+A0FJMtSJslK9wTGEkwUiBkbb3ckJWyFwQFiajPBJHRmK+LlStFL+e
jxmasmShigg98d0pR/8kdKOvKXhJNBPY/wO+ByGn/sCQit4kyeFvseN3wshJ0r+JXkk4VQ6H
+iT/68uxaIaZv1cBp5MrjCjgqCjmM97Acdz4P+6uvbltJMf/v5+it26rYm/ZSr/Z1J23zrGd
jGv8OsuZy1Yqo6IkKuZGErWU5CTz6Q/oJkVKoi1RopK6mUdik8Cv2W8AjQZ68TBAHw8UDT+6
O5bH/X4euqAuFGmUdnsdubu5o6dUNClt4hQ7a5LbFpmPg4+t8PPQ6ubXrctPNQJo7fvPAID8
FKEvz8HpRfvm9qH99vb9zfnhf6axp6x5sXV3vQco0E8NYwUZoDWAxv0oPpUIHtVoufT4Cq3c
nVYyXNKWaNXutLD6+iu0endaT0i9QuvtTmt8LVdozc60jEplVmj93Wk5LLsrtIzWQCw8udob
OFB3JlaSro5Lxmsg9qhSq8TlU6kasdF+yWeUT6ZKxBx6u6RTyqdTNWLOcL9cJi6fUNWIhVcy
8ln5lKpGrKRcXQtZ+aSqRuwxujqrWPm0qkZsPLX6Gbx8WlUiFlTK1U7h5dOqGjEsBatDlJdP
q2rEwsrby8Tl06oasRK65DPKp1U1Ytj3V6cVL59W1YiNx1b3Hl4+rSoRSypFSXeXT6tqxOXd
XT6tqhHDNlHS3eXTqhqxkny16UT5tKpG7IH8sEpcPq2qERthfKsvLCgK0ziNiQKiZ37MUZXa
17ivgzrRLrxu2vAKliEJnSWafIxikhooMPpdt++lqsqn/YApSnGQVwDruUAnaBvfLxinuJNu
AlYWKbzzA0ElRzllc9CFgDEuev0PAtVy0+rn6mVd3KBWccs956S0gVF0MNJPk3FcEl1UIkq6
g8CG56MaaWvF0NxXagmD5RiePaAtwWB1Y3geXa4La7Acg5VhMMpMvRhGK7wFsooBayRQ2zhH
brZ2uR1d8FehW3dkB50NVZVV9oFL6nF5fkHQ/vYlA2Q5IGUuFjnre/sENNlyuymgzAFFX+8B
CccXCsQVkEyhkp6rpOftE5CzinXtFurq6b0ggXSrV5DEfLYwXHBXZ60prB61YDC8EVSGkVYj
+3jtth0t+nhaHURDd8v/7vLyg7SWwn0iQjVXp9EqoucQPVqG2MpP+fcACP8u15nbNRi2Adlk
DO0dKz0h6EJP1IDBBZfLU8diFJYXt0P3Xfw6u0P3UveCcRLmq2GtWBKEseUGL2KZHAvEhYLk
QIthluuC0dp48nkYQYswYQ4TltSsTixocn95PouCREFpWDIC+MIIqAXDV97yKifKez7sdPM6
LQbFrgvGKGPECzD5vpRmT+rC/lQXu4GNxF8WKcRz/WvySnRW+7dWLM6lWp4K0q0WQV9iP5et
FqzYz7VgCAyHXoaxItB0qXTN6xWqsSO7XMMuFxYEli8IrDjE6oLxlNLLK6aq2J51YBj+DEZJ
oxrXqJ1CNXZk97mWy/uYerYxed6YfKEx64HxuRJmGUZXa89aMIRQ/vI+oZ9p1K5r1GI1dmQv
2zj1s40p8sYU/T3AaMPp8sbgVWzPOjA8YejyXumVNypzWwMrbA07sxvhl9agtDFl3phyoTHr
gGENWP88tQxjqrRnTRh8brZbwihpVLchMK9QjV3ZPa2Wlz7zbGOqvDHVQmPWBKO55svygl+x
PevA8Eoa1X+mUd2GwDqFauzKrhVdXn39ZxtT542pFxqzHhjGOF0RJ4Nq7VkPhlndEIJnGtVt
CGyhGruxg+CoXmJfbEwvb0yvvwcYZbRZ3pY6uc7DVdApaU9jiu1ZB4bmii1P+85zCk/f5NWB
HwvVqQnGqGzAL1rI4xG5eX99mmYq2pbcV1Tyoo/Y5dzJ7ioafSEfr25+Pf1EDvKgRBWZiIJ/
/86o/Z8x+O/w8C85khHaW4P0ZqX4CkwvFo+x6yRdg3S2VHwlJls8lowfwPD/heKlj54CLyKd
rxRfgWlN8R5X6yrSWim+AhP5uw//FYtk2pe4ZI4nbXe14wqDd9/dtfAWMLqvNwhbOUjdgS+N
TZfztbJbhJZHNURDk+NCYGBgUMfwh0fu41486MfkXYTxlacR+a/P6U//bSOON6LpP358Odyu
tHcPd9nVU+c7WVr3KrTCE7BqXJyfnpHrsyb5DUMVigZt0EokSqL7hSU5v3jz/l2ThL2g2x52
25Pvk/6kjRd5mpnX/LBLuvb+Wa9GABidsOa+vXt3SobBCJOxk34SDMOvcfKlIpWgHCXy094T
3l3tuSEHHYvZbE8xXjeGRZ1BF6cXPC7zW0qNmkG4Rk2+4HZsvcvRJxqDaSx4Q29BLq1J2pLj
tmEDWbYxWUPb5sHFIKfTGLPbFSLv7sKnfHRZyhJz24jsNt19Z9bvQxOszUpcF4bn4cHKOoxC
engmnFW8XgzJNK6obwazcBrHeAHTRljF0cBh5atOx62z8bobZ2InDsnk4rf8Ms9GY93a03gY
eD0om2Er90DrxEFX3RWcCYZFnpJB8L1mNs9e/yqwXfGz07t9MvoM3RDW9ZDZngG1V7OegdNd
OLhGAxwmZIKtw8X8sNlmbJpNzK2UPvoaDQakE+b5Ksdhcow3xO37PeLZmwoLt3hbX6OpzVoL
S1nhRX5nv17ut63jM1xHMUNmfi1ok/fCWE1wNAaxbHTnlnwcSlUolG1PoCCp1mDvM+I8vMMA
2JbDTc4jcnk+sVcoOpjUyt5qz25V1YtkpPUiSJHYRkiCin0iacZQtc+Q+EZIfbZfJKGt/TBF
Qu+B3jAg/FMVCtDr2ALFBl/jlfVajUiejwGcMyS5EZLcL5JHfa+ApDZCwiTX+0TyJGdLs7vp
rlYTvZgnrjI13oZcjm5gE+iOh8vRDUpjGyxFNuDUKHQj43Ie0uBHFeIzakrdDTMvQ7nWwbU+
FJC6Sj1bMxS11qW1PhSptPcSit7YebV+NC3VizX0NnZXrR8NBpm/gQy0NYMAGUvCrv1wdkdC
mwMjmqA8UZZnAPPmzPMMiKM0+UMx0cA+8LjBlQTxOtA464F0CkT3iCQN6veABAL9HGUyD1uA
lzyLlbeotkz8aQ842t5zeH9+V57iTS00M4juiq9UqQYII/EICSCOr6JpeaqKH4nDqEYHw7WR
UXZgwHxBn8j93dkCwyhAB8D3N5cfMsVrmgSjibWNDW20hUatEFLgXZRliFlvXDuTssHKl5mm
3fqZtM+eYbp523qSDUyx2/3SfQxGmMrvRwAZ7S0fkFo3/qtoGLkkPlESdqdor3qNdmsL1Qft
sE4ITsWKs6V14kdfU5CCL0bpVfK7YDKJ0FYUDsJgEtYIwPyVM2sLcOoCj9mYCq1Tcn59CjMX
fkGbZ5Cg5DepGUR4K/7f1qXyt6gXxpmRxwaPmjwGsK1Cv9/fXmM0lVw66ObSQW/BbLZ3eG2v
hVjr5tlVi6SbzFGWW4louR2t52GYl/cjzGKC7YgaeBIM+5N58NPNqHiDSyOsTSBNbmNpevOU
Nuj4K9OsNjbRMazBhaw29lFqlzzcJySoK3iRdEGwtwm+luOiPRMfjeuekH5ouPSXZHwpqecr
0ByoybOo/ZwSYcMTUGLyfTyNh58TG0GNHAj+cqA9YTLhpRBobw9wSmLUC4yT2gdGPG54dfrb
h/lB0OQVBi/FUFzpEdH88GFnZq1xG/sZzJ6PY2AyjkZtHAfHUyAAiObx8TFpYcAsDM1oG/Gj
zTL9qUlGX5MIcduTKagDkxNMiGrDlM2fUGzxadtGonkKBieaov29E0/CEwbLzKzfh4EyfyuA
ejaFX04UvpzCIjRqT8Iu4sSjuN/PSbMHj/GgB3+f0D9fRTSz7jKrFSFnOJxxuUmftNMPsNkg
6+PnEm+VbcTvals7v6al/GWfnQV1q41dagxP8dLX4+N2BuZG0FIN6sHga6pRaLyyauzErq2O
uVsN6sEQ5dV4jrWsKjtD+AwX2N1qUg+GKMeoUpVdITym9a79WhMGXiDbsSo7QwhfrFntFrBw
O5ksVaQWCFkOUaUiO0NohvkTM1IUitsdEEJGqLP2XVzUpDsjzjtlXhJJXC74xj6AOC3fC59p
0ZI67YxgJIb4KavM7SjMnjvJJMAId3jY+te62A1agz6R/mwafis1QSnG5yYoeeSycS+YoGoD
4TaqQjDrYafNT++xL0fhdIBOcS5YMTlwoeTCXl3MqHnOmdGr9QQd0dyDAya1r31P+qbBtGyy
w5JQ3LWBKI1mCzQDwKdPMC82dhcMmeG43YmmIIJKq0nZtjzB8OIzNJulv9PagQS0KwYZOr+6
hg8G9sEg/9w1L0HBQzPj21ZukrLC3WNIol4bDwoG6HTzJfxum2t3RkGtp96v6fMF4mVnvS3I
mQ3uXSRPr7nvTCwZBuuZE3ej/qQxGY/Cz3Et5D520iJ51BsG4xqoNcWb40k8xAj197fXb1vk
+uGcHJwdEueVCVr2L8H0iFyOuo2d2TyBFvM+xv+0qV4PUq9VG6zZAx3vcDtaX6KZIE6C0edw
7h3ZtcPZWb6sQpiaPZqjeATLe5M26wOAJRw9wTOAZmqWnX/vbIz6ZjBcCHK7C59UODxzL5ib
cNqfkFfdcPz4qtDRLlEFkMwdHXdmVhKjYCFtM/0qcjDsTdzxAxH8cBtSxTSKrcuGHqPXGHrm
B3ELhp7a4Ty1iROZMLtwGOmxwrwNJt+HwxC2327ZvK1I7XO852gFFzIewGsrTmz8XlMflc1w
1NviLbPhM/AZ2lxgKLUfw8EYxje0jBPn7MuiQXdLJslNxtSPkiG6nTddsOR+0A0JWn6+b0nt
UaV1So3yUZO07d9twQ8OUWLCVD5B0n0k0XA8CDF4bxoTPrZMjX0gMRtfsYD0k3G4MXoVR8uf
hSMpX6wX7OqKu4GTJvXYmlpRNAZnYzFBDicy22VlFMKXnRhnNEcn8BN6RCaPMJBRmitIZ7Xh
gN4P680DMtHCvvTsc98GICYYJh4LdolVQCCbVCCB1d0apgl5SALcsQJMVIK9gjlDuvEMJlPv
xPIduapMst9SxSL71Vb5+F+z4XiSV2rP8MpQpv4fw6MTNcKfA++0vIM2ItLa+MZ29HmWyCK1
ozcJprygPmOicMZTmd6jAn373BhkzfXPBRXqxYG3AYlnjBVyLkf9uAkt6hoc92BQEWAiVabz
PV+Itd0pmF+lO9kPg/etudi2tQvvnuXlsthkGE2GwRQW1d9//307pozLeB5HV949jfu9w/vU
wb8wYzYigu7UnnlmmigftlzYXgrTpDq9zHuH8ub655511nxhzqwlEQ2qlRb+uulSgc7TTPnr
u1MZVX3c/wB4z+BAqDCtqjJlXJhUUa1fILYb9z8AXjD0tnxhxmxIxNHp2HtmmvgMNHmf5p7O
W9H7KH266SOaa58L7rm14Nk5swEJzFmbCGHddNmYTnlaybXdybUW24z7vcP7glbbraoyZVxS
Uurtazv5AfBM+2LNjNmISFFj8AJi6TSBvQeWc0wkvz09yIToGnYKjRB8TrUbl2uQewZopfG2
o+WUpwpOmpCtO0sSaLyiLuUSsbl8RIyS6SMq95P6MHTDB/UR7xq33NlQgQJv37nhuB2tZ4MO
WrV0DHrftN8kwWBAuKYLqumWDB4G91F+xtCJpsNg7BikporqGnmM9DO1fjaLeo6DmVqofYWH
eN/+aPfCbpq1M7WkFg2nlSgF5bgbLVDa81oYC5lXpQ0iYu3Dr4Zf4JciNekSLn1CX7ncoHis
Shrf/iD9CF3npzGJMlvFDy+MK/TvTTrTJHTTa27gfe4tOf4H8UH7IM458C/Lv6fMksGaj/kG
ZjZ/Fe5LpYWso0N4BpKbKZa38CAFMobZeFCYmrAdTY1nc2q7BqtGIzyTXod5jKfjweyzi+qx
lMwyCUvyV9bALk0arSfEXApIfPFtjA5qOcKLmTTlXqC0odb7st0ZDLowBS9vHi6uyNnp/eXV
1S25P705+4Vc3Z2tJC/dlRckZL/IexYk0WAQk/tgBPv3m6D7ZWCDhzwbK6I2EN+K6qOnqBcF
/U7bZQFvPZzeP1Si8RlDMeBpOOh3Fk+3q5EYtHqcxbNBz7UbXrFZrNc1NKsb2o3d+biPZ9Aw
WS5vSdDr4SCyGRzH40GUr5Sb04HcAV0yewonAVYyzTMHq1P4LezOYMl6PelEo9dPRu/MZHAN
mzMNgy8hfA+6UTwGU3sQjfTEHSqg9+z8+NsuoA4a9/29QnrMFKv2DoPdwOL325sLYO7HaV7v
LB1fGHw7od9k30qHSXJynJ2f1QxlBLqXzqGeOs4p5eAwY7d70DHnO7H4HO+7zFnGSdwJUYZM
nzToAit8ZJzUCuBTZlPERaPxDDbbu/gr9Nqb2XQKomwwIa/Tu7+vr24+tP7ZerhuUoo/3/3v
/Zsb/NnyuT/pfjFdbsM00FQR8iMwvv20BSHoSrDUdOzLQssVPmVd2+2OoDyMcPTul4tWk8Af
D5kLe5qU9a/bUGob6DeKg2lvGLhcr4OD+0PyP7Oo++U8mAYg43cfR/Eg/vw9W/dlg9K6EAz8
ZAzek2uFCSzfTWK4oq9BG1KU9Cz1EZHEJvk8sjGIJo9B4i5UTQq5aGvEERJ09U/Zpfrp9HuL
ohfZ5etbjNDdN+QgSv5NTtCpC3NWtzvBrAe/4oUWSg+xqQNiyz3dK6RvUEK7LLp93cR/xMMo
rS7hDdbblhyTeEJbDkAcSl+nzggwfnNRcOLEkF25uLVh3cSj46d4AJoxKBbu1lCG8sQaYmty
YRMPj8dQOCaiD5PjyRhPq8dBglvNwI6JlHVXLslxS4EJ0B18aec5h0/w3hA0wOh42B13BhTW
PPL4tbE7n+IC73eAMhk1m/Yvu4kckYv7+9t7WFSfoK978P0tfHd5XgenZpjQZvg1eELP+TFI
8RQg3A+X7VwmfBMHSQ/nf5Nc4FrWJK1r9EdKl6LgCRY7aybAg+hHeDq0bjPhzygJ5D0xL8n+
1es1m/aH1LEpBX47F6VyV0bSwfJJDz5gj4iKMVzTt0SsHQYUWVhOWt9HXRu6EbSSM/vJbgb+
7R5mutOOZENI8rcjXPSg3f8VJ//BJa8fRwm0rf0SjD53H8Pul6bzzLFptrNnLmITBsxuMHIw
hd0JRwgzlEzCbjxCW9IwSD5HI3ys508PGz+6FN/m9LkDyGk8TMP+nadbWOblNsICzJHz87v9
tR5mLShqoMOoa4eCnT2p/zjOnQ8MZJQknJJj5u/E41Flk2IFo3Aw3yqyj8NvUxbme7gacHJ3
bi0M9OFw2ovjMXoPTnuZtegAfoYfT/CG/uvRbNgJk0MynGE6xXBJNasVyAgMrnUlJX33gfQH
6EsOi+4YWrCou1kN1OUdwvvTLsPjEekGI6wtDCIYh7Nwz6iG2huFY9h3+3EyJOPH77h5HFt8
vEGdI9tsSXlsFFovhlAY02IySIJhMxVt49nnR7s/D0O8wNjYktgTeFfu4wg00Ek0/ES+BsnI
Nhram9vo6ggCwSj8Ng67aIXDRZrEsykoIM7QdmSvR4Y4vVsPpw8X7fuL0/N/4hyYJSO8Ov5T
ivIpKjp/sqJ8au1If7aiMALjn68oaX27/mxFKSPkn68oT6GKhSXNIyZbne2IXAejWT+wcYcT
cnmOIQ98kCTOHqNx+qvw68cxGiNfOZyHePIYdQJyc3pzThg319Ebwo7Mb8Qcd7KAlNvy+AoN
ZI4HyAjQHZHW1Rma/EAvJ+gwAG80+RVfjPGo1T1SjB+R29s3c4p9YjJr6viUburpW4dciYRJ
jTruQonFgMub0nCKtyTxSwMYinmFtiMT1ngNYvE0ThYapxqJr9LvBiXQSmBNwjWaDqrRSN/J
mkiDRmpXaJMIXo1G+Zj6G8PGfY16eHPCbPZOe+jPi7fXMDjtYpVlZTLP4FjMyAq96lejQZ/V
nCYfo7ISiW9QFc2HqDN8AineK1FMm8UurUYO/9hMRPj96QGLG2nFT9iMiDM8uU8bdYlMVCYT
HEOJxmP0ALEhY3I1ds1LZVBcbKFsbg2X2YKakE7Qc8cVky2pBWgLeN6VXa5m9m7aGJXb/2Pv
Wp/TRpb99/0r5iQfYlcZWTOj973n1GJwNuz6wQnO49StFFdIsq01SCwCx96//nb3SCAwxgaE
41RdV8JDdP80M5pXT7+oKCjKvVk+e77xqkZxadVQETCLv1r+1VFfmZcDwUo4AUEC4zIXt2H6
m51gGbaLeT4/dFqHnU6LBdf+qGjVsh3EepSwSsFTOh5fR6MEBNZGHqzsKE3I7k1J7h67lZqN
5wn14SjuM2EfMKFzvl85julKHP3RXyBZH/81oUOfkdAxunAnHkB7/A5Sd8b2MvzyaxIMtCAd
7JO2runfxiHraLDGkJp8L/Rvo8GvIHtf+2Mie+G7WC5lRe/HPZAwPfY+voNd0Wmzdc6OJlmu
gQk3pLaFRM/n8STx2Kckzu3ULj6dHV7U28WzLtQOXLMqYJQOrjLEiD6j3HVdzAJiwFbqjv0B
W4nk3k+ym3v23wP/7uZXbFZoDmq6f1WNYnHU+fijIEEva/W+2LWfR2Tr6G2RE40uAy4wuvbH
9w38wN7AjjUJ/VH4hu39r/9uH+03/WGGoxQHZ5GV5EVAXY6iUg4Kb92R/32QhrCkwQc0iIoA
bvSD4BzOjRkcPCxXv7vzWOP8FD/ADBQPMadGzr0lm+GYJsY+6EiPnaWs/rGBTzaAFs3m7FLW
o7QEunWVixKns6K0zmt4egVjkpqmaIa93n0+JXxJ0/A6RddnuEPU1/ZfAtkmE6ZF5GMAhNl1
AKLWJbtPJwzlHL/fv8/tMlEFUQzxIYVg/MdOIV2OYZ73JokKPQrAXTXR7OPFUkyGfXpK/mSc
KvU0pX05Z3nz0GP7L7o7nWVmIGjGl/dkx4Fay2LP8xruDDdG84pZM+LqoneHQUwPnr6Roddi
196cUQj0Rsr6sOHyYBeISmiGGW1Yo35WcpKdVxluzAYLqDNl4zoL76GJ46DEkcc9nR1tbshk
kLCFpZlbnWZMm5E66Oee/eljTkNigfae49qM1rSoioq2G2c+GoZlk8vLOIjRPHl25PvgIH5L
ZsvGUhb7h0EYp11VuG6hhYCrt44TwU3MrdkcGlnja5hDo1EtiYPbS9LvwJ5BX5fK5agLjjjG
Mp+ab7Q/nh+i7uYsGmNElakOSWqmJozajaid1dutSkFMXVf7QgKZJjzbC2b7FEtho10ojD5a
Eqvi5ga6dCP3khosVoHVSnE1pCZ47cZZqEvVeMLGlJA53iwb3BP10yoCcBFAyKdyJza+FTZG
ZN/y8d+M88oAHEsaaAJNVZhF7pWaDivzNVRqD8PoSnn64W9PCpQq95kpPNNAMi48aXimtSMw
w8Ekg4+CPf78G9MsVTsCQ++PHCx6VkeE7qdZtZsqEWzhlBAejE1ggY25uaLzVQLhmBjhJL7q
lSrxW3zlw7OdSc6PjktMxKiXK1UxnEvJOAhufnBidCAYnNxYWbnt2G0Okyex314uqc7neITb
TfZ+kqiEao9WS2i6JkrV2h2wMPCsKQd+UOW8Q4iVla4AQlLQxvjuqlceGrC3KmpY9iZ4tHKG
Zsx1hl3BmuTam8MuXQL4qiWgAgDLxMijBDDXIR6p2jr9g8O/cmVf8FaOxIVteqvHutLK6aka
EBWBJDbmZurZseAsJeLXExiaj9eRww6Nl+fw3SE73MDwawp5sdZcqlqvnL0qQBCk3v8TPSZ/
P42DER5CnjbE16+45qoqLlgawRZacyoEMDjFaL65Fw+MmjBzygaEFhdoD532/dFlHxMKnx1f
TDkMbSNKR8eT7Xa7za6iJMLgWQtFEDDniM3pXdoiIv1RpwnPakCDk3J4KpfDRZOuTZlcnRcl
O223j3fLxbl8TuYmYxsOoaNVVeek1fZK1nAgmtUABfYa3IUPXy4u/sP2Crm/kPYpWNI/hWnt
sz3MQjReOHTMd+T72o+6m3TQW+o67Ace+9A8aUxP6aZtrsxEKUPz1mxKn3snzK6fgUz+VRMm
RotLgnJVYd9bP2l/qK+q304hLYGJ0k7q7aPZLPzAGFIXWzDYBuqUBn7g6ILz7vX3LB4sDzS7
HY9rYWTMOIoiYkKDQJByOlFfGbKM0GglUP6XzO9fpaN4fD1g7wboLTaK+t3r8budgLm6yoa9
CHb9Hc8bMVJMkelH/Vsy9CuBMBwUVOcg+MZVqhTMtvliY/PlleOPVa4CCNdFHe/nU4xHyG4H
d9DBJLvNt3NnrUbRy8t7EAPmKtgal85YKkXigpKMf37fOgfiTxnwnES3EZ7gj/3a/KhDD2JZ
BSceJkJTOrqByWDPYGZudw5F2XX5f/K8tN4fR82DPB+sd3r+6Rsetuh3ln4ALwZDZyR+wMWL
QNsm+gzhyXfqqTswgFD+NQ9Zt+eDIWku8NU/fX2MT2zPKLiDbsoDVCGROxE1HX0tzslRxQqd
CbUeGLNhMHWzr4DdsPSZf2X9AsOqJBkstTDYO7ACCAxqovxNyv6WhXX2IVX0kGo9523JX/IO
sHjBuIxFQOxFoJe5w//nk0md4jYN4/jO6GaDcipPHTbQ6D10NEHX/2xc7uD0iG10/51uG/Sd
YXJd4+iti5HG1ZDHh8tr32OYmJrwkDGoZy5hFZtCrQpO6WKimmaHfzll3zkapQ18nG9nM18u
jRqs87ffS/tBxn67n4xu0moxTAcHG699wWKHs4qgyq/ZEbals56PyVruYSjA7gLDLqPt6Awb
z7PNgx95B8dED4xud4iOxV3SGN2XtDrHhaUuPAY0Gxz6FECnZKj1jmK5+MG7XWKiARCq7bbG
zFvrJYANmwICwyZ2AAtz/t79O02iOfcRNIxGE+gpJVKwvRp393eDZUl0NNm6wpOs926noDYs
KhjiLZ+zW4PjO1pVjv7TZBfpJLhu+09P1rw8WcudQwsNo4agpewwIM8Z1CHhhzty6QmjMTXD
QSHc4UXYtEbTxCMVIGA4OS5RSXzUn0TjNEVr3eLg8EOjVZKn8JxrOyYTpiAMs9ppnuWJPMbR
gH3ELQDXQGLV5OE6tOpdLLzL6TtG6FcvOUX+9svsJg5sgdY5Z9mcyXXQeP8UCfyRqlZQCgWk
KuVuTI/x159xvCKNbThgHDi4DLaLior8IO0ZvwrqLwOsSDfMhh4RqqSUDKQBWJPQodTHsHiZ
xi7Q/CdCW72McfZnfHkJ2x5tV2gqWGqPk01M6QhF9ZZ1yUyBIVx7fFsaS8cjzPFTt3sumUUm
+ZxCWiyQybXJbAPXwcBYdcfn0DiUBKWVXMZJBL9TN883eTDUtalVxwbELubU+BInvTQJ2RfL
cgUpR8ISg9iKwXUwqvpZNP4zGldEaesW6jypX8dDP1jMBLIxLZf4WD/EHf/Om3OhpuV0mKdP
VrMMmqZVwSnISDHn/JyXSmom27vBo7r+/makLmrNi/L499GIs8KnHo/eLehg5sbkkjKxlMlF
mVzC7kUzNiY3TD5ry4soPr0alcmFPjfI1iU3BdpZlgsj58jFVuQgEVvlfnBDLGUO052v7QYc
jjnjUGFbOfUqzB0Ngz7ciNS2jFkXoFgMnLWLVe6sxVkr/Cf9yvb0/a3ZHBNFxZxNzSLh3BzF
nflKr83gUlJqoiQbU5xQqOazIDTr0Dk6yTTlihaTIBUm3zPmUcz+sT0fF1jhq/jKp4xmpdnk
N3WNSd2+25weBCBeosepyVAT17zV5gbELk5Tx816gzWPjz795rHYNNCukqKMnDa8jUihC/AF
UltOSdenMyxjkQ6KY5t3OWX+jeJUXk3tl0kwrBjEpJAxcyBSn5aYPu8YwKbIy2WAO+nk7PBp
Z8wGCLkYoxu6/ngUX9WC4cQrJ9WiGDRhHFBs12Ac38bje/Qla7Q/ZdViKBvJMAh7IKKqNw+D
QPdZh0SqDB2X/SvKocOO0PQ8H2B7M7suS9NrUhP7u0Y1DdScDNJsjKKOUrLtrfG7JdFowo8H
3fw80CNi/NbdhtbWMaTP7L6lh5BE35mPhtOBUvUWswaqBQuhW+EXQTx3hOgYhqXqk+H0/rBx
niRwdeluXqasvKhUCyZ1EwXuxoePzePP7E0wSrNuFLxRQZNyP2cmpGRXaZSxXtRPv9OZZ6Fz
hhUoze9FKfZ2BzxDth3UGmPV+t2RP5yF9QkRCtfGQnMPw7WQtblJHjt9Zu0AyDVQ4VXUNZwM
BvfdbDzQ9Af1Fes35C7Ap+gGp/PCh+j8ATpfu+i7AH8IJh6A6T8ErNSopo7GhA/R5SK6cNdv
1B2A1ydhnLLjuwC6NZ72cEtF+8qHQ8lIrrHPPsYBbnVT9t4PgmuMg4vWnGbNdX6pCmdaV5fj
sZAfhdmQWx6GwFThOMm597SOsSGg0kmIftj327KhTwiIJadRGPsXo/iOMhOnywvfu8fAbsmE
dXyMKwlSUYKllzV4sXaJCEMKD2ryGh2o6kC1VJbK5fXahEdwPEXzQ+4YzmGQGcJwWADzXrBV
6XeDKk1cEBUqiWOtTr2dtMuuowdsPLrHVbBw54XdXDTNblkhCmzuYe8DwixTg6GD+pbRZLBV
BXcCaroo86zXKzbhsRzM/5aR4wNu7ztFFMQ2Om/ONd4apLYl5kibaRI991eHo9T7n1OUf6n4
5+2Tmnx2Yx6wj2mPfUjTy/Gydt0tumvhknraarbYSZoOeyq97qJ345qkFrcxuE39pFNHt9K/
ummWYXrm5N0sKmLBCj9vz2cLtLvLkrBL69fsE0b0myQqQecsWTc773RYu3FaYOmevhMs2xbo
41HvtD60pyfJhsYNTZfrETkOyUBPaYC4vgWHKwVarA7iIaxxp2kPYxu32rfWOgSkfc1wiOAP
LMW6wCcDgz4kUZ9iwcz3lY14LBfNr56sm7kNhyPwwFjFpPTIO3wAW5wAU7QAM5bqNvZhkhoe
xvjPolwBGWW87UUwRYbRcBShxB9q7NMwRNH/Pp2MWBaM4uGYkrxgHAW4AwqyCrVwsE8iPDS4
jmear9dWHlPnOk4HT7WosQ2DiwFvn2Jwt2AQNtrufxVmoS/5PLVFFutSSQMFVPJuD0pGVhht
rDB5Iq3w3ii6Jdcu3RQO83sxc/erRjFIlfKkAb+7DYfp6GZeUgwaMiWdK9n+5vQWpawi+txo
m11Bp/3u309ZpM65vU/Jlq/TaUa6CrgdCsfzpL5dbsPh2hjrYZoRfnQ3Gj5IBr8WIddN1F3O
E3azbUmxnfBkM/D6fhJ11bFPfrQKV7WgZGFfBZ8QOupKh6nv+eNBFz/kXINh1VxSt5RdhQF7
umOKD4PKChrlHvuMCkfNcrIiWpGJRneyUK0qethK/gm7Z3YR+YMXAAahAs0biQS6WjpRKfB8
kHgp7bpKPIi5PTDiYm8S3ESYc4Lrf8wiHVYLZJmonHxyZRXbcNiG/Yy9jDS34XApszv6Afzl
4ZvG/80+n9TPWCc/tLvlmrMpuZACZ79mo9H2WB01AGSh3Gi0mkywvYtGu9aPb6L9LRgMEnaW
MkjF8H4UR0kI1f6Ii39uCVwpAjQKWqkH46EHgkjRiTJcyi7jqwk+gr0eBv2W4tDkFTBKnB2/
sXE8DMplnqou0HFb35xcRVV8shfp23BIB6uuilSkmMQwmjAc+3kSQTwg3oLBNDDO5HSyD5Os
i1HN+7jRXjLjr01vkdZ3Sh9Ew+ut6ByB+Wr6cQ8pvCKNy94gTQ7TLG9M2KofCmN/SybXwpr2
YMXwk64f3nrsSKtrF9opvJ5pDK74SQAw6FmuwbDDXLCw6QbJBxV4U/s+c78cEm23yAbnBkXp
jJLb7Hs8DqCy5/CF3XboG1MXSWryxz6AXlfDKzm6Bg2G/ax7laUgALZPOuy3zvlcMKo1KQ1K
HKtpGqu3Ww2KvUx/RbDMsr3GutQw2MvUn48/dlrnZx4DOcTUdW5sQmlxHHrF/R67/tJ/v8wK
4ugoAT0s4Pz1H1hA18H4/A8LOH/9xxUQdg4YzPjx70LHbEm5TgR2R6dtldCLkkRkHgxZbVNi
Bw9sZsSt8xr1x7czx0NgEcZ2LNKSeSZgHOaoxWmdU7/Xlv9VwWmYGDQgp4bCrfu7qaOBNV6b
Hbu9xUBSD/rRWqQ22ozkhcV5xKNsIHHg91VBMIvxVgyWiceZcwzNqB+T0fMFLIEe25TYFpjc
co745KLDpn9bELuu8bABOVaM2/Cfb0TqWI47VwSGGTnvgC+MR3nojtxjDkaFXQGja7r2ImMb
xl6MhuYqifFcvdekt5TP3Tx90YOnHrKlJlifgQtzSfOKJV15LVJXPmhQf9SLxyoqyVwHXo9Y
kAkUUeIkV35CtJv3NiKVEgP3t86pnfRn/WCj7M2GcYK+jUWGxQMWhVcRO2DX8dX1Afu8p+v7
qHX6uIfvHXotRvMBa6qfT8s7it0Bg0hs5cD8YBqC7gGw5A+A++kVTT8ELAmYvwSwZU6bQqwC
ftgUPwrYJidyApargOWrAXYlBpImYGNFd5PGawG2dYfzHNgsA/cxhkAJ2Hw1wELgkQcBW6se
nvVqgKWlFw/PXgVsvxpgw3WLSchZBey8GmBLOsWQdld1N/fVAMNf0d38VcD1VwPsCl3PgXur
gI9eC7CjW0bx8IJV3a3xaoCFLgvgcBVw89UAS0MUQzpaBXz8aoANcqUl4MtVwO9fDbBFJ6UI
zCvdxu4O2LamwPznAHb1YtrEPGo/AbCrWzwf0lz+HMBCR4GagFdtY18RsDTMoinMnwPYcIql
iVs/B7AlzHz55/bPAYy7wm90DjJOEb7IlJx569E4Ap3MgUZnSy/W/sV0T6jXX0oUdMIGFJwt
vUgMXL2W2FxKcwoUki29SAxSvZbZLKGADbb0IjEY6nXKZqEWxiYKky29SAymei2zkd0uUFhs
6UVisNRriY2TyxdQ2GzpRWKw1WuZzUQdBlA4bOlFYnDUa4lNkG4GKFy29CIxuOq1zEYu5/iI
dLb8qnpmev5WYpV6QcTZ8quKJ3/qvMxqctURuWDLryoekb+VWA1dqCpxyZZfVTwyfyuzmkI1
IjfY8quKx8jfSqzmFL/cdcpXFY+Zv5VZTTE7kV/5x8I0ibQqOB1H5jkhu+n3BC0ws+lcsyYV
18lE5ab+voPGCCH74I8ZfGFBnxLK3Ooanx4Xw1yiVcHJOQY2e9+pNdCSyMNIGpcZe+dfZu/K
joVoDIW2RiW/yO14TQt1M4yd+rD3nSZUdTzuWJ40+AaEjsCBe9Q677DjZpOh16PSzUPlLRWC
7fdJUhOw4Oq58Xc2769fDYYr8XwR2eMEQ1UpPyv0JvRv/biPz1zbkFqovOLqxrXxKIJGb06U
u2fEMG0WGpagxi/ws6iGNgEYLFDl04KF6E1YENfw2lv+5kWgMUfJN/b27VsWjmuUggw/Z2gK
g0rQSRKP6WqNbJe/x/0+y6KIRaMR9JxBlGWYLHdXcBKD7n5jh3NVOxxe+0nYjwg+OwzSJJsM
olHNRyvfST+kB3QVwZ0LwiDq97PaIM7QrIe6/ErE4Si9jcNoxF9fOYTBzf8vx6wchonOVxuU
4xLt33LCncGZtrtZK70InK2j5+Gz4fzR1QRVtxnrp8lVhOE1/SQPVTi+3zmsQzEQfhJYQ5eo
zY9Hf3nwACiMcJgO/DhR69Gyrh4XGbQy/Bjos8gxFaOZ3MI8degZ1Pfvu3HWHadDDFjgsbcm
bEr87BrWzbcW+3UBM+eooVEk/VTrTTL1oZjWnZe+i5R4ElncZRQN0lu/j3dLb7ziMt4wViED
8jJUx29IXO7Sy24BEUL5Ruk9Bn4gLAabr+CmiD6KT2qGWjWMZds4Ky8uvv/H3JP2to1k+T2/
gov5kARNu+tiHcJsz9px0ujtzoEc6BkEgZaiKFtjydJKctLZX7/1ikcxZrFIhyUjRsdwS3yv
6t1HHcy1inwbejGT5gYzqLhRiTQ0FmkuYG/ck1mfF93nq0W18+n7n1eCfPv8i+XNUivVPMzz
AplLyeH0ZP3Cb50zT+7xAMbIJMd/Q5CtwelHPPTLBN4dr7/EE3s69B7fa+PT37/QeSLw7/YG
7huPihvldI613uy0YhGF5O/Rk0X5I8ks0dW8rnMj+1FO5vqjpw+AmJv3df65W+p8FnYXw/6V
cl9ciR5u7T3Z3Ky+mt20sA8vEfw6JAYpoYz1E6dYRZuEd87jBaaWNvMRKfYIPT06XskkWIwf
LxYSNRETzlqI5UMhVlTC1sS/JP95vZ5Ez8Clacx//vRP24GrPYoOdPAFlOXfvGE6JCKBqOl6
7XS435QvN4lui/8rron+sjxcRebVNnvwfrA5brP9asu/I2DCSQI7Sq50nDGV3ROciKeRkcGl
xmScr66nzHnxLTgyTCmXkTlIFK3yxSE8JokVSsxN0HAG7EV9k3ZmsERbXYSflC0T0JjV5vKy
Suj/vZkFxkKQuXyywPI+X8MrwHZfweYzePnbfpt+uSnqSXNRxP42u4JjvXmk8RQ74xo3IATC
ttZqdYAD7dc3G/08PFBe3GwOZzzWAUKnYo+L59LVCu7c0n+Zq7N/hvPCHzGc4tI523p5Y07R
GHXRwjnc7iNKGoAvLG6b4M/yAiFsq6xwNmDeXS+NVRQPwR/1wLry0pHrzeqr/kqPWOY5La2U
OlEWZLTsAmFRAvYDBdKAsNi0NrHxFAbCkjAhwlEWFps0yxRjKQyDRUkaUANCYlOE4/EUhsIi
aHEnWxjKgmKjmMKuxpEUBsJCEhosQoXGps1YjqcwDBYphAxHWVBsjArzFuZxFAbCwhRW4SgL
ik0XwQEoDIQlQTxYhAqMjSNlM59tmW6daEoi08irsD4hhD7tygPxsbBR0/Yeyf1QWLjSHvhW
56fzj4TiT5Ni8chcyVMd5BXJ9z+fJFbTxks1LDZlztuN5WAQLAKZA4qBKAuMjXI8OjsOhYVJ
isNRFgRbaQwJGIN97VX+V57dasoe/7yfLW9+Xm/mW7i47/HdD6KT2We44nvyGbo3mFA2N3/o
n33x0dkLti8/Q2iWIbrPEFoi9HjIpEiASUkkuZmAQBh1TArrSeGlHDQploSdFOqaFDeTGsgp
HkJ8egbFBPR/dycFPbqSU4PFR3/ESbGQ4tMaLzziGzypEDoVmlNshE6l2XY5+ePVP9/96937
l5NBLJA/IAv4D6XBxvGzU53OMSjyzBx12pbQvj4tQa0+7Xg0FYtGyK3Skjd/vj1/NUhLRJAw
FVhLBAphKOcf3g1iAVcPOZoIGoJJcnbe4S7lPpODGT4m2pXvnZzM89VqupvdDhpwjB+oBnyx
/EuDv7z47TW8G3fQsGNiVTVstpvCku8KrioeNOgI/aoHrf44WezSdT67XSzy3aDBRwRCo9zw
CnKM6DDdFj+gM5EjnEnx8tUZ2BRMhGz1L57DLE5yFOOYxNfa2mKdnOt/RP+j+h+Ld/Adj2Wc
rlf7xZdBsxzjhysl2eWXtytzx/iQsIfhihk0rgYLh4WLJFBfLBi2SjQjPPYdBcKgQDg/O2e4
UCAWg+qw+FrgWJBY0FiwWCSx4LEQsVCxOIvFeSyexeIiFs9j8SKWKJbPYvk8li9idR6rZ7G6
iNXzWL2Iz2h8xuKzJD7j8dmz+OwiPhfxuYzPVXyh4uck1r6DxatCc4cqZoCk9dmbD4P8hxyb
+tzHWckAYX8oYWqEddeEnQ0kTI0IcvVgz9CLYYONTdXuNViIYNY7WOVEFG606r/bsQXCQjEf
35o6ikxC2OwZ4sMGG5FgbBaTV3azq9kziN///dWHP/745dmdzwdNZYRfhKksSXZSbbCtplFt
7zyBLwemtGpEJn1/YY/1mfcQNty5/YCDhWDj0MFICA9Nh4UDSkLI7ByhYYOF8NBs6GAhXI8Y
OtgI11MPliA8aDAaIqq+wAMVZGyGdy/KQtQ5t5/zfbqYDRpvRPLuiBjkeyJGGcSZUISOXKMN
hkUiIYPVW2GxwWsizNrgNnpCufQ3UbGU7T2zgXBghsbu2wqHJaGYBuNwUGyccGL3JoKtaePM
7+yFoFw8ja6X5q3cs6/R++dvX0b75eVNugqMRiQU8dH9iFBYmHlzSBg+B8YGB1lG62UoLJLC
4cpQlAXFJhNzycZICgNh4TIJZrdhsUmUmHtwxlEYCotAIpgGBMaGFeejNSEQFiIVDuZRAmH7
vTjqZE7/TqLzzeYQvf79P7o+LsdWSGE0cu9wMCzwdrhAe2GDYyNYiNHZYygsFIWLZ6GxSfOC
7gIb1BIni3S1gnW/k8tdur1aZvs7qQkjsnu3JxEPgJliHEAqgbAQFlAaYbC93wGCr/A6K7bd
5VF0kX7Oo/+GFxVHf5/rv//9X7t8fpUeTrPN+pdHH+HpT9HLdHdtDkJ/3WdaUHCHxlSXiLf7
wxSOHEdPOJvpaRHBIkrgL4rJ0yg1b6HUhWR1l9HpI3jTbrRNd+a6jfoqg9NH1QCAvBxkD/Dl
PZmn1UQuaqbXT601qBZPaq9MgqxYzx5eNhzpZzUHtnBtzr5JjX6KsxM91W6aNDWGhnmeVq+W
Or2DghI/iooNLhTfwmp/ThNU0RtH2DItujNTeBRT56OPLs5e/fr87SR6++HVq99e/RqdvYve
vn79/vTRh5sVaAlceQMvYt7d3twAF7WJpdHn5e5wm640J+EWpjw2rwYtz/Zlqa4ao32+W260
pUFfYJWv94V2acLgDoAvu6XZ7Pzs5et3j7Sy7Zfr5SrdRV+0GV+VaLabgxb0Us/+qx7mOi+G
KAeMbm9mOpaZF9SBXW9uD3pWi+Vu/cXMNd/nh9NHj7LDbnWSRTebLxqgpkabJCCFY496xPRQ
kzjfLOurrLT5cE5xHULKd2+aA4nfuhnKerarE3oqOROwSXa/ya4nNez/HArTOgGMj+Ec463R
8s1sv1nlB2DiASC0MkbvXk/P3108e/3yzdn7Y2KFBBcpW1EeDl/ZXYoR7qMYsNBGqtXGkt/M
QRO1pMALVbcYjAJUpNEy0IBJa95kwLwDYaHkGx4mg4n4TkCJCeOkAUha8+7V03BYqMAeLB4i
vheQIGkPUmlA2pq3GjDvQFgItk2QNhYPEd8LmKCE0wYgvztvzAfMOxAWrLDsxuIh4t6ARVT8
YLzbdjmfwmuB/lNHScFl9WX1esQv6SG7mm8uK3Rx9Oa3C/CNLEGPPsJAEKHhQrorc/OB/iaF
Vy+dVl++q53mEyl1AOVyhhCKZsnTaHMTLeaRjD6SCZmgTw4IHGUVAKueV9FHpp/HirohSA2S
oAoGo+ij1EAEKRcQURGL9Jzqx0n0EaMJ7poUbk0KJ5oKpEdQzA3C2yCacDxJJriDjAoA3rRc
QihgFZ3gxE06PNwahqCCX9JJuR5HVSCLeiCCo49KT81Nvot+UnCsU4zzCkLWEFRDED0IcdOS
R0l7FKZhuOaAkxauM5mKlEUNogVDPaLU02iNwjVI0kk+0NoCMUqMJ/wecqn0mHdoTJtl1Gix
ZrPokGXeGoX6JIkcWkn9qo/mDoukhSjxhBDRYzBC1UDMWAybYNohTVEDkRqoT5qoPbkeaeK2
NKkAyyRuy0Qu+dPSieEO+omDaZX8adLhkvTMGs8zXFpY5xjtaTFSCQY5rYxrwWjdzOvnmZe9
TT3mtUwYyAQooR2KXNM+r0GEdX0QxJJTJAiDmwSLjBx+T3W2PT0s17kuUSZ3c/MnOmrpgSGd
hvfXQe2rH9e1xmWqaz9d8hRwx8buUidW++06+jBZ+G0l3QySNYMsh2rv0BUeaiCRVUCJ8Q9s
kjgF0bB2XEOQHqVSLZ1KKmMXHSCzNkhh6jAQcZLDXQ4i6bP1Wq+I5UBh7J1hyGEjiT//IIs2
RCkb1gVSE0PriXEjGjpJnDA8akch7nXEyOGGeS2ZDh7bgGrnNdyh1rrJe5jcjnVc+FOdWssy
WoN4I2oDZGZpqWwGddhZHR4hHy9gBPLGR9yyGIH9iQ5pUy8SL/WiDaA8k9KU10pM6oxNontP
S9IyAJOuRLqtlLIIEF3DuGQvhde+bMpWi16XCUaOwskwCIyoGRgV9hkKjxbfPOyPcBGpvRev
o6LiPvk1aFa1OJSf6IZTsTOTlcfvCL5Sh3NzIoW1eKxUmRhKdwh2VizIr8nIVXthRLxZu1Xm
BFsYWtZGokPRXJPzK5or0cMo8WV6qFFRWRBRVlSig560PQwuTE2H8w5y6sjMUwuE/Xwj7aiJ
ceJJQ5sFIrcgvPCa/flbYxhRKF5HbHZVFRhqV6inVZeLSrTRJXURhgnyF9S0Dk3UDkL6eObQ
AahDi1RDdUQOBwegFK2VrcgYtQJSgo+Vjx4L+8B8FEMd7U2Tam0k1lZIjzq2EyVMKtVCXTVL
DaSsEpNSufQ0uwJAOy3FtDJLTDskLx1AuEyZeEdF7WjbUFIVrsQ5ELeWKawFUNoIPKUWaJ8O
l8cdSceOhN2lY4lDxyjr6aLUXtKqGOW+sOl2X7TUMcw6RFjrsmoAGRXTFsAb0mASFsqPJY3j
YB9q8bQnpXToOasNqqN1iJQrQ2A9XrsWRyItDCn7el2e3uFbWJFVJJ3NMFdIZd4UATtajpiZ
7A/3Z3/WgTExtBs0VxaozP8629p1tKO2IcxUUVZi4WwiuYpxnPhKHhO62yB9RY8DpGo9aZ4P
7olh01zgJgt2u9Z59M3jfdm8I0NIkp7YV4eJxAon8SkBsq3axjBVZimd8jRVnJ5dvQqCubeM
gUzVwS9eN/hIB5fbXWTMe7hWG5utxjHn/uBf6xm1IY/3+JzaT+WW0aInUayVM7VMEFUQJ6zL
4Bz5gii40OkK7LKINWzRpzvtwhwLr/9wxzRR+gK3TH2VIBaqiGzYnZq7moBY9pg3tmZkI4rs
qQRdPJe1eXfpke0DWqB6oaCrfnTouOzpa9U1TW51XAqfpCLiqINk2dnVtVpfD0XmFqpsVImO
PhVxrJJi5V2Ti0jNhLmtOhWpQ3iHV0lcXkX5l+ZcBaFilWSHR1bVI6PMISMlfQVuo79rW+na
VMruCHHyG+oJ2gwrBPV0xZ2+mKAerrXtgaA+rlmdm6UWqlhrppNOd2eraWqheE9Hpd3qIEgO
9PqswW3lbdzWDSJsV4JxuURNcFeDyLHiCh0VWOyQHUZU+zlu14JhXd9jQ7i2oawxOeYXq9UE
ZWEqCRHaIaJaQjm2UH0SsiEpt0DCn9E6Ft6xX6oOPcBemTpjGKn2HSQd6/ueIEYILi0Wq64F
5XZmR8yOAl826Jplj3TbzXli+iDcqOtwbYVOiDdTbftUAjsEPEmnaxsCNEE8lYdbUtAEMZLq
KKQsr7PEAlHvwkktVIIsCGvIpyyLOWL8eEX3kbAPbIEQytt9RU6S461zHwv7wC4DocKfH9eu
Zd6A8XkjbqOm3ZxE/RHGenFqR2GlN8Id3QKvO2KVO+rY4NBuLBLmizSQcaTfZBzM67p0BuzI
NxirKmzZ4SQdvp9VzquDFFv9Mm6BeNVqccZa1+o1YT0OzxFloANSa0+p0ALBLbTHMpcjYR/q
H5jPwbfWOUnCymy+q0NkywabLEK7ozvAIZfoknKbobxPuOdVuO/QxbqpsLCpIsfVrsy+pXFi
lZH3WJbDfjktGUc6yzQHkDcz4BF2McFb0TS3v6Y2Mef+vWMd7C5LSHeV33BJjZ2QotyDQtwb
V5obC1Ib6EXPXlgH60RPJUQcDlOw0se4sxDNb0cqJnoqSNvVttFD9O1eqbOdJLNAvh2BTYJI
Y3LfsSdUVFtYunIxW3ItrIjK/g3tLKCca/lEkr4A0u4ek54dIM5EVnpbYI18mTdoKltgcLG9
X8MbFZQs2+FdLdc7UVf1bam064yZdUCq2s7QtXHXxQLVwzZHqFY9axWuMkP5+9QOJVD+tQq3
mtZ7VToL9hYMRZWSdq3T1by2JQNFdX876fDcdR4hZhaq8iUYdYmo1uxsbsESX0cYOTwdRT37
fh3bfpGq1sQ7eNde66LV8QXsPl2gNbttqRT7t+Q7fQIcdix9wj16MRTbDZ5dnSwb+ex2dux1
xdyRI1Lc0/+rvYLdFgjXnpfpe2/F0NgGf+8jEJT424auZSLacwrCuaG973xC7X54A6Zvg7pD
qtUJBV2iDc3hKS1zDKy6Dto49m5Q/6ED7mJc48xBh2dw2JE9c9CR21qScutOqNcvuNnQtw+5
nQFR6lt+4I68llL/HllrqQt7gKI6duDeXNlUbNtBp6xvm7jD/TDrSe5xwocy7xGf5jpHA6Y6
fCU7VMHh6FhPs9VxMob5D2zVg6SWcUlZFQm3iHROe7frkKYWuOxw981QcAviK44QnAa6u/hH
E+pf/HOYa1J1HjrOobn2a9Ck6jz0ZrbzBj28bKR38I9as7C7DWkih2ZOdn2NJr5i3J0HUY6r
rZNuD+nrKlEoZGGllvavuloYf9fVJV/OvPUbmrm8K/d2DRrLF1kDhvtbS7V9SCspqH19Vmgj
c24HMnsEuo9niTYPYIeAWabtiBVu6ULlC9LlHf7V4fSg8jWr77x3aa4BxLyrUo7wYspR7xLE
3OGMTEFqVoN7D0jkuYVS/ujnOHMIhxHu2B/VpTrAaMjyapd5NEvhkkQNs7xZbKLFbrMuH4my
NLvK4UKV+hTxr/lNvkvN3RfmopV5vs92y+1hs9tXj5zN53mRtcAT8A70fYEUXn9dtfwSLJRW
guj1xfPzD79Oote3B3hBe/Gi+9Py4/qSj3FQnCdYJ/nRSePnY5Rp2Kt8l0efmp+Pg+FIkU/R
n2dv4SKSSQTXxOtC981vFxPoV0bpIVqvf9azzTbwIvrVaTZRuoTTH0yzy93mdju93c61SKar
3e10v/y//Cf0F8b4Z/2boIceRcIbiTxQTxb6R0p4XwcGzyrjiMbRCXs6iapHYNfFTLMsX28P
Xx8Cs5KMfWox5NlmvZ5EzR5y9GpziA76D1B/dipO0ckuEyfrNT5BiGB5cjlP5glLSfQ3/EDY
BbwD7VMUoTs/vQ9EFbeQ5EIwHeqcH5gPMeV5qmOK8wMLktzFkchHwSfK7g7CmhNFUqpF1v7A
YKI51x+gnMxV64PeidLeB+pRy5+s+wNJZpRkGXJ/0NTh1getiT6D65Te79Isn9zjq+jj3+9K
85dP0fx2vZ2a2261cUuubTtrq1oYyEIwGnI6/ZLubjTULNNQeVshgkClPNVQADPdrzZftunh
arpYHzQClmoEyZERYAXv5PzF576c7vTouBK+EDONa7nfrCoM2/Qy3wOKZAYoFg+AQqrZQqPY
X2l/eD01N4Dl5mIwkPBCoyCzh0CRz7BFcbOZ51OIh5caA0XATqYeAIVCi8W3KCoK8PyosGTO
wJI308Pu6/SwmS52eV5LMmPAQvEwSBKSayQuDGkOruXYCFg2z4XxMtqDbrICuLb7n4AGodHM
+mQZDM88pUkLD4h3ne7B4+J5MsTOQuGRWCcIGs9N/kVTk86AkgxpSI6PBpkLNpca8h/mKqOS
gGWp4lgCG4+OQVKFueGfmXyBAoBTPsS0R4L/CBz4ETBImiXIsPEbLiagRukRYX8I2hk1+da1
Cf5QZ1stwsZ22dExVFSM5cL3ws9UogDeASqPCJriNCs9lwGcbvf57XwDYQ3813HBc6FMZDc8
g8tTq7mb2E6PC53lOaugV5vNtU44DXTChkh7FPRCayutoA+Xy/n0Rk+/QAM5FQXH+QA40mSe
QpJbEgAh3BjMoPR2HLBMZrkpPVbX02yz3m5u8htIanEGqUzSl+GPh1cSG5+1gpzSFD6AS2MQ
kNAmfYnlWARojmg6NwgOUMtOr9LdfLn73/10AwXgHJh4bAw4VYQR0CGYfSHHFJjIyZAqayw0
VUpDV31Rq7pKAXxf7TkS/sfgP0/nqcGg3ZchYrFKL/dV+Y17OgCj4auo+Y8AkXcMjnSGERjT
7T7fFaaUHqamnQmeDA/xZOMxoJkprz4v9tMF3INqdJnlA1KocaAKuPfuX//f3rX+tokE8e/3
V+zpPvROyoZd3qCjUpqkVXTNNbIr3Umnk7XA2kHGQAA7Tf/6m2Hx+YFTp7WT9gPJTzYeZoZ9
zL6YYRmeQwd+vxJvSm7fIHaYOFiwLq3dFjzCncZliaNpU4V7hrRjqmIsCsUjqurbedYs6Rr7
jl5GERRzbGJfM3wYbpay95RGfoDwmEnR3BmEwQ2W/VjNZ+/fj2xzNBZV3S63Oc53wvjZFDXe
HpnFqhSJERumZRrCDkObOZw3/p8jyTzdvXSAzFS9RQW9YzvdQ97Ph0sk2UKkSUzyIoI5qd/c
Vif//ML/JTeDy8vrm49keH1zFKEnuGA+KveLT96R9u+v9vsrHTIvea1aVFN/5RXxIuEyk5E6
8TdcJSaWEfKe7jrzIkoHVzdYV5z5Wze0mYfTg69k374rrqhfvCvuxe2E6xDZ7VQOVSpdfz37
jhm6hFy+fX/2btjYJ3Synn5U2bO//S0nlG6SwZsOlRlkcN6lvoDCizUmt2WCPF91RBnwdqne
8yt8c7NptY6FosztiHKgel3q8ysE6yeO5eh2pMMsWvcMU4+Byn18ZJ3Dv2Mww8bXIQJV9ztO
xxdQaPhdR+aAm37XmzngVreqnl3hW2hFDZMzNjkMq6YFJ35Fwm8EWthKqWzE2zPTLIWT31P3
udLNGbkYtmPc5fLgfMA2mgKYmdHxUR+uYKCvF6/QdSVqrFFd244U1dyqCrs7fz26wgvMxsZM
FkUvBnxHl3CxefHdhf4MCo2dovaKipeCD6Q6G7yc2d1u9egKh+i374QI7Kbu7Q66UQ+bCeVO
l7Bq7Jbp4dY0jxEi17BcB1awHcLeAA5zL0O3h95D4GGXsGrwnuMZNusQugnd7NQMdy/D1gDj
sd0EZcDKP7+bsBKR2zpkN6FHiDTp4w02VPTxBn28QR9v0Mcb9PEGP7KGPt6gjzfo4w36eIM+
3qCPN+jjDfp4gz7eoI836OMN+niD7x9vcN44v3dTXQsReQjTRbghwnARTgNjjFg/y21ES2k0
xDpC8XMDoc4aHmLsIkyOYGOEZyIijujq2cHJEKaFUGlTso6JYCHCZQgjRlgc4RoITyDwvize
mkUoKd1G/M7Gr9VHq2WtRByJYDbC9BBKS2wizAjhegilq81Jc9XIROi40xGxQoTKlRUh2uMY
0bmFOri62eXl/lFc2eiPJo22dVf0629k+3Jki/4N0TC7Zf5QMSeFyJKIUJLlNakesijJJj55
Cy06JfJTJIs6ybMjig5v53XzQHuc32ckKuaVejH4n9dXB7C2CfowHley9rvPpO9h++kyFQU+
lo+bWfoERpk7OZvT6qGq5Yx+cm3oVwiFWRlw0+liRiikhsABktvYHa2YTjSYOs8/aUqAliKL
ozwbJxNaGRTqASbxsIqZRBG1tTYuJbIs7oyZy10RO5bQx1bIY92GLlZEQpq20BYzVPqZfjG6
hYqiwOp/Rco8rwN89l8rxYwRGBQmIww0GTWVFUBTleF8QkQBP9Qh5LK8gwnOvXioRiqPMSkj
Zf6ncDCCzOJDqmm63CQ0wL0jlELKSZWPa5gd4ZppeZFsloyW71APlJnkeVG1h2ku4hEkD8p/
Gui44IN5zf8ERlS5x6dpPhmlciHTQJYlSSZZXuKseNLQiBRl+lCUSVZPg7p+GLITjiUM/WKe
VXkqHyUyspiIAJTNwFDL+2a9E2jTcJ6kMa1lVVdaOc/o3VzOpQaVvKc+mzqnMabJbz5pVeQ1
1RnHtmdxWFT4T61tP0wqGdVU6fS002XtP1VBe1nd5Y6uGwblFl0UJISkR7fBWkq1R1JK3nz4
8HF0dX327jL4rhYdl2F8OkuglmA1PM/qwH1FCMU4sDImWl4lMzGR2t1cZGCYy28agYW07fU0
mnwmdAaNmRFazQoCrQQynUD3KHEmdZLJGn4H8AUM6kcz2z5J4pYYQlsieRnLMsign8tyWsqG
Rpe2TRIb9MsqXJEo+rTyrG1ntKyjZsuPAFqISLH9QDJK3DgX13mBNq60Ko64hqbP6DIfi4Ja
/GQm40QEeOYkGQeLpATFj0vzg6T1g6SNg6TNg6Stg6TtJ0kXSdxswNJ0rNXtDHoLsAMNyJvi
YGmyTKBbQW5/i1ud2haIhZzlGe6yQeGqRSoeYDzN4BdS67wk2TxNyU//Aeieu5LFTgIA

--wac7ysb48OaltWcw
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-quantal-ivb41-105:20160728172446:x86_64-randconfig-s3-07152033:4.7.0-rc7-mm1-00217-g3eee0b4:1.gz"
Content-Transfer-Encoding: base64

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
NxgETOEMY6FfJtMlTPtP/gfsfk/X94UCAA==

--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.7.0-rc7-mm1-00218-gd5d54a2"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.7.0-rc7-mm1 Kernel Configuration
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
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEBUG_RODATA=y
CONFIG_PGTABLE_LEVELS=4
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
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_KERNEL_LZ4=y
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SYSVIPC is not set
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
CONFIG_USELIB=y
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

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
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
CONFIG_RCU_FAST_NO_HZ=y
CONFIG_TREE_RCU_TRACE=y
# CONFIG_RCU_BOOST is not set
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
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
CONFIG_RT_GROUP_SCHED=y
# CONFIG_CGROUP_PIDS is not set
CONFIG_CGROUP_FREEZER=y
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_DEVICE is not set
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
CONFIG_RD_LZMA=y
# CONFIG_RD_XZ is not set
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
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
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_ADVISE_SYSCALLS is not set
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
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SLUB_CPU_PARTIAL is not set
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
CONFIG_STATIC_KEYS_SELFTEST=y
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
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
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
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
# CONFIG_BLOCK is not set
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
# CONFIG_X86_FAST_FEATURE_TESTS is not set
# CONFIG_X86_X2APIC is not set
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_X86_INTEL_LPSS=y
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_IOSF_MBI=y
CONFIG_IOSF_MBI_DEBUG=y
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
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
# CONFIG_CPU_SUP_AMD is not set
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
# CONFIG_DMI is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS=8192
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_X86_DIRECT_GBPAGES=y
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
# CONFIG_ARCH_MEMORY_PROBE is not set
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
# CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is not set
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CLEANCACHE=y
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
CONFIG_DEFERRED_STRUCT_PAGE_INIT=y
CONFIG_IDLE_PAGE_TRACKING=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_SCHED_HRTICK is not set
# CONFIG_KEXEC is not set
# CONFIG_KEXEC_FILE is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_SUSPEND_SKIP_SYNC=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
# CONFIG_PM_ADVANCED_DEBUG is not set
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
CONFIG_ACPI_DEBUGGER=y
CONFIG_ACPI_DEBUGGER_USER=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_REV_OVERRIDE_POSSIBLE is not set
CONFIG_ACPI_EC_DEBUGFS=y
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
# CONFIG_ACPI_THERMAL is not set
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_TABLE_UPGRADE is not set
CONFIG_ACPI_DEBUG=y
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=y
CONFIG_ACPI_REDUCED_HARDWARE_ONLY=y
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
# CONFIG_ACPI_APEI_PCIEAER is not set
CONFIG_ACPI_APEI_EINJ=y
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y

#
# CPU frequency scaling drivers
#
# CONFIG_CPUFREQ_DT is not set
CONFIG_X86_INTEL_PSTATE=y
CONFIG_X86_PCC_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ=y
CONFIG_X86_POWERNOW_K8=y
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
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
CONFIG_PCIEAER_INJECT=y
# CONFIG_PCIEASPM is not set
CONFIG_PCIE_PME=y
CONFIG_PCIE_DPC=y
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
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
# CONFIG_HOTPLUG_PCI_ACPI_IBM is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set

#
# PCI host controller drivers
#
# CONFIG_PCIE_DW_PLAT is not set
# CONFIG_ISA_BUS is not set
CONFIG_ISA_DMA_API=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
# CONFIG_YENTA_ENE_TUNE is not set
# CONFIG_YENTA_TOSHIBA is not set
CONFIG_PD6729=y
CONFIG_I82092=y
CONFIG_PCCARD_NONSTATIC=y
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
# CONFIG_COREDUMP is not set
# CONFIG_IA32_EMULATION is not set
# CONFIG_X86_X32 is not set
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_PMC_ATOM=y
# CONFIG_VMD is not set
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_USER is not set
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
# CONFIG_SYN_COOKIES is not set
CONFIG_NET_UDP_TUNNEL=y
CONFIG_NET_FOU=y
CONFIG_NET_FOU_IP_TUNNELS=y
CONFIG_INET_AH=y
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=y
# CONFIG_INET_DIAG_DESTROY is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_ROUTER_PREF=y
# CONFIG_IPV6_ROUTE_INFO is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
CONFIG_INET6_AH=y
# CONFIG_INET6_ESP is not set
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
# CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET6_XFRM_MODE_TUNNEL is not set
# CONFIG_INET6_XFRM_MODE_BEET is not set
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
CONFIG_IPV6_SIT=y
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
CONFIG_IPV6_FOU=y
CONFIG_IPV6_FOU_TUNNEL=y
# CONFIG_IPV6_MULTIPLE_TABLES is not set
CONFIG_IPV6_MROUTE=y
# CONFIG_IPV6_MROUTE_MULTIPLE_TABLES is not set
CONFIG_IPV6_PIMSM_V2=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

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
CONFIG_INET_SCTP_DIAG=y
# CONFIG_RDS is not set
CONFIG_TIPC=y
# CONFIG_TIPC_MEDIA_UDP is not set
CONFIG_ATM=y
# CONFIG_ATM_CLIP is not set
CONFIG_ATM_LANE=y
CONFIG_ATM_MPOA=y
CONFIG_ATM_BR2684=y
# CONFIG_ATM_BR2684_IPFILTER is not set
# CONFIG_L2TP is not set
CONFIG_STP=y
CONFIG_GARP=y
CONFIG_MRP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
# CONFIG_BRIDGE_VLAN_FILTERING is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
# CONFIG_NET_DSA_HWMON is not set
CONFIG_NET_DSA_TAG_BRCM=y
CONFIG_NET_DSA_TAG_EDSA=y
CONFIG_NET_DSA_TAG_TRAILER=y
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_VLAN_8021Q_MVRP=y
CONFIG_DECNET=y
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
CONFIG_IPX=y
CONFIG_IPX_INTERN=y
# CONFIG_ATALK is not set
CONFIG_X25=y
CONFIG_LAPB=y
CONFIG_PHONET=y
CONFIG_6LOWPAN=y
CONFIG_6LOWPAN_DEBUGFS=y
# CONFIG_6LOWPAN_NHC is not set
CONFIG_IEEE802154=y
# CONFIG_IEEE802154_NL802154_EXPERIMENTAL is not set
# CONFIG_IEEE802154_SOCKET is not set
CONFIG_IEEE802154_6LOWPAN=y
# CONFIG_MAC802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
# CONFIG_BATMAN_ADV_BATMAN_V is not set
CONFIG_BATMAN_ADV_BLA=y
# CONFIG_BATMAN_ADV_DAT is not set
# CONFIG_BATMAN_ADV_NC is not set
CONFIG_BATMAN_ADV_MCAST=y
# CONFIG_BATMAN_ADV_DEBUG is not set
CONFIG_OPENVSWITCH=y
CONFIG_OPENVSWITCH_VXLAN=y
CONFIG_OPENVSWITCH_GENEVE=y
# CONFIG_VSOCKETS is not set
CONFIG_NETLINK_DIAG=y
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=y
CONFIG_MPLS_ROUTING=y
CONFIG_HSR=y
CONFIG_NET_SWITCHDEV=y
CONFIG_NET_L3_MASTER_DEV=y
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
# CONFIG_NET_PKTGEN is not set
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
# CONFIG_AX25 is not set
CONFIG_CAN=y
CONFIG_CAN_RAW=y
# CONFIG_CAN_BCM is not set
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
# CONFIG_CAN_VCAN is not set
CONFIG_CAN_SLCAN=y
CONFIG_CAN_DEV=y
# CONFIG_CAN_CALC_BITTIMING is not set
CONFIG_CAN_LEDS=y
CONFIG_CAN_GRCAN=y
CONFIG_CAN_C_CAN=y
# CONFIG_CAN_C_CAN_PLATFORM is not set
# CONFIG_CAN_C_CAN_PCI is not set
# CONFIG_CAN_CC770 is not set
CONFIG_CAN_IFI_CANFD=y
# CONFIG_CAN_M_CAN is not set
CONFIG_CAN_SJA1000=y
CONFIG_CAN_SJA1000_ISA=y
# CONFIG_CAN_SJA1000_PLATFORM is not set
# CONFIG_CAN_EMS_PCMCIA is not set
# CONFIG_CAN_EMS_PCI is not set
# CONFIG_CAN_PEAK_PCMCIA is not set
CONFIG_CAN_PEAK_PCI=y
CONFIG_CAN_PEAK_PCIEC=y
CONFIG_CAN_KVASER_PCI=y
# CONFIG_CAN_PLX_PCI is not set
CONFIG_CAN_SOFTING=y
# CONFIG_CAN_SOFTING_CS is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
# CONFIG_IRDA is not set
CONFIG_BT=y
# CONFIG_BT_BREDR is not set
# CONFIG_BT_LE is not set
CONFIG_BT_LEDS=y
CONFIG_BT_SELFTEST=y
# CONFIG_BT_DEBUGFS is not set

#
# Bluetooth device drivers
#
# CONFIG_BT_HCIUART is not set
CONFIG_BT_HCIDTL1=y
# CONFIG_BT_HCIBT3C is not set
CONFIG_BT_HCIBLUECARD=y
CONFIG_BT_HCIBTUART=y
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
CONFIG_BT_WILINK=y
CONFIG_AF_RXRPC=y
# CONFIG_AF_RXRPC_DEBUG is not set
# CONFIG_RXKAD is not set
# CONFIG_AF_KCM is not set
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
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
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
# CONFIG_RFKILL_INPUT is not set
CONFIG_RFKILL_REGULATOR=y
CONFIG_RFKILL_GPIO=y
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=y
CONFIG_CEPH_LIB_PRETTYDEBUG=y
# CONFIG_CEPH_LIB_USE_DNS_RESOLVER is not set
# CONFIG_NFC is not set
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=y
CONFIG_NET_DEVLINK=y
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
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPMI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
# CONFIG_DMA_SHARED_BUFFER is not set
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_OF_PARTS=y
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_OOPS=y
# CONFIG_MTD_PARTITIONED_MASTER is not set

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
CONFIG_MTD_CFI_GEOMETRY=y
CONFIG_MTD_MAP_BANK_WIDTH_1=y
# CONFIG_MTD_MAP_BANK_WIDTH_2 is not set
CONFIG_MTD_MAP_BANK_WIDTH_4=y
CONFIG_MTD_MAP_BANK_WIDTH_8=y
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
CONFIG_MTD_CFI_I4=y
CONFIG_MTD_CFI_I8=y
# CONFIG_MTD_OTP is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
# CONFIG_MTD_PHYSMAP_OF is not set
# CONFIG_MTD_SBC_GXX is not set
CONFIG_MTD_AMD76XROM=y
CONFIG_MTD_ICHXROM=y
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
CONFIG_MTD_PCI=y
CONFIG_MTD_PCMCIA=y
# CONFIG_MTD_PCMCIA_ANONYMOUS is not set
CONFIG_MTD_GPIO_ADDR=y
CONFIG_MTD_INTEL_VR_NOR=y
CONFIG_MTD_PLATRAM=y
# CONFIG_MTD_LATCH_ADDR is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_SLRAM=y
# CONFIG_MTD_PHRAM is not set
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0

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
CONFIG_MTD_SM_COMMON=y
CONFIG_MTD_NAND_DENALI=y
CONFIG_MTD_NAND_DENALI_PCI=y
CONFIG_MTD_NAND_DENALI_DT=y
CONFIG_MTD_NAND_DENALI_SCRATCH_REG_ADDR=0xFF108018
# CONFIG_MTD_NAND_GPIO is not set
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=y
CONFIG_MTD_NAND_RICOH=y
# CONFIG_MTD_NAND_DISKONCHIP is not set
CONFIG_MTD_NAND_DOCG4=y
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_NANDSIM=y
# CONFIG_MTD_NAND_PLATFORM is not set
CONFIG_MTD_NAND_HISI504=y
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=y
# CONFIG_MTD_ONENAND_OTP is not set
CONFIG_MTD_ONENAND_2X_PROGRAM=y

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_SPI_NOR=y
# CONFIG_MTD_MT81xx_NOR is not set
CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
CONFIG_MTD_UBI_GLUEBI=y
CONFIG_DTC=y
CONFIG_OF=y
CONFIG_OF_UNITTEST=y
CONFIG_OF_FLATTREE=y
CONFIG_OF_EARLY_FLATTREE=y
CONFIG_OF_DYNAMIC=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_ADDRESS_PCI=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_MDIO=y
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
CONFIG_OF_MTD=y
CONFIG_OF_RESOLVE=y
CONFIG_OF_OVERLAY=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
CONFIG_PHANTOM=y
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_HP_ILO=y
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_SRAM=y
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
CONFIG_CB710_CORE=y
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=y
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
CONFIG_INTEL_MEI_TXE=y
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#
CONFIG_INTEL_MIC_BUS=y

#
# SCIF Bus Driver
#
CONFIG_SCIF_BUS=y

#
# VOP Bus Driver
#
CONFIG_VOP_BUS=y

#
# Intel MIC Host Driver
#
CONFIG_INTEL_MIC_HOST=y

#
# Intel MIC Card Driver
#
CONFIG_INTEL_MIC_CARD=y

#
# SCIF Driver
#
CONFIG_SCIF=y

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#
CONFIG_MIC_COSM=y

#
# VOP Driver
#
# CONFIG_VOP is not set
CONFIG_GENWQE=y
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=0
# CONFIG_ECHO is not set
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_KERNEL_API is not set
# CONFIG_CXL_EEH is not set
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
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
# CONFIG_FIREWIRE_NET is not set
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
CONFIG_BONDING=y
CONFIG_DUMMY=y
CONFIG_EQUALIZER=y
# CONFIG_NET_TEAM is not set
CONFIG_MACVLAN=y
# CONFIG_MACVTAP is not set
# CONFIG_IPVLAN is not set
CONFIG_VXLAN=y
CONFIG_GENEVE=y
# CONFIG_GTP is not set
# CONFIG_MACSEC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
CONFIG_TUN=y
CONFIG_TUN_VNET_CROSS_LE=y
CONFIG_VETH=y
# CONFIG_VIRTIO_NET is not set
CONFIG_NLMON=y
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
# CONFIG_ARCNET_1051 is not set
CONFIG_ARCNET_RAW=y
# CONFIG_ARCNET_CAP is not set
CONFIG_ARCNET_COM90xx=y
CONFIG_ARCNET_COM90xxIO=y
# CONFIG_ARCNET_RIM_I is not set
CONFIG_ARCNET_COM20020=y
CONFIG_ARCNET_COM20020_PCI=y
# CONFIG_ARCNET_COM20020_CS is not set
# CONFIG_ATM_DRIVERS is not set

#
# CAIF transport drivers
#
# CONFIG_VHOST_NET is not set
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6060=y
CONFIG_NET_DSA_MV88E6XXX=y
CONFIG_NET_DSA_BCM_SF2=y
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_PCMCIA_3C574 is not set
CONFIG_PCMCIA_3C589=y
CONFIG_VORTEX=y
# CONFIG_TYPHOON is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
# CONFIG_NET_VENDOR_AGERE is not set
# CONFIG_NET_VENDOR_ALTEON is not set
CONFIG_ALTERA_TSE=y
# CONFIG_NET_VENDOR_AMD is not set
# CONFIG_NET_VENDOR_ARC is not set
# CONFIG_NET_VENDOR_ATHEROS is not set
# CONFIG_NET_VENDOR_AURORA is not set
CONFIG_NET_CADENCE=y
CONFIG_MACB=y
# CONFIG_NET_VENDOR_BROADCOM is not set
# CONFIG_NET_VENDOR_BROCADE is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
CONFIG_THUNDER_NIC_VF=y
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_LIQUIDIO is not set
# CONFIG_NET_VENDOR_CHELSIO is not set
# CONFIG_NET_VENDOR_CISCO is not set
CONFIG_CX_ECAT=y
CONFIG_DNET=y
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
CONFIG_SUNDANCE=y
# CONFIG_SUNDANCE_MMIO is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
# CONFIG_NET_VENDOR_EZCHIP is not set
# CONFIG_NET_VENDOR_EXAR is not set
# CONFIG_NET_VENDOR_FUJITSU is not set
CONFIG_NET_VENDOR_HP=y
CONFIG_HP100=y
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=y
CONFIG_E1000=y
CONFIG_E1000E=y
# CONFIG_E1000E_HWTS is not set
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
CONFIG_IGB_DCA=y
CONFIG_IGBVF=y
# CONFIG_IXGB is not set
CONFIG_IXGBE=y
# CONFIG_IXGBE_VXLAN is not set
# CONFIG_IXGBE_HWMON is not set
# CONFIG_IXGBE_DCA is not set
CONFIG_IXGBEVF=y
CONFIG_I40E=y
# CONFIG_I40E_VXLAN is not set
CONFIG_I40E_GENEVE=y
# CONFIG_I40EVF is not set
# CONFIG_FM10K is not set
CONFIG_NET_VENDOR_I825XX=y
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=y
# CONFIG_MVNETA_BM is not set
CONFIG_SKGE=y
# CONFIG_SKGE_DEBUG is not set
# CONFIG_SKGE_GENESIS is not set
CONFIG_SKY2=y
# CONFIG_SKY2_DEBUG is not set
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=y
CONFIG_MLX4_EN_VXLAN=y
CONFIG_MLX4_CORE=y
# CONFIG_MLX4_DEBUG is not set
# CONFIG_MLX5_CORE is not set
CONFIG_MLXSW_CORE=y
# CONFIG_MLXSW_CORE_HWMON is not set
CONFIG_MLXSW_PCI=y
CONFIG_MLXSW_SWITCHX2=y
CONFIG_MLXSW_SPECTRUM=y
CONFIG_NET_VENDOR_MICREL=y
CONFIG_KS8842=y
# CONFIG_KS8851_MLL is not set
CONFIG_KSZ884X_PCI=y
# CONFIG_NET_VENDOR_MYRI is not set
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NETRONOME=y
# CONFIG_NFP_NETVF is not set
# CONFIG_NET_VENDOR_NVIDIA is not set
# CONFIG_NET_VENDOR_OKI is not set
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_NET_VENDOR_QLOGIC is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_NET_VENDOR_REALTEK is not set
# CONFIG_NET_VENDOR_RENESAS is not set
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_ROCKER=y
# CONFIG_ROCKER is not set
CONFIG_NET_VENDOR_SAMSUNG=y
CONFIG_SXGBE_ETH=y
# CONFIG_NET_VENDOR_SEEQ is not set
CONFIG_NET_VENDOR_SILAN=y
CONFIG_SC92031=y
CONFIG_NET_VENDOR_SIS=y
CONFIG_SIS900=y
CONFIG_SIS190=y
CONFIG_SFC=y
# CONFIG_SFC_MTD is not set
# CONFIG_SFC_MCDI_MON is not set
CONFIG_SFC_SRIOV=y
# CONFIG_SFC_MCDI_LOGGING is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
CONFIG_EPIC100=y
CONFIG_SMSC911X=y
# CONFIG_SMSC911X_ARCH_HOOKS is not set
# CONFIG_SMSC9420 is not set
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
CONFIG_SYNOPSYS_DWC_ETH_QOS=y
# CONFIG_NET_VENDOR_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
CONFIG_VIA_VELOCITY=y
# CONFIG_NET_VENDOR_WIZNET is not set
# CONFIG_NET_VENDOR_XIRCOM is not set
CONFIG_FDDI=y
CONFIG_DEFXX=y
# CONFIG_DEFXX_MMIO is not set
CONFIG_SKFP=y
CONFIG_HIPPI=y
# CONFIG_ROADRUNNER is not set
CONFIG_NET_SB1000=y
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AQUANTIA_PHY is not set
CONFIG_AT803X_PHY=y
CONFIG_AMD_PHY=y
CONFIG_MARVELL_PHY=y
# CONFIG_DAVICOM_PHY is not set
# CONFIG_QSEMI_PHY is not set
CONFIG_LXT_PHY=y
CONFIG_CICADA_PHY=y
CONFIG_VITESSE_PHY=y
CONFIG_TERANETICS_PHY=y
CONFIG_SMSC_PHY=y
CONFIG_BCM_NET_PHYLIB=y
CONFIG_BROADCOM_PHY=y
CONFIG_BCM7XXX_PHY=y
CONFIG_BCM87XX_PHY=y
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
CONFIG_NATIONAL_PHY=y
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MICREL_PHY is not set
# CONFIG_DP83848_PHY is not set
# CONFIG_DP83867_PHY is not set
CONFIG_MICROCHIP_PHY=y
CONFIG_FIXED_PHY=y
CONFIG_MDIO_BITBANG=y
CONFIG_MDIO_GPIO=y
CONFIG_MDIO_CAVIUM=y
CONFIG_MDIO_OCTEON=y
CONFIG_MDIO_THUNDER=y
CONFIG_MDIO_BUS_MUX=y
CONFIG_MDIO_BUS_MUX_GPIO=y
CONFIG_MDIO_BUS_MUX_MMIOREG=y
CONFIG_MDIO_BCM_UNIMAC=y
# CONFIG_PLIP is not set
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
# CONFIG_PPP_DEFLATE is not set
# CONFIG_PPP_FILTER is not set
CONFIG_PPP_MPPE=y
# CONFIG_PPP_MULTILINK is not set
# CONFIG_PPPOATM is not set
CONFIG_PPPOE=y
# CONFIG_PPP_ASYNC is not set
CONFIG_PPP_SYNC_TTY=y
CONFIG_SLIP=y
CONFIG_SLHC=y
# CONFIG_SLIP_COMPRESSED is not set
# CONFIG_SLIP_SMART is not set
CONFIG_SLIP_MODE_SLIP6=y

#
# Host-side USB support is needed for USB Network Adapter support
#
CONFIG_WLAN=y
# CONFIG_WLAN_VENDOR_ADMTEK is not set
# CONFIG_WLAN_VENDOR_ATH is not set
# CONFIG_WLAN_VENDOR_ATMEL is not set
# CONFIG_WLAN_VENDOR_BROADCOM is not set
# CONFIG_WLAN_VENDOR_CISCO is not set
# CONFIG_WLAN_VENDOR_INTEL is not set
# CONFIG_WLAN_VENDOR_INTERSIL is not set
# CONFIG_WLAN_VENDOR_MARVELL is not set
# CONFIG_WLAN_VENDOR_MEDIATEK is not set
CONFIG_WLAN_VENDOR_RALINK=y
# CONFIG_RT2X00 is not set
# CONFIG_WLAN_VENDOR_REALTEK is not set
CONFIG_WLAN_VENDOR_RSI=y
# CONFIG_RSI_91X is not set
CONFIG_WLAN_VENDOR_ST=y
# CONFIG_CW1200 is not set
CONFIG_WLAN_VENDOR_TI=y
# CONFIG_WL1251 is not set
# CONFIG_WL12XX is not set
# CONFIG_WL18XX is not set
# CONFIG_WLCORE is not set
CONFIG_WLAN_VENDOR_ZYDAS=y
CONFIG_PCMCIA_RAYCS=y
# CONFIG_PCMCIA_WL3501 is not set
CONFIG_MAC80211_HWSIM=y

#
# WiMAX Wireless Broadband devices
#

#
# Enable USB support to see WiMAX USB drivers
#
CONFIG_WAN=y
# CONFIG_LANMEDIA is not set
CONFIG_HDLC=y
CONFIG_HDLC_RAW=y
CONFIG_HDLC_RAW_ETH=y
CONFIG_HDLC_CISCO=y
CONFIG_HDLC_FR=y
CONFIG_HDLC_PPP=y
CONFIG_HDLC_X25=y
# CONFIG_PCI200SYN is not set
CONFIG_WANXL=y
CONFIG_PC300TOO=y
CONFIG_FARSYNC=y
# CONFIG_DLCI is not set
CONFIG_LAPBETHER=y
CONFIG_X25_ASY=y
CONFIG_SBNI=y
CONFIG_SBNI_MULTILINE=y
CONFIG_IEEE802154_DRIVERS=y
CONFIG_VMXNET3=y
# CONFIG_FUJITSU_ES is not set
CONFIG_ISDN=y
CONFIG_ISDN_I4L=y
CONFIG_ISDN_PPP=y
CONFIG_ISDN_PPP_VJ=y
# CONFIG_ISDN_MPP is not set
# CONFIG_IPPP_FILTER is not set
CONFIG_ISDN_PPP_BSDCOMP=y
# CONFIG_ISDN_AUDIO is not set
# CONFIG_ISDN_X25 is not set

#
# ISDN feature submodules
#
# CONFIG_ISDN_DIVERSION is not set

#
# ISDN4Linux hardware drivers
#

#
# Passive cards
#
CONFIG_ISDN_DRV_HISAX=y

#
# D-channel protocol features
#
# CONFIG_HISAX_EURO is not set
# CONFIG_HISAX_1TR6 is not set
CONFIG_HISAX_NI1=y
CONFIG_HISAX_MAX_CARDS=8

#
# HiSax supported cards
#
# CONFIG_HISAX_16_3 is not set
CONFIG_HISAX_TELESPCI=y
# CONFIG_HISAX_S0BOX is not set
# CONFIG_HISAX_FRITZPCI is not set
# CONFIG_HISAX_AVM_A1_PCMCIA is not set
CONFIG_HISAX_ELSA=y
# CONFIG_HISAX_DIEHLDIVA is not set
CONFIG_HISAX_SEDLBAUER=y
CONFIG_HISAX_NETJET=y
# CONFIG_HISAX_NETJET_U is not set
# CONFIG_HISAX_NICCY is not set
# CONFIG_HISAX_BKM_A4T is not set
CONFIG_HISAX_SCT_QUADRO=y
CONFIG_HISAX_GAZEL=y
# CONFIG_HISAX_HFC_PCI is not set
CONFIG_HISAX_W6692=y
CONFIG_HISAX_HFC_SX=y
# CONFIG_HISAX_ENTERNOW_PCI is not set
# CONFIG_HISAX_DEBUG is not set

#
# HiSax PCMCIA card service modules
#
CONFIG_HISAX_SEDLBAUER_CS=y
CONFIG_HISAX_ELSA_CS=y
CONFIG_HISAX_AVM_A1_CS=y

#
# HiSax sub driver modules
#
# CONFIG_HISAX_HFC4S8S is not set
# CONFIG_HISAX_FRITZ_PCIPNP is not set
CONFIG_ISDN_CAPI=y
CONFIG_CAPI_TRACE=y
# CONFIG_ISDN_CAPI_CAPI20 is not set
# CONFIG_ISDN_CAPI_CAPIDRV is not set

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
# CONFIG_ISDN_DRV_AVMB1_B1PCI is not set
CONFIG_ISDN_DRV_AVMB1_B1PCMCIA=y
CONFIG_ISDN_DRV_AVMB1_AVM_CS=y
CONFIG_ISDN_DRV_AVMB1_T1PCI=y
CONFIG_ISDN_DRV_AVMB1_C4=y
# CONFIG_CAPI_EICON is not set
CONFIG_ISDN_DRV_GIGASET=y
# CONFIG_GIGASET_CAPI is not set
CONFIG_GIGASET_I4L=y
# CONFIG_GIGASET_DUMMYLL is not set
CONFIG_GIGASET_M101=y
# CONFIG_GIGASET_DEBUG is not set
CONFIG_MISDN=y
CONFIG_MISDN_DSP=y
# CONFIG_MISDN_L1OIP is not set

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=y
# CONFIG_MISDN_HFCMULTI is not set
# CONFIG_MISDN_AVMFRITZ is not set
# CONFIG_MISDN_SPEEDFAX is not set
CONFIG_MISDN_INFINEON=y
CONFIG_MISDN_W6692=y
CONFIG_MISDN_NETJET=y
CONFIG_MISDN_IPAC=y
CONFIG_ISDN_HDLC=y

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
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
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_TC3589X is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_KEYBOARD_CAP11XX is not set
# CONFIG_KEYBOARD_BCM is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_ELAN_I2C is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_GPIO is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
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
# CONFIG_SERIO_PARKBD is not set
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=y
CONFIG_SERIO_APBPS2=y
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
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=y
# CONFIG_N_GSM is not set
# CONFIG_TRACE_ROUTER is not set
CONFIG_TRACE_SINK=y
CONFIG_DEVMEM=y
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_FINTEK=y
CONFIG_SERIAL_8250_CONSOLE=y
# CONFIG_SERIAL_8250_DMA is not set
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_FSL is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
# CONFIG_SERIAL_8250_MID is not set
CONFIG_SERIAL_8250_MOXA=y
# CONFIG_SERIAL_OF_PLATFORM is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_UARTLITE=y
# CONFIG_SERIAL_UARTLITE_CONSOLE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
CONFIG_SERIAL_SCCNXP_CONSOLE=y
# CONFIG_SERIAL_SC16IS7XX is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
# CONFIG_SERIAL_ALTERA_UART is not set
CONFIG_SERIAL_XILINX_PS_UART=y
CONFIG_SERIAL_XILINX_PS_UART_CONSOLE=y
CONFIG_SERIAL_ARC=y
# CONFIG_SERIAL_ARC_CONSOLE is not set
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
# CONFIG_SERIAL_FSL_LPUART is not set
CONFIG_SERIAL_CONEXANT_DIGICOLOR=y
# CONFIG_SERIAL_CONEXANT_DIGICOLOR_CONSOLE is not set
CONFIG_SERIAL_MEN_Z135=y
CONFIG_TTY_PRINTK=y
CONFIG_PRINTER=y
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
# CONFIG_HW_RANDOM_VIRTIO is not set
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=y
# CONFIG_CARDMAN_4000 is not set
CONFIG_CARDMAN_4040=y
# CONFIG_IPWIRELESS is not set
CONFIG_MWAVE=y
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_XILLYBUS=y
# CONFIG_XILLYBUS_PCIE is not set
CONFIG_XILLYBUS_OF=y

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
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
# CONFIG_I2C_ISCH is not set
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
# CONFIG_I2C_NFORCE2 is not set
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
CONFIG_I2C_DESIGNWARE_PCI=y
CONFIG_I2C_DESIGNWARE_BAYTRAIL=y
CONFIG_I2C_EMEV2=y
CONFIG_I2C_GPIO=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_RK3X=y
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_CROS_EC_TUNNEL=y
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_SPMI=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
CONFIG_HSI_CHAR=y

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_PARPORT is not set
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
CONFIG_PINCTRL=y

#
# Pin controllers
#
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
CONFIG_DEBUG_PINCTRL=y
# CONFIG_PINCTRL_AS3722 is not set
# CONFIG_PINCTRL_AMD is not set
# CONFIG_PINCTRL_SINGLE is not set
CONFIG_PINCTRL_BAYTRAIL=y
CONFIG_PINCTRL_CHERRYVIEW=y
CONFIG_PINCTRL_INTEL=y
# CONFIG_PINCTRL_BROXTON is not set
CONFIG_PINCTRL_SUNRISEPOINT=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_74XX_MMIO is not set
# CONFIG_GPIO_ALTERA is not set
CONFIG_GPIO_AMDPT=y
CONFIG_GPIO_DWAPB=y
# CONFIG_GPIO_GENERIC_PLATFORM is not set
CONFIG_GPIO_GRGPIO=y
CONFIG_GPIO_ICH=y
CONFIG_GPIO_LYNXPOINT=y
# CONFIG_GPIO_MENZ127 is not set
CONFIG_GPIO_SYSCON=y
CONFIG_GPIO_VX855=y
# CONFIG_GPIO_XILINX is not set
CONFIG_GPIO_ZX=y

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_IT87=y
CONFIG_GPIO_SCH=y
# CONFIG_GPIO_SCH311X is not set

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
CONFIG_GPIO_ADNP=y
CONFIG_GPIO_MAX7300=y
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_ARIZONA=y
# CONFIG_GPIO_CRYSTAL_COVE is not set
# CONFIG_GPIO_LP3943 is not set
CONFIG_GPIO_RC5T583=y
CONFIG_GPIO_TC3589X=y
# CONFIG_GPIO_TPS65086 is not set
# CONFIG_GPIO_TPS65910 is not set
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL4030=y
# CONFIG_GPIO_TWL6040 is not set
CONFIG_GPIO_UCB1400=y
CONFIG_GPIO_WM831X=y
CONFIG_GPIO_WM8350=y
CONFIG_GPIO_WM8994=y

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=y
CONFIG_GPIO_BT8XX=y
# CONFIG_GPIO_INTEL_MID is not set
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_RDC321X=y
CONFIG_GPIO_SODAVILLE=y

#
# SPI or I2C GPIO expanders
#
CONFIG_GPIO_MCP23S08=y
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
# CONFIG_W1_MASTER_DS2482 is not set
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
CONFIG_W1_SLAVE_DS2413=y
# CONFIG_W1_SLAVE_DS2406 is not set
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
CONFIG_GENERIC_ADC_BATTERY=y
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
CONFIG_WM8350_POWER=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_88PM860X=y
CONFIG_BATTERY_ACT8945A=y
CONFIG_BATTERY_DS2760=y
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_BATTERY_DA9030 is not set
CONFIG_CHARGER_DA9150=y
# CONFIG_BATTERY_DA9150 is not set
CONFIG_AXP288_FUEL_GAUGE=y
# CONFIG_BATTERY_MAX17040 is not set
CONFIG_BATTERY_MAX17042=y
CONFIG_CHARGER_88PM860X=y
CONFIG_CHARGER_PCF50633=y
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_TWL4030 is not set
# CONFIG_CHARGER_LP8727 is not set
CONFIG_CHARGER_GPIO=y
CONFIG_CHARGER_MANAGER=y
# CONFIG_CHARGER_MAX14577 is not set
CONFIG_CHARGER_MAX77693=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_BQ25890=y
CONFIG_CHARGER_SMB347=y
# CONFIG_CHARGER_TPS65090 is not set
CONFIG_CHARGER_TPS65217=y
CONFIG_BATTERY_GAUGE_LTC2941=y
CONFIG_BATTERY_RT5033=y
# CONFIG_CHARGER_RT9455 is not set
# CONFIG_AXP20X_POWER is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_AS3722 is not set
CONFIG_POWER_RESET_GPIO=y
CONFIG_POWER_RESET_GPIO_RESTART=y
CONFIG_POWER_RESET_LTC2952=y
CONFIG_POWER_RESET_RESTART=y
CONFIG_POWER_RESET_SYSCON=y
# CONFIG_POWER_RESET_SYSCON_POWEROFF is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_AD7414=y
# CONFIG_SENSORS_AD7418 is not set
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
# CONFIG_SENSORS_ADT7410 is not set
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=y
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=y
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DELL_SMM=y
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_FSCHMD=y
# CONFIG_SENSORS_GL518SM is not set
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_HIH6130=y
# CONFIG_SENSORS_IIO_HWMON is not set
CONFIG_SENSORS_I5500=y
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
# CONFIG_SENSORS_LTC2945 is not set
CONFIG_SENSORS_LTC2990=y
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
CONFIG_SENSORS_LTC4222=y
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4260 is not set
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
# CONFIG_SENSORS_MENF21BMC_HWMON is not set
CONFIG_SENSORS_LM63=y
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NCT7802 is not set
CONFIG_SENSORS_NCT7904=y
# CONFIG_SENSORS_PCF8591 is not set
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_LM25066=y
# CONFIG_SENSORS_LTC2978 is not set
# CONFIG_SENSORS_LTC3815 is not set
CONFIG_SENSORS_MAX16064=y
CONFIG_SENSORS_MAX20751=y
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
# CONFIG_SENSORS_TPS40422 is not set
# CONFIG_SENSORS_UCD9000 is not set
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
# CONFIG_SENSORS_PWM_FAN is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHTC1=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_SMM665=y
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=y
# CONFIG_SENSORS_ADS7828 is not set
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_TC74=y
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP103=y
# CONFIG_SENSORS_TMP401 is not set
CONFIG_SENSORS_TMP421=y
# CONFIG_SENSORS_VIA_CPUTEMP is not set
CONFIG_SENSORS_VIA686A=y
# CONFIG_SENSORS_VT1211 is not set
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=y
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y
CONFIG_SENSORS_WM8350=y

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_OF=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE=y
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
CONFIG_CPU_THERMAL=y
CONFIG_THERMAL_EMULATION=y
# CONFIG_IMX_THERMAL is not set
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
CONFIG_INTEL_SOC_DTS_THERMAL=y

#
# ACPI INT340X thermal drivers
#
CONFIG_INT340X_THERMAL=y
CONFIG_ACPI_THERMAL_REL=y
CONFIG_INTEL_PCH_THERMAL=y
# CONFIG_QCOM_SPMI_TEMP_ALARM is not set
CONFIG_GENERIC_ADC_THERMAL=y
# CONFIG_WATCHDOG is not set
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
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
CONFIG_BCMA_DRIVER_GPIO=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_ACT8945A=y
CONFIG_MFD_AS3711=y
CONFIG_MFD_AS3722=y
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_AAT2870_CORE=y
# CONFIG_MFD_ATMEL_FLEXCOM is not set
# CONFIG_MFD_ATMEL_HLCDC is not set
# CONFIG_MFD_BCM590XX is not set
CONFIG_MFD_AXP20X=y
CONFIG_MFD_AXP20X_I2C=y
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
CONFIG_PMIC_DA903X=y
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_MFD_HI6421_PMIC=y
# CONFIG_HTC_PASIC3 is not set
CONFIG_HTC_I2CPLD=y
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_INTEL_SOC_PMIC=y
CONFIG_MFD_INTEL_LPSS=y
CONFIG_MFD_INTEL_LPSS_ACPI=y
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
CONFIG_MFD_88PM800=y
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77620 is not set
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MT6397 is not set
CONFIG_MFD_MENF21BMC=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
CONFIG_UCB1400_CORE=y
CONFIG_MFD_RDC321X=y
CONFIG_MFD_RTSX_PCI=y
CONFIG_MFD_RT5033=y
CONFIG_MFD_RC5T583=y
CONFIG_MFD_RK808=y
# CONFIG_MFD_RN5T618 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
CONFIG_MFD_SKY81452=y
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
CONFIG_MFD_TPS65086=y
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS65218 is not set
# CONFIG_MFD_TPS6586X is not set
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
CONFIG_MFD_TC3589X=y
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_CS47L24=y
# CONFIG_MFD_WM5102 is not set
# CONFIG_MFD_WM5110 is not set
CONFIG_MFD_WM8997=y
CONFIG_MFD_WM8998=y
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_88PM800 is not set
# CONFIG_REGULATOR_88PM8607 is not set
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_ACT8945A=y
# CONFIG_REGULATOR_AD5398 is not set
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AAT2870=y
CONFIG_REGULATOR_ARIZONA=y
# CONFIG_REGULATOR_AS3711 is not set
CONFIG_REGULATOR_AS3722=y
CONFIG_REGULATOR_AXP20X=y
# CONFIG_REGULATOR_DA903X is not set
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
# CONFIG_REGULATOR_FAN53555 is not set
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_HI6421=y
CONFIG_REGULATOR_ISL9305=y
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LP8788=y
# CONFIG_REGULATOR_LTC3589 is not set
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX77693=y
# CONFIG_REGULATOR_MT6311 is not set
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=y
CONFIG_REGULATOR_PWM=y
CONFIG_REGULATOR_QCOM_SPMI=y
# CONFIG_REGULATOR_RC5T583 is not set
CONFIG_REGULATOR_RK808=y
CONFIG_REGULATOR_RT5033=y
CONFIG_REGULATOR_SKY81452=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
# CONFIG_REGULATOR_TPS6507X is not set
CONFIG_REGULATOR_TPS65086=y
CONFIG_REGULATOR_TPS65090=y
CONFIG_REGULATOR_TPS65217=y
# CONFIG_REGULATOR_TPS65910 is not set
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_TPS80031=y
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_WM831X=y
CONFIG_REGULATOR_WM8350=y
CONFIG_REGULATOR_WM8400=y
CONFIG_REGULATOR_WM8994=y
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
# CONFIG_VGA_ARB is not set
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set

#
# ACP (Audio CoProcessor) Configuration
#

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
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
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
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
CONFIG_FB_VESA=y
CONFIG_FB_N411=y
# CONFIG_FB_HGA is not set
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
CONFIG_FB_NVIDIA_I2C=y
CONFIG_FB_NVIDIA_DEBUG=y
CONFIG_FB_NVIDIA_BACKLIGHT=y
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
CONFIG_FB_ATY=y
# CONFIG_FB_ATY_CT is not set
# CONFIG_FB_ATY_GX is not set
# CONFIG_FB_ATY_BACKLIGHT is not set
CONFIG_FB_S3=y
# CONFIG_FB_S3_DDC is not set
CONFIG_FB_SAVAGE=y
# CONFIG_FB_SAVAGE_I2C is not set
CONFIG_FB_SAVAGE_ACCEL=y
CONFIG_FB_SIS=y
# CONFIG_FB_SIS_300 is not set
CONFIG_FB_SIS_315=y
# CONFIG_FB_VIA is not set
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
CONFIG_FB_3DFX_ACCEL=y
# CONFIG_FB_3DFX_I2C is not set
# CONFIG_FB_VOODOO1 is not set
CONFIG_FB_VT8623=y
CONFIG_FB_TRIDENT=y
CONFIG_FB_ARK=y
CONFIG_FB_PM3=y
CONFIG_FB_CARMINE=y
CONFIG_FB_CARMINE_DRAM_EVAL=y
# CONFIG_CARMINE_DRAM_CUSTOM is not set
CONFIG_FB_SM501=y
CONFIG_FB_IBM_GXT4500=y
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
CONFIG_FB_BROADSHEET=y
CONFIG_FB_AUO_K190X=y
CONFIG_FB_AUO_K1900=y
# CONFIG_FB_AUO_K1901 is not set
CONFIG_FB_SIMPLE=y
CONFIG_FB_SSD1307=y
CONFIG_FB_SM712=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_PLATFORM=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_CARILLO_RANCH=y
CONFIG_BACKLIGHT_PWM=y
CONFIG_BACKLIGHT_DA903X=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3630A=y
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_LP8788=y
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_SKY81452=y
# CONFIG_BACKLIGHT_TPS65217 is not set
CONFIG_BACKLIGHT_AS3711=y
CONFIG_BACKLIGHT_GPIO=y
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
CONFIG_VGASTATE=y
CONFIG_HDMI=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_PCM_ELD=y
CONFIG_SND_DMAENGINE_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_COMPRESS_OFFLOAD=y
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
CONFIG_SND_PCM_OSS=y
CONFIG_SND_PCM_OSS_PLUGINS=y
CONFIG_SND_PCM_TIMER=y
CONFIG_SND_SEQUENCER_OSS=y
# CONFIG_SND_DYNAMIC_MINORS is not set
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
CONFIG_SND_VERBOSE_PRINTK=y
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=y
CONFIG_SND_OPL3_LIB_SEQ=y
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
CONFIG_SND_MPU401_UART=y
CONFIG_SND_OPL3_LIB=y
CONFIG_SND_VX_LIB=y
CONFIG_SND_AC97_CODEC=y
CONFIG_SND_DRIVERS=y
CONFIG_SND_DUMMY=y
CONFIG_SND_ALOOP=y
# CONFIG_SND_VIRMIDI is not set
# CONFIG_SND_MTPAV is not set
# CONFIG_SND_MTS64 is not set
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=y
CONFIG_SND_PORTMAN2X4=y
# CONFIG_SND_AC97_POWER_SAVE is not set
CONFIG_SND_SB_COMMON=y
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=y
CONFIG_SND_ALS300=y
CONFIG_SND_ALS4000=y
CONFIG_SND_ALI5451=y
CONFIG_SND_ASIHPI=y
CONFIG_SND_ATIIXP=y
CONFIG_SND_ATIIXP_MODEM=y
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
CONFIG_SND_AU8830=y
CONFIG_SND_AW2=y
CONFIG_SND_AZT3328=y
CONFIG_SND_BT87X=y
# CONFIG_SND_BT87X_OVERCLOCK is not set
# CONFIG_SND_CA0106 is not set
CONFIG_SND_CMIPCI=y
CONFIG_SND_OXYGEN_LIB=y
CONFIG_SND_OXYGEN=y
CONFIG_SND_CS4281=y
CONFIG_SND_CS46XX=y
# CONFIG_SND_CS46XX_NEW_DSP is not set
# CONFIG_SND_CTXFI is not set
CONFIG_SND_DARLA20=y
CONFIG_SND_GINA20=y
CONFIG_SND_LAYLA20=y
CONFIG_SND_DARLA24=y
CONFIG_SND_GINA24=y
CONFIG_SND_LAYLA24=y
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
CONFIG_SND_ECHO3G=y
# CONFIG_SND_INDIGO is not set
CONFIG_SND_INDIGOIO=y
CONFIG_SND_INDIGODJ=y
CONFIG_SND_INDIGOIOX=y
# CONFIG_SND_INDIGODJX is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
CONFIG_SND_ENS1370=y
# CONFIG_SND_ENS1371 is not set
CONFIG_SND_ES1938=y
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDSP=y

#
# Don't forget to add built-in firmwares for HDSP driver
#
CONFIG_SND_HDSPM=y
# CONFIG_SND_ICE1712 is not set
CONFIG_SND_ICE1724=y
CONFIG_SND_INTEL8X0=y
CONFIG_SND_INTEL8X0M=y
# CONFIG_SND_KORG1212 is not set
CONFIG_SND_LOLA=y
# CONFIG_SND_LX6464ES is not set
# CONFIG_SND_MAESTRO3 is not set
CONFIG_SND_MIXART=y
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
CONFIG_SND_RIPTIDE=y
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
CONFIG_SND_RME9652=y
CONFIG_SND_SONICVIBES=y
CONFIG_SND_TRIDENT=y
CONFIG_SND_VIA82XX=y
CONFIG_SND_VIA82XX_MODEM=y
CONFIG_SND_VIRTUOSO=y
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set

#
# HD-Audio
#
CONFIG_SND_HDA=y
CONFIG_SND_HDA_INTEL=y
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_RECONFIG=y
# CONFIG_SND_HDA_INPUT_BEEP is not set
CONFIG_SND_HDA_PATCH_LOADER=y
# CONFIG_SND_HDA_CODEC_REALTEK is not set
# CONFIG_SND_HDA_CODEC_ANALOG is not set
CONFIG_SND_HDA_CODEC_SIGMATEL=y
# CONFIG_SND_HDA_CODEC_VIA is not set
CONFIG_SND_HDA_CODEC_HDMI=y
CONFIG_SND_HDA_CODEC_CIRRUS=y
# CONFIG_SND_HDA_CODEC_CONEXANT is not set
CONFIG_SND_HDA_CODEC_CA0110=y
CONFIG_SND_HDA_CODEC_CA0132=y
CONFIG_SND_HDA_CODEC_CA0132_DSP=y
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDA_CORE=y
CONFIG_SND_HDA_DSP_LOADER=y
CONFIG_SND_HDA_EXT_CORE=y
CONFIG_SND_HDA_PREALLOC_SIZE=64
# CONFIG_SND_FIREWIRE is not set
CONFIG_SND_PCMCIA=y
CONFIG_SND_VXPOCKET=y
CONFIG_SND_PDAUDIOCF=y
CONFIG_SND_SOC=y
CONFIG_SND_SOC_AC97_BUS=y
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
CONFIG_SND_SOC_COMPRESS=y
CONFIG_SND_SOC_TOPOLOGY=y
CONFIG_SND_SOC_AMD_ACP=y
# CONFIG_SND_ATMEL_SOC is not set
CONFIG_SND_DESIGNWARE_I2S=y

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
CONFIG_SND_SOC_FSL_ASRC=y
CONFIG_SND_SOC_FSL_SAI=y
# CONFIG_SND_SOC_FSL_SSI is not set
# CONFIG_SND_SOC_FSL_SPDIF is not set
# CONFIG_SND_SOC_FSL_ESAI is not set
CONFIG_SND_SOC_IMX_AUDMUX=y
# CONFIG_SND_SOC_IMG is not set
CONFIG_SND_SST_MFLD_PLATFORM=y
CONFIG_SND_SST_IPC=y
CONFIG_SND_SST_IPC_ACPI=y
CONFIG_SND_SOC_INTEL_SST=y
CONFIG_SND_SOC_INTEL_SST_ACPI=y
CONFIG_SND_SOC_INTEL_SST_MATCH=y
CONFIG_SND_SOC_INTEL_HASWELL=y
CONFIG_SND_SOC_INTEL_HASWELL_MACH=y
# CONFIG_SND_SOC_INTEL_BXT_RT298_MACH is not set
CONFIG_SND_SOC_INTEL_BYTCR_RT5640_MACH=y
# CONFIG_SND_SOC_INTEL_BYTCR_RT5651_MACH is not set
CONFIG_SND_SOC_INTEL_CHT_BSW_RT5672_MACH=y
CONFIG_SND_SOC_INTEL_CHT_BSW_RT5645_MACH=y
# CONFIG_SND_SOC_INTEL_CHT_BSW_MAX98090_TI_MACH is not set
CONFIG_SND_SOC_INTEL_SKYLAKE=y
CONFIG_SND_SOC_INTEL_SKL_RT286_MACH=y
CONFIG_SND_SOC_INTEL_SKL_NAU88L25_SSM4567_MACH=y
CONFIG_SND_SOC_INTEL_SKL_NAU88L25_MAX98357A_MACH=y

#
# Allwinner SoC Audio support
#
# CONFIG_SND_SUN4I_CODEC is not set
CONFIG_SND_SUN4I_SPDIF=y
# CONFIG_SND_SOC_XTFPGA_I2S is not set
CONFIG_SND_SOC_I2C_AND_SPI=y

#
# CODEC drivers
#
CONFIG_SND_SOC_AC97_CODEC=y
CONFIG_SND_SOC_ADAU1701=y
CONFIG_SND_SOC_AK4554=y
CONFIG_SND_SOC_AK4613=y
# CONFIG_SND_SOC_AK4642 is not set
CONFIG_SND_SOC_AK5386=y
CONFIG_SND_SOC_ALC5623=y
CONFIG_SND_SOC_CS35L32=y
# CONFIG_SND_SOC_CS42L51_I2C is not set
# CONFIG_SND_SOC_CS42L52 is not set
# CONFIG_SND_SOC_CS42L56 is not set
# CONFIG_SND_SOC_CS42L73 is not set
# CONFIG_SND_SOC_CS4265 is not set
# CONFIG_SND_SOC_CS4270 is not set
CONFIG_SND_SOC_CS4271=y
CONFIG_SND_SOC_CS4271_I2C=y
CONFIG_SND_SOC_CS42XX8=y
CONFIG_SND_SOC_CS42XX8_I2C=y
# CONFIG_SND_SOC_CS4349 is not set
CONFIG_SND_SOC_DMIC=y
# CONFIG_SND_SOC_ES8328 is not set
CONFIG_SND_SOC_GTM601=y
CONFIG_SND_SOC_HDAC_HDMI=y
CONFIG_SND_SOC_INNO_RK3036=y
CONFIG_SND_SOC_MAX98357A=y
CONFIG_SND_SOC_PCM1681=y
CONFIG_SND_SOC_PCM179X=y
CONFIG_SND_SOC_PCM179X_I2C=y
CONFIG_SND_SOC_PCM3168A=y
CONFIG_SND_SOC_PCM3168A_I2C=y
# CONFIG_SND_SOC_PCM512x_I2C is not set
CONFIG_SND_SOC_RL6231=y
CONFIG_SND_SOC_RL6347A=y
CONFIG_SND_SOC_RT286=y
CONFIG_SND_SOC_RT5616=y
CONFIG_SND_SOC_RT5631=y
CONFIG_SND_SOC_RT5640=y
CONFIG_SND_SOC_RT5645=y
CONFIG_SND_SOC_RT5670=y
# CONFIG_SND_SOC_RT5677_SPI is not set
CONFIG_SND_SOC_SGTL5000=y
CONFIG_SND_SOC_SIGMADSP=y
CONFIG_SND_SOC_SIGMADSP_I2C=y
CONFIG_SND_SOC_SIRF_AUDIO_CODEC=y
CONFIG_SND_SOC_SPDIF=y
# CONFIG_SND_SOC_SSM2602_I2C is not set
CONFIG_SND_SOC_SSM4567=y
CONFIG_SND_SOC_STA32X=y
CONFIG_SND_SOC_STA350=y
CONFIG_SND_SOC_STI_SAS=y
# CONFIG_SND_SOC_TAS2552 is not set
CONFIG_SND_SOC_TAS5086=y
CONFIG_SND_SOC_TAS571X=y
CONFIG_SND_SOC_TAS5720=y
# CONFIG_SND_SOC_TFA9879 is not set
CONFIG_SND_SOC_TLV320AIC23=y
CONFIG_SND_SOC_TLV320AIC23_I2C=y
# CONFIG_SND_SOC_TLV320AIC31XX is not set
# CONFIG_SND_SOC_TLV320AIC3X is not set
CONFIG_SND_SOC_TS3A227E=y
CONFIG_SND_SOC_WM8510=y
CONFIG_SND_SOC_WM8523=y
# CONFIG_SND_SOC_WM8580 is not set
CONFIG_SND_SOC_WM8711=y
CONFIG_SND_SOC_WM8728=y
CONFIG_SND_SOC_WM8731=y
CONFIG_SND_SOC_WM8737=y
CONFIG_SND_SOC_WM8741=y
CONFIG_SND_SOC_WM8750=y
CONFIG_SND_SOC_WM8753=y
CONFIG_SND_SOC_WM8776=y
CONFIG_SND_SOC_WM8804=y
CONFIG_SND_SOC_WM8804_I2C=y
CONFIG_SND_SOC_WM8903=y
CONFIG_SND_SOC_WM8960=y
# CONFIG_SND_SOC_WM8962 is not set
CONFIG_SND_SOC_WM8974=y
CONFIG_SND_SOC_WM8978=y
CONFIG_SND_SOC_NAU8825=y
# CONFIG_SND_SOC_TPA6130A2 is not set
CONFIG_SND_SIMPLE_CARD=y
CONFIG_SOUND_PRIME=y
CONFIG_SOUND_OSS=y
# CONFIG_SOUND_TRACEINIT is not set
CONFIG_SOUND_DMAP=y
CONFIG_SOUND_VMIDI=y
CONFIG_SOUND_TRIX=y
# CONFIG_TRIX_HAVE_BOOT is not set
CONFIG_SOUND_MSS=y
# CONFIG_SOUND_MPU401 is not set
CONFIG_SOUND_PAS=y
CONFIG_PAS_JOYSTICK=y
# CONFIG_SOUND_PSS is not set
# CONFIG_SOUND_SB is not set
CONFIG_SOUND_YM3812=y
# CONFIG_SOUND_UART6850 is not set
CONFIG_SOUND_AEDSP16=y
# CONFIG_SC6600 is not set
CONFIG_AC97_BUS=y

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_PRODIKEYS is not set
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PLANTRONICS is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_RMI is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
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
# CONFIG_UWB_WHCI is not set
# CONFIG_MMC is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
# CONFIG_MEMSTICK_JMICRON_38X is not set
CONFIG_MEMSTICK_R592=y
CONFIG_MEMSTICK_REALTEK_PCI=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y

#
# LED drivers
#
# CONFIG_LEDS_88PM860X is not set
# CONFIG_LEDS_AAT1290 is not set
CONFIG_LEDS_BCM6328=y
CONFIG_LEDS_BCM6358=y
CONFIG_LEDS_LM3530=y
# CONFIG_LEDS_LM3533 is not set
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_LP5562=y
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_LP8860=y
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_WM831X_STATUS is not set
# CONFIG_LEDS_WM8350 is not set
# CONFIG_LEDS_DA903X is not set
CONFIG_LEDS_PWM=y
# CONFIG_LEDS_REGULATOR is not set
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_TLC591XX=y
CONFIG_LEDS_MAX77693=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_MENF21BMC=y
CONFIG_LEDS_KTD2692=y
CONFIG_LEDS_IS31FL32XX=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
CONFIG_LEDS_SYSCON=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_MTD=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
CONFIG_EDAC_DEBUG=y
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_GHES=y
# CONFIG_EDAC_E752X is not set
CONFIG_EDAC_I82975X=y
CONFIG_EDAC_I3000=y
# CONFIG_EDAC_I3200 is not set
# CONFIG_EDAC_IE31200 is not set
CONFIG_EDAC_X38=y
CONFIG_EDAC_I5400=y
# CONFIG_EDAC_I5000 is not set
CONFIG_EDAC_I5100=y
CONFIG_EDAC_I7300=y
CONFIG_RTC_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y
# CONFIG_FSL_EDMA is not set
CONFIG_INTEL_IDMA64=y
CONFIG_INTEL_IOATDMA=y
CONFIG_INTEL_MIC_X100_DMA=y
CONFIG_QCOM_HIDMA_MGMT=y
CONFIG_QCOM_HIDMA=y
CONFIG_DW_DMAC_CORE=y
# CONFIG_DW_DMAC is not set
CONFIG_DW_DMAC_PCI=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
# CONFIG_SYNC_FILE is not set
CONFIG_DCA=y
CONFIG_AUXDISPLAY=y
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
CONFIG_UIO_AEC=y
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=y
# CONFIG_UIO_NETX is not set
CONFIG_UIO_PRUSS=y
CONFIG_UIO_MF624=y
CONFIG_VFIO_IOMMU_TYPE1=y
CONFIG_VFIO_VIRQFD=y
CONFIG_VFIO=y
# CONFIG_VFIO_NOIOMMU is not set
CONFIG_VFIO_PCI=y
CONFIG_VFIO_PCI_MMAP=y
CONFIG_VFIO_PCI_INTX=y
CONFIG_VFIO_PCI_IGD=y
CONFIG_IRQ_BYPASS_MANAGER=y
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_INPUT is not set
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
CONFIG_SLICOSS=y

#
# IIO staging drivers
#

#
# Accelerometers
#

#
# Analog to digital converters
#
# CONFIG_AD7606 is not set

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
# CONFIG_ADT7316_I2C is not set

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
CONFIG_AD7152=y
# CONFIG_AD7746 is not set

#
# Direct Digital Synthesis
#

#
# Digital gyroscope sensors
#

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=y

#
# Light sensors
#
CONFIG_SENSORS_ISL29018=y
CONFIG_SENSORS_ISL29028=y
# CONFIG_TSL2583 is not set
CONFIG_TSL2x7x=y

#
# Active energy metering IC
#
CONFIG_ADE7854=y
# CONFIG_ADE7854_I2C is not set

#
# Resolver to digital converters
#

#
# Triggers - standalone
#
# CONFIG_FB_SM750 is not set
CONFIG_FB_XGI=y

#
# Speakup console speech
#
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
CONFIG_STAGING_BOARD=y
# CONFIG_FIREWIRE_SERIAL is not set
# CONFIG_DGNC is not set
# CONFIG_GS_FPGABOOT is not set
CONFIG_CRYPTO_SKEIN=y
# CONFIG_UNISYSSPAR is not set
CONFIG_COMMON_CLK_XLNX_CLKWZRD=y
CONFIG_MOST=y
CONFIG_MOSTCORE=y
# CONFIG_AIM_CDEV is not set
CONFIG_AIM_NETWORK=y
CONFIG_AIM_SOUND=y
CONFIG_HDM_DIM2=y
CONFIG_HDM_I2C=y

#
# Old ISDN4Linux (deprecated)
#
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_PSTORE=y
CONFIG_CROS_EC_CHARDEV=y
# CONFIG_CROS_EC_LPC is not set
CONFIG_CROS_EC_PROTO=y
CONFIG_CROS_KBD_LED_BACKLIGHT=y
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_WM831X is not set
CONFIG_COMMON_CLK_RK808=y
CONFIG_COMMON_CLK_SI5351=y
CONFIG_COMMON_CLK_SI514=y
# CONFIG_COMMON_CLK_SI570 is not set
CONFIG_COMMON_CLK_CDCE706=y
# CONFIG_COMMON_CLK_CDCE925 is not set
CONFIG_COMMON_CLK_CS2000_CP=y
CONFIG_CLK_TWL6040=y
# CONFIG_COMMON_CLK_NXP is not set
CONFIG_COMMON_CLK_PWM=y
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set
CONFIG_COMMON_CLK_OXNAS=y

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
CONFIG_MAILBOX_TEST=y
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
CONFIG_IOMMU_IOVA=y
CONFIG_OF_IOMMU=y
CONFIG_AMD_IOMMU=y
# CONFIG_AMD_IOMMU_V2 is not set
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_SVM is not set
# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
CONFIG_IRQ_REMAP=y

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_SUNXI_SRAM is not set
# CONFIG_SOC_TI is not set
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
# CONFIG_EXTCON_ARIZONA is not set
CONFIG_EXTCON_GPIO=y
# CONFIG_EXTCON_MAX14577 is not set
CONFIG_EXTCON_MAX3355=y
# CONFIG_EXTCON_MAX77693 is not set
CONFIG_EXTCON_RT8973A=y
CONFIG_EXTCON_SM5502=y
CONFIG_EXTCON_USB_GPIO=y
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
CONFIG_IIO_SW_TRIGGER=y

#
# Accelerometers
#
CONFIG_BMA180=y
CONFIG_BMC150_ACCEL=y
CONFIG_BMC150_ACCEL_I2C=y
CONFIG_IIO_ST_ACCEL_3AXIS=y
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=y
CONFIG_KXCJK1013=y
CONFIG_MMA7455=y
CONFIG_MMA7455_I2C=y
CONFIG_MMA8452=y
CONFIG_MMA9551_CORE=y
CONFIG_MMA9551=y
CONFIG_MMA9553=y
CONFIG_MXC4005=y
# CONFIG_MXC6255 is not set
# CONFIG_STK8312 is not set
CONFIG_STK8BA50=y

#
# Analog to digital converters
#
CONFIG_AD7291=y
CONFIG_AD799X=y
CONFIG_AXP288_ADC=y
CONFIG_CC10001_ADC=y
CONFIG_DA9150_GPADC=y
# CONFIG_LP8788_ADC is not set
CONFIG_MAX1363=y
CONFIG_MCP3422=y
# CONFIG_MEN_Z188_ADC is not set
# CONFIG_NAU7802 is not set
CONFIG_QCOM_SPMI_IADC=y
CONFIG_QCOM_SPMI_VADC=y
# CONFIG_TI_ADC081C is not set
# CONFIG_TWL4030_MADC is not set
# CONFIG_TWL6030_GPADC is not set
CONFIG_VF610_ADC=y

#
# Amplifiers
#

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=y
# CONFIG_IAQCORE is not set
CONFIG_VZ89X=y

#
# Hid Sensor IIO Common
#
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
# CONFIG_AD5064 is not set
CONFIG_AD5380=y
CONFIG_AD5446=y
CONFIG_AD5592R_BASE=y
CONFIG_AD5593R=y
# CONFIG_M62332 is not set
CONFIG_MAX517=y
# CONFIG_MAX5821 is not set
CONFIG_MCP4725=y
# CONFIG_VF610_DAC is not set

#
# IIO dummy driver
#
# CONFIG_IIO_SIMPLE_DUMMY is not set

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
CONFIG_BMG160=y
CONFIG_BMG160_I2C=y
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
CONFIG_ITG3200=y

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4404=y
CONFIG_MAX30100=y

#
# Humidity sensors
#
CONFIG_AM2315=y
CONFIG_DHT11=y
# CONFIG_HDC100X is not set
# CONFIG_HTU21 is not set
CONFIG_SI7005=y
CONFIG_SI7020=y

#
# Inertial measurement units
#
CONFIG_BMI160=y
CONFIG_BMI160_I2C=y
CONFIG_KMX61=y

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
CONFIG_ADJD_S311=y
CONFIG_AL3320A=y
CONFIG_APDS9300=y
CONFIG_APDS9960=y
# CONFIG_BH1750 is not set
# CONFIG_CM32181 is not set
CONFIG_CM3232=y
# CONFIG_CM3323 is not set
CONFIG_CM36651=y
CONFIG_GP2AP020A00F=y
CONFIG_ISL29125=y
CONFIG_JSA1212=y
CONFIG_RPR0521=y
# CONFIG_SENSORS_LM3533 is not set
CONFIG_LTR501=y
# CONFIG_MAX44000 is not set
CONFIG_OPT3001=y
# CONFIG_PA12203001 is not set
# CONFIG_STK3310 is not set
# CONFIG_TCS3414 is not set
CONFIG_TCS3472=y
CONFIG_SENSORS_TSL2563=y
# CONFIG_TSL4531 is not set
CONFIG_US5182D=y
CONFIG_VCNL4000=y
CONFIG_VEML6070=y

#
# Magnetometer sensors
#
CONFIG_AK8975=y
CONFIG_AK09911=y
CONFIG_BMC150_MAGN=y
CONFIG_BMC150_MAGN_I2C=y
CONFIG_MAG3110=y
CONFIG_MMC35240=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y
# CONFIG_SENSORS_HMC5843_I2C is not set

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
CONFIG_IIO_HRTIMER_TRIGGER=y
CONFIG_IIO_INTERRUPT_TRIGGER=y
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Digital potentiometers
#
CONFIG_DS1803=y
CONFIG_MCP4531=y
# CONFIG_TPL0102 is not set

#
# Pressure sensors
#
CONFIG_HP03=y
# CONFIG_MPL115_I2C is not set
# CONFIG_MPL3115 is not set
CONFIG_MS5611=y
# CONFIG_MS5611_I2C is not set
CONFIG_MS5637=y
# CONFIG_IIO_ST_PRESS is not set
CONFIG_T5403=y
# CONFIG_HP206C is not set

#
# Lightning sensors
#

#
# Proximity sensors
#
# CONFIG_LIDAR_LITE_V2 is not set
CONFIG_SX9500=y

#
# Temperature sensors
#
CONFIG_MLX90614=y
# CONFIG_TMP006 is not set
# CONFIG_TSYS01 is not set
CONFIG_TSYS02D=y
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_CRC is not set
# CONFIG_PWM_FSL_FTM is not set
# CONFIG_PWM_LP3943 is not set
CONFIG_PWM_LPSS=y
CONFIG_PWM_LPSS_PCI=y
# CONFIG_PWM_LPSS_PLATFORM is not set
CONFIG_PWM_PCA9685=y
# CONFIG_PWM_TWL is not set
CONFIG_PWM_TWL_LED=y
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
# CONFIG_SERIAL_IPOCTAL is not set
# CONFIG_RESET_CONTROLLER is not set
CONFIG_FMC=y
# CONFIG_FMC_FAKEDEV is not set
# CONFIG_FMC_TRIVIAL is not set
# CONFIG_FMC_WRITE_EEPROM is not set
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_PHY_PXA_28NM_HSIC is not set
# CONFIG_PHY_PXA_28NM_USB2 is not set
# CONFIG_BCM_KONA_USB2_PHY is not set
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=y
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set

#
# Performance monitor support
#
CONFIG_RAS=y
CONFIG_THUNDERBOLT=y

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_NVMEM=y
CONFIG_STM=y
CONFIG_STM_DUMMY=y
CONFIG_STM_SOURCE_CONSOLE=y
# CONFIG_STM_SOURCE_HEARTBEAT is not set
CONFIG_INTEL_TH=y
CONFIG_INTEL_TH_PCI=y
CONFIG_INTEL_TH_GTH=y
# CONFIG_INTEL_TH_STH is not set
# CONFIG_INTEL_TH_MSU is not set
CONFIG_INTEL_TH_PTI=y
# CONFIG_INTEL_TH_DEBUG is not set

#
# FPGA Configuration Support
#
CONFIG_FPGA=y
CONFIG_FPGA_MGR_ZYNQ_FPGA=y

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_FW_CFG_SYSFS is not set
# CONFIG_GOOGLE_FIRMWARE is not set
CONFIG_UEFI_CPER=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_OVERLAY_FS=y

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
# CONFIG_PROC_CHILDREN is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
CONFIG_ECRYPT_FS=y
# CONFIG_ECRYPT_FS_MESSAGING is not set
# CONFIG_JFFS2_FS is not set
CONFIG_UBIFS_FS=y
# CONFIG_UBIFS_FS_ADVANCED_COMPR is not set
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
CONFIG_UBIFS_ATIME_SUPPORT=y
# CONFIG_LOGFS is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_MTD=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
CONFIG_PSTORE_CONSOLE=y
CONFIG_PSTORE_PMSG=y
CONFIG_PSTORE_RAM=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_FSCACHE is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFSD is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
CONFIG_CEPH_FS=y
CONFIG_CEPH_FSCACHE=y
# CONFIG_CEPH_FS_POSIX_ACL is not set
CONFIG_CIFS=y
CONFIG_CIFS_STATS=y
CONFIG_CIFS_STATS2=y
# CONFIG_CIFS_WEAK_PW_HASH is not set
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
CONFIG_CIFS_ACL=y
CONFIG_CIFS_DEBUG=y
CONFIG_CIFS_DEBUG2=y
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_SMB2 is not set
# CONFIG_CIFS_FSCACHE is not set
CONFIG_NCP_FS=y
# CONFIG_NCPFS_PACKET_SIGNING is not set
# CONFIG_NCPFS_IOCTL_LOCKING is not set
# CONFIG_NCPFS_STRONG is not set
# CONFIG_NCPFS_NFS_NS is not set
# CONFIG_NCPFS_OS2_NS is not set
CONFIG_NCPFS_SMALLDOS=y
CONFIG_NCPFS_NLS=y
CONFIG_NCPFS_EXTRAS=y
# CONFIG_CODA_FS is not set
CONFIG_AFS_FS=y
# CONFIG_AFS_DEBUG is not set
CONFIG_AFS_FSCACHE=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
# CONFIG_NLS_MAC_ROMANIAN is not set
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y
CONFIG_DLM=y
CONFIG_DLM_DEBUG=y

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
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
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
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
CONFIG_DEBUG_OBJECTS_TIMERS=y
CONFIG_DEBUG_OBJECTS_WORK=y
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_SLUB_DEBUG_ON=y
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
# CONFIG_DEBUG_VM_RB is not set
# CONFIG_DEBUG_VM_PGFLAGS is not set
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=y
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
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
# CONFIG_WQ_WATCHDOG is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHED_INFO is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set
# CONFIG_TIMER_STATS is not set
CONFIG_DEBUG_PREEMPT=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
# CONFIG_PROVE_RCU_REPEATEDLY is not set
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST_RUNNABLE is not set
# CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT is not set
CONFIG_RCU_TORTURE_TEST_SLOW_INIT=y
CONFIG_RCU_TORTURE_TEST_SLOW_INIT_DELAY=3
# CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
CONFIG_RCU_EQS_DEBUG=y
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
CONFIG_CPU_HOTPLUG_STATE_CONTROL=y
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_CPU_NOTIFIER_ERROR_INJECT=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
CONFIG_OF_RECONFIG_NOTIFIER_ERROR_INJECT=y
CONFIG_NETDEV_NOTIFIER_ERROR_INJECT=y
# CONFIG_FAULT_INJECTION is not set
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
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_TEST_HEXDUMP is not set
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
CONFIG_TEST_PRINTF=y
CONFIG_TEST_BITMAP=y
CONFIG_TEST_UUID=y
CONFIG_TEST_RHASHTABLE=y
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
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
# CONFIG_UBSAN_ALIGNMENT is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
CONFIG_IO_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
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
CONFIG_OPTIMIZE_INLINING=y
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
# CONFIG_ENCRYPTED_KEYS is not set
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_INTEL_TXT=y
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
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
# CONFIG_CRYPTO_PCRYPT is not set
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
# CONFIG_CRYPTO_KEYWRAP is not set

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
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA1_MB=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
# CONFIG_CRYPTO_WP512 is not set
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_DES3_EDE_X86_64=y
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
CONFIG_CRYPTO_CHACHA20=y
# CONFIG_CRYPTO_CHACHA20_X86_64 is not set
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
# CONFIG_CRYPTO_TWOFISH_X86_64_3WAY is not set
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4=y
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
# CONFIG_X509_CERTIFICATE_PARSER is not set

#
# Certificates for signature checking
#
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
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
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
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
# CONFIG_CRC8 is not set
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_LIBFDT=y
CONFIG_OID_REGISTRY=y
# CONFIG_SG_SPLIT is not set
# CONFIG_SG_POOL is not set
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_STACKDEPOT=y

--wac7ysb48OaltWcw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
