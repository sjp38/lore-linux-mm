Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 178976B0085
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 00:40:40 -0400 (EDT)
Date: Thu, 25 Jun 2009 06:41:55 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or suspending
Message-ID: <20090625044155.GC23949@wotan.suse.de>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI> <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI> <20090612091002.GA32052@elte.hu> <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com> <20090612100756.GA25185@elte.hu> <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com> <1244805060.7172.126.camel@pasglop> <1244806440.30512.51.camel@penberg-laptop> <20090612083005.56336219.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090612083005.56336219.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 08:30:05AM -0700, Andrew Morton wrote:
> On Fri, 12 Jun 2009 14:34:00 +0300 Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> 
> > +static gfp_t slab_gfp_mask __read_mostly = __GFP_BITS_MASK & ~__GFP_WAIT;
> 
> It'd be safer and saner to disable __GFP_FS and __GFP_IO as well. 
> Having either of those flags set without __GFP_WAIT is a somewhat
> self-contradictory thing and there might be code under reclaim which
> assumes that __GFP_FS|__GFP_IO implies __GFP_WAIT.
> 
> <wonders why mempool_alloc() didn't clear __GFP_FS>

Maybe we never get there if __GFP_WAIT is clear? It would be neater
if it did clear __GFP_FS, though...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
