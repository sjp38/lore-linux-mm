Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 911A26B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 16:30:34 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so2979304pad.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 13:30:33 -0700 (PDT)
Date: Fri, 28 Sep 2012 13:30:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <0000013a0d36b332-44a8ef43-b881-4267-bb4b-f2e441ae185c-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1209281326070.21335@chino.kir.corp.google.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com>
 <0000013a03150b18-b7c1bfbe-967f-4c33-86e0-f3ca344706cd-000000@email.amazonses.com> <alpine.DEB.2.00.1209261810180.7072@chino.kir.corp.google.com> <0000013a0804637a-82ca7649-bc6c-42ef-9a2c-e79b63f47a23-000000@email.amazonses.com>
 <alpine.DEB.2.00.1209271551220.13360@chino.kir.corp.google.com> <0000013a0d36b332-44a8ef43-b881-4267-bb4b-f2e441ae185c-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 28 Sep 2012, Christoph Lameter wrote:

> > No, it's implementation defined so it shouldn't be in kmem_cache_create(),
> > it should be in __kmem_cache_create()
> 
> The flags are standardized between allocators. We carve out a couple of
> bits here that can be slab specific.
> 

That's true today, it won't be true in a week.

> > I'm referring to additional slab allocators that will be proposed for
> > inclusion shortly.
> 
> I am sorry but we cannot consider something that has not been discussed
> and publicly reviewed on the mailing list before. We have no way to
> understand your rationales at this point and it would take quite some time
> to review a new allocator. I would at least have expected the design of
> the allocator to be discussed on linux-mm. Nothing of that nature has
> happened as far as I can tell.
> 

Nobody here is disagreeing that the patch here is fine for slab, slub, 
and slob as they are currently implemented.  I'm simply trying to avoid 
ripping it out later and asking Glauber to consider something else that 
achieves what he needs.  There is, until this patch, no requirement 
anywhere that the flags passed to kmem_cache_create() may not be extended 
for allocator-specific behavior and I'd prefer to avoid adding such a 
specification unless absolutely necessary; in this case, there is an 
alternative that I've already outlined and it seems like Glauber is 
comfortable with using.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
