Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 46B0B6B0055
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 04:05:04 -0400 (EDT)
Date: Mon, 20 Jul 2009 10:05:02 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC/PATCH] mm: Pass virtual address to [__]p{te,ud,md}_free_tlb()
Message-ID: <20090720080502.GG7298@wotan.suse.de>
References: <20090715074952.A36C7DDDB2@ozlabs.org> <20090715135620.GD7298@wotan.suse.de> <1248073873.13067.31.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1248073873.13067.31.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Hugh Dickins <hugh@tiscali.co.uk>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 20, 2009 at 05:11:13PM +1000, Benjamin Herrenschmidt wrote:
> On Wed, 2009-07-15 at 15:56 +0200, Nick Piggin wrote:
> > > I would like to merge the new support that depends on this in 2.6.32,
> > > so unless there's major objections, I'd like this to go in early during
> > > the merge window. We can sort out separately how to carry the patch
> > > around in -next until then since the powerpc tree will have a dependency
> > > on it.
> > 
> > Can't see any problem with that.
> 
> CC'ing Linus here. How do you want to proceed with that merge ? (IE. so
> far nobody objected to the patch itself)
> 
> IE. The patch affects all archs, though it's a trivial change every
> time, but I'll have stuff in powerpc-next that depends on it, and so I'm
> not sure what the right approach is here. Should I put it in the powerpc
> tree ?
> 
> I also didn't have any formal Ack from anybody, neither mm folks nor
> arch maintainers :-)

Yeah, if you think it helps, Acked-by: Nick Piggin <npiggin@suse.de> is
fine ;)

Unless anybody has other preferences, just send it straight to Linus in
the next merge window -- if any conflicts did come up anyway they would
be trivial. You could just check against linux-next before doing so, and
should see if it is going to cause problems for any arch pull...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
