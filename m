Date: Wed, 16 Jun 2004 11:51:55 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH]: Option to run cache reap in thread mode
Message-ID: <20040616165155.GA6069@sgi.com>
References: <20040616142413.GA5588@sgi.com> <20040616160355.GA5963@sgi.com> <20040616160714.GA14413@infradead.org> <200406161225.11946.jbarnes@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200406161225.11946.jbarnes@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2004 at 12:25:11PM -0400, Jesse Barnes wrote:
> On Wednesday, June 16, 2004 12:07 pm, Christoph Hellwig wrote:
> > Well, if you want deterministic interrupt latencies you should go for a
> > realtime OS.
> 
> Although I don't want to see another kernel thread added as much as the next 
> guy, I think that minimizing the amount of time that irqs are turned off is 
> probably a good thing in general.  For example, the patch to allow interrupts 
> in spin_lock_irq if the lock is already taken is generally a really good 
> thing, because even though reducing lock contention should be a goal, locks 
> by their very nature are taken sometimes, and allowing other CPUs to get 
> useful work done while they're waiting for it is obviously desirable.
> 
> > I know Linux is the big thing in the industry, but you're 
> > really better off looking for a small Hard RT OS. 
> 
> Sure, for some applications, an RTOS is necessary.  But it seems like keeping 
> latencies down in Linux is a good thing to do nonetheless.
> 
> Can you think of other ways to reduce the length of time that interrupts are 
> disabled during cache reaping?  It seems like the cache_reap loop might be a 
> candidate for reorganization (though that would probably imply other 
> changes).

I have another patch forthcoming that does some reorganizing of the locking.
With the two patches I see substantial improvement.

> 
> Thanks,
> Jesse
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
