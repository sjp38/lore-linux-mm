Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4A16E6B004D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 14:38:10 -0400 (EDT)
Date: Mon, 16 Mar 2009 19:37:50 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090316183750.GB20555@random.random>
References: <1237007189.25062.91.camel@pasglop> <200903170419.38988.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903161034030.3675@localhost.localdomain> <200903170502.57217.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903161111090.3675@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903161111090.3675@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 11:14:59AM -0700, Linus Torvalds wrote:
> You may think that the lock isn't particularly "elegant", but I can only 
> say "f*ck that, look at the number of lines of code, and the simplicity".

I'm sorry but the number of lines that you're reading in the
direct_io_worker patch, aren't representative of what it takes to fix
it with a mm wide lock. It may be conceptually simpler to fix it
outside GUP, on that I can certainly agree (with the downside of
leaving splice broken etc..), but I can't see how that small patch can
fix anything as releasing the semaphore after direct_io_worker returns
with O_DIRECT mixed with async-io. Before claiming that the outer lock
results in less number of lines of code, I'd wait to see a fix that
works with O_DIRECT+async-io too as well as mine and Nick's do.

> Your "elegant" argument is total and utter sh*t, in other words. The lock 
> approach is tons more elegant, considering that it solves the problem much 
> more cleanly, and with _much_ less crap.

I guess elegant is relative, but the size argument is objective, and
that should be possible to compare if somebody writes a full fix that
doesn't fall apart if return value of direct_io_worker is -EIOCBQUEUED.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
