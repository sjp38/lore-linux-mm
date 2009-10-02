Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B10986B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 01:13:15 -0400 (EDT)
From: Neil Brown <neilb@suse.de>
Date: Fri, 2 Oct 2009 15:20:34 +1000
Message-ID: <19141.36258.926599.862333@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 01/31] mm: serialize access to min_free_kbytes
In-Reply-To: message from David Rientjes on Thursday October 1
References: <1254405871-15687-1-git-send-email-sjayaraman@suse.de>
	<alpine.DEB.1.00.0910011330430.27559@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Suresh Jayaraman <sjayaraman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thursday October 1, rientjes@google.com wrote:
> On Thu, 1 Oct 2009, Suresh Jayaraman wrote:
> 
> > From: Peter Zijlstra <a.p.zijlstra@chello.nl> 
> > 
> > There is a small race between the procfs caller and the memory hotplug caller
> > of setup_per_zone_wmarks(). Not a big deal, but the next patch will add yet
> > another caller. Time to close the gap.
> > 
> 
> By "next patch," you mean "mm: emegency pool" (patch 08/31)?

:-)  It is always safer to say "a subsequent patch", isn't it....

> 
> If so, can't you eliminate var_free_mutex entirely from that patch and 
> take min_free_lock in adjust_memalloc_reserve() instead?

adjust_memalloc_reserve does a test alloc/free cycle under a lock.
That cannot be done under a spin-lock, it must be a mutex.
So I don't think you can eliminate var_free_mutex.

Thanks,
NeilBrown

> 
>  [ __adjust_memalloc_reserve() would call __setup_per_zone_wmarks()
>    under lock instead, now. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
