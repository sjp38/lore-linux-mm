Date: Wed, 16 Jun 2004 13:16:31 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH]: Option to run cache reap in thread mode
Message-ID: <20040616181631.GE6069@sgi.com>
References: <27JKg-4ht-11@gated-at.bofh.it> <m3r7sfmq0r.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m3r7sfmq0r.fsf@averell.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Manfred Spraul <manfred@colorfullife.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2004 at 06:22:28PM +0200, Andi Kleen wrote:
> Dimitri Sivanich <sivanich@sgi.com> writes:
> 
> > I would like to know what others think about running cache_reap() as a low
> > priority realtime kthread, at least on certain cpus that would be configured
> > that way (probably configured at boottime initially).  I've been doing some
> > testing running it this way on CPU's whose activity is mostly restricted to
> > realtime work (requiring rapid response times).
> >
> > Here's my first cut at an initial patch for this (there will be other changes
> > later to set the configuration and to optimize locking in cache_reap()).
> 
> I would run it in the standard work queue threads. We already have 
> too many kernel threads, no need to add more.
> 
> Also is there really a need for it to be real time? 

Not especially.  Normal time sharing would be OK with me, but I'd like to
emphasize that if it is real time, it would need to be lowest priority.

> Note that we don't make any attempt at all in the linux kernel to handle
> lock priority inversion, so this isn't an argument.
> 
> -Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
