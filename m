Subject: Re: [PATCH 11/30] mm: __GFP_MEMALLOC
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080725180305.86A9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.060638861@chello.nl>
	 <20080725180305.86A9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 25 Jul 2008 11:35:35 +0200
Message-Id: <1216978535.7257.356.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-07-25 at 18:29 +0900, KOSAKI Motohiro wrote:
> Hi Peter,
> 
> > __GFP_MEMALLOC will allow the allocation to disregard the watermarks, 
> > much like PF_MEMALLOC.
> > 
> > It allows one to pass along the memalloc state in object related allocation
> > flags as opposed to task related flags, such as sk->sk_allocation.
> 
> Is this properly name?
> page alloc is always "mem alloc".
> 
> you wrote comment as "Use emergency reserves" and 
> this flag works to turn on ALLOC_NO_WATERMARKS.
> 
> then, __GFP_NO_WATERMARK or __GFP_EMERGENCY are better?

We've been through this pick a better name thing several times :-/

Yes I agree, __GFP_MEMALLOC is a misnomer, however its consistent with
PF_MEMALLOC and __GFP_NOMEMALLOC - of which people know the semantics.

Creating a new name with similar semantics can only serve to confuse.

So unless enough people think its worth renaming all of them, I think
we're better off with this name.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
