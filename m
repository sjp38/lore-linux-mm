Date: Wed, 19 Dec 2007 23:04:33 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 02/20] make the inode i_mmap_lock a reader/writer lock
In-Reply-To: <200712201040.29040.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0712192301120.13118@schroedinger.engr.sgi.com>
References: <20071218211539.250334036@redhat.com> <1198083218.5333.48.camel@localhost>
 <1198092503.6484.21.camel@twins> <200712201040.29040.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Peter Zijlstra <peterz@infradead.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


> The only reason the x86 ticket locks have the 256 CPu limit is that
> if they go any bigger, we can't use the partial registers so would
> have to have a few more instructions.

x86_64 is going up to 4k or 16k cpus soon for our new hardware.

> A 32 bit spinlock would allow 64K cpus (ticket lock has 2 counters,
> each would be 16 bits). And it would actually shrink the spinlock in
> the case of preempt kernels too (because it would no longer have the
> lockbreak field).
> 
> And yes, I'll go out on a limb and say that 64k CPUs ought to be
> enough for anyone ;)

I think those things need a timeframe applied to it. Thats likely 
going to be true for the next 3 years (optimistic assessment ;-)).

Could you go to 32bit spinlock by default?

How about NUMA awareness for the spinlocks? Larger backoff periods for 
off node lock contentions please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
