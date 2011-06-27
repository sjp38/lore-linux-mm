Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDFB6B01F6
	for <linux-mm@kvack.org>; Sun, 26 Jun 2011 22:56:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 474893EE0AE
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 11:56:53 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C22245DEA0
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 11:56:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1492845DE9C
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 11:56:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 095E51DB803B
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 11:56:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B99951DB8038
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 11:56:52 +0900 (JST)
Date: Mon, 27 Jun 2011 11:49:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2011-06-22-13-05 uploaded
Message-Id: <20110627114939.a941b9eb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <201106222042.p5MKgiEe025352@imap1.linux-foundation.org>
References: <201106222042.p5MKgiEe025352@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, 22 Jun 2011 13:05:19 -0700
akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2011-06-22-13-05 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
>    git://zen-kernel.org/kernel/mmotm.git
> or
>    git://git.cmpxchg.org/linux-mmotm.git
> 
> It contains the following patches against 3.0-rc4:
> 

It may be too late but this was reported on KVM guest.

==
[  490.359961]
[  490.360944] =================================
[  490.360944] [ INFO: inconsistent lock state ]
[  490.360944] 3.0.0-rc4-mm1 #1
[  490.360944] ---------------------------------
[  490.360944] inconsistent {HARDIRQ-ON-W} -> {IN-HARDIRQ-W} usage.
[  490.360944] kworker/0:0/0 [HC1[1]:SC0[0]:HE0:SE1] takes:
[  490.360944]  (&(&mapping->tree_lock)->rlock){?.+...}, at: [<ffffffff8110cbea>                  ] test_clear_page_writeback+0x6a/0x160
[  490.360944] {HARDIRQ-ON-W} state was registered at:
[  490.360944]   [<ffffffff81097069>] __lock_acquire+0x609/0x1670
[  490.360944]   [<ffffffff81098754>] lock_acquire+0xa4/0x120
[  490.360944]   [<ffffffff8159e396>] _raw_spin_lock+0x36/0x70
[  490.360944]   [<ffffffff8117d7e6>] end_writeback+0x36/0xd0
[  490.360944]   [<ffffffff8117d982>] evict+0x102/0x180
[  490.360944]   [<ffffffff8117ddda>] iput+0xea/0x1c0
[  490.360944]   [<ffffffff81172d2c>] do_unlinkat+0x16c/0x1d0
[  490.360944]   [<ffffffff81172da6>] sys_unlink+0x16/0x20
[  490.360944]   [<ffffffff815a6fc2>] system_call_fastpath+0x16/0x1b
[  490.360944] irq event stamp: 85616
[  490.360944] hardirqs last  enabled at (85613): [<ffffffff810140a1>] default_i                  dle+0x61/0x190
[  490.360944] hardirqs last disabled at (85614): [<ffffffff8159efea>] save_args                  +0x6a/0x70
[  490.360944] softirqs last  enabled at (85616): [<ffffffff8105fc83>] _local_bh                  _enable+0x13/0x20
[  490.360944] softirqs last disabled at (85615): [<ffffffff8105fd05>] irq_enter                  +0x75/0x90
[  490.360944]
[  490.360944] other info that might help us debug this:
[  490.360944]  Possible unsafe locking scenario:
[  490.360944]
[  490.360944]        CPU0
[  490.360944]        ----
[  490.360944]   lock(&(&mapping->tree_lock)->rlock);
[  490.360944]   <Interrupt>
[  490.360944]     lock(&(&mapping->tree_lock)->rlock);
[  490.360944]
[  490.360944]  *** DEADLOCK ***
[  490.360944]
[  490.360944] 1 lock held by kworker/0:0/0:
[  490.360944]  #0:  (&(&vblk->lock)->rlock){-.-...}, at: [<ffffffffa000f1ab>] blk_done+0x2b/0x120 [virtio_blk]
[  490.360944]
[  490.360944] stack backtrace:
[  490.360944] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-rc4-mm1 #1
[  490.360944] Call Trace:
[  490.360944]  <IRQ>  [<ffffffff810957f5>] print_usage_bug+0x235/0x280
[  490.360944]  [<ffffffff810962d6>] mark_lock+0x346/0x410
[  490.360944]  [<ffffffff810971f9>] __lock_acquire+0x799/0x1670
[  490.360944]  [<ffffffff81032059>] ? kvm_clock_read+0x19/0x20
[  490.360944]  [<ffffffff81032dc8>] ? pvclock_clocksource_read+0x58/0xd0
[  490.360944]  [<ffffffff81032dc8>] ? pvclock_clocksource_read+0x58/0xd0
[  490.360944]  [<ffffffff81085135>] ? sched_clock_local+0x25/0x90
[  490.360944]  [<ffffffff8110cbea>] ? test_clear_page_writeback+0x6a/0x160
[  490.360944]  [<ffffffff81098754>] lock_acquire+0xa4/0x120
[  490.360944]  [<ffffffff8110cbea>] ? test_clear_page_writeback+0x6a/0x160
[  490.360944]  [<ffffffff81085135>] ? sched_clock_local+0x25/0x90
[  490.360944]  [<ffffffff8159e545>] _raw_spin_lock_irqsave+0x55/0xa0
[  490.360944]  [<ffffffff8110cbea>] ? test_clear_page_writeback+0x6a/0x160
[  490.360944]  [<ffffffff81096cab>] ? __lock_acquire+0x24b/0x1670
[  490.360944]  [<ffffffff8110cbea>] test_clear_page_writeback+0x6a/0x160
[  490.360944]  [<ffffffff811012c4>] end_page_writeback+0x24/0x60
[  490.360944]  [<ffffffff81193dca>] end_buffer_async_write+0x13a/0x220
[  490.360944]  [<ffffffff81085258>] ? sched_clock_cpu+0xb8/0x110
[  490.360944]  [<ffffffff811922c0>] end_bio_bh_io_sync+0x30/0x50
[  490.360944]  [<ffffffff811969ad>] bio_endio+0x1d/0x40
[  490.360944]  [<ffffffff812a73a3>] req_bio_endio+0xa3/0xe0
[  490.360944]  [<ffffffff812a8294>] blk_update_request+0x104/0x4e0
[  490.360944]  [<ffffffff812a84e1>] ? blk_update_request+0x351/0x4e0
[  490.360944]  [<ffffffff8109244d>] ? trace_hardirqs_off+0xd/0x10
[  490.360944]  [<ffffffff812a8697>] blk_update_bidi_request+0x27/0xb0
[  490.360944]  [<ffffffff812a99ee>] __blk_end_request_all+0x2e/0x60
[  490.360944]  [<ffffffffa000f1cb>] blk_done+0x4b/0x120 [virtio_blk]
[  490.360944]  [<ffffffffa00052fc>] vring_interrupt+0x3c/0xb0 [virtio_ring]
[  490.360944]  [<ffffffff810c6f3d>] handle_irq_event_percpu+0x5d/0x210
[  490.360944]  [<ffffffff810c713e>] handle_irq_event+0x4e/0x80
[  490.360944]  [<ffffffff810ca213>] handle_edge_irq+0x83/0x140
[  490.360944]  [<ffffffff8100d40c>] handle_irq+0x4c/0xa0
[  490.360944]  [<ffffffff815a8acd>] do_IRQ+0x5d/0xe0
[  490.360944]  [<ffffffff8159f093>] common_interrupt+0x13/0x13
[  490.360944]  <EOI>  [<ffffffff810320bb>] ? native_safe_halt+0xb/0x10
[  490.360944]  [<ffffffff8109677d>] ? trace_hardirqs_on+0xd/0x10
[  490.360944]  [<ffffffff810140a6>] default_idle+0x66/0x190
[  490.360944]  [<ffffffff8100b0ac>] cpu_idle+0xbc/0x110
[  490.360944]  [<ffffffff815950ca>] start_secondary+0x256/0x258
[  OK  ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
