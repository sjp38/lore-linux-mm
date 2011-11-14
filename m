Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3C96B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 00:40:45 -0500 (EST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Mon, 14 Nov 2011 05:38:23 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAE5e4gN2850938
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 16:40:11 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAE5e3bL011158
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 16:40:03 +1100
Message-ID: <4EC0A9B3.7020201@linux.vnet.ibm.com>
Date: Mon, 14 Nov 2011 11:10:03 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: khugepaged cannot be freezed on 3.2-rc1
References: <1321195355.2020.10.camel@localhost.localdomain>
In-Reply-To: <1321195355.2020.10.camel@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maciej Marcin Piechotka <uzytkownik2@gmail.com>
Cc: linux-mm@kvack.org, Linux PM mailing list <linux-pm@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Tejun Heo <tj@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On 11/13/2011 08:12 PM, Maciej Marcin Piechotka wrote:
> I am sorry if I've sent to wrong address. It seems that bug reporting
> resources - bugzilla & "Reporting bugs for the Linux kernel" page - are
> (still?) down. I followed the latter from web archive).
>

Adding linux-pm mailing list to CC.
Andrea Arcangeli has written a patch to solve khugepaged freezing issue.
https://lkml.org/lkml/2011/11/9/312

Can you check if that patch solves the issue for you too?

Thanks,
Srivatsa S. Bhat

> When I try to suspend the computer the khugepaged refuses to be
> suspended:
> 
> [10531.788922] PM: Syncing filesystems ... done.
> [10532.617226] Freezing user space processes ... (elapsed 0.01 seconds)
> done.
> [10532.629073] Freezing remaining freezable tasks ... 
> [10552.638137] Freezing of tasks failed after 20.00 seconds (1 tasks
> refusing to freeze, wq_busy=0):
> [10552.638155] khugepaged      R  running task        0    21      2
> 0x00800000
> [10552.638159]  ffffea000072c740 000000000000ce01 ffffffff81093f56
> ffffffff8166f680
> [10552.638163]  ffffffff8102bbd0 0000000000000001 ffffffff8102bc65
> ffffea000072c140
> [10552.638166]  ffffea000072c1c0 ffffea000072c180 ffffffff8108cbc1
> ffffea000032b700
> [10552.638170] Call Trace:
> [10552.638177]  [<ffffffff81093f56>] ? vma_prio_tree_next+0x3c/0xd5
> [10552.638181]  [<ffffffff810a2798>] ? try_to_unmap_file+0x4a7/0x4bd
> [10552.638184]  [<ffffffff8108cbc1>] ? ____pagevec_lru_add_fn+0x58/0x9a
> [10552.638188]  [<ffffffff810ad11d>] ? compaction_alloc+0x132/0x24f
> [10552.638191]  [<ffffffff810b26f8>] ? migrate_pages+0xa6/0x335
> [10552.638194]  [<ffffffff810acfeb>] ? pfn_valid.part.3+0x32/0x32
> [10552.638197]  [<ffffffff810ad6b2>] ? compact_zone+0x3f4/0x5c3
> [10552.638200]  [<ffffffff810ad9a2>] ? try_to_compact_pages+0x121/0x17e
> [10552.638203]  [<ffffffff8108a2f1>] ? __alloc_pages_direct_compact
> +0xaa/0x197
> [10552.638206]  [<ffffffff8108aa44>] ? __alloc_pages_nodemask
> +0x666/0x6c7
> [10552.638210]  [<ffffffff8102bbd0>] ? get_parent_ip+0x9/0x1b
> [10552.638214]  [<ffffffff81348964>] ? _raw_spin_lock_irqsave+0x13/0x34
> [10552.638217]  [<ffffffff810b2e12>] ? khugepaged_alloc_hugepage
> +0x4c/0xdb
> [10552.638220]  [<ffffffff81047ab9>] ? add_wait_queue+0x3c/0x3c
> [10552.638222]  [<ffffffff810b33fd>] ? khugepaged+0x7c/0xe04
> [10552.638225]  [<ffffffff81047ab9>] ? add_wait_queue+0x3c/0x3c
> [10552.638228]  [<ffffffff810b3381>] ? add_mm_counter.constprop.50
> +0x9/0x9
> [10552.638230]  [<ffffffff810474ee>] ? kthread+0x76/0x7e
> [10552.638233]  [<ffffffff8134b274>] ? kernel_thread_helper+0x4/0x10
> [10552.638236]  [<ffffffff81047478>] ? kthread_worker_fn+0x139/0x139
> [10552.638238]  [<ffffffff8134b270>] ? gs_change+0xb/0xb
> [10552.638347] 
> [10552.638348] Restarting tasks ... done.
> 
> Regards
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
