Date: Mon, 30 Aug 1999 20:28:18 -0400 (EDT)
From: Vladimir Dergachev <vdergach@sas.upenn.edu>
Subject: Re: accel handling
In-Reply-To: <14282.37533.98879.414300@dukat.scot.redhat.com>
Message-ID: <Pine.GSO.4.10.9908302023470.15357-100000@mail1.sas.upenn.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>, linux-mm@kvack.org, James Simmons <jsimmons@edgeglobal.com>
List-ID: <linux-mm.kvack.org>


On Mon, 30 Aug 1999, Stephen C. Tweedie wrote:

> Hi,
> The only way to do it is to flip page tables while the accel engine is
> running.  You may want to restore it on demand by trapping the page
> fault on the framebuffer and stalling until the accel lock is released.
> This can be done, but it is really expensive: you are doing a whole pile
> of messy VM operations every time you want to trigger the accel engine
> (any idea how often you want to flip the protection, btw?)
> 
> So you are talking several system calls, SMP inter-processor interrupts
> and piles of VM page twiddling every time you want to claim and release
> the core engine.  Sorry, folks, but there's no way of avoiding the
> conclusion that this is going to be expensive.  In the single-CPU or
> single-thread case the cost can be kept under control, but it is not
> going to be cheap.
> 

What about forbidding concurrency for the processes that have mmapped
the framebuffer/accelerator ? Say assign all of them to one(or same) cpu
permanently. If someone really wants it's process to run on more than one
cpu (I don't think Linux does this currently) they had to do some extra
work anyway.

                           Vladimir Dergachev 

> --Stephen
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
