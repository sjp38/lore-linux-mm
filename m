Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3D03A6B005A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:14:34 -0400 (EDT)
Date: Fri, 12 Jun 2009 11:14:57 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: slab: setup allocators earlier in the boot sequence
Message-ID: <20090612091457.GF24044@wotan.suse.de>
References: <1244779009.7172.52.camel@pasglop> <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop> <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI> <1244792079.7172.74.camel@pasglop> <1244792745.30512.13.camel@penberg-laptop> <1244796045.7172.82.camel@pasglop> <1244796211.30512.32.camel@penberg-laptop> <1244796837.7172.95.camel@pasglop> <1244797533.30512.35.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1244797533.30512.35.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 12:05:33PM +0300, Pekka Enberg wrote:
> On Fri, 2009-06-12 at 18:53 +1000, Benjamin Herrenschmidt wrote:
> > Now, if you find it a bit too ugly, feel free to rename smellybits to
> > something else and create an accessor function for setting what bits are
> > masked out, but I still believe that the basic idea behind my patch is
> > saner than yours :-)
> 
> It's not the naming I object to but the mechanism because I think is
> open for abuse (think smelly driver playing tricks with it). So I do
> think my patch is the sanest solution here. ;-)
> 
> Nick? Christoph?

I like less overhead of Ben's approach, and I like the slab
allocator being told about this rather than having to deduce
it from that horrible system_state thing.

OTOH, I don't know if it is useful, and is it just to work
around the problem of slab allocators unconditionally doing
the local_irq_enable? Or is it going to be more widely 
useful?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
