Date: Sun, 30 Sep 2007 22:12:44 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] splice mmap_sem deadlock
Message-ID: <20070930201244.GA5756@wotan.suse.de>
References: <20070928173144.GA11717@kernel.dk> <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org> <20070928181513.GB11717@kernel.dk> <alpine.LFD.0.999.0709281120220.3579@woody.linux-foundation.org> <20070928193017.GC11717@kernel.dk> <alpine.LFD.0.999.0709281247490.3579@woody.linux-foundation.org> <20070929131043.GC14159@wotan.suse.de> <20070930064646.GF11717@kernel.dk> <20070930120701.GC7697@wotan.suse.de> <20070930200552.GJ11717@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070930200552.GJ11717@kernel.dk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 30, 2007 at 10:05:52PM +0200, Jens Axboe wrote:
> On Sun, Sep 30 2007, Nick Piggin wrote:
> > 
> > You already have much more PIPE_BUFFERS stuff on the stack. If it
> > gets much bigger, you should dynamically allocate all this anyway, no?
> 
> Yep, but then it's one more item that has to be dynamically allocated.

Just have a struct for a tuple of itmes for each pipe buf to allocate and
you'll never notice ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
