Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 032E66B0082
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 04:19:55 -0400 (EDT)
Date: Fri, 12 Jun 2009 10:20:29 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: slab: setup allocators earlier in the boot sequence
Message-ID: <20090612082029.GC24044@wotan.suse.de>
References: <1244779009.7172.52.camel@pasglop> <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop> <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI> <1244792079.7172.74.camel@pasglop> <1244792745.30512.13.camel@penberg-laptop> <20090612075427.GA24044@wotan.suse.de> <1244793592.30512.17.camel@penberg-laptop> <20090612080236.GB24044@wotan.suse.de> <1244793879.30512.19.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1244793879.30512.19.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 11:04:39AM +0300, Pekka Enberg wrote:
> Hi Nick,
> 
> On Fri, 2009-06-12 at 10:02 +0200, Nick Piggin wrote:
> > Fair enough, but this can be done right down in the synchronous
> > reclaim path in the page allocator. This will catch more cases
> > of code using the page allocator directly, and should be not
> > as hot as the slab allocator.
> 
> So you want to push the local_irq_enable() to the page allocator too? We

Well it would be nice to expose some page allocator functionality
at a bit lower level, yes. Like another thing is to avoid atomic
refcounting when there is no need for it (eg. in allocations for slab).


> can certainly do that but I think we ought to wait for Andrew to merge
> Mel's patches to mainline first, OK?

Sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
