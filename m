Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B8EDE6B0082
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 11:16:44 -0400 (EDT)
Date: Fri, 12 Jun 2009 08:16:41 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
In-Reply-To: <Pine.LNX.4.64.0906121328030.32274@melkki.cs.Helsinki.FI>
Message-ID: <alpine.LFD.2.01.0906120809560.3237@localhost.localdomain>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI> <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI> <20090612091002.GA32052@elte.hu> <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com> <20090612100756.GA25185@elte.hu>
 <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com> <20090612101511.GC13607@wotan.suse.de> <Pine.LNX.4.64.0906121328030.32274@melkki.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>



On Fri, 12 Jun 2009, Pekka J Enberg wrote:
> 
> Hmm. This is turning into one epic patch discussion for sure! But here's a 
> patch to do what you suggested. With the amount of patches I am 
> generating, I'm bound to hit the right one sooner or later, no?-)

Ok, this one looks pretty good. I like the statics, and I like how it lets 
each allocator decide what to do.

Small nit: your mm/slab.c patch does an obviously unnecessary mask in:

	cache_alloc_debugcheck_before(cachep, flags & slab_gfp_flags);

but that's stupid, because the bits were already masked earlier.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
