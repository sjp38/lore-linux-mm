Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0AC6B002D
	for <linux-mm@kvack.org>; Sun, 13 Nov 2011 09:43:02 -0500 (EST)
Received: by wwf10 with SMTP id 10so3884778wwf.26
        for <linux-mm@kvack.org>; Sun, 13 Nov 2011 06:42:59 -0800 (PST)
Message-ID: <1321195355.2020.10.camel@localhost.localdomain>
Subject: khugepaged cannot be freezed on 3.2-rc1
From: Maciej Marcin Piechotka <uzytkownik2@gmail.com>
Date: Sun, 13 Nov 2011 14:42:35 +0000
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I am sorry if I've sent to wrong address. It seems that bug reporting
resources - bugzilla & "Reporting bugs for the Linux kernel" page - are
(still?) down. I followed the latter from web archive).

When I try to suspend the computer the khugepaged refuses to be
suspended:

[10531.788922] PM: Syncing filesystems ... done.
[10532.617226] Freezing user space processes ... (elapsed 0.01 seconds)
done.
[10532.629073] Freezing remaining freezable tasks ... 
[10552.638137] Freezing of tasks failed after 20.00 seconds (1 tasks
refusing to freeze, wq_busy=0):
[10552.638155] khugepaged      R  running task        0    21      2
0x00800000
[10552.638159]  ffffea000072c740 000000000000ce01 ffffffff81093f56
ffffffff8166f680
[10552.638163]  ffffffff8102bbd0 0000000000000001 ffffffff8102bc65
ffffea000072c140
[10552.638166]  ffffea000072c1c0 ffffea000072c180 ffffffff8108cbc1
ffffea000032b700
[10552.638170] Call Trace:
[10552.638177]  [<ffffffff81093f56>] ? vma_prio_tree_next+0x3c/0xd5
[10552.638181]  [<ffffffff810a2798>] ? try_to_unmap_file+0x4a7/0x4bd
[10552.638184]  [<ffffffff8108cbc1>] ? ____pagevec_lru_add_fn+0x58/0x9a
[10552.638188]  [<ffffffff810ad11d>] ? compaction_alloc+0x132/0x24f
[10552.638191]  [<ffffffff810b26f8>] ? migrate_pages+0xa6/0x335
[10552.638194]  [<ffffffff810acfeb>] ? pfn_valid.part.3+0x32/0x32
[10552.638197]  [<ffffffff810ad6b2>] ? compact_zone+0x3f4/0x5c3
[10552.638200]  [<ffffffff810ad9a2>] ? try_to_compact_pages+0x121/0x17e
[10552.638203]  [<ffffffff8108a2f1>] ? __alloc_pages_direct_compact
+0xaa/0x197
[10552.638206]  [<ffffffff8108aa44>] ? __alloc_pages_nodemask
+0x666/0x6c7
[10552.638210]  [<ffffffff8102bbd0>] ? get_parent_ip+0x9/0x1b
[10552.638214]  [<ffffffff81348964>] ? _raw_spin_lock_irqsave+0x13/0x34
[10552.638217]  [<ffffffff810b2e12>] ? khugepaged_alloc_hugepage
+0x4c/0xdb
[10552.638220]  [<ffffffff81047ab9>] ? add_wait_queue+0x3c/0x3c
[10552.638222]  [<ffffffff810b33fd>] ? khugepaged+0x7c/0xe04
[10552.638225]  [<ffffffff81047ab9>] ? add_wait_queue+0x3c/0x3c
[10552.638228]  [<ffffffff810b3381>] ? add_mm_counter.constprop.50
+0x9/0x9
[10552.638230]  [<ffffffff810474ee>] ? kthread+0x76/0x7e
[10552.638233]  [<ffffffff8134b274>] ? kernel_thread_helper+0x4/0x10
[10552.638236]  [<ffffffff81047478>] ? kthread_worker_fn+0x139/0x139
[10552.638238]  [<ffffffff8134b270>] ? gs_change+0xb/0xb
[10552.638347] 
[10552.638348] Restarting tasks ... done.

Regards

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
