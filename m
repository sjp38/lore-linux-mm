Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 73E786B0055
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 06:14:48 -0400 (EDT)
Date: Fri, 12 Jun 2009 12:15:11 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or suspending
Message-ID: <20090612101511.GC13607@wotan.suse.de>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI> <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI> <20090612091002.GA32052@elte.hu> <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com> <20090612100756.GA25185@elte.hu> <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 01:11:52PM +0300, Pekka Enberg wrote:
> Hi Ingo,
> 
> On Fri, Jun 12, 2009 at 1:07 PM, Ingo Molnar<mingo@elte.hu> wrote:
> > IMHO such invisible side-channels modifying the semantics of GFP
> > flags is a bit dubious.
> >
> > We could do GFP_INIT or GFP_BOOT. These can imply other useful
> > modifiers as well: panic-on-failure for example. (this would clean
> > up a fair amount of init code that currently checks for an panics on
> > allocation failure.)
> 
> OK, but that means we need to fix up every single caller. I'm fine
> with that but Ben is not. As I am unable to test powerpc here, I am
> inclined to just merge Ben's patch as "obviously correct".

I agree with Ingo though that exposing it as a gfp modifier is
not so good. I just like the implementation to mask off GFP_WAIT
better, and also prefer not to test system state, but have someone
just call into slab to tell it not to unconditionally enable
interrupts.

> That does not mean we can't introduce GFP_BOOT later on if we want to. Hmm?

Yes, with sufficient warnings in place, I don't think it should be
too error prone to clean up remaining code over the course of
a few releases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
