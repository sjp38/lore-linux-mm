From: Jesse Barnes <jbarnes@engr.sgi.com>
Subject: Re: [PATCH]: Option to run cache reap in thread mode
Date: Wed, 16 Jun 2004 12:25:11 -0400
References: <20040616142413.GA5588@sgi.com> <20040616160355.GA5963@sgi.com> <20040616160714.GA14413@infradead.org>
In-Reply-To: <20040616160714.GA14413@infradead.org>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200406161225.11946.jbarnes@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wednesday, June 16, 2004 12:07 pm, Christoph Hellwig wrote:
> Well, if you want deterministic interrupt latencies you should go for a
> realtime OS.

Although I don't want to see another kernel thread added as much as the next 
guy, I think that minimizing the amount of time that irqs are turned off is 
probably a good thing in general.  For example, the patch to allow interrupts 
in spin_lock_irq if the lock is already taken is generally a really good 
thing, because even though reducing lock contention should be a goal, locks 
by their very nature are taken sometimes, and allowing other CPUs to get 
useful work done while they're waiting for it is obviously desirable.

> I know Linux is the big thing in the industry, but you're 
> really better off looking for a small Hard RT OS. 

Sure, for some applications, an RTOS is necessary.  But it seems like keeping 
latencies down in Linux is a good thing to do nonetheless.

Can you think of other ways to reduce the length of time that interrupts are 
disabled during cache reaping?  It seems like the cache_reap loop might be a 
candidate for reorganization (though that would probably imply other 
changes).

Thanks,
Jesse
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
