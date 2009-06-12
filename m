Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9136B0082
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 04:41:36 -0400 (EDT)
Subject: Re: slab: setup allocators earlier in the boot sequence
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090612075427.GA24044@wotan.suse.de>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>
	 <1244770230.7172.4.camel@pasglop> <1244779009.7172.52.camel@pasglop>
	 <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop>
	 <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
	 <1244792079.7172.74.camel@pasglop>
	 <1244792745.30512.13.camel@penberg-laptop>
	 <20090612075427.GA24044@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 12 Jun 2009 18:42:41 +1000
Message-Id: <1244796161.7172.84.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, cl@linux-foundation.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>


> > Sure, I think we can do what you want with the patch below.
> 
> I don't really like adding branches to slab allocator like this.
> init code all needs to know what services are available, and
> this includes the scheduler if it wants to do anything sleeping
> (including sleeping slab allocations).
> 
> Core mm code is the last place to put in workarounds for broken
> callers...

Right, and that's also a reason why I decided for having that
"smellybits" approach since applying a mask is going to be a lot less
cycle consuming than a conditional branch (especially on small embedded
CPUs, the conditional branch on modern stuff should be be reasonably
harmless).

Nick, have you seen my patch ? What do you think ?

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
