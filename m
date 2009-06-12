Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 74C7C6B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 17:41:37 -0400 (EDT)
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
 suspending
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090612083005.56336219.akpm@linux-foundation.org>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI>
	 <20090612091002.GA32052@elte.hu>
	 <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
	 <20090612100756.GA25185@elte.hu>
	 <84144f020906120311x7c7dd628s82e3ca9a840f9890@mail.gmail.com>
	 <1244805060.7172.126.camel@pasglop>
	 <1244806440.30512.51.camel@penberg-laptop>
	 <20090612083005.56336219.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Sat, 13 Jun 2009 07:42:36 +1000
Message-Id: <1244842956.23936.0.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-12 at 08:30 -0700, Andrew Morton wrote:
> On Fri, 12 Jun 2009 14:34:00 +0300 Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> 
> > +static gfp_t slab_gfp_mask __read_mostly = __GFP_BITS_MASK & ~__GFP_WAIT;
> 
> It'd be safer and saner to disable __GFP_FS and __GFP_IO as well.

Right. That's what my original patch does in fact. I also re-enabled
them all together but in that case, it might be better to re-enable FS
and IO later, I'll let experts decide.
 
> Having either of those flags set without __GFP_WAIT is a somewhat
> self-contradictory thing and there might be code under reclaim which
> assumes that __GFP_FS|__GFP_IO implies __GFP_WAIT.
> 
> <wonders why mempool_alloc() didn't clear __GFP_FS>

Cheers,
Ben.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
