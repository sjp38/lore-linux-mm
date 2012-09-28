Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id CF3E96B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:12:55 -0400 (EDT)
Date: Fri, 28 Sep 2012 14:12:54 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <alpine.DEB.2.00.1209271552350.13360@chino.kir.corp.google.com>
Message-ID: <0000013a0d390e11-03bf6f97-a8b7-4229-9f69-84aa85795b7e-000000@email.amazonses.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com>
 <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com> <5063F94C.4090600@parallels.com> <alpine.DEB.2.00.1209271552350.13360@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 27 Sep 2012, David Rientjes wrote:

> On Thu, 27 Sep 2012, Glauber Costa wrote:
>
> > But I still don't see the big reason for your objection. If other
> > allocator start using those bits, they would not be passed to
> > kmem_cache_alloc anyway, right? So what would be the big problem in
> > masking them out before it?
> >
>
> A slab allocator implementation may allow for additional bits that are
> currently not used or used for internal purposes by the current set of
> slab allocators to be passed in the unsigned long to kmem_cache_create()
> that would be a no-op on other allocators.  It's implementation defined,
> so this masking should be done in the implementation, i.e.
> __kmem_cache_create().

Ok we can do that in the future. There is nothing in this patch that
prevents that from happening. It would affect the memcg implementation
because they can no longer simply grab the flags and pass them in for
creating another slab.

> For context, as many people who attended the kernel summit and LinuxCon
> are aware, a new slab allocator is going to be proposed soon that actually
> uses additional bits that aren't defined for all slab allocators.  My
> opinion is that leaving unused bits and reserved bits to the
> implementation is the best software engineering practice.

Could you please come out with the new allocator and post some patchsets?

We can extend the number of flags reserved if necessary but we really need
to see the source for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
