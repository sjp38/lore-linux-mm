Date: Sat, 29 Sep 2007 15:08:36 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] splice mmap_sem deadlock
Message-ID: <20070929130836.GB14159@wotan.suse.de>
References: <20070928160035.GD12538@wotan.suse.de> <20070928173144.GA11717@kernel.dk> <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 28, 2007 at 11:10:34AM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 28 Sep 2007, Jens Axboe wrote:
> > 
> > It does looks suspicious. It was actually Linus who originally suggested
> > this approach and wrote that comment - Linus?
> 
> Well, it used to be true, long time ago. It probably was still true in the 
> original splice patch back way back when. But yeah, rwsemaphores broke 
> that (very useful) trick in the name of fairness ;(

You might be thinking about rwlocks as well, where it still is true AFAIK.

The rwsem fairness I think is pretty critical for it's most prominent
consumer (ie. mmap_sem), because read sides can be very long and frequent
with a lot of concurrency (it would be easy to starve the write side).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
