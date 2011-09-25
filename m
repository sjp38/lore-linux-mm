Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C7E9B9000BD
	for <linux-mm@kvack.org>; Sun, 25 Sep 2011 01:23:30 -0400 (EDT)
Subject: Re: [RFC][PATCH] slab: fix caller tracking onCONFIG_OPTIMIZE_INLINING.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201109241208.IEH26037.FtSVLJOOQHMFFO@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.00.1109241550230.14043@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1109241550230.14043@chino.kir.corp.google.com>
Message-Id: <201109251421.BEB71358.OFOHJVMFQOFLtS@I-love.SAKURA.ne.jp>
Date: Sun, 25 Sep 2011 14:21:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, vegard.nossum@gmail.com, dmonakhov@openvz.org, catalin.marinas@arm.com, dfeng@redhat.com, linux-mm@kvack.org

David Rientjes wrote:
> On Sat, 24 Sep 2011, Tetsuo Handa wrote:
> 
> > If CONFIG_OPTIMIZE_INLINING=y, /proc/slab_allocators shows entries like
> > 
> >   size-512: 5 kzalloc+0xb/0x10
> >   size-256: 31 kzalloc+0xb/0x10
> > 
> > which are useless for debugging.
> 
> This is only an issue for gcc 4.x compilers, correct?

Yes.

> So this is going against the inlining algorithms in gcc 4.x which will 
> make the kernel image significantly larger even though there seems to be 
> no benefit unless you have CONFIG_DEBUG_SLAB_LEAK, although this patch 
> changes behavior for every system running CONFIG_SLAB with tracing 
> support.

If use of address of kzalloc() itself is fine for tracing functionality, we
don't need to force tracing functionality to use caller address of kzalloc().

I merely want /proc/slab_allocators to print caller address of kzalloc() rather
than kzalloc() address itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
