Date: Fri, 28 Sep 2007 11:10:34 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] splice mmap_sem deadlock
In-Reply-To: <20070928173144.GA11717@kernel.dk>
Message-ID: <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org>
References: <20070928160035.GD12538@wotan.suse.de>
 <20070928173144.GA11717@kernel.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, 28 Sep 2007, Jens Axboe wrote:
> 
> It does looks suspicious. It was actually Linus who originally suggested
> this approach and wrote that comment - Linus?

Well, it used to be true, long time ago. It probably was still true in the 
original splice patch back way back when. But yeah, rwsemaphores broke 
that (very useful) trick in the name of fairness ;(

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
