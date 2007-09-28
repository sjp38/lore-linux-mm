Date: Fri, 28 Sep 2007 20:15:14 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [patch] splice mmap_sem deadlock
Message-ID: <20070928181513.GB11717@kernel.dk>
References: <20070928160035.GD12538@wotan.suse.de> <20070928173144.GA11717@kernel.dk> <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 28 2007, Linus Torvalds wrote:
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

It actually looks like it was buggy from day 1 there, unfortunately. The
code is from april 2006 and used down_read() even then. So can you apply
Nicks patch, add my

Acked-by: Jens Axboe <jens.axboe@oracle.com>

if you want.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
