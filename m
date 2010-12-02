Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AC9218D000E
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 00:07:29 -0500 (EST)
Date: Thu, 2 Dec 2010 00:07:26 -0500 (EST)
From: caiqian@redhat.com
Message-ID: <373935679.1026851291266446567.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1043135380.1026761291266384009.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: oom is broken in mmotm 2010-11-09-15-31 tree?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


> [  580.192024]          kswapd0    33     49939.236793      5021   120
>     49939.236793     39855.128906    456899.562827 /
Follow-up on this, kswapd0 was doing this from SysRq-T output,

[ 2836.085008] kswapd0       R  running task        0    33      2 0x00000000
[ 2836.085008]  ffff8802276f9b10 0000000000000046 0000000000000000 ffffffff8100a84e
[ 2836.085008]  00000000000136c0 00000000000136c0 00000000000136c0 ffff88022b70c590
[ 2836.085008]  00000000000136c0 ffff8802276f9fd8 00000000000136c0 00000000000136c0
[ 2836.085008] Call Trace:
[ 2836.085008]  [<ffffffff8100a84e>] ? call_function_interrupt+0xe/0x20
[ 2836.085008]  [<ffffffff81114594>] ? mem_cgroup_del_lru_list+0x42/0x76
[ 2836.085008]  [<ffffffff8104a437>] __cond_resched+0x2a/0x35
[ 2836.085008]  [<ffffffff8146503c>] _cond_resched+0x1b/0x22
[ 2836.085008]  [<ffffffff810e03c7>] shrink_page_list+0x53/0x469
[ 2836.085008]  [<ffffffff810df7ba>] ? update_isolated_counts.clone.27+0x13d/0x15b
[ 2836.085008]  [<ffffffff810e0bcf>] shrink_inactive_list+0x22b/0x376
[ 2836.085008]  [<ffffffff810db07c>] ? determine_dirtyable_memory+0x1d/0x26
[ 2836.085008]  [<ffffffff810e12eb>] shrink_zone+0x32e/0x3ca
[ 2836.085008]  [<ffffffff814665ae>] ? _raw_spin_lock+0xe/0x10
[ 2836.085008]  [<ffffffff810e1e5d>] balance_pgdat+0x242/0x417
[ 2836.085008]  [<ffffffff810e2258>] kswapd+0x226/0x23c
[ 2836.085008]  [<ffffffff81069c8b>] ? autoremove_wake_function+0x0/0x39
[ 2836.085008]  [<ffffffff81466617>] ? _raw_spin_unlock_irqrestore+0x17/0x19
[ 2836.085008]  [<ffffffff810e2032>] ? kswapd+0x0/0x23c
[ 2836.085008]  [<ffffffff810697da>] kthread+0x82/0x8a
[ 2836.085008]  [<ffffffff8100aae4>] kernel_thread_helper+0x4/0x10
[ 2836.085008]  [<ffffffff81069758>] ? kthread+0x0/0x8a
[ 2836.085008]  [<ffffffff8100aae0>] ? kernel_thread_helper+0x0/0x10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
