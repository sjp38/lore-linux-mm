Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9V3LIiO001411
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 31 Oct 2008 12:21:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C694B2AC02C
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 12:21:18 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BDBD12C044
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 12:21:18 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EFBA1DB8048
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 12:21:18 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id E98131DB8040
	for <linux-mm@kvack.org>; Fri, 31 Oct 2008 12:21:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: 2.6.28-rc2-mm1: possible circular locking
In-Reply-To: <20081029135840.0a50e19c.akpm@linux-foundation.org>
References: <200810292146.03967.m.kozlowski@tuxland.pl> <20081029135840.0a50e19c.akpm@linux-foundation.org>
Message-Id: <20081031121827.AACB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 31 Oct 2008 12:21:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mariusz Kozlowski <m.kozlowski@tuxland.pl>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > stack backtrace:
> > Pid: 4733, comm: psi Not tainted 2.6.28-rc2-mm1 #1
> > Call Trace:
> >  [<c013a0fd>] print_circular_bug_tail+0x78/0xb5
> >  [<c0137a31>] ? print_circular_bug_entry+0x43/0x4b
> >  [<c013a6e4>] validate_chain+0x5aa/0xfe0
> >  [<c0118465>] ? hrtick_update+0x23/0x25
> >  [<c013b388>] __lock_acquire+0x26e/0x98d
> >  [<c0118ac0>] ? default_wake_function+0xb/0xd
> >  [<c013bb03>] lock_acquire+0x5c/0x74
> >  [<c012a330>] ? flush_work+0x2d/0xcb
> >  [<c012a35c>] flush_work+0x59/0xcb
> >  [<c012a330>] ? flush_work+0x2d/0xcb
> >  [<c0139ae6>] ? trace_hardirqs_on+0xb/0xd
> >  [<c012a531>] ? __queue_work+0x26/0x2b
> >  [<c012a58c>] ? queue_work_on+0x37/0x47
> >  [<c014fda7>] ? lru_add_drain_per_cpu+0x0/0xa
> >  [<c014fda7>] ? lru_add_drain_per_cpu+0x0/0xa
> >  [<c012a7a6>] schedule_on_each_cpu+0x65/0x7f
> >  [<c014fb7e>] lru_add_drain_all+0xd/0xf
> >  [<c0157fb2>] __mlock_vma_pages_range+0x44/0x206
> >  [<c0159438>] ? vma_adjust+0x17e/0x384
> >  [<c015971f>] ? split_vma+0xe1/0xf7
> >  [<c01582d1>] mlock_fixup+0x15d/0x1c9
> >  [<c0158479>] do_mlock+0x96/0xc8
> >  [<c02bcb2a>] ? down_write+0x42/0x68
> >  [<c015860e>] sys_mlock+0xb2/0xb6
> >  [<c0102f91>] sysenter_do_call+0x12/0x35
> > 
> 
> This is similar to the problem which
> mm-move-migrate_prep-out-from-under-mmap_sem.patch was supposed to fix.
> 
> We've been calling schedule_on_each_cpu() from within
> lru_add_drain_all() for ages.  What changed to cause all this
> to start happening?

Agreed with there are the same problem.
please assign this bug to me.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
