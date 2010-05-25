Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 62530620202
	for <linux-mm@kvack.org>; Tue, 25 May 2010 10:43:27 -0400 (EDT)
Date: Wed, 26 May 2010 00:43:22 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100525144322.GR5087@laptop>
References: <20100521211452.659982351@quilx.com>
 <20100524070309.GU2516@laptop>
 <alpine.DEB.2.00.1005240852580.5045@router.home>
 <20100525020629.GA5087@laptop>
 <alpine.DEB.2.00.1005250859050.28941@router.home>
 <20100525143409.GP5087@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100525143409.GP5087@laptop>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 12:34:09AM +1000, Nick Piggin wrote:
> On Tue, May 25, 2010 at 09:13:37AM -0500, Christoph Lameter wrote:
> > The queues sacrifice a lot there. The linked list does not allow managing
> > cache cold objects like SLAB does because you always need to touch the
> > object and this will cause regressions against SLAB. I think this is also
> > one of the weaknesses of SLQB.
> 
> But this is just more handwaving. That's what got us into this situation
> we are in now.
> 
> What we know is that SLAB is still used by all high performance
> enterprise distros (and google). And it is used by Altixes in production
> as well as all other large NUMA machines that Linux runs on.
> 
> Given that information, how can you still say that SLUB+more big changes
> is the right way to proceed?

Might I add that once SLAB code is cleaned up, you can always propose
improvements from SLUB or any other ideas for it which we can carefully
test and merge in slowly as bisectable changes to our benchmark
performance slab allocator.

In fact, if you have better ideas in SLEB, I would encourage it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
