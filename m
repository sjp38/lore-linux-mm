Message-ID: <37CBB49E.C52C5D99@switchboard.ericsson.se>
Date: Tue, 31 Aug 1999 12:55:26 +0200
From: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>
MIME-Version: 1.0
Subject: Re: accel handling
References: <Pine.GSO.4.10.9908302023470.15357-100000@mail1.sas.upenn.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vladimir Dergachev <vdergach@sas.upenn.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Vladimir Dergachev wrote:
> 
> On Mon, 30 Aug 1999, Stephen C. Tweedie wrote:
> 
> > Hi,
> > The only way to do it is to flip page tables while the accel engine is
> > running.  You may want to restore it on demand by trapping the page
> > fault on the framebuffer and stalling until the accel lock is released.
> > This can be done, but it is really expensive: you are doing a whole pile
> > of messy VM operations every time you want to trigger the accel engine
> > (any idea how often you want to flip the protection, btw?)
[snip]
> What about forbidding concurrency for the processes that have mmapped
> the framebuffer/accelerator ? Say assign all of them to one(or same) cpu
> permanently.

Not an acceptable solution. You may have several threads clone()d off
after the framebuffer have been mapped, and they may not do anything
related to graphics.

But by only re-mapping the framebuffer on demand as Stephen said you
can avoid repeatedly un-mapping the framebuffer for processes/threads
that doesn't use it.

//Marcus
-- 
-------------------------------+------------------------------------
        Marcus Sundberg        | http://www.stacken.kth.se/~mackan/
 Royal Institute of Technology |       Phone: +46 707 295404
       Stockholm, Sweden       |   E-Mail: mackan@stacken.kth.se
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
