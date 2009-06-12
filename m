Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CB6636B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:43:18 -0400 (EDT)
Subject: Re: slab: setup allocators earlier in the boot sequence
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090612093046.GG24044@wotan.suse.de>
References: <1244792079.7172.74.camel@pasglop>
	 <1244792745.30512.13.camel@penberg-laptop>
	 <20090612075427.GA24044@wotan.suse.de>
	 <1244793592.30512.17.camel@penberg-laptop>
	 <20090612080236.GB24044@wotan.suse.de>
	 <1244793879.30512.19.camel@penberg-laptop>
	 <1244796291.7172.87.camel@pasglop>
	 <84144f020906120149k6cbe5177vef1944d9d216e8b2@mail.gmail.com>
	 <20090612091304.GE24044@wotan.suse.de> <1244798660.7172.102.camel@pasglop>
	 <20090612093046.GG24044@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 12 Jun 2009 19:44:25 +1000
Message-Id: <1244799865.7172.112.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-12 at 11:30 +0200, Nick Piggin wrote:
> On Fri, Jun 12, 2009 at 07:24:20PM +1000, Benjamin Herrenschmidt wrote:
> > 
> > > It's OK. I'd make it gfp_notsmellybits, and avoid the ~.
> > > And read_mostly.
> > 
> > read_mostly is fine. gfp_notsmellybits isn't a nice name :-) Make it
> > gfp_allowedbits then. I did it backward on purpose though as the risk of
> > "missing" bits here (as we may add new ones) is higher and it seemed to
> > me generally simpler to just explicit spell out the ones to forbid
> > (also, on powerpc,  &~ is one instruction :-)
> 
> But just do the ~ in the assignment. No missing bits :)

Heh, ok.
> Yeah but it doesn't do it in the page allocator so it isn't
> really useful as a general allocator flags tweak. ATM it only
> helps this case of slab allocator hackery.

I though I did it in page_alloc.c too but I'm happy to be told what I
missed :-) The intend is certainly do have a general allocator flag
tweak.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
