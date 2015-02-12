Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 23F286B0032
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 04:08:43 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id em10so2551110wid.1
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 01:08:42 -0800 (PST)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0612.outbound.protection.outlook.com. [2a01:111:f400:fe00::612])
        by mx.google.com with ESMTPS id i4si5932932wjw.15.2015.02.12.01.08.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 12 Feb 2015 01:08:27 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: Stuck/not-responding machine when running trinity on next-20150204,
 ext4 disk corruption
Date: Thu, 12 Feb 2015 09:08:12 +0000
Message-ID: <AM3PR05MB093539EE459481B5595CF31BDC220@AM3PR05MB0935.eurprd05.prod.outlook.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,

I have been running trinity inside a VM with kernel
next-20150204. After some run time, the machine gets stuck. On next
reboot, fsck complains about file system consistency issues. When
printing out process list using sysrq-t, I get the following:

[177146.661173] sysrq: SysRq : Manual OOM execution
[177166.531972] sysrq: SysRq : Show State
[177166.532023]   task                        PC stack   pid father
[177166.532023] systemd         R  running task     8632     1      0 0x100=
00000
[177166.532023]  ffff88007e06f7a8 000000010a8ac4e2 ffff88007e06ffd8 0000000=
0001d6240
[177166.532023]  ffff88007a2a9b90 0000000000000292 ffff88007e06f7e8 fffffff=
f82fa59c0
[177166.532023]  000000010a8ac4e2 ffff88007e06f828 0000000000000000 ffff880=
07e06f7b8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff811dca75>] ? try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023]  [<ffffffff812a2867>] ? ep_send_events_proc+0xd7/0x2f0
[177166.532023]  [<ffffffff812a285c>] ? ep_send_events_proc+0xcc/0x2f0
[177166.532023]  [<ffffffff812a2790>] ? ep_poll+0x390/0x390
[177166.532023]  [<ffffffff812a21fc>] ? ep_scan_ready_list+0xac/0x280
[177166.532023]  [<ffffffff812a2538>] ? ep_poll+0x138/0x390
[177166.532023]  [<ffffffff810c37f0>] ? wake_up_state+0x20/0x20
[177166.532023]  [<ffffffff812a3ce5>] ? SyS_epoll_wait+0xb5/0xe0
[177166.532023]  [<ffffffff8176857a>] ? tracesys_phase2+0xd8/0xdd
[177166.532023] kthreadd        R  running task    10616     2      0 0x100=
00000
[177166.532023]  ffff88007e117a48 000000010a8ac501 ffff88007e117fd8 0000000=
0001d6240
[177166.532023]  ffff880079b51b90 ffff8800833d6880 ffffffff811c5708 0000000=
0000f96e2
[177166.532023]  ffff88007e117ad8 ffffffff82fa59c0 0000000000000000 ffff880=
07e117a58
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff811cd94d>] alloc_kmem_pages_node+0x6d/0x130
[177166.532023]  [<ffffffff81086093>] copy_process.part.23+0x133/0x1e80
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff81087f91>] do_fork+0xd1/0x7c0
[177166.532023]  [<ffffffff810b162b>] ? kthreadd+0x33b/0x3d0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff810b162b>] ? kthreadd+0x33b/0x3d0
[177166.532023]  [<ffffffff810886a6>] kernel_thread+0x26/0x30
[177166.532023]  [<ffffffff810b164c>] kthreadd+0x35c/0x3d0
[177166.532023]  [<ffffffff817682bc>] ? ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b12f0>] ? kthread_create_on_cpu+0x70/0x70
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b12f0>] ? kthread_create_on_cpu+0x70/0x70
[177166.532023] ksoftirqd/0     S ffff88007e11fdc8 13368     3      2 0x100=
00000
[177166.532023]  ffff88007e11fdc8 ffff88007e071b90 ffff88007e11ffd8 0000000=
0001d6240
[177166.532023]  ffff88007a2a8000 ffff88007e11fdc8 ffff88007e071b90 ffff880=
07ed37428
[177166.532023]  ffffffff81c40cc0 ffff88007e071b90 ffff88007e071b90 ffff880=
07e11fdd8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810b5afc>] smpboot_thread_fn+0x1ac/0x240
[177166.532023]  [<ffffffff810b5950>] ? cpumask_next+0x50/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff81762872>] ? wait_for_completion+0x112/0x140
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kworker/0:0H    S ffff88007e137db8 12488     5      2 0x100=
00000
[177166.532023]  ffff88007e137db8 ffff88007eccb0f0 ffff88007e137fd8 0000000=
0001d6240
[177166.532023]  ffff88007aa99b90 ffff8800815d5c80 ffff8800815d5c80 ffff880=
0815d5c80
[177166.532023]  ffff88007eccb0f0 ffff88007e138000 ffff88007eccb0c0 ffff880=
07e137dc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] rcu_sched       S ffff88007e157d68 13672     7      2 0x100=
00000
[177166.532023]  ffff88007e157d68 ffff88007e157dd8 ffff88007e157fd8 0000000=
0001d6240
[177166.532023]  ffff88007e160000 00000000000007c9 ffffffff81c95b40 fffffff=
f81cd6da0
[177166.532023]  ffff8800817d7080 0000000000000000 ffffffff81c95b40 ffff880=
07e157d78
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8110b7ba>] rcu_gp_kthread+0xba/0xaf0
[177166.532023]  [<ffffffff810b7872>] ? finish_task_switch+0x52/0x170
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8110b700>] ? force_qs_rnp+0x190/0x190
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] rcu_bh          S ffff88007e15bd68 14832     8      2 0x100=
00000
[177166.532023]  ffff88007e15bd68 ffff88007e15bdd8 ffff88007e15bfd8 0000000=
0001d6240
[177166.532023]  ffff88007e160000 00000000000007c9 ffffffff81c545c0 fffffff=
f81c95820
[177166.532023]  ffffffff8110b700 0000000000000000 0000000000000000 ffff880=
07e15bd78
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff8110b700>] ? force_qs_rnp+0x190/0x190
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8110b7ba>] rcu_gp_kthread+0xba/0xaf0
[177166.532023]  [<ffffffff810b7872>] ? finish_task_switch+0x52/0x170
[177166.532023]  [<ffffffff81760a84>] ? __schedule+0x2c4/0x7b0
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8110b700>] ? force_qs_rnp+0x190/0x190
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] rcuos/0         S ffff88007e15fd78 13944     9      2 0x100=
00000
[177166.532023]  ffff88007e15fd78 ffff88007e15fdd8 ffff88007e15ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e1e8000 0000000000000854 ffff8800815d71f8 ffff880=
0815d7080
[177166.532023]  0000000000000001 ffff88007e160000 0000000000000292 ffff880=
07e15fd88
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8110b132>] rcu_nocb_kthread+0x4d2/0x630
[177166.532023]  [<ffffffff8110adf2>] ? rcu_nocb_kthread+0x192/0x630
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8110ac60>] ? rcu_lockdep_current_cpu_online+0x30=
/0x30
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] rcuob/0         S ffff88007e16bd78 14608    10      2 0x100=
00000
[177166.532023]  ffff88007e16bd78 ffff88007e16bdd8 ffff88007e16bfd8 0000000=
0001d6240
[177166.532023]  ffff88007e070000 0000000000000854 ffff8800815d6f78 ffff880=
0815d6e00
[177166.532023]  ffff88007e1652b0 ffff88007e1652b0 0000000000000000 ffff880=
07e16bd88
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8110b132>] rcu_nocb_kthread+0x4d2/0x630
[177166.532023]  [<ffffffff81760a84>] ? __schedule+0x2c4/0x7b0
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8110ac60>] ? rcu_lockdep_current_cpu_online+0x30=
/0x30
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] migration/0     S ffff88007e16fdc8 14184    11      2 0x100=
00000
[177166.532023]  ffff88007e16fdc8 0000000000000296 ffff88007e16ffd8 0000000=
0001d6240
[177166.532023]  ffff88000fcd3720 ffff88007e16fdb8 ffff88007e161b90 ffff880=
07ed372d0
[177166.532023]  ffffffff81ce17e0 ffff88007e161b90 ffff88007e161b90 ffff880=
07e16fdd8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810b5afc>] smpboot_thread_fn+0x1ac/0x240
[177166.532023]  [<ffffffff810b5950>] ? cpumask_next+0x50/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff81762872>] ? wait_for_completion+0x112/0x140
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] watchdog/0      S ffff88007e193dc8 13896    12      2 0x100=
00000
[177166.532023]  ffff88007e193dc8 00000000001d6d40 ffff88007e193fd8 0000000=
0001d6240
[177166.532023]  ffff88007a8d52b0 ffff88007e163720 ffff88007e163720 ffff880=
07e18a810
[177166.532023]  ffffffff81ce28a0 ffff88007e163720 ffff88007e163720 ffff880=
07e193dd8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810b5afc>] smpboot_thread_fn+0x1ac/0x240
[177166.532023]  [<ffffffff810b5950>] ? cpumask_next+0x50/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff81762872>] ? wait_for_completion+0x112/0x140
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] watchdog/1      S ffff88007e1b7dc8 14184    13      2 0x100=
00000
[177166.532023]  ffff88007e1b7dc8 00000000001d6d40 ffff88007e1b7fd8 0000000=
0001d6240
[177166.532023]  ffff880073703720 ffff88007e19b720 ffff88007e19b720 ffff880=
07e18a968
[177166.532023]  ffffffff81ce28a0 ffff88007e19b720 ffff88007e19b720 ffff880=
07e1b7dd8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810b5afc>] smpboot_thread_fn+0x1ac/0x240
[177166.532023]  [<ffffffff810b5950>] ? cpumask_next+0x50/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff81762872>] ? wait_for_completion+0x112/0x140
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] migration/1     S ffff88007e1c3dc8 14184    14      2 0x100=
00000
[177166.532023]  ffff88007e1c3dc8 0000000000000296 ffff88007e1c3fd8 0000000=
0001d6240
[177166.532023]  ffff88006391b720 ffff88007e1c3db8 ffff88007e1b8000 ffff880=
07e18b580
[177166.532023]  ffffffff81ce17e0 ffff88007e1b8000 ffff88007e1b8000 ffff880=
07e1c3dd8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810b5afc>] smpboot_thread_fn+0x1ac/0x240
[177166.532023]  [<ffffffff810b5950>] ? cpumask_next+0x50/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff81762872>] ? wait_for_completion+0x112/0x140
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] ksoftirqd/1     S ffff88007e1d3dc8 12008    15      2 0x100=
00000
[177166.532023]  ffff88007e1d3dc8 ffff88007e1bd2b0 ffff88007e1d3fd8 0000000=
0001d6240
[177166.532023]  ffff880076b952b0 ffff88007e1d3dc8 ffff88007e1bd2b0 ffff880=
07e18aac0
[177166.532023]  ffffffff81c40cc0 ffff88007e1bd2b0 ffff88007e1bd2b0 ffff880=
07e1d3dd8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810b5afc>] smpboot_thread_fn+0x1ac/0x240
[177166.532023]  [<ffffffff810b5950>] ? cpumask_next+0x50/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff81762872>] ? wait_for_completion+0x112/0x140
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kworker/1:0H    S ffff88007e1e3db8 13576    17      2 0x100=
00000
[177166.532023]  ffff88007e1e3db8 ffff88007ecc9070 ffff88007e1e3fd8 0000000=
0001d6240
[177166.532023]  ffff880079b50000 ffff8800817d5c80 ffff8800817d5c80 ffff880=
0817d5c80
[177166.532023]  ffff88007ecc9070 ffff88007e1bb720 ffff88007ecc9040 ffff880=
07e1e3dc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] rcuos/1         S ffff88007e1e7d78 13656    18      2 0x100=
00000
[177166.532023]  ffff88007e1e7d78 ffff88007e1e7dd8 ffff88007e1e7fd8 0000000=
0001d6240
[177166.532023]  ffff880073738000 00000000000008b4 ffff8800817d71f8 ffff880=
0817d7080
[177166.532023]  ffff88007e1e8000 ffffffff8138fee0 ffff8800560fce28 ffff880=
07e1e7d88
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff8138fee0>] ? radix_tree_maybe_preload+0x20/0x20
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8110ad52>] rcu_nocb_kthread+0xf2/0x630
[177166.532023]  [<ffffffff8110adf2>] ? rcu_nocb_kthread+0x192/0x630
[177166.532023]  [<ffffffff81760a84>] ? __schedule+0x2c4/0x7b0
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8110ac60>] ? rcu_lockdep_current_cpu_online+0x30=
/0x30
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] rcuob/1         S ffff88007e1f3d78 14848    19      2 0x100=
00000
[177166.532023]  ffff88007e1f3d78 ffff88007e1f3dd8 ffff88007e1f3fd8 0000000=
0001d6240
[177166.532023]  ffff88007e070000 00000000000008b4 ffff8800817d6f78 ffff880=
0817d6e00
[177166.532023]  ffff88007e1ed2b0 0000000000000000 0000000000000000 ffff880=
07e1f3d88
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8110ad52>] rcu_nocb_kthread+0xf2/0x630
[177166.532023]  [<ffffffff81760a84>] ? __schedule+0x2c4/0x7b0
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8110ac60>] ? rcu_lockdep_current_cpu_online+0x30=
/0x30
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] watchdog/2      S ffff88007e1fbdc8 14184    20      2 0x100=
00000
[177166.532023]  ffff88007e1fbdc8 00000000001d6d40 ffff88007e1fbfd8 0000000=
0001d6240
[177166.532023]  ffff88007ca83720 ffff88007e1e9b90 ffff88007e1e9b90 ffff880=
07e18b428
[177166.532023]  ffffffff81ce28a0 ffff88007e1e9b90 ffff88007e1e9b90 ffff880=
07e1fbdd8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810b5afc>] smpboot_thread_fn+0x1ac/0x240
[177166.532023]  [<ffffffff810b5950>] ? cpumask_next+0x50/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff81762872>] ? wait_for_completion+0x112/0x140
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] migration/2     S ffff88007e1ffdc8 14184    21      2 0x100=
00000
[177166.532023]  ffff88007e1ffdc8 0000000000000296 ffff88007e1fffd8 0000000=
0001d6240
[177166.532023]  ffff88006d429b90 ffff88007e1ffdb8 ffff88007e1eb720 ffff880=
07e18ac18
[177166.532023]  ffffffff81ce17e0 ffff88007e1eb720 ffff88007e1eb720 ffff880=
07e1ffdd8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810b5afc>] smpboot_thread_fn+0x1ac/0x240
[177166.532023]  [<ffffffff810b5950>] ? cpumask_next+0x50/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff81762872>] ? wait_for_completion+0x112/0x140
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] ksoftirqd/2     S ffff88007e20bdc8 12280    22      2 0x100=
00000
[177166.532023]  ffff88007e20bdc8 ffff88007e200000 ffff88007e20bfd8 0000000=
0001d6240
[177166.532023]  ffff88007a063720 ffff88007e20bdc8 ffff88007e200000 ffff880=
07e18b2d0
[177166.532023]  ffffffff81c40cc0 ffff88007e200000 ffff88007e200000 ffff880=
07e20bdd8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810b5afc>] smpboot_thread_fn+0x1ac/0x240
[177166.532023]  [<ffffffff810b5950>] ? cpumask_next+0x50/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff81762872>] ? wait_for_completion+0x112/0x140
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kworker/2:0H    S ffff88007e223db8 13576    24      2 0x100=
00000
[177166.532023]  ffff88007e223db8 ffff88007ecc9278 ffff88007e223fd8 0000000=
0001d6240
[177166.532023]  ffff8800750f3720 ffff8800819d5c80 ffff8800819d5c80 ffff880=
0819d5c80
[177166.532023]  ffff88007ecc9278 ffff88007e201b90 ffff88007ecc9248 ffff880=
07e223dc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] rcuos/2         S ffff88007e227d78 13944    25      2 0x100=
00000
[177166.532023]  ffff88007e227d78 ffff88007e227dd8 ffff88007e227fd8 0000000=
0001d6240
[177166.532023]  ffff88007e1e8000 0000000000000854 ffff8800819d71f8 ffff880=
0819d7080
[177166.532023]  ffff88007e203720 ffff88007e203720 ffff88006840b500 ffff880=
07e227d88
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8110b132>] rcu_nocb_kthread+0x4d2/0x630
[177166.532023]  [<ffffffff8110adf2>] ? rcu_nocb_kthread+0x192/0x630
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8110ac60>] ? rcu_lockdep_current_cpu_online+0x30=
/0x30
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] rcuob/2         S ffff88007e233d78 14608    26      2 0x100=
00000
[177166.532023]  ffff88007e233d78 ffff88007e233dd8 ffff88007e233fd8 0000000=
0001d6240
[177166.532023]  ffff88007e070000 0000000000000854 ffff8800819d6f78 ffff880=
0819d6e00
[177166.532023]  ffff88007e228000 ffff88007e228000 0000000000000000 ffff880=
07e233d88
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8110b132>] rcu_nocb_kthread+0x4d2/0x630
[177166.532023]  [<ffffffff81760a84>] ? __schedule+0x2c4/0x7b0
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8110ac60>] ? rcu_lockdep_current_cpu_online+0x30=
/0x30
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] watchdog/3      S ffff88007e23fdc8 14184    27      2 0x100=
00000
[177166.532023]  ffff88007e23fdc8 00000000001d6d40 ffff88007e23ffd8 0000000=
0001d6240
[177166.532023]  ffff880077490000 ffff88007e22d2b0 ffff88007e22d2b0 ffff880=
07e18ad70
[177166.532023]  ffffffff81ce28a0 ffff88007e22d2b0 ffff88007e22d2b0 ffff880=
07e23fdd8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810b5afc>] smpboot_thread_fn+0x1ac/0x240
[177166.532023]  [<ffffffff810b5950>] ? cpumask_next+0x50/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff81762872>] ? wait_for_completion+0x112/0x140
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] migration/3     S ffff88007e243dc8 14184    28      2 0x100=
00000
[177166.532023]  ffff88007e243dc8 0000000000000296 ffff88007e243fd8 0000000=
0001d6240
[177166.532023]  ffff88006d42d2b0 ffff88007e243db8 ffff88007e229b90 ffff880=
07e18b178
[177166.532023]  ffffffff81ce17e0 ffff88007e229b90 ffff88007e229b90 ffff880=
07e243dd8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810b5afc>] smpboot_thread_fn+0x1ac/0x240
[177166.532023]  [<ffffffff810b5950>] ? cpumask_next+0x50/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff81762872>] ? wait_for_completion+0x112/0x140
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] ksoftirqd/3     S ffff88007e247dc8 13192    29      2 0x100=
00000
[177166.532023]  ffff88007e247dc8 ffff88007e22b720 ffff88007e247fd8 0000000=
0001d6240
[177166.532023]  ffff880063d31b90 ffff88007e247dc8 ffff88007e22b720 ffff880=
07e18aec8
[177166.532023]  ffffffff81c40cc0 ffff88007e22b720 ffff88007e22b720 ffff880=
07e247dd8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810b5afc>] smpboot_thread_fn+0x1ac/0x240
[177166.532023]  [<ffffffff810b5950>] ? cpumask_next+0x50/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff81762872>] ? wait_for_completion+0x112/0x140
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kworker/3:0H    S ffff88007e25fdb8 13168    31      2 0x100=
00000
[177166.532023]  ffff88007e25fdb8 ffff88007ecc9480 ffff88007e25ffd8 0000000=
0001d6240
[177166.532023]  ffff880075008000 ffff880081bd5c80 ffff880081bd5c80 ffff880=
081bd5c80
[177166.532023]  ffff88007ecc9480 ffff88007e2552b0 ffff88007ecc9450 ffff880=
07e25fdc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] rcuos/3         S ffff88007e26fd78 13952    32      2 0x100=
00000
[177166.532023]  ffff88007e26fd78 ffff88007e26fdd8 ffff88007e26ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e1e8000 00000000000008b4 ffff880081bd71f8 ffff880=
081bd7080
[177166.532023]  ffff88007e251b90 ffffffff8138fee0 ffff88007b42ce28 ffff880=
07e26fd88
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff8138fee0>] ? radix_tree_maybe_preload+0x20/0x20
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8110ad52>] rcu_nocb_kthread+0xf2/0x630
[177166.532023]  [<ffffffff8110adf2>] ? rcu_nocb_kthread+0x192/0x630
[177166.532023]  [<ffffffff81760a84>] ? __schedule+0x2c4/0x7b0
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8110ac60>] ? rcu_lockdep_current_cpu_online+0x30=
/0x30
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] rcuob/3         S ffff88007e273d78 14848    33      2 0x100=
00000
[177166.532023]  ffff88007e273d78 ffff88007e273dd8 ffff88007e273fd8 0000000=
0001d6240
[177166.532023]  ffff88007e070000 00000000000008b4 ffff880081bd6f78 ffff880=
081bd6e00
[177166.532023]  ffff88007e253720 0000000000000000 0000000000000000 ffff880=
07e273d88
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8110ad52>] rcu_nocb_kthread+0xf2/0x630
[177166.532023]  [<ffffffff81760a84>] ? __schedule+0x2c4/0x7b0
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8110ac60>] ? rcu_lockdep_current_cpu_online+0x30=
/0x30
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] khelper         S ffff88007e2d3d88 10200    34      2 0x100=
00000
[177166.532023]  ffff88007e2d3d88 ffff88007e153c00 ffff88007e2d3fd8 0000000=
0001d6240
[177166.532023]  ffff880062b5d2b0 ffffffff81c4b120 ffff88007ecca8a0 ffff880=
07ec4c150
[177166.532023]  ffff88007e153c00 ffff88007ec4c0f8 ffff88007e04e1d0 ffff880=
07e2d3d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kdevtmpfs       S ffff88007e2d7dd8 12944    35      2 0x100=
00000
[177166.532023]  ffff88007e2d7dd8 ffff88007e2d7d98 ffff88007e2d7fd8 0000000=
0001d6240
[177166.532023]  ffff88004f5cd2b0 0000000000000000 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007e2cd2b0 0000000000000000 0000000000000000 ffff880=
07e2d7de8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff814dc339>] devtmpfsd+0x179/0x190
[177166.532023]  [<ffffffff814dc1c0>] ? handle_create.isra.2+0x240/0x240
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] netns           S ffff88007e35fd88 15024    36      2 0x100=
00000
[177166.532023]  ffff88007e35fd88 ffffffff810aa6e0 ffff88007e35ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffffffff81c4b120 ffff88007e31c410 ffff880=
07e2c9b90
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007e313c10 ffff880=
07e35fd98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] perf            S ffff88007e367d88 15024    37      2 0x100=
00000
[177166.532023]  ffff88007e367d88 ffffffff810aa6e0 ffff88007e367fd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffffffff81c4b120 ffff88007e31f6d8 ffff880=
07e2cb720
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007e313580 ffff880=
07e367d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] khungtaskd      S ffff88007dc7fcb8 13840    40      2 0x100=
00000
[177166.532023]  ffff88007dc7fcb8 000000010a8bec3c ffff88007dc7ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e0752b0 0000000000000292 ffff88007dc7fcf8 fffffff=
f82fa59c0
[177166.532023]  000000010a8bec3c ffffffff82fa59c0 0000000000000078 ffff880=
07dc7fcc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff81766789>] schedule_timeout_interruptible+0x29/0=
x30
[177166.532023]  [<ffffffff8116f37c>] watchdog+0x4c/0x680
[177166.532023]  [<ffffffff8116f3d2>] ? watchdog+0xa2/0x680
[177166.532023]  [<ffffffff81760a84>] ? __schedule+0x2c4/0x7b0
[177166.532023]  [<ffffffff8116f330>] ? reset_hung_task_detector+0x20/0x20
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] writeback       S ffff88007dc83d88 12440    41      2 0x100=
00000
[177166.532023]  ffff88007dc83d88 ffff88007e150800 ffff88007dc83fd8 0000000=
0001d6240
[177166.532023]  ffff88000fcd1b90 ffffffff81c4b120 ffff88007e31ecb0 ffff880=
07ec4c150
[177166.532023]  ffff88007e150800 ffff88007ec4c0f8 ffff88007dc5a860 ffff880=
07dc83d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] ksmd            S ffff88007dc93da8 14184    42      2 0x100=
00000
[177166.532023]  ffff88007dc93da8 ffff88007dc93dd8 ffff88007dc93fd8 0000000=
0001d6240
[177166.532023]  ffff88007e19d2b0 0000000000000038 ffff88007dc88000 ffff880=
07dc93df0
[177166.532023]  ffff88007dc88000 ffff88007dc88000 0000000000000000 ffff880=
07dc93db8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81226f7b>] ksm_scan_thread+0x1ab/0x260
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff81226dd0>] ? ksm_do_scan+0xe40/0xe40
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] khugepaged      S ffff88007dc9bc28 10616    43      2 0x100=
00000
[177166.532023]  ffff88007dc9bc28 000000010a8b7680 ffff88007dc9bfd8 0000000=
0001d6240
[177166.532023]  ffff880076c652b0 0000000000000296 ffff88007dc9bc68 ffff880=
07e274000
[177166.532023]  000000010a8b7680 ffff88007e274000 0000000000c00000 ffff880=
07dc9bc38
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810dd965>] ? prepare_to_wait_event+0x95/0x110
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff812388b1>] khugepaged+0xc31/0xca0
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff81237c80>] ? collapse_huge_page.isra.45+0x950/0x=
950
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] crypto          S ffff88007dca3d88 15024    44      2 0x100=
00000
[177166.532023]  ffff88007dca3d88 ffffffff810aa6e0 ffff88007dca3fd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffffffff81c4b120 ffff88007e31d450 ffff880=
07dc89b90
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007dc5a518 ffff880=
07dca3d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kintegrityd     S ffff88007dca7d88 15024    45      2 0x100=
00000
[177166.532023]  ffff88007dca7d88 ffffffff810aa6e0 ffff88007dca7fd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffffffff81c4b120 ffff88007e31eaa8 ffff880=
07dc8b720
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007dc59168 ffff880=
07dca7d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] bioset          S ffff88007dcafd88 15024    46      2 0x100=
00000
[177166.532023]  ffff88007dcafd88 ffffffff810aa6e0 ffff88007dcaffd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffffffff81c4b120 ffff88007e31d658 ffff880=
07dcb8000
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007dc5a1d0 ffff880=
07dcafd98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kblockd         S ffff88007dcd7d88 15024    47      2 0x100=
00000
[177166.532023]  ffff88007dcd7d88 ffffffff810aa6e0 ffff88007dcd7fd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffffffff81c4b120 ffff88007e31e8a0 ffff880=
07dcbd2b0
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007dc594b0 ffff880=
07dcd7d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] md              S ffff88007df5fd88 14704    49      2 0x100=
00000
[177166.532023]  ffff88007df5fd88 ffffffff810aa6e0 ffff88007df5ffd8 0000000=
0001d6240
[177166.532023]  ffffffff81c154e0 ffffffff81c4b120 ffff88007df032c8 ffff880=
07dcbb720
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007dd0d4b0 ffff880=
07df5fd98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] devfreq_wq      S ffff88007df73d88 15024    51      2 0x100=
00000
[177166.532023]  ffff88007df73d88 ffffffff810aa6e0 ffff88007df73fd8 0000000=
0001d6240
[177166.532023]  ffff88007e19d2b0 ffffffff81c4b120 ffff88007df00e38 ffff880=
07df652b0
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007dd0e860 ffff880=
07df73d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] pageattr-test   R  running task    10072    53      2 0x100=
00000
[177166.532023]  ffff88007748f9f8 000000010a8ac4e0 ffff88007748ffd8 0000000=
0001d6240
[177166.532023]  ffff880073738000 0000000000000292 ffff88007748fa38 ffff880=
07e1f4000
[177166.532023]  000000010a8ac4e0 ffff88007e1f4000 0000000000000000 ffff880=
07748fa08
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff8120d5da>] ? __vmalloc_node_range+0x1ca/0x2c0
[177166.532023]  [<ffffffff8120d5da>] __vmalloc_node_range+0x1ca/0x2c0
[177166.532023]  [<ffffffff8107520c>] ? pageattr_test+0x4c/0x4f0
[177166.532023]  [<ffffffff810756b0>] ? pageattr_test+0x4f0/0x4f0
[177166.532023]  [<ffffffff8120d9f4>] vzalloc+0x54/0x60
[177166.532023]  [<ffffffff8107520c>] ? pageattr_test+0x4c/0x4f0
[177166.532023]  [<ffffffff8111461a>] ? del_timer_sync+0xba/0xf0
[177166.532023]  [<ffffffff8107520c>] pageattr_test+0x4c/0x4f0
[177166.532023]  [<ffffffff813ba359>] ? debug_object_free+0x19/0x20
[177166.532023]  [<ffffffff8176650d>] ? schedule_timeout+0x19d/0x3f0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff810756b0>] ? pageattr_test+0x4f0/0x4f0
[177166.532023]  [<ffffffff810756cf>] do_pageattr_test+0x1f/0x50
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kswapd0         R  running task    10776    55      2 0x100=
00000
[177166.532023]  0000000000000001 000000010a8ac7e2 ffff880077517fd8 0000000=
0001d6240
[177166.532023]  ffff88007c03d2b0 0000000000000292 ffff880077517c88 0000000=
000000020
[177166.532023]  000000010a8ac7e5 ffff88007e234000 0000000000000001 ffff880=
077517c58
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810dd441>] ? prepare_to_wait+0x61/0x90
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff811de38a>] kswapd+0xaea/0xd70
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff811dd8a0>] ? mem_cgroup_shrink_node_zone+0x4f0/0=
x4f0
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] fsnotify_mark   S ffff880077103da8 14184    56      2 0x100=
00000
[177166.532023]  ffff880077103da8 ffff880077103dd8 ffff880077103fd8 0000000=
0001d6240
[177166.532023]  ffff88007e1e8000 00000000000001dd ffff880077103dc8 ffff880=
0083fc000
[177166.532023]  ffff880077103db8 ffff880077103dc8 ffff880077103df0 ffff880=
077103db8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8129c552>] fsnotify_mark_destroy+0x122/0x160
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8129c430>] ? fsnotify_put_mark+0x40/0x40
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kthrotld        S ffff8800771fbd88 14680    67      2 0x100=
00000
[177166.532023]  ffff8800771fbd88 ffffffff810aa6e0 ffff8800771fbfd8 0000000=
0001d6240
[177166.532023]  ffffffff81c154e0 ffffffff81c4b120 ffff8800770c2288 ffff880=
0771f0000
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007716c448 ffff880=
0771fbd98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] acpi_thermal_pm S ffff880077217d88 14704    68      2 0x100=
00000
[177166.532023]  ffff880077217d88 ffffffff810aa6e0 ffff880077217fd8 0000000=
0001d6240
[177166.532023]  ffffffff81c154e0 ffffffff81c4b120 ffff8800770c1c70 ffff880=
0771f52b0
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007716f580 ffff880=
077217d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kmpath_rdacd    S ffff88007727bd88 14864    70      2 0x100=
00000
[177166.532023]  ffff88007727bd88 ffffffff810aa6e0 ffff88007727bfd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffffffff81c4b120 ffff880077220410 ffff880=
0771f3720
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007716c790 ffff880=
07727bd98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kpsmoused       S ffff88000014fd88 14864    71      2 0x100=
00000
[177166.532023]  ffff88000014fd88 ffffffff810aa6e0 ffff88000014ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e19d2b0 ffffffff81c4b120 ffff8800772228a0 ffff880=
077493720
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007716ce20 ffff880=
00014fd98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] ipv6_addrconf   S ffff8800773afd88 14864    73      2 0x100=
00000
[177166.532023]  ffff8800773afd88 ffffffff810aa6e0 ffff8800773affd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffffffff81c4b120 ffff88007737cc30 ffff880=
0771952b0
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007716de88 ffff880=
0773afd98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] deferwq         S ffff880076c5fd88 14864    93      2 0x100=
00000
[177166.532023]  ffff880076c5fd88 ffffffff810aa6e0 ffff880076c5ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffffffff81c4b120 ffff88007737e8a0 ffff880=
076c63720
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff8800773d0e20 ffff880=
076c5fd98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kauditd         S ffff880076eabdb8 13912   115      2 0x100=
00000
[177166.532023]  ffff880076eabdb8 ffff880076eabde8 ffff880076eabfd8 0000000=
0001d6240
[177166.532023]  ffff88007a2a3720 0000000000000205 ffff880076eabe00 ffff880=
0771cb720
[177166.532023]  ffff8800771cb720 0000000000000000 0000000000000000 ffff880=
076eabdc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81153efa>] kauditd_thread+0x16a/0x220
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff81153d90>] ? audit_printk_skb+0x70/0x70
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] ata_sff         S ffff880075043d88 14864   260      2 0x100=
00000
[177166.532023]  ffff880075043d88 ffffffff810aa6e0 ffff880075043fd8 0000000=
0001d6240
[177166.532023]  ffff880076fed2b0 ffffffff81c4b120 ffff8800752a36d8 ffff880=
076b91b90
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff8800768ee518 ffff880=
075043d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] scsi_eh_0       S ffff88007533bd88 13240   263      2 0x100=
00000
[177166.532023]  ffff88007533bd88 0000000000000292 ffff88007533bfd8 0000000=
0001d6240
[177166.532023]  ffff88007e13d2b0 0000000000000292 ffff880075cec520 ffff880=
07516c0a0
[177166.532023]  0000000000000292 0000000000000000 0000000000000000 ffff880=
07533bd98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff815092b3>] scsi_error_handler+0xa3/0x900
[177166.532023]  [<ffffffff81760a84>] ? __schedule+0x2c4/0x7b0
[177166.532023]  [<ffffffff81509210>] ? scsi_eh_get_sense+0x260/0x260
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] scsi_tmf_0      S ffff880074647d88 14680   264      2 0x100=
00000
[177166.532023]  ffff880074647d88 ffffffff810aa6e0 ffff880074647fd8 0000000=
0001d6240
[177166.532023]  ffff88007e199b90 ffffffff81c4b120 ffff8800752a0820 ffff880=
075168000
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff8800768ed168 ffff880=
074647d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] scsi_eh_1       S ffff880074177d88 13240   266      2 0x100=
00000
[177166.532023]  ffff880074177d88 0000000000000292 ffff880074177fd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 0000000000000292 ffff880077468000 ffff880=
0752940a0
[177166.532023]  0000000000000292 0000000000000000 0000000000000000 ffff880=
074177d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff815092b3>] scsi_error_handler+0xa3/0x900
[177166.532023]  [<ffffffff81760a84>] ? __schedule+0x2c4/0x7b0
[177166.532023]  [<ffffffff81509210>] ? scsi_eh_get_sense+0x260/0x260
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] scsi_tmf_1      S ffff880074183d88 14544   267      2 0x100=
00000
[177166.532023]  ffff880074183d88 ffffffff810aa6e0 ffff880074183fd8 0000000=
0001d6240
[177166.532023]  ffff880076dd9b90 ffffffff81c4b120 ffff8800752a32c8 ffff880=
0752952b0
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff880076fbdb40 ffff880=
074183d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] ttm_swap        S ffff880075243d88 14688   271      2 0x100=
00000
[177166.532023]  ffff880075243d88 ffffffff810aa6e0 ffff880075243fd8 0000000=
0001d6240
[177166.532023]  ffff88007e19d2b0 ffffffff81c4b120 ffff8800752a30c0 ffff880=
075169b90
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff880076babc10 ffff880=
075243d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kworker/3:1H    S ffff880075db3db8 12032   277      2 0x100=
00000
[177166.532023]  ffff880075db3db8 ffff8800752a2ad8 ffff880075db3fd8 0000000=
0001d6240
[177166.532023]  ffff88007df63720 ffff880081bd5c80 ffff880081bd5c80 ffff880=
081bd5c80
[177166.532023]  ffff8800752a2ad8 ffff880075008000 ffff8800752a2aa8 ffff880=
075db3dc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] jbd2/vda2-8     S ffff8800740bbd98  8584   283      2 0x100=
00000
[177166.532023]  ffff8800740bbd98 ffff8800740bbdf0 ffff8800740bbfd8 0000000=
0001d6240
[177166.532023]  ffff88007c038000 ffff8800752dd690 ffff8800752dd668 ffff880=
0752dd690
[177166.532023]  ffff8800752ddd10 ffff8800752dd850 ffff8800740bbdf0 ffff880=
0740bbda8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffffa016d186>] kjournald2+0x216/0x2a0 [jbd2]
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffffa016cf70>] ? commit_timeout+0x10/0x10 [jbd2]
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] ext4-rsv-conver S ffff880073073d88 14864   284      2 0x100=
00000
[177166.532023]  ffff880073073d88 ffffffff810aa6e0 ffff880073073fd8 0000000=
0001d6240
[177166.532023]  ffff88007e199b90 ffffffff81c4b120 ffff880076f88618 ffff880=
0750f52b0
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007698e1d0 ffff880=
073073d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] systemd-journal R  running task     8792   383      1 0x100=
00000
[177166.532023]  ffff88007523fa18 000000010a8ac88c ffff88007523ffd8 0000000=
0001d6240
[177166.532023]  ffff880077490000 ffff8800833d6880 ffff88007523fa58 ffff880=
07e274000
[177166.532023]  000000010a8ac88f ffff88007e274000 0000000000000000 ffff880=
076c652b0
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff811c676b>] ? out_of_memory+0x5b/0x80
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] ? alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c3ff8>] ? filemap_fault+0x1c8/0x460
[177166.532023]  [<ffffffff811f903c>] ? __do_fault+0x4c/0xd0
[177166.532023]  [<ffffffff811fd7b0>] ? handle_mm_fault+0xcf0/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] lvmetad         S ffff88007422b898 11896   388      1 0x100=
00000
[177166.532023]  ffff88007422b898 ffff88007422b868 ffff88007422bfd8 0000000=
0001d6240
[177166.532023]  ffffffff81c154e0 ffff88007422b878 0000000000000000 0000000=
000000040
[177166.532023]  0000000000000010 0000000000000004 0000000000000004 ffff880=
07422b8a8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff8126833f>] ? __pollwait+0x7f/0xf0
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81268f0f>] do_select+0x65f/0x900
[177166.532023]  [<ffffffff812688b5>] ? do_select+0x5/0x900
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff811f8f4f>] ? might_fault+0x5f/0xb0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff810e4faf>] ? lock_release_holdtime.part.24+0xf/0=
x190
[177166.532023]  [<ffffffff810eaf38>] ? lock_release_non_nested+0x308/0x350
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff811f8f4f>] ? might_fault+0x5f/0xb0
[177166.532023]  [<ffffffff81269440>] core_sys_select+0x290/0x4a0
[177166.532023]  [<ffffffff812691f8>] ? core_sys_select+0x48/0x4a0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff810c3c42>] ? wake_up_new_task+0x172/0x2e0
[177166.532023]  [<ffffffff81088035>] ? do_fork+0x175/0x7c0
[177166.532023]  [<ffffffff810e3323>] ? up_read+0x23/0x40
[177166.532023]  [<ffffffff810713a5>] ? __do_page_fault+0x1c5/0x470
[177166.532023]  [<ffffffff8126970f>] SyS_select+0xbf/0x120
[177166.532023]  [<ffffffff8139a41e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] systemd-udevd   S ffff8800750d7d98  9240   396      1 0x100=
00000
[177166.532023]  ffff8800750d7d98 ffff8800750d7d58 ffff8800750d7fd8 0000000=
0001d6240
[177166.532023]  ffff88007a0e52b0 ffff8800750d7d98 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007a5fa270 ffff8800750f1b90 ffff8800750f1b90 ffff880=
0750d7da8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff812a2692>] ? ep_poll+0x292/0x390
[177166.532023]  [<ffffffff817676d6>] ? _raw_spin_unlock_irqrestore+0x36/0x=
70
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff812a26a7>] ep_poll+0x2a7/0x390
[177166.532023]  [<ffffffff810c37f0>] ? wake_up_state+0x20/0x20
[177166.532023]  [<ffffffff812a3ce5>] SyS_epoll_wait+0xb5/0xe0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] rpciod          S ffff88007cb13d88 14704   397      2 0x100=
00000
[177166.532023]  ffff88007cb13d88 ffffffff810aa6e0 ffff88007cb13fd8 0000000=
0001d6240
[177166.532023]  ffffffff81c154e0 ffffffff81c4b120 ffff88007680f4d0 ffff880=
076859b90
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff880075db8ad8 ffff880=
07cb13d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] vballoon        S ffff88007aae7d88 14768   441      2 0x100=
00000
[177166.532023]  ffff88007aae7d88 ffff88007aae7dd8 ffff88007aae7fd8 0000000=
0001d6240
[177166.532023]  ffff88007c960000 000000000000015b ffff88007468b7b0 ffff880=
07a8d3720
[177166.532023]  ffff88007aae7dd0 0000000000000000 0000000000000000 ffff880=
07aae7d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffffa02ccedb>] balloon+0x24b/0x328 [virtio_balloon]
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffffa02ccc90>] ? virtballoon_restore+0xf0/0xf0 [virt=
io_balloon]
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] hd-audio0       S ffff88007c15fd88 14864   464      2 0x100=
00000
[177166.532023]  ffff88007c15fd88 ffffffff810aa6e0 ffff88007c15ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffffffff81c4b120 ffff88007680cc30 ffff880=
0746f3720
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007695a860 ffff880=
07c15fd98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] jbd2/vda1-8     S ffff88007ae8fd98 14720   476      2 0x100=
00000
[177166.532023]  ffff88007ae8fd98 ffff88007ae8fdf0 ffff88007ae8ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffff88007c151170 ffff88007c151148 ffff880=
07c151170
[177166.532023]  ffff88007c1517f0 ffff88007c151330 ffff88007ae8fdf0 ffff880=
07ae8fda8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffffa016d186>] kjournald2+0x216/0x2a0 [jbd2]
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffffa016cf70>] ? commit_timeout+0x10/0x10 [jbd2]
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] ext4-rsv-conver S ffff88007c96fd88 14864   477      2 0x100=
00000
[177166.532023]  ffff88007c96fd88 ffffffff810aa6e0 ffff88007c96ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffffffff81c4b120 ffff880076f88000 ffff880=
077191b90
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff880076f18ad8 ffff880=
07c96fd98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] auditd          D ffff88007c92fa18  8648   482      1 0x100=
00000
[177166.532023]  ffff88007c92fa18 43aee5820000000c 00000000086357d6 0000000=
0001d6240
[177166.532023]  ffff88007e0752b0 0000000000000292 ffff88007c92fa58 fffffff=
f82fa59c0
[177166.532023]  000000010a8ac920 ffff88007c92fa98 0000000000000000 ffff880=
07c92fa28
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff811dca75>] ? try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] ? alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c3ff8>] ? filemap_fault+0x1c8/0x460
[177166.532023]  [<ffffffff811f903c>] ? __do_fault+0x4c/0xd0
[177166.532023]  [<ffffffff811fd7b0>] ? handle_mm_fault+0xcf0/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] auditd          S ffff88007c8f7c98  9032   487      1 0x100=
00000
[177166.532023]  ffff88007c8f7c98 ffff88007c8f7c68 ffff88007c8f7fd8 0000000=
0001d6240
[177166.532023]  ffffffff81c154e0 0000000000000000 ffff88007c961b90 0000000=
000000000
[177166.532023]  ffff88007c961b90 ffff88007c8f7dc8 ffffc90000a2fe00 ffff880=
07c8f7ca8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8112c0e9>] futex_wait_queue_me+0xe9/0x190
[177166.532023]  [<ffffffff8112cf79>] futex_wait+0x179/0x280
[177166.532023]  [<ffffffff811fd032>] ? handle_mm_fault+0x572/0x1700
[177166.532023]  [<ffffffff8112bef7>] ? get_futex_key+0x1f7/0x300
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff8112eeee>] do_futex+0xfe/0x560
[177166.532023]  [<ffffffff811b6c79>] ? __perf_sw_event+0x59/0x90
[177166.532023]  [<ffffffff8112f3d0>] SyS_futex+0x80/0x180
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] audispd         S ffff88007c8fbc98  9336   488    482 0x100=
00000
[177166.532023]  ffff88007c8fbc98 ffff88007c8fbc68 ffff88007c8fbfd8 0000000=
0001d6240
[177166.532023]  ffff880076c652b0 0000000000000000 ffff88007c960000 0000000=
000000000
[177166.532023]  ffff88007c960000 ffff88007c8fbdc8 ffffc90000a37400 ffff880=
07c8fbca8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8112c0e9>] futex_wait_queue_me+0xe9/0x190
[177166.532023]  [<ffffffff8112cf79>] futex_wait+0x179/0x280
[177166.532023]  [<ffffffff811fdc21>] ? handle_mm_fault+0x1161/0x1700
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff8112eeee>] do_futex+0xfe/0x560
[177166.532023]  [<ffffffff811b6c79>] ? __perf_sw_event+0x59/0x90
[177166.532023]  [<ffffffff8112f3d0>] SyS_futex+0x80/0x180
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] audispd         R  running task     8600   491    482 0x100=
00080
[177166.532023]  ffff88007c2a3a38 000000010a8ac4dd ffff88007c2a3fd8 0000000=
0001d6240
[177166.532023]  ffff880075c19b90 0000000000000296 ffff88007c2a3a78 ffff880=
07e1f4000
[177166.532023]  000000010a8ac4dd ffff88007e1f4000 0000000000000000 ffff880=
07c2a3a48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] sedispatch      S ffff88007c11fba8  8648   490    488 0x100=
00080
[177166.532023]  ffff88007c11fba8 ffff88007c11fb88 ffff88007c11ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e19d2b0 ffff8800819d6d40 ffff88007a5dc200 ffff880=
07a5dc7e8
[177166.532023]  ffff880076c60000 7fffffffffffffff ffff880076c60000 ffff880=
07c11fbb8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817665cc>] schedule_timeout+0x25c/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff816e77d8>] ? unix_stream_recvmsg+0x338/0x8c0
[177166.532023]  [<ffffffff816e77e8>] unix_stream_recvmsg+0x348/0x8c0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff815f73b2>] sock_aio_read+0xf2/0x120
[177166.532023]  [<ffffffff812509a7>] do_sync_read+0x67/0xa0
[177166.532023]  [<ffffffff81251eec>] __vfs_read+0x2c/0x50
[177166.532023]  [<ffffffff81251f9d>] vfs_read+0x8d/0x150
[177166.532023]  [<ffffffff812520b8>] SyS_read+0x58/0xd0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] alsactl         D ffff8800731d3a18  8648   509      1 0x100=
00080
[177166.532023]  ffff8800731d3a18 000000010a8ac4e4 ffff8800731d3fd8 0000000=
0001d6240
[177166.532023]  ffff88007ca81b90 0000000000000292 ffff8800731d3a58 ffff880=
07e1f4000
[177166.532023]  000000010a8ac4e4 ffff88007e1f4000 0000000000000000 ffff880=
0731d3a28
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c0f2f>] __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c3ff8>] filemap_fault+0x1c8/0x460
[177166.532023]  [<ffffffff811f903c>] __do_fault+0x4c/0xd0
[177166.532023]  [<ffffffff811fd7b0>] handle_mm_fault+0xcf0/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] smartd          R  running task     9240   517      1 0x100=
00080
[177166.532023]  ffff88007ab8fa38 000000010a8ac992 ffff88007ab8ffd8 0000000=
0001d6240
[177166.532023]  0000000000000001 0000000000000296 ffff88007ab8fa78 fffffff=
f82fa59c0
[177166.532023]  000000010a8ac996 ffffffff82fa59c0 0000000000000000 ffff880=
07ab8fa48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81094c17>] ? has_capability_noaudit+0x17/0x20
[177166.532023]  [<ffffffff81760f99>] ? schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] ? schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] tuned           R  running task     9240   520      1 0x100=
00080
[177166.532023]  ffff88007696f8d8 000000010a8ac9a3 ffff88007696ffd8 ffff880=
079867790
[177166.532023]  ffff88007373d2b0 0000000000000296 ffff88007696f918 ffff880=
07e234000
[177166.532023]  000000010a8ac9af ffff88007696f958 0000000000000000 ffff880=
07696f8e8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023]  [<ffffffff81398979>] ? copy_user_generic_unrolled+0x89/0xc=
0
[177166.532023]  [<ffffffff81268581>] ? poll_select_copy_remaining+0x101/0x=
160
[177166.532023]  [<ffffffff8126887c>] ? poll_select_set_timeout+0x5c/0x90
[177166.532023]  [<ffffffff81269721>] SyS_select+0xd1/0x120
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] gmain           S ffff88007ad4fa08 14232   633      1 0x100=
00080
[177166.532023]  ffff88007ad4fa08 ffff880073749b90 ffff88007ad4ffd8 0000000=
0001d6240
[177166.532023]  ffff880076c652b0 ffff880073749b90 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007ad4fb8c ffff88007ad4fb8c 0000000000000000 ffff880=
07ad4fa18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] tuned           S ffff88007a167a08 13640   635      1 0x100=
00080
[177166.532023]  ffff88007a167a08 ffff88007a1679d8 ffff88007a167fd8 0000000=
0001d6240
[177166.532023]  ffff88007373d2b0 ffff88007a1679e8 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007a167b94 ffff88007a167b94 0000000000000000 ffff880=
07a167a18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff8126833f>] ? __pollwait+0x7f/0xf0
[177166.532023]  [<ffffffff816e6074>] ? unix_poll+0x44/0xe0
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] tuned           R  running task     8648   637      1 0x100=
00080
[177166.532023]  ffff880000027a38 000000010a8aca0e ffff880000027fd8 0000000=
0001d6240
[177166.532023]  ffff88007c03d2b0 0000000000000296 ffff880000027a78 ffff880=
07e234000
[177166.532023]  000000010a8aca0e ffff88007e234000 ffffffff811dc694 ffff880=
07373d2b0
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff811dca75>] ? try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] tuned           S ffff88007a913d98 14248   639      1 0x100=
00080
[177166.532023]  ffff88007a913d98 ffff88007a913d58 ffff88007a913fd8 0000000=
0001d6240
[177166.532023]  ffffffff81c154e0 ffff88007a913d98 0000000000000000 0000000=
000000000
[177166.532023]  ffff880076c4cb78 ffff88007374b720 ffff88007374b720 ffff880=
07a913da8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff812a2692>] ? ep_poll+0x292/0x390
[177166.532023]  [<ffffffff817676d6>] ? _raw_spin_unlock_irqrestore+0x36/0x=
70
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff812a26a7>] ep_poll+0x2a7/0x390
[177166.532023]  [<ffffffff81273dd7>] ? __fget+0x117/0x200
[177166.532023]  [<ffffffff81273cc5>] ? __fget+0x5/0x200
[177166.532023]  [<ffffffff810c37f0>] ? wake_up_state+0x20/0x20
[177166.532023]  [<ffffffff812a3ce5>] SyS_epoll_wait+0xb5/0xe0
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] avahi-daemon    R  running task     8568   523      1 0x100=
00080
[177166.532023]  ffff8800731fb538 000000010a8aca33 ffff8800731fbfd8 0000000=
0001d6240
[177166.532023]  ffff88007a063720 0000000000000296 ffff8800731fb578 ffff880=
07e274000
[177166.532023]  000000010a8aca3b ffff88007e274000 ffffffff811dc694 0000000=
10a8aca3d
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff811dca75>] ? try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023]  [<ffffffff81269b4c>] ? do_sys_poll+0x18c/0x5c0
[177166.532023]  [<ffffffff81269b09>] ? do_sys_poll+0x149/0x5c0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff811b6b02>] ? ___perf_sw_event+0x192/0x2b0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff811b6b21>] ? ___perf_sw_event+0x1b1/0x2b0
[177166.532023]  [<ffffffff811b69a8>] ? ___perf_sw_event+0x38/0x2b0
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff8106b769>] ? kvm_clock_get_cycles+0x9/0x10
[177166.532023]  [<ffffffff8111eda6>] ? ktime_get_ts64+0xb6/0x180
[177166.532023]  [<ffffffff8126887c>] ? poll_select_set_timeout+0x5c/0x90
[177166.532023]  [<ffffffff8126a084>] ? SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff8176857a>] ? tracesys_phase2+0xd8/0xdd
[177166.532023] abrtd           S ffff8800731f7a08 11848   524      1 0x100=
00080
[177166.532023]  ffff8800731f7a08 ffff8800731f79d8 ffff8800731f7fd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 ffff8800731f79e8 0000000000000000 0000000=
000000000
[177166.532023]  ffff8800731f7ba4 ffff8800731f7ba4 0000000000000000 ffff880=
0731f7a18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff8126833f>] ? __pollwait+0x7f/0xf0
[177166.532023]  [<ffffffff816e6074>] ? unix_poll+0x44/0xe0
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff8175ae54>] ? __slab_free+0x75/0x242
[177166.532023]  [<ffffffff815f8ac4>] ? ___sys_sendmsg+0x1f4/0x330
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8175af04>] ? __slab_free+0x125/0x242
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] abrt-watch-log  R  running task     8648   527      1 0x100=
00080
[177166.532023]  ffff88007c037a38 000000010a8aca89 ffff88007c037fd8 0000000=
0001d6240
[177166.532023]  ffff88007ca83720 0000000000000296 ffff88007c037a78 ffff880=
07e234000
[177166.532023]  000000010a8aca89 ffff88007e234000 0000000000000000 ffff880=
07c037a48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff811dca75>] ? try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] chronyd         R  running task     9000   531      1 0x100=
00080
[177166.532023]  ffff88007c12ba18 000000010a8aca9f ffff88007c12bfd8 0000000=
0001d6240
[177166.532023]  ffff880077490000 0000000000000292 ffff88007c12ba58 ffff880=
07e274000
[177166.532023]  000000010a8aca9f ffff88007e274000 0000000000000000 ffff880=
07c12ba28
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff811c5708>] ? oom_badness+0x38/0x140
[177166.532023]  [<ffffffff81760f99>] ? schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] ? schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] ? alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c3ff8>] ? filemap_fault+0x1c8/0x460
[177166.532023]  [<ffffffff811f903c>] ? __do_fault+0x4c/0xd0
[177166.532023]  [<ffffffff811fd7b0>] ? handle_mm_fault+0xcf0/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] irqbalance      R  running task     8648   532      1 0x100=
00080
[177166.532023]  ffff88007ca8ba38 000000010a8ac4e2 ffff88007ca8bfd8 0000000=
0001d6240
[177166.532023]  ffff880075291b90 0000000000000296 ffff88007ca8ba78 ffff880=
07e1f4000
[177166.532023]  000000010a8ac4e2 ffff88007e1f4000 0000000000000000 ffff880=
07ca8ba48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] NetworkManager  R  running task     8600   534      1 0x100=
00080
[177166.532023]  ffff88007ca81b90 0000000090023ad0 ffff880081603b78 fffffff=
f810c2921
[177166.532023]  ffffffff810c2842 ffffffff81c154e0 ffff880081603b78 ffff880=
07ca81b90
[177166.532023]  ffff88007ca82398 0000000000000000 ffff880081603bc8 fffffff=
f810c2aef
[177166.532023] Call Trace:
[177166.532023]  <IRQ>  [<ffffffff810c2921>] sched_show_task+0x161/0x280
[177166.532023]  [<ffffffff810c2842>] ? sched_show_task+0x82/0x280
[177166.532023]  [<ffffffff810c2aef>] show_state_filter+0xaf/0x100
[177166.532023]  [<ffffffff8147c810>] sysrq_handle_showstate+0x10/0x20
[177166.532023]  [<ffffffff8147d0a7>] __handle_sysrq+0x147/0x240
[177166.532023]  [<ffffffff8147cf65>] ? __handle_sysrq+0x5/0x240
[177166.532023]  [<ffffffff8147d579>] sysrq_filter+0x3a9/0x3f0
[177166.532023]  [<ffffffff81581847>] input_to_handler+0x57/0x120
[177166.532023]  [<ffffffff8158493f>] input_pass_values.part.5+0x2bf/0x300
[177166.532023]  [<ffffffff81584685>] ? input_pass_values.part.5+0x5/0x300
[177166.532023]  [<ffffffff81585109>] input_handle_event+0x129/0x550
[177166.532023]  [<ffffffff81585575>] ? input_event+0x45/0x70
[177166.532023]  [<ffffffff81585589>] input_event+0x59/0x70
[177166.532023]  [<ffffffff8158c512>] atkbd_interrupt+0x622/0x740
[177166.532023]  [<ffffffff8157e98e>] ? serio_interrupt+0x2e/0x90
[177166.532023]  [<ffffffff8157e9aa>] serio_interrupt+0x4a/0x90
[177166.532023]  [<ffffffff8157f61a>] i8042_interrupt+0x18a/0x370
[177166.532023]  [<ffffffff81101260>] handle_irq_event_percpu+0x40/0x500
[177166.532023]  [<ffffffff81101761>] handle_irq_event+0x41/0x70
[177166.532023]  [<ffffffff811048cf>] handle_edge_irq+0x7f/0x120
[177166.532023]  [<ffffffff81020e5e>] handle_irq+0xae/0x140
[177166.532023]  [<ffffffff8110e1f7>] ? rcu_irq_enter+0x77/0xb0
[177166.532023]  [<ffffffff8176b2f1>] do_IRQ+0x51/0xf0
[177166.532023]  [<ffffffff81768f32>] common_interrupt+0x72/0x72
[177166.532023]  <EOI>  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff810eaa43>] ? lock_acquire+0xf3/0x2e0
[177166.532023]  [<ffffffff811f3f62>] ? __list_lru_count_one.isra.2+0x22/0x=
80
[177166.532023]  [<ffffffff8176735d>] _raw_spin_lock+0x3d/0x80
[177166.532023]  [<ffffffff811f3f62>] ? __list_lru_count_one.isra.2+0x22/0x=
80
[177166.532023]  [<ffffffff8176764b>] ? _raw_spin_unlock+0x2b/0x40
[177166.532023]  [<ffffffff811f3f62>] __list_lru_count_one.isra.2+0x22/0x80
[177166.532023]  [<ffffffff811f3fe6>] list_lru_count_one+0x26/0x30
[177166.532023]  [<ffffffff81253b19>] super_cache_count+0x69/0xe0
[177166.532023]  [<ffffffff811d8638>] shrink_slab+0x148/0x750
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff812400d0>] ? mem_cgroup_iter+0x160/0xb00
[177166.532023]  [<ffffffff811dc2a8>] shrink_zone+0x2d8/0x2f0
[177166.532023]  [<ffffffff811dc694>] do_try_to_free_pages+0x194/0x470
[177166.532023]  [<ffffffff811dca75>] try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff811cd445>] __alloc_pages_nodemask+0x7e5/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c0f2f>] __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c3ff8>] filemap_fault+0x1c8/0x460
[177166.532023]  [<ffffffff811f903c>] __do_fault+0x4c/0xd0
[177166.532023]  [<ffffffff811fd7b0>] handle_mm_fault+0xcf0/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] NetworkManager  S ffff88007ba17d38 14784   579      1 0x100=
00080
[177166.532023]  ffff88007ba17d38 ffff88007ba17d08 ffff88007ba17fd8 0000000=
0001d6240
[177166.532023]  ffff88007e198000 0000000000000000 ffff88007a12d2b0 7ffffff=
fffffffff
[177166.532023]  ffff88007ba17ec0 ffff88007a12d2b0 0000000000000000 ffff880=
07ba17d48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817665cc>] schedule_timeout+0x25c/0x3f0
[177166.532023]  [<ffffffff8109ddff>] ? do_sigtimedwait+0x15f/0x240
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8109ddff>] ? do_sigtimedwait+0x15f/0x240
[177166.532023]  [<ffffffff81767740>] ? _raw_spin_unlock_irq+0x30/0x50
[177166.532023]  [<ffffffff81766789>] schedule_timeout_interruptible+0x29/0=
x30
[177166.532023]  [<ffffffff8109de0f>] do_sigtimedwait+0x16f/0x240
[177166.532023]  [<ffffffff8109df78>] SYSC_rt_sigtimedwait+0x98/0x100
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8102d7cc>] ? do_audit_syscall_entry+0x6c/0x70
[177166.532023]  [<ffffffff8102f1d3>] ? syscall_trace_enter_phase1+0x143/0x=
1a0
[177166.532023]  [<ffffffff8139a41e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[177166.532023]  [<ffffffff8109dfee>] SyS_rt_sigtimedwait+0xe/0x10
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] gdbus           S ffff88007ca8fa08  9240   585      1 0x100=
00080
[177166.532023]  ffff88007ca8fa08 ffff880076a89b90 ffff88007ca8ffd8 0000000=
0001d6240
[177166.532023]  ffff880076c652b0 ffff880076a89b90 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007ca8fb9c ffff88007ca8fb9c 0000000000000000 ffff880=
07ca8fa18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff811b6b02>] ? ___perf_sw_event+0x192/0x2b0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff811b6b02>] ? ___perf_sw_event+0x192/0x2b0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] gmain           S ffff88007a29fa08 13968   606      1 0x100=
00080
[177166.532023]  ffff88007a29fa08 ffff880073739b90 ffff88007a29ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e199b90 ffff880073739b90 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007a29fb8c ffff88007a29fb8c 0000000000000000 ffff880=
07a29fa18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff811d389d>] ? pagevec_lru_move_fn+0xdd/0x110
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] lsmd            R  running task     9064   535      1 0x100=
00080
[177166.532023]  ffff88007c8eba18 000000010a8acb67 ffff88007c8ebfd8 0000000=
0001d6240
[177166.532023]  ffff88007c273720 0000000000000292 ffff88007c8eba58 ffff880=
07e234000
[177166.532023]  000000010a8acb67 ffff88007e234000 0000000000000000 ffff880=
07c8eba28
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff811dca75>] ? try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] ? alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c3ff8>] ? filemap_fault+0x1c8/0x460
[177166.532023]  [<ffffffff811f903c>] ? __do_fault+0x4c/0xd0
[177166.532023]  [<ffffffff811fd7b0>] ? handle_mm_fault+0xcf0/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] rsyslogd        R  running task    11096   538      1 0x100=
00080
[177166.532023]  ffff88007a1338d8 000000010a8ac4da ffff88007a133fd8 0000000=
0001d6240
[177166.532023]  ffff88007ca80000 0000000000000296 ffff88007a133918 ffff880=
07e1f4000
[177166.532023]  000000010a8ac4da ffff88007e1f4000 0000000000000000 ffff880=
07a1338e8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023]  [<ffffffff81398979>] ? copy_user_generic_unrolled+0x89/0xc=
0
[177166.532023]  [<ffffffff81268581>] ? poll_select_copy_remaining+0x101/0x=
160
[177166.532023]  [<ffffffff8126887c>] ? poll_select_set_timeout+0x5c/0x90
[177166.532023]  [<ffffffff81269721>] SyS_select+0xd1/0x120
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] in:imjournal    R  running task     8600   569      1 0x100=
00080
[177166.532023]  ffff880079d03a38 000000010a8acb93 ffff880079d03fd8 0000000=
0001d6240
[177166.532023]  ffff880077490000 0000000000000296 ffff880079d03a78 fffffff=
f82fa59c0
[177166.532023]  000000010a8acb93 ffffffff82fa59c0 0000000000000000 ffff880=
079d03a48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd445>] ? __alloc_pages_nodemask+0x7e5/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] rs:main Q:Reg   S ffff88007ca2bc98  8568   571      1 0x100=
00080
[177166.532023]  ffff88007ca2bc98 ffff88007ca2bc68 ffff88007ca2bfd8 0000000=
0001d6240
[177166.532023]  ffff880076c652b0 0000000000000000 ffff88007c039b90 0000000=
000000000
[177166.532023]  ffff88007c039b90 ffff88007ca2bdc8 ffffc90000a28700 ffff880=
07ca2bca8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8112c0e9>] futex_wait_queue_me+0xe9/0x190
[177166.532023]  [<ffffffff8112cf79>] futex_wait+0x179/0x280
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8112eeee>] do_futex+0xfe/0x560
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8112f3d0>] SyS_futex+0x80/0x180
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] systemd-logind  S ffff88007aa37d98  8952   540      1 0x100=
00080
[177166.532023]  ffff88007aa37d98 ffff88007aa37d58 ffff88007aa37fd8 0000000=
0001d6240
[177166.532023]  ffff88007a12b720 ffff88007aa37d98 0000000000000000 0000000=
000000000
[177166.532023]  ffff880000167620 ffff88007a129b90 ffff88007a129b90 ffff880=
07aa37da8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff812a2692>] ? ep_poll+0x292/0x390
[177166.532023]  [<ffffffff817676d6>] ? _raw_spin_unlock_irqrestore+0x36/0x=
70
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff812a26a7>] ep_poll+0x2a7/0x390
[177166.532023]  [<ffffffff810c37f0>] ? wake_up_state+0x20/0x20
[177166.532023]  [<ffffffff812a3ce5>] SyS_epoll_wait+0xb5/0xe0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] dbus-daemon     S ffff88007c2ebd98  8568   541      1 0x100=
00080
[177166.532023]  ffff88007c2ebd98 ffff88007c2ebd58 ffff88007c2ebfd8 0000000=
0001d6240
[177166.532023]  ffff88007df61b90 ffff88007c2ebd98 0000000000000000 0000000=
000000000
[177166.532023]  ffff880076a00ec0 ffff88007a12b720 ffff88007a12b720 ffff880=
07c2ebda8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff812a2692>] ? ep_poll+0x292/0x390
[177166.532023]  [<ffffffff817676d6>] ? _raw_spin_unlock_irqrestore+0x36/0x=
70
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff812a26a7>] ep_poll+0x2a7/0x390
[177166.532023]  [<ffffffff810c37f0>] ? wake_up_state+0x20/0x20
[177166.532023]  [<ffffffff812a3ce5>] SyS_epoll_wait+0xb5/0xe0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] avahi-daemon    S ffff880073007ba8 13752   551    523 0x100=
00080
[177166.532023]  ffff880073007ba8 ffff880073007b88 ffff880073007fd8 0000000=
0001d6240
[177166.532023]  ffff88007e160000 ffff8800817d6d40 ffff88007ca1d280 ffff880=
07ca1d868
[177166.532023]  ffff8800731e9b90 7fffffffffffffff ffff8800731e9b90 ffff880=
073007bb8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817665cc>] schedule_timeout+0x25c/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff816e77d8>] ? unix_stream_recvmsg+0x338/0x8c0
[177166.532023]  [<ffffffff816e77e8>] unix_stream_recvmsg+0x348/0x8c0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff815f73b2>] sock_aio_read+0xf2/0x120
[177166.532023]  [<ffffffff812509a7>] do_sync_read+0x67/0xa0
[177166.532023]  [<ffffffff81251eec>] __vfs_read+0x2c/0x50
[177166.532023]  [<ffffffff81251f9d>] vfs_read+0x8d/0x150
[177166.532023]  [<ffffffff812520b8>] SyS_read+0x58/0xd0
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] iprupdate       S ffff8800769f7b08  9608   559      1 0x100=
00080
[177166.532023]  ffff8800769f7b08 ffff8800769f7ae8 ffff8800769f7fd8 0000000=
0001d6240
[177166.532023]  ffff88004d10b720 00000000001d6d40 ffff8800753c1c80 ffff880=
07c02f0a8
[177166.532023]  ffff8800769f7ce8 ffff88007c02ef60 ffff88007c02f0a8 ffff880=
0769f7b18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817665cc>] schedule_timeout+0x25c/0x3f0
[177166.532023]  [<ffffffff810dd4d1>] ? prepare_to_wait_exclusive+0x61/0x90
[177166.532023]  [<ffffffff817676d6>] ? _raw_spin_unlock_irqrestore+0x36/0x=
70
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd4d1>] ? prepare_to_wait_exclusive+0x61/0x90
[177166.532023]  [<ffffffff8160a1c1>] __skb_recv_datagram+0x531/0x620
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff816092c0>] ? datagram_poll+0x120/0x120
[177166.532023]  [<ffffffff8160a2f1>] skb_recv_datagram+0x41/0x60
[177166.532023]  [<ffffffff8165119a>] netlink_recvmsg+0x5a/0x3c0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff815f7d1c>] sock_recvmsg+0x7c/0xc0
[177166.532023]  [<ffffffff815f7ed2>] SYSC_recvfrom+0xf2/0x180
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8102d7cc>] ? do_audit_syscall_entry+0x6c/0x70
[177166.532023]  [<ffffffff8102f2d7>] ? syscall_trace_enter_phase2+0xa7/0x2=
70
[177166.532023]  [<ffffffff815f99ae>] SyS_recvfrom+0xe/0x10
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] iprinit         S ffff88007c133b08 10520   560      1 0x100=
00080
[177166.532023]  ffff88007c133b08 ffff88007c133ae8 ffff88007c133fd8 0000000=
0001d6240
[177166.532023]  ffff88007e1b9b90 00000000001d6d40 ffff8800753c01c8 ffff880=
07c02de18
[177166.532023]  ffff88007c133ce8 ffff88007c02dcd0 ffff88007c02de18 ffff880=
07c133b18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817665cc>] schedule_timeout+0x25c/0x3f0
[177166.532023]  [<ffffffff810dd4d1>] ? prepare_to_wait_exclusive+0x61/0x90
[177166.532023]  [<ffffffff817676d6>] ? _raw_spin_unlock_irqrestore+0x36/0x=
70
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd4d1>] ? prepare_to_wait_exclusive+0x61/0x90
[177166.532023]  [<ffffffff8160a1c1>] __skb_recv_datagram+0x531/0x620
[177166.532023]  [<ffffffff816092c0>] ? datagram_poll+0x120/0x120
[177166.532023]  [<ffffffff8160a2f1>] skb_recv_datagram+0x41/0x60
[177166.532023]  [<ffffffff8165119a>] netlink_recvmsg+0x5a/0x3c0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff815f7d1c>] sock_recvmsg+0x7c/0xc0
[177166.532023]  [<ffffffff815f7ed2>] SYSC_recvfrom+0xf2/0x180
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8102d7cc>] ? do_audit_syscall_entry+0x6c/0x70
[177166.532023]  [<ffffffff8102f2d7>] ? syscall_trace_enter_phase2+0xa7/0x2=
70
[177166.532023]  [<ffffffff815f99ae>] SyS_recvfrom+0xe/0x10
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] iprdump         S ffff8800737c3b08  9608   574      1 0x100=
00080
[177166.532023]  ffff8800737c3b08 ffff8800737c3ae8 ffff8800737c3fd8 0000000=
0001d6240
[177166.532023]  ffff88004d1a9b90 00000000001d6d40 ffff88007c031008 ffff880=
07c02c240
[177166.532023]  ffff8800737c3ce8 ffff88007c02c0f8 ffff88007c02c240 ffff880=
0737c3b18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817665cc>] schedule_timeout+0x25c/0x3f0
[177166.532023]  [<ffffffff810dd4d1>] ? prepare_to_wait_exclusive+0x61/0x90
[177166.532023]  [<ffffffff817676d6>] ? _raw_spin_unlock_irqrestore+0x36/0x=
70
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd4d1>] ? prepare_to_wait_exclusive+0x61/0x90
[177166.532023]  [<ffffffff8160a1c1>] __skb_recv_datagram+0x531/0x620
[177166.532023]  [<ffffffff816092c0>] ? datagram_poll+0x120/0x120
[177166.532023]  [<ffffffff8160a2f1>] skb_recv_datagram+0x41/0x60
[177166.532023]  [<ffffffff8165119a>] netlink_recvmsg+0x5a/0x3c0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff815f7d1c>] sock_recvmsg+0x7c/0xc0
[177166.532023]  [<ffffffff815f7ed2>] SYSC_recvfrom+0xf2/0x180
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8102d7cc>] ? do_audit_syscall_entry+0x6c/0x70
[177166.532023]  [<ffffffff8102f2d7>] ? syscall_trace_enter_phase2+0xa7/0x2=
70
[177166.532023]  [<ffffffff815f99ae>] SyS_recvfrom+0xe/0x10
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] cfg80211        S ffff88007a713d88 14400   583      2 0x100=
00080
[177166.532023]  ffff88007a713d88 ffffffff810aa6e0 ffff88007a713fd8 0000000=
0001d6240
[177166.532023]  ffff88007e203720 ffffffff81c4b120 ffff88007c070e38 ffff880=
07a8d1b90
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007ca9fc10 ffff880=
07a713d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] polkitd         S ffff88007c21ba08  8648   586      1 0x100=
00080
[177166.532023]  ffff88007c21ba08 ffff88007c21b9c8 ffff88007c21bfd8 0000000=
0001d6240
[177166.532023]  ffff88006cef8000 0000000000000006 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007c21bb9c ffff88007c21bb9c 0000000000000000 ffff880=
07c21ba18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff8176428e>] ? mutex_unlock+0xe/0x10
[177166.532023]  [<ffffffff81764179>] ? __mutex_unlock_slowpath+0xc9/0x1d0
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff811b6b02>] ? ___perf_sw_event+0x192/0x2b0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff811b6b02>] ? ___perf_sw_event+0x192/0x2b0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] gdbus           S ffff880079b9fa08  8600   587      1 0x100=
00080
[177166.532023]  ffff880079b9fa08 ffff88007c03b720 ffff880079b9ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e2052b0 ffff88007c03b720 0000000000000000 0000000=
000000000
[177166.532023]  ffff880079b9fb9c ffff880079b9fb9c 0000000000000000 ffff880=
079b9fa18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff811b6b02>] ? ___perf_sw_event+0x192/0x2b0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff811b6b02>] ? ___perf_sw_event+0x192/0x2b0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff811b6b21>] ? ___perf_sw_event+0x1b1/0x2b0
[177166.532023]  [<ffffffff811b69a8>] ? ___perf_sw_event+0x38/0x2b0
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] JS GC Helper    S ffff88007ba0fc98 14408   588      1 0x100=
00080
[177166.532023]  ffff88007ba0fc98 ffff88007ba0fc68 ffff88007ba0ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e199b90 0000000000000000 ffff88007a0652b0 0000000=
000000000
[177166.532023]  ffff88007a0652b0 ffff88007ba0fdc8 ffffc90000a28e80 ffff880=
07ba0fca8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8112c0e9>] futex_wait_queue_me+0xe9/0x190
[177166.532023]  [<ffffffff8112cf79>] futex_wait+0x179/0x280
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8112eeee>] do_futex+0xfe/0x560
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8112f3d0>] SyS_futex+0x80/0x180
[177166.532023]  [<ffffffff8139a41e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] JS Sour~ Thread S ffff88007a947c98 14552   589      1 0x100=
00080
[177166.532023]  ffff88007a947c98 ffff88007a947c68 ffff88007a947fd8 0000000=
0001d6240
[177166.532023]  ffff88007e199b90 0000000000000000 ffff88007a061b90 0000000=
000000000
[177166.532023]  ffff88007a061b90 ffff88007a947dc8 ffffc90000a2ee80 ffff880=
07a947ca8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8112c0e9>] futex_wait_queue_me+0xe9/0x190
[177166.532023]  [<ffffffff8112cf79>] futex_wait+0x179/0x280
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8112eeee>] do_futex+0xfe/0x560
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8112f3d0>] SyS_futex+0x80/0x180
[177166.532023]  [<ffffffff8139a41e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] runaway-killer- S ffff8800799aba08 13968   590      1 0x100=
00080
[177166.532023]  ffff8800799aba08 ffff88007ca852b0 ffff8800799abfd8 0000000=
0001d6240
[177166.532023]  ffff88007e199b90 ffff88007ca852b0 0000000000000000 0000000=
000000000
[177166.532023]  ffff8800799abb8c ffff8800799abb8c 0000000000000000 ffff880=
0799aba18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff8122b839>] ? deactivate_slab+0x5a9/0x640
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8112c691>] ? futex_wake_op+0x311/0x5a0
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] gmain           S ffff8800799afa08 13504   591      1 0x100=
00080
[177166.532023]  ffff8800799afa08 ffff880073700000 ffff8800799affd8 0000000=
0001d6240
[177166.532023]  ffff88007c03b720 ffff880073700000 0000000000000000 0000000=
000000000
[177166.532023]  ffff8800799afb8c ffff8800799afb8c 0000000000000000 ffff880=
0799afa18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] dhclient        R  running task     9000   604    534 0x100=
00080
[177166.532023]  ffff88007a9f3758 000000010a8acd12 ffff88007a9f3fd8 0000000=
0001d6240
[177166.532023]  0000000000000001 0000000000000292 ffff88007a9f3798 fffffff=
f82fa59c0
[177166.532023]  000000010a8acd15 ffffffff82fa59c0 0000000000000000 ffff880=
07a9f3768
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff811dca75>] ? try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023]  [<ffffffff81398979>] ? copy_user_generic_unrolled+0x89/0xc=
0
[177166.532023]  [<ffffffff8126846d>] ? set_fd_set+0x3d/0x50
[177166.532023]  [<ffffffff81269478>] ? core_sys_select+0x2c8/0x4a0
[177166.532023]  [<ffffffff812691f8>] ? core_sys_select+0x48/0x4a0
[177166.532023]  [<ffffffff8126887c>] ? poll_select_set_timeout+0x5c/0x90
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8126887c>] ? poll_select_set_timeout+0x5c/0x90
[177166.532023]  [<ffffffff8111ed74>] ? ktime_get_ts64+0x84/0x180
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff8106b769>] ? kvm_clock_get_cycles+0x9/0x10
[177166.532023]  [<ffffffff8111eda6>] ? ktime_get_ts64+0xb6/0x180
[177166.532023]  [<ffffffff8126887c>] ? poll_select_set_timeout+0x5c/0x90
[177166.532023]  [<ffffffff8126970f>] ? SyS_select+0xbf/0x120
[177166.532023]  [<ffffffff8176857a>] ? tracesys_phase2+0xd8/0xdd
[177166.532023] sshd            R  running task    11096   826      1 0x100=
00080
[177166.532023]  ffff88007c26b758 000000010a8acd35 ffff88007c26bfd8 0000000=
0001d6240
[177166.532023]  ffff88007500b720 0000000000000292 ffff88007c26b798 fffffff=
f82fa59c0
[177166.532023]  000000010a8acd35 ffffffff82fa59c0 0000000000000000 ffff880=
07c26b768
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff811dc694>] ? do_try_to_free_pages+0x194/0x470
[177166.532023]  [<ffffffff81760f99>] ? schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] ? schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023]  [<ffffffff81398979>] ? copy_user_generic_unrolled+0x89/0xc=
0
[177166.532023]  [<ffffffff8126846d>] ? set_fd_set+0x3d/0x50
[177166.532023]  [<ffffffff81269478>] ? core_sys_select+0x2c8/0x4a0
[177166.532023]  [<ffffffff812691f8>] ? core_sys_select+0x48/0x4a0
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126970f>] ? SyS_select+0xbf/0x120
[177166.532023]  [<ffffffff8176857a>] ? tracesys_phase2+0xd8/0xdd
[177166.532023] xinetd          S ffff88007aaafa08 12488   828      1 0x100=
00080
[177166.532023]  ffff88007aaafa08 ffff88007c271b90 ffff88007aaaffd8 0000000=
0001d6240
[177166.532023]  ffff88007c273720 ffff88007c271b90 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007aaafb8c ffff88007aaafb8c 0000000000000000 ffff880=
07aaafa18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810dd594>] ? __wake_up_sync_key+0x54/0x70
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810dd594>] ? __wake_up_sync_key+0x54/0x70
[177166.532023]  [<ffffffff815fe326>] ? sock_def_readable+0xd6/0x1b0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff815fe326>] ? sock_def_readable+0xd6/0x1b0
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] rpcbind         R  running task     8136   841      1 0x100=
00080
[177166.532023]  ffff88007aa77a38 000000010a8ac4e3 ffff88007aa77fd8 0000000=
0001d6240
[177166.532023]  ffff880075c19b90 0000000000000296 ffff88007aa77a78 ffff880=
07e1f4000
[177166.532023]  000000010a8ac4e3 ffff88007e1f4000 0000000000000000 ffff880=
07aa77a48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] rpc.statd       S ffff88007ba4f898  8952   892      1 0x100=
00080
[177166.532023]  ffff88007ba4f898 ffff88007ba4f868 ffff88007ba4ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e139b90 ffff88007ba4f878 0000000000000000 0000000=
000000040
[177166.532023]  0000000000400000 0000000000000016 0000000000000016 ffff880=
07ba4f8a8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff8169a2f6>] ? udp_poll+0xe6/0x1d0
[177166.532023]  [<ffffffff8169a215>] ? udp_poll+0x5/0x1d0
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81268f0f>] do_select+0x65f/0x900
[177166.532023]  [<ffffffff812688b5>] ? do_select+0x5/0x900
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff810e4faf>] ? lock_release_holdtime.part.24+0xf/0=
x190
[177166.532023]  [<ffffffff810eaf38>] ? lock_release_non_nested+0x308/0x350
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff811f8f4f>] ? might_fault+0x5f/0xb0
[177166.532023]  [<ffffffff81269440>] core_sys_select+0x290/0x4a0
[177166.532023]  [<ffffffff812691f8>] ? core_sys_select+0x48/0x4a0
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126970f>] SyS_select+0xbf/0x120
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] ypbind          S ffff88007a38fa08 11096   910      1 0x100=
00080
[177166.532023]  ffff88007a38fa08 ffff88007a38f9c8 ffff88007a38ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e3d0000 ffff880073731560 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007a38fb94 ffff88007a38fb94 0000000000000000 ffff880=
07a38fa18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff81676309>] ? tcp_poll+0x109/0x3b0
[177166.532023]  [<ffffffff81676205>] ? tcp_poll+0x5/0x3b0
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff816679b0>] ? ip_reply_glue_bits+0x60/0x60
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff816a9983>] ? inet_sendmsg+0xc3/0x1e0
[177166.532023]  [<ffffffff816a99c6>] ? inet_sendmsg+0x106/0x1e0
[177166.532023]  [<ffffffff816a98c5>] ? inet_sendmsg+0x5/0x1e0
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff81273db8>] ? __fget+0xf8/0x200
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] ypbind          S ffff8800746d7d38 13912   917      1 0x100=
00080
[177166.532023]  ffff8800746d7d38 ffff8800746d7d08 ffff8800746d7fd8 0000000=
0001d6240
[177166.532023]  ffff88007aa9b720 0000000000000000 ffff88007373b720 7ffffff=
fffffffff
[177166.532023]  ffff8800746d7ec0 ffff88007373b720 0000000000000000 ffff880=
0746d7d48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817665cc>] schedule_timeout+0x25c/0x3f0
[177166.532023]  [<ffffffff8109ddff>] ? do_sigtimedwait+0x15f/0x240
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8109ddff>] ? do_sigtimedwait+0x15f/0x240
[177166.532023]  [<ffffffff81767740>] ? _raw_spin_unlock_irq+0x30/0x50
[177166.532023]  [<ffffffff81766789>] schedule_timeout_interruptible+0x29/0=
x30
[177166.532023]  [<ffffffff8109de0f>] do_sigtimedwait+0x16f/0x240
[177166.532023]  [<ffffffff8109df78>] SYSC_rt_sigtimedwait+0x98/0x100
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8102d7cc>] ? do_audit_syscall_entry+0x6c/0x70
[177166.532023]  [<ffffffff8102f1d3>] ? syscall_trace_enter_phase1+0x143/0x=
1a0
[177166.532023]  [<ffffffff8139a41e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[177166.532023]  [<ffffffff8109dfee>] SyS_rt_sigtimedwait+0xe/0x10
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] ypbind          S ffff8800746dba08  8600   918      1 0x100=
00080
[177166.532023]  ffff8800746dba08 ffff8800746db9d8 ffff8800746dbfd8 0000000=
0001d6240
[177166.532023]  ffff88000fcd52b0 ffff8800746db9e8 0000000000000000 0000000=
000000000
[177166.532023]  ffff8800746dbb94 ffff8800746dbb94 0000000000000000 ffff880=
0746dba18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff8126833f>] ? __pollwait+0x7f/0xf0
[177166.532023]  [<ffffffff816e6074>] ? unix_poll+0x44/0xe0
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff811b6b02>] ? ___perf_sw_event+0x192/0x2b0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff811b6b02>] ? ___perf_sw_event+0x192/0x2b0
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] ypbind          R  running task     8648   929      1 0x100=
00080
[177166.532023]  ffff88007a39ba18 000000010a8ace0d ffff88007a39bfd8 ffff880=
07a21b960
[177166.532023]  ffff880077490000 0000000000000292 ffff88007a39ba58 ffff880=
07e234000
[177166.532023]  000000010a8ace0f ffff88007e234000 0000000000000000 ffff880=
07a39ba28
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c0f2f>] __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c3ff8>] filemap_fault+0x1c8/0x460
[177166.532023]  [<ffffffff811f903c>] __do_fault+0x4c/0xd0
[177166.532023]  [<ffffffff811fd7b0>] handle_mm_fault+0xcf0/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] sendmail        R  running task     8648   915      1 0x100=
00084
[177166.532023]  ffff88007cbe3a18 000000010a8ac4e3 ffff88007cbe3fd8 0000000=
0001d6240
[177166.532023]  ffff880073738000 0000000000000292 ffff88007cbe3a58 ffff880=
07e1f4000
[177166.532023]  000000010a8ac4e3 ffff88007e1f4000 0000000000000000 ffff880=
07cbe3a28
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c0f2f>] __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c3ff8>] filemap_fault+0x1c8/0x460
[177166.532023]  [<ffffffff811f903c>] __do_fault+0x4c/0xd0
[177166.532023]  [<ffffffff811fd7b0>] handle_mm_fault+0xcf0/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] sendmail        D ffff880079913818  9336   973      1 0x100=
00080
[177166.532023]  ffff880079913818 000000010a8ace36 ffff880079913fd8 0000000=
0001d6240
[177166.532023]  ffff88007a8d52b0 ffff8800833d6000 0000000000000000 fffffff=
f82fa59c0
[177166.532023]  000000010a8ace38 ffffffff82fa59c0 0000000000000000 ffff880=
079913828
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd74a>] ? __alloc_pages_nodemask+0xaea/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023]  [<ffffffff81398931>] ? copy_user_generic_unrolled+0x41/0xc=
0
[177166.532023]  [<ffffffff8102c2a1>] ? save_xstate_sig+0xd1/0x220
[177166.532023]  [<ffffffff8101db27>] ? do_signal+0x5d7/0x750
[177166.532023]  [<ffffffff8122b1ec>] ? kfree+0x2dc/0x380
[177166.532023]  [<ffffffff8101dcff>] ? do_notify_resume+0x5f/0xa0
[177166.532023]  [<ffffffff8176868c>] ? int_signal+0x12/0x17
[177166.532023] crond           R  running task     8648   992      1 0x100=
00080
[177166.532023]  ffff880076a13a18 000000010a8ace51 ffff880076a13fd8 0000000=
0001d6240
[177166.532023]  ffff88007a063720 0000000000000292 ffff880076a13a58 ffff880=
0833d8208
[177166.532023]  000000010a8ace53 ffff88007e274000 0000000000000000 ffff880=
076a13a28
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff811dc694>] ? do_try_to_free_pages+0x194/0x470
[177166.532023]  [<ffffffff81760f99>] ? schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] ? schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] ? alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c0f2f>] ? __page_cache_alloc+0x14f/0x170
[177166.532023]  [<ffffffff811c3ff8>] ? filemap_fault+0x1c8/0x460
[177166.532023]  [<ffffffff811f903c>] ? __do_fault+0x4c/0xd0
[177166.532023]  [<ffffffff811fd7b0>] ? handle_mm_fault+0xcf0/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] atd             R  running task     9240   997      1 0x100=
00080
[177166.532023]  ffff880075f23a38 000000010a8ace66 ffff880075f23fd8 0000000=
0001d6240
[177166.532023]  ffff880077490000 0000000000000296 ffff880075f23a78 ffff880=
07e234000
[177166.532023]  000000010a8ace66 ffff88007e234000 ffffffff811dc694 ffff880=
075f23a48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd445>] ? __alloc_pages_nodemask+0x7e5/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] login           S ffff880079aa3e58 11848  1008      1 0x100=
00080
[177166.532023]  ffff880079aa3e58 ffff880079aa3e18 ffff880079aa3fd8 0000000=
0001d6240
[177166.532023]  ffff8800426ab720 ffff8800771ca320 ffff880079aa3ef8 ffff880=
0771ca320
[177166.532023]  ffff8800771c9b90 ffff8800771c9b90 ffff8800771c9b80 ffff880=
079aa3e68
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8108c394>] do_wait+0x254/0x410
[177166.532023]  [<ffffffff8108d8b0>] SyS_wait4+0x80/0x110
[177166.532023]  [<ffffffff8108a890>] ? rcu_read_lock_sched_held+0xa0/0xa0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] kworker/2:1H    S ffff880075dd3db8 11600  1009      2 0x100=
00080
[177166.532023]  ffff880075dd3db8 ffff88007aee3b18 ffff880075dd3fd8 0000000=
0001d6240
[177166.532023]  ffff88007e203720 ffff8800819d5c80 ffff8800819d5c80 ffff880=
0819d5c80
[177166.532023]  ffff88007aee3b18 ffff8800750f3720 ffff88007aee3ae8 ffff880=
075dd3dc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] automount       S ffff880079e33d38 11848  1023      1 0x100=
00080
[177166.532023]  ffff880079e33d38 ffff880079e33d08 ffff880079e33fd8 0000000=
0001d6240
[177166.532023]  ffff880075c18000 0000000000000000 ffff88007685b720 7ffffff=
fffffffff
[177166.532023]  ffff880079e33ec0 ffff88007685b720 0000000000000000 ffff880=
079e33d48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817665cc>] schedule_timeout+0x25c/0x3f0
[177166.532023]  [<ffffffff8109ddff>] ? do_sigtimedwait+0x15f/0x240
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8109ddff>] ? do_sigtimedwait+0x15f/0x240
[177166.532023]  [<ffffffff81767740>] ? _raw_spin_unlock_irq+0x30/0x50
[177166.532023]  [<ffffffff81766789>] schedule_timeout_interruptible+0x29/0=
x30
[177166.532023]  [<ffffffff8109de0f>] do_sigtimedwait+0x16f/0x240
[177166.532023]  [<ffffffff8109df78>] SYSC_rt_sigtimedwait+0x98/0x100
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8102d7cc>] ? do_audit_syscall_entry+0x6c/0x70
[177166.532023]  [<ffffffff8102f1d3>] ? syscall_trace_enter_phase1+0x143/0x=
1a0
[177166.532023]  [<ffffffff8139a41e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[177166.532023]  [<ffffffff8109dfee>] SyS_rt_sigtimedwait+0xe/0x10
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] automount       R  running task     8648  1024      1 0x100=
00080
[177166.532023]  ffff8800833d6880 000000010a8acea4 ffff880079e43fd8 0000000=
0001d6240
[177166.532023]  ffff88007c273720 0000000000000296 ffff880079e43a78 ffff880=
07e234000
[177166.532023]  000000010a8acea4 ffff88007e234000 0000000000000000 ffff880=
076a8d2b0
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff811dca75>] ? try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] automount       S ffff88007313bc98  8872  1025      1 0x100=
00080
[177166.532023]  ffff88007313bc98 ffff88007313bc68 ffff88007313bfd8 0000000=
0001d6240
[177166.532023]  ffff8800417e52b0 0000000000000000 ffff880076a8b720 0000000=
000000000
[177166.532023]  ffff880076a8b720 ffff88007313bdc8 ffffc90000a30880 ffff880=
07313bca8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8112c0e9>] futex_wait_queue_me+0xe9/0x190
[177166.532023]  [<ffffffff8112cf79>] futex_wait+0x179/0x280
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff8112eeee>] do_futex+0xfe/0x560
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8112f3d0>] SyS_futex+0x80/0x180
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] automount       S ffff88007a327a08 12024  1066      1 0x100=
00080
[177166.532023]  ffff88007a327a08 ffff880079b53720 ffff88007a327fd8 0000000=
0001d6240
[177166.532023]  ffff880076a8b720 ffff880079b53720 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007a327b9c ffff88007a327b9c 0000000000000000 ffff880=
07a327a18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8112c691>] ? futex_wake_op+0x311/0x5a0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] automount       S ffff880076a1ba08 11848  1082      1 0x100=
00080
[177166.532023]  ffff880076a1ba08 ffff880076c61b90 ffff880076a1bfd8 0000000=
0001d6240
[177166.532023]  ffff880076a8b720 ffff880076c61b90 0000000000000000 0000000=
000000000
[177166.532023]  ffff880076a1bb9c ffff880076a1bb9c 0000000000000000 ffff880=
076a1ba18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8112c691>] ? futex_wake_op+0x311/0x5a0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] automount       S ffff88007a043a08 12024  1092      1 0x100=
00080
[177166.532023]  ffff88007a043a08 ffff880076b90000 ffff88007a043fd8 0000000=
0001d6240
[177166.532023]  ffff880076a8b720 ffff880076b90000 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007a043b9c ffff88007a043b9c 0000000000000000 ffff880=
07a043a18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81756961>] ? calc_delta_fair.part.45+0x11/0x13
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8112c691>] ? futex_wake_op+0x311/0x5a0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] automount       S ffff880075d1fa08 10832  1096      1 0x100=
00080
[177166.532023]  ffff880075d1fa08 ffff880076a88000 ffff880075d1ffd8 0000000=
0001d6240
[177166.532023]  ffff880052f9b720 ffff880076a88000 0000000000000000 0000000=
000000000
[177166.532023]  ffff880075d1fb9c ffff880075d1fb9c 0000000000000000 ffff880=
075d1fa18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff813b9631>] ? free_object+0x81/0xb0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff813b9631>] ? free_object+0x81/0xb0
[177166.532023]  [<ffffffff817676d6>] ? _raw_spin_unlock_irqrestore+0x36/0x=
70
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] automount       S ffff8800798fba08 12488  1101      1 0x100=
00080
[177166.532023]  ffff8800798fba08 ffff8800746f0000 ffff8800798fbfd8 0000000=
0001d6240
[177166.532023]  ffff880076a8b720 ffff8800746f0000 0000000000000000 0000000=
000000000
[177166.532023]  ffff8800798fbb9c ffff8800798fbb9c 0000000000000000 ffff880=
0798fba18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81756961>] ? calc_delta_fair.part.45+0x11/0x13
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8112c691>] ? futex_wake_op+0x311/0x5a0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] automount       S ffff88007abafa08 12488  1107      1 0x100=
00080
[177166.532023]  ffff88007abafa08 ffff88007c9652b0 ffff88007abaffd8 0000000=
0001d6240
[177166.532023]  ffff880076a8b720 ffff88007c9652b0 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007abafb9c ffff88007abafb9c 0000000000000000 ffff880=
07abafa18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8112c691>] ? futex_wake_op+0x311/0x5a0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] automount       S ffff880076a0fa08 12488  1114      1 0x100=
00080
[177166.532023]  ffff880076a0fa08 ffff88007374d2b0 ffff880076a0ffd8 0000000=
0001d6240
[177166.532023]  ffff88007e139b90 ffff88007374d2b0 0000000000000000 0000000=
000000000
[177166.532023]  ffff880076a0fb9c ffff880076a0fb9c 0000000000000000 ffff880=
076a0fa18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8112c691>] ? futex_wake_op+0x311/0x5a0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] automount       S ffff880076f2ba08 12488  1118      1 0x100=
00080
[177166.532023]  ffff880076f2ba08 ffff88007a2a0000 ffff880076f2bfd8 0000000=
0001d6240
[177166.532023]  ffff88007e139b90 ffff88007a2a0000 0000000000000000 0000000=
000000000
[177166.532023]  ffff880076f2bb9c ffff880076f2bb9c 0000000000000000 ffff880=
076f2ba18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8112c691>] ? futex_wake_op+0x311/0x5a0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] automount       S ffff88007a497a08 12488  1122      1 0x100=
00080
[177166.532023]  ffff88007a497a08 ffff880079b552b0 ffff88007a497fd8 0000000=
0001d6240
[177166.532023]  ffff880076a8b720 ffff880079b552b0 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007a497b9c ffff88007a497b9c 0000000000000000 ffff880=
07a497a18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81756961>] ? calc_delta_fair.part.45+0x11/0x13
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8112c691>] ? futex_wake_op+0x311/0x5a0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] automount       S ffff880076ddfa08 12488  1127      1 0x100=
00080
[177166.532023]  ffff880076ddfa08 ffff88007c270000 ffff880076ddffd8 0000000=
0001d6240
[177166.532023]  ffff88007685b720 ffff88007c270000 0000000000000000 0000000=
000000000
[177166.532023]  ffff880076ddfb9c ffff880076ddfb9c 0000000000000000 ffff880=
076ddfa18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8112c691>] ? futex_wake_op+0x311/0x5a0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] automount       S ffff880076a9fa08 13368  1131      1 0x100=
00080
[177166.532023]  ffff880076a9fa08 ffff88007a0e1b90 ffff880076a9ffd8 0000000=
0001d6240
[177166.532023]  ffff88007685b720 ffff88007a0e1b90 0000000000000000 0000000=
000000000
[177166.532023]  ffff880076a9fb9c ffff880076a9fb9c 0000000000000000 ffff880=
076a9fa18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81756961>] ? calc_delta_fair.part.45+0x11/0x13
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8112c691>] ? futex_wake_op+0x311/0x5a0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] automount       S ffff8800768fba08 12488  1134      1 0x100=
00080
[177166.532023]  ffff8800768fba08 ffff880076b93720 ffff8800768fbfd8 0000000=
0001d6240
[177166.532023]  ffff88007685b720 ffff880076b93720 0000000000000000 0000000=
000000000
[177166.532023]  ffff8800768fbb9c ffff8800768fbb9c 0000000000000000 ffff880=
0768fba18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff81756961>] ? calc_delta_fair.part.45+0x11/0x13
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810ea106>] ? __lock_acquire+0x396/0xbe0
[177166.532023]  [<ffffffff8112c691>] ? futex_wake_op+0x311/0x5a0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] automount       S ffff880079ae3a08 13368  1138      1 0x100=
00080
[177166.532023]  ffff880079ae3a08 ffff8800746f52b0 ffff880079ae3fd8 0000000=
0001d6240
[177166.532023]  ffffffff81c154e0 ffff8800746f52b0 0000000000000000 0000000=
000000000
[177166.532023]  ffff880079ae3b9c ffff880079ae3b9c 0000000000000000 ffff880=
079ae3a18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff810dd2b0>] ? add_wait_queue+0x40/0x50
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff813b9631>] ? free_object+0x81/0xb0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff813b9631>] ? free_object+0x81/0xb0
[177166.532023]  [<ffffffff817676d6>] ? _raw_spin_unlock_irqrestore+0x36/0x=
70
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] sshd            S ffff880073053a08 11264  1808    826 0x100=
00080
[177166.532023]  ffff880073053a08 ffff8800730539d8 ffff880073053fd8 0000000=
0001d6240
[177166.532023]  ffff88007983d2b0 ffff8800730539e8 0000000000000000 0000000=
000000000
[177166.532023]  ffff880073053b8c ffff880073053b8c 0000000000000000 ffff880=
073053a18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff8126833f>] ? __pollwait+0x7f/0xf0
[177166.532023]  [<ffffffff816e6074>] ? unix_poll+0x44/0xe0
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff81133226>] ? __module_text_address+0x16/0x80
[177166.532023]  [<ffffffff81178eee>] ? is_ftrace_trampoline+0x3e/0x80
[177166.532023]  [<ffffffff810225bf>] ? print_context_stack+0x8f/0x100
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812635a5>] ? putname+0x45/0x70
[177166.532023]  [<ffffffff8175afad>] ? __slab_free+0x1ce/0x242
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8175afad>] ? __slab_free+0x1ce/0x242
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] kworker/1:1H    S ffff880079d37db8 12080  1817      2 0x100=
00080
[177166.532023]  ffff880079d37db8 ffff880073788238 ffff880079d37fd8 0000000=
0001d6240
[177166.532023]  ffff88006391d2b0 ffff8800817d5c80 ffff8800817d5c80 ffff880=
0817d5c80
[177166.532023]  ffff880073788238 ffff880079b50000 ffff880073788208 ffff880=
079d37dc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] nfsiod          S ffff8800753abd88 14384  1818      2 0x100=
00080
[177166.532023]  ffff8800753abd88 ffffffff810aa6e0 ffff8800753abfd8 0000000=
0001d6240
[177166.532023]  ffff880076c652b0 ffffffff81c4b120 ffff88007378bae8 ffff880=
07c2752b0
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff880076f18100 ffff880=
0753abd98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] lockd           S ffff88007a0d3c38 13840  1825      2 0x100=
00080
[177166.532023]  ffff88007a0d3c38 ffff880079839b90 ffff88007a0d3fd8 0000000=
0001d6240
[177166.532023]  ffff88007e203720 ffff88007a0d3c28 ffff880079839b90 ffff880=
073789040
[177166.532023]  ffff880073042148 0000000000000000 0000000000002000 ffff880=
07a0d3c48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817665cc>] schedule_timeout+0x25c/0x3f0
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffffa028dbf1>] ? nlmsvc_retry_blocked+0x111/0x400 [l=
ockd]
[177166.532023]  [<ffffffffa0253c79>] svc_recv+0x8a9/0x10b0 [sunrpc]
[177166.532023]  [<ffffffffa028dbf1>] ? nlmsvc_retry_blocked+0x111/0x400 [l=
ockd]
[177166.532023]  [<ffffffffa028bff0>] ? lockd_up+0x4b0/0x4b0 [lockd]
[177166.532023]  [<ffffffffa028c076>] lockd+0x86/0x2e0 [lockd]
[177166.532023]  [<ffffffff81760a84>] ? __schedule+0x2c4/0x7b0
[177166.532023]  [<ffffffffa028bff0>] ? lockd_up+0x4b0/0x4b0 [lockd]
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] sshd            S ffff880079b63898  7696  1826   1808 0x100=
00080
[177166.532023]  ffff880079b63898 ffff880079b63878 ffff880079b63fd8 0000000=
0001d6240
[177166.532023]  ffff880079c31b90 00000000001d6d40 0000000000000000 0000000=
000000040
[177166.532023]  0000000000004000 000000000000000e 000000000000000e ffff880=
079b638a8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff81478236>] ? tty_ldisc_deref+0x16/0x20
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81268f0f>] do_select+0x65f/0x900
[177166.532023]  [<ffffffff812688b5>] ? do_select+0x5/0x900
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff810eaf38>] ? lock_release_non_nested+0x308/0x350
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff811f8f4f>] ? might_fault+0x5f/0xb0
[177166.532023]  [<ffffffff81269440>] core_sys_select+0x290/0x4a0
[177166.532023]  [<ffffffff812691f8>] ? core_sys_select+0x48/0x4a0
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126970f>] SyS_select+0xbf/0x120
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] bash            S ffff880079af3e58 11280  1827   1826 0x100=
00080
[177166.532023]  ffff880079af3e58 ffff880079af3e18 ffff880079af3fd8 0000000=
0001d6240
[177166.532023]  ffff8800274a52b0 ffff88007983beb0 ffff880079af3ef8 ffff880=
07983beb0
[177166.532023]  ffff88007983b720 ffff88007983b720 ffff88007983b710 ffff880=
079af3e68
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8108c394>] do_wait+0x254/0x410
[177166.532023]  [<ffffffff8108d8b0>] SyS_wait4+0x80/0x110
[177166.532023]  [<ffffffff8108a890>] ? rcu_read_lock_sched_held+0xa0/0xa0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] kworker/0:1H    S ffff88007a0cbdb8 11216  1842      2 0x100=
00080
[177166.532023]  ffff88007a0cbdb8 ffff88007378a2b8 ffff88007a0cbfd8 0000000=
0001d6240
[177166.532023]  ffff88007e139b90 ffff8800815d5c80 ffff8800815d5c80 ffff880=
0815d5c80
[177166.532023]  ffff88007378a2b8 ffff88007aa99b90 ffff88007378a288 ffff880=
07a0cbdc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] sshd            S ffff88007afe7a08 11704  1846    826 0x100=
00080
[177166.532023]  ffff88007afe7a08 ffff88007afe79d8 ffff88007afe7fd8 0000000=
0001d6240
[177166.532023]  ffff880073748000 ffff88007afe79e8 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007afe7b8c ffff88007afe7b8c 0000000000000000 ffff880=
07afe7a18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff8126833f>] ? __pollwait+0x7f/0xf0
[177166.532023]  [<ffffffff816e6074>] ? unix_poll+0x44/0xe0
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff81133226>] ? __module_text_address+0x16/0x80
[177166.532023]  [<ffffffff81178eee>] ? is_ftrace_trampoline+0x3e/0x80
[177166.532023]  [<ffffffff810aeb64>] ? __kernel_text_address+0x64/0x90
[177166.532023]  [<ffffffff810225bf>] ? print_context_stack+0x8f/0x100
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8175a717>] ? cmpxchg_double_slab.isra.60+0xe8/0x=
13b
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8175ae54>] ? __slab_free+0x75/0x242
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] sshd            S ffff88007c047898  8648  1853   1846 0x100=
00080
[177166.532023]  ffff88007c047898 ffff88007c047878 ffff88007c047fd8 0000000=
0001d6240
[177166.532023]  ffff880063d33720 00000000001d6d40 0000000000000000 0000000=
000000040
[177166.532023]  0000000000004000 000000000000000e 000000000000000e ffff880=
07c0478a8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff81478236>] ? tty_ldisc_deref+0x16/0x20
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81268f0f>] do_select+0x65f/0x900
[177166.532023]  [<ffffffff812688b5>] ? do_select+0x5/0x900
[177166.532023]  [<ffffffff81356a07>] ? submit_bio+0x77/0x150
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff810eaf38>] ? lock_release_non_nested+0x308/0x350
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff811f8f4f>] ? might_fault+0x5f/0xb0
[177166.532023]  [<ffffffff81269440>] core_sys_select+0x290/0x4a0
[177166.532023]  [<ffffffff812691f8>] ? core_sys_select+0x48/0x4a0
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126970f>] SyS_select+0xbf/0x120
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] bash            S ffff88007719fe58 11384  1855   1853 0x100=
00080
[177166.532023]  ffff88007719fe58 ffff88007719fe18 ffff88007719ffd8 0000000=
0001d6240
[177166.532023]  ffff8800771c8000 ffff880079838790 ffff88007719fef8 ffff880=
079838790
[177166.532023]  ffff880079838000 ffff880079838000 ffff880079837ff0 ffff880=
07719fe68
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8108c394>] do_wait+0x254/0x410
[177166.532023]  [<ffffffff8108d8b0>] SyS_wait4+0x80/0x110
[177166.532023]  [<ffffffff8108a890>] ? rcu_read_lock_sched_held+0xa0/0xa0
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] sshd            S ffff88007c0cba08 11704  1923    826 0x100=
00080
[177166.532023]  ffff88007c0cba08 ffff88007c0cb9d8 ffff88007c0cbfd8 0000000=
0001d6240
[177166.532023]  ffff88007e203720 ffff88007c0cb9e8 0000000000000000 0000000=
000000000
[177166.532023]  ffff88007c0cbb8c ffff88007c0cbb8c 0000000000000000 ffff880=
07c0cba18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff8126833f>] ? __pollwait+0x7f/0xf0
[177166.532023]  [<ffffffff816e6074>] ? unix_poll+0x44/0xe0
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81269e44>] do_sys_poll+0x484/0x5c0
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff81133226>] ? __module_text_address+0x16/0x80
[177166.532023]  [<ffffffff81178eee>] ? is_ftrace_trampoline+0x3e/0x80
[177166.532023]  [<ffffffff810aeb64>] ? __kernel_text_address+0x64/0x90
[177166.532023]  [<ffffffff810225bf>] ? print_context_stack+0x8f/0x100
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff8175a717>] ? cmpxchg_double_slab.isra.60+0xe8/0x=
13b
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8175ae54>] ? __slab_free+0x75/0x242
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126a084>] SyS_poll+0x74/0x110
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] sshd            S ffff880079b83898  9016  1925   1923 0x100=
00080
[177166.532023]  ffff880079b83898 ffff880079b83878 ffff880079b83fd8 0000000=
0001d6240
[177166.532023]  ffff880075c1b720 00000000001d6d40 0000000000000000 0000000=
000000040
[177166.532023]  0000000000004000 000000000000000e 000000000000000e ffff880=
079b838a8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766bc5>] schedule_hrtimeout_range_clock+0x1a5/=
0x1c0
[177166.532023]  [<ffffffff81478236>] ? tty_ldisc_deref+0x16/0x20
[177166.532023]  [<ffffffff81766bf3>] schedule_hrtimeout_range+0x13/0x20
[177166.532023]  [<ffffffff81268404>] poll_schedule_timeout+0x54/0x80
[177166.532023]  [<ffffffff81268f0f>] do_select+0x65f/0x900
[177166.532023]  [<ffffffff812688b5>] ? do_select+0x5/0x900
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff812685e0>] ? poll_select_copy_remaining+0x160/0x=
160
[177166.532023]  [<ffffffff810eaf38>] ? lock_release_non_nested+0x308/0x350
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff811f8f4f>] ? might_fault+0x5f/0xb0
[177166.532023]  [<ffffffff81269440>] core_sys_select+0x290/0x4a0
[177166.532023]  [<ffffffff812691f8>] ? core_sys_select+0x48/0x4a0
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8126970f>] SyS_select+0xbf/0x120
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] bash            S ffff88007a163c48 10976  1926   1925 0x100=
00080
[177166.532023]  ffff88007a163c48 ffff880079a89b90 ffff88007a163fd8 0000000=
0001d6240
[177166.532023]  ffff880077193720 ffff88007a163c98 ffff88007a163e28 ffff880=
0768d4a40
[177166.532023]  0000000000000001 ffffc90000a90000 7fffffffffffffff ffff880=
07a163c58
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817665cc>] schedule_timeout+0x25c/0x3f0
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff814746a5>] ? n_tty_read+0x265/0xb40
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff814746a5>] ? n_tty_read+0x265/0xb40
[177166.532023]  [<ffffffff810dd7a7>] wait_woken+0x87/0xb0
[177166.532023]  [<ffffffff814746b6>] n_tty_read+0x276/0xb40
[177166.532023]  [<ffffffff810dd700>] ? abort_exclusive_wait+0xb0/0xb0
[177166.532023]  [<ffffffff8146fd9d>] tty_read+0x8d/0x100
[177166.532023]  [<ffffffff81251ed8>] __vfs_read+0x18/0x50
[177166.532023]  [<ffffffff81251f9d>] vfs_read+0x8d/0x150
[177166.532023]  [<ffffffff812520b8>] SyS_read+0x58/0xd0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] iscsi_eh        S ffff88007a4b3d88 14384  2092      2 0x100=
00080
[177166.532023]  ffff88007a4b3d88 0000000000000000 ffff88007a4b3fd8 0000000=
0001d6240
[177166.532023]  ffff88007a2a3720 ffffffff81767747 ffff88007a50ecb0 ffff880=
07a2a1b90
[177166.532023]  ffffffff810aa6e0 0000000000000000 ffff88007a55aef0 ffff880=
07a4b3d98
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81767747>] ? _raw_spin_unlock_irq+0x37/0x50
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa972>] rescuer_thread+0x292/0x330
[177166.532023]  [<ffffffff810aa6e0>] ? worker_thread+0x460/0x460
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] trinity         S ffff880073293e58 13752  2902   1855 0x100=
00080
[177166.532023]  ffff880073293e58 ffff880073293e18 ffff880073293fd8 0000000=
0001d6240
[177166.532023]  ffff88007e139b90 ffff880079c35a40 ffff880073293ef8 ffff880=
079c35a40
[177166.532023]  ffff880079c352b0 ffff880079c352b0 ffff880079c352a0 ffff880=
073293e68
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8108c394>] do_wait+0x254/0x410
[177166.532023]  [<ffffffff8108d8b0>] SyS_wait4+0x80/0x110
[177166.532023]  [<ffffffff8108a890>] ? rcu_read_lock_sched_held+0xa0/0xa0
[177166.532023]  [<ffffffff81768369>] system_call_fastpath+0x12/0x17
[177166.532023] trinity-watchdo R  running task     9160  2903   2902 0x100=
00080
[177166.532023]  ffff8800732aba38 000000010a8ad150 ffff8800732abfd8 0000000=
0001d6240
[177166.532023]  ffff88007df61b90 0000000000000296 ffff8800732aba78 ffff880=
07e274000
[177166.532023]  000000010a8ad150 ffff88007e274000 0000000000000000 ffff880=
0732aba48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] trinity-main    S ffff880079c0be58  9240  2904   2902 0x100=
00080
[177166.532023]  ffff880079c0be58 ffff880079c0be18 ffff880079c0bfd8 0000000=
0001d6240
[177166.532023]  ffff88007e139b90 ffff880055f52320 ffff880079c0bef8 ffff880=
055f52320
[177166.532023]  ffff880055f51b90 ffff880055f51b90 ffff880055f51b80 ffff880=
079c0be68
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8108c394>] do_wait+0x254/0x410
[177166.532023]  [<ffffffff8108d8b0>] SyS_wait4+0x80/0x110
[177166.532023]  [<ffffffff8108a890>] ? rcu_read_lock_sched_held+0xa0/0xa0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] krfcommd        S ffff880004093c38 14160 10400      2 0x100=
00080
[177166.532023]  ffff880004093c38 ffff880004093c68 ffff880004093fd8 0000000=
0001d6240
[177166.532023]  ffff88007a2a3720 ffff880000000000 ffff880004093dc8 ffff880=
055e2fb50
[177166.532023]  ffffffffa0797870 ffffffffa07a00a0 0000000000000000 ffff880=
004093c48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffffa0797870>] ? rfcomm_process_rx+0x8f0/0x8f0 [rfco=
mm]
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817665cc>] schedule_timeout+0x25c/0x3f0
[177166.532023]  [<ffffffff8176428e>] ? mutex_unlock+0xe/0x10
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8176428e>] ? mutex_unlock+0xe/0x10
[177166.532023]  [<ffffffff81764179>] ? __mutex_unlock_slowpath+0xc9/0x1d0
[177166.532023]  [<ffffffffa0797870>] ? rfcomm_process_rx+0x8f0/0x8f0 [rfco=
mm]
[177166.532023]  [<ffffffff810dd7a7>] wait_woken+0x87/0xb0
[177166.532023]  [<ffffffffa0797870>] ? rfcomm_process_rx+0x8f0/0x8f0 [rfco=
mm]
[177166.532023]  [<ffffffffa0797c5d>] rfcomm_run+0x3ed/0x920 [rfcomm]
[177166.532023]  [<ffffffff810b78b1>] ? finish_task_switch+0x91/0x170
[177166.532023]  [<ffffffff810b7872>] ? finish_task_switch+0x52/0x170
[177166.532023]  [<ffffffff810dd700>] ? abort_exclusive_wait+0xb0/0xb0
[177166.532023]  [<ffffffffa0797870>] ? rfcomm_process_rx+0x8f0/0x8f0 [rfco=
mm]
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] bash            R  running task    11144  9780   1008 0x100=
00080
[177166.532023]  ffff88002ea6f748 000000010a8ac4e3 ffff88002ea6ffd8 0000000=
0001d6240
[177166.532023]  ffff880073703720 0000000000000292 ffff88002ea6f788 ffff880=
07e1f4000
[177166.532023]  000000010a8ac4e3 ffff88007e1f4000 0000000000000000 ffff880=
02ea6f758
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023]  [<ffffffff81398990>] ? copy_user_generic_unrolled+0xa0/0xc=
0
[177166.532023]  [<ffffffff81472f58>] ? copy_from_read_buf+0xa8/0x160
[177166.532023]  [<ffffffff814747d9>] n_tty_read+0x399/0xb40
[177166.532023]  [<ffffffff810dd700>] ? abort_exclusive_wait+0xb0/0xb0
[177166.532023]  [<ffffffff8146fd9d>] tty_read+0x8d/0x100
[177166.532023]  [<ffffffff81251ed8>] __vfs_read+0x18/0x50
[177166.532023]  [<ffffffff81251f9d>] vfs_read+0x8d/0x150
[177166.532023]  [<ffffffff812520b8>] SyS_read+0x58/0xd0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity         S ffff8800457f7e58 11656  2912   1827 0x100=
00080
[177166.532023]  ffff8800457f7e58 ffff8800457f7e18 ffff8800457f7fd8 0000000=
0001d6240
[177166.532023]  ffff880079c30000 ffff8800274a5a40 ffff8800457f7ef8 ffff880=
0274a5a40
[177166.532023]  ffff8800274a52b0 ffff8800274a52b0 ffff8800274a52a0 ffff880=
0457f7e68
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8108c394>] do_wait+0x254/0x410
[177166.532023]  [<ffffffff8108d8b0>] SyS_wait4+0x80/0x110
[177166.532023]  [<ffffffff8108a890>] ? rcu_read_lock_sched_held+0xa0/0xa0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-watchdo R  running task     9160  2913   2912 0x100=
00080
[177166.532023]  ffff880079dd7a38 000000010a8ad1df 000000005d4ed02d 0000000=
000000000
[177166.532023]  0000000000000000 0000000000000296 ffff880079dd7a78 ffff880=
07e274000
[177166.532023]  000000010a8ad1ff ffff88007e274000 0000000000000000 ffff880=
079dd7a48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] trinity-main    S ffff88004234fe58  9160  2914   2912 0x100=
00080
[177166.532023]  ffff88004234fe58 ffff88004234fe18 ffff88004234ffd8 0000000=
0001d6240
[177166.532023]  ffff880077490000 ffff8800417e3eb0 ffff88004234fef8 ffff880=
0417e3eb0
[177166.532023]  ffff8800417e3720 ffff8800417e3720 ffff8800417e3710 ffff880=
04234fe68
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8108c394>] do_wait+0x254/0x410
[177166.532023]  [<ffffffff8108d8b0>] SyS_wait4+0x80/0x110
[177166.532023]  [<ffffffff8108a890>] ? rcu_read_lock_sched_held+0xa0/0xa0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] agetty          R  running task    11904  2933      1 0x100=
00080
[177166.532023]  ffff88004402b748 000000010a8ad218 ffff88004402bfd8 0000000=
0001d6240
[177166.532023]  ffff880077490000 0000000000000292 ffff88004402b788 ffff880=
0833d8208
[177166.532023]  ffff8800752921e8 ffff88007e274000 0000000000000000 ffff880=
04402b758
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd445>] ? __alloc_pages_nodemask+0x7e5/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023]  [<ffffffff81398990>] ? copy_user_generic_unrolled+0xa0/0xc=
0
[177166.532023]  [<ffffffff81472f58>] ? copy_from_read_buf+0xa8/0x160
[177166.532023]  [<ffffffff814747d9>] ? n_tty_read+0x399/0xb40
[177166.532023]  [<ffffffff810dd700>] ? abort_exclusive_wait+0xb0/0xb0
[177166.532023]  [<ffffffff8146fd9d>] ? tty_read+0x8d/0x100
[177166.532023]  [<ffffffff81251ed8>] ? __vfs_read+0x18/0x50
[177166.532023]  [<ffffffff81251f9d>] ? vfs_read+0x8d/0x150
[177166.532023]  [<ffffffff812520b8>] ? SyS_read+0x58/0xd0
[177166.532023]  [<ffffffff8176857a>] ? tracesys_phase2+0xd8/0xdd
[177166.532023] kworker/2:1     S ffff880061c47db8 13352  6804      2 0x100=
00080
[177166.532023]  ffff880061c47db8 ffff88005d03ace0 ffff880061c47fd8 0000000=
0001d6240
[177166.532023]  ffff88007c273720 ffff8800819d56c0 ffff8800819d56c0 ffff880=
0819d56c0
[177166.532023]  ffff88005d03ace0 ffff88007a0e52b0 ffff88005d03acb0 ffff880=
061c47dc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kworker/0:2     S ffff880062b57db8 13480  7940      2 0x100=
00080
[177166.532023]  ffff880062b57db8 ffff88005dce0850 ffff880062b57fd8 0000000=
0001d6240
[177166.532023]  ffff88007e0752b0 ffff8800815d56c0 ffff8800815d56c0 ffff880=
0815d56c0
[177166.532023]  ffff88005dce0850 ffff880075290000 ffff88005dce0820 ffff880=
062b57dc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kworker/u8:0    S ffff880062b4bdb8  9800  8010      2 0x100=
00080
[177166.532023]  ffff880062b4bdb8 ffff880050820c60 ffff880062b4bfd8 0000000=
0001d6240
[177166.532023]  ffff880075290000 ffff88007ec4c0f8 ffff88007ec4c0f8 ffff880=
07ec4c0f8
[177166.532023]  ffff880050820c60 ffff88006766d2b0 ffff880050820c30 ffff880=
062b4bdc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] crond           S ffff880062b1bd28  9000  8335    992 0x100=
00080
[177166.532023]  ffff880062b1bd28 ffff880069b677c8 ffff880062b1bfd8 0000000=
0001d6240
[177166.532023]  ffff880079a8d2b0 ffff880062b1bd28 ffff880069b677c8 ffff880=
069b67870
[177166.532023]  ffff880069b677c8 0000000000000000 00007fdb6b1de6d7 ffff880=
062b1bd38
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8125ac46>] pipe_wait+0x76/0xd0
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8125b351>] pipe_read+0x1c1/0x330
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff81250bab>] new_sync_read+0x8b/0xd0
[177166.532023]  [<ffffffff81251ed8>] __vfs_read+0x18/0x50
[177166.532023]  [<ffffffff81251f9d>] vfs_read+0x8d/0x150
[177166.532023]  [<ffffffff812520b8>] SyS_read+0x58/0xd0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] pmlogger_check  S ffff880067df7e58  9240  8538   8335 0x100=
00080
[177166.532023]  ffff880067df7e58 ffff880067df7e18 ffff880067df7fd8 0000000=
0001d6240
[177166.532023]  ffff88007e203720 ffff88007e13da40 ffff880067df7ef8 ffff880=
07e13da40
[177166.532023]  ffff88007e13d2b0 ffff88007e13d2b0 ffff88007e13d2a0 ffff880=
067df7e68
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8108c394>] do_wait+0x254/0x410
[177166.532023]  [<ffffffff8108d8b0>] SyS_wait4+0x80/0x110
[177166.532023]  [<ffffffff8108a890>] ? rcu_read_lock_sched_held+0xa0/0xa0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] crond           S ffff880063da7d28  9240  8628    992 0x100=
00080
[177166.532023]  ffff880063da7d28 ffff880063883138 ffff880063da7fd8 0000000=
0001d6240
[177166.532023]  ffff88007ca81b90 ffff880063da7d28 ffff880063883138 ffff880=
0638831e0
[177166.532023]  ffff880063883138 0000000000000000 00007fdb6b1deb33 ffff880=
063da7d38
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8125ac46>] pipe_wait+0x76/0xd0
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8125b351>] pipe_read+0x1c1/0x330
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff81250bab>] new_sync_read+0x8b/0xd0
[177166.532023]  [<ffffffff81251ed8>] __vfs_read+0x18/0x50
[177166.532023]  [<ffffffff81251f9d>] vfs_read+0x8d/0x150
[177166.532023]  [<ffffffff812520b8>] SyS_read+0x58/0xd0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] kworker/u8:1    S ffff880062ae7db8  9928  8674      2 0x100=
00080
[177166.532023]  ffff880062ae7db8 ffff88005d03aad8 ffff880062ae7fd8 0000000=
0001d6240
[177166.532023]  ffff880063918000 ffff88007ec4c0f8 ffff88007ec4c0f8 ffff880=
07ec4c0f8
[177166.532023]  ffff88005d03aad8 ffff880067668000 ffff88005d03aaa8 ffff880=
062ae7dc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] pmlogger_check  S ffff88006767fd28  9240  8741   8538 0x100=
00080
[177166.532023]  ffff88006767fd28 ffff88006c818000 ffff88006767ffd8 0000000=
0001d6240
[177166.532023]  ffff88007dcb9b90 ffff88006767fd28 ffff88006c818000 ffff880=
06c8180a8
[177166.532023]  ffff88006c818000 0000000000000000 0000000000000001 ffff880=
06767fd38
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8125ac46>] pipe_wait+0x76/0xd0
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8125b351>] pipe_read+0x1c1/0x330
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff81250bab>] new_sync_read+0x8b/0xd0
[177166.532023]  [<ffffffff81251ed8>] __vfs_read+0x18/0x50
[177166.532023]  [<ffffffff81251f9d>] vfs_read+0x8d/0x150
[177166.532023]  [<ffffffff812520b8>] SyS_read+0x58/0xd0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] pmie_check      S ffff880067ccfe58  9336  8850   8628 0x100=
00080
[177166.532023]  ffff880067ccfe58 ffff880067ccfe18 ffff880067ccffd8 0000000=
0001d6240
[177166.532023]  ffff88007a2a3720 ffff880079a88790 ffff880067ccfef8 ffff880=
079a88790
[177166.532023]  ffff880079a88000 ffff880079a88000 ffff880079a87ff0 ffff880=
067ccfe68
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8108c394>] do_wait+0x254/0x410
[177166.532023]  [<ffffffff8108d8b0>] SyS_wait4+0x80/0x110
[177166.532023]  [<ffffffff8108a890>] ? rcu_read_lock_sched_held+0xa0/0xa0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] kworker/3:1     S ffff88006c8bbdb8 13928  8860      2 0x100=
00080
[177166.532023]  ffff88006c8bbdb8 ffff880057dcd070 ffff88006c8bbfd8 0000000=
0001d6240
[177166.532023]  ffff88000fcd1b90 ffff880081bd56c0 ffff880081bd56c0 ffff880=
081bd56c0
[177166.532023]  ffff880057dcd070 ffff88007a2ad2b0 ffff880057dcd040 ffff880=
06c8bbdc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kworker/1:2     D ffff880069ea7a48 13400  9169      2 0x100=
00080
[177166.532023] Workqueue: events flush_to_ldisc
[177166.532023]  ffff880069ea7a48 ffff88000cbf9560 ffff880069ea7fd8 0000000=
0001d6240
[177166.532023]  ffff88007e1bd2b0 ffff88000cbf9578 ffff88000cbf9578 fffffff=
f00000000
[177166.532023]  ffff88000cbf9560 ffff88007e073720 ffffffff00000001 ffff880=
069ea7a58
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff81766135>] rwsem_down_write_failed+0x205/0x410
[177166.532023]  [<ffffffff81765f81>] ? rwsem_down_write_failed+0x51/0x410
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff8139a383>] call_rwsem_down_write_failed+0x13/0x2=
0
[177166.532023]  [<ffffffff8176582d>] ? down_write+0x9d/0xc0
[177166.532023]  [<ffffffff81473fce>] ? isig+0x7e/0x110
[177166.532023]  [<ffffffff810e3323>] ? up_read+0x23/0x40
[177166.532023]  [<ffffffff81473fce>] isig+0x7e/0x110
[177166.532023]  [<ffffffff814742ac>] n_tty_receive_signal_char+0x1c/0x70
[177166.532023]  [<ffffffff81475a3c>] n_tty_receive_char_special+0x8fc/0xb8=
0
[177166.532023]  [<ffffffff81476517>] n_tty_receive_buf_common+0x857/0xba0
[177166.532023]  [<ffffffff81476874>] n_tty_receive_buf2+0x14/0x20
[177166.532023]  [<ffffffff814795c0>] flush_to_ldisc+0xe0/0x120
[177166.532023]  [<ffffffff810a9c4a>] process_one_work+0x20a/0x840
[177166.532023]  [<ffffffff810a9bb6>] ? process_one_work+0x176/0x840
[177166.532023]  [<ffffffff810aa39b>] worker_thread+0x11b/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] pmie_check      S ffff88006d487d28  9336  9178   8850 0x100=
00080
[177166.532023]  ffff88006d487d28 ffff880067787138 ffff88006d487fd8 0000000=
0001d6240
[177166.532023]  ffff88007ca81b90 ffff88006d487d28 ffff880067787138 ffff880=
0677871e0
[177166.532023]  ffff880067787138 0000000000000000 00007fff862a40b7 ffff880=
06d487d38
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8125ac46>] pipe_wait+0x76/0xd0
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff8125b351>] pipe_read+0x1c1/0x330
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff81250bab>] new_sync_read+0x8b/0xd0
[177166.532023]  [<ffffffff81251ed8>] __vfs_read+0x18/0x50
[177166.532023]  [<ffffffff81251f9d>] vfs_read+0x8d/0x150
[177166.532023]  [<ffffffff812520b8>] SyS_read+0x58/0xd0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] kworker/3:2     S ffff880067657db8 13864  9632      2 0x100=
00080
[177166.532023]  ffff880067657db8 ffff880047ba1ea8 ffff880067657fd8 0000000=
0001d6240
[177166.532023]  ffff88007aa98000 ffff880081bd56c0 ffff880081bd56c0 ffff880=
081bd56c0
[177166.532023]  ffff880047ba1ea8 ffff88006d42d2b0 ffff880047ba1e78 ffff880=
067657dc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] kworker/1:0     D ffff88006c993ab8 13928  9968      2 0x100=
00080
[177166.532023]  ffff88006c993ab8 ffff88006d428000 ffff88006c993fd8 0000000=
0001d6240
[177166.532023]  ffff8800731e8000 ffff8800817d6d40 7fffffffffffffff ffff880=
06c993c48
[177166.532023]  ffff88006c993c40 ffff88006d428000 ffff88006d428000 ffff880=
06c993ac8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817665cc>] schedule_timeout+0x25c/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810e7fb5>] ? mark_held_locks+0x75/0xa0
[177166.532023]  [<ffffffff81767740>] ? _raw_spin_unlock_irq+0x30/0x50
[177166.532023]  [<ffffffff817626d7>] wait_for_completion_killable+0x127/0x=
1b0
[177166.532023]  [<ffffffff810c37f0>] ? wake_up_state+0x20/0x20
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b03c9>] kthread_create_on_node+0x189/0x250
[177166.532023]  [<ffffffff817625fc>] ? wait_for_completion_killable+0x4c/0=
x1b0
[177166.532023]  [<ffffffff813980b3>] ? snprintf+0x43/0x60
[177166.532023]  [<ffffffff810a5f91>] create_worker+0xd1/0x1a0
[177166.532023]  [<ffffffff810aa597>] worker_thread+0x317/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] trinity-c10     R  running task     8216 10416   2914 0x100=
00080
[177166.532023]  ffff880068b2fc58 000000010a8ac483 ffff880068b2ffd8 0000000=
0001d6240
[177166.532023]  ffff880075c1b720 0000000000000292 ffff880068b2fc98 ffff880=
07e1f4000
[177166.532023]  000000010a8ac483 ffff88007e1f4000 0000000000000000 ffff880=
068b2fc68
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff811c70c4>] ? __get_free_pages+0x14/0x50
[177166.532023]  [<ffffffff811c70c4>] __get_free_pages+0x14/0x50
[177166.532023]  [<ffffffff811ff7ab>] SyS_mincore+0x9b/0x280
[177166.532023]  [<ffffffff8102d7cc>] ? do_audit_syscall_entry+0x6c/0x70
[177166.532023]  [<ffffffff8102f2d7>] ? syscall_trace_enter_phase2+0xa7/0x2=
70
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023]  [<ffffffffa0000001>] ? slow_down_io+0x1/0x30 [floppy]
[177166.532023] trinity-c15     D ffff88006c83fd48  9080 10461   2914 0x101=
00084
[177166.532023]  ffff88006c83fd48 ffff88006c83fd28 ffff88006c83ffd8 0000000=
0001d6240
[177166.532023]  ffff88007373d2b0 ffff880049558850 ffff88006c83fe40 ffff880=
049558848
[177166.532023]  ffff880049558850 0000000000000246 ffff880063d33720 ffff880=
06c83fd58
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81761540>] schedule_preempt_disabled+0x30/0x80
[177166.532023]  [<ffffffff81763d28>] mutex_lock_nested+0x198/0x520
[177166.532023]  [<ffffffff811c3c04>] ? generic_file_write_iter+0x34/0xb0
[177166.532023]  [<ffffffff811c3c04>] ? generic_file_write_iter+0x34/0xb0
[177166.532023]  [<ffffffff811c3c04>] generic_file_write_iter+0x34/0xb0
[177166.532023]  [<ffffffff81250c7e>] new_sync_write+0x8e/0xd0
[177166.532023]  [<ffffffff812514da>] vfs_write+0xba/0x1f0
[177166.532023]  [<ffffffff81273f6c>] ? __fget_light+0x6c/0xa0
[177166.532023]  [<ffffffff81252352>] SyS_pwrite64+0x92/0xc0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] kworker/0:1     S ffff880067c7bdb8 14696 10487      2 0x100=
00080
[177166.532023]  ffff880067c7bdb8 ffffffff810aa280 ffff880067c7bfd8 0000000=
0001d6240
[177166.532023]  ffffffff81c154e0 ffff8800815d56c0 ffff8800815d56c0 ffff880=
0815d5718
[177166.532023]  ffffffff810aa280 ffff88006d3dd2b0 ffff8800552870c0 ffff880=
067c7bdc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] trinity-c3      R  running task     9080 10593   2904 0x100=
00080
[177166.532023]  ffff88006c9a77e8 0000000000000296 ffff88006c9a7fd8 ffff880=
06c9a77b8
[177166.532023]  ffffffff8106b755 ffff88006c9a77c8 ffffffff81028d79 ffff880=
06c9a77f8
[177166.532023]  ffffffff810c7925 ffff880081bd6d40 ffff880081bd6d40 0000000=
0001d6d40
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff811b4648>] ? __perf_event_task_sched_out+0x2e8/0=
x640
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff81760a14>] ? __schedule+0x254/0x7b0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff81760a14>] ? __schedule+0x254/0x7b0
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff8175a1cf>] ? follow_page_pte+0x31a/0x37e
[177166.532023]  [<ffffffff811f7c08>] ? follow_page_mask+0x1c8/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c13     R  running task     9000 10596   2904 0x100=
00080
[177166.532023]  ffff880064e1fa38 000000010a8ad355 ffff880064e1ffd8 0000000=
0001d6240
[177166.532023]  ffff88006cef8000 0000000000000296 ffff880064e1fa78 ffff880=
07e274000
[177166.532023]  000000010a8ad355 ffff88007e274000 0000000000000000 ffff880=
064e1fa48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] trinity-c1      R  running task     9176 10605   2904 0x100=
00080
[177166.532023]  ffff88006c8e3998 000000010a8ac46c ffff88006c8e3fd8 0000000=
0001d6240
[177166.532023]  ffff880076b952b0 0000000000000296 ffff88006c8e39d8 ffff880=
07e1f4000
[177166.532023]  000000010a8ac46c ffff88007e1f4000 0000000000000000 ffff880=
06c8e39a8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff8175a1cf>] ? follow_page_pte+0x31a/0x37e
[177166.532023]  [<ffffffff811f7c08>] ? follow_page_mask+0x1c8/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c4      R  running task     9160 10628   2904 0x100=
00080
[177166.532023]  ffff88006c977a18 000000010a8ad37c ffff88006c977fd8 0000000=
0001d6240
[177166.532023]  ffff88007e3d0000 0000000000000292 ffff88006c977a58 ffff880=
07e234000
[177166.532023]  000000010a8ad37c ffff88007e234000 0000000000000000 ffff880=
06c977a28
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff811faee2>] ? do_wp_page+0xe2/0x800
[177166.532023]  [<ffffffff811faee2>] do_wp_page+0xe2/0x800
[177166.532023]  [<ffffffff8176764b>] ? _raw_spin_unlock+0x2b/0x40
[177166.532023]  [<ffffffff811fdedb>] handle_mm_fault+0x141b/0x1700
[177166.532023]  [<ffffffff810e923a>] ? lock_is_held+0x6a/0x90
[177166.532023]  [<ffffffff811f7c08>] ? follow_page_mask+0x1c8/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c11     R  running task     9000 10638   2914 0x100=
00080
[177166.532023]  ffff88006c88ba48 000000010a8ac483 ffff88006c88bfd8 0000000=
0001d6240
[177166.532023]  ffff8800771f1b90 0000000000000292 ffff88006c88ba88 ffff880=
07e1f4000
[177166.532023]  000000010a8ac483 ffff88007e1f4000 0000000000000000 ffff880=
06c88ba58
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff8107730b>] ? pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff8123fb90>] ? __mem_cgroup_count_vm_event+0xb0/0x=
1b0
[177166.532023]  [<ffffffff8107730b>] pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff811f9f67>] __pte_alloc+0x27/0x180
[177166.532023]  [<ffffffff811fe070>] handle_mm_fault+0x15b0/0x1700
[177166.532023]  [<ffffffff8175a1b1>] ? follow_page_pte+0x2fc/0x37e
[177166.532023]  [<ffffffff810e923a>] ? lock_is_held+0x6a/0x90
[177166.532023]  [<ffffffff811f7b2f>] ? follow_page_mask+0xef/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c13     R  running task     9256 10642   2914 0x100=
00080
[177166.532023]  ffff8800639cfa48 000000010a8ad3c1 ffff8800639cffd8 0000000=
0001d6240
[177166.532023]  ffff880079b51b90 0000000000000292 ffff8800639cfa88 0000000=
0000f96e2
[177166.532023]  ffff8800639cfad8 ffffffff82fa59c0 0000000000000000 ffff880=
0639cfa58
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff811dca75>] ? try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff8107730b>] ? pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff8123fb90>] ? __mem_cgroup_count_vm_event+0xb0/0x=
1b0
[177166.532023]  [<ffffffff8107730b>] pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff811f9f67>] __pte_alloc+0x27/0x180
[177166.532023]  [<ffffffff811fe070>] handle_mm_fault+0x15b0/0x1700
[177166.532023]  [<ffffffff8175a1b1>] ? follow_page_pte+0x2fc/0x37e
[177166.532023]  [<ffffffff810e923a>] ? lock_is_held+0x6a/0x90
[177166.532023]  [<ffffffff811f7b2f>] ? follow_page_mask+0xef/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c14     R  running task     8232 10645   2914 0x100=
00084
[177166.532023]  ffff88006c9d36e8 000000010a8ad3ac ffff88006c9d3fd8 0000000=
0001d6240
[177166.532023]  ffff8800417e52b0 0000000000000292 ffff88006c9d3728 ffff880=
07e234000
[177166.532023]  000000010a8ad3ac ffff88007e234000 0000000000000000 ffff880=
06c9d36f8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff811c676b>] ? out_of_memory+0x5b/0x80
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff8107730b>] ? pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff8123fb90>] ? __mem_cgroup_count_vm_event+0xb0/0x=
1b0
[177166.532023]  [<ffffffff8107730b>] pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff811f9f67>] __pte_alloc+0x27/0x180
[177166.532023]  [<ffffffff811fe070>] handle_mm_fault+0x15b0/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023]  [<ffffffff811f6ce4>] ? iov_iter_fault_in_readable+0x64/0x8=
0
[177166.532023]  [<ffffffff811d0ac9>] ? balance_dirty_pages_ratelimited+0x1=
9/0x120
[177166.532023]  [<ffffffff811c0a08>] generic_perform_write+0x98/0x1e0
[177166.532023]  [<ffffffff811c39d5>] __generic_file_write_iter+0x175/0x370
[177166.532023]  [<ffffffff81250bf0>] ? new_sync_read+0xd0/0xd0
[177166.532023]  [<ffffffff811c3c0f>] generic_file_write_iter+0x3f/0xb0
[177166.532023]  [<ffffffff811c3bd0>] ? __generic_file_write_iter+0x370/0x3=
70
[177166.532023]  [<ffffffff81250d38>] do_iter_readv_writev+0x78/0xc0
[177166.532023]  [<ffffffff81252588>] do_readv_writev+0xd8/0x2a0
[177166.532023]  [<ffffffff811c3bd0>] ? __generic_file_write_iter+0x370/0x3=
70
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff811c3bd0>] ? __generic_file_write_iter+0x370/0x3=
70
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff812527dc>] vfs_writev+0x3c/0x50
[177166.532023]  [<ffffffff8125294c>] SyS_writev+0x5c/0x100
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c8      R  running task     9256 10653   2914 0x100=
00080
[177166.532023]  ffff88006c887a18 0000000000000296 ffff88006c887fd8 0000000=
0001d6240
[177166.532023]  ffff880076b952b0 ffff8800771f1b90 0000000000000014 0000000=
000000001
[177166.532023]  000000010a8ac483 0000000000000000 0000000000000000 ffff880=
06c887a28
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff817613a2>] _cond_resched.part.82+0x19/0x37
[177166.532023]  [<ffffffff817613dc>] _cond_resched+0x1c/0x1e
[177166.532023]  [<ffffffff811e8007>] wait_iff_congested+0x97/0x310
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff811cd6fb>] __alloc_pages_nodemask+0xa9b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff8175a1cf>] ? follow_page_pte+0x31a/0x37e
[177166.532023]  [<ffffffff811f7c08>] ? follow_page_mask+0x1c8/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c9      R  running task     9816 10655   2914 0x100=
00080
[177166.532023]  ffff880067717a48 000000010a8ac482 ffff880067717fd8 0000000=
0001d6240
[177166.532023]  ffff8800771f1b90 0000000000000292 ffff880067717a88 ffff880=
07e1f4000
[177166.532023]  000000010a8ac482 ffff88007e1f4000 0000000000000000 ffff880=
067717a58
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff8107730b>] ? pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff8123fb90>] ? __mem_cgroup_count_vm_event+0xb0/0x=
1b0
[177166.532023]  [<ffffffff8107730b>] pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff811f9f67>] __pte_alloc+0x27/0x180
[177166.532023]  [<ffffffff811fe070>] handle_mm_fault+0x15b0/0x1700
[177166.532023]  [<ffffffff8175a1b1>] ? follow_page_pte+0x2fc/0x37e
[177166.532023]  [<ffffffff811f7b2f>] ? follow_page_mask+0xef/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176b119>] ia32_do_call+0x13/0x13
[177166.532023] trinity-c8      R  running task     9608 10661   2904 0x100=
00080
[177166.532023]  ffff880055b2f998 000000010a8ac46c ffff880055b2ffd8 0000000=
0001d6240
[177166.532023]  ffff88006391b720 0000000000000296 ffff880055b2f9d8 ffff880=
07e1f4000
[177166.532023]  000000010a8ac46c ffff88007e1f4000 0000000000000000 ffff880=
055b2f9a8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff8175a1cf>] ? follow_page_pte+0x31a/0x37e
[177166.532023]  [<ffffffff810e923a>] ? lock_is_held+0x6a/0x90
[177166.532023]  [<ffffffff811f7c08>] ? follow_page_mask+0x1c8/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-subchil x ffff880062b5fea8  9976 10664  10416 0x100=
00080
[177166.532023]  ffff880062b5fea8 ffff880062b5fe78 ffff880062b5ffd8 0000000=
0001d6240
[177166.532023]  ffff880067659b90 ffff880062b5fea8 00000000000026f8 ffff880=
075c1d2b0
[177166.532023]  ffff880062b5f750 ffff880062b5f750 ffff88006985f170 ffff880=
062b5feb8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff8108d01c>] do_exit+0x7bc/0xcc0
[177166.532023]  [<ffffffff8108d5bc>] do_group_exit+0x4c/0xc0
[177166.532023]  [<ffffffff8108d644>] SyS_exit_group+0x14/0x20
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c15     R  running task     9416 10665   2904 0x100=
00084
[177166.532023]  ffff88006c8577e8 0000000000000296 ffff88006c857fd8 0000000=
0001d6240
[177166.532023]  ffff880076c652b0 ffff88006c8577d8 ffff88006c857a28 0000000=
000000400
[177166.532023]  0000000000000000 0000000000000000 ffffffff81ce9f98 ffff880=
06c8577f8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff817613a2>] _cond_resched.part.82+0x19/0x37
[177166.532023]  [<ffffffff817613dc>] _cond_resched+0x1c/0x1e
[177166.532023]  [<ffffffff811d87f6>] shrink_slab+0x306/0x750
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff812400d0>] ? mem_cgroup_iter+0x160/0xb00
[177166.532023]  [<ffffffff811dc2a8>] shrink_zone+0x2d8/0x2f0
[177166.532023]  [<ffffffff811dc694>] do_try_to_free_pages+0x194/0x470
[177166.532023]  [<ffffffff811dca75>] try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff811cd445>] __alloc_pages_nodemask+0x7e5/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff8175a1cf>] ? follow_page_pte+0x31a/0x37e
[177166.532023]  [<ffffffff810e923a>] ? lock_is_held+0x6a/0x90
[177166.532023]  [<ffffffff811f7c08>] ? follow_page_mask+0x1c8/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c1      D ffff88006c8afe08  9880 10673   2914 0x100=
00084
[177166.532023]  ffff88006c8afe08 ffff88006c8afde8 ffff88006c8affd8 0000000=
0001d6240
[177166.532023]  ffff880073701b90 ffff880049558850 ffff880049558848 ffff880=
049558848
[177166.532023]  ffff880049558850 0000000000000246 ffff8800274a1b90 ffff880=
06c8afe18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81761540>] schedule_preempt_disabled+0x30/0x80
[177166.532023]  [<ffffffff81763d28>] mutex_lock_nested+0x198/0x520
[177166.532023]  [<ffffffff8124e3ba>] ? chmod_common+0x6a/0x170
[177166.532023]  [<ffffffff8124e3ba>] ? chmod_common+0x6a/0x170
[177166.532023]  [<ffffffff8124e3ba>] chmod_common+0x6a/0x170
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8102d7cc>] ? do_audit_syscall_entry+0x6c/0x70
[177166.532023]  [<ffffffff8102f2d7>] ? syscall_trace_enter_phase2+0xa7/0x2=
70
[177166.532023]  [<ffffffff8124faa6>] SyS_fchmod+0x56/0x90
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c5      R  running task     9720 10681   2914 0x100=
00080
[177166.532023]  ffff88006c863a48 000000010a8ad426 ffff88006c863fd8 0000000=
0001d6240
[177166.532023]  ffff8800417e52b0 0000000000000292 0000000000000002 ffff880=
07e234000
[177166.532023]  000000010a8ad495 ffff88007e234000 0000000000000000 ffff880=
06c863a58
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff8107730b>] ? pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff8123fb90>] ? __mem_cgroup_count_vm_event+0xb0/0x=
1b0
[177166.532023]  [<ffffffff8107730b>] pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff811f9f67>] __pte_alloc+0x27/0x180
[177166.532023]  [<ffffffff811fe070>] handle_mm_fault+0x15b0/0x1700
[177166.532023]  [<ffffffff8175a1b1>] ? follow_page_pte+0x2fc/0x37e
[177166.532023]  [<ffffffff811f7b2f>] ? follow_page_mask+0xef/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c14     R  running task     9816 10701   2904 0x100=
00080
[177166.532023]  ffff880062843a48 000000010a8ac46c ffff880062843fd8 0000000=
0001d6240
[177166.532023]  ffff88006d3db720 0000000000000292 ffff880062843a88 ffff880=
07e1f4000
[177166.532023]  000000010a8ac46c ffff88007e1f4000 0000000000000000 ffff880=
062843a58
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff8107730b>] ? pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff8123fb90>] ? __mem_cgroup_count_vm_event+0xb0/0x=
1b0
[177166.532023]  [<ffffffff8107730b>] pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff811f9f67>] __pte_alloc+0x27/0x180
[177166.532023]  [<ffffffff811fe070>] handle_mm_fault+0x15b0/0x1700
[177166.532023]  [<ffffffff8175a1b1>] ? follow_page_pte+0x2fc/0x37e
[177166.532023]  [<ffffffff810e923a>] ? lock_is_held+0x6a/0x90
[177166.532023]  [<ffffffff811f7b2f>] ? follow_page_mask+0xef/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c11     R  running task     9816 10702   2904 0x100=
00080
[177166.532023]  ffff880063c73998 000000010a8ad4b9 ffff880063c73fd8 0000000=
0001d6240
[177166.532023]  ffff88007e0752b0 0000000000000296 ffff880063c739d8 fffffff=
f82fa59c0
[177166.532023]  000000010a8ad4b9 ffffffff82fa59c0 0000000000000000 ffff880=
063c739a8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff8175a1cf>] ? follow_page_pte+0x31a/0x37e
[177166.532023]  [<ffffffff811f7c08>] ? follow_page_mask+0x1c8/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176b119>] ia32_do_call+0x13/0x13
[177166.532023] trinity-c2      R  running task     9720 10706   2904 0x100=
00080
[177166.532023]  ffff88006c82f898 0000000000000292 ffff88006c82ffd8 0000000=
0001d6240
[177166.532023]  ffff88007500d2b0 ffff88006c82f888 ffff88006c82fad8 0000000=
000000400
[177166.532023]  0000000000000000 0000000000000000 ffffffff81ce9f98 ffff880=
06c82f8a8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff817613a2>] _cond_resched.part.82+0x19/0x37
[177166.532023]  [<ffffffff817613dc>] _cond_resched+0x1c/0x1e
[177166.532023]  [<ffffffff811d87f6>] shrink_slab+0x306/0x750
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff812400d0>] ? mem_cgroup_iter+0x160/0xb00
[177166.532023]  [<ffffffff811dc2a8>] shrink_zone+0x2d8/0x2f0
[177166.532023]  [<ffffffff811dc694>] do_try_to_free_pages+0x194/0x470
[177166.532023]  [<ffffffff811dca75>] try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff811cd445>] __alloc_pages_nodemask+0x7e5/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff8107730b>] ? pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff8123fb90>] ? __mem_cgroup_count_vm_event+0xb0/0x=
1b0
[177166.532023]  [<ffffffff8107730b>] pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff811f9f67>] __pte_alloc+0x27/0x180
[177166.532023]  [<ffffffff811fe070>] handle_mm_fault+0x15b0/0x1700
[177166.532023]  [<ffffffff8175a1b1>] ? follow_page_pte+0x2fc/0x37e
[177166.532023]  [<ffffffff811f7b2f>] ? follow_page_mask+0xef/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c2      R  running task     9880 10710   2914 0x100=
00080
[177166.532023]  ffff88006c9ffae8 000000010a8ad4fa ffff88006c9fffd8 0000000=
0001d6240
[177166.532023]  0000000000000001 0000000000000292 ffff88006c9ffb28 ffff880=
07e234000
[177166.532023]  000000010a8ad4fe ffff88007e234000 0000000000000000 ffff880=
07dcb9b90
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff811dc694>] ? do_try_to_free_pages+0x194/0x470
[177166.532023]  [<ffffffff81760f99>] ? schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] ? schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff811dca75>] ? try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd445>] ? __alloc_pages_nodemask+0x7e5/0xc30
[177166.532023]  [<ffffffff8121ff47>] ? alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff8107730b>] ? pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff8123fb90>] ? __mem_cgroup_count_vm_event+0xb0/0x=
1b0
[177166.532023]  [<ffffffff8107730b>] ? pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff811f9f67>] ? __pte_alloc+0x27/0x180
[177166.532023]  [<ffffffff811fe070>] ? handle_mm_fault+0x15b0/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] trinity-c0      R  running task     9080 10726   2904 0x100=
00080
[177166.532023]  ffff880069acfa78 0000000000000296 ffff880069acffd8 0000000=
0001d6240
[177166.532023]  ffff880079b51b90 0000000fffffffff 00000000000200da 0000000=
0000000c0
[177166.532023]  0000000000000000 0000000000000000 ffff88000fcd3720 ffff880=
069acfa88
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff817613a2>] _cond_resched.part.82+0x19/0x37
[177166.532023]  [<ffffffff817613dc>] _cond_resched+0x1c/0x1e
[177166.532023]  [<ffffffff811cd47b>] __alloc_pages_nodemask+0x81b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff8175a1cf>] ? follow_page_pte+0x31a/0x37e
[177166.532023]  [<ffffffff811f7c08>] ? follow_page_mask+0x1c8/0x310
[177166.532023]  [<ffffffff811f7ea9>] __get_user_pages+0x159/0x700
[177166.532023]  [<ffffffff812001b0>] __mlock_vma_pages_range+0x90/0xb0
[177166.532023]  [<ffffffff812009d0>] __mm_populate+0xd0/0x180
[177166.532023]  [<ffffffff81200da3>] SyS_mlockall+0x163/0x1b0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c6      R  running task     9880 10728   2904 0x100=
00080
[177166.532023]  ffff88006c917a38 000000010a8ad4fe ffff88006c917fd8 0000000=
0001d6240
[177166.532023]  ffff880077190000 0000000000000296 ffff88006c917a78 fffffff=
f82fa59c0
[177166.532023]  000000010a8ad4fe ffffffff82fa59c0 0000000000000000 ffff880=
06c917a48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] trinity-c5      R  running task     9256 10730   2904 0x100=
00084
[177166.532023]  ffff880067b7ba08 000000010a8ad4e3 ffff880067b7bfd8 0000000=
0001d6240
[177166.532023]  ffff88006cef8000 0000000000000296 ffff880067b7ba48 ffff880=
07e274000
[177166.532023]  000000010a8ad4e3 ffff88007e274000 0000000000000000 ffff880=
067b7ba18
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff811c8d4b>] ? alloc_kmem_pages+0x3b/0xf0
[177166.532023]  [<ffffffff811c8d4b>] alloc_kmem_pages+0x3b/0xf0
[177166.532023]  [<ffffffff811ebab8>] kmalloc_order+0x18/0x50
[177166.532023]  [<ffffffff811ed114>] kmalloc_order_trace+0x24/0x230
[177166.532023]  [<ffffffff8122de09>] __kmalloc+0x429/0x480
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff812523de>] rw_copy_check_uvector+0x5e/0x130
[177166.532023]  [<ffffffff81288cec>] vmsplice_to_user+0x6c/0x140
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8111f459>] ? current_kernel_time+0x69/0xd0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8128a8a1>] SyS_vmsplice+0xc1/0xe0
[177166.532023]  [<ffffffff8176857a>] tracesys_phase2+0xd8/0xdd
[177166.532023] trinity-c6      R  running task     9256 10736   2914 0x100=
00080
[177166.532023]  ffff8800638e3a38 000000010a8ad54d ffff8800638e3fd8 0000000=
0001d6240
[177166.532023]  ffff8800417e52b0 0000000000000296 ffff8800638e3a78 ffff880=
07e234000
[177166.532023]  000000010a8ad54d ffff88007e234000 0000000000000000 ffff880=
0638e3a48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810b78b1>] ? finish_task_switch+0x91/0x170
[177166.532023]  [<ffffffff810b7872>] ? finish_task_switch+0x52/0x170
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] trinity-c12     R  running task     9256 10737   2914 0x100=
00080
[177166.532023]  ffff88006c807a38 000000010a8ad575 ffff88006c807fd8 0000000=
0001d6240
[177166.532023]  ffff88007e1b9b90 0000000000000296 ffff88006c807a78 ffff880=
07e234000
[177166.532023]  000000010a8ad575 ffff88007e234000 0000000000000000 ffff880=
06c807a48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810b78b1>] ? finish_task_switch+0x91/0x170
[177166.532023]  [<ffffffff810b7872>] ? finish_task_switch+0x52/0x170
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] trinity-c4      R  running task     9976 10744   2914 0x100=
00080
[177166.532023]  ffff880067cdfa38 000000010a8ad574 ffff880067cdffd8 0000000=
0001d6240
[177166.532023]  ffff88006cef9b90 0000000000000296 ffff880067cdfa78 ffff880=
07e234000
[177166.532023]  000000010a8ad574 ffff88007e234000 0000000000000000 ffff880=
067cdfa48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] trinity-c7      R  running task     9880 10749   2914 0x100=
00080
[177166.532023]  ffff88006c907888 0000000000000292 ffff88006c907fd8 0000000=
0001d6240
[177166.532023]  ffff88007500d2b0 ffff88006c907878 ffff88006c907ac8 0000000=
000000400
[177166.532023]  0000000000000000 0000000000000000 ffffffff81ce9f98 ffff880=
06c907898
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff817613a2>] _cond_resched.part.82+0x19/0x37
[177166.532023]  [<ffffffff817613dc>] _cond_resched+0x1c/0x1e
[177166.532023]  [<ffffffff811d87f6>] shrink_slab+0x306/0x750
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff812400d0>] ? mem_cgroup_iter+0x160/0xb00
[177166.532023]  [<ffffffff811dc2a8>] shrink_zone+0x2d8/0x2f0
[177166.532023]  [<ffffffff811dc694>] do_try_to_free_pages+0x194/0x470
[177166.532023]  [<ffffffff811dca75>] try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff811cd445>] __alloc_pages_nodemask+0x7e5/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810b78b1>] ? finish_task_switch+0x91/0x170
[177166.532023]  [<ffffffff810b7872>] ? finish_task_switch+0x52/0x170
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] trinity-c9      R  running task     9880 10751   2904 0x100=
00080
[177166.532023]  ffff880063bcfa38 000000010a8ad588 ffff880063bcffd8 0000000=
0001d6240
[177166.532023]  ffff88006765b720 0000000000000296 ffff880063bcfa78 ffff880=
07e234000
[177166.532023]  000000010a8ad588 ffff88007e234000 0000000000000000 ffff880=
063bcfa48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810b78b1>] ? finish_task_switch+0x91/0x170
[177166.532023]  [<ffffffff810b7872>] ? finish_task_switch+0x52/0x170
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] trinity-c7      R  running task     9880 10766   2904 0x100=
00080
[177166.532023]  ffff88006c9a3a38 000000010a8ad588 ffff88006c9a3fd8 0000000=
0001d6240
[177166.532023]  ffff88006d429b90 0000000000000296 ffff88006c9a3a78 ffff880=
07e234000
[177166.532023]  000000010a8ad588 ffff88007e234000 0000000000000000 ffff880=
06c9a3a48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810b78b1>] ? finish_task_switch+0x91/0x170
[177166.532023]  [<ffffffff810b7872>] ? finish_task_switch+0x52/0x170
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] trinity-c0      R  running task     9880 10768   2914 0x100=
00080
[177166.532023]  ffff8800676d3a38 000000010a8ad5ef ffff8800676d3fd8 0000000=
0001d6240
[177166.532023]  ffff880077490000 0000000000000296 ffff8800676d3a78 fffffff=
f82fa59c0
[177166.532023]  000000010a8ad5ef ffffffff82fa59c0 0000000000000000 ffff880=
0676d3a48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] trinity-c10     R  running task     9976 10772   2904 0x100=
00080
[177166.532023]  ffff8800638e7ab8 0000000000000296 ffff8800638e7fd8 0000000=
0001d6240
[177166.532023]  ffff88007a8d52b0 ffff880077190000 0000000000000014 0000000=
000000001
[177166.532023]  000000010a8ad5f8 0000000000000000 0000000000000000 ffff880=
0638e7ac8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff817613a2>] _cond_resched.part.82+0x19/0x37
[177166.532023]  [<ffffffff817613dc>] _cond_resched+0x1c/0x1e
[177166.532023]  [<ffffffff811e8007>] wait_iff_congested+0x97/0x310
[177166.532023]  [<ffffffff810dd9e0>] ? prepare_to_wait_event+0x110/0x110
[177166.532023]  [<ffffffff811cd6fb>] __alloc_pages_nodemask+0xa9b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] trinity-c12     R  running task     9976 10776   2904 0x100=
00080
[177166.532023]  ffff88006c8a7ab8 0000000000000296 ffff88006c8a7fd8 0000000=
0001d6240
[177166.532023]  ffff8800731e8000 ffff88006cef8000 0000000000000014 0000000=
000000001
[177166.532023]  000000010a8ad5f3 0000000000000000 0000000000000000 ffff880=
06c8a7ac8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] ? alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] ? swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] ? handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff810b78b1>] ? finish_task_switch+0x91/0x170
[177166.532023]  [<ffffffff810b7872>] ? finish_task_switch+0x52/0x170
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] trinity-c3      R  running task     9976 10777   2914 0x100=
00080
[177166.532023]  ffff880067ac7a38 000000010a8ad61b ffff880067ac7fd8 0000000=
0001d6240
[177166.532023]  ffff8800274a3720 0000000000000296 ffff880067ac7a78 ffff880=
07e274000
[177166.532023]  000000010a8ad61b ffff88007e274000 0000000000000000 ffff880=
067ac7a48
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff81112b80>] ? __internal_add_timer+0x130/0x130
[177166.532023]  [<ffffffff817667e9>] schedule_timeout_uninterruptible+0x29=
/0x30
[177166.532023]  [<ffffffff811cd6eb>] __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff81221e23>] alloc_pages_vma+0x123/0x290
[177166.532023]  [<ffffffff812119bd>] ? read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff812119bd>] read_swap_cache_async+0xfd/0x1a0
[177166.532023]  [<ffffffff81211bb6>] swapin_readahead+0x156/0x1d0
[177166.532023]  [<ffffffff811c1135>] ? find_get_entry+0x5/0x230
[177166.532023]  [<ffffffff811c237c>] ? pagecache_get_page+0x2c/0x1d0
[177166.532023]  [<ffffffff811fdc48>] handle_mm_fault+0x1188/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] trace_page_fault+0x28/0x30
[177166.532023] kworker/2:2     S ffff880066493db8 14696 10782      2 0x100=
00080
[177166.532023]  ffff880066493db8 ffffffff810aa280 ffff880066493fd8 0000000=
0001d6240
[177166.532023]  ffff88007373d2b0 ffff8800819d56c0 ffff8800819d56c0 ffff880=
0819d5718
[177166.532023]  ffffffff810aa280 ffff88000fcd1b90 ffff88005043a490 ffff880=
066493dc8
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff810aa414>] worker_thread+0x194/0x460
[177166.532023]  [<ffffffff810aa280>] ? process_one_work+0x840/0x840
[177166.532023]  [<ffffffff810b059d>] kthread+0x10d/0x130
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023]  [<ffffffff817682bc>] ret_from_fork+0x7c/0xb0
[177166.532023]  [<ffffffff810b0490>] ? kthread_create_on_node+0x250/0x250
[177166.532023] pmie_check      D ffff880067c37ae8  9880 10798   9178 0x100=
00080
[177166.532023]  ffff880067c37ae8 000000010a8ad660 ffff880067c37fd8 0000000=
0001d6240
[177166.532023]  ffff880055f552b0 0000000000000292 ffff880067c37b28 ffff880=
07e274000
[177166.532023]  000000010a8ad660 ffff88007e274000 0000000000000000 ffff880=
063d31b90
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff81760f99>] schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff811dca75>] ? try_to_free_pages+0x105/0x4a0
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff8121ff47>] ? alloc_pages_current+0x107/0x1a0
[177166.532023]  [<ffffffff8107730b>] ? pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff8123fb90>] ? __mem_cgroup_count_vm_event+0xb0/0x=
1b0
[177166.532023]  [<ffffffff8107730b>] ? pte_alloc_one+0x1b/0xa0
[177166.532023]  [<ffffffff811f9f67>] ? __pte_alloc+0x27/0x180
[177166.532023]  [<ffffffff811fe070>] ? handle_mm_fault+0x15b0/0x1700
[177166.532023]  [<ffffffff810e919f>] ? __lock_is_held+0x5f/0x90
[177166.532023]  [<ffffffff81071388>] ? __do_page_fault+0x1a8/0x470
[177166.532023]  [<ffffffff81071730>] ? trace_do_page_fault+0x70/0x440
[177166.532023]  [<ffffffff8176a468>] ? trace_page_fault+0x28/0x30
[177166.532023] pmlogger_check  D ffff88006c89fb20 10904 10805   8741 0x100=
00080
[177166.532023]  ffff88006c89fb20 000000010a8ad676 ffff88006c89ffd8 0000000=
0001d6240
[177166.532023]  0000000000000001 0000000000000282 ffff88006c89fb60 ffff880=
07e274000
[177166.532023]  000000010a8ad678 ffff88007e274000 ffffffff811dc694 ffff880=
06c89fb30
[177166.532023] Call Trace:
[177166.532023]  [<ffffffff811f242d>] ? compact_zone_order+0x7d/0xc0
[177166.532023]  [<ffffffff81760f99>] ? schedule+0x29/0x70
[177166.532023]  [<ffffffff817664f6>] ? schedule_timeout+0x186/0x3f0
[177166.532023]  [<ffffffff810c7ba8>] ? sched_clock_cpu+0xa8/0xd0
[177166.532023]  [<ffffffff811c676b>] ? out_of_memory+0x5b/0x80
[177166.532023]  [<ffffffff817667e9>] ? schedule_timeout_uninterruptible+0x=
29/0x30
[177166.532023]  [<ffffffff811cd6eb>] ? __alloc_pages_nodemask+0xa8b/0xc30
[177166.532023]  [<ffffffff811cd94d>] ? alloc_kmem_pages_node+0x6d/0x130
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff81086093>] ? copy_process.part.23+0x133/0x1e80
[177166.532023]  [<ffffffff8106b755>] ? kvm_clock_read+0x25/0x30
[177166.532023]  [<ffffffff81028d79>] ? sched_clock+0x9/0x10
[177166.532023]  [<ffffffff810c7925>] ? sched_clock_local+0x25/0x90
[177166.532023]  [<ffffffff810c7c25>] ? local_clock+0x15/0x30
[177166.532023]  [<ffffffff81087f91>] ? do_fork+0xd1/0x7c0
[177166.532023]  [<ffffffff810e81fd>] ? trace_hardirqs_on+0xd/0x10
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8115c384>] ? __audit_syscall_entry+0xb4/0x110
[177166.532023]  [<ffffffff8102d7cc>] ? do_audit_syscall_entry+0x6c/0x70
[177166.532023]  [<ffffffff8102f2d7>] ? syscall_trace_enter_phase2+0xa7/0x2=
70
[177166.532023]  [<ffffffff81088706>] ? SyS_clone+0x16/0x20
[177166.532023]  [<ffffffff8176873d>] ? stub_clone+0x6d/0x90
[177166.532023]  [<ffffffff8176857a>] ? tracesys_phase2+0xd8/0xdd
[177166.532023] Sched Debug Version: v0.11, 3.19.0-rc7-next-20150204 #27
[177166.532023] ktime                                   : 177171057.235525
[177166.532023] sched_clk                               : 177178806.046345
[177166.532023] cpu_clk                                 : 177166532.023025
[177166.532023] jiffies                                 : 4471838357
[177166.532023] sched_clock_stable()                    : 0
[177166.532023]=20
[177166.532023] sysctl_sched
[177166.532023]   .sysctl_sched_latency                    : 18.000000
[177166.532023]   .sysctl_sched_min_granularity            : 10.000000
[177166.532023]   .sysctl_sched_wakeup_granularity         : 15.000000
[177166.532023]   .sysctl_sched_child_runs_first           : 0
[177166.532023]   .sysctl_sched_features                   : 77435
[177166.532023]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
[177166.532023]=20
[177166.532023] cpu#0, 2393.998 MHz
[177166.532023]   .nr_running                    : 13
[177166.532023]   .load                          : 8552
[177166.532023]   .nr_switches                   : 224561301
[177166.532023]   .nr_load_updates               : 169497347
[177166.532023]   .nr_uninterruptible            : -10335
[177166.532023]   .next_balance                  : 4471.838421
[177166.532023]   .curr->pid                     : 2
[177166.532023]   .clock                         : 177171077.161979
[177166.532023]   .clock_task                    : 176264846.422432
[177166.532023]   .cpu_load[0]                   : 3885
[177166.532023]   .cpu_load[1]                   : 4739
[177166.532023]   .cpu_load[2]                   : 4808
[177166.532023]   .cpu_load[3]                   : 4998
[177166.532023]   .cpu_load[4]                   : 5195
[177166.532023]=20
[177166.532023] cfs_rq[0]:/autogroup-85
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 2505451.687170
[177166.532023]   .min_vruntime                  : 2505451.687170
[177166.532023]   .max_vruntime                  : 2505451.687170
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -372502332.843068
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 0
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 839
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 855
[177166.532023]   .tg_runnable_contrib           : 839
[177166.532023]   .tg_load_avg                   : 855
[177166.532023]   .tg->runnable_avg              : 839
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176264865.927028
[177166.532023]   .se->vruntime                  : 375007786.637408
[177166.532023]   .se->sum_exec_runtime          : 2505454.764265
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 39048
[177166.532023]   .se->avg.runnable_avg_period   : 47549
[177166.532023]   .se->avg.load_avg_contrib      : 838
[177166.532023]   .se->avg.decay_count           : 168099284
[177166.532023]=20
[177166.532023] cfs_rq[0]:/autogroup-68
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 1820954.003681
[177166.532023]   .min_vruntime                  : 1820954.003681
[177166.532023]   .max_vruntime                  : 1820954.003681
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -373186833.539953
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 941
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 940
[177166.532023]   .tg_runnable_contrib           : 929
[177166.532023]   .tg_load_avg                   : 1920
[177166.532023]   .tg->runnable_avg              : 1908
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176264883.760228
[177166.532023]   .se->vruntime                  : 375007789.459983
[177166.532023]   .se->sum_exec_runtime          : 1843688.301517
[177166.532023]   .se->load.weight               : 523
[177166.532023]   .se->avg.runnable_avg_sum      : 44581
[177166.532023]   .se->avg.runnable_avg_period   : 48105
[177166.532023]   .se->avg.load_avg_contrib      : 501
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[0]:/autogroup-48
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 533197.128565
[177166.532023]   .min_vruntime                  : 533197.128565
[177166.532023]   .max_vruntime                  : 533197.128565
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -374474593.066989
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 2501
[177166.532023]   .runnable_load_avg             : 1925
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 1932
[177166.532023]   .tg_runnable_contrib           : 807
[177166.532023]   .tg_load_avg                   : 1972
[177166.532023]   .tg->runnable_avg              : 807
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176264913.890715
[177166.532023]   .se->vruntime                  : 375007792.070476
[177166.532023]   .se->sum_exec_runtime          : 1304777.123176
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 36627
[177166.532023]   .se->avg.runnable_avg_period   : 47694
[177166.532023]   .se->avg.load_avg_contrib      : 786
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[0]:/autogroup-66
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 1594868.173213
[177166.532023]   .min_vruntime                  : 1594868.173213
[177166.532023]   .max_vruntime                  : 1594868.173213
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -373412924.678937
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 964
[177166.532023]   .blocked_load_avg              : 964
[177166.532023]   .tg_load_contrib               : 964
[177166.532023]   .tg_runnable_contrib           : 949
[177166.532023]   .tg_load_avg                   : 1955
[177166.532023]   .tg->runnable_avg              : 1937
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176264936.099495
[177166.532023]   .se->vruntime                  : 375007795.171254
[177166.532023]   .se->sum_exec_runtime          : 1813523.306580
[177166.532023]   .se->load.weight               : 520
[177166.532023]   .se->avg.runnable_avg_sum      : 43784
[177166.532023]   .se->avg.runnable_avg_period   : 47230
[177166.532023]   .se->avg.load_avg_contrib      : 504
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[0]:/autogroup-1
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 674677.984063
[177166.532023]   .min_vruntime                  : 674677.984063
[177166.532023]   .max_vruntime                  : 674677.984063
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -374333117.841341
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 877
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 875
[177166.532023]   .tg_runnable_contrib           : 881
[177166.532023]   .tg_load_avg                   : 875
[177166.532023]   .tg->runnable_avg              : 881
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176264960.884348
[177166.532023]   .se->vruntime                  : 375007798.158785
[177166.532023]   .se->sum_exec_runtime          : 674356.684752
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 41630
[177166.532023]   .se->avg.runnable_avg_period   : 47597
[177166.532023]   .se->avg.load_avg_contrib      : 898
[177166.532023]   .se->avg.decay_count           : 168099373
[177166.532023]=20
[177166.532023] cfs_rq[0]:/autogroup-103
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 2622460.604433
[177166.532023]   .min_vruntime                  : 2622460.604433
[177166.532023]   .max_vruntime                  : 2622460.604433
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -372385338.105848
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 0
[177166.532023]   .runnable_load_avg             : 867
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 867
[177166.532023]   .tg_runnable_contrib           : 850
[177166.532023]   .tg_load_avg                   : 867
[177166.532023]   .tg->runnable_avg              : 850
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176264984.772445
[177166.532023]   .se->vruntime                  : 375007801.014359
[177166.532023]   .se->sum_exec_runtime          : 2622469.378611
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 38542
[177166.532023]   .se->avg.runnable_avg_period   : 46461
[177166.532023]   .se->avg.load_avg_contrib      : 848
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[0]:/autogroup-56
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 2293533.551965
[177166.532023]   .min_vruntime                  : 2293533.551965
[177166.532023]   .max_vruntime                  : 2293533.551965
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -372714268.092516
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 880
[177166.532023]   .blocked_load_avg              : 880
[177166.532023]   .tg_load_contrib               : 880
[177166.532023]   .tg_runnable_contrib           : 868
[177166.532023]   .tg_load_avg                   : 880
[177166.532023]   .tg->runnable_avg              : 868
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176265007.843240
[177166.532023]   .se->vruntime                  : 375007803.858693
[177166.532023]   .se->sum_exec_runtime          : 2293536.848600
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 40518
[177166.532023]   .se->avg.runnable_avg_period   : 47218
[177166.532023]   .se->avg.load_avg_contrib      : 881
[177166.532023]   .se->avg.decay_count           : 168099418
[177166.532023]=20
[177166.532023] cfs_rq[0]:/autogroup-26831
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 0.000001
[177166.532023]   .min_vruntime                  : 101218335.713055
[177166.532023]   .max_vruntime                  : 0.000001
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -273789468.632367
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 0
[177166.532023]   .load                          : 15
[177166.532023]   .runnable_load_avg             : 12
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 12
[177166.532023]   .tg_runnable_contrib           : 860
[177166.532023]   .tg_load_avg                   : 12
[177166.532023]   .tg->runnable_avg              : 860
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176265031.586061
[177166.532023]   .se->vruntime                  : 375007806.545696
[177166.532023]   .se->sum_exec_runtime          : 1482692.667554
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 38931
[177166.532023]   .se->avg.runnable_avg_period   : 46486
[177166.532023]   .se->avg.load_avg_contrib      : 789
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[0]:/autogroup-115
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 351989496.371392
[177166.532023]   .min_vruntime                  : 351989496.371392
[177166.532023]   .max_vruntime                  : 351989496.371392
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -23018310.747857
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 15
[177166.532023]   .runnable_load_avg             : 14
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 14
[177166.532023]   .tg_runnable_contrib           : 997
[177166.532023]   .tg_load_avg                   : 179
[177166.532023]   .tg->runnable_avg              : 4038
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176265025.922404
[177166.532023]   .se->vruntime                  : 375007814.356618
[177166.532023]   .se->sum_exec_runtime          : 6532803.722022
[177166.532023]   .se->load.weight               : 85
[177166.532023]   .se->avg.runnable_avg_sum      : 46284
[177166.532023]   .se->avg.runnable_avg_period   : 47251
[177166.532023]   .se->avg.load_avg_contrib      : 79
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[0]:/autogroup-117
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 3249050405.498591
[177166.532023]   .min_vruntime                  : 3249050408.082961
[177166.532023]   .max_vruntime                  : 3249050416.274146
[177166.532023]   .spread                        : 10.775555
[177166.532023]   .spread0                       : 2874042598.190191
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 4
[177166.532023]   .load                          : 60
[177166.532023]   .runnable_load_avg             : 55
[177166.532023]   .blocked_load_avg              : 1
[177166.532023]   .tg_load_contrib               : 55
[177166.532023]   .tg_runnable_contrib           : 1020
[177166.532023]   .tg_load_avg                   : 234
[177166.532023]   .tg->runnable_avg              : 4074
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176265078.139660
[177166.532023]   .se->vruntime                  : 375007820.276888
[177166.532023]   .se->sum_exec_runtime          : 91397462.439292
[177166.532023]   .se->load.weight               : 257
[177166.532023]   .se->avg.runnable_avg_sum      : 47629
[177166.532023]   .se->avg.runnable_avg_period   : 47722
[177166.532023]   .se->avg.load_avg_contrib      : 239
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[0]:/
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 375007812.832678
[177166.532023]   .min_vruntime                  : 375007812.832678
[177166.532023]   .max_vruntime                  : 375007820.276888
[177166.532023]   .spread                        : 7.444210
[177166.532023]   .spread0                       : 0.000000
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 10
[177166.532023]   .load                          : 8553
[177166.532023]   .runnable_load_avg             : 6423
[177166.532023]   .blocked_load_avg              : 2
[177166.532023]   .tg_load_contrib               : 7280
[177166.532023]   .tg_runnable_contrib           : 1021
[177166.532023]   .tg_load_avg                   : 28957
[177166.532023]   .tg->runnable_avg              : 4060
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .avg->runnable_avg_sum         : 46799
[177166.532023]   .avg->runnable_avg_period      : 46132
[177166.532023]=20
[177166.532023] rt_rq[0]:/
[177166.532023]   .rt_nr_running                 : 0
[177166.532023]   .rt_throttled                  : 0
[177166.532023]   .rt_time                       : 0.000000
[177166.532023]   .rt_runtime                    : 950.000000
[177166.532023]=20
[177166.532023] dl_rq[0]:
[177166.532023]   .dl_nr_running                 : 0
[177166.532023]=20
[177166.532023] runnable tasks:
[177166.532023]             task   PID         tree-key  switches  prio    =
 exec-runtime         sum-exec        sum-sleep
[177166.532023] -----------------------------------------------------------=
-----------------------------------------------
[177166.532023]          systemd     1    674698.240979   2033678   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-1
[177166.532023]         kthreadd     2 375007816.824901   2574966   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      ksoftirqd/0     3 374322026.143288     84866   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]     kworker/0:0H     5     14309.639665         7   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]           rcu_bh     8        20.701413         2   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          rcuob/0    10        24.717657         3   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      migration/0    11         0.000000     93808     0    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]       watchdog/0    12         0.000000     44295     0    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          rcuob/1    19        43.644579         2   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          rcuob/2    26        85.705803         3   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          rcuob/3    33       122.947935         2   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]        kdevtmpfs    35 338474182.666024       151   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]       khungtaskd    40 375001908.322106      1478   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]               md    49       758.866173         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]         kthrotld    67       770.669710         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]  acpi_thermal_pm    68       770.675030         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          lvmetad   388        10.988496         9   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-35
[177166.532023]           rpciod   397      4568.043817         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]         vballoon   441      5972.788185         2   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]           auditd   482    533210.631927  16304885   116    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-48
[177166.532023]           auditd   487    177068.577931     51944   116    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-48
[177166.532023]           smartd   517   2293556.428565  14957023   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-56
[177166.532023]            tuned   639       174.273299         9   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-58
[177166.532023]     in:imjournal   569   1820973.251473  15071990   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-68
[177166.532023]          polkitd   586     22573.725883     62164   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-77
[177166.532023]            gdbus   587     22576.373605     59791   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-77
[177166.532023]            gmain   591        34.671013         2   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-77
[177166.532023]         dhclient   604   1594884.806099   7173548   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-66
[177166.532023]             sshd   826   2505492.992452   9455166   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-85
[177166.532023]           ypbind   910         0.218334        18   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-95
[177166.532023]         sendmail   973   2622488.973212  14604710   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-103
[177166.532023]        automount  1025    476323.853384   1065473   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]        automount  1138        89.462464         4   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]     kworker/0:1H  1842 368345257.608218   1071727   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]     trinity-main  2904 3222239757.989673   1331063   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]         krfcommd 10400    517522.685330         2   110    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          trinity  2912 166377005.882972        14   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]      kworker/0:2  7940 375002722.777345  21949160   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]     kworker/u8:0  8010 368349467.898199      2489   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]   pmlogger_check  8538      1212.204250      2948   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-26742
[177166.532023]     kworker/u8:1  8674 368343934.391631      1439   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      trinity-c15 10461    120070.477795      7909   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-26822
[177166.532023]      kworker/0:1 10487 368262563.773148         2   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      trinity-c13 10642 101220178.521968  13887559   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-26831
[177166.532023]      trinity-c11 10702 3249050496.990738    901719   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]       trinity-c0 10726 3249050486.986194    880197   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]       trinity-c6 10728 3249050477.986194    901577   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]       trinity-c0 10768 351989603.032117   1098295   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]      trinity-c10 10772 3249050499.317680    903436   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]=20
[177166.532023] cpu#1, 2393.998 MHz
[177166.532023]   .nr_running                    : 15
[177166.532023]   .load                          : 7736
[177166.532023]   .nr_switches                   : 217386938
[177166.532023]   .nr_load_updates               : 169216803
[177166.532023]   .nr_uninterruptible            : -50694
[177166.532023]   .next_balance                  : 4471.833883
[177166.532023]   .curr->pid                     : 534
[177166.532023]   .clock                         : 177166531.189964
[177166.532023]   .clock_task                    : 170916417.324586
[177166.532023]   .cpu_load[0]                   : 5040
[177166.532023]   .cpu_load[1]                   : 5811
[177166.532023]   .cpu_load[2]                   : 5918
[177166.532023]   .cpu_load[3]                   : 5950
[177166.532023]   .cpu_load[4]                   : 6009
[177166.532023]=20
[177166.532023] cfs_rq[1]:/autogroup-15273
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 437410.018645
[177166.532023]   .min_vruntime                  : 437410.018645
[177166.532023]   .max_vruntime                  : 437410.018645
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -374570425.229417
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 889
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 902
[177166.532023]   .tg_runnable_contrib           : 889
[177166.532023]   .tg_load_avg                   : 902
[177166.532023]   .tg->runnable_avg              : 889
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 170916416.430792
[177166.532023]   .se->vruntime                  : 371600174.250119
[177166.532023]   .se->sum_exec_runtime          : 437376.040585
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 41474
[177166.532023]   .se->avg.runnable_avg_period   : 47746
[177166.532023]   .se->avg.load_avg_contrib      : 887
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[1]:/autogroup-66
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 0.000001
[177166.532023]   .min_vruntime                  : 1538125.253290
[177166.532023]   .max_vruntime                  : 0.000001
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -373469712.582734
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 982
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 991
[177166.532023]   .tg_runnable_contrib           : 988
[177166.532023]   .tg_load_avg                   : 1931
[177166.532023]   .tg->runnable_avg              : 1939
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 170916417.324586
[177166.532023]   .se->vruntime                  : 371600173.395721
[177166.532023]   .se->sum_exec_runtime          : 1572289.057514
[177166.532023]   .se->load.weight               : 534
[177166.532023]   .se->avg.runnable_avg_sum      : 44654
[177166.532023]   .se->avg.runnable_avg_period   : 46518
[177166.532023]   .se->avg.load_avg_contrib      : 526
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[1]:/autogroup-96
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 2255406.371109
[177166.532023]   .min_vruntime                  : 2255406.371109
[177166.532023]   .max_vruntime                  : 2255406.371109
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -372752434.325218
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 894
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 915
[177166.532023]   .tg_runnable_contrib           : 906
[177166.532023]   .tg_load_avg                   : 915
[177166.532023]   .tg->runnable_avg              : 906
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 170916416.714402
[177166.532023]   .se->vruntime                  : 371600173.553728
[177166.532023]   .se->sum_exec_runtime          : 2255447.417368
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 41578
[177166.532023]   .se->avg.runnable_avg_period   : 47591
[177166.532023]   .se->avg.load_avg_contrib      : 884
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[1]:/autogroup-115
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 385064771.986581
[177166.532023]   .min_vruntime                  : 385064780.986581
[177166.532023]   .max_vruntime                  : 385064792.044274
[177166.532023]   .spread                        : 20.057693
[177166.532023]   .spread0                       : 10056937.457537
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 4
[177166.532023]   .load                          : 60
[177166.532023]   .runnable_load_avg             : 53
[177166.532023]   .blocked_load_avg              : 1
[177166.532023]   .tg_load_contrib               : 54
[177166.532023]   .tg_runnable_contrib           : 1019
[177166.532023]   .tg_load_avg                   : 180
[177166.532023]   .tg->runnable_avg              : 4035
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 170916354.126156
[177166.532023]   .se->vruntime                  : 371600175.884660
[177166.532023]   .se->sum_exec_runtime          : 7087887.294521
[177166.532023]   .se->load.weight               : 335
[177166.532023]   .se->avg.runnable_avg_sum      : 47376
[177166.532023]   .se->avg.runnable_avg_period   : 47552
[177166.532023]   .se->avg.load_avg_contrib      : 310
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[1]:/autogroup-68
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 2948620.791615
[177166.532023]   .min_vruntime                  : 2948620.791615
[177166.532023]   .max_vruntime                  : 2948620.791615
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -372059225.701738
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 966
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 980
[177166.532023]   .tg_runnable_contrib           : 979
[177166.532023]   .tg_load_avg                   : 1941
[177166.532023]   .tg->runnable_avg              : 1916
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 170916407.478182
[177166.532023]   .se->vruntime                  : 371600174.076953
[177166.532023]   .se->sum_exec_runtime          : 2994866.097531
[177166.532023]   .se->load.weight               : 532
[177166.532023]   .se->avg.runnable_avg_sum      : 45292
[177166.532023]   .se->avg.runnable_avg_period   : 47994
[177166.532023]   .se->avg.load_avg_contrib      : 520
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[1]:/autogroup-50
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 466129.794311
[177166.532023]   .min_vruntime                  : 466129.794311
[177166.532023]   .max_vruntime                  : 466129.794311
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -374541719.448431
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 6100
[177166.532023]   .runnable_load_avg             : 5363
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 5448
[177166.532023]   .tg_runnable_contrib           : 903
[177166.532023]   .tg_load_avg                   : 5448
[177166.532023]   .tg->runnable_avg              : 903
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 170916410.396416
[177166.532023]   .se->vruntime                  : 371600173.445801
[177166.532023]   .se->sum_exec_runtime          : 2768292.422865
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 42169
[177166.532023]   .se->avg.runnable_avg_period   : 47961
[177166.532023]   .se->avg.load_avg_contrib      : 882
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[1]:/autogroup-52
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 0.000001
[177166.532023]   .min_vruntime                  : 92625489.443537
[177166.532023]   .max_vruntime                  : 0.000001
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -282382362.741630
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 0
[177166.532023]   .load                          : 0
[177166.532023]   .runnable_load_avg             : 0
[177166.532023]   .blocked_load_avg              : 13
[177166.532023]   .tg_load_contrib               : 13
[177166.532023]   .tg_runnable_contrib           : 916
[177166.532023]   .tg_load_avg                   : 13
[177166.532023]   .tg->runnable_avg              : 916
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 170916417.324586
[177166.532023]   .se->vruntime                  : 371600173.707402
[177166.532023]   .se->sum_exec_runtime          : 1356831.705162
[177166.532023]   .se->load.weight               : 2
[177166.532023]   .se->avg.runnable_avg_sum      : 41977
[177166.532023]   .se->avg.runnable_avg_period   : 47318
[177166.532023]   .se->avg.load_avg_contrib      : 849
[177166.532023]   .se->avg.decay_count           : 162998598
[177166.532023]=20
[177166.532023] cfs_rq[1]:/autogroup-88
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 1506142.479516
[177166.532023]   .min_vruntime                  : 1506142.479516
[177166.532023]   .max_vruntime                  : 1506142.479516
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -373501712.422268
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 910
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 904
[177166.532023]   .tg_runnable_contrib           : 905
[177166.532023]   .tg_load_avg                   : 904
[177166.532023]   .tg->runnable_avg              : 905
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 170916416.978769
[177166.532023]   .se->vruntime                  : 371600173.563902
[177166.532023]   .se->sum_exec_runtime          : 1506149.953738
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 41888
[177166.532023]   .se->avg.runnable_avg_period   : 47088
[177166.532023]   .se->avg.load_avg_contrib      : 903
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[1]:/autogroup-65
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 1623869.846044
[177166.532023]   .min_vruntime                  : 1623869.846044
[177166.532023]   .max_vruntime                  : 1623869.846044
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -373383987.959483
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 856
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 870
[177166.532023]   .tg_runnable_contrib           : 867
[177166.532023]   .tg_load_avg                   : 870
[177166.532023]   .tg->runnable_avg              : 867
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 170916415.385678
[177166.532023]   .se->vruntime                  : 371600174.171951
[177166.532023]   .se->sum_exec_runtime          : 1623885.564701
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 39080
[177166.532023]   .se->avg.runnable_avg_period   : 46735
[177166.532023]   .se->avg.load_avg_contrib      : 865
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[1]:/autogroup-117
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 3195201733.443468
[177166.532023]   .min_vruntime                  : 3195201741.998037
[177166.532023]   .max_vruntime                  : 3195201741.998037
[177166.532023]   .spread                        : 8.554569
[177166.532023]   .spread0                       : 2820193881.563252
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 3
[177166.532023]   .load                          : 45
[177166.532023]   .runnable_load_avg             : 41
[177166.532023]   .blocked_load_avg              : 1
[177166.532023]   .tg_load_contrib               : 41
[177166.532023]   .tg_runnable_contrib           : 1015
[177166.532023]   .tg_load_avg                   : 236
[177166.532023]   .tg->runnable_avg              : 4074
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 170916330.817011
[177166.532023]   .se->vruntime                  : 371600177.852607
[177166.532023]   .se->sum_exec_runtime          : 87367132.524322
[177166.532023]   .se->load.weight               : 191
[177166.532023]   .se->avg.runnable_avg_sum      : 46042
[177166.532023]   .se->avg.runnable_avg_period   : 46331
[177166.532023]   .se->avg.load_avg_contrib      : 176
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[1]:/
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 371600173.445801
[177166.532023]   .min_vruntime                  : 371600173.395721
[177166.532023]   .max_vruntime                  : 371600177.852607
[177166.532023]   .spread                        : 4.406806
[177166.532023]   .spread0                       : -3407689.861427
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 10
[177166.532023]   .load                          : 7736
[177166.532023]   .runnable_load_avg             : 6865
[177166.532023]   .blocked_load_avg              : 850
[177166.532023]   .tg_load_contrib               : 7710
[177166.532023]   .tg_runnable_contrib           : 1010
[177166.532023]   .tg_load_avg                   : 29100
[177166.532023]   .tg->runnable_avg              : 4060
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .avg->runnable_avg_sum         : 46287
[177166.532023]   .avg->runnable_avg_period      : 46287
[177166.532023]=20
[177166.532023] rt_rq[1]:/
[177166.532023]   .rt_nr_running                 : 0
[177166.532023]   .rt_throttled                  : 0
[177166.532023]   .rt_time                       : 0.000000
[177166.532023]   .rt_runtime                    : 950.000000
[177166.532023]=20
[177166.532023] dl_rq[1]:
[177166.532023]   .dl_nr_running                 : 0
[177166.532023]=20
[177166.532023] runnable tasks:
[177166.532023]             task   PID         tree-key  switches  prio    =
 exec-runtime         sum-exec        sum-sleep
[177166.532023] -----------------------------------------------------------=
-----------------------------------------------
[177166.532023]        rcu_sched     7 371600021.525500  16724329   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          rcuos/0     9 371600021.513295   4620498   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]       watchdog/1    13        -1.001965     44290     0    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      migration/1    14         0.000000     95857     0    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      ksoftirqd/1    15 371596708.079410    177637   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]     kworker/1:0H    17     13783.758490         8   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          rcuos/1    18 371600021.521235   2341084   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]            netns    36        17.906620         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]             perf    37        23.952399         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]        writeback    41 364258169.404902        99   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]           crypto    44        65.278617         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      kintegrityd    45        71.312590         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]           bioset    46        77.345116         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          kblockd    47        83.375280         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]    pageattr-test    53 371600173.966656  16545346   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]     kmpath_rdacd    70      1604.904626         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]    ipv6_addrconf    73      1659.987209         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          deferwq    93      1782.158173         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          ata_sff   260      3189.092318         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]        scsi_eh_1   266      3937.238959         4   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]       scsi_tmf_1   267      3849.244932         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]    systemd-udevd   396      1062.698315      3909   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-37
[177166.532023]        hd-audio0   464      7824.599416         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      jbd2/vda1-8   476      7863.803769         2   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]  ext4-rsv-conver   477      7872.945993         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          audispd   491    466129.794311  16240820   112    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-50
[177166.532023]          alsactl   509  92625489.443537  16127574   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-52
[177166.532023]            tuned   635       253.332378        16   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-58
[177166.532023]            abrtd   524        27.256290        79   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-62
[177166.532023]       irqbalance   532   1623869.846044  16496599   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-65
[177166.532023] R NetworkManager   534   1538125.253290  10929581   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-66
[177166.532023]   NetworkManager   579        31.235590         1   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-66
[177166.532023]         rsyslogd   538   2948620.791615    585431   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-68
[177166.532023]   systemd-logind   540     13023.114292     42289   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-70
[177166.532023]     avahi-daemon   551         0.054832         3   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-61
[177166.532023]         cfg80211   583      8769.220473         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]           xinetd   828         0.200495        16   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-86
[177166.532023]          rpcbind   841   1506142.479516  16260960   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-88
[177166.532023]         sendmail   915   2255406.371109  16930681   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-96
[177166.532023]            login  1008        32.831973       142   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-113
[177166.532023]        automount  1082        45.772479         5   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]        automount  1096    105526.523927       193   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]        automount  1107        49.136863         3   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]     kworker/1:1H  1817 364788071.771906    867335   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]             sshd  1826   9483123.586059   1295418   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-114
[177166.532023]             bash  1855       644.627658      2229   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-117
[177166.532023]             sshd  1923        29.865372        43   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-118
[177166.532023]             sshd  1925   2439255.539907    135182   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-118
[177166.532023]             bash  1926  26518132.277426      2300   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-119
[177166.532023]             bash  9780    437410.018645   3054141   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-15273
[177166.532023]       pmie_check  8850      1632.306157      4144   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-26758
[177166.532023]      kworker/1:2  9169 370319593.626894  21806794   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      kworker/1:0  9968 370319594.039006         6   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      trinity-c10 10416 385064771.986581   1120960   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]       trinity-c1 10605 3195201741.998037    905332   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]      trinity-c11 10638 385064771.986581   1116925   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]       trinity-c8 10653 385064781.640916   1116960   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]       trinity-c9 10655 385064792.044274   1123459   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]       trinity-c8 10661 3195201740.626355    900266   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]       trinity-c1 10673     39147.341045      3108   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-26830
[177166.532023]      trinity-c14 10701 3195201733.443468    902522   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]=20
[177166.532023] cpu#2, 2393.998 MHz
[177166.532023]   .nr_running                    : 18
[177166.532023]   .load                          : 3823
[177166.532023]   .nr_switches                   : 224079569
[177166.532023]   .nr_load_updates               : 169487725
[177166.532023]   .nr_uninterruptible            : 18724
[177166.532023]   .next_balance                  : 4471.839256
[177166.532023]   .curr->pid                     : 997
[177166.532023]   .clock                         : 177171939.085316
[177166.532023]   .clock_task                    : 176282951.604784
[177166.532023]   .cpu_load[0]                   : 5718
[177166.532023]   .cpu_load[1]                   : 5020
[177166.532023]   .cpu_load[2]                   : 5114
[177166.532023]   .cpu_load[3]                   : 4948
[177166.532023]   .cpu_load[4]                   : 4811
[177166.532023]=20
[177166.532023] cfs_rq[2]:/autogroup-110
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 0.000001
[177166.532023]   .min_vruntime                  : 1582762.624878
[177166.532023]   .max_vruntime                  : 0.000001
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -373425125.558340
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 0
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 857
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 850
[177166.532023]   .tg_runnable_contrib           : 852
[177166.532023]   .tg_load_avg                   : 859
[177166.532023]   .tg->runnable_avg              : 852
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176282972.816656
[177166.532023]   .se->vruntime                  : 376374927.366688
[177166.532023]   .se->sum_exec_runtime          : 1587894.893245
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 38579
[177166.532023]   .se->avg.runnable_avg_period   : 46869
[177166.532023]   .se->avg.load_avg_contrib      : 831
[177166.532023]   .se->avg.decay_count           : 168116550
[177166.532023]=20
[177166.532023] cfs_rq[2]:/autogroup-95
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 1324950.166978
[177166.532023]   .min_vruntime                  : 1324950.166978
[177166.532023]   .max_vruntime                  : 1324950.166978
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -373682940.511653
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 0
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 832
[177166.532023]   .tg_runnable_contrib           : 828
[177166.532023]   .tg_load_avg                   : 832
[177166.532023]   .tg->runnable_avg              : 828
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176282994.421317
[177166.532023]   .se->vruntime                  : 376374930.084583
[177166.532023]   .se->sum_exec_runtime          : 1325607.248425
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 38386
[177166.532023]   .se->avg.runnable_avg_period   : 46830
[177166.532023]   .se->avg.load_avg_contrib      : 846
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[2]:/autogroup-108
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 3205323.717597
[177166.532023]   .min_vruntime                  : 3205323.717597
[177166.532023]   .max_vruntime                  : 3205323.717597
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -371802569.800773
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 850
[177166.532023]   .blocked_load_avg              : 850
[177166.532023]   .tg_load_contrib               : 868
[177166.532023]   .tg_runnable_contrib           : 845
[177166.532023]   .tg_load_avg                   : 868
[177166.532023]   .tg->runnable_avg              : 845
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176283015.515203
[177166.532023]   .se->vruntime                  : 376374933.235774
[177166.532023]   .se->sum_exec_runtime          : 3205327.299537
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 38320
[177166.532023]   .se->avg.runnable_avg_period   : 46821
[177166.532023]   .se->avg.load_avg_contrib      : 832
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[2]:/autogroup-58
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 2631939.462685
[177166.532023]   .min_vruntime                  : 2631939.639799
[177166.532023]   .max_vruntime                  : 2631939.731649
[177166.532023]   .spread                        : 0.268964
[177166.532023]   .spread0                       : -372375956.631241
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 2
[177166.532023]   .load                          : 2048
[177166.532023]   .runnable_load_avg             : 1819
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 1824
[177166.532023]   .tg_runnable_contrib           : 940
[177166.532023]   .tg_load_avg                   : 1824
[177166.532023]   .tg->runnable_avg              : 940
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176283042.358416
[177166.532023]   .se->vruntime                  : 376374937.268648
[177166.532023]   .se->sum_exec_runtime          : 3334795.113027
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 43384
[177166.532023]   .se->avg.runnable_avg_period   : 46924
[177166.532023]   .se->avg.load_avg_contrib      : 918
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[2]:/autogroup-67
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 1687053.076767
[177166.532023]   .min_vruntime                  : 1687053.076767
[177166.532023]   .max_vruntime                  : 1687053.076767
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -373320846.368082
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 847
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 864
[177166.532023]   .tg_runnable_contrib           : 863
[177166.532023]   .tg_load_avg                   : 864
[177166.532023]   .tg->runnable_avg              : 863
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176283065.404123
[177166.532023]   .se->vruntime                  : 376374939.650415
[177166.532023]   .se->sum_exec_runtime          : 1687066.427503
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 38163
[177166.532023]   .se->avg.runnable_avg_period   : 46629
[177166.532023]   .se->avg.load_avg_contrib      : 845
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[2]:/autogroup-115
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 361235872.166537
[177166.532023]   .min_vruntime                  : 361235881.166537
[177166.532023]   .max_vruntime                  : 361235883.779770
[177166.532023]   .spread                        : 11.613233
[177166.532023]   .spread0                       : -13772020.616615
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 6
[177166.532023]   .load                          : 90
[177166.532023]   .runnable_load_avg             : 84
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 84
[177166.532023]   .tg_runnable_contrib           : 1008
[177166.532023]   .tg_load_avg                   : 180
[177166.532023]   .tg->runnable_avg              : 4049
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176283070.613135
[177166.532023]   .se->vruntime                  : 376374944.701713
[177166.532023]   .se->sum_exec_runtime          : 6887381.288178
[177166.532023]   .se->load.weight               : 495
[177166.532023]   .se->avg.runnable_avg_sum      : 47581
[177166.532023]   .se->avg.runnable_avg_period   : 47581
[177166.532023]   .se->avg.load_avg_contrib      : 475
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[2]:/autogroup-63
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 0.000001
[177166.532023]   .min_vruntime                  : 1553264.803109
[177166.532023]   .max_vruntime                  : 0.000001
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -373454639.787732
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 0
[177166.532023]   .runnable_load_avg             : 864
[177166.532023]   .blocked_load_avg              : 867
[177166.532023]   .tg_load_contrib               : 867
[177166.532023]   .tg_runnable_contrib           : 853
[177166.532023]   .tg_load_avg                   : 857
[177166.532023]   .tg->runnable_avg              : 853
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176283107.964198
[177166.532023]   .se->vruntime                  : 376374945.366639
[177166.532023]   .se->sum_exec_runtime          : 1553293.605024
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 40759
[177166.532023]   .se->avg.runnable_avg_period   : 47262
[177166.532023]   .se->avg.load_avg_contrib      : 870
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[2]:/autogroup-26829
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 448963725.676453
[177166.532023]   .min_vruntime                  : 448963725.676453
[177166.532023]   .max_vruntime                  : 448963725.676453
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : 73955818.080622
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 15
[177166.532023]   .runnable_load_avg             : 12
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 12
[177166.532023]   .tg_runnable_contrib           : 850
[177166.532023]   .tg_load_avg                   : 12
[177166.532023]   .tg->runnable_avg              : 850
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176283135.704509
[177166.532023]   .se->vruntime                  : 376374948.714997
[177166.532023]   .se->sum_exec_runtime          : 6576626.644672
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 39386
[177166.532023]   .se->avg.runnable_avg_period   : 47386
[177166.532023]   .se->avg.load_avg_contrib      : 784
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[2]:/autogroup-117
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 3253330115.653655
[177166.532023]   .min_vruntime                  : 3253330124.653655
[177166.532023]   .max_vruntime                  : 3253330125.559211
[177166.532023]   .spread                        : 9.905556
[177166.532023]   .spread0                       : 2878322214.348482
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 4
[177166.532023]   .load                          : 60
[177166.532023]   .runnable_load_avg             : 42
[177166.532023]   .blocked_load_avg              : 2
[177166.532023]   .tg_load_contrib               : 56
[177166.532023]   .tg_runnable_contrib           : 1019
[177166.532023]   .tg_load_avg                   : 235
[177166.532023]   .tg->runnable_avg              : 4074
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176283152.492944
[177166.532023]   .se->vruntime                  : 376374956.513148
[177166.532023]   .se->sum_exec_runtime          : 90963028.806675
[177166.532023]   .se->load.weight               : 257
[177166.532023]   .se->avg.runnable_avg_sum      : 46640
[177166.532023]   .se->avg.runnable_avg_period   : 46738
[177166.532023]   .se->avg.load_avg_contrib      : 236
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[2]:/
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 376374952.628298
[177166.532023]   .min_vruntime                  : 376374952.800728
[177166.532023]   .max_vruntime                  : 376374956.513148
[177166.532023]   .spread                        : 3.884850
[177166.532023]   .spread0                       : 1367039.537877
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 7
[177166.532023]   .load                          : 6896
[177166.532023]   .runnable_load_avg             : 5751
[177166.532023]   .blocked_load_avg              : 9
[177166.532023]   .tg_load_contrib               : 6584
[177166.532023]   .tg_runnable_contrib           : 1018
[177166.532023]   .tg_load_avg                   : 28948
[177166.532023]   .tg->runnable_avg              : 4060
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .avg->runnable_avg_sum         : 46473
[177166.532023]   .avg->runnable_avg_period      : 47067
[177166.532023]=20
[177166.532023] rt_rq[2]:/
[177166.532023]   .rt_nr_running                 : 0
[177166.532023]   .rt_throttled                  : 0
[177166.532023]   .rt_time                       : 0.000000
[177166.532023]   .rt_runtime                    : 950.000000
[177166.532023]=20
[177166.532023] dl_rq[2]:
[177166.532023]   .dl_nr_running                 : 0
[177166.532023]=20
[177166.532023] runnable tasks:
[177166.532023]             task   PID         tree-key  switches  prio    =
 exec-runtime         sum-exec        sum-sleep
[177166.532023] -----------------------------------------------------------=
-----------------------------------------------
[177166.532023]       watchdog/2    20        -4.963430     44295     0    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      migration/2    21         0.000000     94995     0    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      ksoftirqd/2    22 376184715.153997     81875   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]     kworker/2:0H    24      9433.609548         8   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]             ksmd    42 369299357.881472       394   125    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]       devfreq_wq    51        26.142096         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]    fsnotify_mark    56 368580838.557735       101   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]        kpsmoused    71       506.511114         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]        scsi_eh_0   263      2716.213830         4   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]         ttm_swap   271      2751.252478         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          audispd   488     31554.928962     54086   112    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-50
[177166.532023]       sedispatch   490     31563.302131     91234   116    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-50
[177166.532023]            tuned   520   2631952.530831   7431167   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-58
[177166.532023]            gmain   633        74.088831         4   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-58
[177166.532023]            tuned   637   2631952.990806  11066789   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-58
[177166.532023]   abrt-watch-log   527   1553282.661689  16494663   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-63
[177166.532023]            gdbus   585    469077.097428     57234   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-66
[177166.532023]             lsmd   535   1687077.954301  16420754   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-67
[177166.532023]    rs:main Q:Reg   571    364116.108122    988023   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-68
[177166.532023]      dbus-daemon   541     46313.960359    320593   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-71
[177166.532023]        rpc.statd   892       193.330679       577   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-94
[177166.532023]           ypbind   929   1324984.974570  16456367   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-95
[177166.532023]              atd   997   3205356.169191  14737877   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-108
[177166.532023]     kworker/2:1H  1009 369804308.539212   1062578   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]        automount  1024   1582801.736614  15814141   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]        automount  1114        66.601631         3   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]        automount  1118        70.058959         3   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]        automount  1122        73.155845         3   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]             sshd  1846        15.688715        44   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-116
[177166.532023]             sshd  1853   1318075.893894    109445   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-116
[177166.532023]         iscsi_eh  2092     15516.839096         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      kworker/2:1  6804 376374133.987057  21970522   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]            crond  8628    315122.579026      5877   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-107
[177166.532023]   pmlogger_check  8741     24076.528108     19205   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-26742
[177166.532023]       trinity-c4 10628 3253330176.400888    902302   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]      trinity-c14 10645 361236004.743263   1125762   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]  trinity-subchil 10664 369750218.727221        77   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]       trinity-c5 10681 361235999.237475   1123106   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]       trinity-c2 10706 3253330216.579715    866561   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]       trinity-c2 10710 448965249.258971  13776139   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-26829
[177166.532023]       trinity-c6 10736 361236006.263154   1130077   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]      trinity-c12 10737 361236000.039742   1118554   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]       trinity-c4 10744 361236004.308459   1128122   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]       trinity-c7 10749 361235999.712814   1123006   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]       trinity-c9 10751 3253330216.579715    904474   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]       trinity-c7 10766 3253330226.484657    911766   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]      kworker/2:2 10782 369780260.485894         2   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]=20
[177166.532023] cpu#3, 2393.998 MHz
[177166.532023]   .nr_running                    : 14
[177166.532023]   .load                          : 7714
[177166.532023]   .nr_switches                   : 226359552
[177166.532023]   .nr_load_updates               : 169476618
[177166.532023]   .nr_uninterruptible            : 42316
[177166.532023]   .next_balance                  : 4471.839674
[177166.532023]   .curr->pid                     : 10730
[177166.532023]   .clock                         : 177172320.056798
[177166.532023]   .clock_task                    : 176308603.286546
[177166.532023]   .cpu_load[0]                   : 6210
[177166.532023]   .cpu_load[1]                   : 5245
[177166.532023]   .cpu_load[2]                   : 4754
[177166.532023]   .cpu_load[3]                   : 4565
[177166.532023]   .cpu_load[4]                   : 4371
[177166.532023]=20
[177166.532023] cfs_rq[3]:/autogroup-32
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 0.000001
[177166.532023]   .min_vruntime                  : 2290936.181913
[177166.532023]   .max_vruntime                  : 0.000001
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -372716997.588761
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 0
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 782
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 799
[177166.532023]   .tg_runnable_contrib           : 783
[177166.532023]   .tg_load_avg                   : 799
[177166.532023]   .tg->runnable_avg              : 806
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176308623.296165
[177166.532023]   .se->vruntime                  : 376721287.655836
[177166.532023]   .se->sum_exec_runtime          : 2291072.204528
[177166.532023]   .se->load.weight               : 2
[177166.532023]   .se->avg.runnable_avg_sum      : 36217
[177166.532023]   .se->avg.runnable_avg_period   : 46214
[177166.532023]   .se->avg.load_avg_contrib      : 800
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[3]:/autogroup-26758
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 2481186.466579
[177166.532023]   .min_vruntime                  : 2481186.466579
[177166.532023]   .max_vruntime                  : 2481186.466579
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -372526750.479697
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 812
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 815
[177166.532023]   .tg_runnable_contrib           : 811
[177166.532023]   .tg_load_avg                   : 815
[177166.532023]   .tg->runnable_avg              : 840
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176308655.440758
[177166.532023]   .se->vruntime                  : 376721291.252804
[177166.532023]   .se->sum_exec_runtime          : 2481706.513269
[177166.532023]   .se->load.weight               : 2
[177166.532023]   .se->avg.runnable_avg_sum      : 36844
[177166.532023]   .se->avg.runnable_avg_period   : 46551
[177166.532023]   .se->avg.load_avg_contrib      : 802
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[3]:/autogroup-17269
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 641338.498828
[177166.532023]   .min_vruntime                  : 641338.498828
[177166.532023]   .max_vruntime                  : 641338.498828
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -374366601.746434
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 829
[177166.532023]   .blocked_load_avg              : 837
[177166.532023]   .tg_load_contrib               : 837
[177166.532023]   .tg_runnable_contrib           : 830
[177166.532023]   .tg_load_avg                   : 831
[177166.532023]   .tg->runnable_avg              : 830
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176308676.737343
[177166.532023]   .se->vruntime                  : 376721294.628766
[177166.532023]   .se->sum_exec_runtime          : 641341.506372
[177166.532023]   .se->load.weight               : 2
[177166.532023]   .se->avg.runnable_avg_sum      : 38996
[177166.532023]   .se->avg.runnable_avg_period   : 48127
[177166.532023]   .se->avg.load_avg_contrib      : 844
[177166.532023]   .se->avg.decay_count           : 168141066
[177166.532023]=20
[177166.532023] cfs_rq[3]:/autogroup-64
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 2012621.386557
[177166.532023]   .min_vruntime                  : 2012621.386557
[177166.532023]   .max_vruntime                  : 2012621.386557
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -372995321.899779
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 789
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 791
[177166.532023]   .tg_runnable_contrib           : 807
[177166.532023]   .tg_load_avg                   : 806
[177166.532023]   .tg->runnable_avg              : 807
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176308699.446108
[177166.532023]   .se->vruntime                  : 376721297.650443
[177166.532023]   .se->sum_exec_runtime          : 2012625.191891
[177166.532023]   .se->load.weight               : 2
[177166.532023]   .se->avg.runnable_avg_sum      : 36597
[177166.532023]   .se->avg.runnable_avg_period   : 46695
[177166.532023]   .se->avg.load_avg_contrib      : 790
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[3]:/autogroup-107
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 1979332.719760
[177166.532023]   .min_vruntime                  : 1979332.719760
[177166.532023]   .max_vruntime                  : 1979332.719760
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -373028613.473199
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 868
[177166.532023]   .blocked_load_avg              : 873
[177166.532023]   .tg_load_contrib               : 867
[177166.532023]   .tg_runnable_contrib           : 873
[177166.532023]   .tg_load_avg                   : 867
[177166.532023]   .tg->runnable_avg              : 873
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176308728.440462
[177166.532023]   .se->vruntime                  : 376721300.244680
[177166.532023]   .se->sum_exec_runtime          : 2055891.393269
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 38130
[177166.532023]   .se->avg.runnable_avg_period   : 46377
[177166.532023]   .se->avg.load_avg_contrib      : 851
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[3]:/autogroup-61
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 0.000001
[177166.532023]   .min_vruntime                  : 2952623.822041
[177166.532023]   .max_vruntime                  : 0.000001
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -372055327.451050
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 0
[177166.532023]   .runnable_load_avg             : 817
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 832
[177166.532023]   .tg_runnable_contrib           : 817
[177166.532023]   .tg_load_avg                   : 829
[177166.532023]   .tg->runnable_avg              : 832
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176308747.812181
[177166.532023]   .se->vruntime                  : 376721303.066830
[177166.532023]   .se->sum_exec_runtime          : 2952634.761287
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 37762
[177166.532023]   .se->avg.runnable_avg_period   : 46789
[177166.532023]   .se->avg.load_avg_contrib      : 830
[177166.532023]   .se->avg.decay_count           : 168141135
[177166.532023]=20
[177166.532023] cfs_rq[3]:/autogroup-26742
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 2183309.187031
[177166.532023]   .min_vruntime                  : 2183309.187031
[177166.532023]   .max_vruntime                  : 2183309.187031
[177166.532023]   .spread                        : 0.000000
[177166.532023]   .spread0                       : -372824642.761007
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 1
[177166.532023]   .load                          : 1024
[177166.532023]   .runnable_load_avg             : 859
[177166.532023]   .blocked_load_avg              : 866
[177166.532023]   .tg_load_contrib               : 866
[177166.532023]   .tg_runnable_contrib           : 858
[177166.532023]   .tg_load_avg                   : 866
[177166.532023]   .tg->runnable_avg              : 858
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176308775.256835
[177166.532023]   .se->vruntime                  : 376721306.254769
[177166.532023]   .se->sum_exec_runtime          : 2183893.294187
[177166.532023]   .se->load.weight               : 1024
[177166.532023]   .se->avg.runnable_avg_sum      : 39476
[177166.532023]   .se->avg.runnable_avg_period   : 47145
[177166.532023]   .se->avg.load_avg_contrib      : 837
[177166.532023]   .se->avg.decay_count           : 168141157
[177166.532023]=20
[177166.532023] cfs_rq[3]:/autogroup-117
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 3254005919.416544
[177166.532023]   .min_vruntime                  : 3254005928.416544
[177166.532023]   .max_vruntime                  : 3254005958.353380
[177166.532023]   .spread                        : 38.936836
[177166.532023]   .spread0                       : 2878997973.863545
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 6
[177166.532023]   .load                          : 90
[177166.532023]   .runnable_load_avg             : 83
[177166.532023]   .blocked_load_avg              : 1
[177166.532023]   .tg_load_contrib               : 83
[177166.532023]   .tg_runnable_contrib           : 1020
[177166.532023]   .tg_load_avg                   : 236
[177166.532023]   .tg->runnable_avg              : 4074
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176308798.286110
[177166.532023]   .se->vruntime                  : 376721314.110965
[177166.532023]   .se->sum_exec_runtime          : 91651510.576793
[177166.532023]   .se->load.weight               : 379
[177166.532023]   .se->avg.runnable_avg_sum      : 46662
[177166.532023]   .se->avg.runnable_avg_period   : 46662
[177166.532023]   .se->avg.load_avg_contrib      : 358
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[3]:/autogroup-115
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 354604525.604423
[177166.532023]   .min_vruntime                  : 354604534.604423
[177166.532023]   .max_vruntime                  : 354604534.604423
[177166.532023]   .spread                        : 9.000000
[177166.532023]   .spread0                       : -20403422.744714
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 2
[177166.532023]   .load                          : 30
[177166.532023]   .runnable_load_avg             : 27
[177166.532023]   .blocked_load_avg              : 0
[177166.532023]   .tg_load_contrib               : 27
[177166.532023]   .tg_runnable_contrib           : 1014
[177166.532023]   .tg_load_avg                   : 179
[177166.532023]   .tg->runnable_avg              : 4049
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .se->exec_start                : 176308745.278757
[177166.532023]   .se->vruntime                  : 376721317.766613
[177166.532023]   .se->sum_exec_runtime          : 7072712.719861
[177166.532023]   .se->load.weight               : 169
[177166.532023]   .se->avg.runnable_avg_sum      : 47795
[177166.532023]   .se->avg.runnable_avg_period   : 47902
[177166.532023]   .se->avg.load_avg_contrib      : 154
[177166.532023]   .se->avg.decay_count           : 0
[177166.532023]=20
[177166.532023] cfs_rq[3]:/
[177166.532023]   .exec_clock                    : 0.000000
[177166.532023]   .MIN_vruntime                  : 376721313.014649
[177166.532023]   .min_vruntime                  : 376721313.013709
[177166.532023]   .max_vruntime                  : 376721317.766613
[177166.532023]   .spread                        : 4.751964
[177166.532023]   .spread0                       : 1713352.769967
[177166.532023]   .nr_spread_over                : 0
[177166.532023]   .nr_running                    : 8
[177166.532023]   .load                          : 5668
[177166.532023]   .runnable_load_avg             : 4804
[177166.532023]   .blocked_load_avg              : 2551
[177166.532023]   .tg_load_contrib               : 7402
[177166.532023]   .tg_runnable_contrib           : 1011
[177166.532023]   .tg_load_avg                   : 29016
[177166.532023]   .tg->runnable_avg              : 4060
[177166.532023]   .tg->cfs_bandwidth.timer_active: 0
[177166.532023]   .throttled                     : 0
[177166.532023]   .throttle_count                : 0
[177166.532023]   .avg->runnable_avg_sum         : 46230
[177166.532023]   .avg->runnable_avg_period      : 46189
[177166.532023]=20
[177166.532023] rt_rq[3]:/
[177166.532023]   .rt_nr_running                 : 0
[177166.532023]   .rt_throttled                  : 0
[177166.532023]   .rt_time                       : 0.099937
[177166.532023]   .rt_runtime                    : 950.000000
[177166.532023]=20
[177166.532023] dl_rq[3]:
[177166.532023]   .dl_nr_running                 : 0
[177166.532023]=20
[177166.532023] runnable tasks:
[177166.532023]             task   PID         tree-key  switches  prio    =
 exec-runtime         sum-exec        sum-sleep
[177166.532023] -----------------------------------------------------------=
-----------------------------------------------
[177166.532023]          rcuos/2    25 370034748.679747   3913420   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]       watchdog/3    27        -3.985925     44296     0    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      migration/3    28         0.000000     94837     0    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      ksoftirqd/3    29 376705430.114255     82621   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]     kworker/3:0H    31      1741.083688         7   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          rcuos/3    32 370034074.184545   1924385   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          khelper    34 369156014.260975       160   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]       khugepaged    43 376718732.322143     67195   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          kswapd0    55 376721319.084826  48849818   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]          kauditd   115 369819133.344375     29129   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]       scsi_tmf_0   264      1351.603912         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]     kworker/3:1H   277 369905112.951058   1050038   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]      jbd2/vda2-8   283 369905118.771029    404271   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]  ext4-rsv-conver   284      2118.737700         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]  systemd-journal   383   2290971.790183  17444507   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-32
[177166.532023]     avahi-daemon   523   2952643.883913  15934645   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-61
[177166.532023]          chronyd   531   2012647.640526  15672518   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-64
[177166.532023]            gmain   606        66.554083         3   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-66
[177166.532023]        iprupdate   559         9.810746       183   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-73
[177166.532023]          iprinit   560         9.270212       192   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-74
[177166.532023]          iprdump   574        13.230779       189   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-76
[177166.532023]     JS GC Helper   588        16.031973         2   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-77
[177166.532023]  JS Sour~ Thread   589        26.441424         8   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-77
[177166.532023]  runaway-killer-   590        35.381348         4   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-77
[177166.532023]           ypbind   917        19.220804         1   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-95
[177166.532023]           ypbind   918    426778.524643     24420   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-95
[177166.532023] R          crond   992   1979359.593857  15566265   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-107
[177166.532023]        automount  1023        88.848288        43   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]        automount  1066        49.265695         7   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]        automount  1092        52.782427         3   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]        automount  1101        66.910045         3   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]        automount  1127        81.796583         3   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]        automount  1131        82.691949         2   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]        automount  1134        97.413871         3   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-110
[177166.532023]             sshd  1808        31.160691        96   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-114
[177166.532023]           nfsiod  1818     11967.776609         2   100    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]            lockd  1825     12005.102889         2   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]             bash  1827 164080874.246954      2463   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]          trinity  2902       515.105237         6   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-117
[177166.532023]  trinity-watchdo  2903 3254006032.447642   1427339   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]  trinity-watchdo  2913 354604579.794165   1597034   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]     trinity-main  2914 318633382.354285    467921   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023]           agetty  2933    641376.187522   3004059   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-17269
[177166.532023]            crond  8335    303717.099602      4946   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-107
[177166.532023]      kworker/3:1  8860 369827516.640597        13   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]       pmie_check  9178     21879.123893     11285   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-26758
[177166.532023]      kworker/3:2  9632 376719839.301018  21459814   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /
[177166.532023]       trinity-c3 10593 3254006043.272681    911422   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]      trinity-c13 10596 3254006032.447642    914169   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]      trinity-c15 10665 3254006032.447642    908795   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]       trinity-c5 10730 3254006079.738419    910176   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]      trinity-c12 10776 3254006078.578431    914907   139   =
            0               0               0.000000               0.000000=
               0.000000 0 /autogroup-117
[177166.532023]       trinity-c3 10777 354604603.051931   1114809   139    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-115
[177166.532023] R     pmie_check 10798   2481231.545966  14212012   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-26758
[177166.532023]   pmlogger_check 10805   2183340.119741  13823157   120    =
           0               0               0.000000               0.000000 =
              0.000000 0 /autogroup-26742
[177166.532023]=20
[177166.532023]=20
[177166.532023] Showing all locks held in the system:
[177166.532023] 1 lock held by alsactl/509:
[177166.532023]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8107131a>] __d=
o_page_fault+0x13a/0x470
[177166.532023] 1 lock held by chronyd/531:
[177166.532023]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8107131a>] __d=
o_page_fault+0x13a/0x470
[177166.532023] 8 locks held by NetworkManager/534:
[177166.532023]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8107131a>] __d=
o_page_fault+0x13a/0x470
[177166.532023]  #1:  (shrinker_rwsem){++++..}, at: [<ffffffff811d856c>] sh=
rink_slab+0x7c/0x750
[177166.532023]  #2:  (&(&lru->node[i].lock)->rlock){+.+.-.}, at: [<fffffff=
f811f3f62>] __list_lru_count_one.isra.2+0x22/0x80
[177166.532023]  #3:  (&serio->lock){-.-.-.}, at: [<ffffffff8157e98e>] seri=
o_interrupt+0x2e/0x90
[177166.532023]  #4:  (&(&dev->event_lock)->rlock){-.-.-.}, at: [<ffffffff8=
1585575>] input_event+0x45/0x70
[177166.532023]  #5:  (rcu_read_lock){......}, at: [<ffffffff81584685>] inp=
ut_pass_values.part.5+0x5/0x300
[177166.532023]  #6:  (rcu_read_lock){......}, at: [<ffffffff8147cf65>] __h=
andle_sysrq+0x5/0x240
[177166.532023]  #7:  (tasklist_lock){.+.+..}, at: [<ffffffff810e5b62>] deb=
ug_show_all_locks+0x52/0x210
[177166.532023] 1 lock held by ypbind/929:
[177166.532023]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8107131a>] __d=
o_page_fault+0x13a/0x470
[177166.532023] 1 lock held by atd/997:
[177166.532023]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8107131a>] __d=
o_page_fault+0x13a/0x470
[177166.532023] 2 locks held by bash/1926:
[177166.532023]  #0:  (&tty->ldisc_sem){++++++}, at: [<ffffffff81478174>] t=
ty_ldisc_ref_wait+0x24/0x60
[177166.532023]  #1:  (&ldata->atomic_read_lock){+.+.+.}, at: [<ffffffff814=
74500>] n_tty_read+0xc0/0xb40
[177166.532023] 5 locks held by kworker/1:2/9169:
[177166.532023]  #0:  ("events"){.+.+.+}, at: [<ffffffff810a9bb6>] process_=
one_work+0x176/0x840
[177166.532023]  #1:  ((&buf->work)){+.+...}, at: [<ffffffff810a9bb6>] proc=
ess_one_work+0x176/0x840
[177166.532023]  #2:  (&tty->ldisc_sem){++++++}, at: [<ffffffff814781cf>] t=
ty_ldisc_ref+0x1f/0x70
[177166.532023]  #3:  (&buf->lock){+.+...}, at: [<ffffffff81479523>] flush_=
to_ldisc+0x43/0x120
[177166.532023]  #4:  (&tty->termios_rwsem){++++.+}, at: [<ffffffff81473fce=
>] isig+0x7e/0x110
[177166.532023] 1 lock held by kworker/1:0/9968:
[177166.532023]  #0:  (&pool->manager_arb){+.+.+.}, at: [<ffffffff810aa558>=
] worker_thread+0x2d8/0x460
[177166.532023] 2 locks held by trinity-c15/10461:
[177166.532023]  #0:  (sb_writers#5){.+.+.+}, at: [<ffffffff812515d3>] vfs_=
write+0x1b3/0x1f0
[177166.532023]  #1:  (&sb->s_type->i_mutex_key#8){+.+.+.}, at: [<ffffffff8=
11c3c04>] generic_file_write_iter+0x34/0xb0
[177166.532023] 2 locks held by trinity-c1/10673:
[177166.532023]  #0:  (sb_writers#5){.+.+.+}, at: [<ffffffff812776d4>] mnt_=
want_write+0x24/0x50
[177166.532023]  #1:  (&sb->s_type->i_mutex_key#8){+.+.+.}, at: [<ffffffff8=
124e3ba>] chmod_common+0x6a/0x170
[177166.532023]=20
[177166.532023] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
[177166.532023]=20
[183276.512102] EXT4-fs (vda2): error count since last fsck: 1577
[183276.513343] EXT4-fs (vda2): initial error at time 1423408940: ext4_disc=
ard_preallocations:3997
[183276.515132] EXT4-fs (vda2): last error at time 1423524386: ext4_write_e=
nd:1073
[226437.916050] Clocksource tsc unstable (delta =3D -101454490 ns)

Any guesses as for what could cause this? How can this be avoided?
Should I start doing a bisect for this?

Thanks,
--Shachar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
