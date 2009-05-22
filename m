Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 38E5B6B004D
	for <linux-mm@kvack.org>; Fri, 22 May 2009 09:35:53 -0400 (EDT)
Date: Fri, 22 May 2009 14:37:18 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
 allocator
Message-ID: <20090522143718.75790c94@lxorguk.ukuu.org.uk>
In-Reply-To: <20090522112236.GA13971@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com>
	<1242852158.6582.231.camel@laptop>
	<4A15A69F.3040604@redhat.com>
	<20090521202628.39625a5d@lxorguk.ukuu.org.uk>
	<20090521195603.GK10756@oblivion.subreption.com>
	<20090521214713.65adfd6e@lxorguk.ukuu.org.uk>
	<20090521214638.GL10756@oblivion.subreption.com>
	<20090521234755.31ab1c3a@lxorguk.ukuu.org.uk>
	<20090522112236.GA13971@oblivion.subreption.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

> Definitely, but there's no need for this at all. If you want to target
> certain sensitive data, just grep the variable names in the
> world-readable System.map of your distribution of choice.

A lot of dynamic data will not be findable by System.map but its
certainly findable if you've got a "look mummy this one is stamped
confidential" flag then it becomes easy to find.

> > Obvious candidates would be AGPGart, DRI buffers, DMA lowmem buffering,
> > pad buffers - I dont think they clear all cases and in some cases
> > (notably DRI) there is data that is potentially "secret" stored in the
> > video RAM.
> 
> Overkill. Again, you really don't need to scan memory for anything. Much
> less video memory. If you already have CAP_SYS_RAWIO, you have more
> reliable and easier techniques to intercept information.

If you are working to clear memory then your model is totally flawed
because a lot of memory you might want to handle this way is never
deallocated.

> > You can also extract bits of data post clear out of fascinating corners
> > like the debug interfaces to FIFOs on I/O controllers. There are also a
> > large category of buffers that don't get freed/reallocated notably ring
> > buffers for networking, and tty ring buffers which are mostly not freed
> > for the lifetime of the device (ie forever). Cleaning all RAM as an
> > option on S2D and shutdown would be the only real way you'd fix that.
> 
> One of the patches takes care of tty buffer management to adopt the new
> flag. The only real way to solve the lengthy list of security risks
> coming along suspend-to-disk approaches is to simply disable
> suspend-to-disk altogether.

Which is a rather peculiar viewpoint you hold that I would disagree with
entirely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
