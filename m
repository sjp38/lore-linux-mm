Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9R84l0O014839
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 27 Oct 2008 17:04:47 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EA1EC1B801F
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 17:04:46 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C0BCC2DC015
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 17:04:46 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C14D1DB803F
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 17:04:46 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 57C371DB803C
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 17:04:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
In-Reply-To: <1225094190.16159.3.camel@twins>
References: <20081027120405.1B45.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1225094190.16159.3.camel@twins>
Message-Id: <20081027170156.9659.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 27 Oct 2008 17:03:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Gautham Shenoy <ego@in.ibm.com>, Oleg Nesterov <oleg@tv-sign.ru>, Rusty Russell <rusty@rustcorp.com.au>, mpm <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

> On Mon, 2008-10-27 at 12:14 +0900, KOSAKI Motohiro wrote:
> > > Right, and would be about 4k+sizeof(task_struct), some people might be
> > > bothered, but most won't care.
> > > 
> > > > Perhaps, I misunderstand your intension. so can you point your
> > > > previous discussion url?
> > > 
> > > my google skillz fail me, but once in a while people complain that we
> > > have too many kernel threads.
> > > 
> > > Anyway, if we can re-use this per-cpu workqueue for more goals, I guess
> > > there is even less of an objection.
> > 
> > In general, you are right.
> > but this is special case. mmap_sem is really widely used various subsystem and drivers.
> > (because page fault via copy_user introduce to depend on mmap_sem)
> > 
> > Then, any work-queue reu-sing can cause similar dead-lock easily.
> 
> Yeah, I know, and the cpu-hotplug discussion needed another thread due
> to yet another locking incident. I was hoping these two could go
> together.

Yeah, I found its thread. (I think it is "work_on_cpu: helper for doing task on a CPU.", right?)
So I'll read it soon.

Please wait a bit.


> 
> Neither are general-purpose workqueues, both need to stay away from the
> normal eventd due to deadlocks.
> 
> ego, does you extra thread ever use mmap_sem?





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
