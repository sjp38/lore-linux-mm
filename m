Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AF6056B0088
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 20:27:34 -0400 (EDT)
Date: Sat, 20 Jun 2009 02:28:17 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
	suspending
Message-ID: <20090620002817.GA2524@elf.ucw.cz>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI> <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI> <20090619145913.GA1389@ucw.cz> <1245450449.16880.10.camel@pasglop> <20090619232336.GA2442@elf.ucw.cz> <1245455409.16880.15.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1245455409.16880.15.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, npiggin@suse.de, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat 2009-06-20 09:50:09, Benjamin Herrenschmidt wrote:
> On Sat, 2009-06-20 at 01:23 +0200, Pavel Machek wrote:
> > > No. First, code that assumes GFP_KERNEL don't fail is stupid. Any
> > > allocation should always be assumed to potentially fail.
> > 
> > Stupid, yes. Uncommon? Not sure.
> 
> A lot less than it used to be, we've been fixing those by the truckload
> over the past few years. But again, if allocations start failing that
> early at boot, you are likely to be doomed anyway. Still, better to do
> proper error handling, and I think we -mostly- do (ok, not -always-).
> 
> > > Then, if you start failing allocations at boot time, then you aren't
> > > going anywhere are you ?
> > 
> > Exactly. So boot code should have access to all the memory, right?
> > Setting some aside for GFP_ATOMIC does not make sense in that context.
> 
> I'm not certain what you mean here. If you're going to hit the atomic
> reserve that early, you aren't going anywhere neither :-)
> 
> Is there any real problem you are trying to solve here or is it all
> just academic ?

Academic for boot, probably real for suspend/resume. There the atomic
reserves could matter because the memory can be pretty full when you
start suspend.
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
