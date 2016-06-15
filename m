Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4EA6B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 03:59:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 143so27162955pfx.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 00:59:11 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id r13si29392867pag.64.2016.06.15.00.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 00:59:10 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id 62so1228831pfd.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 00:59:10 -0700 (PDT)
Date: Wed, 15 Jun 2016 16:59:09 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v7 00/12] Support non-lru page migration
Message-ID: <20160615075909.GA425@swordfish>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464736881-24886-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, John Einar Reitan <john.reitan@foss.arm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Aquini <aquini@redhat.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, virtualization@lists.linux-foundation.org, Gioh Kim <gi-oh.kim@profitbricks.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Sangseok Lee <sangseok.lee@lge.com>, Kyeongdon Kim <kyeongdon.kim@lge.com>, Chulmin Kim <cmlaika.kim@samsung.com>

Hello Minchan,

-next 4.7.0-rc3-next-20160614


[  315.146533] kasan: CONFIG_KASAN_INLINE enabled
[  315.146538] kasan: GPF could be caused by NULL-ptr deref or user memory access
[  315.146546] general protection fault: 0000 [#1] PREEMPT SMP KASAN
[  315.146576] Modules linked in: lzo zram zsmalloc mousedev coretemp hwmon crc32c_intel r8169 i2c_i801 mii snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core acpi_cpufreq snd_pcm snd_timer snd soundcore lpc_ich mfd_core processor sch_fq_codel sd_mod hid_generic usbhid hid ahci libahci libata ehci_pci ehci_hcd scsi_mod usbcore usb_common
[  315.146785] CPU: 3 PID: 38 Comm: khugepaged Not tainted 4.7.0-rc3-next-20160614-dbg-00004-ga1c2cbc-dirty #488
[  315.146841] task: ffff8800bfaf2900 ti: ffff880112468000 task.ti: ffff880112468000
[  315.146859] RIP: 0010:[<ffffffffa02c413d>]  [<ffffffffa02c413d>] zs_page_migrate+0x355/0xaa0 [zsmalloc]
[  315.146892] RSP: 0000:ffff88011246f138  EFLAGS: 00010293
[  315.146906] RAX: 736761742d6f6e2c RBX: ffff880017ad9a80 RCX: 0000000000000000
[  315.146924] RDX: 1ffffffff064d704 RSI: ffff88000511469a RDI: ffffffff8326ba20
[  315.146942] RBP: ffff88011246f328 R08: 0000000000000001 R09: 0000000000000000
[  315.146959] R10: ffff88011246f0a8 R11: ffff8800bfc07fff R12: ffff88011246f300
[  315.146977] R13: ffffed0015523e6f R14: ffff8800aa91f378 R15: ffffea0000144500
[  315.146995] FS:  0000000000000000(0000) GS:ffff880113780000(0000) knlGS:0000000000000000
[  315.147015] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  315.147030] CR2: 00007f3f97911000 CR3: 0000000002209000 CR4: 00000000000006e0
[  315.147046] Stack:
[  315.147052]  1ffff10015523e0f ffff88011246f240 ffff880005116800 00017f80e0000000
[  315.147083]  ffff880017ad9aa8 736761742d6f6e2c 1ffff1002248de34 ffff880017ad9a90
[  315.147113]  0000069a1246f660 000000000000069a ffff880005114000 ffffea0002ff0180
[  315.147143] Call Trace:
[  315.147154]  [<ffffffffa02c3de8>] ? obj_to_head+0x9d/0x9d [zsmalloc]
[  315.147175]  [<ffffffff81d31dbc>] ? _raw_spin_unlock_irqrestore+0x47/0x5c
[  315.147195]  [<ffffffff812275b1>] ? isolate_freepages_block+0x2f9/0x5a6
[  315.147213]  [<ffffffff8127f15c>] ? kasan_poison_shadow+0x2f/0x31
[  315.147230]  [<ffffffff8127f66a>] ? kasan_alloc_pages+0x39/0x3b
[  315.147246]  [<ffffffff812267e6>] ? map_pages+0x1f3/0x3ad
[  315.147262]  [<ffffffff812265f3>] ? update_pageblock_skip+0x18d/0x18d
[  315.147280]  [<ffffffff81115972>] ? up_read+0x1a/0x30
[  315.147296]  [<ffffffff8111ec7e>] ? debug_check_no_locks_freed+0x150/0x22b
[  315.147315]  [<ffffffff812842d1>] move_to_new_page+0x4dd/0x615
[  315.147332]  [<ffffffff81283df4>] ? migrate_page+0x75/0x75
[  315.147347]  [<ffffffff8122785e>] ? isolate_freepages_block+0x5a6/0x5a6
[  315.147366]  [<ffffffff812851c1>] migrate_pages+0xadd/0x131a
[  315.147382]  [<ffffffff8122785e>] ? isolate_freepages_block+0x5a6/0x5a6
[  315.147399]  [<ffffffff81226375>] ? kzfree+0x2b/0x2b
[  315.147414]  [<ffffffff812846e4>] ? buffer_migrate_page+0x2db/0x2db
[  315.147431]  [<ffffffff8122a6cf>] compact_zone+0xcdb/0x1155
[  315.147448]  [<ffffffff812299f4>] ? compaction_suitable+0x76/0x76
[  315.147465]  [<ffffffff8122ac29>] compact_zone_order+0xe0/0x167
[  315.147481]  [<ffffffff8111f0ac>] ? debug_show_all_locks+0x226/0x226
[  315.147499]  [<ffffffff8122ab49>] ? compact_zone+0x1155/0x1155
[  315.147515]  [<ffffffff810d58d1>] ? finish_task_switch+0x3de/0x484
[  315.147533]  [<ffffffff8122bcff>] try_to_compact_pages+0x2f1/0x648
[  315.147550]  [<ffffffff8122bcff>] ? try_to_compact_pages+0x2f1/0x648
[  315.147568]  [<ffffffff8122ba0e>] ? compaction_zonelist_suitable+0x3a6/0x3a6
[  315.147589]  [<ffffffff811ee129>] ? get_page_from_freelist+0x2c0/0x129a
[  315.147608]  [<ffffffff811ef1ed>] __alloc_pages_direct_compact+0xea/0x30d
[  315.147626]  [<ffffffff811ef103>] ? get_page_from_freelist+0x129a/0x129a
[  315.147645]  [<ffffffff811f0422>] __alloc_pages_nodemask+0x840/0x16b6
[  315.147663]  [<ffffffff810dba27>] ? try_to_wake_up+0x696/0x6c8
[  315.149147]  [<ffffffff811efbe2>] ? warn_alloc_failed+0x226/0x226
[  315.150615]  [<ffffffff810dba69>] ? wake_up_process+0x10/0x12
[  315.152078]  [<ffffffff810dbaf4>] ? wake_up_q+0x89/0xa7
[  315.153539]  [<ffffffff81128b6f>] ? rwsem_wake+0x131/0x15c
[  315.155007]  [<ffffffff812922e7>] ? khugepaged+0x4072/0x484f
[  315.156471]  [<ffffffff8128e449>] khugepaged+0x1d4/0x484f
[  315.157940]  [<ffffffff8128e275>] ? hugepage_vma_revalidate+0xef/0xef
[  315.159402]  [<ffffffff810d58d1>] ? finish_task_switch+0x3de/0x484
[  315.160870]  [<ffffffff81d31df8>] ? _raw_spin_unlock_irq+0x27/0x45
[  315.162341]  [<ffffffff8111cde6>] ? trace_hardirqs_on_caller+0x3d2/0x492
[  315.163814]  [<ffffffff8111112e>] ? prepare_to_wait_event+0x3f7/0x3f7
[  315.165295]  [<ffffffff81d27ad5>] ? __schedule+0xa4d/0xd16
[  315.166763]  [<ffffffff810ccde3>] kthread+0x252/0x261
[  315.168214]  [<ffffffff8128e275>] ? hugepage_vma_revalidate+0xef/0xef
[  315.169646]  [<ffffffff810ccb91>] ? kthread_create_on_node+0x377/0x377
[  315.171056]  [<ffffffff81d3277f>] ret_from_fork+0x1f/0x40
[  315.172462]  [<ffffffff810ccb91>] ? kthread_create_on_node+0x377/0x377
[  315.173869] Code: 03 b5 60 fe ff ff e8 2e fc ff ff a8 01 74 4c 48 83 e0 fe bf 01 00 00 00 48 89 85 38 fe ff ff e8 41 18 e1 e0 48 8b 85 38 fe ff ff <f0> 0f ba 28 00 73 29 bf 01 00 00 00 41 bc f5 ff ff ff e8 ea 27 
[  315.175573] RIP  [<ffffffffa02c413d>] zs_page_migrate+0x355/0xaa0 [zsmalloc]
[  315.177084]  RSP <ffff88011246f138>
[  315.186572] ---[ end trace 0962b8ee48c98bbc ]---




[  315.186577] BUG: sleeping function called from invalid context at include/linux/sched.h:2960
[  315.186580] in_atomic(): 1, irqs_disabled(): 0, pid: 38, name: khugepaged
[  315.186581] INFO: lockdep is turned off.
[  315.186583] Preemption disabled at:[<ffffffffa02c3f1d>] zs_page_migrate+0x135/0xaa0 [zsmalloc]

[  315.186594] CPU: 3 PID: 38 Comm: khugepaged Tainted: G      D         4.7.0-rc3-next-20160614-dbg-00004-ga1c2cbc-dirty #488
[  315.186599]  0000000000000000 ffff88011246ed58 ffffffff814d56bf ffff8800bfaf2900
[  315.186604]  0000000000000004 ffff88011246ed98 ffffffff810d5e6a 0000000000000000
[  315.186609]  ffff8800bfaf2900 ffffffff81e39820 0000000000000b90 0000000000000000
[  315.186614] Call Trace:
[  315.186618]  [<ffffffff814d56bf>] dump_stack+0x68/0x92
[  315.186622]  [<ffffffff810d5e6a>] ___might_sleep+0x3bd/0x3c9
[  315.186625]  [<ffffffff810d5fd1>] __might_sleep+0x15b/0x167
[  315.186630]  [<ffffffff810ac4c1>] exit_signals+0x7a/0x34f
[  315.186633]  [<ffffffff810ac447>] ? get_signal+0xd9b/0xd9b
[  315.186636]  [<ffffffff811aee21>] ? irq_work_queue+0x101/0x11c
[  315.186640]  [<ffffffff8111f0ac>] ? debug_show_all_locks+0x226/0x226
[  315.186645]  [<ffffffff81096357>] do_exit+0x34d/0x1b4e
[  315.186648]  [<ffffffff81130e16>] ? vprintk_emit+0x4b1/0x4d3
[  315.186652]  [<ffffffff8109600a>] ? is_current_pgrp_orphaned+0x8c/0x8c
[  315.186655]  [<ffffffff81122c56>] ? lock_acquire+0xec/0x147
[  315.186658]  [<ffffffff811321ef>] ? kmsg_dump+0x12/0x27a
[  315.186662]  [<ffffffff81132448>] ? kmsg_dump+0x26b/0x27a
[  315.186666]  [<ffffffff81036507>] oops_end+0x9d/0xa4
[  315.186669]  [<ffffffff8103662c>] die+0x55/0x5e
[  315.186672]  [<ffffffff81032aa0>] do_general_protection+0x16c/0x337
[  315.186676]  [<ffffffff81d33abf>] general_protection+0x1f/0x30
[  315.186681]  [<ffffffffa02c413d>] ? zs_page_migrate+0x355/0xaa0 [zsmalloc]
[  315.186686]  [<ffffffffa02c4136>] ? zs_page_migrate+0x34e/0xaa0 [zsmalloc]
[  315.186691]  [<ffffffffa02c3de8>] ? obj_to_head+0x9d/0x9d [zsmalloc]
[  315.186695]  [<ffffffff81d31dbc>] ? _raw_spin_unlock_irqrestore+0x47/0x5c
[  315.186699]  [<ffffffff812275b1>] ? isolate_freepages_block+0x2f9/0x5a6
[  315.186702]  [<ffffffff8127f15c>] ? kasan_poison_shadow+0x2f/0x31
[  315.186706]  [<ffffffff8127f66a>] ? kasan_alloc_pages+0x39/0x3b
[  315.186709]  [<ffffffff812267e6>] ? map_pages+0x1f3/0x3ad
[  315.186712]  [<ffffffff812265f3>] ? update_pageblock_skip+0x18d/0x18d
[  315.186716]  [<ffffffff81115972>] ? up_read+0x1a/0x30
[  315.186719]  [<ffffffff8111ec7e>] ? debug_check_no_locks_freed+0x150/0x22b
[  315.186723]  [<ffffffff812842d1>] move_to_new_page+0x4dd/0x615
[  315.186726]  [<ffffffff81283df4>] ? migrate_page+0x75/0x75
[  315.186730]  [<ffffffff8122785e>] ? isolate_freepages_block+0x5a6/0x5a6
[  315.186733]  [<ffffffff812851c1>] migrate_pages+0xadd/0x131a
[  315.186737]  [<ffffffff8122785e>] ? isolate_freepages_block+0x5a6/0x5a6
[  315.186740]  [<ffffffff81226375>] ? kzfree+0x2b/0x2b
[  315.186743]  [<ffffffff812846e4>] ? buffer_migrate_page+0x2db/0x2db
[  315.186747]  [<ffffffff8122a6cf>] compact_zone+0xcdb/0x1155
[  315.186751]  [<ffffffff812299f4>] ? compaction_suitable+0x76/0x76
[  315.186754]  [<ffffffff8122ac29>] compact_zone_order+0xe0/0x167
[  315.186757]  [<ffffffff8111f0ac>] ? debug_show_all_locks+0x226/0x226
[  315.186761]  [<ffffffff8122ab49>] ? compact_zone+0x1155/0x1155
[  315.186764]  [<ffffffff810d58d1>] ? finish_task_switch+0x3de/0x484
[  315.186768]  [<ffffffff8122bcff>] try_to_compact_pages+0x2f1/0x648
[  315.186771]  [<ffffffff8122bcff>] ? try_to_compact_pages+0x2f1/0x648
[  315.186775]  [<ffffffff8122ba0e>] ? compaction_zonelist_suitable+0x3a6/0x3a6
[  315.186780]  [<ffffffff811ee129>] ? get_page_from_freelist+0x2c0/0x129a
[  315.186783]  [<ffffffff811ef1ed>] __alloc_pages_direct_compact+0xea/0x30d
[  315.186787]  [<ffffffff811ef103>] ? get_page_from_freelist+0x129a/0x129a
[  315.186791]  [<ffffffff811f0422>] __alloc_pages_nodemask+0x840/0x16b6
[  315.186794]  [<ffffffff810dba27>] ? try_to_wake_up+0x696/0x6c8
[  315.186798]  [<ffffffff811efbe2>] ? warn_alloc_failed+0x226/0x226
[  315.186801]  [<ffffffff810dba69>] ? wake_up_process+0x10/0x12
[  315.186804]  [<ffffffff810dbaf4>] ? wake_up_q+0x89/0xa7
[  315.186807]  [<ffffffff81128b6f>] ? rwsem_wake+0x131/0x15c
[  315.186811]  [<ffffffff812922e7>] ? khugepaged+0x4072/0x484f
[  315.186815]  [<ffffffff8128e449>] khugepaged+0x1d4/0x484f
[  315.186819]  [<ffffffff8128e275>] ? hugepage_vma_revalidate+0xef/0xef
[  315.186822]  [<ffffffff810d58d1>] ? finish_task_switch+0x3de/0x484
[  315.186826]  [<ffffffff81d31df8>] ? _raw_spin_unlock_irq+0x27/0x45
[  315.186829]  [<ffffffff8111cde6>] ? trace_hardirqs_on_caller+0x3d2/0x492
[  315.186832]  [<ffffffff8111112e>] ? prepare_to_wait_event+0x3f7/0x3f7
[  315.186836]  [<ffffffff81d27ad5>] ? __schedule+0xa4d/0xd16
[  315.186840]  [<ffffffff810ccde3>] kthread+0x252/0x261
[  315.186843]  [<ffffffff8128e275>] ? hugepage_vma_revalidate+0xef/0xef
[  315.186846]  [<ffffffff810ccb91>] ? kthread_create_on_node+0x377/0x377
[  315.186851]  [<ffffffff81d3277f>] ret_from_fork+0x1f/0x40
[  315.186854]  [<ffffffff810ccb91>] ? kthread_create_on_node+0x377/0x377
[  315.186869] note: khugepaged[38] exited with preempt_count 4



[  340.319852] NMI watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [jbd2/zram0-8:405]
[  340.319856] Modules linked in: lzo zram zsmalloc mousedev coretemp hwmon crc32c_intel r8169 i2c_i801 mii snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core acpi_cpufreq snd_pcm snd_timer snd soundcore lpc_ich mfd_core processor sch_fq_codel sd_mod hid_generic usbhid hid ahci libahci libata ehci_pci ehci_hcd scsi_mod usbcore usb_common
[  340.319900] irq event stamp: 834296
[  340.319902] hardirqs last  enabled at (834295): [<ffffffff81280b07>] quarantine_put+0xa1/0xe6
[  340.319911] hardirqs last disabled at (834296): [<ffffffff81d31e68>] _raw_write_lock_irqsave+0x13/0x4c
[  340.319917] softirqs last  enabled at (833836): [<ffffffff81d3455e>] __do_softirq+0x406/0x48f
[  340.319922] softirqs last disabled at (833831): [<ffffffff8109914a>] irq_exit+0x6a/0x113
[  340.319929] CPU: 2 PID: 405 Comm: jbd2/zram0-8 Tainted: G      D         4.7.0-rc3-next-20160614-dbg-00004-ga1c2cbc-dirty #488
[  340.319935] task: ffff8800bb512900 ti: ffff8800a69c0000 task.ti: ffff8800a69c0000
[  340.319937] RIP: 0010:[<ffffffff814ed772>]  [<ffffffff814ed772>] delay_tsc+0x0/0xa4
[  340.319943] RSP: 0018:ffff8800a69c70f8  EFLAGS: 00000206
[  340.319945] RAX: 0000000000000001 RBX: ffff8800aa91f300 RCX: 0000000000000000
[  340.319947] RDX: 0000000000000003 RSI: ffffffff81ed2840 RDI: 0000000000000001
[  340.319949] RBP: ffff8800a69c7100 R08: 0000000000000001 R09: 0000000000000000
[  340.319951] R10: ffff8800a69c70e8 R11: 000000007e7516b9 R12: ffff8800aa91f310
[  340.319954] R13: ffff8800aa91f308 R14: 000000001f3306fa R15: 0000000000000000
[  340.319956] FS:  0000000000000000(0000) GS:ffff880113700000(0000) knlGS:0000000000000000
[  340.319959] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  340.319961] CR2: 00007fc99caba080 CR3: 00000000b9796000 CR4: 00000000000006e0
[  340.319963] Stack:
[  340.319964]  ffffffff814ed89c ffff8800a69c7148 ffffffff8112795d ffffed0015523e60
[  340.319970]  000000009e857390 ffff8800aa91f300 ffff8800bbe21cc0 ffff8800047d6f80
[  340.319975]  ffff8800a69c72b0 ffff8800aa91f300 ffff8800a69c7168 ffffffff81d31bed
[  340.319980] Call Trace:
[  340.319983]  [<ffffffff814ed89c>] ? __delay+0xa/0xc
[  340.319988]  [<ffffffff8112795d>] do_raw_spin_lock+0x197/0x257
[  340.319991]  [<ffffffff81d31bed>] _raw_spin_lock+0x35/0x3c
[  340.319998]  [<ffffffffa02c6062>] ? zs_free+0x191/0x27a [zsmalloc]
[  340.320003]  [<ffffffffa02c6062>] zs_free+0x191/0x27a [zsmalloc]
[  340.320008]  [<ffffffffa02c5ed1>] ? free_zspage+0xe8/0xe8 [zsmalloc]
[  340.320012]  [<ffffffff810d58d1>] ? finish_task_switch+0x3de/0x484
[  340.320015]  [<ffffffff810d58a6>] ? finish_task_switch+0x3b3/0x484
[  340.320021]  [<ffffffff81d27ad5>] ? __schedule+0xa4d/0xd16
[  340.320024]  [<ffffffff81d28086>] ? preempt_schedule+0x1f/0x21
[  340.320028]  [<ffffffff81d27ff9>] ? preempt_schedule_common+0xb7/0xe8
[  340.320034]  [<ffffffffa02d3f0e>] zram_free_page+0x112/0x1f6 [zram]
[  340.320039]  [<ffffffffa02d5e6c>] zram_make_request+0x45d/0x89f [zram]
[  340.320045]  [<ffffffffa02d5a0f>] ? zram_rw_page+0x21d/0x21d [zram]
[  340.320048]  [<ffffffff81493657>] ? blk_exit_rl+0x39/0x39
[  340.320053]  [<ffffffff8148fe3f>] ? handle_bad_sector+0x192/0x192
[  340.320056]  [<ffffffff8127f83e>] ? kasan_slab_alloc+0x12/0x14
[  340.320059]  [<ffffffff8127ca68>] ? kmem_cache_alloc+0xf3/0x101
[  340.320062]  [<ffffffff81494e37>] generic_make_request+0x2bc/0x496
[  340.320066]  [<ffffffff81494b7b>] ? blk_plug_queued_count+0x103/0x103
[  340.320069]  [<ffffffff8111ec7e>] ? debug_check_no_locks_freed+0x150/0x22b
[  340.320072]  [<ffffffff81495309>] submit_bio+0x2f8/0x324
[  340.320075]  [<ffffffff81495011>] ? generic_make_request+0x496/0x496
[  340.320078]  [<ffffffff811190fc>] ? lockdep_init_map+0x1ef/0x4b0
[  340.320082]  [<ffffffff814880a4>] submit_bio_wait+0xff/0x138
[  340.320085]  [<ffffffff81487fa5>] ? bio_add_page+0x292/0x292
[  340.320090]  [<ffffffff814ab82c>] blkdev_issue_discard+0xee/0x148
[  340.320093]  [<ffffffff814ab73e>] ? __blkdev_issue_discard+0x399/0x399
[  340.320097]  [<ffffffff8111f0ac>] ? debug_show_all_locks+0x226/0x226
[  340.320101]  [<ffffffff81404de8>] ext4_free_data_callback+0x2cc/0x8bc
[  340.320104]  [<ffffffff81404de8>] ? ext4_free_data_callback+0x2cc/0x8bc
[  340.320107]  [<ffffffff81404b1c>] ? ext4_mb_release_context+0x10aa/0x10aa
[  340.320111]  [<ffffffff81122c56>] ? lock_acquire+0xec/0x147
[  340.320115]  [<ffffffff813c8a6a>] ? ext4_journal_commit_callback+0x203/0x220
[  340.320119]  [<ffffffff813c8a61>] ext4_journal_commit_callback+0x1fa/0x220
[  340.320124]  [<ffffffff81438bf5>] jbd2_journal_commit_transaction+0x3753/0x3c20
[  340.320128]  [<ffffffff814354a2>] ? journal_submit_commit_record+0x777/0x777
[  340.320132]  [<ffffffff8111f0ac>] ? debug_show_all_locks+0x226/0x226
[  340.320135]  [<ffffffff811205a5>] ? __lock_acquire+0x14f9/0x33b8
[  340.320139]  [<ffffffff81d31db0>] ? _raw_spin_unlock_irqrestore+0x3b/0x5c
[  340.320143]  [<ffffffff8111cde6>] ? trace_hardirqs_on_caller+0x3d2/0x492
[  340.320146]  [<ffffffff81d31dbc>] ? _raw_spin_unlock_irqrestore+0x47/0x5c
[  340.320151]  [<ffffffff81156945>] ? try_to_del_timer_sync+0xa5/0xce
[  340.320154]  [<ffffffff8111cde6>] ? trace_hardirqs_on_caller+0x3d2/0x492
[  340.320157]  [<ffffffff8143febd>] kjournald2+0x246/0x6e1
[  340.320160]  [<ffffffff8143febd>] ? kjournald2+0x246/0x6e1
[  340.320163]  [<ffffffff8143fc77>] ? commit_timeout+0xb/0xb
[  340.320167]  [<ffffffff8111112e>] ? prepare_to_wait_event+0x3f7/0x3f7
[  340.320171]  [<ffffffff810ccde3>] kthread+0x252/0x261
[  340.320174]  [<ffffffff8143fc77>] ? commit_timeout+0xb/0xb
[  340.320177]  [<ffffffff810ccb91>] ? kthread_create_on_node+0x377/0x377
[  340.320181]  [<ffffffff81d3277f>] ret_from_fork+0x1f/0x40
[  340.320185]  [<ffffffff810ccb91>] ? kthread_create_on_node+0x377/0x377
[  340.320186] Code: 5c 5d c3 55 48 8d 04 bd 00 00 00 00 65 48 8b 15 8d 59 b2 7e 48 69 d2 fa 00 00 00 48 89 e5 f7 e2 48 8d 7a 01 e8 22 01 00 00 5d c3 <55> 48 89 e5 41 56 41 55 41 54 53 49 89 fd bf 01 00 00 00 e8 ed 

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
